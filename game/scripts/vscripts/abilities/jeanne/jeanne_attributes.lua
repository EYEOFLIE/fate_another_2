jeanne_attribute_identity_discernment = class({})

function jeanne_attribute_identity_discernment:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsIDAcquired) then
		hero.IsIDAcquired = true

		hero:SwapAbilities("fate_empty1", "jeanne_identity_discernment", false, true) 
		hero.DSkill = "jeanne_identity_discernment"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

----------------------------

jeanne_attribute_improve_saint = class({})

function jeanne_attribute_improve_saint:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsSaintImproved) then
		hero.IsSaintImproved = true

		UpgradeAttribute(hero, 'jeanne_saint', 'jeanne_saint_upgrade', true)
		hero.FSkill = "jeanne_saint_upgrade"
		hero:RemoveModifierByName("modifier_jeanne_saint_thinker")
		hero:AddNewModifier(hero, hero:FindAbilityByName(hero.FSkill), "modifier_jeanne_saint_thinker", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

------------------------------------

jeanne_attribute_punishment = class({})

function jeanne_attribute_punishment:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsPunishmentAcquired) then

		if caster:HasModifier("modifier_jeanne_la_pucelle_window") then 
			caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")
		end

		hero.IsPunishmentAcquired = true

		if hero.IsDivineSymbolAcquired then
			UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_2', 'jeanne_gods_resolution_upgrade_3', true)
			hero.ESkill = "jeanne_gods_resolution_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_1', true)
			hero.ESkill = "jeanne_gods_resolution_upgrade_1"
		end
		if hero.IsRevelationAcquired then
			UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_2', 'jeanne_purge_the_unjust_upgrade_3', true)
			hero.WSkill = "jeanne_purge_the_unjust_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_1', true)
			hero.WSkill = "jeanne_purge_the_unjust_upgrade_1"
		end

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

------------------------------------

jeanne_attribute_divine_symbol = class({})

function jeanne_attribute_divine_symbol:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsDivineSymbolAcquired) then

		if caster:HasModifier("modifier_jeanne_la_pucelle_window") then 
			caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")
		end

		hero.IsDivineSymbolAcquired = true

		if hero.IsPunishmentAcquired then
			UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_1', 'jeanne_gods_resolution_upgrade_3', true)
			hero.ESkill = "jeanne_gods_resolution_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_2', true)
			hero.ESkill = "jeanne_gods_resolution_upgrade_2"
		end
		if hero.IsRevelationAcquired then
			UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_2', 'jeanne_luminosite_eternelle_upgrade_3', true)
			hero.RSkill = "jeanne_luminosite_eternelle_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_1', true)
			hero.RSkill = "jeanne_luminosite_eternelle_upgrade_1"
		end

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

------------------------------------

jeanne_attribute_revelation = class({})

function jeanne_attribute_revelation:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.IsRevelationAcquired) then

		hero.IsRevelationAcquired = true

		if hero.IsDivineSymbolAcquired then
			UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_1', 'jeanne_luminosite_eternelle_upgrade_3', true)
			hero.RSkill = "jeanne_luminosite_eternelle_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_2', true)
			hero.RSkill = "jeanne_luminosite_eternelle_upgrade_2"
		end
		if hero.IsPunishmentAcquired then
			UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_1', 'jeanne_purge_the_unjust_upgrade_3', true)
			hero.WSkill = "jeanne_purge_the_unjust_upgrade_3"
		else
			UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_2', true)
			hero.WSkill = "jeanne_purge_the_unjust_upgrade_2"
		end

		UpgradeAttribute(hero, 'jeanne_charisma', 'jeanne_charisma_upgrade', true)
		hero.QSkill = "jeanne_charisma_upgrade"

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end