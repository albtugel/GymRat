import Foundation

@MainActor
enum ExerciseSeeder {
    static func seedIfNeeded(using service: ExerciseServiceType) async {
        do {
            try await service.seedIfNeeded()
        } catch {
            return
        }
    }
}
