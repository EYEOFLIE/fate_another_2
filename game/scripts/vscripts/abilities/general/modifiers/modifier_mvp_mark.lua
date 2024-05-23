modifier_mvp_mark = class({})

function modifier_mvp_mark:GetEffectName()
	return "particles/custom/generic/fate_mvp_mark.vpcf"
end

function modifier_mvp_mark:GetEffectAttachType()
	return "follow_overhead"
end

function modifier_mvp_mark:DeclareFunctions()
    return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
end

function modifier_mvp_mark:GetModifierProvidesFOWVision()
    return 1
end

function modifier_mvp_mark:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mvp_mark:IsDebuff()
    return true
end

function modifier_mvp_mark:IsHidden()
    return false 
end