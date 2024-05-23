modifier_surgical_procedure = class({})

function modifier_surgical_procedure:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then 
	function modifier_surgical_procedure:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local ability = self:GetAbility()
		local healing = ability:GetSpecialValueFor("base_healing") + caster:GetAgility()

		healing = math.min(caster:GetMaxHealth() * 0.07, healing)
		local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

		for k, v in pairs(allies) do
			v:Heal(healing, caster)
		end
	end
end

function modifier_surgical_procedure:GetTexture()
	return "custom/jtr/surgical_procedure"
end