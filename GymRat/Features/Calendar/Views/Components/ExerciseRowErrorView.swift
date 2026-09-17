import SwiftUI

/// Inline notice under a row whose log could not be loaded or saved. Unsaved entries stay in the
/// fields, so the user retries instead of retyping.
struct ExerciseRowErrorView: View {
    let message: String
    let showsRetry: Bool
    let onRetry: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.footnote)
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("exerciseRowErrorMessage")

            if showsRetry {
                Spacer(minLength: 0)
                Button(LocalizedStringKey("retry_button")) {
                    onRetry()
                }
                .font(.footnote.weight(.semibold))
                .buttonStyle(.borderless)
                .accessibilityIdentifier("exerciseRowRetryButton")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
