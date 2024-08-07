atalanta_evolution_attribute = class({})

function atalanta_evolution_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.EvolutionAcquired) then
		hero.EvolutionAcquired = true

		local energy = hero:FindAbilityByName(hero.DSkill):GetEnergyStack(hero)

		UpgradeAttribute(hero, 'fate_empty1', 'atalanta_passive_evolution', true)
		hero.FSkill = "atalanta_passive_evolution"
		hero:FindAbilityByName("atalanta_passive_evolution"):SetLevel(1)

		if hero.CurseMoonAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_curse_upgrade_1', 'atalanta_alter_curse_upgrade_3', true)	
			hero.DSkill = "atalanta_alter_curse_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_curse', 'atalanta_alter_curse_upgrade_2', true)	
			hero.DSkill = "atalanta_alter_curse_upgrade_2"
		end

		hero:RemoveModifierByName('modifier_atalanta_energy_curse_passive')
		hero:AddNewModifier(hero, hero:FindAbilityByName(hero.DSkill), "modifier_atalanta_energy_curse_passive", {})
		hero:FindAbilityByName(hero.DSkill):Energy(energy)

		NonResetAbility(hero)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_moon_attribute = class({})

function atalanta_moon_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.CurseMoonAcquired) then
		hero.CurseMoonAcquired = true

		hero:RemoveModifierByName("modifier_atalanta_combo_window")

		UpgradeAttribute(hero, 'atalanta_alter_skia', 'atalanta_alter_skia_upgrade', false)
		hero.ComboSkill = "atalanta_alter_skia_upgrade"

		local energy = hero:FindAbilityByName(hero.DSkill):GetEnergyStack(hero)

		if hero.EvolutionAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_curse_upgrade_2', 'atalanta_alter_curse_upgrade_3', true)	
			hero.DSkill = "atalanta_alter_curse_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_curse', 'atalanta_alter_curse_upgrade_1', true)	
			hero.DSkill = "atalanta_alter_curse_upgrade_1"
		end

		hero:RemoveModifierByName('modifier_atalanta_energy_curse_passive')
		hero:AddNewModifier(hero, hero:FindAbilityByName(hero.DSkill), "modifier_atalanta_energy_curse_passive", {})
		hero:FindAbilityByName(hero.DSkill):Energy(energy)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_beast_attribute = class({})

function atalanta_beast_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.BeastEnhancementAcquired) then
		hero.BeastEnhancementAcquired = true
		
		if hero.WildBeastLogicAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_ora_upgrade_2', 'atalanta_alter_ora_upgrade_3', true)	
			hero.WSkill = "atalanta_alter_ora_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_ora', 'atalanta_alter_ora_upgrade_1', true)	
			hero.WSkill = "atalanta_alter_ora_upgrade_1"
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_bow_attribute = class({})

function atalanta_bow_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.BowAcquired) then
		hero.BowAcquired = true

		hero:RemoveModifierByName("modifier_atalanta_combo_window")
		
		if hero.WildBeastLogicAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_jump_upgrade_1', 'atalanta_alter_jump_upgrade_3', true)	
			hero.ESkill = "atalanta_alter_jump_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_jump', 'atalanta_alter_jump_upgrade_2', true)	
			hero.ESkill = "atalanta_alter_jump_upgrade_2"
		end

		UpgradeAttribute(hero, 'atalanta_alter_tauropolos_alter', 'atalanta_alter_tauropolos_alter_upgrade', true)	
		hero.RSkill = "atalanta_alter_tauropolos_alter_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_logic_attribute = class({})

function atalanta_logic_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.WildBeastLogicAcquired) then
		hero.WildBeastLogicAcquired = true

		UpgradeAttribute(hero, 'atalanta_alter_roar', 'atalanta_alter_roar_upgrade', true)	
		hero.QSkill = "atalanta_alter_roar_upgrade"

		if hero.BeastEnhancementAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_ora_upgrade_1', 'atalanta_alter_ora_upgrade_3', true)	
			hero.WSkill = "atalanta_alter_ora_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_ora', 'atalanta_alter_ora_upgrade_2', true)	
			hero.WSkill = "atalanta_alter_ora_upgrade_2"
		end

		if hero.BowAcquired then 
			UpgradeAttribute(hero, 'atalanta_alter_jump_upgrade_2', 'atalanta_alter_jump_upgrade_3', true)	
			hero.ESkill = "atalanta_alter_jump_upgrade_3"
		else
			UpgradeAttribute(hero, 'atalanta_alter_jump', 'atalanta_alter_jump_upgrade_1', true)	
			hero.ESkill = "atalanta_alter_jump_upgrade_1"
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end