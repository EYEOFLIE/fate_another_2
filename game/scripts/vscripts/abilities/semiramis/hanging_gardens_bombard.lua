hanging_gardens_bombard = class({})

function hanging_gardens_bombard:GetAOERadius()
	return self:GetSpecialValueFor("beam_aoe")
end

function hanging_gardens_bombard:OnSpellStart()
	local caster = self:GetCaster()
	local targetPoint = self:GetCursorPosition()
	local beamAoE = self:GetSpecialValueFor("beam_aoe")
	local extra_beam = self:GetSpecialValueFor("extra_beam")
	local extra_beam_range = self:GetSpecialValueFor("extra_beam_range")
	local cast_delay = self:GetSpecialValueFor("cast_delay")
	local damage = self:GetSpecialValueFor("damage")


	Timers:CreateTimer(cast_delay, function()
		if caster:HasModifier("modifier_garden_mounted") then
			self:DropBeam(targetPoint, beamAoE, damage)
			local ransec = RandomFloat(0.3 , 0.6)
			for i = extra_beam,1,-1 do	
				Timers:CreateTimer(ransec + (0.325 * i), function()
					local vecran = RandomVector(extra_beam_range)
					self:DropBeam(targetPoint + vecran, beamAoE, damage)
				end)
			end
		else
			self:DropBeam(targetPoint, beamAoE, damage)
		end
	end)
end

function hanging_gardens_bombard:DropBeam(vLoc, fAoE, fDamage)
	local caster = self:GetCaster()

	local targets = FindUnitsInRadius(caster:GetTeam(), vLoc, nil, fAoE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

	for i = 1, #targets do
		DoDamage(caster, targets[i], fDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	end

	EmitSoundOnLocationWithCaster(vLoc, "Semi.GardenBeamSFX", {})
	EmitSoundOnLocationWithCaster(vLoc, "Semi.GardenBeamSFX2", {})

	local beamFx = ParticleManager:CreateParticle("particles/custom/semiramis/laser_beam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(beamFx, 0, vLoc)
	ParticleManager:SetParticleControl(beamFx, 1, vLoc)
	ParticleManager:SetParticleControl(beamFx, 5, vLoc)
end