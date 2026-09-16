import Foundation

@MainActor
protocol DataResetServiceType {
    func resetAllData() throws
}
