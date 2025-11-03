import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteDetailViewModel
    @State private var confirmDelete: Bool = false
    
    init(note: Note, modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(modelContext: modelContext, note: note))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            Form {
            Section {
                TextField("Title", text: $viewModel.title)
                    .font(.title3)
            }
            Section {
                Picker("Mode", selection: $viewModel.markdownPreviewEnabled) {
                    Text("Edit").tag(false)
                    Text("Preview").tag(true)
                }
                .pickerStyle(.segmented)
                if viewModel.markdownPreviewEnabled {
                    ScrollView {
                        Text(.init(viewModel.content))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    .frame(minHeight: 220)
                } else {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 220)
                        .font(.body)
                        .transition(.opacity)
                }
            } header: {
                Text("Content")
            }
            Section("Tags") {
                TextField("Comma separated tags", text: $viewModel.tagsText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            Section("Reminder") {
                Toggle("Enable reminder", isOn: $viewModel.reminderEnabled)
                if viewModel.reminderEnabled {
                    DatePicker("Remind at", selection: $viewModel.reminderDate, displayedComponents: [.date, .hourAndMinute])
                    HStack {
                        Button("Save Reminder") {
                            viewModel.scheduleOrUpdateReminder { _ in }
                        }
                        if viewModelHasReminder {
                            Spacer()
                            Button(role: .destructive, action: { viewModel.cancelReminder() }) {
                                Text("Cancel Reminder")
                            }
                        }
                    }
                }
            }
            Section("Timestamps") {
                HStack {
                    Label("Created", systemImage: "calendar")
                    Spacer()
                    Text(viewModel.createdAt, style: .date)
                }
                HStack {
                    Label("Modified", systemImage: "clock")
                    Spacer()
                    Text(viewModel.modifiedAt, style: .date)
                }
            }
            .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    guard !viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    viewModel.saveChanges()
                    dismiss()
                } label: {
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
                .disabled(viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .destructive) { confirmDelete = true } label: { Image(systemName: "trash") }
            }
        }
        .alert("Delete note?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                viewModel.deleteNote()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This cannot be undone.") }
    }
    
    private var viewModelHasReminder: Bool {
        viewModel.reminderEnabled
    }
}

//#Preview {
//    let container = try! ModelContainer(for: Note.self)
//    let context = ModelContext(container)
//    let example = Note(title: "Sample", content: "**Markdown** _preview_ sample.", tags: ["swift", "ios"])
//    context.insert(example)
//    NavigationStack { NoteDetailView(note: example, modelContext: context) }
//        .modelContainer(container)
//}


