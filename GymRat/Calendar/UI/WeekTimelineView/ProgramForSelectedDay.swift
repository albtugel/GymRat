import SwiftUI
import UIKit

struct ProgramForSelectedDayView: View {
    let selectedDate: Date

    @EnvironmentObject private var programManager: ProgramManager
    let onAddProgramTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                let programs = programManager.programs(for: selectedDate)

                ForEach(programs) { program in
                    ProgramTableView(program: program, selectedDate: selectedDate)
                }

                HStack {
                    Spacer()
                    Button {
                        onAddProgramTap()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add_program_button")
                        }
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }
}
