
function OnGoldenRuleThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gold_gain = ability:GetSpecialValueFor("gold_gain")
    if caster:IsAlive() and GameRules:GetGameTime() > 75 then 
    	caster:SetGold(0, false)
    	caster:SetGold(caster:GetGold() + gold_gain, true) 
    end
end

function OnGramStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local extra_swords = ability:GetSpecialValueFor("extra_swords")
	local radius = ability:GetSpecialValueFor("radius")
	local target_origin = target:GetAbsOrigin()
	local right_vec = caster:GetForwardVector()
	right_vec = Vector(right_vec.y, -right_vec.x, 0)

	local spawn = caster:GetAbsOrigin() + Vector(0, 0, 300)

	local info = {
		Target = target,
		Ability = ability,
		EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
		vSourceLoc = spawn,
		iMoveSpeed = 2000,
		bDrawsOnMinimap = false, 
		bVisibleToEnemies = true,
		bProvidesVision = false, 
		flExpireTime = GameRules:GetGameTime() + 10, 
		bDodgeable = true
	}

	if extra_swords > 0 then
		info.vSourceLoc = spawn + (right_vec * -80)
	end

	ProjectileManager:CreateTrackingProjectile(info) 
	caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")

	Timers:CreateTimer('gilgamesh_gram' .. caster:GetPlayerOwnerID(), {
		endTime = 0.2,
		callback = function()

		if extra_swords <= 0 or not caster:IsAlive() then return end 
		local targets = FindUnitsInRadius(caster:GetTeam(), target_origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		if #targets >= 1 then
			info.Target = targets[1]
			info.vSourceLoc = spawn + (right_vec * 40)

			ProjectileManager:CreateTrackingProjectile(info) 
			caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
		end

		extra_swords = extra_swords - 1

		return 0.2
	end})
end

function OnGramHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(target) then return end -- Linken effect checker
	local caster = keys.caster	
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_cast_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = stun_duration})
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
end

function OnChainStart(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local targetloc = target:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor("duration")
	local bonus_divine = ability:GetSpecialValueFor("bonus_divine")
	
	caster:EmitSound("Gilgamesh_Enkidu_2")

	local stopOrder = {
 		UnitIndex = target:entindex(), 
 		OrderType = DOTA_UNIT_ORDER_STOP
 	}
 	ExecuteOrderFromTable(stopOrder) 
 	if IsDivineServant(target) then
 		ability:ApplyDataDrivenModifier(caster, target, "modifier_enkidu_hold", {duration = duration + bonus_divine})
 	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_enkidu_hold", {duration = duration})
 	end
 	if caster.IsSumerAcquired then 
 		GilgameshCheckCombo2(caster, ability)
 	end
end

function OnChainCreate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target.enkiduBind = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_enkidu.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	if target:ScriptLookupAttachment("attach_origin") ~= nil then 
		ParticleManager:SetParticleControlEnt( target.enkiduBind, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true )
	end
	ParticleManager:SetParticleControl( target.enkiduBind, 1, target:GetAbsOrigin() )
end

function OnChainThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:IsInvisible() then 
		RemoveInvis(target)
	end
end

function OnChainDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	if target.enkiduBind ~= nil then
		ParticleManager:DestroyParticle( target.enkiduBind, true )
		ParticleManager:ReleaseParticleIndex( target.enkiduBind )
	end
end

function OnChainDeath(keys)
	local caster = keys.caster 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	target:RemoveModifierByName("modifier_enkidu_hold")
end

function OnBarrageStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local strike_amount = ability:GetSpecialValueFor("strike_amount")
	local casterorigin = caster:GetAbsOrigin()

	local rainCount = 0
	caster:EmitSound("Archer.UBWAmbient")
    Timers:CreateTimer(function()
		if rainCount == strike_amount then return end
	
		-- Create sword particles
		-- Main variables
		local delay = 0.5				-- Delay before damage
		local speed = 3000				-- Movespeed of the sword
			
		-- Side variables
		local spawn_location = casterorigin + Vector(0, 0, 1500 * math.tan( 60 / 180 * math.pi ))
		local sword_loc = RandomPointInCircle(target_loc, radius * 0.5)
		
			
		local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( swordFxIndex, 0, spawn_location )
		ParticleManager:SetParticleControl( swordFxIndex, 1, (sword_loc - spawn_location):Normalized() * speed )
		
		-- Delay
		Timers:CreateTimer( delay, function()
			-- Destroy particles
			ParticleManager:DestroyParticle( swordFxIndex, false )
			ParticleManager:ReleaseParticleIndex( swordFxIndex )
	
			-- Damage
			local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			if targets[1] ~= nil then
				targets[1]:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
			end
			for k,v in pairs(targets) do
				DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
			
			-- Particles on impact
			local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( explosionFxIndex, 0, target_loc )

			local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( impactFxIndex, 0, target_loc )
			ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(radius, radius, radius) )
				
			-- Destroy Particle
			Timers:CreateTimer( 0.5, function()
				ParticleManager:DestroyParticle( explosionFxIndex, false )
				ParticleManager:DestroyParticle( impactFxIndex, false )
				ParticleManager:ReleaseParticleIndex( explosionFxIndex )
				ParticleManager:ReleaseParticleIndex( impactFxIndex )
			end)
		end)

		rainCount = rainCount + 1
      	return 0.2
    end)

    if caster.IsRainAcquired then 
    	local max_stack = ability:GetSpecialValueFor("max_stack")
    	local stacks = caster:GetModifierStackCount("modifier_gilgamesh_rain_of_swords", caster) or 0
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gilgamesh_rain_of_swords", {})
    	OnRainSwap(caster, ability)
    	if stacks < max_stack then 
    		caster:SetModifierStackCount("modifier_gilgamesh_rain_of_swords", caster, stacks + 1)
    	else
    		caster:SetModifierStackCount("modifier_gilgamesh_rain_of_swords", caster, max_stack)
    	end
    end
end

function OnRainUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade_1" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade_2" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade_3" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade_4" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gilgamesh_sword_barrage_upgrade_5" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(ability:GetLevel())
		end
		if ability:GetLevel() ~= caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):GetLevel() then
			caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(ability:GetLevel())
		end
	end
end

function OnRainSwap(caster, ability)
	local max_stack = ability:GetSpecialValueFor("max_stack")
    local stacks = caster:GetModifierStackCount("modifier_gilgamesh_rain_of_swords", caster) or 0
    if stacks == 0 then 
    	caster:SwapAbilities("gilgamesh_sword_barrage_upgrade", "gilgamesh_sword_barrage_upgrade_1", false, true)
    	caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
    	caster.RainStacks = 1
    elseif stacks == 1 then 
    	caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_1", "gilgamesh_sword_barrage_upgrade_2", false, true)
    	caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
    	caster.RainStacks = 2
    elseif stacks == 2 then 
    	caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_2", "gilgamesh_sword_barrage_upgrade_3", false, true)
    	caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
    	caster.RainStacks = 3
    elseif stacks == 3 then 
    	caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_3", "gilgamesh_sword_barrage_upgrade_4", false, true)
    	caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
    	caster.RainStacks = 4
    elseif stacks == 4 then 
    	caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_4", "gilgamesh_sword_barrage_upgrade_5", false, true)
    	caster:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
    	caster.RainStacks = 5
    end
end

function OnRainDestroy(keys)
	local caster = keys.caster
	if caster.RainStacks == 1 then 
		caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_1", "gilgamesh_sword_barrage_upgrade", false, true)
		caster.RainStacks = 0
	elseif caster.RainStacks == 2 then 
		caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_2", "gilgamesh_sword_barrage_upgrade", false, true)
		caster.RainStacks = 0
	elseif caster.RainStacks == 3 then 
		caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_3", "gilgamesh_sword_barrage_upgrade", false, true)
		caster.RainStacks = 0
	elseif caster.RainStacks == 4 then 
		caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_4", "gilgamesh_sword_barrage_upgrade", false, true)
		caster.RainStacks = 0
	elseif caster.RainStacks == 5 then 
		caster:SwapAbilities("gilgamesh_sword_barrage_upgrade_5", "gilgamesh_sword_barrage_upgrade", false, true)
		caster.RainStacks = 0
	end
end

function OnRainDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_gilgamesh_rain_of_swords")
end

function OnGOBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()

	local gobWeapon = 
	{
		Ability = ability,
        EffectName = "particles/custom/gilgamesh/gilgamesh_gob_model.vpcf",
        vSpawnOrigin = Vector(0,0,0),
        fDistance = 1000,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + duration + 1.0,
		bDeleteOnHit = true,
		vVelocity = nil
	}

	--if caster:HasModifier("modifier_gob_thinker") then caster:RemoveModifierByName("modifier_gob_thinker") end
	GilgameshCheckCombo(caster, ability)
	if caster.IsSumerAcquired then 
 		GilgameshCheckCombo2(caster, ability)
 	end
	CreateGOB(keys, gobWeapon)
	
	caster:EmitSound("Gilgamesh.GOB")
	caster:EmitSound("Saber_Alter.Derange")
	caster:EmitSound("Archer.UBWAmbient")
end

function CreateGOB(keys, proj)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()



	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin() - 250 * frontward, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:SetForwardVector(caster:GetForwardVector())
	
	local portalFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_gob.vpcf", PATTACH_CUSTOMORIGIN, dummy )
	ParticleManager:SetParticleControlEnt( portalFxIndex, 0, dummy, PATTACH_ABSORIGIN, nil, dummy:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControl( portalFxIndex, 0, dummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( portalFxIndex, 1, Vector( 300, 300, 300 ) )

	dummy.GOBProjectile = proj
	dummy.GOBParticle = portalFxIndex
	caster.LatestGOB = dummy
	caster.LatestGOBParticle = portalFxIndex
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_gob_thinker", {})
end

function OnGOBEnd(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	ParticleManager:DestroyParticle( unit.GOBParticle, false )
	ParticleManager:ReleaseParticleIndex( unit.GOBParticle )
	if IsValidEntity(unit) then
		unit:RemoveSelf()
	end
end

function ToggleGOBOn(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ToggleAbility()
end
function OnGOBThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.target
	local origin = unit:GetAbsOrigin()
	local frontward = unit:GetForwardVector()
	local casterFrontWard = caster:GetForwardVector()
	local toggleAbil = caster:FindAbilityByName("gilgamesh_gate_of_babylon_toggle")
	if not caster:IsAlive() then
		unit:RemoveModifierByName("modifier_gob_thinker")
		return
	end
	if caster.IsSumerAcquired and unit == caster.LatestGOB then
		origin = caster:GetAbsOrigin()
		frontward = caster:GetForwardVector()
		caster.LatestGOB:SetAbsOrigin(caster:GetAbsOrigin() - caster:GetForwardVector() * 150)
		caster.LatestGOB:SetForwardVector( caster:GetForwardVector() )
		--ParticleManager:SetParticleControl( caster.LatestGOBParticle, 0, caster.LatestGOB:GetAbsOrigin() )
		--ParticleManager:SetParticleControlOrientation(caster.LatestGOBParticle, 0, Vector(1,0,0), Vector(0.5,1,0.5), Vector(1,0.5,0.5))
	end

	if caster:IsAlive() and not caster:HasModifier("modifier_gilgamesh_combo_active") and (not caster.IsSumerAcquired or (caster.IsSumerAcquired and toggleAbil:GetToggleState())) then
		local projectile = unit.GOBProjectile
		local leftvec = Vector(-frontward.y, frontward.x, 0)
		local rightvec = Vector(frontward.y, -frontward.x, 0)
		local gobCount = 0

		local random1 = RandomInt(0, 300) -- position of weapon spawn
		local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

		if random2 == 0 then 
			projectile.vSpawnOrigin = origin + leftvec*random1
		else 
			projectile.vSpawnOrigin = origin + rightvec*random1
		end
		projectile.vVelocity = frontward * 3000
		ProjectileManager:CreateLinearProjectile(projectile)

		ParticleManager:SetParticleControlEnt( caster.LatestGOBParticle, 0, caster.LatestGOB, PATTACH_ABSORIGIN, nil, caster.LatestGOB:GetAbsOrigin(), false )
	end
end

function OnGOBHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage
	local bonus_damage = ability:GetSpecialValueFor("atk_ratio")
	if caster.IsSumerAcquired then
		damage = damage + caster:GetAttackDamage() * bonus_damage
	end

	
	local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnEnumaCast (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local endcast_pause = ability:GetSpecialValueFor("endcast_pause")
	local max_channel = ability:GetSpecialValueFor("charge_duration")

	ability:EndCooldown() 
	caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_enuma_elish_thinker", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_enuma_elish_activate", {})
	caster.enumachargefx1 = ParticleManager:CreateParticle("particles/custom/gilgamesh/gilgamesh_enuma_elish_charge_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	if caster:HasModifier("modifier_alternate_01") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_enuma_elish_animation", {duration = endcast_pause + max_channel + 1.5})
		StartAnimation(caster, {duration=10, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.2})
	elseif caster:HasModifier("modifier_alternate_02") then 
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			Attachments:AttachProp(caster, "attach_sword", "models/gilgamesh/gil_ea.vmdl")
		end
		StartAnimation(caster, {duration=10, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})
	else
		StartAnimation(caster, {duration=10, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.7})
	end
	ParticleManager:SetParticleControl(caster.enumachargefx1, 1, Vector(300,1,1))

	EmitGlobalSound("gilgamesh_enuma_" .. math.random(2,5))  
  	--EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "gilgamesh_enuma_" .. math.random(2,5), caster) 
  	caster:EmitSound("Hero_Dark_Seer.Wall_of_Replica_lp")
end


function OnEnumaInterrupt (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local frontward = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local position = ability:GetCursorPosition()
	local distance = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("speed")
	local min_channel = ability:GetSpecialValueFor("activation")
	local width = ability:GetSpecialValueFor("radius")
	local end_width = ability:GetSpecialValueFor("end_radius")
	local cd_penalty = ability:GetSpecialValueFor("cd_penalty")
	local mana_penalty = ability:GetSpecialValueFor("mana_penalty")
	local endradius_per_charge = ability:GetSpecialValueFor("endradius_per_charge")
	local endcast_pause = ability:GetSpecialValueFor("endcast_pause")
	
	if caster.enumacharge == nil then 
		caster.enumacharge = 0
	end

	if caster.enumacharge <= min_channel * 10 then
		caster:RemoveModifierByName("modifier_enuma_elish_thinker")
		caster.enumacharge = 0
		ability:StartCooldown(cd_penalty)
		caster:SetMana(caster:GetMana() - mana_penalty)
		if caster:HasModifier("modifier_alternate_01") then 
			caster:RemoveModifierByName("modifier_enuma_elish_animation")
		end
		caster:StopSound("Hero_Dark_Seer.Wall_of_Replica_lp") 
		FxDestroyer(caster.enumachargefx1, false)
		FxDestroyer(caster.enumachargefx2, false)
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			local prop = Attachments:GetCurrentAttachment(caster, "attach_sword")
			if prop ~= nil and not prop:IsNull() then
				prop:RemoveSelf()
			end
		end
		EndAnimation(caster)
		UnfreezeAnimation(caster)
		caster:RemoveModifierByName("modifier_enuma_elish_activate")
		return
	else
		end_width = end_width + caster.enumacharge * endradius_per_charge
		local radius = width
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel())) 
		caster:SetMana(caster:GetMana() - ability:GetManaCost(ability:GetLevel()))
		caster:RemoveModifierByName("modifier_enuma_elish_thinker")
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", endcast_pause) 
		if not caster:HasModifier("modifier_alternate_01") then
			UnfreezeAnimation(caster)
		end
		if caster:HasModifier("modifier_alternate_02") then 
			EmitGlobalSound("female_gil_enuma")  
		else
			EmitGlobalSound("gilgamesh_enuma_elish")  
		end
		OnEnumaElishFire (caster, ability, origin, frontward, distance, width, end_width, speed)
		local EnumaTime = distance / speed
		local dmyLoc = origin
		local EnumaDummy = CreateUnitByName("dummy_unit", dmyLoc, false, caster, caster, caster:GetTeamNumber())
		EnumaDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		EnumaDummy:SetForwardVector(frontward)

		local fxIndex = ParticleManager:CreateParticle("particles/custom/gilgamesh/enuma_elish/projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, EnumaDummy)
  		ParticleManager:SetParticleControl(fxIndex, 3, position)

		Timers:CreateTimer(function()
			if IsValidEntity(EnumaDummy) then
				dmyLoc = dmyLoc + (speed * 0.05) * Vector(frontward.x, frontward.y, 0)
				EnumaDummy:SetAbsOrigin(GetGroundPosition(dmyLoc, nil))
				radius = radius + (end_width - width) * (speed * 0.05 / distance)
				ParticleManager:SetParticleControl(fxIndex, 2, Vector(radius,0,0))
				return 0.05
			else
				return nil
			end
		end)	

		Timers:CreateTimer(EnumaTime - 0.2, function()
			ParticleManager:DestroyParticle( fxIndex, false )
			ParticleManager:ReleaseParticleIndex( fxIndex )	
				
			Timers:CreateTimer(0.01, function()
				if IsValidEntity(EnumaDummy) then
					EnumaDummy:RemoveSelf()
				end
				caster.enumacharge = 0
				return nil
			end)
			return nil
		end)
		Timers:CreateTimer(endcast_pause, function()
			if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
				local prop = Attachments:GetCurrentAttachment(caster, "attach_sword")
				if prop ~= nil and not prop:IsNull() then
					prop:RemoveSelf()
				end
			end
			if caster:HasModifier("modifier_alternate_01") then 
				caster:RemoveModifierByName("modifier_enuma_elish_animation")
			end
		end)

		caster:StopSound("Hero_Dark_Seer.Wall_of_Replica_lp") 
		Timers:CreateTimer(0.8, function()
			FxDestroyer(caster.enumachargefx1, false)
			FxDestroyer(caster.enumachargefx2, false)
		end)
		caster:RemoveModifierByName("modifier_enuma_elish_activate")
	end
	
end	

function OnEnumaElishFire (caster, ability, origin, forwardVec, range, width, end_width, speed)
	forwardVec = GetGroundPosition(forwardVec, nil)

    local projectileTable = {
		Ability = ability,
		iMoveSpeed = speed,
		vSpawnOrigin = origin,
		fDistance = range - end_width + 150,
		Source = caster,
		fStartRadius = width,
        fEndRadius = end_width,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = forwardVec * speed,		
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end

function OnEnumaElishThink (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.enumacharge == nil then
		caster.enumacharge = 0
	end
	caster.enumacharge = caster.enumacharge + 1
	if caster.enumacharge == 14 then
    	caster:EmitSound("Hero_Weaver.CrimsonPique.Layer")
  	elseif caster.enumacharge == 15 then 
  		if not caster:HasModifier("modifier_alternate_01") then 
    		FreezeAnimation(caster)
    	end
    elseif caster.enumacharge == 20 then  
    	if caster:HasModifier("modifier_alternate_01") then 
    		FreezeAnimation(caster, 2.5)
    	end
  	elseif caster.enumacharge == 29 then   
    	caster.enumachargefx2 = FxCreator("particles/custom/gilgamesh/enuma_elish/charging_sparkles.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
  	end
  
  	--red aura
  	local intensity = caster.enumacharge * 20 + 200
  	ParticleManager:SetParticleControl(caster.enumachargefx1, 1, Vector(intensity,1,1))    

  	--red floor
  	local intensity2 = caster.enumacharge * 15 + 130
  	ParticleManager:SetParticleControl(caster.enumachargefx1, 3, Vector(intensity2,1,1))    

  	--sparkles
  	if caster.enumacharge > 32 then
    	local intensity = -0.6 + caster.enumacharge / 100 * 6
    	ParticleManager:SetParticleControl(caster.enumachargefx2, 2, Vector(1, 1, intensity))
  	end
end

function OnEnumaElishHit (keys)
	if keys.target == nil then return end
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster 
	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("gilgamesh_enuma_elish_upgrade")
	end
	local min_channel = ability:GetSpecialValueFor("activation")
	local max_channel = ability:GetSpecialValueFor("charge_duration")
	local min_damage = ability:GetSpecialValueFor("damage")
	local max_damage = ability:GetSpecialValueFor("damagemax")
	local damage = min_damage
	local channel_time = ability:GetChannelTime()

	if caster.enumacharge < min_channel * 10 then
		damage = min_damage
	elseif caster.enumacharge >= max_channel * 10 then
		damage = max_damage
	elseif caster.enumacharge >= min_channel * 10 and caster.enumacharge < max_channel * 10 then
		damage = min_damage + ((max_damage - min_damage) * (caster.enumacharge - 10) * 0.1 / (max_channel - min_channel))
	end

	local PIOnTarget = FxCreator("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target,0,nil)

	DoDamage(caster, target, math.min(damage, max_damage)  , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	

end

function OnEnumaElishModelChangeStart(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_padoru") then 

	else
		if caster:HasModifier("modifier_alternate_01") then
			local enuma_charge_model = "models/updated_by_seva_and_hudozhestvenniy_film_spizdili/gilgamesh/gilgameshcausalunanimea.vmdl"
			caster:SetModel(enuma_charge_model)
			caster:SetOriginalModel(enuma_charge_model)
		end
	end
end

function OnEnumaElishModelChangeDestroy(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_padoru") then 

	else
		if caster:HasModifier("modifier_alternate_01") then 
			local gil_model = "models/updated_by_seva_and_hudozhestvenniy_film_spizdili/gilgamesh/gilgameshcasualunanim.vmdl"
			caster:SetModel(gil_model)
			caster:SetOriginalModel(gil_model)
		end
	end
end
function OnEnumaElishModelChangeDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_enuma_elish_animation")
	caster:RemoveModifierByName("modifier_max_enuma_elish_animation")
end

function OnEnumaElishChargeStart(keys)
	local caster = keys.caster 
	if caster.IsEnumaImproved then
		caster:SwapAbilities("gilgamesh_enuma_elish_upgrade", "gilgamesh_enuma_elish_activate", false, true)
	else
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_enuma_elish_activate", false, true)
	end
end

function OnEnumaElishChargeDestroy(keys)
	local caster = keys.caster 
	if caster.IsEnumaImproved then
		caster:SwapAbilities("gilgamesh_enuma_elish_upgrade", "gilgamesh_enuma_elish_activate", true, false)
	else
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_enuma_elish_activate", true, false)
	end
end

function OnEnumaElishChargeDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_enuma_elish_activate")
end

function OnMaxEnumaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local frontward = caster:GetForwardVector()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local start_radius = ability:GetSpecialValueFor("start_radius")
	local end_radius = ability:GetSpecialValueFor("end_radius")
	local range = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("speed")
	local enumaTime = range / speed
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + enumaTime)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay)

	if caster:HasModifier("modifier_alternate_01") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_enuma_elish_animation", {duration = cast_delay + 2.1})
		StartAnimation(caster, {duration=cast_delay + 2.1, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.2})
	elseif caster:HasModifier("modifier_alternate_02") then 
		StartAnimation(caster, {duration=cast_delay + 0.5, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.6})
	else
		ability:ApplyDataDrivenModifier(caster, caster, "max_enuma_elish_anim", {})
	end

	if caster:HasModifier("modifier_alternate_02") then 
		EmitGlobalSound("female_gil_max_enuma")
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			Attachments:AttachProp(caster, "attach_sword", "models/gilgamesh/gil_ea.vmdl")
		end
		Timers:CreateTimer(cast_delay + 0.5, function() 
			if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
				local prop = Attachments:GetCurrentAttachment(caster, "attach_sword")
				if prop ~= nil and not prop:IsNull() then
					prop:RemoveSelf()
				end
			end
		end)
	else
		EmitGlobalSound("Gilgamesh_Enuma_1") 
	end
	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("gilgamesh_max_enuma_elish")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	local enuma_ability = caster:FindAbilityByName("gilgamesh_enuma_elish")
	if caster.IsEnumaImproved then 
		enuma_ability = caster:FindAbilityByName("gilgamesh_enuma_elish_upgrade")
	end
	enuma_ability:StartCooldown(enuma_ability:GetCooldown(enuma_ability:GetLevel()))

	local climax = caster:FindAbilityByName("gilgamesh_combo_final_hour")
	climax:StartCooldown(ability:GetCooldown(ability:GetLevel()))

	caster:RemoveModifierByName("modifier_max_enuma_elish_window")
	if caster.IsSumerAcquired then
		caster:RemoveModifierByName("modifier_final_hour_window")
	end
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_enuma_elish_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	-- Create charge particle
	local chargeFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_enuma_elish_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )

	local enuma = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = range - end_radius + 50, -- We need this to take end radius of projectile into account
        fStartRadius = start_radius,
        fEndRadius = end_radius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + cast_delay + 5.0,
        bVisibleToEnemies = true,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}

	Timers:CreateTimer(2.5, function() 
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_02") then 
				FreezeAnimation(caster)
			end
		end
		return
	end)

	Timers:CreateTimer(3.25, function() 
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_02") then 
				EmitGlobalSound("female_gil_enuma")  
			else
				EmitGlobalSound("gilgamesh_enuma_elish")  
			end
		end
		return
	end)

	Timers:CreateTimer(cast_delay, function()
		-- Destroy charge particle regardless of alive/dead
		ParticleManager:DestroyParticle( chargeFxIndex, false )
		ParticleManager:ReleaseParticleIndex( chargeFxIndex )
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_02") then 
				UnfreezeAnimation(caster)
			end
			frontward = caster:GetForwardVector()
			enuma.vSpawnOrigin = caster:GetAbsOrigin()
			enuma.vVelocity = frontward * speed
			projectile = ProjectileManager:CreateLinearProjectile(enuma)
			ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 10000, 0, true)
			ParticleManager:CreateParticle("particles/custom/screen_scarlet_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

			-- Create particle
			local casterLocation = caster:GetAbsOrigin()
			local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummy:SetForwardVector(frontward)

			local radius = start_radius
			local fxIndex = ParticleManager:CreateParticle("particles/custom/gilgamesh/enuma_elish/projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
			ParticleManager:SetParticleControl(fxIndex, 3, targetPoint)

			Timers:CreateTimer( function()
				if IsValidEntity(dummy) and not dummy:IsNull() then
					local newLoc = GetGroundPosition(dummy:GetAbsOrigin() + speed * 0.03 * frontward, dummy)
					dummy:SetAbsOrigin( newLoc )
					radius = radius + (end_radius - start_radius) * speed * 0.03 / enuma.fDistance
					ParticleManager:SetParticleControl(fxIndex, 2, Vector(radius,0,0))
					-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, radius, true, 0.15)
					return 0.03
				else
					return nil
				end
			end
			)
			Timers:CreateTimer(enuma.fDistance / speed - 0.06, function()
				EmitGlobalSound("gilgamesh_laugh_3")
				if IsValidEntity(dummy) then
					dummy:RemoveSelf()
				end
				Timers:CreateTimer(0.4, function()
					if caster:HasModifier("modifier_alternate_01") then 
						caster:RemoveModifierByName("modifier_max_enuma_elish_animation")
					end
				end)
			end)
		end
	end)
end

function OnMaxEnumaHit(keys)
	if keys.target == nil then return end

	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("gilgamesh_max_enuma_elish_upgrade")
	end
	
	local damage = ability:GetSpecialValueFor("damage")

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnFinalHourStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local remaining_swords = ability:GetSpecialValueFor("num_swords")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	local masterCombo = caster.MasterUnit2:FindAbilityByName("gilgamesh_max_enuma_elish")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	local maxea = caster:FindAbilityByName("gilgamesh_max_enuma_elish")
	if caster.IsEnumaImproved then 
		maxea = caster:FindAbilityByName("gilgamesh_max_enuma_elish_upgrade")
	end
	maxea:EndCooldown()
	maxea:StartCooldown(ability:GetCooldown(1))
	caster:RemoveModifierByName("modifier_final_hour_window")
	caster:RemoveModifierByName("modifier_max_enuma_elish_window")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gilgamesh_final_hour_cooldown", {duration = ability:GetCooldown(1)})
		
	local stopOrder = {
 		UnitIndex = target:entindex(), 
 		OrderType = DOTA_UNIT_ORDER_STOP
 	}

 	caster:EmitSound("Gilgamesh.Enkidu") 
 	EmitGlobalSound("Gilgamesh_Alt_Combo_" .. math.random(1,3))
 	ExecuteOrderFromTable(stopOrder)  	

	ability:ApplyDataDrivenModifier(caster, target, "modifier_enkidu_hold", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gilgamesh_combo_active", {})
 	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 3.5)

	local info = {
		Target = target,
		vSourceLoc = nil,
		Ability = ability,
		EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin() + Vector(0, 0, 250),
		iMoveSpeed = 2000
	}	

 	Timers:CreateTimer(1.9, function()
		if remaining_swords <= 0 or not caster:IsAlive() or not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then
		 	caster:RemoveModifierByName("jump_pause")
		 	caster:RemoveModifierByName("modifier_gilgamesh_combo_active")
		 	return 
		end 

		info.vSourceLoc = target:GetAbsOrigin() + RandomVector(450)

		ProjectileManager:CreateTrackingProjectile(info) 

		if remaining_swords % 5 < 1 then
			caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
		end		

		remaining_swords = remaining_swords - 1

		return 0.04
	end)
end

function OnFinalHourHit(keys)
	if keys.target == nil then return end

	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster
	local ability = keys.ability
	
	local damage = ability:GetSpecialValueFor("damage")

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function GilgameshCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsEnumaImproved then
			if string.match(ability:GetAbilityName(), "gilgamesh_gate_of_babylon") 
				and caster:FindAbilityByName("gilgamesh_enuma_elish_upgrade"):IsCooldownReady() 
				and caster:FindAbilityByName("gilgamesh_max_enuma_elish_upgrade"):IsCooldownReady() 
				and not caster:HasModifier("modifier_max_enuma_elish_cooldown")
				and not caster:HasModifier("modifier_gilgamesh_final_hour_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_enuma_elish_window", {})		
			end
		else
			if string.match(ability:GetAbilityName(), "gilgamesh_gate_of_babylon") 
				and caster:FindAbilityByName("gilgamesh_enuma_elish"):IsCooldownReady() 
				and caster:FindAbilityByName("gilgamesh_max_enuma_elish"):IsCooldownReady() 
				and not caster:HasModifier("modifier_max_enuma_elish_cooldown")
				and not caster:HasModifier("modifier_gilgamesh_final_hour_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_enuma_elish_window", {})		
			end
		end
	end
end

function OnMaxEnumaWindowCreate(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_enuma_elish_activate") then 
		caster:RemoveModifierByName("modifier_enuma_elish_activate")
	end
	if caster.IsEnumaImproved then
		caster:SwapAbilities("gilgamesh_enuma_elish_upgrade", "gilgamesh_max_enuma_elish_upgrade", false, true)
	else
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", false, true)
	end
end

function OnMaxEnumaWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsEnumaImproved then
		caster:SwapAbilities("gilgamesh_enuma_elish_upgrade", "gilgamesh_max_enuma_elish_upgrade", true, false)
	else
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", true, false)
	end
end

function OnMaxEnumaWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_max_enuma_elish_window")
end

EUsed = false
ETime = GameRules:GetGameTime()

function GilgameshCheckCombo2(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 and caster.IsSumerAcquired then
		if string.match(ability:GetAbilityName(), "gilgamesh_gate_of_babylon") then
			caster.EUsed = true
			caster.ETime = GameRules:GetGameTime()
			if caster.ETimer ~= nil then 
				Timers:RemoveTimer(caster.ETimer)
				caster.ETimer = nil
			end
			caster.ETimer = Timers:CreateTimer(4.0, function()
				caster.EUsed = false
			end)
		else
			if ability:GetAbilityName() == "gilgamesh_enkidu" 
				and caster:FindAbilityByName("gilgamesh_combo_final_hour"):IsCooldownReady() 
				and caster:FindAbilityByName("gilgamesh_gram_upgrade"):IsCooldownReady() 
				and not caster:HasModifier("modifier_max_enuma_elish_cooldown") 
				and not caster:HasModifier("modifier_gilgamesh_final_hour_cooldown") then
				if caster.EUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 4 - (newTime - caster.ETime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_final_hour_window", {duration = duration})
				end
			end
		end
	end
end

function OnFinalHourWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities("gilgamesh_gram_upgrade", "gilgamesh_combo_final_hour", false, true)
end

function OnFinalHourWindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities("gilgamesh_gram_upgrade", "gilgamesh_combo_final_hour", true, false)
end

function OnFinalHourWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_final_hour_window")
end

function OnImproveGoldenRuleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGoldenRuleImproved) then

		hero.IsGoldenRuleImproved = true

		hero:AddAbility("gilgamesh_golden_rule_upgrade")
		hero:FindAbilityByName("gilgamesh_golden_rule_upgrade"):SetLevel(1)
		if hero.IsSumerAcquired then
			hero:FindAbilityByName("gilgamesh_golden_rule_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("gilgamesh_golden_rule_upgrade", "gilgamesh_golden_rule", true, false)
		end
		hero:RemoveAbility("gilgamesh_golden_rule") 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnPowerOfSumerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSumerAcquired) then

		if hero:HasModifier("modifier_final_hour_window") then 
			hero:RemoveModifierByName("modifier_final_hour_window")
		end

		if hero:HasModifier("modifier_max_enuma_elish_window") then 
			hero:RemoveModifierByName("modifier_max_enuma_elish_window")
		end

		hero.IsSumerAcquired = true

		hero:AddAbility("gilgamesh_gate_of_babylon_upgrade")
		hero:FindAbilityByName("gilgamesh_gate_of_babylon_upgrade"):SetLevel(hero:FindAbilityByName("gilgamesh_gate_of_babylon"):GetLevel())
		hero:SwapAbilities("gilgamesh_gate_of_babylon_upgrade", "gilgamesh_gate_of_babylon", true, false) 
		if not hero:FindAbilityByName("gilgamesh_gate_of_babylon"):IsCooldownReady() then 
			hero:FindAbilityByName("gilgamesh_gate_of_babylon_upgrade"):StartCooldown(hero:FindAbilityByName("gilgamesh_gate_of_babylon"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("gilgamesh_gate_of_babylon")

		if hero.IsGoldenRuleImproved then
			hero:SwapAbilities("gilgamesh_gate_of_babylon_toggle", "gilgamesh_golden_rule_upgrade", true, false)
		else
			hero:SwapAbilities("gilgamesh_gate_of_babylon_toggle", "gilgamesh_golden_rule", true, false)
		end
		hero:FindAbilityByName("gilgamesh_gate_of_babylon_toggle"):ToggleAbility()

		hero:AddAbility("gilgamesh_gram_upgrade")
		hero:FindAbilityByName("gilgamesh_gram_upgrade"):SetLevel(1)
		hero:SwapAbilities("gilgamesh_gram_upgrade", "gilgamesh_gram", true, false)
		if not hero:FindAbilityByName("gilgamesh_gram"):IsCooldownReady() then 
			hero:FindAbilityByName("gilgamesh_gram_upgrade"):StartCooldown(hero:FindAbilityByName("gilgamesh_gram"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("gilgamesh_gram") 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnRainOfSwordsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRainAcquired) then

		hero.IsRainAcquired = true

		hero:AddAbility("gilgamesh_sword_barrage_upgrade")
		hero:AddAbility("gilgamesh_sword_barrage_upgrade_1")
		hero:AddAbility("gilgamesh_sword_barrage_upgrade_2")
		hero:AddAbility("gilgamesh_sword_barrage_upgrade_3")
		hero:AddAbility("gilgamesh_sword_barrage_upgrade_4")
		hero:AddAbility("gilgamesh_sword_barrage_upgrade_5")
		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade_1"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())
		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade_2"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())
		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade_3"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())
		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade_4"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())
		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade_5"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())

		hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):SetLevel(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetLevel())
		hero:SwapAbilities("gilgamesh_sword_barrage_upgrade", "gilgamesh_sword_barrage", true, false) 
		if not hero:FindAbilityByName("gilgamesh_sword_barrage"):IsCooldownReady() then 
			hero:FindAbilityByName("gilgamesh_sword_barrage_upgrade"):StartCooldown(hero:FindAbilityByName("gilgamesh_sword_barrage"):GetCooldownTimeRemaining())
		end
		
		hero:RemoveAbility("gilgamesh_sword_barrage") 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSwordOfCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsEnumaImproved) then

		if hero:HasModifier("modifier_max_enuma_elish_window") then 
			hero:RemoveModifierByName("modifier_max_enuma_elish_window")
		end

		if hero:HasModifier("modifier_enuma_elish_thinker") then 
			caster:SetMana(caster:GetMana() + keys.ability:GetManaCost(keys.ability:GetLevel()))
			keys.ability:EndCooldown()
			return
		end

		hero.IsEnumaImproved = true

		hero:AddAbility("gilgamesh_enuma_elish_upgrade")
		hero:FindAbilityByName("gilgamesh_enuma_elish_upgrade"):SetLevel(hero:FindAbilityByName("gilgamesh_enuma_elish"):GetLevel())
		hero:SwapAbilities("gilgamesh_enuma_elish_upgrade", "gilgamesh_enuma_elish", true, false) 
		if not hero:FindAbilityByName("gilgamesh_enuma_elish"):IsCooldownReady() then 
			hero:FindAbilityByName("gilgamesh_enuma_elish_upgrade"):StartCooldown(hero:FindAbilityByName("gilgamesh_enuma_elish"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("gilgamesh_enuma_elish")

		hero:AddAbility("gilgamesh_max_enuma_elish_upgrade")
		hero:FindAbilityByName("gilgamesh_max_enuma_elish_upgrade"):SetLevel(1)
		if not hero:FindAbilityByName("gilgamesh_max_enuma_elish"):IsCooldownReady() then 
			hero:FindAbilityByName("gilgamesh_max_enuma_elish_upgrade"):StartCooldown(hero:FindAbilityByName("gilgamesh_max_enuma_elish"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("gilgamesh_max_enuma_elish")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
