import FluidAudio
import Foundation
import os

protocol UnifiedModel: AnyObject, Sendable {
    func loadModels(from directory: URL) async throws
    func reset() async throws
    func cleanup() async
}

extension UnifiedAsrManager: UnifiedModel {}
extension StreamingUnifiedAsrManager: UnifiedModel {}

/// Retains a model and gives one recording at a time access to its mutable state.
@MainActor
final class UnifiedModelCache<Manager: UnifiedModel> {
    private var modelTask: Task<Manager, Error>?
    private let access = UnifiedModelAccess()
    private let makeManager: () -> Manager
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "UnifiedModelCache")

    init(makeManager: @escaping () -> Manager) {
        self.makeManager = makeManager
    }

    func getOrLoad() async throws -> Manager {
        // The completed task also retains its model for subsequent recordings.
        if let modelTask { return try await modelTask.value }
        let task = Task { @MainActor in
            let loaded = makeManager()
            let start = Date()
            do {
                try await loaded.loadModels(from: FluidAudioModelManager.parakeetUnifiedCacheDirectory())
            } catch {
                modelTask = nil
                await loaded.cleanup()
                throw error
            }
            logger.notice("Unified \(String(describing: Manager.self), privacy: .public) loaded in \(Date().timeIntervalSince(start), format: .fixed(precision: 3), privacy: .public)s")
            return loaded
        }
        modelTask = task
        return try await task.value
    }

    func acquire() async throws -> Manager {
        await access.lock()
        do {
            try Task.checkCancellation()
            let loaded = try await getOrLoad()
            try Task.checkCancellation()
            try await reset(loaded)
            try Task.checkCancellation()
            return loaded
        } catch {
            access.unlock()
            throw error
        }
    }

    func release(_ usedManager: Manager) async {
        try? await reset(usedManager)
        access.unlock()
    }

    func withModel<Result>(_ operation: (Manager) async throws -> Result) async throws -> Result {
        let loaded = try await acquire()
        do {
            let result = try await operation(loaded)
            try Task.checkCancellation()
            await release(loaded)
            return result
        } catch {
            await release(loaded)
            throw error
        }
    }

    private func reset(_ usedManager: Manager) async throws {
        do {
            try await usedManager.reset()
        } catch {
            modelTask = nil
            await usedManager.cleanup()
            logger.error("Unified reset failed: \(error, privacy: .public)")
            throw error
        }
    }
}

/// Holds access across async inference; actor isolation alone allows reentrancy.
@MainActor
final class UnifiedModelAccess {
    private var isLocked = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func lock() async {
        if isLocked {
            await withCheckedContinuation { waiters.append($0) }
        } else {
            isLocked = true
        }
    }

    func unlock() {
        if waiters.isEmpty {
            isLocked = false
        } else {
            waiters.removeFirst().resume()
        }
    }
}
