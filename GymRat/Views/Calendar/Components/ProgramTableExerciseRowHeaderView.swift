import SwiftUI

struct ProgramTableExerciseRowHeaderView: View {
    private let name: String
    private let isSharedHistory: Bool
    private let selectionIndex: Int
    private let accentColor: Color
    private let seed: ExerciseStore.ExerciseSeed?

    init(
        name: String,
        isSharedHistory: Bool,
        selectionIndex: Int,
        accentColor: Color,
        seed: ExerciseStore.ExerciseSeed?
    ) {
        self.name = name
        self.isSharedHistory = isSharedHistory
        self.selectionIndex = selectionIndex
        self.accentColor = accentColor
        self.seed = seed
    }

    // MARK: - Body
    var body: some View {
        HStack {
            Text(name)
                .font(.headline)

            if isSharedHistory {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(accentColor)
                    .font(.system(size: 16))
            }

            Spacer()

            if selectionIndex > 0 {
                ZStack {
                    Circle()
                        .fill(accentColor)
                    Text("\(selectionIndex)")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(width: 22, height: 22)
            }

            if let seed, seed.exerciseDBKey != nil {
                ExerciseTechniqueButton(seed: seed)
            }
        }
    }
}
