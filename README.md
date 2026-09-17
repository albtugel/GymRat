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
- `GymRat/Core` — services and protocols (exercise catalog, AI) and `Persistence` (versioned schemas, migration plan, store opening)
- `GymRat/Features` — feature modules: `Calendar`, `Exercise`, `Program`, `Settings`
- `GymRat/Shared` — reusable components, extensions, managers and theming
- `GymRat/Resources` — assets, `Info.plist` and localizations

Each feature follows MVVM: `Models`, `ViewModels` and `Views`.

## Getting Started
1. Create an empty `GymRat/Core/Secrets.xcconfig` (it is gitignored). The Xcode
   project still uses it as a base configuration, so the build fails without it;
   no keys are needed.
2. Open `GymRat.xcodeproj` in Xcode.
3. Select a simulator or device running iOS 18.2 or newer.
4. Run the app.

AI editing additionally requires a Mistral API key, entered in-app under
Settings → AI. It is stored in the Keychain, not in the repository.

## Data
- The SwiftData store lives in Application Support as `GymRat.sqlite`.
  If it cannot be opened, its files are moved to
  `Application Support/StoreBackups/<timestamp>/`, a fresh store is created and
  the user is told once at launch. Data is never deleted on a failed open.
- Exercise metadata and GIFs come from [exercisedb.dev](https://exercisedb.dev).
  The catalog is downloaded once, cached on disk, and resumed if interrupted.

## Changing the data model
Every store on a user's device was written with some version of the model, and
SwiftData only opens it if that version is listed in `GymRatMigrationPlan`.
Editing a `@Model` without a new version makes the update open an empty app.

To change a model (add, rename or retype a property, add or remove a model):
1. In the current latest schema (`GymRat/Core/Persistence/GymRatSchemaV<N>.swift`),
   replace the references to live classes with frozen nested copies of them, as
   `GymRatSchemaV1` does. Never edit a schema that has shipped.
2. Make the change in the live model classes.
3. Add `GymRatSchemaV<N+1>` listing the live classes with a higher
   `versionIdentifier`, append it to `GymRatMigrationPlan.schemas`, and add a
   stage from the previous version: `.lightweight` for additive changes,
   `.custom` when data has to be copied or transformed (see `LegacyStoreMigration`).
4. Point `PersistentStore.schema` at the new version.
5. Run the tests. `SchemaGuardTests` prints the new checksum; add it to
   `recordedChecksums` without touching the existing entries.
6. Add a test that writes a store with the previous schema and opens it with
   `PersistentStore.open`, like `LegacyStoreMigrationTests`.

`SchemaGuardTests` fails whenever a model changes without these steps.

## Localization
Supported languages: English (default), Russian and German.
All user-facing strings use snake_case keys in `GymRat/Resources/<lang>.lproj/Localizable.strings`.

## Notes
- Cardio exercises use **Rounds** instead of **Sets** and include a **Dur** field.
- The weight column is hidden for cardio exercises.

## Tests
Unit tests live in `GymRatTests` and run with ⌘U in Xcode. They cover the
stores, the set save flow, entry formatting, store recovery and migration from
every shipped schema. `SchemaGuardTests` guards the data model (see
[Changing the data model](#changing-the-data-model)).
