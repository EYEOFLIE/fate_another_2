cu_chulain_disengage = class({})
cu_chulain_disengage_upgrade = class({})

function disengage_wrapper(abil)
	function abil:OnSpellStart()
		local caster = self:GetCaster()
		local backward = caster:GetForwardVector() * self:GetSpecialValueFor("distance")
		local newLoc = caster:GetAbsOrigin() - backward
		local diff = newLoc - caster:GetAbsOrigin()

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

		HardCleanse(caster)
		caster:EmitSound("Hero_PhantomLancer.Doppelwalk")
		local i = 1
		while GridNav:IsBlocked(newLoc) or not GridNav:IsTraversable(newLoc) or i == 100 do
			i = i+1
			newLoc = caster:GetAbsOrigin() + diff:Normalized() * (self:GetSpecialValueFor("distance") - i*10)
		end
		Timers:CreateTimer(0.033, function() 
			caster:SetAbsOrigin(newLoc)
			ProjectileManager:ProjectileDodge(caster) 
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end)

		if caster.IsCelticRuneAcquired then
			local heal = caster:FindAbilityByName("heal")
			caster:FateHeal(heal, caster, true)	
		end

		Timers:CreateTimer(1, function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end) 
	end
end

disengage_wrapper(cu_chulain_disengage)
disengage_wrapper(cu_chulain_disengage_upgrade)