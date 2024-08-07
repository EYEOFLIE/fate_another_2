avalonCooldown = true -- UP if true, 
vectorA = Vector(0,0,0)
combo_available = false
currentHealth = 0

function OnInstinctStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_active", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_cooldown", {})
end

function OnInstinctCrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_crit_hit", {})
end

function CreateWind(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local movespeed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	
	local particleName = "particles/custom/saber/saber_invisible_air_trail.vpcf"
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 3, caster:GetAbsOrigin() )
	
	caster.invisible_air_reach_target = false

	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	
	if dist > 250 then 
		caster.invisible_air_pos = caster:GetAbsOrigin() + (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 150
	else
		caster.invisible_air_pos = caster:GetAbsOrigin() + (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * dist * 0.6
	end

	
	local invisAirCounter = 0
	Timers:CreateTimer( function() 
		-- If over 3 seconds
		if invisAirCounter > 3.0 then
			ParticleManager:DestroyParticle( fxIndex, false )
			ParticleManager:ReleaseParticleIndex( fxIndex )
			return
		end
			
		local forwardVec = ( target:GetAbsOrigin() - caster.invisible_air_pos ):Normalized()
			
		caster.invisible_air_pos = caster.invisible_air_pos + forwardVec * movespeed * 0.05
			
		ParticleManager:SetParticleControl( fxIndex, 3, caster.invisible_air_pos )
		
		-- Reach first
		if caster.invisible_air_reach_target then
			ParticleManager:DestroyParticle( fxIndex, false )
			ParticleManager:ReleaseParticleIndex( fxIndex )
			return nil
		else
			invisAirCounter = invisAirCounter + 0.05
			return 0.05
		end
	end)
end

function AddAirStack(caster,stack)
	local ability = caster:FindAbilityByName("saber_strike_air_upstream")
	local max_stack = ability:GetSpecialValueFor("max_stack")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_upstream_ready", {})
	local current_stack = caster:GetModifierStackCount("modifier_strike_air_upstream_ready", caster) or 0

	current_stack = current_stack + stack 

	if current_stack > max_stack then 
		caster:SetModifierStackCount("modifier_strike_air_upstream_ready", caster, max_stack)
		return
	elseif max_stack <= 0 then 
		caster:RemoveModifierByName("modifier_strike_air_upstream_ready")
	else
		caster:SetModifierStackCount("modifier_strike_air_upstream_ready", caster, current_stack)
	end
end

function InvisibleAirPull(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(target) -- Linken's
		or (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > ability:GetSpecialValueFor("range")
		or target:IsMagicImmune() -- Magic immunity
		or IsWindProtect(target)
	then
		return
	end

	caster.invisible_air_reach_target = true

	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	if not target:HasModifier("modifier_wind_protection_passive") then
		giveUnitDataDrivenModifier(caster, target, "drag_pause", 1.0)
	end
	target:RemoveModifierByName("modifier_invisible_air_target")
	ability:ApplyDataDrivenModifier(caster, target, "modifier_invisible_air_target", {})

	DoDamage(caster, target , keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if caster.bIsUpstreamAcquired then
		AddAirStack(caster,1)
	end

	if IsValidEntity(target) and target:IsAlive() then
	-- physics stuffs
		if not target:HasModifier("modifier_wind_protection_passive") then
		    local pullTarget = Physics:Unit(keys.target)
		    local dist = (keys.caster:GetAbsOrigin() - keys.target:GetAbsOrigin()):Length2D() 
		    target:PreventDI()
		    target:SetPhysicsFriction(0)
		    target:SetPhysicsVelocity((keys.caster:GetAbsOrigin() - keys.target:GetAbsOrigin()):Normalized() * dist * 2)
		    target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		    target:FollowNavMesh(false)

		  	Timers:CreateTimer('invispull' .. caster:GetPlayerOwnerID(), {
				endTime = 1.0,
				callback = function()
				target:PreventDI(false)
				target:SetPhysicsVelocity(Vector(0,0,0))
				target:OnPhysicsFrame(nil)
			end
			})

			target:OnPhysicsFrame(function(unit)
				if IsValidEntity(unit) and not unit:IsNull() then
				  	local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
				  	local dir = diff:Normalized()
				  	unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
				  	if diff:Length() < 100 then
					  	target:RemoveModifierByName("drag_pause")
						target:RemoveModifierByName( "modifier_invisible_air_target" )		-- Addition
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
				        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
				  	end
				end
			end)
		end
	end
end



--[[
	Author: kritth
	Date: 10.01.2015.
	Create yellowish explosion upon hitting unit
]]
function CaliburnExplode( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local slashParticleName = "particles/custom/saber/caliburn/slash.vpcf"
	local explodeParticleName = "particles/custom/saber/caliburn/explosion.vpcf"


	-- Create particle
	local slashFxIndex = ParticleManager:CreateParticle( slashParticleName, PATTACH_ABSORIGIN, target )
	local explodeFxIndex = ParticleManager:CreateParticle( explodeParticleName, PATTACH_ABSORIGIN, target )
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( slashFxIndex, false )
		ParticleManager:DestroyParticle( explodeFxIndex, false )
		return nil
	end)
end

function OnCaliburnHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mini_stun = ability:GetSpecialValueFor("mini_stun")
	local ply = caster:GetPlayerOwner()

	if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_caliburn_slow", {}) 
	end
	
	local aoedmg = keys.Damage * keys.AoEDamage

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())

    if IsValidEntity(target) and target:IsAlive() then
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = mini_stun })
	end

    local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v , aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end

    DoDamage(caster, target , keys.Damage - aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)

    

    caster:EmitSound("Saber.Caliburn")
    if caster:HasModifier("modifier_alternate_04") then 
    	caster:EmitSound("Saber_Lily_Caliburn")
    elseif caster:HasModifier("modifier_alternate_05") then 
    	caster:EmitSound("Saber-Wedding-W")
    elseif caster:HasModifier("modifier_alternate_06") then 
    	caster:EmitSound("Arthur.Caliburn")
    else
    	caster:EmitSound("saber_attack_01")
    end
end

function OnExcaliburVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_3", {})
end

function OnExcaliburSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end


function OnExcaliburStart(keys)
	EmitGlobalSound("Saber.Excalibur_Ready")
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability

	local width = ability:GetSpecialValueFor("width")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 3.5)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur", {})
	ability:ApplyDataDrivenModifier(caster, caster, "saber_anim_vfx", {})

	if caster:HasModifier("modifier_alternate_01") then
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.36})
	elseif caster:HasModifier("modifier_alternate_02") then
		StartAnimation(caster, {duration=1.6, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.00})
	elseif caster:HasModifier("modifier_alternate_03") then
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.60})
	elseif caster:HasModifier("modifier_alternate_04") then
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.60})
	elseif caster:HasModifier("modifier_alternate_05") then
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.60})
	elseif caster:HasModifier("modifier_alternate_06") then
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.00})
	else
		StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.60})
	end

	local excal = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = keys.Range - width + 100,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	
	if caster:HasModifier("modifier_alternate_06") then 
		EmitGlobalSound("Arthur.Exca") 
	else
		EmitGlobalSound("Saber_Ex") 
	end

	if caster:HasModifier("modifier_alternate_01") then 
		Timers:CreateTimer(0.7, function()
			FreezeAnimation(caster,1.2)
		end)
	end		

	Timers:CreateTimer(keys.Delay - 0.5, function() 
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_06") then 
				EmitGlobalSound("Arthur.Calibur") 
			else
				EmitGlobalSound("Saber_Kalibar") 
			end
			if caster:HasModifier("modifier_alternate_03") then 
				FreezeAnimation(caster,0.5)
			else
				FreezeAnimation(caster,0.5)
			end
			return 
		end
	end)
	-- Create linear projectile
	Timers:CreateTimer(keys.Delay - 0.3, function()
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_01") then
				UnfreezeAnimation(caster)
			elseif caster:HasModifier("modifier_alternate_02") or caster:HasModifier("modifier_alternate_06") then
				StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2_END, rate=1.00})
			elseif caster:HasModifier("modifier_alternate_03") then
				UnfreezeAnimation(caster)
			else
				UnfreezeAnimation(caster)
			end
			excal.vSpawnOrigin = caster:GetAbsOrigin() 
			excal.vVelocity = caster:GetForwardVector() * keys.Speed
			--[[for i = 0, 9 do
				Timers:CreateTimer(i * 0.1, function()
					if caster:IsAlive() then]]
			local projectile = ProjectileManager:CreateLinearProjectile(excal)
					--[[end
				end)
			end]]
			ScreenShake(caster:GetOrigin(), 5, 0.1, 2, 20000, 0, true)
		end
	end)
	
	-- for i=0,1 do
		Timers:CreateTimer(keys.Delay - 0.3, function() -- Adjust 2.5 to 3.2 to match the sound
			if caster:IsAlive() then
				-- Create Particle for projectile
				local casterFacing = caster:GetForwardVector()
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				dummy:SetForwardVector(casterFacing)
				Timers:CreateTimer( function()
						if IsValidEntity(dummy) then
							local newLoc = dummy:GetAbsOrigin() + (keys.Speed * 0.03 * casterFacing)
							dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
							-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.StartRadius, true, 0.15)
							return 0.03
						else
							return nil
						end
					end
				)
				
				local excalFxIndex = ParticleManager:CreateParticle( "particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )
				ParticleManager:SetParticleControl(excalFxIndex, 4, Vector(width * 3,0,0))

				Timers:CreateTimer( 1.15, function()
						ParticleManager:DestroyParticle( excalFxIndex, false )
						ParticleManager:ReleaseParticleIndex( excalFxIndex )
						Timers:CreateTimer( 0.5, function()
								if IsValidEntity(dummy) then
									dummy:RemoveSelf()
								end
								return nil
							end
						)
						return nil
					end
				)
				return 
			end
		end)
	-- end
end


function OnExcaliburHit(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability 

	if not IsValidEntity(target) or target:IsNull() then return end

	if ability == nil then 
		ability = caster:FindAbilityByName("saber_excalibur_upgrade")
	end

	local damage = ability:GetSpecialValueFor("damage")
	if caster.IsExcaliburAcquired then
		local bonus_mana = ability:GetSpecialValueFor("bonus_mana") / 100
		damage = damage + (bonus_mana * caster:GetMaxMana())
	end

	if target == nil then return end
	DoDamage(keys.caster, keys.target, damage --[[*0.1]] , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnExcaliburVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_3", {})
end

function OnExcaliburSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end

function OnMaxVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_3", {})
end

function OnMaxSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end

function OnMaxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	if caster.IsExcaliburAcquired then
		caster:FindAbilityByName("saber_excalibur_upgrade"):StartCooldown(caster:FindAbilityByName("saber_excalibur_upgrade"):GetCooldown(caster:FindAbilityByName("saber_excalibur_upgrade"):GetLevel()))
	else
		caster:FindAbilityByName("saber_excalibur"):StartCooldown(caster:FindAbilityByName("saber_excalibur"):GetCooldown(caster:FindAbilityByName("saber_excalibur"):GetLevel()))
	end
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 5.0)
	ability:ApplyDataDrivenModifier(caster, caster, "saber_max_excalibur_anim_vfx", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur", {})

	if caster:HasModifier("modifier_alternate_01") then 
	    StartAnimation(caster, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.3})
	elseif caster:HasModifier("modifier_alternate_02") then 
	    StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.3})
	elseif caster:HasModifier("modifier_alternate_03") then 
	    StartAnimation(caster, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.21})
	elseif caster:HasModifier("modifier_alternate_04") then 
	    StartAnimation(caster, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.6})
	elseif caster:HasModifier("modifier_alternate_05") then 
	    StartAnimation(caster, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.6})
	elseif caster:HasModifier("modifier_alternate_06") then 
	    StartAnimation(caster, {duration=5.5, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
	    local sword_glow_fx = ParticleManager:CreateParticle("particles/custom/saber/arthur_combo_spiral.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControlEnt(sword_glow_fx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), false)
	    Timers:CreateTimer(2.5, function()
	    	ParticleManager:DestroyParticle(sword_glow_fx, true)
	    	ParticleManager:ReleaseParticleIndex(sword_glow_fx)
	    end)
	else
		StartAnimation(caster, {duration=5.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.21})
	end

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("saber_max_excalibur")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	if caster:HasModifier("modifier_max_excalibur_window") then 
		caster:RemoveModifierByName("modifier_max_excalibur_window")
	end

	local max_excal = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = keys.Range - keys.Width + 100,
        fStartRadius = keys.Width,
        fEndRadius = keys.Width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 6.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	
	if caster:HasModifier("modifier_alternate_04") then 
		EmitGlobalSound("Saber_Lily_Max_Chant_" .. math.random(1,2))
	elseif caster:HasModifier("modifier_alternate_05") then 
		EmitGlobalSound("Saber-Wedding-Combo" .. math.random(1,2))
	elseif caster:HasModifier("modifier_alternate_06") then 
		EmitGlobalSound("Arthur.Combo" .. math.random(1,2)) 
		EmitGlobalSound("Arthur.BGM") 
	else
		EmitGlobalSound("Saber_Max_Chant_" .. math.random(1,2))
	end

	if caster:HasModifier("modifier_alternate_01") then 
		Timers:CreateTimer(0.8, function()
	    	FreezeAnimation(caster, 2.2)
	    end)
	end

	Timers:CreateTimer({
		endTime = 2.5, 
		callback = function()
		if caster:HasModifier("modifier_alternate_04") then 
			EmitGlobalSound("Saber_Lily_Max_Excalibur")
		elseif caster:HasModifier("modifier_alternate_05") then 
			EmitGlobalSound("Saber-Wedding-Combo-Excal")
		elseif caster:HasModifier("modifier_alternate_06") then 
			EmitGlobalSound("Arthur.Excalibur") 
		else
	    	EmitGlobalSound("Saber_Max_Excalibur")
	    end
	    EmitGlobalSound("saber_effect")
	    if caster:HasModifier("modifier_alternate_03") then 
	    	FreezeAnimation(caster, 0.5)
	    else
	    	FreezeAnimation(caster, 0.5)
	    end
	end})

	-- Charge particles
	ParticleManager:CreateParticle("particles/custom/saber/max_excalibur/charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	
	-- Create linear projectile
	Timers:CreateTimer(3.5, function()
		if caster:HasModifier("modifier_alternate_01") then 
			UnfreezeAnimation(caster)
		elseif caster:HasModifier("modifier_alternate_02") then 
	    	StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.67})
	    elseif caster:HasModifier("modifier_alternate_06") then

		elseif caster:HasModifier("modifier_alternate_03") then 
			UnfreezeAnimation(caster)
		else
			UnfreezeAnimation(caster)
		end
		if caster:IsAlive() then
			nBeams2 = 0
			Timers:CreateTimer(function()
				if nBeams2 == 10 then return end
				max_excal.vSpawnOrigin = caster:GetAbsOrigin() 
				max_excal.vVelocity = caster:GetForwardVector() * keys.Speed
				local projectile = ProjectileManager:CreateLinearProjectile(max_excal)
				nBeams2 = nBeams2 + 1
				return 0.1
			end)
			local YellowScreenFx = ParticleManager:CreateParticle("particles/custom/screen_yellow_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
			ScreenShake(caster:GetOrigin(), 7, 2.0, 2, 10000, 0, true)
			
        	Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( YellowScreenFx, false )
			end)
		end
	end)

	local casterFacing = caster:GetForwardVector()
	-- for i=0,1 do
		Timers:CreateTimer({
			endTime = 3, 
			callback = function()
			if caster:IsAlive() then
				nBeams = 0
				Timers:CreateTimer(function()
					if nBeams == 50 then return end
					FireSingleMaxParticle(keys)
					nBeams = nBeams + 1
					return 0.02
				end)
			end
		end})
	-- end
end

function FireSingleMaxParticle(keys)
	local caster = keys.caster
	local casterFacing = caster:GetForwardVector()
	if caster.AltPart.combo == 1 then
		local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin() + 700 * casterFacing, false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		dummy:SetForwardVector(casterFacing)
		Timers:CreateTimer( function()
				if IsValidEntity(dummy) then
					local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.015 * casterFacing
					dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
					-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.Width, true, 0.15)
					return 0.015
				else
					return nil
				end
			end
		)
		
		local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber/max_excalibur/shockwave", PATTACH_ABSORIGIN_FOLLOW, dummy)
		--local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
			
		Timers:CreateTimer(0.36, function()
			ParticleManager:DestroyParticle( excalFxIndex, false )
			ParticleManager:ReleaseParticleIndex( excalFxIndex )
			Timers:CreateTimer( 0.1, function()
					if IsValidEntity(dummy) then
						dummy:RemoveSelf()
					end
					return nil
				end
			)
			return nil
		end)
	else
		local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin() + 300 * casterFacing, false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		dummy:SetForwardVector(casterFacing)
		Timers:CreateTimer( function()
				if IsValidEntity(dummy) then
					local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.015 * casterFacing
					dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
					-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.Width, true, 0.15)
					return 0.015
				else
					return nil
				end
			end
		)
		
		local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber/max_excalibur/shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
		--local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
			
		Timers:CreateTimer(0.57, function()
			ParticleManager:DestroyParticle( excalFxIndex, false )
			ParticleManager:ReleaseParticleIndex( excalFxIndex )
			Timers:CreateTimer( 0.1, function()
					if IsValidEntity(dummy) then
						dummy:RemoveSelf()
					end
					return nil
				end
			)
			return nil
		end)
	end
end

function OnMaxHit(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("saber_max_excalibur_upgrade")
	end
	local damage = ability:GetSpecialValueFor("damage")
	local ply = caster:GetPlayerOwner()
	if target.IsMaxcaHit ~= true then
		target.IsMaxcaHit = true
		Timers:CreateTimer(3, function() target.IsMaxcaHit = false return end)
		DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
	--DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnAvalonStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsAvalonOnCooldown == true then 
		Timers:RemoveTimer('avalon_dash')
	end
	caster.IsAvalonOnCooldown = false
	caster:RemoveModifierByName("modifier_avalon")
	caster.avalon_proc = 1

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_avalon", {})
	--giveUnitDataDrivenModifier(caster, caster, "disarmed", 3)
	currentHealth = keys.caster:GetHealth()

	caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
	EmitGlobalSound("Saber.Avalon")
	if caster:HasModifier("modifier_alternate_06") then 
		EmitGlobalSound("Arthur.Avalon")
	else
		EmitGlobalSound("Saber.Avalon_Shout")
	end

	if caster.IsUtopiaAcquired then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_everdistant_utopia", {})
	end

	SaberCheckCombo(keys.caster, keys.ability)
end

function AvalonOnTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	local pid = caster:GetPlayerID() 
	local diff = 0
	local damageTaken = keys.DamageTaken
	local newCurrentHealth = caster:GetHealth()
	local emitwhichsound = RandomInt(1, 2)
	local damage = ability:GetSpecialValueFor("damage")
	local range = ability:GetSpecialValueFor("range")
	local duration = ability:GetSpecialValueFor("duration")
	
	--if caster.IsAvalonPenetrated then return end

	if caster:IsAlive() and not caster:HasModifier("pause_sealdisabled") and not caster:HasModifier("modifier_max_excalibur") and caster.avalon_proc > 0 and caster.IsAvalonProc == true and caster:GetTeam() ~= attacker:GetTeam() and caster.IsAvalonOnCooldown == false and (caster:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D() < range then 
		if emitwhichsound == 1 then attacker:EmitSound("Saber.Avalon_Counter1") else attacker:EmitSound("Saber.Avalon_Counter2") end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_saber_avalon_dash", {})
		AvalonDash(caster, attacker, damage, ability)
		caster.IsAvalonOnCooldown = true
		Timers:CreateTimer('avalon_dash' .. caster:GetPlayerOwnerID(),{
			endTime = duration - 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			callback = function()
		    caster.IsAvalonOnCooldown = false
		    end
		})
	end 
end 

function AvalonDash(caster, attacker, counterdamage, ability)
	local targetPoint = attacker:GetAbsOrigin()
	local casterDash = Physics:Unit(caster)
	local distance = targetPoint - caster:GetAbsOrigin()
	local aoe = ability:GetSpecialValueFor("aoe")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local cleanseCounter = 0
	local speed = math.max(distance:Length2D(), 500) * 2.5
		Timers:CreateTimer(function()
			if cleanseCounter >= 10 then return end
			HardCleanse(caster)
			cleanseCounter = cleanseCounter + 1
			return 0.05
		end)

	if not caster:IsAlive() then return end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", (distance/(math.max(distance:Length2D(), 500) * 2.5)) + 0.05  --[[0.45]])
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(distance:Normalized() * speed)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(true)
	caster:SetAutoUnstuck(false)

	caster:OnPhysicsFrame(function(unit) 
		local diff = attacker:GetAbsOrigin() - caster:GetAbsOrigin()
		caster:SetPhysicsVelocity(diff:Normalized() * speed)
		if not caster:HasModifier("modifier_saber_avalon_dash") or diff:Length() <= 200 then -- if pushback distance is over 500, stop it
			caster:RemoveModifierByName("modifier_saber_avalon_dash")
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end)
	
	--[[Timers:CreateTimer({
		endTime = 0.4,
		callback = function()

	    --stop the dash
	    caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		-- Original function
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	        	v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	        	DoDamage(caster, v, counterdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        end
	    end
	    
		caster:AddNewModifier(caster, nil, "modifier_camera_follow", {Duration = 1.0})
		Timers:CreateTimer(1.0, function()
			if not caster.IsUtopiaAcquired then
				caster:RemoveModifierByName("modifier_avalon")
			end
		end)
		HardCleanse(caster)

		-- Particles
		--local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_impact.vpcf", PATTACH_ABSORIGIN, caster )
		local explosionFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_explosion.vpcf", PATTACH_WORLDORIGIN, caster )
		ParticleManager:SetParticleControl( explosionFxIndex, 3, caster:GetAbsOrigin() )
		EmitSoundOn( "Hero_EarthShaker.Fissure", caster )

		
		Timers:CreateTimer( 3.0, function()
			--ParticleManager:DestroyParticle( impactFxIndex, false )
			ParticleManager:DestroyParticle( explosionFxIndex, false )
		end)
		
	end
	})]]
end

function OnAvalonCounter(keys)
	local caster = keys.caster
	local ability = keys.ability
	local aoe = ability:GetSpecialValueFor("aoe")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	-- Original function
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	       	v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	       	DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	    end
    end
	    
	caster:AddNewModifier(caster, nil, "modifier_camera_follow", {Duration = 1.0})
	Timers:CreateTimer(1.0, function()
		if not caster.IsUtopiaAcquired then
			caster:RemoveModifierByName("modifier_avalon")
		end
	end)
	HardCleanse(caster)

		-- Particles
		--local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_impact.vpcf", PATTACH_ABSORIGIN, caster )
	local explosionFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_explosion.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( explosionFxIndex, 3, caster:GetAbsOrigin() )
	EmitSoundOn( "Hero_EarthShaker.Fissure", caster )

		
	Timers:CreateTimer( 3.0, function()
			--ParticleManager:DestroyParticle( impactFxIndex, false )
		ParticleManager:DestroyParticle( explosionFxIndex, false )
	end)
end

function OnStrikeAirStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local width = keys.ability:GetSpecialValueFor("width")
	local length = keys.ability:GetSpecialValueFor("length")
	local speed = keys.ability:GetSpecialValueFor("speed")
	local cast_time = keys.ability:GetSpecialValueFor("cast_time")

	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", cast_time)
	if caster:HasModifier("modifier_alternate_01") then 
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	elseif caster:HasModifier("modifier_alternate_02") then
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.00})
	elseif caster:HasModifier("modifier_alternate_03") then 
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	elseif caster:HasModifier("modifier_alternate_04") then 
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	elseif caster:HasModifier("modifier_alternate_05") then 
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	elseif caster:HasModifier("modifier_alternate_06") then
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.00})
	else
		StartAnimation(caster, {duration=cast_time, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.3})
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	local strikeair = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/saber_strike_air_blast.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = length - width + 100,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 6.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}
	
	Timers:CreateTimer({
		endTime = cast_time, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
		if caster:IsAlive() then 
			if caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_04") then 
				--StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1.0})
			elseif caster:HasModifier("modifier_alternate_03") then 
				StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1.0})
			elseif caster:HasModifier("modifier_alternate_06") then 
				StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})
			else
				StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1})
			end
			strikeair.vSpawnOrigin = caster:GetAbsOrigin() 
			strikeair.vVelocity = caster:GetForwardVector() * speed
			projectile = ProjectileManager:CreateLinearProjectile(strikeair)
			if caster:HasModifier('modifier_alternate_06') then 
				EmitGlobalSound("Arthur.StrikeAir")
			else
				EmitGlobalSound("Saber.StrikeAir_Release" .. RandomInt(1, 2))
			end
		end
	end})
	if caster:HasModifier('modifier_alternate_06') then 
		EmitGlobalSound("Arthur.Kaze" .. RandomInt(1, 2))
	else
		EmitGlobalSound("Saber.StrikeAir_Cast")
	end
	caster:EmitSound("Hero_Invoker.Tornado")
	ability:ApplyDataDrivenModifier(caster, caster, "saber_strike_air_anim_vfx", {})
end

function StrikeAirPush(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() then return end

	local ability = keys.ability
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	local bonus_agi = ability:GetSpecialValueFor("bonus_agi")
	local bonus_stack = ability:GetSpecialValueFor("bonus_stack")
	local stack = caster:GetModifierStackCount("modifier_strike_air_upstream_ready", caster) or 0
	local knock = ability:GetSpecialValueFor("knock")
	if target == nil then return end

	if IsWindProtect(target) then return end
	local totalDamage = base_damage + (caster:GetAbilityByIndex(0):GetLevel() * bonus_damage) + (bonus_agi * caster:GetAgility()) + (stack * bonus_stack)
	--if (target:GetName() == "npc_dota_hero_bounty_hunter" and target.IsPFWAcquired) then return end
	--[[if caster.IsChivalryAcquired then
		totalDamage = base_damage + ((caster:FindAbilityByName("saber_invisible_air_upgrade"):GetLevel() + caster:FindAbilityByName("saber_caliburn_upgrade"):GetLevel()) * bonus_damage)
	else
		totalDamage = base_damage + ((caster:FindAbilityByName("saber_invisible_air"):GetLevel() + caster:FindAbilityByName("saber_caliburn"):GetLevel()) * bonus_damage)
	end]]
	--if target:GetName() == "npc_dota_hero_juggernaut" then totalDamage = 0 end
	--+ (keys.caster:FindAbilityByName("saber_caliburn"):GetLevel() 
	local WallDamage = keys.WallDamage
	local WallStun = keys.WallStun

	DoDamage(caster, target, totalDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	if IsValidEntity(target) and target:IsAlive() then
		giveUnitDataDrivenModifier(caster, target, "pause_sealenabled", 0.5)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_strike_air_target_VFX", {})

	    local pushTarget = Physics:Unit(target)
	    target:PreventDI()
	    target:SetPhysicsFriction(0)
		local vectorC = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()) 
		-- get the direction where target will be pushed back to
		local vectorB = vectorC - vectorA
		target:SetPhysicsVelocity(vectorB:Normalized() * 1000)
	    target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
		local initialUnitOrigin = target:GetAbsOrigin()
		
		target:OnPhysicsFrame(function(unit) -- pushback distance check
			if IsValidEntity(unit) and not unit:IsNull() then
				local unitOrigin = unit:GetAbsOrigin()
				local diff = unitOrigin - initialUnitOrigin
				local n_diff = diff:Normalized()
				unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
				if diff:Length() > knock then -- if pushback distance is over 500, stop it
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
				end
			end
		end)
		
		target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
			if IsValidEntity(unit) and not unit:IsNull() then
				unit:SetBounceMultiplier(0)
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:AddNewModifier(caster, ability, "modifier_stunned", { Duration = WallStun })
				--giveUnitDataDrivenModifier(caster, target, "stunned",  WallStun)
				DoDamage(caster, unit, WallDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end)
	end
end

function OnUpstreamProc(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster.UpstreamHitCooldown or caster.UpstreamProcCooldown then return end
	--if keys.target:GetName() == "npc_dota_hero_bounty_hunter" and keys.target.IsPFWAcquired then return end
	caster.UpstreamProcCooldown = true
	Timers:CreateTimer(4.0, function()
		caster.UpstreamProcCooldown = false
	end)
	-- particle
	local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( upstreamFx, 0, target:GetAbsOrigin() )

	-- apply knockup
	local damage = caster:GetAttackDamage() * 1.3 + 150
	--if target:GetName() == "npc_dota_hero_juggernaut" then damage = 0 end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	if IsValidEntity(target) and target:IsAlive() then
		ApplyAirborne(caster, target, 1.25)
	end
	--local sound = RandomInt(1,2)
	
	--[[if sound == 1 then 
		caster:EmitSound("Saber.StrikeAir_Release1") 
	else 
		caster:EmitSound("Saber.StrikeAir_Release2") 
	end]]
	
end

function OnUpstreamHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local knockup_duration = ability:GetSpecialValueFor("knockup_duration")
	local ad_ratio = ability:GetSpecialValueFor("ad_ratio")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local stack = caster:GetModifierStackCount("modifier_strike_air_upstream_ready", caster) or 1
	--if keys.target:GetName() == "npc_dota_hero_bounty_hunter" and keys.target.IsPFWAcquired then return end
	-- particle
	local damage = caster:GetAttackDamage() * ad_ratio + (base_damage * stack)

	local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( upstreamFx, 0, target:GetAbsOrigin() )

	--if target:GetName() == "npc_dota_hero_juggernaut" then damage = 0 end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	if IsValidEntity(target) and target:IsAlive() then
		ApplyAirborne(caster, target, knockup_duration)
	end
	caster:RemoveModifierByName("modifier_strike_air_upstream_ready")
	
	caster:EmitSound("Saber.StrikeAir_Release" .. RandomInt(1,2)) 

	caster.UpstreamHitCooldown = true
	Timers:CreateTimer(0.1, function()
		caster.UpstreamHitCooldown = false
	end)
end

function SaberCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsExcaliburAcquired then
			if string.match(ability:GetAbilityName(), 'saber_avalon') and caster:FindAbilityByName("saber_excalibur_upgrade"):IsCooldownReady() and caster:FindAbilityByName("saber_max_excalibur_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_max_excalibur_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur_window", {})	
			end
		else
			if string.match(ability:GetAbilityName(), 'saber_avalon') and caster:FindAbilityByName("saber_excalibur"):IsCooldownReady() and caster:FindAbilityByName("saber_max_excalibur"):IsCooldownReady() and not caster:HasModifier("modifier_max_excalibur_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur_window", {})	
			end
		end
	end
end

function OnMaxExcaWindow(keys)
	local caster = keys.caster 
	if caster.IsExcaliburAcquired then
		caster:SwapAbilities("saber_excalibur_upgrade", "saber_max_excalibur_upgrade", false, true) 
	else
		caster:SwapAbilities("saber_excalibur", "saber_max_excalibur", false, true) 
	end
end

function OnMaxExcaWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsExcaliburAcquired then
		caster:SwapAbilities("saber_excalibur_upgrade", "saber_max_excalibur_upgrade", true, false) 
	else
		caster:SwapAbilities("saber_excalibur", "saber_max_excalibur", true, false) 
	end
end

function OnMaxExcaWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_max_excalibur_window")
end

function OnImproveExcaliburAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsExcaliburAcquired) then

		hero.IsExcaliburAcquired = true

		if hero:HasModifier("modifier_max_excalibur_window") then 
			hero:RemoveModifierByName("modifier_max_excalibur_window")
		end

		UpgradeAttribute(hero, 'saber_excalibur', 'saber_excalibur_upgrade', true)
		UpgradeAttribute(hero, 'saber_max_excalibur', 'saber_max_excalibur_upgrade', false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveInstinctAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsInstinctImproved) then

		hero.IsInstinctImproved = true

		hero:FindAbilityByName("saber_improved_instinct"):SetLevel(1)
		hero:SwapAbilities("saber_instinct","saber_improved_instinct", false, true)
		hero:RemoveAbility("saber_instinct")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnChivalryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsChivalryAcquired) then

		hero.IsChivalryAcquired = true
		UpgradeAttribute(hero, 'saber_invisible_air', 'saber_invisible_air_upgrade', true)
		UpgradeAttribute(hero, 'saber_caliburn', 'saber_caliburn_upgrade', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnStrikeAirAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsStrikeAirAcquired) then

		hero.IsStrikeAirAcquired = true

		if GetMapName() == "fate_tutorial" then 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest5a = true})
		end

		hero:SwapAbilities("saber_charisma","saber_strike_air", false, true)

		hero.bIsUpstreamAcquired = true
		local upstreamAbil = hero:AddAbility("saber_strike_air_upstream")
		upstreamAbil:SetLevel(1)
		upstreamAbil:SetHidden(true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSAUpstreamAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if PlayerResource:GetConnectionState(caster:GetPlayerOwnerID()) == 3 then 
		SendErrorMessage(caster:GetMainControllingPlayer(), "#Player_" .. caster:GetPlayerOwnerID() .. "_is_disconnected")
		caster:SetMana(caster:GetMana() + keys.ability:GetManaCost(keys.ability:GetLevel()))
		keys.ability:EndCooldown()
		return
	end

	if hero.bIsUpstreamAcquired then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#This_attribute_is_already_upgraded")
		caster:SetMana(caster:GetMana() + keys.ability:GetManaCost(keys.ability:GetLevel()))
		return
	end

	hero.bIsUpstreamAcquired = true
	local upstreamAbil = hero:AddAbility("saber_strike_air_upstream")
	upstreamAbil:SetLevel(1)
	upstreamAbil:SetHidden(true)
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSAAvalonAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsUtopiaAcquired) then

		hero.IsUtopiaAcquired = true
		UpgradeAttribute(hero, 'saber_avalon', 'saber_avalon_upgrade', true)

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

