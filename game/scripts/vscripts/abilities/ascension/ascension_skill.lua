LinkLuaModifier("modifier_ascended", "abilities/ascension/ascension_skill", LUA_MODIFIER_MOTION_NONE)

ascension_skill = class ({})

function ascension_skill:GetIntrinsicModifierName()
	return "modifier_ascended"
end

modifier_ascended = class ({})

function modifier_ascended:IsHidden()
	return false
end

function modifier_ascended:IsDebuff()
	return false
end

function modifier_ascended:IsPermanent()
	return true
end

function modifier_ascended:IsPurgable()
	return false
end

function modifier_ascended:IsPurgeException()
	return false
end