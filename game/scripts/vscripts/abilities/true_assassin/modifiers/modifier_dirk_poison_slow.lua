modifier_dirk_poison_slow = class({})

LinkLuaModifier("modifier_weakening_venom", "abilities/true_assassin/modifiers/modifier_weakening_venom", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_dirk_poison_slow", "abilities/true_assassin/modifiers/modifier_dirk_poison_slow", LUA_MODIFIER_MOTION_NONE)

function modifier_dirk_poison_slow:OnCreated(table)
	if IsServer() then
		self.PoisonSlow	= table.PoisonSlow
		CustomNetTables:SetTableValue("sync","dirk_poison_slow", {poison_slow = self.PoisonSlow})
	end
end

function modifier_dirk_poison_slow:OnRefresh(table)
	self:OnCreated(table)
end

function modifier_dirk_poison_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

	return funcs
end

function modifier_dirk_poison_slow:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then        
    	return self.PoisonSlow
    elseif IsClient() then
        local poison_slow = CustomNetTables:GetTableValue("sync","dirk_poison_slow").poison_slow
        return poison_slow 
    end
end

function modifier_dirk_poison_slow:GetAttributes()
  return MODIFIER_ATTRIBUTE_NONE
end

function modifier_dirk_poison_slow:IsDebuff()
	return true 
end

function modifier_dirk_poison_slow:RemoveOnDeath()
	return true 
end

function modifier_dirk_poison_slow:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
end

function modifier_dirk_poison_slow:GetTexture()
    return "custom/true_assassin_dirk"
end

function modifier_dirk_poison_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end