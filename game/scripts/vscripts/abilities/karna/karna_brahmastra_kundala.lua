karna_brahmastra_kundala = class({})
karna_brahmastra_kundala_upgrade = class({})

function karna_brahmastra_kundala_wrapper(ability)
	function ability:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("cast_range")
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:OnAbilityPhaseStart()
		local caster = self:GetCaster()

		caster:EmitSound("karna_sunstrike_1")

		return true 
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local small_radius = self:GetSpecialValueFor("small_radius")
		local large_radius = self:GetSpecialValueFor("radius")
		local full_damage = self:GetSpecialValueFor("damage")
		local delay = self:GetSpecialValueFor("delay")
		local half_damage = self:GetSpecialValueFor("min_damage")
		
		local target_ray = ParticleManager:CreateParticleForTeam("particles/custom/karna/brahmastra_kundala/brahmastra_kundala_ray.vpcf", PATTACH_ABSORIGIN, caster, caster:GetTeamNumber())
		ParticleManager:SetParticleControl(target_ray, 0, target_point) 
		ParticleManager:SetParticleControl(target_ray, 1, Vector(100,0,0))

		local visiondummy = SpawnVisionDummy(caster, target_point, small_radius, delay + 1, false)

		Timers:CreateTimer(0.4, function()
			caster:EmitSound("karna_sunstrike_2")
			return
		end)
		
		EmitSoundOnLocationForAllies(target_point, "karna_brahmastra_kundala_cast", caster)	

		local throw_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(throw_particle, 1, (target_point + Vector(0, 0, 1500) - caster:GetAbsOrigin()):Normalized() * 2500)

		Timers:CreateTimer(delay, function()  
	      
	        local outer_targets = FindUnitsInRadius(caster:GetTeam(), target_point, nil, large_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	        for k,v in pairs(outer_targets) do
	        	if IsValidEntity(v) and not v:IsNull() then
		        	local distance = (v:GetAbsOrigin() - target_point):Length2D()
		        	local far = 1 - (distance / large_radius )

		        	if distance <= small_radius then
		            	DoDamage(caster, v, full_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		            else
		            	DoDamage(caster, v, half_damage * (1 + ((distance - small_radius) / (large_radius - small_radius))), DAMAGE_TYPE_MAGICAL, 0, self, false)
		        	end
		        end 
		    end

	        local particle = ParticleManager:CreateParticle("particles/custom/karna/brahmastra_kundala/brahmastra_kundala_explosion_beam.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, target_point + Vector(0,0,100)) 

			EmitGlobalSound("karna_brahmastra_kundala_explosion")

			Timers:CreateTimer(2, function()
				ParticleManager:DestroyParticle(particle, false)
				ParticleManager:ReleaseParticleIndex(particle)
				ParticleManager:DestroyParticle(target_ray, false)
				ParticleManager:ReleaseParticleIndex(target_ray)
				ParticleManager:DestroyParticle(throw_particle, false)
				ParticleManager:ReleaseParticleIndex(throw_particle)
				return
			end)

	        return 
	    end)
	end
end

karna_brahmastra_kundala_wrapper(karna_brahmastra_kundala)
karna_brahmastra_kundala_wrapper(karna_brahmastra_kundala_upgrade)