import SwiftUI

struct ProgramAlerts: ViewModifier {
    private let viewModel: ProgramEditorViewModel
    private var picker: ExercisePickerViewModel { viewModel.picker }

    init(viewModel: ProgramEditorViewModel) {
        self.viewModel = viewModel
    }


    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: errorAlertBinding) {
                Button("ok_button") { dismissErrors() }
            } message: {
                Text(viewModel.errorMessage ?? picker.errorMessage ?? "")
            }
            .alert(LocalizedStringKey(Alerts.SharedHistory.title), isPresented: sharedHistoryAlertBinding) {
                Button("shared_history_button") {
                    Task { await picker.addPendingExercise(sharedHistory: true) }
                }
                Button("separate_history_button") {
                    Task { await picker.addPendingExercise(sharedHistory: false) }
                }
                Button("cancel_button", role: .cancel) {
                    picker.dismissSharedHistoryAlert()
                }
            } message: {
                let name = picker.pendingSeed?.name ?? ""
                Text(String(format: String(localized: "shared_history_alert_message"), name))
            }
            .alert(LocalizedStringKey(Alerts.ProgramDaysRequired.title), isPresented: weekdaysRequiredAlertBinding) {
                Button("ok_button", role: .cancel) {
                    viewModel.dismissWeekdaysRequiredAlert()
                }
            } message: {
                Text(LocalizedStringKey(Alerts.ProgramDaysRequired.message))
            }
    }


    private func dismissErrors() {
        viewModel.dismissError()
        picker.dismissError()
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil || picker.errorMessage != nil },
            set: { _ in dismissErrors() }
        )
    }

    private var sharedHistoryAlertBinding: Binding<Bool> {
        Binding(
            get: { picker.showSharedHistoryAlert },
            set: { isPresented in
                if !isPresented {
                    picker.dismissSharedHistoryAlert()
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
