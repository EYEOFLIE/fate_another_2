semiramis_beam_bombard = class({})
semiramis_beam_bombard_upgrade = class({})

function SemiBeamWrapper(ability)
	function ability:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("cast_range")
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:OnUpgrade()
		local caster = self:GetCaster()
		if caster.IsOldestPoisonerAcquired then
			if self:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_cloud_upgrade"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_cloud_upgrade"):SetLevel(self:GetLevel())
			end
		else
			if self:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_cloud"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_cloud"):SetLevel(self:GetLevel())
			end
		end
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local targetPoint = self:GetCursorPosition()
		local beam_numbers = self:GetSpecialValueFor("beam_numbers")
		local beamAoE = self:GetSpecialValueFor("beam_aoe")
		local damage = self:GetSpecialValueFor("damage")
		local cast_delay = self:GetSpecialValueFor("cast_delay")
		local curBeam = 1

		if caster.IsAbsoluteAcquired then 
			local bonus_beam_int = self:GetSpecialValueFor("bonus_beam_int")
			beam_numbers = beam_numbers + math.floor(caster:GetIntellect()/bonus_beam_int)
		end

	   	caster:EmitSound("Semi.CasterE")

		Timers:CreateTimer(cast_delay,function()
			local cast_spot = caster:GetAbsOrigin()
			local magic_circle_loc = cast_spot + Vector(RandomInt(-230,230), RandomInt(-230,230), RandomInt(80,220))
			

			self.Dummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
			self.Dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

			Timers:CreateTimer(function()
				if curBeam <= beam_numbers then
					curBeam = curBeam + 1

					local beamLoc = RandomPointInCircle(targetPoint, self:GetAOERadius() - beamAoE + 20)

					self:DropBeam(magic_circle_loc, beamLoc, beamAoE, damage)

					local direction = (beamLoc - magic_circle_loc):Normalized()

					local angle = VectorToAngles(direction)

					local MCFx = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_set_cicle.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(MCFx, 0, magic_circle_loc) 
					ParticleManager:SetParticleControl(MCFx, 1, Vector(0,0,angle.y + 90)) 

					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(MCFx, true)
						ParticleManager:ReleaseParticleIndex(MCFx)
					end)
					--[[local groundFx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8_crystals.vpcf", PATTACH_CUSTOMORIGIN, self.Dummy)
					ParticleManager:SetParticleControl(groundFx, 0, magic_circle_loc)
					ParticleManager:SetParticleControl(groundFx, 5, magic_circle_loc)
					ParticleManager:SetParticleControl(groundFx, 6, magic_circle_loc)]]
					
	   				caster:EmitSound("Semi.CasterESFX")

					magic_circle_loc = cast_spot + Vector(RandomInt(-230,230), RandomInt(-230,230), RandomInt(80,220))
					
					return 0.1
				else
					self.Dummy:RemoveSelf()
					
					return
				end			
			end)
		end)
	end

	function ability:DropBeam(magic_circle_loc,vLoc, fAoE, fDamage)

		Timers:CreateTimer(RandomFloat(0.17, 0.24), function()
			local caster = self:GetCaster()

			local targets = FindUnitsInRadius(caster:GetTeam(), vLoc, nil, fAoE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

			for i = 1, #targets do
				DoDamage(caster, targets[i], fDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
				if caster.IsAbsoluteAcquired then 
					if IsValidEntity(targets[i]) and targets[i]:IsAlive() and not IsImmuneToCC(targets[i]) and not targets[i]:IsMagicImmune() then
						targets[i]:AddNewModifier(caster, self, "modifier_stunned", {Duration = 0.04})
					end
				end
			end

			magic_circle_loc = magic_circle_loc + RandomVector(40)

			local beamFx = ParticleManager:CreateParticle("particles/semiramis/beam_barrage.vpcf", PATTACH_CUSTOMORIGIN, self.Dummy)
			ParticleManager:SetParticleControl(beamFx, 9, magic_circle_loc)
			ParticleManager:SetParticleControl(beamFx, 1, vLoc)
		end)
	end
end

SemiBeamWrapper(semiramis_beam_bombard)
SemiBeamWrapper(semiramis_beam_bombard_upgrade)