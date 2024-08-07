function OnQ(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local range = ability:GetSpecialValueFor("range")
	local targetPoint = ability:GetCursorPosition()

	local casterPos = caster:GetAbsOrigin()
	local direction = (targetPoint - casterPos):Normalized()
	local dashDistance = range  -- move in the direction of the cursor by the specified range

	local damage = ability:GetSpecialValueFor("damage")

    if caster.IsCrime then
    	local damage_per_agi = ability:GetSpecialValueFor("damage_per_agi")
    	damage = (damage_per_agi * caster:GetAgility()) + damage
    end

	local dashSpeed = dashDistance / duration

	-- Calculate the dash step
	local dashStep = direction * dashSpeed / 30 -- 30 times per second, the engine processes the script

	local elapsedTime = 0
	--StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_3, rate=3})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_dashing", {})

    caster:EmitSound("Melt.QSFX")
	caster:EmitSound("Melt.Q" ..math.random(1,3))

    local particleef = ParticleManager:CreateParticle("particles/melt/melt_spin_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleef, 1, caster:GetAbsOrigin())

    local spinfx = ParticleManager:CreateParticle("particles/melt/melt_spin_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(spinfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(spinfx, 5, Vector(200,0,0))
    
	Timers:CreateTimer(function()
		local groundPoint = caster:GetAbsOrigin()
		-- Check if the caster has reached the target point
		if elapsedTime < duration then
			-- Move the caster a step closer to the target point
			local newPos = caster:GetAbsOrigin() + dashStep * 3
            local newPosFar = caster:GetAbsOrigin() + (dashStep * 10)
		    local groundHeight = GetGroundHeight(newPos, nil)
		    local groundHeightFar = GetGroundHeight(newPosFar, nil)
		    print(groundHeight)
		    if (groundHeight > 120 and groundHeight < 130) then
		    	if(GridNav:IsTraversable(newPos)) or not (groundHeightFar > 120 and groundHeightFar < 130) then
			        -- If the ground height is above or equal to the threshold, the point is in the playable area
		            caster:SetAbsOrigin(caster:GetAbsOrigin() + dashStep)
		            groundPoint = caster:GetAbsOrigin()
		    	else
					caster:SetAbsOrigin(groundPoint)
		    	end
			else
		        -- If the ground height is above or equal to the threshold, the point is in the playable area
	            caster:SetAbsOrigin(caster:GetAbsOrigin() + dashStep)
	            groundPoint = caster:GetAbsOrigin()
			end

			elapsedTime = elapsedTime + 1/30 -- 1/30 because the timer runs every 1/30th of a second
			return 1/30 -- return the interval (1/30th of a second)
		else
			-- Dash completed, find units in the line and deal damage to them
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(spinfx, true)
			ParticleManager:ReleaseParticleIndex(spinfx)

			local endPoint = casterPos + direction * dashDistance
			local units = FindUnitsInLine(caster:GetTeamNumber(), casterPos, endPoint, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
			for _, unit in pairs(units) do
	   		    if caster.IsVirus then
					local melt_f = caster:FindAbilityByName("melt_f")
					melt_f:ApplyDataDrivenModifier(caster, unit, "modifier_melt_virus", {})
			    end

			    DoDamage(caster, unit, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
			    local particleeff2 = ParticleManager:CreateParticle("particles/melt/melt_cut_fx.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
			    ParticleManager:SetParticleControl(particleeff2, 0, unit:GetAbsOrigin())
	    		unit:EmitSound("Melt.SfxCut" ..math.random(1,3))
	    		unit:EmitSound("Melt.SfxCutLayering")
			end
		end
	end)
end

function OnW(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local circle_range = ability:GetSpecialValueFor("circle_range")
	local circle_damage = ability:GetSpecialValueFor("circle_damage") -- Damage value you want to apply
	local impact_range = ability:GetSpecialValueFor("impact_range")
	local damage = ability:GetSpecialValueFor("damage") -- Damage value you want to apply
	local front_range = ability:GetSpecialValueFor("front_range") -- Damage value you want to apply
	local delay_spin = ability:GetSpecialValueFor("delay_spin") -- Damage value you want to apply
	local delay_impact = ability:GetSpecialValueFor("delay_impact") -- Damage value you want to apply
	local width = ability:GetSpecialValueFor("width") -- Damage value you want to apply
	local slow_duration = ability:GetSpecialValueFor("slow_duration") -- Damage value you want to apply

	-- Calculate the starting and ending points of the AOE
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.5})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_dance", {})
	caster:EmitSound("Melt.W" ..math.random(1,3))
	-- Apply the first circle of damage after half of the duration
	Timers:CreateTimer(delay_spin, function()
    	caster:EmitSound("Melt.WSfxSpin")
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, circle_range,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		    local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_q_spin.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		    ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin())

		for _, enemy in pairs(enemies) do
   		    if caster.IsVirus then
			local melt_f = caster:FindAbilityByName("melt_f")
			melt_f:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_virus" ,  {})
		    end

			DoDamage(caster, enemy, circle_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			ability:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_dance_slow", {duration = slow_duration})
			local particleeff2 = ParticleManager:CreateParticle("particles/melt/melt_cut_fx.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
    		enemy:EmitSound("Melt.SfxCut"  ..math.random(1,3))
    		enemy:EmitSound("Melt.SfxCutLayering")
			ParticleManager:SetParticleControl(particleeff2, 0, enemy:GetAbsOrigin())
		end
	end)

	-- Apply the second circle of damage after the full duration
	Timers:CreateTimer(delay_impact, function()
    	caster:EmitSound("Melt.WSfxSlam")
		local startPoint = caster:GetAbsOrigin() + caster:GetForwardVector() * front_range
		    local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_w_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    ParticleManager:SetParticleControl(particleeff1, 0, startPoint)


		local enemies = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), startPoint, nil, width,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE)

        for _, enemy in pairs(enemies) do
   		    if caster.IsVirus then
				local melt_f = caster:FindAbilityByName("melt_f")
				melt_f:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_virus" ,  {})
		    end
            DoDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        end

        if caster.IsSadistic then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_dance_buff", {})
        end
        MeltCheckCombo(caster,ability)
	end)
end

function OnE(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local aoe_find_range = ability:GetSpecialValueFor("aoe_find_range")
	local damage = ability:GetSpecialValueFor("damage")
	local cooldown_refund = ability:GetSpecialValueFor("cooldown_refund") -- Damage value you want to apply
	local miss_stun_self = ability:GetSpecialValueFor("miss_stun_self") -- Damage value you want to apply
	local stun_duration = ability:GetSpecialValueFor("stun_duration") -- Damage value you want to apply
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local cast_range = ability:GetSpecialValueFor("cast_range")
	local dist = ((caster:GetAbsOrigin() - target_loc):Length2D() * 10/6)
	local forwardvec = (target_loc - caster:GetAbsOrigin()):Normalized()
	local total_hit = 6
	local hit_count = 0
	local interval = 0.1

	if dist > 2000 then
		dist = cast_range  --Default one
	end

	if caster.IsCrime then 
		local bonus_agi = ability:GetSpecialValueFor("bonus_agi") * caster:GetAgility()
		damage = damage + bonus_agi
	end

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay + 0.05)
	StartAnimation(caster, {duration=3, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})

	caster:EmitSound("Melt.E" ..math.random(1,2))

    local melt = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(forwardvec.x * dist*2, forwardvec.y * dist*2, 4000))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-13333))

	--caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 

	Timers:CreateTimer({
		endTime = cast_delay + 0.05,
		callback = function()

		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	
	 	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_find_range,
	        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

        -- Remove invisible enemies from the enemies table
        --[[for i = #enemies, 1, -1 do
            if enemies[i]:IsInvisible() or enemies[i]:IsInvulnerable() then
                table.remove(enemies, i)
            end
        end]]

	    if #enemies > 0 then
	        --[[local closestEnemy = nil
	        local closestDistance = 9999999 -- Set a very large initial distance

	        for _, enemy in pairs(enemies) do
	            local distance = (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	            if distance < closestDistance and not enemy:IsInvisible() and not enemy:IsInvulnerable() then
	                closestEnemy = enemy
	                closestDistance = distance
	            end
	        end]]

	        --if closestEnemy then
				caster:SetAbsOrigin(enemies[1]:GetAbsOrigin() + Vector(-50,0,0))
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_e_block", {Duration = total_hit * interval})

				Timers:CreateTimer(0, function()

					if hit_count == total_hit or not caster:IsAlive() then 
						if caster:IsAlive() then 
							caster:SetAbsOrigin(caster:GetAbsOrigin() - (Vector(caster:GetForwardVector().x * 150, caster:GetForwardVector().y * 150, 0)))
							FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
						end
						return nil 
					end

			   		if caster.IsVirus then
						local melt_f = caster:FindAbilityByName("melt_f")
						melt_f:ApplyDataDrivenModifier(caster, enemies[1], "modifier_melt_virus" ,  {})
					end

	    			enemies[1]:EmitSound("Melt.ESFX")
	    			enemies[1]:EmitSound("Melt.ESFXLayer1")
	    			enemies[1]:EmitSound("Melt.ESFXLayer2")

		            local bonus_stun = 0
		            if caster.IsComposite then
						local melt_d = caster:FindAbilityByName("melt_d_upgrade")
						bonus_stun = melt_d:GetSpecialValueFor("bonus_stun_e_per25_str") * (caster:GetStrength() / 25)
		            end

					enemies[1]:AddNewModifier(caster, ability, "modifier_stunned", {duration = (stun_duration + bonus_stun)/total_hit})
			    	local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_e_ground_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemies[1])
			   		ParticleManager:SetParticleControl(particleeff1, 0, enemies[1]:GetAbsOrigin())

			   		DoDamage(caster, enemies[1], damage/total_hit, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			   		hit_count = hit_count + 1
			   		return interval
			   	end)

		   		if not ability:IsCooldownReady() then
					ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
					local cd = ability:GetCooldownTimeRemaining()
					ability:EndCooldown()
					ability:StartCooldown(cd - cooldown_refund)	
		   		end			
	        --end
	    else
			caster:AddNewModifier(caster, ability, "modifier_stunned", {duration = miss_stun_self})
			EndAnimation(caster)
			StartAnimation(caster, {duration=miss_stun_self, activity=ACT_DOTA_DIE, rate=1.2})
	    end
	end})
end

function OnR(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage_aoe = ability:GetSpecialValueFor("damage_aoe")
    local damage = ability:GetSpecialValueFor("damage")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")

    local reduce_cast = 0
    if caster.IsComposite then
	local melt_d = caster:FindAbilityByName("melt_d_upgrade")
	reduce_cast = melt_d:GetSpecialValueFor("bonus_r_reduce_cast_per25_agi") * (caster:GetAgility() / 25)   
    end

    local minimum_cast_delay = ability:GetSpecialValueFor("minimum_cast_delay")
    -- Calculate the starting and ending points of the AOE
    cast_delay = cast_delay - reduce_cast

    if cast_delay < minimum_cast_delay then
    	cast_delay = minimum_cast_delay
    end

    local flight_after = cast_delay / 4

    if caster.IsSaintGraph then
    	local damage_per_int = ability:GetSpecialValueFor("damage_per_int")
    	damage = (damage_per_int * caster:GetIntellect()) + damage
    end


    ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_dance", {duration = cast_delay + 0.05})
    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.05)
    giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay + 0.05)

    Timers:CreateTimer(0.05, function()
    StartAnimation(caster, {duration=3, activity=ACT_DOTA_ATTACK2, rate=0.5 + reduce_cast})
	EmitGlobalSound("Melt.R" ..math.random(1,2))
    end)

    StartAnimation(caster, {duration=3, activity=ACT_DOTA_ATTACK2, rate=0.5 + reduce_cast})
    -- Lift the caster after flight_after duration
    Timers:CreateTimer(flight_after, function()
        -- Lift the caster
    	--caster.original_position = caster:GetAbsOrigin()
		--giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay - flight_after)
        caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0, 0, 400))
    end)
    -- Apply the first circle of damage after half of the duration
    Timers:CreateTimer(cast_delay - (cast_delay / 7) , function()
    	local ground = GetGroundPosition(caster:GetAbsOrigin(), caster)
    	local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_r.vpcf", PATTACH_CUSTOMORIGIN, caster)
   		ParticleManager:SetParticleControl(particleeff1, 0, ground)
   		local foottrailfx = ParticleManager:CreateParticle("particles/melt/melt_dash_trail.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    	ParticleManager:SetParticleControlEnt(foottrailfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_foot", caster:GetAbsOrigin(),false)
    	local footglowfx = ParticleManager:CreateParticle("particles/melt/melt_foot_glow.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    	ParticleManager:SetParticleControlEnt(footglowfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_foot", caster:GetAbsOrigin(),false)
    	Timers:CreateTimer(0.45, function()
    		ParticleManager:DestroyParticle(foottrailfx, true)
	       	ParticleManager:ReleaseParticleIndex(foottrailfx)
	       	ParticleManager:DestroyParticle(footglowfx, true)
	       	ParticleManager:ReleaseParticleIndex(footglowfx)
        end)
    end)

    -- Apply the first circle of damage after half of the duration
    Timers:CreateTimer(cast_delay, function()
		EmitGlobalSound("Melt.RSFX")
		EmitGlobalSound("Melt.RSFXLayer2")
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, damage_aoe,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        for _, enemy in pairs(enemies) do
		    if caster.IsVirus then
			local melt_f = caster:FindAbilityByName("melt_f")
			melt_f:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_virus" ,  {})
		    end

            DoDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        end
        local ground = GetGroundPosition(caster:GetAbsOrigin(), caster)
        caster:SetAbsOrigin(ground)
    end)
end

function OnVirusThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local damage_per_second = ability:GetSpecialValueFor("damage_per_second")

    local bonus_dmg = 0
    if caster.IsComposite then
		local melt_d = caster:FindAbilityByName("melt_d_upgrade")
		bonus_dmg = melt_d:GetSpecialValueFor("bonus_melt_virus_damage_per_int") * (caster:GetIntellect())   
    end

	DoDamage(caster, target, damage_per_second + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
end

function OnVirusAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsVirus) then
		UpgradeAttribute(hero, "fate_empty1", "melt_f" , true)
		hero.FSkill = "melt_f"

		hero.IsVirus= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnComposite(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsComposite) then

		UpgradeAttribute(hero, "melt_d", "melt_d_upgrade" , true)
		hero.DSkill = "melt_d_upgrade"

		hero.IsComposite= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnCrimeBallet(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCrime) then

		UpgradeAttribute(hero, "melt_q", "melt_q_upgrade" , true)
		UpgradeAttribute(hero, "melt_e", "melt_e_upgrade" , true)
		hero.QSkill = "melt_q_upgrade"
		hero.ESkill = "melt_e_upgrade"

		hero.IsCrime= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSadistic(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSadistic) then

		UpgradeAttribute(hero, "melt_w", "melt_w_upgrade" , true)
		hero.WSkill = "melt_w_upgrade"

		hero.IsSadistic= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSaintGraphBallet(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSaintGraph) then

		if hero:HasModifier("modifier_combo_window") then
			hero:RemoveModifierByName("modifier_combo_window")
		end
		UpgradeAttribute(hero, "melt_r", "melt_r_upgrade" , true)
		UpgradeAttribute(hero, "melt_combo", "melt_combo_upgrade" , false)
		hero.RSkill = "melt_r_upgrade"
		hero.ComboSkill = "melt_combo_upgrade"

		hero.IsSaintGraph= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSplashBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local splash_dmg_per_str = ability:GetSpecialValueFor("splash_dmg_per_str")
	local splash_aoe_per_int = ability:GetSpecialValueFor("splash_aoe_per_int")
	
	if caster:GetAttackTarget() ~= nil then
		if caster:GetAttackTarget():GetName() == "npc_dota_ward_base" then
			return
		end
	end

    local particleeff = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin())

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_aoe_per_int * caster:GetIntellect(),
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, enemy in pairs(enemies) do
		DoDamage(caster, enemy, splash_dmg_per_str * caster:GetStrength(), DAMAGE_TYPE_MAGICAL, 0, ability, false)
		if caster.IsVirus then
		local melt_f = caster:FindAbilityByName("melt_f")
		melt_f:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_virus" ,  {})
	    end
	end
end

function OnComboCheck(keys)
	local caster = keys.caster
	local ability = keys.ability

    caster:EmitSound("Melt.ComboPrecast")
end

function OnCombo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = ability:GetSpecialValueFor("damage") -- Damage value you want to apply
    local cast_delay = ability:GetSpecialValueFor("cast_delay") -- Delay before moving to the target
    local dash_speed = ability:GetSpecialValueFor("dash_speed") -- Speed of the dash
    local dash_duration_max = ability:GetSpecialValueFor("dash_duration_max") -- Speed of the dash
    local fail_cast_stun = ability:GetSpecialValueFor("fail_cast_stun") -- Speed of the dash
    local fail_cast_cooldown = ability:GetSpecialValueFor("fail_cast_cooldown") -- Speed of the dash

    local target = keys.target
    if not target:IsRealHero() then 
        local hero = target:GetOwner()
        if IsValidEntity(hero) and IsMountedHero(hero) then 
            target = hero 
        end
    end
    caster.cyclone_count = 0

    caster:RemoveModifierByName("modifier_sequence_window") 
    caster:RemoveModifierByName("modifier_combo_window")

    EmitGlobalSound("Melt.ComboCast")
    EmitGlobalSound("Melt.ComboStart")

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 15)
    ability:ApplyDataDrivenModifier(caster, caster, "combo_melt_flying", {duration = 5})

    local targetPoint = target:GetAbsOrigin()
    local casterPos = caster:GetAbsOrigin()
    local direction = (targetPoint - casterPos):Normalized()
    local distance = (targetPoint - casterPos):Length2D()

    local dashDistance = (targetPoint - casterPos):Length2D()
    local dashSpeed = dash_speed

    local dashStep = direction * dashSpeed / 30 -- 30 times per second, the engine processes the script

    local elapsedTime = 0
    StartAnimation(caster, {duration=2, activity=ACT_DOTA_CHANNEL_ABILITY_6, rate=0.3})
    local distanceToTarget = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()

    local particleeff2 = ParticleManager:CreateParticle("particles/melt/melt_combo_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff2, 0, caster:GetAbsOrigin())
    local particleeff23 = ParticleManager:CreateParticle("particles/melt/melt_combo_trail_debris.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particleeff23, 0, caster:GetAbsOrigin())

    local groundPoint = caster:GetAbsOrigin()

    Timers:CreateTimer(function()
        -- Check if the caster has reached the target point
        if elapsedTime < dash_duration_max then
            targetPoint = target:GetAbsOrigin()
            direction = (targetPoint - casterPos):Normalized()
            dashStep = direction * dashSpeed / 30
   			ParticleManager:SetParticleControl(particleeff23, 3, caster:GetAbsOrigin())

            distanceToTarget = (caster:GetAbsOrigin() - targetPoint):Length2D()

            --if math.floor(elapsedTime*100)%6 == 0 then 
            	local feet_fx = ParticleManager:CreateParticle("particles/melt/melt_feet_twinkle.vpcf", PATTACH_CUSTOMORIGIN, caster)
            	ParticleManager:SetParticleControl(feet_fx, 0, caster:GetAbsOrigin()+ Vector(0,0,20))
            	local water_fx = ParticleManager:CreateParticle("particles/melt/melt_feet_water_ring.vpcf", PATTACH_CUSTOMORIGIN, caster)
            	ParticleManager:SetParticleControl(water_fx, 0, caster:GetAbsOrigin()+ Vector(0,0,20))
    			Timers:CreateTimer(1.5, function()
    				ParticleManager:DestroyParticle(feet_fx, false)
    				ParticleManager:ReleaseParticleIndex(feet_fx)
    				ParticleManager:DestroyParticle(water_fx, false)
    				ParticleManager:ReleaseParticleIndex(water_fx)
    			end)
    		--end
            	
            -- Move the caster a step closer to the target point
            local newPos = caster:GetAbsOrigin() + (dashStep * 3)
            local newPosFar = caster:GetAbsOrigin() + (dashStep * 10)
		    local groundHeight = GetGroundHeight(newPos, nil)
		    local groundHeightFar = GetGroundHeight(newPosFar, nil)
		    print(groundHeight)
		    if (groundHeight > 120 and groundHeight < 130) or not groundHeight == 0 then
		    	if(GridNav:IsTraversable(newPos)) or not (groundHeightFar > 120 and groundHeightFar < 130) then
			        -- If the ground height is above or equal to the threshold, the point is in the playable area
		            caster:SetAbsOrigin(caster:GetAbsOrigin() + dashStep)
		            groundPoint = caster:GetAbsOrigin()
		    	else
					caster:SetAbsOrigin(groundPoint)
		    	end
			else
		        -- If the ground height is above or equal to the threshold, the point is in the playable area
	            caster:SetAbsOrigin(caster:GetAbsOrigin() + dashStep)
	            groundPoint = caster:GetAbsOrigin()
			end

            if distanceToTarget < 200 then
                caster:SetAbsOrigin(target:GetAbsOrigin())
            	--FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
            	OnComboSuccess(caster,ability,target, dash_duration_max - elapsedTime)
        		caster:RemoveModifierByName("combo_melt_flying")

            	return
            else
                elapsedTime = elapsedTime + 1/30 -- 1/30 because the timer runs every 1/30th of a second
                return 1/30 -- return the interval (1/30th of a second)
            end
        else
        	if elapsedTime > dash_duration_max then
	            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	            giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", fail_cast_stun + 0.05)
				StartAnimation(caster, {duration=3, activity=ACT_DOTA_DIE, rate=0.6})
				ability:EndCooldown()
    			ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_combo_cooldown", {Duration = fail_cast_cooldown})
    			ability:StartCooldown(fail_cast_cooldown)
	            caster:RemoveModifierByName("jump_pause")
        		caster:RemoveModifierByName("combo_melt_flying")
        	end
        end
    end)
end

function OnComboSuccess(caster, ability, target, extradelay)
    local damage = ability:GetSpecialValueFor("damage") -- Damage value you want to apply
    local cast_delay = ability:GetSpecialValueFor("cast_delay") -- Delay before moving to the target
    local dash_speed = ability:GetSpecialValueFor("dash_speed") -- Speed of the dash
    local dash_duration_max = ability:GetSpecialValueFor("dash_duration_max") -- Maximum duration of the dash animation
    local fail_cast_stun = ability:GetSpecialValueFor("fail_cast_stun") -- Stun duration on failed cast
    local agi_per_slash = ability:GetSpecialValueFor("agi_per_slash") -- Agility per slash
    local damage_per_slash_multiplier_attack = ability:GetSpecialValueFor("damage_per_slash_multiplier_attack") -- Damage multiplier per slash
    local final_aoe_damage = ability:GetSpecialValueFor("final_aoe_damage") -- Damage multiplier per slash
 	local final_stun = ability:GetSpecialValueFor("final_stun") 
   	local cd_time = ability:GetCooldown(1)
   	ability:EndCooldown()
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_combo_cooldown", {Duration = cd_time})
    ability:StartCooldown(cd_time)

	if caster.IsSaintGraph then
		caster:FindAbilityByName("melt_r_upgrade"):StartCooldown(caster:FindAbilityByName("melt_r_upgrade"):GetCooldown(caster:FindAbilityByName("melt_r_upgrade"):GetLevel()))
	else
		caster:FindAbilityByName("melt_r"):StartCooldown(caster:FindAbilityByName("melt_r"):GetCooldown(caster:FindAbilityByName("melt_r"):GetLevel()))
	end

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 3) 
    
    local slashcount = math.floor(caster:GetAgility() / agi_per_slash)
    local lasthitpoint = target:GetAbsOrigin()

    if slashcount < 4 then
    	slashcount = 4
    end

    local interval = 0.4
    local interval_minus = 0.02

    local total_time = (slashcount * 0.4) - (slashcount*(slashcount+1)*interval_minus/2)
    local spin_rate = 2.22

    local spinfx = ParticleManager:CreateParticle("particles/melt/melt_spin_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(spinfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(spinfx, 5, Vector(200,0,0))

    if caster:HasModifier("modifier_alternate_01") then 
    	caster.dummyfx = ParticleManager:CreateParticle("particles/melt/white_melt_combo_dummy.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    	ParticleManager:SetParticleControlEnt(caster.dummyfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(),false)

		caster:AddEffects(EF_NODRAW)
	end

    local cyclonefx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/cyclone_fall2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(cyclonefx, 0, target:GetAbsOrigin())

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_melt_fly", {Duration = total_time + 0.85})

    local dummy = CreateUnitByName("godhand_res_locator", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=total_time + 1})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration=total_time + 1.1})

    -- Iterate over the slash count and create a timer for each slash
    --Timers:CreateTimer(extradelay / 3, function()
    	ability:ApplyDataDrivenModifier(caster, target, "modifier_melt_combo_slow", {Duration = total_time + 0.2})
	    for i = 1, slashcount do
	        Timers:CreateTimer(i * interval, function()
		   		local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_q_spin.vpcf", PATTACH_CUSTOMORIGIN, caster)
			    ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin())

		   		local particleeff111 = ParticleManager:CreateParticle("particles/econ/items/drow/drow_ti9_immortal/drow_ti9_marksman_frost_gem_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			    ParticleManager:SetParticleControl(particleeff111, 0, target:GetAbsOrigin() + Vector(0,0,80))

			    local particleeff2 = ParticleManager:CreateParticle("particles/melt/melt_cut_fx.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			    ParticleManager:SetParticleControl(particleeff2, 0, target:GetAbsOrigin())

	    		target:EmitSound("Melt.SfxCut"  ..math.random(1,3))
	    		target:EmitSound("Melt.SfxCutLayering")

				StartAnimation(caster, {duration= interval, activity=ACT_DOTA_CAST_ABILITY_6, rate=spin_rate})
				if target:IsAlive() then
					dummy:SetAbsOrigin(target:GetAbsOrigin())
				end
				caster:SetAbsOrigin(dummy:GetAbsOrigin() --[[+ Vector(RandomFloat(-70, 70),RandomFloat(-70, 70),0)]])
				--FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	   		    if caster.IsVirus then
					local melt_f = caster:FindAbilityByName("melt_f")
					melt_f:ApplyDataDrivenModifier(caster, target, "modifier_melt_virus" ,  {})
			    end

			    DoDamage(caster, target, caster:GetAttackDamage() * damage_per_slash_multiplier_attack , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	        	interval = interval - interval_minus
	        	spin_rate = spin_rate + 0.09
	        end)
	    end

        Timers:CreateTimer(total_time + 0.4, function()
        	ParticleManager:DestroyParticle(spinfx, true)
        	ParticleManager:ReleaseParticleIndex(spinfx)
        	ParticleManager:DestroyParticle(cyclonefx, true)
        	ParticleManager:ReleaseParticleIndex(cyclonefx)
        	if caster:HasModifier("modifier_alternate_01") then 
        		ParticleManager:DestroyParticle(caster.dummyfx, true)
        		ParticleManager:ReleaseParticleIndex(caster.dummyfx)

				caster:RemoveEffects(EF_NODRAW)
        	end
    		EmitGlobalSound("Melt.ComboFinish")
    		if target:IsAlive() then
    			dummy:SetAbsOrigin(target:GetAbsOrigin())
    		end
            caster:SetAbsOrigin(dummy:GetAbsOrigin() + Vector(0,0,400))
    		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 0.65)
    		StartAnimation(caster, {duration=0.65, activity=ACT_DOTA_CAST_ABILITY_5, rate=2.8})
    		local foottrailfx = ParticleManager:CreateParticle("particles/melt/melt_dash_trail.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(foottrailfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_foot", caster:GetAbsOrigin(),false)
    		local footglowfx = ParticleManager:CreateParticle("particles/melt/melt_foot_glow.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(footglowfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_foot", caster:GetAbsOrigin(),false)
    		Timers:CreateTimer(0.45, function()
    			ParticleManager:DestroyParticle(foottrailfx, true)
	        	ParticleManager:ReleaseParticleIndex(foottrailfx)
	        	ParticleManager:DestroyParticle(footglowfx, true)
	        	ParticleManager:ReleaseParticleIndex(footglowfx)
        	end)
        end)

        Timers:CreateTimer(total_time + 0.75, function()
    		local particleeff1 = ParticleManager:CreateParticle("particles/melt/melt_r.vpcf", PATTACH_CUSTOMORIGIN, caster)
   			ParticleManager:SetParticleControl(particleeff1, 0, dummy:GetAbsOrigin())
        end)

        Timers:CreateTimer(total_time + 0.85, function()
			EmitGlobalSound("Melt.RSFX")
			EmitGlobalSound("Melt.RSFXLayer2")

			if target:IsAlive() then
				dummy:SetAbsOrigin(target:GetAbsOrigin())
			end
            caster:SetAbsOrigin(dummy:GetAbsOrigin())
			
	   		local particleeff1 = ParticleManager:CreateParticle("particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
		    ParticleManager:SetParticleControl(particleeff1, 3, dummy:GetAbsOrigin())
			
        	--FindClearSpaceForUnit(caster, lasthitpoint, true)
        	caster:RemoveModifierByName("jump_pause")

			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), dummy:GetAbsOrigin(), nil, final_aoe_damage,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for _, enemy in pairs(enemies) do
	   		    if caster.IsVirus then
					local melt_f = caster:FindAbilityByName("melt_f")
					melt_f:ApplyDataDrivenModifier(caster, enemy, "modifier_melt_virus" ,  {})
			    end

				DoDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration=final_stun})
			end		
			Timers:CreateTimer(0.2, function()
				local dash_back = caster:GetAbsOrigin() - (Vector(caster:GetForwardVector().x,caster:GetForwardVector().y,0) * 150)
				FindClearSpaceForUnit(caster, dash_back, true)
			end)		
        end)
	--end)
end

function OnCycloneDPS(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local cyclone_dps = ability:GetSpecialValueFor("cyclone_dps")
	local cyclone_bonus_int = ability:GetSpecialValueFor("cyclone_bonus_int") * caster:GetIntellect()
	DoDamage(caster, target, (cyclone_dps + cyclone_bonus_int) * 0.2, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	caster.cyclone_count = caster.cyclone_count + 1

	if caster.cyclone_count >= 5 then 
		giveUnitDataDrivenModifier(caster, target, "silenced", 0.2)
	end
	if caster.cyclone_count >= 10 then 
		giveUnitDataDrivenModifier(caster, target, "rooted", 0.2)
	end
	if caster.cyclone_count >= 15 then 
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration=0.2})
	end
	if caster.cyclone_count >= 20 then 
		giveUnitDataDrivenModifier(caster, target, "revoked", 0.2)
	end
end

function OnComboDummyButton(keys)
	local caster = keys.caster 
	local ability = keys.ability
	MeltCheckCombo(caster, ability)
end

function MeltCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
    	if string.match(ability:GetAbilityName(), "melt_w") and caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and not caster:HasModifier("modifier_melt_combo_cooldown") then
			caster.WUsed = true
			caster.WTime = GameRules:GetGameTime()
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_sequence_window", {duration = 5})
			if caster.WTimer ~= nil then 
				Timers:RemoveTimer(caster.WTimer)
				caster.WTimer = nil
			end
			caster.WTimer = Timers:CreateTimer(5.0, function()
				caster.WUsed = false
			end)

		else
			if string.match(ability:GetAbilityName(), "melt_d_dummy") and caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and not caster:HasModifier("modifier_melt_combo_cooldown") then
				if caster.WUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 5 - (newTime - caster.WTime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = duration})
				end
			end
		end
    end
end

function OnSequenceStart(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.DSkill, "melt_d_dummy", false, true)
end

function OnSequenceDestroy(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.DSkill, "melt_d_dummy", true, false)
end

function OnSequenceDie(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_sequence_window")
end

function OnComboWindow(keys)
	local caster = keys.caster
	if(caster.IsSaintGraph) then
		caster:SwapAbilities("melt_r_upgrade", "melt_combo_upgrade", false, true)
	else
		caster:SwapAbilities("melt_r", "melt_combo", false, true)
	end
end

function OnComboWindowBroken(keys)
	local caster = keys.caster
	if(caster.IsSaintGraph) then
		caster:SwapAbilities("melt_combo_upgrade", "melt_r_upgrade", false, true)
	else
		caster:SwapAbilities("melt_combo", "melt_r", false, true)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_combo_window")
end

function OnMeltKill(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit


	if target:IsHero() then 
		stack = caster:GetModifierStackCount("modifier_virus_stack", caster) or 0
		caster:SetModifierStackCount("modifier_virus_stack", caster, stack + 1)
	end 
end

function OnMeltVirusGone(keys)
	print("OnMeltVirusGone called")
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit

	print(target)
	if target:IsHero() and not target:IsAlive() then 		
	print(target:IsHero())
	print(target:IsAlive())
		stack = caster:GetModifierStackCount("modifier_virus_stack", caster) or 0
		caster:SetModifierStackCount("modifier_virus_stack", caster, stack + 1)
	end 
end