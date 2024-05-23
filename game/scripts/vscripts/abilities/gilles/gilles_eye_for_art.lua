gilles_eye_for_art_passive = class({})
modifier_eye_for_art_aura = class({})
modifier_eye_for_art_trigger = class({})
modifier_eye_for_art_vision = class({})

LinkLuaModifier("modifier_eye_for_art_aura", "abilities/gilles/gilles_eye_for_art", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_eye_for_art_trigger", "abilities/gilles/gilles_eye_for_art", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_eye_for_art_vision", "abilities/gilles/gilles_eye_for_art", LUA_MODIFIER_MOTION_NONE)

-- Passive
function gilles_eye_for_art_passive:GetIntrinsicModifierName()
	return "modifier_eye_for_art_aura"
end

-- Vision provider buff
function modifier_eye_for_art_vision:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
end

function modifier_eye_for_art_vision:GetModifierProvidesFOWVision()
	return 1
end

function modifier_eye_for_art_vision:IsHidden()
	return false
end

function modifier_eye_for_art_vision:IsDebuff()
    return true
end

function modifier_eye_for_art_vision:RemoveOnDeath()
    return true
end

function modifier_eye_for_art_vision:GetTexture()
	return "custom/gille_attribute_eye_for_art"
end 

function modifier_eye_for_art_vision:GetEffectName()
	return "particles/custom/gilles/gilles_eye.vpcf"
end

function modifier_eye_for_art_vision:GetEffectAttachType()
	return "follow_overhead"
end

-- Buff to check for skill usage
function modifier_eye_for_art_trigger:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

if IsServer() then 
	function modifier_eye_for_art_trigger:OnAbilityFullyCast(args)
		if args.unit ~= self:GetParent() or args.ability:IsItem() or IsSpellBook(args.ability:GetAbilityName()) then return end

		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_eye_for_art_vision", { Duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
end

function modifier_eye_for_art_trigger:IsDebuff()
	return true
end

function modifier_eye_for_art_trigger:IsHidden() 
	return true 
end

-- Aura
function modifier_eye_for_art_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_eye_for_art_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_eye_for_art_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_eye_for_art_aura:GetModifierAura()
	return "modifier_eye_for_art_trigger"
end

function modifier_eye_for_art_aura:IsHidden()
	return true 
end

function modifier_eye_for_art_aura:IsPermanent()
	return false
end

function modifier_eye_for_art_aura:IsDebuff()
	return false 
end

function modifier_eye_for_art_aura:IsAura()
	return true 
end