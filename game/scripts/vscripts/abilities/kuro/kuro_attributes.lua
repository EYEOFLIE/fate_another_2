kuro_attribute_excalibur_image = class({})
kuro_attribute_gae_bolg = class({})
kuro_attribute_projection = class({})
kuro_attribute_placeholder4 = class({})

LinkLuaModifier("modifier_kuro_projection", "abilities/kuro/modifiers/modifier_kuro_projection", LUA_MODIFIER_MOTION_NONE)

function kuro_attribute_excalibur_image:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("kuro_excalibur_image"):SetLevel(1)	

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

function kuro_attribute_gae_bolg:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("kuro_gae_bolg"):SetLevel(1)	

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

function kuro_attribute_projection:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	
	Timers:CreateTimer(function()
		if hero:IsAlive() then 
	    	hero:AddNewModifier(hero, self, "modifier_kuro_projection", {})
			return nil
		else
			return 1
		end
	end)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end