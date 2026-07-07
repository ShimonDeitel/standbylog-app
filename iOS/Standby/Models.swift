import Foundation

struct Item: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var field1: String   // Date/Window
    var field2: String   // Callout count
    var status: String
    var notes: String = ""
    var createdAt: Date = Date()
}

enum Status {
    static let all = ["Scheduled", "Active", "Completed"]
}
