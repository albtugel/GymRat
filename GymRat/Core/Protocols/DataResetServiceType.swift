import Foundation

protocol DataResetServiceType: Sendable {
    /// Removes every user record (programs, schedules, logs) but keeps the exercise catalog.
    func resetAllData() async throws
}
