import SwiftUI

struct ProgramCustomizeExercisesSectionView: View {
    private let viewModel: ProgramCustomizeViewModel

    init(viewModel: ProgramCustomizeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Section("exercises_section") {
            ProgramCustomizeExerciseSearchBar(viewModel: viewModel)

            if viewModel.showsMuscleFilter {
                ProgramCustomizeMuscleFilterView(viewModel: viewModel)
            }

            ForEach(viewModel.filteredExerciseSeeds, id: \.name) { seed in
                let info = viewModel.resolveSelectionInfo(for: seed)
                ProgramCustomizeExerciseRowView(
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

            ProgramCustomizeCreateExerciseButton(viewModel: viewModel)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedExerciseIds)
    }
}
