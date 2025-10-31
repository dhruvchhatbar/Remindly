//
//  ContentView.swift
//  Remindly
//
//  Created by Dhruv CHPL on 29/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var isPresentingAdd: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                        Text("No notes yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Tap + to add your first note")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                if !note.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text(note.content)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isPresentingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                NewNoteFormView { newNote in
                    notes.append(newNote)
                }
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}

// MARK: - Simple In-Memory Model
struct Note: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Add Form (no gradient, no tags)
struct NewNoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""

    var onSave: (Note) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Enter title", text: $title)
                }
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let note = Note(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                         content: content)
                        onSave(note)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
