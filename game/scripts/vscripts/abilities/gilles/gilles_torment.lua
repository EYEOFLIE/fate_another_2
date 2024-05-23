gilles_torment = class({})
gilles_torment_upgrade = class({})
modifier_gilles_torment = class({})

LinkLuaModifier("modifier_gilles_torment", "abilities/gilles/gilles_torment", LUA_MODIFIER_MOTION_NONE)

function torment_wrapper(abil)
	function abil:GetManaCost(iLevel)
		return self:GetSpecialValueFor("mana_cost")
	end

	function abil:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function abil:IsHiddenAbilityCastable()
		return true
	end

	function abil:OnSpellStart()
		local hCaster = self:GetCaster()
		local vTargetLocation = self:GetCursorPosition()
		local iAOE = self:GetAOERadius() + 100
		local damage = self:GetSpecialValueFor("distance_damage")

		if hCaster.IsOuterGodAcquired then
			local bonus_int = self:GetSpecialValueFor("bonus_int")
			damage = damage + (bonus_int * hCaster:GetIntellect())
		end

		EmitSoundOnLocationWithCaster(vTargetLocation, "Gilles_Torment_Cast", hCaster)

		local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), vTargetLocation, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			
		for _,v in pairs(tEnemies) do

			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				v:AddNewModifier(hCaster, self, "modifier_gilles_torment", { DistanceDamage = damage,
																			 Damage = self:GetSpecialValueFor("damage"),
																			 Duration =  self:GetSpecialValueFor("duration") + 0.1})
			end
		end

		local particle = ParticleManager:CreateParticle("particles/custom/gilles/torment_cast.vpcf", PATTACH_WORLDORIGIN, hCaster)
		ParticleManager:SetParticleControl(particle, 0, vTargetLocation)
		ParticleManager:SetParticleControl(particle, 2, vTargetLocation)
		ParticleManager:SetParticleControl(particle, 3, Vector(iAOE, iAOE, iAOE))

		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
	end
end

torment_wrapper(gilles_torment)
torment_wrapper(gilles_torment_upgrade)

if IsServer() then 
	function modifier_gilles_torment:OnCreated(args)
		self.vLocation = self:GetParent():GetAbsOrigin()
		self.hTarget = self:GetParent()
		self.Damage = (args.Damage * 0.33) / self:GetDuration()
		self.DistanceDamage = args.DistanceDamage

		self:StartIntervalThink(0.33)
		if self.hTarget.ParticleIndex == nil then
			self.hTarget.ParticleIndex = ParticleManager:CreateParticle("particles/custom/gilles/torment_debuffhellborn_debuff.vpcf", PATTACH_CUSTOMORIGIN, self.hTarget)
	 		ParticleManager:SetParticleControl(self.hTarget.ParticleIndex, 0, self.hTarget:GetAbsOrigin())
	 	end
	end

	function modifier_gilles_torment:OnRefresh(args)
		self.vLocation = self.hTarget:GetAbsOrigin()
		self.Damage = args.Damage * 0.33	
		self.DistanceDamage = args.DistanceDamage
	end

	function modifier_gilles_torment:OnDestroy()
		if self.hTarget.ParticleIndex ~= nil then
			ParticleManager:DestroyParticle( self.hTarget.ParticleIndex, false )
	        ParticleManager:ReleaseParticleIndex( self.hTarget.ParticleIndex )
	        self.hTarget.ParticleIndex = nil
		end
	end

	function modifier_gilles_torment:OnIntervalThink()
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local fDamage = self.Damage
		local fDistance = (self:GetParent():GetAbsOrigin() - self.vLocation):Length2D()
		ParticleManager:SetParticleControl(self.hTarget.ParticleIndex, 0, self.hTarget:GetAbsOrigin())

		if not IsInSameRealm(self:GetParent():GetAbsOrigin(), self.vLocation) then return end

		if (fDistance > 0) then
			fDamage = fDamage + (fDistance * self.DistanceDamage / 100)
		end

		self.vLocation = self.hTarget:GetAbsOrigin()
		DoDamage(hCaster, self.hTarget, fDamage, DAMAGE_TYPE_MAGICAL, 0, hAbility, false)
		
	end
end

function modifier_gilles_torment:IsDebuff()
	return true
end

function modifier_gilles_torment:IsHidden() 
	return false 
end

function modifier_gilles_torment:GetTexture()
	return "custom/gilles/gilles_torment"
end