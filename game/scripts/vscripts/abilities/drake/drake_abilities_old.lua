vectorA = Vector(0,0,0)

function OnAbilityCastCheck (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local targetPoint = ability:GetCursorPosition()
	if not IsInSameRealm(caster:GetAbsOrigin(), targetPoint) then
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target")
		return 
	end 
	if ability:GetAbilityName() == "drake_combo_golden_wild_hunt" then 
		EmitGlobalSound("Drake.PreCombo")
	end
end

function OnDrakeDeath (keys)
	local caster = keys.caster 
	if IsValidEntity(caster.flagship) then
    	caster.flagship:ForceKill(false)
    	UTIL_Remove(caster.flagship)
    	return
    end
    caster:RemoveModifierByName("modifier_military_tactic_cannon")
    caster:RemoveModifierByName("modifier_boarding_ship")
end
function OnMilitaryTacticStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_military_tactic_check", {})
	if caster.IsImproveMilitaryTacticAcquired then 
		ability:EndCooldown()
	end
end

function OnMilitaryTacticUpgrade (keys)
	local caster = keys.caster 
	caster:FindAbilityByName("drake_military_tactic_summon_cannon"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("drake_military_tactic_summon_boarding_ship"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("drake_military_tactic_summon_golden_anchor"):SetLevel(keys.ability:GetLevel())
end

function OnMilitaryTacticOpen (keys)
	local caster = keys.caster
	local ability = keys.ability 
	-- range
	if caster:HasModifier("modifier_pistol_buff") then 
		-- remove macabre skill 2 3
		if caster:HasModifier("modifier_crossing_fire_buff") then 
			caster:RemoveModifierByName("modifier_crossing_fire_buff")
		end
		caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon", false, true)
		caster:SwapAbilities("drake_crossing_fire", "drake_military_tactic_summon_boarding_ship", false, true)
	-- malee
	elseif caster:HasModifier("modifier_sword_buff") then
		-- remove macabre skill 2 3
		if caster:HasModifier("modifier_dance_macabre_1") then 
			caster:RemoveModifierByName("modifier_dance_macabre_1")
		end
		caster:SwapAbilities("drake_pistol", "drake_military_tactic_summon_cannon", false, true)
		caster:SwapAbilities("drake_dance_macabre_1", "drake_military_tactic_summon_boarding_ship", false, true)
	end
	if caster:HasModifier("modifier_golden_wild_hunt_window") then
		caster:RemoveModifierByName("modifier_golden_wild_hunt_window")
	end
	caster:SwapAbilities("drake_support_bombard", "drake_military_tactic_summon_golden_anchor", false, true)
	caster:SwapAbilities("drake_military_tactic", "drake_military_tactic_close", false, true)
	caster:SwapAbilities("drake_voyager_of_storm", "fate_empty3", false, true)
	-- add golden hind ship 
	if caster.IsLogBookAcquired then 
		caster:SwapAbilities("drake_golden_wild_hunt", "drake_military_tactic_summon_golden_hind", false, true)
	else
		caster:SwapAbilities("drake_golden_wild_hunt", "fate_empty5", false, true)
	end
end

function OnMilitaryTacticClose (keys)
	local caster = keys.caster
	local ability = keys.ability 
	-- remove board ship
	--[[if caster:HasModifier("modifier_boarding_ship") then 
		caster:RemoveModifierByName("modifier_boarding_ship")
	end
	-- remove summon cannon
	if caster:HasModifier("modifier_military_tactic_cannon") then 
		caster:RemoveModifierByName("modifier_military_tactic_cannon")
	end]]
	-- range
	if caster:HasModifier("modifier_pistol_buff") then 
		caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon", true, false)
		caster:SwapAbilities("drake_crossing_fire", "drake_military_tactic_summon_boarding_ship", true, false)
	-- malee
	elseif caster:HasModifier("modifier_sword_buff") then
		caster:SwapAbilities("drake_pistol", "drake_military_tactic_summon_cannon", true, false)
		caster:SwapAbilities("drake_dance_macabre_1", "drake_military_tactic_summon_boarding_ship", true, false)
	end
	caster:SwapAbilities("drake_support_bombard", "drake_military_tactic_summon_golden_anchor", true, false)
	caster:SwapAbilities("drake_military_tactic", "drake_military_tactic_close", true, false)
	caster:SwapAbilities("drake_voyager_of_storm", "fate_empty3", true, false)
	-- add golden hind ship 
	if caster.IsLogBookAcquired then 
		caster:SwapAbilities("drake_golden_wild_hunt", "drake_military_tactic_summon_golden_hind", true, false)
	else
		caster:SwapAbilities("drake_golden_wild_hunt", "fate_empty5", true, false)
	end
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:FindAbilityByName("drake_military_tactic"):StartCooldown(15.0)
	end

end

function OnMilitaryTacticCloseStart (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_military_tactic_check")
end

function OnSummonCannonStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_military_tactic_cannon", {})
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end
end

function OnSummonCannonCreate (keys)
	local caster = keys.caster 
	local ability = keys.ability 	
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local cannon_range = ability:GetSpecialValueFor("cannon_range")
	local cannon_delay = ability:GetSpecialValueFor("cannon_delay")
	local cannon_width = ability:GetSpecialValueFor("cannon_width")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")

	if caster.summon_cannon == nil then 
		caster.summon_cannon = {}
	end

	caster.summon_cannon = CreateUnitByName("drake_cannon_dummy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.summon_cannon:SetAbsOrigin(caster:GetAbsOrigin() + Vector(caster:GetForwardVector().x * 100, caster:GetForwardVector().y * 100, 0))
	caster.summon_cannon:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.summon_cannon:SetForwardVector(caster:GetForwardVector())
	caster.summon_cannon:SetModelScale(1.0)
	-- Update the control point as long as modifer is up
	Timers:CreateTimer( function()

		local frontVec = caster:GetForwardVector()
		local origin = caster:GetAbsOrigin()
		caster.summon_cannon:SetAbsOrigin( Vector(origin.x + frontVec.x * 100, origin.y +  frontVec.y * 100, origin.z))
		caster.summon_cannon:SetForwardVector(frontVec)
		if caster:HasModifier( "modifier_military_tactic_cannon" ) and not IsRevoked(caster) then
			return 0.1
		else
			if IsValidEntity(caster.summon_cannon) then 
				caster.summon_cannon:ForceKill(false)
				UTIL_Remove(caster.summon_cannon)
			end
			return nil
		end
	end)

	for i = 0, cannon_count do
		Timers:CreateTimer(i * cannon_delay, function() 
			if not caster:HasModifier("modifier_military_tactic_cannon") or IsRevoked(caster) then return end
			if caster:IsAlive() then 
				SummonCannonShoot (caster, ability, cannon_range, cannon_width, cannon_speed)
			end
		end)
	end
end

function SummonCannonShoot (caster, ability, distance, width, speed)
	local forwardVec = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin() + Vector(forwardVec.x * 100, forwardVec.y * 100, 70)
	local dummy_loc = origin
	local dummy_cannon = CreateUnitByName("dummy_unit", dummy_loc, false, caster, caster, caster:GetTeamNumber())
	caster.cannon_bullet = dummy_cannon
	caster.cannon_bullet:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.cannon_bullet:SetForwardVector(forwardVec)	
	local duration = distance / speed 
	ability:ApplyDataDrivenModifier(caster, dummy_cannon, "modifier_cannon_check", {duration = duration})
	local CannonBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet_yellow.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy_cannon)
	ParticleManager:SetParticleControl( CannonBulletFx, 0, dummy_cannon:GetAbsOrigin() )
	ParticleManager:SetParticleControl( CannonBulletFx, 1, forwardVec * speed )
	caster.cannon_bulletfx = CannonBulletFx
	

	Timers:CreateTimer(function()
		if IsValidEntity(dummy_cannon) then
			if dummy_cannon:HasModifier("modifier_cannon_check") then
				dummy_loc = dummy_loc + (speed * 0.05) * Vector(forwardVec.x, forwardVec.y, 0)								
				dummy_cannon:SetAbsOrigin(dummy_loc)
				return 0.05
			else
				ParticleManager:DestroyParticle( CannonBulletFx, false )
				ParticleManager:ReleaseParticleIndex( CannonBulletFx )
				dummy_cannon:RemoveSelf()
				return nil 
			end
		else
			return nil
		end
	end)

	--[[Timers:CreateTimer(duration, function()
		if IsValidEntity(caster.cannon_bullet) then
			ParticleManager:DestroyParticle( CannonBulletFx, false )
			ParticleManager:ReleaseParticleIndex( CannonBulletFx )			
			Timers:CreateTimer(0.05, function()
				dummy_cannon:RemoveSelf()
				return nil
			end)
		end
		return nil
	end)]]

    local projectileTable = {
		Ability = ability,
		--EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf",
		iMoveSpeed = speed,
		vSpawnOrigin = origin,
		fDistance = distance,
		Source = caster,
		fStartRadius = width,
        fEndRadius = width,
		bHasFrontialCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 1.0,
		bDeleteOnHit = true,
		vVelocity = forwardVec * speed,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
   
    caster:EmitSound("Hero_Snapfire.Shotgun.Fire")
    local CannonFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(CannonFx, 0, origin + Vector(forwardVec.x * 100, forwardVec.y * 100, 35)) 
	local FireFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, origin + Vector(forwardVec.x * 100, forwardVec.y * 100, 35))
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( CannonFx, false )
		ParticleManager:ReleaseParticleIndex( CannonFx )
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
	end)
end

function OnSummonCannonHit (keys)
	if keys.target == nil then return end

	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")
	caster.cannon_bullet:RemoveModifierByName("modifier_cannon_check")
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = cannon_stun})
	target:EmitSound("Hero_Snapfire.Shotgun.Target")
	local CannonFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(CannonFx, 0, target:GetAbsOrigin()) 
	-- radius fire blast, spark, fire ring
	ParticleManager:SetParticleControl(CannonFx, 1, Vector(cannon_aoe,0.3,cannon_aoe)) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( CannonFx, false )
		ParticleManager:ReleaseParticleIndex( CannonFx )
	end)
	local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, cannon_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs (enemies) do
		DoDamage(caster, enemy, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnSummonCannonDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_military_tactic_cannon")
end

function OnBoardingShipStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_boarding_ship", {})
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end
end

function OnBoardingShipCreate (keys)
	local caster = keys.caster 
	-- Sets the new model
	caster:SetModel("models/drake/drake_boat.vmdl")
	caster:SetOriginalModel("models/drake/drake_boat.vmdl")
	caster:SetModelScale(1.2)
	local WaterSplashFx = ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_water_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	caster.WaterSplashFx = WaterSplashFx
	ParticleManager:SetParticleControl(caster.WaterSplashFx, 0, caster:GetAbsOrigin()) 
	
end

function OnBoardingShipDrive (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local impact_dmg = ability:GetSpecialValueFor("impact_dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local range_dmg = ability:GetSpecialValueFor("range_dmg")
	local range_atk_aoe = ability:GetSpecialValueFor("range_atk_aoe")
	local origin = caster:GetOrigin()

	local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), origin, nil, knockback, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
	 
	local modifierKnockback =
	{
		center_x = caster:GetAbsOrigin().x,
		center_y = caster:GetAbsOrigin().y,
		center_z = caster:GetAbsOrigin().z,
		duration = 0.5,
		knockback_duration = 0.1,
		knockback_distance = knockback,
		knockback_height = 100,
	}

	for _,unit in pairs(knockBackUnits) do
	--	print( "knock back unit: " .. unit:GetName() )
		if not unit:HasModifier("modifier_knockback") then
			if not IsKnockbackImmune(unit) or not unit:IsBarracks() or not unit:HasFlyMovementCapability() or not IsLocked(unit) or not IsRevoked(unit) then
				unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback )
			end
			DoDamage(caster, unit, impact_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
end

function OnBoardingShipFire (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local range_dmg = ability:GetSpecialValueFor("range_dmg")
	local range_atk_aoe = ability:GetSpecialValueFor("range_atk_aoe")
	local origin = caster:GetOrigin()
	if caster:HasModifier("modifier_pistol_buff") then 
		local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, range_atk_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
		if targets[1] == nil then return end
		DoDamage(caster, targets[1], range_dmg, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		caster:EmitSound("Hero_Sniper.attack")
		local GunFireFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(GunFireFx, 0, caster:GetOrigin()) 
		-- Destroy particle after delay
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( GunFireFx, false )
			ParticleManager:ReleaseParticleIndex( GunFireFx )
			targets[1]:EmitSound("Hero_Sniper.ProjectileImpact")
		end)
	end
end

function OnBoardingShipDestroy (keys)
	local caster = keys.caster 
	-- Sets the new model
	caster:SetModel("models/drake/drake.vmdl")
	caster:SetOriginalModel("models/drake/drake.vmdl")
	caster:SetModelScale(1.2)
	ParticleManager:DestroyParticle( caster.WaterSplashFx, false )
	ParticleManager:ReleaseParticleIndex( caster.WaterSplashFx )
end

function OnBoardingShipDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_boarding_ship")
end

function OnGoldenAnchorStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ability:GetSpecialValueFor("dmg")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")

	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end

	local AnchorFx = ParticleManager:CreateParticle("particles/custom/drake/drake_anchor.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(AnchorFx, 0, target_loc) 
	Timers:CreateTimer(cast_delay, function()
		local SmashFx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnus_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(SmashFx, 0, target_loc) 
		local SmashRingFx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnus_dust_hit_ring.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(SmashRingFx, 0, target_loc) 
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Snapfire.FeedCookie.Impact", caster)
		local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
		for _,enemy in pairs (enemies) do
			DoDamage(caster, enemy, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			if not enemy:IsMagicImmune() then
				enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
			end
		end
		Timers:CreateTimer(0.3, function()
			ParticleManager:DestroyParticle( AnchorFx, false )
			ParticleManager:ReleaseParticleIndex( AnchorFx )
			ParticleManager:DestroyParticle( SmashFx, false )
			ParticleManager:ReleaseParticleIndex( SmashFx )
			ParticleManager:DestroyParticle( SmashRingFx, false )
			ParticleManager:ReleaseParticleIndex( SmashRingFx )
		end)
	end)

end

function OnCastSummonGoldenHind (keys)
	local caster = keys.caster 
	local ability = keys.ability
	if IsValidEntity(caster.flagship) or caster:HasModifier("modifier_golden_wild_hunt_check") then
    	caster:Stop()
    	SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Summon")
    	return
    end
end

function OnSummonGoldenHindStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()

	if IsValidEntity(caster.flagship) or caster:HasModifier("modifier_golden_wild_hunt_check") then
    	ability:EndCooldown()
    	caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
    	return
    end

    if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end

    caster.flagship = CreateUnitByName("drake_golden_hind", origin, false, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(caster.flagship, origin + Vector(-forwardVec.x * 100,-forwardVec.y * 100,-100), true)
    caster.flagship:SetForwardVector(forwardVec)
	caster.flagship:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.flagship:EmitSound("Ability.Torrent")
	if caster.IsStrengthenGoldenHindAcquired then 
		caster.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(1)
		caster.flagship:SwapAbilities("fate_empty1", "drake_golden_hind_passive", false, true)
		caster.flagship:CreatureLevelUp(1)
	else
		caster.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(0)
		caster.flagship:RemoveModifierByName("modifier_golden_hind_passive")
	end
	caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetLevel(1)
	-- active when mount
	caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetActivated(false)
	caster.flagship:FindAbilityByName("drake_golden_hind_bombard"):SetLevel(1)
	caster.flagship:FindAbilityByName("drake_golden_hind_defensive_cannon"):SetLevel(1)
	caster.flagship:AddItem(CreateItem("item_drake_onboard" , nil, nil))
end

function OnGoldenHindPassiveThink (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec

	local target_left_lock = 0
	local target_right_lock = 0
	
	local AxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(forwardVec.x * 300, forwardVec.y * 300,0), origin - Vector(forwardVec.x * 500,forwardVec.y * 500,0), nil, 200.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,NonTarget in pairs (AxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, NonTarget, "modifier_golden_hind_non_target", {})
	end
	local RightAxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(rightVec.x * 300, rightVec.y * 300,0) + Vector(forwardVec.x * 300, forwardVec.y * 300,0), origin + Vector(rightVec.x * 300, rightVec.y * 300,0) - Vector(forwardVec.x * 500,forwardVec.y * 500,0), nil, 200.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,RightTarget in pairs (RightAxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, RightTarget, "modifier_golden_hind_right_target", {})
	end
	local LeftAxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(leftVec.x * 300, leftVec.y * 300,0) + Vector(forwardVec.x * 300, forwardVec.y * 300,0), origin + Vector(leftVec.x * 300, leftVec.y * 300,0) - Vector(forwardVec.x * 500,forwardVec.y * 500,0), nil, 200.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,LeftTarget in pairs (LeftAxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, LeftTarget, "modifier_golden_hind_left_target", {})
	end
	local CannonTarget = FindUnitsInRadius(caster:GetTeam(), origin, nil, 500.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,SideTarget in pairs (CannonTarget) do
		if not SideTarget:HasModifier("modifier_golden_hind_non_target") then
			-- left side of ship
			if SideTarget:HasModifier("modifier_golden_hind_left_target") then 
				if target_left_lock == 4 then break end
				target_left_lock = target_left_lock + 1
				if target_left_lock == 1 then 
					local cannon_left_origin1 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_left_origin1)
					end
				end
				if target_left_lock == 2 then 
					local cannon_left_origin2 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_left_origin2)
					end
				end
				if target_left_lock == 3 then 
					local cannon_left_origin3 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_left_origin3)
					end
				end
			-- right side of ship
			elseif SideTarget:HasModifier("modifier_golden_hind_right_target") then
				if target_right_lock == 4 then break end
				target_right_lock = target_right_lock + 1
				if target_right_lock == 1 then 
					local cannon_right_origin1 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_right_origin1)
					end
				end
				if target_right_lock == 2 then 
					local cannon_right_origin2 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_right_origin2)
					end
				end
				if target_right_lock == 3 then 
					local cannon_right_origin3 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0)
					if SideTarget:IsAlive() and caster:IsAlive() then 
						GoldenHindSideShoot (caster, ability, SideTarget, cannon_right_origin3)
					end
				end
			end
		end
	end
end

function GoldenHindSideShoot (caster, ability, target, origin)
	local projectileTable = {
        EffectName = "",
        Ability = ability,
        vSpawnOrigin = origin,
        Target = target,
        Source = caster, 
        iMoveSpeed = 1500,
        bDodgable = true,
        bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(projectileTable)
    local CannonFireFxR1 = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(CannonFireFxR1, 0, origin) 
	local FireFxR1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxR1, 0, origin)
	caster:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( CannonFireFxR1, false )
		ParticleManager:ReleaseParticleIndex( CannonFireFxR1 )
		ParticleManager:DestroyParticle( FireFxR1, false )
		ParticleManager:ReleaseParticleIndex( FireFxR1 )
	end)
end

function OnGoldenHindSideCannonHit (keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	DoDamage(caster, target, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	target:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Target")
	local BombFx = ParticleManager:CreateParticle("particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack_explode_debris.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(BombFx, 0, target:GetOrigin()) 
	local DustFx = ParticleManager:CreateParticle("particles/econ/events/ti9/rock_golem_tower/dire_tower_attack_explode_dust_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(DustFx, 0, target:GetOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( BombFx, false )
		ParticleManager:ReleaseParticleIndex( BombFx )
		ParticleManager:DestroyParticle( DustFx, false )
		ParticleManager:ReleaseParticleIndex( DustFx )
	end)
	if not target:IsMagicImmune() then 
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.5})
		local aoe = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, cannon_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,unit in pairs (aoe) do
			if unit ~= target then 
				DoDamage(caster, unit, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	end
end

function OnGoldenHindDriveStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_drive", {})
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	if hero:HasModifier("modifier_sword_buff") then
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.5})
	elseif hero:HasModifier("modifier_pistol_buff") then 
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.5})
	end
end

function OnGoldenHindDrive (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local impact_dmg = ability:GetSpecialValueFor("impact_dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local origin = caster:GetOrigin()
	local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), origin, nil, knockback, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
	 
	local modifierKnockback =
	{
		center_x = caster:GetAbsOrigin().x,
		center_y = caster:GetAbsOrigin().y,
		center_z = caster:GetAbsOrigin().z,
		duration = 0.5,
		knockback_duration = 0.1,
		knockback_distance = knockback,
		knockback_height = knockback,
	}

	for _,unit in pairs(knockBackUnits) do
	--	print( "knock back unit: " .. unit:GetName() )
		if not unit:HasModifier("modifier_knockback") then
			if not IsKnockbackImmune(unit) or not IsLocked(unit) or not IsRevoked(unit) or not unit:IsBarracks() then
				unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback )
			end
			DoDamage(caster, unit, impact_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
end

function OnGoldenHindBombardStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	if hero.IsBoarded == true then
		if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.5})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.9})
		end
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_bombard", {})

	local origin = caster:GetAbsOrigin()
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec
	local target_loc = ability:GetCursorPosition()
	local cannon_interval = ability:GetSpecialValueFor("cannon_interval")
	local aoe = ability:GetSpecialValueFor("aoe")
	local bomb_aoe = ability:GetSpecialValueFor("bomb_aoe")
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_stun = ability:GetSpecialValueFor("bomb_stun")
	local forwardVec = ( target_loc - caster:GetAbsOrigin() ):Normalized()
	local visiondummy = SpawnVisionDummy(caster, target_loc, aoe, 3, false)

	Timers:CreateTimer( function()
		if caster:HasModifier("modifier_golden_hind_bombard") then
			local cannonVector = Vector(RandomFloat(-aoe, aoe), RandomFloat(-aoe, aoe), 0)
			
			-- Create Cannon particles
			-- Main variables
			local delay = 0.5				-- Delay before damage
			
			-- Side variables
			local spawn_location = origin
			local random_location = RandomInt(1, 6) 
			if random_location == 1 then 
				spawn_location = origin + (leftVec * 100) + (forwardVec * 200)
			elseif random_location == 2 then 
				spawn_location = origin + (leftVec * 100)
			elseif random_location == 3 then 
				spawn_location = origin + (leftVec * 100) - (forwardVec * 200)
			elseif random_location == 4 then 
				spawn_location = origin + (rightVec * 100) + (forwardVec * 200)
			elseif random_location == 5 then 
				spawn_location = origin + (rightVec * 100)
			elseif random_location == 6 then 
				spawn_location = origin + (rightVec * 100) - (forwardVec * 200)
			end

			local target_location = target_loc + cannonVector
			local newForwardVec = ( target_location - spawn_location ):Normalized()
			local speed = (target_location - spawn_location):Length2D() / delay
			target_location = target_location + 100 * newForwardVec
			local dummy_loc = spawn_location
			local dummy_cannon = CreateUnitByName("dummy_unit", dummy_loc, false, caster, caster, caster:GetTeamNumber())
			dummy_cannon:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummy_cannon:SetForwardVector(newForwardVec)	

			local CannonBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet_yellow.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy_cannon)
			ParticleManager:SetParticleControl( CannonBulletFx, 0, dummy_cannon:GetAbsOrigin() )
			ParticleManager:SetParticleControl( CannonBulletFx, 1, newForwardVec * speed )
	
			Timers:CreateTimer(function()
				if IsValidEntity(dummy_cannon) then
					dummy_loc = dummy_loc + (speed * 0.05) * newForwardVec						
					dummy_cannon:SetAbsOrigin(dummy_loc)
					return 0.05
				else
					return nil
				end
			end)
			local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( FireFxIndex, 0, spawn_location )
			local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( SmokeFxIndex, 0, spawn_location )
			caster:EmitSound("Hero_Snapfire.Shotgun.Fire")
			
			-- Delay
			Timers:CreateTimer( delay, function()
				-- Destroy particles
				ParticleManager:DestroyParticle( CannonBulletFx, false )
				ParticleManager:ReleaseParticleIndex( CannonBulletFx )
				ParticleManager:DestroyParticle( FireFxIndex, false )
				ParticleManager:ReleaseParticleIndex( FireFxIndex )
				ParticleManager:DestroyParticle( SmokeFxIndex, false )
				ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
				dummy_cannon:RemoveSelf()
					
				-- Delay damage
				local targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, bomb_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets) do
					DoDamage(caster, v, bomb_dmg , DAMAGE_TYPE_MAGICAL, 0, ability, none, false)
					if not v:IsMagicImmune() then
						v:AddNewModifier(caster, v, "modifier_stunned", {Duration = bomb_stun})
					end
				end
				EmitSoundOnLocationWithCaster(target_location, "Hero_Snapfire.Shotgun.Target", caster)
				-- Particles on impact
				local BombFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(BombFx, 0, target_location) 
				-- radius fire blast, spark, fire ring
				ParticleManager:SetParticleControl(BombFx, 1, Vector(bomb_aoe,0.3,bomb_aoe)) 
				-- Destroy particle after delay
				Timers:CreateTimer(0.5, function()
					ParticleManager:DestroyParticle( BombFx, false )
					ParticleManager:ReleaseParticleIndex( BombFx )
				end)
				return nil
			end)	
			return cannon_interval
		else 
			return
		end
    end)
end

function OnGoldenHindBombardCancel (keys)
	keys.caster:RemoveModifierByName("modifier_golden_hind_bombard")
end

function OnGlenderHindDefensiveCannon (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local aoe = ability:GetSpecialValueFor("aoe")
	local origin = caster:GetOrigin()
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local forwardVec = caster:GetForwardVector()
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec
	if hero.IsBoarded == true then
		if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.9})
		end
	end
	local cannonorigin1 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0)
	local cannonorigin2 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0)
	local cannonorigin3 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0)
	local cannonorigin4 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0)
	local cannonorigin5 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0)
	local cannonorigin6 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0)
	caster:EmitSound("Hero_Snapfire.Shotgun.Fire")

	local FireFxIndex1 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex1, 0, cannonorigin1 )
	local SmokeFxIndex1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex1, 0, cannonorigin1 )
	local FireFxIndex2 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex2, 0, cannonorigin2 )
	local SmokeFxIndex2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex2, 0, cannonorigin2 )
	local FireFxIndex3 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex3, 0, cannonorigin3 )
	local SmokeFxIndex3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex3, 0, cannonorigin3 )
	local FireFxIndex4 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex4, 0, cannonorigin4 )
	local SmokeFxIndex4 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex4, 0, cannonorigin4 )
	local FireFxIndex5 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex5, 0, cannonorigin5 )
	local SmokeFxIndex5 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex5, 0, cannonorigin5 )
	local FireFxIndex6 = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex6, 0, cannonorigin6 )
	local SmokeFxIndex6 = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex6, 0, cannonorigin6 )
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex1, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex1)
		ParticleManager:DestroyParticle( SmokeFxIndex1, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex1 )
		ParticleManager:DestroyParticle( FireFxIndex2, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex2)
		ParticleManager:DestroyParticle( SmokeFxIndex2, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex2 )
		ParticleManager:DestroyParticle( FireFxIndex3, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex3)
		ParticleManager:DestroyParticle( SmokeFxIndex3, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex3 )
		ParticleManager:DestroyParticle( FireFxIndex4, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex4)
		ParticleManager:DestroyParticle( SmokeFxIndex4, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex4 )
		ParticleManager:DestroyParticle( FireFxIndex5, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex5)
		ParticleManager:DestroyParticle( SmokeFxIndex5, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex5 )
		ParticleManager:DestroyParticle( FireFxIndex6, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex6)
		ParticleManager:DestroyParticle( SmokeFxIndex6, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex6 )
	end)

	local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), origin, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
	for _,target in pairs(knockBackUnits) do
		if caster ~= nil then
			if not IsKnockbackImmune(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (unit_target_origin - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

    			giveUnitDataDrivenModifier(caster, target, "drag_pause" , 1.0)
		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback)
	   			target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
				target:OnPhysicsFrame(function(unit) -- pushback distance check
					local unitOrigin = unit:GetAbsOrigin()
					local diff = unitOrigin - unit_target_origin
					local n_diff = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
					if diff:Length() > knockback or not unit:HasModifier("drag_pause") then -- if pushback distance is over 150, stop it
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
					end
				end)
			end
			DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
end

function OnVoyagerStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_voyager_lucky", {})
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		local ply = caster:GetMainControllingPlayer()
		local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
		if hero.IsBoarded == true then
			if hero:HasModifier("modifier_sword_buff") then
				StartAnimation(hero, {duration=4.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
			elseif hero:HasModifier("modifier_pistol_buff") then 
				StartAnimation(hero, {duration=4.0, activity=ACT_DOTA_IDLE_RARE, rate=0.9})
			end
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_storm_aura", {})
	end
	DrakeCheckCombo (caster, ability)
end

function OnVoyagerLucky (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ProjectileManager:ProjectileDodge(caster)
end

function OnVoyagerLuckyTakeDamage (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local currentHealth = caster:GetHealth()
	print(keys.DamageTaken)
	if currentHealth < keys.DamageTaken then 
		caster:SetHealth(1)
		EmitGlobalSound("Drake.Voyager")
	end
end

function OnThunderStrike (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local point = RandomPointInCircle(caster:GetOrigin(), radius)
	local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx1, 0, Vector(point.x,point.y,point.z))
	ParticleManager:SetParticleControl(thunderfx1, 1, Vector(point.x,point.y,1000))
	local thundergroundfx1 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thundergroundfx1, 0, Vector(point.x,point.y,point.z))
	EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
 	local thunder = FindUnitsInRadius(caster:GetTeam(), point, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	for _,thundertarget in pairs (thunder) do
 		if not thundertarget:IsMagicImmune() then 
 			thundertarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
 		end
 		DoDamage(caster, thundertarget, 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 	end
 	local point2 = RandomPointInCircle(caster:GetOrigin(), radius)
 	local thunderfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx2, 0, Vector(point2.x,point2.y,point2.z))
	ParticleManager:SetParticleControl(thunderfx2, 1, Vector(point2.x,point2.y,1000))
	local thundergroundfx2 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thundergroundfx2, 0, Vector(point2.x,point2.y,point2.z))
	EmitSoundOnLocationWithCaster(point2, "Hero_Zuus.LightningBolt", caster)
 	local thunder2 = FindUnitsInRadius(caster:GetTeam(), point2, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	for _,thundertarget2 in pairs (thunder2) do
 		if not thundertarget2:IsMagicImmune() then 
 			thundertarget2:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
 		end
 		DoDamage(caster, thundertarget2, 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 	end
 	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( thunderfx1, false )
		ParticleManager:ReleaseParticleIndex( thunderfx1 )
		ParticleManager:DestroyParticle( thundergroundfx1, false )
		ParticleManager:ReleaseParticleIndex( thundergroundfx1 )
		ParticleManager:DestroyParticle( thunderfx2, false )
		ParticleManager:ReleaseParticleIndex( thunderfx2 )
		ParticleManager:DestroyParticle( thundergroundfx2, false )
		ParticleManager:ReleaseParticleIndex( thundergroundfx2 )
	end)
end

function OnBoardStart(keys)
	local caster = keys.caster
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	Timers:CreateTimer(0.2, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsBoarded then
				-- If Caster is attempting to unmount on not traversable terrain,
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(hero:GetPlayerOwnerID(), "#Cannot_Get_Off")
					return								
				else
					hero:RemoveModifierByName("modifier_board_drake")
					caster:RemoveModifierByName("modifier_board")
					hero.IsBoarded = false
					SendMountStatus(hero)
					hero:SetModelScale(1.2)
					if not caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):IsCooldownReady() then 
						hero:FindAbilityByName("drake_voyager_of_storm"):StartCooldown(caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):GetCooldownTimeRemaining())
					end 
					if not caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):IsCooldownReady() then 
						hero:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):GetCooldownTimeRemaining())
					end
					caster:SwapAbilities("fate_empty6", "drake_golden_hind_voyager_of_storm", true, false) 
					caster:SwapAbilities("fate_empty7", "drake_golden_hind_golden_wild_hunt", true, false)
					caster:FindAbilityByName("drake_golden_hind_drive"):SetActivated(false)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then
				hero.IsBoarded = true
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_board_drake", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_board", {}) 
				SendMountStatus(hero)
				caster:SwapAbilities("fate_empty6", "drake_golden_hind_voyager_of_storm", false, true) 
				caster:SwapAbilities("fate_empty7", "drake_golden_hind_golden_wild_hunt", false, true) 
				caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):SetLevel(1)
				if not hero:FindAbilityByName("drake_voyager_of_storm"):IsCooldownReady() then 
					caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):StartCooldown(hero:FindAbilityByName("drake_voyager_of_storm"):GetCooldownTimeRemaining())
				else
					if not caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):IsCooldownReady() then 
						caster:FindAbilityByName("drake_golden_hind_voyager_of_storm"):EndCooldown()
					end
				end
				caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):SetLevel(hero:FindAbilityByName("drake_golden_wild_hunt"):GetLevel())
				if not hero:FindAbilityByName("drake_golden_wild_hunt"):IsCooldownReady() then 
					caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):StartCooldown(hero:FindAbilityByName("drake_golden_wild_hunt"):GetCooldownTimeRemaining())
				else
					if not caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):IsCooldownReady() then 
						caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):EndCooldown()
					end
				end
				caster:FindAbilityByName("drake_golden_hind_drive"):SetActivated(true)
				return
			end 
		end
	end)
end


--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Positions Caster on Dragon's back every tick as long as Caster is mounted
]]
function BoardFollow(keys)
	local caster = keys.caster
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local forwardVec = caster:GetForwardVector()
	if not caster:IsNull() and IsValidEntity(caster) then
		hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(-forwardVec.x * 150,-forwardVec.y * 150,150))
		hero:SetForwardVector(forwardVec)
		hero:SetModelScale(0.8)
	end
end
--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Un-mounts Caster
]]
function OnBoardDeath(keys)
	local caster = keys.caster
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	hero:RemoveModifierByName("modifier_board_drake")
	caster:SwapAbilities("fate_empty6", "drake_golden_hind_voyager_of_storm", true, false) 
	caster:SwapAbilities("fate_empty7", "drake_golden_hind_golden_wild_hunt", true, false) 
	caster:FindAbilityByName("drake_golden_hind_drive"):SetActivated(false)
	hero.IsBoarded = false
	SendMountStatus(hero)
	hero:SetModelScale(1.2)
end

function OnPistalStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_sword_buff")
	if caster:HasModifier("modifier_dance_macabre_1") then 
		caster:RemoveModifierByName("modifier_dance_macabre_1")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pistol_buff", {}) 
	caster:SetAttackCapability(2)	
	caster:SwapAbilities("drake_pistol", "drake_sword", false, true)
	caster:SwapAbilities("drake_dance_macabre_1", "drake_crossing_fire", false, true)
end

function OnPistalUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability:GetLevel() == caster:FindAbilityByName("drake_sword"):GetLevel() then return end
	caster:FindAbilityByName("drake_sword"):SetLevel(ability:GetLevel())
end

function OnPistalCreate (keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:HasModifier("modifier_sword_buff") then 
		caster:RemoveModifierByName("modifier_pistol_buff")
	end
end

function OnPistalAttackStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local mana_cost = ability:GetSpecialValueFor("mana_cost")
	local double_atk_chance = ability:GetSpecialValueFor("double_atk_chance")
	if caster:GetMana() >= mana_cost then 
		caster:SpendMana(mana_cost, ability)
		caster.mana_bullet = true 
		caster:SetRangedProjectileName("particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf")
	else
		caster.mana_bullet = false
		caster:SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_base_attack.vpcf")
	end
	local random = RandomInt(1, 2)
	if random == 1 then 
		attack = ACT_DOTA_ATTACK
	elseif random == 2 then 
		attack = ACT_DOTA_ATTACK2
	end
	if caster.IsPioneerOfStarAcquired then 
		if RandomInt(1, 100) <= double_atk_chance then 
			caster.double_atk = true 
			StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=1.5})
		else
			caster.double_atk = false 
			StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=attack, rate=1.5})
		end
	else
		StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=attack, rate=1.5})
	end
end

function OnPistalAttackLand (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local bonus_dmg = ability:GetSpecialValueFor("bonus_dmg")
	if caster.mana_bullet and caster.mana_bullet == true then
		if not target:IsMagicImmune() then 	
			DoDamage(caster, target, bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	if caster.double_atk and caster.double_atk == true then 
		caster:PerformAttack( target, true, true, true, true, true, false, false )
		if caster.mana_bullet and caster.mana_bullet == true then
			if not target:IsMagicImmune() then 	
				DoDamage(caster, target, bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	elseif caster.double_atk and caster.double_atk == false then 
	end
end

function OnSwordStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_pistol_buff")
	if caster:HasModifier("modifier_crossing_fire_buff") then 
		caster:RemoveModifierByName("modifier_crossing_fire_buff")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sword_buff", {}) 
	caster:SetAttackCapability(1)	
	caster:SwapAbilities("drake_pistol", "drake_sword", true, false)
	caster:SwapAbilities("drake_dance_macabre_1", "drake_crossing_fire", true, false)
end

function OnSwordUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability:GetLevel() == caster:FindAbilityByName("drake_pistol"):GetLevel() then return end
	caster:FindAbilityByName("drake_pistol"):SetLevel(ability:GetLevel())
end
	
function OnSwordCreate (keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:HasModifier("modifier_pistol_buff") then 
		caster:RemoveModifierByName("modifier_sword_buff")
	end
end

function OnCrossingFireStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local bullet_interval = ability:GetSpecialValueFor("bullet_interval")
	local rate = 20 / (24 * bullet_interval)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_crossing_fire_buff", {})
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_ATTACK_EVENT, rate=rate})
	OnCrossingFireThink (caster, ability)
end 

function OnCrossingFireUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local macabre = caster:FindAbilityByName("drake_dance_macabre_1")
	if ability:GetLevel() == macabre:GetLevel() then 
	else	
		macabre:SetLevel(macabre:GetLevel() + 1)
	end
end

function OnCrossingFireThink (caster, ability)
	local bullet_distance = ability:GetSpecialValueFor("bullet_distance")
	local bullet_speed = ability:GetSpecialValueFor("bullet_speed")
	local bullet_interval = ability:GetSpecialValueFor("bullet_interval")
	local bullet_count = math.floor(4 / bullet_interval)
	for i = 0,bullet_count do
		Timers:CreateTimer( bullet_interval * i, function()
			if not caster:HasModifier("modifier_crossing_fire_buff") then return end
			local origin = caster:GetAbsOrigin()
			local frontVec = caster:GetForwardVector() 
			local backVec = -frontVec 
			local rightVec = caster:GetRightVector() 
			local leftVec = -rightVec 
			local front_origin = origin + Vector(frontVec.x * 50, frontVec.y * 50, 0)
			local back_origin = origin + Vector(backVec.x * 50, backVec.y * 50, 0)
			local left_origin = origin + Vector(leftVec.x * 50, leftVec.y * 50, 0)
			local right_origin = origin + Vector(rightVec.x * 50, rightVec.y * 50, 0)
			OnCrossingFireShoot (caster, ability, front_origin, frontVec, bullet_distance, bullet_speed)
			OnCrossingFireShoot (caster, ability, back_origin, backVec, bullet_distance, bullet_speed)
			OnCrossingFireShoot (caster, ability, left_origin, leftVec, bullet_distance, bullet_speed)
			OnCrossingFireShoot (caster, ability, right_origin, rightVec, bullet_distance, bullet_speed)

			if caster.IsPioneerOfStarAcquired then 
				Timers:CreateTimer( 0.1, function()
					OnCrossingFireShoot (caster, ability, front_origin, frontVec, bullet_distance, bullet_speed)
					OnCrossingFireShoot (caster, ability, back_origin, backVec, bullet_distance, bullet_speed)
					OnCrossingFireShoot (caster, ability, left_origin, leftVec, bullet_distance, bullet_speed)
					OnCrossingFireShoot (caster, ability, right_origin, rightVec, bullet_distance, bullet_speed)
				end)
			end
		end)
	end
end

function OnCrossingFireShoot (caster, ability, origin, vector, distance, speed)
	local duration = distance / speed 
	local projectileTable = {
		Ability = ability,
		--EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = speed,
		vSpawnOrigin = origin,
		fDistance = distance,
		Source = caster,
		fStartRadius = 100.0,
        fEndRadius = 100.0,
		bHasFrontialCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP,
		fExpireTime = GameRules:GetGameTime() + duration,
		bDeleteOnHit = true,
		vVelocity = vector * speed,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
    local dummy_loc = origin
	
	local dummy_bullet = CreateUnitByName("dummy_unit", dummy_loc, false, caster, caster, caster:GetTeamNumber())
	dummy_bullet:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy_bullet:SetForwardVector(vector)	
	
	ability:ApplyDataDrivenModifier(caster, dummy_bullet, "modifier_crossing_fire_check", {duration = duration})
	if vector == frontVec then 
		ability:ApplyDataDrivenModifier(caster, dummy_bullet, "modifier_crossing_aura_front_check", {duration = duration})
		caster.bullet_front = dummy_bullet
	elseif vector == backVec then 
		ability:ApplyDataDrivenModifier(caster, dummy_bullet, "modifier_crossing_aura_back_check", {duration = duration})
		caster.bullet_back = dummy_bullet
	elseif vector == backVec then 
		ability:ApplyDataDrivenModifier(caster, dummy_bullet, "modifier_crossing_aura_left_check", {duration = duration})
		caster.bullet_left = dummy_bullet
	elseif vector == backVec then 
		ability:ApplyDataDrivenModifier(caster, dummy_bullet, "modifier_crossing_aura_right_check", {duration = duration})
		caster.bullet_right = dummy_bullet
	end
	local CrossingFireBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy_bullet )
	ParticleManager:SetParticleControl( CrossingFireBulletFx, 0, dummy_bullet:GetAbsOrigin() )
	ParticleManager:SetParticleControl( CrossingFireBulletFx, 1, vector * speed )

	Timers:CreateTimer(function()
		if IsValidEntity(dummy_bullet) then
			if dummy_bullet:HasModifier("modifier_crossing_fire_check") then
				dummy_loc = dummy_loc + (speed * 0.05) * Vector(vector.x, vector.y, 0)								
				dummy_bullet:SetAbsOrigin(dummy_loc)
				return 0.05
			else
				ParticleManager:DestroyParticle( CrossingFireBulletFx, false )
				ParticleManager:ReleaseParticleIndex( CrossingFireBulletFx )
				dummy_bullet:RemoveSelf()
				return nil 
			end
		else
			return nil
		end
	end)

    local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, origin )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, origin )
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
	end)
	caster:EmitSound("Hero_Ancient_Apparition.ProjectileImpact")
end

function OnCrossingFireHit (keys)
	if keys.target == nil then return end 
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local bullet_mini_stun = ability:GetSpecialValueFor("bullet_mini_stun")
	local bullet_dmg = ability:GetSpecialValueFor("bullet_dmg")
	if target:HasModifier("modifier_crossing_front_check") then 
		caster.bullet_front:RemoveModifierByName("modifier_crossing_fire_check")
	elseif target:HasModifier("modifier_crossing_back_check") then 
		caster.bullet_back:RemoveModifierByName("modifier_crossing_fire_check")
	elseif target:HasModifier("modifier_crossing_left_check") then 
		caster.bullet_left:RemoveModifierByName("modifier_crossing_fire_check")
	elseif target:HasModifier("modifier_crossing_right_check") then 
		caster.bullet_right:RemoveModifierByName("modifier_crossing_fire_check")
	end
	DoDamage(caster, target, bullet_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = bullet_mini_stun})
	
end

function OnCrossingFireDestroy (keys)
	local caster = keys.caster 
	StartAnimation(caster, {duration=0.1, activity=ACT_DOTA_IDLE, rate=1.5})
end

function OnDanceMacabre1Start (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local dmg = ability:GetSpecialValueFor("dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local width = ability:GetSpecialValueFor("width")
	local stun = ability:GetSpecialValueFor("stun")
	local forwardvec = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local end_target = origin + Vector(forwardvec.x *  width, forwardvec.y * width ,0)
	StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK, rate=1.5})
	caster:EmitSound("Drake.Dance1")
	caster:EmitSound("Hero_Abaddon.PreAttack")
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_1", {})
			if not IsKnockbackImmune(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
				target:OnPhysicsFrame(function(unit) -- pushback distance check
					local unitOrigin = unit:GetAbsOrigin()
					local diff = unitOrigin - unit_target_origin
					local n_diff = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
					if diff:Length() > knockback or not unit:HasModifier("modifier_dance_macabre_knock_back_1") then -- if pushback distance is over 150, stop it
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
					end
				end)
			end
			DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	if caster:IsAlive() then 
		Timers:CreateTimer(0.2, function()
			local BlurFxIndex = ParticleManager:CreateParticle( "particles/custom/drake/drake_dance_macabre_blur_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( BlurFxIndex, 0, origin )
			Timers:CreateTimer(0.5, function()
				ParticleManager:DestroyParticle( BlurFxIndex, false )
				ParticleManager:ReleaseParticleIndex( BlurFxIndex )
			end)
		end)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dance_macabre_knock_back_1", {})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dance_macabre_1", {})
		caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_2", false, true)
		caster.macabre = 1
		local unit_caster_origin = caster:GetAbsOrigin()		
 		local unit_caster_direction = (end_target - origin):Normalized()
    	local dashCaster = Physics:Unit(caster)

		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		local vectorC_caster = unit_caster_direction
		-- get the direction where target will be pushed back to
		local vectorB_caster = vectorC_caster - vectorA
		caster:SetPhysicsVelocity(vectorB_caster:Normalized() * knockback * 2)
	   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
		caster:OnPhysicsFrame(function(casterunit) -- pushback distance check
			local casterOrigin = casterunit:GetAbsOrigin()
			local diff_caster = casterOrigin - unit_caster_origin
			local n_diff_caster = diff_caster:Normalized()
			casterunit:SetPhysicsVelocity(casterunit:GetPhysicsVelocity():Length() * n_diff_caster) -- track the movement of target being pushed back
			if diff_caster:Length() > knockback or not casterunit:HasModifier("modifier_dance_macabre_knock_back_1") then -- if pushback distance is over 150, stop it
				casterunit:PreventDI(false)
				casterunit:SetPhysicsVelocity(Vector(0,0,0))
				casterunit:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(casterunit, casterunit:GetAbsOrigin(), true)
			end
		end)
	end
end

function OnDanceMacabreUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local crossfire = caster:FindAbilityByName("drake_crossing_fire")
	if ability:GetLevel() == crossfire:GetLevel() then 
	else
		crossfire:SetLevel(crossfire:GetLevel() + 1)
	end
	caster:FindAbilityByName("drake_dance_macabre_2"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("drake_dance_macabre_3"):SetLevel(ability:GetLevel())
end

function OnDanceMacabre2Start (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local dmg = ability:GetSpecialValueFor("dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local width = ability:GetSpecialValueFor("width")
	local stun = ability:GetSpecialValueFor("stun")
	local forwardvec = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local end_target = origin + Vector(forwardvec.x *  width, forwardvec.y * width ,0)
	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_ATTACK2, rate=1.5})
	caster:EmitSound("Hero_Abaddon.PreAttack")
	caster:EmitSound("Drake.Dance2")
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_2", {})
			if not IsKnockbackImmune(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
				target:OnPhysicsFrame(function(unit) -- pushback distance check
					local unitOrigin = unit:GetAbsOrigin()
					local diff = unitOrigin - unit_target_origin
					local n_diff = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
					if diff:Length() > knockback or not unit:HasModifier("modifier_dance_macabre_knock_back_2") then -- if pushback distance is over 150, stop it
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
					end
				end)
			end
			DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	if caster:IsAlive() then 
		Timers:CreateTimer(0.2, function()
			local BlurFxIndex = ParticleManager:CreateParticle( "particles/custom/drake/drake_dance_macabre_blur_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( BlurFxIndex, 0, origin )
			Timers:CreateTimer(0.5, function()
				ParticleManager:DestroyParticle( BlurFxIndex, false )
				ParticleManager:ReleaseParticleIndex( BlurFxIndex )
			end)
		end)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dance_macabre_knock_back_2", {})
		if caster:HasModifier("modifier_dance_macabre_1") and caster.macabre == 1 then
			caster:SwapAbilities("drake_dance_macabre_2", "drake_dance_macabre_3", false, true)
			caster.macabre = 2
		end
		local unit_caster_origin = caster:GetAbsOrigin()		
 		local unit_caster_direction = (end_target - origin):Normalized()
    	local dashCaster = Physics:Unit(caster)

		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		local vectorC_caster = unit_caster_direction
		-- get the direction where target will be pushed back to
		local vectorB_caster = vectorC_caster - vectorA
		caster:SetPhysicsVelocity(vectorB_caster:Normalized() * knockback * 2)
	   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
		caster:OnPhysicsFrame(function(casterunit) -- pushback distance check
			local casterOrigin = casterunit:GetAbsOrigin()
			local diff_caster = casterOrigin - unit_caster_origin
			local n_diff_caster = diff_caster:Normalized()
			casterunit:SetPhysicsVelocity(casterunit:GetPhysicsVelocity():Length() * n_diff_caster) -- track the movement of target being pushed back
			if diff_caster:Length() > knockback or not casterunit:HasModifier("modifier_dance_macabre_knock_back_2") then -- if pushback distance is over 150, stop it
				casterunit:PreventDI(false)
				casterunit:SetPhysicsVelocity(Vector(0,0,0))
				casterunit:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(casterunit, casterunit:GetAbsOrigin(), true)
			end
		end)
	end
end

function OnDanceMacabre3Start (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local dmg = ability:GetSpecialValueFor("dmg")
	local knockback = ability:GetSpecialValueFor("knockback")
	local width = ability:GetSpecialValueFor("width") + 50
	local stun = ability:GetSpecialValueFor("stun")
	local forwardvec = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local end_target = origin + Vector(forwardvec.x *  width, forwardvec.y * width ,0)
	caster:RemoveModifierByName("modifier_dance_macabre_1")
	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=2.0})
	caster:EmitSound("Hero_Abaddon.PreAttack")
	caster:EmitSound("Drake.Dance3")
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_3", {})
			if not IsKnockbackImmune(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
				target:OnPhysicsFrame(function(unit) -- pushback distance check
					local unitOrigin = unit:GetAbsOrigin()
					local diff = unitOrigin - unit_target_origin
					local n_diff = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
					if diff:Length() > knockback or not unit:HasModifier("modifier_dance_macabre_knock_back_3") then -- if pushback distance is over 150, stop it
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
						if target:IsAlive() then 
							target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
						end
					end
				end)
			end
			DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	if caster:IsAlive() then 
		Timers:CreateTimer(0.2, function()
			local BlurFxIndex = ParticleManager:CreateParticle( "particles/custom/drake/drake_dance_macabre_blur_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( BlurFxIndex, 0, origin + Vector(-forwardvec.x * 100, -forwardvec.y * 100,0) )
			Timers:CreateTimer(0.5, function()
				ParticleManager:DestroyParticle( BlurFxIndex, false )
				ParticleManager:ReleaseParticleIndex( BlurFxIndex )
			end)
		end)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dance_macabre_knock_back_3", {})
		local unit_caster_origin = caster:GetAbsOrigin()		
 		local unit_caster_direction = (end_target - origin):Normalized()
    	local dashCaster = Physics:Unit(caster)

		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		local vectorC_caster = unit_caster_direction
		-- get the direction where target will be pushed back to
		local vectorB_caster = vectorC_caster - vectorA
		caster:SetPhysicsVelocity(vectorB_caster:Normalized() * knockback * 2)
	   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
		caster:OnPhysicsFrame(function(casterunit) -- pushback distance check
			local casterOrigin = casterunit:GetAbsOrigin()
			local diff_caster = casterOrigin - unit_caster_origin
			local n_diff_caster = diff_caster:Normalized()
			casterunit:SetPhysicsVelocity(casterunit:GetPhysicsVelocity():Length() * n_diff_caster) -- track the movement of target being pushed back
			if diff_caster:Length() > knockback or not casterunit:HasModifier("modifier_dance_macabre_knock_back_3") then -- if pushback distance is over 150, stop it
				casterunit:PreventDI(false)
				casterunit:SetPhysicsVelocity(Vector(0,0,0))
				casterunit:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(casterunit, casterunit:GetAbsOrigin(), true)
			end
		end)
	end
	if caster.IsPioneerOfStarAcquired then 
		Timers:CreateTimer( 0.5, function()
			local whirlwind = FindUnitsInRadius(caster:GetTeam(), end_target, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,knockup in pairs (whirlwind) do
				DoDamage(caster, knockup, 150 + caster:GetAgility() * 2, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				ApplyAirborne(caster, knockup, 1.25)
				local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( upstreamFx, 0, end_target )
			end
		end)
	end
end

function OnDanceMacabreDie (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_dance_macabre_1")
end

function OnDanceMacabreWindowDestroy (keys)
	local caster = keys.caster 
	if caster.macabre == 1 then 
		caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_2", true, false)
	elseif caster.macabre == 2 then 
		caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_3", true, false)
	end
	caster.macabre = 0
	print(caster.macabre)
end

function OnSummonBombardStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local frontVec = caster:GetForwardVector()
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() 
	local leftVec = -rightVec 
	local cannon3origin = origin + Vector(backVec.x * 200, backVec.y * 200, 200)
	local cannon1origin = cannon3origin + Vector(rightVec.x * 100, rightVec.y * 100, -50)
	local cannon2origin = cannon3origin + Vector(rightVec.x * 50, rightVec.y * 50, 0)
	local cannon4origin = cannon3origin + Vector(leftVec.x * 50, leftVec.y * 50, 0)
	local cannon5origin = cannon3origin + Vector(leftVec.x * 100, leftVec.y * 100, -50)
	local aoe = ability:GetSpecialValueFor("aoe")
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval") 
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_stun = ability:GetSpecialValueFor("bomb_stun")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local bomb_count = ability:GetSpecialValueFor("bomb_count")

	if caster.IsImproveMilitaryTacticAcquired then 
		bomb_count = bomb_count + 1
	end
	local visiondummy = SpawnVisionDummy(caster, position, aoe, 3, false)

	Timers:CreateTimer( cast_delay, function()
		caster.bombard_cannon1 = CreateUnitByName("drake_cannon_dummy", cannon1origin, false, caster, caster, caster:GetTeamNumber())
		caster.bombard_cannon2 = CreateUnitByName("drake_cannon_dummy", cannon2origin, false, caster, caster, caster:GetTeamNumber())
		caster.bombard_cannon3 = CreateUnitByName("drake_cannon_dummy", cannon3origin, false, caster, caster, caster:GetTeamNumber())
		caster.bombard_cannon4 = CreateUnitByName("drake_cannon_dummy", cannon4origin, false, caster, caster, caster:GetTeamNumber())
		caster.bombard_cannon5 = CreateUnitByName("drake_cannon_dummy", cannon5origin, false, caster, caster, caster:GetTeamNumber())
		caster.bombard_cannon1:SetOrigin(cannon1origin + Vector(0,0,-120))
		caster.bombard_cannon2:SetOrigin(cannon2origin + Vector(0,0,-100))
		caster.bombard_cannon3:SetOrigin(cannon3origin + Vector(0,0,-100))
		caster.bombard_cannon4:SetOrigin(cannon4origin + Vector(0,0,-100))
		caster.bombard_cannon5:SetOrigin(cannon5origin + Vector(0,0,-120))
		caster.bombard_cannon1:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bombard_cannon2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bombard_cannon3:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bombard_cannon4:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bombard_cannon5:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bombard_cannon1:SetForwardVector(frontVec)
		caster.bombard_cannon2:SetForwardVector(frontVec)
		caster.bombard_cannon3:SetForwardVector(frontVec)
		caster.bombard_cannon4:SetForwardVector(frontVec)
		caster.bombard_cannon5:SetForwardVector(frontVec)
		
		for i = 1, bomb_count do
			Timers:CreateTimer( bomb_interval*i, function()
				if i == 1 then local cannonorigin = cannon1origin end
				if i == 2 then cannonorigin = cannon2origin end
				if i == 3 then cannonorigin = cannon3origin end
				if i == 4 then cannonorigin = cannon4origin end
				if i == 5 then cannonorigin = cannon5origin end
				if i == 6 then cannonorigin = cannon3origin end
				SummonBombardShoot (caster, ability, position, cannonorigin, bomb_speed)
			end)
		end
		Timers:CreateTimer( bomb_interval * (bomb_count + 1), function()
			caster.bombard_cannon1:RemoveSelf()
			caster.bombard_cannon2:RemoveSelf()
			caster.bombard_cannon3:RemoveSelf()
			caster.bombard_cannon4:RemoveSelf()
			caster.bombard_cannon5:RemoveSelf()
		end)
	end)
end

function SummonBombardShoot (caster, ability, position, origin, speed)
	local origindummy = CreateUnitByName("dummy_unit", origin , false, caster, caster, caster:GetTeamNumber())
	origindummy:SetOrigin(origin)
    origindummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	local targetdummy = CreateUnitByName("dummy_unit", position , false, caster, caster, caster:GetTeamNumber())
    targetdummy:SetOrigin(position)
    targetdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

	local projectileTable = {
        EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf",
        Ability = ability,
        vSpawnOrigin = origin,
        Target = targetdummy,
        Source = origindummy, 
        iMoveSpeed = speed,
        bDodgable = false,
        bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(projectileTable)
    caster:EmitSound("Hero_Snapfire.Shotgun.Fire")
    -- Particles on impact
	local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, origin )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, origin )
	-- Destroy Particle
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
		Timers:CreateTimer( 0.5, function()
			if targetdummy then
           		targetdummy:RemoveSelf()
        	end
        	if origindummy then
           		origindummy:RemoveSelf()
        	end
        end)
	end)	
end

function OnSummonBombardHit (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local aoe = ability:GetSpecialValueFor("aoe")
	local bomb_stun = ability:GetSpecialValueFor("bomb_stun")
	target:EmitSound("Hero_Snapfire.Shotgun.Target") 
	-- Particles on impact
	local BombFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(BombFx, 0, target:GetOrigin()) 
	-- radius fire blast, spark, fire ring
	ParticleManager:SetParticleControl(BombFx, 1, Vector(aoe,0,aoe)) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( BombFx, false )
		ParticleManager:ReleaseParticleIndex( BombFx )
	end)
	local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs (enemies) do
		if not enemy:IsMagicImmune() then 
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = bomb_stun})
		end
		DoDamage(caster, enemy, bomb_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnGoldenWildHuntStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local position = ability:GetCursorPosition()
	local frontVec = caster:GetForwardVector()
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() 
	local leftVec = -rightVec 
	local bomb_count = ability:GetSpecialValueFor("bomb_count")
	local aoe = ability:GetSpecialValueFor("aoe")
	local point = RandomPointInCircle(position, aoe)
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval")
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cannon_interval = ability:GetSpecialValueFor("cannon_interval")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local visiondummy = SpawnVisionDummy(caster, position, aoe, 5, false)
	-- front line
	local flagshiporigin = origin + Vector(backVec.x * 100, backVec.y * 100, -100)
	local smallship5origin = flagshiporigin + Vector(leftVec.x * 400, leftVec.y * 400,100)
	local smallship4origin = flagshiporigin + Vector(rightVec.x * 400, rightVec.y * 400,100)
	-- second line
	local mediumship1origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(rightVec.x * 300, rightVec.y * 300,0)
	local mediumship2origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(leftVec.x * 300, leftVec.y * 300,0)
	local bigship1origin = mediumship1origin + Vector(rightVec.x * 300, rightVec.y * 300,100)
	local bigship2origin = mediumship2origin + Vector(leftVec.x * 300, leftVec.y * 300,100)
	--third line
	local bigship3origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600, 0) + Vector(rightVec.x * 200, rightVec.y * 200,0)
	local smallship1origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600,0) + Vector(leftVec.x * 200, leftVec.y * 200,0)
	local mediumship3origin = bigship3origin + Vector(rightVec.x * 200, rightVec.y * 200,100)
	local mediumship4origin = smallship1origin + Vector(leftVec.x * 200, leftVec.y * 200,100)
	local smallship2origin = bigship3origin + Vector(rightVec.x * 400, rightVec.y * 400,0)
	local smallship3origin = smallship1origin + Vector(leftVec.x * 400, leftVec.y * 400,0)
	
	
	-- golden hind
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		if caster:HasModifier("modifier_golden_wild_hunt_check") then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + 800)
			return
		end
		if IsValidEntity(caster.flagship) then 
			caster.flagship:SetOrigin(flagshiporigin)
			caster.flagship:SetForwardVector(frontVec)
			giveUnitDataDrivenModifier(caster, caster.flagship, "jump_pause" , 5.0)
		else
			caster.flagshipdummy = CreateUnitByName("drake_golden_hind_dummy", flagshiporigin, false, caster, caster, caster:GetTeamNumber())
			caster.flagshipdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			caster.flagshipdummy:SetForwardVector(frontVec)
			caster.flagshipdummy:EmitSound("Ability.Torrent")
		end
		if caster.IsStrengthenGoldenHindAcquired then 
			cannon_count = cannon_count + 1 
		end
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		flagshiporigin = origin
		if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.9})
		end
		giveUnitDataDrivenModifier(caster, caster, "drag_pause" , 5.0)
		if hero.IsStrengthenGoldenHindAcquired then 
			cannon_count = cannon_count + 1 
		end
 	end
 	EmitGlobalSound("Drake.WildHunt")
 	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_check", {})
 	if caster.bigship == nil then 
		caster.bigship = {}
	end
	if caster.smallship == nil then 
		caster.smallship = {}
	end
 	-- fleet
 	for j = 1,3 do
 		if j == 1 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship1origin)
 		elseif j == 2 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship2origin)
 		elseif j == 3 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship3origin)
 		end
 		caster.bigship[j]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 		caster.bigship[j]:SetModelScale(1.3)
 		caster.bigship[j]:SetForwardVector(frontVec)
 	end

 	for b = 1,bomb_count do
 		if b == 1 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship3origin)
 		elseif b == 2 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship2origin)
 		elseif b == 3 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship4origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship4origin)
 		elseif b == 4 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship4origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship4origin)
 		elseif b == 5 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship2origin)
 		elseif b == 6 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship5origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(smallship5origin)
 			caster.smallship[b]:SetModelScale(0.8)
 		elseif b == 7 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship1origin)
 		elseif b == 8 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship1origin)
 		elseif b == 9 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship3origin)
 		end
 		caster.smallship[b]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 		caster.smallship[b]:SetForwardVector(frontVec)
 	end

 	for i = 1,bomb_count do
 		Timers:CreateTimer(bomb_interval * i, function()
 			if not caster:IsAlive() then return end
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 1, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 2, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 3, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 4, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 5, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 6, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 7, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 8, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 9, bomb_speed, 1)
 		end)
 	end

 	for k = 1, cannon_count do
 		Timers:CreateTimer(cannon_interval * k, function()
 			if not caster:IsAlive() then return end
 			if k == 5 then 
 				local bigbomb = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 				for _,bigbomb in pairs (bigbomb) do
 					if not bigbomb:IsMagicImmune() then 
 						bigbomb:AddNewModifier(caster, ability, "modifier_stunned", {duration = 1.0})
 					end
 					DoDamage(caster, bigbomb, 500, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 				end
 				return
 			end
 			if k >= 1 and k < 5 then
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 1, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 2, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 3, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 4, cannon_speed, 2)
 			end
 		end)
 	end
end

function GoldenWildHuntShoot (caster, ability, position,casterorigin, i, speed, iship)
	local frontVec = caster:GetForwardVector()
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() 
	local leftVec = -rightVec 
	-- front line
	local flagshiporigin = casterorigin + Vector(backVec.x * 100, backVec.y * 100, -100)
	local smallship5origin = flagshiporigin + Vector(leftVec.x * 400, leftVec.y * 400,100)
	local smallship4origin = flagshiporigin + Vector(rightVec.x * 400, rightVec.y * 400,100)
	-- second line
	local mediumship1origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(rightVec.x * 300, rightVec.y * 300,0)
	local mediumship2origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(leftVec.x * 300, leftVec.y * 300,0)
	local bigship1origin = mediumship1origin + Vector(rightVec.x * 300, rightVec.y * 300,100)
	local bigship2origin = mediumship2origin + Vector(leftVec.x * 300, leftVec.y * 300,100)
	--third line
	local bigship3origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600, 0) + Vector(rightVec.x * 200, rightVec.y * 200,0)
	local smallship1origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600,0) + Vector(leftVec.x * 200, leftVec.y * 200,0)
	local mediumship3origin = bigship3origin + Vector(rightVec.x * 200, rightVec.y * 200,100)
	local mediumship4origin = smallship1origin + Vector(leftVec.x * 200, leftVec.y * 200,100)
	local smallship2origin = bigship3origin + Vector(rightVec.x * 400, rightVec.y * 400,0)
	local smallship3origin = smallship1origin + Vector(leftVec.x * 400, leftVec.y * 400,0)

	if caster.bomb_target == nil then 
		caster.bomb_target = {}
	end
	if caster.cannon_target == nil then 
		caster.cannon_target = {}
	end
	if iship == 1 then
		if i == 1 then 
			origin = smallship5origin
		elseif i == 2 then
			origin = mediumship1origin
		elseif i == 3 then
			origin = mediumship2origin
		elseif i == 4 then
			origin = mediumship3origin
		elseif i == 5 then
			origin = mediumship4origin
		elseif i == 6 then
			origin = smallship1origin
		elseif i == 7 then
			origin = smallship2origin
		elseif i == 8 then
			origin = smallship3origin
		elseif i == 9 then
			origin = smallship4origin
		end
		local bomb_origin = CreateUnitByName("dummy_unit", origin , false, caster, caster, caster:GetTeamNumber())
		bomb_origin:SetOrigin(origin)
    	bomb_origin:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		caster.bomb_target[i] = CreateUnitByName("dummy_unit", position , false, caster, caster, caster:GetTeamNumber())
    	caster.bomb_target[i]:SetOrigin(position)
    	caster.bomb_target[i]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
    	local bomb_target = caster.bomb_target[i]
    	local projectileTable = {
       	 	EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf",
       		Ability = ability,
        	vSpawnOrigin = origin,
        	Target = bomb_target,
        	Source = bomb_origin, 
        	iMoveSpeed = speed,
        	bDodgable = false,
        	bProvidesVision = true,
        	fExpireTime = GameRules:GetGameTime() + 0.6,
			bDeleteOnHit = true,
    	}
   	 	ProjectileManager:CreateTrackingProjectile(projectileTable)
   	 	bomb_origin:EmitSound("Hero_Snapfire.MortimerBlob.Launch")
   	 	-- Particles on impact
		local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( FireFxIndex, 0, origin )
		local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( SmokeFxIndex, 0, origin )
		-- Destroy Particle
		Timers:CreateTimer( 0.5, function()
			ParticleManager:DestroyParticle( FireFxIndex, false )
			ParticleManager:ReleaseParticleIndex( FireFxIndex )
			ParticleManager:DestroyParticle( SmokeFxIndex, false )
			ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
			if bomb_origin then 
        		bomb_origin:RemoveSelf()
        	end
        	Timers:CreateTimer( 0.5, function()
        		if IsValidEntity(bomb_target) then 
 					bomb_target:ForceKill(false)
    				UTIL_Remove(bomb_target)
        		end
        	end)
		end)		
    elseif iship == 2 then 
    	if i == 1 then 
			origin = flagshiporigin
		elseif i == 2 then
			origin = bigship1origin
		elseif i == 3 then
			origin = bigship2origin
		elseif i == 4 then
			origin = bigship3origin
		end
		local cannon_origin = CreateUnitByName("dummy_unit", origin , false, caster, caster, caster:GetTeamNumber())
		cannon_origin:SetOrigin(origin)
    	cannon_origin:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
   		caster.cannon_target[i] = CreateUnitByName("dummy_unit", position , false, caster, caster, caster:GetTeamNumber())
    	caster.cannon_target[i]:SetOrigin(position)
    	caster.cannon_target[i]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
    	local cannon_target = caster.cannon_target[i]
    	local projectileTable = {
       	 	--EffectName = "particles/custom/drake/drake_cannon_bullet.vpcf",
       		Ability = ability,
        	vSpawnOrigin = origin,
        	Target = cannon_target,
        	Source = cannon_origin, 
        	iMoveSpeed = speed,
        	bDodgable = false,
        	bProvidesVision = true,
        	fExpireTime = GameRules:GetGameTime() + 0.6,
			bDeleteOnHit = true,
    	}
   	 	ProjectileManager:CreateTrackingProjectile(projectileTable)
   	 	cannon_origin:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
   	 	local newForwardVec = ( position - origin ):Normalized()
   	 	local distance = ( position - origin ):Length2D()
   	 	-- Particles on impact
   	 	local CannonBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet_yellow.vpcf", PATTACH_ABSORIGIN_FOLLOW, cannon_origin)
		ParticleManager:SetParticleControl( CannonBulletFx, 0, cannon_origin:GetAbsOrigin() )
		ParticleManager:SetParticleControl( CannonBulletFx, 1, newForwardVec * speed )
		Timers:CreateTimer( distance / speed + 0.1, function()
			ParticleManager:DestroyParticle( CannonBulletFx, false )
			ParticleManager:ReleaseParticleIndex( CannonBulletFx )
		end)
		local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( FireFxIndex, 0, origin )
		local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( SmokeFxIndex, 0, origin )
		-- Destroy Particle
		Timers:CreateTimer( 0.5, function()
			ParticleManager:DestroyParticle( FireFxIndex, false )
			ParticleManager:ReleaseParticleIndex( FireFxIndex )
			ParticleManager:DestroyParticle( SmokeFxIndex, false )
			ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
			if cannon_origin then 
        		cannon_origin:RemoveSelf()
        	end
        	Timers:CreateTimer( 0.5, function()
        		if IsValidEntity(cannon_target) then 
 					cannon_target:ForceKill(false)
    				UTIL_Remove(cannon_target)
        		end
        	end)
		end)		
   	end
end

function OnGoldenWildHuntHit (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_aoe = ability:GetSpecialValueFor("bomb_aoe")
	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")
	
	for _,bomb_target in pairs (caster.bomb_target) do	
		if bomb_target and IsValidEntity(bomb_target) then 
			if  bomb_target == target then
				target:EmitSound("Hero_Techies.RemoteMine.Detonate")
				local CannonFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl(CannonFx, 0, target:GetAbsOrigin()) 
				local FireFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, target )
				ParticleManager:SetParticleControl( FireFxIndex, 0, target:GetAbsOrigin() )
				-- Destroy particle after delay
				Timers:CreateTimer(0.5, function()
					ParticleManager:DestroyParticle( CannonFx, false )
					ParticleManager:ReleaseParticleIndex( CannonFx )
					ParticleManager:DestroyParticle( FireFxIndex, false )
					ParticleManager:ReleaseParticleIndex( FireFxIndex )
				end)
				local BombTarget = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bomb_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for _, slowtarget in pairs (BombTarget) do
					if not slowtarget:IsMagicImmune() then 
						ability:ApplyDataDrivenModifier(caster, slowtarget, "modifier_golden_wild_hunt_slow", {})
					end
					DoDamage(caster, slowtarget, bomb_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end
	end
	
	for _,cannon_target in pairs (caster.cannon_target) do	
		if target == cannon_target then 
			target:EmitSound("Hero_Snapfire.MortimerBlob.Impact")
			local CannonFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControl(CannonFx, 0, target:GetAbsOrigin()) 
		-- radius fire blast, spark, fire ring
			ParticleManager:SetParticleControl(CannonFx, 1, Vector(cannon_aoe,0.2,cannon_aoe)) 
		-- Destroy particle after delay
			Timers:CreateTimer(0.5, function()
				ParticleManager:DestroyParticle( CannonFx, false )
				ParticleManager:ReleaseParticleIndex( CannonFx )
			end)
			local CannonTarget = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, cannon_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for _, stuntarget in pairs (CannonTarget) do
				if not stuntarget:IsMagicImmune() then 
					stuntarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = cannon_stun})
				end
				DoDamage(caster, stuntarget, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	end
end

function OnGoldenWildHuntDestroy (keys)
	local caster = keys.caster 
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	for _,v in pairs(caster.smallship) do
		if v and IsValidEntity(v) then
            v:ForceKill(false)
            UTIL_Remove(v)
        end
	end
	for _,u in pairs(caster.bigship) do
		if u and IsValidEntity(u) then
            u:ForceKill(false)
            UTIL_Remove(u)
        end
	end
 	if IsValidEntity(caster.flagshipdummy) then 
 		caster.flagshipdummy:ForceKill(false)
    	UTIL_Remove(caster.flagshipdummy)
    end
    --[[for _,w in pairs(hero.smallship) do
		if w and IsValidEntity(w) then
            w:ForceKill(false)
            UTIL_Remove(w)
        end
	end
	for _,x in pairs(hero.bigship) do
		if x and IsValidEntity(x) then
            x:ForceKill(false)
            UTIL_Remove(x)
        end
	end]]
	for _,y in pairs(caster.bomb_target) do
		if y and IsValidEntity(y) then
            y:ForceKill(false)
            UTIL_Remove(y)
        end
	end
	for _,z in pairs(caster.cannon_target) do
		if z and IsValidEntity(z) then
            z:ForceKill(false)
            UTIL_Remove(z)
        end
	end
end

function OnGoldenWildHuntDie (keys)
	keys.caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
end

function DrakeCheckCombo(caster, ability)
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		if caster:GetStrength() >= 29.1 and caster:GetAgility() >= 29.1 and caster:GetIntellect() >= 29.1 then
			if ability == caster:FindAbilityByName("drake_voyager_of_storm") and caster:FindAbilityByName("drake_golden_wild_hunt"):IsCooldownReady() and not caster:HasModifier("modifier_golden_wild_hunt_cooldown") and not caster:HasModifier("modifier_golden_wild_hunt_check") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
			end
		end
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		local ply = caster:GetMainControllingPlayer()
		local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
		if hero:GetStrength() >= 29.1 and hero:GetAgility() >= 29.1 and hero:GetIntellect() >= 29.1 then
			if ability == caster:FindAbilityByName("drake_golden_hind_voyager_of_storm") and caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):IsCooldownReady() and not hero:HasModifier("modifier_golden_wild_hunt_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
			end
		end
	end
end

function OnComboWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", false, true) 
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		caster:SwapAbilities("drake_golden_hind_golden_wild_hunt", "drake_combo_golden_wild_hunt", false, true) 
	end
end

function OnComboWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", true, false) 
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		caster:SwapAbilities("drake_golden_hind_golden_wild_hunt", "drake_combo_golden_wild_hunt", true, false) 
	end
end

function OnComboWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_golden_wild_hunt_window")
end

function OnGoldenWildHuntIIStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local position = ability:GetCursorPosition()
	local frontVec = caster:GetForwardVector()
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() 
	local leftVec = -rightVec 
	local bomb_count = ability:GetSpecialValueFor("bomb_count")
	local aoe = ability:GetSpecialValueFor("aoe")
	local point = RandomPointInCircle(position, aoe)
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval")
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cannon_interval = ability:GetSpecialValueFor("cannon_interval")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")
	local lightning_dmg = ability:GetSpecialValueFor("lightning_dmg")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local lightning_stun = ability:GetSpecialValueFor("lightning_stun")
	local blizzard_aoe = ability:GetSpecialValueFor("blizzard_aoe")
	local blizzard_dmg = ability:GetSpecialValueFor("blizzard_dmg")
	local fireship_dmg = ability:GetSpecialValueFor("fireship_dmg")
	local fireship_aoe = ability:GetSpecialValueFor("fireship_aoe")
	local fireship_count = ability:GetSpecialValueFor("fireship_count")
	local ply = caster:GetMainControllingPlayer()
	local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local visiondummy = SpawnVisionDummy(caster, position, aoe, 5, false)
	-- front line
	local flagshiporigin = origin + Vector(backVec.x * 100, backVec.y * 100, -100)
	local smallship5origin = flagshiporigin + Vector(leftVec.x * 400, leftVec.y * 400,100)
	local smallship4origin = flagshiporigin + Vector(rightVec.x * 400, rightVec.y * 400,100)
	-- second line
	local mediumship1origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(rightVec.x * 300, rightVec.y * 300,0)
	local mediumship2origin = flagshiporigin + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(leftVec.x * 300, leftVec.y * 300,0)
	local bigship1origin = mediumship1origin + Vector(rightVec.x * 300, rightVec.y * 300,100)
	local bigship2origin = mediumship2origin + Vector(leftVec.x * 300, leftVec.y * 300,100)
	--third line
	local bigship3origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600, 0) + Vector(rightVec.x * 200, rightVec.y * 200,0)
	local smallship1origin = flagshiporigin + Vector(backVec.x * 600, backVec.y * 600,0) + Vector(leftVec.x * 200, leftVec.y * 200,0)
	local mediumship3origin = bigship3origin + Vector(rightVec.x * 200, rightVec.y * 200,100)
	local mediumship4origin = smallship1origin + Vector(leftVec.x * 200, leftVec.y * 200,100)
	local smallship2origin = bigship3origin + Vector(rightVec.x * 400, rightVec.y * 400,0)
	local smallship3origin = smallship1origin + Vector(leftVec.x * 400, leftVec.y * 400,0)
	
	
	
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		if caster:HasModifier("modifier_golden_wild_hunt_check") then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + 800)
			return
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_cooldown", {})
		caster:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetLevel()))
		if IsValidEntity(caster.flagship) then 
			caster.flagship:SetOrigin(flagshiporigin)
			caster.flagship:SetForwardVector(frontVec)
		else
			caster.flagship = CreateUnitByName("drake_golden_hind", origin, false, caster, caster, caster:GetTeamNumber())
    		FindClearSpaceForUnit(caster.flagship, origin + Vector(-frontVec.x * 100,-frontVec.y * 100,-100), true)
    		caster.flagship:SetForwardVector(frontVec)
			caster.flagship:SetControllableByPlayer(caster:GetPlayerID(), true)
			caster.flagship:EmitSound("Ability.Torrent")
			if caster.IsStrengthenGoldenHindAcquired then 
				caster.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(1)
				caster.flagship:SwapAbilities("fate_empty1", "drake_golden_hind_passive", false, true)
			else
				caster.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(0)
				caster.flagship:RemoveModifierByName("modifier_golden_hind_passive")
			end
			caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetLevel(1)
			-- active when mount
			caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetActivated(false)
			caster.flagship:FindAbilityByName("drake_golden_hind_bombard"):SetLevel(1)
			caster.flagship:FindAbilityByName("drake_golden_hind_defensive_cannon"):SetLevel(1)
			caster.flagship:AddItem(CreateItem("item_drake_onboard" , nil, nil))
		end
		caster.flagship:CastAbilityImmediately(caster.flagship:FindItemInInventory("item_drake_onboard"),caster:GetPlayerOwnerID())
		giveUnitDataDrivenModifier(caster, caster.flagship, "jump_pause" , 5.0)
		if caster.IsStrengthenGoldenHindAcquired then 
			cannon_count = cannon_count + 1 
		end
	-- golden hind
	elseif caster:GetUnitName() == "drake_golden_hind" then 
		flagshiporigin = origin
		if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.9})
		end
		ability:ApplyDataDrivenModifier(caster, hero, "modifier_golden_wild_hunt_cooldown", {})
		caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):GetLevel()))
		giveUnitDataDrivenModifier(caster, caster, "jump_pause" , 5.0)
		if hero.IsStrengthenGoldenHindAcquired then 
			cannon_count = cannon_count + 1 
		end
 	end
 	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_check", {})

 	Timers:CreateTimer(1.68, function()
 		if caster:IsAlive() then 
 			EmitGlobalSound("Drake.Temeroso")
 		end
 		Timers:CreateTimer(2.0, function()
 			if caster:IsAlive() then 
 				EmitGlobalSound("Drake.ComboEnd")
 			end
 		end)
 	end)
 	if caster.bigship == nil then 
		caster.bigship = {}
	end
	if caster.smallship == nil then 
		caster.smallship = {}
	end
 	-- fleet
 	for j = 1,3 do
 		if j == 1 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship1origin)
 		elseif j == 2 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship2origin)
 		elseif j == 3 then 
 			caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", bigship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.bigship[j]:SetOrigin(bigship3origin)
 		end
 		caster.bigship[j]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 		caster.bigship[j]:SetModelScale(1.3)
 		caster.bigship[j]:SetForwardVector(frontVec)
 	end

 	for b = 1,bomb_count do
 		if b == 1 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship3origin)
 		elseif b == 2 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship2origin)
 		elseif b == 3 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship4origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship4origin)
 		elseif b == 4 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship4origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship4origin)
 		elseif b == 5 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship2origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship2origin)
 		elseif b == 6 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship5origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(smallship5origin)
 			caster.smallship[b]:SetModelScale(0.8)
 		elseif b == 7 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship1origin)
 		elseif b == 8 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", mediumship1origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetOrigin(mediumship1origin)
 		elseif b == 9 then 
 			caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", smallship3origin, false, nil, nil, caster:GetTeamNumber())
 			caster.smallship[b]:SetModelScale(0.8)
 			caster.smallship[b]:SetOrigin(smallship3origin)
 		end
 		caster.smallship[b]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 		caster.smallship[b]:SetForwardVector(frontVec)
 	end

 	for i = 1,bomb_count do
 		Timers:CreateTimer(bomb_interval * i, function()
 			if not caster:IsAlive() then return end
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 1, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 2, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 3, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 4, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 5, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 6, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 7, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 8, bomb_speed, 1)
 			GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 200.0),origin, 9, bomb_speed, 1)
 		end)
 	end

 	for k = 1, cannon_count do
 		Timers:CreateTimer(cannon_interval * k, function()
 			if not caster:IsAlive() then return end
 			if k == 5 then 
 				local bigbomb = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 				for _,bigbomb in pairs (bigbomb) do
 					if not bigbomb:IsMagicImmune() then 
 						bigbomb:AddNewModifier(caster, ability, "modifier_stunned", {duration = 1.0})
 					end
 					DoDamage(caster, bigbomb, 1000, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 				end
 				return
 			end
 			if k >= 1 and k < 5 then
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 1, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 2, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 3, cannon_speed, 2)
 				GoldenWildHuntShoot (caster, ability, RandomPointInCircle(position, aoe - 400.0),origin, 4, cannon_speed, 2)
 			end
 		end)
 	end

 	for k = 0,10 do
 		Timers:CreateTimer(0.4 * k, function()
 			if not caster:IsAlive() then return end
 			point = RandomPointInCircle(position, aoe)
 			local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(thunderfx1, 0, Vector(point.x,point.y,point.z))
			ParticleManager:SetParticleControl(thunderfx1, 1, Vector(point.x,point.y,1000))
			local thundergroundfx1 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(thundergroundfx1, 0, Vector(point.x,point.y,point.z))
			Timers:CreateTimer(0.4 , function()
				ParticleManager:DestroyParticle( thunderfx1, false )
				ParticleManager:ReleaseParticleIndex( thunderfx1 )
				ParticleManager:DestroyParticle( thundergroundfx1, false )
				ParticleManager:ReleaseParticleIndex( thundergroundfx1 )
			end)
			EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
 			local thunder = FindUnitsInRadius(caster:GetTeam(), point, nil, lightning_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 			for _,thundertarget in pairs (thunder) do
 				if not thundertarget:IsMagicImmune() then 
 					thundertarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
 				end
 				DoDamage(caster, thundertarget, lightning_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 			end
 		end)
 	end
 	for l = 0,10 do
 		Timers:CreateTimer(0.4 * l, function()
 			if not caster:IsAlive() then return end
 			point = RandomPointInCircle(position, aoe)
 			local blizzardfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_caster_c.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(blizzardfx, 0, Vector(point.x,point.y,point.z))
			Timers:CreateTimer(0.4 , function()
				ParticleManager:DestroyParticle( blizzardfx, false )
				ParticleManager:ReleaseParticleIndex( blizzardfx )
			end)
 			EmitSoundOnLocationWithCaster(point, "hero_Crystal.preAttack", caster)
 			local blizzard = FindUnitsInRadius(caster:GetTeam(), point, nil, blizzard_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 			for _,frosttarget in pairs (blizzard) do
 				if not frosttarget:IsMagicImmune() then 
 					ability:ApplyDataDrivenModifier(caster, frosttarget, "modifier_blizzard_slow", {})
 				end
 				DoDamage(caster, frosttarget, blizzard_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 			end
 		end)
 	end
 	if caster.firetarget == nil then
 		caster.firetarget = {}
 	end
 	for m = 1,fireship_count do
 		Timers:CreateTimer(0.4 * m, function()
 			if not caster:IsAlive() then return end
 			local leftvec = Vector(-frontVec.y, frontVec.x, 0)
			local rightvec = Vector(frontVec.y, -frontVec.x, 0)
			local random1 = RandomInt(0,350) -- position of weapon spawn
			local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

			if random2 == 0 then 
				fire_pos = flagshiporigin + leftvec*random1 + Vector(0,0,1000)
			else 
				fire_pos = flagshiporigin + rightvec*random1 + Vector(0,0,1000)
			end
 			--[[local fire_origin = CreateUnitByName("dummy_unit", fire_pos , false, caster, caster, caster:GetTeamNumber())
			fire_origin:SetAbsOrigin(fire_pos)
    		fire_origin:FindAbilityByName("dummy_unit_passive"):SetLevel(1)]]
 			point = RandomPointInCircle(position, aoe)
 			local newForwardVec = (point - fire_pos):Normalized()
 			fire_origin:SetForwardVector(newForwardVec)
 			local fire_distance = (point - fire_pos):Length2D()
 			local fire_duration = 1.3
 			local fireship_speed = fire_distance / fire_duration
 			local FireShipFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_fireship_model.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl( FireShipFx, 0, fire_pos )
			ParticleManager:SetParticleControl( FireShipFx, 1, Vector(point.x,point.y,0) )
			ParticleManager:SetParticleControl( FireShipFx, 2, newForwardVec * speed )
			Timers:CreateTimer(  fire_duration + 0.1, function()
				ParticleManager:DestroyParticle( FireShipFx, false )
				ParticleManager:ReleaseParticleIndex( FireShipFx )	
				EmitSoundOnLocationWithCaster(point, "Hero_Techies.Suicide", caster)
				--[[if fire_origin then 
					fire_origin:RemoveSelf()
				end	]]
 				local fireship = FindUnitsInRadius(caster:GetTeam(), point, nil, fireship_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 				for _,burntarget in pairs (fireship) do
 					if not burntarget:IsMagicImmune() then 
 						ability:ApplyDataDrivenModifier(caster, burntarget, "modifier_golden_wild_hunt_burn", {})
 					end
 					DoDamage(caster, burntarget, fireship_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 				end
 			end)
 		end)
 	end
end

function FireShipBurn (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local fireship_burn_dmg = ability:GetSpecialValueFor("fireship_burn_dmg")
	local dmg = fireship_burn_dmg * 0.2
	DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnGoldenWildHuntIIHit (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_aoe = ability:GetSpecialValueFor("bomb_aoe")
	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")
	target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")	
	local CannonFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(CannonFx, 0, target:GetAbsOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( CannonFx, false )
		ParticleManager:ReleaseParticleIndex( CannonFx )
	end)
	if target == caster.bomb_target2 then 
		local BombTarget = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, bomb_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, slowtarget in pairs (BombTarget) do
			if not slowtarget:IsMagicImmune() then 
				ability:ApplyDataDrivenModifier(caster, slowtarget, "modifier_golden_wild_hunt_slow", {})
			end
			DoDamage(caster, slowtarget, bomb_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	elseif target == caster.cannon_target2 then 
		local CannonTarget = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, stuntarget in pairs (CannonTarget) do
			if not stuntarget:IsMagicImmune() then 
				stuntarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = cannon_stun})
			end
			DoDamage(caster, stuntarget, bomb_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	-- fire ship sound "Hero_Techies.Suicide"
end

function OnImproveMilitaryTacticAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsImproveMilitaryTacticAcquired = true
	keys.ability:StartCooldown(9999)

	hero:FindAbilityByName("drake_military_tactic"):SetLevel(2)
	if not hero:FindAbilityByName("drake_military_tactic"):IsCooldownReady() then 
		hero:FindAbilityByName("drake_military_tactic"):EndCooldown()
	end

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPioneerOfStarAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsPioneerOfStarAcquired = true
	keys.ability:StartCooldown(9999)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnLogBookAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsLogBookAcquired = true
	keys.ability:StartCooldown(9999)

	if hero:HasModifier("modifier_military_tactic_check") then 
		hero:SwapAbilities("fate_empty5", "drake_military_tactic_summon_golden_hind", false, true)
	end

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnStrengthenGoldenHindAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsStrengthenGoldenHindAcquired = true
	keys.ability:StartCooldown(9999)

	if IsValidEntity(hero.flagship) then 
		hero.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(1)
		hero.flagship:SwapAbilities("fate_empty1", "drake_golden_hind_passive", false, true)
		hero.flagship:FindAbilityByName("drake_golden_hind_passive"):ApplyDataDrivenModifier(hero.flagship, hero.flagship, "modifier_golden_hind_passive", {})
		hero.flagship:CreatureLevelUp(1)
	end

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end