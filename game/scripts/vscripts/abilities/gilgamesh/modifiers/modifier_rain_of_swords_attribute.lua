modifier_rain_of_swords_attribute = class({})

function modifier_rain_of_swords_attribute:IsHidden()
	return true
end

function modifier_rain_of_swords_attribute:IsPermanent()
	return true
end

function modifier_rain_of_swords_attribute:RemoveOnDeath()
	return false
end

function modifier_rain_of_swords_attribute:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end