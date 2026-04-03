import SwiftUI

struct ProgramCustomizeExerciseSearchBar: View {
    private let viewModel: ProgramCustomizeViewModel

    init(viewModel: ProgramCustomizeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("search_exercises_placeholder", text: searchTextBinding)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit { viewModel.setSearchText(searchTextBinding.wrappedValue) }
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearSearchText()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers
    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.setSearchText($0) }
        )
    }
}
