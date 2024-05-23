modifier_command_seal_5 = class({})

function modifier_command_seal_5:IsHidden()
	return false 
end

function modifier_command_seal_5:RemoveOnDeath()
	return false
end

function modifier_command_seal_5:IsDebuff()
	return true 
end

function modifier_command_seal_5:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_command_seal_5:GetTexture()
	return "custom/master/master_intervention"
end