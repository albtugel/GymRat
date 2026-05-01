import SwiftUI

struct SettingsAboutSectionView: View {
    private let appVersion: String
    private let developerHandle: String
    private let supportEmailURL: URL?
    private let privacyURL: URL?
    private let githubURL: URL?
    private let exerciseDBURL: URL?

    init(
        appVersion: String,
        developerHandle: String,
        supportEmailURL: URL?,
        privacyURL: URL?,
        githubURL: URL?,
        exerciseDBURL: URL?
    ) {
        self.appVersion = appVersion
        self.developerHandle = developerHandle
        self.supportEmailURL = supportEmailURL
        self.privacyURL = privacyURL
        self.githubURL = githubURL
        self.exerciseDBURL = exerciseDBURL
    }

    // MARK: - Body
    var body: some View {
        Section("about_section") {
            SettingsInfoRowView(
                titleKey: "app_version_label",
                valueText: appVersion
            )

            SettingsInfoRowView(
                titleKey: "developer_label",
                valueText: developerHandle
            )

            if let supportEmailURL {
                SettingsLinkRowView(
                    titleKey: "support_email_label",
                    valueKey: "@email_support",
                    url: supportEmailURL
                )
            }

            if let privacyURL {
                SettingsLinkRowView(
                    titleKey: "privacy_policy_label",
                    valueKey: nil,
                    url: privacyURL
                )
            }

            if let githubURL {
                SettingsLinkRowView(
                    titleKey: "github_label",
                    valueKey: nil,
                    url: githubURL
                )
            }

            if let exerciseDBURL {
                SettingsLinkRowView(
                    titleKey: "exercise_images_source_label",
                    valueKey: nil,
                    url: exerciseDBURL
                )
            }
        }
    }
}
