modifier_sex_scroll_root = class({})

--LinkLuaModifier("modifier_sex_scroll_slow","items/modifiers/modifier_sex_scroll_slow.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_sex_scroll_root:OnCreated(args)
    
end

function modifier_sex_scroll_root:OnRefresh(args)
    
end

function modifier_sex_scroll_root:CheckState()   
    return {[MODIFIER_STATE_ROOTED] = true}
end

--function modifier_sex_scroll_root:OnDestroy()
    
--end

-----------------------------------------------------------------------------------
function modifier_sex_scroll_root:GetEffectName()
    --return "particles/items_fx/diffusal_slow.vpcf"
end

function modifier_sex_scroll_root:GetEffectAttachType()
    --return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sex_scroll_root:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_sex_scroll_root:IsPurgable()
    return false
end

function modifier_sex_scroll_root:IsDebuff()
    return true
end

function modifier_sex_scroll_root:IsPassive()
    return false
end

function modifier_sex_scroll_root:IsHidden()
    return false
end

function modifier_sex_scroll_root:RemoveOnDeath()
    return true
end

function modifier_sex_scroll_root:GetTexture()
    return "custom/s_scroll"
end
-----------------------------------------------------------------------------------
