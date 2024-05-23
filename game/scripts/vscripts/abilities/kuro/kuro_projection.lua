kuro_projection = class({})

LinkLuaModifier("modifier_projection_active", "abilities/kuro/modifiers/modifier_projection_active", LUA_MODIFIER_MOTION_NONE)

function kuro_projection:OnSpellStart()
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_projection_active", { Duration = 5 })
end