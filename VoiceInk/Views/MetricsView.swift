import SwiftUI
import SwiftData
import Charts

struct MetricsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var recordingShortcutManager: RecordingShortcutManager

    var body: some View {
        VStack {
            // Remove all trial messages for free fork version

            MetricsContent(
                modelContext: modelContext,
                licenseState: .licensed
            )
        }
        .background(Color(.controlBackgroundColor))
    }
}
