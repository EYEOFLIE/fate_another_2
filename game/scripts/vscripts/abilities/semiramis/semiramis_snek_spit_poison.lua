semiramis_snek_spit_poison = class({})

--LinkLuaModifier("modifier_snek_poison", "abilities/semiramis/modifiers/modifier_snek_poison", LUA_MODIFIER_MOTION_NONE)

function semiramis_snek_spit_poison:OnSpellStart()
	local caster = self:GetCaster()
	local target_loc = self:GetCursorPosition()
	local range = self:GetSpecialValueFor("range")
	local aoe = self:GetSpecialValueFor("aoe")

   	caster:EmitSound("Semi.AssassinW")
   	caster:EmitSound("Semi.AssassinWSFX")
   	caster:EmitSound("Semi.AssassinWSFX2")

	local projectileTable = {
		EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
		Ability = self,
		iMoveSpeed = 1500,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = range,
		Source = self:GetCaster(),
		fStartRadius = aoe,
        fEndRadius = aoe,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1350,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end

function semiramis_snek_spit_poison:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil then return end

	if self:GetCaster().IsCharmAcquired then
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage") + (self:GetSpecialValueFor("damage_per_int") * self:GetCaster():GetIntellect()) , DAMAGE_TYPE_MAGICAL, 0, self, false) 
	else
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL, 0, self, false) 
	end

	Timers:CreateTimer(0.5, function()
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("dps") / 2, DAMAGE_TYPE_MAGICAL, 0, self, false) 
	end)	
	Timers:CreateTimer(1, function()
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("dps") / 2, DAMAGE_TYPE_MAGICAL, 0, self, false) 
	end)	
	Timers:CreateTimer(1.5, function()
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("dps") / 2, DAMAGE_TYPE_MAGICAL, 0, self, false) 
	end)	
	Timers:CreateTimer(2, function()
		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("dps") / 2, DAMAGE_TYPE_MAGICAL, 0, self, false) 
	end)
end