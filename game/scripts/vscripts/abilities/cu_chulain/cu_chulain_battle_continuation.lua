cu_chulain_battle_continuation = class({})

LinkLuaModifier("modifier_battle_continuation", "abilities/cu_chulain/modifiers/modifier_battle_continuation", LUA_MODIFIER_MOTION_NONE)

function cu_chulain_battle_continuation:GetCooldown(iLevel)
	return self:GetSpecialValueFor("cooldown")
end

function cu_chulain_battle_continuation:GetIntrinsicModifierName()
	return "modifier_battle_continuation"
end