import Foundation

actor ExerciseRepo {
    static let shared = ExerciseRepo()

    nonisolated var seeds: [ExerciseSeed] {
        Self.localSeeds
    }

    private var exercises: [Exercise] = []
    private var mergedSeeds: [ExerciseSeed] = []
    private var remoteCache: [RemoteExercise] = []

    private let baseURL = "https://oss.exercisedb.dev/api/v1/exercises"

    private init() {
        if let cached = Self.loadCachedRemoteExercises(fileName: Self.cacheFileName) {
            remoteCache = cached
            exercises = Self.mergeWithSeeds(remoteExercises: cached)
            mergedSeeds = Self.makeMergedSeeds(remoteExercises: cached)
            Self.log("Restored \(cached.count) API exercises from cache.")
        } else {
            exercises = Self.mergeWithSeeds(remoteExercises: [])
            mergedSeeds = Self.localSeeds
            Self.log("Started with local seeds; API cache is empty.")
        }
    }

    func refresh() async -> [Exercise] {
        if !remoteCache.isEmpty {
            Self.log("ExerciseDB refresh skipped: using \(remoteCache.count) cached exercises.")
            return exercises
        }

        do {
            Self.log("Refreshing exercise catalog from ExerciseDB.")
            let remoteExercises = try await fetchExercises()
            remoteCache = remoteExercises
            exercises = Self.mergeWithSeeds(remoteExercises: remoteExercises)
            mergedSeeds = Self.makeMergedSeeds(remoteExercises: remoteExercises)
            Self.saveCachedRemoteExercises(remoteExercises, fileName: Self.cacheFileName)
            Self.log("Refresh completed. API: \(remoteExercises.count), merged: \(exercises.count), seeds: \(mergedSeeds.count).")
            return exercises
        } catch {
            Self.log("ExerciseDB refresh failed: \(error.localizedDescription)")
            if let cached = Self.loadCachedRemoteExercises(fileName: Self.cacheFileName), !cached.isEmpty {
                remoteCache = cached
                exercises = Self.mergeWithSeeds(remoteExercises: cached)
                mergedSeeds = Self.makeMergedSeeds(remoteExercises: cached)
                Self.log("Using cached API exercises: \(cached.count).")
            } else if exercises.isEmpty {
                exercises = Self.mergeWithSeeds(remoteExercises: [])
                mergedSeeds = Self.localSeeds
                Self.log("Using local seeds only.")
            }
            return exercises
        }
    }

    func fetchExercises() async throws -> [RemoteExercise] {
        var allExercises: [RemoteExercise] = []
        var cursor: String?
        var page = 1

        repeat {
            var components = URLComponents(string: baseURL)
            var queryItems = [URLQueryItem(name: "limit", value: "100")]
            if let cursor {
                queryItems.append(URLQueryItem(name: "cursor", value: cursor))
            }
            components?.queryItems = queryItems
            guard let url = components?.url else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 20
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            if let httpResponse = urlResponse as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                let message = String(data: data, encoding: .utf8) ?? "No response body"
                Self.log("ExerciseDB page \(page) failed with HTTP \(httpResponse.statusCode): \(message)")
                throw URLError(.badServerResponse)
            }

            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            guard response.success else { throw URLError(.cannotParseResponse) }

            allExercises.append(contentsOf: response.data)
            Self.log("Fetched ExerciseDB page \(page): +\(response.data.count), total \(allExercises.count).")
            cursor = response.meta.hasNextPage ? response.meta.nextCursor : nil
            page += 1
        } while cursor != nil

        return allExercises
    }

    func mergeWithSeeds() -> [Exercise] {
        Self.mergeWithSeeds(remoteExercises: remoteCache)
    }

    func getExercises(by category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }

    func getExercise(by id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }

    func seedSnapshot() -> [ExerciseSeed] {
        mergedSeeds.isEmpty ? Self.localSeeds : mergedSeeds
    }

    func getExerciseSeed(named name: String) -> ExerciseSeed? {
        let normalizedName = name.normalizedExerciseToken
        return seedSnapshot().first {
            $0.name.normalizedExerciseToken == normalizedName
                || $0.canonicalName.normalizedExerciseToken == normalizedName
                || $0.remoteExercise?.name.normalizedExerciseToken == normalizedName
        }
    }

    func getExerciseSeedResolvingRemote(named name: String) async -> ExerciseSeed? {
        guard let seed = getExerciseSeed(named: name) else { return nil }
        guard seed.gifURL == nil else { return seed }

        do {
            guard let remote = try await fetchBestRemoteExercise(for: seed) else { return seed }
            remoteCache = (remoteCache + [remote]).uniqued(by: \.exerciseId)
            exercises = Self.mergeWithSeeds(remoteExercises: remoteCache)
            mergedSeeds = Self.makeMergedSeeds(remoteExercises: remoteCache)
            Self.saveCachedRemoteExercises(remoteCache, fileName: Self.cacheFileName)
            return getExerciseSeed(named: name) ?? seed
        } catch {
            Self.log("ExerciseDB lookup for '\(seed.canonicalName)' failed: \(error.localizedDescription)")
            return seed
        }
    }

    func fetchAndCacheExercises() async {
        _ = await refresh()
    }

    private func fetchBestRemoteExercise(for seed: ExerciseSeed) async throws -> RemoteExercise? {
        var candidates: [RemoteExercise] = []
        for name in Self.preferredRemoteNames(for: seed) {
            let fetched = try await fetchExercises(named: name)
            candidates.append(contentsOf: fetched)
            if fetched.contains(where: { Self.namesMatch(seedName: seed.canonicalName, remoteName: $0.name) }) {
                break
            }
        }

        return candidates
            .uniqued(by: \.exerciseId)
            .filter { $0.gifUrl != nil }
            .sorted { first, second in
                let firstScore = Self.matchScore(remote: first, seed: seed)
                let secondScore = Self.matchScore(remote: second, seed: seed)
                return firstScore == secondScore
                    ? first.name.count < second.name.count
                    : firstScore > secondScore
            }
            .first
    }

    private func fetchExercises(named name: String) async throws -> [RemoteExercise] {
        var allExercises: [RemoteExercise] = []
        var cursor: String?
        var page = 1

        repeat {
            var components = URLComponents(string: baseURL)
            var queryItems = [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "limit", value: "25")
            ]
            if let cursor {
                queryItems.append(URLQueryItem(name: "cursor", value: cursor))
            }
            components?.queryItems = queryItems
            guard let url = components?.url else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 20
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            if let httpResponse = urlResponse as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                let message = String(data: data, encoding: .utf8) ?? "No response body"
                Self.log("ExerciseDB lookup '\(name)' page \(page) failed with HTTP \(httpResponse.statusCode): \(message)")
                return allExercises
            }

            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            guard response.success else { throw URLError(.cannotParseResponse) }

            allExercises.append(contentsOf: response.data)
            cursor = response.meta.hasNextPage ? response.meta.nextCursor : nil
            page += 1
        } while cursor != nil

        Self.log("Fetched ExerciseDB lookup '\(name)': \(allExercises.count) candidates.")
        return allExercises
    }

    private static func mergeWithSeeds(remoteExercises: [RemoteExercise]) -> [Exercise] {
        let remoteBySeedKey = makeRemoteBySeedKey(remoteExercises: remoteExercises)
        let mergedFromSeeds = localSeeds.map { seed -> Exercise in
            guard let remote = remoteBySeedKey[seed.matchKey] else {
                return Exercise(
                    id: stableSeedId(for: seed.name),
                    name: seed.name,
                    localizedName: seed.name,
                    category: seed.category,
                    muscles: seed.muscles,
                    inputType: seed.inputType,
                    gifUrl: nil,
                    bodyParts: [],
                    targetMuscles: [],
                    secondaryMuscles: [],
                    equipments: [],
                    instructions: [],
                    source: .seed
                )
            }

            let mappedMuscles = mappedMuscles(for: remote, seed: seed)

            return Exercise(
                id: remote.exerciseId,
                name: remote.name,
                localizedName: seed.name,
                category: seed.category,
                muscles: mappedMuscles.isEmpty ? seed.muscles : mappedMuscles,
                inputType: seed.inputType,
                gifUrl: remote.gifUrl,
                bodyParts: remote.bodyParts,
                targetMuscles: remote.targetMuscles,
                secondaryMuscles: remote.secondaryMuscles ?? [],
                equipments: remote.equipments ?? [],
                instructions: remote.instructions ?? [],
                source: .api
            )
        }

        let matchedRemoteIds = Set(remoteBySeedKey.values.map(\.exerciseId))
        let apiOnly = remoteExercises
            .filter { !matchedRemoteIds.contains($0.exerciseId) }
            .map { remote in
                Exercise(
                    id: remote.exerciseId,
                    name: remote.name,
                    localizedName: remote.name,
                    category: category(for: remote),
                    muscles: MuscleGroup.map(
                        targetMuscles: remote.targetMuscles,
                        bodyParts: remote.bodyParts,
                        secondaryMuscles: remote.secondaryMuscles ?? []
                    ),
                    inputType: .strength,
                    gifUrl: remote.gifUrl,
                    bodyParts: remote.bodyParts,
                    targetMuscles: remote.targetMuscles,
                    secondaryMuscles: remote.secondaryMuscles ?? [],
                    equipments: remote.equipments ?? [],
                    instructions: remote.instructions ?? [],
                    source: .api
                )
            }

        return (mergedFromSeeds + apiOnly).uniqued(by: \.id)
    }

    private static func makeMergedSeeds(remoteExercises: [RemoteExercise]) -> [ExerciseSeed] {
        let remoteBySeedKey = makeRemoteBySeedKey(remoteExercises: remoteExercises)
        return localSeeds.map { seed in
            guard let remote = remoteBySeedKey[seed.matchKey] else { return seed }
            let mappedMuscles = mappedMuscles(for: remote, seed: seed)
            return ExerciseSeed(
                name: seed.name,
                canonicalName: seed.canonicalName,
                category: seed.category,
                muscles: mappedMuscles.isEmpty ? seed.muscles : mappedMuscles,
                inputType: seed.inputType,
                exerciseId: remote.exerciseId,
                remoteExercise: remote
            )
        }
    }

    private static func makeRemoteBySeedKey(remoteExercises: [RemoteExercise]) -> [String: RemoteExercise] {
        var resolved: [String: RemoteExercise] = [:]
        let remoteByName = Dictionary(
            remoteExercises.map { ($0.name.normalizedExerciseToken, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let remoteById = Dictionary(
            remoteExercises.map { ($0.exerciseId, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for seed in localSeeds {
            guard let remote = resolveRemoteExercise(
                for: seed,
                remoteByName: remoteByName,
                remoteById: remoteById,
                remoteExercises: remoteExercises
            ) else {
                Self.log("No exact API match for seed '\(seed.canonicalName)'. Keeping it without gifUrl.")
                continue
            }
            resolved[seed.matchKey] = remote
            Self.log("Matched seed '\(seed.canonicalName)' -> '\(remote.name)' (\(remote.exerciseId)).")
        }

        return resolved
    }

    private static func mappedMuscles(for remote: RemoteExercise, seed: ExerciseSeed) -> [MuscleGroup] {
        guard category(for: remote) == seed.category else { return seed.muscles }
        return MuscleGroup.map(
            targetMuscles: remote.targetMuscles,
            bodyParts: remote.bodyParts,
            secondaryMuscles: remote.secondaryMuscles ?? []
        )
    }

    private static func resolveRemoteExercise(
        for seed: ExerciseSeed,
        remoteByName: [String: RemoteExercise],
        remoteById: [String: RemoteExercise],
        remoteExercises: [RemoteExercise]
    ) -> RemoteExercise? {
        if seed.category == .cardio,
           let exerciseId = seed.exerciseId,
           let remote = remoteById[exerciseId] {
            return remote
        }

        let preferredNames = preferredRemoteNames(for: seed)
        for name in preferredNames {
            if let remote = remoteByName[name.normalizedExerciseToken] {
                return remote
            }
        }

        if let exerciseId = seed.exerciseId,
           let remote = remoteById[exerciseId],
           preferredNames.contains(where: { namesMatch(seedName: $0, remoteName: remote.name) }) {
            return remote
        }

        let canonical = seed.canonicalName.normalizedExerciseToken
        guard canonical.split(separator: " ").count > 1 else { return nil }

        return remoteExercises
            .filter { namesMatch(seedName: seed.canonicalName, remoteName: $0.name) }
            .sorted {
                $0.name.count == $1.name.count
                    ? $0.exerciseId < $1.exerciseId
                    : $0.name.count < $1.name.count
            }
            .first
    }

    private static func preferredRemoteNames(for seed: ExerciseSeed) -> [String] {
        let canonical = seed.canonicalName
        var names = preferredRemoteNameOverrides[seed.localizationKey ?? ""] ?? []
        names.append(canonical)

        if !canonical.normalizedExerciseToken.hasPrefix("barbell ") { names.append("barbell \(canonical)") }
        if !canonical.normalizedExerciseToken.hasPrefix("dumbbell ") { names.append("dumbbell \(canonical)") }
        if !canonical.normalizedExerciseToken.hasPrefix("cable ") { names.append("cable \(canonical)") }
        if !canonical.normalizedExerciseToken.hasPrefix("lever ") { names.append("lever \(canonical)") }
        if !canonical.normalizedExerciseToken.hasPrefix("assisted ") { names.append("assisted \(canonical)") }

        return names.uniqued()
    }

    private static func namesMatch(seedName: String, remoteName: String) -> Bool {
        let seed = seedName.normalizedExerciseToken
        let remote = remoteName.normalizedExerciseToken
        guard !seed.isEmpty, !remote.isEmpty else { return false }
        if seed == remote { return true }
        let seedTokenCount = seed.split(separator: " ").count
        let remoteTokenCount = remote.split(separator: " ").count
        guard seedTokenCount > 1, remoteTokenCount <= seedTokenCount + 1 else { return false }
        return remote.contains(seed)
    }

    private static func matchScore(remote: RemoteExercise, seed: ExerciseSeed) -> Int {
        let remoteName = remote.name.normalizedExerciseToken
        let preferredNames = preferredRemoteNames(for: seed).map(\.normalizedExerciseToken)
        let canonical = seed.canonicalName.normalizedExerciseToken
        let canonicalTokens = canonical.split(separator: " ").map(String.init)

        var score = 0
        if preferredNames.contains(remoteName) {
            score += 10_000
        }
        if namesMatch(seedName: seed.canonicalName, remoteName: remote.name) {
            score += 5_000
        }
        if canonicalTokens.allSatisfy({ remoteName.contains($0) }) {
            score += 2_000
        }

        let remoteMuscles = MuscleGroup.map(
            targetMuscles: remote.targetMuscles,
            bodyParts: remote.bodyParts,
            secondaryMuscles: remote.secondaryMuscles ?? []
        )
        score += Set(remoteMuscles).intersection(seed.muscles).count * 250

        if remote.gifUrl != nil {
            score += 100
        }

        return score - remoteName.count
    }

    // MARK: - Helpers

    private static func category(for remote: RemoteExercise) -> ExerciseCategory {
        let haystack = (remote.bodyParts + remote.targetMuscles + [remote.name])
            .joined(separator: " ")
            .normalizedExerciseToken
        return haystack.contains("cardio") || haystack.contains("cardiovascular") ? .cardio : .strength
    }

    private static func stableSeedId(for name: String) -> String {
        "seed-\(name.normalizedExerciseToken)"
    }

    static func log(_ message: String) {
        print("[ExerciseRepo] \(message)")
    }
}
