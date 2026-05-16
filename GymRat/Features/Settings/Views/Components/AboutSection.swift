import SwiftUI

struct AboutSection: View {
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


    var body: some View {
        Section("about_section") {
            InfoRow(
                titleKey: "app_version_label",
                valueText: appVersion
            )

            InfoRow(
                titleKey: "developer_label",
                valueText: developerHandle
            )

            if let supportEmailURL {
                LinkRow(
                    titleKey: "support_email_label",
                    valueKey: "@email_support",
                    url: supportEmailURL
                )
            }

            if let privacyURL {
                LinkRow(
                    titleKey: "privacy_policy_label",
                    valueKey: nil,
                    url: privacyURL
                )
            }

            if let githubURL {
                LinkRow(
                    titleKey: "github_label",
                    valueKey: nil,
                    url: githubURL
                )
            }

            if let exerciseDBURL {
                LinkRow(
                    titleKey: "exercise_images_source_label",
                    valueKey: nil,
                    url: exerciseDBURL
                )
            }
        }
    }
}
