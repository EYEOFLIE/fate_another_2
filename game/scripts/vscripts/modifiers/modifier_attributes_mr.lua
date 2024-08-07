modifier_attributes_mr = class({})


function modifier_attributes_mr:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_mr:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
  }
  return funcs
end


function modifier_attributes_mr:GetModifierMagicalResistanceBonus()
--math.abs(intellect * Attributes.mana_regen_adjustment * 100)
  --[[if IsServer() then
    local parent = self:GetParent()
    self:SetStackCount(math.abs(math.ceil(parent:GetIntellect())*parent.mana_regen_adjustment*100))
    parent.intellect_mana_regen = self:GetStackCount() / 100
  end
  return self:GetStackCount()/100]]


  --if IsServer() then
    local parent = self:GetParent()
    if IsValidEntity(parent) and not parent:IsNull() then
      self:SetStackCount(parent:GetIntellect(true) * 10)
      --print(self:GetStackCount())
    end
  --end
  return -self:GetStackCount() / 100
end


function modifier_attributes_mr:IsHidden()
  return true
end

function modifier_attributes_mr:OnCreated()
  print('modifier attribute mr has been created')
end

function modifier_attributes_mr:IsDebuff()
  return false
end

function modifier_attributes_mr:RemoveOnDeath()
  return false
end
