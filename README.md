# Remindly (SwiftUI + SwiftData)

Remindly is an offline-first Notes app showcasing intermediate iOS skills (MVVM, SwiftData, local search/filter, and local notifications using UNUserNotificationCenter).

## Features
- Local CRUD with SwiftData
- Notes include: title, markdown-enabled content, tags, created/modified timestamps
- Search and tag-based filtering
- Local reminders per note (schedule/update/cancel)
- Offline-only (no networking)
- Modern SwiftUI UI with light/dark support

## Tech Stack
- SwiftUI (iOS 17+)
- SwiftData for persistence
- Local Notifications with UNUserNotificationCenter
- MVVM architecture
- Markdown preview via SwiftUI `Text(.init(...))`

## Project Structure
- `Remindly/Models/Note.swift`: SwiftData model
- `Remindly/ViewModels/NotesViewModel.swift`: List, search, filter, CRUD
- `Remindly/ViewModels/NoteDetailViewModel.swift`: Edit note, tags, reminders
- `Remindly/Views/NotesListView.swift`: List with search and tag chips
- `Remindly/Views/NoteDetailView.swift`: Editor, markdown toggle, reminder picker
- `Remindly/Views/Components/TagChipsView.swift`: Tag filter UI
- `Remindly/Utilities/NotificationManager.swift`: Local notifications helper
- `Remindly/Utilities/SampleDataSeeder.swift`: First-launch sample notes
- `Remindly/RemindlyApp.swift`: App entry with SwiftData container

## Requirements
- Xcode 15+
- iOS 17+

## Run
1. Open `Remindly.xcodeproj` in Xcode.
2. Select an iOS 17+ Simulator or a device.
3. Run.

On first launch, the app seeds a few example notes. Grant notification permissions to test reminders.

## Notes
- Markdown preview is provided by SwiftUI’s Markdown support in `Text(.init(content))`.
- Notifications are fully local; no external services required.


