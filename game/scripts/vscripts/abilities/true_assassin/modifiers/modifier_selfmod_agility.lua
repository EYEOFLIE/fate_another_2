modifier_selfmod_agility = class({})

function modifier_selfmod_agility:OnCreated(args)
	if IsServer() then
		self.AttackBonus = args.AttackBonus
		CustomNetTables:SetTableValue("sync","self_mod_damage", { atk_bonus = self.AttackBonus })
	end
end

function modifier_selfmod_agility:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_selfmod_agility:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		return self.AttackBonus
	elseif IsClient() then
		local atk_bonus = CustomNetTables:GetTableValue("sync","self_mod_damage").atk_bonus
        return atk_bonus 
	end
end

function modifier_selfmod_agility:IsHidden()
	return true
end

function modifier_selfmod_agility:IsDebuff()
	return false
end

function modifier_selfmod_agility:RemoveOnDeath()
	return false
end

function modifier_selfmod_agility:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_selfmod_agility:GetTexture()
	return "custom/true_assassin_attribute_weakening_venom"
end