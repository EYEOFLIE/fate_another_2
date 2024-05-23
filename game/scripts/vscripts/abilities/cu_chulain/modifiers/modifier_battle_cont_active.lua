modifier_battle_cont_active = class({})

LinkLuaModifier("modifier_battle_cont_cooldown", "abilities/cu_chulain/modifiers/modifier_battle_cont_cooldown", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_battle_cont_active:OnDestroy()
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName("cu_chulain_battle_continuation")

		caster:AddNewModifier(caster, ability, "modifier_battle_cont_cooldown", { Duration = ability:GetSpecialValueFor("cooldown")})
		ability:StartCooldown(ability:GetSpecialValueFor("cooldown"))
	end
end

function modifier_battle_cont_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end