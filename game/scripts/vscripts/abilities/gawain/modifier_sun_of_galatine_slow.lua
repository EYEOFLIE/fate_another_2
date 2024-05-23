modifier_sun_of_galatine_slow = class({})

function modifier_sun_of_galatine_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_sun_of_galatine_slow:GetModifierMoveSpeedBonus_Percentage() 
    local ability = self:GetAbility()
    local slow = ability:GetSpecialValueFor("slow_perc")

    return ability:GetSpecialValueFor("slow_perc")
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_slow:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_slow:IsPurgable()
    return false
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_slow:IsDebuff()
    return true
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_slow:RemoveOnDeath()
    return true
end

-----------------------------------------------------------------------------------

function modifier_sun_of_galatine_slow:GetTexture()
    return "custom/gawain_suns_embrace"
end
-----------------------------------------------------------------------------------
