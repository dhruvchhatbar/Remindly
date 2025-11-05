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
    @State private var appear = false

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
                                .shadow(color: AppTheme.brand.opacity(0.3), radius: 8, x: 0, y: 4)
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create a new note")
                                .font(.headline)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppTheme.brand, AppTheme.brandSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("Title, content, tags and optional reminder")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : -20)
                }
                Section {
                    TextField("Title", text: $title)
                        .font(.title3)
                        .foregroundStyle(.primary)
                } header: {
                    Text("Title")
                        .foregroundStyle(AppTheme.brand.opacity(0.8))
                }

                Section {
                    Picker("Mode", selection: $markdownPreviewEnabled) {
                        Text("Edit").tag(false)
                        Text("Preview").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .tint(AppTheme.brand)
                    if markdownPreviewEnabled {
                        ScrollView {
                            Text(.init(content))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.cardGradient)
                                )
                        }
                        .frame(minHeight: 220)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        TextEditor(text: $content)
                            .frame(minHeight: 220)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.cardGradient)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                AppTheme.brand.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .padding(4)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                } header: {
                    Text("Content")
                        .foregroundStyle(AppTheme.brand.opacity(0.8))
                }

                Section {
                    TextField("Comma separated tags", text: $tagsText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppTheme.cardGradient)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(
                                            AppTheme.brand.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                        )
                } header: {
                    Text("Tags")
                        .foregroundStyle(AppTheme.brand.opacity(0.8))
                }

                Section {
                    Toggle("Enable reminder", isOn: $reminderEnabled)
                        .tint(AppTheme.brand)
                    if reminderEnabled {
                        DatePicker("Remind at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(AppTheme.brand)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                } header: {
                    Text("Reminder")
                        .foregroundStyle(AppTheme.brand.opacity(0.8))
                }
                }
                .scrollContentBackground(.hidden)
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
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appear = true
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


