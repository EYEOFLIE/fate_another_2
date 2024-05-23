modifier_projection_active = class({})

function modifier_projection_active:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_projection_active:IsPurgable()
    return false
end

function modifier_projection_active:IsDebuff()
    return false
end

function modifier_projection_active:RemoveOnDeath()
    return true
end

function modifier_projection_active:GetTexture()
    return "custom/kuro/kuro_attribute_projection"
end

-----------------------------------------------------------------------------------
