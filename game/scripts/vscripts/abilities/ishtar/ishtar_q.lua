
ishtar_q = class({})
ishtar_q_upgrade = class({})
modifier_ishtar_q_slow = class({})
LinkLuaModifier("modifier_ishtar_q_slow", "abilities/ishtar/ishtar_q", LUA_MODIFIER_MOTION_NONE)

function ishtar_q_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end

	function abil:GetManaCost(iLevel)
		return 100
	end

	function abil:GetAbilityTextureName()
		return "abilities/ishtar/ishtar_q"
	end

	function abil:GetGemConsume()
		local caster = self:GetCaster()
		local max_gem_use = self:GetSpecialValueFor("gem_consume")
		local gem = caster:FindModifierByName("modifier_ishtar_gem")
		local gem_consume = math.min(max_gem_use, gem:GetStackCount())
		gem:AddGem(gem_consume)

		return gem_consume
	end

	function abil:OnSpellStart()
		local caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		self.arrow = self:GetSpecialValueFor("arrow")
		self.distance = self:GetSpecialValueFor("distance")
		self.speed = self:GetSpecialValueFor("speed")
		self.width = self:GetSpecialValueFor("width")
		self.gem_consume = 0
		local angle = 120

		if caster:HasModifier("modifier_ishtar_gem_consume") then 
			self.gem_consume = self:GetGemConsume()
			self.arrow = self.arrow + self.gem_consume
			local forwardvec = (target_loc-caster:GetAbsOrigin()):Normalized()
			local caster_angle = VectorToAngles(forwardvec).y 
			local new_angle = caster_angle + angle
			local dist = (target_loc-caster:GetAbsOrigin()):Length2D()
			if new_angle > 360 then 
				new_angle = new_angle - 360 
			end
			for i = 1, self.arrow do 
				local originLoc = GetRotationPoint(target_loc,dist,new_angle)
				originLoc.z = caster:GetAbsOrigin().z
				local new_forwardvec = (originLoc - target_loc):Normalized()
				self:CreateArrowProjectile(originLoc, new_forwardvec)
				new_angle = new_angle + (120 / (self.arrow - i))
			end
		else
			local forwardvec = (caster:GetAbsOrigin()-target_loc):Normalized()
			local caster_angle = VectorToAngles(forwardvec).y 
			local new_angle = caster_angle + angle
			if new_angle > 360 then 
				new_angle = new_angle - 360 
			end
			for i = 1, self.arrow do 
				local endLoc = GetRotationPoint(caster:GetAbsOrigin(),self.distance,new_angle)
				endLoc.z = caster:GetAbsOrigin().z
				local new_forwardvec = (caster:GetAbsOrigin()-endLoc):Normalized()
				self:CreateArrowProjectile(caster:GetAbsOrigin(), new_forwardvec)
				new_angle = new_angle + (120 / (self.arrow - i))
			end
		end
	end

	function abil:CreateArrowProjectile(vOrigin, vForward)

		local arrow = {
			Ability = self,
			EffectName = "",
			vSpawnOrigin = vOrigin,
			fDistance = self.distance ,
			Source = self:GetCaster(),
			fStartRadius = self.width,
	        fEndRadius = self.width,
			bHasFrontialCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			fExpireTime = GameRules:GetGameTime() + 2,
			bDeleteOnHit = false,
			vVelocity = vForward * self.speed,		
		}

		ProjectileManager:CreateLinearProjectile(arrow)
	end

	function abil:OnProjectileHit(hTarget, vLocation)
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")
		DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self, false)
		if caster.is then 
			if not IsImmuneToSlow(hTarget) then
				hTarget:AddNewModifier(caster, self, "modifier_ishtar_q_slow", {Duration = self:GetSpecialValueFor("slow_dur")})
			end
		end
	end
end

ishtar_q_wrapper(ishtar_q)
ishtar_q_wrapper(ishtar_q_upgrade)

--------------------------

function modifier_ishtar_q_slow:IsHidden()
	return false 
end

function modifier_ishtar_q_slow:IsDebuff()
	return true 
end

function modifier_ishtar_q_slow:IsPassive() 
	return false 
end

function modifier_ishtar_q_slow:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return func 
end

function modifier_ishtar_q_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end