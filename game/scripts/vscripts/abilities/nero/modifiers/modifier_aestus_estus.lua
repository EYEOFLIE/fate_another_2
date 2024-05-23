modifier_aestus_estus = class({})

function modifier_aestus_estus:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then 
	function modifier_aestus_estus:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end
		
		local caster = self:GetParent()

		DoDamage(caster, args.target, self:GetAbility():GetSpecialValueFor("agi_ratio") * caster:GetAgility(), DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
	end
end

function modifier_aestus_estus:IsPermanent()
	return true 
end

function modifier_aestus_estus:IsHidden()
	return false
end

function modifier_aestus_estus:GetTexture()
	return "custom/aestus_estus"
end
