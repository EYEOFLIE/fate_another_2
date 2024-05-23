modifier_attributes_as = class({})


function modifier_attributes_as:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_as:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end


function modifier_attributes_as:GetModifierAttackSpeedBonus_Constant()
--math.abs(agility * Attributes.attackspeed_adjustment)
  if IsServer() then
    local parent = self:GetParent()
    if parent:IsIllusion() then 
      --print('illusion')
      return nil
    end
    --if parent:IsIllusion() and parent:GetPlayerOwner():GetAssignedHero():GetName() == "npc_dota_hero_windrunner" then return end
    if IsValidEntity(parent) and not parent:IsNull() then
      self:SetStackCount(math.abs(parent:GetAgility()*parent.attackspeed_adjustment))
    end
  end
  return self:GetStackCount()
end


function modifier_attributes_as:IsHidden()
  return true
end

function modifier_attributes_as:IsDebuff()
  return false
end

function modifier_attributes_as:RemoveOnDeath()
  return false
end
