import Foundation

enum AITestSupport {
    static let resetLaunchArgument = "GYMRAT_UI_TEST_RESET"

    @MainActor
    static func resetIfNeeded(dependencies: Dependencies) {
        guard ProcessInfo.processInfo.arguments.contains(resetLaunchArgument) else { return }
        UserDefaults.standard.removeObject(forKey: "ai.chatModel")
        UserDefaults.standard.removeObject(forKey: "ai.voiceModel")
        dependencies.aiSettingsManager.deleteAPIKey()
    }
}
