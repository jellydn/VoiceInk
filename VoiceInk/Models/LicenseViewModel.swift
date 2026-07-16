import AppKit
import Foundation
import os

@MainActor
class LicenseViewModel: ObservableObject {
    enum LicenseState: Equatable {
        case unlicensed
        case trial(daysRemaining: Int)
        case trialExpired
        case licensed
    }

    @Published private(set) var licenseState: LicenseState = .licensed
    @Published var licenseKey: String = ""
    @Published var isValidating = false
    @Published private(set) var isDeactivating = false
    @Published var validationMessage: String?
    @Published var validationSuccess: Bool = false
    @Published private(set) var activationsLimit: Int = 0

    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "LicenseViewModel")
    private let userDefaults = UserDefaults.standard

    init() {
        // Fork: always licensed; no trial or paywall gating
        licenseState = .licensed
    }

    func startTrial() {
        licenseState = .licensed
        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
    }

    private func loadLicenseState() {
        licenseState = .licensed
    }

    func refreshLicenseState() {
        licenseState = .licensed
    }

    var isLicensed: Bool {
        true
    }

    var canUseApp: Bool {
        true
    }

    var usageRestrictionMessage: String? {
        nil
    }

    func openPurchaseLink() {
        if let url = URL(string: "https://tryvoiceink.com/buy") {
            NSWorkspace.shared.open(url)
        }
    }

    func validateLicense() async {
        licenseState = .licensed
        validationSuccess = true
        validationMessage = String(localized: "License checks are disabled in this fork.")
        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
    }

    func deactivateLicense() async {
        guard !isDeactivating else { return }
        isDeactivating = true
        validationMessage = nil
        defer { isDeactivating = false }

        licenseState = .licensed
        licenseKey = ""
        validationMessage = nil
        validationSuccess = false
        activationsLimit = 0
        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
    }
}

// UserDefaults extension for non-sensitive license settings
extension UserDefaults {
    var activationsLimit: Int {
        get { integer(forKey: "VoiceInkActivationsLimit") }
        set { set(newValue, forKey: "VoiceInkActivationsLimit") }
    }
}