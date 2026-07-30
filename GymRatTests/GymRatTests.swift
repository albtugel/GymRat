import Foundation
import Testing
@testable import GymRat

struct ExerciseCatalogCacheTests {

    /// A download cut short by rate limiting must persist its cursor and the partial flag: that pair
    /// is what makes the next launch resume instead of freezing an incomplete catalog.
    @Test func partialCatalogRoundTripKeepsResumeState() throws {
        let fileName = Self.temporaryCacheName()
        defer { Self.removeCache(named: fileName) }

        ExerciseRepo.saveCachedCatalog(
            ExerciseRepo.CachedCatalog(
                exercises: [Self.makeRemoteExercise(id: "abc123")],
                paginationCursor: "abc123",
                isComplete: false
            ),
            fileName: fileName
        )

        let loaded = try #require(ExerciseRepo.loadCachedCatalog(fileName: fileName))
        #expect(loaded.isComplete == false)
        #expect(loaded.paginationCursor == "abc123")
        #expect(loaded.exercises.map(\.exerciseId) == ["abc123"])
    }

    @Test func completeCatalogRoundTripPreservesContents() throws {
        let fileName = Self.temporaryCacheName()
        defer { Self.removeCache(named: fileName) }

        let exercises = [
            Self.makeRemoteExercise(id: "one", name: "first"),
            Self.makeRemoteExercise(id: "two", name: "second")
        ]
        ExerciseRepo.saveCachedCatalog(
            ExerciseRepo.CachedCatalog(
                exercises: exercises,
                paginationCursor: "two",
                isComplete: true
            ),
            fileName: fileName
        )

        let loaded = try #require(ExerciseRepo.loadCachedCatalog(fileName: fileName))
        #expect(loaded.isComplete)
        #expect(loaded.exercises == exercises)
    }

    @Test func missingCacheLoadsAsNil() {
        #expect(ExerciseRepo.loadCachedCatalog(fileName: Self.temporaryCacheName()) == nil)
    }

    /// Prefetching feeds these URLs straight to Kingfisher, so duplicates would queue the same
    /// download twice and unresolved names would produce bogus requests.
    @Test func gifURLsDeduplicateAndSkipUnknownNames() async {
        let urls = await ExerciseRepo.shared.gifURLs(
            forExerciseNames: ["Squat", "Squat", "Definitely Not A Real Exercise"]
        )

        #expect(urls.count == 1)
        #expect(urls.first?.host() == "static.exercisedb.dev")
    }

    private static func temporaryCacheName() -> String {
        "test-catalog-\(UUID().uuidString).json"
    }

    private static func removeCache(named fileName: String) {
        guard let url = ExerciseRepo.cacheURL(fileName: fileName) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private static func makeRemoteExercise(id: String, name: String = "example") -> ExerciseRepo.RemoteExercise {
        ExerciseRepo.RemoteExercise(
            exerciseId: id,
            name: name,
            gifUrl: nil,
            bodyParts: [],
            targetMuscles: [],
            secondaryMuscles: nil,
            equipments: nil,
            instructions: nil
        )
    }
}
