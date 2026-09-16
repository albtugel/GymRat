import Foundation

/// A catalog exercise as stored in the app's own table (seeded from the catalog or created by the user).
struct ExerciseSnapshot: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, category: ExerciseCategory, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.isCustom = isCustom
    }
}

/// One exercise inside a program: its default sets/reps, its position, and whether its history is
/// shared with the same exercise in other programs.
struct WorkoutExerciseSnapshot: Identifiable, Hashable, Sendable {
    let id: UUID
    var exercise: ExerciseSnapshot
    var sets: Int
    var reps: Int
    var selectionIndex: Int
    var sharedHistory: Bool

    init(
        id: UUID = UUID(),
        exercise: ExerciseSnapshot,
        sets: Int = 3,
        reps: Int = 0,
        selectionIndex: Int = 0,
        sharedHistory: Bool = false
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.selectionIndex = selectionIndex
        self.sharedHistory = sharedHistory
    }
}

/// A program as the UI sees it: a value the editor mutates freely and hands back to `ProgramStoreType`.
struct ProgramSnapshot: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var type: ProgramType
    var colorHex: String?
    var weekdays: Set<ProgramWeekday>
    /// Ordered by position.
    var exercises: [WorkoutExerciseSnapshot]

    init(
        id: UUID = UUID(),
        name: String,
        type: ProgramType,
        colorHex: String? = nil,
        weekdays: Set<ProgramWeekday> = [],
        exercises: [WorkoutExerciseSnapshot] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.colorHex = colorHex
        self.weekdays = weekdays
        self.exercises = exercises
    }
}
