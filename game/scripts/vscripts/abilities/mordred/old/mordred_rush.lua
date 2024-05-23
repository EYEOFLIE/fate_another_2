mordred_rush = class({})

function mordred_rush:OnUpgrade()
    local clarent = self:GetCaster():FindAbilityByName("mordred_clarent")
    clarent:SetLevel(self:GetLevel())
end

function mordred_rush:OnSpellStart()
	self.ChannelTime = 0
	ParticleManager:CreateParticle("particles/custom/mordred/max_excalibur/charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
end

function mordred_rush:OnChannelThink(fInterval)
    self.ChannelTime = self.ChannelTime + fInterval
end

function mordred_rush:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})

	caster:EmitSound("mordred_rush")

	self.damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_per_second")*self.ChannelTime

	local qdProjectile = 
	{
		Ability = self,
        EffectName = nil,
        iMoveSpeed = 1800,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = self:GetSpecialValueFor("distance"),
        fStartRadius = 300,
        fEndRadius = 300,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1800
	}

	local projectile = ProjectileManager:CreateLinearProjectile(qdProjectile)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 1.0)
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector() * 1800)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("mordred_rush", {
		endTime = 1.0,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("mordred_rush")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)
end

function mordred_rush:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil then return end

	local caster = self:GetCaster()
	if self.damage == nil then self.damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_per_second")*2 end
	print(self.damage)

	--giveUnitDataDrivenModifier(caster, hTarget, "rooted", duration)
	--giveUnitDataDrivenModifier(caster, hTarget, "locked", duration)

	DoDamage(caster, hTarget, self.damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
end