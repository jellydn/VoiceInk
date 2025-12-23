import SwiftUI
import SwiftData

// Simplified ViewType for free fork
enum ViewType: String, CaseIterable, Identifiable {
    case metrics = "Dashboard"
    case transcribeAudio = "Transcribe Audio"
    case history = "History"
    case models = "AI Models"
    case enhancement = "Enhancement"
    case powerMode = "Power Mode"
    case permissions = "Permissions"
    case audioInput = "Audio Input"
    case dictionary = "Dictionary"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .metrics: return "gauge.medium"
        case .transcribeAudio: return "waveform.circle.fill"
        case .history: return "doc.text.fill"
        case .models: return "brain.head.profile"
        case .enhancement: return "wand.and.stars"
        case .powerMode: return "sparkles.square.fill.on.square"
        case .permissions: return "shield.fill"
        case .audioInput: return "mic.fill"
        case .dictionary: return "character.book.closed.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = false
    @State private var selectedView: ViewType? = .metrics
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    private var visibleViewTypes: [ViewType] {
        ViewType.allCases.filter { viewType in
            if viewType == .powerMode {
                return powerModeUIFlag
            }
            return true
        }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedView) {
                Section {
                    // App Header
                    HStack(spacing: 6) {
                        if let appIcon = NSImage(named: "AppIcon") {
                            Image(nsImage: appIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                                .cornerRadius(8)
                        }

                        Text("VoiceInk Free")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                ForEach(visibleViewTypes) { viewType in
                    Section {
                        NavigationLink(destination: detailView(for: viewType), value: viewType) {
                            HStack(spacing: 12) {
                                Image(systemName: viewType.icon)
                                    .font(.system(size: 18, weight: .medium))
                                    .frame(width: 24, height: 24)

                                Text(viewType.rawValue)
                                    .font(.system(size: 14, weight: .medium))

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 2)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                    }

                    if selectedView != nil {
                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)

            // Detail View
            Group {
                if let selectedView = selectedView {
                    detailView(for: selectedView)
                } else {
                    Text("Welcome to VoiceInk Free")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 500)
            .background(Color(.controlBackgroundColor))
        }
        .onAppear {
            selectedView = .metrics
        }
    }
    
    @ViewBuilder
    private func detailView(for viewType: ViewType) -> some View {
        switch viewType {
        case .metrics:
            Text("Dashboard")
                .font(.title)
                .padding()
        case .transcribeAudio:
            Text("Transcribe Audio")
                .font(.title)
                .padding()
        case .history:
            Text("History")
                .font(.title)
                .padding()
        case .models:
            Text("AI Models")
                .font(.title)
                .padding()
        case .enhancement:
            Text("Enhancement")
                .font(.title)
                .padding()
        case .powerMode:
            Text("Power Mode")
                .font(.title)
                .padding()
        case .permissions:
            Text("Permissions")
                .font(.title)
                .padding()
        case .audioInput:
            Text("Audio Input")
                .font(.title)
                .padding()
        case .dictionary:
            Text("Dictionary")
                .font(.title)
                .padding()
        case .settings:
            Text("Settings")
                .font(.title)
                .padding()
        }
    }
}