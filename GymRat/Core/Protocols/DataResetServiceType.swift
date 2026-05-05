import Foundation

@MainActor
protocol DataResetServiceType {
    func resetAllData() async throws
}
