modifier_perfect_agony_penalty = class({})

LinkLuaModifier("modifier_weakening_venom", "abilities/true_assassin/modifiers/modifier_weakening_venom", LUA_MODIFIER_MOTION_NONE)

function modifier_perfect_agony_penalty:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			 MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_perfect_agony_penalty:GetModifierBaseDamageOutgoing_Percentage()
	if IsServer() then
		return -100
	elseif IsClient() then
        return -100 
	end
end

function modifier_perfect_agony_penalty:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local target = args.target

		if caster:GetMana() > 25 then
			local stacks = 0
			if target:HasModifier("modifier_weakening_venom") then 
				stacks = target:GetModifierStackCount("modifier_weakening_venom", ability)
			end		

			local dirkAbility = caster:FindAbilityByName("true_assassin_dirk")

			target:RemoveModifierByName("modifier_weakening_venom") 
			target:AddNewModifier(caster, dirkAbility, "modifier_weakening_venom", { duration = 12 })
			target:SetModifierStackCount("modifier_weakening_venom", dirkAbility, stacks + 1)			

			if not dirkAbility:IsCooldownReady() then
				local dirkCooldown = dirkAbility:GetCooldownTimeRemaining()
				dirkAbility:EndCooldown()

				if dirkCooldown > 1 then
					dirkAbility:StartCooldown(dirkCooldown - 1)
				end
			end

			caster:SetMana(caster:GetMana() - 25)
		end
	end
end

function modifier_perfect_agony_penalty:IsHidden()
	return false
end

function modifier_perfect_agony_penalty:IsDebuff()
	return false
end

function modifier_perfect_agony_penalty:RemoveOnDeath()
	return false
end

function modifier_perfect_agony_penalty:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_perfect_agony_penalty:GetTexture()
	return "custom/true_assassin_attribute_weakening_venom"
end