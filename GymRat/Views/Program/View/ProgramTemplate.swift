import Foundation

struct ProgramTemplate: Identifiable {
    let id: UUID
    let name: String
    let typeRaw: String

    init(id: UUID = UUID(), name: String, typeRaw: String) {
        self.id = id
        self.name = name
        self.typeRaw = typeRaw
    }

    static let templates: [ProgramTemplate] = [
        ProgramTemplate(
            name: ProgramTypeDisplay.title(for: .strength),
            typeRaw: ProgramType.strength.rawValue
        ),
        ProgramTemplate(
            name: ProgramTypeDisplay.title(for: .cardio),
            typeRaw: ProgramType.cardio.rawValue
        ),
        ProgramTemplate(
            name: ProgramTypeDisplay.title(for: .crossfit),
            typeRaw: ProgramType.crossfit.rawValue
        )
    ]
}
