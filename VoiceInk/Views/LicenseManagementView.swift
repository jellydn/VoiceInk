import SwiftUI

struct LicenseManagementView: View {
    @Environment(\.colorScheme) private var colorScheme
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                heroSection
                
                // Main Content - Free Version
                VStack(spacing: 32) {
                    freeContent
                }
                .padding(32)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            // App Icon (simple text replacement since AppIconView is missing)
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Text("VI")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                // Title Section
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.green)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) { 
                            Text("VoiceInk Free")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text("v\(appVersion)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                        }
                    }
                    
                    Text("All Premium Features Unlocked - Free Version")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
    }
    
    private var freeContent: some View {
        VStack(spacing: 40) {
            // Status Card
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.yellow)
                    
                    Text("Free Version")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("All Premium Features Unlocked")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text("Enjoy all VoiceInk features without any restrictions or limitations.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: 10)
            )
            
            // Features List
            VStack(spacing: 24) {
                Text("Available Features")
                    .font(.headline)
                
                VStack(spacing: 16) {
                    featureRow(icon: "mic.fill", title: "Unlimited Transcriptions", description: "Transcribe as much as you need")
                    featureRow(icon: "brain.head.profile", title: "All AI Models", description: "Access all transcription models")
                    featureRow(icon: "wand.and.stars", title: "AI Enhancement", description: "Enhance transcriptions with AI")
                    featureRow(icon: "sparkles.square.fill.on.square", title: "Power Mode", description: "Advanced automation features")
                    featureRow(icon: "gauge.medium", title: "Full Analytics", description: "Complete usage metrics")
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: 10)
            )
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct LicenseManagementView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseManagementView()
    }
}