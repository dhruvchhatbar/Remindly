//
//  RemindlyApp.swift
//  Remindly
//
//  Created by Dhruv CHPL on 29/10/25.
//

import SwiftUI
import SwiftData

@main
struct RemindlyApp: App {
    @State private var showMain: Bool = false
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showMain {
                    ContentView()
                        .transition(.opacity.combined(with: .scale))
                        .tint(AppTheme.brand)
                } else {
                    SplashView(isActive: $showMain)
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
