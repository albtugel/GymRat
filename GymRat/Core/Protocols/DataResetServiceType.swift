import Foundation

protocol DataResetServiceType: Sendable {
    /// Removes every user record (programs, schedules, logs, events) but keeps the exercise catalog.
    func resetAllData() async throws
}
