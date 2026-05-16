import Foundation

extension ExerciseRepo {
    static let localSeeds: [ExerciseSeed] = [
        // MARK: Legs
        ExerciseSeed(localizedKey: "exercise_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "0dCyly0"),
        ExerciseSeed(localizedKey: "exercise_front_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "1gFNTZV"),
        ExerciseSeed(localizedKey: "exercise_hack_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "3xK09Sk"),
        ExerciseSeed(localizedKey: "exercise_leg_press", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "10Z2DXU"),
        ExerciseSeed(localizedKey: "exercise_leg_extension", category: .strength, muscles: [.legs], inputType: .strength, exerciseId: "1TVoin7"),
        ExerciseSeed(localizedKey: "exercise_leg_curl", category: .strength, muscles: [.legs], inputType: .strength, exerciseId: "17lJ1kr"),
        ExerciseSeed(localizedKey: "exercise_standing_calf_raise", category: .strength, muscles: [.calves], inputType: .strength, exerciseId: "6HmFgmx"),
        ExerciseSeed(localizedKey: "exercise_seated_calf_raise", category: .strength, muscles: [.calves], inputType: .strength, exerciseId: "0S75mYG"),
        ExerciseSeed(localizedKey: "exercise_lunge", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "1TVoin7"),
        ExerciseSeed(localizedKey: "exercise_bulgarian_split_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "HUEqZ1y"),

        // MARK: Glutes / Posterior Chain
        ExerciseSeed(localizedKey: "exercise_deadlift", category: .strength, muscles: [.glutes, .back, .legs], inputType: .strength, exerciseId: "9sgNE2O"),
        ExerciseSeed(localizedKey: "exercise_romanian_deadlift", category: .strength, muscles: [.glutes, .legs, .back], inputType: .strength, exerciseId: "2DxtqHL"),
        ExerciseSeed(localizedKey: "exercise_hip_thrust", category: .strength, muscles: [.glutes], inputType: .strength, exerciseId: "f7Y9eDZ"),
        ExerciseSeed(localizedKey: "exercise_glute_bridge", category: .strength, muscles: [.glutes], inputType: .strength, exerciseId: "aWedzZX"),
        ExerciseSeed(localizedKey: "exercise_cable_pull_through", category: .strength, muscles: [.glutes, .legs], inputType: .strength, exerciseId: "BmrwWzo"),

        // MARK: Chest
        ExerciseSeed(localizedKey: "exercise_bench_press", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "EIeI8Vf"),
        ExerciseSeed(localizedKey: "exercise_incline_bench_press", category: .strength, muscles: [.chest, .shoulders, .triceps], inputType: .strength, exerciseId: "3TZduzM"),
        ExerciseSeed(localizedKey: "exercise_decline_bench_press", category: .strength, muscles: [.chest, .triceps], inputType: .strength, exerciseId: "1qrWgZ2"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_bench_press", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "3d7wHyd"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_incline_bench_press", category: .strength, muscles: [.chest, .shoulders, .triceps], inputType: .strength, exerciseId: "8eqjhOl"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_fly", category: .strength, muscles: [.chest], inputType: .strength, exerciseId: "0IgNjSM"),
        ExerciseSeed(localizedKey: "exercise_cable_fly", category: .strength, muscles: [.chest], inputType: .strength, exerciseId: "0CXGHya"),
        ExerciseSeed(localizedKey: "exercise_push_up", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "0br45wL"),

        // MARK: Shoulders
        ExerciseSeed(localizedKey: "exercise_overhead_press", category: .strength, muscles: [.shoulders, .triceps], inputType: .strength, exerciseId: "1TkiAFK"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_shoulder_press", category: .strength, muscles: [.shoulders, .triceps], inputType: .strength, exerciseId: "5vfAI0I"),
        ExerciseSeed(localizedKey: "exercise_arnold_press", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "dCPESfR"),
        ExerciseSeed(localizedKey: "exercise_lateral_raise", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "53Ttlck"),
        ExerciseSeed(localizedKey: "exercise_front_raise", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "33AzZeV"),
        ExerciseSeed(localizedKey: "exercise_face_pull", category: .strength, muscles: [.shoulders, .back], inputType: .strength, exerciseId: "za9Ni4z"),
        ExerciseSeed(localizedKey: "exercise_rear_delt_fly", category: .strength, muscles: [.shoulders, .back], inputType: .strength, exerciseId: "EKXOMEh"),

        // MARK: Back
        ExerciseSeed(localizedKey: "exercise_barbell_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "0dCyly0"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "0IgNjSM"),
        ExerciseSeed(localizedKey: "exercise_seated_cable_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "bOOdeyc"),
        ExerciseSeed(localizedKey: "exercise_t_bar_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "aaXr7ld"),
        ExerciseSeed(localizedKey: "exercise_lat_pulldown", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "CmEr4pM"),
        ExerciseSeed(localizedKey: "exercise_close_grip_lat_pulldown", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "4LoWllp"),
        ExerciseSeed(localizedKey: "exercise_pull_up", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "0rHfvy9"),
        ExerciseSeed(localizedKey: "exercise_chin_up", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "7OeHptV"),
        ExerciseSeed(localizedKey: "exercise_back_extension", category: .strength, muscles: [.back, .glutes], inputType: .strength, exerciseId: "1TVoin7"),
        ExerciseSeed(localizedKey: "exercise_shrug", category: .strength, muscles: [.back, .shoulders], inputType: .strength, exerciseId: "1oE78pm"),
        ExerciseSeed(localizedKey: "exercise_straight_arm_pulldown", category: .strength, muscles: [.back], inputType: .strength, exerciseId: "DT14T9T"),

        // MARK: Biceps
        ExerciseSeed(localizedKey: "exercise_bicep_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "1gFNTZV"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "1VpF8db"),
        ExerciseSeed(localizedKey: "exercise_hammer_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "1qrWgZ2"),
        ExerciseSeed(localizedKey: "exercise_preacher_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "4dF3maG"),
        ExerciseSeed(localizedKey: "exercise_cable_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "0CXGHya"),

        // MARK: Triceps
        ExerciseSeed(localizedKey: "exercise_triceps_pushdown", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "9tvVVM9"),
        ExerciseSeed(localizedKey: "exercise_skull_crusher", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "h8LFzo9"),
        ExerciseSeed(localizedKey: "exercise_overhead_triceps_extension", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "1xHyxys"),
        ExerciseSeed(localizedKey: "exercise_close_grip_bench_press", category: .strength, muscles: [.triceps, .chest], inputType: .strength, exerciseId: "3QgteDK"),
        ExerciseSeed(localizedKey: "exercise_dip", category: .strength, muscles: [.triceps, .chest], inputType: .strength, exerciseId: "05Cf2v8"),

        // MARK: Core
        ExerciseSeed(localizedKey: "exercise_crunch", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "225x2Vd"),
        ExerciseSeed(localizedKey: "exercise_sit_up", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "1GPHRyK"),
        ExerciseSeed(localizedKey: "exercise_leg_raise", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "03lzqwk"),
        ExerciseSeed(localizedKey: "exercise_hanging_knee_raise", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "03lzqwk"),
        ExerciseSeed(localizedKey: "exercise_cable_crunch", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "7xI5MXA"),
        ExerciseSeed(localizedKey: "exercise_ab_wheel_rollout", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "KtRomty"),
        ExerciseSeed(localizedKey: "exercise_russian_twist", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "d9Xaxq6"),
        ExerciseSeed(localizedKey: "exercise_plank", category: .strength, muscles: [.core], inputType: .timed, exerciseId: "5VXmnV5"),

        // MARK: Cardio
        ExerciseSeed(localizedKey: "exercise_running", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_walking", category: .cardio, muscles: [.legs], inputType: .cardioDistance, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_jump_rope", category: .cardio, muscles: [.legs, .calves], inputType: .cardioJump, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_treadmill", category: .cardio, muscles: [.legs], inputType: .cardioDistance, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_stationary_bike", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: "H1PESYI"),
        ExerciseSeed(localizedKey: "exercise_rowing_machine", category: .cardio, muscles: [.back, .legs, .core], inputType: .cardioDistance, exerciseId: "7I6LNUG"),
        ExerciseSeed(localizedKey: "exercise_elliptical", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: "rjtuP6X"),
        ExerciseSeed(localizedKey: "exercise_stair_climber", category: .cardio, muscles: [.legs, .glutes, .calves], inputType: .cardioDistance, exerciseId: "j9Q5crt"),
    ]

    static let preferredRemoteNameOverrides: [String: [String]] = [
        "exercise_bench_press": ["barbell bench press"],
        "exercise_cable_fly": ["cable cross-over variation"],
        "exercise_leg_curl": ["lever lying leg curl"],
        "exercise_hanging_knee_raise": ["assisted hanging knee raise"],
        "exercise_dip": ["impossible dips"],
    ]
}
