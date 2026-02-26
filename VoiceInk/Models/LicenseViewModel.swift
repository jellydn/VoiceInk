import Foundation
import AppKit

@MainActor
class LicenseViewModel: ObservableObject {
    enum LicenseState: Equatable {
        case trial(daysRemaining: Int)
        case trialExpired
        case licensed
    }

    @Published private(set) var licenseState: LicenseState = .trial(daysRemaining: 7)  // Default to trial
    @Published var licenseKey: String = ""
    @Published var isValidating = false
    @Published var validationMessage: String?
    @Published private(set) var activationsLimit: Int = 0

    private let trialPeriodDays = 7
    private let polarService = PolarService()
    private let userDefaults = UserDefaults.standard
    private let licenseManager = LicenseManager.shared

    init() {
        // Fork behavior: disable licensing/trial gating globally.
        licenseState = .licensed
    }

    func startTrial() {
        // Only set trial start date if it hasn't been set before
        if licenseManager.trialStartDate == nil {
            licenseManager.trialStartDate = Date()
            licenseState = .trial(daysRemaining: trialPeriodDays)
            NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
        }
    }

    private func loadLicenseState() {
        // Check for existing license key
        if let storedLicenseKey = licenseManager.licenseKey {
            self.licenseKey = storedLicenseKey

            // If we have a license key, trust that it's licensed
            // Skip server validation on startup
            if licenseManager.activationId != nil || !userDefaults.bool(forKey: "VoiceInkLicenseRequiresActivation") {
                licenseState = .licensed
                activationsLimit = userDefaults.activationsLimit
                return
            }
        }

        // Check if this is first launch
        let hasLaunchedBefore = userDefaults.bool(forKey: "VoiceInkHasLaunchedBefore")
        if !hasLaunchedBefore {
            // First launch - start trial automatically
            userDefaults.set(true, forKey: "VoiceInkHasLaunchedBefore")
            startTrial()
            return
        }

        // Only check trial if not licensed and not first launch
        if let trialStartDate = licenseManager.trialStartDate {
            let daysSinceTrialStart = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0

            if daysSinceTrialStart >= trialPeriodDays {
                licenseState = .trialExpired
            } else {
                licenseState = .trial(daysRemaining: trialPeriodDays - daysSinceTrialStart)
            }
        } else {
            // No trial has been started yet - start it now
            startTrial()
        }
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
        validationMessage = "License checks are disabled in this fork."
        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
    }
    
    func removeLicense() {
        // Best-effort cleanup of persisted data while keeping app fully usable.
        licenseManager.removeAll()

        userDefaults.set(false, forKey: "VoiceInkLicenseRequiresActivation")
        userDefaults.set(false, forKey: "VoiceInkHasLaunchedBefore")
        userDefaults.activationsLimit = 0

        licenseState = .licensed
        licenseKey = ""
        validationMessage = nil
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
