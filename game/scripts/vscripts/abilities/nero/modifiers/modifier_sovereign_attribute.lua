modifier_sovereign_attribute = class({})

function modifier_sovereign_attribute:IsHidden()
	return true
end

function modifier_sovereign_attribute:IsPermanent()
	return true
end

function modifier_sovereign_attribute:RemoveOnDeath()
	return false
end

function modifier_sovereign_attribute:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end