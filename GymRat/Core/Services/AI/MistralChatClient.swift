import Foundation

enum MistralClientError: LocalizedError {
    case invalidURL
    case missingResponse
    case emptyContent
    case requestFailed(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "ai_invalid_url_error")
        case .missingResponse:
            return String(localized: "ai_missing_response_error")
        case .emptyContent:
            return String(localized: "ai_empty_response_error")
        case .requestFailed(_, let message):
            return message
        }
    }
}

struct MistralChatMessage: Codable {
    let role: String
    let content: String
}

protocol MistralChatCompleting {
    func completeJSON(apiKey: String, model: String, messages: [MistralChatMessage]) async throws -> String
}

final class MistralChatClient: MistralChatCompleting {
    private struct ChatRequest: Encodable {
        struct ResponseFormat: Encodable {
            struct JSONSchema: Encodable {
                let name: String
                let schema: JSONValue
            }

            let type: String
            let jsonSchema: JSONSchema

            enum CodingKeys: String, CodingKey {
                case type
                case jsonSchema = "json_schema"
            }
        }

        let model: String
        let messages: [MistralChatMessage]
        let temperature: Double
        let responseFormat: ResponseFormat

        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case temperature
            case responseFormat = "response_format"
        }
    }

    private struct ChatResponse: Decodable {
        struct Choice: Decodable {
            let message: Message
        }

        struct Message: Decodable {
            let content: ChatContent
        }

        let choices: [Choice]
    }

    private enum ChatContent: Decodable {
        struct Chunk: Decodable {
            let type: String?
            let text: String?
        }

        case string(String)
        case chunks([Chunk])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .string(string)
                return
            }
            self = .chunks(try container.decode([Chunk].self))
        }

        var text: String {
            switch self {
            case .string(let value):
                return value
            case .chunks(let chunks):
                return chunks.compactMap(\.text).joined()
            }
        }
    }

    private struct ErrorResponse: Decodable {
        struct APIError: Decodable {
            let message: String?
        }

        let error: APIError?
        let message: String?
    }

    private let endpoint: URL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        endpoint: URL = URL(string: "https://api.mistral.ai/v1/chat/completions")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func completeJSON(apiKey: String, model: String, messages: [MistralChatMessage]) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(ChatRequest(
            model: model,
            messages: messages,
            temperature: 0.1,
            responseFormat: Self.workoutPlanEditResponseFormat
        ))

        let (data, response) = try await session.data(for: request)
        try validate(data: data, response: response)
        let decoded = try decoder.decode(ChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content.text else {
            throw MistralClientError.emptyContent
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw MistralClientError.emptyContent
        }
        return trimmed
    }

    private func validate(data: Data, response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw MistralClientError.missingResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let decoded = try? decoder.decode(ErrorResponse.self, from: data)
            let fallback = HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            let message = decoded?.error?.message ?? decoded?.message ?? fallback
            throw MistralClientError.requestFailed(http.statusCode, message)
        }
    }

    private static let workoutPlanEditResponseFormat = ChatRequest.ResponseFormat(
        type: "json_schema",
        jsonSchema: .init(
            name: "workout_plan_edit",
            schema: .object([
                "type": .string("object"),
                "additionalProperties": .bool(false),
                "required": .array([.string("exercises")]),
                "properties": .object([
                    "program_name": .object([
                        "type": .array([.string("string"), .string("null")])
                    ]),
                    "exercises": .object([
                        "type": .string("array"),
                        "items": .object([
                            "type": .string("object"),
                            "additionalProperties": .bool(false),
                            "required": .array([
                                .string("name"),
                                .string("sets"),
                                .string("reps")
                            ]),
                            "properties": .object([
                                "name": .object([
                                    "type": .string("string")
                                ]),
                                "sets": .object([
                                    "type": .string("integer"),
                                    "minimum": .int(1),
                                    "maximum": .int(10)
                                ]),
                                "reps": .object([
                                    "type": .string("integer"),
                                    "minimum": .int(0)
                                ])
                            ])
                        ])
                    ])
                ])
            ])
        )
    )
}

private enum JSONValue: Encodable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}
