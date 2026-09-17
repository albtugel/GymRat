import Foundation

/// The exercise catalog: local seeds merged with whatever has been downloaded from ExerciseDB.
/// This is the surface the app uses from `ExerciseRepo`, so services and view models can take a fake.
protocol ExerciseStoreType: Sendable {
    /// Downloads the part of the remote catalog that is still missing.
    func refresh() async
    func seedSnapshot() async -> [ExerciseRepo.ExerciseSeed]
    func getExerciseSeed(named name: String) async -> ExerciseRepo.ExerciseSeed?
    /// Like `getExerciseSeed`, but fetches the remote metadata (muscles, instructions) if it is missing.
    func getExerciseSeedResolvingRemote(named name: String) async -> ExerciseRepo.ExerciseSeed?
    /// Media URLs for the given names, deduplicated and skipping names the catalog cannot resolve.
    func gifURLs(forExerciseNames names: [String]) async -> [URL]
}
