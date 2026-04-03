import SwiftUI

struct ExerciseTechniqueSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseTechniqueViewModel

    init(seed: ExerciseStore.ExerciseSeed) {
        _viewModel = State(initialValue: ExerciseTechniqueViewModel(seed: seed))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ExerciseTechniqueContentView(
                    imageURLs: viewModel.imageURLs,
                    placeholderSystemName: viewModel.placeholderSystemName,
                    musclesTitle: viewModel.musclesTitle,
                    muscleLabels: viewModel.muscleLabels
                )
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done_button") { dismiss() }
                }
            }
        }
    }
}
