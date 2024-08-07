LinkLuaModifier("modifier_ishtar_crown", "abilities/ishtar/ishtar_crown", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_crown_tracker", "abilities/ishtar/ishtar_crown", LUA_MODIFIER_MOTION_NONE)

ishtar_crown = class({})

function ishtar_crown:GetIntrinsicModifierName()
	return "modifier_ishtar_crown"
end

function ishtar_crown:GetSpawnLoc()
	self.caster = self:GetCaster()
	local front = self.caster:GetForwardVector()
	local origin = self.caster:GetAbsOrigin() + (Vector(front.x,front.y,0) * 50)
	local leftvec = Vector(-front.y, front.x, 0)
	local rightvec = self.caster:GetRightVector() --Vector(front.y, -front.x, 0)
		--local vSpawnOrigin = Vector(0,0,0)
	local random1 = RandomInt(0, 100) -- position of weapon spawn
	local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

	local vSpawnOrigin = origin + (rightvec * RandomInt(-150, 150)) + Vector(0,0,400)

	return vSpawnOrigin
end

function ishtar_crown:CreateTrackingProjectile(vSpawnLoc ,hTarget)

	local arrow = {
		Target = hTarget,
		Ability = self,	
		EffectName = "particles/ishtar/ishtar_proj_track.vpcf",
		iMoveSpeed = 1000,
		vSourceLoc= vSpawnLoc,
		bDrawsOnMinimap = false,
		bVisibleToEnemies = true,
		bProvidesVision = false, 
		bDodgeable = true,
		bIsAttack = false,
		flExpireTime = GameRules:GetGameTime() + 3,	
	}
	local spawn_arrow = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_track.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(spawn_arrow, 0, vSpawnLoc)
	ParticleManager:SetParticleControl(spawn_arrow, 1, vSpawnLoc)
	ParticleManager:SetParticleControl(spawn_arrow, 2, Vector(0,0,0))
	Timers:CreateTimer(0.3, function()
		ParticleManager:DestroyParticle(spawn_arrow, true)
		ParticleManager:ReleaseParticleIndex(spawn_arrow)
		ProjectileManager:CreateTrackingProjectile(arrow)
	end)
end

function ishtar_crown:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil then return end

	hTarget:EmitSound("Ishtar.ProjectileLayer")
	hTarget:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("gem_damage")

	DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self, false)

	if caster.IsManaBurstGemAcquired then 
		caster:FindAbilityByName(caster.FSkill):AddManaBurstDebuff(hTarget)
	end

	local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, hTarget)
	ParticleManager:SetParticleControl(particleeff1, 0, hTarget:GetAbsOrigin())
end

--------------------------

modifier_ishtar_crown = class({})

function modifier_ishtar_crown:IsHidden() return false end
function modifier_ishtar_crown:IsDebuff() return false end
function modifier_ishtar_crown:IsPassive() return true end
function modifier_ishtar_crown:IsPurgable() return false end
function modifier_ishtar_crown:RemoveOnDeath() return false end
function modifier_ishtar_crown:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_ishtar_crown:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, 
			MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_PROPERTY_BONUS_DAY_VISION,
			MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function modifier_ishtar_crown:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("ms")
end
function modifier_ishtar_crown:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision")
end
function modifier_ishtar_crown:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision")
end
function modifier_ishtar_crown:GetEffectName()
	return "particles/ishtar/ishtar_crown.vpcf"
end
function modifier_ishtar_crown:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_ishtar_crown:OnCreated(args)
	self.caster = self:GetParent()
	self.gold = self:GetAbility():GetSpecialValueFor("gold")
	self.atk_count = self:GetAbility():GetSpecialValueFor("atk_count")
	self.gem_consume = self:GetAbility():GetSpecialValueFor("gem_consume")
	self.gem_arrow = self:GetAbility():GetSpecialValueFor("gem_arrow")
	self.gem_damage = self:GetAbility():GetSpecialValueFor("gem_damage")
	self.speed = 1000

	self:StartIntervalThink(1.0)
end
if IsServer() then
	function modifier_ishtar_crown:OnIntervalThink()
		if self:GetParent():IsAlive() and GameRules:GetGameTime() > 75 then 
			self:GetParent():ModifyGold(self.gold, true, 0)
		end
	end

	function modifier_ishtar_crown:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		self.caster = self:GetParent()
		local stacks = (self.caster:HasModifier("modifier_ishtar_crown_tracker") and self.caster:FindModifierByName("modifier_ishtar_crown_tracker"):GetStackCount()) or 0
		print('crown stack = ' .. stacks)

		self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ishtar_crown_tracker", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		self.caster:FindModifierByName("modifier_ishtar_crown_tracker"):SetStackCount(math.min(stacks + 1, self.atk_count))
	end

	function modifier_ishtar_crown:OnAttackStart(args)
		if args.attacker ~= self:GetParent() then return end

		local stacks = (self.caster:HasModifier("modifier_ishtar_crown_tracker") and self.caster:FindModifierByName("modifier_ishtar_crown_tracker"):GetStackCount()) or 0
		print('crown stack = ' .. stacks)
		if stacks >= self.atk_count then 
			local current_gem = self.caster:FindAbilityByName(self.caster.DSkill):GetCurrentGem()
			if current_gem >= self.gem_consume then
				print('ishtar fire magic arrow')
				self:ArrowAttack(args.target)
				self.caster:FindAbilityByName(self.caster.DSkill):AddGem(-1)
				self.caster:RemoveModifierByName("modifier_ishtar_crown_tracker")
				return
			end
		end

	end
end
	
function modifier_ishtar_crown:ArrowAttack(hTarget)
	local spawn_loc = {}
	for i = 1, self.gem_arrow do 
		Timers:CreateTimer(i * 0.1, function()
			spawn_loc[i] = self:GetAbility():GetSpawnLoc()
			self:GetAbility():CreateTrackingProjectile(spawn_loc[i] ,hTarget)
		end)
	end
end

-----------------------------

modifier_ishtar_crown_tracker = class({})

function modifier_ishtar_crown_tracker:IsHidden() return false end
function modifier_ishtar_crown_tracker:IsDebuff() return false end
function modifier_ishtar_crown_tracker:IsPassive() return true end
function modifier_ishtar_crown_tracker:IsPurgable() return false end
function modifier_ishtar_crown_tracker:RemoveOnDeath() return false end
function modifier_ishtar_crown_tracker:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end