modifier_mad_enhancement_attribute = class({})

function modifier_mad_enhancement_attribute:IsHidden()
	return true
end

function modifier_mad_enhancement_attribute:IsPermanent()
	return true
end

function modifier_mad_enhancement_attribute:RemoveOnDeath()
	return false
end

function modifier_mad_enhancement_attribute:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end