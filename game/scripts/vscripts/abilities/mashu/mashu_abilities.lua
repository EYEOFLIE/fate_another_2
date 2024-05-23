function OnProtectCastStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local cast_delay = ability:GetSpecialValueFor("cast_delay")

	Timers:CreateTimer(cast_delay, function()
		if caster.ProtectTarget == nil then
		    if target == caster then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_mashu_parry", {})
		    else
				ability:ApplyDataDrivenModifier(caster, target, "modifier_mashu_protect", {})
		    end
	    	caster.ProtectTarget = keys.target
		else
			if caster.ProtectTarget:HasModifier("modifier_mashu_protect") then
		    	caster.ProtectTarget:RemoveModifierByName("modifier_mashu_protect")
		    end
		    if caster.ProtectTarget:HasModifier("modifier_mashu_parry") then
		    	caster.ProtectTarget:RemoveModifierByName("modifier_mashu_parry") 
		    end

	    	caster.ProtectTarget = keys.target
		    if target == caster then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_mashu_parry", {})
		    else
				ability:ApplyDataDrivenModifier(caster, target, "modifier_mashu_protect", {})
		    end
	   	end
	end)
end

function MashuCheckCombo(caster, ability)
	--print(ability:GetAbilityName())
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if string.match(ability:GetAbilityName(), "mashu_snowflake") and not caster:HasModifier("modifier_mashu_combo_cooldown") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 3})
		end
    end
end

function OnComboWindow(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.RSkill, "mashu_combo", false, true)
end

function OnComboWindowBroken(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.RSkill, "mashu_combo", true, false)
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_combo_window")
end

function OnUltUp(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local hero = caster.HeroUnit

	if caster.Barrel then
		caster:FindAbilityByName("mashu_punishment_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("mashu_punishment"):SetLevel(ability:GetLevel())
	end
end

function OnProtectionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if caster.ShieldAmount <= 0 then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(200))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Shield")
		return 
	end

	if caster:HasModifier("modifier_mashu_shield_break_cooldown") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(200))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Shield_Break")
		return 
	end

	if target == caster then 
		OnShieldMode(caster, ability)
	else 
		local speed = ability:GetSpecialValueFor("speed")
		local shielder = Physics:Unit(caster) 
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_3, rate=2.0})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_protect_dash", {Duration = 1})
		caster:OnHibernate(function(unit)
			caster:SetPhysicsVelocity((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * speed)
		   	caster:PreventDI()
		   	caster:SetPhysicsFriction(0)
		   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		   	caster:FollowNavMesh(false)	
		   	caster:SetAutoUnstuck(false)

		   	caster:OnPhysicsFrame(function(unit)
				local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
				local dir = diff:Normalized()
				diff.z = 0
				caster:SetForwardVector(diff)
				if diff:Length() < 150 or not caster:HasModifier("modifier_mashu_protect_dash") then
				  	caster:RemoveModifierByName("modifier_mashu_protect_dash")
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					unit:OnHibernate(nil)
					unit:SetAutoUnstuck(true)
					ExecuteOrderFromTable({UnitIndex = caster:entindex(),OrderType = DOTA_UNIT_ORDER_STOP,})
			        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			        --[[local nearest_target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
			        if nearest_target[1] == nil then ]]
			        	local forward = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
			        	forward.z = 0 
			        	if target:GetAbsOrigin() == caster:GetAbsOrigin() then 
							forward = caster:GetForwardVector() 
						end
			        	caster:SetForwardVector(forward)
			        	if caster:IsAlive() then
			        		OnShieldMode(caster, ability)
			        	end
			        --[[else
			        	local diff = (nearest_target[1]:GetAbsOrigin() - target:GetAbsOrigin() ):Normalized() 
						caster:SetAbsOrigin(target:GetAbsOrigin() + diff*100) 
						local forward = (nearest_target[1]:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
			        	forward.z = 0 
			        	caster:SetForwardVector(forward)
			        	OnShieldMode(caster, ability)
			        end]]
			    end
			end)
		end)
	end
end

function OnShieldBeamDeath(keys)
	local shield = keys.caster 
	local hero = shield:GetOwner()
	local radius = hero:FindAbilityByName(hero.WSkill):GetSpecialValueFor("protect_radius")
	hero:RemoveModifierByName("modifier_mashu_protect_self")
	hero:FindAbilityByName(hero.WSkill):ApplyDataDrivenModifier(hero, hero, "modifier_mashu_shield_break_cooldown", {})
	local allies = FindUnitsInRadius(hero:GetTeam(), shield:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for k,v in pairs(allies) do 
		if v:IsRealHero() then 
			hero:FindAbilityByName(hero.WSkill):ApplyDataDrivenModifier(hero, v, "modifier_mashu_beam_dummy_track", {})
		end
	end
end

function OnShieldDamaged(keys)
	local shield = keys.caster 
	local hero = shield:GetOwner()
	local damage = keys.DamageTaken
	AddShield(hero, -damage)
end

function OnShieldPush(keys)
	local shield = keys.caster 
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("protect_radius")
	local target = keys.target
	local dist = (target:GetAbsOrigin() - shield:GetAbsOrigin()):Length2D()
	if dist < radius then 
		local diff = (target:GetAbsOrigin() - shield:GetAbsOrigin()):Normalized()
		target:SetAbsOrigin(target:GetAbsOrigin() + (diff * (radius - dist)))
		FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )	
	end
end

function OnShieldAttacked(keys)
	local attacker = keys.attacker 
	local shield_dummy = keys.caster 
	local attack_damage = attacker:GetAverageTrueAttackDamage(attacker)
	--attacker:PerformAttack(shield_dummy, false, false, true, true)
	local dmgtable = {
	    attacker = attacker,
	    victim = shield_dummy,
	    damage = attack_damage,
	    damage_type = DAMAGE_TYPE_PHYSICAL,
	    damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
	}
	ApplyDamage(dmgtable)
end

function OnShieldMode(caster, ability)
	local radius = ability:GetSpecialValueFor("protect_radius")
	local caster_angle = caster:GetAnglesAsVector().y
	local protect_zone_origin = GetRotationPoint(caster:GetAbsOrigin(), radius - 50, caster_angle - 180)
	local protect_shield_origin = GetRotationPoint(caster:GetAbsOrigin(), 100, caster_angle)
	local shield_angle = caster_angle
	if shield_angle > 180 then 
		shield_angle = shield_angle - 360
	end
	if caster.shield_dummy == nil then
		caster.shield_dummy = CreateUnitByName("mashu_shield_dummy", protect_zone_origin, false, caster, caster, caster:GetTeamNumber())
		caster.shield_dummy:FindAbilityByName("mashu_dummy_shield_passive"):SetLevel(1)
		caster.shield_dummy:SetDayTimeVisionRange(1)
		caster.shield_dummy:SetNightTimeVisionRange(1)
		caster.shield_dummy:SetOwner(caster)
	end
	caster.shield_dummy:SetForwardVector(caster:GetForwardVector())
	caster.shield_dummy:CreatureLevelUp(caster:GetLevel()-1)
	caster.shield_dummy:SetHealth(caster.ShieldAmount)
	caster.zone = ParticleManager:CreateParticleForTeam("particles/custom/nursery_rhyme/nursery_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.shield_dummy, caster.shield_dummy:GetTeamNumber())
	ParticleManager:SetParticleControl(caster.zone, 0, caster.shield_dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster.zone, 1, Vector(radius,0,0))
	caster.shieldfx = ParticleManager:CreateParticle("particles/mashu/mashu_protect.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	ParticleManager:SetParticleControl(caster.shieldfx, 0, caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt(caster.shieldfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
	--ParticleManager:SetParticleControl(caster.shieldfx, 2, protect_shield_origin)
	--ParticleManager:SetParticleControl(caster.shieldfx, 1, Vector(0,shield_angle,0))

	caster.shield_dummy:SetAbsOrigin(protect_zone_origin)
	caster:RemoveModifierByName("modifier_mashu_shield_stop")
	--StartAnimation(caster, {duration=120, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_protect_self", {})
	--ability:ApplyDataDrivenModifier(caster, caster.protect_zone_dummy, "modifier_mashu_protect_aura", {})
	local shield_abi = caster:FindAbilityByName(caster.DSkill)
	shield_abi:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_shield_stop", {})
end

function OnShieldMove(keys)
	local shield = keys.caster
	local ability = keys.ability
	local hero = shield:GetOwner()
	local radius = ability:GetSpecialValueFor("protect_radius")
	local caster_angle = hero:GetAnglesAsVector().y
	local protect_zone_origin = GetRotationPoint(hero:GetAbsOrigin(), radius - 50, caster_angle - 180)
	local protect_shield_origin = GetRotationPoint(hero:GetAbsOrigin(), 100, caster_angle)
	local shield_angle = caster_angle
	if shield_angle > 180 then 
		shield_angle = shield_angle - 360
	end
	shield:SetAbsOrigin(protect_zone_origin)
	ParticleManager:SetParticleControl(hero.shieldfx, 0, hero:GetForwardVector())
	ParticleManager:SetParticleControlEnt(hero.shieldfx, 1, hero, PATTACH_ABSORIGIN_FOLLOW, nil, hero:GetAbsOrigin(), false)
	--ParticleManager:SetParticleControlEnt(caster.shieldfx, 0, caster, PATTACH_POINT_FOLLOW	, "attach_hitloc", caster:GetAbsOrigin(),false)
	--ParticleManager:SetParticleControl(caster.shieldfx, 2, protect_shield_origin)
	--ParticleManager:SetParticleControl(caster.shieldfx, 1, Vector(0,shield_angle,0))
end

function OnShieldCreate(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.WSkill, "mashu_protect_stop", false, true)
	caster:FindAbilityByName("mashu_protect_stop"):StartCooldown(1.0)
end

function OnShieldDestroy(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.WSkill, "mashu_protect_stop", true, false)
	ParticleManager:DestroyParticle(caster.zone, true)
	ParticleManager:ReleaseParticleIndex(caster.zone)
	ParticleManager:DestroyParticle(caster.shieldfx, true)
	ParticleManager:ReleaseParticleIndex(caster.shieldfx)
	--EndAnimation(caster)
	caster:RemoveModifierByName("modifier_mashu_shield_stop")
	local shield_abi = caster:FindAbilityByName(caster.DSkill)
	shield_abi:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_shield_stop", {Duration = shield_abi:GetSpecialValueFor("shield_regen_time")})
	if IsValidEntity(caster.shield_dummy) then 
		caster.shield_dummy:RemoveSelf()
		caster.shield_dummy = nil 
	end
end

function ShieldStop(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_mashu_protect_self")
end

function OnShieldGainThink(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_mashu_shield_stop") or caster:HasModifier("modifier_mashu_shield_break_cooldown") then 
		return 
	end

	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName(caster.DSkill)
	end

	local shield_amount_regen = ability:GetSpecialValueFor("shield_amount_regen")
	AddShield(caster, shield_amount_regen)
end

function OnShieldRespawn(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if ability == nil then
	 	ability = caster:FindAbilityByName(caster.DSkill)
	end
	local max_shield = ability:GetSpecialValueFor("max_shield")

	AddShield(caster, caster.max_shield)
end

function AddShield(caster, amount)
	local ability = caster:FindAbilityByName(caster.DSkill)
	local base_shield = ability:GetSpecialValueFor("base_shield")
	local bonus_shield = ability:GetSpecialValueFor("bonus_lvl_shield")
	caster.max_shield = base_shield + (bonus_shield * caster:GetLevel())

	if caster.ShieldAmount == nil then 
		caster.ShieldAmount = 0 
	end

	caster.ShieldAmount = math.max(math.min(caster.ShieldAmount + amount, caster.max_shield),0)
	caster:SetModifierStackCount("modifier_mashu_passive_shield", caster, caster.ShieldAmount)
	if caster.ShieldAmount == 0 then 
		caster:RemoveModifierByName("modifier_mashu_protect_self")
	end
end

function OnShieldResume(keys)
	local caster = keys.caster 
	local shield = caster:FindAbilityByName(caster.DSkill)
	shield:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_shield_buff", {})
end

function OnProtectProc(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = caster.ProtectTarget
    local max_range = ability:GetSpecialValueFor("max_range")
    local damage_proc = ability:GetSpecialValueFor("damage_proc")
    local mana_restore = ability:GetSpecialValueFor("mana_restore")
    local invul = ability:GetSpecialValueFor("invul")
    local red_cooldown = ability:GetSpecialValueFor("red_cooldown")
    local aoe = ability:GetSpecialValueFor("aoe")
    local damage = ability:GetSpecialValueFor("damage")

	if keys.DamageTaken >= 50 then
		if target:HasModifier("modifier_mashu_parry") then
    		target:RemoveModifierByName("modifier_mashu_parry") 
			giveUnitDataDrivenModifier(caster, caster, "jump_pause", invul)
		end

		if target:HasModifier("modifier_mashu_protect") then
    		target:RemoveModifierByName("modifier_mashu_protect") 
			giveUnitDataDrivenModifier(caster, caster, "jump_pause", invul)
			caster:SetAbsOrigin(target:GetAbsOrigin())		
		end

		local reviveFx = ParticleManager:CreateParticle("particles/mashu/mashuw/mashuw.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 0, caster:GetAbsOrigin())

		StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK2, rate=1.1})

    	caster:EmitSound("Mashu.W" .. math.random(1,2))
    	caster:EmitSound("Mashu.WPop1")
    	caster:EmitSound("Mashu.WPop2")

		caster:GiveMana(mana_restore)
		ability:StartCooldown(ability:GetCooldownTimeRemaining() - red_cooldown)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	       		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)	       	
	       	end
	    end
	end
end

function OnProtectThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = caster.ProtectTarget
    local max_range = ability:GetSpecialValueFor("max_range")
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 

	if distance > max_range then
		if target:HasModifier("modifier_mashu_parry") then
    		target:RemoveModifierByName("modifier_mashu_parry") 
		end

		if target:HasModifier("modifier_mashu_protect") then
    		target:RemoveModifierByName("modifier_mashu_protect") 
		end	
	end
end

function ProtectParticleCreate(keys)
	local caster = keys.caster
	local target = keys.target
	local radius = keys.ability:GetSpecialValueFor("protect_radius")
	local zone = ParticleManager:CreateParticleForTeam("particles/custom/nursery_rhyme/nursery_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, target:GetTeamNumber())
	ParticleManager:SetParticleControl(zone, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(zone, 1, Vector(radius,0,0))
end

function OnMashuTaunt(keys)
	local caster = keys.caster 
	local ability = keys.ability 
    local radius = ability:GetSpecialValueFor("radius")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local channel_time = ability:GetSpecialValueFor("channel_time")
    caster:RemoveModifierByName("modifier_mashu_protect_self")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", channel_time)
	StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.8})

    caster:EmitSound("Mashu.E" .. math.random(1,4))

	Timers:CreateTimer(cast_delay, function()
    	caster:EmitSound("Mashu.EPop1")
    	caster:EmitSound("Mashu.EPop2")

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_dmg_reduc", {})

		local reviveFx = ParticleManager:CreateParticle("particles/mashu/mashue.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 0, caster:GetAbsOrigin())

		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				ability:ApplyDataDrivenModifier(caster, v, "modifier_mashu_taunt", {})
				v:MoveToTargetToAttack(caster)

				if caster.Amalgam then
   					local damage_from_max_health = ability:GetSpecialValueFor("damage_from_max_health")
	       			DoDamage(caster, v, caster:GetMaxHealth() * damage_from_max_health, DAMAGE_TYPE_MAGICAL, 0, ability, false)	    
				end
	       	end
	    end
	end)
end

function OnMashuTauntThink(keys)
	local unit = keys.target 
	local caster = keys.caster 
	local ability = keys.ability

	if caster:IsAlive() then
	    local particle = ParticleManager:CreateParticle("particles/mashu/mashu_taunted.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	    ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
		unit:MoveToTargetToAttack(caster)
   	else
		unit:RemoveModifierByName("modifier_mashu_taunt")
   	end
end

function OnMashuTauntDestroy(keys)
	local unit = keys.target 
	unit:SetForceAttackTarget(nil)	
end

function OnBunkerBolt(keys)
	local caster = keys.caster
	local ability = keys.ability
	local dash_back = ability:GetSpecialValueFor("range")
	local dash_duration = ability:GetSpecialValueFor("dash_duration")

	local dashback = Physics:Unit(caster)
	local origin = caster:GetOrigin()
	local backward = caster:GetForwardVector()
	caster:RemoveModifierByName("modifier_mashu_protect_self")
	--StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.75})

    caster:EmitSound("Mashu.QStart")

	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(backward * dash_back * 1.5)
   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", dash_duration)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_bunker_bolting", {})
end

function OnBunkerBoltThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius_detect = ability:GetSpecialValueFor("radius_detect")

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius_detect, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	if targets[1] == nil then 
		return 
	else
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.0})
		local forward = (targets[1]:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() 
		forward.z = 0 
		caster:SetForwardVector(forward)
		caster:RemoveModifierByName("modifier_mashu_bunker_bolting")

		local damage = ability:GetSpecialValueFor("damage")
		local aoe = ability:GetSpecialValueFor("aoe")
		local stun_duration = ability:GetSpecialValueFor("stun_duration")
		local bonus_dmg = 0

		if caster.Barrel then
	   		bonus_dmg = ability:GetSpecialValueFor("damage_per_strength") * caster:GetStrength() 
		end

		local reviveFx = ParticleManager:CreateParticle("particles/mashu/mashuq/mashuq.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 0, caster:GetAbsOrigin())

		DoDamage(caster, targets[1], damage + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		targets[1]:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})

		caster:EmitSound("Mashu.Q" .. math.random(1,4))
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.QPop", {})
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.QPop2", {})

		local targets2 = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets2) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and v ~= targets[1] then
				DoDamage(caster, v, damage + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)

    			if not IsImmuneToCC(v) and not IsImmuneToSlow(v) then 
    				ability:ApplyDataDrivenModifier(caster, v, "modifier_mashu_bunker_bolt_slow", {})
    			end
    		end
    	end
    end

	--[[for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			if not IsAnim then 
				local IsAnim = true 
				StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.0})
			end
		    caster:RemoveModifierByName("modifier_mashu_bunker_bolting")

			local damage = ability:GetSpecialValueFor("damage")
			local aoe = ability:GetSpecialValueFor("aoe")
			local stun_duration = ability:GetSpecialValueFor("stun_duration")

			local targets2 = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets2) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				    caster:RemoveModifierByName("modifier_mashu_bunker_bolting")

					local reviveFx = ParticleManager:CreateParticle("particles/mashu/mashuq/mashuq.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(reviveFx, 0, caster:GetAbsOrigin())

    				caster:EmitSound("Mashu.Q" .. math.random(1,4))
					EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.QPop", {})
					EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.QPop2", {})

					if caster.Barrel then
	   					local damage_per_strength = ability:GetSpecialValueFor("damage_per_strength")
		       			DoDamage(caster, v, damage + caster:GetStrength() * damage_per_strength, DAMAGE_TYPE_MAGICAL, 0, ability, false)	    
					else
						DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end

					v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		       	end
		    end
		    print("damage dealt once")
		    return
		end
	end]]
end

function OnBunkerBoltDeath(keys)
	local caster = keys.caster

	caster:PreventDI(false)
	caster:SetPhysicsVelocity(Vector(0,0,0))
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function OnMashuUlt(keys)
	local caster = keys.caster 
	local ability = keys.ability 
    local radius = ability:GetSpecialValueFor("radius")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local active_instant_heal = ability:GetSpecialValueFor("active_instant_heal")
    local channel_time = ability:GetSpecialValueFor("channel_time")
    local invul = ability:GetSpecialValueFor("invul")
    local ally_invul = ability:GetSpecialValueFor("ally_invul")
    local AllyInvul = false
    caster:RemoveModifierByName("modifier_mashu_protect_self")
	local eff = ParticleManager:CreateParticle("particles/mashu/mashur/mashur1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(eff, 0, caster:GetAbsOrigin())


	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", channel_time)
	StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.8})
    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4 , 0.8)

	Timers:CreateTimer(cast_delay, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_snowflake_self_invul", {})
		--giveUnitDataDrivenModifier(caster, caster, "jump_pause", invul)
	    EmitGlobalSound("Mashu.R" .. math.random(1,2))
	end)

	Timers:CreateTimer(channel_time, function()
		--HardCleanse(caster)
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.RPop1", {})
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.RPop2", {})
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin() , "Mashu.RPop3", {})

		ParticleManager:DestroyParticle( eff, true )

		local reviveFx = ParticleManager:CreateParticle("particles/mashu/mashur/particlepop/mashur-pop1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 0, caster:GetAbsOrigin())

		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				ability:ApplyDataDrivenModifier(caster, v, "modifier_mashu_snowflake", {})
				v:FateHeal(active_instant_heal, caster, true)
				if v ~= caster and caster.Chalk and not AllyInvul then 
					AllyInvul = true 
					ability:ApplyDataDrivenModifier(caster, v, "modifier_mashu_snowflake_invul", {})
				end
			end
	    end
	    MashuCheckCombo(caster,ability)
	end)	
end

function OnMashuPunishment(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local speed = ability:GetSpecialValueFor("projectile_speed")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local width = ability:GetSpecialValueFor("width")
	local length = ability:GetSpecialValueFor("throw_length")
	local target_point = ability:GetCursorPosition()
	caster:RemoveModifierByName("modifier_mashu_protect_self")
	--giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.3 + cast_delay)
	StartAnimation(caster, {duration=0.9, activity=ACT_DOTA_ATTACK, rate=1.5})

	Timers:CreateTimer(cast_delay, function()

	    EmitGlobalSound("Mashu.DFStart")

		if caster:IsAlive() then
			local Arrow =
			{
				Ability = keys.ability,
		        EffectName = "particles/mashu/mashudf/shieldproj.vpcf",
		        iMoveSpeed = 9999,
		        vSpawnOrigin = caster:GetOrigin(),
		        fDistance = length,
		        fStartRadius = width,
		        fEndRadius = width,
		        Source = caster,
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		        fExpireTime = GameRules:GetGameTime() + 3.0,
				bDeleteOnHit = true,
				vVelocity = caster:GetForwardVector() * speed,
			}
			ProjectileManager:CreateLinearProjectile(Arrow)
			if caster.Defense and not caster:HasModifier("modifier_mashu_smash_cooldown") then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_smash_window", {})
			end
		end
	end)
end

function OnPunishmentHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")
	local stun_revoke = ability:GetSpecialValueFor("stun_revoke")

	local particle = ParticleManager:CreateParticle("particles/mashu/mashudf/pop/mashudfpop1.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())	

	EmitGlobalSound("Mashu.DFPop1")
	EmitGlobalSound("Mashu.DFPop2")

	giveUnitDataDrivenModifier(caster, target, "pause_sealdisabled", stun_revoke + 0.12)
	if caster.Barrel then
		local damage_per_strength = ability:GetSpecialValueFor("damage_per_strength")
   		DoDamage(caster, target, damage + (caster:GetStrength() * damage_per_strength), DAMAGE_TYPE_MAGICAL, 0, ability, false)	    
	else
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end

	--[[if caster:IsAlive() then
	    EmitGlobalSound("Mashu.DF" .. math.random(1,3))

	    EmitGlobalSound("Mashu.DFPop1")
	    EmitGlobalSound("Mashu.DFPop2")

		local particle = ParticleManager:CreateParticle("particles/mashu/mashudf/pop/mashudfpop1.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())		

		caster:SetAbsOrigin(target:GetAbsOrigin())		
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.8})


		giveUnitDataDrivenModifier(caster, target, "pause_sealdisabled", stun_revoke + 0.12)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", stun_revoke - 0.12)

		if caster.Barrel then
			local damage_per_strength = ability:GetSpecialValueFor("damage_per_strength")
   			DoDamage(caster, target, damage + caster:GetStrength() * damage_per_strength, DAMAGE_TYPE_MAGICAL, 0, ability, false)	    
		else
			DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end]]
end

function OnSmashWindow(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.FSkill, "mashu_smash", false, true)
end

function OnSmashWindowBroken(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.FSkill, "mashu_smash", true, false)
end

function OnSmashStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local dist = math.max(0, ((caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6) - 170)
	local castRange = ability:GetSpecialValueFor("cast_range")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local radius = ability:GetSpecialValueFor("radius")
	local bonus_def_dmg = ability:GetSpecialValueFor("bonus_def_dmg")
	local bonus_shield_dmg = ability:GetSpecialValueFor("bonus_shield_dmg")
	local stun = ability:GetSpecialValueFor("stun")
	local damage = base_damage + (bonus_def_dmg * caster:GetPhysicalArmorValue(false)) + (bonus_shield_dmg * caster.ShieldAmount)

	-- When you exit the ubw on the last moment, dist is going to be a pretty high number, since the targetPoint is on ubw but you are outside it
	-- If it's, then we can't use it like that. Either cancel Overedge, or use a default one.
	-- 2000 is a fixedNumber, just to check if dist is not valid. Over 2000 is surely wrong. (Max is close to 900)
	if dist > 2000 then
		dist = math.max(0, castRange - 170)  --Default one
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	caster:RemoveModifierByName("modifier_mashu_smash_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_smash_cooldown", {Duration = ability:GetCooldown(1)})
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
	StartAnimation(caster, {duration=0.65, activity=ACT_DOTA_CAST_ABILITY_3, rate=2.0})
    local mashu = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 4000))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-13333))

	--caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 

	

	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		caster:EmitSound("Hero_Centaur.HoofStomp") 
		caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	-- Stomp
		local stompParticleIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_stomp_magical.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( stompParticleIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( stompParticleIndex, 1, Vector( radius, radius, radius ) )
		
	-- Destroy particle
		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( stompParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( stompParticleIndex )
		end)

        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				if not v:IsMagicImmune() and not IsImmuneToCC(v) then 
		       		v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})	       			
		       	end
	       	end
	    end
	end})
end


function OnMashuCombo(keys)
	local caster = keys.caster 
	local ability = keys.ability 
    local radius = ability:GetSpecialValueFor("radius")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local channel_time = ability:GetSpecialValueFor("channel_time")
    local active_instant_heal = ability:GetSpecialValueFor("active_instant_heal")
    local invul = ability:GetSpecialValueFor("invul")
    caster:RemoveModifierByName("modifier_mashu_protect_self")
	local masterCombo = caster.MasterUnit2:FindAbilityByName("mashu_combo")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_combo_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster:RemoveModifierByName("modifier_combo_window")
	local angle = caster:GetAnglesAsVector().y

	local charging = ParticleManager:CreateParticle("particles/mashu/mashucombo/mashucombochannel.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(charging, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(charging, 1, Vector(0,angle,0))

	EmitGlobalSound("Mashu.Combo1")
	EmitGlobalSound("Mashu.ComboCharging1")
	EmitGlobalSound("Mashu.ComboCharging2")
	EmitGlobalSound("Mashu.ComboCharging3")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mashu_combo_chanting", {})

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", channel_time)
	StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.8})


	Timers:CreateTimer(0.95, function()
		FreezeAnimation(caster,6)
	end)


	Timers:CreateTimer(2.2, function()
		if caster:IsAlive() then
		EmitGlobalSound("Mashu.ComboShieldAppear")
		EmitGlobalSound("Mashu.ComboShieldAppear2")
		else
			ParticleManager:DestroyParticle( charging, true )
		end
	end)	

	Timers:CreateTimer(4.3, function()
		if caster:IsAlive() then
		EmitGlobalSound("Mashu.ComboShieldAppear")
		EmitGlobalSound("Mashu.ComboShieldAppear2")
		else
			ParticleManager:DestroyParticle( charging, true )
		end
	end)	

	Timers:CreateTimer(0.1, function()
		if caster:IsAlive() then
		EmitGlobalSound("Mashu.ComboShieldAppear")
		EmitGlobalSound("Mashu.ComboShieldAppear2")
		else
			ParticleManager:DestroyParticle( charging, true )
		end
	end)

	Timers:CreateTimer(2, function()
		if caster:IsAlive() then
			EmitGlobalSound("Mashu.Combo2")
		else
			ParticleManager:DestroyParticle( charging, true )
		end
	end)

	Timers:CreateTimer(5, function()
		if caster:IsAlive() then
			EmitGlobalSound("Mashu.Combo3")
		else
			ParticleManager:DestroyParticle( charging, true )
		end
	end)

	Timers:CreateTimer(channel_time, function()
		if caster:IsAlive() then

			EmitGlobalSound("Mashu.ComboPop")
			EmitGlobalSound("Mashu.ComboPop2")

			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					ability:ApplyDataDrivenModifier(caster, v, "modifier_mashu_combo", {Duration = 120})
					v:FateHeal(active_instant_heal, caster, true)

    				local barrier_amount = ability:GetSpecialValueFor("barrier_amount")
					ability:ApplyDataDrivenModifier(v, v, "modifier_mashu_combo_barrier", {Duration = 120})
					stack = v:GetModifierStackCount("modifier_mashu_combo_barrier", v) or 0
					v:SetModifierStackCount("modifier_mashu_combo_barrier", v,barrier_amount)

					local fx = ParticleManager:CreateParticle("particles/mashu/mashucombo/mashucombopop.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControl(fx, 0, v:GetAbsOrigin())
				end
		    end
		end
	end)	
end

function OnBarrierDamaged(keys)
	local caster = keys.caster 
	local unit = keys.unit 
	local currentHealth = unit:GetHealth() 

	stack = unit:GetModifierStackCount("modifier_mashu_combo_barrier", unit) or 0
	stack = stack - keys.DamageTaken
	unit:SetModifierStackCount("modifier_mashu_combo_barrier", unit,stack)

	if stack <= 0 then
		if currentHealth + stack <= 0 then
		else
			unit:RemoveModifierByName("modifier_mashu_combo_barrier")
			unit:SetHealth(currentHealth + keys.DamageTaken + stack)
			stack = 0
		end
	else
		unit:SetHealth(currentHealth + keys.DamageTaken)
	end
end

function OnBarrelUpgrade(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Barrel) then
		hero.Barrel = true

		UpgradeAttribute(hero, "mashu_bunker_bolt", "mashu_bunker_bolt_upgrade" , true)
		hero.QSkill = "mashu_bunker_bolt_upgrade"
		UpgradeAttribute(hero, "mashu_punishment", "mashu_punishment_upgrade" , true)
		hero.FSkill = "mashu_punishment_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnShieldUpgrade(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Shield) then
		hero.Shield = true

		if hero:HasModifier("modifier_mashu_protect_self") then
			hero:RemoveModifierByName("modifier_mashu_protect_self")
		end

		UpgradeAttribute(hero, "mashu_w", "mashu_w_upgrade" , true)
		hero.WSkill = "mashu_w_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnChalkUpgrade(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Chalk) then
		hero.Chalk = true

		if hero:HasModifier("modifier_combo_window") then
			hero:RemoveModifierByName("modifier_combo_window")
		end
		hero:RemoveModifierByName("modifier_mashu_snowflake_passive")
		UpgradeAttribute(hero, "mashu_snowflake", "mashu_snowflake_upgrade" , true)
		hero.RSkill = "mashu_snowflake_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAmalgamUpgrade(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Amalgam) then
		hero.Amalgam = true

		UpgradeAttribute(hero, "mashu_taunt", "mashu_taunt_upgrade" , true)
		hero.ESkill = "mashu_taunt_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDefenseUpgrade(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Defense) then
		hero.Defense = true

		
		UpgradeAttribute(hero, "mashu_shield", "mashu_shield_upgrade" , true)
		hero.DSkill = "mashu_shield_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
