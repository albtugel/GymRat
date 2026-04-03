import Foundation

@MainActor
protocol DataResetServiceProtocol {
    func resetAllData() async throws
}
