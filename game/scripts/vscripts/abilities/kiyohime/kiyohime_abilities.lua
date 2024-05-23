function OnKiyoQ(keys)
    local caster = keys.caster
    local ability = keys.ability
	local buff_duration = ability:GetSpecialValueFor("buff_duration")
	local sa_5_duration = ability:GetSpecialValueFor("sa_5_duration")

	RemoveSlowEffect(caster)
    caster:EmitSound("Kiyo.Q")
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_kiyohime_q_buff", {Duration = buff_duration})

    if(caster.Sa5Acquired) then
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_kiyohime_q_buff_cc_immune", {Duration = sa_5_duration})
    end

    KiyoCheckCombo(caster,ability)
end 

function OnCrit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	local crit_bonus = ability:GetSpecialValueFor("crit_bonus")
	local agi_scaling = ability:GetSpecialValueFor("agi_scaling")

	local rng = RandomInt(0,100)
	if (rng < crit_chance) then
		DoDamage(caster, target, (caster:GetAgility() * agi_scaling) , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
end

function OnStalkingThink(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local range = ability:GetSpecialValueFor("range")
	local width = ability:GetSpecialValueFor("width")

    local casterPos = caster:GetAbsOrigin()
    local casterForward = caster:GetForwardVector()
    local startPoint = casterPos
    local endPoint = casterPos + casterForward * range

    local units = FindUnitsInLine(caster:GetTeamNumber(), startPoint, endPoint, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)

    -- Do something with the found units
    for _, unit in pairs(units) do
    	if IsFemaleServant(unit) then
    	else
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_kiyo_stalking_buff" , {} )
    		ability:ApplyDataDrivenModifier(caster, unit, "modifier_kiyo_stalking_debuff" , {Duration = 1} )
    		
    		return
    	end
    end
end

function OnPhysicalAbility(keys,damagebase)
    local caster = keys.caster
    --local target = keys.target
    local damagefinal = damagebase
    local d_ability = caster:FindAbilityByName(caster.DSkill)
	local crit_chance = d_ability:GetSpecialValueFor("crit_chance")
	local crit_bonus = d_ability:GetSpecialValueFor("crit_bonus_ability") / 100
	local agi_scaling = d_ability:GetSpecialValueFor("agi_scaling")

	local rng = RandomInt(0,100)
	if (rng < crit_chance) then
		damagefinal = (damagefinal + (caster:GetAgility() * agi_scaling)) * (1 + crit_bonus)
		print('crit dmg: ' .. damagefinal)
		return damagefinal
	else
		return damagefinal
	end
end

function OnKiyoW(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local cast_duration = ability:GetSpecialValueFor("cast_duration")
	local casterPos = caster:GetAbsOrigin()
	local casterForward = caster:GetForwardVector()
	local coneAngle = ability:GetSpecialValueFor("angle")
	local searchRadius = ability:GetSpecialValueFor("range")
	local minRange = ability:GetSpecialValueFor("minimum_range")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_kiyo_slash", {})
	StartAnimation(caster, {duration=cast_duration - 0.05, activity=ACT_DOTA_ATTACK, rate=2})
	caster:EmitSound("Kiyo.W" ..math.random(1,2))

	Timers:CreateTimer(cast_duration - 0.05, function()
		FreezeAnimation(caster,0.05)
	end)

	Timers:CreateTimer(0.2, function()
	caster:EmitSound("Kiyo.WSfxEarly")
	end)

	Timers:CreateTimer(cast_duration - 0.05, function()
		caster:EmitSound("Kiyo.WSfx1")
		caster:EmitSound("Kiyo.WSfx2")

		local casterForward = caster:GetForwardVector()
		local yawRadians = math.atan2(casterForward.y, casterForward.x)
		local yawDegrees = yawRadians * 180 / math.pi
		local yawVector = Vector(yawDegrees, 0, 0)

		local slash = ParticleManager:CreateParticle("particles/kiyohime/kiyo_q_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(slash, 0, caster:GetAbsOrigin())
		-- Calculate the cone's half angle in radians
		local coneHalfAngleRad = math.rad(coneAngle / 2)
		-- Calculate the positions for the search
		local searchPos = casterPos + casterForward * searchRadius
        
		local searchDirection = casterForward

		-- Find units in the search area
		local units = FindUnitsInRadius(caster:GetTeamNumber(), searchPos, nil, searchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_UNITS_EVERYWHERE, false)

		for _, unit in pairs(units) do
		    local unitPos = unit:GetAbsOrigin()
		    local toUnit = unitPos - casterPos
		    local angleToUnit = math.acos(toUnit:Dot(searchDirection) / toUnit:Length())  -- Calculate angle between vectors

		    if angleToUnit <= coneHalfAngleRad then 
		    	if toUnit:Length() >= minRange then
					DoDamage(caster, unit, OnPhysicalAbility(keys,damage) , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
					local hit = ParticleManager:CreateParticle("particles/kiyohime/kiyo_w_slash2.vpcf", PATTACH_ABSORIGIN, unit)
					ParticleManager:SetParticleControl(hit, 0, unit:GetAbsOrigin())

					if(caster.Sa2Acquired) then
						ability:ApplyDataDrivenModifier(caster, unit, "modifier_kiyo_slash_enemy",{})
					end
		        -- The unit is within the cone and meets the minimum range requirement
		        -- Do something with the unit, such as applying an effect or dealing damage
		        else
		        	DoDamage(caster, unit, OnPhysicalAbility(keys,damage) * 0.5 , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		        end
		    end
		end

	end)
end

function OnKiyoE(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cast_duration = ability:GetSpecialValueFor("cast_delay")
	local wave_speed = ability:GetSpecialValueFor("wave_speed")
	local wave_distance = ability:GetSpecialValueFor("wave_distance")
	local wave_width = ability:GetSpecialValueFor("wave_width")

	local explosion_point = caster:GetAbsOrigin() + caster:GetForwardVector() * wave_distance
	local explosion_delay = ability:GetSpecialValueFor("explosion_delay")
	local explosion_aoe = ability:GetSpecialValueFor("explosion_aoe")
	local explosion_damage = ability:GetSpecialValueFor("explosion_damage")
	local explosion_stun = ability:GetSpecialValueFor("explosion_stun")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", cast_duration)
	StartAnimation(caster, {duration=cast_duration - 0.05, activity=ACT_DOTA_CAST_ABILITY_2, rate=1, bloop = true})
	caster:EmitSound("Kiyo.E")

	Timers:CreateTimer(cast_duration - 0.05, function()
		FreezeAnimation(caster,0.05)
	end)

	Timers:CreateTimer(cast_duration + explosion_delay - 0.05, function()		
		EmitSoundOnLocationWithCaster(explosion_point, "Kiyo.ESfxPop1" , caster)
		EmitSoundOnLocationWithCaster(explosion_point, "Kiyo.ESfxPop2" , caster)
		EmitSoundOnLocationWithCaster(explosion_point, "Kiyo.ESfxPop3" , caster)

		local hit = ParticleManager:CreateParticle("particles/kiyohime/kiyo_e_blast.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(hit, 0, explosion_point)
		-- Find units in the search area	
		local targets = FindUnitsInRadius(caster:GetTeam(), explosion_point, nil, explosion_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do 

			if(caster.Sa4Acquired) then
    			local int_scale = ability:GetSpecialValueFor("int_scale")
    			explosion_damage = explosion_damage + (int_scale * caster:GetIntellect())
    		end

			DoDamage(caster, v, explosion_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = explosion_stun})
		end
	end)

	Timers:CreateTimer(cast_duration - 0.05, function()
		caster:EmitSound("Kiyo.ESfx2")
		caster:EmitSound("Kiyo.ESfx1")

		local NFProjectile = 
		{
			Ability = ability,
	        EffectName = "particles/kiyohime/kiyo_e_proj.vpcf",
	        iMoveSpeed = wave_speed,
	        vSpawnOrigin = caster:GetOrigin(),
	        fDistance = wave_distance,
	        fStartRadius = wave_width,
	        fEndRadius = wave_width,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = true,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        fExpireTime = GameRules:GetGameTime() + 1.0,
			bDeleteOnHit = false,
			vVelocity = caster:GetForwardVector() * wave_speed
		}

		local projectile = ProjectileManager:CreateLinearProjectile(NFProjectile)
	end)
end

function OnKiyoEProjectileHit(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local wave_damage = ability:GetSpecialValueFor("wave_damage")

    if target and not target:IsNull() and target:IsAlive() then
    	if(caster.Sa4Acquired) then
    		local int_scale = ability:GetSpecialValueFor("int_scale")
    		wave_damage = wave_damage + (int_scale * caster:GetIntellect())
    	end
        DoDamage(caster, target, wave_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end
end

function OnKiyoRCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
    if --[[GridNav:IsBlocked(target_loc) or]] not GridNav:IsTraversable(target_loc) then
    	caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return false
	end
end

function OnKiyoR(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cast_duration = ability:GetSpecialValueFor("cast_duration")
	local first_slash_delay = ability:GetSpecialValueFor("first_slash_delay")
	local second_slash_delay = ability:GetSpecialValueFor("second_slash_delay")
	local burst_delay = ability:GetSpecialValueFor("burst_delay")
	local slash_damage = ability:GetSpecialValueFor("slash_damage")
	local slash_range = ability:GetSpecialValueFor("slash_range")
	local slash_aoe = ability:GetSpecialValueFor("slash_aoe")
	local burst_damage = ability:GetSpecialValueFor("burst_damage")
	local casterPos = caster:GetAbsOrigin()
    local targetPos = ability:GetCursorPosition()
    local unitsDamaged = {}

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_duration)
	StartAnimation(caster, {duration=first_slash_delay - 0.05, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.4})
	local IsInMarble = false
	EmitGlobalSound("Kiyo.R1")

	Timers:CreateTimer(first_slash_delay - 0.05, function()
		if caster:IsAlive() then
			giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_duration - 0.325)
			local newCasterPos = casterPos + (0.6 * (targetPos - casterPos))
			newCasterPos = newCasterPos + Vector(0, 0, 200) -- Raise the caster 200 units above the ground
			if caster:HasModifier("modifier_inside_marble") then 
				IsInMarble = true
			end
			caster:SetAbsOrigin(newCasterPos)
			StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_ATTACK2, rate=1.6})
		end
	end)

    local lineA = targetPos - Vector(slash_range , slash_range , 0)
    local lineB = targetPos + Vector(slash_range , slash_range , 0)
    local lineC = targetPos - Vector(slash_range , -slash_range , 0)
    local lineD = targetPos + Vector(slash_range , -slash_range , 0)

	Timers:CreateTimer(first_slash_delay, function()
		if caster:IsAlive() then
			if caster:HasModifier("modifier_inside_marble") then 
				IsInMarble = true
			end
			EmitGlobalSound("Kiyo.R2")
			EmitGlobalSound("Kiyo.RSlash1")
			EmitGlobalSound("Kiyo.RSlashExtra")
			StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_ATTACK_EVENT, rate=1.6})

			local slash = ParticleManager:CreateParticle("particles/kiyohime/kiyo_r_slash.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(slash, 0, lineA)
			ParticleManager:SetParticleControl(slash, 1, lineB)

	   		local unitsAB = FindUnitsInLine(caster:GetTeam(), lineA, lineB, caster, slash_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)

				for _, unit in pairs(unitsAB) do
	   		     unitsDamaged[unit] = true  -- Mark units in unitsAB as already damaged
	   		 end
	   		 for _, unit in pairs(unitsAB) do
	   		     DoDamage(caster, unit, OnPhysicalAbility(keys,slash_damage), DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	   		    	unit.SlashCount = 1
	   		 end
		end
	end)

	Timers:CreateTimer(second_slash_delay, function()
		if caster:IsAlive() then
			if caster:HasModifier("modifier_inside_marble") then 
				IsInMarble = true
			end
			EmitGlobalSound("Kiyo.R3")
			EmitGlobalSound("Kiyo.RSlash2")
			EmitGlobalSound("Kiyo.RSlashExtra")
			StartAnimation(caster, {duration=cast_duration-second_slash_delay , activity=ACT_DOTA_CAST_ABILITY_2, rate=1})

			local slash = ParticleManager:CreateParticle("particles/kiyohime/kiyo_r_slash.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(slash, 0, lineC)
			ParticleManager:SetParticleControl(slash, 1, lineD)

		    local unitsCD = FindUnitsInLine(caster:GetTeam(), lineC, lineD, caster, slash_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)

	        for _, unit in pairs(unitsCD) do
	            unitsDamaged[unit] = true  -- Mark units in unitsCD as already damaged
	        end
		    for _, unit in pairs(unitsCD) do
		        DoDamage(caster, unit, OnPhysicalAbility(keys,slash_damage), DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		   		unit.SlashCount = unit.SlashCount + 1
		    end
		end
	end)

	Timers:CreateTimer(burst_delay + 0.5, function()
		if caster:IsAlive() then
			EmitGlobalSound("Kiyo.R4")
        -- Deal damage to units in unitsDamaged
        for unit, _ in pairs(unitsDamaged) do
        	if(caster.Sa4Acquired) then
        		local int_scale = ability:GetSpecialValueFor("burst_int_scale")
        		burst_damage = burst_damage + (int_scale * caster:GetIntellect())
        	end

        	unit:EmitSound("Kiyo.RBurstPop1")
        	unit:EmitSound("Kiyo.RBurstPop2")
        	unit:EmitSound("Kiyo.RBurstPop3")
        	--EmitGlobalSound("Kiyo.RBurstPop1")
			--EmitGlobalSound("Kiyo.RBurstPop2")
			--EmitGlobalSound("Kiyo.RBurstPop3")
        		local r_burst_bonus_per_slash = ability:GetSpecialValueFor("r_burst_bonus_per_slash")
            	DoDamage(caster, unit, burst_damage * (1 + (unit.SlashCount * r_burst_bonus_per_slash /100)), DAMAGE_TYPE_MAGICAL, 0, ability, false)	
	   			unit.SlashCount = 0
			local b = ParticleManager:CreateParticle("particles/kiyohime/kiyo_r_blast.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(b, 3, unit:GetAbsOrigin())
        end
    	end
	end)

	Timers:CreateTimer(cast_duration + 0.2, function()
		if IsInMarble == true and not caster:HasModifier("modifier_inside_marble") then 
			casterPos = caster:GetAbsOrigin() - (0.4 * (targetPos - casterPos))
			IsInMarble = false 
		end

		caster:SetAbsOrigin(casterPos)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

        if caster:HasModifier("jump_pause") then
        	caster:RemoveModifierByName("jump_pause")
        end
	end)


	--[[Timers:CreateTimer(cast_duration + 0.2, function()
		-- Find all heroes named "npc_dota_hero_ember_spirit" within a radius of 1000 units from a specific point for both teams
		local targetName = "npc_dota_hero_ember_spirit"
		local searchRadius = 50000
		local origin = Vector(0, 0, 0)

		local emiya = nil
		-- Iterate through all heroes and filter by name and distance
		GameRules:GetGameModeEntity():SetContextThink("FindHeroes", function()
		    local heroes = HeroList:GetAllHeroes()
		    for _, hero in pairs(heroes) do
		        if hero:GetUnitName() == targetName and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS or hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
		            local distance = (hero:GetAbsOrigin() - origin):Length2D()
		            if distance <= searchRadius then
		                -- Do something with the hero (for example, print its name)
		                emiya = hero
		            end
		        end
		    end
		    return nil
		end, 0)

        if caster:HasModifier("jump_pause") then
			if UBWcheck == true and emiya:IsAlive() == false then 
				caster:SetAbsOrigin(emiya:GetAbsOrigin())
		        FindClearSpaceForUnit(caster, emiya:GetAbsOrigin(), true)
			else
				caster:SetAbsOrigin(casterPos)
        		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			end
        	caster:RemoveModifierByName("jump_pause")
        end
	end)]]
end

function OnKiyoCombo(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage_lower = ability:GetSpecialValueFor("damage_lower")
	local damage_upper = ability:GetSpecialValueFor("damage_upper")
	local bell_aoe = ability:GetSpecialValueFor("bell_aoe")
	local kiyo_arrive = ability:GetSpecialValueFor("kiyo_arrive")
	local bell_falling = ability:GetSpecialValueFor("bell_falling")
	local damage_delay = ability:GetSpecialValueFor("damage_delay")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local casterPos = caster:GetAbsOrigin()
    local targetPos = target:GetAbsOrigin()
    local unitsHit = {}
    local particle = "particles/custom/kiyo_lancer/kiyo_model.vpcf"

    if caster:HasModifier("modifier_alternate_01") then 
    	particle = "particles/custom/kiyo_lancer/kiyo_swim_model.vpcf"
    end

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_kiyohime_combo_cooldown", {Duration = ability:GetCooldown(1)})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay)

	EmitGlobalSound("Kiyo.Combo")

	local kiyo_r = caster:FindAbilityByName(caster.RSkill)
	kiyo_r:StartCooldown(kiyo_r:GetCooldown(kiyo_r:GetLevel()))

	Timers:CreateTimer(cast_delay/2, function()
		StartAnimation(caster, {duration=cast_delay/2, activity=ACT_DOTA_CAST_ABILITY_3, rate=(24/15)*(cast_delay/2)})
		local jump_counter = 0
		Timers:CreateTimer(0.2, function()
			if jump_counter == 10 then return end
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,100))
			jump_counter = jump_counter + 1
			return 0.033
		end)
	end)

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then
			if target:IsAlive() then
				targetPos = target:GetAbsOrigin()
			end
			local bell = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(bell, 0, targetPos + Vector(0,0,700))
			ParticleManager:SetParticleControl(bell, 1, targetPos)
			ParticleManager:SetParticleControl(bell, 2, Vector(damage_delay,0,kiyo_arrive))
			ParticleManager:SetParticleControl(bell, 3, Vector(0,0,caster:GetAnglesAsVector().y+90))
			ParticleManager:SetParticleControl(bell, 4, Vector(bell_aoe,0,0))

			Timers:CreateTimer(bell_falling / 2, function()
				EmitGlobalSound("Kiyo.ComboBellDown1")
				EmitGlobalSound("Kiyo.ComboBellDown2")

				giveUnitDataDrivenModifier(caster, caster, "jump_pause", damage_delay)
				caster:AddEffects(EF_NODRAW)
				GetGroundPosition(caster:GetAbsOrigin(), caster)
				SpawnVisionDummy(caster, targetPos, bell_aoe, damage_delay, false)
				--[[local newCasterPos = targetPos 
				newCasterPos = newCasterPos + Vector(0, 0, 4000)
				caster:SetAbsOrigin(newCasterPos)]]

				local bellArrive = ParticleManager:CreateParticle("particles/kiyohime/kiyo_combo_bell_arrive.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(bellArrive, 0, targetPos)
		
				unitsHit = FindUnitsInRadius(caster:GetTeamNumber(), targetPos, nil, bell_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_UNITS_EVERYWHERE, false)
			    for _, unit in pairs(unitsHit) do
			    	ability:ApplyDataDrivenModifier(caster, unit, "modifier_kiyo_combo_debuff", {Duration=damage_delay + 1.5})
			    	unit:SetAbsOrigin(targetPos)
			    end
			end)

			Timers:CreateTimer(damage_delay, function()
				EmitGlobalSound("Kiyo.ComboImpact1")
				EmitGlobalSound("Kiyo.ComboImpact2")
				caster:RemoveEffects(EF_NODRAW)
				GetGroundPosition(caster:GetAbsOrigin(), caster)
				--caster:SetAbsOrigin(casterPos)
		        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

				local bellStrike = ParticleManager:CreateParticle("particles/kiyohime/kiyo_combo_impact.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(bellStrike, 0, targetPos)

		        ParticleManager:DestroyParticle(bell, true)
		        ParticleManager:ReleaseParticleIndex(bell)

		        -- Deal damage to units in unitsDamaged
		        for _, unit in pairs(unitsHit) do
		            if IsValidEntity(unit) and unit:IsAlive() then
			        	local damage = RandomInt(damage_upper, damage_lower)
			        	if unit:HasModifier("modifier_kiyo_combo_debuff") then
			            	DoDamage(caster, unit, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
				    	end
				    	unit:SetAbsOrigin(targetPos)
				    	FindClearSpaceForUnit(unit, targetPos, true)
				    	unit:RemoveModifierByName("modifier_kiyo_combo_debuff")
			        end
			    end

		        if caster:HasModifier("jump_pause") then
		        	caster:RemoveModifierByName("jump_pause")
		        end
			end)
		end
	end)
end

function OnKiyoBellStart(keys)
	local target = keys.target
	target:AddEffects(EF_NODRAW)
end

function OnKiyoBellEnd(keys)
	local target = keys.target
	target:RemoveEffects(EF_NODRAW)
end

function OnKiyoSa1(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Sa1Acquired) then

		hero.Sa1Acquired = true
		UpgradeAttribute(hero, "kiyo_d", "kiyo_d_upgrade", true)
		--hero:FindAbilityByName("kiyo_d"):SetLevel(2)
		hero.DSkill = "kiyo_d_upgrade"
		NonResetAbility(hero)

		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKiyoSa2(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Sa2Acquired) then

		hero.Sa2Acquired = true
		UpgradeAttribute(hero, "kiyo_w", "kiyo_w_upgrade", true)
		hero.WSkill = "kiyo_w_upgrade"

		if(hero.Sa4Acquired)then
			UpgradeAttribute(hero, "kiyo_r_upgrade2", "kiyo_r_upgrade3", true)
			hero.RSkill = "kiyo_r_upgrade3"
		else
			UpgradeAttribute(hero, "kiyo_r", "kiyo_r_upgrade1", true)
			hero.RSkill = "kiyo_r_upgrade1"
		end

		NonResetAbility(hero)

		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKiyoSa3(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Sa3Acquired) then

		hero.Sa3Acquired = true

		UpgradeAttribute(hero, "fate_empty1", "kiyo_f", true)
		hero:FindAbilityByName("kiyo_f"):SetLevel(1)
		hero.FSkill = "kiyo_f"

		NonResetAbility(hero)

		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKiyoSa4(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Sa4Acquired) then

		hero.Sa4Acquired = true

		UpgradeAttribute(hero, "kiyo_e", "kiyo_e_upgrade", true)
		hero.ESkill = "kiyo_e_upgrade"

		if(hero.Sa2Acquired)then
			UpgradeAttribute(hero, "kiyo_r_upgrade1", "kiyo_r_upgrade3", true)
			hero.RSkill = "kiyo_r_upgrade3"
		else
			UpgradeAttribute(hero, "kiyo_r", "kiyo_r_upgrade2", true)
			hero.RSkill = "kiyo_r_upgrade2"
		end

		NonResetAbility(hero)

		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKiyoSa5(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.Sa5Acquired) then

		if hero:HasModifier("modifier_combo_window") then 
			hero:RemoveModifierByName("modifier_combo_window")
		end

		hero.Sa5Acquired = true

		UpgradeAttribute(hero, "kiyo_q", "kiyo_q_upgrade", true)
		hero.QSkill = "kiyo_q_upgrade"

		NonResetAbility(hero)

		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function KiyoCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
    	if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and not caster:HasModifier("modifier_kiyohime_combo_cooldown") then 
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 3})
    	end
    	--[[if caster.Sa5Acquired then
			if string.match(ability:GetAbilityName(), "kiyo_q_upgrade") and not caster:HasModifier("modifier_kiyohime_combo_cooldown") then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 5})
			end
    	else
			if string.match(ability:GetAbilityName(), "kiyo_q") and not caster:HasModifier("modifier_kiyohime_combo_cooldown") then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 5})
			end
    	end]]
    end
end

function OnComboWindow(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.RSkill, "kiyo_combo", false, true)
end

function OnComboWindowBroken(keys)
	local caster = keys.caster
	caster:SwapAbilities("kiyo_combo", caster.RSkill, false, true)
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_combo_window")
end
