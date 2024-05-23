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
	if string.match(ability:GetAbilityName(),"drake_combo_golden_wild_hunt" ) then 
		if caster:HasModifier('modifier_alternate_04') then 
			EmitGlobalSound("Drake-Summer-Combo1")
		else
			EmitGlobalSound("Drake.PreCombo")
		end	
	end
end

function OnDrakeDeath (keys)
	local caster = keys.caster 
	if IsValidEntity(caster.flagship) then
    	caster.flagship:RemoveSelf()
    	UTIL_Remove(caster.flagship)
    	return
    end
    caster:RemoveModifierByName("modifier_military_tactic_cannon")
    caster:RemoveModifierByName("modifier_boarding_ship")
    caster:RemoveModifierByName("modifier_boarding_ship_hit")
    caster:RemoveModifierByName("modifier_golden_hind_check")
end

function OnGoldenHindDestroy (keys)
	local caster = keys.caster 
	if IsValidEntity(caster.flagship) and not caster:HasModifier("modifier_board_drake") then 
 		caster.flagship:RemoveSelf()
    	UTIL_Remove(caster.flagship)
    end
end

function OnMilitaryTacticStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if caster:HasModifier("modifier_crossing_fire_buff") then 
		caster:RemoveModifierByName("modifier_crossing_fire_buff")
	end

	if caster:HasModifier("modifier_dance_macabre_1") then 
		caster:RemoveModifierByName("modifier_dance_macabre_1")
	end

	if caster:HasModifier("modifier_golden_wild_hunt_window") then
		caster:RemoveModifierByName("modifier_golden_wild_hunt_window")
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_military_tactic_check", {})
	caster.SpellCast = false
	ability:EndCooldown()
end

function OnMilitaryTacticUpgrade (keys)
	local caster = keys.caster 
	if caster.IsImproveMilitaryTacticAcquired then 
		caster:FindAbilityByName("drake_military_tactic_summon_cannon_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("drake_military_tactic_summon_boarding_ship_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("drake_military_tactic_summon_golden_anchor_upgrade"):SetLevel(keys.ability:GetLevel())
	else
		caster:FindAbilityByName("drake_military_tactic_summon_cannon"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("drake_military_tactic_summon_boarding_ship"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("drake_military_tactic_summon_golden_anchor"):SetLevel(keys.ability:GetLevel())
	end
end

function OnMilitaryTacticOpen (keys)
	local caster = keys.caster
	local ability = keys.ability 
	
	if caster.IsImproveMilitaryTacticAcquired then 
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "drake_military_tactic_summon_cannon_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "drake_military_tactic_summon_boarding_ship_upgrade", false, true)
		caster:SwapAbilities("drake_support_bombard_upgrade", "drake_military_tactic_summon_golden_anchor_upgrade", false, true)
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_military_tactic_upgrade_3", "fate_empty3", false, true)
		else
			caster:SwapAbilities("drake_military_tactic_upgrade_1", "fate_empty3", false, true)
		end
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "drake_military_tactic_summon_cannon", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "drake_military_tactic_summon_boarding_ship", false, true)
		caster:SwapAbilities("drake_support_bombard", "drake_military_tactic_summon_golden_anchor", false, true)
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_military_tactic_upgrade_2", "fate_empty3", false, true)
		else
			caster:SwapAbilities("drake_military_tactic", "fate_empty3", false, true)
		end	
	end 
	caster:SwapAbilities("drake_voyager_of_storm", "drake_military_tactic_close", false, true)
	-- add golden hind ship 
	if caster.IsStrengthenGoldenHindAcquired then
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_military_tactic_summon_golden_hind_upgrade", false, true)
		else
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "fate_empty5", false, true)
		end
	else
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_military_tactic_summon_golden_hind", false, true)
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "fate_empty5", false, true)
		end
	end
end

function OnMilitaryTacticClose (keys)
	local caster = keys.caster
	local ability = keys.ability 

	if caster.IsImproveMilitaryTacticAcquired then 
	-- range	
		if caster.IsPioneerOfStarAcquired then
			if caster:HasModifier("modifier_pistol_buff") then 
				caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon_upgrade", true, false)
				caster:SwapAbilities("drake_crossing_fire_upgrade", "drake_military_tactic_summon_boarding_ship_upgrade", true, false)
			-- malee
			elseif caster:HasModifier("modifier_sword_buff") then
				-- remove macabre skill 2 3
				caster:SwapAbilities("drake_pistol_upgrade", "drake_military_tactic_summon_cannon_upgrade", true, false)
				caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_military_tactic_summon_boarding_ship_upgrade", true, false)
			end
		else
			if caster:HasModifier("modifier_pistol_buff") then 
				caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon_upgrade", true, false)
				caster:SwapAbilities("drake_crossing_fire", "drake_military_tactic_summon_boarding_ship_upgrade", true, false)
			-- malee
			elseif caster:HasModifier("modifier_sword_buff") then
				-- remove macabre skill 2 3
				caster:SwapAbilities("drake_pistol", "drake_military_tactic_summon_cannon_upgrade", true, false)
				caster:SwapAbilities("drake_dance_macabre_1", "drake_military_tactic_summon_boarding_ship_upgrade", true, false)
			end
		end
		caster:SwapAbilities("drake_support_bombard_upgrade", "drake_military_tactic_summon_golden_anchor_upgrade", true, false)
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_military_tactic_upgrade_3", "fate_empty3", true, false)
		else
			caster:SwapAbilities("drake_military_tactic_upgrade_1", "fate_empty3", true, false)
		end
	else 
		if caster.IsPioneerOfStarAcquired then
			if caster:HasModifier("modifier_pistol_buff") then 
				caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon", true, false)
				caster:SwapAbilities("drake_crossing_fire_upgrade", "drake_military_tactic_summon_boarding_ship", true, false)
			-- malee
			elseif caster:HasModifier("modifier_sword_buff") then
				-- remove macabre skill 2 3
				caster:SwapAbilities("drake_pistol_upgrade", "drake_military_tactic_summon_cannon", true, false)
				caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_military_tactic_summon_boarding_ship", true, false)
			end
		else
			if caster:HasModifier("modifier_pistol_buff") then 
				caster:SwapAbilities("drake_sword", "drake_military_tactic_summon_cannon", true, false)
				caster:SwapAbilities("drake_crossing_fire", "drake_military_tactic_summon_boarding_ship", true, false)
			-- malee
			elseif caster:HasModifier("modifier_sword_buff") then
				-- remove macabre skill 2 3
				caster:SwapAbilities("drake_pistol", "drake_military_tactic_summon_cannon", true, false)
				caster:SwapAbilities("drake_dance_macabre_1", "drake_military_tactic_summon_boarding_ship", true, false)
			end
		end
		caster:SwapAbilities("drake_support_bombard", "drake_military_tactic_summon_golden_anchor", true, false)
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_military_tactic_upgrade_2", "fate_empty3", true, false)
		else
			caster:SwapAbilities("drake_military_tactic", "fate_empty3", true, false)
		end	
	end
	caster:SwapAbilities("drake_voyager_of_storm", "drake_military_tactic_close", true, false)
	-- add golden hind ship 
	if caster.IsStrengthenGoldenHindAcquired then
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_military_tactic_summon_golden_hind_upgrade", true, false)
		else
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "fate_empty5", true, false)
		end
	else
		if caster.IsLogBookAcquired then 
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_military_tactic_summon_golden_hind", true, false)
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "fate_empty5", true, false)
		end
	end

	if caster.SpellCast == true and not caster.IsImproveMilitaryTacticAcquired then 
		if caster.IsLogBookAcquired then
			caster:FindAbilityByName("drake_military_tactic_upgrade_2"):StartCooldown(caster:FindAbilityByName("drake_military_tactic_upgrade_2"):GetCooldown(1))
		else
			caster:FindAbilityByName("drake_military_tactic"):StartCooldown(caster:FindAbilityByName("drake_military_tactic"):GetCooldown(1))
		end
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
	caster.SpellCast = true
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end
end

function OnSummonCannonCreate (keys)
	local caster = keys.caster 
	local ability = keys.ability 	
	local duration = ability:GetSpecialValueFor("duration")
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local cannon_range = ability:GetSpecialValueFor("cannon_range")
	local cannon_delay = ability:GetSpecialValueFor("cannon_delay")
	local cannon_width = ability:GetSpecialValueFor("cannon_width")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")
	local interval = 0.1
	local angle = caster:GetAnglesAsVector().y + 90
	local stack = math.floor(cannon_delay / interval)

	local cannon_counter = 0

	if caster.summon_cannon == nil then 
		caster.summon_cannon = {}
	end
 
	caster.summon_cannon_loc = GetRotationPoint(caster:GetAbsOrigin(), 100, caster:GetAnglesAsVector().y)
	local summon_cannon = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl(summon_cannon, 0, caster.summon_cannon_loc)
	ParticleManager:SetParticleControl(summon_cannon, 1, Vector(0,0,angle))


	-- Update the control point as long as modifer is up
	Timers:CreateTimer( function()

		if caster:HasModifier( "modifier_military_tactic_cannon" ) and not IsRevoked(caster) and caster:IsAlive() then
			if cannon_counter >= duration * stack then 
				--print('counter mroe over')
				ParticleManager:DestroyParticle(summon_cannon, true)
				ParticleManager:ReleaseParticleIndex(summon_cannon)
				return nil 
			end
			angle = caster:GetAnglesAsVector().y + 90
			caster.summon_cannon_loc = GetRotationPoint(caster:GetAbsOrigin(), 100, caster:GetAnglesAsVector().y)
			ParticleManager:SetParticleControl(summon_cannon, 0, caster.summon_cannon_loc)
			ParticleManager:SetParticleControl(summon_cannon, 1, Vector(0,0,angle))

			if cannon_counter % stack == 0 then 
				--print('cannon fire')
				SummonCannonShoot (caster, ability, cannon_range, cannon_width, cannon_speed)
			end
			cannon_counter = cannon_counter + 1
			--print('cannon counter: ' .. cannon_counter)
			return interval
		else
			--print('ded')
			ParticleManager:DestroyParticle(summon_cannon, true)
			ParticleManager:ReleaseParticleIndex(summon_cannon)
			return nil
		end
	end)
end

function SummonCannonShoot (caster, ability, distance, width, speed)
	local forwardVec = caster:GetForwardVector()
	
    local projectileTable = {
		Ability = ability,
		EffectName = "particles/custom/drake/drake_cannon_bullet.vpcf",
		iMoveSpeed = speed,
		vSpawnOrigin = caster.summon_cannon_loc,
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
    local CannonFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(CannonFx, 0, caster.summon_cannon_loc)
	--ParticleManager:SetParticleControlEnt(CannonFx, 0, caster.summon_cannon, PATTACH_POINT_FOLLOW, "attach_attack1", caster.summon_cannon:GetAbsOrigin(),false)
	--ParticleManager:SetParticleControl(CannonFx, 0, caster.summon_cannon:GetAbsOrigin() + Vector(forwardVec.x * 100, forwardVec.y * 100, 35)) 
	local FireFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl(FireFxIndex, 0, caster.summon_cannon_loc)
	--ParticleManager:SetParticleControlEnt(FireFxIndex, 0, caster.summon_cannon, PATTACH_POINT_FOLLOW, "attach_attack1", caster.summon_cannon:GetAbsOrigin(),false)
	--ParticleManager:SetParticleControl( FireFxIndex, 0, caster.summon_cannon:GetAbsOrigin() + Vector(forwardVec.x * 100, forwardVec.y * 100, 35))
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

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")

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
		if IsValidEntity(enemy) and not enemy:IsNull() and enemy:IsAlive() then
			if not IsImmuneToCC(enemy) then
				enemy:AddNewModifier(caster, nil, "modifier_stunned", {duration = cannon_stun})
			end
			DoDamage(caster, enemy, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
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
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_boarding_ship_hit", {})
	caster.SpellCast = true
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end
end

function OnBoardingShipCreate (keys)
	local caster = keys.caster 
	Attachments:AttachProp(caster, "attach_origin", "models/drake/drake_boat.vmdl")
	-- Sets the new model
	--[[caster:SetModel("models/drake/drake_boat.vmdl")
	caster:SetOriginalModel("models/drake/drake_boat.vmdl")
	caster:SetModelScale(1.2)]]
	local WaterSplashFx = ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_water_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	caster.WaterSplashFx = WaterSplashFx
	ParticleManager:SetParticleControl(caster.WaterSplashFx, 0, caster:GetAbsOrigin()) 
	
end

function OnBoardingShipDrive (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local impact_dmg = ability:GetSpecialValueFor("impact_dmg")
	local impact_aoe = ability:GetSpecialValueFor("impact_aoe")
	local origin = caster:GetOrigin()

	local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), origin, nil, impact_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
	for _,unit in pairs(knockBackUnits) do
		if IsValidEntity(unit) and not unit:IsNull() and unit:IsAlive() then
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
		if not IsValidEntity(targets[1]) or targets[1]:IsNull() or not targets[1]:IsAlive() then return end
		targets[1]:EmitSound("Hero_Sniper.ProjectileImpact")
		DoDamage(caster, targets[1], range_dmg, DAMAGE_TYPE_PHYSICAL, 0, ability, false)	
		caster:EmitSound("Hero_Sniper.attack")
		local GunFireFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(GunFireFx, 0, caster:GetOrigin()) 
		-- Destroy particle after delay
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( GunFireFx, false )
			ParticleManager:ReleaseParticleIndex( GunFireFx )
			
		end)
	end
end

function OnBoardingShipDestroy (keys)
	local caster = keys.caster 
	-- Sets the new model
	local boat = Attachments:GetCurrentAttachment(caster, "attach_origin")
	if boat ~= nil and not boat:IsNull() then
		boat:RemoveSelf()
	end
	--[[caster:SetModel("models/drake/drake.vmdl")
	caster:SetOriginalModel("models/drake/drake.vmdl")
	caster:SetModelScale(1.2)]]
	ParticleManager:DestroyParticle( caster.WaterSplashFx, false )
	ParticleManager:ReleaseParticleIndex( caster.WaterSplashFx )
end

function OnBoardingShipDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_boarding_ship")
	caster:RemoveModifierByName("modifier_boarding_ship_hit")
end

function OnGoldenAnchorStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ability:GetSpecialValueFor("dmg")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	caster.SpellCast = true
	if not caster.IsImproveMilitaryTacticAcquired then 
		caster:RemoveModifierByName("modifier_military_tactic_check")
	end

	local AnchorFx = ParticleManager:CreateParticle("particles/custom/drake/drake_anchor.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(AnchorFx, 0, target_loc + Vector(0,0,500)) 
	ParticleManager:SetParticleControl(AnchorFx, 1, target_loc) 
	ParticleManager:SetParticleControl(AnchorFx, 2, Vector(1.0,0,0)) 
	Timers:CreateTimer(cast_delay, function()
		local SmashFx = ParticleManager:CreateParticle("particles/custom/drake/drake_anchor_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(SmashFx, 0, target_loc) 
		ParticleManager:SetParticleControl(SmashFx, 1, Vector(aoe,0,0)) 
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Snapfire.FeedCookie.Impact", caster)
		local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
		for _,enemy in pairs (enemies) do
			if IsValidEntity(enemy) and not enemy:IsNull() and enemy:IsAlive() then
				if not enemy:IsMagicImmune() and not IsImmuneToCC(enemy) then
					enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
				end
				DoDamage(caster, enemy, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
		Timers:CreateTimer(0.3, function()
			ParticleManager:DestroyParticle( AnchorFx, false )
			ParticleManager:ReleaseParticleIndex( AnchorFx )
			ParticleManager:DestroyParticle( SmashFx, false )
			ParticleManager:ReleaseParticleIndex( SmashFx )
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

	local unitName = "drake_golden_hind"
	if caster.IsStrengthenGoldenHindAcquired then 
		unitName = "drake_golden_hind_upgrade"
	end

	local spawn = GetRotationPoint(caster:GetAbsOrigin(), 100, caster:GetAnglesAsVector().y + 180)

    caster.flagship = CreateUnitByName(unitName, spawn, false, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(caster.flagship, spawn, true)
    caster.flagship:SetForwardVector(forwardVec)
    caster.flagship:SetOwner(caster)
	caster.flagship:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.flagship:EmitSound("Ability.Torrent")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_check", {})
	caster.IsOnBoarded = false
	SendMountStatus(caster)
	for i = 0,11 do 
		caster.flagship:GetAbilityByIndex(i):SetLevel(1)
	end
	caster.flagship:FindAbilityByName("drake_golden_wild_hunt_upgrade"):SetHidden(true)
	caster.flagship:FindAbilityByName("drake_golden_wild_hunt"):SetHidden(true)

	local playerData = {
        transport = caster.flagship:entindex()
    }
    CustomGameEventManager:Send_ServerToPlayer( caster:GetPlayerOwner(), "player_summoned_transport", playerData )

	--[[if caster.IsStrengthenGoldenHindAcquired then 
		caster.flagship:FindAbilityByName("drake_golden_hind_passive"):SetLevel(1)
	end
	caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetLevel(1)
	if not caster.flagship:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):IsHidden() then
		caster.flagship:FindAbilityByName("drake_golden_hind_golden_wild_hunt"):SetHidden(true)
	end
	if not caster.flagship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):IsHidden() then
		caster.flagship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):SetHidden(true)
	end
	--[[caster.flagship:FindAbilityByName("fate_empty6"):SetHidden(false)
	caster.flagship:FindAbilityByName("fate_empty7"):SetHidden(false)]]
	-- active when mount
	--caster.flagship:FindAbilityByName("drake_golden_hind_drive"):SetActivated(false)
	--[[caster.flagship:FindAbilityByName("drake_golden_hind_bombard"):SetLevel(1)
	caster.flagship:FindAbilityByName("drake_golden_hind_defensive_cannon"):SetLevel(1)]]
	caster.flagship:AddItem(CreateItem("item_drake_onboard" , nil, nil))
	if not string.match(GetMapName(), "fate_elim") then 
		caster.flagship:AddNewModifier(caster, nil, "modifier_kill", {Duration = 60})
	end
end

function OnGoldenHindPassiveThink (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec
	local cannon_range = ability:GetSpecialValueFor("cannon_range")

	local target_left_lock = 0
	local target_right_lock = 0

	local detected = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, cannon_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for k,v in pairs (detected) do 
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
			local caster_angle = caster:GetAnglesAsVector().y
			local forwardvec = (caster:GetAbsOrigin()-v:GetAbsOrigin()):Normalized()
			local enemy_angle = VectorToAngles(forwardvec).y

			-- right  
			if enemy_angle >= 30 and enemy_angle <= 150 then 
				if target_right_lock <= 3 then
					target_right_lock = target_right_lock + 1
					local cannon_angle = GetRotationPoint(caster:GetAbsOrigin(), 150, caster:GetAnglesAsVector().y + (45 *target_right_lock) )
					GoldenHindSideShoot (caster, ability, v, cannon_angle)
				end
			-- left	
			elseif enemy_angle >=210 and enemy_angle <= 330 then 
				if target_left_lock <= 3 then
					target_left_lock = target_left_lock + 1
					local cannon_angle = GetRotationPoint(caster:GetAbsOrigin(), 150, caster:GetAnglesAsVector().y - (45 *target_left_lock) )
					GoldenHindSideShoot (caster, ability, v, cannon_angle)
				end
			end
		end
	end
	
	--[[local AxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(forwardVec.x * cannon_range, forwardVec.y * cannon_range,0), origin - Vector(forwardVec.x * cannon_range,forwardVec.y * cannon_range,0), nil, cannon_range/3, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,NonTarget in pairs (AxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, NonTarget, "modifier_golden_hind_non_target", {})
	end
	local RightAxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(rightVec.x * cannon_range, rightVec.y * cannon_range,0) + Vector(forwardVec.x * cannon_range, forwardVec.y * cannon_range,0), origin + Vector(rightVec.x * cannon_range, rightVec.y * cannon_range,0) - Vector(forwardVec.x * cannon_range,forwardVec.y * cannon_range,0), nil, cannon_range/3, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,RightTarget in pairs (RightAxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, RightTarget, "modifier_golden_hind_right_target", {})
	end
	local LeftAxisTarget = FindUnitsInLine(caster:GetTeam(), origin + Vector(leftVec.x * cannon_range, leftVec.y * cannon_range,0) + Vector(forwardVec.x * cannon_range, forwardVec.y * cannon_range,0), origin + Vector(leftVec.x * cannon_range, leftVec.y * cannon_range,0) - Vector(forwardVec.x * cannon_range,forwardVec.y * cannon_range,0), nil, cannon_range/3, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
	for _,LeftTarget in pairs (LeftAxisTarget) do 
		ability:ApplyDataDrivenModifier(caster, LeftTarget, "modifier_golden_hind_left_target", {})
	end
	local CannonTarget = FindUnitsInRadius(caster:GetTeam(), origin, nil, cannon_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,SideTarget in pairs (CannonTarget) do
		if not SideTarget:HasModifier("modifier_golden_hind_non_target") then
			-- left side of ship
			if SideTarget:HasModifier("modifier_golden_hind_left_target") and not SideTarget:IsInvisible() then 
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
			elseif SideTarget:HasModifier("modifier_golden_hind_right_target") and not SideTarget:IsInvisible() then
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
	end]]
end

function GoldenHindSideShoot (caster, ability, target, origin)
	local projectileTable = {
        EffectName = "",
        Ability = ability,
        vSourceLoc = origin,
        Target = target,
        --Source = caster, 
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

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")
	
	if IsValidEntity(target) and not target:IsNull() then
		target:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Target")
		local BombFx = ParticleManager:CreateParticle("particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack_explode_debris.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(BombFx, 0, target:GetOrigin()) 
		local DustFx = ParticleManager:CreateParticle("particles/econ/events/ti9/rock_golem_tower/dire_tower_attack_explode_dust_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(DustFx, 0, target:GetOrigin()) 

		DoDamage(caster, target, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	-- Destroy particle after delay
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( BombFx, false )
			ParticleManager:ReleaseParticleIndex( BombFx )
			ParticleManager:DestroyParticle( DustFx, false )
			ParticleManager:ReleaseParticleIndex( DustFx )
		end)

		if IsValidEntity(target) and not target:IsNull() and not target:IsMagicImmune() then 
			if not IsImmuneToCC(target) then
				target:AddNewModifier(caster, ability, "modifier_stunned", {duration = cannon_stun})
			end
			local aoe = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, cannon_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,unit in pairs (aoe) do
				if IsValidEntity(unit) and not unit:IsNull() and unit ~= target then 
					DoDamage(caster, unit, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end
	end
end

function OnGoldenHindDriveStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_drive", {})
	local ply = caster:GetMainControllingPlayer()
	local hero = caster:GetOwnerEntity()
	local duration = ability:GetSpecialValueFor("duration")
	StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	--[[if hero:HasModifier("modifier_sword_buff") then
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.2})
	elseif hero:HasModifier("modifier_pistol_buff") then 
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.5})
	end]]
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
		duration = 0.2,
		knockback_duration = 0.2,
		knockback_distance = knockback,
		knockback_height = 100,
	}

	for _,unit in pairs(knockBackUnits) do
	--	print( "knock back unit: " .. unit:GetName() )
		if IsValidEntity(unit) and not unit:IsNull() then
			if not IsBiggerUnit(unit) and not unit:HasModifier("modifier_knockback") and not unit:HasModifier("modifier_golden_hind_drive_cooldown") then
				if not IsKnockbackImmune(unit) and not unit:IsRooted() and not IsRevoked(unit) and not unit:IsBarracks() then
					unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback )
				end
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_golden_hind_drive_cooldown", {})
				if unit:IsAlive() then
					DoDamage(caster, unit, impact_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end
	end
end

function OnGoldenHindBombardStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local ply = caster:GetMainControllingPlayer()
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local hero = caster:GetOwnerEntity()
	if hero.IsOnBoarded == true then
		StartAnimation(hero, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
		--[[if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.5})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.9})
		end]]
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
		if IsValidEntity(caster) and not caster:IsNull() and caster:HasModifier("modifier_golden_hind_bombard") then
			
			-- Create Cannon particles
			-- Main variables
			local delay = 0.5				-- Delay before damage
			
			-- Side variables
			local spawn_location = origin
			local random_location = RandomInt(1, 6) 
			if random_location == 1 then 
				spawn_location = origin + (leftVec * 100) + (forwardVec * 200) + Vector(0,0,200)
			elseif random_location == 2 then 
				spawn_location = origin + (leftVec * 100) + Vector(0,0,200)
			elseif random_location == 3 then 
				spawn_location = origin + (leftVec * 100) - (forwardVec * 200) + Vector(0,0,200)
			elseif random_location == 4 then 
				spawn_location = origin + (rightVec * 100) + (forwardVec * 200) + Vector(0,0,200)
			elseif random_location == 5 then 
				spawn_location = origin + (rightVec * 100) + Vector(0,0,200)
			elseif random_location == 6 then 
				spawn_location = origin + (rightVec * 100) - (forwardVec * 200) + Vector(0,0,200)
			end

			local target_location = RandomPointInCircle(target_loc, aoe - bomb_aoe)

			local CannonBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet_yellow.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl( CannonBulletFx, 0, spawn_location )
			ParticleManager:SetParticleControl( CannonBulletFx, 1, target_location )

			local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_WORLDORIGIN, caster )
			ParticleManager:SetParticleControl( FireFxIndex, 0, spawn_location )
			local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_WORLDORIGIN, caster )
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
					
				-- Delay damage
				if IsValidEntity(caster) and not caster:IsNull() then
					local targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, bomb_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
					for k,v in pairs(targets) do
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
							if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = bomb_stun})
							end
							DoDamage(caster, v, bomb_dmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end
					end
					EmitSoundOnLocationWithCaster(target_location, "Hero_Snapfire.Shotgun.Target", caster)
					-- Particles on impact
					local BombFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_WORLDORIGIN, caster)
					ParticleManager:SetParticleControl(BombFx, 0, target_location) 
					-- radius fire blast, spark, fire ring
					ParticleManager:SetParticleControl(BombFx, 1, Vector(bomb_aoe,0.3,bomb_aoe)) 
					-- Destroy particle after delay
					Timers:CreateTimer(0.5, function()
						ParticleManager:DestroyParticle( BombFx, false )
						ParticleManager:ReleaseParticleIndex( BombFx )
					end)
					return nil
				end
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
	local hero = caster:GetOwnerEntity()
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local forwardVec = caster:GetForwardVector()
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec
	if hero.IsOnBoarded == true then
		StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
		--[[if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.9})
		end]]
	end
	local cannonorigin1 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0) + Vector(0,0,200)
	local cannonorigin2 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0) + Vector(0,0,200)
	local cannonorigin3 = origin + Vector(leftVec.x * 100, leftVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0) + Vector(0,0,200)
	local cannonorigin4 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) + Vector(forwardVec.x * 150, forwardVec.y * 150,0) + Vector(0,0,200)
	local cannonorigin5 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 50, forwardVec.y * 50,0) + Vector(0,0,200)
	local cannonorigin6 = origin + Vector(rightVec.x * 100, rightVec.y * 100,0) - Vector(forwardVec.x * 250, forwardVec.y * 250,0) + Vector(0,0,200)
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
		if IsValidEntity(target) and not target:IsNull() then
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
	   			target:SetNavCollisionType(PHYSICS_NAV_HALT)
		
				target:OnPhysicsFrame(function(unit) -- pushback distance check
					local unitOrigin = unit:GetAbsOrigin()
					local diff = unitOrigin - unit_target_origin
					local n_diff = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
					if diff:Length() > knockback or not unit:HasModifier("drag_pause") then -- if pushback distance is over 150, stop it
						if IsValidEntity(unit) then 
							unit:PreventDI(false)
							unit:SetPhysicsVelocity(Vector(0,0,0))
							unit:OnPhysicsFrame(nil)
							FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
						end
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
		caster.mada = false
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_voyager_lucky", {})
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		local ply = caster:GetMainControllingPlayer()
		local hero = caster:GetOwnerEntity()
		--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
		hero.mada = false
		if hero.IsOnBoarded == true then
			StartAnimation(hero, {duration=4.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
			--[[if hero:HasModifier("modifier_sword_buff") then
				StartAnimation(hero, {duration=4.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
			elseif hero:HasModifier("modifier_pistol_buff") then 
				StartAnimation(hero, {duration=4.0, activity=ACT_DOTA_IDLE_RARE, rate=0.9})
			end]]
		end
		Timers:CreateTimer(2.0, function()
			hero:FindAbilityByName("drake_voyager_of_storm"):ApplyDataDrivenModifier(hero, hero, "modifier_voyager_lucky", {})
		end)
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
		if IsReviveSeal(caster) then return end
		caster:SetHealth(1)
		if caster.mada == false then
			EmitGlobalSound("Drake.Voyager")
			caster.mada = true 
		end
	end
end

function OnThunderStrike (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local lighning_dmg = ability:GetSpecialValueFor("lighning_dmg")
	local hero = caster:GetOwnerEntity()

	ThunderStrike(hero, ability, RandomPointInCircle(caster:GetOrigin(), radius), lighning_dmg, lightning_aoe)
	ThunderStrike(hero, ability, RandomPointInCircle(caster:GetOrigin(), radius), lighning_dmg, lightning_aoe)
	--[[local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx1, 0, Vector(point.x,point.y,point.z))
	ParticleManager:SetParticleControl(thunderfx1, 1, Vector(point.x,point.y,1000))
	local thundergroundfx1 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thundergroundfx1, 0, Vector(point.x,point.y,point.z))
	EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
 	local thunder = FindUnitsInRadius(caster:GetTeam(), point, nil, lightning_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	for _,thundertarget in pairs (thunder) do
 		if IsValidEntity(thundertarget) and not thundertarget:IsNull() and thundertarget:IsAlive() then
	 		if not thundertarget:IsMagicImmune() then 
	 			thundertarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
	 		end
	 		if not IsLightningResist(thundertarget) then
	 			DoDamage(caster, thundertarget, lighning_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	 		end
	 	end
	end
 	local point2 = RandomPointInCircle(caster:GetOrigin(), radius)
 	local thunderfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx2, 0, Vector(point2.x,point2.y,point2.z))
	ParticleManager:SetParticleControl(thunderfx2, 1, Vector(point2.x,point2.y,1000))
	local thundergroundfx2 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thundergroundfx2, 0, Vector(point2.x,point2.y,point2.z))
	EmitSoundOnLocationWithCaster(point2, "Hero_Zuus.LightningBolt", caster)
 	local thunder2 = FindUnitsInRadius(caster:GetTeam(), point2, nil, lightning_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	for _,thundertarget2 in pairs (thunder2) do
 		if IsValidEntity(thundertarget2) and not thundertarget2:IsNull() and thundertarget2:IsAlive() then
	 		if not thundertarget2:IsMagicImmune() then 
	 			thundertarget2:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
	 		end
	 		if not IsLightningResist(thundertarget) then
	 			DoDamage(caster, thundertarget2, lighning_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	 		end
	 	end
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
	end)]]
end

function OnBoardStart(keys)
	local caster = keys.caster
	local ply = caster:GetMainControllingPlayer()
	local hero = caster:GetOwnerEntity()
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	Timers:CreateTimer(0.2, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsOnBoarded then
				-- If Caster is attempting to unmount on not traversable terrain,
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) or caster:HasModifier("modifier_golden_hind_drive") then
					keys.ability:EndCooldown()
					SendErrorMessage(hero:GetPlayerOwnerID(), "#Cannot_Get_Off")
					return								
				else
					hero:RemoveModifierByName("modifier_board_drake")
					caster:RemoveModifierByName("modifier_board")
					hero:Stop()
					--hero.IsOnBoarded = false
					--SendMountStatus(hero)
					
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then
				--hero.IsOnBoarded = true
				hero:Stop()
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_board_drake", {})
				keys.ability:ApplyDataDrivenModifier(hero, caster, "modifier_board", {}) 
				--SendMountStatus(hero)
				return
			end 
		end
	end)
end

function BoardCreate(keys)
	local hero = keys.caster
	local ship = keys.target
	hero.IsOnBoarded = true
	SendMountStatus(hero)
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	if hero:HasModifier("modifier_padoru") then 

	else
		hero:SetModelScale(0.8)
	end
	if hero:HasModifier("modifier_crossing_fire_buff") then 
		hero:RemoveModifierByName("modifier_crossing_fire_buff")
	end
	if hero:HasModifier("modifier_boarding_ship") then 
		hero:RemoveModifierByName("modifier_boarding_ship")
	end
	if hero:HasModifier("modifier_military_tactic_check") then 
		hero:RemoveModifierByName("modifier_military_tactic_check")
	end
	if hero:HasModifier("modifier_golden_wild_hunt_window") then 
		hero:RemoveModifierByName("modifier_golden_wild_hunt_window")
	end
	local golden_wild_hunt = "drake_golden_wild_hunt"
	if hero.IsStrengthenGoldenHindAcquired then 
		golden_wild_hunt = "drake_golden_wild_hunt_upgrade"
	end
	ship:SwapAbilities("fate_empty8", "drake_golden_hind_drive", false, true) 
	ship:SwapAbilities("fate_empty6", "drake_golden_hind_voyager_of_storm", false, true) 
	ship:SwapAbilities("fate_empty7", golden_wild_hunt, false, true) 
	ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):SetLevel(1)
	if not hero:FindAbilityByName("drake_voyager_of_storm"):IsCooldownReady() then 
		ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):StartCooldown(hero:FindAbilityByName("drake_voyager_of_storm"):GetCooldownTimeRemaining())
	else
		if not ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):IsCooldownReady() then 
			ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):EndCooldown()
		end
	end
	ship:FindAbilityByName(golden_wild_hunt):SetLevel(hero:FindAbilityByName(golden_wild_hunt):GetLevel())
	if not hero:FindAbilityByName(golden_wild_hunt):IsCooldownReady() then 
		ship:FindAbilityByName(golden_wild_hunt):StartCooldown(hero:FindAbilityByName(golden_wild_hunt):GetCooldownTimeRemaining())
	else
		if not ship:FindAbilityByName(golden_wild_hunt):IsCooldownReady() then 
			ship:FindAbilityByName(golden_wild_hunt):EndCooldown()
		end
	end
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Positions Caster on Dragon's back every tick as long as Caster is mounted
]]
function BoardFollow(keys)
	local ship = keys.caster
	--print('caster:' .. caster:GetUnitName())
	local hero = keys.target
	--print('ship:' .. ship:GetUnitName())
	local forwardVec = ship:GetForwardVector()
	if IsValidEntity(ship) then
		hero:SetAbsOrigin(ship:GetAbsOrigin() + Vector(forwardVec.x * 150,forwardVec.y * 150,150))
		hero:SetForwardVector(forwardVec)
	end
end

function GetOff (keys)
	local ship = keys.caster
	local hero = keys.target
	hero.IsOnBoarded = false
	SendMountStatus(hero)
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	if hero:HasModifier("modifier_padoru") then 

	else
		hero:SetModelScale(1.2)
	end
	local golden_wild_hunt = "drake_golden_wild_hunt"
	if hero.IsStrengthenGoldenHindAcquired then 
		golden_wild_hunt = "drake_golden_wild_hunt_upgrade"
	end
	if ship:HasModifier("modifier_golden_wild_hunt_window") then 
		ship:RemoveModifierByName("modifier_golden_wild_hunt_window")
	end
	if not ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):IsCooldownReady() then 
		hero:FindAbilityByName("drake_voyager_of_storm"):StartCooldown(ship:FindAbilityByName("drake_golden_hind_voyager_of_storm"):GetCooldownTimeRemaining())
	end 
	if not ship:FindAbilityByName(golden_wild_hunt):IsCooldownReady() then 
		hero:FindAbilityByName(golden_wild_hunt):StartCooldown(ship:FindAbilityByName(golden_wild_hunt):GetCooldownTimeRemaining())
	end
	ship:SwapAbilities("fate_empty8", "drake_golden_hind_drive", true, false) 
	ship:SwapAbilities("fate_empty6", "drake_golden_hind_voyager_of_storm", true, false) 
	ship:SwapAbilities("fate_empty7", golden_wild_hunt, true, false)
end

function OnBoardDeath(keys)
	local hero = keys.caster
	local ship = keys.target
	hero:RemoveModifierByName("modifier_board_drake")
	hero:RemoveModifierByName("modifier_golden_hind_check")
end

function OnPistalStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_sword_buff")
	if caster:HasModifier("modifier_dance_macabre_1") then 
		caster:RemoveModifierByName("modifier_dance_macabre_1")
	end
	if caster:ScriptLookupAttachment("attach_gun1") ~= nil then 
		Attachments:AttachProp(caster, "attach_gun1", "models/drake/drake_gun1.vmdl")
	
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then sword:RemoveSelf() end
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pistol_buff", {}) 
	caster:SetAttackCapability(2)	
	if caster.IsPioneerOfStarAcquired then 
		caster:SwapAbilities("drake_pistol_upgrade", "drake_sword", false, true)
		caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_crossing_fire_upgrade", false, true)
	else
		caster:SwapAbilities("drake_pistol", "drake_sword", false, true)
		caster:SwapAbilities("drake_dance_macabre_1", "drake_crossing_fire", false, true)
	end
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

	--[[Attachments:AttachProp(caster, "attach_gun1", "models/drake/drake_gun1.vmdl")
	
	local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
	if sword ~= nil and not sword:IsNull() then sword:RemoveSelf() end]]

	--[[if caster:HasModifier("modifier_sword_buff") then 
		caster:RemoveModifierByName("modifier_pistol_buff")
	end]]
end

function OnPistalDestroy (keys)
	local caster = keys.caster 
	local gun = Attachments:GetCurrentAttachment(caster, "attach_gun1")
	if gun ~= nil and not gun:IsNull() then 
		gun:RemoveSelf() 
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
	if caster:HasModifier("modifier_voyager_lucky") then 
		double_atk_chance = 100
	end
	if caster.IsPioneerOfStarAcquired then 
		if RandomInt(1, 100) <= double_atk_chance then 
			caster.double_atk = true 
			StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=ACT_DOTA_ATTACK_EVENT, rate=1/caster:GetAttackAnimationPoint()})
		else
			caster.double_atk = false 
			StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=attack, rate=1/caster:GetAttackAnimationPoint()})
		end
	else
		StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=attack, rate=1/caster:GetAttackAnimationPoint()})
	end
end

function OnPistalAttackLand (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local bonus_dmg = ability:GetSpecialValueFor("bonus_dmg")
	if caster.mana_bullet and caster.mana_bullet == true and target:IsAlive() then
		if not target:IsMagicImmune() then 	
			DoDamage(caster, target, bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
	if caster.double_atk and caster.double_atk == true and IsValidEntity(target) and not target:IsNull() and target:IsAlive() then 
		if caster:GetAttackTarget() ~= target or not caster:IsAttacking() then 
			caster.double_atk = false
		else
			caster:PerformAttack( target, true, true, true, true, true, false, false )
			caster.double_atk = false
			if caster.mana_bullet and caster.mana_bullet == true then
				if IsValidEntity(target) and not target:IsNull() and not target:IsMagicImmune() then 	
					DoDamage(caster, target, bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end
	elseif caster.double_atk and caster.double_atk == false then 
		caster.double_atk = false
	end
end

function OnSwordStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_pistol_buff")
	if caster:HasModifier("modifier_crossing_fire_buff") then 
		caster:RemoveModifierByName("modifier_crossing_fire_buff")
	end
	if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
		Attachments:AttachProp(caster, "attach_sword", "models/drake/drake_sword.vmdl")

		local gun = Attachments:GetCurrentAttachment(caster, "attach_gun1")
		if gun ~= nil and not gun:IsNull() then 
			gun:RemoveSelf() 
		end
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sword_buff", {}) 
	caster:SetAttackCapability(1)	
	if caster.IsPioneerOfStarAcquired then 
		caster:SwapAbilities("drake_pistol_upgrade", "drake_sword", true, false)
		caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_crossing_fire_upgrade", true, false)
	else
		caster:SwapAbilities("drake_pistol", "drake_sword", true, false)
		caster:SwapAbilities("drake_dance_macabre_1", "drake_crossing_fire", true, false)
	end
end

function OnSwordUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsPioneerOfStarAcquired then 
		if ability:GetLevel() == caster:FindAbilityByName("drake_pistol_upgrade"):GetLevel() then return end
		caster:FindAbilityByName("drake_pistol_upgrade"):SetLevel(ability:GetLevel())
	else
		if ability:GetLevel() == caster:FindAbilityByName("drake_pistol"):GetLevel() then return end
		caster:FindAbilityByName("drake_pistol"):SetLevel(ability:GetLevel())
	end
end
	
function OnSwordCreate (keys)
	local caster = keys.caster 
	local ability = keys.ability

	--[[Attachments:AttachProp(caster, "attach_sword", "models/drake/drake_sword.vmdl")

	local gun = Attachments:GetCurrentAttachment(caster, "attach_gun1")
	if gun ~= nil and not gun:IsNull() then 
		gun:RemoveSelf() 
	end]]
	--print('attach sword : ' .. caster:GetName())
	
	--[[if caster:HasModifier("modifier_pistol_buff") then 
		caster:RemoveModifierByName("modifier_sword_buff")
	end]]
end

function OnSwordDestroy (keys)
	local caster = keys.caster 
	--print('get sword : ' .. caster:GetName())
	local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
	--print(sword)
	if sword ~= nil and not sword:IsNull() then 
		sword:RemoveSelf() 
	end
end

function OnCrossingFireStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local bullet_interval = ability:GetSpecialValueFor("bullet_interval")
	local rate = 20 / (24 * bullet_interval)

	if caster:HasModifier('modifier_alternate_03') then 
		caster:EmitSound("Drake-Cowgirl-W")
	end	

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_crossing_fire_buff", {})
	OnCrossingFireThink (caster, ability)
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_4, rate=1/bullet_interval})
end 

function OnCrossingFireAnimate (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local bullet_interval = ability:GetSpecialValueFor("bullet_interval")
	--local rate = 20 / (24 * bullet_interval)
	--StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_4, rate=1/bullet_interval})
end

function OnCrossingFireDestroy (keys)
	local caster = keys.caster 
	EndAnimation(caster)
end

function OnCrossingFireDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_crossing_fire_buff")
end

function OnCrossingFireUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local macabre = caster:FindAbilityByName("drake_dance_macabre_1")
	if caster.IsPioneerOfStarAcquired then 
		macabre = caster:FindAbilityByName("drake_dance_macabre_1_upgrade")
	end
	if ability:GetLevel() == macabre:GetLevel() then 
	else	
		macabre:SetLevel(ability:GetLevel())
	end
end

function OnCrossingFireThink (caster, ability)
	local bullet_distance = ability:GetSpecialValueFor("bullet_distance")
	local bullet_speed = ability:GetSpecialValueFor("bullet_speed")
	local bullet_interval = ability:GetSpecialValueFor("bullet_interval")
	local bullet_count = math.floor(4 / bullet_interval)
	local bullet_c = 0

	Timers:CreateTimer(function()
		if caster:IsAlive() and caster:HasModifier("modifier_crossing_fire_buff") then
			if bullet_c == (bullet_count * 2) - 1 then return end
			if bullet_c % 2 == 0 then
				--StartAnimation(caster, {duration=bullet_interval, activity=ACT_DOTA_CAST_ABILITY_4, rate=1/bullet_interval})
			end
			local origin = caster:GetAbsOrigin()
			local frontVec = caster:GetForwardVector() 
			local backVec = -frontVec 
			local rightVec = caster:GetRightVector() 
			local leftVec = -rightVec 
			local right_hand = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1"))
			local left_hand = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2"))

			if bullet_c % 2 == 0 then
				OnCrossingFireShoot (caster, ability, left_hand, frontVec, bullet_distance, bullet_speed, 2)
				OnCrossingFireShoot (caster, ability, right_hand, backVec, bullet_distance, bullet_speed, 1)
			else
				OnCrossingFireShoot (caster, ability, left_hand, rightVec, bullet_distance, bullet_speed, 2)
				OnCrossingFireShoot (caster, ability, right_hand, leftVec, bullet_distance, bullet_speed, 1)
			end

			if caster.IsPioneerOfStarAcquired then 
				Timers:CreateTimer( 0.1, function()
					if bullet_c % 2 == 0 then
						OnCrossingFireShoot (caster, ability, left_hand, frontVec, bullet_distance, bullet_speed, 2)
						OnCrossingFireShoot (caster, ability, right_hand, backVec, bullet_distance, bullet_speed, 1)
					else
						OnCrossingFireShoot (caster, ability, left_hand, rightVec, bullet_distance, bullet_speed, 2)
						OnCrossingFireShoot (caster, ability, right_hand, leftVec, bullet_distance, bullet_speed, 1)
					end
				end)
			end

			bullet_c = bullet_c + 1
			return bullet_interval / 2 
		end
	end)

	--[[for i = 0,(bullet_count * 2) - 1 do
		Timers:CreateTimer( bullet_interval * i / 2, function()
			if not caster:HasModifier("modifier_crossing_fire_buff") then return end
			StartAnimation(caster, {duration=bullet_interval, activity=ACT_DOTA_CAST_ABILITY_4, rate=1/bullet_interval})
			local origin = caster:GetAbsOrigin()
			local frontVec = caster:GetForwardVector() 
			local backVec = -frontVec 
			local rightVec = caster:GetRightVector() 
			local leftVec = -rightVec 
			local right_hand = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1"))
			local left_hand = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2"))

			if i % 2 == 0 then
				OnCrossingFireShoot (caster, ability, left_hand, frontVec, bullet_distance, bullet_speed, 2)
				OnCrossingFireShoot (caster, ability, right_hand, backVec, bullet_distance, bullet_speed, 1)
			else
				OnCrossingFireShoot (caster, ability, left_hand, rightVec, bullet_distance, bullet_speed, 2)
				OnCrossingFireShoot (caster, ability, right_hand, leftVec, bullet_distance, bullet_speed, 1)
			end

			if caster.IsPioneerOfStarAcquired then 
				Timers:CreateTimer( 0.1, function()
					if i % 2 == 0 then
						OnCrossingFireShoot (caster, ability, left_hand, frontVec, bullet_distance, bullet_speed, 2)
						OnCrossingFireShoot (caster, ability, right_hand, backVec, bullet_distance, bullet_speed, 1)
					else
						OnCrossingFireShoot (caster, ability, left_hand, rightVec, bullet_distance, bullet_speed, 2)
						OnCrossingFireShoot (caster, ability, right_hand, leftVec, bullet_distance, bullet_speed, 1)
					end
				end)
			end
		end)
	end]]
end

function OnCrossingFireShoot (caster, ability, origin, vector, distance, speed, attach_point)
	local duration = distance / speed 
	local projectileTable = {
		Ability = ability,
		EffectName = "particles/custom/drake/drake_cannon_bullet.vpcf",
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

    local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(FireFxIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack" .. attach_point, caster:GetAbsOrigin(),false)
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
	end)
	caster:EmitSound("Hero_Ancient_Apparition.ProjectileImpact")
end

function OnCrossingFireHit (keys)
	if keys.target == nil then return end 
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local bullet_mini_stun = ability:GetSpecialValueFor("bullet_mini_stun")
	local bullet_dmg = ability:GetSpecialValueFor("bullet_dmg")
	
	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = bullet_mini_stun})
	end
	DoDamage(caster, target, bullet_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
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
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, width + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() and IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_1", {})
			if not IsKnockbackImmune(target) and not IsImmuneToCC(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
		if caster.IsPioneerOfStarAcquired then
			caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_dance_macabre_2", false, true)
		else
			caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_2", false, true)
		end
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
	   	caster:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
	if caster.IsPioneerOfStarAcquired then
		crossfire = caster:FindAbilityByName("drake_crossing_fire_upgrade")
	end
	if ability:GetLevel() == crossfire:GetLevel() then 
	else
		crossfire:SetLevel(ability:GetLevel())
	end
	caster:FindAbilityByName("drake_dance_macabre_2"):SetLevel(ability:GetLevel())
	if caster.IsPioneerOfStarAcquired then
		caster:FindAbilityByName("drake_dance_macabre_3_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("drake_dance_macabre_3"):SetLevel(ability:GetLevel())
	end
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
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, width + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_2", {})
			if not IsKnockbackImmune(target) and not IsImmuneToCC(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
			if caster.IsPioneerOfStarAcquired then
				caster:SwapAbilities("drake_dance_macabre_2", "drake_dance_macabre_3_upgrade", false, true)
			else
				caster:SwapAbilities("drake_dance_macabre_2", "drake_dance_macabre_3", false, true)
			end
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
	   	caster:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
	local width = ability:GetSpecialValueFor("width")
	local stun = ability:GetSpecialValueFor("stun")
	local forwardvec = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local end_target = origin + Vector(forwardvec.x *  width, forwardvec.y * width ,0)
	caster:RemoveModifierByName("modifier_dance_macabre_1")
	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=2.0})
	caster:EmitSound("Hero_Abaddon.PreAttack")
	caster:EmitSound("Drake.Dance3")
	local knockBackUnits = FindUnitsInLine(caster:GetTeamNumber(), origin, end_target , nil, width + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0)
	for _,target in pairs(knockBackUnits) do
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dance_macabre_knock_back_3", {})
			if not IsKnockbackImmune(target) and not IsImmuneToCC(target) then 
				local unit_target_origin = target:GetAbsOrigin()		
 				local unit_target_direction = (end_target - origin):Normalized()
    			local pushTarget = Physics:Unit(target)

		    	target:PreventDI()
		    	target:SetPhysicsFriction(0)
				local vectorC = unit_target_direction
				-- get the direction where target will be pushed back to
				local vectorB = vectorC - vectorA
				target:SetPhysicsVelocity(vectorB:Normalized() * knockback * 2)
	   			target:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
	   	caster:SetNavCollisionType(PHYSICS_NAV_HALT)
		
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
		local base_dmg = ability:GetSpecialValueFor("base_dmg")
		local agi_ratio = ability:GetSpecialValueFor("agi_ratio")
		local knock_duration = ability:GetSpecialValueFor("knock_duration")
		Timers:CreateTimer( 0.5, function()
			local whirlwind = FindUnitsInRadius(caster:GetTeam(), end_target, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( upstreamFx, 0, end_target )
			for _,knockup in pairs (whirlwind) do
				DoDamage(caster, knockup, base_dmg + caster:GetAgility() * agi_ratio, DAMAGE_TYPE_PURE, 0, ability, false)
				ApplyAirborne(caster, knockup, knock_duration)
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
		if caster.IsPioneerOfStarAcquired then
			caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_dance_macabre_2", true, false)
		else
			caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_2", true, false)
		end
	elseif caster.macabre == 2 then 
		if caster.IsPioneerOfStarAcquired then
			caster:SwapAbilities("drake_dance_macabre_1_upgrade", "drake_dance_macabre_3_upgrade", true, false)
		else
			caster:SwapAbilities("drake_dance_macabre_1", "drake_dance_macabre_3", true, false)
		end
	end
	caster.macabre = 0
end

function OnSummonBombardStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local frontVec = caster:GetForwardVector()
	local angle = caster:GetAnglesAsVector().y
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() + 90
	local leftVec = -rightVec 
	local aoe = ability:GetSpecialValueFor("aoe")
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval") 
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_stun = ability:GetSpecialValueFor("bomb_stun")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local bomb_count = ability:GetSpecialValueFor("bomb_count")

	local visiondummy = SpawnVisionDummy(caster, position, aoe, 3, false)

	local cannon_counter = 1

	if caster:HasModifier('modifier_alternate_04') then 
		caster:EmitSound("Drake-Summer-E")
	end	

	Timers:CreateTimer( cast_delay - ability:GetCastPoint(), function()

		local cannonorigin = {}
		cannonorigin[1] = GetRotationPoint(origin, 200,angle + 180) + Vector(0,0,200)
		cannonorigin[2] = GetRotationPoint(cannonorigin[1], 100,angle + 90) + Vector(0,0,-50)
		cannonorigin[3] = GetRotationPoint(cannonorigin[1], 50, angle + 90)
		cannonorigin[4] = GetRotationPoint(cannonorigin[1], 50,angle - 90)
		cannonorigin[5] = GetRotationPoint(cannonorigin[1], 100,angle - 90) + Vector(0,0,-50)
		--[[cannonorigin[1] = origin + Vector(backVec.x * 200, backVec.y * 200, 200)
		cannonorigin[2] = cannonorigin[1] + Vector(rightVec.x * 100, rightVec.y * 100, -50)
		cannonorigin[3] = cannonorigin[1] + Vector(rightVec.x * 50, rightVec.y * 50, 0)
		cannonorigin[4] = cannonorigin[1] + Vector(leftVec.x * 50, leftVec.y * 50, 0)
		cannonorigin[5] = cannonorigin[1] + Vector(leftVec.x * 100, leftVec.y * 100, -50)]]
		--[[for k,v in pairs( cannonorigin) do 
			print(k,v)
		end]]
		local cannon_loc = cannonorigin[1]
		local summon_cannon = {}
		for i = 1, 5 do
			summon_cannon[i] = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_dummy.vpcf", PATTACH_WORLDORIGIN, caster )
			--print('cannon origin ' .. i .. " : " .. cannonorigin[i])
			--cannon_loc = cannonorigin[i]
			--print(cannon_loc)
			ParticleManager:SetParticleControl(summon_cannon[i], 0, cannonorigin[i])
			ParticleManager:SetParticleControl(summon_cannon[i], 1, Vector(0,0,angle + 90))
		end

		--[[Timers:CreateTimer((bomb_interval * bomb_count) + 0.1, function()
			for k,v in pairs (summon_cannon) do
				if v ~= nil then 
					ParticleManager:DestroyParticle(v, true)
					ParticleManager:ReleaseParticleIndex(v)
				end
			end
		end)]]
		local sourceLoc = 0
		Timers:CreateTimer(bomb_interval, function()
			if cannon_counter > bomb_count then 
				for k,v in pairs (summon_cannon) do
					if v ~= nil then 
						ParticleManager:DestroyParticle(v, true)
						ParticleManager:ReleaseParticleIndex(v)
					end
				end
				return nil 
			end

			

			if cannon_counter == 6 then 
				sourceLoc = 1
			else
				sourceLoc = cannon_counter
			end
			--print('cannon counter = ' .. sourceLoc)

			SummonBombardShoot(caster, ability, position, cannonorigin[sourceLoc], bomb_speed, aoe, bomb_dmg, bomb_stun)

			cannon_counter = cannon_counter + 1

			return bomb_interval
		end)
	end)


		--[[local bombard_cannon1 = CreateUnitByName("drake_cannon_dummy", cannon1origin, false, caster, caster, caster:GetTeamNumber())
		local bombard_cannon2 = CreateUnitByName("drake_cannon_dummy", cannon2origin, false, caster, caster, caster:GetTeamNumber())
		local bombard_cannon3 = CreateUnitByName("drake_cannon_dummy", cannon3origin, false, caster, caster, caster:GetTeamNumber())
		local bombard_cannon4 = CreateUnitByName("drake_cannon_dummy", cannon4origin, false, caster, caster, caster:GetTeamNumber())
		local bombard_cannon5 = CreateUnitByName("drake_cannon_dummy", cannon5origin, false, caster, caster, caster:GetTeamNumber())
		bombard_cannon1:SetOrigin(cannon1origin + Vector(0,0,-120))
		bombard_cannon2:SetOrigin(cannon2origin + Vector(0,0,-100))
		bombard_cannon3:SetOrigin(cannon3origin + Vector(0,0,-100))
		bombard_cannon4:SetOrigin(cannon4origin + Vector(0,0,-100))
		bombard_cannon5:SetOrigin(cannon5origin + Vector(0,0,-120))
		bombard_cannon1:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		bombard_cannon2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		bombard_cannon3:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		bombard_cannon4:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		bombard_cannon5:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		bombard_cannon1:SetForwardVector(frontVec)
		bombard_cannon2:SetForwardVector(frontVec)
		bombard_cannon3:SetForwardVector(frontVec)
		bombard_cannon4:SetForwardVector(frontVec)
		bombard_cannon5:SetForwardVector(frontVec)
		bombard_cannon1:AddNewModifier(caster, nil, "modifier_kill", {duration = (bomb_interval * bomb_count) + 1})
		bombard_cannon2:AddNewModifier(caster, nil, "modifier_kill", {duration = (bomb_interval * bomb_count) + 1})
		bombard_cannon3:AddNewModifier(caster, nil, "modifier_kill", {duration = (bomb_interval * bomb_count) + 1})
		bombard_cannon4:AddNewModifier(caster, nil, "modifier_kill", {duration = (bomb_interval * bomb_count) + 1})
		bombard_cannon5:AddNewModifier(caster, nil, "modifier_kill", {duration = (bomb_interval * bomb_count) + 1})
		
		for i = 1, bomb_count do
			Timers:CreateTimer( bomb_interval*i, function()
				if i == 1 then
					SummonBombardShoot (caster, ability, position, cannon1origin, bomb_speed)
				elseif i == 2 then
					SummonBombardShoot (caster, ability, position, cannon2origin, bomb_speed)
				elseif i == 3 then
					SummonBombardShoot (caster, ability, position, cannon3origin, bomb_speed)
				elseif i == 4 then 
					SummonBombardShoot (caster, ability, position, cannon4origin, bomb_speed)
				elseif i == 5 then
					SummonBombardShoot (caster, ability, position, cannon5origin, bomb_speed)
				elseif i == 6 then 
					SummonBombardShoot (caster, ability, position, cannon3origin, bomb_speed)
				end
			end)
		end
	end)]]
end

function SummonBombardShoot (caster, ability, vTargetLoc, vSourceLoc, iSpeed, iAOE, iDamage, iStun)
	
	local bulletfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl(bulletfx, 0, vSourceLoc)
	ParticleManager:SetParticleControl(bulletfx, 1, vTargetLoc)
	ParticleManager:SetParticleControl(bulletfx, 2, Vector(iSpeed,0,0))
	local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, vSourceLoc )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, vSourceLoc )

	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
	end)

	local distance = (vTargetLoc - vSourceLoc):Length2D()
	local delay = distance / iSpeed

	Timers:CreateTimer(delay + 0.1, function()
		ParticleManager:DestroyParticle(bulletfx, true)
		ParticleManager:ReleaseParticleIndex(bulletfx)

		EmitSoundOnLocationWithCaster(vTargetLoc, "Hero_Snapfire.Shotgun.Target", caster)

		local BombFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(BombFx, 0, vTargetLoc) 
		ParticleManager:SetParticleControl(BombFx, 1, Vector(iAOE,0,iAOE)) 
			
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( BombFx, false )
			ParticleManager:ReleaseParticleIndex( BombFx )
		end)

		local enemies = FindUnitsInRadius(caster:GetTeam(), vTargetLoc, nil, iAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for _, target in pairs (enemies) do
			--if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
				DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
					target:AddNewModifier(caster, ability, "modifier_stunned", {duration = iStun})
				end
				
			--end
		end
	end)
end
--[[function SummonBombardShoot (caster, ability, position, origin, speed)
	local origindummy = CreateUnitByName("dummy_unit", origin , false, caster, caster, caster:GetTeamNumber())
	origindummy:SetOrigin(origin)
    origindummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	local targetdummy = CreateUnitByName("dummy_unit", position , false, caster, caster, caster:GetTeamNumber())
    targetdummy:SetOrigin(position)
    targetdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

	local projectileTable = {
        EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_base_attack.vpcf",
        Ability = ability,
        --vSpawnOrigin = origin,
        Target = targetdummy,
        Source = origindummy, 
        iMoveSpeed = speed,
        bDodgable = false,
        bProvidesVision = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_NONE,
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
			if IsValidEntity(targetdummy) then
           		targetdummy:RemoveSelf()
        	end
        	if IsValidEntity(origindummy) then
           		origindummy:RemoveSelf()
        	end
        end)
	end)	
end]]

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
		if not enemy:IsMagicImmune() and not IsImmuneToCC(enemy) then 
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
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local aoe = ability:GetSpecialValueFor("aoe")
	local Blaser_dmg = ability:GetSpecialValueFor("lasthit_dmg")
	local point = RandomPointInCircle(position, aoe)
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval")
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cannon_interval = ability:GetSpecialValueFor("cannon_interval")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")
	local Rlaser_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local Ylaser_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local ply = caster:GetMainControllingPlayer()
	local angle = caster:GetAnglesAsVector().y + 90

	local visiondummy = SpawnVisionDummy(caster, position, aoe, 5, false)
	local shiploc = {}
	shiploc[1] = origin + Vector(backVec.x * 600, backVec.y * 600, 200)
	-- first line
 	shiploc[12] = shiploc[1] + Vector(leftVec.x * 400, leftVec.y * 400,100)
	shiploc[13] = shiploc[1] + Vector(rightVec.x * 400, rightVec.y * 400,100)
	-- second line
	shiploc[9] = shiploc[1] + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(rightVec.x * 300, rightVec.y * 300,0)
	shiploc[6] = shiploc[1] + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(leftVec.x * 300, leftVec.y * 300,0)
	shiploc[2] = shiploc[9] + Vector(rightVec.x * 300, rightVec.y * 300,100)
	shiploc[3] = shiploc[6] + Vector(leftVec.x * 300, leftVec.y * 300,100)
	--third line
	shiploc[4] = shiploc[1] + Vector(backVec.x * 600, backVec.y * 600, 0) + Vector(rightVec.x * 200, rightVec.y * 200,0)
	shiploc[5] = shiploc[1] + Vector(backVec.x * 600, backVec.y * 600,0) + Vector(leftVec.x * 200, leftVec.y * 200,0)
	shiploc[7] = shiploc[4] + Vector(rightVec.x * 200, rightVec.y * 200,100)
	shiploc[8] = shiploc[5] + Vector(leftVec.x * 200, leftVec.y * 200,100)
	shiploc[10] = shiploc[4] + Vector(rightVec.x * 400, rightVec.y * 400,0)
	shiploc[11] = shiploc[5] + Vector(leftVec.x * 400, leftVec.y * 400,0)
	
	if string.match(caster:GetUnitName(), "troll_warlord") then 
		if caster:HasModifier("modifier_golden_wild_hunt_check") then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + 800)
			return
		end
		if IsValidEntity(caster.flagship) and caster.flagship:IsAlive() then 
			caster.flagship:SetOrigin(shiploc[1])
			caster.flagship:SetForwardVector(frontVec)
			giveUnitDataDrivenModifier(caster, caster.flagship, "jump_pause" , 5.0)
		else
			caster.flagshipdummy = ParticleManager:CreateParticle("particles/custom/drake/drake_golden_hind.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(caster.flagshipdummy, 0, shiploc[1])
			ParticleManager:SetParticleControl(caster.flagshipdummy, 1, Vector(0,0,angle))
			--[[caster.flagshipdummy = CreateUnitByName("drake_golden_hind_dummy", shiploc1, false, caster, caster, caster:GetTeamNumber())
			caster.flagshipdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			caster.flagshipdummy:SetForwardVector(frontVec)
			caster.flagshipdummy:EmitSound("Ability.Torrent")
			caster.flagshipdummy:SetOwner(caster)]]
		end
		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled" , cast_delay)
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		local hero = caster:GetOwnerEntity()
		shiploc1 = origin
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
		--[[if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.9})
		end]]
		giveUnitDataDrivenModifier(caster, caster, "drag_pause" , 5.0)
		hero:SetMana(math.max(0, hero:GetMana() - 800))
		caster = hero
		ability = caster:FindAbilityByName(ability:GetAbilityName())
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
 	end

 	

 	EmitGlobalSound("Drake.WildHunt")
 	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_check", {})
 	if caster.bigship == nil then 
		caster.bigship = {}
	end
	--[[if caster.smallship == nil then 
		caster.smallship = {}
	end]]

	local ship_dummy = "particles/custom/drake/drake_big_ship.vpcf"
	for i = 2,13 do 
		caster.bigship[i] = ParticleManager:CreateParticle(ship_dummy, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(caster.bigship[i], 0, shiploc[i])
		ParticleManager:SetParticleControl(caster.bigship[i], 1, Vector(0,0,angle))
		if i >= 2 and i <= 5 then 
			ParticleManager:SetParticleControl(caster.bigship[i], 2, Vector(1.0,0,0))
		elseif i >= 6 and i <= 13 then 
			ParticleManager:SetParticleControl(caster.bigship[i], 2, Vector(0.7,0,0))
		end 
	end

	local Rlaser_counter = 0 
	local Ylaser_counter = 0 

	Timers:CreateTimer(cast_delay, function()
		Timers:CreateTimer("golden_wild_red" .. caster:GetPlayerOwnerID(), {
			endTime = cannon_interval,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			if hero == caster then 
				if not IsValidEntity(caster.flagship) or not caster.flagship:IsAlive() then
					caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
					return nil
				end
			end

			Rlaser_counter = Rlaser_counter + 1

			if Rlaser_counter > cannon_count then
				caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
				return nil 
			elseif Rlaser_counter == 4 then 
				GoldenWildHuntShot(caster, ability, position, shiploc[1], Blaser_dmg, 3)
			else	
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[1], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[2], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[3], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[4], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[5], Rlaser_dmg, 1)
			end

			EmitSoundOnLocationWithCaster(shiploc[1], "Hero_Snapfire.ExplosiveShellsBuff.Attack", caster)
			

			Timers:CreateTimer(0.3, function()
				EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
			end)
			return cannon_interval
		end})

		Timers:CreateTimer("golden_wild_yellow" .. caster:GetPlayerOwnerID(), {
			endTime = 0,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			Ylaser_counter = Ylaser_counter + 1

			if Ylaser_counter > cannon_count then
				return nil 
			else	
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[6], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[7], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[8], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[9], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[10], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[11], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[12], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[13], Ylaser_dmg, 2)
			end

			EmitSoundOnLocationWithCaster(shiploc[6], "Hero_Snapfire.ExplosiveShellsBuff.Attack", caster)
			

			Timers:CreateTimer(0.3, function()
				EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
			end)
			return bomb_interval
		end})
	end)
end

function GetTargetLoc(source, vPosition, iRadius, bLuck)
	local vTargetLoc = RandomPointInCircle(vPosition, iRadius)
	if GridNav:IsBlocked(vTargetLoc) or not GridNav:IsTraversable(vTargetLoc) then
		vTargetLoc = RandomPointInCircle(vPosition, iRadius)
	end
	if bLuck == true then 
		local random = RandomInt(1, 100)
		if (string.match(source:GetUnitName(), "troll_warlord") and source:HasModifier("modifier_voyager_lucky")) or (string.match(source:GetUnitName(), "drake_golden_hind") and source:HasModifier("modifier_storm_aura")) then 
			random = 1
		end
		if random <= 10 then 
 			local targets = FindUnitsInRadius(source:GetTeam(), vPosition, nil, iRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		 	if targets[1] == nil then 
		 		vTargetLoc = vTargetLoc
		 	else
		 		vTargetLoc = targets[1]:GetAbsOrigin()
		 	end
		end
	end
	return vTargetLoc
end

function GoldenWildHuntShot(caster, ability, vTargetLoc, vSourceLoc, iDamage, iLaser)
	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end
	if ability == nil then return end
	local laserFx = "particles/custom/drake/drake_red_laser.vpcf"
	local aoe = ability:GetSpecialValueFor("cannon_aoe")
	local stun = ability:GetSpecialValueFor("cannon_stun")

	if iLaser == 1 then 
		--print('red laser')
	elseif iLaser == 2 then 
		laserFx = "particles/custom/drake/drake_yellow_laser.vpcf"
		aoe = ability:GetSpecialValueFor("bomb_aoe")
		--print('yellow laser')
	elseif iLaser == 3 then 
		laserFx = "particles/custom/drake/drake_blue_laser.vpcf"
		aoe = ability:GetSpecialValueFor("bomb_aoe")
		stun = 1.0
		--print('blue laser')
	end 

	local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, vSourceLoc  )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, vSourceLoc  )

	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
	end)

	local LaserFx = ParticleManager:CreateParticle( laserFx, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl( LaserFx, 0, vSourceLoc )
	ParticleManager:SetParticleControl( LaserFx, 1, vTargetLoc )

	Timers:CreateTimer( 0.3 , function()
		ParticleManager:DestroyParticle( LaserFx, true )
		ParticleManager:ReleaseParticleIndex( LaserFx )

		local CannonFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(CannonFx, 0, vTargetLoc) 
		ParticleManager:SetParticleControl(CannonFx, 1, Vector(aoe,0.2,aoe)) 
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( CannonFx, false )
			ParticleManager:ReleaseParticleIndex( CannonFx )
		end)
		if IsValidEntity(caster) and not caster:IsNull() then
			local Targets = FindUnitsInRadius(caster:GetTeamNumber(), vTargetLoc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for _, target in pairs (Targets) do
				if IsValidEntity(target) and not target:IsNull() then
					if iLaser == 2 then 
						if not target:IsMagicImmune() and not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
							ability:ApplyDataDrivenModifier(caster, target, "modifier_golden_wild_hunt_slow", {})
						end
					else
						if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
							target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
						end
					end
					DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end
	end)
end

function ThunderStrike(caster, ability, vTargetLoc, iDamage, iAOE)
	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end
	if ability == nil then return end
	local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx1, 0, vTargetLoc)
	ParticleManager:SetParticleControl(thunderfx1, 1, Vector(vTargetLoc.x,vTargetLoc.y,1000))
	local thundergroundfx1 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thundergroundfx1, 0, vTargetLoc)
	Timers:CreateTimer(0.5 , function()
		ParticleManager:DestroyParticle( thunderfx1, false )
		ParticleManager:ReleaseParticleIndex( thunderfx1 )
		ParticleManager:DestroyParticle( thundergroundfx1, false )
		ParticleManager:ReleaseParticleIndex( thundergroundfx1 )
	end)
	EmitSoundOnLocationWithCaster(vTargetLoc, "Hero_Zuus.LightningBolt", caster)
 	local thunder = FindUnitsInRadius(caster:GetTeam(), vTargetLoc, nil, iAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
 	for _,target in pairs (thunder) do
 		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
	 		if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
	 			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
	 		end
	 		if not IsLightningResist(target) then
	 			DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	 		end
	 	end
 	end
end

function BlizzardStorm(caster, ability, vTargetLoc, iDamage, iAOE)
	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end
	if ability == nil then return end
	local blizzardfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(blizzardfx, 0, vTargetLoc)
	ParticleManager:SetParticleControl(blizzardfx, 1, Vector(iAOE,0,0))
	Timers:CreateTimer(0.5 , function()
		ParticleManager:DestroyParticle( blizzardfx, false )
		ParticleManager:ReleaseParticleIndex( blizzardfx )
	end)
 	EmitSoundOnLocationWithCaster(vTargetLoc, "hero_Crystal.preAttack", caster)
 	local blizzard = FindUnitsInRadius(caster:GetTeam(), vTargetLoc, nil, iAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
 	for _,target in pairs (blizzard) do
 		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
	 		if not target:IsMagicImmune() and not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
	 			ability:ApplyDataDrivenModifier(caster, target, "modifier_blizzard_slow", {})
	 		end
	 		DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	 	end
 	end
end

function FireShipFall(caster, ability, vTargetLoc, iDamage, iAOE)
	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end
	if ability == nil then return end
	local frontVec = caster:GetForwardVector()
	local vSourceLoc = caster:GetAbsOrigin() + Vector(0,0,1000)
	local leftvec = Vector(-frontVec.y, frontVec.x, 0)
	local rightvec = Vector(frontVec.y, -frontVec.x, 0)
	local random1 = RandomInt(0,350) -- position of weapon spawn
	local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero
	local fire_pos = vSourceLoc + leftvec*random1 
	
	if random2 == 1 then 
		fire_pos = vSourceLoc + rightvec*random1
	end

 	local forwardvec = (fire_pos-vTargetLoc):Normalized()
	local angle = VectorToAngles(forwardvec).y
	--print('angle = ' .. angle)

 	local FireShipFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_fireship_model.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( FireShipFx, 0, fire_pos )
	ParticleManager:SetParticleControl( FireShipFx, 1, vTargetLoc )
	ParticleManager:SetParticleControl( FireShipFx, 2, Vector(1.3,0,0) )
	ParticleManager:SetParticleControl( FireShipFx, 4, Vector(0,angle,0) )
	Timers:CreateTimer(  1.4, function()
		ParticleManager:DestroyParticle( FireShipFx, false )
		ParticleManager:ReleaseParticleIndex( FireShipFx )	
		EmitSoundOnLocationWithCaster(vTargetLoc, "Hero_Techies.Suicide", caster)
 		local fireship = FindUnitsInRadius(caster:GetTeam(), vTargetLoc, nil, iAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
 		for _,target in pairs (fireship) do
 			if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
		 		if not target:IsMagicImmune() then 
		 			ability:ApplyDataDrivenModifier(caster, target, "modifier_golden_wild_hunt_burn", {})
		 		end
		 		DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		 	end
 		end
 	end)
end

function GoldenWildHuntBigShot (caster, ability, position, source, origin, speed)
	local cannon_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local cannon_aoe = ability:GetSpecialValueFor("cannon_aoe")
	local cannon_stun = ability:GetSpecialValueFor("cannon_stun")
 	local start_loc = origin + Vector(0,0,200)
 	
   	local newForwardVec = ( position - start_loc ):Normalized()
   	local distance = ( position - start_loc  ):Length2D()
	
	local LaserFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_laser.vpcf", PATTACH_ABSORIGIN_FOLLOW, source)
	ParticleManager:SetParticleControl( LaserFx, 0, start_loc )
	ParticleManager:SetParticleControl( LaserFx, 1, position )

	Timers:CreateTimer( distance / speed , function()
		ParticleManager:DestroyParticle( LaserFx, false )
		ParticleManager:ReleaseParticleIndex( LaserFx )

		EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
		local CannonFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(CannonFx, 0, position) 
		-- radius fire blast, spark, fire ring
		ParticleManager:SetParticleControl(CannonFx, 1, Vector(cannon_aoe,0.2,cannon_aoe)) 
		-- Destroy particle after delay
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( CannonFx, false )
			ParticleManager:ReleaseParticleIndex( CannonFx )
		end)
		local CannonTarget = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, cannon_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for _, stuntarget in pairs (CannonTarget) do
			if not stuntarget:IsMagicImmune() and not IsImmuneToCC(stuntarget) then 
				stuntarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = cannon_stun})
			end
			DoDamage(caster, stuntarget, cannon_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end)
	local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, start_loc  )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, start_loc  )
	-- Destroy Particle
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
	end)
end

function GoldenWildHuntBulletShot (caster, ability, position, source, speed)
	local bomb_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local bomb_aoe = ability:GetSpecialValueFor("bomb_aoe")
 	local start_loc = source:GetAbsOrigin() + Vector(0,0,200)
 	if ability:GetAbilityName() == "drake_golden_wild_hunt" then 
 		if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
 			if caster:HasModifier("modifier_voyager_lucky") then 
 				local targets = FindUnitsInRadius(caster:GetTeam(), position, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
 				if targets[1] == nil then 
 					position = position
 				else
 					position = targets[1]:GetAbsOrigin()
 				end
 			end
 		end	
 	end
   	local newForwardVec = ( position - start_loc ):Normalized()
   	local distance = ( position - start_loc  ):Length2D()
   	 -- Particles on impact
   	local CannonBulletFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_cannon_bullet_yellow.vpcf", PATTACH_ABSORIGIN_FOLLOW, source)
	ParticleManager:SetParticleControl( CannonBulletFx, 0, start_loc )
	ParticleManager:SetParticleControl( CannonBulletFx, 1, newForwardVec * speed )

	Timers:CreateTimer( distance / speed , function()
		ParticleManager:DestroyParticle( CannonBulletFx, false )
		ParticleManager:ReleaseParticleIndex( CannonBulletFx )

		EmitSoundOnLocationWithCaster(position, "Hero_Techies.LandMine.Detonate", caster)
		local CannonFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(CannonFx, 0, position) 
		local FireFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( FireFxIndex, 0, position )
		-- Destroy particle after delay
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( CannonFx, false )
			ParticleManager:ReleaseParticleIndex( CannonFx )
			ParticleManager:DestroyParticle( FireFxIndex, false )
			ParticleManager:ReleaseParticleIndex( FireFxIndex )
		end)
		local BombTarget = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, bomb_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for _, slowtarget in pairs (BombTarget) do
			if not slowtarget:IsMagicImmune() and not IsImmuneToSlow(slowtarget) and not IsImmuneToCC(slowtarget) then 
				ability:ApplyDataDrivenModifier(caster, slowtarget, "modifier_golden_wild_hunt_slow", {})
			end
			DoDamage(caster, slowtarget, bomb_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end)
	local FireFxIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( FireFxIndex, 0, start_loc  )
	local SmokeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( SmokeFxIndex, 0, start_loc  )
	-- Destroy Particle
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( FireFxIndex, false )
		ParticleManager:ReleaseParticleIndex( FireFxIndex )
		ParticleManager:DestroyParticle( SmokeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( SmokeFxIndex )
	end)
end

function OnGoldenWildHuntDestroy (keys)
	local caster = keys.caster 
	local ply = caster:GetMainControllingPlayer()
	local hero = caster:GetOwnerEntity()
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	if caster.bigship ~= nil then 
		for _,v in pairs(caster.bigship) do 
			if v ~= nil then 
				ParticleManager:DestroyParticle(v, true)
				ParticleManager:ReleaseParticleIndex(v)
			end
		end 
	end

	if caster.flagshipdummy ~= nil then 
		ParticleManager:DestroyParticle(caster.flagshipdummy, true)
		ParticleManager:ReleaseParticleIndex(caster.flagshipdummy)
	end
	--[[for _,v in pairs(caster.smallship) do
		if v and IsValidEntity(v) then
            v:RemoveSelf()
            UTIL_Remove(v)
        end
	end
	for _,u in pairs(caster.bigship) do
		if u and IsValidEntity(u) then
            u:RemoveSelf()
            UTIL_Remove(u)
        end
	end
 	if IsValidEntity(caster.flagshipdummy) then 
 		caster.flagshipdummy:RemoveSelf()
    	UTIL_Remove(caster.flagshipdummy)
    end]]
end

function OnGoldenWildHuntDie (keys)
	keys.caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
end

function DrakeCheckCombo(caster, ability)
	if string.match(caster:GetUnitName(), "troll_warlord") then 
		if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 and not caster:HasModifier("modifier_golden_wild_hunt_cooldown") and not caster:HasModifier("modifier_golden_wild_hunt_check") then
			if caster.IsStrengthenGoldenHindAcquired then
				if string.match(ability:GetAbilityName(), "drake_voyager_of_storm") and caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):IsCooldownReady() and caster:FindAbilityByName("drake_combo_golden_wild_hunt_upgrade"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
				end
			else
				if string.match(ability:GetAbilityName(), "drake_voyager_of_storm") and caster:FindAbilityByName("drake_golden_wild_hunt"):IsCooldownReady() and caster:FindAbilityByName("drake_combo_golden_wild_hunt"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
				end
			end
		end
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		local ply = caster:GetMainControllingPlayer()
		local hero = caster:GetOwnerEntity()
		if math.ceil(hero:GetStrength()) >= 25 and math.ceil(hero:GetAgility()) >= 25 and math.ceil(hero:GetIntellect()) >= 25 and not hero:HasModifier("modifier_golden_wild_hunt_cooldown") and not hero:HasModifier("modifier_golden_wild_hunt_check") then
			if hero.IsStrengthenGoldenHindAcquired then
				if string.match(ability:GetAbilityName(), "drake_golden_hind_voyager_of_storm") and caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
				end
			else
				if string.match(ability:GetAbilityName(), "drake_golden_hind_voyager_of_storm") and caster:FindAbilityByName("drake_golden_wild_hunt"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_window", {})	
				end
			end
		end
	end
end

function OnComboWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if string.match(caster:GetUnitName(), "troll_warlord") then 
		if caster.IsStrengthenGoldenHindAcquired then
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_combo_golden_wild_hunt_upgrade", false, true) 
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", false, true) 
		end
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		local hero = caster:GetOwnerEntity()
		if hero.IsStrengthenGoldenHindAcquired then
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_combo_golden_wild_hunt_upgrade", false, true) 
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", false, true) 
		end
	end
end

function OnComboWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if string.match(caster:GetUnitName(), "troll_warlord") then 
		if caster.IsStrengthenGoldenHindAcquired then
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_combo_golden_wild_hunt_upgrade", true, false) 
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", true, false) 
		end
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		local hero = caster:GetOwnerEntity()
		if hero.IsStrengthenGoldenHindAcquired then
			caster:SwapAbilities("drake_golden_wild_hunt_upgrade", "drake_combo_golden_wild_hunt_upgrade", true, false) 
		else
			caster:SwapAbilities("drake_golden_wild_hunt", "drake_combo_golden_wild_hunt", true, false) 
		end
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
	local lightning_dmg = ability:GetSpecialValueFor("lightning_dmg")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local lightning_stun = ability:GetSpecialValueFor("lightning_stun")
	local lightning_count = ability:GetSpecialValueFor("lightning_count")
	local lightning_interval = ability:GetSpecialValueFor("lightning_interval")
	local blizzard_count = ability:GetSpecialValueFor("blizzard_count")
	local blizzard_aoe = ability:GetSpecialValueFor("blizzard_aoe")
	local blizzard_dmg = ability:GetSpecialValueFor("blizzard_dmg")
	local blizzard_interval = ability:GetSpecialValueFor("blizzard_interval")
	local fireship_dmg = ability:GetSpecialValueFor("fireship_dmg")
	local fireship_aoe = ability:GetSpecialValueFor("fireship_aoe")
	local fireship_count = ability:GetSpecialValueFor("fireship_count")
	local bomb_count = ability:GetSpecialValueFor("bomb_count")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local aoe = ability:GetSpecialValueFor("aoe")
	local Blaser_dmg = ability:GetSpecialValueFor("lasthit_dmg")
	local point = RandomPointInCircle(position, aoe)
	local bomb_interval = ability:GetSpecialValueFor("bomb_interval")
	local cannon_count = ability:GetSpecialValueFor("cannon_count")
	local bomb_speed = ability:GetSpecialValueFor("bomb_speed")
	local cannon_interval = ability:GetSpecialValueFor("cannon_interval")
	local cannon_speed = ability:GetSpecialValueFor("cannon_speed")
	local Rlaser_dmg = ability:GetSpecialValueFor("cannon_dmg")
	local Ylaser_dmg = ability:GetSpecialValueFor("bomb_dmg")
	local ply = caster:GetMainControllingPlayer()
	local angle = caster:GetAnglesAsVector().y + 90
	local hero = nil

	local visiondummy = SpawnVisionDummy(caster, position, aoe, 5, false)

	local shiploc = {}
	shiploc[1] = origin + Vector(backVec.x * 600, backVec.y * 600, 200)
	-- first line
 	shiploc[12] = shiploc[1] + Vector(leftVec.x * 400, leftVec.y * 400,100)
	shiploc[13] = shiploc[1] + Vector(rightVec.x * 400, rightVec.y * 400,100)
	-- second line
	shiploc[9] = shiploc[1] + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(rightVec.x * 300, rightVec.y * 300,0)
	shiploc[6] = shiploc[1] + Vector(backVec.x * 200, backVec.y * 200, 0) + Vector(leftVec.x * 300, leftVec.y * 300,0)
	shiploc[2] = shiploc[9] + Vector(rightVec.x * 300, rightVec.y * 300,100)
	shiploc[3] = shiploc[6] + Vector(leftVec.x * 300, leftVec.y * 300,100)
	--third line
	shiploc[4] = shiploc[1] + Vector(backVec.x * 600, backVec.y * 600, 0) + Vector(rightVec.x * 200, rightVec.y * 200,0)
	shiploc[5] = shiploc[1] + Vector(backVec.x * 600, backVec.y * 600,0) + Vector(leftVec.x * 200, leftVec.y * 200,0)
	shiploc[7] = shiploc[4] + Vector(rightVec.x * 200, rightVec.y * 200,100)
	shiploc[8] = shiploc[5] + Vector(leftVec.x * 200, leftVec.y * 200,100)
	shiploc[10] = shiploc[4] + Vector(rightVec.x * 400, rightVec.y * 400,0)
	shiploc[11] = shiploc[5] + Vector(leftVec.x * 400, leftVec.y * 400,0)
	
	if string.match(caster:GetUnitName(), "troll_warlord") then 
		if caster:HasModifier("modifier_golden_wild_hunt_check") then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + 800)
			return
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_cooldown", {})
		if caster.IsStrengthenGoldenHindAcquired then 
			caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetLevel()))
		else
			caster:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetLevel()))
		end
		if IsValidEntity(caster.flagship) and caster.flagship:IsAlive() then 
			caster.flagship:SetOrigin(shiploc[1])
			caster.flagship:SetForwardVector(frontVec)
		else
			local unitName = "drake_golden_hind"
			local golden_wild_hunt = "drake_golden_wild_hunt"
			if caster.IsStrengthenGoldenHindAcquired then 
				unitName = "drake_golden_hind_upgrade"
				golden_wild_hunt = "drake_golden_wild_hunt_upgrade"
			end
			caster.flagship = CreateUnitByName(unitName, origin, false, caster, caster, caster:GetTeamNumber())
    		FindClearSpaceForUnit(caster.flagship, origin + Vector(-frontVec.x * 100,-frontVec.y * 100,-100), true)
    		caster.flagship:SetForwardVector(frontVec)
			caster.flagship:SetControllableByPlayer(caster:GetPlayerID(), true)
			caster.flagship:EmitSound("Ability.Torrent")
			caster.flagship:SetOwner(caster)
			caster.IsOnBoarded = false
			SendMountStatus(caster)
			local playerData = {
		        transport = caster.flagship:entindex()
		    }
		    CustomGameEventManager:Send_ServerToPlayer( caster:GetPlayerOwner(), "player_summoned_transport", playerData )
			if caster.IsStrengthenGoldenHindAcquired then
				caster:FindAbilityByName("drake_military_tactic_summon_golden_hind_upgrade"):ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_check", {})
			else
				caster:FindAbilityByName("drake_military_tactic_summon_golden_hind"):ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_check", {})
			end
			for i = 0,11 do 
				caster.flagship:GetAbilityByIndex(i):SetLevel(1)
			end
			caster.flagship:FindAbilityByName("drake_golden_wild_hunt_upgrade"):SetHidden(true)
			caster.flagship:FindAbilityByName("drake_golden_wild_hunt"):SetHidden(true)
			caster.flagship:AddItem(CreateItem("item_drake_onboard" , nil, nil))
		end
		caster.flagship:FindItemInInventory("item_drake_onboard"):ApplyDataDrivenModifier(caster.flagship, caster, "modifier_board_drake", {})
		caster.flagship:FindItemInInventory("item_drake_onboard"):ApplyDataDrivenModifier(caster, caster.flagship, "modifier_board", {}) 

		giveUnitDataDrivenModifier(caster, caster.flagship, "jump_pause" , 5.0)
		-- Set master's combo cooldown
		masterCombo = caster.MasterUnit2:FindAbilityByName("drake_combo_golden_wild_hunt")
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	elseif string.match(caster:GetUnitName(), "drake_golden_hind") then 
		hero = caster:GetOwnerEntity()
		shiploc1 = origin
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
		--[[if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.9})
		end]]
		giveUnitDataDrivenModifier(caster, caster, "drag_pause" , 5.0)
		hero:SetMana(math.max(0, hero:GetMana() - 800))
		caster = hero
		ability = caster:FindAbilityByName(ability:GetAbilityName())
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_cooldown", {})
		if caster.IsStrengthenGoldenHindAcquired then 
			caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetLevel()))
		else
			caster:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetLevel()))
		end
 	end

 	caster:RemoveModifierByName("modifier_golden_wild_hunt_window")
 	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_check", {})

 	Timers:CreateTimer(2.2, function()
 		if caster:IsAlive() then 
	 		if caster:HasModifier('modifier_alternate_04') then 
				EmitGlobalSound("Drake-Summer-Combo2")
			else
				EmitGlobalSound("Drake.Temeroso")
			end	
 		end
 		Timers:CreateTimer(2.2, function()
 			if caster:IsAlive() then 
	 			if caster:HasModifier('modifier_alternate_04') then 
					EmitGlobalSound("Drake-Summer-Combo3")
				else
					EmitGlobalSound("Drake.ComboEnd")
				end	
 			end
 		end)
 	end)

 	if caster.bigship == nil then 
		caster.bigship = {}
	end
	--[[if caster.smallship == nil then 
		caster.smallship = {}
	end]]

	local ship_dummy = "particles/custom/drake/drake_big_ship.vpcf"
	for i = 2,13 do 
		caster.bigship[i] = ParticleManager:CreateParticle(ship_dummy, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(caster.bigship[i], 0, shiploc[i])
		ParticleManager:SetParticleControl(caster.bigship[i], 1, Vector(0,0,angle))
		if i >= 2 and i <= 5 then 
			ParticleManager:SetParticleControl(caster.bigship[i], 2, Vector(1.0,0,0))
		elseif i >= 6 and i <= 13 then 
			ParticleManager:SetParticleControl(caster.bigship[i], 2, Vector(0.7,0,0))
		end 
	end

	local Rlaser_counter = 0 
	local Ylaser_counter = 0 
	local thunder_counter = 0
	local blizzard_counter = 0
	local fireship_counter = 0

	Timers:CreateTimer(cast_delay, function()
		Timers:CreateTimer("golden_wild_red" .. caster:GetPlayerOwnerID(), {
			endTime = cannon_interval,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			if hero == caster then 
				if not IsValidEntity(caster.flagship) or not caster.flagship:IsAlive() then
					caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
					return nil
				end
			end

			Rlaser_counter = Rlaser_counter + 1

			if Rlaser_counter > cannon_count then
				caster:RemoveModifierByName("modifier_golden_wild_hunt_check")
				return nil 
			elseif Rlaser_counter == 5 then 
				GoldenWildHuntShot(caster, ability, position, shiploc[1], Blaser_dmg, 3)
			else	
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[1], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[2], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[3], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[4], Rlaser_dmg, 1)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, true), shiploc[5], Rlaser_dmg, 1)
			end

			EmitSoundOnLocationWithCaster(shiploc[1], "Hero_Snapfire.ExplosiveShellsBuff.Attack", caster)
			

			Timers:CreateTimer(0.3, function()
				EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
			end)
			return cannon_interval
		end})

		Timers:CreateTimer("golden_wild_yellow" .. caster:GetPlayerOwnerID(), {
			endTime = 0.1,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			Ylaser_counter = Ylaser_counter + 1

			if Ylaser_counter > cannon_count then
				return nil 
			else	
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[6], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[7], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[8], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[9], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[10], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[11], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[12], Ylaser_dmg, 2)
				GoldenWildHuntShot(caster, ability, GetTargetLoc(caster, position, aoe - 200, false), shiploc[13], Ylaser_dmg, 2)
			end

			EmitSoundOnLocationWithCaster(shiploc[6], "Hero_Snapfire.ExplosiveShellsBuff.Attack", caster)
			
			Timers:CreateTimer(0.3, function()
				EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
			end)
			return bomb_interval
		end})

		Timers:CreateTimer("golden_wild_thunder" .. caster:GetPlayerOwnerID(), {
			endTime = 0.1,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			thunder_counter = thunder_counter + 1

			if thunder_counter > lightning_count then
				return nil 
			else	
				ThunderStrike(caster, ability, RandomPointInCircle(position, aoe), lighning_dmg, lightning_aoe)
			end

			return lightning_interval
		end})
		
		Timers:CreateTimer("golden_wild_blizzard" .. caster:GetPlayerOwnerID(), {
			endTime = 0.1,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end

			blizzard_counter = blizzard_counter + 1

			if blizzard_counter > blizzard_count then
				return nil 
			else
				BlizzardStorm(caster, ability, RandomPointInCircle(position, aoe), blizzard_dmg, blizzard_aoe)	
			end	

			return blizzard_interval
		end})
		
		Timers:CreateTimer("golden_wild_fireship" .. caster:GetPlayerOwnerID(), {
			endTime = 0.1,
			callback = function()
			if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() or not caster:HasModifier("modifier_golden_wild_hunt_check") then return nil end
			
			fireship_counter = fireship_counter + 1

			if fireship_counter > fireship_count then
				return nil 
			else
				FireShipFall(caster, ability, RandomPointInCircle(position, aoe - 100), fireship_dmg, fireship_aoe)
			end

			return 0.4
		end})
		
	end)



	--[[local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local position = ability:GetCursorPosition()
	local frontVec = caster:GetForwardVector()
	local backVec = -frontVec 
	local rightVec = caster:GetRightVector() 
	local leftVec = -rightVec 
	local bomb_count = ability:GetSpecialValueFor("bomb_count")
	local aoe = ability:GetSpecialValueFor("aoe")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
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
	local lasthit_dmg = ability:GetSpecialValueFor("lasthit_dmg")
	local ply = caster:GetMainControllingPlayer()
	
	--local hero = PlayerResource:GetPlayer(ply):GetAssignedHero()
	local visiondummy = SpawnVisionDummy(caster, position, aoe, 5, false)
	-- front line
	local flagshiporigin = origin + Vector(backVec.x * 600, backVec.y * 600, -100)
	
	local golden_hind = caster
	-- Set master's combo cooldown
	
	
	if caster:GetUnitName() == "npc_dota_hero_troll_warlord" then 
		if caster:HasModifier("modifier_golden_wild_hunt_check") then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + 800)
			return
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_cooldown", {})
		if caster.IsStrengthenGoldenHindAcquired then 
			caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetLevel()))
		else
			caster:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetLevel()))
		end
		if IsValidEntity(caster.flagship) and caster.flagship:IsAlive() then 
			caster.flagship:SetOrigin(flagshiporigin)
			caster.flagship:SetForwardVector(frontVec)
		else
			local unitName = "drake_golden_hind"
			local golden_wild_hunt = "drake_golden_wild_hunt"
			if caster.IsStrengthenGoldenHindAcquired then 
				unitName = "drake_golden_hind_upgrade"
				golden_wild_hunt = "drake_golden_wild_hunt_upgrade"
			end
			caster.flagship = CreateUnitByName(unitName, origin, false, caster, caster, caster:GetTeamNumber())
    		FindClearSpaceForUnit(caster.flagship, origin + Vector(-frontVec.x * 100,-frontVec.y * 100,-100), true)
    		caster.flagship:SetForwardVector(frontVec)
			caster.flagship:SetControllableByPlayer(caster:GetPlayerID(), true)
			caster.flagship:EmitSound("Ability.Torrent")
			caster.flagship:SetOwner(caster)
			caster.IsOnBoarded = false
			SendMountStatus(caster)
			local playerData = {
		        transport = caster.flagship:entindex()
		    }
		    CustomGameEventManager:Send_ServerToPlayer( caster:GetPlayerOwner(), "player_summoned_transport", playerData )
			if caster.IsStrengthenGoldenHindAcquired then
				caster:FindAbilityByName("drake_military_tactic_summon_golden_hind_upgrade"):ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_check", {})
			else
				caster:FindAbilityByName("drake_military_tactic_summon_golden_hind"):ApplyDataDrivenModifier(caster, caster, "modifier_golden_hind_check", {})
			end
			for i = 0,11 do 
				caster.flagship:GetAbilityByIndex(i):SetLevel(1)
			end
			caster.flagship:FindAbilityByName("drake_golden_wild_hunt_upgrade"):SetHidden(true)
			caster.flagship:FindAbilityByName("drake_golden_wild_hunt"):SetHidden(true)
			caster.flagship:AddItem(CreateItem("item_drake_onboard" , nil, nil))
		end
		golden_hind = caster.flagship
		caster.flagship:FindItemInInventory("item_drake_onboard"):ApplyDataDrivenModifier(caster.flagship, caster, "modifier_board_drake", {})
		caster.flagship:FindItemInInventory("item_drake_onboard"):ApplyDataDrivenModifier(caster.flagship, caster.flagship, "modifier_board", {}) 

		--caster.flagship:CastAbilityImmediately(caster.flagship:FindItemInInventory(""),caster:GetPlayerOwnerID())
		giveUnitDataDrivenModifier(caster, caster.flagship, "jump_pause" , 5.0)
		-- Set master's combo cooldown
		masterCombo = caster.MasterUnit2:FindAbilityByName("drake_combo_golden_wild_hunt")
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	-- golden hind
	elseif caster:GetUnitName() == "drake_golden_hind" or caster:GetUnitName() == "drake_golden_hind_upgrade" then 
		local hero = caster:GetOwnerEntity()
		flagshiporigin = origin
		local masterCombo = hero.MasterUnit2:FindAbilityByName("drake_combo_golden_wild_hunt")
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(keys.ability:GetCooldown(1))
		StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.0})
		--[[if hero:HasModifier("modifier_sword_buff") then
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.9})
		elseif hero:HasModifier("modifier_pistol_buff") then 
			StartAnimation(hero, {duration=5.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=0.9})
		end]]
		--[[ability:ApplyDataDrivenModifier(caster, hero, "modifier_golden_wild_hunt_cooldown", {})
		if hero.IsStrengthenGoldenHindAcquired then 
			caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt_upgrade"):GetLevel()))
		else
			caster:FindAbilityByName("drake_golden_wild_hunt"):StartCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetCooldown(caster:FindAbilityByName("drake_golden_wild_hunt"):GetLevel()))
		end
		giveUnitDataDrivenModifier(caster, caster, "jump_pause" , 5.0)
		if hero:GetMana() >= 800 then 
			hero:SetMana(hero:GetMana() - 800)
		else 
			hero:SetMana(1.0)
		end
 	end

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

 	caster:RemoveModifierByName("modifier_golden_wild_hunt_window")
 	ability:ApplyDataDrivenModifier(caster, caster, "modifier_golden_wild_hunt_check", {})

 	Timers:CreateTimer(2.2, function()
 		if caster:IsAlive() then 
 			EmitGlobalSound("Drake.Temeroso")
 		end
 		Timers:CreateTimer(2.2, function()
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
 		Timers:CreateTimer(0.3 * j, function()
 			if not caster:IsAlive() then return end
 			if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 			if j == 1 then 
 				caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.bigship[j]:SetOrigin(bigship1origin)
 			elseif j == 2 then 
 				caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.bigship[j]:SetOrigin(bigship2origin)
 			elseif j == 3 then 
 				caster.bigship[j] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.bigship[j]:SetOrigin(bigship3origin)
 			end
 			caster.bigship[j]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 			caster.bigship[j]:SetModelScale(1.3)
 			caster.bigship[j]:SetForwardVector(frontVec)
 		end)
 	end

 	for b = 1,9 do
 		Timers:CreateTimer(0.1 * b, function()
 			if not caster:IsAlive() then return end
 			if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 			if b == 1 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetOrigin(mediumship3origin)
 			elseif b == 2 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetModelScale(0.8)
 				caster.smallship[b]:SetOrigin(smallship2origin)
 			elseif b == 3 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetModelScale(0.8)
 				caster.smallship[b]:SetOrigin(smallship4origin)
 			elseif b == 4 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetOrigin(mediumship4origin)
 			elseif b == 5 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetOrigin(mediumship2origin)
 			elseif b == 6 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetOrigin(smallship5origin)
 				caster.smallship[b]:SetModelScale(0.8)
 			elseif b == 7 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetModelScale(0.8)
 				caster.smallship[b]:SetOrigin(smallship1origin)
 			elseif b == 8 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetOrigin(mediumship1origin)
 			elseif b == 9 then 
 				caster.smallship[b] = CreateUnitByName("drake_wild_hunt_dummy", origin, false, nil, nil, caster:GetTeamNumber())
 				caster.smallship[b]:SetModelScale(0.8)
 				caster.smallship[b]:SetOrigin(smallship3origin)
 			end
 			caster.smallship[b]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
 			caster.smallship[b]:SetForwardVector(frontVec)
 		end)
 	end
 	Timers:CreateTimer(cast_delay, function()
 		for i = 1,bomb_count do
 			Timers:CreateTimer(bomb_interval * i, function()
 				if not caster:IsAlive() then return end
 				if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 				GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[1], bomb_speed)
 				GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[2], bomb_speed)
 				GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[3], bomb_speed)
 				GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[4], bomb_speed)
 				GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[6], bomb_speed)
 				caster.smallship[1]:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
 				Timers:CreateTimer(0.2, function()
 					if not caster:IsAlive() then return end
 					GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[5], bomb_speed)
 					GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[7], bomb_speed)
 					GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[8], bomb_speed)
 					GoldenWildHuntBulletShot (caster, ability, RandomPointInCircle(position, aoe - 200.0), caster.smallship[9], bomb_speed)
 					caster.smallship[5]:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
 				end)
 			end)
 		end

 		for k = 1, cannon_count do
 			Timers:CreateTimer(cannon_interval * k, function()
 				if not caster:IsAlive() then return end
 				if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 				if k == 5 then 
 					local bigbombs = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 					for _,bigbomb in pairs (bigbombs) do
 						if not bigbomb:IsMagicImmune() and not IsImmuneToCC(bigbomb) then 
 							bigbomb:AddNewModifier(caster, ability, "modifier_stunned", {duration = 1.0})
 						end
 						DoDamage(caster, bigbomb, lasthit_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 					end
 					EmitSoundOnLocationWithCaster(position, "Hero_Snapfire.MortimerBlob.Impact", caster)
					local CannonFx = ParticleManager:CreateParticle("particles/custom/drake/drake_cannon_blast.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(CannonFx, 0, position) 
					-- radius fire blast, spark, fire ring
					ParticleManager:SetParticleControl(CannonFx, 1, Vector(aoe,0.2,aoe)) 
					-- Destroy particle after delay
					Timers:CreateTimer(0.5, function()
						ParticleManager:DestroyParticle( CannonFx, false )
						ParticleManager:ReleaseParticleIndex( CannonFx )
					end)
 				end
 				if k >= 1 and k < 5 then
 					local random = RandomInt(1, 100)
 					local pos_1 = RandomPointInCircle(position, aoe - 200.0)
 					local pos_2 = RandomPointInCircle(position, aoe - 200.0)
 					local pos_3 = RandomPointInCircle(position, aoe - 200.0)
 					local pos_4 = RandomPointInCircle(position, aoe - 200.0)
 					while GridNav:IsBlocked(pos_1) or not GridNav:IsTraversable(pos_1) do
						pos_1 = RandomPointInCircle(position, aoe - 200.0)
					end
					while GridNav:IsBlocked(pos_2) or not GridNav:IsTraversable(pos_2) do
						pos_2 = RandomPointInCircle(position, aoe - 200.0)
					end
					while GridNav:IsBlocked(pos_3) or not GridNav:IsTraversable(pos_3) do
						pos_3 = RandomPointInCircle(position, aoe - 200.0)
					end
					while GridNav:IsBlocked(pos_4) or not GridNav:IsTraversable(pos_4) do
						pos_4 = RandomPointInCircle(position, aoe - 200.0)
					end
					if caster.IsStrengthenGoldenHindAcquired or ((caster:GetUnitName() == "drake_golden_hind" or caster:GetUnitName() == "drake_golden_hind_upgrade") and hero.IsStrengthenGoldenHindAcquired) then 
						random = 1
					end
 					if random <= 18 then 
 						local targets = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 				if targets[1] == nil then 
		 					pos_1 = pos_1
		 				else
		 					pos_1 = targets[1]:GetAbsOrigin()
		 				end

		 				local targets2 = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 				if targets2[1] == nil then 
		 					pos_2 = pos_2
		 				else
		 					pos_2 = targets2[1]:GetAbsOrigin()
		 				end

		 				local targets3 = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 				if targets3[1] == nil then 
		 					pos_3 = pos_3
		 				else
		 					pos_3 = targets3[1]:GetAbsOrigin()
		 				end

		 				local targets4 = FindUnitsInRadius(caster:GetTeam(), pos_4, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 				if targets4[1] == nil then 
		 					pos_4 = pos_4
		 				else
		 					pos_4 = targets4[1]:GetAbsOrigin()
		 				end
		 			end
 					GoldenWildHuntBigShot (caster, ability, pos_1, golden_hind, flagshiporigin, cannon_speed)
 					GoldenWildHuntBigShot (caster, ability, pos_2, caster.bigship[1], bigship1origin, cannon_speed)
 					golden_hind:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
 					Timers:CreateTimer(0.5, function()
 						if not caster:IsAlive() then return end
 						GoldenWildHuntBigShot (caster, ability, pos_3, caster.bigship[2], bigship2origin, cannon_speed)
 						GoldenWildHuntBigShot (caster, ability, pos_4, caster.bigship[3], bigship3origin, cannon_speed)
 						caster.bigship[2]:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
 					end)
 				end
 			end)
 		end

 		for n = 0,10 do
 			Timers:CreateTimer(0.5 * n, function()
 				if not caster:IsAlive() then return end
 				if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 				point = RandomPointInCircle(position, aoe)
 				local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(thunderfx1, 0, Vector(point.x,point.y,point.z))
				ParticleManager:SetParticleControl(thunderfx1, 1, Vector(point.x,point.y,1000))
				local thundergroundfx1 = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(thundergroundfx1, 0, Vector(point.x,point.y,point.z))
				Timers:CreateTimer(0.5 , function()
					ParticleManager:DestroyParticle( thunderfx1, false )
					ParticleManager:ReleaseParticleIndex( thunderfx1 )
					ParticleManager:DestroyParticle( thundergroundfx1, false )
					ParticleManager:ReleaseParticleIndex( thundergroundfx1 )
				end)
				EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
 				local thunder = FindUnitsInRadius(caster:GetTeam(), point, nil, lightning_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 				for _,thundertarget in pairs (thunder) do
 					if not thundertarget:IsMagicImmune() and not IsImmuneToCC(thundertarget) then 
 						thundertarget:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.2})
 					end
 					if not IsLightningResist(thundertarget) then
 						DoDamage(caster, thundertarget, lightning_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
 					end
 				end
 			end)
 		end
 		for l = 0,10 do
 			Timers:CreateTimer(0.5 * l, function()
 				if not caster:IsAlive() then return end
 				if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 				point = RandomPointInCircle(position, aoe)
 				local blizzardfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_caster_c.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(blizzardfx, 0, Vector(point.x,point.y,point.z))
				Timers:CreateTimer(0.5 , function()
					ParticleManager:DestroyParticle( blizzardfx, false )
					ParticleManager:ReleaseParticleIndex( blizzardfx )
				end)
 				EmitSoundOnLocationWithCaster(point, "hero_Crystal.preAttack", caster)
 				local blizzard = FindUnitsInRadius(caster:GetTeam(), point, nil, blizzard_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 				for _,frosttarget in pairs (blizzard) do
 					if not frosttarget:IsMagicImmune() and not IsImmuneToSlow(frosttarget) and not IsImmuneToCC(frosttarget) then 
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
 				if not caster:HasModifier("modifier_golden_wild_hunt_check") then return end
 				local leftvec = Vector(-frontVec.y, frontVec.x, 0)
				local rightvec = Vector(frontVec.y, -frontVec.x, 0)
				local random1 = RandomInt(0,350) -- position of weapon spawn
				local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

				if random2 == 0 then 
					fire_pos = flagshiporigin + leftvec*random1 + Vector(0,0,1000)
				else 
					fire_pos = flagshiporigin + rightvec*random1 + Vector(0,0,1000)
				end
 				point = RandomPointInCircle(position, aoe)
 				local newForwardVec = (point - fire_pos):Normalized()
 				local fire_distance = (point - fire_pos):Length2D()
 				local fire_duration = 1.3
 				local fireship_speed = fire_distance / fire_duration
 				local FireShipFx = ParticleManager:CreateParticle( "particles/custom/drake/drake_fireship_model.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl( FireShipFx, 0, fire_pos )
				ParticleManager:SetParticleControl( FireShipFx, 1, Vector(point.x,point.y,0) )
				ParticleManager:SetParticleControl( FireShipFx, 2, Vector(1.3,0,0) )
				Timers:CreateTimer(  fire_duration + 0.1, function()
					ParticleManager:DestroyParticle( FireShipFx, false )
					ParticleManager:ReleaseParticleIndex( FireShipFx )	
					EmitSoundOnLocationWithCaster(point, "Hero_Techies.Suicide", caster)
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
 	end)]]
end

function FireShipBurn (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local fireship_burn_dmg = ability:GetSpecialValueFor("fireship_burn_dmg")
	local dmg = fireship_burn_dmg * 0.2
	DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

drake_dance_macabre_1 = class({})
drake_dance_macabre_1_upgrade = class({})
LinkLuaModifier("modifier_dance_macabre_window", "abilities/drake/drake_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dance_macabre_tracker", "abilities/drake/drake_abilities", LUA_MODIFIER_MOTION_NONE)

function dance_macabre_wrapper(DM)
	function DM:GetCastPoint()
		return 0.1
	end

	function DM:CheckSequence()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_dance_macabre_tracker") then
			local stack = caster:GetModifierStackCount("modifier_dance_macabre_tracker", caster)

			return stack
		else
			return 0
		end	
	end

	function DM:GetCastAnimation()
		if self:CheckSequence() == 2 then
			return ACT_DOTA_ATTACK_EVENT
		elseif self:CheckSequence() == 1 then
			return ACT_DOTA_ATTACK2
		else
			return ACT_DOTA_ATTACK
		end
	end

	function DM:GetPlaybackRateOverride()
		if self:CheckSequence() == 2 then
			return 1.0
		elseif self:CheckSequence() == 1 then
			return 1.0
		else
			return 1.0
		end
	end

	function DM:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("width")
	end

	function DM:GetAbilityTextureName()
		if self:CheckSequence() == 2 then
			return "custom/drake/drake_dance_macabre_3"
		elseif self:CheckSequence() == 1 then
			return "custom/drake/drake_dance_macabre_2"
		else
			return "custom/drake/drake_dance_macabre_1"
		end
	end

	function DM:OnUpgrade()
		local caster = self:GetCaster()
		local ability = self
		local crossfire = caster:FindAbilityByName("drake_crossing_fire")
		if crossfire == nil then
			crossfire = caster:FindAbilityByName("drake_crossing_fire_upgrade")
		end
		if ability:GetLevel() == crossfire:GetLevel() then 
		else
			crossfire:SetLevel(ability:GetLevel())
		end
	end

	function DM:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local total_slash = self:GetSpecialValueFor("total_slash")
		local width = self:GetSpecialValueFor("width")
		local dmg_1 = self:GetSpecialValueFor("dmg_1")
		local dmg_2 = self:GetSpecialValueFor("dmg_2")
		local dmg_3 = self:GetSpecialValueFor("dmg_3")
		local knockback_1 = self:GetSpecialValueFor("knockback_1")
		local knockback_2 = self:GetSpecialValueFor("knockback_2")
		local knockback_3 = self:GetSpecialValueFor("knockback_3")
		local stun = self:GetSpecialValueFor("stun_3")
		local window_duration = self:GetSpecialValueFor("window_duration")
		local direction = caster:GetForwardVector()
		local dmg = 0
		local knockback = knockback_1
		local particle_blur = "particles/custom/drake/drake_dance_macabre_blur_1.vpcf"
		local particle_origin = caster:GetAbsOrigin()
		
		if self:CheckSequence() == total_slash - 1 then
			caster:SetModifierStackCount("modifier_dance_macabre_tracker", caster, 3)
			dmg = dmg_3
			knockback = knockback_3
			ability:EndCooldown()
			particle_blur = "particles/custom/drake/drake_dance_macabre_blur_3.vpcf"
			StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK_EVENT, rate=1.0})
			particle_origin = GetRotationPoint(caster:GetAbsOrigin(), 100,caster:GetAnglesAsVector().y)
			caster:EmitSound("Drake.Dance3")
			caster:RemoveModifierByName('modifier_dance_macabre_window')
		elseif self:CheckSequence() == total_slash - 2 then
			dmg = dmg_2
			knockback = knockback_2
			particle_blur = "particles/custom/drake/drake_dance_macabre_blur_2.vpcf"
			caster:EmitSound("Drake.Dance2")
			ability:EndCooldown()
			caster:SetModifierStackCount("modifier_dance_macabre_tracker", caster, 2)
			StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK2, rate=1.0})
		else
			dmg = dmg_1
			caster:EmitSound("Drake.Dance1")
			ability:EndCooldown()
			caster:AddNewModifier(caster, self, "modifier_dance_macabre_window", {Duration = window_duration})
			caster:AddNewModifier(caster, self, "modifier_dance_macabre_tracker", {Duration = window_duration})
			caster:SetModifierStackCount("modifier_dance_macabre_tracker", caster, 1)
			StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK, rate=1.0})
		end

		caster:EmitSound("Hero_Abaddon.PreAttack")

		local dash = Physics:Unit(caster)
		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(direction*400)
		caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
		caster:FollowNavMesh(false)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled" , 0.6)

		Timers:CreateTimer(0.2, function()
			if caster:IsAlive() then
				local BlurFxIndex = ParticleManager:CreateParticle( particle_blur, PATTACH_ABSORIGIN_FOLLOW, caster )
				ParticleManager:SetParticleControl( BlurFxIndex, 0, particle_origin )
				Timers:CreateTimer(0.5, function()
					ParticleManager:DestroyParticle( BlurFxIndex, false )
					ParticleManager:ReleaseParticleIndex( BlurFxIndex )
				end)
			end
		end)

		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if caster:IsAlive() then
				local caster_angle = caster:GetAnglesAsVector().y
				local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

				local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

				origin_difference_radian = origin_difference_radian * 180
				local enemy_angle = origin_difference_radian / math.pi

				enemy_angle = enemy_angle + 180.0

				local result_angle = enemy_angle - caster_angle
				result_angle = math.abs(result_angle)

				if result_angle <= 180 then
					if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and not IsKnockbackImmune(v) and not IsImmuneToCC(v) then 
						v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 0.5})
						local knock = Physics:Unit(v)
				    	v:PreventDI()
				    	v:SetPhysicsFriction(0)
						v:SetPhysicsVelocity(direction * knockback * 2)
			   			v:SetNavCollisionType(PHYSICS_NAV_HALT)

			   			Timers:CreateTimer(0.5, function()
			   				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				   				v:OnPreBounce(nil)
								v:OnPhysicsFrame(nil)
								v:SetBounceMultiplier(0)
								v:PreventDI(false)
								v:SetPhysicsVelocity(Vector(0,0,0))
								FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
							end
						end)
					end
					if self:CheckSequence() == total_slash - 1 then
						v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
					end
					DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
		end

		Timers:CreateTimer(0.5, function()
			caster:OnPreBounce(nil)
			caster:OnPhysicsFrame(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			if caster.IsPioneerOfStarAcquired then 
				if self:CheckSequence() == total_slash - 1 then
					local base_dmg = ability:GetSpecialValueFor("base_dmg")
					local agi_ratio = ability:GetSpecialValueFor("agi_ratio")
					local knock_duration = ability:GetSpecialValueFor("knock_duration")
					local whirlwind_center = GetRotationPoint(caster:GetAbsOrigin(), width,caster:GetAnglesAsVector().y)
					local whirlwind = FindUnitsInRadius(caster:GetTeam(), whirlwind_center, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
					local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
					ParticleManager:SetParticleControl( upstreamFx, 0, whirlwind_center )
					for _,knockup in pairs (whirlwind) do
						if IsValidEntity(knockup) and not knockup:IsNull() and knockup:IsAlive() then
							ApplyAirborne(caster, knockup, knock_duration)
							DoDamage(caster, knockup, base_dmg + caster:GetAgility() * agi_ratio, DAMAGE_TYPE_PURE, 0, ability, false)
						end
					end
				end
			end
		end)
	end
end

dance_macabre_wrapper(drake_dance_macabre_1_upgrade)
dance_macabre_wrapper(drake_dance_macabre_1)

modifier_dance_macabre_window = class({})	

function modifier_dance_macabre_window:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_dance_macabre_window:IsHidden()
	return false 
end

function modifier_dance_macabre_window:IsDebuff()
	return false 
end

function modifier_dance_macabre_window:RemoveOnDeath()
	return true 
end

if IsServer() then
	function modifier_dance_macabre_window:OnDestroy()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		local time = self:GetDuration() - self:GetRemainingTime()
		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()) - time)
	end
end

modifier_dance_macabre_tracker = class({})	

function modifier_dance_macabre_tracker:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_dance_macabre_tracker:IsHidden()
	return true 
end

function modifier_dance_macabre_tracker:IsDebuff()
	return false 
end

function modifier_dance_macabre_tracker:RemoveOnDeath()
	return true 
end

function OnImproveMilitaryTacticAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveMilitaryTacticAcquired) then

		hero.IsImproveMilitaryTacticAcquired = true

		if hero:HasModifier("modifier_military_tactic_check") then 
			UpgradeAttribute(hero, "drake_military_tactic_summon_cannon", "drake_military_tactic_summon_cannon_upgrade", true)
			UpgradeAttribute(hero, "drake_military_tactic_summon_boarding_ship", "drake_military_tactic_summon_boarding_ship_upgrade", true)
			UpgradeAttribute(hero, "drake_military_tactic_summon_golden_anchor", "drake_military_tactic_summon_golden_anchor_upgrade", true)
			UpgradeAttribute(hero, "drake_support_bombard", "drake_support_bombard_upgrade", false)
			if hero.IsLogBookAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_upgrade_2", "drake_military_tactic_upgrade_3", false)
				hero:FindAbilityByName("drake_military_tactic_upgrade_3"):EndCooldown()
			else
				UpgradeAttribute(hero, "drake_military_tactic", "drake_military_tactic_upgrade_1", false)
				hero:FindAbilityByName("drake_military_tactic_upgrade_1"):EndCooldown()
			end
		else
			UpgradeAttribute(hero, "drake_military_tactic_summon_cannon", "drake_military_tactic_summon_cannon_upgrade", false)
			UpgradeAttribute(hero, "drake_military_tactic_summon_boarding_ship", "drake_military_tactic_summon_boarding_ship_upgrade", false)
			UpgradeAttribute(hero, "drake_military_tactic_summon_golden_anchor", "drake_military_tactic_summon_golden_anchor_upgrade", false)
			UpgradeAttribute(hero, "drake_support_bombard", "drake_support_bombard_upgrade", true)
			if hero.IsLogBookAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_upgrade_2", "drake_military_tactic_upgrade_3", true)
				hero:FindAbilityByName("drake_military_tactic_upgrade_3"):EndCooldown()
			else
				UpgradeAttribute(hero, "drake_military_tactic", "drake_military_tactic_upgrade_1", true)
				hero:FindAbilityByName("drake_military_tactic_upgrade_1"):EndCooldown()
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnPioneerOfStarAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPioneerOfStarAcquired) then

		if hero:HasModifier("modifier_crossing_fire_buff") then 
			hero:RemoveModifierByName("modifier_crossing_fire_buff")
		end

		if hero:HasModifier("modifier_dance_macabre_1") then 
			hero:RemoveModifierByName("modifier_dance_macabre_1")
		end

		hero.IsPioneerOfStarAcquired = true

		if hero:HasModifier("modifier_military_tactic_check") then 
			UpgradeAttribute(hero, "drake_pistol", "drake_pistol_upgrade", false)
			UpgradeAttribute(hero, "drake_dance_macabre_1", "drake_dance_macabre_1_upgrade", false)
			UpgradeAttribute(hero, "drake_crossing_fire", "drake_crossing_fire_upgrade", false)
		elseif hero:HasModifier("modifier_sword_buff") then 
			UpgradeAttribute(hero, "drake_pistol", "drake_pistol_upgrade", true)
			UpgradeAttribute(hero, "drake_dance_macabre_1", "drake_dance_macabre_1_upgrade", true)
			UpgradeAttribute(hero, "drake_crossing_fire", "drake_crossing_fire_upgrade", false)
		else
			UpgradeAttribute(hero, "drake_pistol", "drake_pistol_upgrade", false)
			UpgradeAttribute(hero, "drake_dance_macabre_1", "drake_dance_macabre_1_upgrade", false)
			UpgradeAttribute(hero, "drake_crossing_fire", "drake_crossing_fire_upgrade", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnLogBookAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLogBookAcquired) then

		hero.IsLogBookAcquired = true

		if hero:HasModifier("modifier_military_tactic_check") then 
			if hero.IsImproveMilitaryTacticAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_upgrade_1", "drake_military_tactic_upgrade_3", false)
				hero:FindAbilityByName("drake_military_tactic_upgrade_3"):EndCooldown()
			else
				UpgradeAttribute(hero, "drake_military_tactic", "drake_military_tactic_upgrade_2", false)
				hero:FindAbilityByName("drake_military_tactic_upgrade_2"):EndCooldown()
			end
			if hero.IsStrengthenGoldenHindAcquired then
				hero:SwapAbilities("fate_empty5", "drake_military_tactic_summon_golden_hind_upgrade", false, true)
			else
				hero:SwapAbilities("fate_empty5", "drake_military_tactic_summon_golden_hind", false, true)
			end
		else
			if hero.IsImproveMilitaryTacticAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_upgrade_1", "drake_military_tactic_upgrade_3", true)
				hero:FindAbilityByName("drake_military_tactic_upgrade_3"):EndCooldown()
			else
				UpgradeAttribute(hero, "drake_military_tactic", "drake_military_tactic_upgrade_2", true)
				hero:FindAbilityByName("drake_military_tactic_upgrade_2"):EndCooldown()
			end
			if hero.IsStrengthenGoldenHindAcquired then
				hero:SwapAbilities("fate_empty5", "drake_military_tactic_summon_golden_hind_upgrade", false, false)
			else
				hero:SwapAbilities("fate_empty5", "drake_military_tactic_summon_golden_hind", false, false)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnStrengthenGoldenHindAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsStrengthenGoldenHindAcquired) then

		if hero:HasModifier("modifier_golden_wild_hunt_window") then 
			hero:RemoveModifierByName("modifier_golden_wild_hunt_window")
		end
		if IsValidEntity(hero.flagship) then
			if hero.flagship:HasModifier("modifier_golden_wild_hunt_window") then 
				hero.flagship:RemoveModifierByName("modifier_golden_wild_hunt_window")
			end
		end

		hero.IsStrengthenGoldenHindAcquired = true

		if hero:HasModifier("modifier_military_tactic_check") then 
			UpgradeAttribute(hero, "drake_golden_wild_hunt", "drake_golden_wild_hunt_upgrade", false)
			UpgradeAttribute(hero, "drake_combo_golden_wild_hunt", "drake_combo_golden_wild_hunt_upgrade", false)
			if hero.IsLogBookAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_summon_golden_hind", "drake_military_tactic_summon_golden_hind_upgrade", true)
			else
				UpgradeAttribute(hero, "drake_military_tactic_summon_golden_hind", "drake_military_tactic_summon_golden_hind_upgrade", false)
			end
		else
			UpgradeAttribute(hero, "drake_golden_wild_hunt", "drake_golden_wild_hunt_upgrade", true)
			UpgradeAttribute(hero, "drake_combo_golden_wild_hunt", "drake_combo_golden_wild_hunt_upgrade", false)
			if hero.IsLogBookAcquired then
				UpgradeAttribute(hero, "drake_military_tactic_summon_golden_hind", "drake_military_tactic_summon_golden_hind_upgrade", false)
			else
				UpgradeAttribute(hero, "drake_military_tactic_summon_golden_hind", "drake_military_tactic_summon_golden_hind_upgrade", false)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end