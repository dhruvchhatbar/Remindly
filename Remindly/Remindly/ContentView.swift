//
//  ContentView.swift
//  Remindly
//
//  Created by Dhruv CHPL on 29/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell")
                .imageScale(.large)
            Text("Remindly")
                .font(.title)
                .fontWeight(.semibold)
            Text("Initial setup")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
