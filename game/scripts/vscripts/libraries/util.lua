-- where the misc functios gather
heroList = LoadKeyValues("scripts/npc/herolist.txt")
testList = LoadKeyValues("scripts/npc/herotest.txt")
fate_ability_count = LoadKeyValues("scripts/npc/fate_ability_count.txt")
require('libraries/modifiers/modifier_ndm')

--"SpellDispellableType"   "SPELL_DISPELLABLE_YES"
-- S, EX remove modifier
softdispellable = {
    -- Buff
    "modifier_lancer_rune_of_combat",
    "modifier_warriors_charge_buff",
    "modifier_blade_of_the_devoted",
    "modifier_courage_self_buff_stack",
    "modifier_jeanne_charisma_str",
    "modifier_jeanne_charisma_agi",
    "modifier_jeanne_charisma_int",
    "modifier_jtr_surgery_heal", 
    "modifier_murderous_instinct",
    "modifier_lishuwen_invis",
    "modifier_lishuwen_invis_move",
    "modifier_lishuwen_cosmic_orbit_speed",
    "modifier_lishuwen_cosmic_orbit",
    "modifier_double_spearsmanship_active",
    "modifier_scathach_spearmanship",
    "modifier_argos_armor", 
    "modifier_shukuchi_invis",
    "modifier_shukuchi_breath",
    "modifier_tennen_bonus",
    "modifier_derange",
    "modifier_scathach_rune_heal_buff",
    "modifier_ambush",
    "modifier_ta_invis",
    "modifier_ta_self_mod",
    "modifier_atalanta_last_spurt_cap",
    "modifier_gordius_wheel_speed_boost",
    "modifier_gordius_wheel_cap",
    "modifier_zhuge_liang_heal_buff",
    "modifier_zhuge_liang_mana_buff",
    "modifier_zhuge_liang_accel_buff",
    "modifier_aspd_increase",
    "modifier_hans_invis",
    "modifier_mass_recall",

    --items
    "modifier_berserk_scroll",
    "modifier_share_damage",
    "modifier_a_plus_armor",
    "modifier_speed_gem",
    "modifier_replenishment_heal",
    "modifier_master_intervention",

    -- Debuff
    "modifier_kinghassan_dread",
    "modifier_kinghassan_flames_of_gehenna",
    "modifier_scathach_fire_burn",
    "modifier_l_rule_breaker",
    "modifier_c_rule_breaker",
    "modifier_gladiusanus_blauserum_mark",
    "modifier_mordred_rampage_stack",
    "modifier_armor_reduction",
    "modifier_witchcraft_mr_reduction",
    "modifier_dirk_weakening_venom",
    "modifier_zhuge_liang_acid",
    "modifier_zhuge_liang_fire_arrow",
    "modifier_robin_roots_slow",
    "modifier_robin_hunter_rain_slow",
    "modifier_poison_cloud_debuff",
    "modifier_nobu_innovation_ms",
    "modifier_nobu_slow",
    "modifier_roar_slow",
}
-- Rule Breaker/ Gae Dearg remove modifier
strongdispellable = {
    "modifier_kinghassan_eveningbell",
    "modifier_rho_aias",
    "modifier_kanshou_byakuya",    
    "modifier_argos_shield",
    "modifier_argos_armor",
    "modifier_military_tactic_cannon",
    "modifier_boarding_ship",
    "modifier_golden_hind_drive",
    "modifier_golden_hind_bombard",
    "modifier_crossing_fire_buff",
    "modifier_storm_aura",
    "modifier_light_of_galatine",
    "modifier_agni_karna",
    "modifier_courage_self_buff",
    "modifier_jeanne_charisma_str_flag",
    "modifier_jeanne_charisma_agi_flag",
    "modifier_jeanne_charisma_int_flag",
    "modifier_mordred_shield",
    "modifier_gladiusanus_blauserum",
    "modifier_pari_tenu_blauserum",
    "modifier_nameless_forest_stat_steal_buff",
    "modifier_nameless_forest_stat_steal_debuff",
    "modifier_plains_of_water_int_debuff",
    "modifier_plains_of_water_int_buff",
    "modifier_tennen_base",
    "modifier_gate_keeper_self_buff",
    "modifier_scathach_rune_heal_buff",
    "modifier_mantra_ally",
    "modifier_mantra_mr_buff",
    "modifier_soulstream_buff",
    "modifier_ta_self_mod_agi_dmg",
    "modifier_cursed_lance_shield",
    "modifier_atalanta_last_spurt",
    "modifier_heracles_berserk",
    "modifier_eternal_rage",
    "modifier_double_edge_thinker",
    "modifier_double_edge_ms",
    "modifier_double_edge_as",
    "modifier_double_edge_damage_amp",
    "modifier_lishuwen_cosmic_orbit_attack",
    "modifier_heart_of_harmony",
    "modifier_ta_self_mod_str",
    "modifier_ta_self_mod_agi",
    "modifier_ta_self_mod_int",
    "modifier_ta_self_mod_all",
    "modifier_fran_mana_burst",
    "modifier_fran_elect_shield",
    "modifier_mordred_shield",
    "modifier_lubu_bravary",
    "modifier_amakusa_god_buff",
    "modifier_edmond_shadow",
    "modifier_edmond_hate_shield",
    "modifier_zhuge_liang_ambush",
    "modifier_zhuge_liang_offense",
    "modifier_zhuge_liang_defense",
    "modifier_zhuge_liang_shield",
    "modifier_hans_territory_buff",
    "modifier_hans_observation",
    "modifier_robin_poison_smoke",
    "modifier_poisonous_bite_slow",
    "modifier_nobu_innovation_aura",
    "modifier_mashu_snowflake",
    "modifier_mashu_dmg_reduc",
    "modifier_atalanta_ora",
    "modifier_kiyohime_q_buff",
    "modifier_semiramis_shield",

    -- items
    "modifier_b_scroll",

}
-- 5th Seal remove
cleansable = {

    -- Root, Lock, Stun, Silence, Disarm, Sleep
    "modifier_stunned",
    "modifier_c_rule_breaker",
    "modifier_l_rule_breaker",
    "modifier_purge",
    "rb_sealdisabled",
    "modifier_dagger_of_treachery",
    "modifier_silence",
    "modifier_disarmed",
    "modifier_enkidu_hold", -- enkidu
    "modifier_tentacle_wrap",
    "modifier_gust_heaven_purge",
    "modifier_subterranean_grasp",
    "modifier_illusion_trap",
    "revoked",
    "freezed",
    "locked",
    "rooted",
    "stunned",
    "silenced",
    --"modifier_sword_barrage_confine",
    "modifier_mordred_mb_silence",
    "modifier_frostbite_root",
    "modifier_breaker_gorgon_stone",
    "modifier_dance_macabre_knock_back_1",
    "modifier_dance_macabre_knock_back_2",
    "modifier_dance_macabre_knock_back_3",
    "modifier_atalanta_calydonian_hunt_root",
    "modifier_waver_silence",
    "modifier_waver_root",
    "modifier_vajra_root",
    "modifier_bloodfort_seal",
    "modifier_la_black_luna_silence",
    "modifier_sex_scroll_root",
    "modifier_scathach_freeze", 
    "modifier_bathory_dragon_voice_deaf",  
    "modifier_zhuge_liang_wood_trap",
    "musashi_modifier_wind_debuff",

    -- DPS, Curse, Burn 
    "modifier_scathach_fire_burn",
    "modifier_dirk_poison",
    "modifier_golden_wild_hunt_burn",
    "modifier_light_of_galatine_burn",
    "modifier_excalibur_galatine_burn",
    "modifier_gilles_grief",
    "modifier_gilles_misery",
    "modifier_gilles_smother",
    "modifier_gilles_jellyfish_curse",
    "modifier_gilles_torment",
    "modifier_laus_saint_burn",
    "modifier_tamamo_fire_debuff",
    "modifier_agni_burn",
    "modifier_zhuge_liang_fire_arrow",
    "modifier_zhuge_liang_acid",
    "modifier_semi_snek_poison",
    "musashi_modifier_fire_debuff",

    -- Debuffs  
    "modifier_armor_reduction",
    "modifier_atalanta_calydonian_hunt_sight",
    --"modifier_sword_barrage_confine_armor",
    --"modifier_sword_barrage_confine_mr",    
    "modifier_courage_enemy_debuff_stack",
    "modifier_courage_enemy_debuff",
    "modifier_battle_horn_armor_reduction",   
    "modifier_sharing_of_pain_enemy_target",
    "modifier_sharing_of_pain_ally_target",
    "modifier_smg_armor_reduction",    
    "modifier_mantra_mr_debuff",
    "modifier_witchcraft_mr_reduction",
    "modifier_gust_heaven_indicator_enemy",
    "modifier_tamamo_wind_debuff",
    "modifier_tamamo_ice_debuff",   
    "modifier_gladiusanus_blauserum_mark",
    "modifier_mordred_rampage_stack",
    "modifier_dirk_weakening_venom",
    "modifier_fran_lightning_slow",
    "modifier_fran_lament",
    "modifier_zhuge_liang_ambush_debuff",
    "modifier_hans_territory_debuff",
    "modifier_hans_red_shoes",
    "modifier_robin_roots_slow",
    "modifier_robin_hunter_rain_slow",
    "modifier_robin_yew_bow",
    "modifier_tiatum_umu_cast",
    "modifier_semiramis_babylon_quake",
    "modifier_binding_chains",
    "modifier_poison_cloud_debuff",
    "modifier_poisonous_bite_slow",
    "modifier_nobu_divinity_mark_activated",
    "modifier_mashu_taunt",
    "modifier_mashu_bunker_bolt_slow",
    "modifier_atalanta_curse",
    "modifier_fear_kh",
    "modifier_kiyo_slash_enemy",
}

slowmodifier = {
    "modifier_slow_tier1",
    "modifier_slow_tier2",
    "modifier_atalanta_calydonian_hunt_slow",
    "modifier_phoebus_slow",
    "modifier_la_black_luna_slow",
    "modifier_tawrich_zarich_slow",
    "modifier_warriors_charge_slow",
    "modifier_storm_slow",
    "modifier_golden_wild_hunt_slow",
    "modifier_blizzard_slow",
    "modifier_light_of_galatine_slow",
    "modifier_sun_of_galatine_slow",
    "modifier_gilles_jellyfish_slow",
    "modifier_fissure_strike_slow",
    "modifier_courage_enemy_debuff_slow",
    "modifier_gordius_wheel_thunder_slow",
    "modifier_battle_horn_movespeed_debuff",
    "modifier_purge_the_unjust_slow",
    "modifier_gods_resolution_slow",
    "modifier_la_pucelle_slow",
    "modifier_jtr_curse_slow",
    "modifier_jtr_dagger_slow",
    "modifier_kuro_rosa_slow",
    "modifier_caliburn_slow",
    "modifier_vajra_slow",
    "modifier_arondite_slow",
    "modifier_tiger_first_strike_slow",
    "modifier_raging_dragon_strike_1_slow",
    "chilling_breath_slow",
    "modifier_mystic_eye_enemy",
    "modifier_mystic_eye_enemy_upgrade",
    "modifier_breaker_gorgon",
    "modifier_bloodfort_slow",
    "modifier_sex_scroll_slow",
    "modifier_rosa_slow",
    "modifier_white_queens_enigma_slow",
    "modifier_plains_of_water_slow",
    "modifier_doppelganger_lookaway_slow",
    "modifier_amaterasu_slow_enemy",
    "modifier_dirk_poison_slow",
    "modifier_ceremonial_purge_slow",
    "modifier_gate_of_sky_no_blink",
    "modifier_lancelot_rosa_slow",
    "modifier_scathach_fire_burn",
    "modifier_fran_lightning_slow",
    "modifier_lubu_fear",
    "modifier_fly_slow",
    "modifier_bathory_slap_slow",
    "modifier_amakusa_god_slow",
    "modifier_amakusa_god_hit_slow",
    "modifier_edmond_thunder_slow",
    "modifier_edmond_flame_slow",
    "modifier_zhuge_liang_acid_slow",
    "modifier_hans_snow_queen",
    "modifier_robin_roots_slow",
    "modifier_robin_hunter_rain_slow",
    "modifier_tiatum_umu_cast",
    "modifier_semiramis_babylon_quake",
    "modifier_poisonous_bite_slow",
    "modifier_nobu_slow",
    "modifier_mashu_bunker_bolt_slow",
    "modifier_roar_slow",
    "musashi_modifier_earth_debuff",
}

revokes = {
    "modifier_ubw_chronosphere",
    "modifier_ubw_chronosphere_self",
    "modifier_madmans_roar_silence",
    "modifier_enkidu_hold",
    "jump_pause",
    "pause_sealdisabled",
    "rb_sealdisabled",
    "revoked",
    "round_pause",
    "modifier_tres_fontaine_nero",
    "modifier_bathory_cage_target",
    "modifier_hippogriff_vanish_banish",
}

locks = {
    --"modifier_purge",
    "modifier_sex_scroll_root",
    "locked",
    "dragged",
    "freezed",
    "modifier_atalanta_calydonian_hunt_root",
    "jump_pause_postlock",
    "jump_pause_nosilence",
    "modifier_sword_barrage_confine",
    "modifier_story_for_someones_sake",
    "modifier_aestus_domus_aurea_enemy",
    "modifier_aestus_domus_aurea_ally",
    "modifier_aestus_domus_aurea_nero",
    "modifier_rho_aias",
    "modifier_binding_chains",
    "modifier_enkidu_hold",
    "modifier_jtr_whitechapel_self",
    "modifier_jtr_whitechapel_enemies",
    "modifier_jtr_whitechapel_female_enemies",
    "modifier_jtr_whitechapel_allies",
    "modifier_gate_of_sky_no_blink",
    "modifier_scathach_freeze",
    "modifier_hira_seigan_shield",
    "modifier_sandanzuki_window",
    "modifier_gordius_wheel",
    "modifier_boarding_ship",
    "modifier_zhuge_liang_wood_trap",
    "modifier_zhuge_liang_array_enemy",
    "modifier_kinghassan_death_announce",
    "modifier_tiatum_umu_execute",
    "modifier_mashu_taunt",
    "modifier_mashu_protect_self",
    "modifier_melt_combo_slow",
}

no_tp = {
    "modifier_aestus_domus_aurea_enemy",
    "modifier_aestus_domus_aurea_ally",
    "modifier_aestus_domus_aurea_nero",
    "jump_pause_nosilence",
    "modifier_story_for_someones_sake",
    "modifier_jtr_whitechapel_enemies",
    "modifier_jtr_whitechapel_female_enemies",
    "modifier_jtr_whitechapel_allies",
    "modifier_jtr_whitechapel_self",
    "modifier_zhuge_liang_array_enemy",
    "modifier_tiatum_umu_execute",
    "modifier_mashu_taunt",
}

goesthruB = {
    "saber_avalon",
    "saber_avalon_upgrade",
    "sasaki_quickdraw",
    "gilgamesh_gate_of_babylon",
    "gilgamesh_gate_of_babylon_upgrade",
    "lancer_gae_bolg",
    "lancer_gae_bolg_upgrade",
    "lancer_wesen_gae_bolg",
    "lancer_wesen_gae_bolg_upgrade",
    "karna_brahmastra_upgrade",
    "karna_brahmastra_kundala_upgrade",
    "kuro_gae_bolg",
    "kuro_gae_bolg_upgrade",
    "scathach_gae_bolg",
    "scathach_gae_bolg_upgrade_1",
    "scathach_gae_bolg_upgrade_2",
    "scathach_gae_bolg_upgrade_3",
    --"avenger_verg_avesta_upgrade",    
    --"avenger_verg_avesta",
}

invis = {
    "modifier_ambush",
    "modifier_ta_invis",
    "modifier_shukuchi_invis",
    "modifier_fa_invis",
    "modifier_lishuwen_invis",
    "modifier_jtr_whitechapel_self",
    "modifier_jtr_the_mist_invis",
    "modifier_zhuge_liang_ambush",
    "modifier_faceless_king_invis",
    "modifier_semiramis_presence_concealment",
}

invulabil = {
    "modifier_selfish_self_invul",
    "modifier_big_bad_voodoo_invulnerability",
    "modifier_waver_big_bad_voodoo_invulnerability",
    "modifier_vlad_battle_continuation",
}

donotlevel = {
    "attribute_bonus_custom",
    "attribute_bonus_custom_no_int",
    "saber_improved_instinct",
    "saber_alter_darklight_passive",
    "archer_rho_aias",  
    "archer_sword_barrage_retreat_shot", 
    "archer_sword_barrage_confine", 
    "archer_gae_bolg", 
    "archer_sword_barrage", 
    "archer_nine_lives", 
    "archer_shroud_of_martin",
    "lancer_protection_from_arrows",  
    "lancer_rune_of_disengage",  
    "lancer_rune_of_combat",  
    "lancer_rune_of_ferocity",  
    "lancer_rune_of_flame",   
    "lancer_rune_of_protection",   
    "medusa_monstrous_strength_passive",
    "medusa_riding_passive",
    "heracles_reincarnation",
    "heracles_god_hand",
    "sasaki_presence_concealment",
    "hassan_protection_from_wind",
    "hassan_self_modification_str",
    "hassan_self_modification_agi",
    "hassan_self_modification_int",
    "drake_crossing_fire",
    "drake_sword",
    "drake_dance_macabre_2",
    "drake_dance_macabre_3",
    "scathach_wisdom_of_haunt_ground",
    "scathach_immortal",
    "vlad_innocent_monster",
    "vlad_protection_of_faith",
    "jeanne_charisma_saint",
    "jeanne_purge_the_unjust_saint",
    "jeanne_gods_resolution_saint",
    "jeanne_luminosite_eternelle_saint",
    "kuro_crane_wing",
    "kuro_excalibur",
    "kuro_gae_bolg",
    "kuro_fake_nine_live",
    "kuro_rho_aias",
    "kuro_rosa_ichthys",
    "jtr_quick_strikes_curse",
    "jtr_maria_the_ripper_curse",
    "jtr_ghost_walk",
    "jtr_information_erase",
    "jtr_holy_mother_passive",
    "jtr_mental_pollution_passive",
    "jtr_soul_eater_passive",
    "jtr_murderer_on_misty_night",
    "lancelot_blessing_of_fairy",
    "lishuwen_berserk", 
    "lishuwen_tiger_strike_2",
    "lishuwen_tiger_strike_3",
    "lishuwen_tiger_strike_berserk_2",
    "lishuwen_tiger_strike_berserk_3",
    "astolfo_monstrous_strength",
    "astolfo_independent_action",
    "astolfo_evaporation_of_sanity_passive",
    "tamamo_witchcraft",   
    "atalanta_arrows_of_the_big_dipper", 
    "mordred_curse_passive",
    "mordred_overload_passive",
    "mordred_rampage_passive", 
    "mordred_bc_passive", 
    "avenger_unlimited_remains", 
    "avenger_avenger", 
    "avenger_unlimited_remains", 
    "avenger_vengeance_mark", 
    "avenger_demon_core", 
    "okita_sandanzuki_charge3",
    "gilles_eye_for_art_passive", 
    "iskandar_arrow_bombard", 
    --"gawain_numeral_saint",
    "gawain_blessing_of_fairy",
    "gawain_blade_of_the_devoted_light",
    "gawain_excalibur_galatine_light",
    "nero_aestus_estus_passive",
    "nero_invictus_spiritus", 
    "fran_bridal_chest",  
    "lubu_ruthless_warrior",
    "lubu_immortal_red_hare",   
    "bathory_charisma",
    "bathory_territory",  
    "amakusa_anti_ruler",  
    "amakusa_revelation",  
    "edmond_avenger",
    "kinghassan_faith",
    "kinghassan_stack",
    "hans_masterpiece_red_shoes",
    "hans_masterpiece_snow_queen",
    "hans_masterpiece_match_girl",
    "hans_masterpiece_thumbelina",
    "hans_masterpiece_red_shoes_upgrade",
    "hans_masterpiece_snow_queen_upgrade",
    "hans_masterpiece_match_girl_upgrade",
    "hans_masterpiece_thumbelina_upgrade",
    "robin_saboteur_pitfall",
    "robin_saboteur_barrel",
    "semiramis_presence_concealment",
    "semiramis_snek_spit_poison",
    "semiramis_poisonous_cloud",
    "semiramis_poisonous_bite",
    "semiramis_absolute_queen",
    "nobu_strat",
}

tModifierCooldown = {
    "modifier_strike_air_cooldown",
    "modifier_instinct_cooldown",
    "modifier_max_excalibur_cooldown",
    "modifier_air_burst_cooldown",
    "modifier_hrunting_cooldown",
    "modifier_arrow_rain_cooldown",
    "modifier_retreat_root_cooldown",
    "modifier_battle_continuation_cooldown",
    "modifier_wesen_gae_bolg_cooldown",
    "modifier_max_mana_burst_cooldown",
    "modifier_hippogriff_ride_cooldown",
    "modifier_mordred_mmb_cooldown",
    "modifier_gate_of_sky_cooldown",
    "modifier_combo_double_gae_bolg_cooldown",
    "modifier_scathach_rune_of_protection_cooldown",
    "modifier_pinning_god_cooldown",
    "modifier_fake_ubw_cooldown",
    "modifier_golden_wild_hunt_cooldown",
    "modifier_zekken_cooldown",
    "modifier_arondite_overload_cooldown",
    "modifier_gilgamesh_final_hour_cooldown",
    "modifier_jtr_whitechapel_cooldown",
    "modifier_tamamo_combo_cooldown",
    "modifier_mystic_shackle_cooldown",
    "modifier_polygamist_fist_cooldown",
    "modifier_combo_vasavi_cooldown",
    "modifier_lord_of_execution_cooldown",
    "modifier_laus_saint_claudius_cooldown",
    "modifier_lancelot_arondite_overload_cooldown",
    "modifier_blessing_of_fairy_cooldown",
    "modifier_hecatic_graea_powered_cooldown",
    "modifier_casa_cooldown",
    "modifier_bellerophon_2_cooldown",
    "modifier_madmans_roar_cooldown",
    "modifier_tsubame_mai_cooldown",
    "modifier_story_for_someones_sake_cooldown",
    "modifier_la_pucelle_cooldown",
    "modifier_max_enuma_elish_cooldown",
    "modifier_nuke_cooldown",
    "modifier_4_days_loop_cooldown",
    "modifier_rampant_warrior_cooldown",
    "modifier_annihilate_cooldown",
    "modifier_larret_de_mort_cooldown",
    "modifier_meltdown_cooldown",
    "modifier_combo_galatine_cooldown",
    "modifier_raging_dragon_strike_cooldown",
    "modifier_phoebus_catastrophe_cooldown",
    "modifier_mordred_bc_cooldown",
    "modifier_delusional_illusion_cooldown",
    "modifier_sasaki_quickdraw_cooldown",
    "modifier_blasted_tree_cooldown",
    "modifier_lubu_immortal_cooldown",
    "modifier_lubu_combo_cooldown",
    "modifier_bathory_battle_continuation_cooldown",
    "modifier_bathory_innocent_cooldown",
    "modifier_bathory_combo_cooldown",
    "modifier_amakusa_twin_cooldown",
    "modifier_amakusa_baptism_cooldown",
    "modifier_amakusa_identity_cooldown",
    "modifier_edmond_chateau_cooldown",
    "modifier_edmond_esperer_cooldown",
    "modifier_zhuge_thunder_storm_cooldown",
    "modifier_kinghassan_combo_cooldown",
    "modifier_kinghassan_faith_cooldown",
    "modifier_hans_territory_cooldown",
    "modifier_hans_naked_king_cooldown",
    "modifier_hans_combo_cooldown",
    "modifier_faceless_king_cooldown",
    "modifier_robin_combo_cooldown",
    "modifier_dual_class_cooldown",
    "modifier_tiatum_umu_cooldown",
    "modifier_nobu_strategy_attribute_cooldown",
    "modifier_nobu_combo_cd",
    "modifier_mashu_combo_cooldown",
    "musashi_modifier_ishana_daitenshou_cooldown",
    "modifier_ishtar_combo_cooldown",
    "modifier_atalanta_skia_cd",
    "modifier_muramasa_combo_cooldown",
    "modifier_kiyohime_combo_cooldown",
    "modifier_melt_combo_cooldown",
}

CannotReset = {
    "saber_improved_instinct",
    "saber_strike_air",
    "saber_max_excalibur",
    "saber_max_excalibur_upgrade",
    "saber_alter_unleashed_ferocity",
    "saber_alter_unleashed_ferocity_upgrade",
    "saber_alter_max_mana_burst",
    "saber_alter_max_mana_burst_upgrade",
    "archer_clairvoyance",
    "archer_clairvoyance_upgrade",
    "archer_hrunting",
    "archer_hrunting_upgrade",
    "archer_arrow_rain",
    "lancer_battle_continuation",
    "lancer_battle_continuation_upgrade",
    "lancer_protection_from_arrows",
    "lancer_wesen_gae_bolg",
    "lancer_wesen_gae_bolg_upgrade",
    "medusa_bellerophon_2",
    "medusa_bellerophon_2_upgrade",
    "medusa_bloodfort_andromeda",
    "medusa_bloodfort_andromeda_upgrade",
    "medusa_mystic_eye_upgrade",
    "heracles_madmans_roar",
    "heracles_madmans_roar_upgrade_1",
    "heracles_madmans_roar_upgrade_2",
    "heracles_madmans_roar_upgrade_3",
    "sasaki_hiken_enbu",
    "sasaki_hiken_enbu_upgrade",
    "sasaki_quickdraw",
    "hassan_combo",
    "hassan_combo_upgrade",
    "gilgamesh_max_enuma_elish",
    "gilgamesh_max_enuma_elish_upgrade",
    "gilgamesh_combo_final_hour",
    "medea_sacrifice",
    "medea_hecatic_graea_powered",
    "medea_hecatic_graea_powered_upgrade",
    "drake_military_tactic_summon_golden_hind",
    "drake_military_tactic_summon_golden_hind_upgrade",
    "drake_voyager_of_storm",
    "drake_golden_hind_voyager_of_storm",
    "drake_combo_golden_wild_hunt",
    "drake_combo_golden_wild_hunt_upgrade",
    "scathach_pinning_god",
    "scathach_rune_fire",
    "scathach_rune_fire_upgrade",
    "scathach_rune_frost",
    "scathach_rune_frost_upgrade",
    "scathach_rune_blast",
    "scathach_rune_blast_upgrade",
    "scathach_rune_of_protection",
    "scathach_rune_heal",
    "scathach_rune_heal_upgrade",
    "scathach_combo_double_gae_bolg",
    "scathach_combo_double_gae_bolg_upgrade",
    "scathach_combo_gate_of_sky",
    "vlad_transfusion",
    "vlad_transfusion_upgrade",
    "vlad_impale",
    "vlad_battle_continuation",
    "vlad_battle_continuation_upgrade",
    "vlad_combo",
    "vlad_protection_of_faith",
    "diarmuid_love_spot",
    "diarmuid_love_spot_upgrade",
    "diarmuid_minds_eye_upgrade",
    "diarmuid_rampant_warrior",
    "kuro_sharing_pain",
    "kuro_sharing_pain_upgrade",
    "kuro_clairvoyance",
    "kuro_clairvoyance_upgrade",
    "kuro_hrunting",
    "kuro_hrunting_upgrade",
    "kuro_fake_ubw",
    "kuro_fake_ubw_upgrade_1",
    "kuro_fake_ubw_upgrade_2",
    "kuro_fake_ubw_upgrade_3",
    "jeanne_la_pucelle",
    "jeanne_identity_discernment",
    "jtr_information_erase",
    "jtr_mental_pollution_passive",
    "jtr_illusion_trap_curse",
    "jtr_whitechapel",
    "jtr_surgery", 
    "lancelot_blessing_of_fairy",
    "lancelot_eternal_arms_mastership_upgrade",
    "lancelot_nuke",
    "lancelot_arondite_overload",
    "karna_combo_vasavi",
    "karna_combo_vasavi_upgrade",
    "karna_discern_poor",
    "lishuwen_martial_arts",
    "lishuwen_martial_arts_upgrade",
    "lishuwen_raging_dragon_strike",
    "lishuwen_raging_dragon_strike_2",
    "lishuwen_raging_dragon_strike_3",
    "lishuwen_berserk",
    "nursery_rhyme_shapeshift",
    "nursery_rhyme_shapeshift_upgrade",
    "nursery_rhyme_shapeshift_swap",
    "nursery_rhyme_nameless_forest",
    "nursery_rhyme_nameless_forest_upgrade",
    "nursery_rhyme_reminiscence",
    "nursery_rhyme_queens_glass_game_activate",
    "nursery_rhyme_story_for_somebodys_sake",
    "nursery_rhyme_story_for_somebodys_sake_upgrade",
    "astolfo_casa_di_logistilla",
    "astolfo_casa_di_logistilla_upgrade",
    "astolfo_hippogriff_ride",
    "astolfo_hippogriff_rush", 
    "tamamo_curse_charm",
    "tamamo_curse_charm_upgrade", 
    "tamamo_combo",
    "tamamo_mystic_shackle",  
    "tamamo_poly_castration_fist",
    "tamamo_poly_castration_fist_fire",
    "tamamo_poly_castration_fist_ice",
    "tamamo_poly_castration_fist_wind",
    "atalanta_golden_apple",
    "atalanta_crossing_arcadia",
    "atalanta_crossing_arcadia_upgrade",
    "atalanta_phoebus_catastrophe_snipe",
    "mordred_mmb_lightning_upgrade",
    "mordred_mmb_lightning",
    "mordred_bc_passive",
    "mordred_mb_lightning",
    "mordred_mb_lightning_upgrade",
    "avenger_combo_endless_loop_upgrade",
    "avenger_combo_endless_loop",
    "avenger_dark_passage_upgrade",
    "avenger_dark_passage",
    "okita_mind_eye",
    "okita_zekken",
    "okita_zekken_upgrade",   
    "okita_flag_of_sincerity",
    "okita_flag_of_sincerity_upgrade",    
    "gilles_prelati_spellbook",
    "gilles_prelati_spellbook_upgrade",
    "gille_larret_de_mort",
    "iskander_annihilate",
    "iskandar_spatha",
    "gawain_blessing_of_fairy",
    "gawain_combo_excalibur_galatine",
    "gawain_combo_excalibur_galatine_upgrade_1",
    "gawain_combo_excalibur_galatine_upgrade_2",
    "gawain_combo_excalibur_galatine_upgrade_3",
    "nero_imperial_privilege",
    "nero_imperial_privilege_upgrade",
    "nero_laus_saint_claudius",
    "fran_lament",
    "fran_combo_blasted_tree",
    "fran_combo_blasted_tree_upgrade",
    "lubu_combo_god_force",
    "lubu_combo_god_force_upgrade",
    "lubu_immortal_red_hare",
    "bathory_combo_fresh_blood",
    "bathory_combo_fresh_blood_upgrade",
    "bathory_battle_continuation",
    "bathory_innocent",
    "bathory_innocent_upgrade",
    "amakusa_identity_discernment",
    "amakusa_twin_arm",
    "amakusa_twin_arm_upgrade",
    "amakusa_baptism",
    "amakusa_baptism_chant",
    "edmond_lord_of_vengeance",
    "edmond_lord_of_vengeance_upgrade_1",
    "edmond_lord_of_vengeance_upgrade_2",
    "edmond_lord_of_vengeance_upgrade_3",
    "edmond_esperer",
    "edmond_chateau",
    "edmond_chateau_upgrade",
    "zhuge_liang_alchemist",
    "zhuge_liang_heal_pot",
    "zhuge_liang_heal_pot_upgrade",
    "zhuge_liang_mana_pot",
    "zhuge_liang_mana_pot_upgrade",
    "zhuge_liang_accel_pot",
    "zhuge_liang_accel_pot_upgrade",
    "zhuge_liang_acid_pot",
    "zhuge_liang_acid_pot_upgrade",
    "zhuge_liang_combo",
    "kinghassan_combo",
    "kinghassan_faith",
    "kinghassan_flames_of_gehenna_upgrade",
    "kinghassan_flames_of_gehenna",
    "kinghassan_beheader",
    "hans_naked_king",
    "hans_territory_upgrade",
    "hans_combo",
    "robin_faceless_king",
    "robin_faceless_king_upgrade",
    "robin_combo",
    "semiramis_dual_class",
    "semiramis_dual_class_upgrade",
    "semiramis_combo",
    "nobu_combo",
    "nobu_combo_upgrade",
    "nobu_leader_of_innovation",
    "nobu_divinity_mark",
    "nobu_demon_king_open",
    "mashu_combo",
    "mashu_smash",
    "musashi_tengan",
    "musashi_mukyuu",
    "musashi_battle_continuation",
    "musashi_ishana_daitenshou",
    "atalanta_skia",
    "atalanta_curse",
    "atalanta_curse_upgrade",
    "melt_combo",
}

femaleservant = {
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_spectre",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_lina",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_mirana",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_riki",
    "npc_dota_hero_dark_willow",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_tusk",
    "npc_dota_hero_zuus",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_gyrocopter",
    "npc_dota_hero_dragon_knight",
    "npc_dota_hero_antimage",
    "npc_dota_hero_oracle",
    "npc_dota_hero_ursa",
    "npc_dota_hero_void_spirit",
    "npc_dota_hero_nyx_assassin",
}

tSpellBookHero = {
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_sven",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_tusk",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_necrolyte",
    "npc_dota_hero_sniper",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_gyrocopter",
    "npc_dota_hero_dragon_knight",
}

tArrow = {
    "atalanta_crossing_arcadia", 
    "atalanta_crossing_arcadia_upgrade", 
    "atalanta_arrows_of_the_big_dipper", 
    "atalanta_celestial_arrow", 
    "atalanta_celestial_arrow_red", 
    "atalanta_celestial_arrow_upgrade", 
    "atalanta_celestial_arrow_red_upgrade", 
    "atalanta_phoebus_catastrophe_barrage", 
    "atalanta_phoebus_catastrophe_barrage_upgrade", 
    "atalanta_calydonian_snipe", 
    "atalanta_phoebus_catastrophe_snipe", 
    "archer_arrow_rain",
    "archer_unlimited_bladeworks_upgrade", --auto blade
    "hassan_dirk",
    "hassan_dirk_upgrade",
    "iskandar_annihilate",
    "iskandar_arrow_bombard",
    "lubu_combo_god_force",
    "lubu_combo_god_force_upgrade",
    "robin_yew_bow",
    "robin_yew_bow_taxine",
    "robin_yew_bow_guerilla",
    "robin_yew_bow_upgrade",
}

tPoison = {
    "hassan_dirk",
    "hassan_dirk_upgrade", 
    "gilles_squidlordz_contaminate",
    "robin_saboteur_poison_well",
    "robin_roots",
    "robin_roots_upgrade",
    "robin_yew_bow",
    "robin_yew_bow_taxine",
    "robin_yew_bow_guerilla",
    "robin_yew_bow_upgrade",
    "robin_combo",
    "robin_combo_upgrade",
    "semiramis_snek_spit_poison",
    "semiramis_snek_spit_poison_upgrade",
    "semiramis_poisonous_cloud",
    "semiramis_poisonous_cloud_upgrade",
    "semiramis_poisonous_bite",
    "semiramis_poisonous_bite_charm",
    "semiramis_poisonous_bite_old",
    "semiramis_poisonous_bite_upgrade",
    "semiramis_hanging_garden_sikera_usum",
}

tWind = {
    "saber_invisible_air", 
    "saber_invisible_air_upgrade", 
    "saber_strike_air", 
    "sasaki_windblade", 
    "sasaki_windblade_upgrade", 
    "tamamo_soulstream_wind", 
    "tamamo_soulstream_wind_upgrade_1", 
    "tamamo_soulstream_wind_upgrade_2", 
    "tamamo_soulstream_wind_upgrade_3", 
}

tWindImmune = {
    "modifier_wind_protection_passive",
}

tPoisonImmune = {
    "modifier_edmond_monte_cristo",
}

tSpellBook = {
    "lancer_rune_magic",
    "lancer_rune_magic_upgrade",
    "lancer_rune_magic_close",
    "drake_pistol",
    "drake_pistol_upgrade",
    "drake_sword",
    "drake_military_tactic",
    "drake_military_tactic_upgrade_1",
    "drake_military_tactic_upgrade_2",
    "drake_military_tactic_upgrade_3",
    "drake_military_tactic_close",
    "gilgamesh_gate_of_babylon_toggle", --toggle
    "kuro_projection",
    "kuro_projection_upgrade",
    "kuro_projection_close",
    "lancelot_close_spellbook",
    "lancelot_knight_of_honor",
    "lancelot_knight_of_honor_upgrade_1",
    "lancelot_knight_of_honor_upgrade_2",
    "lancelot_knight_of_honor_upgrade_3",
    "lancelot_knight_of_honor_arsenal",
    "lancelot_knight_of_honor_arsenal_upgrade",
    "lancelot_knight_of_honor_close",
    "medea_ancient_magic",
    "medea_ancient_magic_upgrade",
    "medea_close_spellbook",
    "scathach_rune_mage",
    "scathach_rune_mage_upgrade_1",
    "scathach_rune_mage_upgrade_2",
    "scathach_rune_mage_upgrade_3",
    "scathach_rune_close",
    "tamamo_curse_charm",
    "tamamo_curse_charm_upgrade",
    "tamamo_close_spellbook",
    "avenger_demon_core", --toggle
    "avenger_demon_core_upgrade", --toggle
    "vlad_rebellious_intent", --toggle
    "gilles_rlyeh_text_open",
    "gilles_rlyeh_text_close",     
    "nero_imperial_privilege",
    "nero_imperial_privilege_upgrade",
    "nero_close_spellbook",   
    "atalanta_celestial_arrow_upgrade", --toggle 
    "atalanta_celestial_arrow", --toggle 
    "hans_masterpiece_open",
    "hans_masterpiece_close",
    "zhuge_liang_strat_command",
    "zhuge_liang_war_command",
    "zhuge_liang_alchemist",
    "zhuge_liang_alchemist_close",
    "zhuge_liang_strat_command_upgrade",
    "zhuge_liang_war_command_upgrade",
    "zhuge_liang_alchemist_upgrade",
    "hans_masterpiece_open",
    "hans_masterpiece_close",
    "hans_masterpiece_open_observation",
    "hans_masterpiece_open_thumbelina",
    "hans_masterpiece_open_upgrade",
    "robin_saboteur",
    "robin_saboteur_upgrade",
    "robin_saboteur_close",
}
--Assassin Class
tCannotDetect = {
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_riki",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_phantom_assassin",
}
--before revive
tDangerousBuffs = {
    "modifier_gae_buidhe",
    "modifier_zaba_curse",
    "modifier_gae_buidhe"
}

itemComp = {
    {"item_c_scroll","item_c_scroll", "item_b_scroll"},
    {"item_b_scroll", "item_b_scroll", "item_a_scroll"},
    {"item_a_scroll", "item_a_scroll", "item_s_scroll"},
    {"item_s_scroll", "item_s_scroll", "item_ex_scroll"},
    {"item_mana_essence", "item_mana_essence", "item_condensed_mana_essence"},
    {"item_mana_essence", "item_recipe_healing_scroll", "item_healing_scroll"},
    {"item_a_scroll", "item_recipe_a_plus_scroll", "item_a_plus_scroll"}
}

tItemComboTable = {
    item_c_scroll = "item_b_scroll",
    item_b_scroll = "item_a_scroll",
    item_a_scroll = "item_s_scroll",
    item_s_scroll = "item_ex_scroll",
    item_mana_essence = "item_condensed_mana_essence",
    item_f_scroll = "item_a_plus_scroll"
}

tIsekaiAbuser = {
    "npc_dota_hero_lina",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_queenofpain",
    "npc_dota_hero_sven",
    "npc_dota_hero_dark_willow",
}

tMount = {
    "modifier_board_drake",
    "modifier_mount_caster",
    "modifier_integrate_gille",
    "modifier_semiramis_mounted",
}

tModifierKBImmune = {
    "modifier_avalon",
    "modifier_gate_of_sky_buff",
    "modifier_enkidu_hold",
    "modifier_hira_seigan_shield",
    "modifier_heart_of_harmony",
    "modifier_mashu_protect_self",
    "modifier_mashu_protect_ally"
}

tTrueInvis = {
    "modifier_ambush_invis",
    "modifier_murderer_mist_invis",
    "modifier_whitechapel_murderer",
}

tUnExecute = {
    "modifier_immortal_revive",
    "modifier_voyager_lucky",
    "modifier_avalon",
}

tExecuteSeal = {
    "modifier_kinghassan_combo_revive_lock",
}

tManalessHero = {
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_shadow_shaman"
}
--round end
tRemoveTheseModifiers = {
    "modifier_aestus_domus_aurea_enemy",
    "modifier_aestus_domus_aurea_ally",
    "modifier_aestus_domus_aurea_nero",
    "modifier_unlimited_bladeworks",
    "modifier_UBW_chant",
    "modifier_army_of_the_king_death_checker",
    "modifier_gae_buidhe",
    "modifier_gae_dearg",
    "modifier_zaba_curse",
    "modifier_golden_hind_check",
    "modifier_fake_ubw_dummy",
    "modifier_sharing_of_pain_tracker",
    "modifier_sharing_of_pain_enemy_target",
    "modifier_sharing_of_pain_ally_target",
    "modifier_4_days_loop",
    "modifier_all_the_world_evil",
    "modifier_verg_marker",
    "modifier_verg_damage_tracker_progress",
    "modifier_celestial_arrow_damage",
    "modifier_edmond_vengeance",
    "modifier_edmond_hate",
    "modifier_zhuge_liang_array_checker",
    "modifier_zhuge_liang_array_enemy",
}

tLightningResist = {
    "modifier_fran_mana_burst",
    "modifier_lightning_resistance",
}

tProjectileParry = {
    "modifier_lancer_protection_from_arrows_active"
}

tBeamAbilities = {
    "saber_max_excalibur",
    "saber_max_excalibur_upgrade",
    "saber_excalibur",
    "saber_excalibur_upgrade",
    "gilgamesh_max_enuma_elish",
    "gilgamesh_max_enuma_elish_upgrade",
    "gilgamesh_enuma_elish",
    "gilgamesh_enuma_elish_upgrade",
    "saber_alter_excalibur",
    "saber_alter_excalibur_upgrade",
    "kuro_excalibur",
    "kuro_excalibur_upgrade",
    "mordred_clarent",
    "mordred_clarent_upgrade_1",
    "mordred_clarent_upgrade_2",
    "mordred_clarent_upgrade_3",
    "gawain_excalibur_galatine_light",
    "gawain_excalibur_galatine_light_upgrade_1",
    "gawain_excalibur_galatine_light_upgrade_2",
    "gawain_excalibur_galatine_light_upgrade_3",
    "nobu_3000_upgrade",
}

tDivineHeroes = {
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_chen",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_beastmaster",
    "npc_dota_hero_oracle",
    "npc_dota_hero_nyx_assassin",
}

tArthurHeroes = {
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_spectre",
}

tLivingHumanHeroes = {
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_dragon_knight",
}

tShinsengumi = {
    "npc_dota_hero_dark_willow",
    "okita_shinsengumi",
    "okita_hijikata",
}

tSoldierAoTK = {
    "iskandar_infantry",
    "iskandar_archer",
    "iskandar_eumenes",
    "iskandar_cavalry",
    "iskandar_hephaestion",
    "iskandar_mage",
    "iskandar_waver",
}

donotmute = {
    "medea_territory",
    "medea_territory_improved",
    "medea_ancient_dragon",
    "gille_gigantic_horror",
    "drake_golden_hind",
    "semiramis_hanging_gardens",
}

tDragonHeroes = {
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_spectre",
    "npc_dota_hero_tusk",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_void_spirit",
    "medea_ancient_dragon",
}

tVampireHeroes = {
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_templar_assassin",
}

tKnightClass = {
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_spectre",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_ember_spirit",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_huskar",
    "npc_dota_hero_lina",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_beastmaster",
    "npc_dota_hero_dark_willow",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_tusk",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_antimage",
}

tHorsemanClass = {
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_sven",
    "npc_dota_hero_shadow_shaman",
    "npc_dota_hero_chen",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_queenofpain",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_zuus",
    "npc_dota_hero_axe",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_skeleton_king",
}

tSaberClass = {
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_spectre",
    "npc_dota_hero_tusk",
    "npc_dota_hero_dark_willow",
    "npc_dota_hero_lina",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_antimage",
}

tArcherClass = {
    "npc_dota_hero_ember_spirit",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_sniper",
    "npc_dota_hero_gyrocopter",
}

tLancerClass = {
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_huskar",
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_beastmaster",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_void_spirit",
}

tRiderClass = {
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_chen",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_queenofpain",
}

tCasterClass = {
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_shadow_shaman",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_necrolyte",
}

tAssassinClass = {
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_riki",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_phantom_assassin",
}

tBerserkerClass = {
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_sven",
    "npc_dota_hero_zuus",
    "npc_dota_hero_axe",
    "npc_dota_hero_ursa",
}

tRulerClass = {
    "npc_dota_hero_mirana",
    "npc_dota_hero_enigma"
}

tAvengerClass = {
    "npc_dota_hero_vengefulspirit",
    "npc_dota_hero_night_stalker",
}

tShielderClass = {
    "npc_dota_hero_dragon_knight",
}

tAlterEgoClass = {
    "npc_dota_hero_nyx_assassin",
}

tClass = {
    Saber = tSaberClass,
    Archer = tArcherClass,
    Lancer = tLancerClass,
    Rider = tRiderClass,
    Caster = tCasterClass,
    Assassin = tAssassinClass,
    Berserker = tBerserkerClass,
    Avenger = tAvengerClass,
    Ruler = tRulerClass,
    Shielder = tShielderClass,
    AlterEgo = tAlterEgoClass,
}

tipTable = { "<font color='#58ACFA'>Tip : C Scroll</font> is everyone's bread-and-butter item that you should be carrying at all times. Use it to guarantee your skill combo, or help your teammate by interrupting enemy.",
    "<font color='#58ACFA'>Tip : </font>Work towards gathering 25 all stats in order to acquire <font color='#58ACFA'>Combo</font>, a defining move of hero that can turn the tides of battle. You can level  Stat Bonus of your hero or buy stats with Master's mana  to boost the timing of acquisition.",
    "<font color='#58ACFA'>Tip : </font>To increase your survivability, consider carrying <font color='#58ACFA'>A Scroll and B Scroll</font> that grant you significant damage mitigation for duration.",
    "<font color='#58ACFA'>Tip : </font>Using <font color='#58ACFA'>Scout Familiar and Ward Familiar</font> is an excellent way to develop a vision control, allowing your team to plan ahead for enemy moves.",
    "<font color='#58ACFA'>Tip : </font>You will get a warning ping when enemy Servant's presence is detected within 2500 range around your hero.",
    "<font color='#58ACFA'>Tip : </font>Master can cast only up to 12 Command Seals per 10 minutes due to limited health, which resets every 10 minutes.",
    "<font color='#58ACFA'>Tip : </font>Bind your Master to key unit via [CTRL+Number Key] in order to provide quick support to your hero by transfering items or casting Command Seal.",
    "<font color='#58ACFA'>Tip : </font>Upon dying 7 times, player will be granted a chance to use Shard of Holy Grail that offers diverse array of advantages. Check the details in Master 2.",
    "<font color='#58ACFA'>Tip : </font>You can check the detail and cooldown of your Combo on Master 2.",
    "<font color='#58ACFA'>Tip : </font>When you are desperately short on gold, consider using <font color='#58ACFA'>-goldpls</font> command to ask for a financial assistance from your team.",
    "<font color='#58ACFA'>Tip : </font>A well-timed use of <font color='#58ACFA'>Command Seal</font> can give you decisive advantage over your foes, both defensively and offensively."
}
-- Calculates the angle from caster to target(in radian, multiply it by 180/math.pi for degree)
function CalculateAngle(u, v)
    local angle = 0
    local dotproduct = u.x * v.x + u.y * v.y
    local cosangle = dotproduct/(u:Length2D()*v:Length2D()) 
    return math.acos(cosangle)
end

function SpawnVisionDummy(owner, location, radius, duration, bTrueSight)
    local visiondummy = CreateUnitByName("sight_dummy_unit", location, false, owner, owner, owner:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(radius)
    visiondummy:SetNightTimeVisionRange(radius)
    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)

    if bTrueSight then
        visiondummy:AddNewModifier(owner, owner, "modifier_item_ward_true_sight", {true_sight_range = radius}) 
    end
    
    Timers:CreateTimer(duration, function() 
        if IsValidEntity(visiondummy) then
            visiondummy:RemoveSelf()
        end 
        return 
    end)
    return visiondummy
end

function SpawnAttachedVisionDummy(owner, target, radius, duration, bTrueSight)
    local visiondummy = CreateUnitByName("sight_dummy_unit", target:GetAbsOrigin(), false, owner, owner, owner:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(radius)
    visiondummy:SetNightTimeVisionRange(radius)
    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)

    if bTrueSight then
        visiondummy:AddNewModifier(owner, owner, "modifier_item_ward_true_sight", {true_sight_range = radius}) 
    end

    local counter = 0
    Timers:CreateTimer(function()
        counter = counter + 0.10
        if (counter > duration) then
            visiondummy:RemoveSelf()
            return
        end
        if not IsValidEntity(target) or target:IsNull() then 
            visiondummy:RemoveSelf()
            return nil 
        end
        visiondummy:SetAbsOrigin(target:GetAbsOrigin())
        return 0.10
    end)
    return visiondummy
end

-- Apply a modifier from item
function giveUnitDataDrivenModifier(source, target, modifier,dur)
    if source == nil or target == nil then 
        print('data modifier error: source or target is nor found.')
        return 
    end

    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

    if not source:IsHero() then 
        source = source:GetPlayerOwner():GetAssignedHero() 
    end
    local dummyAbility = source:FindAbilityByName("presence_detection_passive")
    dummyAbility:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end

function DoCompositeDamage(source, target, dmg, dmg_type, dmg_flag, abil, isLoop)
    DoDamage(source, target , dmg/3, DAMAGE_TYPE_MAGICAL, dmg_flag, abil, isLoop)
    DoDamage(source, target , dmg/3, DAMAGE_TYPE_PHYSICAL, dmg_flag, abil, isLoop)
    DoDamage(source, target , dmg/3, DAMAGE_TYPE_PURE, dmg_flag, abil, isLoop)
end

function ApplyAirborne(source, target, duration)
    if target:HasModifier("modifier_wind_protection_passive") then return end
    target:AddNewModifier(source, source, "modifier_stunned", {Duration = duration})
    --if target:GetName() == "npc_dota_hero_legion_commander" and target:HasModifier("modifier_avalon") then return end
    --[[local ascendCounter = 0
    Timers:CreateTimer(function()
        if ascendCounter > duration/2 then return end
        target:SetAbsOrigin(target:GetAbsOrigin() + Vector(0,0,25))
        ascendCounter = ascendCounter + 0.033
        return 0.033
    end)
    local descendCounter = 0
    Timers:CreateTimer(duration/2, function()
        if descendCounter > duration/2 then return end
        target:SetAbsOrigin(target:GetAbsOrigin() + Vector(0,0,-25))
        descendCounter = descendCounter + 0.033
        return 0.033
    end)]]
    local knockupSpeed = 1500
    ApplyAirborneOnly(target, knockupSpeed, duration)
end

function ApplyAirborneOnly(target, knockupSpeed, duration, Acc)
    --if target:HasModifier("modifier_wind_protection_passive") then return end
    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

    if target:GetName() == "npc_dota_hero_legion_commander" and target:HasModifier("modifier_avalon") then return end

    local knockupAcc = knockupSpeed/duration * 2
    if Acc then
        knockupAcc = Acc
    end

    Physics:Unit(target)
    target:PreventDI()
    target:SetPhysicsVelocity(Vector(0,0,knockupSpeed))
    target:SetPhysicsAcceleration(Vector(0,0,-knockupAcc))
    target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    target:FollowNavMesh(false)
    target:Hibernate(false)

    Timers:CreateTimer(duration, function()
        if IsValidEntity(target) and not target:IsNull() then
            target:PreventDI(false)
            target:SetPhysicsVelocity(Vector(0,0,0))
            target:SetPhysicsAcceleration(Vector(0,0,0))
            target:OnPhysicsFrame(nil)
            target:Hibernate(true)
            target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), nil))
        end
    end)
end

function DummyEnd(dummy)
    dummy:RemoveSelf()
    return nil
end

function GiveGold(senderID, receiverID, amount)
    
    if PlayerResource:GetReliableGold(senderID) > amount and senderID ~= receiverID then
        local senderHero = PlayerResource:GetSelectedHeroEntity(senderID)
        local receiverHero = PlayerResource:GetSelectedHeroEntity(receiverID)
        senderHero:SetGold(0, false)
        senderHero:SetGold(senderHero:GetGold() - amount, true)
        --senderHero:ModifyGold(-amount, true , 0) 
        receiverHero:SetGold(receiverHero:GetGold() + amount, true)
        --receiverHero:ModifyGold(amount, true, 0)

        return true
    else 
        return false
    end
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function HasLeaversInTeam(hero)
    local leaverCount = 0
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() == hero:GetTeamNumber() then 
            if playerHero:HasOwnerAbandoned() then
                leaverCount = leaverCount + 1
            end
        end
    end)
    return leaverCount
end

function SumTable(table) --sums a freaking table why do I have to write primitive stuff like these
    local sum = 0
    for k,v in pairs(table) do
        sum = sum + v
    end

    return sum
end

function MaxNumTable(table) --sorts a table and return first value in the table which is the highest and also its table index
    for k,curGold in spairs(table, function(t,a,b) return t[b] < t[a] end) do
        return k, curGold
    end
end

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
        local mult = 10^numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
 
function StartQuestTimer(questname, questtitle, questendtime)
  local entQuest = SpawnEntityFromTableSynchronous( "quest", { name = questname, title = questtitle } )
  --add   "QuestTimer"  "Survive for %quest_current_value% seconds"   in addon_english
  
  local questTimeEnd = GameRules:GetGameTime() + questendtime --Time to Finish the quest

  --bar system
  local entKillCountSubquest = SpawnEntityFromTableSynchronous( "subquest_base", {
    show_progress_bar = true
  } )
  entQuest:AddSubquest( entKillCountSubquest )
  entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, questendtime ) --text on the quest timer at start
  entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, questendtime ) --text on the quest timer
  entKillCountSubquest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, questendtime ) --value on the bar at start
  entKillCountSubquest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, questendtime ) --value on the bar
  
  Timers:CreateTimer(0.9, function()
    if entQuest:IsNull() then return end
    if (questTimeEnd - GameRules:GetGameTime())<=0 then
      UTIL_RemoveImmediate( entQuest )
      entKillCountSubquest = nil
      return
    end
    entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, questTimeEnd - GameRules:GetGameTime() )
    entKillCountSubquest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, questTimeEnd - GameRules:GetGameTime() ) --update the bar with the time passed        
    return 1      
  end
  )

  return entQuest
end

choice = 0 --
function PlayBGM(player)
    local delayInBetween = 2.0
    
    Timers:CreateTimer("BGMTimer" .. player:GetPlayerID(), {
        endTime = 0,
        callback = function()
            choice = RandomInt(1,8)
            if choice == lastChoice then return 0.1 end
            print("Playing BGM No. " .. choice)
            local songName = "BGM." .. choice
            player.CurrentBGM = songName
            if choice == 1 then EmitSoundOnClient(songName, player) lastChoice = 1 return 186+delayInBetween
            elseif choice == 2 then EmitSoundOnClient(songName, player) lastChoice = 2 return 327+delayInBetween
            elseif choice == 3 then EmitSoundOnClient(songName, player) lastChoice = 3 return 138+delayInBetween
            elseif choice == 4 then EmitSoundOnClient(songName, player) lastChoice = 4 return 149+delayInBetween
            elseif choice == 5 then EmitSoundOnClient(songName, player) lastChoice = 5 return 181+delayInBetween
            elseif choice == 6 then EmitSoundOnClient(songName, player) lastChoice = 6 return 143+delayInBetween
            elseif choice == 7 then EmitSoundOnClient(songName, player) lastChoice = 7 return 184+delayInBetween
            elseif choice == 8 then EmitSoundOnClient(songName, player) lastChoice = 8 return 366+delayInBetween
            elseif choice == 9 then EmitSoundOnClient(songName, player) lastChoice = 9 return 239+delayInBetween
            elseif choice == 10 then EmitSoundOnClient(songName, player) lastChoice = 10 return 141+delayInBetween
            elseif choice == 11 then EmitSoundOnClient(songName, player) lastChoice = 11 return 184+delayInBetween
            elseif choice == 12 then EmitSoundOnClient(songName, player) lastChoice = 12 return 213+delayInBetween
            elseif choice == 13 then EmitSoundOnClient(songName, player) lastChoice = 13 return 180+delayInBetween
            elseif choice == 14 then EmitSoundOnClient(songName, player) lastChoice = 14 return 166+delayInBetween
            elseif choice == 15 then EmitSoundOnClient(songName, player) lastChoice = 15 return 156+delayInBetween
            elseif choice == 16 then EmitSoundOnClient(songName, player) lastChoice = 16 return 173+delayInBetween
        else EmitSoundOnClient(songName, player) lastChoice = 17 return 143+delayInBetween end
    end})
end

function LevelAllAbility(hero)
    for i=0, 23 do
        local ability = hero:GetAbilityByIndex(i)
        if ability == nil then return end
        local level0 = false -- whether ability should be kept level 0 or not
        -- If skill shouldn't be leveled, do not set level to 1
        for i=1, #donotlevel do
            if ability:GetName() == donotlevel[i] then level0 = true end
        end
        -- If skill is actually a talent, do not level it
        if string.match(ability:GetName(),"special_bonus") then level0 = true end
        if not level0 then ability:SetLevel(1) end
        -- if skill should not be reset when using command seal, flag it as unresetable
        for i=1, #CannotReset do
            if ability:GetName() == CannotReset[i] then ability.IsResetable = false break end
        end
        
    end
end

function NonResetAbility(hero)
    --NotifyManaAndShard(hero)
    for i=0, 23 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            for i=1, #CannotReset do
                if ability:GetName() == CannotReset[i] then 
                    ability.IsResetable = false 
                    break 
                end
            end   
        end     
    end
end

--[[function EmitSoundOnAllClient(songname)
    for i=0, 11 do
        local player = PlayerResource:GetPlayer(i)
        if player ~= nil then
            EmitSoundOnClient(songname, player)
        end
    end
end]]

function EmitSoundOnAllClient(sound)
    --[[for i=0, 11 do
        local player = PlayerResource:GetPlayer(i)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "emit_client_sound", {sound=sound})
        end
    end]]
    Sounds:EmitSoundOnAllClient(sound)
end

function CheckItemCombination(hero)
    local bIsMatchingFound = false
    local ply = hero:GetPlayerOwner()
    if not ply.bIsAutoCombineEnabled or ply.bIsAutoCombineEnabled == false then return end

    --print("Checking item combination")

    -- loop through stash
    for i=0,5 do
        if bIsMatchingFound then break end
        local currentItem = hero:GetItemInSlot(i)
        if currentItem then
            local currentItemName1 = currentItem:GetName()
            local currentItemIndex1 = i
            if GetMatchingItem(currentItemName1) then
                -- first component found, find second component
                for j=0,5 do
                    if bIsMatchingFound then break end

                    if j == currentItemIndex1 then goto continue end -- just continue if we are looking at the same slot as first component
                    local currentItem2 = hero:GetItemInSlot(j)
                    if currentItem2 ~= nil then
                        local currentItemName2 = currentItem2:GetName()
                        -- match found, combine item 1 and item 2
                        if currentItemName1 == currentItemName2 then
                            if currentItemName1 == "item_f_scroll" and currentItemName2 == "item_f_scroll" then return end
                            bIsMatchingFound = true
                            if not currentItem:IsNull() then currentItem:RemoveSelf() end
                            if not currentItem2:IsNull() then currentItem2:RemoveSelf() end
                            CreateItemAtSlot(hero, tItemComboTable[currentItemName1], 0, -1, true, false)
                        elseif (currentItemName1 == "item_f_scroll" and currentItemName2 == "item_a_scroll") 
                            or (currentItemName1 == "item_a_scroll" and currentItemName2 == "item_f_scroll") then
                            bIsMatchingFound = true
                            if not currentItem:IsNull() then currentItem:RemoveSelf() end
                            if not currentItem2:IsNull() then currentItem2:RemoveSelf() end
                            CreateItemAtSlot(hero, tItemComboTable["item_f_scroll"], 0, -1, true, false)
                        end
                    end
                    ::continue::
                end
            end

        end
    end
end

function CheckItemCombinationInStash(hero)
    local bIsMatchingFound = false
    local ply = hero:GetPlayerOwner()
    if not ply.bIsAutoCombineEnabled or ply.bIsAutoCombineEnabled == false then return end

    -- loop through stash
    for i=9,14 do
        if bIsMatchingFound then break end

        local currentItem = hero:GetItemInSlot(i)
        if currentItem then
            local currentItemName1 = currentItem:GetName()
            local currentItemIndex1 = i
            --print("Current")
            --print(currentItemIndex1, currentItemName1)
            if GetMatchingItem(currentItemName1) then
                -- first component found, find second component
                for j=10,15 do
                    if bIsMatchingFound then break end

                    if j == currentItemIndex1 then goto continue end -- just continue if we are looking at the same slot as first component
                    local currentItem2 = hero:GetItemInSlot(j)
                    --local currentItemIndex2 = j
                    if currentItem2 then
                        local currentItemName2 = currentItem2:GetName()
                        -- match found, combine item 1 and item 2
                        if currentItemName1 == currentItemName2 then            
							if currentItemName1 == "item_f_scroll" and currentItemName2 == "item_f_scroll" then return end
                            bIsMatchingFound = true
                            --print("Match with")
                            --print(currentItemIndex2 ,currentItemName2)
                            if not currentItem:IsNull() then currentItem:RemoveSelf() end
                            if not currentItem2:IsNull() then currentItem2:RemoveSelf() end
                            CreateItemAtSlot(hero, tItemComboTable[currentItemName1], 9, -1, false, true)
                        elseif (currentItemName1 == "item_f_scroll" and currentItemName2 == "item_a_scroll") 
                            or (currentItemName1 == "item_a_scroll" and currentItemName2 == "item_f_scroll") then
                            bIsMatchingFound = true
                            if not currentItem:IsNull() then currentItem:RemoveSelf() end
                            if not currentItem2:IsNull() then currentItem2:RemoveSelf() end
                            CreateItemAtSlot(hero, tItemComboTable["item_f_scroll"], 9, -1, true, false)
                        end
                    end
                    ::continue::
                end
            end

        end
    end
end

function GetMatchingItem(name)
    for k,v in pairs(tItemComboTable) do
        if k == name then
            return true
        end
    end
    return false
end


function CreateItemAtSlot(hero, itemname, slot, charges, bIsInventoryChecked, bIsStashChecked)
    local dummyitemtable = {}
    for i = 0, slot-1 do
        if hero:GetItemInSlot(i) == nil then
            local dummyitem = CreateItem("item_dummy_item", nil, nil)
            table.insert(dummyitemtable, dummyitem)
            hero:AddItem(dummyitem)
        end
    end
    local newItem = CreateItem(itemname, nil, nil)
    if charges ~= -1 then
        newItem:SetCurrentCharges(charges)
    end
    hero:AddItem(newItem)

    for i = 1, #dummyitemtable do
        hero:RemoveItem(dummyitemtable[i]) 
    end
    if bIsInventoryChecked then CheckItemCombination(hero) end 
    if bIsStashChecked then CheckItemCombinationInStash(hero) end
end

function AddValueToTable(table, value)
    for i=1, 100 do
        if table[i] == nil then 
            table[i] = value
        end
    end
    return table
end

function CreateSlashFx(source, backpoint, frontpoint)
    local slash1ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, source )
    ParticleManager:SetParticleControl( slash1ParticleIndex, 2, backpoint )
    ParticleManager:SetParticleControl( slash1ParticleIndex, 3, frontpoint )
end

function IsSpellBlocked(target)
    if target:HasModifier("modifier_instinct_active") then  --This abililty is blocked by the active/targeted Linken's effect.
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_instinct_active")
        return true
    --elseif target:HasModifier("modifier_arondite") then
      --  EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        --ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        --return true
    elseif target:HasModifier("modifier_diarmuid_minds_eye_active") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_diarmuid_minds_eye_active")
        return true
    elseif target:HasModifier("modifier_lancer_rune_of_protection") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_lancer_rune_of_protection")
        return true
    elseif target:HasModifier("modifier_jtr_mental_pollution_passive") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_jtr_mental_pollution_passive")
        return true
    elseif target:HasModifier("modifier_okita_mind_eye") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_okita_mind_eye")
        return true
    elseif target:HasModifier("modifier_wisdom_spell_block") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_wisdom_spell_block")
        return true
    elseif target:HasModifier("modifier_scathach_rune_of_protection") then
        EmitSoundWithCooldown("DOTA_Item.LinkensSphere.Activate", target, 1)
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        target:RemoveModifierByName("modifier_scathach_rune_of_protection")
        return true
    else
        return false
    end
end

function EmitSoundWithCooldown(soundname, target, cooldown)
    if not target.bIsSoundOnCooldown then
        target:EmitSound(soundname)
        target.bIsSoundOnCooldown = true
        Timers:CreateTimer(cooldown, function()
            target.bIsSoundOnCooldown = false
        end)
    end
end

function IsRevoked(target)
    for i=1, #revokes do
        if target:HasModifier(revokes[i]) then return true end
    end
    return false
end

function IsLocked(target)
    for i=1, #locks do
        if target:HasModifier(locks[i]) then return true end
    end
    return false
end

function IsTPLocked(target)
    for i=1, #no_tp do
        if target:HasModifier(no_tp[i]) then return true end
    end
    return false
end

function IsRevivePossible(target)
    if target:HasModifier("can_be_executed") then
        --print("cannot revive")
        return false
    end
    return true
end

function IsFemaleServant(target)
    for i=1, #femaleservant do
        if target:GetName() == femaleservant[i] then
            return true
        end
    end

    -- skin female
    --[[if target:GetName() == "npc_dota_hero_bounty_hunter" then 
        if target:HasModifier("modifier_alternate_02") or target:HasModifier("modifier_alternate_03") then 
            return true 
        end
    elseif target:GetName() == "npc_dota_hero_phantom_lancer" then 
        if target:HasModifier("modifier_alternate_02") then 
            return true 
        end
    elseif target:GetName() == "npc_dota_hero_doom_bringer" then 
        if target:HasModifier("modifier_alternate_01") then 
            return true 
        end
    elseif target:GetName() == "npc_dota_hero_skywrath_mage" then 
        if target:HasModifier("modifier_alternate_02") then 
            return true 
        end    
    end]]

    return false
end

function IsIsekaiAbuser(target)
    for i=1, #tIsekaiAbuser do
        if target:GetName() == tIsekaiAbuser[i] then
            return true
        end
    end
    
    return false
end

function IsImmuneToCC(target)
    if target:HasModifier("modifier_heracles_berserk") and target.IsMadEnhancementAcquired then
        return true 
    elseif target:HasModifier("modifier_lishuwen_berserk_immune") then
        return true
    elseif target:HasModifier("modifier_heart_of_harmony") then
        return true
    elseif target:HasModifier("modifier_fran_mad") then 
        return true
    elseif target:HasModifier("modifier_lubu_mad") then
        return true
    elseif target:HasModifier("modifier_double_edge_mad") then
        return true
    elseif target:HasModifier("modifier_bathory_berserk") then
        return true
    elseif target:HasModifier("modifier_edmond_monte_cristo") and target.IsDeterminationAcquired then
        return true 
    elseif target:HasModifier("modifier_gordius_wheel") and target.IsThundergodAcquired then
        return true
    elseif target:GetUnitName() == "bathory_iron_maiden" then
        return true
    elseif target:HasModifier("modifier_kiyohime_q_buff_cc_immune") and target.Sa5Acquired then 
        return true
    elseif target:HasModifier("modifier_okita_headband_upgrade") and target:IsRealHero() then 
        return true
    --elseif target:HasModifier("modifier_mashu_protect_ally") then 
    --    return true
    else
        return false
    end
end

function IsImmuneToSlow(target)
    if target:HasModifier("modifier_heracles_berserk") and target.IsMadEnhancementAcquired then
        return true 
    elseif target:HasModifier("modifier_forward") then
        return true
    elseif target:HasModifier("modifier_lishuwen_berserk_immune") then
        return true
    elseif target:HasModifier("modifier_fran_mad") then
        return true
    elseif target:HasModifier("modifier_lubu_mad") then
        return true
    elseif target:HasModifier("modifier_double_edge_mad") then
        return true
    elseif target:HasModifier("modifier_bathory_berserk") then
        return true
    elseif target:HasModifier("modifier_edmond_monte_cristo") and target.IsDeterminationAcquired then
        return true
    elseif target:HasModifier("modifier_kiyohime_q_buff_cc_immune") and target.Sa5Acquired then 
        return true
    else
        return false
    end
end

function IsBiggerUnit(target)
    if target:HasModifier("modifier_gordius_wheel") then
        return true
    elseif target:HasModifier("modifier_boarding_ship") then
        return true
    elseif target:GetName() == "npc_dota_hero_ember_spirit" and target:HasModifier("modifier_unlimited_bladeworks") then
        return true
    elseif target:GetName() == "npc_dota_hero_vengefulspirit" and target:HasModifier("modifier_4_days_loop") then
        return true
    elseif target:GetName() == "npc_dota_hero_chen" and target:HasModifier("modifier_army_of_the_king_death_checker") then
        return true
    elseif target:GetName() == "npc_dota_hero_riki" and target:HasModifier("modifier_jtr_whitechapel_self") then
        return true
    elseif target:GetName() == "npc_dota_hero_naga_siren" and target:HasModifier("modifier_fake_ubw_think") then
        return true
    elseif target:GetName() == "npc_dota_hero_enchantress" and target:HasModifier("modifier_amaterasu_aura") then
        return true
    elseif target:GetName() == "npc_dota_hero_windrunner" and target:HasModifier("modifier_queens_glass_game") then
        return true
    elseif target:GetName() == "npc_dota_hero_lina" and target:HasModifier("modifier_aestus_domus_aurea_nero") then
        return true
    
    elseif target:GetName() == "npc_dota_hero_queenofpain" and target:HasModifier("modifier_casa_active_mr_self") then
        return true
    
    elseif target:GetName() == "npc_dota_hero_troll_warlord" and target:HasModifier("modifier_voyager_lucky") then
        return true
    
    elseif target:GetName() == "npc_dota_hero_legion_commander" and target:HasModifier("modifier_avalon") then
        return true
    elseif target:GetName() == "npc_dota_hero_dark_willow" and target:HasModifier("modifier_hira_seigan_shield") then
        return true
    elseif target:GetName() == "npc_dota_hero_juggernaut" and target:HasModifier("modifier_heart_of_harmony") then
        return true
    elseif string.match(target:GetUnitName(), "bathory_iron_maiden") then
        return true
    elseif string.match(target:GetUnitName(), "drake_golden_hind") then
        return true
    elseif string.match(target:GetUnitName(), "medea_ancient_dragon") then
        return true
    elseif string.match(target:GetUnitName(), "gille_gigantic_horror") then
        return true
    else
        return false
    end

end

function IsFront(source, target, qAngle)
    if IsValidEntity(target) and not target:IsNull() then
        local caster_angle = source:GetAnglesAsVector().y

        local origin_difference = source:GetAbsOrigin() - target:GetAbsOrigin()
        local angle = qAngle 
        if angle == nil then 
            angle = 180 
        end

        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

        origin_difference_radian = origin_difference_radian * 180
        local enemy_angle = origin_difference_radian / math.pi

        enemy_angle = enemy_angle + 180.0
        --print('enemy angle ' .. enemy_angle)

        if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
            enemy_angle = 360 - enemy_angle
        elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
            caster_angle = 360 - caster_angle 
        end

        local result_angle = math.abs(enemy_angle - caster_angle)

        if result_angle <= angle/2 then
            return true 
        else 
            return false 
        end
    else
        print('target is invaid')
        return false
    end
end

function IsFacingUnit(source, target, angle)
    local source_loc = source:GetAbsOrigin()
    local target_loc = target:GetAbsOrigin()
    if source_loc.z ~= target_loc.z then 
        source_loc.z = target_loc.z
    end
    local sourceangle = math.abs(RotationDelta(VectorToAngles((target_loc - source_loc):Normalized()), VectorToAngles(source_loc)).y)
    if sourceangle < angle/2 then
        return true
    else
        return false
    end
end

--
function OnExperienceZoneThink(keys)
    local hero = keys.target
    local gold = keys.ability:GetSpecialValueFor("gold")
    if hero:IsRealHero() and hero:IsHero() and not hero:IsIllusion() and (heroList[hero:GetName()] == 1 or testList[hero:GetName()] == 1) then
        hero:SetGold(hero:GetGold() + gold, true)
        if hero:GetLevel() < 24 then
            hero:AddExperience(hero:GetLevel() * 2 + 15, false, false)
        end
    end
end

function HardCleanse(target)
    for i=1, #cleansable do
        if target:HasModifier(cleansable[i]) then
            target:RemoveModifierByName(cleansable[i])
        end
    end

    for i=1, #slowmodifier do
        if target:HasModifier(slowmodifier[i]) then
            target:RemoveModifierByName(slowmodifier[i])
        end
    end
end

function RemoveSlowEffect(target)
    for i=1, #slowmodifier do
        if target:HasModifier(slowmodifier[i]) then
            target:RemoveModifierByName(slowmodifier[i])
        end
    end
end

function GetPhysicalDamageReduction(armor)
    local reduction = 0.06*armor / (1+0.06*armor)
    return reduction
    --[[if armor >= 0 then 
        return reduction
    else
        return -reduction
    end]]
end

-- Does what it says. damage post reduction -> pre reduction
function CalculateDamagePreReduction(eDamageType, fDamage, hUnit)
	if eDamageType == DAMAGE_TYPE_PHYSICAL then
		local fArmor = hUnit:GetPhysicalArmorValue(false)
		local multiplier = 1 + 0.06 * fArmor / (1 + 0.06 * math.abs(fArmor))
		return fDamage * multiplier
	end
	
	if eDamageType == DAMAGE_TYPE_MAGICAL then
		local fMagicRes = hUnit:GetBaseMagicalResistanceValue()/100 --hUnit:GetMagicalArmorValue()
		return fDamage * (1 + fMagicRes)
	end
	
	return fDamage
end

function CalculateDamagePostReduction(eDamageType, fDamage, hUnit)
	if eDamageType == DAMAGE_TYPE_PHYSICAL then
		local fArmor = hUnit:GetPhysicalArmorValue(false)
		local multiplier = 1 - 0.06 * fArmor / (1 + 0.06 * math.abs(fArmor))
		return fDamage * multiplier
	end
	
	if eDamageType == DAMAGE_TYPE_MAGICAL then
		local fMagicRes = hUnit:GetBaseMagicalResistanceValue()/100 --hUnit:GetMagicalArmorValue()
		return fDamage * (1 - fMagicRes)
	end
	
	return fDamage
end


function ReduceCooldown(ability, reduction)
    local remainingCD = ability:GetCooldownTimeRemaining() 
    ability:EndCooldown()
    ability:StartCooldown(remainingCD - reduction)
end

lastTipChoice = 0
function DisplayTip()
    print("Displaying tip!")
    local tipchoice = 0
    local tipRef = ""
    while tipchoice == lastTipChoice do
        --print("Rerolling tip choice")
        tipchoice = RandomInt(1, 10) 
        tipRef = ("#Fate_Tip" .. tipchoice)
    end

    GameRules:SendCustomMessage(tipRef, 0, 0) 
    lastTipChoice = tipchoice
end

-- ten_min_timer
-- round_timer
-- pregame_timer
-- ubw_timer
-- aotk_timer
function CreateUITimer(message, duration, description)
    local timerData = {
        timerMsg = message,
        timerDuration = duration,
        timerDescription = description
    }
    CustomGameEventManager:Send_ServerToAllClients( "display_timer", timerData ) 
end

-- Create a particle that is visible by anyone in both teams
-- example: CreateGlobalParticle("particles/custom/iskandar/iskandar_aotk.vpcf", {[0] = caster:GetAbsOrigin()}, 2)
function CreateGlobalParticle(particle_name, controlpoints, duration)
    for i=2,13 do
        local particle = ParticleManager:CreateParticleForTeam(particle_name, PATTACH_CUSTOMORIGIN, nil, i)
        for k,v in pairs(controlpoints) do
            ParticleManager:SetParticleControl(particle, k, v)
        end
        Timers:CreateTimer(duration, function()
            ParticleManager:DestroyParticle( particle, false )
            ParticleManager:ReleaseParticleIndex( particle )
        end)
    end
end
-- check whether two locations belong in same realm
-- loc 1 = vector
-- loc 2 = vector
function IsInSameRealm(loc1, loc2)
    -- above -2000 normal map
    if loc1.y > -2000 and loc2.y > -2000 then
      -- both are in normal map
      return true
    elseif not (loc1.y <= -2000 and loc2.y <= -2000) then
      return false
    end
    -- 3300 split between AotK and UBW
    if loc1.x < 3300 and loc2.x < 3300 then
      -- both are in AotK
      return true
    elseif not (loc1.x >= 3300 and loc2.x >= 3300) then
      return false
    end
    -- below -6300 master location
    if loc1.y > -6300 and loc2.y > -6300 then
      -- both are in UBW
      return true
    elseif not (loc1.y <= -6300 and loc2.y <= -6300) then
      return false
    end
    -- both are in master area
    return true
end

function UpdateBarriorUI(caster, shieldBuff, shieldamount)
    if caster.ShieldParticleIndex ~= nil then
        -- Destroy previous
        ParticleManager:DestroyParticle( caster.ShieldParticleIndex, true )
        ParticleManager:ReleaseParticleIndex( caster.ShieldParticleIndex )
    end
    local shield_particle = "particles/custom/caster/caster_argos_durability.vpcf"
    if shieldamount > 0 and caster:HasModifier( shieldBuff ) then
        local digit = 0
        if shieldamount > 999 then
            digit = 4
        elseif shieldamount > 99 then
            digit = 3
        elseif shieldamount > 9 then
            digit = 2
        else
            digit = 1
        end
        
        -- Create new one
        caster.ShieldParticleIndex = ParticleManager:CreateParticle( shield_particle, PATTACH_CUSTOMORIGIN, caster )
        ParticleManager:SetParticleControlEnt( caster.ShieldParticleIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
        ParticleManager:SetParticleControl( caster.ShieldParticleIndex, 1, Vector( 0, math.floor( shieldamount ), 0 ) )
        ParticleManager:SetParticleControl( caster.ShieldParticleIndex, 2, Vector( 1, digit, 0 ) )
        ParticleManager:SetParticleControl( caster.ShieldParticleIndex, 3, Vector( 100, 100, 255 ) )
    else
        caster:RemoveModifierByName(shieldBuff)
        ParticleManager:DestroyParticle( caster.ShieldParticleIndex, true )
        ParticleManager:ReleaseParticleIndex( caster.ShieldParticleIndex )
    end
end

function SendErrorMessage(playerID, string)
   CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_message_fired", {message=string}) 
end

function SendMountStatus(hero)
    local bMounted = false
    if hero:GetName() == "npc_dota_hero_shadow_shaman" then 
        bMounted = hero.IsIntegrated
    elseif hero:GetName() == "npc_dota_hero_crystal_maiden" then 
        bMounted = hero.IsMounted
    elseif hero:GetName() == "npc_dota_hero_troll_warlord" then 
        bMounted = hero.IsOnBoarded
    elseif hero:GetName() == "npc_dota_hero_phantom_assassin" then 
        bMounted = hero.IsOnBoarded
    end

    local playerData = {
        bIsMounted = bMounted
    }
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_mount_status_changed", playerData )
end

function GetSpellAmp(source)
    if source:HasModifier("spell_amplified") then
        local amp = source:GetModifierStackCount("spell_amplified", nil) 
        return amp
    else
        return 0
    end
end

function GiveSpellAmp(target,duration,amount,source,ability)
    local amp = target:GetModifierStackCount("spell_amplified", target) or 0
    if amount < amp then
        return
    else
        giveUnitDataDrivenModifier(source, target, "spell_amplified", duration)
        target:SetModifierStackCount("spell_amplified", source, amount)
    end    
end



function DoDamage(source, target , dmg, dmg_type, dmg_flag, abil, isLoop)
    if not IsValidEntity(target) or target:IsNull() then 
        print('Dodamage: target is null')
        return 
    end

    if abil == nil or abil:IsNull() then 
        print('Dodamage: ability is null')
        return 
    end

    if target:HasModifier("modifier_mashu_protect_ally") then 
        local mashu = Entities:FindByClassname(nil, "npc_dota_hero_dragon_knight")
        if target:GetUnitName() == "npc_dota_hero_dragon_knight" then 
            mashu = target 
        end 
        DoMashuShieldDamage(source, target , dmg, dmg_type, dmg_flag, abil, mashu)
        return
    elseif target:HasModifier("modifier_mashu_protect_aura") then 
        local mashu = Entities:FindByClassname(nil, "npc_dota_hero_dragon_knight")
        if mashu.IsDMGCalculated then
            --return 
        else
            DoMashuShieldDamage(source, target , dmg, dmg_type, dmg_flag, abil, mashu)
            --[[mashu.IsDMGCalculated = true
            Timers:CreateTimer(0.099, function()
                mashu.IsDMGCalculated = false
                mashu.ability_name = 0
            end)]]
        end
    elseif target:HasModifier("modifier_mashu_beam_dummy_track") then
        print('mashu after beam track')
        if IsBeam(abil) then 
            local mashu = Entities:FindByClassname(nil, "npc_dota_hero_dragon_knight")
            if mashu.projectile.ability_name and mashu.projectile.ability_name == abil:GetAbilityName() then 
                print('dmg beam track = ' .. mashu.projectile.damage)
                dmg = mashu.projectile.damage
            end
        end
    end

   -- if target == nil then return end 
    local IsAbsorbed = false
    local IsBScrollIgnored = false
    local MR = target:GetBaseMagicalResistanceValue()/100 --target:GetMagicalArmorValue() 
    local PhysicReduction = GetPhysicalDamageReduction(target:GetPhysicalArmorValue(false))
    dmg_flag = bit.bor(dmg_flag, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
    print('dmg_flag = ' .. dmg_flag)
    if target:GetName() == "npc_dota_ward_base" or target:GetUnitName() == "ward_familiar" or target:GetUnitName() == "sentry_familiar" then
        if string.match(abil:GetAbilityName(), "atalanta_celestial_arrow") then
            dmg = 1
            dmg_type = DAMAGE_TYPE_PURE 
        else
            --print('bruh')
            return 
        end
    end
    if string.match(target:GetUnitName(), "okita_flag") then
        if not IsBeam(abil) then 
            dmg = math.min(math.floor(dmg/100),math.ceil(dmg/500))
        end
    end

    -- Records skill damage PRE-REDUCTION. For the rest, refer to OnHeroTakeDamage() below.
    if isLoop == false then
        if GetMapName() == "fate_tutorial" then 
        else
            if not source:IsHero() then --Account for neutral attacker
                if IsValidEntity(source:GetPlayerOwner()) then
                    sourceHero = source:GetPlayerOwner():GetAssignedHero()
                end
            else
                sourceHero = source
            end

            if not target:IsHero() and not target.IsNurseryClone then --Account for neutral target
                if IsValidEntity(target:GetPlayerOwner()) then
                    targetHero = target:GetPlayerOwner():GetAssignedHero()
                end
            else
                targetHero = target
            end        
            
            if not target.IsNurseryClone then
                local dmg_stat = dmg 
                if sourceHero:GetTeam() == targetHero:GetTeam() then 
                    dmg_stat = 0 
                end
                sourceHero.ServStat:doDamageBeforeReduction(dmg_stat)
                if not targetHero:IsIllusion() then -- band aid for NR's shapeshift.
        	        targetHero.ServStat:takeDamageBeforeReduction(dmg_stat)
        	    end
            end  
        end  
    end
    -- END
    --[[if abil:GetAbilityName() == "karna_vasavi_shakti" or abil:GetAbilityName() == "karna_combo_vasavi" then
    else
        if IsDivineServant(target) then
            --print('Divine Servant')
            if CheckDivinity(target) == 1 then 
                --print('Divine Servant Rank A')
                dmg = dmg * 0.95
            elseif CheckDivinity(target) == 2 then 
                --print('Divine Servant Rank B')
                dmg = dmg
            end
        end
    end]]

    -- on mount
    if IsMountedHero(target) and not string.match(abil:GetAbilityName(), "lancer_wesen_gae_bolg") then 
        dmg = 0
    end

    -- Bonus damage to Squid
    if IsBeam(abil) then 
        if string.match(target:GetUnitName() ,"gille_gigantic_horror") then 
            local bonus_dmg = target:FindAbilityByName("gille_gigantic_horror_passive"):GetSpecialValueFor("additional_damage") 
            dmg = dmg * bonus_dmg / 100
        end
    -- damage on arrow protection
    elseif IsArrowAbility(abil) then
        if IsProjectileParry(target) then 
            dmg = 0 
        end
    end

    if source:HasModifier("modifier_zhuge_spell_amp") then 
        local spell_amp = source:GetModifierStackCount("modifier_zhuge_spell_amp", nil) / 100
        dmg = dmg * (1 + spell_amp)
    end

    if target:HasModifier("modifier_mark_of_fatality") and source.bIsMartialArtsImproved then 
        local fatal_stack = target:GetModifierStackCount("modifier_mark_of_fatality", source)
        local bonus_fatal = source:GetAbilityByIndex(3):GetSpecialValueFor("bonus_dmg") / 100
        dmg = dmg * (1 + (fatal_stack * bonus_fatal))
    end

    if dmg_type == DAMAGE_TYPE_MAGICAL then
        -- PROCESS EXTRA SPELL DAMAGE WITH CUSTOM SPELL AMP
        local magicamp = GetSpellAmp(source)
        if dmg > 500 then
            local ampvalue = dmg * magicamp / 100
            local penalty = ((10 - dmg / 500) / 10)

            if penalty < 0.5 then
                penalty = 0.5
            end

            dmg = dmg + ampvalue * penalty
        else
            dmg = dmg + dmg * magicamp / 100
        end
        -- Process B scroll
        for k,v in pairs(goesthruB) do
            if abil:GetAbilityName() == v then IsBScrollIgnored = true break end
        end
        
        if target:IsMagicImmune() and dmg_flag ~= bit.bor(dmg_flag, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)  then 
            dmg = 0 
        end

        if target:HasModifier("modifier_amakusa_combo_block") then 
            local amakusa = Entities:FindByClassname(nil, "npc_dota_hero_ember_spirit")
            local twin_arm = amakusa:FindAbilityByName("amakusa_twin_arm")
            if twin_arm == nil then 
                twin_arm = amakusa:FindAbilityByName("amakusa_twin_arm_upgrade")
            end
            local block = twin_arm:GetSpecialValueFor("block")
            dmg = math.max(0, dmg - block)
        end

        if target:HasModifier("modifier_semiramis_poisonous_cloud_amp") and IsPoisonAbility(abil) and abil:GetAbilityName() ~= "semiramis_poisonous_cloud_upgrade" then 
            local semiramis = Entities:FindByClassname(nil, "npc_dota_hero_phantom_assassin")
            local poison_aura = semiramis:FindAbilityByName("semiramis_poisonous_cloud_upgrade")
            local bonus_poison = poison_aura:GetSpecialValueFor("bonus_poison") / 100
            dmg = dmg + (dmg * bonus_poison)
        end

        if IsPoisonAbility(abil) and IsPoisonImmune(target) and abil:GetAbilityName() ~= "semiramis_poisonous_bite_charm" and abil:GetAbilityName() ~= "semiramis_poisonous_bite_upgrade" then 
            dmg = 0
        end
        --[[if (abil:GetAbilityName() == "karna_combo_vasavi" 
            or abil:GetAbilityName() == "karna_vasavi_shakti")
            and source.IndraAttribute then
            IsBScrollIgnored = true
        else
        if (abil:GetAbilityName() == "karna_brahmastra" 
            or abil:GetAbilityName() == "karna_brahmastra_kundala")
            and source.ManaBurstAttribute then
            IsBScrollIgnored = true
        end]]

        if IsBScrollIgnored == false and target:HasModifier("modifier_b_scroll") then 
            local originalDamage = dmg - target.BShieldAmount --* 1/(1-MR)
            target.BShieldAmount = target.BShieldAmount - dmg --* (1-MR)
            if target.BShieldAmount <= 0 then
                dmg = originalDamage
                target:RemoveModifierByName("modifier_b_scroll")
            else 
                dmg = 0
                IsAbsorbed = true
            end
        end
    elseif dmg_type == DAMAGE_TYPE_PURE then 
        if target:HasModifier("modifier_d_scroll") then 
            local originalDamage = dmg - target.DShieldAmount
            target.DShieldAmount = target.DShieldAmount - dmg
            if target.DShieldAmount <= 0 then
                dmg = originalDamage
                target:RemoveModifierByName("modifier_d_scroll")
            else 
                dmg = 0
                IsAbsorbed = true
            end
        end
    end

    -- check if target has Kongming Shield
    if not IsAbsorbed and target:HasModifier("modifier_zhuge_liang_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR 
        end 
        local originalDamage = dmg - target.ZhugeShield * 1/(1-reduction)
        target.ZhugeShield = target.ZhugeShield - dmg * (1-reduction)
        if target.ZhugeShield <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_zhuge_liang_shield") 
            target.ZhugeShield = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- check if target has Rho Aias shield 
    if not IsAbsorbed and target:HasModifier("modifier_rho_aias") then
        local reduction = 0
        if target:HasModifier("modifier_l_rule_breaker") or target:HasModifier ("modifier_c_rule_breaker") and (dmg_type == DAMAGE_TYPE_PURE or dmg_type == DAMAGE_TYPE_PHYSICAL) then
            reduction = 1
        elseif dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR
        end 
        local originalDamage = dmg - target.rhoShieldAmount * 1/(1-reduction)
        target.rhoShieldAmount = target.rhoShieldAmount - dmg * (1-reduction)

        -- if damage is beyond the shield's block amount, update remaining damage
        if target.rhoShieldAmount <= 0 then
            --print("Rho Aias has been broken through by " .. -target.rhoShieldAmount)
            dmg = originalDamage
            target:RemoveModifierByName("modifier_rho_aias")
            target.argosShieldAmount = 0
        -- if shield has enough durability, set a flag that the damage is fully absorbed
        else 
            --print("Rho Aias absorbed full damage")
            dmg = 0
            IsAbsorbed = true
        end
    end
  
    -- check if target has Cursed Lance
    if not IsAbsorbed and target:HasModifier("modifier_cursed_lance_shield") then
  	    --local modifier = target:FindModifierByName("modifier_cursed_lance_shield")
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR
        end
        local originalDamage = dmg - target.CurseShieldAmount * 1/(1-reduction)
        target.CurseShieldAmount = target.CurseShieldAmount - dmg * (1-reduction)
        if target.CurseShieldAmount <= 0 then
            dmg = originalDamage
            if not target.InstantCurseAcquired then
                target:RemoveModifierByName("modifier_cursed_lance_shield")
            end
            target.CurseShieldAmount = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- check if target has Mordred Shield
    if not IsAbsorbed and target:HasModifier("modifier_mordred_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR
        end 
        local originalDamage = dmg - target.argosShieldAmount * 1/(1-reduction)
        target.argosShieldAmount = target.argosShieldAmount - dmg * (1-reduction)
        if target.argosShieldAmount <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_mordred_shield") 
            target.argosShieldAmount = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- Check if target has Avalon up
    if target:GetName() == "npc_dota_hero_legion_commander" and target:HasModifier("modifier_avalon") then
        local incomingDmg = dmg
        local reduction = 0

        if target:HasModifier("modifier_l_rule_breaker") or target:HasModifier ("modifier_c_rule_breaker") and (dmg_type == DAMAGE_TYPE_PURE or dmg_type == DAMAGE_TYPE_PHYSICAL) then
            incomingDmg = incomingDmg * 0
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            incomingDmg = incomingDmg * (1-MR)
        elseif dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
            incomingDmg = incomingDmg * (1-reduction) 
        end
        if string.match(abil:GetAbilityName(), "sasaki_tsubame_gaeshi") then
            target.IsAvalonPenetrated = true
            target.IsAvalonProc = false
        else
            local avalon = target:FindAbilityByName("saber_avalon") or target:FindAbilityByName("saber_avalon_upgrade")
            if incomingDmg > avalon:GetSpecialValueFor("damage_threshold") then 
                target.IsAvalonProc = true
            else 
                target.IsAvalonProc = false
            end
            dmg = 0
            target.IsAvalonPenetrated = false
        end
    end 
    -- check if target has Argos
    if not IsAbsorbed and target:HasModifier("modifier_argos_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR
        end 
        local originalDamage = dmg - target.argosShieldAmount * 1/(1-reduction)
        target.argosShieldAmount = target.argosShieldAmount - dmg * (1-reduction)
        if target.argosShieldAmount <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_argos_shield") 
            target.argosShieldAmount = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- check if target has Semi shield
    if not IsAbsorbed and target:HasModifier("modifier_semiramis_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR 
        end 
        local originalDamage = dmg - target.SemiShieldAmount * 1/(1-reduction)
        target.SemiShieldAmount = target.SemiShieldAmount - dmg * (1-reduction)
        UpdateBarriorUI(target, "modifier_semiramis_shield", target.SemiShieldAmount)
        if target.SemiShieldAmount <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_semiramis_shield") 
            target.SemiShieldAmount = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
        
    end

    -- check if target has Fran Electric shield
    if not IsAbsorbed and target:HasModifier("modifier_fran_elect_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR 
        end 
        local originalDamage = dmg - target.ElectricShieldAmount * 1/(1-reduction)
        target.ElectricShieldAmount = target.ElectricShieldAmount - dmg * (1-reduction)
        if target.ElectricShieldAmount <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_fran_elect_shield") 
            target.ElectricShieldAmount = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
        
    end

    -- check if target has Seigan Shield
    if not IsAbsorbed and target:HasModifier("modifier_hira_seigan_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR 
        end 
        local originalDamage = dmg - target.SeiganShield * 1/(1-reduction)
        target.SeiganShield = target.SeiganShield - dmg * (1-reduction)
        if target.SeiganShield <= 0 then
            dmg = originalDamage
            target.IsShieldBreak = true
            target.SeiganShield = 0
            target.attacker = source
            target:RemoveModifierByName("modifier_hira_seigan_shield") 
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- check if target has Hate Shield
    if not IsAbsorbed and target:HasModifier("modifier_edmond_hate_shield") then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR
        end 
        if source:HasModifier("modifier_edmond_vengeance") then 
            dmg = dmg * 0.5 
        end
        local originalDamage = dmg - target.HateShield * 1/(1-reduction)
        target.HateShield = target.HateShield - dmg * (1-reduction)
        if target.HateShield <= 0 then
            dmg = originalDamage
            target:RemoveModifierByName("modifier_edmond_hate_shield") 
            target.HateShield = 0
        else
            dmg = 0
            IsAbsorbed = true
        end
    end

    -- Mashu shield Protect
    --[[if not IsAbsorbed and target:HasModifier("modifier_mashu_protect_self") and target.ShieldAmount > 0 then
        local reduction = 0
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            reduction = PhysicReduction
        elseif dmg_type == DAMAGE_TYPE_MAGICAL then
            reduction = MR 
        end 
        local originalDamage = dmg - target.ShieldAmount * 1/(1-reduction)
        target.ShieldAmount = math.max(target.ShieldAmount - dmg * (1-reduction), 0)
        target:SetModifierStackCount("modifier_mashu_passive_shield", caster, target.ShieldAmount)
        if target.ShieldAmount <= 0 then
            dmg = originalDamage
            EndAnimation(target)
            target:RemoveModifierByName("modifier_mashu_protect_self")
            target:RemoveModifierByName("modifier_mashu_shield_buff") 
            target:FindAbilityByName(target.WSkill):ApplyDataDrivenModifier(target, target, "modifier_mashu_shield_break_cooldown", {})
        else
            dmg = 0
            IsAbsorbed = true
        end
    end]]

    -- Check Lancelot Fairy 
    if target:GetName() == "npc_dota_hero_sven" and target.IsBlessingOfFairyAcquired and not target:HasModifier("modifier_blessing_of_fairy_cooldown") and dmg_type == DAMAGE_TYPE_MAGICAL then
        local fairy = target:FindAbilityByName("lancelot_blessing_of_fairy")
        local health_threshold = fairy:GetSpecialValueFor("damage_threshold")
        --print('lancelot MR = ' .. MR)
        local dmg_deal = dmg * (1-MR) 
        if target:HasModifier("modifier_double_edge_damage_amp") then 
            local dmg_taken = target:GetModifierStackCount("modifier_double_edge_damage_amp", target) / 100
            --print('bonus damage taken ' .. dmg_taken)
            dmg_deal = dmg_deal * (1 + dmg_taken)
        end -- 10000 - 1300 = 500      1300 - 500 = 800
        --print('damage take ' .. dmg_deal)
        --print('health ' .. target:GetHealth())
        if target:GetHealth() - dmg_deal <= health_threshold then 
            dmg = math.ceil((target:GetHealth() - health_threshold) / (1-MR))
            --print(dmg)
            if target:HasModifier("modifier_double_edge_damage_amp") then 
                local dmg_taken = target:GetModifierStackCount("modifier_double_edge_damage_amp", target) / 100
                dmg = math.ceil(dmg / (1 + dmg_taken))
            end
            --print(dmg)
        end
    end

    -- Check King Hassan Faith 
    if target:GetName() == "npc_dota_hero_skeleton_king" and target.IsFaithAcquired and not target:HasModifier("modifier_kinghassan_faith_cooldown") then 
        local faith = target:FindAbilityByName("kinghassan_faith")
        local dmg_proc = faith:GetSpecialValueFor("dmg_proc") / 100 

        if dmg >= dmg_proc * target:GetMaxHealth() then 
            dmg = 0
            HardCleanse(target)
            target:RemoveModifierByName("modifier_kinghassan_faith_passive")
            faith:ApplyDataDrivenModifier( target, target, "modifier_kinghassan_faith", {} )
            faith:ApplyDataDrivenModifier( target, target, "modifier_kinghassan_faith_cooldown", {Duration = faith:GetCooldown(1)} )
        end
    end
    --[[if IsFemaleServant(source) and target:HasModifier("modifier_love_spot") and source:HasModifier("modifier_love_spot_charmed") then
        dmg = dmg * 0.5
    end]]

    -- if damage was not fully absorbed by shield, deal residue damage 
    if IsAbsorbed == true then
        local dmgtable = {
            attacker = source,
            victim = target,
            damage = 0,
            damage_type = dmg_type,
            damage_flags = dmg_flag,
            ability = abil
        }
        ApplyDamage(dmgtable)
        return 
    else
        local dmgtable = {
            attacker = source,
            victim = target,
            damage = dmg,
            damage_type = dmg_type,
            damage_flags = dmg_flag,
            ability = abil
        }
        
        -- if target is linked, distribute damages 
        if target:HasModifier("modifier_share_damage")
          and not isLoop
          and not (string.match(abil:GetAbilityName(), "avenger_verg_avesta") and source:GetTeam() == target:GetTeam())
         --Queens glass game attribute fix
          and not (string.match(abil:GetAbilityName(), "kuro_sharing_pain") and source:GetTeam() == target:GetTeam())
          and not (target:HasModifier("modifier_queens_glass_game_check_link") and not target:HasModifier("modifier_qgg_oracle"))
          and target.linkTable ~= nil
        then
            -- Calculate the damage to secondary targets separately, in order to prevent MR from being twice as effective on primary target.
            local damageToAllies =  dmgtable.damage
            damageToAllies = damageToAllies/#target.linkTable -- * (1 + 0.1 * #target.linkTable - (#target.linkTable == 1 and 1 or 0) * 0.1) --damage/person is now 100/60/43.3/35/30 after instead of 100/50/33.3/25/20
            dmgtable.damage = dmgtable.damage/#target.linkTable -- * (1 + 0.1 * #target.linkTable - (#target.linkTable == 1 and 1 or 0) * 0.1)
            -- Loop through linked heroes
            for i=#target.linkTable,1,-1 do
                local hLinkTarget = target.linkTable[i]
                -- do ApplyDamage if it's primary target since the shield processing is already done
                if target.linkTable[i] == target then
                    ApplyDamage(dmgtable)
                -- for other linked targets, we need DoDamage
                else
                    if target.linkTable[i] ~= nil and IsValidEntity(target.linkTable[i]) then
                        if hLinkTarget:GetHealth() == 1 then
                            --hLinkTarget:SetHealth(1)
                            hLinkTarget:RemoveModifierByName("modifier_share_damage")
                            RemoveHeroFromLinkTables(hLinkTarget)
                        elseif hLinkTarget:GetHealth() >= CalculateDamagePostReduction(DAMAGE_TYPE_MAGICAL, damageToAllies, hLinkTarget) then
                            --DoDamage(source, hLinkTarget, damageToAllies,  DAMAGE_TYPE_MAGICAL, 0, abil, true)
                            DoDamage(target, hLinkTarget, damageToAllies,  DAMAGE_TYPE_MAGICAL, 0, abil, true)
                        elseif hLinkTarget:GetHealth() < CalculateDamagePostReduction(DAMAGE_TYPE_MAGICAL, damageToAllies, hLinkTarget) then
                            hLinkTarget:RemoveModifierByName("modifier_share_damage")
                            RemoveHeroFromLinkTables(hLinkTarget)
                            hLinkTarget:SetHealth(1)
                        end
                    end 
                end
            end
        -- if target is not linked, apply damage normally
        else 
            dmgtable.victim = target
            ApplyDamage(dmgtable)
        end        
    end
end

function DoMashuShieldDamage(source, target , dmg, dmg_type, dmg_flag, abil, mashu)
    local shield_dummy = mashu.shield_dummy or Entities:FindByClassname(nil, "mashu_shield_dummy")
    local shield_hp = mashu.ShieldAmount or shield_dummy:GetHealth()
    local ability_name = abil:GetAbilityName()

    if not mashu.IsDMGCalculated then
        mashu.IsDMGCalculated = true
        Timers:CreateTimer(0.099, function()
            mashu.IsDMGCalculated = false
            mashu.ability_name = 0
        end)

        if dmg_flag == DAMAGE_TYPE_PHYSICAL then 
            dmg_flag = bit.bor(dmg_flag, DOTA_DAMAGE_FLAG_BYPASSES_BLOCK)
        end

        if mashu.Shield then 
            if dmg >= shield_hp then 
                local reduction = 0
                if dmg_type == DAMAGE_TYPE_PHYSICAL then
                    reduction = GetPhysicalDamageReduction(mashu:GetPhysicalArmorValue(false))
                elseif dmg_type == DAMAGE_TYPE_MAGICAL then
                    reduction = mashu:GetBaseMagicalResistanceValue()/100
                end
                local originalDamage1 = dmg - shield_hp
                print('original dmage = ' .. originalDamage1)
                local mashudamagetaken_cap = mashu:GetHealth() * 1/(1-reduction)
                print('mashu damage taken cap ' .. mashudamagetaken_cap)
                if originalDamage1 >= mashudamagetaken_cap then 
                    mashu.ability_name = originalDamage1 - mashudamagetaken_cap
                    if IsBeam(abil) and not mashu.IsBeamDMGCalculated then
                        mashu.IsBeamDMGCalculated = true
                        mashu.projectile = {ability_name = ability_name, damage = originalDamage1 - mashudamagetaken_cap}
                        Timers:CreateTimer(1.5, function()
                            mashu.IsBeamDMGCalculated = false
                            mashu.projectile = {ability_name = nil, damage = 0}
                        end)
                    end
                else
                    mashu.ability_name = 0
                end
                if originalDamage1 > 0 then 
                    print('mashu take damage instead of ally')
                    mashu:RemoveModifierByName("modifier_mashu_protect_ally")
                    DoDamage(source, mashu , originalDamage1, dmg_type, dmg_flag, abil, false)
                end
            else 
                mashu.ability_name = 0    
            end
        else
            if dmg >= shield_hp then 
                mashu.ability_name = dmg - shield_hp
                if IsBeam(abil) and not mashu.IsBeamDMGCalculated then
                    mashu.IsBeamDMGCalculated = true
                    mashu.projectile = {ability_name = ability_name, damage = dmg - shield_hp}
                    Timers:CreateTimer(1.5, function()
                        mashu.IsBeamDMGCalculated = false
                        mashu.projectile = {ability_name = nil, damage = 0}
                    end)
                end
            else
                mashu.ability_name = 0
            end 
        end
        DoDamage(source, shield_dummy , math.min(dmg, mashu.max_shield), dmg_type, bit.bor(dmg_flag, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY), abil, false)
    end
    if mashu.Shield and target == mashu then

    else
        if mashu.ability_name > 0 and target:HasModifier("modifier_mashu_protect_ally") then
            target:RemoveModifierByName("modifier_mashu_protect_ally")
            DoDamage(source, target , mashu.ability_name, dmg_type, dmg_flag, abil, false)
            Timers:CreateTimer(0.033, function()
                target:RemoveModifierByName("modifier_mashu_beam_dummy_track")
            end)
        end
    end
end

function GetRotationPoint( ... )
    local originPoint, radius, angle = ...
    local radAngle = math.rad(angle)
    local x = math.cos(radAngle) * radius + originPoint.x
    local y = math.sin(radAngle) * radius + originPoint.y
    local position = Vector(x, y, originPoint.z)
    return position
end

function RandomPositionAtRadius(center, radius, iangle)
    local point = center
    local angle = 30 * iangle
    point.x = center.x + (radius * math.cos(angle))
    point.y = center.y + (radius * math.sin(angle))
    print(center.x .. " + " .. " " .. (radius * math.cos(angle)) .. " = " .. point.x)
    return Vector(point.x, point.y, center.z)
end

-- Check if anyone on this hero's team is still alive. 
function IsTeamWiped(hero)
    if _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" then return false end

    for i=0, 13 do
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(i)
        if playerHero ~= nil then 
            servant = playerHero
            if servant:GetTeam() == hero:GetTeam() and servant:IsAlive() then 
                return false
            end
        end
    end
    return true
end

function ApplyPurge(target)
    if not IsValidEntity(target) or target:IsNull() then return end
    for k,v in pairs(softdispellable) do
        if v == "modifier_courage_self_buff_stack" then
            if not target:HasModifier("modifier_madmans_roar_silence") then
                local currentStack = target:GetModifierStackCount("modifier_courage_self_buff_stack", target)
                if currentStack <= 2 then
                    target:RemoveModifierByName("modifier_courage_self_buff_stack")
                else
                    target:SetModifierStackCount("modifier_courage_self_buff_stack", target, currentStack-2)
                end
            end
        elseif v == "modifier_tennen_bonus" then
            target:SetModifierStackCount("modifier_tennen_bonus", target, 0)
        else
            if v == "modifier_share_damage" then
                RemoveHeroFromLinkTables(target)
            end
            target:RemoveModifierByName(v)
        end
    end
end

function ApplyStrongDispel(target)
    if not IsValidEntity(target) or target:IsNull() then return end
    for k,v in pairs(softdispellable) do
        if v == "modifier_share_damage" then
            RemoveHeroFromLinkTables(target)
            target:RemoveModifierByName(v)
        elseif v == "modifier_courage_self_buff_stack" then
            if not target:HasModifier("modifier_madmans_roar_silence") then
                target:RemoveModifierByName(v)
            end
        else
            target:RemoveModifierByName(v)
        end   
    end

    for k,v in pairs(strongdispellable) do
        if v == "modifier_courage_self_buff" or v == "modifier_heracles_berserk" or v == "modifier_eternal_rage" then
            if not target:HasModifier("modifier_madmans_roar_silence") then
                target:RemoveModifierByName(v)
            end
        else
            target:RemoveModifierByName(v)
        end
    end
end

-- Fills inventory with unusable placeholders
function FillInventory(entity)
    for i=0, 5 do
        local hero_item = entity:GetItemInSlot(i)
        if hero_item == nil then
            entity:AddItem(CreateItem("item_dummy_item_unusable" , nil, nil))
        end
    end
end


function ProcessShield()
    for k,v in pairs(goesthruB) do
        if ability == v then return else 
            -- process shield here
        end
    end
end


function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function SendKVToFatepedia(player)
    local abilKV = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
    local heroKV = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    local KVData = {abilKV, heroKV}
    CustomGameEventManager:Send_ServerToPlayer( player, "fatepedia_kv_sent", KVData )
    print("KV sent")
end

function CreateClientsideSpellbook(hero)
    --[[local pID = hero:GetPlayerID()
    local ply = PlayerResource:GetPlayer(pID)
    local heroName = hero:GetName()
    local spellbookData = {
        heroEnt = hero:entindex()
    }
    CustomGameEventManager:Send_ServerToPlayer( ply, "spellbook_created", playerData )]]

end

function CreateTemporaryStatTable(hero)
    local statTable = {
        STR = 0,
        AGI = 0,
        INT = 0,
        DMG = 0,
        ARMOR = 0,
        HPREG = 0,
        MPREG = 0,
        MS = 0,
        Gold = 0,
        ShardAmount = 0
    }
    statTable.STR = hero.STRgained 
    statTable.AGI = hero.AGIgained
    statTable.INT = hero.INTgained
    statTable.DMG = hero.DMGgained
    statTable.ARMOR = hero.ARMORgained
    statTable.HPREG = hero.HPREGgained
    statTable.MPREG = hero.MPREGgained
    statTable.MS = hero.MSgained
    statTable.Gold = hero.Goldgained
    statTable.ShardAmount = hero.ShardAmount
    return statTable
end
-- hi i'm here to implement math i don't really understand and hope it works
function RandomPointInCircle(origin, radius)
    t = 2*math.pi*RandomFloat(0,radius)
    u = RandomFloat(0, radius)+RandomFloat(0, radius)
    if u > radius then u = radius * 2 - u end
    return Vector(u*math.cos(t), u*math.sin(t),0) + origin
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


--============ Copyright (c) Valve Corporation, All rights reserved. ==========
--
--
--=============================================================================

--/////////////////////////////////////////////////////////////////////////////
-- Debug helpers
--
--  Things that are really for during development - you really should never call any of this
--  in final/real/workshop submitted code
--/////////////////////////////////////////////////////////////////////////////

-- if you want a table printed to console formatted like a table (dont we already have this somewhere?)
scripthelp_LogDeepPrintTable = "Print out a table (and subtables) to the console"
logFile = "log/log.txt"

function LogDeepSetLogFile( file )
	logFile = file
end

function LogEndLine ( line )
	AppendToLogFile(logFile, line .. "\n")
end

function _LogDeepPrintMetaTable( debugMetaTable, prefix )
	_LogDeepPrintTable( debugMetaTable, prefix, false, false )
	if getmetatable( debugMetaTable ) ~= nil and getmetatable( debugMetaTable ).__index ~= nil then
		_LogDeepPrintMetaTable( getmetatable( debugMetaTable ).__index, prefix )
	end
end

function _LogDeepPrintTable(debugInstance, prefix, isOuterScope, chaseMetaTables ) 
    prefix = prefix or ""
    local string_accum = ""
    if debugInstance == nil then 
		LogEndLine( prefix .. "<nil>" )
		return
    end
	local terminatescope = false
	local oldPrefix = ""
    if isOuterScope then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" then 
            LogEndLine( prefix .. "{" )
			oldPrefix = prefix
            prefix = prefix .. "   "
			terminatescope = true
        else 
            LogEndLine( prefix .. " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance))
        end
    end
    local debugOver = debugInstance

	-- First deal with metatables
	if chaseMetaTables == true then
		if getmetatable( debugOver ) ~= nil and getmetatable( debugOver ).__index ~= nil then
			local thisMetaTable = getmetatable( debugOver ).__index 
			if vlua.find(_LogDeepprint_alreadyseen, thisMetaTable ) ~= nil then 
				LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, "metatable", tostring( thisMetaTable ) ) )
			else
				LogEndLine(prefix .. "metatable = " .. tostring( thisMetaTable ) )
				LogEndLine(prefix .. "{")
				table.insert( _LogDeepprint_alreadyseen, thisMetaTable )
				_LogDeepPrintMetaTable( thisMetaTable, prefix .. "   ", false )
				LogEndLine(prefix .. "}")
			end
		end
	end

	-- Now deal with the elements themselves
	-- debugOver sometimes a string??
    for idx, data_value in pairs(debugOver) do
        if type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, idx, tostring( data_value ) ) )
            else
                local is_array = #data_value > 0
				local test = 1
				for idx2, val2 in pairs(data_value) do
					if type( idx2 ) ~= "number" or idx2 ~= test then
						is_array = false
						break
					end
					test = test + 1
				end
				local valtype = type(data_value)
				if is_array == true then
					valtype = "array table"
				end
                LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), valtype ) )
                LogEndLine(prefix .. (is_array and "[" or "{"))
                table.insert(_LogDeepprint_alreadyseen, data_value)
                _LogDeepPrintTable(data_value, prefix .. "   ", false, true)
                LogEndLine(prefix .. (is_array and "]" or "}"))
            end
		elseif type(data_value) == "string" then 
            LogEndLine( string.format( "%s%-32s\t= \"%s\" (%s)", prefix, idx, data_value, type(data_value) ) )
		else 
            LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), type(data_value) ) )
        end
    end
	if terminatescope == true then
		LogEndLine( oldPrefix .. "}" )
	end
end


function LogDeepPrintTable( debugInstance, prefix, isPublicScriptScope ) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    _LogDeepPrintTable(debugInstance, prefix, true, isPublicScriptScope )
end

function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end


--/////////////////////////////////////////////////////////////////////////////
-- Fancy new LogDeepPrint - handles instances, and avoids cycles
--
--/////////////////////////////////////////////////////////////////////////////

-- @todo: this is hideous, there must be a "right way" to do this, im dumb!
-- outside the recursion table of seen recurses so we dont cycle into our components that refer back to ourselves
_LogDeepprint_alreadyseen = {}


-- the inner recursion for the LogDeep print
function _LogDeepToString(debugInstance, prefix) 
    local string_accum = ""
    if debugInstance == nil then 
        return "LogDeep Print of NULL" .. "\n"
    end
    if prefix == "" then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" or type(debugInstance) == "table" or type(debugInstance) == "UNKNOWN" or type(debugInstance) == "table" then 
            string_accum = string_accum .. (type(debugInstance) == "table" and "[" or "{") .. "\n"
            prefix = "   "
        else 
            return " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance) .. "\n"
        end
    end
    local debugOver = type(debugInstance) == "UNKNOWN" and getclass(debugInstance) or debugInstance
    for idx, val in pairs(debugOver) do
        local data_value = debugInstance[idx]
        if type(data_value) == "table" or type(data_value) == "table" or type(data_value) == "UNKNOWN" or type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                string_accum = string_accum .. prefix .. idx .. " ALREADY SEEN " .. "\n"
            else 
                local is_array = type(data_value) == "table"
                string_accum = string_accum .. prefix .. idx .. " = ( " .. type(data_value) .. " )" .. "\n"
                string_accum = string_accum .. prefix .. (is_array and "[" or "{") .. "\n"
                table.insert(_LogDeepprint_alreadyseen, data_value)
                string_accum = string_accum .. _LogDeepToString(data_value, prefix .. "   ")
                string_accum = string_accum .. prefix .. (is_array and "]" or "}") .. "\n"
            end
        else 
            --string_accum = string_accum .. prefix .. idx .. "\t= " .. (type(data_value) == "string" and ("\"" .. data_value .. "\"") or data_value) .. "\n"
			string_accum = string_accum .. prefix .. idx .. "\t= " .. "\"" .. tostring(data_value) .. "\"" .. "\n"
        end
    end
    if prefix == "   " then 
        string_accum = string_accum .. (type(debugInstance) == "table" and "]" or "}") .. "\n" -- hack for "proving" at end - this is DUMB!
    end
    return string_accum
end


scripthelp_LogDeepString = "Convert a class/array/instance/table to a string"

function LogDeepToString(debugInstance, prefix) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    return _LogDeepToString(debugInstance, prefix)
end


scripthelp_LogDeepPrint = "Print out a class/array/instance/table to the console"

function LogDeepPrint(debugInstance, prefix) 
    prefix = prefix or ""
    LogEndLine(LogDeepToString(debugInstance, prefix))
end

function LoopOverHeroes(callback)
    for i=0, 13 do
        local hero = PlayerResource:GetSelectedHeroEntity(i)
        if hero ~= nil then 
            if callback(hero) then
                break
            end 
        end
    end
end

function LoopOverPlayers(callback)
    for i=0, 13 do
        local playerID = i
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
        if playerHero then
            --print("Looping through hero " .. playerHero:GetName())
            if callback(player, playerID, playerHero) then
                break
            end
        end 
    end
end

function UpgradeAttribute(hero, oldAbility, newAbility, bShow)
    hero:AddAbility(newAbility)
    hero:FindAbilityByName(newAbility):SetLevel(hero:FindAbilityByName(oldAbility):GetLevel())
    if not hero:FindAbilityByName(oldAbility):IsCooldownReady() then 
        hero:FindAbilityByName(newAbility):StartCooldown(hero:FindAbilityByName(oldAbility):GetCooldownTimeRemaining())
    end

    hero:SwapAbilities(newAbility, oldAbility, bShow, false)

    hero:RemoveAbility(oldAbility)
end

function MasterCannotUpgrade(hero, caster, ability, AcquireSA)
    if PlayerResource:GetConnectionState(caster:GetPlayerOwnerID()) == 3 then 
        SendErrorMessage(caster:GetMainControllingPlayer(), "#Player_" .. caster:GetPlayerOwnerID() .. "_is_disconnected")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true
    elseif AcquireSA then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#This_attribute_is_already_upgraded")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        return true
    elseif hero:IsChanneling() or hero:HasModifier("pause_sealenabled") or hero:HasModifier("pause_sealdisabled") or hero:HasModifier("jump_pause") or hero == nil then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true
    end

    if hero:GetName() == "npc_dota_hero_ember_spirit" and hero:HasModifier("modifier_ubw_chronosphere_aura") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true
    elseif hero:GetName() == "npc_dota_hero_chen" then 
        if hero:HasModifier("modifier_army_of_the_king_freeze") or hero:HasModifier("modifier_army_of_the_king_death_checker") or hero:HasModifier("iskandar_gordius_wheel") then
            SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
            caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
            ability:EndCooldown()
            return true
        end
    elseif hero:GetName() == "npc_dota_hero_lina" and hero:HasModifier("modifier_aestus_domus_aurea_nero") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true
    elseif hero:GetName() == "npc_dota_hero_omniknight" and hero:HasModifier("modifier_sun_of_galatine_channel_aura") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true
    elseif hero:GetName() == "npc_dota_hero_windrunner" and hero:HasModifier("modifier_queens_glass_game") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true      
    elseif hero:GetName() == "npc_dota_hero_sven" then 
        if hero:HasModifier("modifier_gatling_weapon") or hero:HasModifier("modifier_arondite") then
            SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
            caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
            ability:EndCooldown()
            return true 
        end
    elseif hero:GetName() == "npc_dota_hero_death_prophet" and hero:HasModifier("modifier_bathory_cage_check") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true  
    elseif hero:GetName() == "npc_dota_hero_troll_warlord" and hero:HasModifier("modifier_golden_wild_hunt_check") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true  
    elseif hero:GetName() == "npc_dota_hero_dark_willow" and (hero:HasModifier("modifier_hira_seigan_shield") or hero:HasModifier("modifier_okita_flash_window"))  then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true  
    elseif hero:GetName() == "npc_dota_hero_enigma" and hero:HasModifier("modifier_right_hand") then 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true    
    elseif hero:GetName() == "npc_dota_hero_gyrocopter" and hero:HasModifier("modifier_nobu_turnlock") then   
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true   
    elseif hero:GetName() == "npc_dota_hero_dragon_knight" and hero:HasModifier("modifier_mashu_protect_self") then   
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Upgrade_Now")
        caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
        ability:EndCooldown()
        return true   
    end
 
    return false
end

function RemoveHeroFromLinkTables(targethero)
    LoopOverHeroes(function(hero)
        if hero.linkTable ~= nil then
            for i=1, #hero.linkTable do
                if hero.linkTable[i] == targethero then
                    --print("Removed " .. hero.linkTable[i]:GetName() .. "from", hero:GetName(), " from table")
                    table.remove(hero.linkTable, i)
                end
            end
        end
    end)
    --For debugging
    --[[LoopOverHeroes(function(hero)
        if hero.linkTable ~= nil then
            for i=1, #hero.linkTable do
                print(hero:GetName(),hero.linkTable[i]:GetName())
            end
        end
    end)]]
end

function CheckingComboEnable(hero)
    if not hero.EnableCombo then
        if IsManaLess(hero) then 
            if math.ceil(hero:GetStrength()) >= 30 and math.ceil(hero:GetAgility()) >= 30 then 
                CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "combo_declare", {hero = hero:GetName(), combo = hero.MasterUnit2:GetAbilityByIndex(5):GetAbilityName()})
                --GameRules:SendCustomMessageToTeam("#" .. hero:GetName() .."_enable_combo", hero:GetTeamNumber(), 0,hero:GetTeamNumber())
                hero.MasterUnit2:FindAbilityByName(hero.MasterUnit2:GetAbilityByIndex(5):GetAbilityName()):EndCooldown()
                hero.EnableCombo = true
            end
        else
            if math.ceil(hero:GetStrength()) >= 25 and math.ceil(hero:GetAgility()) >= 25 and math.ceil(hero:GetIntellect(true)) >= 25 then 
                if hero:GetName() == "npc_dota_hero_bounty_hunter" then
                    local self_mod = hero:FindAbilityByName(hero:GetAbilityByIndex(1):GetAbilityName())
                    if hero:HasModifier("modifier_ta_self_mod_str") and math.ceil(hero:GetStrength() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
                        return 
                    elseif hero:HasModifier("modifier_ta_self_mod_agi") and math.ceil(hero:GetStrength() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
                        return 
                    elseif hero:HasModifier("modifier_ta_self_mod_int") and math.ceil(hero:GetAgility() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
                        return 
                    elseif hero:HasModifier("modifier_ta_self_mod_all") and math.ceil(hero:GetIntellect() - self_mod:GetSpecialValueFor("bonus_stat_half")) < 25 then 
                        return 
                    end
                elseif hero:GetName() == "npc_dota_hero_sven" then
                    local arondight = GetAbility(hero, "lancelot_arondite")
                    if hero:HasModifier("modifier_arondite") and (math.ceil(hero:GetStrength() - arondight:GetSpecialValueFor("bonus_allstat")) < 25 or math.ceil(hero:GetAgility() - arondight:GetSpecialValueFor("bonus_allstat")) < 25 or math.ceil(hero:GetIntellect() - arondight:GetSpecialValueFor("bonus_allstat")) < 25) then 
                        return 
                    end
                elseif hero:GetName() == "npc_dota_hero_omniknight" then
                    if hero:HasModifier("modifier_gawain_saint_bonus") and hero:GetModifierStackCount('modifier_gawain_saint_bonus', hero) == 3 then 
                        local numsaint = hero:FindAbilityByName('gawain_numeral_saint')
                        if math.ceil(hero:GetStrength() - (numsaint:GetSpecialValueFor("bonus_stat")*2)) < 25 or math.ceil(hero:GetAgility() - (numsaint:GetSpecialValueFor("bonus_stat")*2)) < 25 or math.ceil(hero:GetIntellect() - (numsaint:GetSpecialValueFor("bonus_stat")*2)) < 25 then 
                            return 
                        end
                    end
                end
                --GameRules:SendCustomMessageToTeam("#" .. hero:GetName() .."_enable_combo", hero:GetTeamNumber(), hero:GetPlayerOwnerID(),hero:GetPlayerOwnerID())
                CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "combo_declare", {hero = hero:GetName(), combo = hero.MasterUnit2:GetAbilityByIndex(5):GetAbilityName()})
                hero.MasterUnit2:FindAbilityByName(hero.MasterUnit2:GetAbilityByIndex(5):GetAbilityName()):EndCooldown()
                hero.EnableCombo = true
            end
        end
    end
end

function SaveStashState(hero)
    local stashState = {}
    local stashChargeState = {}
    for i=1, 6 do
        local item = hero:GetItemInSlot(i + 9)
        table.insert(stashState, i, item and item:GetName())
        table.insert(stashChargeState, i, item and item:GetCurrentCharges())
    end
    hero.stashState = stashState
    hero.stashChargeState = stashChargeState
end

function LoadStashState(hero)
    local stashState = hero.stashState or {}
    local stashChargeState = hero.stashChargeState or {}
    -- fill inventory with dummy items so AddItem adds to correct index
    for i=0,5 do
        local item = hero:GetItemInSlot(i)
        if item == nil then
            local dummyItem = CreateItem("item_dummy_item", nil, nil)
            hero:AddItem(dummyItem)
        end
    end
    for i=1,6 do
        local item = hero:GetItemInSlot(i + 10)
        hero:RemoveItem(item)

        local savedItemName = stashState[i]
        local newItem = CreateItem(savedItemName or "item_dummy_item", nil, nil)
        hero:AddItem(newItem)

        local charges = stashChargeState[i]
        if charges ~= nil then
            newItem:SetCurrentCharges(charges)
        end
    end
    -- clear dummy items
    for i=0,15 do
        local item = hero:GetItemInSlot(i)
        if item:GetName() == "item_dummy_item" then
            hero:RemoveItem(item)
        end
    end
end

function CheckDummyCollide(unit)
	local origin = unit:GetAbsOrigin()
	local targets = Entities:FindAllByNameWithin("npc_dota_creature", origin, 500)
	for k,v in pairs(targets) do
		if v:GetUnitName() == "ubw_sword_confine_dummy" and IsFacingUnit(unit, v, 180) and (origin - v:GetAbsOrigin()):Length2D() < 80 then
			return true
		end
	end
	return false
end

local substitutions = {
    -- colours
    ["_gray_"] = "",
    ["_silver_"] = "	",
    ["_default_"] = "",
    ["_yellow_"] = "",
    ["_gold_"] = "",
    ["_orange_"] = "",
    ["_lightred_"] = "",
    ["_red_"] = "",
    ["_magenta_"] = "",
    ["_pink_"] = "",
    ["_violet_"] = "",
    ["_purple_"] = "",
    ["_blue_"] = "",
    ["_darkgreen_"] = "",
    ["_olive_"] = "",
    ["_lightgreen_"] = "",
    ["_green_"] = "",

    --symbols
    ["_arrow_"] = "▶",
}

local heroNames = {
    ["npc_dota_hero_legion_commander"] = "Artoria Pendragon",
    ["npc_dota_hero_phantom_lancer"] = "Cu Chulain",
    ["npc_dota_hero_spectre"] = "Artoria Alter",
    ["npc_dota_hero_ember_spirit"] = "Emiya",
    ["npc_dota_hero_templar_assassin"] = "Medusa",
    ["npc_dota_hero_doom_bringer"] = "Heracles",
    ["npc_dota_hero_juggernaut"] = "Sasaki Kojiro",
    ["npc_dota_hero_bounty_hunter"] = "Hassan-i-Sabbah",
    ["npc_dota_hero_crystal_maiden"] = "Medea",
    ["npc_dota_hero_skywrath_mage"] = "Gilgamesh",
    ["npc_dota_hero_sven"] = "Lancelot",
    ["npc_dota_hero_vengefulspirit"] = "Angra Mainyu",
    ["npc_dota_hero_huskar"] = "Diarmuid",
    ["npc_dota_hero_chen"] = "Iskandar",
    ["npc_dota_hero_shadow_shaman"] = "Gilles de Rais",
    ["npc_dota_hero_lina"] = "Nero Claudius",
    ["npc_dota_hero_omniknight"] = "Gawain",
    ["npc_dota_hero_enchantress"] = "Tamamo no Mae",
    ["npc_dota_hero_bloodseeker"] = "Li Shuwen",
    ["npc_dota_hero_mirana"] = "Jeanne",
    ["npc_dota_hero_queenofpain"] = "Astolfo",
    ["npc_dota_hero_windrunner"] = "Nursery Rhyme",
    ["npc_dota_hero_drow_ranger"] = "Atalanta",
    ["npc_dota_hero_tidehunter"] = "Vlad III",
    ["npc_dota_hero_phantom_assassin"] = "Semiramis",
    ["npc_dota_hero_beastmaster"] = "Karna",
    ["npc_dota_hero_naga_siren"] = "Chloe von Einzbern",
    ["npc_dota_hero_riki"] = "Jack the Ripper",
    ["npc_dota_hero_dark_willow"] = "Okita Souji",
    ["npc_dota_hero_troll_warlord"] = "Francis Drake",
    ["npc_dota_hero_monkey_king"] = "Scathach",
    ["npc_dota_hero_tusk"] = "Mordred",
    ["npc_dota_hero_zuus"] = "Frankenstein",
    ["npc_dota_hero_axe"] = "Lu Bu",
    ["npc_dota_hero_death_prophet"] = "Elizabeth Bathory",
    ["npc_dota_hero_enigma"] = "Amakusa Shirou",
    ["npc_dota_hero_night_stalker"] = "Edmond Dante",
    ["npc_dota_hero_disruptor"] = "Zhuge Liang",
    ["npc_dota_hero_skeleton_king"] = "King Hassan",
    ["npc_dota_hero_necrolyte"] = "Hans Christian Andersen",
    ["npc_dota_hero_sniper"] = "Robin Hood",
    ["npc_dota_hero_gyrocopter"] = "Nobunaga",
    ["npc_dota_hero_dragon_knight"] = "Mash Kyrielight",
    ["npc_dota_hero_antimage"] = "Miyamoto Musashi",
    ["npc_dota_hero_oracle"] = "Ishtar",
    ["npc_dota_hero_ursa"] = "Atalanta Alter",
    ["npc_dota_hero_kunkka"] = "Muramasa",
    ["npc_dota_hero_void_spirit"] = "Kiyohime",
    ["npc_dota_hero_nyx_assassin"] = "Melt",
}


function SubstituteMessageCodes(message)
    for k,v in pairs(substitutions) do
        message = string.gsub(message, k , v)
    end
    for k,v in pairs(heroNames) do
        message = string.gsub(message, k , v)
    end
    return message
end

function FindName(name)
    return heroNames[name] or "Undefined"
end

local heroCombos = {
    ["npc_dota_hero_legion_commander"] = "saber_max_excalibur",
    ["npc_dota_hero_phantom_lancer"] = "lancer_5th_wesen_gae_bolg",
    ["npc_dota_hero_spectre"] = "saber_alter_max_mana_burst",
    ["npc_dota_hero_ember_spirit"] = "archer_5th_arrow_rain",
    ["npc_dota_hero_templar_assassin"] = "rider_5th_bellerophon_2",
    ["npc_dota_hero_doom_bringer"] = "berserker_5th_madmans_roar",
    ["npc_dota_hero_juggernaut"] = "false_assassin_hiken_enbu",
    ["npc_dota_hero_bounty_hunter"] = "true_assassin_combo",
    ["npc_dota_hero_crystal_maiden"] = "medea_hecatic_graea_combo",
    ["npc_dota_hero_skywrath_mage"] = "gilgamesh_max_enuma_elish",
    ["npc_dota_hero_sven"] = "lancelot_nuke",
    ["npc_dota_hero_vengefulspirit"] = "avenger_endless_loop",
    ["npc_dota_hero_huskar"] = "diarmuid_rampant_warrior",
    ["npc_dota_hero_chen"] = "iskander_annihilate",
    ["npc_dota_hero_shadow_shaman"] = "gille_larret_de_mort",
    ["npc_dota_hero_lina"] = "nero_laus_saint_claudius",
    ["npc_dota_hero_omniknight"] = "gawain_supernova",
    ["npc_dota_hero_enchantress"] = "tamamo_polygamist_castration_fist",
    ["npc_dota_hero_bloodseeker"] = "lishuwen_raging_dragon_strike",
    ["npc_dota_hero_mirana"] = "jeanne_combo_la_pucelle",
    ["npc_dota_hero_queenofpain"] = "astolfo_hippogriff_ride",
    ["npc_dota_hero_windrunner"] = "nursery_rhyme_story_for_somebodys_sake",
    ["npc_dota_hero_drow_ranger"] = "atalanta_phoebus_catastrophe_barrage",
    ["npc_dota_hero_tidehunter"] = "vlad_combo",
    ["npc_dota_hero_phantom_assassin"] = "semiramis_combo",
    ["npc_dota_hero_beastmaster"] = "karna_combo_vasavi",
    ["npc_dota_hero_naga_siren"] = "kuro_crane_wings_combo",
    ["npc_dota_hero_riki"] = "jtr_whitechapel_murderer",
    ["npc_dota_hero_dark_willow"] = "okita_zekken",
    ["npc_dota_hero_troll_warlord"] = "drake_combo_golden_wild_hunt",
    ["npc_dota_hero_monkey_king"] = "scathach_combo_gate_of_sky",
}

function GetAbility(caster, ability_name)
    local ability 

    for i = 0,24 do
        local a = caster:GetAbilityByIndex(i)
        if a ~= nil then
            if string.match(a:GetAbilityName(), ability_name) then 
                ability = a 
                return ability
            end
        end
    end
    return nil
end

function GetHeroCombo(hero)
    local name = hero:GetName()
    return heroCombos[name] or ""
end

-- returns -1 if combo is not available
-- returns 0 if combo is available and ready
-- otherwise returns cooldown remaning on combo
function GetComboAvailability(hero)
    local heroName = hero:GetName()
    if heroName == "npc_dota_hero_juggernaut" then
        if hero:GetStrength() < 24.1 or hero:GetAgility() < 24.1 then
            return -1
        end
    else
        local statreq = 19.1
        if heroName == "npc_dota_hero_sven" then
            local ability = hero:FindAbilityByName("lancelot_arondite")
            if hero:HasModifier("modifier_arondite") then
                statreq = statreq + ability:GetLevelSpecialValueFor("bonus_allstat", ability:GetLevel() - 1)
            end
        end
        if hero:GetStrength() < statreq
            or hero:GetAgility() < statreq
            or hero:GetIntellect() < statreq
        then
            return -1
        end
    end
    local comboName = GetHeroCombo(hero)
    if comboName == "" then
        return -1
    end
    local combo = hero:FindAbilityByName(comboName)
    if combo == nil then
        return -1
    end
    return combo:GetCooldownTimeRemaining()
end

--Function records EMPIRICAL damage and also PRE-REDUCTION right click damage, PRE-REDUCTION skill damage is handled at line 906 to 910.
function OnHeroTakeDamage(keys)
    local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
    local attacker = keys.attacker
    local damageTaken = keys.DamageTaken

    if attacker == nil or hero == nil then return end

    if attacker == hero then return end

    if not attacker:IsHero() and not attacker.TempestDouble then --Account neutral attackers
        if IsValidEntity(attacker:GetPlayerOwner()) then
            attackerHero = attacker:GetPlayerOwner():GetAssignedHero()
        elseif attacker:GetUnitName() == "okita_shinsengumi" then 
            attackerHero = attacker:GetOwner()
        end
    elseif attacker.TempestDouble then
        attackerHero = attacker.NurseryRhyme
    else
        attackerHero = attacker
    end

    if attackerHero == nil then return end

    if GetMapName() == "fate_tutorial" then 
    else
        if attacker:GetAttackTarget() == hero then
            --print("Right click before armor reductions", damageTaken * 1/(1-GetPhysicalDamageReduction(hero:GetPhysicalArmorValue(false))))
            attackerHero.ServStat:doDamageBeforeReduction(damageTaken * 1/(1-GetPhysicalDamageReduction(hero:GetPhysicalArmorValue(false))))
            hero.ServStat:takeDamageBeforeReduction(damageTaken * 1/(1-GetPhysicalDamageReduction(hero:GetPhysicalArmorValue(false))))
        end
        --print("Actual damage from KV:", damageTaken)
        attackerHero.ServStat:doActualDamage(math.min(damageTaken,hero:GetMaxHealth()))
        hero.ServStat:takeActualDamage(math.min(damageTaken,hero:GetMaxHealth()))
    end
end

function CCTime(keys)
    local hero = keys.caster
    hero.ServStat:doControl(0.1)
end

function FxDestroyer(PIndex,instant)
  if PIndex ~= nil and type(PIndex) == "table" then
    --PrintTable(PIndex)
    for i,j in pairs(PIndex) do
      --print("destroy",PIndex[i])
      ParticleManager:DestroyParticle(PIndex[i], instant)
      ParticleManager:ReleaseParticleIndex(PIndex[i])
    end
    PIndex = nil
    return PIndex
  elseif PIndex ~= nil then
    --print("destroy1",PIndex)
    ParticleManager:DestroyParticle(PIndex, instant)
    ParticleManager:ReleaseParticleIndex(PIndex)
    PIndex = nil
    return PIndex
  end
end

function FxCreator(effectname,pattach,target,cp,attach,amount)
  if amount ~= nil then
    local FXIndex = {}
    for i=amount,1,-1 do
      FXIndex[i] = ParticleManager:CreateParticle(effectname,pattach,target)
      ParticleManager:SetParticleControlEnt(FXIndex[i],cp,target,pattach,attach,target:GetAbsOrigin(),false)
      --print("create            ",FXIndex[i])
    end
    return FXIndex
  else         
    local FXIndex = ParticleManager:CreateParticle(effectname,pattach,target)
    ParticleManager:SetParticleControlEnt(FXIndex,cp,target,pattach,attach,target:GetAbsOrigin(),false)
    --print("create                ", FXIndex)
    return FXIndex
  end
end


function WrapAttributes(ability, attributeName, callback)
    function ability:OnSpellStart()
        local caster = self:GetCaster()
        local player = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()

        hero[attributeName] = true

        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - self:GetManaCost(1))

        if callback then
            callback(self, hero)
        end
    end
end

-- Spaghetti and hax as fuck.
function HotkeyPurchaseItem(iSource, args)
    print('quickbuy')
    local item = args['item']
    local cost = GetItemCost(item)
    local entity = EntIndexToHScript(iSource)
    local id = entity:GetPlayerID()
    local hero = entity:GetAssignedHero()

    if not hero or hero:GetUnitName() == "npc_dota_hero_wisp" then return end

    local mode = GameRules.AddonTemplate
    local gold = hero:GetGold()
    local keys = {
        PlayerID = id,
        itemname = item,
        itemcost = cost,
        hotkey = true
    }

    local hItem = nil

    local target = nil
    for j = 10, 15 do
        if hero:GetItemInSlot(j) == nil then target = j break end
    end
    if not target then return end

    local purchase = function()
        hItem = hero:AddItemByName(item)
        hero:SetGold(0, false)
        hero:SpendGold(cost, 4)
        mode:OnItemPurchased(keys)
    end

    if hero.IsInBase and gold >= cost then
        purchase()
    elseif gold >= cost * 1.5 then
        purchase()
    else
        return
    end

    local index = nil
    for i = 0, 5 do
        if hero:GetItemInSlot(i) == hItem then index = i break end
    end

    if index ~= nil and target ~= nil then
        hero:SwapItems(index, target)
    end
end


function SpawnDummy(hCaster,vOrigin,vFacing)
  local hDummy = CreateUnitByName("visible_dummy_unit", vOrigin or hCaster:GetAbsOrigin(), false, hCaster, hCaster, hCaster:GetTeamNumber())
  hDummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  hDummy:SetDayTimeVisionRange(0)
  hDummy:SetNightTimeVisionRange(0)
  hDummy:SetAbsOrigin(vOrigin or hCaster:GetAbsOrigin())
  hDummy:SetForwardVector(vFacing or hCaster:GetForwardVector())
  return hDummy
end

--atr1's way to fix shooting arrows backward
function ForwardVForPointGround(hCaster,vTarget)
  local vOrigin = hCaster:GetAbsOrigin()
  local vDisplacement, vFacing = vTarget - vOrigin
  if math.abs(vDisplacement.x) < 0.05 then
    vDisplacement.x = 0
  end
  if math.abs(vDisplacement.y) < 0.05 then
    vDisplacement.y = 0
  end
  vDisplacement.z = 0
  if vDisplacement == Vector(0, 0, 0) then
    vFacing = hCaster:GetForwardVector()
  else
    vFacing = vDisplacement:Normalized()
  end  
  return vFacing
end

function UpdateAbilityLayout(hHero, tAbilities)
    local tAbilities = tAbilities or hHero.AbilityLayout
    for i = 1, hHero:GetAbilityCount() do
        if hHero:GetAbilityByIndex(i - 1) == nil then
        elseif i > #tAbilities then
            hHero:GetAbilityByIndex(i - 1):SetHidden(true)
        elseif hHero:GetAbilityByIndex(i - 1):GetAbilityName() ~= tAbilities[i] then
            hHero:SwapAbilities(hHero:GetAbilityByIndex(i - 1):GetAbilityName(), tAbilities[i], true, true)
        end
    end
end

function CanBeDetected(hHero)
    for i=1, #tCannotDetect do
        if hHero:GetName() == tCannotDetect[i] then
            return false
        end
    end
    
    return true
end

function RemoveDebuffsForRevival(hTarget)
    for i=1, #tDangerousBuffs do
        print(tDangerousBuffs[i])
        hTarget:RemoveModifierByName(tDangerousBuffs[i])
    end
end

function IsBeam(ability)
    for i = 1, #tBeamAbilities do
        if ability:GetAbilityName() == tBeamAbilities[i] then
            return true
        end
    end
    
    return false
end

function IsSpellBook(abilityname)
    for i = 1, #tSpellBook do 
        if abilityname == tSpellBook[i] then
            return true
        end
    end
    
    return false
end

function HasSpellBook(hTarget)
    for i = 1, #tSpellBookHero do
        if hTarget:GetName() == tSpellBookHero[i] then
            return true
        end
    end
    
    return false
end

function GenerateAbilitiesData(hTarget)
    hTarget.QSkill = hTarget:GetAbilityByIndex(0):GetAbilityName()
    hTarget.WSkill = hTarget:GetAbilityByIndex(1):GetAbilityName()
    hTarget.ESkill = hTarget:GetAbilityByIndex(2):GetAbilityName()
    hTarget.DSkill = hTarget:GetAbilityByIndex(3):GetAbilityName()
    hTarget.FSkill = hTarget:GetAbilityByIndex(4):GetAbilityName()
    hTarget.RSkill = hTarget:GetAbilityByIndex(5):GetAbilityName()
    hTarget.ComboSkill = GetUnitKV(hTarget:GetUnitName(), "Combo")
end

function IsKnockbackImmune(hTarget)
    for i=1, #tModifierKBImmune do
        if hTarget:HasModifier(tModifierKBImmune[i]) then
            return true
        end
    end
    if hTarget:GetUnitName() == "okita_flag" then return true end
    return false
end

function IsManaLess(hTarget)
    for i = 1, #tManalessHero do
        if hTarget:GetName() == tManalessHero[i] then
            return true
        end
    end
    
    return false
end

function IsTrueInvis(hTarget)
    for i = 1, #tTrueInvis do
        if hTarget:HasModifier(tTrueInvis[i]) then
            return true
        end
    end
    
    return false
end

function IsInvulAbility(hTarget)
    for i = 1, #invulabil do
        if hTarget:HasModifier(invulabil[i]) then
            return true
        end
    end
    
    return false
end

function RemoveInVis(hTarget)
    for i = 1, #invis do
        hTarget:RemoveModifierByName(invis[i])
    end
end

function IsUnExecute(hTarget)
    for i = 1, #tUnExecute do
        if hTarget:HasModifier(tUnExecute[i]) then
            return true
        end
    end
    
    return false
end

function IsReviveSeal(hTarget)
    for i = 1, #tExecuteSeal do
        if hTarget:HasModifier(tExecuteSeal[i]) then
            return true
        end
    end
    
    return false

end

function RemoveComboCD(hTarget)
    for i = 1, #tModifierCooldown do
        if hTarget:HasModifier(tModifierCooldown[i]) then
            hTarget:RemoveModifierByName(tModifierCooldown[i])
        end
    end
end

function IsArthur(hTarget)
    for i = 1, #tArthurHeroes do
        if hTarget:GetName() == tArthurHeroes[i] then
            return true
        end
    end
    
    return false
end

function DoNotMute(hTarget)
    for i = 1, #donotmute do
        if hTarget:GetUnitName() == donotmute[i] then
            return true
        end
    end
    
    return false
end

function IsAoTKSoldier(hTarget)
    for i = 1, #tSoldierAoTK do
        if hTarget:GetUnitName() == tSoldierAoTK[i] then
            return true
        end
    end
    
    return false
end

function IsHuman(hTarget)
    for i = 1, #tLivingHumanHeroes do
        if hTarget:GetName() == tLivingHumanHeroes[i] then
            return true
        end
    end
    
    return false
end

function IsDragon(hTarget)
    for i = 1, #tDragonHeroes do
        if hTarget:GetUnitName() == tDragonHeroes[i] then
            return true
        end
    end
    
    return false
end

function IsVampire(hTarget)
    for i = 1, #tVampireHeroes do
        if hTarget:GetUnitName() == tVampireHeroes[i] then
            return true
        end
    end
    
    return false
end

function IsShinsengumi(hTarget)
    for i = 1, #tShinsengumi do
        if hTarget:GetUnitName() == tShinsengumi[i] then
            return true
        end
    end
    
    return false
end

function IsArrowAbility(ability)
    for i = 1, #tArrow do
        if ability:GetAbilityName() == tArrow[i] then
            return true
        end
    end
    
    return false
end

function IsPoisonAbility(ability)
    for i = 1, #tPoison do
        if ability:GetAbilityName() == tPoison[i] then
            return true
        end
    end
    
    return false
end

function IsWindProtect(target)
    for i = 1, #tWindImmune do 
        if target:HasModifier(tWindImmune[i]) then 
            return true 
        end
    end 

    return false 
end

function IsPoisonImmune(target)
    for i = 1, #tPoisonImmune do 
        if target:HasModifier(tPoisonImmune[i]) then 
            return true 
        end
    end 

    return false 
end

function IsProjectileParry(target)
    for i = 1, #tProjectileParry do 
        if target:HasModifier(tProjectileParry[i]) then 
            return true 
        end
    end 

    return false 
end

function IsLightningResist(target)
    for i = 1, #tLightningResist do
        if target:HasModifier(tLightningResist[i]) then
            return true
        end
    end
    
    return false
end

function IsMountedHero(hTarget)
    for i = 1, #tMount do
        if hTarget:HasModifier(tMount[i]) then
            return true
        end
    end
    
    return false
end

function IsDivineServant(hTarget)
    if not hTarget:IsHero() then return false end

    for i = 1, #tDivineHeroes do
        if hTarget:GetName() == tDivineHeroes[i] then
            return true
        end
    end

    if hTarget:HasModifier("modifier_nobu_divinity_mark_activated") then 
        return true 
    end

    return false
end

function CheckDivine(hTargetName) 
    for i=1, #tDivineHeroes do
        if hTargetName == tDivineHeroes[i] then
            return true
        end
    end
    
    return false
end

function CheckDivinity (hTarget)
    if hTarget:GetName() == "npc_dota_hero_chen" or hTarget:GetName() == "npc_dota_hero_phantom_assassin" or hTarget:GetName() == "npc_dota_hero_enchantress" or hTarget:GetName() == "npc_dota_hero_templar_assassin" or hTarget:GetName() == "npc_dota_hero_skywrath_mage" or hTarget:GetName() == "npc_dota_hero_phantom_lancer" then 
        return 1
    elseif hTarget:GetName() == "npc_dota_hero_doom_bringer" or hTarget:GetName() == "npc_dota_hero_beastmaster" then 
        return 2
    end
end

function RemoveTroublesomeModifiers(hTarget)
    for i = 1, #tRemoveTheseModifiers do
        hTarget:RemoveModifierByName(tRemoveTheseModifiers[i])
    end
end

function CheckSex(hTargetName) 
    for i=1, #femaleservant do
        if hTargetName == femaleservant[i] then
            return "Female"
        end
    end
    
    return "Male"
end


function CheckClass(hTargetName)
    for k,v in pairs(tClass) do 
        for i = 1, #v do 
            if hTargetName == v[i] then 
                return k 
            end
        end
    end

    return "Undefined"
end

function IsKnightClass(hTarget)
    if not hTarget:IsHero() then return false end

    if CheckClass(hTarget:GetName()) == {"Saber" or "Archer" or "Lancer"} then 
        return true 
    end

    --[[for i = 1, #tSaberClass do
        if hTarget:GetName() == tSaberClass[i] then
            return true
        end
    end]]

    return false
end

function IsHorsemanClass(hTarget)
    if not hTarget:IsHero() then return false end

    if CheckClass(hTarget:GetName()) == {"Caster" or "Assassin" or "Berserker" or "Rider"} then 
        return true 
    end

    --[[for i = 1, #tHorsemanClass do
        if hTarget:GetName() == tHorsemanClass[i] then
            return true
        end
    end]]

    return false
end

function NotifyManaAndShard(hero)
    if GetMapName() == "fate_tutorial" or hero.MasterUnit2 == nil or hero == nil then return end

    local playerId = hero:GetPlayerOwnerID()
    local player = hero:GetPlayerOwner()

    if player.bNotifyMasterManaDisabled == nil then 
        player.bNotifyMasterManaDisabled = false 
    end

    if player.bNotifyMasterManaDisabled == false then 
        if hero.MasterUnit2:GetMana() >= 15 and hero.MasterUnit:GetMana() >= 15 then 
            CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_notify_master_mana", {playerId = playerId} )
        end
    end
end

function PickRandomEnemy(hHero)
    local enemy

    for i=0, 13 do
        local playerID = i
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)

        if playerHero then        
            if playerHero:GetTeamNumber() ~= hHero:GetTeamNumber() and playerHero:IsAlive() then
                enemy = playerHero
                break
            end
        else
            break
        end
    end

    return enemy
end

function PotatoHelping()
    if not IsPaused() then 
        PauseGame(true)
        Timers:CreateTimer(10, function()
            if IsPaused() then
                PauseGame(false)
            end
        end)
    end
end

LinkLuaModifier("modifier_winner_inertia", "abilities/general/modifiers/modifier_winner_inertia", LUA_MODIFIER_MOTION_NONE)

function AddInertiaModifier(hHero)
    hHero:AddNewModifier(hHero, nil, "modifier_winner_inertia", { Duration = 17 })
end