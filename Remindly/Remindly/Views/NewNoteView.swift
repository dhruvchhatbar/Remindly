import SwiftUI
import SwiftData

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var tagsText: String = ""
    @State private var markdownPreviewEnabled: Bool = false
    @State private var reminderEnabled: Bool = false
    @State private var reminderDate: Date = Date().addingTimeInterval(3600)

    let onSaved: (Note) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                Form {
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.tagGradient)
                                .frame(width: 40, height: 40)
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create a new note")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Title, content, tags and optional reminder")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                Section { TextField("Title", text: $title) .font(.title3) }

                Section {
                    Picker("Mode", selection: $markdownPreviewEnabled) {
                        Text("Edit").tag(false)
                        Text("Preview").tag(true)
                    }
                    .pickerStyle(.segmented)
                    if markdownPreviewEnabled {
                        ScrollView { Text(.init(content)).frame(maxWidth: .infinity, alignment: .leading) }
                            .frame(minHeight: 220)
                    } else {
                        TextEditor(text: $content).frame(minHeight: 220).font(.body)
                    }
                } header: { Text("Content") }

                Section("Tags") { TextField("Comma separated tags", text: $tagsText).textInputAutocapitalization(.never).autocorrectionDisabled(true) }

                Section("Reminder") {
                    Toggle("Enable reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Remind at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                }
                .scrollContentBackground(.hidden)
                .background(Color.gray.opacity(0.2))
            }
            .tint(AppTheme.brand)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.brand, AppTheme.brandSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let note = Note(title: title, content: content, tags: NoteDetailViewModel.parseTags(from: tagsText))
        if reminderEnabled { note.reminderDate = reminderDate }
        modelContext.insert(note)
        do { try modelContext.save() } catch { }
        if reminderEnabled {
            let id = note.reminderIdentifier ?? UUID().uuidString
            NotificationManager.shared.scheduleNotification(id: id, title: title, body: content, at: reminderDate) { success in
                if success {
                    note.reminderIdentifier = id
                    do { try? modelContext.save() } catch { }
                }
            }
        }
        onSaved(note)
        dismiss()
    }
}

#Preview { NewNoteView(onSaved: { _ in }) }


