ishtar_w = class({})
modifier_ishtar_w_dash = class({})
ishtar_w_stop = class({})
modifier_ishtar_w_stop = class({})
modifier_ishtar_w_damage_cooldown = class({})
LinkLuaModifier("modifier_ishtar_w_dash", "abilities/ishtar/ishtar_W", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ishtar_w_stop", "abilities/ishtar/ishtar_W", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_w_damage_cooldown", "abilities/ishtar/ishtar_W", LUA_MODIFIER_MOTION_NONE)

function ishtar_w:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
end

function ishtar_w:GetMana()
	return 200 
end

function ishtar_w:GetAbilityTextureName()
	return "custom/ishtar/ishtar_w"
end

function ishtar_w:GetCastAnimation()
	return nil
end

function ishtar_w:GetChannelTime()
	return self:GetSpecialValueFor("dash_duration") 
end

function ishtar_w:GetGemConsume(iMaxGemUse)
	local caster = self:GetCaster()
	local gem_consume = 0
	if caster:HasModifier("modifier_ishtar_gem_consume") then 
		local gem = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
		gem_consume = math.min(iMaxGemUse, gem)
		caster:FindAbilityByName(caster.DSkill):AddGem(-gem_consume)
	end
	return gem_consume
end

function ishtar_w:OnSpellStart()
	local caster = self:GetCaster() 
	self.origin = caster:GetAbsOrigin()
	local w_gem = caster:FindAbilityByName(caster.FSkill)
	self.gem_consume = 0
	if caster:HasModifier("modifier_ishtar_gem_consume") then
		self.gem_consume = self:GetGemConsume(w_gem:GetSpecialValueFor("WGem"))
	end

	caster:EmitSound("Ishtar.WDashSFX")
	caster:EmitSound("Ishtar.WDashSFX2")

	local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar_dash_star.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,200))

	caster:AddNewModifier(caster, self, "modifier_ishtar_w_dash", {Duration = self:GetChannelTime(), GemUse = self.gem_consume})
	caster:AddNewModifier(caster, nil, "modifier_camera_follow", {duration = self:GetChannelTime()})
end

function ishtar_w:GetWOrigin()
	return self.origin
end

----------------------------------

function ishtar_w_stop:CastFilterResult()
	if IsServer() then
		local caster = self:GetCaster()
		local w_dash = caster:FindAbilityByName(caster.WSkill):GetWOrigin()
		if IsServer() and not IsInSameRealm(caster:GetAbsOrigin(), w_dash) then
		    return UF_FAIL_CUSTOM
		elseif GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
			return UF_FAIL_INVALID_LOCATION
		else
		    return UF_SUCESS
		end
	end
end

function ishtar_w_stop:GetCustomCastError()
	return "#Invalid_Location"
end

function ishtar_w_stop:OnSpellStart()
	local caster = self:GetCaster() 
	caster:AddNewModifier(caster, self, "modifier_ishtar_w_stop", {Duration = 0.1})
end

--------------------------------------

function modifier_ishtar_w_dash:IsPassive() return false end
function modifier_ishtar_w_dash:IsDebuff() return false end
function modifier_ishtar_w_dash:IsHidden() return false end
function modifier_ishtar_w_dash:IsPurgable() return false end
function modifier_ishtar_w_dash:RemoveOnDeath() return true end
function modifier_ishtar_w_dash:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_w_dash:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
					MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
					MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
					MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
	return func 
end

function modifier_ishtar_w_dash:GetModifierTurnRate_Percentage()
	return -500
end

function modifier_ishtar_w_dash:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function modifier_ishtar_w_dash:GetOverrideAnimationRate()
	return 1
end

function modifier_ishtar_w_dash:OnCreated(args)
	self.gem_use = args.GemUse
	self.caster = self:GetParent()
	self.w_gem = self.caster:FindAbilityByName(self.caster.FSkill)
	self.effect = ParticleManager:CreateParticle("particles/ishtar/ishtar_dash_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.effect, 0, self.caster:GetAbsOrigin() + Vector(0,0,100))
	if IsServer() then 
		self.caster:SwapAbilities(self.caster.WSkill, "ishtar_w_stop", false, true)
		self.fly_duration = self:GetAbility():GetSpecialValueFor("dash_duration") 
		self.dash_range = self:GetAbility():GetSpecialValueFor("dash_range")
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.gem_damage = self.w_gem:GetSpecialValueFor("WDamage")
		self.elapsedTime = 0
		self.motionTick = 0
		self.max_tick = self.fly_duration * 30
		self.origin_loc = self.caster:GetAbsOrigin()
		self.center_loc = GetRotationPoint(self.origin_loc, self.dash_range/2, self.caster:GetAnglesAsVector().y)
		self.origin_angle = self.caster:GetAnglesAsVector().y - 180

		self.rotate_angle = 360 / (self.fly_duration * 30)
		self.caster:SetForwardVector(-self.caster:GetRightVector())
		if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end

function modifier_ishtar_w_dash:CheckState()
    local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_MUTED] = true,
                }
    return state
end

function modifier_ishtar_w_dash:GetModifierIncomingDamage_Percentage()
	local reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	if self:GetParent():HasModifier("modifier_ishtar_mana_burst_gem") then 
		reduction = reduction + (self.gem_use * self.w_gem:GetSpecialValueFor("WBonusBlock"))
	end
	return reduction
end

function modifier_ishtar_w_dash:UpdateHorizontalMotion(me, dt)

	--[[if not IsInSameRealm(self.caster:GetAbsOrigin(), self.origin_loc) then 
        self:Destroy()
        return nil
    end]]

	if self.caster:HasModifier("modifier_ishtar_w_stop") then 
		self:Destroy()
        return nil
    end

    self.origin_angle = self.origin_angle - self.rotate_angle
    self.motionTick = self.motionTick + 1
    local prev_loc = self.caster:GetAbsOrigin()

    if not IsInSameRealm(self.caster:GetAbsOrigin(), self.origin_loc) then 
    	self.center_loc = GetRotationPoint(prev_loc, self.dash_range/2, self.origin_angle)
    end

    local radAngle = math.rad(self.origin_angle)

    local x = (math.cos(radAngle) * self.dash_range/2) + self.center_loc.x
    local y = (math.sin(radAngle) * self.dash_range/2) + self.center_loc.y
    local ground = GetGroundPosition(Vector(x, y, self.center_loc.z), self.caster)
    local position = Vector(x, y, ground.z)

    self.caster:SetAbsOrigin(position)

    local enemies = FindUnitsInRadius(self.caster:GetTeam(), position, nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_ANY_ORDER, false)
    for _,enemy in pairs (enemies) do
    	if not enemy:HasModifier("modifier_ishtar_w_damage_cooldown") then 
    		enemy:AddNewModifier(self.caster, self:GetAbility(), "modifier_ishtar_w_damage_cooldown", {Duration = 0.5})
    		DoDamage(self.caster, enemy, self.damage + (self.gem_damage * self.gem_use), DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self:GetAbility(), false)
    		if self.gem_use > 0 and not IsKnockbackImmune(enemy) and not IsImmuneToCC(enemy) then 
    			local knockback = { should_stun = true,
    	                                knockback_duration = 0.5,
    	                                duration = 0.1,
    	                                knockback_distance = self.gem_use * self.w_gem:GetSpecialValueFor("WKnock"),
    	                                knockback_height = 0,
    	                                center_x = position.x,
    	                                center_y = position.y,
    	                                center_z = position.z }
    	        enemy:AddNewModifier(self.caster, self:GetAbility(), "modifier_knockback", knockback)  
    	    end                    
    	end
    end
    self.elapsedTime = self.elapsedTime + dt


    if self.elapsedTime >= self.fly_duration then 
    	self:Destroy()
        return nil
    end
end
function modifier_ishtar_w_dash:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end
function modifier_ishtar_w_dash:OnDestroy()
	ParticleManager:DestroyParticle(self.effect, true)
    ParticleManager:ReleaseParticleIndex(self.effect)
    if IsServer() then
    	local stop_loc = self.caster:GetAbsOrigin()
    	if IsOutOfMap(stop_loc) then 
    		print('out of map!!')
    		stop_loc = self.origin_loc
    	end
    	FindClearSpaceForUnit(self.caster,stop_loc, true)
    	self:GetAbility():EndChannel(true)
    	self.caster:SwapAbilities(self.caster.WSkill, "ishtar_w_stop", true, false)
        self.caster:InterruptMotionControllers(true)
    end
end

------------------------------------------------

function modifier_ishtar_w_stop:IsPassive() return false end
function modifier_ishtar_w_stop:IsDebuff() return false end
function modifier_ishtar_w_stop:IsHidden() return true end
function modifier_ishtar_w_stop:IsPurgable() return false end
function modifier_ishtar_w_stop:RemoveOnDeath() return true end
function modifier_ishtar_w_stop:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

------------------------------------------------

function modifier_ishtar_w_damage_cooldown:IsPassive() return false end
function modifier_ishtar_w_damage_cooldown:IsDebuff() return true end
function modifier_ishtar_w_damage_cooldown:IsHidden() return true end
function modifier_ishtar_w_damage_cooldown:IsPurgable() return false end
function modifier_ishtar_w_damage_cooldown:RemoveOnDeath() return true end
function modifier_ishtar_w_damage_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end


--[[ishtar_w = class({})
LinkLuaModifier( "modifier_generic_vector_target", "abilities/ishtar/modifier_generic_vector_target", LUA_MODIFIER_MOTION_NONE )

function ishtar_w:GetVectorTargetRange()
	return 600
end

function ishtar_w:CastFilterResultLocation( vLocation )
	self.pointcast = vLocation
	return UF_SUCCESS
end

ishtar_w.projectiles = {}

function ishtar_w:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local vector_point = self.pointcast
	if not vector_point then
		-- likely reflected, otherwise set forward as default
		vector_point = ishtar_w.reflect_location or (target:GetOrigin() + target:GetForwardVector())
	end

	-- load data
	local speed = self:GetSpecialValueFor( "speed" )
	local damage = self:GetSpecialValueFor( "damage" )

	local effect_name_tracking = "particles/units/heroes/hero_muerta/muerta_deadshot_tracking_proj.vpcf"
	local effect_name_tree = "particles/units/heroes/hero_muerta/muerta_deadshot_linear_tree.vpcf"

	-- calculate ricochet direction
	local direction = vector_point - target:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	-- target unit
	-- Create Tracking Projectile
	local info = {
		Source = caster,
		Target = target,
		Ability = self,
		iMoveSpeed = speed,
		EffectName = effect_name_tracking,
		bDodgeable = true,
	}
	local projID = ProjectileManager:CreateTrackingProjectile( info )

	local data = {}
	self.projectiles[projID] = data
	data.info = info
	data.OnHit = function( this, target, location )
		return self:OnInitialHit( direction, target, location )
	end

	EmitSoundOn( "Hero_Muerta.DeadShot.Cast", caster )
	EmitSoundOn( "Hero_Muerta.DeadShot.Layer", caster )
end

function ishtar_w:OnInitialHit( direction, target, location )
	local caster = self:GetCaster()

	if target:IsMagicImmune() or target:IsInvulnerable() then return end

	-- NOTE: Lotus reflects direction to the opposite of original cast
	-- this code below create static variable for reflected ability to use
	ishtar_w.reflect_location = caster:GetOrigin() - direction
	if target:TriggerSpellAbsorb( self ) then
		ishtar_w.reflect_location = nil
		return
	end

	local damage = self:GetSpecialValueFor( "damage" )
	
	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage( damageTable )

	-- ricochet
	self:LaunchRicochet( target, direction )
end

function ishtar_w:LaunchRicochet( target, direction )
	local caster = self:GetCaster()

	local effect_name_linear = "particles/units/heroes/hero_muerta/muerta_deadshot_linear.vpcf"
	local speed = self:GetSpecialValueFor( "speed" )
	local ricochet_radius_start = self:GetSpecialValueFor( "ricochet_radius_start" )
	local ricochet_radius_end = self:GetSpecialValueFor( "ricochet_radius_end" )
	local ricochet_distance = self:GetCastRange(target:GetOrigin(), target) * self:GetSpecialValueFor( "ricochet_distance_multiplier" )

	-- linear projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = target:GetOrigin(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		
		bDeleteOnHit = false,
		
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		
		EffectName = effect_name_linear,
		fDistance = ricochet_distance,
		fStartRadius = ricochet_radius_start,
		fEndRadius = ricochet_radius_end,
		vVelocity = direction * speed,
	
		bProvidesVision = true,
		iVisionRadius = ricochet_radius_start,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	local projID = ProjectileManager:CreateLinearProjectile( info )

	local data = {}
	self.projectiles[projID] = data
	data.info = info_ricochet
	data.OnHit = function( this, ricochet_target, location )
		return self:OnRicochetHit( target, ricochet_target, location, direction )
	end

	EmitSoundOnLocationWithCaster(target:GetOrigin(), "Hero_Muerta.DeadShot.Ricochet", caster)
end

function ishtar_w:OnRicochetHit( initial_target, target, location, direction )
	if target==initial_target then return false end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor( "damage" )
	local fear_duration = self:GetSpecialValueFor( "ricochet_fear_duration" )

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage( damageTable )

	EmitSoundOn( "Hero_Muerta.DeadShot.Damage", target )


	if target:IsRealHero() then
		-- apply fear
		target:AddNewModifier(
			caster,
			self,
			"modifier_muerta_dead_shot_lua",
			{duration = fear_duration}
		):Init( direction )

		EmitSoundOn( "Hero_Muerta.DeadShot.Ricochet.Impact", target )
		return true
	end

	self:PlayEffects( target )

	return false
end

--------------------------------------------------------------------------------
-- Projectile
function ishtar_w:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	if not data then return end

	local pos = ProjectileManager:GetLinearProjectileLocation( handle )

	if data.OnThink then
		data:OnThink( pos )
	end
end

function ishtar_w:OnProjectileHitHandle( target, location, handle )
	local data = self.projectiles[handle]
	if not data then return end

	if not target then
		if data.OnDestroy then
			data:OnDestroy( location )
		end
		self.projectiles[handle] = nil
		return
	end

	if data.OnHit then
		return data:OnHit( target, location )
	end
end

--------------------------------------------------------------------------------
-- Effects
function ishtar_w:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_muerta/muerta_deadshot_creep_impact.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT,
		"attach_hitloc",
		Vector(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end]]
