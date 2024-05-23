karna_vasavi_shakti = class({})
karna_vasavi_shakti_upgrade = class({})

LinkLuaModifier("modifier_vasavi_thinker", "abilities/karna/modifiers/modifier_vasavi_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vision_provider", "abilities/general/modifiers/modifier_vision_provider", LUA_MODIFIER_MOTION_NONE)

function karna_vasavi_shakti_wrapper(ability)
	function ability:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("cast_range")
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()

		local ascendCount = 0
		local descendCount = 0

		if caster:HasModifier('modifier_alternate_02') then 
			caster:EmitSound("Karna.Skin.R" .. math.random(1,3))
		end	

		local damage = self:GetSpecialValueFor("damage")
		--[[local dummy = CreateUnitByName("dummy_unit", target_point, false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)]]
		
		if caster.IndraAttribute then 
			damage = damage + (self:GetSpecialValueFor("bonus_agi") * caster:GetAgility())
		end



		--[[local enemy = PickRandomEnemy(caster)
		if enemy ~= nil then
			dummy:AddNewModifier(enemy, self, "modifier_vision_provider", { Duration = 5 })
		end	]]

		giveUnitDataDrivenModifier(caster, caster, "jump_pause", 2.8)
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postlock", 3)
		StartAnimation(caster, {duration=0.45, activity=ACT_DOTA_CAST_ABILITY_4, rate=2.2})

		local modifier = caster:FindModifierByName("modifier_kavacha_kundala")

		if modifier then
			modifier:RemoveArmor(self:GetSpecialValueFor("remove_duration"))
		end

		Timers:CreateTimer('vas_asc_' .. caster:GetPlayerOwnerID(), {
			endTime = 0,
			callback = function()
		   	if ascendCount == 15 and caster:IsAlive() then 
		   		StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1})

				if caster:HasModifier('modifier_alternate_02') then 
			   		Timers:CreateTimer(0.15, function()
			   			EmitGlobalSound("karna_vasavi_short_" .. math.random(1,2))
					end)
				else
		   			EmitGlobalSound("karna_vasavi_short_" .. math.random(1,2))
				end

		   		local beam_particle = ParticleManager:CreateParticle("particles/custom/karna/vasavi_shakti/vasavi_shakti_beam.vpcf", PATTACH_CUSTOMORIGIN, caster)
		   		ParticleManager:SetParticleControlEnt(beam_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_lance", caster:GetOrigin(), true)
		   		--ParticleManager:SetParticleControl(beam_particle, 0, Vector(caster:GetOrigin().x, caster:GetOrigin().y, caster:GetOrigin().z + 50))
		   		ParticleManager:SetParticleControl(beam_particle, 1, target_point) 
		   		local ground_fx = "particles/custom/karna/vasavi_shakti/vasavi_ground.vpcf"
		   		if self:GetCaster():HasModifier("modifier_alternate_02") then 
		   			ground_fx = "particles/custom/karna/vasavi_shakti/vasavi_blue_ground.vpcf"
		   		end

		   		self.FireParticle = ParticleManager:CreateParticle(ground_fx, PATTACH_WORLDORIGIN, caster)
		   		ParticleManager:SetParticleControl(self.FireParticle, 0, target_point) 

		   		CreateModifierThinker(caster, self, "modifier_vasavi_thinker", { Duration = 1.15,
																				 Damage = damage,
																				 BonusDivine = self:GetSpecialValueFor("bonus_divine"),
																				 Radius = self:GetAOERadius()}
																				, target_point, caster:GetTeamNumber(), false)

		   		EmitGlobalSound("karna_vasavi_explosion")

		   		Timers:CreateTimer(1.2, function()
					ParticleManager:DestroyParticle(beam_particle, true)
					ParticleManager:ReleaseParticleIndex(beam_particle)
					--dummy:RemoveSelf()
					
					return
				end)

			   	return
			elseif ascendCount == 15 then
				return
			end

			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+30))
			ascendCount = ascendCount + 1;
			return 0.033
		end
		})

		Timers:CreateTimer("vas_desc_" .. caster:GetPlayerOwnerID(), {
		    endTime = 2.3,
		    callback = function()
		    	if descendCount == 15 then return end	    	

				caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-30))
				descendCount = descendCount + 1;
		      	return 0.033
		    end
		})

		Timers:CreateTimer(1.7, function()		
			if self.FireParticle then
				ParticleManager:DestroyParticle(self.FireParticle, true)
				ParticleManager:ReleaseParticleIndex(self.FireParticle)		
			end
			return
		end)
	end
end

karna_vasavi_shakti_wrapper(karna_vasavi_shakti)
karna_vasavi_shakti_wrapper(karna_vasavi_shakti_upgrade)
--[[function karna_vasavi_shakti:OnOwnerDied()
	if not self.FxDestroyed then
		ParticleManager:DestroyParticle(self.FireParticle, true)
		ParticleManager:ReleaseParticleIndex(self.FireParticle)
	end
end]]