gilles_grief = class({})
gilles_grief_upgrade = class({})
modifier_gilles_grief = class({})

LinkLuaModifier("modifier_gilles_grief", "abilities/gilles/gilles_grief", LUA_MODIFIER_MOTION_NONE)

function grief_wrapper(abil)
	function abil:CastFilterResultTarget(hTarget)
		local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())

		if(filter == UF_SUCCESS) then
			if hTarget:GetName() == "npc_dota_ward_base" or hTarget == self:GetCaster() then 
				return UF_FAIL_CUSTOM 
			else
				return UF_SUCCESS
			end
		else
			return filter
		end
	end

	function abil:IsHiddenAbilityCastable()
		return true
	end

	function abil:GetCustomCastErrorTarget(hTarget)
		return "Invalid Target"
	end

	--[[function gilles_grief:GetManaCost(iLevel)
		return (self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost") / 100)
	end]]

	function abil:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function abil:OnSpellStart()
		local hCaster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
		
		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Gilles_Grief_Cast", hCaster)

		hTarget:AddNewModifier(hCaster, self, "modifier_gilles_grief", { Damage = self:GetSpecialValueFor("damage"),
																		 Duration = self:GetSpecialValueFor("duration") })
	end
end

grief_wrapper(gilles_grief)
grief_wrapper(gilles_grief_upgrade)

if IsServer() then 
	function modifier_gilles_grief:OnCreated(args)
		self.Damage = args.Damage

		if self:GetParent().Particle == nil then
			self:GetParent().Particle = ParticleManager:CreateParticle("particles/econ/items/sand_king/sandking_ti7_arms/sandking_ti7_caustic_finale_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(self:GetParent().Particle, 0, self:GetParent():GetAbsOrigin()) 
			ParticleManager:SetParticleControl(self:GetParent().Particle, 3, self:GetParent():GetAbsOrigin()) 
		end
	end

	function modifier_gilles_grief:OnRefresh(args)
		self.Damage = args.Damage
	end

	function modifier_gilles_grief:OnDestroy()
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local fDamage = self.Damage
		local target = self:GetParent()
		local bonus_damage = 0

		if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Gilles_Grief_Explode", hCaster)
		if target.Particle ~= nil then
			ParticleManager:DestroyParticle( target.Particle, true )
	        ParticleManager:ReleaseParticleIndex( target.Particle )
	        target.Particle = nil
	    end

        local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	 	ParticleManager:SetParticleControl(particleIndex, 0, self:GetParent():GetAbsOrigin()) 

        DoDamage(hCaster, target, fDamage, DAMAGE_TYPE_MAGICAL, 0, hAbility, false)
        if hCaster.IsOuterGodAcquired then
        	local bonus_int = hAbility:GetSpecialValueFor("bonus_void_int")
        	bonus_damage = bonus_int * hCaster:GetIntellect()
        	DoDamage(hCaster, target, bonus_damage, DAMAGE_TYPE_PURE, 0, hAbility, false)
        end

		if IsValidEntity(target) and self:GetParent():IsAlive() then
			local fExplosionDamage = (self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) * hAbility:GetSpecialValueFor("void_damage") / 100
			
			local tTargets = FindUnitsInRadius(hCaster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, hAbility:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		
			if not IsImmuneToCC(self:GetParent()) then
				target:AddNewModifier(hCaster, hAbility, "modifier_stunned", {Duration = hAbility:GetSpecialValueFor("stun_duration") })
			end
			
			for _,v in pairs(tTargets) do
				if IsValidEntity(v) and not v:IsNull() and v ~= self:GetParent() then
					DoDamage(hCaster, v, fExplosionDamage, DAMAGE_TYPE_MAGICAL, 0, hAbility, false)
					if hCaster.IsOuterGodAcquired then
						DoDamage(hCaster, target, bonus_damage, DAMAGE_TYPE_PURE, 0, hAbility, false)
        			end
				end
			end

		end

		Timers:CreateTimer( 1.5, function()
	        ParticleManager:DestroyParticle( particleIndex, true )
	        ParticleManager:ReleaseParticleIndex( particleIndex )
	        return
	    end)
	end	
end

function modifier_gilles_grief:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gilles_grief:IsDebuff()
	return true
end

function modifier_gilles_grief:IsHidden() 
	return false 
end

function modifier_gilles_grief:GetTexture()
	return "custom/gilles/gilles_grief"
end