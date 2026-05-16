import Foundation

protocol MistralTranscribing {
    func transcribe(apiKey: String, model: String, audioFileURL: URL) async throws -> String
}

final class MistralTranscriptionClient: MistralTranscribing {
    private struct TranscriptionResponse: Decodable {
        let text: String
    }

    private let endpoint: URL
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(
        endpoint: URL = URL(string: "https://api.mistral.ai/v1/audio/transcriptions")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func transcribe(apiKey: String, model: String, audioFileURL: URL) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try makeBody(boundary: boundary, model: model, audioFileURL: audioFileURL)

        let (data, response) = try await session.data(for: request)
        try validate(data: data, response: response)
        let decoded = try decoder.decode(TranscriptionResponse.self, from: data)
        let trimmed = decoded.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw MistralClientError.emptyContent
        }
        return trimmed
    }

    private func makeBody(boundary: String, model: String, audioFileURL: URL) throws -> Data {
        var body = Data()
        appendField(name: "model", value: model, boundary: boundary, to: &body)
        appendFile(
            name: "file",
            fileName: audioFileURL.lastPathComponent,
            mimeType: "audio/m4a",
            data: try Data(contentsOf: audioFileURL),
            boundary: boundary,
            to: &body
        )
        body.append("--\(boundary)--\r\n")
        return body
    }

    private func appendField(name: String, value: String, boundary: String, to body: inout Data) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    private func appendFile(
        name: String,
        fileName: String,
        mimeType: String,
        data: Data,
        boundary: String,
        to body: inout Data
    ) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    private func validate(data: Data, response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw MistralClientError.missingResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            throw MistralClientError.requestFailed(http.statusCode, message)
        }
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
