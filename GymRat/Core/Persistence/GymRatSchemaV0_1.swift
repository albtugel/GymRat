import Foundation
import SwiftData

/// Data model of the first App Store releases (April – 6 May 2026). Frozen.
///
/// Entity names differ from everything that followed (`ProgramModel`, `ProgramExercise`, …), so a
/// store in this shape cannot be migrated by inference; `LegacyStoreMigration` copies it into
/// `GymRatSchemaV0_2`. Every model is a nested copy so this version never drifts with the live code.
enum GymRatSchemaV0_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 0)

    static var models: [any PersistentModel.Type] {
        [
            ProgramModel.self,
            ProgramExercise.self,
            ExerciseModel.self,
            ProgramExerciseLog.self,
            ProgramAssignment.self,
            DayProgramModel.self,
            TimelineItem.self
        ]
    }

    @Model
    final class ExerciseModel {
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
    final class ProgramExercise {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .noAction)
        var exercise: ExerciseModel

        var sets: Int
        var reps: Int
        var selectionIndex: Int
        var sharedHistory: Bool = false

        init(
            id: UUID = UUID(),
            exercise: ExerciseModel,
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
    final class ProgramExerciseLog {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .noAction)
        var programExercise: ProgramExercise
        var exerciseName: String?
        var date: Date
        var dayStamp: Int = 0
        var repsBySet: [Int]
        var weightsBySet: [Double]
        var durationsBySet: [Int] = []

        init(
            id: UUID = UUID(),
            programExercise: ProgramExercise,
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
    final class DayProgramModel {
        @Attribute(.unique) var id: UUID
        var date: Date

        @Relationship(deleteRule: .nullify)
        var program: ProgramModel

        init(id: UUID = UUID(), date: Date, program: ProgramModel) {
            self.id = id
            self.date = date
            self.program = program
        }
    }

    @Model
    final class ProgramAssignment {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .cascade)
        var program: ProgramModel
        var date: Date

        init(id: UUID = UUID(), program: ProgramModel, date: Date) {
            self.id = id
            self.program = program
            self.date = date
        }
    }

    @Model
    final class ProgramModel {
        @Attribute(.unique) var id: UUID
        var name: String
        var typeRaw: String
        @Relationship(deleteRule: .cascade)
        var exercises: [ProgramExercise] = []
        @Attribute var colorHex: String? = nil

        @Attribute var weekdaysRaw: [String] = []

        init(
            id: UUID = UUID(),
            name: String,
            typeRaw: String,
            exercises: [ProgramExercise] = [],
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
    final class TimelineItem {
        @Attribute(.unique) var id: UUID = UUID()
        var title: String
        var startDate: Date
        var endDate: Date
        var typeRaw: String
        var program: ProgramModel?

        init(
            id: UUID = UUID(),
            title: String,
            startDate: Date,
            endDate: Date,
            typeRaw: String,
            program: ProgramModel? = nil
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
