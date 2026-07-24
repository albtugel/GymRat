import Foundation


extension ExerciseRepo {
    /// ExerciseDB serves media at a fixed path, so a known exercise id is enough to show a GIF
    /// even when the catalog API is unreachable.
    static func mediaURLString(forExerciseId id: String) -> String {
        "https://static.exercisedb.dev/media/\(id).gif"
    }

    struct Exercise: Identifiable, Codable, Equatable, Sendable {
        let id: String
        let name: String
        let localizedName: String
        let category: ExerciseCategory
        let muscles: [MuscleGroup]
        let inputType: ExerciseInputType
        let gifUrl: String?
        let bodyParts: [String]
        let targetMuscles: [String]
        let secondaryMuscles: [String]
        let equipments: [String]
        let instructions: [String]
        let source: Source

        enum Source: String, Codable, Sendable {
            case api
            case seed
        }

        var gifURL: URL? {
            guard let gifUrl else { return nil }
            return URL(string: gifUrl)
        }

        var iconURL: URL? { gifURL }
    }

    struct RemoteExercise: Codable, Equatable, Sendable {
        let exerciseId: String
        let name: String
        let gifUrl: String?
        let bodyParts: [String]
        let targetMuscles: [String]
        let secondaryMuscles: [String]?
        let equipments: [String]?
        let instructions: [String]?
    }

    struct ExerciseSeed: Equatable, Sendable {
        let localizationKey: String?
        let name: String
        let canonicalName: String
        let category: ExerciseCategory
        let muscles: [MuscleGroup]
        let inputType: ExerciseInputType
        let exerciseId: String?
        var remoteExercise: RemoteExercise?

        init(
            localizedKey: String,
            category: ExerciseCategory,
            muscles: [MuscleGroup],
            inputType: ExerciseInputType,
            exerciseId: String? = nil,
            remoteExercise: RemoteExercise? = nil
        ) {
            self.localizationKey = localizedKey
            self.name = String(localized: String.LocalizationValue(localizedKey))
            self.canonicalName = EnglishLocalization.value(for: localizedKey)
            self.category = category
            self.muscles = muscles
            self.inputType = inputType
            self.exerciseId = exerciseId
            self.remoteExercise = remoteExercise
        }

        init(
            name: String,
            canonicalName: String? = nil,
            category: ExerciseCategory,
            muscles: [MuscleGroup],
            inputType: ExerciseInputType,
            exerciseId: String? = nil,
            remoteExercise: RemoteExercise? = nil
        ) {
            self.localizationKey = nil
            self.name = name
            self.canonicalName = canonicalName ?? name
            self.category = category
            self.muscles = muscles
            self.inputType = inputType
            self.exerciseId = exerciseId
            self.remoteExercise = remoteExercise
        }

        var gifURL: URL? {
            if let remoteURL = remoteExercise?.gifUrl, let url = URL(string: remoteURL) {
                return url
            }
            guard let exerciseId else { return nil }
            return URL(string: ExerciseRepo.mediaURLString(forExerciseId: exerciseId))
        }

        var iconURL: URL? { gifURL }

        var matchKey: String {
            (localizationKey ?? canonicalName).normalizedExerciseToken
        }
    }

    struct Meta: Codable, Sendable {
        let hasNextPage: Bool
        let nextCursor: String?
    }

    struct APIResponse: Codable, Sendable {
        let success: Bool
        let meta: Meta
        let data: [RemoteExercise]
    }

    /// The by-id endpoint (`/exercises/{id}`) returns a single object instead of a list.
    struct APISingleResponse: Codable, Sendable {
        let success: Bool
        let data: RemoteExercise
    }
}
