gilles_eye_for_art_attribute = class({})
gilles_outer_god_attribute = class({})
gilles_demonic_horde_attribute = class({})
gilles_sunken_city_attribute = class({})
gilles_abyssal_connection_attribute = class({})

LinkLuaModifier("modifier_demonic_horde_attribute", "abilities/gilles/modifiers/modifier_demonic_horde_attribute", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sunken_city_attribute", "abilities/gilles/modifiers/modifier_sunken_city_attribute", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_connection_attribute", "abilities/gilles/modifiers/modifier_abyssal_connection_attribute", LUA_MODIFIER_MOTION_NONE)

function gilles_eye_for_art_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.IsEyeOfArtAcquired) then

		hero.IsEyeOfArtAcquired = true

		hero:FindAbilityByName("gilles_eye_for_art_passive"):SetLevel(1)
		
		if hero:HasModifier("modifier_gilles_rlyeh_text_window") then 
			hero:FindAbilityByName("gilles_eye_for_art_passive"):SetHidden(true)
		else
			hero:SwapAbilities("gilles_eye_for_art_passive", "fate_empty1", true, false)
		end

		hero.FSkill = "gilles_eye_for_art_passive"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

function gilles_outer_god_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.IsOuterGodAcquired) then

		hero.IsOuterGodAcquired = true

		if hero:HasModifier("modifier_gilles_rlyeh_text_window") then 
			UpgradeAttribute(hero, 'gilles_grief', 'gilles_grief_upgrade', true)
			UpgradeAttribute(hero, 'gilles_torment', 'gilles_torment_upgrade', true)
			UpgradeAttribute(hero, 'gilles_smother', 'gilles_smother_upgrade', true)
			UpgradeAttribute(hero, 'gilles_misery', 'gilles_misery_upgrade', true)
			UpgradeAttribute(hero, 'gilles_hysteria', 'gilles_hysteria_upgrade', true)
			UpgradeAttribute(hero, 'gilles_prelati_spellbook', 'gilles_prelati_spellbook_upgrade', false)
			UpgradeAttribute(hero, 'gilles_rlyeh_text_open', 'gilles_rlyeh_text_open_upgrade', false)
		else
			UpgradeAttribute(hero, 'gilles_grief', 'gilles_grief_upgrade', false)
			UpgradeAttribute(hero, 'gilles_torment', 'gilles_torment_upgrade', false)
			UpgradeAttribute(hero, 'gilles_smother', 'gilles_smother_upgrade', false)
			UpgradeAttribute(hero, 'gilles_misery', 'gilles_misery_upgrade', false)
			UpgradeAttribute(hero, 'gilles_hysteria', 'gilles_hysteria_upgrade', false)
			UpgradeAttribute(hero, 'gilles_prelati_spellbook', 'gilles_prelati_spellbook_upgrade', true)
			UpgradeAttribute(hero, 'gilles_rlyeh_text_open', 'gilles_rlyeh_text_open_upgrade', true)
		end

		hero.WSkill = "gilles_rlyeh_text_open_upgrade"
		hero.DSkill = "gilles_prelati_spellbook_upgrade"

		hero:RemoveAbility("gilles_prelati_spellbook")
		hero:AddNewModifier(hero, hero:FindAbilityByName("gilles_prelati_spellbook_upgrade"), "modifier_prelati_regen", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

function gilles_demonic_horde_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.IsDemonicHordeAcquired) then

		hero.IsDemonicHordeAcquired = true

		if hero:HasModifier("modifier_gilles_rlyeh_text_window") then 
			UpgradeAttribute(hero, 'gilles_summon_jellyfish', 'gilles_summon_jellyfish_upgrade', false)
		else
			UpgradeAttribute(hero, 'gilles_summon_jellyfish', 'gilles_summon_jellyfish_upgrade', true)
		end

		hero.QSkill = "gilles_summon_jellyfish_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

function gilles_sunken_city_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.IsSunkenCityAcquired) then

		hero.IsSunkenCityAcquired = true

		if hero:HasModifier("modifier_gilles_rlyeh_text_window") then 
			UpgradeAttribute(hero, 'gilles_cthulhu_favour', 'gilles_cthulhu_favour_upgrade', false)
		else
			UpgradeAttribute(hero, 'gilles_cthulhu_favour', 'gilles_cthulhu_favour_upgrade', true)
		end

		hero.ESkill = "gilles_cthulhu_favour_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

function gilles_abyssal_connection_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.IsAbyssalConnectionAcquired) then

		hero.IsAbyssalConnectionAcquired = true

		if hero:HasModifier("modifier_gilles_rlyeh_text_window") then 
			UpgradeAttribute(hero, 'gilles_abyssal_contract', 'gilles_abyssal_contract_upgrade', false)
		else
			UpgradeAttribute(hero, 'gilles_abyssal_contract', 'gilles_abyssal_contract_upgrade', true)
		end

		hero.RSkill = "gilles_abyssal_contract_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

function OnGilleComboStart(keys)
	local caster = keys.caster
	local tentacle = caster.Squidlord
	
	local ability = caster:FindAbilityByName("gille_larret_de_mort")
	local radius = ability:GetSpecialValueFor("radius")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	--print(tentacle)
	--print(tentacle:IsAlive())

	if not tentacle or not tentacle:IsAlive() then
		caster:FindAbilityByName("gille_larret_de_mort"):EndCooldown()
		return 
	end

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("gille_larret_de_mort")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_larret_de_mort_cooldown", {duration = ability:GetCooldown(1)})

	-- knockup enemies
	local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		ApplyAirborne(caster, v, keys.KnockupDuration)
		v:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
	end

	-- remove integrate status
	if caster.IsIntegrated then
		caster:RemoveModifierByName("modifier_integrate_gille")
		tentacle:RemoveModifierByName("modifier_integrate")
		caster.IsIntegrated = false
		tentacle.AttemptingIntegrate = false
		SendMountStatus(caster)
	end


	ability:ApplyDataDrivenModifier(caster, tentacle, "modifier_gigantic_horror_freeze", {})
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 300)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 650)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), radius)
	EmitGlobalSound("ZC.Ravage")
	EmitGlobalSound("ZC.Laugh")

	local contractFx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
	ParticleManager:SetParticleControl(contractFx, 0, tentacle:GetAbsOrigin())
	ParticleManager:SetParticleControl(contractFx, 1, Vector(radius + 200,0,0))
	Timers:CreateTimer( 3, function()
		ParticleManager:DestroyParticle( contractFx, false )
		ParticleManager:ReleaseParticleIndex( contractFx )
	end)

	Timers:CreateTimer(cast_delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			DoDamage(caster, v, v:GetMaxHealth() * keys.Damage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			ability:ApplyDataDrivenModifier(caster, v, "modifier_gille_combo", {})
			v:EmitSound("hero_bloodseeker.rupture")
		end
		Timers:CreateTimer(0.5, function()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_CUSTOMORIGIN, tentacle)
			ParticleManager:SetParticleControl(particle, 0, tentacle:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(radius+200,0,0))  
			--ParticleManager:DestroyParticle(contractFx, false)
			--ParticleManager:ReleaseParticleIndex(contractFx)
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end)
		
		tentacle:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
		local splashFx = ParticleManager:CreateParticle("particles/custom/screen_scarlet_splash.vpcf", PATTACH_EYES_FOLLOW, tentacle)
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splashFx, false )
			ParticleManager:ReleaseParticleIndex( splashFx )
		end)
		tentacle:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")
		tentacle:ForceKill(true)
	end)
end

function CreateRavageParticle(handle, center, multiplier)
	for i=1, math.floor(multiplier/60) do
		local x = math.cos(i) * multiplier
		local y = math.sin(i) * multiplier
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, handle)
		ParticleManager:SetParticleControl(tentacleFx, 0, Vector(center.x + x, center.y + y, 100))
		ParticleManager:SetParticleControl(tentacleFx, 2, Vector(center.x + x, center.y + y, 100))
	end
end

function OnGilleComboThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = target:GetMaxHealth()*keys.DPS/100
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	--print("dealing damage")
end

function RemoveAllPoisons(keys) -- so people don't respawn with poison DoT debuff modifiers
	local caster = keys.caster
    LoopOverHeroes(function(hero)
    	hero:RemoveModifierByName("modifier_contaminate")
    	hero:RemoveModifierByName("modifier_gille_combo")
    end)
end