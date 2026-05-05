# GymRat

GymRat is a SwiftUI iOS app for planning gym programs and logging workouts.
It includes a weekly timeline, program builder, and exercise logs.

## Features
- Weekly timeline with day selection
- Program creation and editing
- Exercise logging (sets/reps/weight)
- Cardio support with rounds + duration
- Exercise drag & drop ordering
- Local data persistence (SwiftData)
- Full localization (EN/RU/DE)

## Tech Stack
- SwiftUI
- SwiftData
- iOS 17+

## Project Structure
- `GymRat/App` — app entry point
- `GymRat/Calendar` — week timeline UI
- `GymRat/Program` — program models, manager, and UI
- `GymRat/Workout` — workout logging UI
- `GymRat/Settings` — app settings UI

## Getting Started
1. Open `GymRat.xcodeproj` in Xcode.
2. Select a simulator or device (iOS 17+).
3. Run the app.

## Data Storage
- SwiftData store is created in Application Support as `GymRat.sqlite`.
- If the store is corrupted, the app auto-resets and recreates it.

## Localization
Supported languages: English (default), Russian, German.
All user-facing strings use snake_case keys in `GymRat/Localizable.xcstrings`.

## Notes
- Cardio exercises use **Rounds** instead of **Sets** and include a **Dur** field.
- Weight column is hidden for cardio exercises.
