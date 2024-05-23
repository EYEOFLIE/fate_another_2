modifier_whitechapel_murderer = class({})

LinkLuaModifier("modifier_whitechapel_murderer_crit", "abilities/jtr/modifiers/modifier_whitechapel_murderer_crit", LUA_MODIFIER_MOTION_NONE)

function modifier_whitechapel_murderer:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_START,
			 MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			 MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

if IsServer() then
	function modifier_whitechapel_murderer:OnCreated(args)
		self.AgiBonus = args.AgiBonus

		CustomNetTables:SetTableValue("sync","whitechapel_murderer", { agility_bonus = self.AgiBonus })

		self.ParticleDummy = CreateUnitByName("dummy_unit", self:GetParent():GetAbsOrigin(), false, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber())
		self.ParticleDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

		self.Particle = ParticleManager:CreateParticle("particles/custom/jtr/invis_smoke.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.ParticleDummy)

	    ParticleManager:SetParticleControl(self.Particle, 1, self.ParticleDummy:GetAbsOrigin())

	    self:StartIntervalThink(0.033)
	end

	function modifier_whitechapel_murderer:OnIntervalThink()
		self.ParticleDummy:SetAbsOrigin(self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.Particle, 1, self.ParticleDummy:GetAbsOrigin())
	end

	function modifier_whitechapel_murderer:OnDestroy()
		self:GetAbility():EndCombo()

		ParticleManager:DestroyParticle(self.Particle, false)
		ParticleManager:ReleaseParticleIndex(self.Particle)
		self.ParticleDummy:RemoveSelf()
	end

	function modifier_whitechapel_murderer:OnAttackStart(args)
		if args.attacker ~= self:GetParent() then return end

		if RandomInt(1, 100) <= 35 then
			args.attacker:AddNewModifier(args.attacker, self:GetAbility(), "modifier_whitechapel_murderer_crit", { Duration = 1 })
		end
	end
	
	function modifier_whitechapel_murderer:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		self:GetParent():RemoveModifierByName("modifier_whitechapel_murderer_crit")
	end

	function modifier_whitechapel_murderer:CheckState()
		return { [MODIFIER_STATE_INVISIBLE] = true,
				 [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true }
	end
end

function modifier_whitechapel_murderer:GetModifierBonusStats_Agility()
	if IsServer() then
		return self.AgiBonus
	elseif IsClient() then
		local agility_bonus = CustomNetTables:GetTableValue("sync","whitechapel_murderer").agility_bonus
        return agility_bonus 		
	end
end

function modifier_whitechapel_murderer:GetTexture()
	return "custom/jtr/whitechapel_murderer"
end