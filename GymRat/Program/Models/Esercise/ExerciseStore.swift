import Foundation

final class ExerciseStore {
    static let shared = ExerciseStore()

    struct ExerciseSeed {
        let name: String
        let category: ExerciseCategory
        let muscles: [MuscleGroup]
    }

    let seeds: [ExerciseSeed] = [

        // MARK: - Strength / Legs
        ExerciseSeed(name: String(localized: "exercise_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_front_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_hack_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_smith_machine_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_leg_press"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_leg_extension"), category: .strength, muscles: [.legs]),
        ExerciseSeed(name: String(localized: "exercise_leg_curl"), category: .strength, muscles: [.legs]),
        ExerciseSeed(name: String(localized: "exercise_calf_raise_machine"), category: .strength, muscles: [.calves]),
        ExerciseSeed(name: String(localized: "exercise_standing_calf_raise"), category: .strength, muscles: [.calves]),
        ExerciseSeed(name: String(localized: "exercise_lunge"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_bulgarian_split_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_step_up"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_air_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_sumo_squat"), category: .strength, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_leg_abduction"), category: .strength, muscles: [.glutes, .legs]),
        ExerciseSeed(name: String(localized: "exercise_leg_adduction"), category: .strength, muscles: [.legs]),

        // MARK: - Strength / Glutes
        ExerciseSeed(name: String(localized: "exercise_deadlift"), category: .strength, muscles: [.glutes, .back, .legs]),
        ExerciseSeed(name: String(localized: "exercise_romanian_deadlift"), category: .strength, muscles: [.glutes, .legs, .back]),
        ExerciseSeed(name: String(localized: "exercise_good_morning"), category: .strength, muscles: [.glutes, .back, .legs]),
        ExerciseSeed(name: String(localized: "exercise_hip_thrust"), category: .strength, muscles: [.glutes]),
        ExerciseSeed(name: String(localized: "exercise_hip_thrust_machine"), category: .strength, muscles: [.glutes]),
        ExerciseSeed(name: String(localized: "exercise_glute_bridge"), category: .strength, muscles: [.glutes]),
        ExerciseSeed(name: String(localized: "exercise_cable_kickback"), category: .strength, muscles: [.glutes]),
        ExerciseSeed(name: String(localized: "exercise_donkey_kick"), category: .strength, muscles: [.glutes]),

        // MARK: - Strength / Chest
        ExerciseSeed(name: String(localized: "exercise_bench_press"), category: .strength, muscles: [.chest, .triceps, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_incline_bench_press"), category: .strength, muscles: [.chest, .shoulders, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_decline_bench_press"), category: .strength, muscles: [.chest, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_bench_press"), category: .strength, muscles: [.chest, .triceps, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_chest_press_machine"), category: .strength, muscles: [.chest, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_pec_deck"), category: .strength, muscles: [.chest]),
        ExerciseSeed(name: String(localized: "exercise_cable_fly"), category: .strength, muscles: [.chest]),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_fly"), category: .strength, muscles: [.chest]),
        ExerciseSeed(name: String(localized: "exercise_push_up"), category: .strength, muscles: [.chest, .triceps, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_pike_push_up"), category: .strength, muscles: [.shoulders, .triceps]),

        // MARK: - Strength / Shoulders
        ExerciseSeed(name: String(localized: "exercise_overhead_press"), category: .strength, muscles: [.shoulders, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_shoulder_press"), category: .strength, muscles: [.shoulders, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_lateral_raise"), category: .strength, muscles: [.shoulders]),
        ExerciseSeed(name: String(localized: "exercise_front_raise"), category: .strength, muscles: [.shoulders]),
        ExerciseSeed(name: String(localized: "exercise_face_pull"), category: .strength, muscles: [.shoulders, .back]),
        ExerciseSeed(name: String(localized: "exercise_cable_lateral_raise"), category: .strength, muscles: [.shoulders]),
        ExerciseSeed(name: String(localized: "exercise_arnold_press"), category: .strength, muscles: [.shoulders, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_upright_row"), category: .strength, muscles: [.shoulders, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_rear_delt_fly"), category: .strength, muscles: [.shoulders, .back]),

        // MARK: - Strength / Back
        ExerciseSeed(name: String(localized: "exercise_barbell_row"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_dumbbell_row"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_seated_cable_row"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_lat_pulldown"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_pull_up"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_assisted_pull_up"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_inverted_row"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_back_extension"), category: .strength, muscles: [.back, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_shrug"), category: .strength, muscles: [.back, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_t_bar_row"), category: .strength, muscles: [.back, .biceps]),
        ExerciseSeed(name: String(localized: "exercise_chest_supported_row"), category: .strength, muscles: [.back, .biceps]),

        // MARK: - Strength / Arms
        ExerciseSeed(name: String(localized: "exercise_bicep_curl"), category: .strength, muscles: [.biceps]),
        ExerciseSeed(name: String(localized: "exercise_hammer_curl"), category: .strength, muscles: [.biceps]),
        ExerciseSeed(name: String(localized: "exercise_cable_biceps_curl"), category: .strength, muscles: [.biceps]),
        ExerciseSeed(name: String(localized: "exercise_preacher_curl"), category: .strength, muscles: [.biceps]),
        ExerciseSeed(name: String(localized: "exercise_concentration_curl"), category: .strength, muscles: [.biceps]),
        ExerciseSeed(name: String(localized: "exercise_triceps_extension"), category: .strength, muscles: [.triceps]),
        ExerciseSeed(name: String(localized: "exercise_triceps_pushdown"), category: .strength, muscles: [.triceps]),
        ExerciseSeed(name: String(localized: "exercise_dip"), category: .strength, muscles: [.triceps, .chest]),
        ExerciseSeed(name: String(localized: "exercise_assisted_dip"), category: .strength, muscles: [.triceps, .chest]),
        ExerciseSeed(name: String(localized: "exercise_skull_crusher"), category: .strength, muscles: [.triceps]),
        ExerciseSeed(name: String(localized: "exercise_wrist_curl"), category: .strength, muscles: []),

        // MARK: - Strength / Core
        ExerciseSeed(name: String(localized: "exercise_ab_crunch_machine"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_crunch"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_sit_up"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_leg_raise"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_superman"), category: .strength, muscles: [.back, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_russian_twist"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_cable_crunch"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_hanging_leg_raise"), category: .strength, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_ab_wheel"), category: .strength, muscles: [.core]),

        // MARK: - Isometric / Timed
        ExerciseSeed(name: String(localized: "exercise_plank"), category: .cardio, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_side_plank"), category: .cardio, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_hollow_hold"), category: .cardio, muscles: [.core]),
        ExerciseSeed(name: String(localized: "exercise_wall_sit"), category: .cardio, muscles: [.legs]),
        ExerciseSeed(name: String(localized: "exercise_dead_hang"), category: .cardio, muscles: [.back]),
        ExerciseSeed(name: String(localized: "exercise_l_sit"), category: .cardio, muscles: [.core]),

        // MARK: - Cardio
        ExerciseSeed(name: String(localized: "exercise_running"), category: .cardio, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_walking"), category: .cardio, muscles: [.legs]),
        ExerciseSeed(name: String(localized: "exercise_sprints"), category: .cardio, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_jump_rope"), category: .cardio, muscles: [.legs, .calves]),
        ExerciseSeed(name: String(localized: "exercise_treadmill"), category: .cardio, muscles: [.legs]),
        ExerciseSeed(name: String(localized: "exercise_stationary_bike"), category: .cardio, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_assault_bike"), category: .cardio, muscles: [.legs, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_rowing_machine"), category: .cardio, muscles: [.back, .legs, .core]),
        ExerciseSeed(name: String(localized: "exercise_elliptical"), category: .cardio, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_stair_climber"), category: .cardio, muscles: [.legs, .glutes, .calves]),
        ExerciseSeed(name: String(localized: "exercise_skierg"), category: .cardio, muscles: [.back, .shoulders, .core]),
        ExerciseSeed(name: String(localized: "exercise_cycling"), category: .cardio, muscles: [.legs, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_swimming"), category: .cardio, muscles: [.back, .shoulders, .chest]),
        ExerciseSeed(name: String(localized: "exercise_lap_swimming"), category: .cardio, muscles: [.back, .shoulders, .chest]),
        ExerciseSeed(name: String(localized: "exercise_open_water_swimming"), category: .cardio, muscles: [.back, .shoulders, .chest, .core]),
        ExerciseSeed(name: String(localized: "exercise_aqua_jogging"), category: .cardio, muscles: [.legs, .core]),
        ExerciseSeed(name: String(localized: "exercise_water_aerobics"), category: .cardio, muscles: [.legs, .core, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_kayaking"), category: .cardio, muscles: [.back, .shoulders, .core]),
        ExerciseSeed(name: String(localized: "exercise_canoeing"), category: .cardio, muscles: [.back, .shoulders, .core]),
        ExerciseSeed(name: String(localized: "exercise_standup_paddleboarding"), category: .cardio, muscles: [.core, .shoulders, .legs]),
        ExerciseSeed(name: String(localized: "exercise_surfing"), category: .cardio, muscles: [.core, .legs, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_hiking"), category: .cardio, muscles: [.legs, .glutes, .calves]),

        // MARK: - Crossfit
        ExerciseSeed(name: String(localized: "exercise_burpees"), category: .crossfit, muscles: [.chest, .legs, .core, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_kettlebell_swing"), category: .crossfit, muscles: [.glutes, .back, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_box_jump"), category: .crossfit, muscles: [.legs, .glutes, .calves]),
        ExerciseSeed(name: String(localized: "exercise_thruster"), category: .crossfit, muscles: [.legs, .shoulders, .triceps]),
        ExerciseSeed(name: String(localized: "exercise_wall_ball"), category: .crossfit, muscles: [.legs, .shoulders, .core]),
        ExerciseSeed(name: String(localized: "exercise_power_clean"), category: .crossfit, muscles: [.legs, .back, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_clean_and_jerk"), category: .crossfit, muscles: [.legs, .back, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_snatch"), category: .crossfit, muscles: [.legs, .back, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_double_unders"), category: .crossfit, muscles: [.legs, .calves]),
        ExerciseSeed(name: String(localized: "exercise_medicine_ball_slam"), category: .crossfit, muscles: [.core, .shoulders, .back]),
        ExerciseSeed(name: String(localized: "exercise_tire_flip"), category: .crossfit, muscles: [.legs, .back, .glutes]),
        ExerciseSeed(name: String(localized: "exercise_battle_rope"), category: .crossfit, muscles: [.shoulders, .core, .back]),
        ExerciseSeed(name: String(localized: "exercise_sled_push"), category: .crossfit, muscles: [.legs, .glutes, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_farmers_walk"), category: .crossfit, muscles: [.back, .shoulders, .legs]),
        ExerciseSeed(name: String(localized: "exercise_rope_climb"), category: .crossfit, muscles: [.back, .biceps, .core]),
        ExerciseSeed(name: String(localized: "exercise_mountain_climbers"), category: .crossfit, muscles: [.core, .legs, .shoulders]),
        ExerciseSeed(name: String(localized: "exercise_jump_squat"), category: .crossfit, muscles: [.legs, .glutes, .calves]),
        ExerciseSeed(name: String(localized: "exercise_turkish_getup"), category: .crossfit, muscles: [.shoulders, .core, .glutes]),
    ]
}
