import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteDetailViewModel
    @State private var confirmDelete: Bool = false
    @State private var appear = false
    
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
                    .foregroundStyle(.primary)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : -20)
            } header: {
                Text("Title")
                    .foregroundStyle(AppTheme.brand.opacity(0.8))
            }
            Section {
                Picker("Mode", selection: $viewModel.markdownPreviewEnabled) {
                    Text("Edit").tag(false)
                    Text("Preview").tag(true)
                }
                .pickerStyle(.segmented)
                .tint(AppTheme.brand)
                if viewModel.markdownPreviewEnabled {
                    ScrollView {
                        Text(.init(viewModel.content))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.cardGradient)
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    .frame(minHeight: 220)
                } else {
                    TextEditor(text: $viewModel.content)
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
                TextField("Comma separated tags", text: $viewModel.tagsText)
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
                Toggle("Enable reminder", isOn: $viewModel.reminderEnabled)
                    .tint(AppTheme.brand)
                if viewModel.reminderEnabled {
                    DatePicker("Remind at", selection: $viewModel.reminderDate, displayedComponents: [.date, .hourAndMinute])
                        .tint(AppTheme.brand)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    HStack {
                        Button("Save Reminder") {
                            viewModel.scheduleOrUpdateReminder { _ in }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.brand)
                        if viewModelHasReminder {
                            Spacer()
                            Button(role: .destructive, action: { viewModel.cancelReminder() }) {
                                Text("Cancel Reminder")
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            } header: {
                Text("Reminder")
                    .foregroundStyle(AppTheme.brand.opacity(0.8))
            }
            Section {
                HStack {
                    Label("Created", systemImage: "calendar")
                        .foregroundStyle(AppTheme.brand.opacity(0.7))
                    Spacer()
                    Text(viewModel.createdAt, style: .date)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Modified", systemImage: "clock")
                        .foregroundStyle(AppTheme.brand.opacity(0.7))
                    Spacer()
                    Text(viewModel.modifiedAt, style: .date)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Timestamps")
                    .foregroundStyle(AppTheme.brand.opacity(0.8))
            }
            .scrollContentBackground(.hidden)
            }
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
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


