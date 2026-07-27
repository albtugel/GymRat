import Foundation

/// Thin async client for the WorkoutX exercise API (https://workoutxapp.com).
///
/// The API key is injected at construction (e.g. `WorkoutXClient(apiKey: Secrets.workoutXAPIKey)`),
/// so this type stays decoupled from where secrets are stored. Endpoints, headers and JSON shape
/// follow WorkoutX's published docs; the exact field names and whether the GIF endpoint needs the
/// key are verified against the live API once a real key is wired in.
///
/// - Note: **Not wired in yet.** The app currently sources exercise media and metadata from
///   `exercisedb.dev` (no auth) via `ExerciseRepo`, so nothing instantiates this client and the
///   `RAPID_*` / `WORKOUTX_API_KEY` secrets are unused. This is intentional groundwork — when
///   WorkoutX is adopted, create it as `WorkoutXClient(apiKey: Secrets.workoutXAPIKey)` and first
///   validate the endpoints, headers and JSON shape below against the live API.
struct WorkoutXClient: Sendable {
    struct Exercise: Codable, Sendable, Identifiable {
        let id: String
        let name: String
        let bodyPart: String?
        let target: String?
        let equipment: String?
        let secondaryMuscles: [String]?
        let gifUrl: String?
        let instructions: [String]?
        let difficulty: String?
    }

    /// List endpoints wrap their results as `{ total, count, data: [...] }`.
    private struct ListResponse: Codable {
        let total: Int?
        let count: Int?
        let data: [Exercise]
    }

    enum ClientError: Error {
        case missingAPIKey
        case badURL
        case httpStatus(Int)
    }

    private static let baseURL = "https://api.workoutxapp.com/v1"
    private static let pageSize = 100

    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Request plumbing

    private func makeRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard !apiKey.isEmpty else { throw ClientError.missingAPIKey }

        var components = URLComponents(string: Self.baseURL + path)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components?.url else { throw ClientError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(apiKey, forHTTPHeaderField: "X-WorkoutX-Key")
        return request
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.httpStatus(http.statusCode)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    // MARK: - Exercises

    /// One page of exercises. `GET /v1/exercises?limit=&offset=`.
    func fetchExercises(limit: Int = pageSize, offset: Int = 0) async throws -> [Exercise] {
        let request = try makeRequest(path: "/exercises", queryItems: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ])
        let response: ListResponse = try await send(request)
        return response.data
    }

    /// The whole catalog, paged by offset until a short page signals the end.
    /// Note: every page is one billed request against the monthly quota.
    func fetchAllExercises() async throws -> [Exercise] {
        var all: [Exercise] = []
        var offset = 0
        while true {
            let page = try await fetchExercises(limit: Self.pageSize, offset: offset)
            all.append(contentsOf: page)
            guard page.count == Self.pageSize, offset < 10_000 else { break }
            offset += Self.pageSize
        }
        return all
    }

    /// A single exercise by id. `GET /v1/exercises/exercise/:id`.
    func fetchExercise(id: String) async throws -> Exercise? {
        let request = try makeRequest(path: "/exercises/exercise/\(id)")
        if let single = try? await send(request) as Exercise { return single }
        let response: ListResponse = try await send(request)
        return response.data.first
    }

    /// Name search. `GET /v1/exercises/name/:name`.
    func searchByName(_ name: String) async throws -> [Exercise] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let request = try makeRequest(path: "/exercises/name/\(encoded)")
        let response: ListResponse = try await send(request)
        return response.data
    }

    /// Deterministic GIF URL for an exercise id (`/v1/gifs/:id`).
    /// This is the metered API host — confirm whether the key header is required (and whether
    /// each load counts against the quota) once the live key is in place.
    static func gifURLString(forExerciseId id: String) -> String {
        "\(baseURL)/gifs/\(id)"
    }
}
