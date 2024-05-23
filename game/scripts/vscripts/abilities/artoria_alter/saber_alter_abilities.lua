
function OnDerangeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	
	DSCheckCombo(keys.caster, keys.ability)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_derange", {} )

	if caster.IsManaBlastAcquired then
		--[[
			Fix a bug where user can have more than 7 charges and add VFX
		]]
		local maximum_charges = ability:GetSpecialValueFor("maximum_charges")
		local min_charge = ability:GetSpecialValueFor("min_charge")
		local max_charge = ability:GetSpecialValueFor("max_charge")
		
		-- Check the amount of next charge
		local next_charge = RandomInt(min_charge, max_charge)

		-- Check if the charges will become over capacity
		if not caster.ManaBlastCount then caster.ManaBlastCount = 0 end	-- This might be because I was debugging it to double check nil value

		if caster.ManaBlastCount + next_charge > maximum_charges then
			if caster.ManaBlastCount == maximum_charges then
				next_charge = 0
			else
				next_charge = caster.ManaBlastCount + next_charge - maximum_charges
			end
			caster.ManaBlastCount = maximum_charges
		else
			caster.ManaBlastCount = caster.ManaBlastCount + next_charge
		end
		
		-- Adding modifiers
		for i = 1, next_charge do
			keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_derange_mana_catalyst_VFX", {} )
		end
		
		-- Update the charge
		caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
	end

	caster:EmitSound("Saber_Alter.Derange")
	caster:EmitSound("saber_alter_other_01")

	if caster.IsAirBurstAcquired and not caster:HasModifier("modifier_air_burst_cooldown") then 
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_air_burst_window", {} )
	end
end

function OnDerangeAttackStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, target, "modifier_armor_reduction", {} )
end

function OnDerangeDeath(keys)
	local caster = keys.caster
	caster.ManaBlastCount = 0
	caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
end

function OnDarklightProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end

function OnUFStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local UFCount = 0
	local bonusDamage = 0
	local bonus_str = ability:GetSpecialValueFor("bonus_str")
	local bonus_int = ability:GetSpecialValueFor("bonus_int")

	if caster.IsFerocityImproved then
		bonusDamage = caster:GetStrength()*bonus_str + caster:GetIntellect()*bonus_int
	end

	if caster:HasModifier('modifier_alternate_02') then 
		caster:EmitSound("Salter-F")
	else
		caster:EmitSound("saber_alter_other_03") 
	end

	DSCheckCombo(caster, ability)
	Timers:CreateTimer(function()
		if UFCount == 5 or not caster:IsAlive() then return end
		caster:EmitSound("Saber_Alter.Unleashed") 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if not IsImmuneToCC(v) and IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	        	v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 0.1})
	        end
	        DoDamage(caster, v, v:GetHealth() * keys.Damage / 100 + bonusDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    end
		UFCount = UFCount + 1;
		return 0.5
		end
	)

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_unleashed_ferocity_caster_VFX_controller", {} )
end

function OnUFCreateVfx(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_unleashed_ferocity_caster_VFX", {} )
end

function OnDarklightCrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_darklight_crit_hit", {} )
end

function OnMBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local stunDuration = ability:GetSpecialValueFor("stun")
	local bonus_int = ability:GetSpecialValueFor("bonus_int")
	local bonus_mana = ability:GetSpecialValueFor("bonus_mana")
	local bonus_cost = ability:GetSpecialValueFor("bonus_cost")

	if caster.IsManaShroudImproved == true then 
		keys.Damage = keys.Damage + bonus_int * caster:GetIntellect()
	end


	if caster.IsManaBlastAcquired then
		keys.Damage = keys.Damage + (caster:GetMana() * bonus_mana/100)
		caster:SpendMana(caster:GetMana() * bonus_cost/100, ability)
	end

	caster:EmitSound("Saber_Alter.ManaBurst") 

	if caster:HasModifier('modifier_alternate_02') then 
		caster:EmitSound("Salter-W")
	else
		caster:EmitSound("saber_alter_attack_03")
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/items2_fx/skadi_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 500
	}
	
	if caster.IsManaBlastAcquired and #targets ~= 0 then
		-- Force remove all particles
		while caster:HasModifier( "modifier_derange_mana_catalyst_VFX" ) do
			caster:RemoveModifierByName( "modifier_derange_mana_catalyst_VFX" )
		end
		
		while caster.ManaBlastCount ~= 0 do
			info.Target = targets[math.random(#targets)]
			ProjectileManager:CreateTrackingProjectile(info) 
			caster.ManaBlastCount = caster.ManaBlastCount - 1
		end
		
		-- Update the charge
		caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
	end

	-- 1.24c particle fix
	-- Slight fix to make the particle size respect the actual AoE after obtaining SA
	local mbParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(mbParticle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(mbParticle, 1, Vector(keys.Radius, 0, 0))
	ParticleManager:SetParticleControl(mbParticle, 2, Vector(1.0, 0, 0))

	for k,v in pairs(targets) do
		if not IsImmuneToCC(v) then
		    v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stunDuration})
		end
	    DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_mana_burst_VFX", {} )
end

function OnManaBlastHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local derange_dmg = ability:GetSpecialValueFor("derange_dmg")
	DoDamage(keys.caster, keys.target, derange_dmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMMBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	local mana_ratio = ability:GetSpecialValueFor("mana_ratio")
	local inner_range = ability:GetSpecialValueFor("inner_range")
	local low = ability:GetSpecialValueFor("low")
	local medium_range = ability:GetSpecialValueFor("medium_range")
	local moderate = ability:GetSpecialValueFor("moderate")

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("saber_alter_max_mana_burst")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	if caster:HasModifier("modifier_max_mana_burst_window") then 
		caster:RemoveModifierByName("modifier_max_mana_burst_window")
	end
	caster:GetAbilityByIndex(1):StartCooldown(15.0)

	--local inner_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, inner_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	--local moderate_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, medium_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local outer_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	EmitGlobalSound("Saber_Alter.MMB" ) 
	EmitGlobalSound("saber_alter_other_04")
	EmitGlobalSound("Saber_Alter.MMBAfter") 
	local BlueSplashFx = ParticleManager:CreateParticle("particles/custom/screen_blue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	ScreenShake(caster:GetOrigin(), 15, 2.0, 2, 10000, 0, true)
	-- Destroy particle
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( BlueSplashFx, false )
	end)

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_max_mana_burst_VFX", {} )

	local dmg = caster:GetMaxMana() * mana_ratio / 100

	for k,v in pairs(outer_targets) do 
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			local distance = (v:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			if distance <= inner_range then
				DoDamage(caster, v, dmg , DAMAGE_TYPE_MAGICAL, 0, ability)
			elseif distance > inner_range and distance <= medium_range then
				DoDamage(caster, v, dmg * moderate / 100 , DAMAGE_TYPE_MAGICAL, 0, ability)
			elseif distance > medium_range then 
				DoDamage(caster, v, dmg * low / 100 , DAMAGE_TYPE_MAGICAL, 0, ability)
			end
		end
	end

end

vortigernCount = 0
function OnVortigernStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local forward = ( keys.target_points[1] - caster:GetAbsOrigin() ):Normalized() -- caster:GetForwardVector() 
	local angle = 120
	local increment_factor = 30
	local origin = caster:GetAbsOrigin()
	local destination = origin + forward
	local radius = ability:GetSpecialValueFor("radius")

	if (math.abs(destination.x - origin.x) < 0.01) and (math.abs(destination.y - origin.y) < 0.01) then
		destination = caster:GetForwardVector() + caster:GetAbsOrigin()
	end
	
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.70) -- Beam interval * 9 + 0.44
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = 3000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = radius,
		Source = caster,
		fStartRadius = 75,
        fEndRadius = 120,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0,
	}
	if caster.IsFerocityImproved then 
		if (ability:GetCurrentAbilityCharges() > 0) then
			ability:EndCooldown()
		end
	end

	--[[if caster.IsFerocityImproved then
		local stacks = caster:GetModifierStackCount("modifier_vortigern_ferocity_base", caster)
		if stacks > 1 then
			ability:EndCooldown()
			caster:SetModifierStackCount("modifier_vortigern_ferocity_base", caster, stacks - 1)
		elseif stacks == 1 then
			caster:SetModifierStackCount("modifier_vortigern_ferocity_base", caster, stacks - 1)
		end
		if not caster:HasModifier("modifier_vortigern_ferocity_progress") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_vortigern_ferocity_progress", {})
		end
		caster:SetModifierStackCount("modifier_vortigern_ferocity_progress", caster, stacks - 1)
		caster:RemoveModifierByName("modifier_vortigern_ferocity_show")
	end]]

	
	--[[local casterAngle = QAngle(0, 120 ,0)
	Timers:CreateTimer(function() 
			if vortigernCount == 10 then vortigernCount = 0 return end -- finish spell
			vortigernBeam.vVelocity = RotatePosition(caster:GetAbsOrigin(), casterAngle, forward * 3000) 
			local projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 24;
			print(casterAngle.y)
			vortigernCount = vortigernCount + 1; 
			
			return 0.040 
		end
	)]]
	
	-- Base variables


	vortigernCount = 0
	Timers:CreateTimer( function()
			-- Finish spell, need to include the last angle as well
			-- Note that the projectile limit is currently at 9, to increment this, need to create either dummy or thinker to store them
			if vortigernCount == 9 then return end
			
			-- Start rotating
			local theta = ( angle - vortigernCount * increment_factor ) * math.pi / 180
			local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
			local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y

			local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
			vortigernBeam.vVelocity = new_forward * 3000
			vortigernBeam.fExpireTime = GameRules:GetGameTime() + 0.4
			
			-- Fire the projectile
			local projectile = ProjectileManager:CreateLinearProjectile( vortigernBeam )
			vortigernCount = vortigernCount + 1
			
			-- Create particles
			local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/saber_alter/saber_alter_vortigern_line.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex1, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex1, 1, vortigernBeam.vVelocity )
			ParticleManager:SetParticleControl( fxIndex1, 2, Vector( 0.2, 0.2, 0.2 ) )
			
			Timers:CreateTimer( 0.2, function()
					ParticleManager:DestroyParticle( fxIndex1, false )
					ParticleManager:ReleaseParticleIndex( fxIndex1 )
					return nil
				end
			)
			
			return 0.06
		end
	)
end

function OnVortigernStackGain(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local stacks = caster:GetModifierStackCount("modifier_vortigern_ferocity_base", caster)
	if stacks < 2 then
		caster:SetModifierStackCount("modifier_vortigern_ferocity_base", caster, stacks + 1)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_vortigern_ferocity_progress", {})
		caster:SetModifierStackCount("modifier_vortigern_ferocity_progress", caster, stacks + 1)
	else
		caster:SetModifierStackCount("modifier_vortigern_ferocity_base", caster, 3)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_vortigern_ferocity_show", {})
		caster:SetModifierStackCount("modifier_vortigern_ferocity_show", caster, 3)
	end
end	

function OnVortigernStackRespawn(keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:SetModifierStackCount("modifier_vortigern_ferocity_base", caster, 3)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vortigern_ferocity_show", {})
	caster:SetModifierStackCount("modifier_vortigern_ferocity_show", caster, 3)
end

function OnVortigernHit(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() then return end

	--local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local damage = keys.Damage
	local StunDuration = keys.StunDuration
	local vortSwingDamage = 5
	local low_end = keys.ability:GetSpecialValueFor("low_end")

	damage = damage * (low_end + vortigernCount * vortSwingDamage) / 100

	--[[if caster.IsFerocityImproved then 
		if caster:HasModifier("modifier_vortigern_ferocity") then
			damage = damage * 0.66
		end		
	end]]
	
	StunDuration = StunDuration * (low_end + vortigernCount * 5)/100

	if target.IsVortigernHit ~= true then
		target.IsVortigernHit = true
		Timers:CreateTimer(0.54, function() target.IsVortigernHit = false return end)
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		if IsValidEntity(target) and target:IsAlive() then
			if not IsImmuneToCC(target) then
				target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = StunDuration})
			end		
		end
	end

end

--[[ function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local casterVec = caster:GetForwardVector()
	local targetVec = Vector(0,0,0)
	local damage = keys.Damage
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.4)
	if caster.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end

	local angle = 0
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigerndmg = {
		attacker = caster,
		victim = nil,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        targetVec = v:GetAbsOrigin() - caster:GetAbsOrigin() 
        degree = CalculateAngle(casterVec, targetVec)*180/math.pi -- degree from caster to target
        -- Starts at 120(85% damage), ends at -120(120% damage)
        if degree <= 120 and degree >= -120 then
        	local multiplier = 0.85 + (120 - degree)/(240/0.35)
        	DoDamage(caster, v, damage * multiplier , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--print(degree .. " " .. multiplier)
        	v:AddNewModifier(caster, target, "modifier_stunned", {duration = keys.StunDuration})
        end
    end
end]]

function OnDexVfxControllerStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_3", {})
end

function OnDexVfxPhase2Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_2", {})
end


function OnDexStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 4.2)

	--local morgan = ParticleManager:CreateParticle("particles/custom/saber_alter/salter_exca_morgan_dip_purple.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	--ParticleManager:SetParticleControlEnt(morgan, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
	
	EmitGlobalSound("Saber.Caliburn")
	EmitGlobalSound("Excalibur_Morgan_Precast")
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_VFX_controller", {})

	StartAnimation(caster, {duration=4, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.9})

	Timers:CreateTimer(0.5, function() 
		if caster:IsAlive() then
			if caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_03") then  
				FreezeAnimation(caster)
			end
		end
	end)

	local dex = 
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
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * keys.Speed
	}	

	Timers:CreateTimer(1.0, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Excalibur_Morgan")
		end
	end)

	Timers:CreateTimer(2.75, function()
		if caster:IsAlive() then
			--EmitGlobalSound("Saber.Excalibur_Ready")
			dex.vSpawnOrigin = caster:GetAbsOrigin() 
			dex.vVelocity = caster:GetForwardVector() * keys.Speed

			local angle = caster:GetAnglesAsVector().y
			local end_point = GetRotationPoint(caster:GetAbsOrigin(),keys.Range - keys.Width + 100,angle)

			projectile = ProjectileManager:CreateLinearProjectile(dex)
			ScreenShake(caster:GetOrigin(), 7, 2.0, 2, 10000, 0, true)
			if caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_03") then  
				UnfreezeAnimation(caster)
			end
			local beam = ParticleManager:CreateParticle("particles/custom/saber_alter/salter_exca_morgan_beam.vpcf", PATTACH_WORLDORIGIN, caster )
			ParticleManager:SetParticleControl(beam, 0, dex.vSpawnOrigin + Vector(0,0,200))
			ParticleManager:SetParticleControl(beam, 1, end_point + Vector(0,0,200))	
			ParticleManager:SetParticleControl(beam, 2, Vector(keys.Width - 100,0,0))

			local glow = ParticleManager:CreateParticle("particles/custom/saber_alter/saber_alter_excalibur_beam_charge_expanding.vpcf", PATTACH_WORLDORIGIN, caster )
			ParticleManager:SetParticleControl(glow, 0, dex.vSpawnOrigin + Vector(0,0,150))
			ParticleManager:SetParticleControl(glow, 1, Vector(keys.Width - 50,0,0))	
			ParticleManager:SetParticleControl(glow, 2, dex.vVelocity)
			Timers:CreateTimer(0.7, function()
				ParticleManager:DestroyParticle( beam, false )
				ParticleManager:ReleaseParticleIndex( beam )
				ParticleManager:DestroyParticle( glow, true )
				ParticleManager:ReleaseParticleIndex( glow )
			end)
		end
		--ParticleManager:DestroyParticle( morgan, false )
		--ParticleManager:ReleaseParticleIndex( morgan )
	end)

	--[[Timers:CreateTimer(2.75, function()
		if caster:IsAlive() then
			-- Create Particle for projectile
			local casterFacing = caster:GetForwardVector()
			local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummy:SetForwardVector(casterFacing)
			Timers:CreateTimer( function()
					if IsValidEntity(dummy) then
						local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * casterFacing
						dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
						-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.StartRadius, true, 0.15)
						return 0.03
					else
						return nil
					end
				end
			)
			
			local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber_alter/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )

			Timers:CreateTimer( 1.5, function()
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
	end)]]
end

function OnDexHit(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() then return end

	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("saber_alter_excalibur_upgrade")
	end 
	local damage = ability:GetSpecialValueFor("damage")
	if caster.IsDarklightAcquired then 
		local bonus_mana = ability:GetSpecialValueFor("bonus_mana") / 100
		damage = damage + (bonus_mana * caster:GetMaxMana())
	end
	
	if target == nil then return end

	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnAirBurstWindow(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.DSkill, "saber_alter_air_burst", false, true)
end

function OnAirBurstDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.DSkill, "saber_alter_air_burst", true, false)
end

function OnAirBurstDied(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_air_burst_window")
end

function OnAirBurstStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local speed = ability:GetSpecialValueFor("speed")
	local range = ability:GetSpecialValueFor("range")
	local width = ability:GetSpecialValueFor("width")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_air_burst_cooldown", {Duration=ability:GetCooldown(1)})
	caster:RemoveModifierByName("modifier_air_burst_window")

	EmitGlobalSound("Saber.Caliburn")

	local air_burst = 
	{
		Ability = ability,
        EffectName = "particles/custom/saber_alter/saber_alter_x_burst_air.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = range - width + 100,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}	

	caster.air_burst = ProjectileManager:CreateLinearProjectile(air_burst)
end

function OnAirBurstHit(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() then return end

	local ability = keys.ability 

	local based_damage = ability:GetSpecialValueFor("based_damage")
	local bonus_int = ability:GetSpecialValueFor("bonus_int")
	local damage = based_damage + (bonus_int * caster:GetIntellect())

	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

	--[[
	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
		iMoveSpeed = 10000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = keys.Radius,
		Source = caster,
		fStartRadius = 10,
        fEndRadius = 50,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0.0,
	}

	local casterAngle = QAngle(0,120,0)
	EmitGlobalSound("Saber_Alter.Vortigern")
	Timers:CreateTimer(function() 
			vortigernBeam.vVelocity = RotatePosition(Vector(0,0,0), casterAngle, caster:GetForwardVector()) * 10000
			projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 6.66;
			vortigernCount = vortigernCount + 1; 
			if vortigernCount == 36 then vortigernCount = 0 return end -- finish spell
			
			return .01 -- tick every 0.01
		end
	)
end]]
	
function DSCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "saber_alter_derange") then
			caster.DUsed = true
			caster.DTime = GameRules:GetGameTime()
			if caster.DTimer ~= nil then 
				Timers:RemoveTimer(caster.DTimer)
				caster.DTimer = nil
			end
			caster.DTimer = Timers:CreateTimer(5.0, function()
				caster.DUsed = false
			end)

		else
				if caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
					if string.match(ability:GetAbilityName(), "saber_alter_unleashed_ferocity") and caster:FindAbilityByName("saber_alter_mana_burst_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("saber_alter_max_mana_burst_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_max_mana_burst_cooldown") then
						if caster.DUsed == true then 
							local newTime =  GameRules:GetGameTime()
							local duration = 5 - (newTime - caster.DTime)
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_window", {duration = duration})
						end
					end
				elseif not caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
					if string.match(ability:GetAbilityName(), "saber_alter_unleashed_ferocity") and caster:FindAbilityByName("saber_alter_mana_burst_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("saber_alter_max_mana_burst"):IsCooldownReady() and not caster:HasModifier("modifier_max_mana_burst_cooldown") then
						if caster.DUsed == true then 
							local newTime =  GameRules:GetGameTime()
							local duration = 5 - (newTime - caster.DTime)
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_window", {duration = duration})
						end
					end
				elseif caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
					if string.match(ability:GetAbilityName(), "saber_alter_unleashed_ferocity") and caster:FindAbilityByName("saber_alter_mana_burst_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("saber_alter_max_mana_burst_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_max_mana_burst_cooldown") then
						if caster.DUsed == true then 
							local newTime =  GameRules:GetGameTime()
							local duration = 5 - (newTime - caster.DTime)
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_window", {duration = duration})
						end
					end
				elseif not caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
					if string.match(ability:GetAbilityName(), "saber_alter_unleashed_ferocity") and caster:FindAbilityByName("saber_alter_mana_burst"):IsCooldownReady() and caster:FindAbilityByName("saber_alter_max_mana_burst"):IsCooldownReady() and not caster:HasModifier("modifier_max_mana_burst_cooldown") then
						if caster.DUsed == true then 
							local newTime =  GameRules:GetGameTime()
							local duration = 5 - (newTime - caster.DTime)
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_window", {duration = duration})
						end
					end
				end
		end
	end
end

function OnMMBWindow(keys)
	local caster = keys.caster 
	if caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_3", "saber_alter_max_mana_burst_upgrade", false, true)
	elseif not caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_1", "saber_alter_max_mana_burst", false, true)			
	elseif caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_2", "saber_alter_max_mana_burst_upgrade", false, true)			
	elseif not caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", false, true)
	end
end

function OnMMBWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_3", "saber_alter_max_mana_burst_upgrade", true, false)
	elseif not caster.IsManaBlastAcquired and caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_1", "saber_alter_max_mana_burst", true, false)			
	elseif caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst_upgrade_2", "saber_alter_max_mana_burst_upgrade", true, false)			
	elseif not caster.IsManaBlastAcquired and not caster.IsManaShroudImproved then
		caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", true, false)
	end
end

function OnMMBWindowDied(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_max_mana_burst_window")
end

function OnImproveManaShroundAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsManaShroudImproved) then

		if hero:HasModifier("modifier_max_mana_burst_window") then 
			hero:RemoveModifierByName("modifier_max_mana_burst_window")
		end

		hero.IsManaShroudImproved = true

		UpgradeAttribute(hero, 'saber_alter_mana_shroud', 'saber_alter_mana_shroud_upgrade', true)
		hero:RemoveModifierByName("modifier_mana_shroud")
		hero.DSkill = "saber_alter_mana_shroud_upgrade"

		if hero.IsManaBlastAcquired then 
			UpgradeAttribute(hero, 'saber_alter_mana_burst_upgrade_2', 'saber_alter_mana_burst_upgrade_3', true)	
			UpgradeAttribute(hero, 'saber_alter_derange_burst', 'saber_alter_derange_upgrade', true)	
			hero.QSkill = "saber_alter_derange_upgrade"
			hero.WSkill = "saber_alter_mana_burst_upgrade_3"
		else
			UpgradeAttribute(hero, 'saber_alter_mana_burst', 'saber_alter_mana_burst_upgrade_1', true)
			UpgradeAttribute(hero, 'saber_alter_derange', 'saber_alter_derange_shroud', true)
			hero.QSkill = "saber_alter_derange_shroud"
			hero.WSkill = "saber_alter_mana_burst_upgrade_1"	
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnManaBlastAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsManaBlastAcquired) then

		if hero:HasModifier("modifier_max_mana_burst_window") then 
			hero:RemoveModifierByName("modifier_max_mana_burst_window")
		end

		hero.IsManaBlastAcquired = true
		hero.ManaBlastCount = 0

		UpgradeAttribute(hero, 'saber_alter_max_mana_burst', 'saber_alter_max_mana_burst_upgrade', false)	
		

		if hero.IsManaShroudImproved then 
			UpgradeAttribute(hero, 'saber_alter_mana_burst_upgrade_1', 'saber_alter_mana_burst_upgrade_3', true)	
			UpgradeAttribute(hero, 'saber_alter_derange_shroud', 'saber_alter_derange_upgrade', true)
			hero.QSkill = "saber_alter_derange_upgrade"
			hero.WSkill = "saber_alter_mana_burst_upgrade_3"
		else
			UpgradeAttribute(hero, 'saber_alter_mana_burst', 'saber_alter_mana_burst_upgrade_2', true)	
			UpgradeAttribute(hero, 'saber_alter_derange', 'saber_alter_derange_burst', true)	
			hero.QSkill = "saber_alter_derange_burst"
			hero.WSkill = "saber_alter_mana_burst_upgrade_2"
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveFerocityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsFerocityImproved) then

		hero.IsFerocityImproved = true
		UpgradeAttribute(hero, 'saber_alter_unleashed_ferocity', 'saber_alter_unleashed_ferocity_upgrade', true)
		UpgradeAttribute(hero, 'saber_alter_vortigern', 'saber_alter_vortigern_upgrade', true)

		--hero:SetModifierStackCount("modifier_vortigern_ferocity_base", hero, 3)
		--hero:SetModifierStackCount("modifier_vortigern_ferocity_show", hero, 3)

		hero.ESkill = "saber_alter_vortigern_upgrade"
		hero.FSkill = "saber_alter_unleashed_ferocity_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDarklightAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDarklightAcquired) then

		hero.IsDarklightAcquired = true

		hero:FindAbilityByName("saber_alter_darklight_passive"):SetLevel(1)

		UpgradeAttribute(hero, 'saber_alter_excalibur', 'saber_alter_excalibur_upgrade', true)

		hero.ESkill = "saber_alter_excalibur_upgrade"
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAirBurstAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAirBurstAcquired) then

		hero.IsAirBurstAcquired = true
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
