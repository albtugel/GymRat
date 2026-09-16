import Foundation
import SwiftData
import Testing
@testable import GymRat

@MainActor
struct DataResetServiceTests {

    @Test func removesUserRecordsButKeepsTheCatalog() async throws {
        let fixture = try ExerciseRowFixture()
        let context = fixture.container.mainContext
        let program = Program(name: "Push", typeRaw: ProgramType.strength.rawValue, exercises: [fixture.programExercise])
        context.insert(program)
        context.insert(ExerciseLog(
            programExercise: fixture.programExercise, exerciseName: nil, date: fixture.today,
            dayStamp: ExerciseLogHelper.makeDayStamp(for: fixture.today), repsBySet: [5], weightsBySet: [20]
        ))
        try context.save()

        try await DataResetService(modelContainer: fixture.container).resetAllData()

        let fresh = ModelContext(fixture.container)
        #expect(try fresh.fetch(FetchDescriptor<Program>()).isEmpty)
        #expect(try fresh.fetch(FetchDescriptor<WorkoutExercise>()).isEmpty)
        #expect(try fresh.fetch(FetchDescriptor<ExerciseLog>()).isEmpty)
        #expect(try fresh.fetch(FetchDescriptor<Exercise>()).map(\.name) == ["Test press"])
    }
}
