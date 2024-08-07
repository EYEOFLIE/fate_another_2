

function Alternate01Create (keys)
	local caster = keys.caster 
	print('skin 01 add')
	if caster:GetName() == "npc_dota_hero_skywrath_mage" then 	
		caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/gilgamesh/gilgameshcasualunanim.vmdl")
		caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/gilgamesh/gilgameshcasualunanim.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/artoria/casual_saber/casual_saber_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria/casual_saber/casual_saber_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/artoria_alter/saber_alter_casual/artoria_alter_casual_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria_alter/saber_alter_casual/artoria_alter_casual_by_zefiroft.vmdl")
		caster:SetModelScale(1.18)
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/mordred/casual/casual_mordred_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/mordred/casual/casual_mordred_by_zefiroft.vmdl")
		caster:SetModelScale(1.17)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/emiya_black/emiya_black_zefiroft.vmdl")
		caster:SetOriginalModel("models/archer/emiya_black/emiya_black_zefiroft.vmdl")
		caster:SetModelScale(1.2)
		Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
        Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
    elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/medusa_lily_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/medusa_lily_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_tidehunter" then 	
		caster:SetModel("models/vlad/apo/vlad_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/vlad/apo/vlad_by_zefiroft.vmdl")
		caster:SetModelScale(0.5)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/medea/medea_uncape/medea_uncape_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medea/medea_uncape/medea_uncape_by_zefiroft.vmdl")
		caster:SetModelScale(1.6)
	elseif caster:GetName() == "npc_dota_hero_dark_willow" then 	
		caster:SetModel("models/okita/okita_pink/okita_pink_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/okita/okita_pink/okita_pink_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
		Attachments:AttachProp(caster, "attach_attack1", "models/okita/okita_sword.vmdl")
        --Attachments:AttachProp(caster, "attach_scabbard", "models/okita/okita_scabbard.vmdl")	
    elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/cu_extra_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/cu_extra_by_zefiroft.vmdl")
		caster:SetModelScale(1.04)
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_emperor/nero_emberor_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/nero/nero_emperor/nero_emberor_by_zefiroft.vmdl")
		caster:SetModelScale(1.22)
	elseif caster:GetName() == "npc_dota_hero_drow_ranger" then 	
		caster:SetModel("models/atalanta/atalanta_alter/atalanta_alter_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/atalanta/atalanta_alter/atalanta_alter_by_zefiroft.vmdl")
		caster:SetModelScale(1.33)	
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/casual/tamamo_casual_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/casual/tamamo_casual_by_zefiroft.vmdl")
		caster:SetModelScale(1.18)	
	elseif caster:GetName() == "npc_dota_hero_mirana" then 	
		caster:SetModel("models/jeanne/white/white_jeanne_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/jeanne/white/white_jeanne_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)		
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/gang/lishuwen_gangster_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/gang/lishuwen_gangster_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)		
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/school/astolfo_school_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/school/astolfo_school_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" then 	
		caster:SetModel("models/gilles/abyss/gilles_abyss_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gilles/abyss/gilles_abyss_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_chen" then 	
		caster:SetModel("models/iskandar/salary/iskandar_salary_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/iskandar/salary/iskandar_salary_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/hassan/100face/hassan_100_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/hassan/100face/hassan_100_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/school/bathory_schoolgirl_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/school/bathory_schoolgirl_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_vengefulspirit" then 	
		caster:SetModel("models/angra_mainyu/shirou/angra_emiya_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/angra_mainyu/shirou/angra_emiya_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)		
	elseif caster:GetName() == "npc_dota_hero_sven" then 
		caster:SetModel("models/lancelot/suit/lancelot_suit_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lancelot/suit/lancelot_suit_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)	
	elseif caster:GetName() == "npc_dota_hero_omniknight" then 
		caster:SetModel("models/gawain/samurai/gawain_samurai_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gawain/samurai/gawain_samurai_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/bartender/karna_bartender_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/bartender/karna_bartender_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_windrunner" then 
		caster:SetModel("models/nursery_rhyme/alice/nr_alice_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/nursery_rhyme/alice/nr_alice_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)	
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/secretary/scat_secretary_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/secretary/scat_secretary_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/general/lubu_flying_general.vmdl")
		caster:SetOriginalModel("models/lubu/general/lubu_flying_general.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/captain/drake_captain_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/captain/drake_captain_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_enigma" then 
		caster:SetModel("models/amakusa/samurai/amakusa_rebel_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/amakusa/samurai/amakusa_rebel_by_zefiroft.vmdl")
		caster:SetModelScale(1.5)	
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then 
			sword:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_sword", "models/amakusa/amakusa_sword2.vmdl") 
	elseif caster:GetName() == "npc_dota_hero_naga_siren" then 
		caster:SetModel("models/kuro/illya_archer/illya_archer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/kuro/illya_archer/illya_archer_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)	
		Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
        Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
    elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/tamamo/waifu/illya_berserk_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/waifu/illya_berserk_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)	
	elseif caster:GetName() == "npc_dota_hero_disruptor" then 
    	caster:SetModel("models/koumei/waver/waver_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/koumei/waver/waver_by_zefiroft.vmdl")
		caster:SetModelScale(0.8)	
	elseif caster:GetName() == "npc_dota_hero_night_stalker" then 
    	caster:SetModel("models/edmond/cape/edmond_cape_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/edmond/cape/edmond_cape_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)	
	elseif caster:GetName() == "npc_dota_hero_void_spirit" then 
    	caster:SetModel("models/kiyohime/lancer_swim/kiyo_swim_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/kiyohime/lancer_swim/kiyo_swim_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	
	elseif caster:GetName() == "npc_dota_hero_juggernaut" then 
		caster:SetModel("models/pepe/pepesaki/pepesaki_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/pepe/pepesaki/pepesaki_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)	 
	elseif caster:GetName() == "npc_dota_hero_nyx_assassin" then 
		caster:SetModel("models/melt/white/melt_white_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/melt/white/melt_white_by_zefiroft.vmdl")
		caster:SetModelScale(1.7)
	elseif caster:GetName() == "npc_dota_hero_ursa" then 
		caster:SetModel("models/atalanta_alter/armor/atalanta_alter_armor_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/atalanta_alter/armor/atalanta_alter_armor_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_zuus" then 
		caster:SetModel("models/fran/gladiator/fran_gladiator_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/fran/gladiator/fran_gladiator_by_zefiroft.vmdl")
		caster:SetModelScale(0.85)
	elseif caster:GetName() == "npc_dota_hero_oracle" then 
		caster:SetModel("models/ishtar/rin/ishtar_rin_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/ishtar/rin/ishtar_rin_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/capeless/robin_capeless_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/capeless/robin_capeless_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)
	end
end

function Alternate01Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_skywrath_mage" then 
		caster:SetModel("models/gilgamesh/gilgamesh.vmdl")
		caster:SetOriginalModel("models/gilgamesh/gilgamesh.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetOriginalModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetModelScale(2.4)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/archertest.vmdl")
		caster:SetOriginalModel("models/archer/archertest.vmdl")
		caster:SetModelScale(1.6)
		local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		kanshou:RemoveSelf()
		local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
		bakuya:RemoveSelf()
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_tidehunter" then 	
		caster:SetModel("models/vlad/vlad.vmdl")
		caster:SetOriginalModel("models/vlad/vlad.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/caster/caster.vmdl")
		caster:SetOriginalModel("models/caster/caster.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_dark_willow" then 	
		caster:SetModel("models/okita/okita_blue/okita_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/okita/okita_blue/okita_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
		local sword = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		--local scabbard = Attachments:GetCurrentAttachment(caster, "attach_scabbard")
		sword:RemoveSelf()
		--scabbard:RemoveSelf()
	elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetModelScale(0.9)	
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_new.vmdl")
		caster:SetOriginalModel("models/nero/nero_new.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_drow_ranger" then 	
		caster:SetModel("models/atalanta/new/atalanta_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/atalanta/new/atalanta_by_zefiroft.vmdl")
		caster:SetModelScale(1.12)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_mirana" then 	
		caster:SetModel("models/jeanne/default/jeanne_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/jeanne/default/jeanne_by_zefiroft.vmdl")
		caster:SetModelScale(1.85)			
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)		
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" then 	
		caster:SetModel("models/gilles/default/gilles_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gilles/default/gilles_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_chen" then 	
		caster:SetModel("models/iskandar/default/iskandar_new_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/iskandar/default/iskandar_new_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/true_assassin/ta.vmdl")
		caster:SetOriginalModel("models/true_assassin/ta.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_vengefulspirit" then 	
		caster:SetModel("models/angra_mainyu/avenger_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/angra_mainyu/avenger_by_zefiroft.vmdl")
		caster:SetModelScale(1.8)	
	elseif caster:GetName() == "npc_dota_hero_sven" then 	
		caster:SetModel("models/lancelot/lancelot_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lancelot/lancelot_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)	
	elseif caster:GetName() == "npc_dota_hero_omniknight" then 
		caster:SetModel("models/gawain/default/gawain_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gawain/default/gawain_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_windrunner" then 
		caster:SetModel("models/nurseryrhyme/nurseryrhyme.vmdl")
		caster:SetOriginalModel("models/nurseryrhyme/nurseryrhyme.vmdl")
		caster:SetModelScale(0.78)	
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_enigma" then 
		caster:SetModel("models/amakusa/default/amakusa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/amakusa/default/amakusa_by_zefiroft.vmdl")
		caster:SetModelScale(1.5)	
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then 
			sword:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_sword", "models/amakusa/amakusa_sword.vmdl")
	elseif caster:GetName() == "npc_dota_hero_naga_siren" then 
		caster:SetModel("models/kuro/kuro.vmdl")
		caster:SetOriginalModel("models/kuro/kuro.vmdl")
		caster:SetModelScale(1.00)	
		local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		kanshou:RemoveSelf()
		local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
		bakuya:RemoveSelf()
	elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	
	elseif caster:GetName() == "npc_dota_hero_disruptor" then 
    	caster:SetModel("models/koumei/default/koumei_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/koumei/default/koumei_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_night_stalker" then 
    	caster:SetModel("models/edmond/default/edmond_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/edmond/default/edmond_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)
	elseif caster:GetName() == "npc_dota_hero_void_spirit" then 
    	caster:SetModel("models/kiyohime/lancer/kiyo_lancer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/kiyohime/lancer/kiyo_lancer_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	
	elseif caster:GetName() == "npc_dota_hero_juggernaut" then 
		caster:SetModel("models/assassin/asn.vmdl")
		caster:SetOriginalModel("models/assassin/asn.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_nyx_assassin" then 
		caster:SetModel("models/melt/default/melt_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/melt/default/melt_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_ursa" then 
		caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/alter_atalanta_boar_fix/alter_atalanta_fbx.vmdl")
		caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/alter_atalanta_boar_fix/alter_atalanta_fbx.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_zuus" then 
		caster:SetModel("models/fran/default/new_fran_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/fran/default/new_fran_by_zefiroft.vmdl")
		caster:SetModelScale(0.7)
	elseif caster:GetName() == "npc_dota_hero_oracle" then 
		caster:SetModel("models/ishtar/default/ishtar_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/ishtar/default/ishtar_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)
	end
end

function Alternate02Create (keys)
	local caster = keys.caster 
	print('skin 02 add')
	if caster:GetName() == "npc_dota_hero_skywrath_mage" then 	
		caster:SetModel("models/gilgamesh/female/female_gil_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gilgamesh/female/female_gil_by_zefiroft.vmdl")
		caster:SetModelScale(1.5)
	elseif caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/artoria/suit_saber/artoria_suit_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria/suit_saber/artoria_suit_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/medea/medea_lily/medea_lily_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medea/medea_lily/medea_lily_by_zefiroft.vmdl")
		caster:SetModelScale(0.95)
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/artoria_alter/saber_alter_unarm_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria_alter/saber_alter_unarm_by_zefiroft.vmdl")
		caster:SetModelScale(0.95)
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/mordred/mordred_unarmor/mordred_unarmor_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/mordred/mordred_unarmor/mordred_unarmor_by_zefiroft.vmdl")
		caster:SetModelScale(1.09) 
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/emiya_shirou/emiya_shirou_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/archer/emiya_shirou/emiya_shirou_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
		Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
        Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_king/nero_king_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/nero/nero_king/nero_king_by_zefiroft.vmdl")
		caster:SetModelScale(1.12)
	elseif caster:GetName() == "npc_dota_hero_mirana" then 	
		caster:SetModel("models/jeanne/santa/jeanna_lily_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/jeanne/santa/jeanna_lily_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)	
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/coat/lushuwen_boss_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/coat/lushuwen_boss_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)	
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/casual/astolfo_pink_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/casual/astolfo_pink_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" then 	
		caster:SetModel("models/gilles/pope/gilles_pope_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gilles/pope/gilles_pope_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_omniknight" then 
		caster:SetModel("models/gawain/summer/gawain_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gawain/summer/gawain_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/god/karna_god_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/god/karna_god_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/gypse/scat_gypsee_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/gypse/scat_gypsee_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/mecha/mecha_lubu_zefiroft.vmdl")
		caster:SetOriginalModel("models/lubu/mecha/mecha_lubu_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/hunter/bathory_hunter_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/hunter/bathory_hunter_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_sven" then 
		caster:SetModel("models/lancelot/armor/lancelot_curse_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lancelot/armor/lancelot_curse_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/pirate/drake_pirate_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/pirate/drake_pirate_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then 
			sword:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_sword", "models/amakusa/amakusa_sword.vmdl")
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/illya_rider/illya_rider_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/illya_rider/illya_rider_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/hassan/female_hassan/female_hassan_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/hassan/female_hassan/female_hassan_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/illya_lancer/illya_lancer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/illya_lancer/illya_lancer_by_zefiroft.vmdl")
		caster:SetModelScale(1.19)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/schoolgirl/tamamo_schoolgirl_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/schoolgirl/tamamo_schoolgirl_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)	
	elseif caster:GetName() == "npc_dota_hero_dark_willow" then 
		local scabbard = Attachments:GetCurrentAttachment(caster, "attach_scabbard")
		if scabbard ~= nil and not scabbard:IsNull() then
			scabbard:RemoveSelf()
		end	
		caster:SetModel("models/okita/okita_alter/okita_alter_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/okita/okita_alter/okita_alter_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/bonk/bonk_doge_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bonk/bonk_doge_by_zefiroft.vmdl")
		caster:SetModelScale(2.3)	
		Attachments:AttachProp(caster, "attach_sword", "models/bonk/bonk_bat.vmdl") 
	elseif caster:GetName() == "npc_dota_hero_disruptor" then 
    	caster:SetModel("models/koumei/koihime/koihime_koumei_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/koumei/koihime/koihime_koumei_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)	
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/hiking/hiking_robin_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/hiking/hiking_robin_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)
	end 

end

function Alternate02Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_skywrath_mage" then 
		caster:SetModel("models/gilgamesh/gilgamesh.vmdl")
		caster:SetOriginalModel("models/gilgamesh/gilgamesh.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/caster/caster.vmdl")
		caster:SetOriginalModel("models/caster/caster.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetOriginalModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetModelScale(2.4)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/archertest.vmdl")
		caster:SetOriginalModel("models/archer/archertest.vmdl")
		caster:SetModelScale(1.6)
		local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		kanshou:RemoveSelf()
		local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
		bakuya:RemoveSelf()
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_new.vmdl")
		caster:SetOriginalModel("models/nero/nero_new.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_mirana" then 	
		caster:SetModel("models/jeanne/default/jeanne_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/jeanne/default/jeanne_by_zefiroft.vmdl")
		caster:SetModelScale(1.85)	
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" then 	
		caster:SetModel("models/gilles/default/gilles_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gilles/default/gilles_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_omniknight" then 
		caster:SetModel("models/gawain/default/gawain_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/gawain/default/gawain_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_sven" then 	
		caster:SetModel("models/lancelot/lancelot_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lancelot/lancelot_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/true_assassin/ta.vmdl")
		caster:SetOriginalModel("models/true_assassin/ta.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetModelScale(0.9)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/tamamo.vmdl")
		caster:SetOriginalModel("models/tamamo/tamamo.vmdl")
		caster:SetModelScale(0.8)
	elseif caster:GetName() == "npc_dota_hero_dark_willow" then 	
		caster:SetModel("models/okita/okita_blue/okita_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/okita/okita_blue/okita_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
		Attachments:AttachProp(hero, "attach_scabbard", "models/okita/okita_scabbard.vmdl") 
	elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then 
			sword:RemoveSelf() 
		end
	elseif caster:GetName() == "npc_dota_hero_disruptor" then 
    	caster:SetModel("models/koumei/default/koumei_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/koumei/default/koumei_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)
	end
end

function Alternate03Create (keys) 
	local caster = keys.caster 
	print('skin 03 add')
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		print('skin crown saber')
		caster:SetModel("models/artoria/crown_saber_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria/crown_saber_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_dress/nero_dress_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/nero/nero_dress/nero_dress_by_zefiroft.vmdl")
		caster:SetModelScale(1.22)
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/duchess/scat_duchess_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/duchess/scat_duchess_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/cowgirl/drake_cowgirl_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/cowgirl/drake_cowgirl_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/emiya_hero/emiya_hero_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/archer/emiya_hero/emiya_hero_by_zefiroft.vmdl")
		caster:SetModelScale(1.35)
		Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
        Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
    elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/hassan/illya_assassin/illya_assassin_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/hassan/illya_assassin/illya_assassin_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/police/tamamo_police_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/police/tamamo_police_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/medea/illya_caster/illya_caster_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medea/illya_caster/illya_caster_by_zefiroft.vmdl")
		caster:SetModelScale(0.95)
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/ana/ana_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/ana/ana_by_zefiroft.vmdl")
		caster:SetModelScale(0.85)
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/dw/dw_lubu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lubu/dw/dw_lubu_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)	
		local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
		lance:RemoveSelf()
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/artoria_alter/alter_summer/artoria_alter_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria_alter/alter_summer/artoria_alter_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/mordred/summer/summer_mordred_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/mordred/summer/summer_mordred_by_zefiroft.vmdl")
		caster:SetModelScale(1.22)
	elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/rin_lancer/lancer_rin_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/rin_lancer/lancer_rin_by_zefiroft.vmdl") 
		caster:SetModelScale(0.8)
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/sailor/sailor_astolfo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/sailor/sailor_astolfo_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/summer/summer_bathory_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/summer/summer_bathory_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/old/old_li_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/old/old_li_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)	
	elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/heracles/guts/guts_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/heracles/guts/guts_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/ninja/ninja_robin_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/ninja/ninja_robin_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	 
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/super_karna/super_karna_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/super_karna/super_karna_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	end
end

function Alternate03Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_new.vmdl")
		caster:SetOriginalModel("models/nero/nero_new.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/archertest.vmdl")
		caster:SetOriginalModel("models/archer/archertest.vmdl")
		caster:SetModelScale(1.6)
		local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		kanshou:RemoveSelf()
		local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
		bakuya:RemoveSelf()	
	elseif caster:GetName() == "npc_dota_hero_bounty_hunter" then 	
		caster:SetModel("models/true_assassin/ta.vmdl")
		caster:SetOriginalModel("models/true_assassin/ta.vmdl")
		caster:SetModelScale(1.2)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_crystal_maiden" then 	
		caster:SetModel("models/caster/caster.vmdl")
		caster:SetOriginalModel("models/caster/caster.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_axe" then 
		caster:SetModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lubu/default/lubu_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
		Attachments:AttachProp(caster, "attach_lance", "models/lubu/lubu_lance2.vmdl")  
	elseif caster:GetName() == "npc_dota_hero_spectre" then 	
		caster:SetModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetOriginalModel("models/saber_alter/sbr_alter.vmdl")
		caster:SetModelScale(1.15) 
	elseif caster:GetName() == "npc_dota_hero_tusk" then 	
		caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
		caster:SetModelScale(2.4)
	elseif caster:GetName() == "npc_dota_hero_phantom_lancer" then 	
		caster:SetModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/cu_chulainn/default/cu_by_zefiroft.vmdl")
		caster:SetModelScale(0.9)
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)
	elseif caster:GetName() == "npc_dota_hero_death_prophet" then 	
		caster:SetModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/bathory/default/bathory_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_doom_bringer" then 
    	caster:SetModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/heracles/default/heracles_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)	
	elseif caster:GetName() == "npc_dota_hero_sniper" then 
		caster:SetModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/robin/default/robin_new_by_zefiroft.vmdl")
		caster:SetModelScale(1.25)
	elseif caster:GetName() == "npc_dota_hero_beastmaster" then 
		caster:SetModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/karna/default/karna_by_zefiroft.vmdl")
		caster:SetModelScale(1.20)	
	end
end
 
function Alternate04Create (keys) 
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/artoria/saber_lily/artoria_lily_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria/saber_lily/artoria_lily_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/summer/scat_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/summer/scat_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/summer/drake_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/summer/drake_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/racing_nero/racing_nero_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/nero/racing_nero/racing_nero_by_zefiroft.vmdl")
		caster:SetModelScale(0.86)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/emiya_cyber/emiya_cyber_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/archer/emiya_cyber/emiya_cyber_by_zefiroft.vmdl")
		caster:SetModelScale(1.2)
		Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
        Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
    elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/magical/tamamo_magical_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/magical/tamamo_magical_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/mysterious_ana/myst_ana_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/mysterious_ana/myst_ana_by_zefiroft.vmdl")
		caster:SetModelScale(2.1)
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/summer/astolfo_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/summer/astolfo_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/old/old_boss_li_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/old/old_boss_li_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)	
	end
end

function Alternate04Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_troll_warlord" then 
		caster:SetModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/drake/default/drake_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_monkey_king" then 
		caster:SetModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/scathach/default/scat_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	elseif caster:GetName() == "npc_dota_hero_lina" then 	
		caster:SetModel("models/nero/nero_new.vmdl")
		caster:SetOriginalModel("models/nero/nero_new.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/archertest.vmdl")
		caster:SetOriginalModel("models/archer/archertest.vmdl")
		caster:SetModelScale(1.6)
		local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
		kanshou:RemoveSelf()
		local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
		bakuya:RemoveSelf()	
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	elseif caster:GetName() == "npc_dota_hero_templar_assassin" then 	
		caster:SetModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/medusa/default/medusa_by_zefiroft.vmdl")
		caster:SetModelScale(1.1)
	elseif caster:GetName() == "npc_dota_hero_queenofpain" then 	
		caster:SetModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/astolfo/default/astolfo_by_zefiroft.vmdl")
		caster:SetModelScale(1.05)
	elseif caster:GetName() == "npc_dota_hero_bloodseeker" then 	
		caster:SetModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/lishuwen/default/lishuwen_by_zefiroft.vmdl")
		caster:SetModelScale(1.15)	
	end
end

function Alternate05Create (keys)
	local caster = keys.caster 

	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/artoria/dress_saber/artoria_dress_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/artoria/dress_saber/artoria_dress_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/muramasa/muramasa_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/archer/muramasa/muramasa_by_zefiroft.vmdl")
		caster:SetModelScale(1.4)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/wedding/wedding_tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/wedding/wedding_tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.22)	
	end
end

function Alternate05Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 	
		caster:SetModel("models/archer/archertest.vmdl")
		caster:SetOriginalModel("models/archer/archertest.vmdl")
		caster:SetModelScale(1.6)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	end
end

function Alternate06Create (keys)
	local caster = keys.caster 

	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		print('skin arthur')
		caster:SetModel("models/arthur/arthur_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/arthur/arthur_by_zefiroft.vmdl")
		caster:SetModelScale(1.3)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/waifu/tamamo_waifu_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/waifu/tamamo_waifu_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	end
end

function Alternate06Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_legion_commander" then 	
		caster:SetModel("models/saber/saber.vmdl")
		caster:SetOriginalModel("models/saber/saber.vmdl")
		caster:SetModelScale(1.15)
	elseif caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	end
end

function Alternate07Create (keys)
	local caster = keys.caster 

	if caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/summer/tamamo_summer_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/summer/tamamo_summer_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	end
end

function Alternate07Destroy (keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_enchantress" then 	
		caster:SetModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetOriginalModel("models/tamamo/default/tamamo_by_zefiroft.vmdl")
		caster:SetModelScale(1.0)
	end
end




--PADORU
function OnPadoruCreate(keys)
	local caster = keys.caster 
	caster.OriginModel = caster.OriginModel or caster:GetModelName()
	caster.OriginModelSize = caster.OriginModelSize or caster:GetModelScale()
	caster:SetModel("models/padoru/padoru_alter.vmdl")
	caster:SetOriginalModel("models/padoru/padoru_alter.vmdl")
	caster:SetModelScale(0.8)
end

function OnPadoruDestroy(keys)
	local caster = keys.caster
	caster:SetModel(caster.OriginModel)
	caster:SetOriginalModel(caster.OriginModel)
	caster:SetModelScale(caster.OriginModelSize)
end

function OnPadoruDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_padoru")
	local padoru_hat = caster:FindItemInInventory("item_padoru_hat")
	caster:DropItemAtPositionImmediate(padoru_hat, caster:GetAbsOrigin())
end

function OnPadoruCast(keys)
	local caster = keys.caster
	local ability_use = keys.event_ability
	if IsSpellBook(ability_use:GetAbilityName()) then 
		return 
	end
	caster.padoru_cooldown = caster.padoru_cooldown or false
	LoopOverPlayers(function(player, playerID, playerHero)
		if player.IsPadoruEnable and player.IsPadoruEnable == true then
			if caster.padoru_cooldown == false then
				EmitSoundOnClient("Padoru", player)
				--caster:EmitSound("Padoru")
				caster.padoru_cooldown = true 
				Timers:CreateTimer(3.0, function()
					caster.padoru_cooldown = false
				end)
			end

		end
	end)
	
end

function OnPadoruKill(keys)
	local target = keys.target 

	if target:IsRealHero() then 
		LoopOverPlayers(function(player, playerID, playerHero)
			if player.IsPadoruEnable and player.IsPadoruEnable == true then
				EmitSoundOnClient("Merry_Padoru", player)
			end
		end)
	end
end