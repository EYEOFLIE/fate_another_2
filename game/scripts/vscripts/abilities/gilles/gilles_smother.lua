gilles_smother = class({})
gilles_smother_upgrade = class({})
modifier_gilles_smother = class({})

LinkLuaModifier("modifier_gilles_smother", "abilities/gilles/gilles_smother", LUA_MODIFIER_MOTION_NONE)

function smother_wrapper(abil)
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
		local fAOE = self:GetAOERadius() + 50
		local explosion_damage = self:GetSpecialValueFor("explosion_damage")
		if hCaster.IsOuterGodAcquired then
			local bonus_int = self:GetSpecialValueFor("bonus_int")
			explosion_damage = explosion_damage + (bonus_int * hCaster:GetIntellect())
		end

		EmitSoundOnLocationWithCaster(vTargetLocation, "Gilles_Smother_Cast", hCaster)

		local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), vTargetLocation, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			
		for _,v in pairs(tEnemies) do

			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				v:AddNewModifier(hCaster, self, "modifier_gilles_smother", { ExplosionDamage = explosion_damage,
																			 Damage = self:GetSpecialValueFor("damage"),
																			 Duration =  self:GetSpecialValueFor("duration") + 0.1})
			end
		end

		local particle = ParticleManager:CreateParticle("particles/custom/gilles/smother_ground_fire.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, vTargetLocation) 
		ParticleManager:SetParticleControl(particle, 1, Vector(fAOE,fAOE,fAOE)) 
		ParticleManager:SetParticleControl(particle, 3, Vector(fAOE,fAOE,fAOE)) 
		
		local particle2 = ParticleManager:CreateParticle("particles/custom/gilles/smother_cast_warp.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle2, 1, vTargetLocation) 
		ParticleManager:SetParticleControl(particle2, 2, vTargetLocation) 
		ParticleManager:SetParticleControl(particle2, 3, vTargetLocation) 
		ParticleManager:SetParticleControl(particle2, 4, vTargetLocation) 

		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			ParticleManager:DestroyParticle( particle2, false )
			ParticleManager:ReleaseParticleIndex( particle2 )
		end)
	end
end

smother_wrapper(gilles_smother)
smother_wrapper(gilles_smother_upgrade)

function modifier_gilles_smother:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

if IsServer() then 
	function modifier_gilles_smother:OnCreated(args)
		self.Damage = (args.Damage * 0.4) / self:GetDuration()
		self.hTarget = self:GetParent()
		self.ExplosionDamage = args.ExplosionDamage

		self:StartIntervalThink(0.4)

		if self.hTarget.Particle == nil then
			self.hTarget.Particle = ParticleManager:CreateParticle("particles/custom/gilles/smother_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hTarget)
			ParticleManager:SetParticleControl(self.hTarget.Particle, 0, self.hTarget:GetAbsOrigin()) 
			ParticleManager:SetParticleControl(self.hTarget.Particle, 1, self.hTarget:GetAbsOrigin()) 
			ParticleManager:SetParticleControl(self.hTarget.Particle, 3, self.hTarget:GetAbsOrigin()) 
		end
	end

	function modifier_gilles_smother:OnRefresh(args)
		self.Damage = (args.Damage * 0.4) / self:GetDuration()
		self.ExplosionDamage = args.ExplosionDamage
	end

	function modifier_gilles_smother:OnDestroy()
		if self.hTarget.Particle ~= nil then
			ParticleManager:DestroyParticle( self.hTarget.Particle, false )
			ParticleManager:ReleaseParticleIndex( self.hTarget.Particle )
			self.hTarget.Particle = nil
		end
	end

	function modifier_gilles_smother:OnIntervalThink()
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local fDamage = self.Damage

		DoDamage(hCaster, self:GetParent(), fDamage, DAMAGE_TYPE_MAGICAL, 0, hAbility, false)
	end

	function modifier_gilles_smother:OnAbilityFullyCast(args)
		if args.unit ~= self:GetParent() or args.ability:IsItem() or IsSpellBook(args.ability:GetAbilityName()) then return end

		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Gilles_Smother_Explode", self:GetParent())

		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local tTargets = FindUnitsInRadius(hCaster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, hAbility:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		
		if not IsImmuneToCC(self:GetParent()) then
			self:GetParent():AddNewModifier(hCaster, hAbility, "modifier_stunned", { Duration = hAbility:GetSpecialValueFor("stun_duration") })
		end

		local particle = ParticleManager:CreateParticle("particles/custom/gilles/smother_explode.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin()) 
		ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin()) 

		for _,v in pairs(tTargets) do
			DoDamage(hCaster, v, self.ExplosionDamage, DAMAGE_TYPE_MAGICAL, 0, hAbility, false)
		end

		Timers:CreateTimer( 2.5, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)

		self:Destroy()
	end
end

function modifier_gilles_smother:IsDebuff()
	return true
end

function modifier_gilles_smother:IsHidden() 
	return false 
end

function modifier_gilles_smother:GetTexture()
	return "custom/gilles/gilles_smother"
end