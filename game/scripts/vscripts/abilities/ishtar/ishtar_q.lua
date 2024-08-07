
ishtar_q = class({})
ishtar_q_upgrade = class({})
modifier_ishtar_q_use = class({})
LinkLuaModifier("modifier_ishtar_q_use", "abilities/ishtar/ishtar_q", LUA_MODIFIER_MOTION_NONE)

function ishtar_q_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_POINT
	end

	function abil:GetManaCost(iLevel)
		return 100
	end

	function abil:GetCastAnimation()
		return ACT_DOTA_CAST_ABILITY_1
	end

	function abil:GetPlaybackRateOverride()
		return 1.5
	end

	function abil:GetCastPoint()
		return self:GetSpecialValueFor("cast_delay")
	end

	function abil:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("distance")
	end

	function abil:GetAbilityTextureName()
		return "custom/ishtar/ishtar_q"
	end

	function abil:GetGemConsume(iMaxGemUse)
		local caster = self:GetCaster()
		local gem_consume = 0
		if caster:HasModifier("modifier_ishtar_gem_consume") then 
			local gem = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
			gem_consume = math.min(iMaxGemUse, gem)
			caster:FindAbilityByName(caster.DSkill):AddGem(-gem_consume)
		end
		return gem_consume
	end

	function abil:OnSpellStart()
		local caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		self.arrow = self:GetSpecialValueFor("arrow")
		self.distance = self:GetSpecialValueFor("distance")
		self.speed = self:GetSpecialValueFor("speed")
		self.width = self:GetSpecialValueFor("width")
		local angle = 120
		local q_gem = caster:FindAbilityByName(caster.FSkill)
		self.gem_consume = 0
		if caster:HasModifier("modifier_ishtar_gem_consume") then
			self.gem_consume = self:GetGemConsume(q_gem:GetSpecialValueFor("QGem"))
		end

		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.Projectile" .. math.random(1,4) , caster)
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.ProjectileBase" , caster)

		self.arrow = self.arrow + (self.gem_consume * q_gem:GetSpecialValueFor("QArrow"))
		print('total arrow = ' .. self.arrow)
		local forwardvec = (Vector(target_loc.x, target_loc.y, 0) - Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, 0)):Normalized()
		local caster_angle = VectorToAngles(forwardvec).y 
		local new_angle = caster_angle - angle/2
		for i = 0, self.arrow - 1 do 
			local endLoc = GetRotationPoint(caster:GetAbsOrigin(), self.distance, new_angle + (angle * i / (self.arrow - 1)))
			local new_forwardvec = (Vector(endLoc.x,endLoc.y,0) - Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,0)):Normalized()
			self:CreateArrowProjectile(caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_bow")), new_forwardvec)
		end

		caster:EmitSound("Ishtar.F" .. math.random(1,3))

		EmitSoundOn( "Hero_Muerta.DeadShot.Cast", caster )
		EmitSoundOn( "Hero_Muerta.DeadShot.Layer", caster )

		--check combo
	    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then		
			if caster:FindAbilityByName(caster.DSkill):IsCooldownReady() and not caster:HasModifier("modifier_ishtar_combo_cooldown") then
				caster:AddNewModifier(caster, self, "modifier_ishtar_q_use", {Duration = 4})
			end
		end
	end

	function abil:CreateArrowProjectile(vOrigin, vForward)

		local arrow = {
			Ability = self,
			EffectName = "particles/econ/items/drow/drow_arcana/drow_arcana_multishot_linear_proj_frost_v2.vpcf",
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
		if hTarget == nil then return end

		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")
		local bonus_damage = 0

		hTarget:EmitSound("Ishtar.ProjectileLayer")
		hTarget:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

		EmitSoundOn( "Hero_Muerta.DeadShot.Slow", hTarget )

		local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, hTarget)
		ParticleManager:SetParticleControl(particleeff1, 0, hTarget:GetAbsOrigin())

		if caster.IsVenusAcquired then 
			bonus_damage = self:GetSpecialValueFor("bonus_agi") * caster:GetAgility()
		end
		DoDamage(caster, hTarget, damage + bonus_damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self, false)
		if caster.IsManaBurstGemAcquired then 
			caster:FindAbilityByName(caster.FSkill):AddManaBurstDebuff(hTarget)
		end
	end
end

ishtar_q_wrapper(ishtar_q)
ishtar_q_wrapper(ishtar_q_upgrade)

--------------------------

function modifier_ishtar_q_use:IsHidden() return true end
function modifier_ishtar_q_use:IsDebuff() return false end
function modifier_ishtar_q_use:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
