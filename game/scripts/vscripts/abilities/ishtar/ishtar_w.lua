ishtar_w = class({})

function ishtar_w:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
end

function ishtar_w:GetMana()
	return 200 
end

function ishtar_w:GetAbilityTextureName()
	return "abilities/ishtar/ishtar_w"
end

function ishtar_w:GetCastAnimation()
	return nil
end

function ishtar_w:GetChannelTime()
	return 1 
end

function ishtar_w:OnSpellStart()
	local caster = self:GetCaster() 

	caster:AddNewModifier(caster, self, "modifier_ishtar_w_dash", {Duration = self:GetChannelTime()})
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
