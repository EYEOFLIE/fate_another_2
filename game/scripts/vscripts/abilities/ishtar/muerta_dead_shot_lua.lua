-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
ishtar_f = class({})
LinkLuaModifier( "modifier_generic_vector_target", "abilities/ishtar/modifier_generic_vector_target", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function ishtar_f:GetIntrinsicModifierName()
	return "modifier_generic_vector_target"
end

--------------------------------------------------------------------------------
-- Ability Custom Indicator (using CustomIndicator library, this section is Client Lua only)
function ishtar_f:CreateCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end

	-- get data
	local caster = self:GetCaster()
	local ricochet_radius_start = self:GetSpecialValueFor( "ricochet_radius_start" )
	local ricochet_radius_end = self:GetSpecialValueFor( "ricochet_radius_end" )

	-- primary cast unit
	-- NOTE: We don't know how to get tree entity is currently targeted in Panorama yet. Only units.
	if unit then
		self.is_primary_unit = true
		self.client_vector_target = unit
	else
		self.is_primary_unit = false
		self.client_vector_target = position or self:GetCaster():GetAbsOrigin()
	end

	-- create particle
	local particle_cast = "particles/ui_mouseactions/range_finder_cone.vpcf"
	self.indicator = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( self.indicator, 3, Vector( ricochet_radius_start, ricochet_radius_end, 0 ) )
	ParticleManager:SetParticleControl( self.indicator, 4, Vector( 0, 255, 0 ) )
	ParticleManager:SetParticleControl( self.indicator, 6, Vector( 1, 0, 0 ) )

	-- do logic that is similar to update func
	self:UpdateCustomIndicator( position, unit, behavior )
end

function ishtar_f:UpdateCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end

	-- get data
	local ricochet_range = self:GetCastRange( position, unit ) * self:GetSpecialValueFor( "ricochet_distance_multiplier" )
	local origin_pos = self.client_vector_target
	if self.is_primary_unit then
		origin_pos = self.client_vector_target:GetAbsOrigin()
	end

	local direction = position - origin_pos
	direction.z = 0
	direction = direction:Normalized()

	local end_pos = origin_pos + direction * ricochet_range

	-- update particle
	ParticleManager:SetParticleControl( self.indicator, 1, origin_pos )
	ParticleManager:SetParticleControl( self.indicator, 2, end_pos )
end

function ishtar_f:DestroyCustomIndicator( position, unit, behavior )
	if behavior~=DOTA_CLICK_BEHAVIOR_VECTOR_CAST then return end
	self.is_primary_unit = nil
	self.client_vector_target  = nil

	-- destroy particle
	ParticleManager:DestroyParticle(self.indicator, false)
	ParticleManager:ReleaseParticleIndex(self.indicator)
	self.indicator = nil
end

-- Ability Start
ishtar_f.projectiles = {}
function ishtar_f:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local vector_point = self.vector_position
	if not vector_point then
		-- likely reflected, otherwise set forward as default
		vector_point = ishtar_f.reflect_location or (target:GetOrigin() + target:GetForwardVector())
	end

	caster:EmitSound("Ishtar.F" .. math.random(1,3))

	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.Projectile" .. math.random(1,4) , caster)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.ProjectileBase" , caster)

	-- load data
	local speed = self:GetSpecialValueFor( "speed" )
	local damage = self:GetSpecialValueFor( "damage" )

	local effect_name_tracking = "particles/ishtar/ishtar_proj_track.vpcf"
	local effect_name_tree = "particles/ishtar/ishtar_proj_linear.vpcf"

	-- calculate ricochet direction
	local direction = vector_point - target:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

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

function ishtar_f:OnTreeHit( tree, direction, location )
	-- ricochet
	self:LaunchRicochet( tree, direction )
	GridNav:DestroyTreesAroundPoint(tree:GetOrigin(), 0, true)

	EmitSoundOnLocationWithCaster( location, "Hero_Muerta.DeadShot.Tree", self:GetCaster() )
end

function ishtar_f:OnInitialHit( direction, target, location )
	local caster = self:GetCaster()

	if target:IsMagicImmune() or target:IsInvulnerable() then return end

	-- NOTE: Lotus reflects direction to the opposite of original cast
	-- this code below create static variable for reflected ability to use
	ishtar_f.reflect_location = caster:GetOrigin() - direction
	ishtar_f.reflected = true
	local reflect = target:TriggerSpellAbsorb( self )
	ishtar_f.reflect_location = nil
	ishtar_f.reflected = nil

	if reflect then return end

	local damage = self:GetSpecialValueFor( "damage" )

	local gem_ability = caster:FindAbilityByName("ishtar_d")
	local bonus_f_percentage_per_gem = gem_ability:GetSpecialValueFor("bonus_f_percentage_per_gem")

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	if stack == 0 then
	else
		damage = damage + (damage * (stack * bonus_f_percentage_per_gem) / 100)
	end

	target:EmitSound("Ishtar.ProjectileLayer")
	target:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

	local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
	local particleeff2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())

	-- ricochet
	self:LaunchRicochet( target, direction )

	EmitSoundOn( "Hero_Muerta.DeadShot.Slow", target )
end

function ishtar_f:LaunchRicochet( target, direction )
	local caster = self:GetCaster()

	local effect_name_linear = "particles/ishtar/ishtar_proj_linear.vpcf"
	local speed = self:GetSpecialValueFor( "speed" )
	local ricochet_radius_start = self:GetSpecialValueFor( "ricochet_radius_start" )
	local ricochet_radius_end = self:GetSpecialValueFor( "ricochet_radius_end" )
	local ricochet_distance = self:GetCastRange(target:GetOrigin(), target) * self:GetSpecialValueFor( "ricochet_distance_multiplier" )

	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.Projectile" .. math.random(1,4) , caster)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.ProjectileBase" , caster)

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

function ishtar_f:OnRicochetHit( initial_target, target, location, direction )
	if target==initial_target then return false end

	local caster = self:GetCaster()
	local splash_radius = self:GetSpecialValueFor( "splash_radius" )
	local speed = self:GetSpecialValueFor( "speed" )
	local ricochet_damage_multiplier = self:GetSpecialValueFor( "ricochet_damage_multiplier" )
	local damage = self:GetSpecialValueFor( "damage" ) * ricochet_damage_multiplier

	local splash = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for i = 1, #splash do
		local delay = 0.4
		Timers:CreateTimer(delay * i, function()
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.Projectile" .. math.random(1,4) , caster)
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.ProjectileBase" , caster)
			
			-- Create Tracking Projectile
			local effect_name_tracking = "particles/ishtar/ishtar_proj_track.vpcf"
			local info = {
				Source = target,
				Target = splash[i],
				Ability = self,
				iMoveSpeed = speed,
				EffectName = effect_name_tracking,
				bDodgeable = true,
			}
			local projID = ProjectileManager:CreateTrackingProjectile( info )

			local data = {}
			self.projectiles[projID] = data
			data.info = info
			data.OnHit = function( this, target, damage )
				return self:OnSplashHit(target,damage)
			end
		end)
	end

	if target:IsRealHero() then
		local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
		local particleeff2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())
	return true
	end

	local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
	local particleeff2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())

	return false
end

function ishtar_f:OnSplashHit( target, damage )
	local caster = self:GetCaster()
	local ricochet_damage_multiplier = self:GetSpecialValueFor( "ricochet_damage_multiplier" )
	local damage = self:GetSpecialValueFor( "damage" ) * ricochet_damage_multiplier

	local gem_ability = caster:FindAbilityByName("ishtar_d")
	local bonus_f_percentage_per_gem = gem_ability:GetSpecialValueFor("bonus_f_percentage_per_gem")

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	if stack == 0 then
	else
		damage = damage + (damage * (stack * bonus_f_percentage_per_gem) / 100)
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	EmitSoundOn( "Hero_Muerta.DeadShot.Damage", target )

	if target:IsRealHero() then

		target:EmitSound("Ishtar.ProjectileLayer")
		target:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

		local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
		local particleeff2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())

		return true
	end
	
	local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
	local particleeff2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())

	return false
end

--------------------------------------------------------------------------------
-- Projectile
function ishtar_f:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	if not data then return end

	local pos = ProjectileManager:GetLinearProjectileLocation( handle )

	if data.OnThink then
		data:OnThink( pos )
	end
end

function ishtar_f:OnProjectileHitHandle( target, location, handle )
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

