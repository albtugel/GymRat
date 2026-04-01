import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ProgramForSelectedDayView: View {
    let selectedDate: Date

    @EnvironmentObject private var programManager: ProgramManager
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var context
    let onAddProgramTap: () -> Void
    @State private var dayPrograms: [ProgramModel] = []
    @State private var draggingProgram: ProgramModel?
    @State private var editingProgram: ProgramModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(dayPrograms) { program in
                    ProgramTableView(
                        program: program,
                        selectedDate: selectedDate,
                        onEdit: { editingProgram = $0 }
                    )
                        .onDrag {
                            draggingProgram = program
                            return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.data.identifier)
                        }
                        .onDrop(
                            of: [UTType.data],
                            delegate: ProgramDropDelegate(
                                item: program,
                                programs: $dayPrograms,
                                dragging: $draggingProgram,
                                onReorder: applyDayProgramOrder
                            )
                        )
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
                        .foregroundColor(themeManager.accentColor)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, dayPrograms.isEmpty ? 10 : 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .overlay(
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(height: 2)
                    Spacer()
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(height: 2)
                }
            )
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .sheet(item: $editingProgram) { program in
            ProgramCustomizeSheetView(
                mode: .edit,
                program: program
            )
            .environmentObject(programManager)
            .environmentObject(themeManager)
            .accentColor(themeManager.accentColor)
            .environment(\.modelContext, context)
        }
        .onAppear(perform: reloadPrograms)
        .onChange(of: selectedDate) { _, _ in
            reloadPrograms()
        }
        .onReceive(programManager.$customPrograms) { _ in
            reloadPrograms()
        }
    }

    private func reloadPrograms() {
        dayPrograms = programManager.programs(for: selectedDate)
    }

    private func applyDayProgramOrder(_ reordered: [ProgramModel]) {
        let ids = reordered.map(\.id)
        var updated = programManager.customPrograms
        let indices = updated.enumerated().compactMap { index, element in
            ids.contains(element.id) ? index : nil
        }
        if indices.count == reordered.count {
            for (orderIndex, programIndex) in indices.enumerated() {
                updated[programIndex] = reordered[orderIndex]
            }
            programManager.customPrograms = updated
        } else {
            updated.removeAll { ids.contains($0.id) }
            updated.append(contentsOf: reordered)
            programManager.customPrograms = updated
        }
        dayPrograms = reordered
    }
}
