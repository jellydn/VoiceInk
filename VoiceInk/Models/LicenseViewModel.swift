import AppKit
import Foundation

@MainActor
final class LicenseViewModel: ObservableObject {
    enum LicenseState: Equatable {
        case unlicensed
        case trial(daysRemaining: Int)
        case trialExpired
        case licensed
    }

    static let shared = LicenseViewModel()

    @Published private(set) var licenseState: LicenseState = .licensed
    @Published private(set) var licenseKey = ""
    @Published var isValidating = false
    @Published private(set) var isDeactivating = false
    @Published var validationMessage: String?
    @Published var validationSuccess = false
    @Published private(set) var activationsLimit = 0

    init() {
        // Fork: always licensed; no trial or paywall gating.
        licenseState = .licensed
    }

    @discardableResult
    func startTrial() -> Bool {
        licenseState = .licensed
        return true
    }

    func refreshLicenseState() {
        licenseState = .licensed
    }

    var isLicensed: Bool {
        true
    }

    var hasVerifiedLicense: Bool {
        true
    }

    var canUseApp: Bool {
        true
    }

    var usageRestrictionMessage: String? {
        nil
    }

    var diagnosticLicenseStatus: String {
        "Licensed (Fork — always licensed)"
    }

    func openPurchaseLink() {
        if let url = URL(string: "https://tryvoiceink.com/buy") {
            NSWorkspace.shared.open(url)
        }
    }

    func validateLicense(_ submittedKey: String) async {
        guard !isValidating else { return }
        isValidating = true
        defer { isValidating = false }

        licenseState = .licensed
        if !submittedKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            licenseKey = submittedKey
        }
        validationSuccess = true
        validationMessage = String(localized: "License checks are disabled in this fork.")
        NotificationCenter.default.post(name: .licenseCelebrationRequested, object: nil)
    }

    func deactivateLicense() async {
        guard !isDeactivating else { return }
        isDeactivating = true
        defer { isDeactivating = false }

        // Fork: nothing to deactivate — remain licensed.
        licenseState = .licensed
        licenseKey = ""
        validationMessage = nil
        validationSuccess = false
        activationsLimit = 0
    }
}

// UserDefaults extension for non-sensitive license settings.
extension UserDefaults {
    var activationsLimit: Int {
        get { integer(forKey: "VoiceInkActivationsLimit") }
        set { set(newValue, forKey: "VoiceInkActivationsLimit") }
    }
}
