import SwiftUI

struct ExercisePickerView: View {
    private let viewModel: ProgramEditorViewModel

    init(viewModel: ProgramEditorViewModel) {
        self.viewModel = viewModel
    }


    var body: some View {
        Section("exercises_section") {
            ExerciseSearchBar(viewModel: viewModel)

            if viewModel.showsMuscleFilter {
                MuscleFilterView(viewModel: viewModel)
            }

            ForEach(viewModel.filteredExerciseSeeds, id: \.name) { seed in
                let info = viewModel.resolveSelectionInfo(for: seed)
                ExercisePickerRowView(
                    seed: seed,
                    selectedExercise: info.selectedExercise,
                    selectionNumber: info.selectionNumber,
                    isEditing: viewModel.isEditing,
                    onToggle: { selectedSeed in
                        Task { await viewModel.toggleExercise(selectedSeed) }
                    },
                    onClearHistory: { exercise in
                        Task { await viewModel.clearHistory(for: exercise) }
                    }
                )
            }

            CreateExerciseButton(viewModel: viewModel)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedExerciseIds)
    }
}
