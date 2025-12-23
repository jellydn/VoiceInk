import SwiftUI
import SwiftData

struct MetricsContent: View {
    let transcriptions: [Transcription]
    @State private var showKeyboardShortcuts = false

    var body: some View {
        Group {
            if transcriptions.isEmpty {
                emptyStateView
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 24) {
                            heroSection
                            metricsSection
                            HStack(alignment: .top, spacing: 18) {
                                HelpAndResourcesSection()
                                // Remove promotions for free fork
                            }

                            Spacer(minLength: 20)

                            HStack {
                                Spacer()
                                footerActionsView
                            }
                        }
                        .frame(minHeight: geometry.size.height - 56)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("No Transcriptions Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start your first transcription to see your metrics here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            Text("Welcome to VoiceInk Free")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("All premium features unlocked for unlimited use")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var metricsSection: some View {
        VStack(spacing: 20) {
let totalTranscriptions = transcriptions.count
        let totalDuration = transcriptions.reduce(0.0) { $0 + $1.duration }
            let avgDuration = totalTranscriptions > 0 ? totalDuration / Double(totalTranscriptions) : 0
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                metricCard(
                    icon: "doc.text.fill",
                    title: "Total Transcriptions",
                    value: "\(totalTranscriptions)",
                    color: .blue
                )
                
                metricCard(
                    icon: "clock.fill",
                    title: "Total Duration",
                    value: formatDuration(totalDuration),
                    color: .green
                )
                
                metricCard(
                    icon: "waveform.circle.fill",
                    title: "Average Duration",
                    value: formatDuration(avgDuration),
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func metricCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }
    
    private var footerActionsView: some View {
        HStack(spacing: 16) {
            Button(action: {
                showKeyboardShortcuts = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "keyboard.fill")
                    Text("Keyboard Shortcuts")
                }
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showKeyboardShortcuts) {
            // Simple keyboard shortcuts view
            VStack(spacing: 20) {
                Text("Keyboard Shortcuts")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    shortcutRow(key: "⌘⇧V", description: "Toggle Mini Recorder")
                    shortcutRow(key: "⌘⇧T", description: "Transcribe Audio")
                    shortcutRow(key: "⌘,", description: "Start Recording")
                }
            }
            .padding()
        }
    }
    
    private func shortcutRow(key: String, description: String) -> some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
            Spacer()
            Text(description)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Simple HelpAndResourcesSection replacement
struct HelpAndResourcesSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Help & Resources")
                .font(.headline)
            
            VStack(spacing: 12) {
                resourceLink(title: "Documentation", icon: "book.fill")
                resourceLink(title: "Support", icon: "questionmark.circle.fill")
                resourceLink(title: "GitHub", icon: "link.circle.fill")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }
    
    private func resourceLink(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}