import SwiftUI
import SwiftData
import Charts
import KeyboardShortcuts

struct MetricsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    // Remove licenseViewModel for free fork version

    var body: some View {
        VStack {
            // Remove all trial messages for free fork version

            MetricsContent(
                modelContext: modelContext
            )
        }
        .background(Color(.controlBackgroundColor))
    }
}
