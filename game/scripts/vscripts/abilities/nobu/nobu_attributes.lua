nobu_strategy_attribute = class({})

function nobu_strategy_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	hero.StrategyAcquired = true
	hero.IsStrategyReady = true
	hero:FindAbilityByName("nobu_strat"):SetLevel(1)
 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

nobu_expanding_attribute = class({})
LinkLuaModifier("modifier_nobu_expanding_attribute", "abilities/nobu/nobu_attributes", LUA_MODIFIER_MOTION_NONE)
modifier_nobu_expanding_attribute = class({})

 

function modifier_nobu_expanding_attribute:IsHidden()
	return true
end

function modifier_nobu_expanding_attribute:IsPermanent()
	return true
end

function modifier_nobu_expanding_attribute:RemoveOnDeath()
	return false
end

function modifier_nobu_expanding_attribute:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function nobu_expanding_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.Expanded) then
		hero.Expanded = true
		if hero:GetAbilityByIndex(4):GetAbilityName() == 'nobu_demon_king_open' then
	 		UpgradeAttribute(hero, 'nobu_demon_king_open', 'nobu_demon_king_open_upgrade', true)
	 	else
	 		UpgradeAttribute(hero, 'nobu_demon_king_open', 'nobu_demon_king_open_upgrade', false)
	 	end
	 	hero.FSkill = "nobu_demon_king_open_upgrade"
		Timers:CreateTimer(function()
			if hero:IsAlive() then 
				hero:AddNewModifier(hero, self, "modifier_nobu_expanding_attribute", {})
				return nil
			else
				return 1
			end
		end)

		NonResetAbility(hero)
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end


nobu_3000_attribute = class({})

function nobu_3000_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.is3000Acquired) then
		hero.is3000Acquired = true
		hero:RemoveModifierByName("modifier_nobu_combo_window")
		local show = true
	 	if hero:GetAbilityByIndex(4):GetAbilityName() == "nobu_demon_king_close" then
	 		show = false
		end
		if hero.NobuActionAcquired then
			UpgradeAttribute(hero, 'nobu_dash_action', 'nobu_dash_upgrade', show)
			hero.WSkill = "nobu_dash_upgrade"
		else
			UpgradeAttribute(hero, 'nobu_dash', 'nobu_dash_3000', show)
			hero.WSkill = "nobu_dash_3000"
		end
		UpgradeAttribute(hero, 'nobu_3000', 'nobu_3000_upgrade', show)
		UpgradeAttribute(hero, 'nobu_combo', 'nobu_combo_upgrade', false)	
		hero.RSkill = "nobu_3000_upgrade"
		NonResetAbility(hero)
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end


nobu_unifying_attribute = class({})

function nobu_unifying_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.UnifyingAcquired) then
		hero.UnifyingAcquired = true
		hero:RemoveModifierByName("modifier_nobu_combo_window")
	 
		if hero.NobuActionAcquired then
			UpgradeAttribute(hero, 'nobu_guns_action', 'nobu_guns_upgrade', true)
			hero.DSkill = "nobu_guns_upgrade"
		else
			UpgradeAttribute(hero, 'nobu_guns', 'nobu_guns_unifying', true)
			hero.DSkill = "nobu_guns_unifying"
		end

		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end


nobu_independent_action = class({})

function nobu_independent_action:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.NobuActionAcquired) then
		hero:RemoveModifierByName("modifier_nobu_combo_window")
		
		hero.NobuActionAcquired = true
		local show = true
	 	if hero:GetAbilityByIndex(4):GetAbilityName() == "nobu_demon_king_close" then
	 		show = false
		end

		UpgradeAttribute(hero, 'nobu_shot', 'nobu_shot_upgrade', show)
		UpgradeAttribute(hero, 'nobu_double_shots', 'nobu_double_shots_upgrade', show)
		hero.QSkill = "nobu_shot_upgrade"
		hero.ESkill = "nobu_double_shots_upgrade"

		if hero.UnifyingAcquired then
			UpgradeAttribute(hero, 'nobu_guns_unifying', 'nobu_guns_upgrade', true)
			hero.DSkill = "nobu_guns_upgrade"
		else
			UpgradeAttribute(hero, 'nobu_guns', 'nobu_guns_action', true)
			hero.DSkill = "nobu_guns_action"
		end

		if hero.is3000Acquired then
			UpgradeAttribute(hero, 'nobu_dash_3000', 'nobu_dash_upgrade', show)
			hero.WSkill = "nobu_dash_upgrade"
		else
			UpgradeAttribute(hero, 'nobu_dash', 'nobu_dash_action', show)
			hero.WSkill = "nobu_dash_action"
		end

		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

 
 