jtr_quick_strikes = class({})

LinkLuaModifier("modifier_jtr_quick_strikes", "abilities/jtr/modifiers/modifier_jtr_quick_strikes", LUA_MODIFIER_MOTION_NONE)

function jtr_quick_strikes:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:AddNewModifier(caster, self, "modifier_jtr_quick_strikes", {})
end
