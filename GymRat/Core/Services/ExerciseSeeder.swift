import Foundation

@MainActor
enum ExerciseSeeder {
    static func seedIfNeeded(using service: ExerciseServiceProtocol) async {
        do {
            try await service.seedIfNeeded()
        } catch {
            return
        }
    }
}
