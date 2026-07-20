import Foundation

extension ExerciseRepo {
    /// Every `exerciseId` below was verified against the ExerciseDB catalog: the id exists,
    /// is unique across seeds, and its media file resolves on the CDN. Do not edit an id
    /// without re-checking `https://static.exercisedb.dev/media/<id>.gif`.
    static let localSeeds: [ExerciseSeed] = [
        // MARK: Legs
        ExerciseSeed(localizedKey: "exercise_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "qXTaZnJ"),
        ExerciseSeed(localizedKey: "exercise_front_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "zG0zs85"),
        ExerciseSeed(localizedKey: "exercise_hack_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "Qa55kX1"),
        ExerciseSeed(localizedKey: "exercise_leg_press", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "10Z2DXU"),
        ExerciseSeed(localizedKey: "exercise_leg_extension", category: .strength, muscles: [.legs], inputType: .strength, exerciseId: "my33uHU"),
        ExerciseSeed(localizedKey: "exercise_leg_curl", category: .strength, muscles: [.legs], inputType: .strength, exerciseId: "17lJ1kr"),
        ExerciseSeed(localizedKey: "exercise_standing_calf_raise", category: .strength, muscles: [.calves], inputType: .strength, exerciseId: "ykUOVze"),
        ExerciseSeed(localizedKey: "exercise_seated_calf_raise", category: .strength, muscles: [.calves], inputType: .strength, exerciseId: "bOOdeyc"),
        ExerciseSeed(localizedKey: "exercise_lunge", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "kMzUs9Y"),
        // No Bulgarian split squat in the catalog; closest match is the barbell split squat.
        ExerciseSeed(localizedKey: "exercise_bulgarian_split_squat", category: .strength, muscles: [.legs, .glutes], inputType: .strength, exerciseId: "HBYyX94"),

        // MARK: Glutes / Posterior Chain
        ExerciseSeed(localizedKey: "exercise_deadlift", category: .strength, muscles: [.glutes, .back, .legs], inputType: .strength, exerciseId: "ila4NZS"),
        ExerciseSeed(localizedKey: "exercise_romanian_deadlift", category: .strength, muscles: [.glutes, .legs, .back], inputType: .strength, exerciseId: "wQ2c4XD"),
        // No barbell hip thrust in the catalog; the barbell glute bridge is the closest pattern.
        ExerciseSeed(localizedKey: "exercise_hip_thrust", category: .strength, muscles: [.glutes], inputType: .strength, exerciseId: "qKBpF7I"),
        ExerciseSeed(localizedKey: "exercise_glute_bridge", category: .strength, muscles: [.glutes], inputType: .strength, exerciseId: "u0cNiij"),
        ExerciseSeed(localizedKey: "exercise_cable_pull_through", category: .strength, muscles: [.glutes, .legs], inputType: .strength, exerciseId: "OM46QHm"),

        // MARK: Chest
        ExerciseSeed(localizedKey: "exercise_bench_press", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "EIeI8Vf"),
        ExerciseSeed(localizedKey: "exercise_incline_bench_press", category: .strength, muscles: [.chest, .shoulders, .triceps], inputType: .strength, exerciseId: "3TZduzM"),
        ExerciseSeed(localizedKey: "exercise_decline_bench_press", category: .strength, muscles: [.chest, .triceps], inputType: .strength, exerciseId: "GrO65fd"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_bench_press", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "SpYC0Kp"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_incline_bench_press", category: .strength, muscles: [.chest, .shoulders, .triceps], inputType: .strength, exerciseId: "ns0SIbU"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_fly", category: .strength, muscles: [.chest], inputType: .strength, exerciseId: "yz9nUhF"),
        ExerciseSeed(localizedKey: "exercise_cable_fly", category: .strength, muscles: [.chest], inputType: .strength, exerciseId: "xLYSdtg"),
        ExerciseSeed(localizedKey: "exercise_push_up", category: .strength, muscles: [.chest, .triceps, .shoulders], inputType: .strength, exerciseId: "I4hDWkc"),

        // MARK: Shoulders
        ExerciseSeed(localizedKey: "exercise_overhead_press", category: .strength, muscles: [.shoulders, .triceps], inputType: .strength, exerciseId: "kTbSH9h"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_shoulder_press", category: .strength, muscles: [.shoulders, .triceps], inputType: .strength, exerciseId: "znQUdHY"),
        ExerciseSeed(localizedKey: "exercise_arnold_press", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "Xy4jlWA"),
        ExerciseSeed(localizedKey: "exercise_lateral_raise", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "DsgkuIt"),
        ExerciseSeed(localizedKey: "exercise_front_raise", category: .strength, muscles: [.shoulders], inputType: .strength, exerciseId: "3eGE2JC"),
        // No face pull in the catalog; the cable rear delt row is the closest pull pattern.
        ExerciseSeed(localizedKey: "exercise_face_pull", category: .strength, muscles: [.shoulders, .back], inputType: .strength, exerciseId: "yUdIGNs"),
        ExerciseSeed(localizedKey: "exercise_rear_delt_fly", category: .strength, muscles: [.shoulders, .back], inputType: .strength, exerciseId: "8DiFDVA"),

        // MARK: Back
        ExerciseSeed(localizedKey: "exercise_barbell_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "eZyBC3j"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "BJ0Hz5L"),
        ExerciseSeed(localizedKey: "exercise_seated_cable_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "fUBheHs"),
        ExerciseSeed(localizedKey: "exercise_t_bar_row", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "aaXr7ld"),
        ExerciseSeed(localizedKey: "exercise_lat_pulldown", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "LEprlgG"),
        // The catalog only carries band close-grip pulldowns, no cable variant.
        ExerciseSeed(localizedKey: "exercise_close_grip_lat_pulldown", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "DptumMx"),
        ExerciseSeed(localizedKey: "exercise_pull_up", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "lBDjFxJ"),
        ExerciseSeed(localizedKey: "exercise_chin_up", category: .strength, muscles: [.back, .biceps], inputType: .strength, exerciseId: "T2mxWqc"),
        ExerciseSeed(localizedKey: "exercise_back_extension", category: .strength, muscles: [.back, .glutes], inputType: .strength, exerciseId: "rUXfn3R"),
        ExerciseSeed(localizedKey: "exercise_shrug", category: .strength, muscles: [.back, .shoulders], inputType: .strength, exerciseId: "dG7tG5y"),
        ExerciseSeed(localizedKey: "exercise_straight_arm_pulldown", category: .strength, muscles: [.back], inputType: .strength, exerciseId: "x69MAlq"),

        // MARK: Biceps
        ExerciseSeed(localizedKey: "exercise_bicep_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "25GPyDY"),
        ExerciseSeed(localizedKey: "exercise_dumbbell_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "NbVPDMW"),
        ExerciseSeed(localizedKey: "exercise_hammer_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "slDvUAU"),
        ExerciseSeed(localizedKey: "exercise_preacher_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "qOgPVf6"),
        ExerciseSeed(localizedKey: "exercise_cable_curl", category: .strength, muscles: [.biceps], inputType: .strength, exerciseId: "G08RZcQ"),

        // MARK: Triceps
        ExerciseSeed(localizedKey: "exercise_triceps_pushdown", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "gAwDzB3"),
        ExerciseSeed(localizedKey: "exercise_skull_crusher", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "h8LFzo9"),
        ExerciseSeed(localizedKey: "exercise_overhead_triceps_extension", category: .strength, muscles: [.triceps], inputType: .strength, exerciseId: "1xHyxys"),
        ExerciseSeed(localizedKey: "exercise_close_grip_bench_press", category: .strength, muscles: [.triceps, .chest], inputType: .strength, exerciseId: "J6Dx1Mu"),
        ExerciseSeed(localizedKey: "exercise_dip", category: .strength, muscles: [.triceps, .chest], inputType: .strength, exerciseId: "X6C6i5Y"),

        // MARK: Core
        ExerciseSeed(localizedKey: "exercise_crunch", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "TFqbd8t"),
        ExerciseSeed(localizedKey: "exercise_sit_up", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "Bn6TXyO"),
        ExerciseSeed(localizedKey: "exercise_leg_raise", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "WhuFnR7"),
        ExerciseSeed(localizedKey: "exercise_hanging_knee_raise", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "03lzqwk"),
        ExerciseSeed(localizedKey: "exercise_cable_crunch", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "WW95auq"),
        ExerciseSeed(localizedKey: "exercise_ab_wheel_rollout", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "NAgVB3t"),
        ExerciseSeed(localizedKey: "exercise_russian_twist", category: .strength, muscles: [.core], inputType: .strength, exerciseId: "XVDdcoj"),
        // The catalog has no unweighted front plank.
        ExerciseSeed(localizedKey: "exercise_plank", category: .strength, muscles: [.core], inputType: .timed, exerciseId: "VBAWRPG"),

        // MARK: Cardio
        ExerciseSeed(localizedKey: "exercise_running", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: "oLrKqDH"),
        // No plain walking entry exists in the catalog, so this seed stays without media.
        ExerciseSeed(localizedKey: "exercise_walking", category: .cardio, muscles: [.legs], inputType: .cardioDistance, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_jump_rope", category: .cardio, muscles: [.legs, .calves], inputType: .cardioJump, exerciseId: "e1e76I2"),
        ExerciseSeed(localizedKey: "exercise_treadmill", category: .cardio, muscles: [.legs], inputType: .cardioDistance, exerciseId: "rjiM4L3"),
        ExerciseSeed(localizedKey: "exercise_stationary_bike", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: "H1PESYI"),
        // The catalog has no rowing ergometer, only strength rows, so this seed stays without media.
        ExerciseSeed(localizedKey: "exercise_rowing_machine", category: .cardio, muscles: [.back, .legs, .core], inputType: .cardioDistance, exerciseId: nil),
        ExerciseSeed(localizedKey: "exercise_elliptical", category: .cardio, muscles: [.legs, .glutes], inputType: .cardioDistance, exerciseId: "rjtuP6X"),
        ExerciseSeed(localizedKey: "exercise_stair_climber", category: .cardio, muscles: [.legs, .glutes, .calves], inputType: .cardioDistance, exerciseId: "j9Q5crt"),
    ]

    /// Catalog names for seeds whose own name finds nothing (or the wrong thing) in a name search.
    /// Only used when a seed has no `exerciseId` to resolve by.
    static let preferredRemoteNameOverrides: [String: [String]] = [
        "exercise_squat": ["barbell full squat"],
        "exercise_bench_press": ["barbell bench press"],
        "exercise_barbell_row": ["barbell bent over row"],
        "exercise_dumbbell_row": ["dumbbell bent over row"],
        "exercise_leg_curl": ["lever lying leg curl"],
        "exercise_leg_extension": ["lever leg extension"],
        "exercise_overhead_press": ["barbell seated overhead press"],
        "exercise_lat_pulldown": ["cable lat pulldown full range of motion"],
        "exercise_cable_crunch": ["cable kneeling crunch"],
        "exercise_ab_wheel_rollout": ["wheel rollerout"],
        "exercise_dip": ["triceps dip"],
        "exercise_running": ["run"],
        "exercise_treadmill": ["walking on incline treadmill"],
        "exercise_stair_climber": ["walking on stepmill"],
    ]
}
