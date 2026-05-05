import SwiftUI

struct CreateExerciseButton: View {
    private let viewModel: ProgramEditorViewModel

    init(viewModel: ProgramEditorViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Button {
            viewModel.presentCreateExerciseAlert()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("create_exercise_button")
            }
            .foregroundColor(.accentColor)
        }
        .alert(LocalizedStringKey(Alerts.CreateExercise.title), isPresented: createAlertBinding) {
            TextField("exercise_name_placeholder", text: newExerciseNameBinding)
                .autocorrectionDisabled()
            Picker("", selection: newExerciseCategoryBinding) {
                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    Text(ExerciseCategoryText.localizedLabel(for: cat)).tag(cat)
                }
            }
            Button("save_button") {
                Task { await viewModel.createCustomExercise() }
            }
            Button("cancel_button", role: .cancel) {
                viewModel.dismissCreateExerciseAlert()
            }
        } message: {
            Text(LocalizedStringKey(Alerts.CreateExercise.message))
        }
    }

    // MARK: - Helpers
    private var newExerciseNameBinding: Binding<String> {
        Binding(
            get: { viewModel.newExerciseName },
            set: { viewModel.updateNewExerciseName($0) }
        )
    }

    private var newExerciseCategoryBinding: Binding<ExerciseCategory> {
        Binding(
            get: { viewModel.newExerciseCategory },
            set: { viewModel.updateNewExerciseCategory($0) }
        )
    }

    private var createAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showCreateAlert },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissCreateExerciseAlert()
                }
            }
        )
    }
}
