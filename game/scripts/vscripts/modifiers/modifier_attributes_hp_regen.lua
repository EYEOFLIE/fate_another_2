modifier_attributes_hp_regen = class({})

function modifier_attributes_hp_regen:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_hp_regen:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
  return funcs
end


function modifier_attributes_hp_regen:GetModifierConstantHealthRegen()

  if IsServer() then
    local parent = self:GetParent()
    local regen = parent:GetStrength() * 0.25
    if IsValidEntity(parent) and not parent:IsNull() then
      self:SetStackCount(regen * 100)
    end
  end

  return self:GetStackCount() / 100
end


function modifier_attributes_hp_regen:IsHidden()
  return true
end

function modifier_attributes_hp_regen:IsDebuff()
  return false
end

function modifier_attributes_hp_regen:RemoveOnDeath()
  return false
end
