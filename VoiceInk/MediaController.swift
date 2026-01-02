import AppKit
import Combine
import Foundation
import SwiftUI
import CoreAudio

/// Controls system audio management during recording
class MediaController: ObservableObject {
    static let shared = MediaController()
    private var didMuteAudio = false
    private var wasAudioMutedBeforeRecording = false
    private var currentMuteTask: Task<Bool, Never>?
    private var unmuteTask: Task<Void, Never>?

    @Published var isSystemMuteEnabled: Bool = UserDefaults.standard.bool(forKey: "isSystemMuteEnabled") {
        didSet {
            UserDefaults.standard.set(isSystemMuteEnabled, forKey: "isSystemMuteEnabled")
        }
    }

    @Published var audioResumptionDelay: Double = UserDefaults.standard.double(forKey: "audioResumptionDelay") {
        didSet {
            UserDefaults.standard.set(audioResumptionDelay, forKey: "audioResumptionDelay")
        }
    }

    private init() {
        if !UserDefaults.standard.contains(key: "isSystemMuteEnabled") {
            UserDefaults.standard.set(true, forKey: "isSystemMuteEnabled")
        }

        if !UserDefaults.standard.contains(key: "audioResumptionDelay") {
            UserDefaults.standard.set(0.0, forKey: "audioResumptionDelay")
        }
    }
    
    private func isSystemAudioMuted() -> Bool {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "output muted of (get volume settings)"]
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return output == "true"
            }
        } catch { }
        
        return false
    }
    
    func muteSystemAudio() async -> Bool {
        guard isSystemMuteEnabled else { return false }

        unmuteTask?.cancel()
        unmuteTask = nil
        currentMuteTask?.cancel()

        let task = Task<Bool, Never> {
            wasAudioMutedBeforeRecording = isSystemAudioMuted()

            if wasAudioMutedBeforeRecording {
                return true
            }

            let success = executeAppleScript(command: "set volume with output muted")
            didMuteAudio = success
            return success
        }

        currentMuteTask = task
        return await task.value
    }
    
    func unmuteSystemAudio() async {
        guard isSystemMuteEnabled else { return }

        if let muteTask = currentMuteTask {
            _ = await muteTask.value
        }

        let delay = audioResumptionDelay
        let shouldUnmute = didMuteAudio && !wasAudioMutedBeforeRecording

        let task = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            if Task.isCancelled {
                return
            }

            if shouldUnmute {
                _ = executeAppleScript(command: "set volume without output muted")
            }

            didMuteAudio = false
            currentMuteTask = nil
        }

        unmuteTask = task
        await task.value
    }
    
    private func executeAppleScript(command: String) -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }

    var isSystemMuteEnabled: Bool {
        get { bool(forKey: "isSystemMuteEnabled") }
        set { set(newValue, forKey: "isSystemMuteEnabled") }
    }

    var audioResumptionDelay: Double {
        get { double(forKey: "audioResumptionDelay") }
        set { set(newValue, forKey: "audioResumptionDelay") }
    }
}
