semiramis_binding_chains = class({})

LinkLuaModifier("modifier_binding_chains", "abilities/semiramis/modifiers/modifier_binding_chains", LUA_MODIFIER_MOTION_NONE)

function semiramis_binding_chains:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local bind_duration = self:GetSpecialValueFor("max_dur")
	local min_dur = self:GetSpecialValueFor("min_dur")
	local mr_red = self:GetSpecialValueFor("mr_red")

	local magic_res = target:GetBaseMagicalResistanceValue()/100

	bind_duration = math.max(min_dur, bind_duration * (1 - magic_res))
	
	target:AddNewModifier(caster, self, "modifier_binding_chains", { Duration = bind_duration, MagicResist = mr_red })
end