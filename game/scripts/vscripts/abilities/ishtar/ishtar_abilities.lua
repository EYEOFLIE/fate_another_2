function OnIshtarDead(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gem_loss = ability:GetSpecialValueFor("gem_loss")

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	local newstack = 0
	if stack == 1 then
		newstack = 0
	else
		if caster.IsGemsAcquired then
		newstack = stack / 2
		else
		newstack = 0
		end
	end
	caster:SetModifierStackCount("modifier_ishtar_gem", caster, newstack)
end

function IshtarCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if caster.IsVenusAcquired == true then
	    	if string.match(ability:GetAbilityName(), "ishtar_w") and not caster:HasModifier("modifier_ishtar_combo_cooldown") and caster:FindAbilityByName("ishtar_r_upgrade"):IsCooldownReady() then 
	            ability:ApplyDataDrivenModifier(caster, caster, "modifier_ishtar_combo_window", {})
	        end
   		else
	    	if string.match(ability:GetAbilityName(), "ishtar_w") and not caster:HasModifier("modifier_ishtar_combo_cooldown") and caster:FindAbilityByName("ishtar_r"):IsCooldownReady() then 
	            ability:ApplyDataDrivenModifier(caster, caster, "modifier_ishtar_combo_window", {})
	        end
        end
    end
end

function OnComboWindow(keys)
	local caster = keys.caster
	if caster.IsVenusAcquired == true then
		caster:SwapAbilities("ishtar_r_upgrade", "ishtar_combo" , false, true)
	else
		caster:SwapAbilities("ishtar_r", "ishtar_combo", false, true)
	end
end

function OnComboWindowBroken(keys)
	local caster = keys.caster	

	if caster.IsVenusAcquired == true then
		caster:SwapAbilities("ishtar_combo" , "ishtar_r_upgrade" , false, true)
	else
		caster:SwapAbilities( "ishtar_combo" , "ishtar_r", false, true)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ishtar_combo_window")
end

function OnIshtarQ(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local gem_ability = caster:FindAbilityByName("ishtar_d")
	local gem_cost = ability:GetSpecialValueFor("gem_cost")
	local max_gem = gem_ability:GetSpecialValueFor("max_gem")

	local num = RandomInt(0, 100)
    if num <= 20 then
    	caster:EmitSound("Ishtar.Q")
    end
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.QSFX", caster)

	caster:SetGold(0, false)
	caster:SetGold(caster:GetGold() - gem_cost, true) 

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0

	if stack > max_gem then
		return
    end

	local newstack = stack + 1
	caster:SetModifierStackCount("modifier_ishtar_gem", caster, newstack)
end

function OnIshtarQCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gem_ability = caster:FindAbilityByName("ishtar_d")
	local gem_cost = ability:GetSpecialValueFor("gem_cost")
	local max_gem = gem_ability:GetSpecialValueFor("max_gem")

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0

	if stack == max_gem then
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "Maximum Gem")
        return
    elseif caster:GetGold() < gem_cost then
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "No money")
        return
    end
end

function OnIshtarE(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local aoerandom = 350
	local arrows = ability:GetSpecialValueFor("arrows")
	local speed = ability:GetSpecialValueFor("speed")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local effect_name_tracking = "particles/ishtar/ishtar_proj_track.vpcf"

	local particleeff1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_e_cast.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin() + Vector(0,0,50))

	caster:EmitSound("Ishtar.E" .. math.random(1,3))

    Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then
			local delay = 0.06
			for i=1,arrows do
			    Timers:CreateTimer(delay * i, function()

					local ranpos = RandomPointInCircle(caster:GetAbsOrigin(), aoerandom) + Vector(0,0,50)

					EmitSoundOnLocationWithCaster(ranpos, "Ishtar.Projectile" .. math.random(1,4) , caster)
					EmitSoundOnLocationWithCaster(ranpos, "Ishtar.ProjectileBase" , caster)

					local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_laser_spawn.vpcf", PATTACH_WORLDORIGIN, caster)
					ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,80))
					ParticleManager:SetParticleControl(particleeff, 9, ranpos)

	    			Timers:CreateTimer(0.04, function()
						local particleeff1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_spawn.vpcf", PATTACH_ABSORIGIN, caster)
						ParticleManager:SetParticleControl(particleeff1, 0, ranpos)

						local projectile = {
					    	Target = target,
							Source = caster,
							Ability = ability,	
				        	EffectName = effect_name_tracking,
					        iMoveSpeed = speed,
							vSourceLoc= ranpos,
							bDrawsOnMinimap = false,
					        bDodgeable = true,
					        bIsAttack = false,
					        flExpireTime = GameRules:GetGameTime() + 3,
				   		}
				    	ProjectileManager:CreateTrackingProjectile(projectile)

					end)
				end)
			end
		end
	end)
end

function OnIshtarEHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")

	target:EmitSound("Ishtar.ProjectileLayer")
	target:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

	local gem_ability = caster:FindAbilityByName("ishtar_q")
	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	local scale = gem_ability:GetSpecialValueFor("bonus_e_per_gem")
	damage = damage + scale * stack
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	local particleeff1 = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particleeff1, 0, target:GetAbsOrigin())
end

function OnIshtarW(keys)
	local caster = keys.caster
	local ability = keys.ability
	local dash_duration = ability:GetSpecialValueFor("dash_duration")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = ability:GetSpecialValueFor("speed")
	local target_loc = ability:GetCursorPosition()

	caster:EmitSound("Ishtar.WDashSFX")
	caster:EmitSound("Ishtar.WDashSFX2")

    Timers:CreateTimer(cast_delay, function()
		if interrupt then return end

		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar_dash_star.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())
		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ishtar_dashing", {duration = dash_duration})

		IshtarCheckCombo(caster,ability)
	end)
end

function OnIshtarWThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")

	caster:SetForwardVector(caster:GetForwardVector():Normalized())
	local nextpos = caster:GetAbsOrigin() + caster:GetForwardVector() * speed / 5
	caster:SetAbsOrigin(nextpos)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function OnIshtarWFinish(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_ishtar_dashing")
	caster:MoveToPosition(caster:GetAbsOrigin() + caster:GetForwardVector() * 10)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function OnIshtarR(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = ability:GetSpecialValueFor("speed")
	local width = ability:GetSpecialValueFor("width")
	local range_max = ability:GetSpecialValueFor("range_max")
	local target_loc = ability:GetCursorPosition()
	local mode = ability:GetAutoCastState()

	if mode == true then
		local extra_range = ability:GetSpecialValueFor("extra_range")
		local extra_cast_delay = ability:GetSpecialValueFor("extra_cast_delay")

		local gem_cost_per_r = ability:GetSpecialValueFor("gem_cost_per_r")
		stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
		if(stack > 0) then
			stack = stack - gem_cost_per_r
			caster.IsBonusR = true
		else
			caster.IsBonusR = false
		end
		caster:SetModifierStackCount("modifier_ishtar_gem", caster, stack)

		range_max = range_max + extra_range
		cast_delay = cast_delay + extra_cast_delay

		StartAnimation(caster, {duration=1.4, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.2})
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.2)
	else
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.8})
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay  + 0.1)
	end

	if mode == true then
	    Timers:CreateTimer(0.2, function()
			 EmitGlobalSound("Ishtar.R" .. math.random(1,3))
		end)
	else
		EmitGlobalSound("Ishtar.R" .. math.random(1,3))
	end

	local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())
	local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())

	local particleeffhand = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_buff.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particleeffhand, 0, caster:GetAbsOrigin() + Vector(0,0,160))	

    Timers:CreateTimer(0.3, function()
		if caster:IsAlive() then
	    	if mode == true then
				local dashback = Physics:Unit(caster)
				local origin = caster:GetOrigin()
				local backward = -caster:GetForwardVector()
				local invul_duration = ability:GetSpecialValueFor("invul_duration")
				local dash_back = ability:GetSpecialValueFor("dash_back")

				giveUnitDataDrivenModifier(caster, caster, "jump_pause",invul_duration)

				caster:PreventDI()
				caster:SetPhysicsFriction(0)
				caster:SetPhysicsVelocity(backward * dash_back * 1.25)
			   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
				
				Timers:CreateTimer(invul_duration, function() 
					caster:PreventDI(false)
					caster:SetPhysicsVelocity(Vector(0,0,0))
					FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				end)
	    	end
    	end
    end)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ishtar_casting", {})

    Timers:CreateTimer(cast_delay - 0.15, function()
		if caster:IsAlive() then
			local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_r_cast.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,140))
		end
    end)

    Timers:CreateTimer(cast_delay - 0.1, function()
		if caster:IsAlive() then
			EmitGlobalSound("Ishtar.Shoot")
			local Arrow =
			{
				Ability = keys.ability,
		        EffectName = "particles/ishtar/ishtar-r/ishtar_r_projectile_model2.vpcf",
		        iMoveSpeed = 9999,
		        vSpawnOrigin = caster:GetOrigin() + Vector(0,0,60),
		        fDistance = range_max,
		        fStartRadius = width,
		        fEndRadius = width + 30,
		        Source = caster,
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		        fExpireTime = GameRules:GetGameTime() + 3.0,
				bDeleteOnHit = true,
				vVelocity = caster:GetForwardVector() * speed,		
			}
			ProjectileManager:CreateLinearProjectile(Arrow)

		    Timers:CreateTimer(0.1, function()
				EmitGlobalSound("Ishtar.RLaunch")
			end)
		end
	end)
end

function OnIshtarRHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
    local damage = ability:GetSpecialValueFor("damage")
    local damage_impact = ability:GetSpecialValueFor("damage_impact")
    local impact_radius = ability:GetSpecialValueFor("impact_radius")
	local mode = ability:GetAutoCastState()

	EmitSoundOnLocationWithCaster(target:GetAbsOrigin() , "Ishtar.RImpact" , caster)
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin() , "Ishtar.RImpact2" , caster)
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin() , "Ishtar.RImpact3" , caster)

	local pot_hit = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/impact/ishtar_r_impact_parent.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pot_hit, 0, target:GetAbsOrigin())	

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	local gem_ability = caster:FindAbilityByName("ishtar_q")
	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	local scale = gem_ability:GetSpecialValueFor("bonus_r_impact_per_gem") * stack
	damage_impact = damage_impact + scale

	if mode == true then
		local extra_impact_damage_percentage = ability:GetSpecialValueFor("extra_impact_damage_percentage")
		damage_impact = damage_impact + damage_impact * extra_impact_damage_percentage / 100
		if caster.IsBonusR then
			local bonus_r_damage = ability:GetSpecialValueFor("bonus_r_damage")
			damage_impact = damage_impact + bonus_r_damage
		end
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	       	DoDamage(caster, v, damage_impact  , DAMAGE_TYPE_MAGICAL, 0, ability, false)	       	
       	end
    end
end

function OnIshtarCombo(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = ability:GetSpecialValueFor("speed")
	local width = ability:GetSpecialValueFor("width")
	local range_max = ability:GetSpecialValueFor("range_max")
	local target_loc = ability:GetCursorPosition()

	local cast_position = caster:GetAbsOrigin()

	local portal = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_portal_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(portal, 0, caster:GetAbsOrigin() + Vector(100,0,100))	

	caster:MoveToPosition(caster:GetAbsOrigin() + Vector(100,0,100))

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ishtar_combo_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

    Timers:CreateTimer(0.7, function()
		if caster:IsAlive() then
	    	caster:SetAbsOrigin(caster:GetAbsOrigin() +Vector(0,0,9999))
			local portal2 = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_portal_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
		    Timers:CreateTimer(0.7, function()
		    	DestroyParticle(portal2, true)
			end)
		end
	end)

    Timers:CreateTimer(1.2, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay - 1.1)
		if caster:IsAlive() then
		ParticleManager:SetParticleControl(portal, 0, caster:GetAbsOrigin() + Vector(0,0,700))	
		caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,700))
		end
	end)

    Timers:CreateTimer(1, function()
		if caster:IsAlive() then
		local particleeffdel = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6_leading.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeffdel, 3, caster:GetAbsOrigin())
		end
	end)

    Timers:CreateTimer(1.6, function()
		if caster:IsAlive() then
		StartAnimation(caster, {duration=2, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.5})
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay  + 0.1)

		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())

		local particleeffhand = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_buff.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particleeffhand, 0, caster:GetAbsOrigin() + Vector(0,0,160))	
		end
	end)


    Timers:CreateTimer(1.6, function()
	end)

    Timers:CreateTimer(1.8, function()
		if caster:IsAlive() then
		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())
		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())    	
		end
	end)

    Timers:CreateTimer(2.9, function()
    	DestroyParticle(particleefdel, true)

		if caster:IsAlive() then
		local targetdummy = CreateUnitByName("dummy_unit", target_loc , false, caster, caster, caster:GetTeamNumber())
		targetdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
		targetdummy:AddNewModifier(caster, nil, "modifier_phased", {duration=9})
		targetdummy:AddNewModifier(caster, nil, "modifier_kill", {duration=9})

			local projectile = {
	    	Target = targetdummy,
			Source = caster,
			Ability = ability,	
        	EffectName = "particles/ishtar/ishtar_combo/ishtar_combo_projectile.vpcf",
	        iMoveSpeed = speed,
			vSourceLoc= caster:GetAbsOrigin(),
			bDrawsOnMinimap = false,
	        bDodgeable = false,
	        bIsAttack = false,
	        flExpireTime = GameRules:GetGameTime() + 3,
			bProvidesVision = true,                           -- Optional
			iVisionRadius = 150,                              -- Optional
			iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
	   		}
	    	ProjectileManager:CreateTrackingProjectile(projectile)
	    end
    end)
	--caster:
end

function OnDashUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local hero = caster.HeroUnit

	caster:FindAbilityByName("ishtar_f"):SetLevel(ability:GetLevel())
end

function OnPassiveThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local buff_radius = ability:GetSpecialValueFor("buff_radius")

	if caster.IsGoddessAcquired == false then return end

	if caster:IsAlive() then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, buff_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				if IsFemaleServant(v) == false then
					ability:ApplyDataDrivenModifier(caster, v, "modifier_ishtar_passive_buff", {duration = 1})
				end
	       	end
	    end
	end
end

function OnPassiveDamaged(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local attacker = keys.attacker
	local recover_damage_taken = ability:GetSpecialValueFor("recover_damage_taken")
	local damage_taken = keys.DamageTaken

	if caster.IsGoddessAcquired == false then return end

	if IsFemaleServant(attacker) == false then
		local recoverhealth = damage_taken * recover_damage_taken / 100

		stack = caster:GetModifierStackCount("modifier_ishtar_damage_stack", caster) or 0
		local newstack = stack + recoverhealth
		caster:SetModifierStackCount("modifier_ishtar_damage_stack", caster, newstack)
	end
end


function OnPassiveRegenThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local recovery_per_second = ability:GetSpecialValueFor("recovery_per_second")

	if caster.IsGoddessAcquired == false then return end

	stack = caster:GetModifierStackCount("modifier_ishtar_damage_stack", caster) or 0

	if stack > recovery_per_second / 4 then
		caster:FateHeal(recovery_per_second / 4, caster, true)
		local newstack = stack - recovery_per_second / 4
		caster:SetModifierStackCount("modifier_ishtar_damage_stack", caster, newstack)
	else
		if(stack > 0) then
			caster:FateHeal(stack, caster, true)
			local newstack = 0
			caster:SetModifierStackCount("modifier_ishtar_damage_stack", caster, 0)
		end
	end
end

function OnPassiveGemThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local time_per_gem = ability:GetSpecialValueFor("time_per_gem")
	local stack_gain = ability:GetSpecialValueFor("stack_gain")
	local gem_ability = caster:FindAbilityByName("ishtar_d")
	local max_gem = gem_ability:GetSpecialValueFor("max_gem")

	if caster.IsOfferingAcquired == false then return end

	if caster:IsAlive() then
		stack = caster:GetModifierStackCount("modifier_ishtar_passive_gem_gain", caster) or 0
		local newstack = stack + stack_gain
		if(stack == time_per_gem) then
			caster:SetModifierStackCount("modifier_ishtar_passive_gem_gain", caster, 0)
			gemstack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
			if(gemstack < max_gem) then
				gemstack = gemstack + 1
				caster:SetModifierStackCount("modifier_ishtar_gem", caster, gemstack)
			end
		else
			caster:SetModifierStackCount("modifier_ishtar_passive_gem_gain", caster, newstack)
		end
	end
end

function OnVenusAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsVenusAcquired) then

		if hero:HasModifier("modifier_combo_window") then
			hero:RemoveModifierByName("modifier_combo_window")
		end
		
		hero.IsVenusAcquired = true
		UpgradeAttribute(hero, "ishtar_r", "ishtar_r_upgrade" , true)

		NonResetAbility(hero)
		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnGemsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGemsAcquired) then

		if hero:HasModifier("modifier_ishtar_combo_window") then
			hero:RemoveModifierByName("modifier_ishtar_combo_window")
		end
		
		hero.IsGemsAcquired = true
		hero:FindAbilityByName("ishtar_d"):SetLevel(2)

		NonResetAbility(hero)
		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnOfferingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsOfferingAcquired) then
		
		hero.IsOfferingAcquired = true
		hero:FindAbilityByName("ishtar_passive_gem_gain"):SetLevel(2)

		NonResetAbility(hero)
		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnGoddessAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGoddessAcquired) then

		hero.IsGoddessAcquired = true
		hero:AddAbility("ishtar_passive")
		hero:FindAbilityByName("ishtar_passive"):SetLevel(2)

		NonResetAbility(hero)
		-- UpgradeAttribute(hero, "kinghassan_azrael", "kinghassan_azrael_upgraded", true)
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end