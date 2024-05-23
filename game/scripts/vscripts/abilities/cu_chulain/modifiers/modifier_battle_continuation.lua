modifier_battle_continuation = class({})

LinkLuaModifier("modifier_battle_cont_active", "abilities/cu_chulain/modifiers/modifier_battle_cont_active", LUA_MODIFIER_MOTION_NONE)

function modifier_battle_continuation:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

if IsServer() then
	function modifier_battle_continuation:OnTakeDamage(args)
		if args.unit ~= self:GetParent() then return end
		local ability = self:GetAbility()
		local caster = self:GetParent()

		if args.damage < ability:GetSpecialValueFor("max_damage") 
			and caster:GetHealth() <= 0 
			and not caster:HasModifier("modifier_battle_cont_cooldown") 
			and IsRevivePossible(caster)
			then

			caster:SetHealth(1)

			if not caster:HasModifier("modifier_battle_cont_active") then
				HardCleanse(caster)
				caster:EmitSound("Cu_Battlecont")
				caster:AddNewModifier(caster, ability, "modifier_battle_cont_active", { Duration = ability:GetSpecialValueFor("active_dur") })
			end
		end
	end
end

function modifier_battle_continuation:IsHidden()
	return true 
end


