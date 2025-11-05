import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: NotesViewModel
    @State private var path: [UUID] = []
    @State private var showingNew: Bool = false
    @State private var notePendingDelete: Note?
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: NotesViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 12) {
                    if !viewModel.allTags.isEmpty {
                        TagChipsView(allTags: viewModel.allTags, selected: $viewModel.selectedTags)
                            .padding(.horizontal)
                    }
                    List {
                        ForEach(viewModel.notes) { note in
                            Button {
                                path.append(note.id)
                            } label: {
                                NoteRow(note: note, onDelete: { note in
                                    notePendingDelete = note
                                })
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: viewModel.deleteNotes)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Remindly")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .overlay(content: {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.white)
                                    .padding()
                            })
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.brand, AppTheme.brandSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            )
                            .shadow(color: AppTheme.brand.opacity(0.4), radius: 6, x: 0, y: 3)
                            .accessibilityLabel("Add note")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: Text("Search notes"))
            .refreshable { viewModel.refresh() }
            .navigationDestination(for: UUID.self) { id in
                if let note = fetchNote(by: id) {
                    NoteDetailView(note: note, modelContext: modelContext)
                } else {
                    Text("Note not found")
                }
            }
            .onAppear {
                SampleDataSeeder.seedIfNeeded(context: modelContext)
                viewModel.refresh()
            }
            .sheet(isPresented: $showingNew) {
                NewNoteView { newNote in
                    viewModel.refresh()
                    path.append(newNote.id)
                }
            }
            .alert(item: $notePendingDelete, content: { note in
                Alert(
                    title: Text("Delete note?"),
                    message: Text("This cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.delete(note: note)
                    },
                    secondaryButton: .cancel()
                )
            })
        }
    }
    
    private func fetchNote(by id: UUID) -> Note? {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }
}

private struct NoteRow: View {
    let note: Note
    let onDelete: (Note) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if note.reminderDate != nil {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.brand, AppTheme.brandSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppTheme.brand.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                Button {
                    onDelete(note)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            if !note.content.isEmpty {
                Text(note.content)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            if !note.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(note.tags.prefix(4), id: \.self) { tag in
                        Text(tag)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.brand, AppTheme.brandSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.brand.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
            }
            HStack {
                Text(note.modifiedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self)
    let context = ModelContext(container)
    NotesListView(modelContext: context)
}


