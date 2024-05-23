LinkLuaModifier("modifier_mordred_bc", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_bc_cooldown", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_rampage", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_rampage_stack", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)

mordred_pedigree_attribute = class({})

function mordred_pedigree_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	hero:FindAbilityByName("mordred_pedigree"):SetLevel(2)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

mordred_curse_attribute = class({})

function mordred_curse_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	hero:SwapAbilities("fate_empty1", "mordred_curse_passive", false, true)
	hero:FindAbilityByName("mordred_curse_passive"):SetLevel(1)

	hero.CurseOfRetributionAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

mordred_bc_attribute = class({})

function mordred_bc_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	Timers:CreateTimer(function()
		if hero:IsAlive() then 
	    	hero:AddNewModifier(hero, self, "modifier_mordred_bc", {})
			return nil
		else
			return 1
		end
	end)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

mordred_rampage_attribute = class({})

function mordred_rampage_attribute:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	Timers:CreateTimer(function()
		if hero:IsAlive() then 
	    	hero:AddNewModifier(hero, self, "modifier_mordred_rampage", {})
			return nil
		else
			return 1
		end
	end)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
end

modifier_mordred_bc = class({})

function modifier_mordred_bc:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE,
			 }
end

function modifier_mordred_bc:IsHidden() 
	return true 
end

function modifier_mordred_bc:IsPermanent()
	return true
end

function modifier_mordred_bc:RemoveOnDeath()
	return false
end

function modifier_mordred_bc:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mordred_bc:OnTakeDamage(args)
	self.parent = self:GetParent()
	local caster = self:GetParent()
	if args.unit ~= self.parent then return end
	if caster:HasModifier("modifier_mordred_bc_cooldown") then return end

	caster:AddNewModifier(caster, caster:FindAbilityByName("mordred_pedigree"), "modifier_mordred_bc_cooldown", {duration = 99})
	if self.parent:GetHealth()<=0 then
		self.parent:SetHealth(args.damage)
		StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})

		caster:EmitSound("mordred_rush")

		local qdProjectile = 
		{
			Ability = self.parent:FindAbilityByName("mordred_rush"),
       	 	EffectName = nil,
       	 	iMoveSpeed = 1800,
        	vSpawnOrigin = caster:GetOrigin(),
        	fDistance = 1800,
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
		giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.0)
		caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
		local sin = Physics:Unit(caster)
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(caster:GetForwardVector() * 1800)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)

		Timers:CreateTimer("mordred_rush", {
			endTime = 1.0,
			callback = function()
			caster:OnPreBounce(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:RemoveModifierByName("jump_pause")
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		return end
		})

		caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
			Timers:RemoveTimer("mordred_rush")
			unit:OnPreBounce(nil)
			unit:SetBounceMultiplier(0)
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			caster:RemoveModifierByName("jump_pause")
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end)
	end
end

modifier_mordred_rampage = class({})

function modifier_mordred_rampage:IsHidden() 
	return true 
end

function modifier_mordred_rampage:IsPermanent()
	return true
end

function modifier_mordred_rampage:RemoveOnDeath()
	return false
end

function modifier_mordred_rampage:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mordred_rampage:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 }
end

function modifier_mordred_rampage:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end

	self.parent = self:GetParent()
	args.target:AddNewModifier(self.parent, self.parent:FindAbilityByName("mordred_pedigree"), "modifier_mordred_rampage_stack", {duration = 10})
	if IsServer() then
		DoDamage(self.parent, args.target, args.target:FindModifierByName("modifier_mordred_rampage_stack"):GetStackCount()*10, DAMAGE_TYPE_MAGICAL, 0, self.parent:FindAbilityByName("mordred_pedigree"), false)
	end
end

modifier_mordred_rampage_stack = class({})

function modifier_mordred_rampage_stack:GetTexture()
	return "custom/mordred/mordred_rampage"
end

function modifier_mordred_rampage_stack:IsHidden() return false end

function modifier_mordred_rampage_stack:IsDebuff() return true end

function modifier_mordred_rampage_stack:OnCreated()
	self:SetStackCount((self:GetStackCount() or 0) + 1)
end

function modifier_mordred_rampage_stack:OnRefresh()
	self:OnCreated()
end

modifier_mordred_bc_cooldown = class({})

function modifier_mordred_bc_cooldown:GetTexture()
	return "custom/mordred/mordred_battle_continuation"
end

function modifier_mordred_bc_cooldown:IsHidden()
	return false 
end

function modifier_mordred_bc_cooldown:RemoveOnDeath()
	return false
end

function modifier_mordred_bc_cooldown:IsDebuff()
	return true 
end

function modifier_mordred_bc_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end