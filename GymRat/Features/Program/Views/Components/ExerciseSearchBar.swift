import SwiftUI

struct ExerciseSearchBar: View {
    private let viewModel: ProgramEditorViewModel

    init(viewModel: ProgramEditorViewModel) {
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
                .onSubmit { viewModel.updateSearch(searchTextBinding.wrappedValue) }
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
            set: { viewModel.updateSearch($0) }
        )
    }
}
