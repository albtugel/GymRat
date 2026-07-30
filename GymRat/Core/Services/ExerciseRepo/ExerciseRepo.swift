import Foundation

actor ExerciseRepo {
    static let shared = ExerciseRepo()

    nonisolated var seeds: [ExerciseSeed] {
        Self.localSeeds
    }

    private var exercises: [Exercise] = []
    private var mergedSeeds: [ExerciseSeed] = []
    private var remoteCache: [RemoteExercise] = []
    /// Where bulk paging stopped, so an interrupted download resumes instead of restarting.
    private var catalogCursor: String?
    private var catalogIsComplete = false

    private let baseURL = "https://oss.exercisedb.dev/api/v1/exercises"

    /// The API caps every response at 25 items regardless of the requested limit.
    private static let pageSize = 25
    /// Hard stop so a misbehaving cursor can never turn paging into an endless request loop.
    private static let maxCatalogPages = 80
    /// Spacing between page requests. Firing ~50 requests back to back is what trips the rate limiter.
    private static let pageInterval: Duration = .milliseconds(200)
    private static let maxRateLimitRetries = 3
    /// Used when the server rate limits without a `Retry-After` header; matches the API's own advice.
    private static let defaultRetryDelay: TimeInterval = 30
    private static let maxRetryDelay: TimeInterval = 120

    private init() {
        Self.removeLegacyCaches()

        if let cached = Self.loadCachedCatalog(fileName: Self.cacheFileName), !cached.exercises.isEmpty {
            remoteCache = cached.exercises
            catalogCursor = cached.paginationCursor
            catalogIsComplete = cached.isComplete
            exercises = Self.mergeWithSeeds(remoteExercises: cached.exercises)
            mergedSeeds = Self.makeMergedSeeds(remoteExercises: cached.exercises)
            Self.log("Restored \(cached.exercises.count) API exercises from cache (complete: \(cached.isComplete)).")
        } else {
            exercises = Self.mergeWithSeeds(remoteExercises: [])
            mergedSeeds = Self.localSeeds
            Self.log("Started with local seeds; API cache is empty.")
        }
    }

    func refresh() async -> [Exercise] {
        if catalogIsComplete, !remoteCache.isEmpty {
            Self.log("ExerciseDB refresh skipped: catalog complete with \(remoteCache.count) exercises.")
            return exercises
        }

        if remoteCache.isEmpty {
            Self.log("Refreshing exercise catalog from ExerciseDB.")
        } else {
            Self.logNotice("Resuming ExerciseDB catalog download from \(remoteCache.count) cached exercises.")
        }

        let result = await fetchCatalogPages(
            startingAfter: catalogCursor,
            knownIds: Set(remoteCache.map(\.exerciseId))
        )

        guard !result.exercises.isEmpty || result.isComplete else {
            Self.logNotice("Catalog download made no progress; keeping \(remoteCache.count) cached exercises.")
            return exercises
        }

        remoteCache = (remoteCache + result.exercises).uniqued(by: \.exerciseId)
        catalogCursor = result.cursor ?? catalogCursor
        catalogIsComplete = result.isComplete
        exercises = Self.mergeWithSeeds(remoteExercises: remoteCache)
        mergedSeeds = Self.makeMergedSeeds(remoteExercises: remoteCache)
        persistCatalog()
        Self.logNotice("Refresh finished. API: \(remoteCache.count), merged: \(exercises.count), complete: \(catalogIsComplete).")
        return exercises
    }

    /// Writes the catalog together with its paging state, so single-id lookups that grow the cache
    /// never clear the cursor or the completeness flag.
    private func persistCatalog() {
        Self.saveCachedCatalog(
            CachedCatalog(
                exercises: remoteCache,
                paginationCursor: catalogCursor,
                isComplete: catalogIsComplete
            ),
            fileName: Self.cacheFileName
        )
    }

    private struct CatalogPageRun {
        var exercises: [RemoteExercise] = []
        var cursor: String?
        var isComplete = false
    }

    private enum CatalogPageOutcome {
        case success([RemoteExercise])
        case rateLimited(retryAfter: TimeInterval)
        case failed(String)
    }

    /// Pages through the bulk catalog, resuming after `startingAfter` and backing off when the API
    /// rate limits. Deliberately non-throwing: an interrupted run returns what it managed to fetch
    /// along with a cursor, so the next launch continues instead of freezing a partial catalog.
    ///
    /// `meta.hasNextPage` stays true even on the last page and `meta.nextCursor` never advances, so
    /// paging is driven by the last id seen and stops once a page adds nothing new.
    private func fetchCatalogPages(
        startingAfter startCursor: String?,
        knownIds: Set<String>
    ) async -> CatalogPageRun {
        var run = CatalogPageRun(cursor: startCursor)
        var seenIds = knownIds
        var after = startCursor
        var page = 1
        var rateLimitAttempts = 0

        while page <= Self.maxCatalogPages {
            try? await Task.sleep(for: Self.pageInterval)

            let outcome: CatalogPageOutcome
            do {
                outcome = try await fetchCatalogPage(after: after)
            } catch {
                Self.log("ExerciseDB page \(page) failed: \(error.localizedDescription). Catalog stays partial.")
                return run
            }

            switch outcome {
            case .rateLimited(let retryAfter):
                guard rateLimitAttempts < Self.maxRateLimitRetries else {
                    Self.logNotice("ExerciseDB still rate limited after \(rateLimitAttempts) retries. Catalog stays partial.")
                    return run
                }
                let delay = min(retryAfter * pow(2, Double(rateLimitAttempts)), Self.maxRetryDelay)
                rateLimitAttempts += 1
                Self.logNotice("Rate limited on page \(page); retrying in \(Int(delay))s (attempt \(rateLimitAttempts)).")
                try? await Task.sleep(for: .seconds(delay))

            case .failed(let reason):
                Self.log("ExerciseDB page \(page) failed: \(reason). Catalog stays partial.")
                return run

            case .success(let fetched):
                rateLimitAttempts = 0
                let newExercises = fetched.filter { seenIds.insert($0.exerciseId).inserted }
                run.exercises.append(contentsOf: newExercises)

                guard let lastId = fetched.last?.exerciseId, !newExercises.isEmpty else {
                    run.isComplete = true
                    Self.logNotice("ExerciseDB catalog complete: \(seenIds.count) exercises.")
                    return run
                }

                Self.log("Fetched ExerciseDB page \(page): +\(newExercises.count), total \(seenIds.count).")
                after = lastId
                run.cursor = lastId
                page += 1
            }
        }

        Self.logNotice("Hit the \(Self.maxCatalogPages)-page cap; catalog stays partial and resumes next launch.")
        return run
    }

    private func fetchCatalogPage(after: String?) async throws -> CatalogPageOutcome {
        var components = URLComponents(string: baseURL)
        var queryItems = [URLQueryItem(name: "limit", value: String(Self.pageSize))]
        if let after {
            queryItems.append(URLQueryItem(name: "after", value: after))
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
            guard httpResponse.statusCode != 429 else {
                return .rateLimited(retryAfter: Self.retryDelay(from: httpResponse))
            }
            let message = String(data: data, encoding: .utf8) ?? "No response body"
            return .failed("HTTP \(httpResponse.statusCode): \(message)")
        }

        guard let response = try? JSONDecoder().decode(APIResponse.self, from: data), response.success else {
            return .failed("unreadable body")
        }

        return .success(response.data)
    }

    /// Honours the server's `Retry-After` header, falling back to the delay the API documents.
    private static func retryDelay(from response: HTTPURLResponse) -> TimeInterval {
        guard let header = response.value(forHTTPHeaderField: "Retry-After"),
              let seconds = TimeInterval(header.trimmingCharacters(in: .whitespaces)),
              seconds > 0 else {
            return defaultRetryDelay
        }
        return min(seconds, maxRetryDelay)
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

    /// Media URLs for the given exercise names, deduplicated and skipping names the catalog cannot
    /// resolve. Used to warm the image cache ahead of the details screen.
    func gifURLs(forExerciseNames names: [String]) -> [URL] {
        var seen = Set<String>()
        return names.compactMap { name in
            guard let url = getExerciseSeed(named: name)?.gifURL,
                  seen.insert(url.absoluteString).inserted else { return nil }
            return url
        }
    }

    func getExerciseSeedResolvingRemote(named name: String) async -> ExerciseSeed? {
        guard let seed = getExerciseSeed(named: name) else { return nil }
        // A seed always has a gifURL when it carries an id (id-based media fallback), so the gate
        // is whether we still lack API metadata (target muscles, instructions), not the image.
        guard seed.remoteExercise == nil else { return seed }

        do {
            guard let remote = try await fetchRemoteExercise(for: seed) else { return seed }
            remoteCache = (remoteCache + [remote]).uniqued(by: \.exerciseId)
            exercises = Self.mergeWithSeeds(remoteExercises: remoteCache)
            mergedSeeds = Self.makeMergedSeeds(remoteExercises: remoteCache)
            persistCatalog()
            return getExerciseSeed(named: name) ?? seed
        } catch {
            Self.log("ExerciseDB lookup for '\(seed.canonicalName)' failed: \(error.localizedDescription)")
            return seed
        }
    }

    func fetchAndCacheExercises() async {
        _ = await refresh()
    }

    /// Resolves the catalog entry backing a seed, preferring the hand-verified id (an exact,
    /// deterministic lookup) and only falling back to a name search when the seed has no id.
    private func fetchRemoteExercise(for seed: ExerciseSeed) async throws -> RemoteExercise? {
        if let id = seed.exerciseId, let remote = try await fetchExercise(byId: id) {
            return remote
        }
        return try await fetchBestRemoteExercise(for: seed)
    }

    /// The `/exercises/{id}` endpoint returns the exact entry with full metadata (target muscles,
    /// instructions, equipment), so it enriches a seed reliably where name matching often misses.
    private func fetchExercise(byId id: String) async throws -> RemoteExercise? {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/\(encoded)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let httpResponse = urlResponse as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            Self.log("ExerciseDB id lookup '\(trimmed)' failed with HTTP \(httpResponse.statusCode).")
            return nil
        }

        guard let response = try? JSONDecoder().decode(APISingleResponse.self, from: data), response.success else {
            Self.log("ExerciseDB id lookup '\(trimmed)' returned an unreadable body.")
            return nil
        }

        Self.log("Resolved seed by id '\(trimmed)' -> '\(response.data.name)'.")
        return response.data
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

    /// A name search already returns the relevant candidates in one page, so it is deliberately
    /// not paginated — the API's cursor does not advance and would loop forever.
    private func fetchExercises(named name: String) async throws -> [RemoteExercise] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "limit", value: String(Self.pageSize))
        ]
        guard let url = components?.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let httpResponse = urlResponse as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "No response body"
            Self.log("ExerciseDB lookup '\(name)' failed with HTTP \(httpResponse.statusCode): \(message)")
            return []
        }

        guard let response = try? JSONDecoder().decode(APIResponse.self, from: data), response.success else {
            Self.log("ExerciseDB lookup '\(name)' returned an unreadable body.")
            return []
        }

        Self.log("Fetched ExerciseDB lookup '\(name)': \(response.data.count) candidates.")
        return response.data
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
                    gifUrl: seed.exerciseId.map { mediaURLString(forExerciseId: $0) },
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
                gifUrl: remote.gifUrl ?? mediaURLString(forExerciseId: remote.exerciseId),
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
                    gifUrl: remote.gifUrl ?? mediaURLString(forExerciseId: remote.exerciseId),
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
                Self.log("Seed '\(seed.canonicalName)' unmatched in bulk catalog; using id-based media, metadata resolves by id on open.")
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
        // Seed ids are hand-verified against the catalog, so they outrank any name guess.
        if let exerciseId = seed.exerciseId, let remote = remoteById[exerciseId] {
            return remote
        }

        let preferredNames = preferredRemoteNames(for: seed)
        for name in preferredNames {
            if let remote = remoteByName[name.normalizedExerciseToken] {
                return remote
            }
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

    /// Per-seed and per-page tracing. Debug level keeps the ~250 lines a launch produces out of
    /// release builds.
    static func log(_ message: String) {
        AppLog.exerciseRepo.debug("\(message, privacy: .public)")
    }

    /// Catalog state worth seeing in a shipped build: rate limiting, completion, partial downloads.
    static func logNotice(_ message: String) {
        AppLog.exerciseRepo.notice("\(message, privacy: .public)")
    }
}
