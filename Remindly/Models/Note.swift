import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var modifiedAt: Date
    var reminderDate: Date?
    var reminderIdentifier: String?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        tags: [String] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        reminderDate: Date? = nil,
        reminderIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.reminderDate = reminderDate
        self.reminderIdentifier = reminderIdentifier
    }
}


