modifier_poisonous_bite = class({})

LinkLuaModifier("modifier_poisonous_bite", "abilities/semiramis/modifiers/modifier_poisonous_bite", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_poisonous_bite_slow", "abilities/semiramis/modifiers/modifier_poisonous_bite_slow", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_poisonous_bite:OnCreated(args)		
		self.Damage = args.Damage
		self.AOE = args.AOE
		
		--target:EmitSound(soundname)
		local target = self:GetParent()
		local particle = ParticleManager:CreateParticle("particles/semiramis/basmu_claw_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

		local particlewound = ParticleManager:CreateParticle("particles/custom/semiramis/open_wounds.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particlewound, 0, target:GetAbsOrigin())

		Timers:CreateTimer(2.5, function()
			ParticleManager:DestroyParticle( particlewound, false )
		end)

		self:StartIntervalThink(0.25)
	end

	function modifier_poisonous_bite:OnRefresh(args)
		self:OnCreated(args)
	end

	function modifier_poisonous_bite:OnIntervalThink()
		local damage = self.Damage / (4*self:GetAbility():GetSpecialValueFor("duration"))
		local dps_per_int  = self:GetAbility():GetSpecialValueFor("dps_per_int")

	   	if  self:GetCaster().IsCharmAcquired then
			DoDamage(self:GetCaster(), self:GetParent(), damage + dps_per_int * self:GetCaster():GetIntellect() , DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
		else
			DoDamage(self:GetCaster(), self:GetParent(), damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
		end

	end

	function modifier_poisonous_bite:OnDestroy()
		local parent = self:GetParent()
		local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self.AOE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		local ability = self:GetAbility()		

		local particle = ParticleManager:CreateParticle("particles/custom/semiramis/basmu_poison_d.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 1, Vector(ability:GetSpecialValueFor("radius") , 0, 0))


	   	parent:EmitSound("Semi.AssassinRSFXPop")
	   	parent:EmitSound("Semi.AssassinRSFXPop2")

		for i = 1, #enemies do
			if enemies[i] ~= self:GetParent() then
				enemies[i]:AddNewModifier(self:GetCaster(), ability, "modifier_poisonous_bite", { Duration = ability:GetSpecialValueFor("duration"),
																								  Damage = ability:GetSpecialValueFor("damage"),
																								  AOE = ability:GetSpecialValueFor("radius")})

				self:CreatePoisonFx(enemies[i])

				if not IsImmuneToSlow(enemies[i]) then
					enemies[i]:AddNewModifier(self:GetCaster(), ability, "modifier_poisonous_bite_slow", { Slow = ability:GetSpecialValueFor("slow"),
																									   		SlowInc = ability:GetSpecialValueFor("slow_inc") })
				end
			end
		end		
	end

	function modifier_poisonous_bite:CreatePoisonFx(target)

		local particle5 = ParticleManager:CreateParticle("particles/econ/events/diretide_2020/high_five/high_five_impact_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle5, 3, target:GetAbsOrigin())

	end
end

function modifier_poisonous_bite:IsHidden()
	return true 
end

function modifier_poisonous_bite:RemoveOnDeath()
	return true
end

function modifier_poisonous_bite:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

