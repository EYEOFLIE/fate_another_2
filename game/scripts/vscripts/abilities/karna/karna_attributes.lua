

LinkLuaModifier("modifier_uncrowned_martial_arts", "abilities/karna/modifiers/modifier_uncrowned_martial_arts", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_karna_divinity", "abilities/karna/modifiers/modifier_karna_divinity", LUA_MODIFIER_MOTION_NONE)

function OnDiscernmentOfThePoorAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.DiscernPoorAttribute) then

		hero.DiscernPoorAttribute = true

		hero:SwapAbilities("karna_discern_poor", "fate_empty1", true, false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - ability:GetManaCost(ability:GetLevel()))
	end
end

function OnUncrownMartialArtAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.UncrownedAttribute) then

		Timers:CreateTimer(function()
			if hero:IsAlive() then 
				hero:AddNewModifier(hero, ability, "modifier_uncrowned_martial_arts", {})
				return nil
			else
				return 1
			end
		end)

		hero.UncrownedAttribute = true

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - ability:GetManaCost(ability:GetLevel()))
	end
end

function OnManaBurstFlameAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.ManaBurstAttribute) then

		if hero:HasModifier("modifier_karna_combo_window") then 
			hero:RemoveModifierByName("modifier_karna_combo_window")
		end

		hero.ManaBurstAttribute = true

		UpgradeAttribute(hero, "karna_agni", "karna_agni_upgrade", true)
		UpgradeAttribute(hero, "karna_brahmastra", "karna_brahmastra_upgrade", true)
		UpgradeAttribute(hero, "karna_brahmastra_kundala", "karna_brahmastra_kundala_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - ability:GetManaCost(ability:GetLevel()))
	end
end

--[[function karna_divinity_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	--hero:FindAbilityByName("karna_divinity_proxy"):SetLevel(1)

	--hero:SwapAbilities("gawain_excalibur_galatine", "karna_divinity_proxy", false, true)

	Timers:CreateTimer(function()
		if hero:IsAlive() then 
			hero:AddNewModifier(hero, self, "modifier_karna_divinity", {})
			return nil
		else
			return 1
		end
	end)
	
	hero.KarnaDivinityAttribute = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end]]

function OnIndraLightningAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IndraAttribute) then

		if hero:HasModifier("modifier_karna_combo_window") then 
			hero:RemoveModifierByName("modifier_karna_combo_window")
		end

		hero.IndraAttribute = true

		UpgradeAttribute(hero, "karna_vasavi_shakti", "karna_vasavi_shakti_upgrade", true)
		UpgradeAttribute(hero, "karna_combo_vasavi", "karna_combo_vasavi_upgrade", false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - ability:GetManaCost(ability:GetLevel()))
	end
end