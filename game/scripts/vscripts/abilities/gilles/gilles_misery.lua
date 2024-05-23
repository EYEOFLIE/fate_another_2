gilles_misery = class({})
gilles_misery_upgrade = class({})
modifier_gilles_misery = class({})
modifier_gilles_misery_cooldown = class({})

LinkLuaModifier("modifier_gilles_misery", "abilities/gilles/gilles_misery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gilles_misery_cooldown", "abilities/gilles/gilles_misery", LUA_MODIFIER_MOTION_NONE)
--[[function gilles_misery:GetManaCost(iLevel) 
	return (self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost") / 100)
end]]

function misery_wrapper(abil)
	function abil:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function abil:IsHiddenAbilityCastable()
		return true
	end

	function abil:OnSpellStart()
		local hCaster = self:GetCaster()
		local vTargetLocation = self:GetCursorPosition()
		local duration = self:GetSpecialValueFor("duration")

		if hCaster.IsOuterGodAcquired then
			local bonus_int = self:GetSpecialValueFor("bonus_int")
			duration = duration + (bonus_int * hCaster:GetIntellect())
		end
		
		EmitSoundOnLocationWithCaster(vTargetLocation, "Gilles_Misery_Cast", hCaster)

		local particle = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_hellborn/warlock_rain_of_chaos_hellborn_cast.vpcf", PATTACH_WORLDORIGIN, hCaster)
		ParticleManager:SetParticleControl(particle, 0, vTargetLocation)

		Timers:CreateTimer(1.0, function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end)

		local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), vTargetLocation, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			
		for _,v in pairs(tEnemies) do
			
			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				v:AddNewModifier(hCaster, self, "modifier_gilles_misery", { Duration =  duration + 0.033})
			end
		end
	end
end

misery_wrapper(gilles_misery)
misery_wrapper(gilles_misery_upgrade)

function modifier_gilles_misery:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

if IsServer() then 
	function modifier_gilles_misery:OnCreated(args)
		self.target = self:GetParent()
		--[[if self.target.ParticleIndex == nil then
			self.target.ParticleIndex = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_hellborn/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
	 		ParticleManager:SetParticleControl(self.target.ParticleIndex, 0, self.target:GetAbsOrigin())
	 	end]]
 		self:SetStackCount(1)
	end

	function modifier_gilles_misery:OnRefresh(args)
		self:SetStackCount(1) 
	end

	function modifier_gilles_misery:OnDestroy()
		--[[if self.target.ParticleIndex ~= nil then
			ParticleManager:DestroyParticle( self.target.ParticleIndex, false )
	        ParticleManager:ReleaseParticleIndex( self.target.ParticleIndex )
	        self.target.ParticleIndex = nil
		end]]
	end

	function modifier_gilles_misery:OnTakeDamage(args)
		if args.unit ~= self:GetParent() then return end
		print("misery target get damage")
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()

		if not IsValidEntity(self:GetParent()) or self:GetParent():IsNull() or not self:GetParent():IsAlive() then return end
		
		if not self:GetParent():HasModifier("modifier_gilles_misery_cooldown") then
			self:GetParent():AddNewModifier(hCaster, hAbility, "modifier_stunned", { Duration = 0.033 * self:GetStackCount()})
			self:GetParent():AddNewModifier(hCaster, hAbility, "modifier_gilles_misery_cooldown", { Duration = math.max(0.5, 0.05*self:GetStackCount())})
		end
		self:SetStackCount(self:GetStackCount() + 1) 
	end
end

function modifier_gilles_misery:IsDebuff()
	return true
end

function modifier_gilles_misery:IsHidden() 
	return false 
end

function modifier_gilles_misery:GetTexture()
	return "custom/gilles/gilles_misery"
end

function modifier_gilles_misery:GetEffectName()
	return "particles/econ/items/warlock/warlock_ti9/warlock_ti9_shadow_word_debuff.vpcf"
end

function modifier_gilles_misery:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_gilles_misery_cooldown:IsDebuff()
	return true
end

function modifier_gilles_misery_cooldown:IsHidden() 
	return true 
end
