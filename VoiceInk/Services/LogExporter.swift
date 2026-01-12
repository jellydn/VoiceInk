import Foundation
import OSLog

/// Utility class for exporting app logs since launch for diagnostic purposes
final class LogExporter {
    static let shared = LogExporter()

    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "LogExporter")
    private let subsystem = "com.prakashjoshipax.voiceink"

    /// Timestamp when the app was launched
    let launchDate: Date

    private init() {
        self.launchDate = Date()
        logger.notice("🎙️ LogExporter initialized, launch timestamp recorded")
    }

    /// Exports logs since app launch to a file and returns the file URL
    func exportLogs() async throws -> URL {
        logger.notice("🎙️ Starting log export since \(self.launchDate)")

        let logs = try await fetchLogsSinceLaunch()

        let fileURL = try saveLogsToFile(logs)

        logger.notice("🎙️ Log export completed: \(fileURL.path)")

        return fileURL
    }

    /// Fetches logs from OSLogStore since app launch
    private func fetchLogsSinceLaunch() async throws -> [String] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)

        // Get logs since launch
        let position = store.position(date: launchDate)

        // Create predicate to filter by our subsystem
        let predicate = NSPredicate(format: "subsystem == %@", subsystem)

        let entries = try store.getEntries(at: position, matching: predicate)

        var logLines: [String] = []

        // Add header
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        logLines.append("=== VoiceInk Diagnostic Logs ===")
        logLines.append("Export Date: \(dateFormatter.string(from: Date()))")
        logLines.append("App Launch: \(dateFormatter.string(from: launchDate))")
        logLines.append("Subsystem: \(subsystem)")
        logLines.append("================================")
        logLines.append("")

        for entry in entries {
            guard let logEntry = entry as? OSLogEntryLog else { continue }

            let timestamp = dateFormatter.string(from: logEntry.date)
            let level = logLevelString(logEntry.level)
            let category = logEntry.category
            let message = logEntry.composedMessage

            logLines.append("[\(timestamp)] [\(level)] [\(category)] \(message)")
        }

        if logLines.count <= 6 { // Only header lines
            logLines.append("No logs found since app launch.")
        }

        return logLines
    }

    /// Converts OSLogEntryLog.Level to a readable string
    private func logLevelString(_ level: OSLogEntryLog.Level) -> String {
        switch level {
        case .undefined:
            return "UNDEFINED"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .notice:
            return "NOTICE"
        case .error:
            return "ERROR"
        case .fault:
            return "FAULT"
        @unknown default:
            return "UNKNOWN"
        }
    }

    /// Saves logs to a file in the Downloads folder
    private func saveLogsToFile(_ logs: [String]) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())

        let fileName = "VoiceInk_Logs_\(timestamp).log"

        // Get Downloads folder
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "LogExporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Downloads directory unavailable"])
        }
        let fileURL = downloadsURL.appendingPathComponent(fileName)

        let content = logs.joined(separator: "\n")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }
}
