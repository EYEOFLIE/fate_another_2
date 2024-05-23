
function OnDiscernEyeCheck(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 
	local primaryStat = target:GetPrimaryAttribute()

	if primaryStat == 0 then 
		if caster.IsDiscernEyeAcquired and IsManaLess(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_discern_eye_str_no_int", {})
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_discern_eye_str", {})
		end
	elseif primaryStat == 1 then 
		if caster.IsDiscernEyeAcquired and IsManaLess(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_discern_eye_agi_no_int", {})
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_discern_eye_agi", {})
		end
	elseif primaryStat == 2 then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_discern_eye_int", {})
	end
end

function OnDiscernEyeDestroy(keys)
	local target = keys.target
	target:RemoveModifierByName("modifier_discern_eye_str")
	target:RemoveModifierByName("modifier_discern_eye_agi")
	target:RemoveModifierByName("modifier_discern_eye_int")
	target:RemoveModifierByName("modifier_discern_eye_str_no_int")
	target:RemoveModifierByName("modifier_discern_eye_agi_no_int")
end

function OnSpellBookClose(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_zhuge_liang_alchemist_check")
	caster:RemoveModifierByName("modifier_zhuge_liang_strat_command_check")
	caster:RemoveModifierByName("modifier_zhuge_liang_war_command_check")
end

function OnAlchemistStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_liang_alchemist_check", {})
	caster.IsAlchemistUse = false
	ability:EndCooldown()
end

function OnAlchemistOpen (keys)
	local caster = keys.caster
	local delay = 0

	if caster:HasModifier("modifier_zhuge_thunder_storm_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_zhuge_thunder_storm_window")
	end

	Timers:CreateTimer(delay, function()
		if caster.IsAlchemistAcquired then 
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_heal_pot_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_mana_pot_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_accel_pot_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_acid_pot_upgrade", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_heal_pot", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_mana_pot", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_accel_pot", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_acid_pot", false, true)
		end
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "fate_empty2", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "zhuge_liang_alchemist_close", false, true)
	end)
end

function OnAlchemistClose(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName(caster.DSkill)

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)


	if caster.IsAlchemistUse == true and not caster.IsAlchemistAcquired then 
		ability:StartCooldown(ability:GetCooldown(1))
	end
end

function OnPotionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local speed = 1000 
	local distance = (target_loc - caster:GetAbsOrigin()):Length2D()
	local delay = distance / speed
	local radius = ability:GetSpecialValueFor("radius")
	local buff = ""
	local effect = ""
	local pot = 0

	if string.match(ability:GetAbilityName(), "heal") then 
		buff = "modifier_zhuge_liang_heal_buff"
		effect = "red"
		pot = 1
	elseif string.match(ability:GetAbilityName(), "mana") then 
		buff = "modifier_zhuge_liang_mana_buff"
		effect = "blue"
		pot = 2
	elseif string.match(ability:GetAbilityName(), "accel") then 
		buff = "modifier_zhuge_liang_accel_buff"
		effect = "purple"
		pot = 3
	end

	caster:EmitSound("Hero_Alchemist.BerserkPotion.Cast")
	caster:EmitSound("ZhugeLiang.Skill2")

	local pot_fx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_" .. effect .. "_potion.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pot_fx, 0, caster:GetAbsOrigin() + Vector(0,0,300)) 
	ParticleManager:SetParticleControl(pot_fx, 1, target_loc) 
	ParticleManager:SetParticleControl(pot_fx, 2, Vector(speed,0,0)) 

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(pot_fx, true)
		ParticleManager:ReleaseParticleIndex(pot_fx)
		local pot_hit = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_" .. effect .. "_potion_hit.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(pot_hit, 0, target_loc)	
		ParticleManager:SetParticleControl(pot_hit, 1, Vector(10,10,10))
		Timers:CreateTimer(0.8, function()
			ParticleManager:DestroyParticle(pot_hit, true)
			ParticleManager:ReleaseParticleIndex(pot_hit)
		end)
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Alchemist.BerserkPotion.Target", caster)
		local healtargets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _,target in pairs (healtargets) do
			if pot == 2 then 
				if not IsManaLess(target) then
					ability:ApplyDataDrivenModifier(caster, target, buff, {})
				end
			else
				ability:ApplyDataDrivenModifier(caster, target, buff, {})
			end
		end
	end)

	caster.IsAlchemistUse = true

	if not caster.IsAlchemistAcquired then 
		caster:RemoveModifierByName("modifier_zhuge_liang_alchemist_check")
	end
end

function OnGreenPotionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local speed = 1000 
	local distance = (target_loc - caster:GetAbsOrigin()):Length2D()
	local delay = distance / speed
	local radius = ability:GetSpecialValueFor("radius")

	caster.IsAlchemistUse = true

	local pot_fx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_green_potion.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pot_fx, 0, caster:GetAbsOrigin() + Vector(0,0,300)) 
	ParticleManager:SetParticleControl(pot_fx, 1, target_loc) 
	ParticleManager:SetParticleControl(pot_fx, 2, Vector(speed,0,0)) 

	caster:EmitSound("Hero_Alchemist.BerserkPotion.Cast")
	caster:EmitSound("ZhugeLiang.Skill2")

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(pot_fx, true)
		ParticleManager:ReleaseParticleIndex(pot_fx)
		local pot_hit = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_green_potion_hit.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(pot_hit, 0, target_loc)	
		ParticleManager:SetParticleControl(pot_hit, 1, Vector(10,10,10))
		Timers:CreateTimer(0.8, function()
			ParticleManager:DestroyParticle(pot_hit, true)
			ParticleManager:ReleaseParticleIndex(pot_hit)
		end)
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Alchemist.AcidSpray", caster)
		local acidtargets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,target in pairs (acidtargets) do
			if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
				ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_acid_slow", {})
			end
			ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_acid", {})
		end
	end)

	if not caster.IsAlchemistAcquired then 
		caster:RemoveModifierByName("modifier_zhuge_liang_alchemist_check")
	end
end

function OnGreenPotionThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local dps = ability:GetSpecialValueFor("dps")

	DoDamage(caster, target, dps * 0.5 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnLaserStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local target_loc = ability:GetCursorPosition() 
	local cast_range = 500
	local angle = caster:GetAnglesAsVector().y
	local speed = 1200
	local range = ability:GetSpecialValueFor("range")

	if (math.abs(target_loc.x - origin.x) < cast_range) and (math.abs(target_loc.y - origin.y) < cast_range) then 
		target_loc = GetRotationPoint(caster:GetAbsOrigin(),cast_range,angle)
	end

	Timers:CreateTimer(0.1, function()
		if not caster:IsAlive() then return end
		local left_origin = GetRotationPoint(caster:GetAbsOrigin(), 150, angle - 105)
		local left_forward = (target_loc - left_origin):Normalized()
		local left_end = target_loc + (left_forward * (range - cast_range))
		local right_origin = GetRotationPoint(caster:GetAbsOrigin(), 150, angle + 105)
		local right_forward = (target_loc - right_origin):Normalized()
		local right_end = target_loc + (right_forward * (range - cast_range))	

		LaserFire(left_origin, left_forward, ability, caster, speed, left_end)
		LaserFire(right_origin, right_forward, ability, caster, speed, right_end)
		caster:EmitSound("Hero_Tinker.Laser")
	end)
end

function LaserFire(origin, forwardVec, ability, caster, speed, endpoint)
	local width = ability:GetSpecialValueFor("width")
	local range = ability:GetSpecialValueFor("range")

	local duration = range / speed

    local projectileTable = {
		Ability = ability,
		--EffectName = particle,
		vSpawnOrigin = origin,
		fDistance = range,
		Source = caster,
		fStartRadius = width,
        fEndRadius = width,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + duration,
		bDeleteOnHit = false,
		vVelocity = forwardVec * speed,		
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)

    local laserFx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(laserFx, 0, origin + Vector(0,0,250))
	ParticleManager:SetParticleControl(laserFx, 1, endpoint + Vector(0,0,100))  
	ParticleManager:SetParticleControl(laserFx, 9, origin + Vector(0,0,250))

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(laserFx, false)
		ParticleManager:ReleaseParticleIndex(laserFx)
	end)
    
    --caster:EmitSound("Hero_Luna.Attack")
end

function OnLaserHit(keys)
	local target = keys.target
	if target == nil then return end

	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage") 
	local silence = ability:GetSpecialValueFor("silence")

	local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(KBHitFx, 0, target:GetAbsOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( KBHitFx, false )
		ParticleManager:ReleaseParticleIndex( KBHitFx )
	end)

	target:EmitSound("Hero_Tinker.LaserImpact")
	target:AddNewModifier(caster, ability, "modifier_silence", {Duration=silence})
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnTacticeUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	
	if caster.IsStratagemsAcquired then
		caster:FindAbilityByName("zhuge_liang_rock_fall_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_fire_arrow_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_flood_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_wind_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_wood_trap_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("zhuge_liang_rock_fall"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_fire_arrow"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_flood"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_wind"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_wood_trap"):SetLevel(ability:GetLevel())
	end
end

function OnTacticStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_liang_strat_command_check", {})
end

function OnTacticOpen(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local delay = 0

	if caster:HasModifier("modifier_zhuge_thunder_storm_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_zhuge_thunder_storm_window")
	end

	Timers:CreateTimer(delay, function()
		if caster.IsStratagemsAcquired then 
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_rock_fall_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_fire_arrow_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_flood_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "zhuge_liang_wind_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_wood_trap_upgrade", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_rock_fall", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_fire_arrow", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_flood", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "zhuge_liang_wind", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_wood_trap", false, true)
		end
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "zhuge_liang_alchemist_close", false, true)
	end)
end

function OnTacticClose(keys)
	local caster = keys.caster
	local ability = keys.ability 

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)
end

function OnRockFall(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local stun = ability:GetSpecialValueFor("stun")

	local rock_fall = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_rock_fall.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(rock_fall, 0, target_loc + Vector(0,0,500))	
	ParticleManager:SetParticleControl(rock_fall, 1, Vector(radius - 30,0,0))
	ParticleManager:SetParticleControl(rock_fall, 2, target_loc)	
	
	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(rock_fall, true)
		ParticleManager:ReleaseParticleIndex(rock_fall)
		local rock_hit = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_groundrock.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(rock_hit, 0, target_loc)	
		ParticleManager:SetParticleControl(rock_hit, 1, target_loc)
		Timers:CreateTimer(0.8, function()
			ParticleManager:DestroyParticle(rock_hit, true)
			ParticleManager:ReleaseParticleIndex(rock_hit)
		end)
		EmitSoundOnLocationWithCaster(target_loc, "Ability.Avalanche", caster)
		local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,target in pairs (targets) do
			if not IsImmuneToCC(target) and not target:IsMagicImmune() then 
				target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
			end
			DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end)
end

function OnFireArrows(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local flame_dur = ability:GetSpecialValueFor("flame_dur")

	local arrows = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_arrow_group.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(arrows, 0, target_loc)	
	ParticleManager:SetParticleControl(arrows, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(arrows, 2, Vector(85, radius - 50, 0))

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(arrows, true)
		ParticleManager:ReleaseParticleIndex(arrows)
	end)

	Timers:CreateTimer(delay, function()
		AddFlameAOE(caster, target_loc)
		
		EmitSoundOnLocationWithCaster(target_loc, "Hero_LegionCommander.Overwhelming.Location", caster)
		local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,target in pairs (targets) do
			if not target:IsMagicImmune() then 
				ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_fire_arrow", {})
			end
			DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		end
	end)
end

function AddFlameAOE(caster, target_loc)
	local fire_arrow = caster:FindAbilityByName("zhuge_liang_fire_arrow")
	if fire_arrow == nil then 
		fire_arrow = caster:FindAbilityByName("zhuge_liang_fire_arrow_upgrade")
	end

	local radius = fire_arrow:GetSpecialValueFor("radius")
	local flame_dur = fire_arrow:GetSpecialValueFor("flame_dur")

	local FlameDummy = CreateUnitByName("zhuge_liang_fire_dummy", target_loc, false, caster, caster, caster:GetTeamNumber())
	FlameDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	FlameDummy:SetDayTimeVisionRange(radius)
	FlameDummy:SetNightTimeVisionRange(radius)
	fire_arrow:ApplyDataDrivenModifier(caster, FlameDummy, "modifier_zhuge_liang_fire_aoe_thinker", {Duration = flame_dur})
	FlameDummy:AddNewModifier(caster, nil, "modifier_kill", {Duration = flame_dur})

	local FlameFx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_scorch_burn.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(FlameFx, 0, target_loc)	
	ParticleManager:SetParticleControl(FlameFx, 1, Vector(radius,0,0))

	Timers:CreateTimer(flame_dur, function()
		ParticleManager:DestroyParticle(FlameFx, true)
		ParticleManager:ReleaseParticleIndex(FlameFx)
	end)
end

function OnFireArrowsBurn(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local fire_damage = ability:GetSpecialValueFor("fire_damage")

	if target:HasModifier("modifier_zhuge_liang_wood_trap") then 
		target:RemoveModifierByName("modifier_zhuge_liang_wood_trap")
	end

	DoDamage(caster, target, fire_damage * 0.5, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnFireBurn(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local dummy = keys.target
	local fire_damage = ability:GetSpecialValueFor("fire_damage") 
	local radius = ability:GetSpecialValueFor("radius") 

	local targets = FindUnitsInRadius(caster:GetTeam(), dummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,v in pairs (targets) do

		if v:HasModifier("modifier_zhuge_liang_wood_trap") then 
			v:RemoveModifierByName("modifier_zhuge_liang_wood_trap")
		end

		DoDamage(caster, v, fire_damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)

		if not v:IsMagicImmune() then 
			ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_liang_fire_arrow", {})
		end
	end
end

function OnFloodStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local angle = caster:GetAnglesAsVector().y
	local width = ability:GetSpecialValueFor("width")
	local distance = ability:GetSpecialValueFor("distance")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = 800
	local duration = math.ceil(distance / speed)

	local origin = GetRotationPoint(target_loc, distance/2, angle - 90)
	local end_point = GetRotationPoint(target_loc, distance/2, angle + 90)
	caster.floodVec = (end_point - origin):Normalized()

	Timers:CreateTimer(cast_delay, function()
		local flood = {
			Ability = ability,
			--EffectName = "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_front.vpcf",
			vSpawnOrigin = origin,
			fDistance = distance,
			Source = caster,
			fStartRadius = width,
	        fEndRadius = width,
			bHasFrontialCone = true,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			fExpireTime = GameRules:GetGameTime() + duration,
			bDeleteOnHit = false,
			vVelocity = caster.floodVec * speed,		
		}
		EmitSoundOnLocationWithCaster(origin, "Hero_Tidehunter.Gush.AghsProjectile", caster)
		local projectile = ProjectileManager:CreateLinearProjectile(flood)
		local flood = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_flood.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(flood, 0, origin)	
		ParticleManager:SetParticleControl(flood, 1, caster.floodVec * speed)
		ParticleManager:SetParticleControl(flood, 3, origin)
		Timers:CreateTimer(duration + 0.1, function()
			ParticleManager:DestroyParticle(flood, true)
			ParticleManager:ReleaseParticleIndex(flood)
		end)
	end)
end

function OnFloodHit(keys)
	local target = keys.target
	if target == nil then return end

	local caster = keys.caster
	local ability = keys.ability
	if target:GetTeam() == caster:GetTeam() then
		if target:GetUnitName() == "zhuge_liang_fire_dummy" then 
			target:ForceKill(false)
		else
			return nil
		end
	else
		local damage = ability:GetSpecialValueFor("damage")
		local knock = ability:GetSpecialValueFor("knock")
		local distance = ability:GetSpecialValueFor("distance")

		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

		if target:HasModifier("modifier_zhuge_liang_fire_arrow") then 
			target:RemoveModifierByName("modifier_zhuge_liang_fire_arrow")
		end

		if not IsKnockbackImmune(target) and not target:HasModifier("modifier_zhuge_liang_wood_trap") then
			--giveUnitDataDrivenModifier(caster, v, "drag_pause", knock)
			local pushback = Physics:Unit(target)
			target:PreventDI()
			target:SetPhysicsFriction(0)
			target:SetPhysicsVelocity(caster.floodVec * distance / 2)
			target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
			target:FollowNavMesh(false)

			Timers:CreateTimer(knock, function()  
				target:PreventDI(false)
				target:SetPhysicsVelocity(Vector(0,0,0))
				target:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
				return 
			end)
		end
	end
end

function OnWindStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local origin = caster:GetAbsOrigin()
	local target_loc = ability:GetCursorPosition()
	target_loc.z = origin.z
	local width = ability:GetSpecialValueFor("width")
	local distance = ability:GetSpecialValueFor("distance")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = 1500
	local forwardVec = (target_loc - origin):Normalized()
	caster.wildfire = false
	caster.start_origin = caster:GetAbsOrigin()
	caster.fire_forward = forwardVec

	caster:EmitSound("Hero_Invoker.Tornado.Cast")
	--Timers:CreateTimer(cast_delay, function()
		local wind = {
			Ability = ability,
			EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			fDistance = distance,
			Source = caster,
			fStartRadius = width,
	        fEndRadius = width,
			bHasFrontialCone = true,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			fExpireTime = GameRules:GetGameTime() + 3,
			bDeleteOnHit = false,
			vVelocity = forwardVec * speed,		
		}
		local projectile = ProjectileManager:CreateLinearProjectile(wind)
	--end)
end

function OnWindHit(keys)
	local target = keys.target
	if target == nil then return end

	local caster = keys.caster
	local ability = keys.ability
	if target:GetTeam() == caster:GetTeam() then
		if target:GetUnitName() == "zhuge_liang_fire_dummy" then 
			if caster.wildfire == false then 
				local old_wildfire = target:GetAbsOrigin()
				local distance = ability:GetSpecialValueFor("distance")
				caster.wildfire = true
				for i = 1,3 do
					local dist = (caster.start_origin - old_wildfire):Length2D()
					if dist < distance - 180 then 
						local new_wildfire = old_wildfire + (Vector(caster.fire_forward.x, caster.fire_forward.y, 0) * 200)
						AddFlameAOE(caster, new_wildfire)
						old_wildfire = new_wildfire
					else
						return nil
					end
				end
			end
		else
			return nil
		end
	else
		local damage = ability:GetSpecialValueFor("damage")
		local knock = ability:GetSpecialValueFor("knock")

		--[[if caster.wildfire == true then 
			local firearrow = GetAbility(caster, "zhuge_liang_fire_arrow")
			firearrow:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_fire_arrow", {})
		end]]

		ApplyAirborne(caster, target, knock)

		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnWoodTrap(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")

	local root = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_wood_cast.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(root, 0, target_loc)

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(root, false)
		ParticleManager:ReleaseParticleIndex(root)
	end)
	
	EmitSoundOnLocationWithCaster(target_loc, "Hero_Treant.Overgrowth.Cast", caster)
	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,target in pairs (targets) do
			if not IsImmuneToCC(target) and not target:IsMagicImmune() then 
				ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_wood_trap", {})
			end
		end
	end)
end

function OnWoodLock(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local dps = ability:GetSpecialValueFor("dps")

	DoDamage(caster, target, dps * 0.5 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnCommandUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	
	if caster.IsLetterAcquired then
		caster:FindAbilityByName("zhuge_liang_ambush_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_offense_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_defense_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("zhuge_liang_ambush"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_offense"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("zhuge_liang_defense"):SetLevel(ability:GetLevel())
	end
end

function OnCommandStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_liang_war_command_check", {})
	caster.IsCommandUse = false
	ability:EndCooldown()
end

function OnCommandOpen(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local delay = 0

	if caster:HasModifier("modifier_zhuge_thunder_storm_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_zhuge_thunder_storm_window")
	end

	Timers:CreateTimer(delay, function()
		if caster.IsLetterAcquired then 
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_ambush_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_offense_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_defense_upgrade", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "zhuge_liang_ambush", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "zhuge_liang_offense", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "zhuge_liang_defense", false, true)
		end
		--if caster.IsStratagemsAcquired then 
		--	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_cross_bow", false, true)
		--else
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "fate_empty3", false, true)
		--end
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "fate_empty2", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "zhuge_liang_alchemist_close", false, true)
	end)
end

function OnCommandClose(keys)
	local caster = keys.caster
	local ability = keys.ability 

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)

	if caster.IsCommandUse == true and not caster.IsLetterAcquired then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end
end

function OnCommandFilter(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if target == caster or not target:IsRealHero() then 
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
        return 
	end
end

function OnAmbushStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	target:RemoveModifierByName("modifier_zhuge_liang_offense")
	target:RemoveModifierByName("modifier_zhuge_liang_offense_crit")
	target:RemoveModifierByName("modifier_zhuge_liang_defense")
	target:RemoveModifierByName("modifier_zhuge_liang_shield")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_ambush", {})
	caster:EmitSound("ZhugeLiang.Skill3")
	target:EmitSound("Hero_Oracle.FalsePromise.Healed")

	caster.IsCommandUse = true

	if caster.IsLetterAcquired then
		local aoe = ability:GetSpecialValueFor("aoe")
		local allies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs (allies) do
			if v ~= target then 
				v:RemoveModifierByName("modifier_zhuge_liang_offense")
				v:RemoveModifierByName("modifier_zhuge_liang_offense_crit")
				v:RemoveModifierByName("modifier_zhuge_liang_defense")
				v:RemoveModifierByName("modifier_zhuge_liang_shield")

				ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_liang_ambush", {})
			end
		end
	else
		caster:RemoveModifierByName("modifier_zhuge_liang_war_command_check")
	end
end

function OnAmbushBreak(keys)

	local caster = keys.caster 
	local source = keys.attacker
	local target = keys.unit 
	target:RemoveModifierByName("modifier_zhuge_liang_ambush")
end

function OnAmbushAttack(keys)
	
	local caster = keys.caster 
	local ability = keys.ability 
	local source = keys.attacker
	local target = keys.target 

	source:RemoveModifierByName("modifier_zhuge_liang_ambush")

	if caster.IsLetterAcquired then
		ability:ApplyDataDrivenModifier(source, target, "modifier_zhuge_liang_ambush_debuff", {}) 
	end
end

function OnOffenseStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	target:RemoveModifierByName("modifier_zhuge_liang_ambush")
	target:RemoveModifierByName("modifier_zhuge_liang_defense")
	target:RemoveModifierByName("modifier_zhuge_liang_shield")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_offense", {})
	caster:EmitSound("ZhugeLiang.Skill3")
	target:EmitSound("Hero_OgreMagi.Bloodlust.Cast")

	caster.IsCommandUse = true

	if caster.IsLetterAcquired then
		local spell_amp = ability:GetSpecialValueFor("spell_amp")
		ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_spell_amp", {})
		target:SetModifierStackCount("modifier_zhuge_spell_amp", caster, spell_amp)

		local aoe = ability:GetSpecialValueFor("aoe")
		local allies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs (allies) do
			if v ~= target then 
				v:RemoveModifierByName("modifier_zhuge_liang_ambush")
				v:RemoveModifierByName("modifier_zhuge_liang_defense")
				v:RemoveModifierByName("modifier_zhuge_liang_shield")

				ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_liang_offense", {})
				ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_spell_amp", {})
				v:SetModifierStackCount("modifier_zhuge_spell_amp", caster, spell_amp)
			end
		end
	else
		caster:RemoveModifierByName("modifier_zhuge_liang_war_command_check")
	end
end

function OnOffenseCrit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.attacker

	ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_offense_crit", {})
end

function OnDefenseStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	target:RemoveModifierByName("modifier_zhuge_liang_ambush")
	target:RemoveModifierByName("modifier_zhuge_liang_offense")
	target:RemoveModifierByName("modifier_zhuge_liang_offense_crit")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_defense", {})
	caster:EmitSound("ZhugeLiang.Skill3")
	target:EmitSound("Hero_Omniknight.Purification")

	if caster.IsLetterAcquired then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_liang_shield", {}) 
		target.ZhugeShield = ability:GetSpecialValueFor("shield")
	end

	caster.IsCommandUse = true

	if caster.IsLetterAcquired then
		local aoe = ability:GetSpecialValueFor("aoe")
		local allies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs (allies) do
			if v ~= target then 
				v:RemoveModifierByName("modifier_zhuge_liang_offense")
				v:RemoveModifierByName("modifier_zhuge_liang_offense_crit")
				v:RemoveModifierByName("modifier_zhuge_liang_ambush")

				ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_liang_defense", {})
				ability:ApplyDataDrivenModifier(caster, v, "modifier_zhuge_liang_shield", {}) 
				v.ZhugeShield = ability:GetSpecialValueFor("shield")
			end
		end
	else
		caster:RemoveModifierByName("modifier_zhuge_liang_war_command_check")
	end
end

function OnShieldDamaged(keys)
	local caster = keys.caster 
	local target = keys.target 
	local currentHealth = target:GetHealth() 

	-- Create particles
	local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, target )
	ParticleManager:SetParticleControl( onHitParticleIndex, 2, target:GetAbsOrigin() )
	
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( onHitParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
	end)

	target.ZhugeShield = target.ZhugeShield - keys.DamageTaken
	if target.ZhugeShield <= 0 then
		if currentHealth + target.ZhugeShield <= 0 then
			--print("lethal")
		else
			--print("rho broken, but not lethal")
			target:RemoveModifierByName("modifier_rho_aias")
			target:SetHealth(currentHealth + keys.DamageTaken + target.ZhugeShield)
			target.ZhugeShield = 0
		end
	else
		--print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		target:SetHealth(currentHealth + keys.DamageTaken)
		--caster.rhoTarget:SetModifierStackCount("modifier_rho_aias", caster, caster.rhoTarget.rhoShieldAmount/10)
	end
end

function OnMazeFilter(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()

	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc) then
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
end

function OnMazeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")

	if caster.MazeCastFx == nil then 
		caster.MazeCastFx = {}
	else
		for i = 1, #caster.MazeCastFx do 
			ParticleManager:DestroyParticle(caster.MazeCastFx[i], true)
			ParticleManager:ReleaseParticleIndex(caster.MazeCastFx[i])
		end
		Timers:RemoveTimer("zhuge_maze_cast" .. caster:GetPlayerOwnerID())
	end

	if caster.MazeDummy ~= nil and not caster.MazeDummy:IsNull() and IsValidEntity(caster.MazeDummy) then 
		caster.MazeDummy:RemoveModifierByName("modifier_zhuge_liang_array_aura")
		ParticleManager:DestroyParticle(caster.MazeGroundFx, true)
		ParticleManager:ReleaseParticleIndex(caster.MazeGroundFx)
		ParticleManager:DestroyParticle(caster.MazeRingFx, false)
		ParticleManager:ReleaseParticleIndex(caster.MazeRingFx)
		ParticleManager:DestroyParticle(caster.MazeParticleFx, false)
		ParticleManager:ReleaseParticleIndex(caster.MazeParticleFx)
		Timers:RemoveTimer(caster.mazeTimer)
		caster.MazeDummy:RemoveSelf()
		caster:RemoveModifierByName("modifier_zhuge_liang_array_checker")
	end

	if caster:HasModifier("modifier_alternate_01") then 
		EmitGlobalSound("Waver.Array")
	else
		EmitGlobalSound("ZhugeLiang.Array")
	end

	caster.MazeCastFx = {}
	local total_pillar = 1 
	local interval = delay / 8
	local angle = 10
	local pillar_loc = GetRotationPoint(target_loc, radius + 50, angle)

	Timers:CreateTimer("zhuge_maze_cast" .. caster:GetPlayerOwnerID(), {
		endTime = 0,
		callback = function()

		if not caster:IsAlive() or total_pillar > 8 then
			for i = 1, total_pillar - 1 do 
				ParticleManager:DestroyParticle(caster.MazeCastFx[i], true)
				ParticleManager:ReleaseParticleIndex(caster.MazeCastFx[i])
			end
		 	return nil
		end

		angle = angle + 45
		if angle > 360 then 
			angle = angle - 360
		end
		pillar_loc = GetRotationPoint(target_loc, radius + 50, angle)

		caster.MazeCastFx[total_pillar] = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_maze_pilar.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(caster.MazeCastFx[total_pillar], 0, pillar_loc + Vector(0,0,1024))
		ParticleManager:SetParticleControl(caster.MazeCastFx[total_pillar], 1, pillar_loc)	

		EmitSoundOnLocationWithCaster(pillar_loc, "ZhugeLiang.ArrayCast", caster)

		total_pillar = total_pillar + 1
				
		return interval 
	end})

	caster.mazeTimer = Timers:CreateTimer(delay, function()
	
		if caster:IsAlive() then
			EmitSoundOnLocationWithCaster(pillar_loc, "ZhugeLiang.ArrayStart", caster)
			caster.MazeDummy = CreateUnitByName("sight_dummy_unit", target_loc, false, caster, caster, caster:GetTeamNumber())
			caster.MazeDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			caster.MazeDummy:SetDayTimeVisionRange(radius)
			caster.MazeDummy:SetNightTimeVisionRange(radius)
			caster.MazeDummyCenter = target_loc
			ability:ApplyDataDrivenModifier(caster, caster.MazeDummy, "modifier_zhuge_liang_array_aura", {})
			if caster.IsTerritoryAcquired then 
				ability:ApplyDataDrivenModifier(caster, caster.MazeDummy, "modifier_zhuge_liang_array_aura_debuff", {})
			end
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_liang_array_checker", {})
			caster.MazeParticleFx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_maze_ring.vpcf", PATTACH_WORLDORIGIN, caster.MazeDummy)
			ParticleManager:SetParticleControl(caster.MazeParticleFx, 0, Vector(0,0,0))	
			ParticleManager:SetParticleControl(caster.MazeParticleFx, 1, Vector(radius + 50,0,0))	
			ParticleManager:SetParticleControl(caster.MazeParticleFx, 2, caster.MazeDummyCenter)
			caster.MazeGroundFx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_maze_ground_glow.vpcf", PATTACH_WORLDORIGIN, caster.MazeDummy)
			ParticleManager:SetParticleControl(caster.MazeGroundFx, 0, caster.MazeDummyCenter)
			ParticleManager:SetParticleControl(caster.MazeGroundFx, 1, Vector(radius,0,0))	
			caster.MazeRingFx = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_maze_border_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.MazeDummy)
			ParticleManager:SetParticleControl(caster.MazeRingFx, 0, caster.MazeDummyCenter)	
			ParticleManager:SetParticleControl(caster.MazeRingFx, 1, Vector(radius + 50,0,0))	
			ParticleManager:SetParticleControl(caster.MazeRingFx, 2, caster.MazeDummyCenter + Vector(0,0,400))				
		end
	end)

	ZhugeLiangCheckCombo(caster, ability)
end

function OnMazeLock(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local radius = ability:GetSpecialValueFor("radius")

	if math.abs((caster.MazeDummyCenter - target:GetAbsOrigin()):Length2D()) > radius then 
		local diff = target:GetAbsOrigin() - caster.MazeDummyCenter
		diff = diff:Normalized()
		if target:HasModifier("modifier_zhuge_liang_array_enemy") then
			target:SetAbsOrigin(caster.MazeDummyCenter + diff * radius)
			FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		end
	end
end

function OnMazeDestroy(keys)
	local caster = keys.caster 
	if caster.MazeGroundFx ~= nil then
		ParticleManager:DestroyParticle(caster.MazeGroundFx, true)
		ParticleManager:ReleaseParticleIndex(caster.MazeGroundFx)
		ParticleManager:DestroyParticle(caster.MazeRingFx, false)
		ParticleManager:ReleaseParticleIndex(caster.MazeRingFx)
		ParticleManager:DestroyParticle(caster.MazeParticleFx, false)
		ParticleManager:ReleaseParticleIndex(caster.MazeParticleFx)
		Timers:RemoveTimer(caster.mazeTimer)
	end
	if caster.MazeDummy ~= nil and not caster.MazeDummy:IsNull() and IsValidEntity(caster.MazeDummy) then	
		caster.MazeDummy:RemoveModifierByName("modifier_zhuge_liang_array_aura")
		caster.MazeDummy:RemoveSelf()
	end
end

function OnMazeDie(keys)
	local caster = keys.caster 
	if caster.MazeDummy ~= nil and not caster.MazeDummy:IsNull() and IsValidEntity(caster.MazeDummy) then 
		caster.MazeDummy:RemoveModifierByName("modifier_zhuge_liang_array_aura")
		Timers:RemoveTimer(caster.mazeTimer)
		caster.MazeDummy:RemoveSelf()
		caster:RemoveModifierByName("modifier_zhuge_liang_array_checker")
	end
end

function DebuffStack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local heal_debuff = math.abs(ability:GetSpecialValueFor("heal_debuff"))

	target:SetModifierStackCount("modifier_zhuge_liang_array_heal_debuff", caster, heal_debuff)
end

function ZhugeLiangCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "zhuge_liang_array") and not caster:HasModifier("modifier_zhuge_thunder_storm_cooldown") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_thunder_storm_window", {})
		end
	end
end

function OnThunderStormWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_combo", false, true)
end

function OnThunderStormWindowDestroy(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.RSkill, "zhuge_liang_combo", true, false)
end

function OnThunderStormWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_zhuge_thunder_storm_window")
end

function ThunderStrike(caster, ability, vTargetLoc, iDamage, iAOE)
	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end
	if ability == nil then return end
	local stun = ability:GetSpecialValueFor("stun")
	local thunderfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(thunderfx1, 0, vTargetLoc + Vector(0,0,1000))
	ParticleManager:SetParticleControl(thunderfx1, 1, vTargetLoc)
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
 		--if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
 			DoDamage(caster, target, iDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	 		if not target:IsMagicImmune() then 
	 			ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_thunder_storm_slow", {})
	 			local sstack = target:GetModifierStackCount("modifier_zhuge_thunder_storm_slow", caster) or 0 
	 			target:SetModifierStackCount("modifier_zhuge_thunder_storm_slow", caster, sstack + 1)
	 			if not IsImmuneToCC(target) then 
		 			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
		 		end
		 	end
	 		--if not IsLightningResist(target) then
	 			ability:ApplyDataDrivenModifier(caster, target, "modifier_zhuge_thunder_storm_debuff", {})
	 			local stack = target:GetModifierStackCount("modifier_zhuge_thunder_storm_debuff", caster) or 0 
	 			target:SetModifierStackCount("modifier_zhuge_thunder_storm_debuff", caster, stack + 1)
	 		--end
	 	--end
 	end
end

function OnThunderStormStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local position = ability:GetCursorPosition()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local lightning_dmg = ability:GetSpecialValueFor("lightning_dmg")
	local lightning_count = ability:GetSpecialValueFor("lightning_count")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local interval = 0.4

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zhuge_thunder_storm_cooldown", {Duration = ability:GetCooldown(ability:GetLevel())})
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("zhuge_liang_combo")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	caster:RemoveModifierByName("modifier_zhuge_thunder_storm_window")

	local thunder_count = 0
	Timers:CreateTimer(cast_delay/2, function()
		if caster:HasModifier("modifier_alternate_01") then 
			EmitGlobalSound("Waver.Combo")
		else
			EmitGlobalSound("ZhugeLiang.Combo")
		end
	end)

	local cloudFx = {}
	for i = 1,4 do 
		local cloud_pos = GetRotationPoint(position, radius * 0.5, 90 * i)
		cloudFx[i] = ParticleManager:CreateParticle("particles/custom/zhuge_liang/kongming_rain_storm_cloud.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(cloudFx[i], 0, cloud_pos + Vector(0,0,300))
	end
	EmitGlobalSound("Hero_Zuus.Cloud.Cast")

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then 
			Timers:CreateTimer("zhuge_combo" .. caster:GetPlayerOwnerID(), {
				endTime = interval,
				callback = function()

				if not caster:IsAlive() or thunder_count > lightning_count then 
					for i = 1,4 do
						ParticleManager:DestroyParticle(cloudFx[i], true)
						ParticleManager:ReleaseParticleIndex(cloudFx[i])
					end
					StopGlobalSound("Hero_Zuus.Cloud.Cast")
					return nil 
				end

				ThunderStrike(caster, ability, RandomPointInCircle(position, radius), lightning_dmg, lightning_aoe)
				ThunderStrike(caster, ability, RandomPointInCircle(position, radius), lightning_dmg, lightning_aoe)

				thunder_count = thunder_count + 2 
				
				return interval - (thunder_count * 0.01)
			end})
		end
	end)
end

function OnTerritoryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTerritoryAcquired) then

		if hero:HasModifier("modifier_zhuge_thunder_storm_window") then 
			hero:RemoveModifierByName("modifier_zhuge_thunder_storm_window")
		end

		hero.IsTerritoryAcquired = true

		if string.match(hero:GetAbilityByIndex(5):GetAbilityName(), "zhuge_liang_array") then 
			UpgradeAttribute(hero, "zhuge_liang_array", "zhuge_liang_array_upgrade", true)
		else
			UpgradeAttribute(hero, "zhuge_liang_array", "zhuge_liang_array_upgrade", false)
		end

		hero.RSkill = "zhuge_liang_array_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAlchemistAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAlchemistAcquired) then

		hero.IsAlchemistAcquired = true

		if hero:HasModifier("modifier_zhuge_liang_alchemist_check") then 
			UpgradeAttribute(hero, "zhuge_liang_heal_pot", "zhuge_liang_heal_pot_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_mana_pot", "zhuge_liang_mana_pot_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_accel_pot", "zhuge_liang_accel_pot_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_acid_pot", "zhuge_liang_acid_pot_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_alchemist", "zhuge_liang_alchemist_upgrade", false)
		else
			UpgradeAttribute(hero, "zhuge_liang_heal_pot", "zhuge_liang_heal_pot_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_mana_pot", "zhuge_liang_mana_pot_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_accel_pot", "zhuge_liang_accel_pot_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_acid_pot", "zhuge_liang_acid_pot_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_alchemist", "zhuge_liang_alchemist_upgrade", true)
		end

		hero:FindAbilityByName("zhuge_liang_alchemist_upgrade"):EndCooldown()

		hero.DSkill = "zhuge_liang_alchemist_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnStratagemsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsStratagemsAcquired) then

		hero.IsStratagemsAcquired = true

		if hero:HasModifier("modifier_zhuge_liang_strat_command_check") then 
			UpgradeAttribute(hero, "zhuge_liang_rock_fall", "zhuge_liang_rock_fall_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_fire_arrow", "zhuge_liang_fire_arrow_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_flood", "zhuge_liang_flood_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_wind", "zhuge_liang_wind_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_wood_trap", "zhuge_liang_wood_trap_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_strat_command", "zhuge_liang_strat_command_upgrade", false)
		else
			UpgradeAttribute(hero, "zhuge_liang_rock_fall", "zhuge_liang_rock_fall_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_fire_arrow", "zhuge_liang_fire_arrow_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_flood", "zhuge_liang_flood_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_wind", "zhuge_liang_wind_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_wood_trap", "zhuge_liang_wood_trap_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_strat_command", "zhuge_liang_strat_command_upgrade", true)
		end

		hero.WSkill = "zhuge_liang_strat_command_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnLetterAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLetterAcquired) then

		hero.IsLetterAcquired = true

		if hero:HasModifier("modifier_zhuge_liang_war_command_check") then 
			UpgradeAttribute(hero, "zhuge_liang_ambush", "zhuge_liang_ambush_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_offense", "zhuge_liang_offense_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_defense", "zhuge_liang_defense_upgrade", true)
			UpgradeAttribute(hero, "zhuge_liang_war_command", "zhuge_liang_war_command_upgrade", false)
		else
			UpgradeAttribute(hero, "zhuge_liang_ambush", "zhuge_liang_ambush_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_offense", "zhuge_liang_offense_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_defense", "zhuge_liang_defense_upgrade", false)
			UpgradeAttribute(hero, "zhuge_liang_war_command", "zhuge_liang_war_command_upgrade", true)
		end

		hero.ESkill = "zhuge_liang_war_command_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDiscernEyeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDiscernEyeAcquired) then

		hero.IsDiscernEyeAcquired = true

		if string.match(hero:GetAbilityByIndex(4):GetAbilityName(), "zhuge_liang_discern_eye") then 
			UpgradeAttribute(hero, "zhuge_liang_discern_eye", "zhuge_liang_discern_eye_upgrade", true)
		else
			UpgradeAttribute(hero, "zhuge_liang_discern_eye", "zhuge_liang_discern_eye_upgrade", false)
		end

		hero.FSkill = "zhuge_liang_discern_eye_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end