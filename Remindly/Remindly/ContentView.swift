//
//  ContentView.swift
//  Remindly
//
//  Created by Dhruv CHPL on 29/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NotesListView(modelContext: modelContext)
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self)
    ContentView()
        .modelContainer(container)
}
