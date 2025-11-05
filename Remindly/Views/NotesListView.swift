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
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    List {
                        ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                            NoteRow(note: note, index: index, onDelete: { note in
                                notePendingDelete = note
                            })
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    path.append(note.id)
                                }
                            }
                        }
                        .onDelete(perform: { indexSet in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.deleteNotes(at: indexSet)
                            }
                        })
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
                        ZStack(){
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppTheme.brand, AppTheme.brandSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: AppTheme.brand.opacity(0.4), radius: 6, x: 0, y: 3)
                            
                            Spacer()
                            Image(systemName: "plus")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                                .padding(5.0)
                            
                        }
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
    let index: Int
    let onDelete: (Note) -> Void
    @State private var isPressed = false
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary, AppTheme.brand.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                if note.reminderDate != nil {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(AppTheme.tagGradient)
                        .font(.subheadline)
                        .shadow(color: AppTheme.brand.opacity(0.4), radius: 4, x: 0, y: 2)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        onDelete(note)
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            if !note.content.isEmpty {
                Text(note.content)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            if !note.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(note.tags.prefix(4).enumerated()), id: \.element) { index, tag in
                        Text(tag)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.tagGradient)
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.brand.opacity(0.4), radius: 4, x: 0, y: 2)
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                                .delay(Double(index) * 0.05),
                                value: isPressed
                            )
                    }
                }
            }
            HStack {
                Label {
                    Text(note.modifiedAt, style: .date)
                        .font(.caption)
                } icon: {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
        .scaleEffect(isPressed ? 0.98 : appear ? 1.0 : 0.95)
        .opacity(isPressed ? 0.9 : appear ? 1.0 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                appear = true
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self)
    let context = ModelContext(container)
    NotesListView(modelContext: context)
}


