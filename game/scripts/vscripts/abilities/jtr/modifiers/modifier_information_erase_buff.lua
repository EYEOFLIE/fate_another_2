modifier_information_erase_buff = class({})

function modifier_information_erase_buff:CheckState()
	return { [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true }
end

function modifier_information_erase_buff:IsDebuff()
	return false 
end

function modifier_information_erase_buff:RemoveOnDeath()
	return true 
end

function modifier_information_erase_buff:IsHidden()
	return false
end