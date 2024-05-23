
function OnCasaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("active_radius")
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Astolfo_Is_Ridding_Now")
		return 
	end 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_cooldown", {Duration = ability:GetCooldown(1)})
	caster:RemoveModifierByName("modifier_casa_passive_mr")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_active_mr_aura", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_active_mr_self", {})
	caster:EmitSound("Hero_Oracle.FortunesEnd.Target")
	
end

function OnCasaActiveEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_passive_mr", {})
end

function OnRideCastCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Astolfo_Is_Ridding_Now")
		return 
	end
end

function OnVanishStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local banish_duration = ability:GetSpecialValueFor("banish_duration")
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		return 
	end 
	local info = {
		Target = target, -- chainTarget
		Source = caster, -- chainSource
		Ability = ability,
		EffectName = "particles/custom/astolfo/astolfo_hippogriff_vanish.vpcf",
		--vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 2500
	}
	ProjectileManager:CreateTrackingProjectile(info) 

	caster:EmitSound("Astolfo_Snatch_" .. RandomInt(1,4))
	caster:EmitSound("Hero_Mirana.Leap.MoonGriffon")

	if caster.IsRidingAcquired then		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_vanish_banish", {})
		caster:AddEffects(EF_NODRAW)

		Timers:CreateTimer(banish_duration, function()
			caster:RemoveEffects(EF_NODRAW)
			return
		end)
	end
end

function OnVanishHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(target) or target:IsMagicImmune() then
		return
	end -- Linken effect checker

	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")

	if caster.IsRidingAcquired then
		caster:SetAbsOrigin(target:GetAbsOrigin())
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end

	ApplyPurge(target)
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	if IsValidEntity(target) and target:IsAlive() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_hippogriff_vanish_banish", {})
	end
end

function OnVanishDebuffStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:AddEffects(EF_NODRAW)
	target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")
end

function OnVanishDebuffEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveEffects(EF_NODRAW)

	if caster.IsRidingAcquired then 
		local stun_duration = ability:GetSpecialValueFor("stun_duration")
		if IsValidEntity(target) and target:IsAlive() then
			target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun_duration })
		end
	end

end

function OnVanishSwordRemove(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetName() == "npc_dota_hero_queenofpain" then
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			local prop = Attachments:GetCurrentAttachment(target, "attach_sword")
			if prop ~= nil and not prop:IsNull() then
				prop:RemoveSelf()
			end
		end
	end
end

function OnVanishSwordAttach(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetName() == "npc_dota_hero_queenofpain" then
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			Attachments:AttachProp(target, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
		end
	end
end

function OnTrapArgaliaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")
	local distance = ability:GetSpecialValueFor("distance")
	local width = ability:GetSpecialValueFor("width")
	local qdProjectile = 
	{
		Ability = ability,
        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = distance,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}

	if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then sword:RemoveSelf() end
		Attachments:AttachProp(caster, "attach_lance", "models/astolfo/astolfo_lance.vmdl")
	end

	local projectile = ProjectileManager:CreateLinearProjectile(qdProjectile)
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.0})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	caster:EmitSound("Astolfo_Slide_" .. math.random(1,5))
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*speed)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("trap_argalia_dash" .. caster:GetPlayerOwnerID(), {
		endTime = 0.5,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		if caster:ScriptLookupAttachment("attach_lance") ~= nil then 
			local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
			if lance ~= nil and not lance:IsNull() then lance:RemoveSelf() end
			Attachments:AttachProp(caster, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
		end
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("trap_argalia_dash" .. caster:GetPlayerOwnerID())
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		ProjectileManager:DestroyLinearProjectile(projectile)
		if caster:ScriptLookupAttachment("attach_lance") ~= nil then 
			local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
			if lance ~= nil and not lance:IsNull() then lance:RemoveSelf() end
			Attachments:AttachProp(caster, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
		end
	end)

end

function OnTrapArgaliaHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end

	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("duration")

	giveUnitDataDrivenModifier(caster, target, "rooted", duration)
	giveUnitDataDrivenModifier(caster, target, "locked", duration)

	target:EmitSound("Hero_Sniper.AssassinateDamage")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnHornCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Astolfo_Is_Ridding_Now")
		return 
	end 
	caster:EmitSound("Astolfo_Luna_" .. RandomInt(1, 2))
end

function OnHornCreate(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then sword:RemoveSelf() end
		Attachments:AttachProp(caster, "attach_horn", "models/astolfo/astolfo_new_horn.vmdl")
	end
end

function OnHornDestroy(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_horn") ~= nil then 
		local horn = Attachments:GetCurrentAttachment(caster, "attach_horn")
		if horn ~= nil and not horn:IsNull() then horn:RemoveSelf() end
		Attachments:AttachProp(caster, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
	end
end

function OnHornStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local slow_radius = ability:GetSpecialValueFor("slow_radius")
	local silenceRadius = ability:GetSpecialValueFor("silence_radius")
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		caster:Stop()
		return 
	end

	AstolfoCheckCombo(caster, ability)
	caster.currentHornManaCost = ability:GetManaCost(ability:GetLevel())
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_black_luna_slow_aura", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_black_luna_silence_aura", {})

    if caster.IsDeafeningBlastAcquired then
    	ProjectileManager:ProjectileDodge(caster)
    	local knock_damage = ability:GetSpecialValueFor("knock_damage")
		local knock_radius = ability:GetSpecialValueFor("knock_radius")
		local knock_duration = ability:GetSpecialValueFor("knock_duration")

    	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, knock_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	    for k,v in pairs(targets) do
	    	if v:GetName() ~= "npc_dota_ward_base" then
		    	DoDamage(caster, v, knock_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		    	if IsValidEntity(v) and v:IsAlive() then
			    	if not IsKnockbackImmune(v) then
						giveUnitDataDrivenModifier(caster, v, "drag_pause", knock_duration)
						--v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 1.5 })
						
						local pushback = Physics:Unit(v)
						v:PreventDI()
						v:SetPhysicsFriction(0)
						v:SetPhysicsVelocity((v:GetAbsOrigin() -  caster:GetAbsOrigin()):Normalized() * knock_duration * knock_radius)
						v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
						v:FollowNavMesh(false)

						Timers:CreateTimer(knock_duration, function()  
							if IsValidEntity(v) and not v:IsNull() then
								v:PreventDI(false)
								v:SetPhysicsVelocity(Vector(0,0,0))
								v:OnPhysicsFrame(nil)
								FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
							end
							return 
						end)
					end
				end
			end
		end
    end

	--StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=1.0})

    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() == caster:GetTeamNumber() then
        	-- apply legion horn vsnd on their client
        	CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="Astolfo.Horn"})
        	--caster:EmitSound("Hero_LegionCommander.PressTheAttack")
        else
        	-- apply legion horn + silencer vsnd on their client
        	CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="Hero_Silencer.GlobalSilence.Effect"})
        end
    end)

    local shockwaveIndex = ParticleManager:CreateParticle("particles/custom/astolfo/la_black_luna/la_black_luna_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl( shockwaveIndex, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( shockwaveIndex, 1, Vector(500,0,0))
    ParticleManager:SetParticleControl( shockwaveIndex, 2, Vector(slow_radius,0,0))
end

function OnHornDamageThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if ability == nil then 
		ability = GetAbility(caster, "astolfo_la_black_luna")
	end

	local damageRadius = ability:GetSpecialValueFor("damage_radius")
	local damage = ability:GetSpecialValueFor("damage") / 100 * 0.1
	local min_damage = (9 + ability:GetLevel())

	if caster.IsDeafeningBlastAcquired then
    	ProjectileManager:ProjectileDodge(caster)
    end

    local deafTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(deafTargets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_la_black_luna_deaf", {})
		end
    end

    local damageTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, damageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(damageTargets) do
		-- apply damage
		DoDamage(caster, v, math.max(v:GetHealth() * damage, min_damage), DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end

end

function OnHornSilenceThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if not target:HasModifier("modifier_la_black_luna_silence") then
		if not IsImmuneToCC(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_la_black_luna_silence", {})
		end
    end
end

function OnHornSilenceDestroy(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:HasModifier("modifier_la_black_luna_silence") then
		target:RemoveModifierByName("modifier_la_black_luna_silence")
	end
end

function OnHornSlowThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if not target:HasModifier("modifier_la_black_luna_slow") then
		if not IsImmuneToSlow(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_la_black_luna_slow", {})
		end
    end
end

function OnHornSlowDestroy(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:HasModifier("modifier_la_black_luna_slow") then
		target:RemoveModifierByName("modifier_la_black_luna_slow")
	end
end

function OnHornInterrupted(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	CustomGameEventManager:Send_ServerToAllClients("stop_horn_sound", {})
	caster:RemoveModifierByName("modifier_la_black_luna_slow_aura")
	caster:RemoveModifierByName("modifier_la_black_luna_silence_aura")

	--local prop = Attachments:GetCurrentAttachment(caster, "attach_horn")
	--if not prop:IsNull() then prop:RemoveSelf() end

end


function OnRaidCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Astolfo_Is_Ridding_Now")
		return 
	elseif caster.RaidActive then
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return 
	end 

	caster:EmitSound("Astolfo.Hippogriff_Raid_Cast")
end

function CreateBeaconForEnemies(caster, targetPoint)
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
        	AddFOWViewer(playerHero:GetTeamNumber(), targetPoint, 150, 2.5, false)
        	local beaconIndex = ParticleManager:CreateParticleForPlayer("particles/custom/astolfo/astolfo_ground_mark_flex.vpcf", PATTACH_CUSTOMORIGIN, nil, player)
			ParticleManager:SetParticleControl( beaconIndex, 0, targetPoint)
        	-- set a timer to check whether affected enemies retain buff
        	local beaconCounter = 0
        	Timers:CreateTimer(function() 
        		if beaconCounter > 40 then return end
        		if playerHero:HasModifier("modifier_la_black_luna_deaf") then
        			ParticleManager:SetParticleControl( beaconIndex, 0, Vector(20000,20000,1000))
        		else
        			ParticleManager:SetParticleControl( beaconIndex, 0, targetPoint)
        		end
        		beaconCounter = beaconCounter + 1
        		return 0.1
        	end)
        end
    end)
end

function OnRaidStart(keys)
	local caster = keys.caster
	local targetPoint = caster.HippogriffCastLocation
	local ability = keys.ability
	local firstDmg = ability:GetSpecialValueFor("first_impact_damage")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local total_delay = ability:GetSpecialValueFor("total_delay")
	local reveal_delay = ability:GetSpecialValueFor("reveal_delay")
	local impact_delay = ability:GetSpecialValueFor("impact_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local rootDuration = ability:GetSpecialValueFor("first_impact_root_duration")
	local secondDmg = ability:GetSpecialValueFor("second_impact_damage")
	local stunDuration = ability:GetSpecialValueFor("second_impact_stun_duration")
	if caster:HasModifier("modifier_hippogriff_ride_ascended") or not IsInSameRealm(caster:GetAbsOrigin(), targetPoint) then
		caster:GiveMana(ability:GetManaCost(1))
		ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return
	end

	caster.RaidActive = true

	Timers:CreateTimer(total_delay - cast_delay, function()		
		caster.RaidActive = false
		return
	end)

	caster:EmitSound("Astolfo.Hippogriff_Raid_Cast_Success")
	caster:EmitSound("Hero_Phoenix.IcarusDive.Cast")

	local ascendFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_ascend.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( ascendFx, 0, caster:GetAbsOrigin())
	-- create beacon for team
	local teamBeacon = ParticleManager:CreateParticleForTeam("particles/custom/astolfo/astolfo_ground_mark_flex.vpcf", PATTACH_CUSTOMORIGIN, nil, caster:GetTeam())
	ParticleManager:SetParticleControl( teamBeacon, 0, targetPoint)

	AddFOWViewer(caster:GetTeamNumber(), targetPoint, radius, 6, false)
	Timers:CreateTimer(reveal_delay, function()
		CreateBeaconForEnemies(caster, targetPoint)
		EmitGlobalSound("Astolfo.Hippogriff_Raid_Shout")
		Timers:CreateTimer(total_delay, function()
			EmitGlobalSound("Astolfo.Leap")

			local birdOrigin = caster:GetAbsOrigin() + Vector(0,0,2000) + (caster:GetAbsOrigin() - targetPoint):Normalized()*1000
			local dist = (targetPoint  - birdOrigin):Length2D()
			local birdVector = (targetPoint  - birdOrigin):Normalized() * dist * 3
			local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/astolfo_hippogriff_raid_flyer.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( swordFxIndex, 0, birdOrigin)
			ParticleManager:SetParticleControl( swordFxIndex, 1,  birdVector)
		end)
		Timers:CreateTimer(total_delay - reveal_delay, function()
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() then
					giveUnitDataDrivenModifier(caster,v, "rooted", rootDuration)
			        giveUnitDataDrivenModifier(caster,v, "locked", rootDuration)
			        DoDamage(caster, v, firstDmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			    end
		        --v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stunDuration })
		    end

			EmitGlobalSound("Astolfo.SolarForge")
			local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_first_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
		    ParticleManager:SetParticleControl(firstImpactIndex, 0, Vector(1,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(radius,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(1.5,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 3, targetPoint)
		    ParticleManager:SetParticleControl(firstImpactIndex, 4, Vector(0,0,0))

			Timers:CreateTimer(impact_delay - total_delay, function()	
				if caster.IsRidingAcquired then 
					local bonus_agi = ability:GetSpecialValueFor("second_impact_bonus_agi")	
					secondDmg = secondDmg + (bonus_agi * caster:GetAgility())
				end
				local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
						v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stunDuration })
			        	DoDamage(caster, v, secondDmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			        end
			    end
			    ScreenShake(targetPoint, 15, 1.0, 2, 2000, 0, true)

				caster.RaidActive = false

				EmitSoundOnLocationWithCaster(targetPoint, "Misc.Crash", caster)
				local secondImpactIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_second_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(secondImpactIndex, 0, targetPoint)
			    ParticleManager:SetParticleControl(secondImpactIndex, 1, Vector(radius,1,1))
			end)
		end)
	end)
end

function AstolfoCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "astolfo_la_black_luna") and caster:FindAbilityByName("astolfo_hippogriff_ride"):IsCooldownReady() and not caster:HasModifier("modifier_hippogriff_ride_cooldown") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_hippogriff_ride_window", {})
		end
	end
end

function OnHippogriffRideWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities("astolfo_hippogriff_ride", "fate_empty1", true, false)
end

function OnHippogriffRideWindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities("astolfo_hippogriff_ride", "fate_empty1", false, true)
end

function OnHippogriffRideWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_hippogriff_ride_window")
end

function OnRideStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ascendDelay = ability:GetSpecialValueFor("ascend_delay")
	local radius = ability:GetSpecialValueFor("max_range")
	local duration = ability:GetSpecialValueFor("duration")
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then return end 

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("astolfo_hippogriff_ride")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hippogriff_ride_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster:RemoveModifierByName("modifier_hippogriff_ride_window")
	caster.ComboStringNum = RandomInt(1, 2)

	EmitGlobalSound("Astolfo_Hippogriff_Ride_Cast_" .. caster.ComboStringNum)
	EmitGlobalSound("Astolfo.SolarForge")
	-- pause for ascend delay
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", ascendDelay)
	StartAnimation(caster, {duration=ascendDelay, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})
	local ascendIndex = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_swirl_fxset.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ascendIndex, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(ascendDelay, function()
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_hippogriff_ride_ascended", {})
			giveUnitDataDrivenModifier(caster, caster, "zero_attack_damage", duration)
			HardCleanse(caster)
			for i=2, 13 do
				if caster:GetTeamNumber() ~= i then
					AddFOWViewer(i, caster:GetAbsOrigin(), 500, duration, false)
				end
			end

			local aoeFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_aoe_indicator.vpcf", PATTACH_WORLDORIGIN, caster )
			ParticleManager:SetParticleControl( aoeFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl( aoeFx, 1, Vector(radius,0,0))
			local beaconIndex = ParticleManager:CreateParticle("particles/custom/astolfo/astolfo_ground_mark_flex_10sec.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl( beaconIndex, 0, caster:GetAbsOrigin())
		end
	end)
	-- swap ability layout
end

function OnRideAscend(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	giveUnitDataDrivenModifier(caster, caster, "jump_pause_nosilence", duration)
	caster:AddEffects(EF_NODRAW)
	caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_rush", false, true)
	Timers:CreateTimer(0.7, function()
		EmitGlobalSound("Astolfo_Hippogriff_Ride_Success_" .. caster.ComboStringNum)
		return
	end)
	
	local ascendFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_ascend.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( ascendFx, 0, caster:GetAbsOrigin())
	--local aoeIndicatorFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_aoe_indicator.vpcf", PATTACH_CUSTOMORIGIN, nil )
    --ParticleManager:SetParticleControl(aoeIndicatorFx, 0, caster:GetAbsOrigin())
    --print("ascended")
	
end

function OnRideAscendEnd(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveEffects(EF_NODRAW)
	caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_rush", true, false)
end

function OnRushStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local comboabil = caster:FindAbilityByName("astolfo_hippogriff_ride")
	local range = comboabil:GetSpecialValueFor("linear_range")
	local width = comboabil:GetSpecialValueFor("linear_width")
	local damage = comboabil:GetSpecialValueFor("damage")
	local stun_duration = comboabil:GetSpecialValueFor("stun_duration")
	local midPos = ability:GetCursorPosition()
	if caster.oldpos == nil or caster.oldpos == midPos then 
		caster.oldpos = caster:GetAbsOrigin()
	end

	local Vector = (midPos - caster.oldpos):Normalized()
	local startPos = midPos - Vector * range/2
	local endPos = midPos + Vector * range/2

	caster.oldpos = midPos

	local markerCounter = 0
	if (startPos - caster:GetAbsOrigin()):Length2D() > 3500 or not IsInSameRealm(caster:GetAbsOrigin(), startPos) then
		ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Out_Of_Range")
		return
	end

	Timers:CreateTimer(function()
		if markerCounter >= 5 then return end
		local diff = startPos + Vector * (range/5 * markerCounter + 100)
		local beaconIndex = ParticleManager:CreateParticle("particles/custom/astolfo/astolfo_ground_mark_smile.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( beaconIndex, 0, diff)
		EmitSoundOnLocationWithCaster(diff, "Astolfo.Dash_Alert", caster)
		AddFOWViewer(caster:GetTeamNumber(), diff, 500, 3, false)

		Timers:CreateTimer(0.4, function()
			local targets = FindUnitsInRadius(caster:GetTeam(), diff, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and not v.bIsDamagedByHippoRush then 
					v:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		        	--caster:PerformAttack( v, true, true, true, true, false, false, true )
		        	
		        	v.bIsDamagedByHippoRush = true
		        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		        	Timers:CreateTimer(0.6, function()
		        		if IsValidEntity(v) and not v:IsNull() then
		        			v.bIsDamagedByHippoRush = false
		        		end
		        	end)
		        end
		    end

			local thunderFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_thunder.vpcf", PATTACH_CUSTOMORIGIN, nil)
    		ParticleManager:SetParticleControl(thunderFx, 0, diff)
    		ParticleManager:SetParticleControl(thunderFx, 1, diff)
			ParticleManager:SetParticleControl(thunderFx, 2, diff)
		end)
		markerCounter = markerCounter + 1
		return 0.12
	end)

	Timers:CreateTimer(0.4, function()
		if RandomInt(1, 2) == 1 then 
			EmitSoundOnLocationWithCaster(midPos, "Astolfo.Hippo_Shout1", caster)
		else
			EmitSoundOnLocationWithCaster(midPos, "Astolfo.Hippo_Shout2", caster)
		end
		local forwardVec = (endPos  - startPos):Normalized()
		local hippoVector = forwardVec * range * 3
		local portalFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_rush_portal.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( portalFx, 0, startPos)
		ParticleManager:SetParticleControlForward(portalFx, 0, forwardVec)

		--[[local hippoFx = ParticleManager:CreateParticle( "particles/custom/astolfo/astolfo_hippogriff_raid_flyer.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( hippoFx, 0, startPos + Vector(0,0,200))
		ParticleManager:SetParticleControl( hippoFx, 1,  hippoVector)]]
		Timers:CreateTimer(0.35, function()
			--[[ParticleManager:DestroyParticle( hippoFx, true )
			ParticleManager:ReleaseParticleIndex( hippoFx )]]
			local portalFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_rush_portal.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( portalFx, 0, endPos)
			ParticleManager:SetParticleControlForward(portalFx, 0, forwardVec)
		end)
	end)
end

function OnIAThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local bIsVisibleToEnemy = false
	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see astolfo, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				bIsVisibleToEnemy = true
				return
			end
		end
	end)
	if IsRevoked(caster) or not bIsVisibleToEnemy then
		if caster:HasModifier("modifier_astolfo_indepedent_action_regen") then 
			caster:RemoveModifierByName("modifier_astolfo_indepedent_action_regen")
		end
		if not caster:HasModifier("modifier_astolfo_indepedent_action_conditional_regen") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_indepedent_action_conditional_regen", {})
		end
	else
		if caster:HasModifier("modifier_astolfo_indepedent_action_conditional_regen") then 
			caster:RemoveModifierByName("modifier_astolfo_indepedent_action_conditional_regen")
		end
		if not caster:HasModifier("modifier_astolfo_indepedent_action_regen") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_indepedent_action_regen", {})
		end
	end
end

function OnMonstrousStrThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local atk_str_ratio = ability:GetSpecialValueFor("atk_per_str")
	local str = caster:GetStrength() 
	caster:SetModifierStackCount("modifier_astolfo_monstrous_strength_atk", caster, math.ceil(str))
end

function OnMonstrousStrAtk(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local str_dmg = ability:GetSpecialValueFor("str_dmg")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local str = caster:GetStrength() 
	DoDamage(caster, target, base_dmg + (str_dmg * str), DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnEvaporationSanityCrit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_evaporation_sanity_hit", {})
end

function OnRidingAcquired(keys)
    local caster = keys.caster
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRidingAcquired) then

	    hero.IsRidingAcquired = true

	    UpgradeAttribute(hero, 'astolfo_hippogriff_vanish', 'astolfo_hippogriff_vanish_upgrade', true)
		UpgradeAttribute(hero, 'astolfo_hippogriff_raid', 'astolfo_hippogriff_raid_upgrade', true)

		NonResetAbility(hero)

	    -- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMStrengthAcquired(keys)
    local caster = keys.caster
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsMStrengthAcquired) then

	    hero.bIsMStrengthAcquired = true

	    hero:FindAbilityByName("astolfo_monstrous_strength"):SetLevel(1)

	    UpgradeAttribute(hero, 'astolfo_trap_of_argalia', 'astolfo_trap_of_argalia_upgrade', true)

		NonResetAbility(hero)

	    -- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnIActionAcquired(keys)
    local caster = keys.caster
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsIAAcquired) then

	    hero.bIsIAAcquired = true

	    hero:FindAbilityByName("astolfo_independent_action"):SetLevel(1)

	    NonResetAbility(hero)

	    -- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSanityAcquired(keys)
    local caster = keys.caster
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSanityAcquired) then

		if hero:HasModifier("modifier_hippogriff_ride_window") then 
			hero:RemoveModifierByName("modifier_hippogriff_ride_window")
		end

	    hero.IsSanityAcquired = true

	    hero:FindAbilityByName("astolfo_evaporation_of_sanity_passive"):SetLevel(1)

	    UpgradeAttribute(hero, 'astolfo_casa_di_logistilla', 'astolfo_casa_di_logistilla_upgrade', true)

		if hero.IsDeafeningBlastAcquired then
			UpgradeAttribute(hero, 'astolfo_la_black_luna_upgrade_2', 'astolfo_la_black_luna_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'astolfo_la_black_luna', 'astolfo_la_black_luna_upgrade_1', true)
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDeafeningBlastAcquired(keys)
    local caster = keys.caster
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDeafeningBlastAcquired) then

		if hero:HasModifier("modifier_hippogriff_ride_window") then 
			hero:RemoveModifierByName("modifier_hippogriff_ride_window")
		end

	    hero.IsDeafeningBlastAcquired = true

	    if hero.IsSanityAcquired then
	    	UpgradeAttribute(hero, 'astolfo_la_black_luna_upgrade_1', 'astolfo_la_black_luna_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'astolfo_la_black_luna', 'astolfo_la_black_luna_upgrade_2', true)
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end