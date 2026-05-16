import Foundation

protocol MistralAPIKeyValidating {
    func validate(apiKey: String) async throws
}

final class MistralAPIKeyValidator: MistralAPIKeyValidating {
    private struct ErrorResponse: Decodable {
        struct APIError: Decodable {
            let message: String?
        }

        let error: APIError?
        let message: String?
    }

    private let endpoint: URL
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(
        endpoint: URL = URL(string: "https://api.mistral.ai/v1/models")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func validate(apiKey: String) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
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
}

struct AcceptingMistralAPIKeyValidator: MistralAPIKeyValidating {
    func validate(apiKey: String) async throws { }
}
