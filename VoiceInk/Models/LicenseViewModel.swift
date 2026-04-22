import Foundation
import AppKit
import os

@MainActor
class LicenseViewModel: ObservableObject {
    enum LicenseState: Equatable {
        case trial(daysRemaining: Int)
        case trialExpired
        case licensed
    }

    @Published private(set) var licenseState: LicenseState = .licensed
    @Published var licenseKey: String = ""
    @Published var isValidating = false
    @Published var validationMessage: String?
    @Published var validationSuccess: Bool = false
    @Published private(set) var activationsLimit: Int = 0

    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "LicenseViewModel")
    private let userDefaults = UserDefaults.standard

    init() {
        // Fork behavior: always licensed
        licenseState = .licensed
    }

    func startTrial() {
        // No-op: fork disables trial gating
        licenseState = .licensed
    }

    private func loadLicenseState() {
        // Fork: always licensed
        licenseState = .licensed
    }

    var canUseApp: Bool {
        true
    }

    func openPurchaseLink() {
        if let url = URL(string: "https://tryvoiceink.com/buy") {
            NSWorkspace.shared.open(url)
        }
    }

    func validateLicense() async {
        licenseState = .licensed
        validationSuccess = true
        validationMessage = "License checks are disabled in this fork."
        NotificationCenter.default.post(name: Notification.Name("licenseStatusChanged"), object: nil)
    }

    func removeLicense() {
        licenseState = .licensed
        licenseKey = ""
        validationMessage = nil
        activationsLimit = 0
        NotificationCenter.default.post(name: Notification.Name("licenseStatusChanged"), object: nil)
    }
}

// UserDefaults extension for compatibility
extension UserDefaults {
    var activationsLimit: Int {
        get { integer(forKey: "VoiceInkActivationsLimit") }
        set { set(newValue, forKey: "VoiceInkActivationsLimit") }
    }
}
