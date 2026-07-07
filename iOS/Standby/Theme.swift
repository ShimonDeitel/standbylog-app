import SwiftUI

/// Unique visual identity for Standby - On-Call Log.
enum Theme {
    static let accent = Color(red: 0.7020, green: 0.1294, blue: 0.1176)
    static let background = Color(red: 0.0941, green: 0.0471, blue: 0.0431)
    static let textPrimary = Color(red: 0.9804, green: 0.9294, blue: 0.9216)
    static let card = background.opacity(0.6)

    static let titleFont = Font.system(.title2, design: .serif).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static func statusColor(_ status: String) -> Color {
        switch status {
        case "Scheduled": return accent
        case "Completed": return .gray
        default: return accent.opacity(0.7)
        }
    }
}
