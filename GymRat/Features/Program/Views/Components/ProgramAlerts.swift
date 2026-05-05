import SwiftUI

struct ProgramAlerts: ViewModifier {
    private let viewModel: ProgramEditorViewModel

    init(viewModel: ProgramEditorViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: errorAlertBinding) {
                Button("ok_button") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert(LocalizedStringKey(Alerts.SharedHistory.title), isPresented: sharedHistoryAlertBinding) {
                Button("shared_history_button") {
                    Task { await viewModel.addPendingExercise(sharedHistory: true) }
                }
                Button("separate_history_button") {
                    Task { await viewModel.addPendingExercise(sharedHistory: false) }
                }
                Button("cancel_button", role: .cancel) {
                    viewModel.dismissSharedHistoryAlert()
                }
            } message: {
                let name = viewModel.pendingSeed?.name ?? ""
                Text(String(format: String(localized: "shared_history_alert_message"), name))
            }
            .alert(LocalizedStringKey(Alerts.NoSharedExercise.title), isPresented: noSharedExerciseAlertBinding) {
                Button("ok_button", role: .cancel) {
                    viewModel.dismissNoSharedExerciseAlert()
                }
            } message: {
                Text(LocalizedStringKey(Alerts.NoSharedExercise.message))
            }
            .alert(LocalizedStringKey(Alerts.ProgramDaysRequired.title), isPresented: weekdaysRequiredAlertBinding) {
                Button("ok_button", role: .cancel) {
                    viewModel.dismissWeekdaysRequiredAlert()
                }
            } message: {
                Text(LocalizedStringKey(Alerts.ProgramDaysRequired.message))
            }
    }

    // MARK: - Helpers
    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.dismissError() }
        )
    }

    private var sharedHistoryAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showSharedHistoryAlert },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissSharedHistoryAlert()
                }
            }
        )
    }

    private var noSharedExerciseAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showNoSharedExerciseAlert },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissNoSharedExerciseAlert()
                }
            }
        )
    }

    private var weekdaysRequiredAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showWeekdaysRequiredAlert },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissWeekdaysRequiredAlert()
                }
            }
        )
    }
}
