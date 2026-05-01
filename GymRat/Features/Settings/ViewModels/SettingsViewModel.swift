import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - State
    private(set) var appVersion: String
    private(set) var developerHandle: String
    private(set) var supportEmailURL: URL?
    private(set) var privacyURL: URL?
    private(set) var githubURL: URL?
    private(set) var exerciseDBURL: URL?
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let dataResetService: DataResetServiceProtocol

    init(dataResetService: DataResetServiceProtocol) {
        self.dataResetService = dataResetService
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        developerHandle = "@albtugel"
        supportEmailURL = URL(string: "mailto:al.tugel02@gmail.com")
        privacyURL = URL(string: "https://albtugel.github.io/GymRat/privacy-policy")
        githubURL = URL(string: "https://github.com/albtugel/GymRat")
        exerciseDBURL = URL(string: "https://github.com/yuhonas/free-exercise-db")
    }

    // MARK: - Intents
    func deletePrograms(at offsets: IndexSet, programViewModel: ProgramViewModel) async {
        await programViewModel.deletePrograms(at: offsets)
    }

    func resetAllData(programViewModel: ProgramViewModel) async {
        do {
            try await dataResetService.resetAllData()
            programViewModel.resetPrograms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
