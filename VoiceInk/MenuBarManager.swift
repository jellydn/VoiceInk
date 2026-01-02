import SwiftUI
import SwiftData
import AppKit

class MenuBarManager: ObservableObject {
    @Published var isMenuBarOnly: Bool {
        didSet {
            UserDefaults.standard.set(isMenuBarOnly, forKey: "IsMenuBarOnly")
            updateAppActivationPolicy()
        }
    }

    private var modelContainer: ModelContainer?
    private var whisperState: WhisperState?

    init() {
        self.isMenuBarOnly = UserDefaults.standard.bool(forKey: "IsMenuBarOnly")
        updateAppActivationPolicy()
    }

    func configure(modelContainer: ModelContainer, whisperState: WhisperState) {
        self.modelContainer = modelContainer
        self.whisperState = whisperState
    }
    
    func toggleMenuBarOnly() {
        isMenuBarOnly.toggle()
    }
    
    func applyActivationPolicy() {
        updateAppActivationPolicy()
    }
    
    func focusMainWindow() {
        applyActivationPolicy()
        DispatchQueue.main.async {
            if WindowManager.shared.showMainWindow() == nil {
                print("MenuBarManager: Unable to locate main window to focus")
            }
        }
    }
    
    private func updateAppActivationPolicy() {
        let applyPolicy = { [weak self] in
            guard let self else { return }
            let application = NSApplication.shared
            if self.isMenuBarOnly {
                application.setActivationPolicy(.accessory)
                WindowManager.shared.hideMainWindow()
            } else {
                application.setActivationPolicy(.regular)
                WindowManager.shared.showMainWindow()
            }
        }

        if Thread.isMainThread {
            applyPolicy()
        } else {
            DispatchQueue.main.async(execute: applyPolicy)
        }
    }
    
    func openMainWindowAndNavigate(to destination: String) {
        print("MenuBarManager: Navigating to \(destination)")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.applyActivationPolicy()

            guard WindowManager.shared.showMainWindow() != nil else {
                print("MenuBarManager: Unable to show main window for navigation")
                return
            }

            // Post a notification to navigate to the desired destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(
                    name: .navigateToDestination,
                    object: nil,
                    userInfo: ["destination": destination]
                )
                print("MenuBarManager: Posted navigation notification for \(destination)")
            }
        }
    }

    func openHistoryWindow() {
        guard let modelContainer = modelContainer,
              let whisperState = whisperState else {
            print("MenuBarManager: Dependencies not configured")
            return
        }
        HistoryWindowController.shared.showHistoryWindow(
            modelContainer: modelContainer,
            whisperState: whisperState
        )
    }
}
