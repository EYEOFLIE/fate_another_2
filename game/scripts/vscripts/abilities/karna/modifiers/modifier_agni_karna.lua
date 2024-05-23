modifier_agni_karna = class({})

LinkLuaModifier("modifier_agni_burn", "abilities/karna/modifiers/modifier_agni_burn", LUA_MODIFIER_MOTION_NONE)

function modifier_agni_karna:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then
	function modifier_agni_karna:OnCreated(args)
		self.OnHitDamage = args.OnHitDamage
		self.BurnDamage = args.BurnDamage
		self.BurnDuration = args.BurnDuration
		self.BurnAOE = args.BurnAOE
		self.ExplodeAOE = args.ExplodeAOE
		self.ExplodeDamage = args.ExplodeDamage
		self.ExplodeStun = args.ExplodeStun
		self.ExplodeHitCount = args.ExplodeHitCount

		self:AttachParticle()
	end

	function modifier_agni_karna:OnRefresh(args)
		self:DetachParticle()
		self:OnCreated(args)
	end

	function modifier_agni_karna:OnDestroy()
		self:DetachParticle()
	end

	function modifier_agni_karna:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		local caster = self:GetParent()
		local target = args.target
		local ability = self:GetAbility()

		local modifier = target:AddNewModifier(caster, ability, "modifier_agni_burn", { Duration = self.BurnDuration,
																	   					BurnDamage = self.BurnDamage})

		local damage = self.OnHitDamage
		local stacks = 0

		if modifier then
			stacks = modifier:GetStackCount()
		end

		damage = damage + (damage * stacks)
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

		local burn_targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, self.BurnAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

		if #burn_targets > 1 then
			for i = 1, #burn_targets do
				if IsValidEntity(burn_targets[i]) and not burn_targets[i]:IsNull() then
					burn_targets[i]:AddNewModifier(caster, ability, "modifier_agni_burn", { Duration = self.BurnDuration,
																		   				BurnDamage = self.BurnDamage})
				end
			end
		end

		if caster.ManaBurstAttribute and stacks % self.ExplodeHitCount < 1 then
			target:AddNewModifier(caster, target, "modifier_stunned", {Duration = self.ExplodeStun })

			local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, self.ExplodeAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(enemies) do
				if IsValidEntity(v) and not v:IsNull() then
					v:EmitSound("karna_agni_explosion")

			        local particle_fx = "particles/custom/karna/agni/agni_explosion.vpcf"
					if caster:HasModifier('modifier_alternate_02') then 
						particle_fx = "particles/custom/karna/agni/agni_blue_explosion.vpcf"
					end		        

			        local particle = ParticleManager:CreateParticle(particle_fx, PATTACH_ABSORIGIN, target)
					ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 

					DoDamage(caster, v, self.ExplodeDamage * stacks, DAMAGE_TYPE_MAGICAL, 0, ability, false)

					Timers:CreateTimer(2, function()
						ParticleManager:DestroyParticle(particle, false)
						ParticleManager:ReleaseParticleIndex(particle)

						return
					end)
				end
		    end
		end
	end

	function modifier_agni_karna:AttachParticle()
		local caster = self:GetParent()
		local particle_fx = "particles/custom/karna/agni/agni_fire_ambient.vpcf"
		if caster:HasModifier('modifier_alternate_02') then 
			particle_fx = "particles/custom/karna/agni/agni_blue_fire_ambient.vpcf"
		end
		self.particle = ParticleManager:CreateParticle(particle_fx, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_hitloc", caster:GetOrigin(), true)
	end

	function modifier_agni_karna:DetachParticle()
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end



function modifier_agni_karna:IsDebuff()
	return false
end

function modifier_agni_karna:RemoveOnDeath()
	return true 
end