import Foundation
import SwiftData

struct SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let key = "hasSeededSampleData"
        let hasSeededSampleData = UserDefaults.standard.bool(forKey: key)
        guard !hasSeededSampleData else { return }

        let samples: [Note] = [
            Note(
                title: "Welcome to Remindly",
                content: "# Remindly\n\n- Write notes\n- Add tags\n- Set reminders\n\nToggle markdown preview in the detail screen.",
                tags: ["welcome", "tips"]
            ),
            Note(
                title: "Groceries",
                content: "- Milk\n- Eggs\n- Bread\n- Apples",
                tags: ["home", "shopping"]
            ),
            Note(
                title: "Learning Plan",
                content: "Study SwiftData, SwiftUI, and notifications.",
                tags: ["learning", "ios"]
            )
        ]

        for note in samples {
            context.insert(note)
        }

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            // Ignore seed failures; app still runs
        }
    }
}


