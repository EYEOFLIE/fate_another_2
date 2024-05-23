modifier_sun_of_galatine_self = class({})

function modifier_sun_of_galatine_self:DeclareFunctions()
    local funcs = {}
 
    return funcs
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_self:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_sun_of_galatine_self:IsPurgable()
    return false
end

function modifier_sun_of_galatine_self:IsDebuff()
    return false
end

function modifier_sun_of_galatine_self:RemoveOnDeath()
    return true
end

function modifier_sun_of_galatine_self:GetTexture()
    return "custom/gawain_suns_embrace"
end

-----------------------------------------------------------------------------------
