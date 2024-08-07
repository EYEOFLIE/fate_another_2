
function OnFairyDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage_threshold = ability:GetSpecialValueFor("damage_threshold")
	local health_regain = ability:GetSpecialValueFor("health_regain") / 100  * caster:GetMaxHealth()
	local duration = ability:GetSpecialValueFor("duration")
	local currentHealth = caster:GetHealth()

	if currentHealth < damage_threshold and ability:IsCooldownReady() and IsRevivePossible(caster) and not caster:HasModifier("modifier_gawain_blessing_cooldown") then
		
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel())) 

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_blessing_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

		if IsReviveSeal(caster) then return end

		HardCleanse(caster)
		RemoveDebuffsForRevival(caster)
		caster:SetHealth(health_regain)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_revive_regen", {})
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
		Timers:CreateTimer( duration, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
	end
end

function OnDayTime(caster)
	if caster.IsNumeralSaintAcquired then 
		if caster:GetModifierStackCount("modifier_gawain_saint_bonus", caster) == 0 then
			caster:EmitSound("Gawain_Trigger2")
		end
		local ability = caster:GetAbilityByIndex(3)
		local sun_stack = ability:GetSpecialValueFor("sun_stack")
		caster:SetModifierStackCount("modifier_gawain_saint_bonus", caster, sun_stack)
		caster:CalculateStatBonus(true)
	else
		local ability = caster:FindAbilityByName("gawain_numeral_saint")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_saint_bonus", {})
		caster:CalculateStatBonus(true)
	end
end

function OnNightTime(caster)
	if caster.IsNumeralSaintAcquired then 
		caster:SetModifierStackCount("modifier_gawain_saint_bonus", caster, 0)
		caster:CalculateStatBonus(true)
	else
		caster:RemoveModifierByName("modifier_gawain_saint_bonus")
		caster:CalculateStatBonus(true)
	end
end

function OnDevoteUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability:GetAbilityName() == "gawain_blade_of_the_devoted" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gawain_blade_of_the_devoted_light"):GetLevel() then
			caster:FindAbilityByName("gawain_blade_of_the_devoted_light"):SetLevel(ability:GetLevel())
		end
	elseif ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" then 
		if ability:GetLevel() ~= caster:FindAbilityByName("gawain_blade_of_the_devoted"):GetLevel() then
			caster:FindAbilityByName("gawain_blade_of_the_devoted"):SetLevel(ability:GetLevel())
		end
	end
end

function OnDevoteCD(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability:GetAbilityName() == "gawain_blade_of_the_devoted" then 
		caster:FindAbilityByName("gawain_blade_of_the_devoted_light"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	elseif ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" then 
		caster:FindAbilityByName("gawain_blade_of_the_devoted"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end
end

function OnDevoteStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_blade_of_the_devoted", {})

	caster:EmitSound("Hero_EmberSpirit.FireRemnant.Cast")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( lightFx1, 0, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
	end)

	GawainCheckCombo(caster, ability)
end

function OnDevoteHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")

	target:EmitSound("Hero_Invoker.ColdSnap")
	caster:EmitSound("Gawain_Attack" .. math.random(1,3))

	if caster:HasModifier("modifier_light_of_galatine") then 
		local stun = ability:GetSpecialValueFor("stun")
		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
		end
	end

	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	local flameFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( flameFx1, 0, target:GetAbsOrigin())

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	caster:RemoveModifierByName("modifier_blade_of_the_devoted")

	
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
		ParticleManager:DestroyParticle( flameFx1, false )
		ParticleManager:ReleaseParticleIndex( flameFx1 )
	end)
end

function OnLightOfGalatineStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_light_of_galatine", {})
	if caster.IsKnightOfTheSunAcquired then 
		local sun_duration = ability:GetSpecialValueFor("sun_duration")
		GenerateArtificialSun(caster, ability, sun_duration)
	end

	GawainCheckCombo(caster, ability)
end

function OnLightOfGalatineCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities("gawain_blade_of_the_devoted_light", "gawain_blade_of_the_devoted", true, false)
	if not caster:HasModifier("modifier_galatine_detonate") then
		if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_excalibur_galatine_upgrade_3", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_excalibur_galatine_upgrade_2", true, false)
		elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_excalibur_galatine_upgrade_1", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light", "gawain_excalibur_galatine", true, false)
		end
	end
end

function OnLightOfGalatineDestroy(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_gawain_combo_excalibur_window") then 
		caster:RemoveModifierByName("modifier_gawain_combo_excalibur_window")
	end
	caster:SwapAbilities("gawain_blade_of_the_devoted_light", "gawain_blade_of_the_devoted", false, true)
	if not caster:HasModifier("modifier_galatine_detonate") then
		if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_excalibur_galatine_upgrade_3", false, true)
		elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_excalibur_galatine_upgrade_2", false, true)
		elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_excalibur_galatine_upgrade_1", false, true)
		elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light", "gawain_excalibur_galatine", false, true)
		end
	end
end

function OnLightOfGalatineAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if IsValidEntity(target) and target:IsAlive() then
		local current_stack = target:GetModifierStackCount("modifier_light_of_galatine_burn", caster) or 0
		ability:ApplyDataDrivenModifier(caster, target, "modifier_light_of_galatine_burn", {})
		target:SetModifierStackCount("modifier_light_of_galatine_burn", caster, current_stack + 1)
		
		if not IsImmuneToSlow(target) then 	
			ability:ApplyDataDrivenModifier(caster, target, "modifier_light_of_galatine_slow", {})
		end
	end
end

function OnLightOfGalatineBurn(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local burn_dps = ability:GetSpecialValueFor("burn_dps")
	local burn_stack_dps = ability:GetSpecialValueFor("burn_stack_dps")
	local stack = target:GetModifierStackCount("modifier_light_of_galatine_burn", caster) - 1
	DoDamage(caster, target, (burn_dps + (burn_stack_dps * stack)) * 0.5, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnSunOfGalatineStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sun_of_galatine_channel_aura", {})
	caster.sun_galatine_channel = 0
	if caster.IsKnightOfTheSunAcquired then 
		duration = ability:GetSpecialValueFor("sun_duration")
	end
	if caster.IsBeltOfBertilakAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_belt_of_bertilak", {})
	end
	GenerateArtificialSun(caster, ability, duration)
end

function OnSunOfGalatineThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local channel_dps = ability:GetSpecialValueFor("channel_dps")
	ProjectileManager:ProjectileDodge(caster)
	caster.sun_galatine_channel = caster.sun_galatine_channel + 0.2
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do   
    	if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() and not IsImmuneToCC(v) then 
        	v:AddNewModifier(caster, nil, "modifier_stunned", {Duration = 0.1})
        end         
        DoDamage(caster, v, channel_dps * 0.2, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end 
end

function OnSunOfGalatineCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	caster.sun_galatine_ring = ParticleManager:CreateParticle("particles/custom/gawain/manjinx_gawain_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(caster.sun_galatine_ring, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(caster.sun_galatine_ring, 3, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(caster.sun_galatine_ring, 4, Vector(radius / 215,0,0))
end

function OnSunOfGalatineDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability
	ParticleManager:DestroyParticle( caster.sun_galatine_ring, false )
	ParticleManager:ReleaseParticleIndex( caster.sun_galatine_ring )
	if caster:IsChanneling() then 
		ability:EndChannel(true)
	end
end

function OnSunOfGalatineInterrupt(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local channel_dps = ability:GetSpecialValueFor("channel_dps")
	local burst_damage = ability:GetSpecialValueFor("burst_damage")
	local stun = ability:GetSpecialValueFor("stun")
	local duration = ability:GetSpecialValueFor("duration")

	local damage = burst_damage

	local explosionFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_supernova_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(explosionFx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 1, Vector(3,0,0))

    if caster:HasModifier("modifier_sun_of_galatine_channel_aura") then 
    	caster:RemoveModifierByName("modifier_sun_of_galatine_channel_aura")
    end

    if not caster.IsKnightOfTheSunAcquired then
    	if IsValidEntity(caster.ArtificialSun) then 
    		caster.ArtificialSun:RemoveSelf()
    	end
    end

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do 
    	if IsValidEntity(v) and not v:IsNull() then
    		v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun * (caster.sun_galatine_channel / duration)})          
        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    	end 
    end

    caster:EmitSound("Gawain_Sun_Explode")
end

function OnSunOfGalatineSlowCheck(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if not IsImmuneToSlow(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_sun_of_galatine_slow", {})
	end
end

function OnSunOfGalatineSlowRemove(keys)
	local target = keys.target 
	if target:HasModifier("modifier_sun_of_galatine_slow") then 
		target:RemoveModifierByName("modifier_sun_of_galatine_slow")
	end
end

function OnGalatineUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetLevel(ability:GetLevel())
			end
		end
	elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):SetLevel(ability:GetLevel())
			end
		end
	elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):SetLevel(ability:GetLevel())
			end
		end
	elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("gawain_excalibur_galatine_light"):GetLevel() then
				caster:FindAbilityByName("gawain_excalibur_galatine_light"):SetLevel(ability:GetLevel())
			end
		end
	end
end

function OnGalatineCD(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_3" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_3" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_2" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_2" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light_upgrade_1" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine_upgrade_1" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		if ability:GetAbilityName() == "gawain_excalibur_galatine_light" then 
			caster:FindAbilityByName("gawain_excalibur_galatine"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "gawain_excalibur_galatine" then 
			caster:FindAbilityByName("gawain_excalibur_galatine_light"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function OnGalatineStart(keys)
	-- Declaring a bunch of stuffs
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = ability:GetCursorPosition()
	local dist = ability:GetSpecialValueFor("max_range")
	local orbLoc = caster:GetAbsOrigin()
	local diff = caster:GetForwardVector()
	local timeElapsed = 0
	local flyingDist = 0
	local orbVelocity = ability:GetSpecialValueFor("speed")
	local fireTrailDuration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local InFirstLoop = true
	caster.IsGalatineActive = true

	-- Stops Gawain from doing anything else essentially and play the Galatine animation
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_vfx", {Duration = cast_delay - 0.25})	
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.1)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_anim",{Duration = cast_delay + 0.2})
	-- Need the dank voice. 
	EmitGlobalSound("Gawain_Galatine_1")

	if caster.IsBeltOfBertilakAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_belt_of_bertilak",{--[[Duration = cast_delay + 0.2]]})
		local bonus_str = ability:GetSpecialValueFor("bonus_str") * caster:GetStrength()
		damage = damage + bonus_str
	end

	-- Make dem particles and the Galatine ball
	local castFx1 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx1, 0, caster:GetAbsOrigin())

	GenerateArtificialSun(caster, ability, cast_delay)

	local castFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx2, 0, caster:GetAbsOrigin())

	local galatineDummy = CreateUnitByName("gawain_galatine_dummy", Vector(20000,20000,0), true, nil, nil, caster:GetTeamNumber())
	local flameFx1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_excalibur_galatine_orb.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
	ParticleManager:SetParticleControl( flameFx1, 0, galatineDummy:GetAbsOrigin())



	galatineDummy:SetDayTimeVisionRange(300)
	galatineDummy:SetNightTimeVisionRange(300)
	galatineDummy:AddNewModifier(caster, nil, "modifier_kill", {duration = cast_delay + 3})

	Timers:CreateTimer(cast_delay, function()
		ParticleManager:DestroyParticle( castFx1, false )
		ParticleManager:ReleaseParticleIndex( castFx1 )
	end)

	--[[if caster.IsSoVAcquired then
		damage = damage + 250
		fireTrailDuration = fireTrailDuration + 3
	end]]

	-- Checks if Gawain is still alive as well as whether or not it overshot where the player intended it to flew.. or it flew for too long
	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() and timeElapsed < dist / orbVelocity and caster.IsGalatineActive and flyingDist < dist then
			-- Need to initialize the variables and put in Gawain's detonate Galatine ability
			if InFirstLoop then
				casterLoc = caster:GetAbsOrigin()
				orbLoc = caster:GetAbsOrigin()
				diff = caster:GetForwardVector()
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_galatine_detonate",{})
				InFirstLoop = false
				EmitGlobalSound("Gawain_Galatine_2")
				if caster.IsKnightOfTheSunAcquired then 
					ability:ApplyDataDrivenModifier(caster, galatineDummy, "modifier_gawain_heat_radiance", {Duration = dist / orbVelocity})
				end
			end
			-- Move the ball, reduce the remaining flight distance, reduce the remaining timer and increase the AoE gradually
			orbLoc = orbLoc + diff * orbVelocity * 0.05
			galatineDummy:SetAbsOrigin(orbLoc)
			flyingDist = (casterLoc - orbLoc):Length2D()
			timeElapsed = timeElapsed + 0.05

			-- Get all nearby enemies and give them Galatine burn debuff if they don't have it
			local burnTargets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)			
			for i,j in pairs(burnTargets) do
				if IsValidEntity(j) and not j:IsNull() then
					ability:ApplyDataDrivenModifier(caster, j, "modifier_excalibur_galatine_burn", {}) 				
				end
			end

			--Hacky way to leave a fire trail 
			if (math.ceil(flyingDist) % 300 < 5) then
				LeaveFireTrail(keys, GetGroundPosition(galatineDummy:GetAbsOrigin(), nil), fireTrailDuration)
			end
			
			return 0.05
		else 
			LeaveFireTrail(keys, GetGroundPosition(galatineDummy:GetAbsOrigin(), nil), fireTrailDuration)

			-- Give Gawain back his Galatine
			GiveGawainGalatine(caster)

			-- Explosion on enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

			for k,v in pairs(targets) do	
				if IsValidEntity(v) and not v:IsNull() then 
					ability:ApplyDataDrivenModifier(caster, v, "modifier_excalibur_galatine_burn", {})
					DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)	
				end			
			end

			local explodeFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_ABSORIGIN, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx1, 0, galatineDummy:GetAbsOrigin())			

			local explodeFx2 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_galetine_explosion_parent.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx2, 0, galatineDummy:GetAbsOrigin())

			galatineDummy:EmitSound("Ability.LightStrikeArray")

			galatineDummy:ForceKill(true) 
			
			ParticleManager:DestroyParticle( flameFx1, false )
			ParticleManager:ReleaseParticleIndex( flameFx1 )

			Timers:CreateTimer( 2.0, function()
				
				ParticleManager:DestroyParticle( explodeFx1, false )
				ParticleManager:ReleaseParticleIndex( explodeFx1 )
				ParticleManager:DestroyParticle( explodeFx2, false )
				ParticleManager:ReleaseParticleIndex( explodeFx2 )
			end)
			return
		end
	end)
end

function OnGalatineDetonateCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "gawain_excalibur_galatine_detonate", false, true)
end

function OnGalatineDetonateDestroy(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_light_of_galatine") then 
		if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_excalibur_galatine_detonate", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_excalibur_galatine_detonate", true, false)
		elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_excalibur_galatine_detonate", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_light", "gawain_excalibur_galatine_detonate", true, false)
		end
	else
		if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_upgrade_3", "gawain_excalibur_galatine_detonate", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_upgrade_2", "gawain_excalibur_galatine_detonate", true, false)
		elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine_upgrade_1", "gawain_excalibur_galatine_detonate", true, false)
		elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, false)
		end
	end
end

function OnGalatineDetonateDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_galatine_detonate")
end

function OnGalatineDetonate(keys)
	local caster = keys.caster
	caster.IsGalatineActive = false
	GiveGawainGalatine(caster)

end

function GiveGawainGalatine(caster)
	caster.IsGalatineActive = false
	caster:RemoveModifierByName("modifier_galatine_detonate")
	
end

--Copied from Jeanne's kek
function LeaveFireTrail(keys, location, duration)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("dot_damage")
	local radius = ability:GetSpecialValueFor("radius")

	local fireFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_galetine_flametrail_parent.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fireFx, 0, location)
	ParticleManager:SetParticleControl(fireFx, 1, Vector(duration,0,0))

	local counter = 0
	local period = 0.5
	Timers:CreateTimer(function()
		counter = counter + period
		if counter > duration then return end
		local targets = FindUnitsInRadius(caster:GetTeam(), location, nil, radius - 30, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_excalibur_galatine_burn", {})
			end
		end
		return period
	end)
end

function OnBurnDamageTick(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("dot_damage") * 0.25

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnGalatineLightStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = ability:GetCursorPosition()
	local dist = ability:GetSpecialValueFor("max_range")
	local orbLoc = caster:GetAbsOrigin()
	local diff = caster:GetForwardVector()
	local orbVelocity = ability:GetSpecialValueFor("speed")
	local fireTrailDuration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_vfx", {Duration = cast_delay - 0.25})	
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + dist / orbVelocity)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_anim",{Duration = cast_delay + 0.2})
	-- Need the dank voice. 
	EmitGlobalSound("Gawain_Galatine_1")

	if caster.IsBeltOfBertilakAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_belt_of_bertilak",{--[[Duration = cast_delay + dist / orbVelocity]]})
	end

	local duration = cast_delay + dist / orbVelocity

	if caster.IsKnightOfTheSunAcquired then 
		duration = ability:GetSpecialValueFor("sun_duration")
	end

	GenerateArtificialSun(caster, ability, duration)

	-- Make dem particles and the Galatine ball
	local castFx1 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx1, 0, caster:GetAbsOrigin())

	local castFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx2, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(cast_delay, function()
		ParticleManager:DestroyParticle( castFx1, false )
		ParticleManager:ReleaseParticleIndex( castFx1 )
	end)


	local galatine = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = orbVelocity,
        vSpawnOrigin = casterLoc,
        fDistance = dist - radius +100,
        fStartRadius = radius,
        fEndRadius = radius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * orbVelocity,
		bProvidesVision = true,
		iVisionRadius = radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then 
			EmitGlobalSound("Gawain_Galatine_2")
			local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummy:SetForwardVector(caster:GetForwardVector())
			local flameFx1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_excalibur.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControlEnt( flameFx1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + Vector(0,0,50), true )

			ParticleManager:SetParticleControl(flameFx1, 10, Vector(radius,0,0))
			local projectile = ProjectileManager:CreateLinearProjectile(galatine)
			Timers:CreateTimer( function()
				if IsValidEntity(dummy) and caster:IsAlive() then
					orbLoc = orbLoc + diff * orbVelocity * 0.05
					orbLoc.z = caster:GetAbsOrigin().z + 100
					dummy:SetAbsOrigin(orbLoc)
					ParticleManager:SetParticleControl(flameFx1, 1, dummy:GetAbsOrigin())
					return 0.05
				else
					return nil
				end
			end)
			Timers:CreateTimer(dist / orbVelocity + 0.05, function()
				if IsValidEntity(dummy) then
					dummy:RemoveSelf()
				end
				ParticleManager:DestroyParticle( flameFx1, false )
				ParticleManager:ReleaseParticleIndex( flameFx1 )
			end)
		end
	end)
end

function OnGalatineLightHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	if caster.IsBeltOfBertilakAcquired then 
		local bonus_str = ability:GetSpecialValueFor("bonus_str") * caster:GetStrength()
		damage = damage + bonus_str
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_excalibur_galatine_burn", {})
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
end

function GenerateArtificialSun(caster, ability, duration)
	local radius = 200
	if caster.ArtificialSun == nil then 
		caster.ArtificialSun = {}
	end 
	if not IsValidEntity(caster.ArtificialSun) then 
		caster.ArtificialSun = CreateUnitByName("gawain_artificial_sun", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
	end

	if caster.IsKnightOfTheSunAcquired then
		radius = ability:GetSpecialValueFor("sun_radius")
		local reveal = ability:GetSpecialValueFor("sun_reveal")
		caster.ArtificialSun:AddNewModifier(caster, ability, "modifier_item_ward_true_sight", {true_sight_range = reveal}) 			
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_heat_radiance", {Duration = duration})
	end

	caster.ArtificialSun:SetAbsOrigin(caster.ArtificialSun:GetAbsOrigin() + Vector(0,0, 500))
	caster.ArtificialSun:SetDayTimeVisionRange(radius)
	caster.ArtificialSun:SetNightTimeVisionRange(radius)
	
	--if caster.IsNumeralSaintAcquired then 
		OnDayTime(caster)
	--end
	ability:ApplyDataDrivenModifier(caster, caster.ArtificialSun, "modifier_artificial_sun", {Duration = duration})
	Timers:CreateTimer(duration, function()
		if --[[not caster.IsKnightOfTheSunAcquired and]] not IsValidEntity(caster.ArtificialSun) then
			--if caster.IsNumeralSaintAcquired then 
				OnNightTime(caster)
			--end
		end
	end)
end

function OnSunPassiveThink(keys)
	local target = keys.target
	local caster = keys.caster
	target:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,500))
end

function OnSunDestroy(keys)
	local target = keys.target 
	local caster = keys.caster 
	if IsValidEntity(target) then
		target:RemoveSelf()
	end
	if caster.IsNumeralSaintAcquired then 
		OnNightTime(caster)
	end
end

function StopSound(keys)
	local caster = keys.caster 
	caster:StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function OnHeatBurn(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local heat_lvl = ability:GetSpecialValueFor("heat_lvl")
	local sun_galatine = caster:FindAbilityByName("gawain_sun_of_galatine_upgrade_2")
	local excalibur_galatine = caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_2")
	if sun_galatine == nil or excalibur_galatine == nil then 
		sun_galatine = caster:FindAbilityByName("gawain_sun_of_galatine_upgrade_3")
		excalibur_galatine = caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3")		
	end

	local heat_radius = ability:GetSpecialValueFor("heat_radius")
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, heat_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() then 
			DoDamage(caster, v, heat_lvl * (sun_galatine:GetLevel() + excalibur_galatine:GetLevel()) * 0.25, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			if ability:GetAbilityName() == "gawain_combo_excalibur_galatine_upgrade_2" or ability:GetAbilityName() == "gawain_combo_excalibur_galatine_upgrade_3" then 
				local dot_damage = ability:GetSpecialValueFor("dot_damage")
				DoDamage(caster, v, dot_damage * 0.25, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	end
end

function GawainCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		--[[if caster:HasModifier("modifier_gawain_saint_bonus") and caster:GetModifierStackCount("modifier_gawain_saint_bonus", caster) == 3 then 
			local num_saint = caster:FindAbilityByName("gawain_numeral_saint")
			if math.ceil(caster:GetStrength() - (num_saint:GetSpecialValueFor("bonus_stat") * 2)) < 25 and math.ceil(caster:GetAgility() - (num_saint:GetSpecialValueFor("bonus_stat") * 2)) < 25 and math.ceil(caster:GetIntellect() - (num_saint:GetSpecialValueFor("bonus_stat") * 2)) < 25 then
				return 
			end
		end]]
		if string.match(ability:GetAbilityName(), "gawain_light_of_galatine") then
			caster.WUsed = true
			caster.WTime = GameRules:GetGameTime()
			if caster.WTimer ~= nil then 
				Timers:RemoveTimer(caster.WTimer)
				caster.WTimer = nil
			end
			caster.WTimer = Timers:CreateTimer(3.0, function()
				caster.WUsed = false
			end)
		else
			if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
				if ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" and caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_3"):IsCooldownReady() and not caster:HasModifier("modifier_combo_galatine_cooldown") then
					if caster.WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 3 - (newTime - caster.WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_combo_excalibur_window", {duration = duration})
					end
				end
			elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
				if ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" and caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_2"):IsCooldownReady() and not caster:HasModifier("modifier_combo_galatine_cooldown") then
					if caster.WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 3 - (newTime - caster.WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_combo_excalibur_window", {duration = duration})
					end
				end
			elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
				if ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" and caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_1"):IsCooldownReady() and not caster:HasModifier("modifier_combo_galatine_cooldown") then
					if caster.WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 3 - (newTime - caster.WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_combo_excalibur_window", {duration = duration})
					end
				end
			elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
				if ability:GetAbilityName() == "gawain_blade_of_the_devoted_light" and caster:FindAbilityByName("gawain_excalibur_galatine_light"):IsCooldownReady() and caster:FindAbilityByName("gawain_combo_excalibur_galatine"):IsCooldownReady() and not caster:HasModifier("modifier_combo_galatine_cooldown") then
					if caster.WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 3 - (newTime - caster.WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_combo_excalibur_window", {duration = duration})
					end
				end
			end
		end
	end
end

function OnComboExcaliburWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_combo_excalibur_galatine_upgrade_3", false, true)
	elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_combo_excalibur_galatine_upgrade_2", false, true)			
	elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_combo_excalibur_galatine_upgrade_1", false, true)			
	elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light", "gawain_combo_excalibur_galatine", false, true)
	end
end

function OnComboExcaliburWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_combo_excalibur_galatine_upgrade_3", true, false)
	elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_combo_excalibur_galatine_upgrade_2", true, false)			
	elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_combo_excalibur_galatine_upgrade_1", true, false)			
	elseif not caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then
		caster:SwapAbilities("gawain_excalibur_galatine_light", "gawain_combo_excalibur_galatine", true, false)
	end
end

function OnComboExcaliburWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_gawain_combo_excalibur_window")
end

function OnComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local low_damage_radius = ability:GetSpecialValueFor("low_damage_radius")
	local origin = caster:GetAbsOrigin() 
	local forwardVec = caster:GetForwardVector() 
	local speed = 99999 
	local angle = 360
	local increment_factor = 30

	local masterCombo = caster.MasterUnit2:FindAbilityByName("gawain_combo_excalibur_galatine")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	local galatine = caster:FindAbilityByName("gawain_excalibur_galatine")
	local galatine_light = caster:FindAbilityByName("gawain_excalibur_galatine_light")
	
	if galatine == nil or galatine_light == nil then 
		if caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			galatine = caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_3")
			galatine_light = caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3")
		elseif not caster.IsBeltOfBertilakAcquired and caster.IsKnightOfTheSunAcquired then 
			galatine = caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_2")
			galatine_light = caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2")
		elseif caster.IsBeltOfBertilakAcquired and not caster.IsKnightOfTheSunAcquired then 
			galatine = caster:FindAbilityByName("gawain_excalibur_galatine_upgrade_1")
			galatine_light = caster:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1")
		end
	end
	galatine:StartCooldown(galatine:GetCooldown(galatine:GetLevel()))
	galatine_light:StartCooldown(galatine_light:GetCooldown(galatine_light:GetLevel()))

	caster:RemoveModifierByName("modifier_gawain_combo_excalibur_window")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_galatine_cooldown", {Duration = ability:GetCooldown(1)})

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.72)

	if caster.IsBeltOfBertilakAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_belt_of_bertilak",{--[[Duration = cast_delay + 0.72]]})
	end

	StartAnimation(caster, {duration = 2, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
	EmitGlobalSound("gawain_galatine_combo_cast")

	Timers:CreateTimer(2, function()
		if caster:IsAlive() then 
			StartAnimation(caster, {duration = cast_delay - 2, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.4})
		end
	end)

	GenerateArtificialSun(caster, ability, cast_delay)

	local CircleFx = ParticleManager:CreateParticleForTeam("particles/custom/gawain/gawain_combo_circle1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(CircleFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(CircleFx, 1, Vector(low_damage_radius,0,0))
	ParticleManager:SetParticleAlwaysSimulate(CircleFx)

	local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(1000, 1000, 1000))
	Timers:CreateTimer(3.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
					
	Timers:CreateTimer(cast_delay, function()
		Timers:CreateTimer( 0.6, function()
			ParticleManager:DestroyParticle( CircleFx, true )
			ParticleManager:ReleaseParticleIndex( CircleFx )
		end)
		if caster:IsAlive() then 
			if caster:HasModifier('modifier_alternate_02') then 
				EmitGlobalSound("Gawain-Summer-Combo-Activate")
			else
				EmitGlobalSound("gawain_galatine_combo_activate")
			end
			StartAnimation(caster, {duration = 0.72, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=1.39})
			local GalatineBeam =
			{
				Ability = ability,
				EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
				iMoveSpeed = speed,
				vSpawnOrigin = caster:GetAbsOrigin(),
				fDistance = low_damage_radius,
				Source = caster,
				fStartRadius = 75,
		        fEndRadius = low_damage_radius * 3.14 * increment_factor / angle,
				bHasFrontialCone = true,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_ALL,
				fExpireTime = GameRules:GetGameTime() + 0.4,
				bDeleteOnHit = false,
				vVelocity = 0,
			}

			local GalatineCount = 0 
			local newAngle = caster:GetAnglesAsVector().y - 90
			Timers:CreateTimer( function()
				if GalatineCount >= angle / increment_factor then return end 

				local newLoc = GetRotationPoint(caster:GetAbsOrigin(),low_damage_radius,newAngle)
				local new_forward = (newLoc - caster:GetAbsOrigin()):Normalized()

				GalatineBeam.vVelocity = new_forward * speed
				GalatineBeam.fExpireTime = GameRules:GetGameTime() + 0.3
				GalatineBeam.vSpawnOrigin = caster:GetAbsOrigin()

				local projectile = ProjectileManager:CreateLinearProjectile( GalatineBeam )
				GalatineCount = GalatineCount + 1

				newAngle = newAngle - increment_factor

				return 0.06
			end)

			local splashFx = ParticleManager:CreateParticle("particles/custom/screen_yellow_splash_gawain.vpcf", PATTACH_EYES_FOLLOW, caster)
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( splashFx, false )
				ParticleManager:ReleaseParticleIndex( splashFx )
			end)

			
			local swingFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo_new_slash.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(swingFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(swingFx, 5, Vector(low_damage_radius / 4.3,0,0))
			ParticleManager:SetParticleFoWProperties(swingFx, 0, 0, low_damage_radius)

			local swordFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo_new_slash2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(swordFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(swordFx, 1, Vector(low_damage_radius,0,0))
			ParticleManager:SetParticleControl(swordFx, 2, Vector(0,0,caster:GetAnglesAsVector().y - 90))
			Timers:CreateTimer( 0.72, function()
				caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
				ParticleManager:DestroyParticle( swingFx, true )
				ParticleManager:ReleaseParticleIndex( swingFx )
				ParticleManager:DestroyParticle( swordFx, true )
				ParticleManager:ReleaseParticleIndex( swordFx )
			end)
		end
	end)
end

function OnComboHit(keys)
	if keys.target == nil then return end 

	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	local low_damage_radius = ability:GetSpecialValueFor("low_damage_radius")
	local medium_damage_radius = ability:GetSpecialValueFor("medium_damage_radius")
	local high_damage_radius = ability:GetSpecialValueFor("high_damage_radius")
	local low_damage = ability:GetSpecialValueFor("low_damage")
	local medium_damage = ability:GetSpecialValueFor("medium_damage")
	local high_damage = ability:GetSpecialValueFor("high_damage")

	SpawnAttachedVisionDummy(target, caster, 1, 0.75, false)

	local damage = 0

	local dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

	if dist <= high_damage_radius then 
		damage = high_damage
	elseif dist > high_damage_radius and dist <= medium_damage_radius then 
		damage = medium_damage
	elseif dist > medium_damage_radius and dist <= low_damage_radius then 
		damage = low_damage
	end
	if target.IsComboGalatineHit ~= true and damage ~= 0 then
		target.IsComboGalatineHit = true
		Timers:CreateTimer(0.72, function() target.IsComboGalatineHit = false return end)

		if caster.IsBeltOfBertilakAcquired  then
			local stun = ability:GetSpecialValueFor("stun")
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
		end

		ability:ApplyDataDrivenModifier(caster, target, "modifier_excalibur_galatine_burn", {})
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		
	end
end

function OnFairyAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsFairyAcquired) then

		hero.IsFairyAcquired = true
		
		hero:FindAbilityByName("gawain_blessing_of_fairy"):SetLevel(1)
		hero:SwapAbilities("gawain_blessing_of_fairy", "fate_empty8", true, false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnNoSAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsNumeralSaintAcquired) then

		hero.IsNumeralSaintAcquired = true
		
		UpgradeAttribute(hero, 'gawain_numeral_saint', 'gawain_numeral_saint_upgrade', true)
		hero:FindAbilityByName("gawain_numeral_saint_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_gawain_saint_bonus", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBeltAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBeltOfBertilakAcquired) then
	
		if hero:HasModifier("modifier_gawain_combo_excalibur_window") then 
			hero:RemoveModifierByName("modifier_gawain_combo_excalibur_window")
		end

		hero.IsBeltOfBertilakAcquired = true
		
		if hero.IsKnightOfTheSunAcquired then 
			hero:AddAbility("gawain_sun_of_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_2"):GetLevel())
			hero:SwapAbilities("gawain_sun_of_galatine_upgrade_3", "gawain_sun_of_galatine_upgrade_2", true, false) 
			if not hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_2"):GetCooldownTimeRemaining())
			end

			hero:RemoveAbility("gawain_sun_of_galatine_upgrade_2")

			hero:AddAbility("gawain_excalibur_galatine_upgrade_3")
			hero:AddAbility("gawain_excalibur_galatine_light_upgrade_3")
			hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):GetLevel())
			hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):GetLevel())
			
			if not hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_galatine_detonate") then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetHidden(true)
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetHidden(true)
			else
				if hero:HasModifier("modifier_light_of_galatine") then
					hero:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_excalibur_galatine_light_upgrade_2", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetHidden(true)
				else
					hero:SwapAbilities("gawain_excalibur_galatine_upgrade_3", "gawain_excalibur_galatine_upgrade_2", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetHidden(true)
				end
			end
			hero:RemoveAbility("gawain_excalibur_galatine_light_upgrade_2")
			hero:RemoveAbility("gawain_excalibur_galatine_upgrade_2")

			hero:AddAbility("gawain_combo_excalibur_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_3"):SetLevel(1)
			if not hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_2"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_combo_excalibur_galatine_upgrade_2")
		else
			hero:AddAbility("gawain_sun_of_galatine_upgrade_1")
			hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_1"):SetLevel(hero:FindAbilityByName("gawain_sun_of_galatine"):GetLevel())
			hero:SwapAbilities("gawain_sun_of_galatine_upgrade_1", "gawain_sun_of_galatine", true, false) 
			if not hero:FindAbilityByName("gawain_sun_of_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_1"):StartCooldown(hero:FindAbilityByName("gawain_sun_of_galatine"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_sun_of_galatine")

			hero:AddAbility("gawain_excalibur_galatine_upgrade_1")
			hero:AddAbility("gawain_excalibur_galatine_light_upgrade_1")
			hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine"):GetLevel())
			hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine"):GetLevel())
			
			if not hero:FindAbilityByName("gawain_excalibur_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_galatine_detonate") then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):SetHidden(true)
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):SetHidden(true)
			else
				if hero:HasModifier("modifier_light_of_galatine") then
					hero:SwapAbilities("gawain_excalibur_galatine_light_upgrade_1", "gawain_excalibur_galatine_light", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):SetHidden(true)
				else
					hero:SwapAbilities("gawain_excalibur_galatine_upgrade_1", "gawain_excalibur_galatine", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_1"):SetHidden(true)
				end
			end
			hero:RemoveAbility("gawain_excalibur_galatine_light")
			hero:RemoveAbility("gawain_excalibur_galatine")

			hero:AddAbility("gawain_combo_excalibur_galatine_upgrade_1")
			hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_1"):SetLevel(1)
			if not hero:FindAbilityByName("gawain_combo_excalibur_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_1"):StartCooldown(hero:FindAbilityByName("gawain_combo_excalibur_galatine"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_combo_excalibur_galatine")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnNightlessAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsNightLessCharismaAcquired) then

		hero.IsNightLessCharismaAcquired = true
		
		if hero.IsKnightOfTheSunAcquired then 
			hero:AddAbility("gawain_light_of_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_light_of_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_light_of_galatine_upgrade_2"):GetLevel())
			hero:SwapAbilities("gawain_light_of_galatine_upgrade_3", "gawain_light_of_galatine_upgrade_2", true, false) 
			if not hero:FindAbilityByName("gawain_light_of_galatine_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_light_of_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_light_of_galatine_upgrade_2"):GetCooldownTimeRemaining())
			end

			hero:RemoveModifierByName("gawain_light_of_galatine_upgrade_2")
		else
			hero:AddAbility("gawain_light_of_galatine_upgrade_1")
			hero:FindAbilityByName("gawain_light_of_galatine_upgrade_1"):SetLevel(hero:FindAbilityByName("gawain_light_of_galatine"):GetLevel())
			hero:SwapAbilities("gawain_light_of_galatine_upgrade_1", "gawain_light_of_galatine", true, false) 
			if not hero:FindAbilityByName("gawain_light_of_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_light_of_galatine_upgrade_1"):StartCooldown(hero:FindAbilityByName("gawain_light_of_galatine"):GetCooldownTimeRemaining())
			end

			hero:RemoveModifierByName("gawain_light_of_galatine")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKnightAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKnightOfTheSunAcquired) then

		if hero:HasModifier("modifier_gawain_combo_excalibur_window") then 
			hero:RemoveModifierByName("modifier_gawain_combo_excalibur_window")
		end

		hero.IsKnightOfTheSunAcquired = true
		
		if hero.IsBeltOfBertilakAcquired then 
			hero:AddAbility("gawain_sun_of_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_1"):GetLevel())
			hero:SwapAbilities("gawain_sun_of_galatine_upgrade_3", "gawain_sun_of_galatine_upgrade_1", true, false) 
			if not hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_1"):GetCooldownTimeRemaining())
			end

			hero:RemoveAbility("gawain_sun_of_galatine_upgrade_1")

			hero:AddAbility("gawain_excalibur_galatine_upgrade_3")
			hero:AddAbility("gawain_excalibur_galatine_light_upgrade_3")
			hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):GetLevel())
			hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):GetLevel())
			
			if not hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_1"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_galatine_detonate") then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetHidden(true)
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetHidden(true)
			else
				if hero:HasModifier("modifier_light_of_galatine") then
					hero:SwapAbilities("gawain_excalibur_galatine_light_upgrade_3", "gawain_excalibur_galatine_light_upgrade_1", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_3"):SetHidden(true)
				else
					hero:SwapAbilities("gawain_excalibur_galatine_upgrade_3", "gawain_excalibur_galatine_upgrade_1", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_3"):SetHidden(true)
				end
			end
			hero:RemoveAbility("gawain_excalibur_galatine_light_upgrade_1")
			hero:RemoveAbility("gawain_excalibur_galatine_upgrade_1")

			hero:AddAbility("gawain_combo_excalibur_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_3"):SetLevel(1)
			if not hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_1"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_combo_excalibur_galatine_upgrade_1")
		else
			hero:AddAbility("gawain_sun_of_galatine_upgrade_2")
			hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_2"):SetLevel(hero:FindAbilityByName("gawain_sun_of_galatine"):GetLevel())
			hero:SwapAbilities("gawain_sun_of_galatine_upgrade_2", "gawain_sun_of_galatine", true, false) 
			if not hero:FindAbilityByName("gawain_sun_of_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_sun_of_galatine_upgrade_2"):StartCooldown(hero:FindAbilityByName("gawain_sun_of_galatine"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_sun_of_galatine")

			hero:AddAbility("gawain_excalibur_galatine_upgrade_2")
			hero:AddAbility("gawain_excalibur_galatine_light_upgrade_2")
			hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine"):GetLevel())
			hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):SetLevel(hero:FindAbilityByName("gawain_excalibur_galatine"):GetLevel())
			
			if not hero:FindAbilityByName("gawain_excalibur_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):StartCooldown(hero:FindAbilityByName("gawain_excalibur_galatine"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_galatine_detonate") then 
				hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):SetHidden(true)
				hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):SetHidden(true)
			else
				if hero:HasModifier("modifier_light_of_galatine") then
					hero:SwapAbilities("gawain_excalibur_galatine_light_upgrade_2", "gawain_excalibur_galatine_light", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_upgrade_2"):SetHidden(true)
				else
					hero:SwapAbilities("gawain_excalibur_galatine_upgrade_2", "gawain_excalibur_galatine", true, false) 
					hero:FindAbilityByName("gawain_excalibur_galatine_light_upgrade_2"):SetHidden(true)
				end
			end
			hero:RemoveAbility("gawain_excalibur_galatine_light")
			hero:RemoveAbility("gawain_excalibur_galatine")

			hero:AddAbility("gawain_combo_excalibur_galatine_upgrade_2")
			hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_2"):SetLevel(1)
			if not hero:FindAbilityByName("gawain_combo_excalibur_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_combo_excalibur_galatine_upgrade_2"):StartCooldown(hero:FindAbilityByName("gawain_combo_excalibur_galatine"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("gawain_combo_excalibur_galatine")
		end

		if hero.IsNightLessCharismaAcquired then 
			hero:AddAbility("gawain_light_of_galatine_upgrade_3")
			hero:FindAbilityByName("gawain_light_of_galatine_upgrade_3"):SetLevel(hero:FindAbilityByName("gawain_light_of_galatine_upgrade_1"):GetLevel())
			hero:SwapAbilities("gawain_light_of_galatine_upgrade_3", "gawain_light_of_galatine_upgrade_1", true, false) 
			if not hero:FindAbilityByName("gawain_light_of_galatine_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_light_of_galatine_upgrade_3"):StartCooldown(hero:FindAbilityByName("gawain_light_of_galatine_upgrade_1"):GetCooldownTimeRemaining())
			end

			hero:RemoveModifierByName("gawain_light_of_galatine_upgrade_1")
		else
			hero:AddAbility("gawain_light_of_galatine_upgrade_2")
			hero:FindAbilityByName("gawain_light_of_galatine_upgrade_2"):SetLevel(hero:FindAbilityByName("gawain_light_of_galatine"):GetLevel())
			hero:SwapAbilities("gawain_light_of_galatine_upgrade_2", "gawain_light_of_galatine", true, false) 
			if not hero:FindAbilityByName("gawain_light_of_galatine"):IsCooldownReady() then 
				hero:FindAbilityByName("gawain_light_of_galatine_upgrade_2"):StartCooldown(hero:FindAbilityByName("gawain_light_of_galatine"):GetCooldownTimeRemaining())
			end

			hero:RemoveModifierByName("gawain_light_of_galatine")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end