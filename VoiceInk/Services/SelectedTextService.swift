import Foundation
import AppKit

class SelectedTextService {
    static func fetchSelectedText() async -> String? {
        // Save current pasteboard content
        let originalPasteboard = NSPasteboard.general.string(forType: .string)
        
        // Simulate copy action
        NSApp.sendAction(Selector(("copy:")), to: nil, from: nil)
        
        // Wait for copy to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        let copiedText = NSPasteboard.general.string(forType: .string)
        
        // Restore original pasteboard if no new text was copied
        if copiedText == originalPasteboard {
            return nil
        }
        
        // Restore original pasteboard
        if let original = originalPasteboard {
            NSPasteboard.general.setString(original, forType: .string)
        }
        
        return copiedText
    }
}
