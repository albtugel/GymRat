# GymRat

GymRat is a SwiftUI iOS app for planning gym programs and logging workouts.  
It includes a weekly timeline, program builder, exercise logs, and a stub AI chat for future analytics.

## Features
- Weekly timeline with day selection
- Program creation and editing
- Exercise logging (sets/reps/weight)
- Cardio support with rounds + duration
- Exercise drag & drop ordering
- Local data persistence (SwiftData)
- AI chat screen with saved history (stubbed for now)
- Full localization (EN/RU/DE)

## Tech Stack
- SwiftUI
- SwiftData
- iOS 17+

## Project Structure (high level)
- `GymRat/App` — app entry point
- `GymRat/Calendar` — week timeline UI
- `GymRat/Program` — program models, manager, and UI
- `GymRat/Workout` — workout logging UI
- `GymRat/Settings` — app settings UI
- `GymRat/AIChat` — AI chat models, data, use cases, and UI

## Getting Started
1. Open `GymRat.xcodeproj` in Xcode.
2. Select a simulator or device (iOS 17+).
3. Run the app.

## Data Storage
- SwiftData store is created in Application Support as `GymRat.sqlite`.
- If the store is corrupted, the app auto-resets and recreates it.

## Localization
Localizations are in:
- `GymRat/Localizable.xcstrings`

Supported languages:
- English (default)
- Russian
- German

All user-facing strings use snake_case keys.  
To add new text:
1. Add a key to `Localizable.xcstrings` for all three languages.
2. Use it in SwiftUI, e.g.:
   ```swift
   Text("save_button")
   .navigationTitle("settings_title")
   TextField("program_name_placeholder", text: $name)
   ```

### Exercise Names
Exercise names are localized via `ExerciseStore` using `String(localized:)`.  
If you add exercises, add keys like `exercise_new_name` in `Localizable.xcstrings`.

## AI Chat (Stub)
The chat uses a stubbed AI client and saved message history.
Integration points:
- `AIClient` protocol
- `GenerateAIReplyUseCase`
- `ApplyProgramChangesUseCase` (for confirmed changes)

## Notes
- Cardio exercises use **Rounds** instead of **Sets** and include a **Dur** field.
- Weight column is hidden for cardio exercises.

## Tests
No automated tests yet.
