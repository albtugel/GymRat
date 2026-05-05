import Foundation
import Kingfisher

final class ExerciseRepo {
    static let shared = ExerciseRepo()

    struct ExerciseSeed {
        let name: String
        let category: ExerciseCategory
        let muscles: [MuscleGroup]
        let exerciseDBKey: String?
        let inputType: ExerciseInputType
        
        private static let baseImageURL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises"

                var imageURLs: [URL] {
                    guard let key = exerciseDBKey else { return [] }

                    return ["0", "1"].compactMap {
                        URL(string: "\(Self.baseImageURL)/\(key)/\($0).jpg")
                    }
                }

                var iconURL: URL? {
                    imageURLs.first
                }
            }

    let seeds: [ExerciseSeed] = [

        // MARK: - Strength / Legs
        ExerciseSeed(name: String(localized: "exercise_squat"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Barbell_Full_Squat", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_front_squat"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Barbell_Front_Squat", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_hack_squat"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Hack_Squat", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_press"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Leg_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_extension"), category: .strength, muscles: [.legs], exerciseDBKey: "Leg_Extension", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_curl"), category: .strength, muscles: [.legs], exerciseDBKey: "Lying_Leg_Curls", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_standing_calf_raise"), category: .strength, muscles: [.calves], exerciseDBKey: "Standing_Calf_Raises", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_seated_calf_raise"), category: .strength, muscles: [.calves], exerciseDBKey: "Seated_Calf_Raise", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_lunge"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Barbell_Lunge", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_bulgarian_split_squat"), category: .strength, muscles: [.legs, .glutes], exerciseDBKey: "Barbell_Bulgarian_Split_Squat", inputType: .strength),

        // MARK: - Strength / Glutes
        ExerciseSeed(name: String(localized: "exercise_deadlift"), category: .strength, muscles: [.glutes, .back, .legs], exerciseDBKey: "Barbell_Deadlift", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_romanian_deadlift"), category: .strength, muscles: [.glutes, .legs, .back], exerciseDBKey: "Romanian_Deadlift", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_hip_thrust"), category: .strength, muscles: [.glutes], exerciseDBKey: "Barbell_Hip_Thrust", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_glute_bridge"), category: .strength, muscles: [.glutes], exerciseDBKey: "Glute_Bridge", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_pull_through"), category: .strength, muscles: [.glutes, .legs], exerciseDBKey: "Cable_Pull_Through", inputType: .strength),

        // MARK: - Strength / Chest
        ExerciseSeed(name: String(localized: "exercise_bench_press"), category: .strength, muscles: [.chest, .triceps, .shoulders], exerciseDBKey: "Barbell_Guillotine_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_incline_bench_press"), category: .strength, muscles: [.chest, .shoulders, .triceps], exerciseDBKey: "Barbell_Incline_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_decline_bench_press"), category: .strength, muscles: [.chest, .triceps], exerciseDBKey: "Barbell_Decline_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_bench_press"), category: .strength, muscles: [.chest, .triceps, .shoulders], exerciseDBKey: "Dumbbell_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_incline_bench_press"), category: .strength, muscles: [.chest, .shoulders, .triceps], exerciseDBKey: "Dumbbell_Incline_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_fly"), category: .strength, muscles: [.chest], exerciseDBKey: "Dumbbell_Flyes", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_fly"), category: .strength, muscles: [.chest], exerciseDBKey: "Cable_Crossover", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_push_up"), category: .strength, muscles: [.chest, .triceps, .shoulders], exerciseDBKey: "Push-up", inputType: .strength),

        // MARK: - Strength / Shoulders
        ExerciseSeed(name: String(localized: "exercise_overhead_press"), category: .strength, muscles: [.shoulders, .triceps], exerciseDBKey: "Barbell_Shoulder_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_shoulder_press"), category: .strength, muscles: [.shoulders, .triceps], exerciseDBKey: "Dumbbell_Shoulder_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_arnold_press"), category: .strength, muscles: [.shoulders], exerciseDBKey: "Arnold_Dumbbell_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_lateral_raise"), category: .strength, muscles: [.shoulders], exerciseDBKey: "Side_Lateral_Raise", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_front_raise"), category: .strength, muscles: [.shoulders], exerciseDBKey: "Front_Dumbbell_Raise", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_face_pull"), category: .strength, muscles: [.shoulders, .back], exerciseDBKey: "Face_Pull", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_rear_delt_fly"), category: .strength, muscles: [.shoulders, .back], exerciseDBKey: "Bent_Over_Dumbbell_Rear_Delt_Raise__With_Head_On_Bench", inputType: .strength),

        // MARK: - Strength / Back
        ExerciseSeed(name: String(localized: "exercise_barbell_row"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Barbell_Row", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_row"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Dumbbell_Row", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_seated_cable_row"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Seated_Cable_Rows", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_t_bar_row"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "T-Bar_Row_with_Handle", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_lat_pulldown"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Wide-Grip_Lat_Pulldown", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_close_grip_lat_pulldown"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Close-Grip_Front_Lat_Pulldown", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_pull_up"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Pullups", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_chin_up"), category: .strength, muscles: [.back, .biceps], exerciseDBKey: "Chin-up", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_back_extension"), category: .strength, muscles: [.back, .glutes], exerciseDBKey: "Back_Extension", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_shrug"), category: .strength, muscles: [.back, .shoulders], exerciseDBKey: "Barbell_Shrug", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_straight_arm_pulldown"), category: .strength, muscles: [.back], exerciseDBKey: "Straight-Arm_Pulldown", inputType: .strength),
        
        // MARK: - Strength / Arms
        ExerciseSeed(name: String(localized: "exercise_bicep_curl"), category: .strength, muscles: [.biceps], exerciseDBKey: "Barbell_Curl", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_curl"), category: .strength, muscles: [.biceps], exerciseDBKey: "Dumbbell_Alternate_Bicep_Curl", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_hammer_curl"), category: .strength, muscles: [.biceps], exerciseDBKey: "Hammer_Curls", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_preacher_curl"), category: .strength, muscles: [.biceps], exerciseDBKey: "Preacher_Curl", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_curl"), category: .strength, muscles: [.biceps], exerciseDBKey: "Cable_Curl", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_triceps_pushdown"), category: .strength, muscles: [.triceps], exerciseDBKey: "Triceps_Pushdown", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_skull_crusher"), category: .strength, muscles: [.triceps], exerciseDBKey: "Decline_Close-Grip_Bench_To_Skull_Crusher", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_overhead_triceps_extension"), category: .strength, muscles: [.triceps], exerciseDBKey: "Dumbbell_Lying_Triceps_Extension", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_close_grip_bench_press"), category: .strength, muscles: [.triceps, .chest], exerciseDBKey: "Close-Grip_Barbell_Bench_Press", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_dip"), category: .strength, muscles: [.triceps, .chest], exerciseDBKey: "Dips", inputType: .strength),

        // MARK: - Strength / Core
        ExerciseSeed(name: String(localized: "exercise_crunch"), category: .strength, muscles: [.core], exerciseDBKey: "Crunch", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_sit_up"), category: .strength, muscles: [.core], exerciseDBKey: "Sit-up", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_raise"), category: .strength, muscles: [.core], exerciseDBKey: "Leg_Raises", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_hanging_knee_raise"), category: .strength, muscles: [.core], exerciseDBKey: "Hanging_Leg_Raise", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_crunch"), category: .strength, muscles: [.core], exerciseDBKey: "Cable_Crunch", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_ab_wheel_rollout"), category: .strength, muscles: [.core], exerciseDBKey: "Ab_Roller", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_russian_twist"), category: .strength, muscles: [.core], exerciseDBKey: "Russian_Twist", inputType: .strength),
        ExerciseSeed(name: String(localized: "exercise_plank"), category: .strength, muscles: [.core], exerciseDBKey: "Plank", inputType: .timed),

        // MARK: - Cardio
        ExerciseSeed(name: String(localized: "exercise_running"), category: .cardio, muscles: [.legs, .glutes], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_walking"), category: .cardio, muscles: [.legs], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_jump_rope"), category: .cardio, muscles: [.legs, .calves], exerciseDBKey: nil, inputType: .cardioJump),
        ExerciseSeed(name: String(localized: "exercise_treadmill"), category: .cardio, muscles: [.legs], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_stationary_bike"), category: .cardio, muscles: [.legs, .glutes], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_rowing_machine"), category: .cardio, muscles: [.back, .legs, .core], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_elliptical"), category: .cardio, muscles: [.legs, .glutes], exerciseDBKey: nil, inputType: .cardioDistance),
        ExerciseSeed(name: String(localized: "exercise_stair_climber"), category: .cardio, muscles: [.legs, .glutes, .calves], exerciseDBKey: nil, inputType: .cardioDistance),
    ]
    
    func prefetchAllIcons() {
            let urls = seeds.compactMap { $0.iconURL }
            let prefetcher = ImagePrefetcher(resources: urls)
            prefetcher.start()
        }
}
