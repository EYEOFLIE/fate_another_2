artoria_charisma = class{()}
modifier_artoria_charisma_aura = class{()}
modifier_artoria_charisma_buff = class{()}

LinkLuaModifier("modifier_artoria_charisma_aura", "abilities/artoria/artoria_charisma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_artoria_charisma_buff", "abilities/artoria/artoria_charisma", LUA_MODIFIER_MOTION_NONE)

function artoria_charisma:GetIntrinsicModifierName()
	return "modifier_artoria_charisma_aura"
end

function artoria_charisma:GetAbilityTextureName()
	return "custom/artoria/saber_charisma"
end

--------------------------------------------------------------

function modifier_artoria_charisma_aura:IsAura()
	return true 
end

function modifier_artoria_charisma_aura:IsAuraActiveOnDeath()
	return false 
end

function modifier_artoria_charisma_aura:IsHidden() 
	return true 
end

function modifier_artoria_charisma_aura:IsDebuff() 
	return false 
end 

function modifier_artoria_charisma_aura:IsPassive() 
	return true 
end

function modifier_artoria_charisma_aura:RemoveOnDeath() 
	return false 
end

function modifier_artoria_charisma_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_artoria_charisma_aura:GetAuraRadius() 
	return self:GetAbility():GetSpecialValueFor("range")
end 

function modifier_artoria_charisma_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_artoria_charisma_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_artoria_charisma_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_artoria_charisma_aura:GetModifierAura()
	return "modifier_artoria_charisma_buff"
end 

function modifier_artoria_charisma_aura:IsRemoveOnRoundStart()
	return false 
end

-------------------------------------------------------------

function modifier_artoria_charisma_buff:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_artoria_charisma_buff:IsHidden()
	return false 
end

function modifier_artoria_charisma_buff:IsDebuff()
	return false 
end

function modifier_artoria_charisma_buff:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return func
end

function modifier_artoria_charisma_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end

function modifier_artoria_charisma_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_artoria_charisma_buff:GetEffectName()
	return "particles/items2_fx/rod_of_atos_debuff_ground.vpcf"
end

function modifier_artoria_charisma_buff:GetEffectAttachType()
	return "follow_origin"
end