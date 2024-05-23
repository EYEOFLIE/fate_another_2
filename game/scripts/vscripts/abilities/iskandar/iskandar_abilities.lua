function OnSpathaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local root = ability:GetSpecialValueFor("root")

	EmitSoundOnLocationWithCaster(target_loc, "Hero_Zuus.LightningBolt", caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_isk_spatha_cooldown", {Duration = ability:GetCooldown(1)})

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle2, 0, target_loc)
    ParticleManager:SetParticleControl(particle2, 1, target_loc)
    ParticleManager:SetParticleControl(particle2, 2, target_loc)
    Timers:CreateTimer( 0.5, function()
    	local particle3 = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_spatha.vpcf", PATTACH_CUSTOMORIGIN, caster)
	    ParticleManager:SetParticleControl(particle3, 0, target_loc)
	    ParticleManager:SetParticleControl(particle3, 1, target_loc)
	    ParticleManager:SetParticleControl(particle3, 2, target_loc)
	    ParticleManager:SetParticleControl(particle3, 6, Vector(radius - 50,0,0))
	    Timers:CreateTimer( 1.5, function()
	    	ParticleManager:DestroyParticle( particle3, false )
			ParticleManager:ReleaseParticleIndex( particle3 )
		end)
	end)
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle2, false )
		ParticleManager:ReleaseParticleIndex( particle2 )	
	end)

	local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(enemies) do
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		if not IsLightningResist(v) and not IsImmuneToCC(v) then 
			giveUnitDataDrivenModifier(caster, v, "rooted", root)
		end
	end

end
function OnForwardStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local ply = caster:GetPlayerOwner() 
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
	
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius
        , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			RemoveSlowEffect(v)
			ability:ApplyDataDrivenModifier(caster,v, "modifier_forward", {})
			if v ~= caster and v:IsHero() then
				v:EmitSound("Hero_LegionCommander.Overwhelming.Location")
			elseif v == caster then
				v:EmitSound("Iskander_Charge_" .. math.random(1,5))
			end
		end
    end
end

function OnPhalanxStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local total_number = ability:GetSpecialValueFor("total_number")
	local width = ability:GetSpecialValueFor("width")
	local damage = ability:GetSpecialValueFor("damage")
	if caster.IsBeyondTimeAcquired then
		aotkAbility = caster:FindAbilityByName("iskandar_army_of_the_king_upgrade")
	end
    local targetPoint = ability:GetCursorPosition()
    local forwardVec = caster:GetForwardVector()
    caster.PhalanxSoldiers = {}

	local leftvec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightvec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Spawn soldiers from target point to left end
	for i=0,(total_number / 2) - 1 do
		Timers:CreateTimer(i*0.1, function()
			local soldier = CreateUnitByName("iskandar_infantry", targetPoint + leftvec * (width / total_number) * i, true, nil, nil, caster:GetTeamNumber())
			soldier:SetOwner(caster)
			soldier:SetUnitCanRespawn(false)
			soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
			--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
			if caster.IsBeyondTimeAcquired then
				aotkAbility:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})
				soldier:SetModifierStackCount("modifier_army_of_the_king_infantry_bonus_stat", caster, aotkAbility:GetLevel())
				if caster:HasModifier("modifier_army_of_the_king_death_checker") then 
					caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
				end
			else
				ability:ApplyDataDrivenModifier(caster, soldier, "modifier_phalanx_wall",{})
			end
			
			PhalanxPull(caster, soldier, targetPoint, damage, ability) -- do pullback

			--local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
			--ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
			soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
			if i==0 then
				local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
				ParticleManager:SetParticleControl(particle, 3, targetPoint)
				Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( particle, false )
					ParticleManager:ReleaseParticleIndex( particle )
				end)
			end 
			table.insert(caster.PhalanxSoldiers, soldier)
		end)
	end

	-- Spawn soldiers on right side
	for i=1,total_number / 2 do
		Timers:CreateTimer(i*0.1, function()
			local soldier = CreateUnitByName("iskandar_infantry", targetPoint + rightvec * (width / total_number) * i, true, nil, nil, caster:GetTeamNumber())
			soldier:SetOwner(caster)
			soldier:SetUnitCanRespawn(false)
			soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
			--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
			if caster.IsBeyondTimeAcquired then
				aotkAbility:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})
				soldier:SetModifierStackCount("modifier_army_of_the_king_infantry_bonus_stat", caster, aotkAbility:GetLevel())
			else
				ability:ApplyDataDrivenModifier(caster, soldier, "modifier_phalanx_wall",{})
			end
			PhalanxPull(caster, soldier, targetPoint, damage, ability) -- do pullback

			--local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
			--ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
			soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
			table.insert(caster.PhalanxSoldiers, soldier)
		end)
	end

	caster:EmitSound("Iskander_Skill_" .. math.random(1, 4))
end

function PhalanxPull(caster, soldier, targetPoint, damage, ability)
	local targets = FindUnitsInRadius(caster:GetTeam(), soldier:GetAbsOrigin(), nil, 150
	        , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v.PhalanxSoldiersHit ~= true and v:GetName() ~= "npc_dota_ward_base" then
			v.PhalanxSoldiersHit = true
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			
			Timers:CreateTimer(0.5, function()
				if IsValidEntity(v) and not v:IsNull() then
					v.PhalanxSoldiersHit = false
				end
			end)
			if IsValidEntity(v) and not v:IsNull() and not IsKnockbackImmune(v) and not IsImmuneToCC(v) then
				local pullTarget = Physics:Unit(v)
				local pullVector = (caster:GetAbsOrigin() - targetPoint):Normalized() * 500
				v:PreventDI()
				v:SetPhysicsFriction(0)
				v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 500))
				v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
				v:FollowNavMesh(false)

				Timers:CreateTimer({
					endTime = 0.25,
					callback = function()
					v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -500))
				end
				})

			  	Timers:CreateTimer(0.5, function()
					v:PreventDI(false)
					v:SetPhysicsVelocity(Vector(0,0,0))
					v:OnPhysicsFrame(nil)
				end)
				giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
				local forwardVec = v:GetForwardVector()
				v:SetForwardVector(Vector(forwardVec.x*-1, forwardVec.y, forwardVec.z))
			end
		end
    end
end

function OnChariotStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local delay = ability:GetSpecialValueFor("cast_delay")
	local duration = ability:GetSpecialValueFor("duration")

	if caster.IsRiding == true and caster:HasModifier("modifier_gordius_wheel") then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Already_Riding")
		caster:GiveMana(ability:GetManaCost(ability:GetLevel()))
		ability:EndCooldown() 
		return 
	elseif caster:HasModifier("modifier_army_of_the_king_death_checker") then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Cast_Now")
		caster:GiveMana(ability:GetManaCost(ability:GetLevel()))
		ability:EndCooldown() 
		return 
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", delay)
	StartAnimation(caster, {duration=delay, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.5})

	caster:EmitSound("Hero_Magnataur.Skewer.Cast")
    caster:EmitSound("Hero_Zuus.GodsWrath")
    caster:EmitSound("Iskander_Wheel_" .. math.random(1,3))
    caster.IsRiding = true

    local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin())
    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle3, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle3, 2, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
		ParticleManager:DestroyParticle( particle2, false )
		ParticleManager:ReleaseParticleIndex( particle2 )
		ParticleManager:DestroyParticle( particle3, false )
		ParticleManager:ReleaseParticleIndex( particle3 )
	end)

	Timers:CreateTimer(1.0, function() 
    	if caster:IsAlive() then
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel", {}) 
    	end
    	return
    end)
end

function OnChariotCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local max_damage_radius = ability:GetSpecialValueFor("max_damage_radius")
	local min_damage_radius = ability:GetSpecialValueFor("min_damage_radius")
	local max_damage = ability:GetSpecialValueFor("max_damage")
	local min_damage = ability:GetSpecialValueFor("min_damage")
	local base_ms = caster:GetBaseMoveSpeed()
	local bonus_ms = ability:GetSpecialValueFor("movespeed_per_second") / 100

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_speed_boost", {}) 
	caster:SetModifierStackCount("modifier_gordius_wheel_speed_boost", caster, 1)
	if caster:HasModifier("modifier_padoru") then 

	else
		caster.OriginModel = caster:GetModelName()
		caster.OriginModelSize = caster:GetModelScale()
		if caster:HasModifier("modifier_alternate_01") then 
			caster:SetModel("models/iskandar/salary/iskandar_salary_gordius.vmdl")
	    	caster:SetOriginalModel("models/iskandar/salary/iskandar_salary_gordius.vmdl")
	    	caster:SetModelScale(1.0)
		else
			caster:SetModel("models/iskandar/default/iskandar_gordius.vmdl")
	    	caster:SetOriginalModel("models/iskandar/default/iskandar_gordius.vmdl")
	    	caster:SetModelScale(1.0)
	    end
	end

    if caster.IsVEAcquired then
		if caster:FindAbilityByName("iskandar_via_expugnatio"):IsHidden() then
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "iskandar_via_expugnatio", false, true) 
			caster:FindAbilityByName("iskandar_via_expugnatio"):EndCooldown()
		end
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "fate_empty3", false, true)
	end

	local counter = 0
	caster.BonusChargeDamage = 0
	
   	Timers:CreateTimer(function() 
   		--print("Entering main timer")
   		--print(caster:HasModifier("modifier_gordius_wheel"))
   		if caster.IsRiding and counter < duration then 
   			--print("something")
   			if not caster:HasModifier("modifier_army_of_the_king_death_checker") then
				local total_ms = base_ms + (base_ms * bonus_ms * (counter + 1))
				if total_ms > 550 then 
					if not caster:HasModifier("modifier_gordius_wheel_cap") then 
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_cap", {Duration = duration - counter}) 
					end
					caster:SetModifierStackCount("modifier_gordius_wheel_cap", caster, total_ms)
				end
				caster:SetModifierStackCount("modifier_gordius_wheel_speed_boost", caster, counter + 1)
   			end

			-- do damage around rider
	        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, min_damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
	        	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					local distance = (caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() 
					if distance <= max_damage_radius then 
						damage = max_damage
					elseif distance > max_damage_radius then
						damage = max_damage - ((max_damage - min_damage) * distance)/min_damage_radius
					end
		            DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		        end
		    end

	        if caster.IsVEAcquired then
	       		caster.BonusChargeDamage = counter * caster:FindAbilityByName("iskandar_via_expugnatio"):GetSpecialValueFor("bonus_charge")
	       	end

	        if caster.IsThundergodAcquired then
	        	local stomp_radius = ability:GetSpecialValueFor("stomp_radius")
				local stomp_damage = ability:GetSpecialValueFor("stomp_damage")
				local thunder_radius = ability:GetSpecialValueFor("thunder_radius")
				local thunder_damage = ability:GetSpecialValueFor("thunder_damage") / 100
		        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, stomp_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		        for k,v in pairs(targets) do
		        	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
		            	DoDamage(caster, v, stomp_damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		            end
		        end	  
		        local thunderTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, thunder_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		        local thunderTarget = thunderTargets[math.random(#thunderTargets)]
		        if IsValidEntity(thunderTarget) and not thunderTarget:IsNull() and thunderTarget ~= nil then	
		        	if not IsImmuneToSlow(thunderTarget) and not IsImmuneToCC(thunderTarget) then 
	       				ability:ApplyDataDrivenModifier(caster, thunderTarget, "modifier_gordius_wheel_thunder_slow", {}) 
					end
		        	if not IsLightningResist(thunderTarget) then	        	
		        		DoDamage(caster, thunderTarget, thunderTarget:GetHealth() * thunder_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end

		       		thunderTarget:EmitSound("Hero_Zuus.LightningBolt")
		        	local thunderFx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", PATTACH_CUSTOMORIGIN, thunderTarget)
		        	ParticleManager:SetParticleControl(thunderFx, 0, thunderTarget:GetAbsOrigin())
		        	ParticleManager:SetParticleControl(thunderFx, 1, caster:GetAbsOrigin()+Vector(0,0,800))
					Timers:CreateTimer( 2.0, function()
						ParticleManager:DestroyParticle( thunderFx, false )
						ParticleManager:ReleaseParticleIndex( thunderFx )
					end)
		        end
	        end
			local groundcrack = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			caster:EmitSound("Hero_Centaur.HoofStomp")
			counter = counter + 1
			return 1.0
		else
			return
		end
	end)

	if not caster:HasModifier("modifier_army_of_the_king_death_checker") then
		-- Apply diminishing mitigation over time
		Timers:CreateTimer(duration * 0.4, function()	
			if IsValidEntity(caster) and caster:IsAlive() and caster:HasModifier("modifier_gordius_wheel") then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation", {Duration = duration * 0.6}) 
				caster:SetModifierStackCount("modifier_gordius_wheel_mitigation", caster, 1)
			end
		end)
		Timers:CreateTimer(duration * 0.7, function()	
			if IsValidEntity(caster) and caster:IsAlive() and caster:HasModifier("modifier_gordius_wheel") and caster:HasModifier("modifier_gordius_wheel_mitigation") then 
				caster:SetModifierStackCount("modifier_gordius_wheel_mitigation", caster, 2)
			end
		end)
	end
end

function OnChariotEnd(keys)
	local caster = keys.caster
	caster.IsRiding = false

	if caster:HasModifier("modifier_army_of_the_king_death_checker") then
		caster:SwapAbilities("fate_empty3", caster:GetAbilityByIndex(5):GetName(), true, false) 
	else
		if caster.IsBeyondTimeAcquired then
			caster:SwapAbilities("iskandar_army_of_the_king_upgrade", caster:GetAbilityByIndex(5):GetName(), true, false) 
		else
			caster:SwapAbilities("iskandar_army_of_the_king", caster:GetAbilityByIndex(5):GetName(), true, false) 
		end
	end

	if caster:HasModifier("modifier_padoru") then 

	else
		if caster:HasModifier("modifier_alternate_01") then 
			caster:SetModel("models/iskandar/salary/iskandar_salary_by_zefiroft.vmdl")
	    	caster:SetOriginalModel("models/iskandar/salary/iskandar_salary_by_zefiroft.vmdl")
	    	caster:SetModelScale(1.1)
		else
			caster:SetModel("models/iskandar/default/iskandar_new_by_zefiroft.vmdl")
	    	caster:SetOriginalModel("models/iskandar/default/iskandar_new_by_zefiroft.vmdl")
	    	caster:SetModelScale(1.1)
	    end
	end
    caster:RemoveModifierByName("modifier_gordius_wheel")
    caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost")
    caster:RemoveModifierByName("modifier_gordius_wheel_cap")
    caster:RemoveModifierByName("modifier_gordius_wheel_mitigation")
end

function OnChariotChargeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local range = ability:GetSpecialValueFor("range")
	local stun = ability:GetSpecialValueFor("stun")
	local self_stun = ability:GetSpecialValueFor("self_stun")
	local width = ability:GetSpecialValueFor("width")
	local charge_damage = ability:GetSpecialValueFor("charge_damage") / 100

	local soundQueue = math.random(1,4)

	if soundQueue == 4 then
		caster:EmitSound("Iskander.Charge")
	elseif soundQueue == 3 then
		EmitGlobalSound("Iskander_Cart_Charge_3")
	else
		caster:EmitSound("Iskander_Cart_Charge_" .. soundQueue)
	end
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 0.5 + self_stun)
	local currentMS = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false)
	--print(currentMS)

	local unit = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector() * range * 2)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("chariot_dash_damage" .. caster:GetPlayerOwnerID(), {
		endTime = 0.0,
		callback = function()

		CreateLightningField(keys, caster:GetAbsOrigin())
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        local bonus_charge_damage = caster.BonusChargeDamage or ability:GetSpecialValueFor("bonus_charge")

        for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v.ChariotChargeHit ~= true then 
				v.ChariotChargeHit = true
				Timers:CreateTimer(1.0, function()
					if IsValidEntity(v) and not v:IsNull() then
						v.ChariotChargeHit = false
					end
				end)
				v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
           		v:EmitSound("Iskandar_Chariot_hit")
           		DoDamage(caster, v, (charge_damage * currentMS) + bonus_charge_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
           		
           	end
        end
		return 0.1
	end})

	Timers:CreateTimer("chariot_dash" .. caster:GetPlayerOwnerID(), {
		endTime = 0.5,
		callback = function()
		Timers:RemoveTimer("chariot_dash_damage" .. caster:GetPlayerOwnerID())
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("modifier_gordius_wheel")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		return 
	end})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("chariot_dash" .. caster:GetPlayerOwnerID())
		Timers:RemoveTimer("chariot_dash_damage" .. caster:GetPlayerOwnerID())
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("modifier_gordius_wheel")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)	
		caster:RemoveModifierByName("pause_sealenabled")
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", self_stun)
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)
end

function CreateLightningField(keys, vector)
	local caster = keys.caster
	local ability = keys.ability
	local trail_duration = ability:GetSpecialValueFor("trail_duration")
	local width = ability:GetSpecialValueFor("width")
	local trail_damage = ability:GetSpecialValueFor("trail_damage") / 100
    local fieldCounter = 0
 	local plusminus = 1
    local currentMS = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false)
    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	Timers:CreateTimer( trail_duration + 1, function()
		ParticleManager:DestroyParticle( particle3, false )
		ParticleManager:ReleaseParticleIndex( particle3 )
	end)
    Timers:CreateTimer(function()	
    	if fieldCounter >= trail_duration then return end

		local targets = FindUnitsInRadius(caster:GetTeam(), vector, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v.ChariotTrailHit ~= true then 
				v.ChariotTrailHit = true
				Timers:CreateTimer(0.49, function()
					if IsValidEntity(v) and not v:IsNull() then
						v.ChariotTrailHit = false
					end
				end)
				if not IsLightningResist(v) then
           			DoDamage(caster, v, trail_damage * currentMS * 0.5 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
           		end
        	end
        end
        local randomVec = RandomInt(-400,400)
        
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
        local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field_c.vpcf", PATTACH_CUSTOMORIGIN, caster)

    	ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle3, 2, caster:GetAbsOrigin())
    	ParticleManager:SetParticleControl( particle, 0, vector + Vector(randomVec, 0, 250))
    	ParticleManager:SetParticleControl( particle2, 0, vector + Vector(randomVec, 0, 100))
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			ParticleManager:DestroyParticle( particle2, false )
			ParticleManager:ReleaseParticleIndex( particle2 )
		end)
    	fieldCounter = fieldCounter + 0.5
    	return 0.5
    end)
end

function OnAOTKCastStart(keys)
	-- initialize stuffs
	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("iskandar_army_of_the_king_upgrade")
	end
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local duration = ability:GetSpecialValueFor("duration")
	local soldierCount = ability:GetSpecialValueFor("soldier_count")

	if caster:GetAbsOrigin().x < 3000 and caster:GetAbsOrigin().y < -2000 then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Already_Within_Reality_Marble")
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
		ability:EndCooldown()
		return
	end 

	if caster.AOTKSoldiers == nil then 
		caster.AOTKSoldiers = {}
	end

	for k,v in pairs (caster.AOTKSoldiers) do 
		if IsValidEntity(v) and not v:IsNull() then 
			v:RemoveSelf()
			UTIL_Remove(v)
		end
	end

	caster.AOTKSoldiers = {}

	--if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_army_of_the_king_freeze",{})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay)
	IskandarCheckCombo(caster, ability) -- check combo
	EmitGlobalSound("Iskander.AOTK")

	-- particle
	--CreateGlobalParticle("particles/custom/iskandar/iskandar_aotk.vpcf", caster:GetAbsOrigin(), 0)
	CreateGlobalParticle("particles/custom/iskandar/iskandar_aotk.vpcf", {[0] = caster:GetAbsOrigin()}, 2)

	local firstRowPos = aotkCenter + Vector(300, -600,0) 
	local maharajaPos = aotkCenter + Vector(600, 0,0)

	local infantrySpawnCounter = 0

	caster.AOTKSoldierCount = soldierCount + soldierCount
	--print('soldier count: ' .. caster.AOTKSoldierCount)

	Timers:CreateTimer(function()
		if infantrySpawnCounter == soldierCount then return end
		local soldier = CreateUnitByName("iskandar_infantry", firstRowPos + Vector(0,infantrySpawnCounter*100,0), true, nil, nil, caster:GetTeamNumber())
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetUnitCanRespawn(false)
		soldier:SetOwner(caster)
		soldier.IsAOTKSoldier = true
		--soldier:SetForwardVector(Vector(-0.999991, 0.004154, -0.000000))
		table.insert(caster.AOTKSoldiers, soldier)
		--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		ability:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{Duration = duration + cast_delay + 1})
		soldier:SetModifierStackCount("modifier_army_of_the_king_infantry_bonus_stat", caster, ability:GetLevel())
		soldier:AddNewModifier(caster, nil, "modifier_kill", {Duration = 16})
		infantrySpawnCounter = infantrySpawnCounter + 1
		return 0.03
	end)

	local archerSpawnCounter1 = 0
	Timers:CreateTimer(0.99, function()
		if archerSpawnCounter1 == (soldierCount / 2) then return end
		local soldier = CreateUnitByName("iskandar_archer", aotkCenter + Vector(800, 700 - archerSpawnCounter1*100, 0), true, nil, nil, caster:GetTeamNumber())
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetUnitCanRespawn(false)
		soldier:SetOwner(caster)
		soldier.IsAOTKSoldier = true
		--soldier:SetForwardVector(Vector(-0.999991, 0.004154, -0.000000))
		table.insert(caster.AOTKSoldiers, soldier)
		--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		ability:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{Duration = duration + cast_delay + 1})
		soldier:SetModifierStackCount("modifier_army_of_the_king_archer_bonus_stat", caster, ability:GetLevel())
		soldier:AddNewModifier(caster, nil, "modifier_kill", {Duration = 16})
		archerSpawnCounter1 = archerSpawnCounter1 + 1
		return 0.03
	end)

	local archerSpawnCounter2 = 0
	Timers:CreateTimer(1.49, function()
		if archerSpawnCounter2 == (soldierCount / 2) then return end
		local soldier = CreateUnitByName("iskandar_archer", aotkCenter + Vector(800, -700 + archerSpawnCounter2*100, 0), true, nil, nil, caster:GetTeamNumber())
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetUnitCanRespawn(false)
		soldier:SetOwner(caster)
		soldier.IsAOTKSoldier = true
		--soldier:SetForwardVector(Vector(-0.999991, 0.004154, -0.000000))
		table.insert(caster.AOTKSoldiers, soldier)
		--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		ability:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{Duration = duration + cast_delay + 1})
		soldier:SetModifierStackCount("modifier_army_of_the_king_archer_bonus_stat", caster, ability:GetLevel())
		soldier:AddNewModifier(caster, nil, "modifier_kill", {Duration = 16})
		archerSpawnCounter2 = archerSpawnCounter2 + 1
		return 0.03
	end)
	
	Timers:CreateTimer({
		endTime = cast_delay,
		callback = function()
		if caster:IsAlive() then 
		    caster.AOTKLocator = CreateUnitByName("ping_sign2", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		    caster.AOTKLocator:FindAbilityByName("ping_sign_passive"):SetLevel(1)
		    caster.AOTKLocator:AddNewModifier(caster, nil, "modifier_kill", {duration = duration + 0.5})
		    caster.AOTKLocator:SetAbsOrigin(caster:GetAbsOrigin())
			OnAOTKStart(keys)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_army_of_the_king_death_checker",{})
		end
	end
	})
end

aotkTargets = nil
aotkCenter = Vector(500, -4800, 208)
ubwCenter = Vector(5600, -4398, 200)
aotkCasterPos = nil
aotkAbilityHandle = nil	-- handle of AOTK ability

LinkLuaModifier("modifier_inside_marble", "abilities/general/modifiers/modifier_inside_marble", LUA_MODIFIER_MOTION_NONE)

function OnAOTKLevelUp(keys)
	aotkAbilityHandle = keys.ability -- Store handle in global variable for future use
	local caster = keys.caster
	local ability = keys.ability

	caster:FindAbilityByName("iskandar_arrow_bombard"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("iskandar_bucephalus"):SetLevel(ability:GetLevel())
end

function OnAOTKStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("iskandar_army_of_the_king_upgrade")
	end
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	caster.IsAOTKActive = true
	caster:EmitSound("Ability.SandKing_SandStorm.loop")
	CreateUITimer("Army of the King", duration, "aotk_timer")
	--aotkQuest = StartQuestTimer("aotkTimerQuest", "Army of the King", 12) -- Start timer

	-- Swap abilities

	caster:SwapAbilities("iskandar_spatha", "iskandar_summon_hephaestion", false, true)
	if caster.IsThundergodAcquired then
		caster:SwapAbilities("iskandar_gordius_wheel_upgrade", "iskandar_arrow_bombard", false, true)
	else
		caster:SwapAbilities("iskandar_gordius_wheel", "iskandar_arrow_bombard", false, true)
	end
	if caster.IsBeyondTimeAcquired then
		--[[if caster.IsCharismaImproved then
			caster:SwapAbilities("iskandar_charisma_upgrade", "iskandar_summon_waver", false, true) 
		else
			caster:SwapAbilities("iskandar_charisma", "iskandar_summon_waver", false, true) 
		end]]
		caster:SwapAbilities("iskandar_army_of_the_king_upgrade", "iskandar_bucephalus", false, true)
	else 
		--[[if caster.IsCharismaImproved then
			caster:SwapAbilities("iskandar_charisma_upgrade", "fate_empty4", false, true) 
		else
			caster:SwapAbilities("iskandar_charisma", "fate_empty4", false, true) 
		end]]
		caster:SwapAbilities("iskandar_army_of_the_king", "fate_empty3", false, true)
	end

	-- Find eligible targets
	aotkTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	caster.IsAOTKDominant = true

	-- Remove any dummy or hero in jump
	i = 1
	while i <= #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			ProjectileManager:ProjectileDodge(aotkTargets[i]) -- Disjoint particles
			if aotkTargets[i]:HasModifier("jump_pause") or string.match(aotkTargets[i]:GetUnitName(),"dummy") or aotkTargets[i]:HasModifier("spawn_invulnerable") and aotkTargets[i] ~= caster then 
				table.remove(aotkTargets, i)
				i = i - 1
			end
		end
		i = i + 1
	end

	if caster:GetAbsOrigin().x > 3000 and caster:GetAbsOrigin().y < -2000 then
		caster.IsAOTKDominant = false
	end

	--[[-- Check if Archer's UBW is already in place 
	for i=1, #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			if aotkTargets[i]:GetName() == "npc_dota_hero_ember_spirit" and aotkTargets[i]:HasModifier("modifier_ubw_death_checker") then
				caster.IsAOTKDominant = false
				break
			end
		end
	end]]


 	-- spawn sight dummy
	local truesightdummy = CreateUnitByName("sight_dummy_unit", aotkCenter, false, caster, caster, caster:GetTeamNumber())
	truesightdummy:AddNewModifier(caster, nil, "modifier_item_ward_true_sight", {true_sight_range = 3000}) 
	truesightdummy:AddNewModifier(caster, nil, "modifier_kill", {duration = duration}) 
	truesightdummy:SetDayTimeVisionRange(2500)
	truesightdummy:SetNightTimeVisionRange(2500)
	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)
	-- spawn sight dummy for enemies
	--[[local enemyTeamNumber = 0
	if caster:GetTeamNumber() == 0 then enemyTeamNumber = 1 end
	local truesightdummy2 = CreateUnitByName("sight_dummy_unit", aotkCenter, false, keys.caster, keys.caster, enemyTeamNumber)
	truesightdummy2:AddNewModifier(caster, caster, "modifier_kill", {duration = 12}) 
	truesightdummy2:SetDayTimeVisionRange(2500)
	truesightdummy2:SetNightTimeVisionRange(2500)
	local unseen2 = truesightdummy2:FindAbilityByName("dummy_unit_passive")
	unseen2:SetLevel(1)]]

	-- Summon soldiers
	local marbleCenter = 0
	if caster.IsAOTKDominant then marbleCenter = aotkCenter else marbleCenter = ubwCenter end
	local firstRowPos = marbleCenter + Vector(300, -500,0) 
	local maharajaPos = marbleCenter + Vector(600, 0,0)
	local waverPos = marbleCenter + Vector(0, -200,0)

	for i=1, #caster.AOTKSoldiers do
		local soldierHandle = caster.AOTKSoldiers[i]
		local soldierPos = caster.AOTKSoldiers[i]:GetAbsOrigin()
		local diffFromCenter = soldierPos - aotkCenter
		soldierHandle:SetAbsOrigin(diffFromCenter + marbleCenter)
	end

	local maharaja = CreateUnitByName("iskandar_eumenes", maharajaPos, true, nil, nil, caster:GetTeamNumber())
	maharaja:SetControllableByPlayer(caster:GetPlayerID(), true)
	maharaja:SetUnitCanRespawn(false)
	maharaja:SetOwner(caster)
	maharaja:FindAbilityByName("iskandar_battle_horn"):SetLevel(ability:GetLevel())
	maharaja:AddNewModifier(caster, ability, "modifier_kill", {Duration = 16})
	table.insert(caster.AOTKSoldiers, maharaja)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	ability:ApplyDataDrivenModifier(caster, maharaja, "modifier_army_of_the_king_maharaja_bonus_stat",{})
	maharaja:SetModifierStackCount("modifier_army_of_the_king_maharaja_bonus_stat", caster, ability:GetLevel())

	if caster.IsBeyondTimeAcquired then
		local waver = CreateUnitByName("iskandar_waver", waverPos, true, nil, nil, caster:GetTeamNumber())
		waver:SetControllableByPlayer(caster:GetPlayerID(), true)
		waver:SetOwner(caster)
		waver:SetUnitCanRespawn(false)
		waver:FindAbilityByName("iskandar_brilliance_of_the_king"):SetLevel(aotkAbilityHandle:GetLevel())
		waver:FindAbilityByName("iskandar_brilliance_of_the_king"):StartCooldown(1)
		waver:AddNewModifier(caster, ability, "modifier_kill", {Duration = 16})
		table.insert(caster.AOTKSoldiers, waver)
		caster.waver = waver
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		ability:ApplyDataDrivenModifier(caster, waver, "modifier_army_of_the_king_waver_bonus_stat",{})
		waver:SetModifierStackCount("modifier_army_of_the_king_waver_bonus_stat", caster, ability:GetLevel())
	end

	if not caster.IsAOTKDominant then return end -- If Archer's UBW is already active, do not teleport units


	aotkTargetLoc = {}
	local diff = nil
	local aotkTargetPos = nil
	aotkCasterPos = caster:GetAbsOrigin()

	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			if aotkTargets[i]:GetName() ~= "npc_dota_ward_base" then
				aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_enemy")
				aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_ally")
				aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
				aotkTargets[i]:RemoveModifierByName("modifier_zhuge_liang_array_checker")
				aotkTargets[i]:RemoveModifierByName("modifier_zhuge_liang_array_enemy")
				aotkTargets[i]:RemoveModifierByName("modifier_queens_glass_game")
				
				--if aotkTargets[i]:GetName() == "npc_dota_hero_bounty_hunter" or aotkTargets[i]:GetName() == "npc_dota_hero_riki" then
	                aotkTargets[i]:AddNewModifier(caster, ability, "modifier_inside_marble", { Duration = duration })
	            --end

	            --[[if IsIsekaiAbuser(aotkTargets[i]) then
                    giveUnitDataDrivenModifier(caster, aotkTargets[i], "modifier_isekai_check", duration)
                    giveUnitDataDrivenModifier(caster, aotkTargets[i], "modifier_isekai_abuser", duration + 5)
                end]]

				aotkTargetPos = aotkTargets[i]:GetAbsOrigin()
		        aotkTargetLoc[i] = aotkTargetPos
		        diff = (aotkCasterPos - aotkTargetPos)

		        local forwardVec = aotkTargets[i]:GetForwardVector()
		        -- scale position difference to size of AOTK
		        diff.y = diff.y * 0.7
		        if aotkTargets[i]:GetTeam() ~= caster:GetTeam() then 
		        	if diff.x <= 0 then 
		        		diff.x = diff.x * -1 
		        		forwardVec.x = forwardVec.x * -1
		        	end
		        elseif aotkTargets[i]:GetTeam() == caster:GetTeam() then
		        	if diff.x >= 0 then 
		        		diff.x = diff.x * -1
		        		forwardVec.x = forwardVec.x * -1
		        	end
		        end
		        aotkTargets[i]:SetAbsOrigin(aotkCenter - diff)
				FindClearSpaceForUnit(aotkTargets[i], aotkTargets[i]:GetAbsOrigin(), true)
				Timers:CreateTimer(0.1, function() 
					if caster:IsAlive() and IsValidEntity(aotkTargets[i]) then
						aotkTargets[i]:AddNewModifier(aotkTargets[i], nil, "modifier_camera_follow", {duration = 1.0})
					end
				end)
				Timers:CreateTimer(0.033, function()
					if caster:IsAlive() and IsValidEntity(aotkTargets[i]) then
						ExecuteOrderFromTable({
							UnitIndex = aotkTargets[i]:entindex(),
							OrderType = DOTA_UNIT_ORDER_STOP,
							Queue = false
						})
						aotkTargets[i]:SetForwardVector(forwardVec)
					end
				end)
			end
		end
    end
end

function OnAOTKSoldierDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("iskandar_army_of_the_king_upgrade")
	end
	local sustain = ability:GetSpecialValueFor("sustain_limit")
	--local target = keys.target
		
	--if target and target.IsAOTKSoldier then
		if caster.IsAOTKActive then
			caster.AOTKSoldierCount = caster.AOTKSoldierCount - 1
			if caster.AOTKSoldierCount < sustain then
				EndAOTK(caster)
				caster:RemoveModifierByName("modifier_army_of_the_king_death_checker")
			end
		end
		--print('soldier count: ' .. caster.AOTKSoldierCount)
		--print("Current number of remaining soldiers : " .. caster.AOTKSoldierCount)
		--[[if caster.AOTKSoldierCount < sustain and caster.IsAOTKActive then
			EndAOTK(caster)
		end]]
	--end
end

function OnAOTKDeath(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_annihilate_window") then 
		caster:RemoveModifierByName("modifier_annihilate_window")
	end
	Timers:CreateTimer(0.066, function()
		EndAOTK(caster)
	end)
end

function EndAOTK(caster)
	if caster.IsAOTKActive == false then return end
	print("AOTK ended")
	-- Revert abilities

	caster:SwapAbilities("iskandar_spatha", "iskandar_summon_hephaestion", true, false)
	if caster.IsThundergodAcquired then
		caster:SwapAbilities("iskandar_gordius_wheel_upgrade", "iskandar_arrow_bombard", true, false)
	else
		caster:SwapAbilities("iskandar_gordius_wheel", "iskandar_arrow_bombard", true, false)
	end
	if caster.IsBeyondTimeAcquired then
		--[[if caster.IsCharismaImproved then
			caster:SwapAbilities("iskandar_charisma_upgrade", "iskandar_summon_waver", true, false) 
		else
			caster:SwapAbilities("iskandar_charisma", "iskandar_summon_waver", true, false) 
		end]]
		caster:SwapAbilities("iskandar_army_of_the_king_upgrade", "iskandar_bucephalus", true, false)
	else 
		--[[if caster.IsCharismaImproved then
			caster:SwapAbilities("iskandar_charisma_upgrade", "fate_empty4", true, false) 
		else
			caster:SwapAbilities("iskandar_charisma", "fate_empty4", true, false) 
		end]]
		caster:SwapAbilities("iskandar_army_of_the_king", "fate_empty3", true, false)
	end

	CreateUITimer("Army of the King", 0, "aotk_timer")
	--UTIL_RemoveImmediate(aotkQuest)
	caster.IsAOTKActive = false
	if not caster.AOTKLocator:IsNull() and IsValidEntity(caster.AOTKLocator) then
		caster.AOTKLocator:RemoveSelf()
	end

	StopSoundEvent("Ability.SandKing_SandStorm.loop", caster)

	CleanUpHammer(caster)

	-- Remove soldiers 
	for i=1, #caster.AOTKSoldiers do
		if IsValidEntity(caster.AOTKSoldiers[i]) and not caster.AOTKSoldiers[i]:IsNull() then
			if caster.AOTKSoldiers[i]:IsAlive() then
				caster.AOTKSoldiers[i]:ForceKill(false)
			end
		end
	end
	--[[for i=0, 9 do
	    local player = PlayerResource:GetPlayer(i)
	    if player ~= nil and player:GetAssignedHero() ~= nil then 
			player:StopSound("Iskander.AOTK_Ambient")
		end
	end]]
    local units = FindUnitsInRadius(caster:GetTeam(), aotkCenter, nil, 3000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
 
    for i=1, #units do
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then
			if string.match(units[i]:GetUnitName(),"dummy") then 
				table.remove(units, i)
			end
		end
	end

    for i=1, #units do
    	--print("removing units in AOTK")
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then 
	    	-- Disjoint all projectiles
	    	ProjectileManager:ProjectileDodge(units[i])
	    	-- If unit is Archer and UBW is active, deactive it as well
	    	if IsAoTKSoldier(units[i]) then 
	    		units[i]:ForceKill(false)
	    	end
	    	units[i]:RemoveModifierByName("modifier_aestus_domus_aurea_enemy")
			units[i]:RemoveModifierByName("modifier_aestus_domus_aurea_ally")
			units[i]:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
			units[i]:RemoveModifierByName("modifier_zhuge_liang_array_checker")
			units[i]:RemoveModifierByName("modifier_zhuge_liang_array_enemy")
			units[i]:RemoveModifierByName("modifier_inside_marble")
			--if units[i]:GetName() == "npc_dota_hero_bounty_hunter" or units[i]:GetName() == "npc_dota_hero_riki" then
                
           -- end

			if units[i]:GetName() == "npc_dota_hero_ember_spirit" and units[i]:HasModifier("modifier_unlimited_bladeworks") then
				units[i]:RemoveModifierByName("modifier_unlimited_bladeworks")
			end
			if units[i]:HasModifier("modifier_annihilate_mute") then
				units[i]:RemoveModifierByName("modifier_annihilate_mute")
			end

	    	local IsUnitGeneratedInAOTK = true
	    	if aotkTargets ~= nil then
		    	for j=1, #aotkTargets do
		    		if IsValidEntity(aotkTargets[j]) and not aotkTargets[j]:IsNull() then
			    		if units[i] == aotkTargets[j] then
			    			if aotkTargets[j] ~= nil then
			    				units[i]:SetAbsOrigin(aotkTargetLoc[j]) 
			    			end
			    			FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true)
			    			Timers:CreateTimer(0.1, function() 
			    				if IsValidEntity(units[i]) and not units[i]:IsNull() then 
									units[i]:AddNewModifier(units[i], nil, "modifier_camera_follow", {duration = 1.0})
								end
							end)
			    			IsUnitGeneratedInAOTK = false
			    			break 
			    		end
			    	end
		    	end 
	    	end
	    	if IsUnitGeneratedInAOTK then
	    		diff = aotkCenter - units[i]:GetAbsOrigin()
	    		if aotkCasterPos ~= nil then 
	    			units[i]:SetAbsOrigin(aotkCasterPos - diff * 0.7)
	    		end

	    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
				Timers:CreateTimer(0.1, function() 
					if IsValidEntity(units[i]) and not units[i]:IsNull() then
						units[i]:AddNewModifier(units[i], nil, "modifier_camera_follow", {duration = 1.0})
					end
				end)
	    	end
	    end
    end

    aotkTargets = nil
    aotkTargetLoc = nil

    Timers:RemoveTimer("aotk_timer")

end

function OnSoldierCheck(keys)
	local caster = keys.caster 
	local target = keys.target 
	local ability = keys.ability
	local hero = caster:GetOwner()
	if hero.IsAOTKDominant == true then
		if caster:GetUnitName() == "iskandar_waver" then
			if IsAoTKSoldier(target) or target:GetName() == "npc_dota_hero_chen" or target:GetName() == "npc_dota_hero_disruptor" then 
				ability:ApplyDataDrivenModifier(caster, target, "modifier_waver_passive_buff", {})
			end
		else
			if IsAoTKSoldier(target) then 
				if caster:GetUnitName() == "iskandar_eumenes" then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_maharaja_passive_buff", {})
				elseif caster:GetUnitName() == "iskandar_hephaestion" then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hephaestion_passive_buff", {})
				end
			end
		end
	end
end

function OnWaverSilence(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target
	local hero = caster:GetOwner()
	local base = ability:GetSpecialValueFor("base_arm_red")
	local bonus = ability:GetSpecialValueFor("arm_red_lvl")
	local armor_red = base + (hero:GetLevel() * bonus)
	target:SetModifierStackCount("modifier_waver_silence", caster, armor_red)
end

function OnEumenesBuffDestroy(keys)
	local caster = keys.caster 
	local target = keys.target 
	target:RemoveModifierByName("modifier_maharaja_passive_buff")
	target:RemoveModifierByName("modifier_hephaestion_passive_buff")
	target:RemoveModifierByName("modifier_waver_passive_buff")
end

function ModifySoldierHealth(keys)
	local unit = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner() 
	local newHP = unit:GetMaxHealth() + keys.HealthBonus * ability:GetLevel()
	local newcurrentHP = unit:GetHealth() + keys.HealthBonus * ability:GetLevel()
	--print(newHP .. " " .. newcurrentHP)

	if caster.IsBeyondTimeAcquired then 
		local bonus_health = ability:GetSpecialValueFor("bonus_health") / 100
		newHP = newHP + caster:GetMaxHealth() * bonus_health
		newcurrentHP = newcurrentHP + caster:GetMaxHealth() * bonus_health
	end

	
	unit:SetMaxHealth(newHP)
	unit:SetBaseMaxHealth(newHP)
	unit:SetHealth(newcurrentHP)
end

function OnBucephalusStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local dist = (caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6
	local castRange = ability:GetSpecialValueFor("range")
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local stun = ability:GetSpecialValueFor("stun")
	-- When you exit the ubw on the last moment, dist is going to be a pretty high number, since the targetPoint is on ubw but you are outside it
	-- If it's, then we can't use it like that. Either cancel Overedge, or use a default one.
	-- 2000 is a fixedNumber, just to check if dist is not valid. Over 2000 is surely wrong. (Max is close to 900)
	if dist > 2000 then
		dist = castRange --Default one
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_iskandar_bucephalus", {Duration = 0.6 + 0.5})
	
    local archer = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 1200))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-2666))

	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		caster:EmitSound("Hero_Centaur.DoubleEdge") 
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	
	-- Stomp
		local stompParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( stompParticleIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( stompParticleIndex, 1, Vector( radius, radius, radius ) )
		
	-- Destroy particle
		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( stompParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( stompParticleIndex )
			
		end)
		
        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() then
		       	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		       	if not IsImmuneToCC(v) then 
		       		v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
		       	end
		    end
		end
	end})
end

function OnBucephalusCreate(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_hitloc") ~= nil then 
		Attachments:AttachProp(caster, "attach_hitloc", "models/iskandar/horse/horse.vmdl")
	end
end

function OnBucephalusDestroy(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_hitloc") ~= nil then 
		local prop = Attachments:GetCurrentAttachment(caster, "attach_hitloc")
		if prop ~= nil and not prop:IsNull() then
			prop:RemoveSelf()
		end
	end
end

function OnBattleHornStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local ability = keys.ability
	local arm_reduce = ability:GetSpecialValueFor("pct_armor_reduction") / 100
	if hero == nil then 
		hero = caster:GetOwnerEntity() 
	end
	local targetPoint = keys.target_points[1]
	caster:EmitSound("Hero_LegionCommander.PressTheAttack")
	local marbleCenter = 0
	local aotkCenter = Vector(500, -4800, 208)
	local ubwCenter = Vector(5600, -4398, 200)

	if hero.IsAOTKDominant then 
		marbleCenter = aotkCenter 
	else 
		marbleCenter = ubwCenter 
	end

	for i=1, #hero.AOTKSoldiers do
		if IsValidEntity(hero.AOTKSoldiers[i]) then
			if hero.AOTKSoldiers[i]:IsAlive() then
				ability:ApplyDataDrivenModifier(caster,hero.AOTKSoldiers[i], "modifier_battle_horn_movespeed_buff", {})
				ExecuteOrderFromTable({
			        UnitIndex = hero.AOTKSoldiers[i]:entindex(),
			        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			        Position = targetPoint
			    })
			end
		end
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), marbleCenter, nil, 3000
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			local target_armor = math.floor(v:GetPhysicalArmorBaseValue() * arm_reduce)
			ability:ApplyDataDrivenModifier(caster,v, "modifier_battle_horn_armor_reduction", {})
			v:SetModifierStackCount("modifier_battle_horn_armor_reduction", caster, target_armor)
	    end
	end
    if hero:HasModifier("modifier_annihilate_caster") then
		for k,v in pairs(targets) do
			ability:ApplyDataDrivenModifier(caster,v, "modifier_battle_horn_movespeed_debuff", {})
	    end
    end
end

function OnCavalrySummon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cavalry_count = ability:GetSpecialValueFor("cavalry_count")
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if hero == nil then 
		hero = caster:GetOwnerEntity() 
	end
	if hero.hepha == nil then 
		hero.hepha = {}
	end
	if IsValidEntity(hero.hepha) and hero.hepha:IsAlive() then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Only_One_Hephaestion_Can_be_Summoned")
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
		ability:EndCooldown()
		return
	end
	local targetPoint = keys.target_points[1]
	IskandarCheckCombo(caster, ability)
	--caster.AOTKCavalryTable = {}
	caster:EmitSound("Hero_KeeperOfTheLight.SpiritForm")
	for i=0,cavalry_count - 1 do
		local soldier = CreateUnitByName("iskandar_cavalry", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		--soldier:SetBaseMaxHealth(soldier:GetHealth() + ) 
		soldier:SetUnitCanRespawn(false)
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(hero)
		table.insert(caster.AOTKSoldiers, soldier)
		--table.insert(caster.AOTKCavalryTable, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(caster, soldier, "modifier_army_of_the_king_cavalry_bonus_stat",{})
		soldier:SetModifierStackCount("modifier_army_of_the_king_cavalry_bonus_stat", caster, aotkAbilityHandle:GetLevel())
	end
	local hepha = CreateUnitByName("iskandar_hephaestion", targetPoint, true, nil, nil, caster:GetTeamNumber())
	hepha:SetControllableByPlayer(caster:GetPlayerID(), true)
	hepha:SetUnitCanRespawn(false)
	hepha:SetOwner(hero)
	hepha:FindAbilityByName("iskandar_hammer_and_anvil"):SetLevel(aotkAbilityHandle:GetLevel())
	table.insert(caster.AOTKSoldiers, hepha)
	hero.hepha = hepha
	--table.insert(caster.AOTKCavalryTable, hepha)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(caster, hepha, "modifier_army_of_the_king_hepha_bonus_stat",{})
	hepha:SetModifierStackCount("modifier_army_of_the_king_hepha_bonus_stat", caster, aotkAbilityHandle:GetLevel())
end

function CleanUpHammer(hero)
    local hammerTimers = hero.HammerTimers
    if hammerTimers ~= nil then
        for i=1,hammerTimers do
            Timers:RemoveTimer("hammer_charge" .. i)
        end
    end
    local oldCavalryTable = hero.CavalryTable
    if oldCavalryTable ~= nil then
        for i=1,#oldCavalryTable do
	    local unit = oldCavalryTable[i]
	    if unit ~= nil and not unit:IsNull() then
                unit:PreventDI(false)
                unit:SetPhysicsVelocity(Vector(0,0,0))
                unit:OnPhysicsFrame(nil)
                unit:RemoveModifierByName("round_pause")
	    end
        end
    end

    hero.CavalryTable = nil
    hero.HammerTimers= nil
end

function OnHammerAttachEffect(keys)
	local caster = keys.caster 
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)
end

function OnHammerStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stun = ability:GetSpecialValueFor("stun")
	local damage = ability:GetSpecialValueFor("damage")
	local bonus_damage = ability:GetSpecialValueFor("bonus_damage") / 100
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if hero == nil then 
		hero = caster:GetOwnerEntity() 
	end

	CleanUpHammer(hero)

	local cavalryTable = {}
	table.insert(cavalryTable, caster)
	caster:EmitSound("Hero_Centaur.Stampede.Cast")
	local annihilateabil = hero:FindAbilityByName("iskandar_annihilate")
	if hero:HasModifier("modifier_annihilate_caster") then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(annihilateabil:GetSpecialValueFor("hammer_cd"))
	end

	if hero.IsAOTKDominant then	
		caster:SetAbsOrigin(aotkCenter + Vector(-1400, 0, 0)) 
	else
		caster:SetAbsOrigin(ubwCenter + Vector(-1100, 0, 0)) 
	end		

	for i=1, #hero.AOTKSoldiers do
		if IsValidEntity(hero.AOTKSoldiers[i]) then
			if hero.AOTKSoldiers[i]:IsAlive() then
				if hero.AOTKSoldiers[i]:GetUnitName() == "iskandar_cavalry" then
					table.insert(cavalryTable, hero.AOTKSoldiers[i])
					if hero.IsAOTKDominant then
						hero.AOTKSoldiers[i]:SetAbsOrigin(aotkCenter + Vector(-1400, -600 + RandomInt(0, 1200), 0)) 
					else
						hero.AOTKSoldiers[i]:SetAbsOrigin(ubwCenter + Vector(-900, -600 + RandomInt(0,1200), 0))
					end
				end
			end
		end
	end

	hero.hammerTimers = #cavalryTable

	for i=1,#cavalryTable do
		local counter = 0
		Timers:CreateTimer("hammer_charge" .. i, {
			endTime = 0.0,
			callback = function()
			if counter > 3 then return end
			local targets = FindUnitsInRadius(cavalryTable[i]:GetTeam(), cavalryTable[i]:GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and v.HammerChargeHit ~= true then 
					v.HammerChargeHit = true
					Timers:CreateTimer(1.0, function()
						if IsValidEntity(v) and not v:IsNull() then
							v.HammerChargeHit = false
						end
					end)
					v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
	           		DoDamage(cavalryTable[i], v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	           	else
	           		DoDamage(cavalryTable[i], v, damage * bonus_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	           	end
	        end
	        counter = counter+0.15
			return 0.15
		end})

		giveUnitDataDrivenModifier(keys.caster, keys.caster, "round_pause", 2.0)
		local cavalryUnit = Physics:Unit(cavalryTable[i])
		cavalryTable[i]:PreventDI()
		cavalryTable[i]:SetPhysicsFriction(0)
		cavalryTable[i]:SetPhysicsVelocity((hero:GetAbsOrigin() - cavalryTable[i]:GetAbsOrigin()):Normalized() * 1500)
		cavalryTable[i]:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		cavalryTable[i]:FollowNavMesh(false)

		cavalryTable[i]:OnPhysicsFrame(function(unit)
			local diff = hero:GetAbsOrigin() - cavalryTable[i]:GetAbsOrigin()
			local dir = diff:Normalized()
			local particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_end_bots_dust.vpcf", PATTACH_ABSORIGIN, cavalryTable[i])
			ParticleManager:SetParticleControl(particle, 0, cavalryTable[i]:GetAbsOrigin())
			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
	   		unit:SetForwardVector(dir) 
			if diff:Length() < 50 then
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:RemoveModifierByName("round_pause")
				Timers:RemoveTimer("hammer_charge" .. i)
			end
		end)
	end
        hero.CavalryTable = cavalryTable
end

function OnMageSummon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mage_count = ability:GetSpecialValueFor("mage_count")
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if hero == nil then 
		hero = caster:GetOwnerEntity() 
	end
	if hero.waver == nil then 
		hero.waver = {}
	end
	if IsValidEntity(hero.waver) and hero.waver:IsAlive() then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Only_One_Waver_Can_be_Summoned")
		caster:SetMana(caster:GetMana() + ability:GetManaCost(ability:GetLevel()))
		ability:EndCooldown()
		return
	end
	local targetPoint = keys.target_points[1]
	caster:EmitSound("Hero_Silencer.Curse.Cast")
	for i=0,mage_count - 1 do
		local soldier = CreateUnitByName("iskandar_mage", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(hero)
		soldier:SetUnitCanRespawn(false)
		table.insert(caster.AOTKSoldiers, soldier)
		--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_mage_bonus_stat",{})
		soldier:SetModifierStackCount("modifier_army_of_the_king_mage_bonus_stat", caster, aotkAbilityHandle:GetLevel())
	end
	local waver = CreateUnitByName("iskandar_waver", targetPoint, true, nil, nil, caster:GetTeamNumber())
	waver:SetControllableByPlayer(caster:GetPlayerID(), true)
	waver:SetOwner(hero)
	waver:SetUnitCanRespawn(false)
	waver:FindAbilityByName("iskandar_brilliance_of_the_king"):SetLevel(aotkAbilityHandle:GetLevel())
	table.insert(caster.AOTKSoldiers, waver)
	hero.waver = waver
	--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(caster, waver, "modifier_army_of_the_king_waver_bonus_stat",{})
	waver:SetModifierStackCount("modifier_army_of_the_king_waver_bonus_stat", caster, aotkAbilityHandle:GetLevel())
end

function OnBrillianceStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero() or caster:GetOwner()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_waver_big_bad_voodoo", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_waver_silence_aura", {})

	EmitGlobalSound("Waver_NP_" .. math.random(1,2))
	if hero:HasModifier("modifier_annihilate_caster") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_waver_root_aura", {})
	end
end

function OnBrillianceCheck(keys)
	local caster = keys.caster 
	local target = keys.target 
	local ability = keys.ability
	print(target:GetUnitName())
	if IsValidEntity(target) and not target:IsNull() and IsAoTKSoldier(target) then
		print('invul') 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_waver_big_bad_voodoo_invulnerability", {})
	end
end

function OnBrillianceInterrupt(keys)
	local caster = keys.caster 
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if hero == nil then 
		hero = caster:GetOwnerEntity() 
	end
	caster:RemoveModifierByName("modifier_waver_big_bad_voodoo")
	caster:RemoveModifierByName("modifier_waver_silence_aura")
	if caster:HasModifier("modifier_waver_root_aura") then 
		caster:RemoveModifierByName("modifier_waver_root_aura")
	end
end

function OnBrillianceEnd(keys)
	local caster = keys.caster

	caster:RemoveModifierByName("modifier_waver_big_bad_voodoo")
	caster:RemoveModifierByName("modifier_waver_silence_aura") 
	caster:RemoveModifierByName("modifier_waver_root_aura") 
end

function OnBrillianceDestroy(keys)
	local caster = keys.caster 
	local target = keys.target
	target:RemoveModifierByName("modifier_waver_big_bad_voodoo_invulnerability")
end

function OnArrowBombard(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local root_dur = ability:GetSpecialValueFor("root_dur")	

	local iParticleIndex = ParticleManager:CreateParticle("particles/custom/iskandar/arrow_volley.vpcf", PATTACH_CUSTOMORIGIN, nil) 
    ParticleManager:SetParticleControl(iParticleIndex, 0, target_loc)
    ParticleManager:SetParticleControl(iParticleIndex, 1, caster:GetAbsOrigin() + Vector(0, 0, 500))
    ParticleManager:SetParticleControl(iParticleIndex, 3, caster:GetAbsOrigin() + Vector(0, 0, 500))
    ParticleManager:SetParticleControl(iParticleIndex, 4, Vector(radius, 1, 1))

    EmitSoundOnLocationWithCaster(target_loc, "Hero_LegionCommander.Overwhelming.Location", caster)

	local tEnemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for i = 1, #tEnemies do
		if IsValidEntity(tEnemies[i]) and not tEnemies[i]:IsNull() and tEnemies[i]:IsAlive() then
			giveUnitDataDrivenModifier(caster, tEnemies[i], "rooted", root_dur)
			DoDamage(caster, tEnemies[i], damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)		
		end
	end

	Timers:CreateTimer(0.75, function()
		ParticleManager:DestroyParticle(iParticleIndex, true)
		ParticleManager:ReleaseParticleIndex(iParticleIndex)
	end)
end

function IskandarCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "iskandar_army_of_the_king") and not caster:HasModifier("modifier_annihilate_cooldown") then
			caster.RUsed = true
			caster.RTime = GameRules:GetGameTime()
			if caster.RTimer ~= nil then 
				Timers:RemoveTimer(caster.RTimer)
				caster.RTimer = nil
			end
			caster.ETimer = Timers:CreateTimer(5.0, function()
				caster.RUsed = false
			end)
		else
			if string.match(ability:GetAbilityName(), "iskandar_summon_hephaestion") and not caster:HasModifier("modifier_annihilate_cooldown") and caster.IsAOTKDominant then 
				if caster.IsCharismaImproved then
					if caster:FindAbilityByName("iskandar_forward_upgrade"):IsCooldownReady() and caster:FindAbilityByName("iskandar_annihilate"):IsCooldownReady() then 
						local newTime = GameRules:GetGameTime()
						local duration = 5 - (newTime - caster.RTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_annihilate_window", {Duration = duration})
					end
				else
					if caster:FindAbilityByName("iskandar_forward"):IsCooldownReady() and caster:FindAbilityByName("iskandar_annihilate"):IsCooldownReady() then 
						local newTime = GameRules:GetGameTime()
						local duration = 5 - (newTime - caster.RTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_annihilate_window", {Duration = duration})
					end
				end
			end
		end
	end
end

function OnAnnihilateWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsCharismaImproved then 
		caster:SwapAbilities("iskandar_forward_upgrade", "iskandar_annihilate", false, true)
	else
		caster:SwapAbilities("iskandar_forward", "iskandar_annihilate", false, true)
	end
end

function OnAnnihilateWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsCharismaImproved then 
		caster:SwapAbilities("iskandar_forward_upgrade", "iskandar_annihilate", true, false)
	else
		caster:SwapAbilities("iskandar_forward", "iskandar_annihilate", true, false)
	end
end

function OnAnnihilateStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local aoe = ability:GetSpecialValueFor("aoe")
	local mute_delay = ability:GetSpecialValueFor("mute_delay")
	local arrow_count = ability:GetSpecialValueFor("arrow_count")
	local arrow_duration = ability:GetSpecialValueFor("arrow_duration")
	local arrow_delay = ability:GetSpecialValueFor("arrow_delay")
	local interval = arrow_duration / arrow_count

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("iskandar_annihilate")

	local marbleCenter = 0
	if caster.IsAOTKDominant then 
		marbleCenter = aotkCenter 
	else 
		marbleCenter = ubwCenter 
	end

	caster:RemoveModifierByName("modifier_annihilate_window")

	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_annihilate_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	local aotk = caster:FindAbilityByName("iskandar_army_of_the_king")
	if aotk == nil then 
		aotk = caster:FindAbilityByName("iskandar_army_of_the_king_upgrade")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_annihilate_caster", {Duration = aotk:GetSpecialValueFor("duration")})
	EmitGlobalSound("Iskander.Annihilate")
	Timers:CreateTimer(2.0, function()
		EmitGlobalSound("Iskander.Aye")
	end)
	EmitGlobalSound("Hero_LegionCommander.PressTheAttack")
	-- Remove soldiers 
	for i=1, #caster.AOTKSoldiers do
		if IsValidEntity(caster.AOTKSoldiers[i]) then
			if caster.AOTKSoldiers[i]:IsAlive() then
				keys.ability:ApplyDataDrivenModifier(caster,caster.AOTKSoldiers[i], "modifier_annihilate", {Duration = aotk:GetSpecialValueFor("duration")})
			end
		end
	end

	-- Mute
	Timers:CreateTimer(mute_delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), marbleCenter, nil, 2000
           	 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and not DoNotMute(v) then
				ability:ApplyDataDrivenModifier(caster,v, "modifier_annihilate_mute", {})
			end
   		end
		local particle = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_combo_mute.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()+Vector(3000,0,0))
   	end)

    -- Arrows
    local tableOfSounds = {"Iskander.ArrowFly1","Iskander.ArrowFly2","Iskander.ArrowLand1","Iskander.ArrowLand3"}
	local nVolleys = 0
	local nHit = 0
	Timers:CreateTimer(arrow_delay, function() -- Empirical testing; 500 arrows fired with each arrow being 200 aoe, each servant will get hit by 6-7 arrows on average.
		if caster:IsAlive() and caster:GetAbsOrigin().y < -3500 then
			for i=0,4 do
				local targetPoint = RandomPointInCircle(marbleCenter, 2000)
				local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, flamePillarRadius, true, 30)
				for k,v in pairs(targets) do
					nHit = nHit + 1
					if IsValidEntity(v) and not v:IsNull() and not v:HasModifier("modifier_protection_from_arrows_active") then
						DoDamage(caster, v, damage , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
					end
				end
				GenerateArrowParticle(keys,targetPoint,marbleCenter)
			end
			nVolleys = nVolleys + 1
			if nVolleys % 3 == 0 and nVolleys <= 95 then EmitGlobalSound(tableOfSounds[math.random(4)]) end
			--print("rawr")
			if nVolleys == arrow_count then
				print(nHit)
				return
			else
				return interval
			end
		else
			return
		end
	end)
end

function GenerateArrowParticle(keys, targetPoint, marbleCenter)
	local caster = keys.caster
	local arrowFx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_combo_arrow.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( arrowFx, 0, targetPoint)
	ParticleManager:SetParticleControl( arrowFx, 1, RandomPointInCircle(targetPoint + Vector(1000,0,0), 300))
	
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( arrowFx, true )
		ParticleManager:ReleaseParticleIndex( arrowFx )
	end)
end

function OnIskanderCharismaImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCharismaImproved) then

		if hero:HasModifier("modifier_annihilate_window") then 
			hero:RemoveModifierByName("modifier_annihilate_window")
		end

	    hero.IsCharismaImproved = true

		UpgradeAttribute(hero, "iskandar_forward", "iskandar_forward_upgrade", true)

		if hero:HasModifier("modifier_army_of_the_king_death_checker") then 
			UpgradeAttribute(hero, "iskandar_charisma", "iskandar_charisma_upgrade", false)
		else
			UpgradeAttribute(hero, "iskandar_charisma", "iskandar_charisma_upgrade", true)
		end

		hero:RemoveModifierByName("modifier_iskandar_charisma_aura")
		hero:FindAbilityByName("iskandar_charisma_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_iskandar_charisma_aura", {})

	    NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnThundergodAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsThundergodAcquired) then

	    hero.IsThundergodAcquired = true
	   
		if hero:HasModifier("modifier_army_of_the_king_death_checker") then 
			UpgradeAttribute(hero, "iskandar_gordius_wheel", "iskandar_gordius_wheel_upgrade", false)
		else
			UpgradeAttribute(hero, "iskandar_gordius_wheel", "iskandar_gordius_wheel_upgrade", true)
		end

	    NonResetAbility(hero)

	       -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnChariotChargeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsVEAcquired) then

	    hero.IsVEAcquired = true

	    if hero:HasModifier("iskandar_gordius_wheel") then 
	    	hero:SwapAbilities("iskandar_via_expugnatio", hero:GetAbilityByIndex(5):GetAbilityName(), true, false)
	    end

	    NonResetAbility(hero)

	       -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBeyondTimeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBeyondTimeAcquired) then

	    hero.IsBeyondTimeAcquired = true

	    UpgradeAttribute(hero, "iskandar_phalanx", "iskandar_phalanx_upgrade", true)

		if hero:HasModifier("modifier_army_of_the_king_death_checker") then 
			UpgradeAttribute(hero, "iskandar_army_of_the_king", "iskandar_army_of_the_king_upgrade", false)
		else
			UpgradeAttribute(hero, "iskandar_army_of_the_king", "iskandar_army_of_the_king_upgrade", true)
		end

		aotkAbilityHandle = hero:FindAbilityByName("iskandar_army_of_the_king_upgrade")

	    NonResetAbility(hero)

	       -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end