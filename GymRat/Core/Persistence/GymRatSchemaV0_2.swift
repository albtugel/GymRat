import Foundation
import SwiftData

/// Data model from 6 May to 19 July 2026: today's entity names, but `ScheduleItem.program` was
/// non-optional with a cascade rule and `Program` had no `scheduleItems` inverse. Frozen.
enum GymRatSchemaV0_2: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 2, 0)

    static var models: [any PersistentModel.Type] {
        [
            Program.self,
            WorkoutExercise.self,
            Exercise.self,
            ExerciseLog.self,
            ScheduleItem.self,
            DayProgram.self,
            Event.self
        ]
    }

    @Model
    final class Program {
        @Attribute(.unique) var id: UUID
        var name: String
        var typeRaw: String
        @Relationship(deleteRule: .cascade)
        var exercises: [WorkoutExercise] = []
        @Attribute var colorHex: String? = nil
        @Attribute var weekdaysRaw: [String] = []

        init(
            id: UUID = UUID(),
            name: String,
            typeRaw: String,
            exercises: [WorkoutExercise] = [],
            colorHex: String? = nil,
            weekdaysRaw: [String] = []
        ) {
            self.id = id
            self.name = name
            self.typeRaw = typeRaw
            self.exercises = exercises
            self.colorHex = colorHex
            self.weekdaysRaw = weekdaysRaw
        }
    }

    @Model
    final class WorkoutExercise {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .noAction)
        var exercise: Exercise
        var sets: Int
        var reps: Int
        var selectionIndex: Int
        var sharedHistory: Bool = false

        init(
            id: UUID = UUID(),
            exercise: Exercise,
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

    @Model
    final class Exercise {
        @Attribute(.unique) var id: UUID = UUID()
        var name: String
        var categoryRaw: String
        var isCustom: Bool = false

        init(id: UUID = UUID(), name: String, categoryRaw: String, isCustom: Bool = false) {
            self.id = id
            self.name = name
            self.categoryRaw = categoryRaw
            self.isCustom = isCustom
        }
    }

    @Model
    final class ExerciseLog {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .noAction)
        var programExercise: WorkoutExercise
        var exerciseName: String?
        var date: Date
        var dayStamp: Int = 0
        var repsBySet: [Int]
        var weightsBySet: [Double]
        var durationsBySet: [Int] = []

        init(
            id: UUID = UUID(),
            programExercise: WorkoutExercise,
            exerciseName: String?,
            date: Date,
            dayStamp: Int,
            repsBySet: [Int],
            weightsBySet: [Double],
            durationsBySet: [Int] = []
        ) {
            self.id = id
            self.programExercise = programExercise
            self.exerciseName = exerciseName
            self.date = date
            self.dayStamp = dayStamp
            self.repsBySet = repsBySet
            self.weightsBySet = weightsBySet
            self.durationsBySet = durationsBySet
        }
    }

    @Model
    final class ScheduleItem {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .cascade)
        var program: Program
        var date: Date

        init(id: UUID = UUID(), program: Program, date: Date) {
            self.id = id
            self.program = program
            self.date = date
        }
    }

    @Model
    final class DayProgram {
        @Attribute(.unique) var id: UUID
        var date: Date
        @Relationship(deleteRule: .nullify)
        var program: Program

        init(id: UUID = UUID(), date: Date, program: Program) {
            self.id = id
            self.date = date
            self.program = program
        }
    }

    @Model
    final class Event {
        @Attribute(.unique) var id: UUID = UUID()
        var title: String
        var startDate: Date
        var endDate: Date
        var typeRaw: String
        var program: Program?

        init(
            id: UUID = UUID(),
            title: String,
            startDate: Date,
            endDate: Date,
            typeRaw: String,
            program: Program? = nil
        ) {
            self.id = id
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.typeRaw = typeRaw
            self.program = program
        }
    }
}
