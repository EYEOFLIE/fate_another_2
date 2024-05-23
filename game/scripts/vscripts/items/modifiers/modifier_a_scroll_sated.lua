modifier_a_scroll_sated = class({})

function modifier_a_scroll_sated:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_a_scroll_sated:IsHidden()
	return false
end

function modifier_a_scroll_sated:IsDebuff()
	return true 
end

function modifier_a_scroll_sated:RemoveOnDeath()
	return true 
end

function modifier_a_scroll_sated:GetTexture()
    return "custom/a_scroll_debuff"
end

-------------------------

modifier_a_scroll_2 = class({})

function modifier_a_scroll_2:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_a_scroll_2:IsHidden()
	return false
end

function modifier_a_scroll_2:IsDebuff()
	return true 
end

function modifier_a_scroll_2:RemoveOnDeath()
	return true 
end

function modifier_a_scroll_2:GetTexture()
    return "custom/a_scroll_debuff"
end