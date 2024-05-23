atalanta_evolution_attribute = class({})

function atalanta_evolution_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.EvolutionAcquired) then
		hero.EvolutionAcquired = true

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

	if not MasterCannotUpgrade(hero, caster, self, hero.CursedMoonAcquired) then
		hero.CursedMoonAcquired = true

		UpgradeAttribute(hero, 'atalanta_roar', 'atalanta_roar_upgrade', true)
		UpgradeAttribute(hero, 'atalanta_tauropolos_alter', 'atalanta_tauropolos_alter_upgrade', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_tornado_attribute = class({})

function atalanta_tornado_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.TornadoAcquired) then
		hero.TornadoAcquired = true
		UpgradeAttribute(hero, 'fate_empty1', 'atalanta_passive_beast', true)
		hero:FindAbilityByName('atalanta_passive_beast'):SetLevel(1)
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

atalanta_vision_attribute = class({})

function atalanta_vision_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not MasterCannotUpgrade(hero, caster, self, hero.VisionAcquired) then
		hero.VisionAcquired = true


		local units = FindUnitsInRadius(caster:GetTeam(),
                                        caster:GetAbsOrigin(), 
                                        nil, 
                                        99999, 
                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                        DOTA_UNIT_TARGET_ALL, 
                                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
                                        0, 
                                        false)
		for _,unit in pairs(units) do
			if not unit or unit:IsNull() or not unit:IsAlive() then return end
			unit:RemoveModifierByName("modifier_atalanta_curse")
        end

		UpgradeAttribute(hero, 'atalanta_curse', 'atalanta_curse_upgrade', true)
		hero:AddNewModifier(hero, hero:FindAbilityByName('atalanta_curse_upgrade'), "modifier_atalanta_curse_passive", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end