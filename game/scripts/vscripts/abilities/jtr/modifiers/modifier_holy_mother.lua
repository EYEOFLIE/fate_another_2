modifier_holy_mother = class({})

LinkLuaModifier("modifier_holy_mother_buff", "abilities/jtr/modifiers/modifier_holy_mother_buff", LUA_MODIFIER_MOTION_NONE)

function modifier_holy_mother:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then 
	function modifier_holy_mother:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		local target = args.target
		local caster = self:GetParent()
		if IsFemaleServant(target) then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_holy_mother_buff", { Duration = self:GetAbility():GetSpecialValueFor("duration"),
																						    AgiPerStack = self:GetAbility():GetSpecialValueFor("agi_per_stack")})
		end
	end
end

function modifier_holy_mother:IsHidden()
	return true 
end