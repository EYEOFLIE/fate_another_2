
--[[function OnArrowStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_arrow = ability:GetSpecialValueFor("arrows")
	caster.ArrowStack = max_arrow
    AddArrowStack(keys, caster.ArrowStack)
	if not caster:HasModifier("modifier_priestess_arrow_progress") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_priestess_arrow_progress", {})
	end
	caster.ArrowProgress = 0
	UpdateArrowProgress(caster)
end

function OnArrowThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local max_stack = ability:GetSpecialValueFor("arrows")
	local regen_duration = caster:GetAttacksPerSecond()
	local progress = regen_duration * 0.05

    if caster:HasModifier("modifier_atalanta_tauropolos") then 
        local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
        max_stack = max_stack + tauropolos:GetSpecialValueFor("bonus_arrows")
    end

    local currentStack = caster:GetModifierStackCount("modifier_priestess_arrow_count", caster)

	if currentStack >= max_stack then
		caster.ArrowProgress = 0
        AddArrowStack(keys, max_stack)
	else
		caster.ArrowProgress = caster.ArrowProgress + progress
		if caster.ArrowProgress > 1 then
			caster.ArrowProgress = caster.ArrowProgress - 1
			AddArrowStack(keys, 1)
		end
	end

	UpdateArrowProgress(caster)
end

function OnArrowRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_arrow = ability:GetSpecialValueFor("arrows")
    caster.ArrowStack = max_arrow
	AddArrowStack(keys, max_arrow)
end

function AddArrowStack(keys, modifier)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("atalanta_priestess_of_the_hunt")
	local maxStack = ability:GetSpecialValueFor("arrows")
	if caster:HasModifier("modifier_atalanta_tauropolos") then 
		local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
		maxStack = maxStack + tauropolos:GetSpecialValueFor("bonus_arrows")
	end

	if not caster.ArrowStack then caster.ArrowStack = 0 end
	if not caster:HasModifier("modifier_priestess_arrow_buff") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_priestess_arrow_buff", {}) 
	end 

	local newStack = caster.ArrowStack + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		caster:RemoveModifierByName("modifier_priestess_arrow_buff")
	else
		caster:SetModifierStackCount("modifier_priestess_arrow_buff", caster, newStack)
	end
	caster:SetModifierStackCount("modifier_priestess_arrow_count", caster, newStack)
	caster.ArrowStack = newStack
end

function UpdateArrowProgress(caster)
	local progress = caster.ArrowProgress * 100
	caster:SetModifierStackCount("modifier_priestess_arrow_progress", caster, progress)
end

function OnArrowCheck(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local minimum_require_arrow = ability:GetSpecialValueFor("arrow_cost")
	if caster:GetModifierStackCount("modifier_priestess_arrow_count", caster) < minimum_require_arrow then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Arrows")
        return
	end
end]]

function ShootArrow(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	keys.Effect = keys.Effect or "particles/custom/atalanta/rainbow_arrow.vpcf"
    keys.Sound = keys.Sound or "Ability.Powershot.Alt"

    --[[if not keys.DontUseArrow then
        AddArrowStack(keys, -1)
    end]]

    if not keys.NoSound then
        caster:EmitSound(keys.Sound)
    end

    if not keys.NoShock then
        CreateShockRing(caster, keys.Facing)
    end

    if keys.Linear then
        ShootLinearArrow(keys)
    else
        ShootAoEArrow(keys)
    end

    if caster.IsArrowsOfTheBigDipperAcquired and keys.DontCountArrow == false then
        CheckBonusArrow(keys, true)
    end
end

function CreateShockRing(caster, facing)
    local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)
    dummy:SetOrigin(caster:GetOrigin())
    dummy:SetForwardVector(facing or caster:GetForwardVector())
    
    local particle = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6_shock_ring.vpcf"

    if caster:HasModifier("modifier_atalanta_tauropolos") then 
        particle = "particles/custom/atalanta/atalanta_shock_ring.vpcf"
    end

    local casterFX = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, dummy)
    ParticleManager:SetParticleControlEnt(casterFX, 1, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(casterFX)

    Timers:CreateTimer(3, function()
        
        dummy:RemoveSelf()
    end)
end

function ShootLinearArrow(keys)
    local projectileTable = {
        EffectName = keys.Effect,
        Ability = keys.ability,
        vSpawnOrigin = keys.Origin,
        vVelocity = keys.Facing * keys.Speed,
        fDistance = keys.Range,
        fStartRadius = keys.AoE,
        fEndRadius = keys.AoE,
        Source = keys.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bProvidesVision = false,
    }
    ProjectileManager:CreateLinearProjectile(projectileTable)
end

function ShootAoEArrow(keys)
    local caster = keys.caster
    local ability = keys.ability

    local origin
    local target
    local dummy
    local position

    if keys.Origin then
        origin = keys.Origin
    else
        origin = caster:GetOrigin()
    end

    if not keys.Target then
        dummy = CreateUnitByName("dummy_unit", keys.Position, false, caster, caster, caster:GetTeamNumber())
        dummy:SetOrigin(keys.Position)
        dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

        target = dummy
        position = keys.Position
    else
        target = keys.Target
        position = target:GetOrigin()
    end

    local displacement = position - origin
    if displacement == Vector(0, 0, 0) then
        displacement = Vector(1, 1, 0)
    end
    local velocity = displacement / keys.Delay

    local projectile = {
        Target = target,
        Ability = ability,
        EffectName = keys.Effect,
        vSourceLoc = origin,
        iMoveSpeed = velocity:Length(),
        bDrawsOnMinimap = false, 
        bVisibleToEnemies = true,
        bProvidesVision = false, 
        flExpireTime = GameRules:GetGameTime() + 10, 
        bDodgeable = false
    }

    --[[local projectile = {
        Target = target,
        Source = source,
        Ability = ability,
        EffectName = keys.Effect,
        bDodgable = false,
        bProvidesVision = false,
        iMoveSpeed = velocity:Length(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	    ExtraData = {keys.AoE or 0, keys.Slow or 0, keys.IsPhoebus or 0, keys.IsCombo or 0}
    }]]
    ProjectileManager:CreateTrackingProjectile(projectile)

    Timers:CreateTimer(keys.Delay + 0.2, function()
        if IsValidEntity(dummy) then
            dummy:RemoveSelf()
        end

    end)
end

function CheckBonusArrow(keys, bIsLine)
	local caster = keys.caster
    local ability = caster:FindAbilityByName("atalanta_arrows_of_the_big_dipper")
    local target = keys.target

    local arrowsUsed = caster:GetModifierStackCount("modifier_arrows_of_big_dipper", caster) or 0
	arrowsUsed = arrowsUsed + 1

	
	local interval = 0.1
	local bonus_arrow = ability:GetSpecialValueFor("bonus_arrow")

    if arrowsUsed >= ability:GetSpecialValueFor("require_arrow") then
        --[[local copyKeys = {}
        for k,v in pairs(keys) do
            copyKeys[k] = v
        end
        copyKeys.DontCountArrow = true 
        copyKeys.DontUseArrow = true ]]
        if bIsLine == true then 
            local copyKeys = {}
            for k,v in pairs(keys) do
                copyKeys[k] = v
            end
            copyKeys.DontCountArrow = true 
            copyKeys.DontUseArrow = true 
            for i = 1, bonus_arrow do
                Timers:CreateTimer(interval * i, function()
                    ShootArrow(copyKeys)
                end)    
            end 
        else
            for i = 1, bonus_arrow do
    			Timers:CreateTimer(interval * i, function()
    			    --ShootArrow(copyKeys)
                    caster:PerformAttack( target, true, true, true, true, true, false, false )
    		    end)
    		end	
        end

        arrowsUsed = 0
    end

	caster:SetModifierStackCount("modifier_arrows_of_big_dipper", caster, arrowsUsed)
end

function OnCalydonianPassive(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    local target = keys.target 
    AddHuntStack(caster, target, 1)
end

function AddHuntStack(caster, target, count)
    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
    
	local ability = caster:FindAbilityByName("atalanta_calydonian_hunt")
    if ability == nil then 
        ability = caster:FindAbilityByName("atalanta_calydonian_hunt_upgrade")
    end
	local max_stack = ability:GetSpecialValueFor("max_stacks")
	local root_duration = ability:GetSpecialValueFor("root_duration")
	local currentStack = target:GetModifierStackCount("modifier_atalanta_calydonian_hunt", caster) or 0 

    if IsProjectileParry(target) then return end

	if currentStack + 1 >= max_stack then
		if not target:HasModifier("modifier_atalanta_calydonian_hunt_root_cooldown") and not target:IsMagicImmune() then
			target:RemoveModifierByName("modifier_atalanta_calydonian_hunt")
            if not IsImmuneToCC(target) then
    			ability:ApplyDataDrivenModifier(caster, target, "modifier_atalanta_calydonian_hunt_root", {})
                ability:ApplyDataDrivenModifier(caster, target, "modifier_atalanta_calydonian_hunt_root_cooldown", {})
			end
            ability:ApplyDataDrivenModifier(caster, target, "modifier_atalanta_calydonian_hunt_sight", {Duration = root_duration})
        	target:EmitSound("Hero_NagaSiren.Ensnare.Cast")
        	
        end
    else
    	target:RemoveModifierByName("modifier_atalanta_calydonian_hunt")
        ability:ApplyDataDrivenModifier(caster, target, "modifier_atalanta_calydonian_hunt", {})
        target:SetModifierStackCount("modifier_atalanta_calydonian_hunt", caster, math.min(max_stack, currentStack + count))
    end
end

function ShootAirArrows(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition()
    local origin = caster:GetOrigin()
    local delay = 0.6

    EmitGlobalSound("Atalanta.PhoebusRelease")
    
    local midpoint = (origin + position) / 2
    local targetLocation = midpoint + Vector(0, 0, 1000)

    local displacement = position - origin
    if displacement == Vector(0, 0, 0) then
        displacement = Vector(1, 1, 0)
    end
    local velocity = displacement / delay

    local arrow1 = ParticleManager:CreateParticle("particles/custom/atalanta/rainbow_arrow.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(arrow1, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(arrow1, 1, targetLocation + Vector(100, 0, 0))
    ParticleManager:SetParticleControl(arrow1, 2, Vector(velocity:Length(),0,0))

    local arrow2 = ParticleManager:CreateParticle("particles/custom/atalanta/rainbow_arrow.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(arrow2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(arrow2, 1, targetLocation + Vector(-100, 0, 0))
    ParticleManager:SetParticleControl(arrow2, 2, Vector(velocity:Length(),0,0))

    Timers:CreateTimer(delay, function()
        ParticleManager:DestroyParticle(arrow1, true)
        ParticleManager:DestroyParticle(arrow2, true)
        ParticleManager:ReleaseParticleIndex(arrow1)
        ParticleManager:ReleaseParticleIndex(arrow2)
    end)

    --[[local dummy = CreateUnitByName("dummy_unit", targetLocation, false, caster, caster, caster:GetTeamNumber())
    dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy:SetOrigin(targetLocation + Vector(100, 0, 0))

    local dummy2 = CreateUnitByName("dummy_unit", targetLocation, false, caster, caster, caster:GetTeamNumber())
    dummy2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy2:SetOrigin(targetLocation + Vector(-100, 0, 0))

	caster.phoebus_dummy = dummy 
	caster.phoebus_dummy2 = dummy2 
    local arrow_1 = {
        caster = caster,
        ability = ability,
        Target = dummy,
        AoE = 0,
        Delay = 0.6,
        Effect = effect,
        Facing = facing,
        DontCountArrow = true
    }
    local arrow_2 = {
        caster = caster,
        ability = ability,
        Target = dummy2,
        AoE = 0,
        Delay = 0.6,
        Effect = effect,
        Facing = facing,
        DontCountArrow = true
    }
	ShootArrow(arrow_1)
    
    ShootArrow(arrow_2)

    Timers:CreateTimer(1.0, function()
        if IsValidEntity(dummy) then
    	   dummy:RemoveSelf()
           UTIL_Remove(dummy)
        end
        if IsValidEntity(dummy2) then
    	   dummy2:RemoveSelf()
           UTIL_Remove(dummy2)
        end
    end)]]
end

function OnCrossingArcadiaStart(keys)
	local caster = keys.caster
    local ability = keys.ability
    local position = ability:GetCursorPosition()
    local origin = caster:GetOrigin()
    local arrow_fire = ability:GetSpecialValueFor("arrow")
    local diff = position - caster:GetAbsOrigin()
    caster.crossing_direction = diff

    if (position - caster:GetAbsOrigin()):Length2D() > ability:GetSpecialValueFor("range") then
        
        local length_diff = (position - caster:GetAbsOrigin()):Length2D()

        position = position - diff:Normalized() * (length_diff - ability:GetSpecialValueFor("range"))
    end

    local retreatDist = ability:GetSpecialValueFor("leapback_range")
    local forwardVec = caster:GetForwardVector()
    --position - caster:GetAbsOrigin()
    --caster:GetForwardVector()
    local archer = Physics:Unit(caster)
    --AddArrowStack(keys, -ability:GetSpecialValueFor("arrow_cost"))

    local duration = ability:GetSpecialValueFor("jump_duration")
    --local stunDuration = self:GetSpecialValueFor("stun_duration")
    local aoe = ability:GetSpecialValueFor("aoe")
    local effect = "particles/custom/atalanta/normal_arrow.vpcf"
    local facing = caster:GetForwardVector() + Vector(0, 0, -2)
    --position - caster:GetAbsOrigin()
    --caster:GetForwardVector() + Vector(0, 0, -2)

    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(-forwardVec * retreatDist * 2 + Vector(0,0,1200))
    caster:SetPhysicsAcceleration(Vector(0,0,-3000))
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:FollowNavMesh(true)

    ProjectileManager:ProjectileDodge(caster)

    Timers:CreateTimer(duration, function()
        caster:PreventDI(false)
        caster:SetPhysicsVelocity(Vector(0,0,0))
        caster:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    end)
    StartAnimation(caster, {duration=duration, activity=ACT_DOTA_ATTACK_EVENT, rate=1.0})
    --[[rotateCounter = 1
    Timers:CreateTimer(function()
        if rotateCounter == 13 then return end
        caster:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0,30*rotateCounter,0), forwardVec))
        rotateCounter = rotateCounter + 1
        return 0.03
    end)]]
    giveUnitDataDrivenModifier(caster, caster, "jump_pause", duration)


    local offset = 0.7071 * aoe - 50
    local interval = 0.1

    if caster.CrossingArcadiaPlusAcquired then
    	interval = 0.07 
    end

    for i = 1,arrow_fire do 
    	Timers:CreateTimer(interval * i, function()
    		if not caster:IsAlive() then
                return
            end

            local arrowKeys = {
            	caster = caster,
            	ability = ability,
            	Position = position + Vector(-offset, -offset, 0),
            	Delay = 0.2,
                Effect = effect,
                Facing = facing,
                DontUseArrow = true,
                IsPhoebus = true,
                DontCountArrow = false,
            }
            if i % 3 == 1 then 
            	arrowKeys.Position = position + Vector(-offset, -offset, 0)
            elseif i % 3 == 2 then 
            	arrowKeys.Position = position + Vector(offset, -offset, 0)
            elseif i % 3 == 0 then 
            	arrowKeys.Position = position + Vector(0, aoe - 50, 0)
            end

            ShootArrow(arrowKeys)

            --[[if caster.IsArrowsOfTheBigDipperAcquired then
                local arrowsUsed = caster:GetModifierStackCount("modifier_arrows_of_big_dipper", caster) or 0
                arrowsUsed = arrowsUsed + 1
                caster:SetModifierStackCount("modifier_arrows_of_big_dipper", caster, arrowsUsed)
            end]]
        end)
    end

    Timers:CreateTimer(duration, function()
        caster:SetForwardVector(forwardVec)
        if caster.IsCrossingArcadiaPlusAcquired then
        	ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_last_spurt", {})
        end
    end)

    if caster.IsGoldenAppleAcquired and caster:FindAbilityByName("atalanta_golden_apple"):IsCooldownReady() and not caster:HasModifier("modifier_atalanta_golden_apple_cooldown") then
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_golden_apple_window", {})
    end
end

function OnCrossingArcadiaHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if target == nil then return end

    local pos = target:GetAbsOrigin()

    local atk = caster:GetAverageTrueAttackDamage(caster)

	--local damage = ability:GetSpecialValueFor("damage") / 100 
	local aoe = ability:GetSpecialValueFor("width")
    if caster.IsArrowsOfTheBigDipperAcquired then
        local celestial = caster:FindAbilityByName("atalanta_celestial_arrow_upgrade") or caster:FindAbilityByName("atalanta_celestial_arrow_red_upgrade") 
        local dmg_magic = celestial:GetSpecialValueFor("bonus_damage_per_atk") / 100
        --damage = celestial:GetSpecialValueFor("damage") / 100 
    end

	local targets = FindUnitsInRadius(caster:GetTeam(), pos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        --[[if caster.IsArrowsOfTheBigDipperAcquired then
            DoDamage(caster, v, atk, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
            DoDamage(caster, v, dmg_magic * atk, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
        else]]
        if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
            AddHuntStack(caster, v, 1)
            DoDamage(caster, v, atk, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
        end
	end

    local searching_target = FindUnitsInRadius(caster:GetTeam(), pos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    if searching_target[1] ~= nil then 
        searching_target[1]:SetOrigin(searching_target[1]:GetAbsOrigin() + (caster.crossing_direction:Normalized() * ability:GetSpecialValueFor("knock"))) 
        FindClearSpaceForUnit(searching_target[1], searching_target[1]:GetAbsOrigin(), true)
    end
end

function OnLastSpurtCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local aoe = ability:GetSpecialValueFor("last_spurt_detect")
    local bonus_ms = ability:GetSpecialValueFor("last_spurt_ms") / 100

	caster:EmitSound("Ability.Windrun")
	
	local stacks = 1
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
        if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
            --if not IsFacingUnit(v, caster, 180) then
                stacks = stacks + 1
            --end
        end
    end
    local base_ms = caster:GetBaseMoveSpeed()
    local total_ms = base_ms + (base_ms * stacks * bonus_ms)
    if total_ms > 550 then 
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_last_spurt_cap", {})
        caster:SetModifierStackCount("modifier_atalanta_last_spurt_cap", caster, total_ms)
    end
    caster:SetModifierStackCount("modifier_atalanta_last_spurt", caster, stacks)
end

function OnCelestialArrowUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsArrowsOfTheBigDipperAcquired then 
		if ability:GetAbilityName() == "atalanta_celestial_arrow_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("atalanta_celestial_arrow_red_upgrade"):GetLevel() then
				caster:FindAbilityByName("atalanta_celestial_arrow_red_upgrade"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "atalanta_celestial_arrow_red_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("atalanta_celestial_arrow_upgrade"):GetLevel() then
				caster:FindAbilityByName("atalanta_celestial_arrow_upgrade"):SetLevel(ability:GetLevel())
			end
		end
	else
		if ability:GetAbilityName() == "atalanta_celestial_arrow" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("atalanta_celestial_arrow_red"):GetLevel() then
				caster:FindAbilityByName("atalanta_celestial_arrow_red"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "atalanta_celestial_arrow_red" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("atalanta_celestial_arrow"):GetLevel() then
				caster:FindAbilityByName("atalanta_celestial_arrow"):SetLevel(ability:GetLevel())
			end
		end
	end
end

function OnCelestialArrowCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local base_cast = ability:GetSpecialValueFor("base_cast")
	if caster:HasModifier("modifier_atalanta_tauropolos") then 
		local min_cast = ability:GetSpecialValueFor("min_cast")
		local cast_reduction = ability:GetSpecialValueFor("cast_reduction") / 100 * caster:GetAgility()
		base_cast = base_cast - (base_cast * cast_reduction)
		ability:SetOverrideCastPoint(math.max(base_cast, min_cast))
	else
		ability:SetOverrideCastPoint(base_cast)
	end
end

function OnCelestialArrowToggleOn(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    ability:ApplyDataDrivenModifier(caster, caster, 'modifier_celestial_arrow_damage', {})
    caster:SetRangedProjectileName('particles/custom/atalanta/atalanta_green_arrow.vpcf')
end

function OnCelestialArrowToggleOff(keys)
    local caster = keys.caster 
    caster:RemoveModifierByName('modifier_celestial_arrow_damage')
    caster:SetRangedProjectileName('particles/custom/atalanta/normal_arrow.vpcf')
end

function OnCelestialArrowAttack(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    if ability == nil then 
        ability = caster:FindAbilityByName('atalanta_celestial_arrow_upgrade')
    end
    local target = keys.target 

    if target == nil then return end

    if ability:GetAutoCastState() == false then 
        caster:SetRangedProjectileName('particles/custom/atalanta/normal_arrow.vpcf')
        return 
    else
        caster:SetRangedProjectileName('particles/custom/atalanta/atalanta_green_arrow.vpcf')
    end

    if IsValidEntity(target) and target:IsAlive() then
        local attack_damage = keys.AttackDamage 
        local damage = ability:GetSpecialValueFor("damage")
        local mana_cost = ability:GetSpecialValueFor("mana_cost")
        if caster.IsArrowsOfTheBigDipperAcquired then 
            local bonus_damage_per_atk = ability:GetSpecialValueFor("bonus_damage_per_atk") / 100 
            damage = damage + (bonus_damage_per_atk * caster:GetAverageTrueAttackDamage(caster))
        end
        if caster:GetMana() >= mana_cost then
            caster:SpendMana(mana_cost, ability)
            DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
        end
    end
end

function OnCelestialArrowStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local aoe = ability:GetSpecialValueFor("width")
	local range = ability:GetSpecialValueFor("distance")
	local var = false
    local effect = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"

    if (ability:GetCurrentAbilityCharges() > 0) then
        ability:EndCooldown()
    else
        ability:EndCooldown()
        ability:StartCooldown(ability:GetCooldown(1))
    end

    if caster:HasModifier("modifier_atalanta_tauropolos") then        
        effect = "particles/custom/atalanta/atalanta_arrow_10stack.vpcf"
        var = true    
    end

    caster.first_hit = false

    local position = ability:GetCursorPosition()
    local origin = caster:GetAbsOrigin()
    local facing = ForwardVForPointGround(caster,position)

    local arrow_fire = {
    	caster = caster,
    	ability = ability,
    	Effect = effect,
        Origin = origin,
        Speed = 3000,
        Facing = facing,
        AoE = aoe,
	    Range = range,
	    Linear = true,
        DontUseArrow = var,
        DontCountArrow = false
    }

    ShootArrow(arrow_fire)

    --[[if caster.IsArrowsOfTheBigDipperAcquired then
        local arrowsUsed = caster:GetModifierStackCount("modifier_arrows_of_big_dipper", caster) or 0
        arrowsUsed = arrowsUsed + 1
        caster:SetModifierStackCount("modifier_arrows_of_big_dipper", caster, arrowsUsed)
    end]]
end

function OnCelestialArrowHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	--if target == nil then return end

	local damage = ability:GetSpecialValueFor("shot_damage") / 100 * caster:GetAverageTrueAttackDamage(caster)
    local bonus_damage = ability:GetSpecialValueFor("damage")

    --AddHuntStack(caster, target, 1)

	if caster.IsArrowsOfTheBigDipperAcquired then
        local bonus_damage_per_atk = ability:GetSpecialValueFor("bonus_damage_per_atk") / 100 
        bonus_damage = bonus_damage + (bonus_damage_per_atk * caster:GetAverageTrueAttackDamage(caster))
		--[[local damage_magic = ability:GetSpecialValueFor("damage") / 100 * caster:GetAverageTrueAttackDamage(caster)
		DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
		DoDamage(caster, target, damage_magic, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
	else
		DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)]]
	end
    DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
    DoDamage(caster, target, bonus_damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
    
    if target:IsRealHero() then
        if --[[caster.first_hit == false and]] not target:HasModifier("modifier_atalanta_calydonian_hunt_root_cooldown") then
    	   AddHuntStack(caster, target, 1)
           --caster.first_hit = true 
        end
    else
        AddHuntStack(caster, target, 1)
    end
end

function OnCalydonianHuntStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local sight_radius = ability:GetSpecialValueFor("sight_radius")

	caster:EmitSound("Hero_BountyHunter.Target")

	local casterFX = ParticleManager:CreateParticle("particles/econ/items/enchantress/enchantress_lodestar/ench_lodestar_death.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX, 0, caster:GetOrigin())

    Timers:CreateTimer(1, function()
        ParticleManager:ReleaseParticleIndex(casterFX)
    end)

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, sight_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _,v in pairs(targets) do
        if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
        	if v:HasModifier("modifier_atalanta_calydonian_hunt_root_cooldown") then 
        		v:RemoveModifierByName("modifier_atalanta_calydonian_hunt_root_cooldown")
        	end

            if CanBeDetected(v) then
            	ability:ApplyDataDrivenModifier(caster, v, "modifier_atalanta_calydonian_hunt_sight", {})
                v:EmitSound("Hero_BountyHunter.Target")
            else
                if not v:IsInvisible() then 
                    ability:ApplyDataDrivenModifier(caster, v, "modifier_atalanta_calydonian_hunt_sight", {})
                    v:EmitSound("Hero_BountyHunter.Target") 
                end
            end
        end
    end

    if caster.IsHuntersMarkAcquired then
    	local slow_radius = ability:GetSpecialValueFor("slow_radius")
        local slowTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, slow_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
        for _,v in pairs(slowTargets) do            
            if IsValidEntity(v) and not v:IsNull() and not IsImmuneToSlow(v) and not v:IsMagicImmune() and v:IsAlive() then
                ability:ApplyDataDrivenModifier(caster, v, "modifier_atalanta_calydonian_hunt_slow", {})
            end
        end
    end

    if caster.IsCalydonianSnipeAcquired then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_calydonian_snipe_window", {})
        local snipe = caster:FindAbilityByName("atalanta_calydonian_snipe")
        local max_stack = snipe:GetSpecialValueFor("max_stack")
        caster:SetModifierStackCount("modifier_atalanta_calydonian_snipe_window", caster, max_stack)
    end

    AtalantaCheckCombo(caster, ability)
end

function OnCalydonianHuntVisionCreate(keys)
    local caster = keys.caster 
    local target = keys.target 
    if IsValidEntity(target) and not target:IsNull() and target.crosshair == nil then
        target.crosshair = ParticleManager:CreateParticle("particles/custom/atalanta/atalanta_calydonian_boar.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(target.crosshair, 0, target:GetAbsOrigin())
    end
    --ParticleManager:SetParticleControl(target.crosshair, 1, target:GetAbsOrigin() + Vector(0,0,100))
end

function OnCalydonianHuntVisionDestroy(keys)
    local target = keys.target 
    if target.crosshair ~= nil then
        ParticleManager:DestroyParticle(target.crosshair, true)
        ParticleManager:ReleaseParticleIndex(target.crosshair)
        target.crosshair = nil
    end
end

function OnCalydonianHuntVisionThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

    if not IsValidEntity(target) or target:IsNull() then return end

    if ability == nil then 
        ability = caster:FindAbilityByName("atalanta_calydonian_hunt_upgrade")
    end
	local max_range = ability:GetSpecialValueFor("sight_limit")
	if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > max_range or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) or (not CanBeDetected(target) and target:IsInvisible()) then 
		target:RemoveModifierByName("modifier_atalanta_calydonian_hunt_sight")
		target:RemoveModifierByName("modifier_atalanta_calydonian_hunt_root")
	end
end

function OnTauropolosStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local bonus_arrows = ability:GetSpecialValueFor("bonus_arrows")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_tauropolos", {})
	--AddArrowStack(keys, bonus_arrows)
end

function OnTauropolosCreate(keys)
    local caster = keys.caster 
    if caster.IsArrowsOfTheBigDipperAcquired then 
        caster:SwapAbilities("atalanta_celestial_arrow_upgrade", "atalanta_celestial_arrow_red_upgrade", false, true)
    else
        caster:SwapAbilities("atalanta_celestial_arrow", "atalanta_celestial_arrow_red", false, true)
    end
end

function OnTauropolosDestroy(keys)
    local caster = keys.caster 
    if caster.IsArrowsOfTheBigDipperAcquired then 
        caster:SwapAbilities("atalanta_celestial_arrow_upgrade", "atalanta_celestial_arrow_red_upgrade", true, false)
    else
        caster:SwapAbilities("atalanta_celestial_arrow", "atalanta_celestial_arrow_red", true, false)
    end
end

function OnTauropolosDeath(keys)
    local caster = keys.caster 
    caster:RemoveModifierByName("modifier_atalanta_tauropolos")
end

function OnPhoebusCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 

    --[[if caster:HasModifier('modifier_phoebus_checker') then 
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
        return 
    end]]

	if not IsInSameRealm(caster:GetAbsOrigin(), ability:GetCursorPosition()) then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return 
	end

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    if #enemies == 0 then 
        caster:EmitSound("Atalanta.PhoebusCast")  
    else
        EmitGlobalSound("Atalanta.PhoebusCast")
    end
    
    local casterFX = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/death/mk_spring_arcana_death_ground_impact.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX, 0, caster:GetOrigin())
    
    local casterFX2 = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_land_force_impact_rings_gold.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX2, 0, caster:GetOrigin())
    
    local casterFX3 = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_land_force_impact_d_gold.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX3, 0, caster:GetOrigin())
    
    Timers:CreateTimer(1, function()
        ParticleManager:ReleaseParticleIndex(casterFX)
        ParticleManager:ReleaseParticleIndex(casterFX2)
        ParticleManager:ReleaseParticleIndex(casterFX3)
    end)
end

function OnPheobusStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition()
	local origin = caster:GetOrigin()
    local aoe = ability:GetSpecialValueFor("aoe")
    local arrows = ability:GetSpecialValueFor("arrows")
    local delay = ability:GetSpecialValueFor("delay")
    local shock_dps = ability:GetSpecialValueFor("shock_dps")
    local fixDuration = 4
    local interval = fixDuration / arrows
    --caster.phoebus_damage_stack = caster.ArrowStack
    --AddArrowStack(keys, -caster.ArrowStack)

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_phoebus_checker", {Duration= fixDuration + delay})

    AddFOWViewer(caster:GetTeamNumber(), position, aoe, 3 + fixDuration, false)
	ShootAirArrows(keys)

	local barrageMarker = ParticleManager:CreateParticleForTeam("particles/custom/atalanta/atalanta_barrage_marker.vpcf", PATTACH_CUSTOMORIGIN, nil, caster:GetTeamNumber())
    ParticleManager:SetParticleControl( barrageMarker, 0, position)
    --ParticleManager:SetParticleControl( caster.barrageMarker, 1, Vector(0,0,300))
    Timers:CreateTimer( 3, function()
        ParticleManager:DestroyParticle( barrageMarker, false )
        ParticleManager:ReleaseParticleIndex( barrageMarker )
    end)

    Timers:CreateTimer(delay-0.4, function()

    	local midpoint = (origin + position) / 2
        local sourceLocation = midpoint + Vector(0, 0, 1000)

        local arrowAoE = ability:GetSpecialValueFor("arrow_aoe")

        for i=1,arrows do
            Timers:CreateTimer(0.2 + interval * i, function()
                local point = RandomPointInCircle(position, aoe)
                EmitGlobalSound("Ability.Powershot.Alt")
                local aoearrow = {
                    caster = caster,
                    ability = ability,
                    Origin = sourceLocation,
                    Position = point,
                    AoE = arrowAoE,
                    Delay = 0.2,
                    DontUseArrow = true,
                    NoShock = true,
                    DontCountArrow = true,
                    IsPhoebus = true,
                }
                ShootArrow(aoearrow)
                local enemies = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
                for k,v in pairs (enemies) do 
                    if not IsImmuneToSlow(v) then 
                        ability:ApplyDataDrivenModifier(caster, v, "modifier_phoebus_slow", {})
                    end
                    DoDamage(caster, v, shock_dps * interval, DAMAGE_TYPE_MAGICAL, 0, ability, false)
                end 
            end)
        end
    end)
end

function OnPhoebusHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if target == nil then return end
	--if target == caster.phoebus_dummy or target == caster.phoebus_dummy2 then return end

    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

    local damage = ability:GetSpecialValueFor("arrows_damage")
    local aoe = ability:GetSpecialValueFor("arrow_aoe")

    if caster.IsHuntersMarkAcquired then
        local bonus_damage = ability:GetSpecialValueFor("bonus_damage_per_atk") / 100 * caster:GetAverageTrueAttackDamage(caster)
        damage = damage + bonus_damage
    end

    local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
            if not IsImmuneToSlow(v) then 
                ability:ApplyDataDrivenModifier(caster, v, "modifier_phoebus_slow", {})
            end
            AddHuntStack(caster, v, 1)
    		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
        end
	end
end

function OnGoldenAppleWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsCrossingArcadiaPlusAcquired then 
		caster:SwapAbilities("atalanta_golden_apple", "atalanta_crossing_arcadia_upgrade", true, false)
	else
		caster:SwapAbilities("atalanta_golden_apple", "atalanta_crossing_arcadia", true, false)
	end
end

function OnGoldenAppleWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsCrossingArcadiaPlusAcquired then 
		caster:SwapAbilities("atalanta_golden_apple", "atalanta_crossing_arcadia_upgrade", false, true)
	else
		caster:SwapAbilities("atalanta_golden_apple", "atalanta_crossing_arcadia", false, true)
	end
end

function OnGoldenAppleWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_atalanta_golden_apple_window")
end

function OnGoldenAppleStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition() 
	local origin = caster:GetOrigin()
    local forwardVector = caster:GetForwardVector()
    local duration = ability:GetSpecialValueFor("lure_duration")
    local aoe = ability:GetSpecialValueFor("aoe")
    local speed = 1500
    local delay = math.max(0.1, (position - origin):Length() / speed)

    caster:RemoveModifierByName("modifier_atalanta_golden_apple_window")
    local goldenapple = {
        caster = caster,
        ability = ability,
        Position = position,
        AoE = 0,
        Delay = delay,
        Effect = "particles/units/heroes/hero_furion/furion_base_attack.vpcf",
        NoSound = true,
        DontUseArrow = true,
        DontCountArrow = true
    }
    ShootArrow(goldenapple)

    local forcemove = {
        UnitIndex = nil,
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
        Position = nil
    }

    local dummy = CreateUnitByName("visible_dummy_unit", position, false, caster, caster, caster:GetTeamNumber())
    dummy:SetOrigin(position)
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)

    dummy:EmitSound("Atalanta.GoldenApple")
	
    AddFOWViewer(caster:GetTeamNumber(), position, aoe, duration, false)

    local appleFX
    local appleFX2
    local appleFX3
    local totalTime = 0
    Timers:CreateTimer(delay, function()
        appleFX = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_natures_attendants_lvl4.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControlEnt(appleFX, 3, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 4, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 5, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 6, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 7, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 8, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 9, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 10, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 11, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)

        appleFX2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_teleport_model_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControlEnt(appleFX2, 3, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)

        appleFX3 = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControl(appleFX3, 1, Vector(aoe, 0, 0))

       	Timers:CreateTimer(function()
	   	totalTime = totalTime + 0.1

           	local targets = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe,
               	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
               	FIND_ANY_ORDER, false) 
           	for k,v in pairs(targets) do
                if IsValidEntity(v) and not v:IsNull() then
                   	forcemove.UnitIndex = v:entindex()
                   	forcemove.Position = position
                   	v:Stop()
                   	ExecuteOrderFromTable(forcemove) 
               	end
            end

           	if totalTime >= duration then
               	return
           	end
           	return 0.1
        end)
    end)

    Timers:CreateTimer(delay + duration, function()
        ParticleManager:ReleaseParticleIndex(appleFX2)
        ParticleManager:DestroyParticle(appleFX3, true)
        ParticleManager:ReleaseParticleIndex(appleFX3)
    end)

    Timers:CreateTimer(delay + duration + 2, function()
        ParticleManager:ReleaseParticleIndex(appleFX)
	    dummy:StopSound("Atalanta.GoldenApple")
        if IsValidEntity(dummy) then
            dummy:RemoveSelf()
        end
    end)

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_golden_apple_cooldown", {Duration = ability:GetCooldown(1)})
end

function OnCalydonianSnipeWindowCreate(keys)
	local caster = keys.caster 
    local ply = caster:GetPlayerOwner()
    if ply == nil then 
        ply = PlayerResource:GetPlayer(caster:GetPlayerOwnerID())
    end
	caster:SwapAbilities("atalanta_calydonian_snipe", caster:GetAbilityByIndex(4):GetAbilityName(), true, false)

    if not string.match(GetMapName(),"fate_elim") then return end

    --Convars:SetInt("dota_camera_distance", 1600)
    local count_tick = 0
    local max_tick = 10
    caster.base_camera = Convars:GetInt("dota_camera_distance") or 1900
    caster.bonus_camera = 100
    caster.current_camera = Convars:GetInt("dota_camera_distance") or 1900

    if caster.CameraTimerDown ~= nil then 
        Timers:RemoveTimer(caster.CameraTimerDown)
        caster.CameraTimerDown = nil
    end
    if caster:IsAlive() then 
        caster.CameraTimerUp = Timers:CreateTimer(function()
            if not caster:IsAlive() then 
                CustomGameEventManager:Send_ServerToPlayer( ply, "cam_distance", {camera= caster.base_camera} )
                return nil 
            end
            if count_tick == max_tick then 
                return nil 
            end
            caster.current_camera = math.min(caster.current_camera + caster.bonus_camera, 1900 + (max_tick * caster.bonus_camera))
            CustomGameEventManager:Send_ServerToPlayer( ply, "cam_distance", {camera= caster.current_camera} )
            count_tick = count_tick + 1
            return 0.033
        end)
    end
end

function OnCalydonianSnipeWindowDestroy(keys)
	local caster = keys.caster 
    local ply = caster:GetPlayerOwner()
    if ply == nil then 
        ply = PlayerResource:GetPlayer(caster:GetPlayerOwnerID())
    end
	caster:SwapAbilities("atalanta_calydonian_snipe", "fate_empty1", false, true)

    if not string.match(GetMapName(),"fate_elim") then return end

    if caster.CameraTimerUp ~= nil then 
        Timers:RemoveTimer(caster.CameraTimerUp)
        caster.CameraTimerUp = nil
    end

    local count_tick = 0
    local max_tick = 10
    if caster:IsAlive() then 
        caster.CameraTimerDown = Timers:CreateTimer(function()
            if not caster:IsAlive() then 
                CustomGameEventManager:Send_ServerToPlayer( ply, "cam_distance", {camera= caster.base_camera} )
                return nil 
            end
            if count_tick == 10 then 
                return nil 
            end
            caster.current_camera = math.max(caster.current_camera - caster.bonus_camera, 1900)
            CustomGameEventManager:Send_ServerToPlayer( ply, "cam_distance", {camera= caster.current_camera} )
            count_tick = count_tick + 1
            return 0.033
        end)
    else
        CustomGameEventManager:Send_ServerToPlayer( ply, "cam_distance", {camera= caster.base_camera} )
    end
end

function OnCalydonianSnipeWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_atalanta_calydonian_snipe_window")
end

function OnCalydonianSnipeCheck(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    local target = keys.target 
    local charge_delay = ability:GetCastPoint()
    if not target:HasModifier("modifier_atalanta_calydonian_hunt_sight") then 
        caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
        return 
    end
end

function OnCalydonianSnipeCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
    ability.target = target
    --local charge_delay = ability:GetCastPoint()
    local ply = caster:GetPlayerOwner()
    local playerId = caster:GetPlayerOwnerID()
    ability:EndCooldown()
    caster:GiveMana(ability:GetManaCost(1))
	--[[if not target:HasModifier("modifier_atalanta_calydonian_hunt_sight") then 
		caster:Interrupt() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return 
	end]]
    caster.BPparticle = ParticleManager:CreateParticleForTeam("particles/custom/atalanta/atalanta_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

    ParticleManager:SetParticleControl( caster.BPparticle, 0, target:GetAbsOrigin() + Vector(0,0,500)) 
    ParticleManager:SetParticleControl( caster.BPparticle, 1, target:GetAbsOrigin() + Vector(0,0,500)) 

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_calydonian_snipe_tracker", {Duration = ability:GetSpecialValueFor("cast_delay") - 0.04})

    caster.ChargeParticle = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_powershot_channel_combo_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.ChargeParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(caster.ChargeParticle, 1, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 350, caster:GetAnglesAsVector().y)) 
    caster:EmitSound("Ability.PowershotPull.Lyralei")	
    --[[Timers:CreateTimer(charge_delay, function()
        ParticleManager:DestroyParticle(ChargeParticle, true)
        ParticleManager:ReleaseParticleIndex( ChargeParticle )
    end)]]

    if target:IsHero() and PlayerResource:GetConnectionState(playerId) == 2 then
        Say(ply, "Calydonian Snipe targets " .. FindName(target:GetName()) .. ".", true)
    end
end

function OnCalydonianSnipeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = ability.target
	local arrow_cost = ability:GetSpecialValueFor("arrow_cost")
	local speed = ability:GetSpecialValueFor("speed")
    local ply = caster:GetPlayerOwner()
    local playerId = caster:GetPlayerOwnerID()

    if caster:HasModifier("modifier_calydonian_snipe_tracker") then 
        OnCalydonianSnipeInterrupted(keys)
        return nil 
    end
	caster:StopSound("Ability.PowershotPull.Lyralei")
	caster:EmitSound("Ability.Powershot.Alt")
	--AddArrowStack(keys, -arrow_cost)

    ParticleManager:DestroyParticle(caster.BPparticle, true)
    ParticleManager:DestroyParticle(caster.ChargeParticle, true)
    ParticleManager:ReleaseParticleIndex( caster.ChargeParticle )
    ParticleManager:ReleaseParticleIndex( caster.BPparticle )
    
    if not caster:CanEntityBeSeenByMyTeam(target) or caster:GetMana() < ability:GetManaCost(1) or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
        Say(ply, "Calydonian Snipe failed.", true)
        return 
    end

    ability:StartCooldown(ability:GetCooldown(1))
    caster:SetMana(caster:GetMana() - ability:GetManaCost(1))

	local currentStack = caster:GetModifierStackCount("modifier_atalanta_calydonian_snipe_window", caster)
	if currentStack - 1 >= 1 then 
		caster:SetModifierStackCount("modifier_atalanta_calydonian_snipe_window", caster, currentStack - 1)
	else
		caster:RemoveModifierByName("modifier_atalanta_calydonian_snipe_window")
	end
    local arrow_loc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_bow"))
	local projectile = {
    	Target = target,
		--Source = caster,
		Ability = ability,	
        EffectName = "particles/custom/atalanta/rainbow_arrow.vpcf",
        iMoveSpeed = speed,
		vSourceLoc= arrow_loc,
        --iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
        bDodgeable = true,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = GameRules:GetGameTime() + 7,
		bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(projectile)

    if target:IsHero() and PlayerResource:GetConnectionState(playerId) == 2 then
        Say(ply, "Calydonian Snipe at " .. FindName(target:GetName()) .. ".", true)
    end
end

function OnCalydonianSnipeInterrupted(keys)
    local caster = keys.caster
    local target = keys.target
    local ply = caster:GetPlayerOwner()
    ParticleManager:DestroyParticle(caster.BPparticle, true)
    ParticleManager:DestroyParticle(caster.ChargeParticle, true)
    ParticleManager:ReleaseParticleIndex( caster.ChargeParticle )
    ParticleManager:ReleaseParticleIndex( caster.BPparticle )
    Say(ply, "Calydonian Snipe failed.", true)
end

function OnCalydonianSnipeHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end
    local base_damage = ability:GetSpecialValueFor("base_damage")
	local bonus_damage = ability:GetSpecialValueFor("damage") / 100 * caster:GetAverageTrueAttackDamage(caster) 

    if IsSpellBlocked(target) then return end

	target:EmitSound("Hero_Enchantress.ImpetusDamage")
    AddHuntStack(caster, target, 1)
	DoDamage(caster, target, base_damage + bonus_damage, DAMAGE_TYPE_PHYSICAL, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, ability, false)
	
end

function AtalantaCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if string.match(ability:GetAbilityName(), "atalanta_calydonian_hunt") and caster:FindAbilityByName("atalanta_phoebus_catastrophe_snipe"):IsCooldownReady() and not caster:HasModifier("modifier_atalanta_phoebus_snipe_cooldown") then 
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_phoebus_snipe_window", {})
		end
	end
end

function OnPheobusSnipeWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsHuntersMarkAcquired then
		caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt_upgrade", true, false)
	else
		caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt", true, false)
	end
end

function OnPheobusSnipeWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsHuntersMarkAcquired then
		caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt_upgrade", false, true)
	else
		caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_calydonian_hunt", false, true)
	end
end

function OnPheobusSnipeWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_atalanta_phoebus_snipe_window")
end

function OnPhoebusSnipeCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	if not IsInSameRealm(target:GetOrigin(), caster:GetOrigin()) then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return 
	end
    EmitGlobalSound("Atalanta.PreCombo")
end

function OnPhoebusSnipeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target

	local position = target:GetOrigin()
    local origin = caster:GetOrigin()
    local arrows = ability:GetSpecialValueFor("arrows")
    local delay = ability:GetSpecialValueFor("delay")

    local targetTime = delay + 0.2 + 0.1 * arrows

    -- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("atalanta_phoebus_catastrophe_snipe")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_atalanta_phoebus_snipe_cooldown", {Duration = ability:GetCooldown(1)})
	caster:RemoveModifierByName("modifier_atalanta_phoebus_snipe_window")

    SpawnAttachedVisionDummy(caster, target, 400, targetTime, false)

    ShootAirArrows(keys)

    caster.snipeParticle = ParticleManager:CreateParticleForTeam("particles/custom/atalanta/atalanta_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

    ParticleManager:SetParticleControl( caster.snipeParticle, 0, target:GetAbsOrigin() + Vector(0,0,100)) 
    ParticleManager:SetParticleControl( caster.snipeParticle, 1, target:GetAbsOrigin() + Vector(0,0,100)) 

    Timers:CreateTimer(delay, function()
        local screenFx = ParticleManager:CreateParticle("particles/custom/screen_green_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

        local midpoint = (origin + position) / 2
        local sourceLocation = midpoint + Vector(0, 0, 1000)

        local arrowAoE = ability:GetSpecialValueFor("arrow_aoe")
        local psarrow = 0

        local combo_snipe = {
            caster = caster,
            ability = ability,
            Origin = sourceLocation+RandomVector(200),
            Target = nil,
            Position = nil,
            AoE = arrowAoE,
            Delay = 0.2,
            Effect = effect,
            DontUseArrow = true,
            NoShock = true,
            DontCountArrow = true,
            IsPhoebus = true,
            IsCombo = true
        }

        Timers:CreateTimer("phoebus_snipe" .. caster:GetPlayerOwnerID(), {
            endTime = 0.1,
            callback = function()
            if psarrow == arrows then return nil end 

            local sameRealm = IsInSameRealm(target:GetOrigin(), position)
            EmitGlobalSound("Ability.Powershot.Alt")

            combo_snipe.Target = sameRealm and target or nil
            combo_snipe.Position = (not sameRealm) and position or nil

            ShootArrow(combo_snipe)

            psarrow = psarrow + 1
            return 0.1
        end})

        --[[for i=1,arrows do
            Timers:CreateTimer(0.1 + 0.1 * i, function()
                local sameRealm = IsInSameRealm(target:GetOrigin(), position)
                EmitGlobalSound("Ability.Powershot.Alt")
                local combo_snipe = {
                    caster = caster,
                    ability = ability,
                    Origin = sourceLocation+RandomVector(200),
                    Target = sameRealm and target or nil,
                    Position = (not sameRealm) and position or nil,
                    AoE = arrowAoE,
                    Delay = 0.2,
                    Effect = effect,
                    DontUseArrow = true,
                    NoShock = true,
                    DontCountArrow = true,
                    IsPhoebus = true,
                    IsCombo = true
                }
                ShootArrow(combo_snipe)
            end)
        end]]

        Timers:CreateTimer(0.2 + (0.1 * arrows), function()
            ParticleManager:DestroyParticle(screenFx, false)
            ParticleManager:DestroyParticle(caster.snipeParticle, true)
            --[[if IsValidEntity(dummy) then
                dummy:RemoveSelf()
            end]]
        end)
    end)
end

function OnPhoebusSnipeHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end
	--[[if target == caster.phoebus_dummy or target == caster.phoebus_dummy2 then
        if IsValidEntity(caster.phoebus_dummy) then
            caster.phoebus_dummy:RemoveSelf() 
        end
        if IsValidEntity(caster.phoebus_dummy2) then
            caster.phoebus_dummy2:RemoveSelf()
        end
		return 
	end]]

    local damage = ability:GetSpecialValueFor("damage") / 100 * caster:GetAverageTrueAttackDamage(caster)
    local aoe = ability:GetSpecialValueFor("arrow_aoe")

    local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
    		AddHuntStack(caster, v, 1)
    		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
    	end
    end
end

function OnArrowsOfTheBigDipperAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsArrowsOfTheBigDipperAcquired) then

    	hero.IsArrowsOfTheBigDipperAcquired = true 

    	hero:FindAbilityByName("atalanta_arrows_of_the_big_dipper"):SetLevel(1)

        UpgradeAttribute(hero, "atalanta_celestial_arrow", "atalanta_celestial_arrow_upgrade", true)

    	NonResetAbility(hero)

    	-- Set master 1's mana 
    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end

function OnHuntersMarkAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHuntersMarkAcquired) then

    	if hero:HasModifier("modifier_atalanta_phoebus_snipe_window") then 
    		hero:RemoveModifierByName("modifier_atalanta_phoebus_snipe_window")
    	end

    	hero.IsHuntersMarkAcquired = true 

        UpgradeAttribute(hero, "atalanta_calydonian_hunt", "atalanta_calydonian_hunt_upgrade", true)
        UpgradeAttribute(hero, "atalanta_phoebus_catastrophe_barrage", "atalanta_phoebus_catastrophe_barrage_upgrade", true)

    	NonResetAbility(hero)

    	-- Set master 1's mana 
    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end

function OnGoldenAppleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGoldenAppleAcquired) then

    	hero.IsGoldenAppleAcquired = true 

    	NonResetAbility(hero)

    	-- Set master 1's mana 
    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end

function OnCrossingArcadiaPlusAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCrossingArcadiaPlusAcquired) then

    	--[[if hero:HasModifier("modifier_atalanta_golden_apple_window") then 
    		hero:RemoveModifierByName("modifier_atalanta_golden_apple_window")
    	end]]

    	hero.IsCrossingArcadiaPlusAcquired = true 

        hero.IsGoldenAppleAcquired = true 

        UpgradeAttribute(hero, "atalanta_crossing_arcadia", "atalanta_crossing_arcadia_upgrade", true)

    	NonResetAbility(hero)

    	-- Set master 1's mana 
    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end

function OnCalydonianSnipeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCalydonianSnipeAcquired) then

    	hero.IsCalydonianSnipeAcquired = true 

    	NonResetAbility(hero)

    	-- Set master 1's mana 
    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end