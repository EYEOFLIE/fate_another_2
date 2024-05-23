kuro_nine_lives = class({})

LinkLuaModifier("modifier_kuro_nine_lives", "abilities/kuro/modifiers/modifier_kuro_nine_lives", LUA_MODIFIER_MOTION_NONE)

function kuro_nine_lives:GetCooldown(iLevel)
	local cooldown = self:GetSpecialValueFor("cooldown")

	if self:GetCaster():HasModifier("modifier_kuro_projection") then
		cooldown = cooldown - (cooldown * self:GetSpecialValueFor("cooldown_reduction") / 100)
	end

	return cooldown
end

function kuro_nine_lives:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function kuro_nine_lives:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_RUN, rate=0.2})

	return true
end

function kuro_nine_lives:OnSpellStart()
	local caster = self:GetCaster()
	local casterName = caster:GetName()
	local targetPoint = self:GetCursorPosition()
	local ability = self
	local berserker = Physics:Unit(caster)
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance

	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*distance)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4.0)
	caster:EmitSound("Hero_OgreMagi.Ignite.Cast")

	StartAnimation(caster, {duration=1, activity=ACT_DOTA_RUN, rate=0.8})

	caster.NineTimer = Timers:CreateTimer(1.0, function()
		self:StartNineLives()
	end)
	caster:OnPhysicsFrame(function(unit)
		if CheckDummyCollide(unit) then
			self:StartNineLives()
		end
	end)
	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		self:StartNineLives()
	end)

	EmitGlobalSound("chloe_attack_2")
end

function kuro_nine_lives:StartNineLives()
	local caster = self:GetCaster()
	caster:OnPreBounce(nil)
	caster:OnPhysicsFrame(nil)
	caster:SetBounceMultiplier(0)
	caster:PreventDI(false)
	caster:SetPhysicsVelocity(Vector(0,0,0))
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	Timers:RemoveTimer(caster.NineTimer)
	caster.NineTimer = nil

	if caster:IsAlive() then
		self:NineLivesHits()
		return 
	end
	return
end

function kuro_nine_lives:NineLivesHits()
	local bonus_damage = 0
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_projection_attribute") then
		bonus_damage = caster:GetStrength()
		--caster:GetAverageTrueAttackDamage(caster)
	end

	local casterInitOrigin = caster:GetAbsOrigin() 

	caster:AddNewModifier(caster, self, "modifier_kuro_nine_lives", { Duration = 1.25,
																	 SmallDamage = self:GetSpecialValueFor("damage") + bonus_damage,
																	 LargeDamage = self:GetSpecialValueFor("damage_lasthit") + bonus_damage,
																	 SmallRadius = self:GetSpecialValueFor("radius"),
																	 LargeRadius = self:GetSpecialValueFor("radius_lasthit")})
end