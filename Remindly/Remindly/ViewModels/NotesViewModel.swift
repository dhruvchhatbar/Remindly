import Foundation
import SwiftData
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = "" {
        didSet { filterAndSort() }
    }
    @Published var selectedTags: Set<String> = [] {
        didSet { filterAndSort() }
    }

    private(set) var allTags: [String] = []

    private var allNotes: [Note] = []
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadNotes()
    }

    func loadNotes() {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [
                .init(\Note.modifiedAt, order: .reverse)
            ]
        )
        do {
            allNotes = try modelContext.fetch(descriptor)
            updateAllTags()
            filterAndSort()
        } catch {
            allNotes = []
            notes = []
            allTags = []
        }
    }

    func addNote() -> Note {
        let note = Note(title: "New Note", content: "", tags: [])
        modelContext.insert(note)
        save()
        loadNotes()
        return note
    }

    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            modelContext.delete(note)
        }
        save()
        loadNotes()
    }

    func delete(note: Note) {
        modelContext.delete(note)
        save()
        loadNotes()
    }

    func save() {
        do { try modelContext.save() } catch { }
    }

    func refresh() {
        loadNotes()
    }

    private func updateAllTags() {
        let tagsSet = Set(allNotes.flatMap { $0.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.filter { !$0.isEmpty } })
        allTags = Array(tagsSet).sorted()
    }

    private func filterAndSort() {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let activeTags = selectedTags

        notes = allNotes.filter { note in
            var matches = true
            if !search.isEmpty {
                let hay = (note.title + "\n" + note.content).lowercased()
                matches = hay.contains(search)
            }
            if matches, !activeTags.isEmpty {
                let noteTags = Set(note.tags.map { $0.lowercased() })
                matches = activeTags.isSubset(of: noteTags)
            }
            return matches
        }
        .sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
}


