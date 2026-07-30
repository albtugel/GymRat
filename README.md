# GymRat

GymRat is a SwiftUI iOS app for planning gym programs and logging workouts.
It includes a weekly timeline, a program builder, exercise logs, and AI-assisted plan editing.

## Features
- Weekly timeline with day selection
- Program creation and editing
- Exercise logging (sets/reps/weight)
- Cardio support with rounds + duration
- Exercise drag & drop ordering
- AI plan editing via text or voice (Mistral)
- Exercise details with demonstration GIFs, target muscles and instructions
- Local data persistence (SwiftData)
- Full localization (EN/RU/DE)

## Tech Stack
- SwiftUI
- SwiftData
- Kingfisher (image loading and caching)
- iOS 18.2+

## Project Structure
- `GymRat/App` — app entry point
- `GymRat/Core` — services, protocols and secrets (exercise catalog, AI, persistence)
- `GymRat/Features` — feature modules: `Calendar`, `Exercise`, `Program`, `Settings`
- `GymRat/Shared` — reusable components, extensions, managers and theming
- `GymRat/Resources` — assets, `Info.plist` and localizations

Each feature follows MVVM: `Models`, `ViewModels` and `Views`.

## Getting Started
1. Create `GymRat/Core/Secrets.xcconfig` (it is gitignored) with:
   ```
   WORKOUTX_API_KEY = your_key_here
   ```
   The app reads this through `Info.plist`; without the file it will crash on
   launch with `Missing value for WORKOUTX_API_KEY in Info.plist`.
2. Open `GymRat.xcodeproj` in Xcode.
3. Select a simulator or device running iOS 18.2 or newer.
4. Run the app.

AI editing additionally requires a Mistral API key, entered in-app under
Settings → AI. It is stored in the Keychain, not in the repository.

## Data
- The SwiftData store lives in Application Support as `GymRat.sqlite`.
  If it is corrupted, the app resets and recreates it automatically.
- Exercise metadata and GIFs come from [exercisedb.dev](https://exercisedb.dev).
  The catalog is downloaded once, cached on disk, and resumed if interrupted.

## Localization
Supported languages: English (default), Russian and German.
All user-facing strings use snake_case keys in `GymRat/Resources/<lang>.lproj/Localizable.strings`.

## Notes
- Cardio exercises use **Rounds** instead of **Sets** and include a **Dur** field.
- The weight column is hidden for cardio exercises.

## Tests
Unit tests live in `GymRatTests` and run with ⌘U in Xcode.
