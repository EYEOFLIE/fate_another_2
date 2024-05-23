modifier_resonator_cooldown = class({})

function modifier_resonator_cooldown:IsHidden()
    return true
end

function modifier_resonator_cooldown:IsDebuff()
	return true 
end

function modifier_resonator_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end