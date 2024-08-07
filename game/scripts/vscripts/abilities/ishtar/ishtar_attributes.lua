ishtar_attribute_gems = class({})

function ishtar_attribute_gems:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsGemsAcquired) then
		hero.IsGemsAcquired = true

		local current_gem = hero:FindAbilityByName(hero.DSkill):GetCurrentGem()

		UpgradeAttribute(hero, 'ishtar_d', 'ishtar_d_upgrade', true)
		hero.DSkill = "ishtar_d_upgrade"

		hero:AddNewModifier(hero, hero:FindAbilityByName(hero.DSkill), "modifier_ishtar_gem", {})
		hero:FindAbilityByName(hero.DSkill):AddGem(current_gem)

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

ishtar_attribute_goddess = class({})

function ishtar_attribute_goddess:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsGoddessAcquired) then
		hero.IsGoddessAcquired = true

		hero:FindAbilityByName("ishtar_beauty"):SetLevel(1)

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

ishtar_attribute_crown = class({})

function ishtar_attribute_crown:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsCrownAcquired) then
		hero.IsCrownAcquired = true

		hero:FindAbilityByName("ishtar_crown"):SetLevel(1)

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

ishtar_attribute_mana_burst = class({})

function ishtar_attribute_mana_burst:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsManaBurstGemAcquired) then
		hero.IsManaBurstGemAcquired = true

		local IsFToggle = hero:FindAbilityByName(hero.FSkill):IsToggle()

		UpgradeAttribute(hero, 'ishtar_f', 'ishtar_f_upgrade', true)
		hero.FSkill = "ishtar_f_upgrade"

		if IsFToggle then 
			hero:FindAbilityByName(hero.FSkill):ToggleAbility()
		end

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

ishtar_attribute_venus = class({})

function ishtar_attribute_venus:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsVenusAcquired) then
		hero.IsVenusAcquired = true

		hero:RemoveModifierByName("modifier_ishtar_combo_window")

		UpgradeAttribute(hero, 'ishtar_q', 'ishtar_q_upgrade', true)
		UpgradeAttribute(hero, 'ishtar_e', 'ishtar_e_upgrade', true)
		UpgradeAttribute(hero, 'ishtar_r', 'ishtar_r_upgrade', true)
		hero.QSkill = "ishtar_q_upgrade"
		hero.ESkill = "ishtar_e_upgrade"
		hero.RSkill = "ishtar_r_upgrade"

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end