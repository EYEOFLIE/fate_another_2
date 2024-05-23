modifier_prelati_regen = class({})

if IsServer() then
	function modifier_prelati_regen:OnCreated(args)
		self:StartIntervalThink(0.1)
	end

	function modifier_prelati_regen:OnIntervalThink()
		local ability = self:GetAbility()
		if self:GetParent():HasModifier("modifier_prelati_regen_block") or not self:GetParent():IsAlive() then
			return
		end
		if ability == nil then 
			ability = self:GetParent():FindAbilityByName("gilles_prelati_spellbook_upgrade")
		end
		local regen_pct = ability:GetSpecialValueFor("regen_pct")
		local max_mana = self:GetParent():GetMaxMana()

		self:GetParent():GiveMana(max_mana * regen_pct / 1000)
	end
end

function modifier_prelati_regen:IsHidden()
	return true 
end

function modifier_prelati_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS} 
end

function modifier_prelati_regen:GetModifierManaBonus()
	local mana = 0
	if self:GetParent().IsOuterGodAcquired then 
		mana = self:GetParent().MasterUnit2:FindAbilityByName("gilles_outer_god_attribute"):GetSpecialValueFor("bonus_mana")
	end
	return mana
end

function modifier_prelati_regen:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end