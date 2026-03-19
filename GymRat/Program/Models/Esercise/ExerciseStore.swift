import Foundation

final class ExerciseStore {
    static let shared = ExerciseStore()

    struct ExerciseSeed {
        let name: String
        let category: ExerciseCategory
    }

    let seeds: [ExerciseSeed] = [

        // MARK: - Strength / Legs
        ExerciseSeed(name: String(localized: "exercise_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_front_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_hack_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_smith_machine_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_extension"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_calf_raise_machine"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_standing_calf_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_lunge"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_bulgarian_split_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_step_up"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_air_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_sumo_squat"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_abduction"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_adduction"), category: .strength),

        // MARK: - Strength / Glutes
        ExerciseSeed(name: String(localized: "exercise_deadlift"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_romanian_deadlift"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_good_morning"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_hip_thrust"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_hip_thrust_machine"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_glute_bridge"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_kickback"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_donkey_kick"), category: .strength),

        // MARK: - Strength / Chest
        ExerciseSeed(name: String(localized: "exercise_bench_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_incline_bench_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_decline_bench_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_bench_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_chest_press_machine"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_pec_deck"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_fly"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_fly"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_push_up"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_pike_push_up"), category: .strength),

        // MARK: - Strength / Shoulders
        ExerciseSeed(name: String(localized: "exercise_overhead_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_shoulder_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_lateral_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_front_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_face_pull"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_lateral_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_arnold_press"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_upright_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_rear_delt_fly"), category: .strength),

        // MARK: - Strength / Back
        ExerciseSeed(name: String(localized: "exercise_barbell_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_seated_cable_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_lat_pulldown"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_pull_up"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_assisted_pull_up"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_inverted_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_back_extension"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_shrug"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_t_bar_row"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_chest_supported_row"), category: .strength),

        // MARK: - Strength / Arms
        ExerciseSeed(name: String(localized: "exercise_bicep_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_hammer_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_biceps_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_preacher_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_concentration_curl"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_triceps_extension"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_triceps_pushdown"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_dip"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_assisted_dip"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_skull_crusher"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_wrist_curl"), category: .strength),

        // MARK: - Strength / Core
        ExerciseSeed(name: String(localized: "exercise_ab_crunch_machine"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_crunch"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_sit_up"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_leg_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_superman"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_russian_twist"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_cable_crunch"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_hanging_leg_raise"), category: .strength),
        ExerciseSeed(name: String(localized: "exercise_ab_wheel"), category: .strength),

        // MARK: - Isometric / Timed (cardio category — duration based)
        ExerciseSeed(name: String(localized: "exercise_plank"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_side_plank"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_hollow_hold"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_wall_sit"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_dead_hang"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_l_sit"), category: .cardio),

        // MARK: - Cardio
        ExerciseSeed(name: String(localized: "exercise_running"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_walking"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_sprints"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_jump_rope"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_treadmill"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_stationary_bike"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_assault_bike"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_rowing_machine"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_elliptical"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_stair_climber"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_skierg"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_cycling"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_swimming"), category: .cardio),
        ExerciseSeed(name: String(localized: "exercise_hiking"), category: .cardio),

        // MARK: - Crossfit
        ExerciseSeed(name: String(localized: "exercise_burpees"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_kettlebell_swing"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_box_jump"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_thruster"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_wall_ball"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_power_clean"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_clean_and_jerk"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_snatch"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_double_unders"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_medicine_ball_slam"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_tire_flip"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_battle_rope"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_sled_push"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_farmers_walk"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_rope_climb"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_mountain_climbers"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_jump_squat"), category: .crossfit),
        ExerciseSeed(name: String(localized: "exercise_turkish_getup"), category: .crossfit),
    ]
}
