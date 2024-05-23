LinkLuaModifier("modifier_charges", "modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_tiger_strike_tracker", "abilities/lishuwen/modifiers/modifier_tiger_strike_tracker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vortigern_ferocity", "abilities/arturia_alter/modifiers/modifier_vortigern_ferocity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_a_scroll_sated", "items/modifiers/modifier_a_scroll_sated.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vision_provider", "abilities/general/modifiers/modifier_vision_provider", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_resonator_cooldown", "abilities/general/modifiers/modifier_resonator_cooldown", LUA_MODIFIER_MOTION_NONE)

ServantAttribute = LoadKeyValues("scripts/npc/servant_attribute.txt")

SaberAttribute = {
	"saber_attribute_improve_excalibur",
	"saber_attribute_improve_instinct",
	"saber_attribute_strike_air",
	"saber_attribute_everdistant_utopia",
	"saber_attribute_chivalry",
	"saber_max_excalibur",
	attrCount = 5
}

LancerAttribute = {
	"lancer_attribute_improve_battle_continuation",
	"lancer_attribute_protection_from_arrows",
	"lancer_attribute_death_flight",
	"lancer_attribute_the_heartseeker",
	"lancer_attribute_celtic_runes",
	"lancer_wesen_gae_bolg",
	attrCount = 5
}

SaberAlterAttribute = {
	"saber_alter_attribute_mana_shroud",
	"saber_alter_attribute_mana_blast",
	"saber_alter_attribute_improve_ferocity",
	"saber_alter_attribute_ultimate_darklight",
	"saber_alter_max_mana_burst",
	attrCount = 4
}

ArcherAttribute = {
	"archer_attribute_eagle_eye",
	"archer_attribute_overedge",
	"archer_attribute_shroud_of_martin",
	"archer_attribute_improve_projection",
	"archer_attribute_hrunting",
	"archer_arrow_rain",
	attrCount = 5
}

RiderAttribute = {
	"medusa_attribute_improve_mystic_eyes",
	"medusa_attribute_riding",
	"medusa_attribute_seal",
	"medusa_attribute_monstrous_strength",
	"medusa_bellerophon_2",
	attrCount = 4
}

BerserkerAttribute = {
	"heracles_attribute_eternal_rage",
	"heracles_attribute_god_hand",
	"heracles_attribute_reincarnation",
	"heracles_attribute_mad_enhancement",
	"heracles_madmans_roar",
	attrCount = 4
}

FAAttribute = {
	"sasaki_attribute_ganryu",
	"sasaki_attribute_katana_of_the_forgotten",
	"sasaki_attribute_vitrification",
	"sasaki_attribute_improve_minds_eye",
	--"sasaki_attribute_presence_concealment",
	"sasaki_hiken_enbu",
	attrCount = 4
}

TAAttribute = {
	"hassan_attribute_improve_presence_concealment",
	"hassan_attribute_protection_from_wind",
	"hassan_attribute_weakening_venom",
	"hassan_attribute_shadow_strike",
	"hassan_attribute_shaytan_arm",
	"hassan_combo",
	attrCount = 5
}

GilgaAttribute = {
	"gilgamesh_attribute_improve_golden_rule",
	"gilgamesh_attribute_power_of_sumer",
	"gilgamesh_attribute_rain_of_swords",
	"gilgamesh_attribute_sword_of_creation",
	"gilgamesh_max_enuma_elish",
	attrCount = 4
}

CasterAttribute = {
	"medea_attribute_improve_territory_creation",
	"medea_attribute_improve_argos",
	"medea_attribute_witchcraft",
	"medea_attribute_dagger_of_treachery",
	"medea_hecatic_graea_powered",
	attrCount = 4
}

LancelotAttribute = {
	"lancelot_attribute_improve_eternal",
	"lancelot_attribute_blessing_of_fairy",
	"lancelot_attribute_improve_knight_of_owner",	
	"lancelot_attribute_knight_of_owner_arsenal",
	"lancelot_attribute_kotl",
	"lancelot_nuke",
	attrCount = 5
}

AvengerAttribute = {
	"avenger_attribute_improve_dark_passage",
	"avenger_attribute_demon_incarnate",
	"avenger_attribute_end_of_four_nights",
	"avenger_attribute_world_evil",
	"avenger_attribute_avenger",
	"avenger_combo_endless_loop",
	attrCount = 5
}

DiarmuidAttribute = {
	"diarmuid_attribute_improve_love_spot",
	"diarmuid_attribute_improve_minds_eye",
	"diarmuid_attribute_golden_rose_of_mortality",
	"diarmuid_attribute_crimson_rose_of_exorcism",
	"diarmuid_attribute_double_spear_strike",
	"diarmuid_rampant_warrior",
	attrCount = 5
}

IskanderAttribute = {
	"iskandar_attribute_improve_charisma",
	"iskandar_attribute_thundergods_wrath",
	"iskandar_attribute_via_expugnatio",
	"iskandar_attribute_bond_beyond_time",
	"iskandar_annihilate",
	attrCount = 4
}

GillesAttribute = {
	"gilles_eye_for_art_attribute",
	"gilles_outer_god_attribute",
	"gilles_demonic_horde_attribute",
	"gilles_sunken_city_attribute",
	"gilles_abyssal_connection_attribute",
	"gille_larret_de_mort",
	attrCount = 5
}

NeroAttribute = {
	"nero_attribute_pari_tenu_blauserum",
	"nero_attribute_improve_imperial_privilege",
	"nero_attribute_invictus_spiritus",
	"nero_attribute_soverigns_glory",
	"nero_attribute_aestus_estus",
	"nero_laus_saint_claudius",	
	attrCount = 5
}

GawainAttribute = {
	"gawain_attribute_blessing_of_fairy",
	"gawain_attribute_nightless_charisma",
	"gawain_attribute_numeral_saint",
	"gawain_attribute_belt",
	"gawain_attribute_kots",
	"gawain_combo_excalibur_galatine",
	attrCount = 5
}

TamamoAttribute = {
	"tamamo_attribute_spirit_theft",
	"tamamo_attribute_mystic_shackle",
	"tamamo_attribute_polygamist",
	"tamamo_attribute_witchcraft",
	"tamamo_attribute_territory",
	"tamamo_combo",
	attrCount = 5
}

LiAttribute = {
	"lishuwen_attribute_circulatory_shock",
	"lishuwen_attribute_improve_martial_arts",
	"lishuwen_attribute_dual_class",
	"lishuwen_attribute_furious_chain",
	"lishuwen_raging_dragon_strike",
	attrCount = 4
}

JeanneAttribute = {
	"jeanne_attribute_identity_discernment",
	"jeanne_attribute_improve_saint",
	"jeanne_attribute_punishment",
	"jeanne_attribute_divine_symbol",
	"jeanne_attribute_revelation",
	"jeanne_la_pucelle",
	attrCount = 5
}

AstolfoAttribute = {
	"astolfo_attribute_riding",
	"astolfo_attribute_monstrous_strength",
	"astolfo_attribute_independent_action",
	"astolfo_attribute_sanity",
	"astolfo_attribute_deafening_blast",
	"astolfo_hippogriff_ride",
	attrCount = 5
}

NRAttribute = {
	"nursery_rhyme_attribute_forever_together",
	"nursery_rhyme_attribute_nightmare",
	"nursery_rhyme_attribute_reminiscence",
	"nursery_rhyme_attribute_improve_queens_glass_game",
	"nursery_rhyme_story_for_somebodys_sake",
	attrCount = 4
}
AtalantaAttribute = {
	"atalanta_attribute_arrows_of_the_big_dipper",
	"atalanta_attribute_hunters_mark",
	"atalanta_attribute_crossing_arcadia_plus",
	"atalanta_attribute_calydonian_snipe",
	"atalanta_phoebus_catastrophe_snipe",
	attrCount = 4
}
VladAttribute = {
	"vlad_attribute_innocent_monster",
	"vlad_attribute_protection_of_faith",
	"vlad_attribute_improved_impaling",
	"vlad_attribute_instant_curse",
	"vlad_attribute_bloodletter",
	"vlad_combo",
	attrCount = 5
}

SemiramisAttribute = {
	"semiramis_attribute_dual_class",
	"semiramis_attribute_territory",
	"semiramis_attribute_absolute",
	"semiramis_attribute_charmer",
	"semiramis_attribute_poisoner",
	"semiramis_combo",
	attrCount = 5	
}

KarnaAttribute = {
	"karna_attribute_poor",
	"karna_attribute_ucm",
	"karna_attribute_mana_burst",
	--"karna_divinity_attribute",
	"karna_attribute_indra",
	"karna_combo_vasavi",
	attrCount = 4
}

KuroAttribute = {
	"kuro_attribute_overedge",
	"kuro_attribute_improve_projection",
	"kuro_attribute_kuro_magic",
	"kuro_attribute_eagle_eye",
	"kuro_attribute_hrunting",
	"kuro_fake_ubw",
	attrCount = 5
}

JTRAttribute = {
	"jtr_attribute_information_erase",
	"jtr_attribute_mental_pollution",
	"jtr_attribute_soul_eater",
	"jtr_attribute_murderer_on_misty_night",
	"jtr_attribute_holy_mother",
	"jtr_whitechapel",
	attrCount = 5
}

OkitaAttribute = {
	"okita_attribute_kyokuji",
	"okita_attribute_persistence",
	"okita_attribute_peerless",
	"okita_attribute_mind_eye",
	"okita_attribute_kiku_ichimonji",
	"okita_zekken",
	attrCount = 5
}

DrakeAttribute = {
	"drake_attribute_improve_military_tactic",
	"drake_attribute_pioneer",
	"drake_attribute_logbook",
	"drake_attribute_strengthen_golden_hind",
	"drake_combo_golden_wild_hunt",
	attrCount = 4
}

ScathachAttribute = {
	"scathach_attribute_primeval_rune",
	"scathach_attribute_god_slayer",
	"scathach_attribute_branch_tonelico",
	"scathach_attribute_wisdom_of_haunt_ground",
	"scathach_attribute_immortal",
	"scathach_combo_gate_of_sky",
	attrCount = 5
}

MordredAttribute = {
	"mordred_attribute_curse",
	"mordred_attribute_bc",
	"mordred_attribute_rampage",
	"mordred_attribute_pedigree",
	"mordred_attribute_overload",
	"mordred_mmb_lightning",
	attrCount = 5
}

FranAttribute = {
	"fran_attribute_bridal_chest",
	"fran_attribute_mad_enhancement",
	"fran_attribute_overload",
	"fran_attribute_lament",
	"fran_attribute_improve_galvanism",
	"fran_combo_blasted_tree",
	attrCount = 5
}

LubuAttribute = {
	"lubu_attribute_houtengageki",
	"lubu_attribute_mad_enhancement",
	"lubu_attribute_dragon_tongue",
	"lubu_attribute_ruthless_warrior",
	"lubu_attribute_immortal",
	"lubu_combo_god_force",
	attrCount = 5
}

BathoryAttribute = {
	"bathory_attribute_territory",
	"bathory_attribute_dragon_breath",
	"bathory_attribute_mental",
	"bathory_attribute_sadism_charisma",
	"bathory_attribute_torture",
	"bathory_combo_fresh_blood",
	attrCount = 5
}

AmakusaAttribute = {
	"amakusa_attribute_left_hand",
	"amakusa_attribute_identify",
	"amakusa_attribute_church",
	"amakusa_attribute_anti_ruler",
	"amakusa_twin_arm",
	attrCount = 4
}

EdmondAttribute = {
	"edmond_attribute_avenger",
	"edmond_attribute_determination",
	"edmond_attribute_wisdom",
	"edmond_attribute_esperer",
	"edmond_attribute_improve_monte",
	"edmond_chateau",
	attrCount = 5
}

KongMingAttribute = {
	"zhuge_liang_attribute_territory",
	"zhuge_liang_attribute_alchemist",
	"zhuge_liang_attribute_stratagems",
	"zhuge_liang_attribute_letter",
	"zhuge_liang_attribute_discern_eye",
	"zhuge_liang_combo",
	attrCount = 5
}

KingHassanAttribute = {
	"kinghassan_attribute_oldman",
	"kinghassan_attribute_presence",
	"kinghassan_attribute_abyss",
	"kinghassan_attribute_boundary",
	"kinghassan_attribute_body",
	"kinghassan_combo",
	attrCount = 5
}

HansAttribute = {
	"hans_attribute_territory",
	"hans_attribute_write_thumbelina",
	"hans_attribute_human_observation",
	"hans_attribute_refine_nightingale",
	"hans_attribute_love_letter",
	"hans_combo",
	attrCount = 5
}

RobinAttribute = {
	"robin_attribute_subversive",
	"robin_attribute_faceless",
	"robin_attribute_righteous_thief",
	"robin_attribute_taxine",
	"robin_attribute_guerilla",
	"robin_combo",
	attrCount = 5
}
NobuAttribute = {
	"nobu_strategy_attribute",
	"nobu_expanding_attribute",
	"nobu_3000_attribute",
	"nobu_unifying_attribute",
	"nobu_independent_action",
	"nobu_combo",
	attrCount = 5
}
SaitoAttribute = {
	"saito_attribute_freedom",
	"saito_attribute_sword",
	"saito_attribute_memoir",
	"saito_attribute_freestyle",
	"saito_attribute_kunishige",
	"saito_style",
	attrCount = 5
}
MusashiAttribute = 
{
	"musashi_attributes_battle_continuation",
	"musashi_attributes_improve_tengan",
	"musashi_attributes_gorin_no_sho",
	"musashi_attributes_mukyuu",
	"musashi_attributes_niten_ichiryuu",
	"musashi_ishana_daitenshou",
	attrCount = 5
}
MashuAttribute = {
	"mashu_attribute_barrel",
	"mashu_attribute_shield",
	"mashu_attribute_chalk",
	"mashu_attribute_amalgam",
	"mashu_combo",
	attrCount = 4
}
IshtarAttribute = {
	"ishtar_attribute_offering",
	"ishtar_attribute_gems",
	"ishtar_attribute_goddess",
	"ishtar_attribute_venus",
	"ishtar_combo",
	attrCount = 4
}

AtlantaAlterAttribute = {
	"atalanta_evolution_attribute",
	"atalanta_tornado_attribute",
	"atalanta_vision_attribute",
	"atalanta_moon_attribute",
	"atalanta_skia",
	attrCount = 4
}

MuramasaAttribute = {
	"muramasa_pride",
	"muramasa_tameshi_mono",
	"muramasa_karmic_vision",
	"muramasa_blaze",
	"muramasa_combo",
	attrCount = 4
}

KiyohimeAttribute = {
	"kiyo_sa_1",
	"kiyo_sa_2",
	"kiyo_sa_3",
	"kiyo_sa_4",
	"kiyo_combo",
	attrCount = 4
}

ChargeBasedBuffs = {
	"modifier_tiger_strike_tracker",
	"modifier_vortigern_ferocity",
	--"modifier_a_scroll_sated",
	"modifier_doublespear_buidhe",
	"modifier_doublespear_dearg",
	"modifier_quickdraw_cooldown"
}
 
ChargeBuffReset = {
	saber_alter_vortigern_upgrade = 3,
	hassan_dirk = 4,
	hassan_dirk_upgrade = 7,
	nobu_dash = 3,
	nobu_dash_upgrade = 3,
	atalanta_celestial_arrow = 5,
	atalanta_celestial_arrow_upgrade = 5,
	diarmuid_warriors_charge_upgrade = 2,
}


function OnSeal1Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")

	if caster:GetHealth() == 1 then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel())) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Master_Not_Enough_Health")
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel())) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
		return
	end

	if hero:GetName() == "npc_dota_hero_doom_bringer" and RandomInt(1, 100) <= 35 then
		EmitGlobalSound("Shiro_Onegai")
	end

	hero.ServStat:useQSeal()

	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - ability:GetManaCost(ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth() - 1) 

	-- Particle
	hero:EmitSound("Misc.CmdSeal")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_ancestral_spirit_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, hero:GetAbsOrigin())


	keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_1",{})
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_command_seal_1",{})
	caster.IsFirstSeal = true

	if hero:HasModifier("modifier_command_seal_5") then 
		hero:RemoveModifierByName("modifier_command_seal_5")
	end
	caster:FindAbilityByName("cmd_seal_5"):EndCooldown()

	caster:FindAbilityByName("cmd_seal_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	Timers:CreateTimer({
		endTime = duration,
		callback = function()
		caster.IsFirstSeal = false
	end
	})
end

function ResetCharge(ability)
	if ChargeBuffReset[ability:GetAbilityName()] then 
		ability:SetCurrentAbilityCharges(ChargeBuffReset[ability:GetAbilityName()])
	end
end

function ResetAbilities(hero)
	-- Reset all resetable abilities
	RemoveChargeModifiers(hero)
	for i=0, 26 do 
		local ability = hero:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability.IsResetable ~= false then
				ResetCharge(ability)
				ability:EndCooldown()
			end
		end
	end
end

function ResetItems(hero)
	-- Reset all items
	for i=0, 14 do
		local item = hero:GetItemInSlot(i) 
		if item ~= nil then
			item:EndCooldown()
		end
	end
end

function ResetMasterAbilities(hero)
	local masterUnit = hero.MasterUnit
	
	masterUnit:FindAbilityByName("cmd_seal_1"):EndCooldown()
	masterUnit:FindAbilityByName("cmd_seal_2"):EndCooldown()
	masterUnit:FindAbilityByName("cmd_seal_3"):EndCooldown()
	masterUnit:FindAbilityByName("cmd_seal_4"):EndCooldown()
	masterUnit:FindAbilityByName("master_presence_resonator"):EndCooldown()
	masterUnit:FindAbilityByName("master_presence_resonator"):StartCooldown(22)
	masterUnit:FindAbilityByName("cmd_seal_5"):EndCooldown()

	--[[for i=0, 14 do
		local item = hero:GetItemInSlot(i) 
		if item ~= nil then
			item:EndCooldown()
		end
	end]]
end

function IncrementCharges(hero)
	if hero:HasModifier("modifier_charges") then
		local modifier = hero:FindModifierByName("modifier_charges")
		modifier:OnIntervalThink()
	end
end

function RemoveChargeModifiers(hero)
	for i=1, #ChargeBasedBuffs do
		--print(ChargeBasedBuffs[i])
        hero:RemoveModifierByName(ChargeBasedBuffs[i])        
    end
end

function OnSeal2Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local currentMana = caster:GetMana()
	local ability = keys.ability

	if caster:GetHealth() == 1 then
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Master_Not_Enough_Health")
		return 
	end

	if caster:GetMana() <= 1 then
		if caster.IsFirstSeal and caster:GetMana() == 1 then
		else
			keys.ability:EndCooldown() 
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Master_Mana")
			return 
		end
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		keys.ability:EndCooldown() 		
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
		return
	end
	hero.ServStat:useWSeal()
	-- pay mana cost
	-- caster:SetMana(caster:GetMana()-2)
	local master2 = hero.MasterUnit2
	master2:SetMana(caster:GetMana())
	-- pay health cost
	caster:SetHealth(caster:GetHealth()-1) 

	ResetAbilities(hero)
	ResetItems(hero)
	IncrementCharges(hero)

	--[[if(hero:GetName() == "npc_dota_hero_windrunner" and hero.bIsFTAcquired) then
		local clone = hero.TempestDouble

		if(clone and clone:IsAlive()) then
			ResetAbilities(clone)
			ResetItems(clone)
		end
	end]]

	-- Particle
	hero:EmitSound("DOTA_Item.Refresher.Activate")
	local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


	-- Set cooldown
	if caster:HasModifier("modifier_command_seal_1_buff") then
		keys.ability:EndCooldown()
		--[[if currentMana ~= 1 then
			caster:SetMana(caster:GetMana()+1)  --refund 1 mana
			master2:SetMana(caster:GetMana())
		end]]
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(ability:GetCooldown(1))
		--caster:FindAbilityByName("cmd_seal_5"):StartCooldown(ability:GetCooldown(1))
		keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_2",{})
	end
end

function OnSeal3Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local ability = keys.ability

	if caster:GetHealth() == 1 then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Master_Not_Enough_Health")
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
		return
	elseif hero:GetHealth() == hero:GetMaxHealth() then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#At_Max_Health")
		return
	end

	if hero:GetName() == "npc_dota_hero_doom_bringer" and RandomInt(1, 100) <= 35 then
		EmitGlobalSound("Shiro_Onegai")
	end

	hero:EmitSound("DOTA_Item.UrnOfShadows.Activate")
	hero.ServStat:useESeal()
	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	local particle = ParticleManager:CreateParticle("particles/items2_fx/urn_of_shadows_heal_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
	hero:FateHeal(hero:GetMaxHealth(), hero, false)

	if caster.IsFirstSeal == true then
		keys.ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(ability:GetCooldown(1))
		--caster:FindAbilityByName("cmd_seal_5"):StartCooldown(ability:GetCooldown(1))
		ability:ApplyDataDrivenModifier(caster, hero, "modifier_command_seal_3",{})
	end
end

function OnSeal4Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local ability = keys.ability

	if IsManaLess(hero) then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Recover_Mana")
		return 
	elseif caster:GetHealth() == 1 then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Master_Not_Enough_Health")
		return 
	elseif not hero:IsAlive() or IsRevoked(hero)  then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
		return
	elseif hero:GetMana() == hero:GetMaxMana() then
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1)) 
		keys.ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#At_Max_Mana")
		return
	end
	hero.ServStat:useRSeal()
	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - ability:GetManaCost(keys.ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	if hero:GetName() == "npc_dota_hero_doom_bringer" and RandomInt(1, 100) <= 35 then
		EmitGlobalSound("Shiro_Onegai")
	end

	-- Particle
	hero:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target")
	local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


	hero:SetMana(hero:GetMaxMana()) 


	if caster.IsFirstSeal == true then
		ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(ability:GetCooldown(1))
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(ability:GetCooldown(1))
		--caster:FindAbilityByName("cmd_seal_5"):StartCooldown(ability:GetCooldown(1))
		ability:ApplyDataDrivenModifier(caster, hero, "modifier_command_seal_4",{})
	end
end

function OnPRStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
    local heroTable = {}
    local target = nil

    local enemiesAlive = 0
    
    if not hero:IsAlive() then
    	return
    end

    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero:IsAlive() and playerHero:GetTeamNumber() ~= hero:GetTeamNumber() then
    		enemiesAlive = enemiesAlive + 1
    	end
    end)

    LoopOverPlayers(function(player, playerID, playerHero)
		if playerHero:GetTeamNumber() ~= hero:GetTeamNumber() then
			if playerHero:IsAlive() and CanBeDetected(playerHero) and not playerHero:HasModifier("modifier_e_scroll") then
			--or (playerHero:IsAlive() and not CanBeDetected(playerHero) and not playerHero:IsInvisible()) then
				table.insert(heroTable, playerHero)
			end
		end
	end)

	if #heroTable == 0 then 
		LoopOverPlayers(function(player, playerID, playerHero)
			if playerHero:IsAlive() and not CanBeDetected(playerHero) and not playerHero:HasModifier("modifier_ta_invis_passive") and not playerHero:HasModifier("modifier_e_scroll") --[[and not playerHero:IsInvisible()]] then 
				table.insert(heroTable, playerHero)
			end
		end)
	end

    if #heroTable > 0 then
    	if #heroTable == 1 then 
    		target = heroTable[1]
    		target:AddNewModifier(hero, nil, "modifier_vision_provider", { Duration = 2 })
	    	MinimapEvent( hero:GetTeamNumber(), hero, target:GetAbsOrigin().x, target:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_RADAR, 2)
    	else
    		local nearestHero = heroTable[1]
    		local nearestDistance = (heroTable[1]:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()

    		for i = 2, #heroTable do
	    		local distance = (heroTable[i]:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()	    		

	    		if math.abs(distance) < math.abs(nearestDistance) and not heroTable[i]:HasModifier("modifier_resonator_cooldown") then
	    			nearestHero = heroTable[i]
	    			nearestDistance = distance
	    		end
	    	end

	    	target = nearestHero
	    	if target:HasModifier("modifier_resonator_cooldown") then 
		    	for i = 1, #heroTable do
		    		local distance = (heroTable[i]:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()	    		

		    		if math.abs(distance) < math.abs(nearestDistance) then
		    			target = heroTable[i]
		    			nearestDistance = distance
		    		end
		    	end	
	    	end

	    	--SpawnAttachedVisionDummy(hero, target, 100, 4, true)
	    	--SpawnAttachedVisionDummy(target, hero, 100, 4, true)    	
	    	target:AddNewModifier(hero, nil, "modifier_resonator_cooldown", { Duration = 5 })
	    	target:AddNewModifier(hero, nil, "modifier_vision_provider", { Duration = 2 })
	    	MinimapEvent( hero:GetTeamNumber(), hero, target:GetAbsOrigin().x, target:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_RADAR, 2)
    	end    	
    	local target_master_ability = target.MasterUnit:FindAbilityByName(ability:GetName())

    	--[[if not CanBeDetected(target) and target:IsInvisible() then

    	else
    		
    	end]]
    	
	    --hero:AddNewModifier(target, nil, "modifier_vision_provider", { Duration = 2 })
    end
    
    GameRules:SendCustomMessage("<font color='#58ACFA'>" .. FindName(hero:GetName()) .."</font>" ..  "<font color='#ff9900'>'s Master just used Presence Resonator!", 0, 0)

    --[[if hero:GetName() == "npc_dota_hero_mirana" and hero.bIsIDAcquired then
    	ability:EndCooldown()
    	ability:StartCooldown(ability:GetCooldown(1)/2)
    end]]

    EmitGlobalSound("Resonator.Activate")
end

function AddMasterAbility(master, name)
    --local ply = master:GetPlayerOwner()
    --local attributeTable = FindAttribute(name)
    --if attributeTable == nil then return end
    --LoopThroughAttr(master, attributeTable)
    if master:GetAbilityByIndex(0) == nil then 
    	master:AddAbility(ServantAttribute[name]["SA1"])
    	master:AddAbility(ServantAttribute[name]["SA2"])
	    master:AddAbility(ServantAttribute[name]["SA3"])
	    master:AddAbility(ServantAttribute[name]["SA4"])
	    master:AddAbility(ServantAttribute[name]["SA5"])
	    master:AddAbility(ServantAttribute[name]["SCombo"])
    else
	    master:AddAbility(ServantAttribute[name]["SA2"])
	    master:AddAbility(ServantAttribute[name]["SA3"])
	    master:AddAbility(ServantAttribute[name]["SA4"])
	    master:AddAbility(ServantAttribute[name]["SA5"])
	    master:AddAbility(ServantAttribute[name]["SA1"])
	    master:SwapAbilities(ServantAttribute[name]["SA1"], "twin_gate_portal_warp", true, true)
	    master:AddAbility(ServantAttribute[name]["SCombo"])
	    master:SwapAbilities(ServantAttribute[name]["SCombo"], "twin_gate_portal_warp", true, true)
	end
    master:FindAbilityByName(ServantAttribute[name]["SCombo"]):StartCooldown(9999) 
    
    --[[local i = 0
    for k,v in pairs(ServantAttribute[name]) do 
    	print(k,v)
    	master:AddAbility(v)
    	local sa = master:GetAbilityByIndex(i):GetAbilityName()
    	master:SwapAbilities(v, sa, true, false)
    	print(sa)
    	i = i + 1
    	if k == "SCombo" then 
    		master:FindAbilityByName(v):StartCooldown(9999) 
    	end
    end]]
    master:RemoveAbility("twin_gate_portal_warp")
	master:AddAbility("master_strength")
	master:AddAbility("master_agility")
	master:AddAbility("master_intelligence")
	master:AddAbility("master_damage")
	master:AddAbility("master_armor")
	master:AddAbility("master_health_regen")
	master:AddAbility("master_mana_regen")
	master:AddAbility("master_movement_speed")
	master:AddAbility("master_gold")
	master:AddAbility("master_2_passive")
end

function LoopThroughAttr(hero, attrTable)
    for i=1, #attrTable do
        --print("Added " .. attrTable[i])
        hero:AddAbility(attrTable[i])
        if i == #attrTable then 
        	hero.ComboName = attrTable[i]
        end
    end

   	print(hero.ComboName)
   	print(attrTable[#attrTable])
   	if attrTable.attrCount == 4 then
   		hero:AddAbility("fate_empty1")
    	hero:SwapAbilities(hero.ComboName, "fate_empty1", true, true)
    elseif attrTable.attrCount == 5 then
    	--if hero:GetAbilityByIndex(5):GetAbilityName() ~= hero.ComboName then 
    		hero:SwapAbilities(hero.ComboName, hero:GetAbilityByIndex(5):GetAbilityName(), true, true)
    	--end
   	end


   	--hero.ComboName = attrTable[#attrTable]
    hero:FindAbilityByName(hero.ComboName):StartCooldown(9999) 
    --print(attrTable[#attrTable])
    --hero:SwapAbilities(attrTable[#attrTable], hero:GetAbilityByIndex(4):GetName(), true, true)
    --hero:SwapAbilities("master_close_list", "fate_empty1", true, true)
    --[[if #attrTable-1 == 4 then
    	hero:AddAbility("fate_empty1")
    	hero:SwapAbilities(attrTable[#attrTable], "fate_empty1", true, true)
   	end
    if attrTable.attrCount == 5 then
    	hero:SwapAbilities(hero.ComboName, hero:GetAbilityByIndex(5):GetAbilityName(), true, true)
    end]]
end

function FindAttribute(name)
    local attributes = nil
    if name == "npc_dota_hero_legion_commander" then
        attributes = SaberAttribute
    elseif name == "npc_dota_hero_phantom_lancer" then
        attributes = LancerAttribute
    elseif name == "npc_dota_hero_spectre" then
        attributes = SaberAlterAttribute
    elseif name == "npc_dota_hero_ember_spirit" then
        attributes = ArcherAttribute
    elseif name == "npc_dota_hero_templar_assassin" then
        attributes = RiderAttribute
    elseif name == "npc_dota_hero_doom_bringer" then
        attributes = BerserkerAttribute
    elseif name == "npc_dota_hero_juggernaut" then
        attributes = FAAttribute
    elseif name == "npc_dota_hero_bounty_hunter" then
        attributes = TAAttribute
    elseif name == "npc_dota_hero_crystal_maiden" then
        attributes = CasterAttribute
    elseif name == "npc_dota_hero_skywrath_mage" then
        attributes = GilgaAttribute
    elseif name == "npc_dota_hero_sven" then
        attributes = LancelotAttribute
    elseif name == "npc_dota_hero_vengefulspirit" then
        attributes = AvengerAttribute
    elseif name == "npc_dota_hero_huskar" then
        attributes = DiarmuidAttribute
    elseif name == "npc_dota_hero_chen" then
        attributes = IskanderAttribute
    elseif name == "npc_dota_hero_shadow_shaman" then
        attributes = GillesAttribute
    elseif name == "npc_dota_hero_lina" then
        attributes = NeroAttribute
    elseif name == "npc_dota_hero_omniknight" then
        attributes = GawainAttribute
    elseif name == "npc_dota_hero_enchantress" then
        attributes = TamamoAttribute
    elseif name == "npc_dota_hero_bloodseeker" then
    	attributes = LiAttribute
    elseif name == "npc_dota_hero_mirana" then
    	attributes = JeanneAttribute
    elseif name == "npc_dota_hero_queenofpain" then
    	attributes = AstolfoAttribute
    elseif name == "npc_dota_hero_windrunner" then
    	attributes = NRAttribute
    elseif name == "npc_dota_hero_drow_ranger" then
    	attributes = AtalantaAttribute
	elseif name == "npc_dota_hero_tidehunter" then
		attributes = VladAttribute
	elseif name == "npc_dota_hero_phantom_assassin" then
		attributes = SemiramisAttribute
	elseif name == "npc_dota_hero_beastmaster" then
		attributes = KarnaAttribute
	elseif name == "npc_dota_hero_naga_siren" then
		attributes = KuroAttribute
	elseif name == "npc_dota_hero_riki" then
		attributes = JTRAttribute
	elseif name == "npc_dota_hero_dark_willow" then
		attributes = OkitaAttribute
	elseif name == "npc_dota_hero_troll_warlord" then
		attributes = DrakeAttribute
	elseif name == "npc_dota_hero_monkey_king" then
		attributes = ScathachAttribute
	elseif name == "npc_dota_hero_tusk" then
		attributes = MordredAttribute
	elseif name == "npc_dota_hero_zuus" then
		attributes = FranAttribute
	elseif name == "npc_dota_hero_axe" then
		attributes = LubuAttribute
	elseif name == "npc_dota_hero_death_prophet" then
		attributes = BathoryAttribute
	elseif name == "npc_dota_hero_enigma" then
		attributes = AmakusaAttribute
	elseif name == "npc_dota_hero_night_stalker" then
		attributes = EdmondAttribute
	elseif name == "npc_dota_hero_disruptor" then
		attributes = KongMingAttribute
	elseif name == "npc_dota_hero_skeleton_king" then
		attributes = KingHassanAttribute
	elseif name == "npc_dota_hero_necrolyte" then
		attributes = HansAttribute
	elseif name == "npc_dota_hero_sniper" then
		attributes = RobinAttribute
	elseif name == "npc_dota_hero_gyrocopter" then
		attributes = NobuAttribute
	elseif name == "npc_dota_hero_terrorblade" then
		attributes = SaitoAttribute
	elseif name == "npc_dota_hero_antimage" then
		attributes = MusashiAttribute
	elseif name == "npc_dota_hero_dragon_knight" then
		attributes = MashuAttribute
	elseif name == "npc_dota_hero_oracle" then
		attributes = IshtarAttribute
	elseif name == "npc_dota_hero_ursa" then
		attributes = AtlantaAlterAttribute
	elseif name == "npc_dota_hero_kunkka" then
		attributes = MuramasaAttribute
	elseif name == "npc_dota_hero_void_spirit" then
		attributes = KiyohimeAttribute
    end
   
    return attributes
end 

function OnAttributeListOpen(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	local attributeTable = FindAttribute(hero:GetName())


	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), attributeTable[1], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), attributeTable[2], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), attributeTable[3], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "master_close_list", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), attributeTable[4], true, true)
	

	--if attributeTable[5] ~= nil then 

	if attributeTable.attrCount == 5 then 
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), attributeTable[5], true, true)
	else 
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), fate_empty1, true, true)
	end
end

function OnListClose(keys)
	local caster = keys.caster

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "master_attribute_list", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "master_stat_list1", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "master_stat_list2", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "master_shard_of_holy_grail", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), caster.ComboName, true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "fate_empty2", true, true)
end

function OnStatList1Open(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_strength")
	caster:AddAbility("master_agility")
	caster:AddAbility("master_intelligence")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("master_damage")
	caster:AddAbility("master_armor")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
	caster:GetAbilityByIndex(4):SetLevel(1)
	caster:GetAbilityByIndex(5):SetLevel(1)
end

function OnStatList2Open(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_health_regen")
	caster:AddAbility("master_mana_regen")
	caster:AddAbility("master_movement_speed")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("fate_empty1")
	caster:AddAbility("fate_empty2")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
end

function OnShardOpen(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_shard_of_avarice")
	caster:AddAbility("master_shard_of_anti_magic")
	caster:AddAbility("master_shard_of_replenishment")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("master_shard_of_prosperity")
	caster:AddAbility("fate_empty2")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
	caster:GetAbilityByIndex(4):SetLevel(1)
end

function OnStatListClose(keys)
	local caster = keys.caster
	for i=0,5 do
		caster:RemoveAbility(caster:GetAbilityByIndex(i):GetName())
	end
	caster:RemoveAbility(caster.ComboName)
	for i=1, 20 do
		if caster.SavedList[i] == nil then break
		else
			caster:AddAbility(caster.SavedList[i])
		end
		LevelAllAbility(caster)
	end
end

-- Remove all abilities and save it to caster handle
function RemoveAllAbility(caster)
	local abilityList = {}
	for i=0,20 do
		if caster:GetAbilityByIndex(i) ~= nil then 
			local abil = caster:GetAbilityByIndex(i):GetName()
			abilityList[i+1] = abil
			caster:RemoveAbility(caster:GetAbilityByIndex(i):GetName())
		else 
			break
		end
	end
	caster.SavedList = abilityList
end

function OnStrengthGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.STRgained == nil then
		hero.STRgained = 1
	else 
		if hero.STRgained < 50 then
			hero.STRgained = hero.STRgained + 1
		else
			caster:GiveMana(1)
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			return
		end
	end 

	if GetMapName() == "fate_tutorial" then 
		if hero:GetName() == "npc_dota_hero_legion_commander" then
			if math.ceil(hero:GetStrength()) >= 24 then 
				if math.ceil(hero:GetStrength()) == 24 then  
					CustomNetTables:SetTableValue("tutorial", "subquest", {quest6b = false , quest6a = true})
				else
					CustomNetTables:SetTableValue("tutorial", "subquest", {quest6a = true })
				end
			end
		end
	end

	hero.ServStat:addStr()
	--NotifyManaAndShard(hero)
	hero:SetBaseStrength(hero:GetBaseStrength()+1) 
	CheckingComboEnable(hero)
	hero:CalculateStatBonus(true)
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnAgilityGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.AGIgained == nil then
		hero.AGIgained = 1
	else 
		if hero.AGIgained < 50 then
			hero.AGIgained = hero.AGIgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 

	if GetMapName() == "fate_tutorial" then 
		if hero:GetName() == "npc_dota_hero_legion_commander" then
			if math.ceil(hero:GetAgility()) >= 24 then 
				if math.ceil(hero:GetAgility()) == 24 then  
					CustomNetTables:SetTableValue("tutorial", "subquest", {quest6c = false, quest6b = true })
				else
					CustomNetTables:SetTableValue("tutorial", "subquest", {quest6b = true })
				end
			end	
		end
	end

	hero.ServStat:addAgi()
	--NotifyManaAndShard(hero)
	hero:SetBaseAgility(hero:GetBaseAgility()+1) 
	CheckingComboEnable(hero)
	hero:CalculateStatBonus(true)
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnIntelligenceGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if IsManaLess(hero) and not string.match(hero:GetName(), "shaman") then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Intelligence")
		caster:GiveMana(1)
		return
	end

	if hero.INTgained == nil then
		hero.INTgained = 1
	else 
		if hero.INTgained < 50 then
			hero.INTgained = hero.INTgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 

	if GetMapName() == "fate_tutorial" then 
		if hero:GetName() == "npc_dota_hero_legion_commander" then
			if math.ceil(hero:GetIntellect()) >= 25 then 
				CustomNetTables:SetTableValue("tutorial", "subquest", {quest6c = true})
			end
		end
	end

	hero.ServStat:addInt()
	--NotifyManaAndShard(hero)
	hero:SetBaseIntellect(hero:GetBaseIntellect()+1) 
	CheckingComboEnable(hero)
	hero:CalculateStatBonus(true)
	
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnDamageGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.DMGgained == nil then
		hero.DMGgained = 1
	else 
		if hero.DMGgained < 50 then
			hero.DMGgained = hero.DMGgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	hero.ServStat:addAtk()
	local primaryStat = 0
	local attr = hero:GetPrimaryAttribute() -- 0 strength / 1 agility / 2 intelligence
	if attr == 0 then
		primaryStat = hero:GetStrength()
	elseif attr == 1 then
		primaryStat = hero:GetAgility()
	elseif attr == 2 then
		primaryStat = hero:GetIntellect()
	else
		primaryStat = (hero:GetStrength() + hero:GetAgility() + hero:GetIntellect()) * 0.7
	end

	hero:SetBaseDamageMax(hero:GetBaseDamageMax() - math.floor(primaryStat) + 3)
	hero:SetBaseDamageMin(hero:GetBaseDamageMin() - math.floor(primaryStat) + 3)
	hero:CalculateStatBonus(true)
	--NotifyManaAndShard(hero)

	--[[local minDmg = hero:GetBaseDamageMin() - primaryStat
	local maxDmg = hero:GetBaseDamageMax() - primaryStat

	print("Current base damage : " .. minDmg  .. " to " .. maxDmg)]]
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnArmorGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.ARMORgained == nil then
		hero.ARMORgained = 1
	else 
		if hero.ARMORgained < 50 then
			hero.ARMORgained = hero.ARMORgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	hero.ServStat:addArmor()
	--NotifyManaAndShard(hero)
	local armor = hero.BaseArmor + (hero:GetAgility() * 0.04) + (hero.ARMORgained * 1.0)
	hero:SetPhysicalArmorBaseValue(armor) 
	hero:CalculateStatBonus(true)

	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnHPRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.HPREGgained == nil then
		hero.HPREGgained = 1
	elseif hero.BaseHPRegen == nil then
		hero.BaseHPRegen = hero:GetBaseHealthRegen()
	else 
		if hero.HPREGgained < 50 then
			hero.HPREGgained = hero.HPREGgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	hero.ServStat:addHPregen()
	--NotifyManaAndShard(hero)
	-- Bandaid balance for health regen.
	hero:SetBaseHealthRegen(hero.BaseHPRegen + (3.0 * hero.HPREGgained)) --down here attributes.txt is useless, and this line is working.
	hero:CalculateStatBonus(true)
	
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnManaRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if IsManaLess(hero) then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Mana_Regeneration")
		caster:GiveMana(1)
		return
	end

	if hero.MPREGgained == nil then
		hero.MPREGgained = 1
	elseif hero.BaseMPRegen == nil then
		hero.BaseMPRegen = hero:GetBaseManaRegen()
	else 
		if hero.MPREGgained < 50 then
			hero.MPREGgained = hero.MPREGgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	hero.ServStat:addMPregen()	
	--NotifyManaAndShard(hero)
	hero:SetBaseManaRegen(hero.BaseMPRegen + (1.75 * hero.MPREGgained)) --down here attributes.txt is useless, and this line is working.
	hero:CalculateStatBonus(true)

	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnMovementSpeedGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.MSgained == nil then
		hero.MSgained = 1
	else 
		if hero.MSgained < 50 then
			hero.MSgained = hero.MSgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_50_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	hero.ServStat:addMS()
	--NotifyManaAndShard(hero)
	hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed() + 5) 
	hero:CalculateStatBonus(true)
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnGoldGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.Goldgained == nil then
		hero.Goldgained = 1
	else 
		if hero.Goldgained < 10 then
			hero.Goldgained = hero.Goldgained + 1
		else
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Get_Over_10_Stats")
			caster:GiveMana(1)
			return
		end
	end 
	--hero.ServStat:addMS()
	--NotifyManaAndShard(hero)
	--hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed() + 5) 
	--hero:CalculateStatBonus(true)
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

end

function OnHeroGainGold(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.Goldgained ~= nil then
		hero:SetGold(0, false)
        hero:SetGold(hero:GetGold() + (hero.Goldgained * 2), true)
    end
end

function OnAvariceAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Shard")
		return 
	else 
		hero.ShardAmount = hero.ShardAmount - 1
		hero.ServStat:getS1()
	end

	caster:GiveMana(3)
    hero.MasterUnit2:GiveMana(3)
    caster:Heal(1, caster)

	-- distribute gold
	local teamTable = {}
	for i=0, 13 do
		local playerHero = PlayerResource:GetSelectedHeroEntity(i)
		if playerHero ~= nil then 
			if playerHero:GetTeam() == caster:GetTeam() then
				if playerHero.AvariceCount == nil then 
					playerHero.AvariceCount = 1
				else
					playerHero.AvariceCount = playerHero.AvariceCount + 1
					--if string.match(GetMapName(), "fate_elim") then
						--[[if playerHero.AvariceCount == 5 and not caster.avarice5 then 
							local team = caster:GetTeamNumber()
							if team == 2 then
								ServerTables:SetTableValue("avarice", "Radiant", true, true) 
							elseif team == 3 then 
								ServerTables:SetTableValue("avarice", "Dire", true, true) 
							end
						else]]
					if string.match(GetMapName(), "fate_elim") then
						if playerHero.AvariceCount == 4 then 
							if IsManaLess(playerHero) then
								playerHero:AddAbility("avarice_4_no_mana")
								playerHero:FindAbilityByName("avarice_4_no_mana"):SetLevel(1)
							else
								playerHero:AddAbility("avarice_4")
								playerHero:FindAbilityByName("avarice_4"):SetLevel(1)
							end
						end
					end
				end
			end
		end
	end

	if string.match(GetMapName(), "fate_elim") then
		local team = caster:GetTeamNumber()
		local radiant_avarice = ServerTables:GetTableValue("avarice", "Radiant")
		local dire_avarice = ServerTables:GetTableValue("avarice", "Dire")
		if team == 2 then
			radiant_avarice = radiant_avarice + 1
		elseif team == 3 then 		
			dire_avarice = dire_avarice + 1			
		end
		ServerTables:SetTableValue("avarice", "Radiant", radiant_avarice, true) 
		ServerTables:SetTableValue("avarice", "Dire", dire_avarice, true) 

		CustomGameEventManager:Send_ServerToAllClients("avarice_upgrade", {radiant_avarice = radiant_avarice, dire_avarice = dire_avarice})
	end

	CustomGameEventManager:Send_ServerToPlayer(ply, "avarice_declare", {avarice = hero.AvariceCount})

	hero:SetGold(hero:GetGold() + 10000, true)
	--for i=1,#teamTable do
		--local goldperperson = 10000/#teamTable
		--print("Distributing " .. goldperperson .. " per person")
		--teamTable[i]:SetGold(teamTable[i]:GetGold() + goldperperson, true)
		--teamTable[i]:ModifyGold(goldperperson, true, 0)
	--end
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS
end

function OnAMAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Shard")
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
		hero.ServStat:getS2()
	end

	hero:AddItem(CreateItem("item_shard_of_anti_magic" , nil, nil)) 
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

    SaveStashState(hero)
end

function OnReplenishmentAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Shard")
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
		hero.ServStat:getS3()
	end
	hero:AddItem(CreateItem("item_shard_of_replenishment" , nil, nil)) 
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

    SaveStashState(hero)
end

function OnProsperityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	--print("Prosperity shard acquired")
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Acquire_Shard")
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
		hero.ServStat:getS4()
	end

	local master = hero.MasterUnit 
	local master2 = hero.MasterUnit2

	if hero.ProsperityCount == nil then 
		hero.ProsperityCount = 1.3
	end

	for i=1,3 do
		local level = hero:GetLevel()
		if level ~= 24 then
			hero:AddExperience(_G.XP_PER_LEVEL_TABLE[level], false, false)
			--hero:AddExperience(XP_BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()]/realHeroCount, false, false)
		else
			master:SetMana(master:GetMana() + 3)
			master2:SetMana(master:GetMana())	
			NotifyManaAndShard(hero)	
		end
	end


	--[[
	master:SetMana(master:GetMana()+20)
	master2:SetMana(master:GetMana())]]
	--[[master:SetMaxHealth(master:GetMaxHealth() + 1) 
	master:SetHealth(master:GetHealth() + 1)
	master2:SetMaxHealth(master:GetMaxHealth()) 
	master2:SetHealth(master:GetHealth())]]
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS
end

function OnStatUpgrade(keys)
	local caster = keys.caster
	CheckingComboEnable(caster)
end

LinkLuaModifier("modifier_sasaki_vision", "abilities/sasaki/modifiers/modifier_sasaki_vision", LUA_MODIFIER_MOTION_NONE)

function OnPresenceDetectionThink(keys)
	local caster = keys.caster
	local hasSpecialPresenceDetection = false
	if caster:IsIllusion() then return end
	if caster:GetName() == "npc_dota_hero_juggernaut" and caster.IsEyeOfSerenityAcquired and caster.IsEyeOfSerenityActive then 
		hasSpecialPresenceDetection = true
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" and caster.IsEyeForArtAcquired then
		hasSpecialPresenceDetection = true
	elseif caster:GetName() == "npc_dota_hero_beastmaster" and caster.DiscernPoorAttribute then
		hasSpecialPresenceDetection = true
	end

	if GameRules:GetGameTime() < RoundStartTime + 30 then
		if hasSpecialPresenceDetection == false then return end 
	end

	local oldEnemyTable = caster.PresenceTable
	local newEnemyTable = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

	-- Flag everyone in range as true before comparing two tables
	for i=1, #newEnemyTable do
		newEnemyTable[i].IsPresenceDetected = true
	end

	-- If enemy has not moved out of range since last presence detection, flag them as false
	for i=1,#oldEnemyTable do
		for j=1, #newEnemyTable do
			if oldEnemyTable[i] == newEnemyTable[j] then 
				--print(" " .. newEnemyTable[j]:GetName() .. " has not been out of range since last presence detection")
				newEnemyTable[j].IsPresenceDetected = false
				break
			end
		end
	end

	-- Do the ping for everyone with IsPresenceDetected marked as true
	-- Filter TA from ping if he has improved presence concealment attribute
	--and not (enemy:GetName() == "npc_dota_hero_bounty_hunter" and enemy.IsPCImproved and (enemy:HasModifier("modifier_ta_invis") or enemy:HasModifier("modifier_ambush")))
	-- Filter EA from ping
	--and not (enemy:GetName() == "npc_dota_hero_bloodseeker" and enemy:HasModifier("modifier_lishuwen_concealment"))
	for i=1, #newEnemyTable do
		local enemy = newEnemyTable[i]
		if enemy:IsRealHero() and not enemy:IsIllusion() and CanBeDetected(enemy) then
			if enemy.IsPresenceDetected == true or enemy.IsPresenceDetected == nil then
				--print("Pinged " .. enemy:GetPlayerOwnerID() .. " by player " .. caster:GetPlayerOwnerID())
				MinimapEvent( caster:GetTeamNumber(), caster, enemy:GetAbsOrigin().x, enemy:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
				SendErrorMessage(caster:GetPlayerOwnerID(), "#Presence_Detected")
				local dangerping = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))

				ParticleManager:SetParticleControl(dangerping, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(dangerping, 1, enemy:GetAbsOrigin())
				
				--GameRules:AddMinimapDebugPoint(caster:GetPlayerID(), enemy:GetAbsOrigin(), 255, 0, 0, 500, 3.0)
				if not caster.bIsAlertSoundDisabled then
					CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "emit_presence_sound", {sound="Misc.BorrowedTime"})
				end
				-- Process Eye of Serenity attribute
				if caster:GetName() == "npc_dota_hero_juggernaut" and caster.IsEyeOfSerenityAcquired == true and caster.IsEyeOfSerenityActive == true then
					FAEyeAttribute(caster, enemy)
				end
				-- Process Eye for Art attribute
				local hPlayer = caster:GetPlayerOwner()
				if IsValidEntity(hPlayer) and not hPlayer:IsNull() then
					if caster:GetName() == "npc_dota_hero_shadow_shaman" and caster.IsEyeForArtAcquired == true then
						local choice = math.random(1,3)
						if choice == 1 then
							--Say(hPlayer, FindName(enemy:GetName()) .. ", dare to enter the demon's lair on your own?", true)
						elseif choice == 2 then
							--Say(hPlayer, "This presence...none other than " .. FindName(enemy:GetName()) .. "!", true)
						elseif choice == 3 then
							--Say(hPlayer, "Come forth, " .. FindName(enemy:GetName()) .. "...The fresh terror awaits you!", true)
						end
					end
				end
			end
		end
	end
	caster.PresenceTable = newEnemyTable
end

function OnIsekaiFixCreate (keys)
  	local target = keys.unit 
  	print(target:GetUnitName())
  	--target = self:GetParent()
  	-- nomal map
  	if target:GetAbsOrigin().y > -2000 then
    	target.RealWorldPos = target:GetAbsOrigin()
    	print(target:GetAbsOrigin())
    --AOTK
  	elseif target:GetAbsOrigin().y <= -2000 and target:GetAbsOrigin().x < 3300 then 
    	return
    --UBW
  	elseif target:GetAbsOrigin().y <= -2000 and target:GetAbsOrigin().x >= 3300 then 
    	return
  	end
end

function OnIsekaiFixThink (keys)
  	local target = keys.unit 
  	local time_count = 0
  	time_count = time_count + 1

  	if target:HasModifier("round_pause") then
    	target:RemoveModifierByName("modifier_isekai_check")
    	target:RemoveModifierByName("modifier_isekai_abuser")
  		return 
  	end

  	if time_count >= 30 then 
  		if target:GetAbsOrigin().y > -2000 then
  			if not target:HasModifier("out_of_game") or not target:HasModifier("jump_pause") or not target:HasModifier("jump_pause_nosilence") then
    			target:RemoveModifierByName("modifier_isekai_check")
    			target:RemoveModifierByName("modifier_isekai_abuser")
    		end
    	end
  	end

  	if target:HasModifier("modifier_isekai_check") then return end
  	if target:HasModifier("out_of_game") then return end
  	if target:HasModifier("jump_pause") then return end
  	if target:HasModifier("jump_pause_nosilence") then return end
  	
  	target:SetOrigin(target.RealWorldPos)
  	target:RemoveModifierByName("modifier_isekai_abuser")
end


-- Scrapped it(can have only 1 instance of AddMinimapDebugPoint at time)
function CustomPing(playerid, location)
	print("Custom Ping Issued")
	GameRules:AddMinimapDebugPoint(playerid, location, 255, 0, 0, 300, 3.0)
end 

function FAEyeAttribute(caster, enemy)
	enemy:AddNewModifier(caster, nil, "modifier_sasaki_vision", { Duration = 10 })

	--local eye = ParticleManager:CreateParticleForPlayer("particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN, enemy, PlayerResource:GetPlayer(caster:GetPlayerID()))
	--[[local eye = ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)

	ParticleManager:SetParticleControl(eye, 0, enemy:GetAbsOrigin())

	local eyedummy = CreateUnitByName("visible_dummy_unit", enemy:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	eyedummy:SetDayTimeVisionRange(500)
	eyedummy:SetNightTimeVisionRange(500)
	eyedummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 100}) 
	

	local eyedummypassive = eyedummy:FindAbilityByName("dummy_visible_unit_passive")
	eyedummypassive:SetLevel(1)

	local eyeCounter = 0

	Timers:CreateTimer(function() 
		if eyeCounter > 3.0 then DummyEnd(eyedummy) return end
		eyedummy:SetAbsOrigin(enemy:GetAbsOrigin()) 
		eyeCounter = eyeCounter + 0.2
		return 0.2
	end)]]
end

function OnHeroRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	if _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio" then
		if caster.AvariceCount == nil then 
			caster.AvariceCount = 0
		end
		caster:SetGold(0, false)
		caster:SetGold(caster:GetGold() + 3000 + (caster.AvariceCount * 300), true)

		caster.MasterUnit:GiveMana(math.min(math.ceil(caster.AvariceCount/3), 2))
		caster.MasterUnit2:GiveMana(math.min(math.ceil(caster.AvariceCount/3), 2))

		if caster.AvariceCount >= 2 then 
           caster.MasterUnit:Heal(1, caster.MasterUnit)
        end

		if caster.ProsperityCount ~= nil then
            caster.MasterUnit:Heal(1, caster.MasterUnit)
            caster:AddExperience(_G.XP_PER_LEVEL_TABLE[caster:GetLevel()] * 0.5, false, false)
        end
		--caster:ModifyGold(2000, true, 0) 
		giveUnitDataDrivenModifier(caster, caster, "spawn_invulnerable", 4.0)
	end
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
end

--[[function OnComboCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if caster:HasModifier("combo_cooldown") then
		caster:RemoveModifierByName("combo_cooldown")
	end
	if caster:HasModifier("combo_unavailable") then
		caster:RemoveModifierByName("combo_unavailable")
	end

	local comboAvailability = GetComboAvailability(hero)
	if comboAvailability == -1 then
		ability:ApplyDataDrivenModifier(caster, caster, "combo_unavailable", {duration=1})
	elseif comboAvailability > 0 then
		ability:ApplyDataDrivenModifier(caster, caster, "combo_cooldown", {duration=comboAvailability})
	end
end]]
