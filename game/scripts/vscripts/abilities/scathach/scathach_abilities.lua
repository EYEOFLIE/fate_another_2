vectorA = Vector(0,0,0)

function OnRuneMagicStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	
	if caster:HasModifier("modifier_scathach_rune_mage_check") then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_rune_mage_check", {})
	caster.IsMagicUse = false
	ability:EndCooldown()
end

function OnRuneMagicUpgrade (keys)
	local caster = keys.caster 
	if caster.IsPrimevalRuneAcquired then
		caster:FindAbilityByName("scathach_rune_fire_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_frost_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_blast_upgrade"):SetLevel(keys.ability:GetLevel())
		--caster:FindAbilityByName("scathach_rune_teleport_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_heal_upgrade"):SetLevel(keys.ability:GetLevel())
	else
		caster:FindAbilityByName("scathach_rune_fire"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_frost"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_blast"):SetLevel(keys.ability:GetLevel())
		--caster:FindAbilityByName("scathach_rune_teleport"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("scathach_rune_heal"):SetLevel(keys.ability:GetLevel())
	end
end

function OnRuneMagicOpen (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local delay = 0

	if caster:HasModifier("modifier_gate_of_sky_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_gate_of_sky_window")
	end
	if caster:HasModifier("modifier_gae_combo_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_gae_combo_window")
	end

	Timers:CreateTimer(delay, function()
		if caster.IsPrimevalRuneAcquired then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "scathach_rune_fire_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "scathach_rune_frost_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "scathach_rune_blast_upgrade", false, true)		
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "scathach_rune_heal_upgrade", false, true)
		else	
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "scathach_rune_fire", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "scathach_rune_frost", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "scathach_rune_blast", false, true)		
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "scathach_rune_heal", false, true)
		end
		if caster.IsWisdomOfHauntGroundAcquired then
			caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "scathach_rune_of_protection", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "fate_empty2", false, true)
		end
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "scathach_rune_close", false, true)
	end)
end

function OnRuneMagicClose (keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName(caster.FSkill)

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)

	if caster.IsMagicUse == true and not caster.IsPrimevalRuneAcquired then
		ability:StartCooldown(ability:GetCooldown(1))
	end
end

function OnRuneMagicCloseStart (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
end

function OnRuneFlameStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_fire_check", {})
	caster.IsMagicUse = true
	caster:EmitSound("Scathach.Rune_Fire")
	if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
	Timers:CreateTimer(cast_delay, function()
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Shredder.ControlledBurn.Layer", caster)
		local FirePillarFx = ParticleManager:CreateParticle("particles/custom/tamamo/combo/fire_explosion_column.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(FirePillarFx, 0, target_loc)
		Timers:CreateTimer( 0.8, function()
			ParticleManager:DestroyParticle( FirePillarFx, false )
		end)
	end)
	for i = 0,5 do
		Timers:CreateTimer(cast_delay * i, function()
			if not caster:IsAlive() then return end 
			if not caster:HasModifier("modifier_scathach_fire_check") then return end
			local flametargets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,flame in pairs (flametargets) do
				if IsValidEntity(flame) and not flame:IsNull() and not flame:IsMagicImmune() and not flame:HasModifier("modifier_scathach_fire_burn") then 
					ability:ApplyDataDrivenModifier(caster, flame, "modifier_scathach_fire_burn", {})
				end
			end
		end)
	end
end

function OnRuneFlameCreate (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	target:EmitSound("Hero_Huskar.Burning_Spear")
end

function OnRuneFlameDestroy (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	target:StopSound("Hero_Huskar.Burning_Spear")
end

function OnRuneFlameBurn (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local burn_dps = ability:GetSpecialValueFor("burn_dps")

	if target:IsAlive() then
		if not target:IsMagicImmune() then 
			DoDamage(caster, target, burn_dps * 0.2 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end
end

function OnRuneFrostStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local range = ability:GetSpecialValueFor("range")
	local dmg = ability:GetSpecialValueFor("dmg")
	local duration = ability:GetSpecialValueFor("duration")
	local origin = caster:GetAbsOrigin()
	caster.IsMagicUse = true
	local frostground = ParticleManager:CreateParticle("particles/custom/scathach/scathach_frost.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(frostground, 0, caster:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(frostground, 1, Vector(range,1,1))
	caster:EmitSound("hero_Crystal.freezingField.wind")
	caster:EmitSound("Scathach.Rune_Frost")
	Timers:CreateTimer( duration, function()
		ParticleManager:DestroyParticle( frostground, false )
		ParticleManager:ReleaseParticleIndex(frostground)
		caster:StopSound("hero_Crystal.freezingField.wind")
	end)
	local freezetargets = FindUnitsInRadius(caster:GetTeam(), origin, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,freeze in pairs (freezetargets) do
		if IsValidEntity(freeze) and not freeze:IsNull() and not freeze:IsMagicImmune() and not IsImmuneToCC(freeze) then 
			ability:ApplyDataDrivenModifier(caster, freeze, "modifier_scathach_freeze", {})
			freeze:EmitSound("hero_Crystal.frostbite")		
		end
		DoDamage(caster, freeze, dmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
	if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
end

function OnRuneFrostCreate (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
end

function OnRuneFrostDestroy (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	target:StopSound("hero_Crystal.frostbite")
end

function OnRuneFrostFreeze (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local freeze_dps = ability:GetSpecialValueFor("freeze_dps")
	local freeze_mana_drain = ability:GetSpecialValueFor("freeze_mana_drain")

	if target:IsAlive() then
		if not target:IsMagicImmune() then 
			target:SetMana(target:GetMana() - freeze_mana_drain * 0.1)
			DoDamage(caster, target, freeze_dps * 0.1 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
			
		end
	end
end

function OnBlastStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local distance = ability:GetSpecialValueFor("distance")
	local speed = ability:GetSpecialValueFor("speed")
	local width = 130 
	local origin = caster:GetAbsOrigin()
	local forwardVec = (target_loc - origin):Normalized() 
	local rightVec = caster:GetRightVector()
	local leftVec = -rightVec
	local backVec = -forwardVec
	local origin_1 = origin + (backVec * 100)
	local origin_2 = origin_1 + (leftVec * 100)
	local origin_3 = origin_1 + (leftVec * 200)
	local origin_4 = origin_1 + (rightVec * 100)
	local origin_5 = origin_1 + (rightVec * 200)
	caster:EmitSound("Scathach.Rune_Blast")
	caster:EmitSound("Hero_Mirana.ArrowCast")
	BlastFire (caster,ability,speed,distance,origin_1,forwardVec,width)
	BlastFire (caster,ability,speed,distance,origin_2,forwardVec,width)
	BlastFire (caster,ability,speed,distance,origin_3,forwardVec,width)
	BlastFire (caster,ability,speed,distance,origin_4,forwardVec,width)
	BlastFire (caster,ability,speed,distance,origin_5,forwardVec,width)
	caster.IsMagicUse = true
	if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
end

function BlastFire (caster,ability,speed,distance,origin,forwardVec,width)

	local duration = distance / speed

	local blast_dummy = CreateUnitByName("dummy_unit", origin, false, caster, caster, caster:GetTeamNumber())
	blast_dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	blast_dummy:SetForwardVector(forwardVec)	

	local blastfx = ParticleManager:CreateParticle( "particles/custom/scathach/scathach_blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, blast_dummy )
	ParticleManager:SetParticleControl( blastfx, 4, forwardVec * speed)

	Timers:CreateTimer(function()
		if IsValidEntity(blast_dummy) then
			origin = GetGroundPosition(origin + (speed * 0.05) * Vector(forwardVec.x, forwardVec.y, 0), nil)								
			blast_dummy:SetAbsOrigin(origin)
			return 0.05
		else
			return nil
		end
	end)
			
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle( blastfx, false )
		ParticleManager:ReleaseParticleIndex( blastfx )
		Timers:CreateTimer(0.05, function()
			if IsValidEntity(blast_dummy) then
				blast_dummy:RemoveSelf()
			end
			return nil
		end)
		return nil
	end)

	local blast = {
		Ability = ability,
		--EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow_launch.vpcf",
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
		fExpireTime = GameRules:GetGameTime() + 1,
		bDeleteOnHit = false,
		vVelocity = forwardVec * speed,
		
	}

    local projectile = ProjectileManager:CreateLinearProjectile(blast)
end

function OnBlastHit (keys)
	if keys.target == nil then return end
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local stun = ability:GetSpecialValueFor("stun")
	local dmg = ability:GetSpecialValueFor("dmg")
	if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun})
	end
	DoDamage(caster, target, dmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnTeleportCast (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local range = ability:GetSpecialValueFor("range")
	if IsLocked(caster) or caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") then
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end
end

function OnTeleportStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local range = ability:GetSpecialValueFor("range")
	if IsLocked(caster) or caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") then
		ability:EndCooldown() 
		caster:GiveMana(100) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end
    caster.IsMagicUse = true
    if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
	OnTeleportBlink (caster, target_loc, range)
	
end

function OnTeleportBlink (hCaster, vTarget, fMaxDistance, tParams)

    local tParams = tParams or {}
    local sOutEffect = tParams.sInEffect or "particles/items_fx/blink_dagger_start.vpcf"
    local sInEffect = tParams.sOutEffect or "particles/items_fx/blink_dagger_end.vpcf"
    local sOutSound = tParams.sOutSound or "Hero_Antimage.Blink_out"
    local sInSound = tParams.sInSound or "Hero_Antimage.Blink_in"
    
    local bDodge = true
    if tParams.bDodgeProjectiles ~= nil then bDodge = tParams.bDodgeProjectiles end
    
    local bNavCheck = true
    if tParams.bNavCheck ~= nil then bNavCheck = tParams.bNavCheck end

    local vPos = hCaster:GetAbsOrigin()
    local vDifference = vTarget - vPos
    
    local vDirection = vDifference:Normalized()
    local fDistance = vDifference:Length()
    if fDistance >= fMaxDistance then fDistance = fMaxDistance end
    local vBlinkPos = vPos + (vDirection * fDistance)
    
    if bNavCheck then
		local i = 0
        local iStep = 10
        local iSteps = math.ceil(fDistance / iStep)

        while GridNav:IsBlocked( vBlinkPos ) or not GridNav:IsTraversable( vBlinkPos )do
            i = i + 1
            vBlinkPos = vPos + (vDirection * (fDistance - i * iStep))
            if i >= iSteps then break end
        end
    end
    local pcBlinkOut = ParticleManager:CreateParticle(sOutEffect, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pcBlinkOut, 0, hCaster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pcBlinkOut)
    hCaster:EmitSound(sOutSound)

    ProjectileManager:ProjectileDodge(hCaster)
    FindClearSpaceForUnit(hCaster, vBlinkPos, true)

    local pcBlinkIn = ParticleManager:CreateParticle(sInEffect, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pcBlinkIn, 0, hCaster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pcBlinkIn)
    hCaster:EmitSound(sInSound)
end

function OnHealStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local heal_amount = ability:GetSpecialValueFor("heal_amount")
	target:FateHeal(heal_amount, caster, true)
	if caster.IsPrimevalRuneAcquired then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_scathach_rune_heal_buff", {})
	end
	caster.IsMagicUse = true
	if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
end

function OnHealBuffCreate (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	caster.healbuff = ParticleManager:CreateParticle("particles/items_fx/healing_clarity.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(caster.healbuff, 0, target:GetAbsOrigin()) 
end

function OnHealBuffDestroy (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	ParticleManager:DestroyParticle( caster.healbuff, false )
	ParticleManager:ReleaseParticleIndex(caster.healbuff)
end

function OnRuneProtectionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	caster.IsMagicUse = true
	if not caster.IsPrimevalRuneAcquired then 
		caster:RemoveModifierByName("modifier_scathach_rune_mage_check")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_rune_of_protection", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_rune_of_protection_cooldown", {duration=ability:GetCooldown(1)})
end 

function OnPinningCast (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability.target = keys.target
	if caster:HasModifier("modifier_pinning_god_cooldown") then 
		--caster:Stop()
		--SendErrorMessage(caster:GetPlayerOwnerID(), "#Ability_on_cooldown")
	end
	ability:EndCooldown()
	caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
	EmitGlobalSound("Scathach.Pinning_God")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pinning_god_tracker", {Duration=ability:GetSpecialValueFor("cast_delay") - 0.04})
end

function OnPinningInterrupt (keys)
	StopGlobalSound("Scathach.Pinning_God")
end

function OnPinningStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = ability.target 

	if caster:HasModifier("modifier_pinning_god_tracker") then 
		OnPinningInterrupt (keys)
		return nil 
	end
	
	local origin = caster:GetAbsOrigin()
	local speed = ability:GetSpecialValueFor("speed")
	local distance = ability:GetSpecialValueFor("distance")
	--caster:EmitSound("Scathach.Pinning_God")
	ability:StartCooldown(ability:GetCooldown(1))
	caster:SetMana(caster:GetMana() - ability:GetManaCost(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pinning_god_cooldown", {Duration = ability:GetCooldown(1)})
	local dodge = true 
	if caster.IsBranchTonelicoAcquired then 
		if IsDivineServant(target) then 
			dodge = false 
		end
	end
	
	local lance = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/custom/lancer/soaring/spear.vpcf",
		vSpawnOrigin = origin,
		iMoveSpeed = speed,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDodgeable = dodge
	}
	ProjectileManager:CreateTrackingProjectile(lance) 
	caster:EmitSound("Hero_DrowRanger.FrostArrows")
end

function OnPinningHit (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local bonus_agi_ratio = ability:GetSpecialValueFor("bonus_agi_ratio")
	local stun = ability:GetSpecialValueFor("stun")
	local knockback = ability:GetSpecialValueFor("knockback")
	local wall_dmg = ability:GetSpecialValueFor("wall_dmg")
	local bonus_dmg = caster:GetAgility() * bonus_agi_ratio
	local dmg = base_dmg + bonus_dmg
	local bonus_divine = ability:GetSpecialValueFor("bonus_divine")

	giveUnitDataDrivenModifier(caster, target, "pause_sealenabled", 0.3)

	if IsDivineServant(target) then 
		giveUnitDataDrivenModifier(caster, target, "revoked", 0.3)
		DoDamage(caster, target, dmg * (1 + bonus_divine/100) , DAMAGE_TYPE_MAGICAL, 0, ability, false)
		
	else
		DoDamage(caster, target, dmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
	
	local pushTarget = Physics:Unit(target)
	target:EmitSound("Hero_Huskar.ProjectileImpact")
    target:PreventDI()
    target:SetPhysicsFriction(0)
	local vectorC = (target:GetAbsOrigin() - caster:GetAbsOrigin()) 
	-- get the direction where target will be pushed back to
	local vectorB = vectorC - vectorA
	target:SetPhysicsVelocity(vectorB:Normalized() * 1000)
    target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	local initialUnitOrigin = target:GetAbsOrigin()
	
	target:OnPhysicsFrame(function(unit) -- pushback distance check
		local unitOrigin = unit:GetAbsOrigin()
		local diff = unitOrigin - initialUnitOrigin
		local n_diff = diff:Normalized()
		unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
		if diff:Length() > knockback then -- if pushback distance is over 500, stop it
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end)
	
	target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		if IsDivineServant(target) then 
			giveUnitDataDrivenModifier(caster,target, "revoked", stun )
		end
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			target:AddNewModifier(caster, ability, "modifier_stunned", { duration = stun })
		end
		DoDamage(caster, unit, wall_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		
	end)
end

function OnRedWindStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local origin = caster:GetAbsOrigin() 
	local target_loc = target:GetAbsOrigin()
	local stun = ability:GetSpecialValueFor("stun")
	local damage = ability:GetSpecialValueFor("damage")
	local bonus_divine = ability:GetSpecialValueFor("bonus_divine")

	local diff = target_loc - origin
	CreateSlashFx(caster, caster:GetAbsOrigin() + Vector(0,0,80), caster:GetAbsOrigin() + Vector(0,0,80) + diff:Normalized() * diff:Length2D())
	local rush = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = origin,
        fDistance = diff:Length2D(),
        fStartRadius = 150,
        fEndRadius = 150,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 1.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 99999
	}
	local projectile = ProjectileManager:CreateLinearProjectile(rush)

	caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	StartAnimation(caster, {duration = 0.5, activity = ACT_DOTA_CAST_ABILITY_1_END, rate = 2})	
	caster:MoveToTargetToAttack(target)

	ScathachCheckCombo1(caster, ability)

	if IsSpellBlocked(target) then return end

	if caster.IsGodSlayerAcquired then 
		if IsDivineServant(target) then 
			damage = damage * (1 + bonus_divine / 100)
			giveUnitDataDrivenModifier(caster, target, "revoked", stun)
		end
	end

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
	end

	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)

	caster.redwindtarget = target
end

function OnRedwindHit (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local damage = ability:GetSpecialValueFor("damage")
	if target == nil then return end
	if target == caster.redwindtarget then return end
	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.1})
	end
	DoDamage(caster, target, damage * 0.5 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
end

function OnAttack (keys)
	local caster = keys.caster
	caster:EmitSound("Hero_PhantomLancer.Attack")
end

function OnSpearmanshipStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_spearmanship", {})
	ScathachCheckCombo1(caster, ability)
	if caster.IsBranchTonelicoAcquired then 
		ScathachCheckCombo2(caster, ability)
	end
end

function OnSpearmanshipDeath (keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_scathach_spearmanship")
end

function OnSpearmanshipAttackLand (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	local bonus_dmg = caster:GetAgility()
	local double_atk_chance = ability:GetSpecialValueFor("double_atk_chance")
	local double_spear = false
	if RandomInt(1, 100) <= double_atk_chance and double_spear == false then 
		double_spear = true 
		print('Scathach double attack')
		caster:PerformAttack( target, true, true, true, true, false, false, false )
		StartAnimation(caster, {duration=caster:GetAttackAnimationPoint(), activity=ACT_DOTA_ATTACK_EVENT, rate=1/caster:GetAttackAnimationPoint()})
	end

	if caster.IsGodSlayerAcquired then 
		local divine_chance = ability:GetSpecialValueFor("divine_chance")
		local divine_agi_ratio = ability:GetSpecialValueFor("divine_agi_ratio")
		local agi = caster:GetAgility()
		local random = RandomInt(1, 100)
		if random <= divine_chance then
			if IsDivineServant(target) then 
				if not caster:HasModifier("modifier_scathach_spearmanship_divine_cooldown") then 
					DoDamage(caster, target, divine_agi_ratio * agi , DAMAGE_TYPE_MAGICAL, 0, ability, false)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_scathach_spearmanship_divine_cooldown",{})
				end
			end
		end
	end
end

function OnSpearmanshipCreate (keys)
	local caster = keys.caster
	Attachments:AttachProp(caster, "attach_attack2", "models/scathach/scat_gae.vmdl")
end

function OnSpearmanshipDestroy (keys)
	local caster = keys.caster
	local gae = Attachments:GetCurrentAttachment(caster, "attach_attack2")
	if gae ~= nil and not gae:IsNull() then
		gae:RemoveSelf() 
	end
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	elseif caster:HasModifier("modifier_self_disarm") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Disarmed")
		return
	end
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)

	if caster:HasModifier('modifier_alternate_02') then 
		EmitGlobalSound("Scat-Priestess-E")
	elseif caster:HasModifier('modifier_alternate_03') then 
		EmitGlobalSound("Scat-Sergeant-E")
	elseif caster:HasModifier('modifier_alternate_04') then 
		EmitGlobalSound("Scat-Summer-E")
	else
		EmitGlobalSound("Scathach.Gae_Bolg")
	end
end


function OnGBTargetHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local HBThreshold = ability:GetSpecialValueFor("heart_break")
	local Damage = ability:GetSpecialValueFor("damage")
	local stun = ability:GetSpecialValueFor("stun")

	if caster.IsBranchTonelicoAcquired then 
		local bonus_doublespear = ability:GetSpecialValueFor("bonus_doublespear")
		if caster:HasModifier("modifier_scathach_spearmanship") then
			Damage = Damage * (1 + bonus_doublespear / 100)
		end
	end

	if caster.IsGodSlayerAcquired then
		local bonus_divine = ability:GetSpecialValueFor("bonus_divine")
		if IsDivineServant(target) then
			Damage = Damage * (1 + bonus_divine / 100)
		end
	end

	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_1_END, rate=2})

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_lance", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 500
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity,0,0))
	target:EmitSound("Hero_Lion.Impale")
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex(dagon_particle)
	end)

	if caster.IsBranchTonelicoAcquired then 
		local dagon_particle2 = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(dagon_particle2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(dagon_particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(dagon_particle2, 2, Vector(particle_effect_intensity,0,0))
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( dagon_particle2, false )
			ParticleManager:ReleaseParticleIndex(dagon_particle2)
		end)
	end	

	if IsSpellBlocked(target) then -- no damage but play the effect
	else
		giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)

		-- Blood splat
		local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)	
		local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)	

		if caster.IsGodSlayerAcquired then
			if IsDivineServant(target) then
				giveUnitDataDrivenModifier(caster, target, "revoked", stun)
			end
		end
		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		end

		DoDamage(caster, target, Damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
		
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			if target:GetHealthPercent() < HBThreshold and not target:IsMagicImmune() and not IsUnExecute(target) then
				local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
				target:Execute(ability, caster, { bExecution = true })
				
				Timers:CreateTimer( 3.0, function()
					ParticleManager:DestroyParticle( hb, false )
					ParticleManager:ReleaseParticleIndex(hb)
				end)
			end  -- check for HB
		end

		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splat, false )
			ParticleManager:DestroyParticle( culling_kill_particle, false )
			ParticleManager:ReleaseParticleIndex(culling_kill_particle)	
		end)
	end

end

function OnScatGBAOECast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_self_disarm") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Disarmed")
		return
	end
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)
end

function OnScatGBAOEStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local projectileSpeed = ability:GetSpecialValueFor("speed")
	local damage = ability:GetSpecialValueFor("damage")
	local knock_duration = ability:GetSpecialValueFor("knock_duration")
	local ascendCount = 0
	local descendCount = 0

	if (caster:GetAbsOrigin() - targetPoint):Length2D() > 2500 then 
		caster:SetMana(caster:GetMana() + ability:GetManaCost( ability:GetLevel())) 
		ability:EndCooldown() 
		return
	end

	if caster.IsBranchTonelicoAcquired then
		local bonus_agi = ability:GetSpecialValueFor("bonus_agi")
		local branch_damage = ability:GetSpecialValueFor("branch_damage") / 100
		damage = damage + (bonus_agi * caster:GetAgility())
		if caster:HasModifier("modifier_scathach_spearmanship") then		
			damage = damage * branch_damage
		end
	end

	EmitGlobalSound("Scathach.Gae_Bolg_Alternative")

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.8)
	Timers:CreateTimer(0.8, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postdelay", 0.15)
	end)
	Timers:CreateTimer(0.95, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postlock", 0.2)
	end)
	if caster.IsBranchTonelicoAcquired and caster:HasModifier("modifier_scathach_spearmanship") then
		StartAnimation(caster, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=2.0})
	else
		StartAnimation(caster, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_4, rate=2.0})
	end

	Timers:CreateTimer('sgb_throw' .. caster:GetPlayerOwnerID(), {
		endTime = 0.45,
		callback = function()
		local projectileOrigin = caster:GetAbsOrigin() + Vector(0,0,300)

		local particle_name = "particles/custom/lancer/lancer_gae_bolg_projectile.vpcf"
		local throw_particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(throw_particle, 0, projectileOrigin)
		ParticleManager:SetParticleControl(throw_particle, 1, (targetPoint - projectileOrigin):Normalized() * projectileSpeed)
		ParticleManager:SetParticleControl(throw_particle, 9, projectileOrigin)

		if not caster.IsBranchTonelicoAcquired then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_self_disarm", {})
		end

		local travelTime = (targetPoint - projectileOrigin):Length() / projectileSpeed
		Timers:CreateTimer(travelTime, function()
			ParticleManager:DestroyParticle(throw_particle, false)
			OnScatGBAOEHit(caster, ability, targetPoint, radius, damage, knock_duration, 1)
		end)

		if caster.IsBranchTonelicoAcquired then
			if caster:HasModifier("modifier_scathach_spearmanship") then 
				Timers:CreateTimer(0.3, function()
					local throw_particle_2 = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, projectile)
					ParticleManager:SetParticleControl(throw_particle_2, 0, projectileOrigin)
					ParticleManager:SetParticleControl(throw_particle_2, 1, (targetPoint - projectileOrigin):Normalized() * projectileSpeed)
					ParticleManager:SetParticleControl(throw_particle_2, 9, projectileOrigin)
					Timers:CreateTimer(travelTime, function()
						ParticleManager:DestroyParticle(throw_particle_2, false)
						OnScatGBAOEHit(caster, ability, targetPoint, radius, damage, knock_duration, 2)
					end)
				end)
			end
		end
	end})

	Timers:CreateTimer('sgb_ascend' .. caster:GetPlayerOwnerID(), {
		endTime = 0,
		callback = function()
	   	if ascendCount == 15 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+50))
		ascendCount = ascendCount + 1;
		return 0.033
	end
	})

	Timers:CreateTimer("sgb_descend" .. caster:GetPlayerOwnerID(), {
	    endTime = 0.3,
	    callback = function()
	    	if descendCount == 15 then return end
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-50))
			descendCount = descendCount + 1;
	      	return 0.033
	    end
	})
end

function OnScatGBAOEHit(caster, ability, targetPoint, radius, dmg, knock, iLance)

	Timers:CreateTimer(0.15, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				ApplyAirborne(caster, v, knock)
				if caster.IsGodSlayerAcquired then 
					local bonus_divine = ability:GetSpecialValueFor("bonus_divine") / 100
					if IsDivineServant(v) then 
						giveUnitDataDrivenModifier(caster, v, "revoked", knock)
						DoDamage(caster, v, dmg * (1 + bonus_divine), DAMAGE_TYPE_MAGICAL, 0, ability, false)
					else
						DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
				else
					DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end
	    end
	    
	    local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_WORLDORIGIN, caster)
		local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_WORLDORIGIN, caster)
		local explodeFx1 = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_hit.vpcf", PATTACH_WORLDORIGIN, caster )
		ParticleManager:SetParticleControl( fire, 0, targetPoint)
		ParticleManager:SetParticleControl( crack, 0, targetPoint)
		ParticleManager:SetParticleControl( explodeFx1, 0, targetPoint)
		ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
		caster:EmitSound("Misc.Crash")
	    Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( crack, false )
			ParticleManager:DestroyParticle( fire, false )
			ParticleManager:DestroyParticle( explodeFx1, false )
		end)
	end)
	if iLance == 1 then
		if not caster.IsBranchTonelicoAcquired then
			Timers:CreateTimer(0.75, function()

		   	 	local tProjectile = {
		        	Target = caster,
		        	vSourceLoc = targetPoint,
		        	Ability = ability,
		        	EffectName = "particles/custom/lancer/soaring/spear.vpcf",
		        	iMoveSpeed = 3000,
		        	bDodgeable = false,
		        	flExpireTime = GameRules:GetGameTime() + 10,
		    	}

		    	ProjectileManager:CreateTrackingProjectile(tProjectile)
			end)	
		end
	end
end

function OnGBReturn (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end

	target:RemoveModifierByName("modifier_self_disarm")
end

function OnWisdomOsHauntGroundDetect (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.unit
	local detect = ability:GetSpecialValueFor("detect_duration")
	local invis_detect = ability:GetSpecialValueFor("invis_detect_duration")
	if ability:IsItem() or IsSpellBook(ability:GetAbilityName()) then return end
	if target:IsInvisible() then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_wisdom_target", {duration = invis_detect})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_wisdom_target", {duration = detect})
	end
end

function OnWisdomSpellThink (keys)
	local caster = keys.caster
	local ability = keys.ability 

	if caster.spellblock == true and not caster:HasModifier("modifier_wisdom_spell_block") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisdom_spell_block", {})
	elseif caster.spellblock == false and not caster:HasModifier("modifier_wisdom_spell_block_cooldown") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisdom_spell_block_cooldown", {})
	end
end

function OnWisdomSpellBlockDestroy (keys)
	local caster = keys.caster
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisdom_spell_block_cooldown", {})
	caster.spellblock = false
end

function OnWisdomSpellBlockCooldownEnd (keys)
	local caster = keys.caster
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisdom_spell_block", {})
	caster.spellblock = true
end

function OnImmortalKill (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	local kill_stack = caster:GetModifierStackCount("modifier_immortal_passive", caster) or 0
	local stack_count = ability:GetSpecialValueFor("stack_count")
	
	if IsDivineServant(target) then 
		if not caster:HasModifier("modifier_immortal_agi") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_agi", {})
		end
		caster:SetModifierStackCount("modifier_immortal_passive", caster, kill_stack + 1)
		caster:SetModifierStackCount("modifier_immortal_agi", caster, kill_stack + 1)
		caster:CalculateStatBonus(true)
	end 

	if kill_stack >= stack_count then 
		if not caster:HasModifier("modifier_immortal_evade") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_evade", {})
		end
	end
	if kill_stack >= stack_count * 2 - 1 then 
		if not caster:HasModifier("modifier_immortal_crit") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_crit", {})
		end
	end
	if kill_stack >= stack_count * 3 - 1 then 
		if not caster:HasModifier("modifier_immortal_aspd") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_aspd", {})
		end
	end
	if kill_stack >= stack_count * 4 - 1 then 
		if not caster:HasModifier("modifier_immortal_revive") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_revive", {})
		end
	end
end

function OnImmortalCrit (keys)
	local caster = keys.caster
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_immortal_crit_hit", {})
end

function OnImmortalDead (keys)
	local caster = keys.caster
	local ability = keys.ability 
	--[[caster:SetModifierStackCount("modifier_immortal_passive", caster, 0)
	caster:RemoveModifierByName("modifier_immortal_agi")
	if caster:HasModifier("modifier_immortal_aspd") then 
		caster:RemoveModifierByName("modifier_immortal_aspd")
	end
	if caster:HasModifier("modifier_immortal_crit") then 
		caster:RemoveModifierByName("modifier_immortal_crit")
	end
	if caster:HasModifier("modifier_immortal_evade") then 
		caster:RemoveModifierByName("modifier_immortal_evade")
	end]]
end

function OnImmortalRevive (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local stack_count = ability:GetSpecialValueFor("stack_count")
	local revive_hp = ability:GetSpecialValueFor("revive_hp")
	local revive_duration = ability:GetSpecialValueFor("revive_duration")

	if caster:GetHealth() <= 0 and not IsReviveSeal(caster) and caster:HasModifier("modifier_immortal_revive") then
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
		caster:SetHealth(caster:GetMaxHealth() * revive_hp / 100)
		caster:SetModifierStackCount("modifier_immortal_passive", caster, stack_count*3)
		caster:SetModifierStackCount("modifier_immortal_agi", caster, stack_count*3)
		Timers:CreateTimer(revive_duration, function()
			caster:RemoveModifierByName("modifier_immortal_revive")
		end)
	end
end

WUsed = false
WTime = 0

function ScathachCheckCombo1(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "scathach_spearmanship") then
		--if ability == caster:FindAbilityByName("scathach_spearmanship") or ability == caster:FindAbilityByName("scathach_spearmanship_upgrade") then
			WUsed = true
			WTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 4,
				callback = function()
				WUsed = false
			end})
		else
			
			if string.match(ability:GetAbilityName(), "scathach_red_wind") and caster:FindAbilityByName(caster:GetAbilityByIndex(4):GetAbilityName()):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
				if WUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 4 - (newTime - WTime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
				end
			end
			--[[if caster.IsGodSlayerAcquired then 
				if caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind_upgrade") and caster:FindAbilityByName("scathach_rune_mage_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif not caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind_upgrade") and caster:FindAbilityByName("scathach_rune_mage_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind_upgrade") and caster:FindAbilityByName("scathach_rune_mage_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif not caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind_upgrade") and caster:FindAbilityByName("scathach_rune_mage"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				end
			else
				if caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind") and caster:FindAbilityByName("scathach_rune_mage_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif not caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind") and caster:FindAbilityByName("scathach_rune_mage_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind") and caster:FindAbilityByName("scathach_rune_mage_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				elseif not caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
					if ability == caster:FindAbilityByName("scathach_red_wind") and caster:FindAbilityByName("scathach_rune_mage"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_gate_of_sky"):IsCooldownReady() and not caster:HasModifier("modifier_gate_of_sky_cooldown") and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") then
						if WUsed == true then 
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_window", {duration = duration})	
							WUsed = false
						end
					end
				end
			end]]
		end
	end
end

function OnGateOfSkyWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "scathach_combo_gate_of_sky", false, true) 
	--[[if caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_3", "scathach_combo_gate_of_sky", false, true) 
	elseif not caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_2", "scathach_combo_gate_of_sky", false, true) 
	elseif caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_1", "scathach_combo_gate_of_sky", false, true) 
	elseif not caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage", "scathach_combo_gate_of_sky", false, true) 
	end]]
end

function OnGateOfSkyWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_3", "scathach_combo_gate_of_sky", true, false) 
	elseif not caster.IsPrimevalRuneAcquired and caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_2", "scathach_combo_gate_of_sky", true, false) 
	elseif caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage_upgrade_1", "scathach_combo_gate_of_sky", true, false) 
	elseif not caster.IsPrimevalRuneAcquired and not caster.IsWisdomOfHauntGroundAcquired then
		caster:SwapAbilities("scathach_rune_mage", "scathach_combo_gate_of_sky", true, false) 
	end
end

function OnGateOfSkyWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_gate_of_sky_window")
end


function ScathachCheckCombo2(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 and caster.IsBranchTonelicoAcquired then
		if caster.IsGodSlayerAcquired then
			if ability == caster:FindAbilityByName("scathach_spearmanship_upgrade") and caster:FindAbilityByName("scathach_gae_bolg_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_double_gae_bolg_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") and not caster:HasModifier("modifier_gate_of_sky_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_gae_combo_window", {})	
			end
		else
			if ability == caster:FindAbilityByName("scathach_spearmanship") and caster:FindAbilityByName("scathach_gae_bolg_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("scathach_combo_double_gae_bolg"):IsCooldownReady() and not caster:HasModifier("modifier_combo_double_gae_bolg_cooldown") and not caster:HasModifier("modifier_gate_of_sky_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_gae_combo_window", {})	
			end
		end
	end
end

function OnGaeComboWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsGodSlayerAcquired then
		caster:SwapAbilities("scathach_gae_bolg_upgrade_3", "scathach_combo_double_gae_bolg_upgrade", false, true) 
	else
		caster:SwapAbilities("scathach_gae_bolg_upgrade_1", "scathach_combo_double_gae_bolg", false, true) 
	end
end

function OnGaeComboWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsGodSlayerAcquired then
		caster:SwapAbilities("scathach_gae_bolg_upgrade_3", "scathach_combo_double_gae_bolg_upgrade", true, false) 
	else
		caster:SwapAbilities("scathach_gae_bolg_upgrade_1", "scathach_combo_double_gae_bolg", true, false) 
	end
end

function OnGaeComboWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_gae_combo_window")
end

function OnGateOfSkySound (keys)
	local caster = keys.caster
	local ability = keys.ability
	EmitGlobalSound("Scathach.Gate_Cast")
	if ability:OnAbilityPhaseInterrupted() then 
		StopGlobalSound("Scathach.Gate_Cast")
	end
end

function OnGateOfSkyCast (keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("range")
	local duration = ability:GetSpecialValueFor("duration")
	local pull_duration = ability:GetSpecialValueFor("pull_duration")
	local gate_open_duration = ability:GetSpecialValueFor("gate_open_duration")
	local execute_range = ability:GetSpecialValueFor("execute_range")
	local dmg = ability:GetSpecialValueFor("dmg")
	caster:RemoveModifierByName("modifier_gate_of_sky_window")
	caster:RemoveModifierByName("modifier_gae_combo_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_cooldown", {duration=ability:GetCooldown(1)})	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_check", {})	
	local double_gae = caster:FindAbilityByName("scathach_combo_double_gae_bolg") 
	if double_gae == nil then 
		if caster.IsGodSlayerAcquired then
			double_gae = caster:FindAbilityByName("scathach_combo_double_gae_bolg_upgrade")
		end
	end
	double_gae:StartCooldown(ability:GetCooldown(1))
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", duration + 0.1)
	SpawnAttachedVisionDummy(caster, caster, radius + 100, duration, false)

	StartAnimation(caster, {duration=gate_open_duration + 1.0, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.5})
	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("scathach_combo_gate_of_sky")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:StartCooldown(ability:GetCooldown(1))

	caster.gate = ParticleManager:CreateParticle("particles/custom/scathach/scat_gate.vpcf",  PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(caster.gate, 0, caster:GetAbsOrigin() + Vector(0,0,1200) )
	ParticleManager:SetParticleControl(caster.gate, 1, caster:GetAbsOrigin() + Vector(0,0,600))
	ParticleManager:SetParticleControl(caster.gate, 2, Vector(1.0,0,0)) 

	caster.gate_ground = ParticleManager:CreateParticle("particles/custom/scathach/scathach_gate_ground.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(caster.gate_ground, 0, caster:GetAbsOrigin() )
	caster:EmitSound("Hero_Mars.ArenaOfBlood.Crumble")

	Timers:CreateTimer(gate_open_duration, function()
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_buff", {duration = duration - gate_open_duration})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_of_sky_pull_aura", {duration = pull_duration})	
			caster.gate_open = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient_base.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(caster.gate_open, 0, caster:GetAbsOrigin() + Vector(0,0,800))
			ParticleManager:SetParticleControl(caster.gate_open, 1, Vector(200,1,1))
			ParticleManager:SetParticleControl(caster.gate_open, 2, caster:GetAbsOrigin() + Vector(0,0,800))
			EmitGlobalSound("Ability.Focusfire")	
			caster:StopSound("Hero_Mars.ArenaOfBlood.Crumble")
		end
		Timers:CreateTimer(1.5, function()		
			EmitGlobalSound("Scathach.Gate_Of_Sky")
			StartAnimation(caster, {duration=pull_duration - 1.5, activity=ACT_DOTA_CAST_ABILITY_7, rate=0.4})
		end)
		Timers:CreateTimer(pull_duration, function()
			if caster:IsAlive() and caster:HasModifier("modifier_gate_of_sky_check") then 
				EmitGlobalSound("Scathach.Gate_Post")
				caster.gate_close = ParticleManager:CreateParticle("particles/custom/scathach/scat_gate_end.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(caster.gate_close, 0, caster:GetAbsOrigin() + Vector(0,0,800) )
				ParticleManager:SetParticleControl(caster.gate_close, 2, caster:GetAbsOrigin() + Vector(0,0,800) )
				ParticleManager:SetParticleControl(caster.gate_close, 5, caster:GetAbsOrigin() + Vector(0,0,800) )
				ParticleManager:SetParticleControl(caster.gate_close, 61, Vector(500,0,0) )
				Timers:CreateTimer(2, function()
					ParticleManager:DestroyParticle( caster.gate_close, true )
					ParticleManager:ReleaseParticleIndex(caster.gate_close)
				end)
				local GateTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for k,v in pairs (GateTargets) do 
					if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
						local target_loc = v:GetAbsOrigin()
						local distance = (target_loc - caster:GetAbsOrigin()):Length2D()
						--print(v:GetName() .. ' distance = ' .. distance)
						local far = 1 - (distance / radius )
						--print('far : ' .. far)
						if distance <= execute_range then
							giveUnitDataDrivenModifier(caster, v, "revoked", 1.0)
							if IsUnExecute(v) then
								DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
							else
								giveUnitDataDrivenModifier(caster, v, "can_be_executed", 0.033)
								v:Execute(ability, caster, { bExecution = true })
							end
							
						elseif distance > execute_range and distance <= radius then 
							v:AddNewModifier(caster, nil, "modifier_stunned", {duration = far})
							DoDamage(caster, v, dmg * far, DAMAGE_TYPE_MAGICAL, 0, ability, false)

						end
					end
				end
			end
		end)
	end)

	-- sound 
	-- find enemy : cant blink 
end 

function OnGateOfSkyCreate (keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local backVec = -caster:GetForwardVector()
	local duration = ability:GetSpecialValueFor("duration")
	--[[caster.gate_of_sky = CreateUnitByName("scathach_gate_dummy", origin + Vector(backVec.x * 50, backVec.y * 50,0), false, caster, caster, caster:GetTeamNumber())
	caster.gate_of_sky:SetForwardVector(caster:GetForwardVector())
	caster.gate_of_sky:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.gate_of_sky:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})]]
	-- particle Gate at high
	-- gate go down 
end

function OnGateOfSkyDestroy (keys)
	local caster = keys.caster
	ParticleManager:DestroyParticle( caster.gate, true )
	ParticleManager:ReleaseParticleIndex(caster.gate)
	ParticleManager:DestroyParticle( caster.gate_ground, true )
	ParticleManager:ReleaseParticleIndex(caster.gate_ground)
	ParticleManager:DestroyParticle( caster.gate_open, true )
	ParticleManager:ReleaseParticleIndex(caster.gate_open)
	--ParticleManager:DestroyParticle( caster.gate_close, true )
	--ParticleManager:ReleaseParticleIndex(caster.gate_close)
	StopGlobalSound("Ability.Focusfire")
	--[[if IsValidEntity(caster.gate_of_sky) then
		caster.gate_of_sky:RemoveSelf()
	end]]
	-- remove Gate 
end

function OnGateOfSkyDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_gate_of_sky_check")
	caster:RemoveModifierByName("modifier_gate_of_sky_buff")
	caster:RemoveModifierByName("modifier_gate_of_sky_pull_aura")
end

function OnGateOfSkyPull (keys)
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability
	local target = keys.target
	local target_origin = target:GetAbsOrigin()		
 	local target_direction = (center - target_origin):Normalized()
    local pullTarget = Physics:Unit(target)

	target:PreventDI()
	target:SetPhysicsFriction(0)
   	target:SetNavCollisionType(PHYSICS_NAV_NOTHING)

end

function OnGateOfSkyBurnMana (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local mana_burn_sec = ability:GetSpecialValueFor("mana_burn_sec")
	local interval = ability:GetSpecialValueFor("interval")
	local max_mana = target:GetMaxMana()
	local radius = ability:GetSpecialValueFor("range")
	local mana_burn = max_mana * mana_burn_sec * interval / 100
	--print(target:GetName() .. ' mana burn = ' .. mana_burn)

	if target:IsAlive() and caster:IsAlive() then 
		if not IsManaLess(target) then
			target:SpendMana(mana_burn, ability)
			if target:GetMana() == 0 then
				giveUnitDataDrivenModifier(caster, target, "drag_pause", 0.2)
			end
		end
	end

	local unit_location = target:GetAbsOrigin()
	local vector_distance = caster:GetAbsOrigin() - unit_location
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
		-- If the target is greater than 40 units from the center, we move them 40 units towards it, otherwise we move them directly to the center
	if distance >= 40 then
		target:SetAbsOrigin(unit_location + (direction * radius / 40))
	else
		target:SetAbsOrigin(unit_location + direction * distance)
	end
end

function OnGateOfSkyPullStop (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

    --[[target:PreventDI(false)
    target:SetPhysicsVelocity(Vector(0,0,0))
    target:SetPhysicsAcceleration(Vector(0,0,0))
    FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)]]
end

function OnGateOfSkyOpen(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- Gate Open 
	-- Pull Unit 

	-- 4 s calculate how far from gate 
	--deal dmg
end

function OnGaeComboCast (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	elseif caster:HasModifier("modifier_self_disarm") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Disarmed")
		return
	end
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)
	EmitGlobalSound("Scathach.Gae_Combo_Cast")
end 

function OnGaeComboStart (keys)
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local gae_bolg = caster:FindAbilityByName("scathach_gae_bolg_upgrade_1")
	if gae_bolg == nil then
		if caster.IsGodSlayerAcquired then 
			gae_bolg = caster:FindAbilityByName("scathach_gae_bolg_upgrade_3")
		end
	end
	local HBThreshold = gae_bolg:GetLevelSpecialValueFor("heart_break", gae_bolg:GetLevel()) 
	local GaeDamage = gae_bolg:GetLevelSpecialValueFor("damage", gae_bolg:GetLevel())
	local bonus_gae_malee = ability:GetSpecialValueFor("gae_malee_dmg")
	local bonus_divine = ability:GetSpecialValueFor("bonus_divine")
	local stun = ability:GetSpecialValueFor("stun")
	local dashback = ability:GetSpecialValueFor("dashback")
	local forwardVec = caster:GetForwardVector()
	local GaeBonus = 0

	caster:RemoveModifierByName("modifier_gae_combo_window")
	if caster:HasModifier("modifier_gate_of_sky_window") then 
		caster:RemoveModifierByName("modifier_gate_of_sky_window")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_double_gae_bolg_cooldown", {duration=ability:GetCooldown(1)})	
	caster:FindAbilityByName("scathach_combo_gate_of_sky"):StartCooldown(ability:GetCooldown(1))
	gae_bolg:StartCooldown(gae_bolg:GetCooldown(gae_bolg:GetLevel()))
	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("scathach_combo_gate_of_sky")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:StartCooldown(ability:GetCooldown(1))

	if caster.IsGodSlayerAcquired then
		if IsDivineServant(target) then
			GaeBonus = GaeDamage * bonus_divine / 100
		end
	end

	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_1_END, rate=3})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_lance", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))

	local dagon_particle_2 = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle_2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(dagon_particle_2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(dagon_particle_2, 2, Vector(particle_effect_intensity))

	target:EmitSound("Hero_Lion.Impale")
	-- Blood splat
	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)

	if IsSpellBlocked(target) then -- Linken effect checker / dodge 1 lance and not stunned 
		DoDamage(caster, target, GaeDamage, DAMAGE_TYPE_PURE, 0, ability, false)
	else

		-- Blood splat
		local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)	
		local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)	

		giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
		DoDamage(caster, target, GaeDamage * bonus_gae_malee / 100, DAMAGE_TYPE_PURE, 0, ability, false)
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			if IsDivineServant(target) then
				giveUnitDataDrivenModifier(caster, target, "revoked", stun)
				target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
				DoDamage(caster, target, GaeBonus * bonus_gae_malee / 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			else
				target:AddNewModifier(caster, target, "modifier_stunned", {duration = stun})
			end
		end
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			if target:GetHealthPercent() < HBThreshold and not target:IsMagicImmune() and not IsUnExecute(target) then
				local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
				target:Execute(ability, caster, { bExecution = true })
				
				Timers:CreateTimer( 3.0, function()
					ParticleManager:DestroyParticle( hb, false )
					ParticleManager:ReleaseParticleIndex(hb)
				end)
			end  -- check for HB
		end

		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splat, false )
			ParticleManager:DestroyParticle( culling_kill_particle, false )
			ParticleManager:ReleaseParticleIndex(culling_kill_particle)	
		end)

		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() and caster:IsAlive() then 
			local ascendCount = 0
			local dashCount = 0
			Timers:CreateTimer('sdgb_ascend' .. caster:GetPlayerOwnerID(), {
				endTime = 0,
				callback = function()
				if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
			   	if ascendCount == 10 then return end
				target:SetAbsOrigin(target:GetAbsOrigin() + Vector(0,0,20))
				ascendCount = ascendCount + 1;
				return 0.033
			end})

			Timers:CreateTimer('sdgb_back' .. caster:GetPlayerOwnerID(), {
				endTime = 0,
				callback = function()
				if not caster:IsAlive() then return nil end
			   	if dashCount == 10 then return nil end
			   	local angle = 180 + caster:GetAnglesAsVector().y
			   	local newloc = GetRotationPoint(caster:GetAbsOrigin(),dashback/10,angle)
				caster:SetAbsOrigin(newloc)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				dashCount = dashCount + 1;
				return 0.033
			end})

			Timers:CreateTimer( 1.0, function()
				if IsValidEntity(target) and not target:IsNull() and target:IsAlive() and caster:IsAlive() then 
					giveUnitDataDrivenModifier(caster, target, "pause_sealdisabled", 3.0)
				end
			end)
		end
	end 

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:DestroyParticle( dagon_particle_2, false )
		ParticleManager:ReleaseParticleIndex(dagon_particle)
		ParticleManager:ReleaseParticleIndex(dagon_particle_2)
	end)

	if IsValidEntity(target) and not target:IsNull() and target:IsAlive() and caster:IsAlive() then 
		Timers:CreateTimer( 1.0, function()
			giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 2.0)
			StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=1})
			Timers:CreateTimer( 1.0, function()
				if IsValidEntity(target) and not target:IsNull() and target:IsAlive() and caster:IsAlive() then 
					EmitGlobalSound("Scathach.Gae_Bolg_Alternative")
					local tProjectile = {
	        			Target = target,
	        			Source = caster,
	        			Ability = ability,
	        			EffectName = "particles/custom/lancer/soaring/spear.vpcf",
	        			iMoveSpeed = 5000,
	        			vSourceLoc = caster:GetAbsOrigin(),
	        			bDodgeable = false,
	        			flExpireTime = GameRules:GetGameTime() + 2,
	        			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	    			}
	    			ProjectileManager:CreateTrackingProjectile(tProjectile)
	    			caster:EmitSound("Hero_DrowRanger.FrostArrows")
	    		else
	    			caster:RemoveModifierByName("jump_pause")
	    		end
	    	end)
	    end)
	end
end

function OnGaeComboHit (keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	
	local ability = keys.ability
	local gae_bolg_jump = caster:FindAbilityByName("scathach_gae_bolg_jump_upgrade_1")
	if caster.IsGodSlayerAcquired then 
		gae_bolg_jump = caster:FindAbilityByName("scathach_gae_bolg_jump_upgrade_3")
	end
	local radius = gae_bolg_jump:GetSpecialValueFor("radius")
	local damage = gae_bolg_jump:GetLevelSpecialValueFor("damage", gae_bolg_jump:GetLevel()) * ability:GetSpecialValueFor("gae_thrown") / 100
	local bonus_gae_thrown = ability:GetSpecialValueFor("gae_thrown_dmg")
	local bonus_divine = ability:GetSpecialValueFor("bonus_divine")
	local stun = ability:GetSpecialValueFor("stun")
	local knock = ability:GetSpecialValueFor("knock")
	local target_loc = GetGroundPosition(target:GetAbsOrigin(), target) 

	local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v ~= target then 
			ApplyAirborne(caster, v, knock)
	    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)	
		end
	end
	local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_WORLDORIGIN, nil)
	local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_WORLDORIGIN, nil)
	local explodeFx1 = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_hit.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( fire, 0, target_loc)
	ParticleManager:SetParticleControl( crack, 0, target_loc)
	ParticleManager:SetParticleControl( explodeFx1, 0, target_loc)
	ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
	caster:EmitSound("Misc.Crash")
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( crack, false )
		ParticleManager:DestroyParticle( fire, false )
		ParticleManager:DestroyParticle( explodeFx1, false )
	end)

	DoDamage(caster, target, damage + bonus_gae_thrown, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
		target:RemoveModifierByName("pause_sealdisabled")
		target:SetAbsOrigin(target_loc)
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		if caster.IsGodSlayerAcquired then
			if IsDivineServant(target) then
				giveUnitDataDrivenModifier(caster, target, "revoked", stun)
				local divine_damage = damage * (1 + bonus_divine/100)
				DoDamage(caster, target, divine_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	end
end

function OnPrimevalRuneAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPrimevalRuneAcquired) then

		if hero:HasModifier("modifier_gate_of_sky_window") then 
			hero:RemoveModifierByName("modifier_gate_of_sky_window")
		end

		if hero:HasModifier("modifier_gae_combo_window") then 
			hero:RemoveModifierByName("modifier_gae_combo_window")
		end

		hero.IsPrimevalRuneAcquired = true

		if hero:HasModifier("modifier_scathach_rune_mage_check") then 
			UpgradeAttribute(hero, "scathach_rune_fire", "scathach_rune_fire_upgrade", true)
			UpgradeAttribute(hero, "scathach_rune_frost", "scathach_rune_frost_upgrade", true)
			UpgradeAttribute(hero, "scathach_rune_blast", "scathach_rune_blast_upgrade", true)
			UpgradeAttribute(hero, "scathach_rune_heal", "scathach_rune_heal_upgrade", true)
			if hero.IsWisdomOfHauntGroundAcquired then
				UpgradeAttribute(hero, "scathach_rune_mage_upgrade_2", "scathach_rune_mage_upgrade_3", false)
				hero.FSkill = "scathach_rune_mage_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_rune_mage", "scathach_rune_mage_upgrade_1", false)
				hero.FSkill = "scathach_rune_mage_upgrade_1"
			end
		else
			UpgradeAttribute(hero, "scathach_rune_fire", "scathach_rune_fire_upgrade", false)
			UpgradeAttribute(hero, "scathach_rune_frost", "scathach_rune_frost_upgrade", false)
			UpgradeAttribute(hero, "scathach_rune_blast", "scathach_rune_blast_upgrade", false)
			UpgradeAttribute(hero, "scathach_rune_heal", "scathach_rune_heal_upgrade", false)
			if hero.IsWisdomOfHauntGroundAcquired then
				UpgradeAttribute(hero, "scathach_rune_mage_upgrade_2", "scathach_rune_mage_upgrade_3", true)
				hero.FSkill = "scathach_rune_mage_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_rune_mage", "scathach_rune_mage_upgrade_1", true)
				hero.FSkill = "scathach_rune_mage_upgrade_1"
			end
		end

		--[[hero:RemoveAbility("scathach_rune_fire")
		hero:RemoveAbility("scathach_rune_frost")
		hero:RemoveAbility("scathach_rune_blast")
		hero:RemoveAbility("scathach_rune_heal")
		hero:RemoveAbility("scathach_rune_mage")]]

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnGodSlayerAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGodSlayerAcquired) then

		if hero:HasModifier("modifier_gate_of_sky_window") then 
			hero:RemoveModifierByName("modifier_gate_of_sky_window")
		end

		if hero:HasModifier("modifier_gae_combo_window") then 
			hero:RemoveModifierByName("modifier_gae_combo_window")
		end

		hero.IsGodSlayerAcquired = true

		if hero:HasModifier("modifier_scathach_rune_mage_check") then 
			UpgradeAttribute(hero, "scathach_red_wind", "scathach_red_wind_upgrade", false)
			UpgradeAttribute(hero, "scathach_spearmanship", "scathach_spearmanship_upgrade", false)
			if hero.IsBranchTonelicoAcquired then 
				UpgradeAttribute(hero, "scathach_gae_bolg_upgrade_1", "scathach_gae_bolg_upgrade_3", false)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump_upgrade_1", "scathach_gae_bolg_jump_upgrade_3", false)
				hero.ESkill = "scathach_gae_bolg_upgrade_3"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_gae_bolg", "scathach_gae_bolg_upgrade_2", false)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump", "scathach_gae_bolg_jump_upgrade_2", false)
				hero.ESkill = "scathach_gae_bolg_upgrade_2"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_2"
			end
			hero:SwapAbilities("scathach_pinning_god", "fate_empty1", false, false)
		else
			UpgradeAttribute(hero, "scathach_red_wind", "scathach_red_wind_upgrade", true)
			UpgradeAttribute(hero, "scathach_spearmanship", "scathach_spearmanship_upgrade", true)
			if hero.IsBranchTonelicoAcquired then 
				UpgradeAttribute(hero, "scathach_gae_bolg_upgrade_1", "scathach_gae_bolg_upgrade_3", true)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump_upgrade_1", "scathach_gae_bolg_jump_upgrade_3", true)
				hero.ESkill = "scathach_gae_bolg_upgrade_3"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_gae_bolg", "scathach_gae_bolg_upgrade_2", true)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump", "scathach_gae_bolg_jump_upgrade_2", true)
				hero.ESkill = "scathach_gae_bolg_upgrade_2"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_2"
			end
			hero:SwapAbilities("scathach_pinning_god", "fate_empty1", true, false)
		end

		hero.QSkill = "scathach_red_wind_upgrade"
		hero.WSkill = "scathach_spearmanship_upgrade"
		hero.DSkill = "scathach_pinning_god"

		UpgradeAttribute(hero, "scathach_combo_double_gae_bolg", "scathach_combo_double_gae_bolg_upgrade", false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBranchTonelicoAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBranchTonelicoAcquired) then

		if hero:HasModifier("modifier_gate_of_sky_window") then 
			hero:RemoveModifierByName("modifier_gate_of_sky_window")
		end

		hero.IsBranchTonelicoAcquired = true

		if hero:HasModifier("modifier_scathach_rune_mage_check") then 
			if hero.IsGodSlayerAcquired then 
				UpgradeAttribute(hero, "scathach_gae_bolg_upgrade_2", "scathach_gae_bolg_upgrade_3", false)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump_upgrade_2", "scathach_gae_bolg_jump_upgrade_3", false)
				hero.ESkill = "scathach_gae_bolg_upgrade_3"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_gae_bolg", "scathach_gae_bolg_upgrade_1", false)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump", "scathach_gae_bolg_jump_upgrade_1", false)
				hero.ESkill = "scathach_gae_bolg_upgrade_1"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_1"
			end
		else
			if hero.IsGodSlayerAcquired then 
				UpgradeAttribute(hero, "scathach_gae_bolg_upgrade_2", "scathach_gae_bolg_upgrade_3", true)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump_upgrade_2", "scathach_gae_bolg_jump_upgrade_3", true)
				hero.ESkill = "scathach_gae_bolg_upgrade_3"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_gae_bolg", "scathach_gae_bolg_upgrade_1", true)
				UpgradeAttribute(hero, "scathach_gae_bolg_jump", "scathach_gae_bolg_jump_upgrade_1", true)
				hero.ESkill = "scathach_gae_bolg_upgrade_1"
				hero.RSkill = "scathach_gae_bolg_jump_upgrade_1"
			end
		end


		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnWisdomOfHauntGroundAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWisdomOfHauntGroundAcquired) then

		hero.IsWisdomOfHauntGroundAcquired = true

		local wisdom = hero:FindAbilityByName("scathach_wisdom_of_haunt_ground")
		wisdom:SetLevel(1)

		if hero:HasModifier("modifier_scathach_rune_mage_check") then 
			hero:SwapAbilities("fate_empty2", "scathach_rune_of_protection", false, true)
			if hero.IsPrimevalRuneAcquired then
				UpgradeAttribute(hero, "scathach_rune_mage_upgrade_1", "scathach_rune_mage_upgrade_3", false)
				hero.FSkill = "scathach_rune_mage_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_rune_mage", "scathach_rune_mage_upgrade_2", false)
				hero.FSkill = "scathach_rune_mage_upgrade_2"
			end
		else
			hero:SwapAbilities("fate_empty2", "scathach_rune_of_protection", false, false)
			if hero.IsPrimevalRuneAcquired then
				UpgradeAttribute(hero, "scathach_rune_mage_upgrade_1", "scathach_rune_mage_upgrade_3", true)
				hero.FSkill = "scathach_rune_mage_upgrade_3"
			else
				UpgradeAttribute(hero, "scathach_rune_mage", "scathach_rune_mage_upgrade_2", true)
				hero.FSkill = "scathach_rune_mage_upgrade_2"
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImmortalAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImmortalAcquired) then

		hero.IsImmortalAcquired = true

		local immortal = hero:FindAbilityByName("scathach_immortal")
		immortal:SetLevel(1)
		immortal:ApplyDataDrivenModifier(hero, hero, "modifier_immortal_passive", {})

		local divine_enemies = {}
		local d = 0
		--FindName(hero:GetName())

		LoopOverPlayers(function(player, playerID, playerHero)
			if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
				if IsDivineServant(playerHero) then
					table.insert(divine_enemies, d + 1, playerHero)
				end
			end
		end)

		local divine_list = ''

		for i = 1,#divine_enemies do 
			if i == #divine_enemies then 
				divine_list = divine_list .. FindName(divine_enemies[i]:GetName()) .. '.'
			else
				divine_list = divine_list .. FindName(divine_enemies[i]:GetName()) .. ', '
			end
		end

		Say(hero:GetPlayerOwner(), "Divinity Enemies: " .. divine_list, true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end