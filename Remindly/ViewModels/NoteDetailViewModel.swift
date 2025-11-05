import Foundation
import SwiftData
import Combine

@MainActor
final class NoteDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var tagsText: String
    @Published var markdownPreviewEnabled: Bool = false
    @Published var reminderEnabled: Bool
    @Published var reminderDate: Date

    private let modelContext: ModelContext
    private var note: Note

    init(modelContext: ModelContext, note: Note) {
        self.modelContext = modelContext
        self.note = note
        self.title = note.title
        self.content = note.content
        self.tagsText = note.tags.joined(separator: ", ")
        self.reminderEnabled = note.reminderDate != nil
        self.reminderDate = note.reminderDate ?? Date().addingTimeInterval(3600)
    }

    var createdAt: Date { note.createdAt }
    var modifiedAt: Date { note.modifiedAt }

    func saveChanges() {
        note.title = title
        note.content = content
        note.tags = Self.parseTags(from: tagsText)
        note.modifiedAt = Date()
        if reminderEnabled {
            note.reminderDate = reminderDate
        } else {
            if let id = note.reminderIdentifier { NotificationManager.shared.cancelNotification(id: id) }
            note.reminderDate = nil
            note.reminderIdentifier = nil
        }
        do { try modelContext.save() } catch { }
    }

    func scheduleOrUpdateReminder(completion: @escaping (Bool) -> Void) {
        let id = note.reminderIdentifier ?? UUID().uuidString
        NotificationManager.shared.scheduleNotification(
            id: id,
            title: title,
            body: content,
            at: reminderDate
        ) { [weak self] success in
            guard let self else { completion(false); return }
            if success {
                self.note.reminderIdentifier = id
                self.note.reminderDate = self.reminderDate
                self.note.modifiedAt = Date()
                do { try self.modelContext.save() } catch { }
            }
            completion(success)
        }
    }

    func cancelReminder() {
        if let id = note.reminderIdentifier {
            NotificationManager.shared.cancelNotification(id: id)
        }
        note.reminderIdentifier = nil
        note.reminderDate = nil
        note.modifiedAt = Date()
        do { try modelContext.save() } catch { }
    }

    static func parseTags(from text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func deleteNote() {
        modelContext.delete(note)
        do { try modelContext.save() } catch { }
    }
}


