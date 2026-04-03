import SwiftUI

struct ExerciseTechniqueMusclesSectionView: View {
    private let title: String
    private let muscleLabels: [String]

    init(title: String, muscleLabels: [String]) {
        self.title = title
        self.muscleLabels = muscleLabels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(muscleLabels, id: \.self) { label in
                    ExerciseTechniqueMuscleChipView(text: label)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
