import Foundation

struct ProgramTemplate: Identifiable {
    let id: UUID
    let name: String
    let type: ProgramType

    init(id: UUID = UUID(), name: String, type: ProgramType) {
        self.id = id
        self.name = name
        self.type = type
    }

    static let templates: [ProgramTemplate] = ProgramType.allCases.map {
        ProgramTemplate(name: ProgramTypeText.title(for: $0), type: $0)
    }
}
