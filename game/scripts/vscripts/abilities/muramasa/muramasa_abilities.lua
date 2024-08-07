function OnChant(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local chant_duration = ability:GetSpecialValueFor("chant_duration")
	local marble_duration = ability:GetSpecialValueFor("marble_duration")
	local cd_reduce = ability:GetSpecialValueFor("cd_reduce")

	if not (caster.IsBlazeAcquired) then
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", duration + 0.15)
	else
		if(caster.IsTameshiAcquired) then
			local ability_r = caster:FindAbilityByName("muramasa_r_upgrade")
			local cd = ability_r:GetCooldownTimeRemaining()
			ability_r:EndCooldown()
			ability_r:StartCooldown(cd - cd_reduce)
		else
			local ability_r = caster:FindAbilityByName("muramasa_r")
			local cd = ability_r:GetCooldownTimeRemaining()
			ability_r:EndCooldown()
			ability_r:StartCooldown(cd - cd_reduce)
		end
	end

	local particleeff1 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_flame_cloak_takeoff.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particleeff1, 1, caster:GetAbsOrigin())

	if caster:HasModifier("modifier_muramasa_chant") then
		local stack = caster:GetModifierStackCount("modifier_muramasa_chant", caster) or 0
		if stack == 2 then
			caster:RemoveModifierByName("modifier_muramasa_chant")

			if(caster.IsBlazeAcquired) then
			else
				StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_5, rate=1})
			end

			--marble here
	   		ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_marble", {})

			local particleeff1 = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_shockwave.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin())

			if(caster.CurrentChant == 1) then
    			caster:EmitSound("Muramasa.Q4")
			else
    			caster:EmitSound("Muramasa.Q4-2")
			end
		else
			local stack = caster:GetModifierStackCount("modifier_muramasa_chant", caster) or 0
			--chant here
			if(caster.CurrentChant == 1) then
				if(stack == 0) then
    				caster:EmitSound("Muramasa.Q2")
				else 
    				caster:EmitSound("Muramasa.Q3")
				end
			else
				if(stack == 0) then
    				caster:EmitSound("Muramasa.Q2-2")
				else 
    				caster:EmitSound("Muramasa.Q3-2")
				end
			end

			if(caster.IsBlazeAcquired) then
			else
				StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
			end

	    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_chant", {})
			caster:SetModifierStackCount("modifier_muramasa_chant", caster, stack + 1)
		end
	else
		caster.CurrentChant = math.random(1,2)

		if(caster.IsBlazeAcquired) then
		else
			StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
		end


		local stack = caster:GetModifierStackCount("modifier_muramasa_chant", caster) or 0
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_chant", {})

		if(caster.CurrentChant == 1) then
    			caster:EmitSound("Muramasa.Q1")
		else
    			caster:EmitSound("Muramasa.Q1-2")
		end
	end
end

function OnBuffSelf(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability

	local particleeff1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particleeff1, 1, caster:GetAbsOrigin())

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_unsheathe", {})
	caster:EmitSound("Muramasa.Buff" ..math.random(1,3))

	MuramasaCheckCombo(caster,ability)
end

function OnE(keys)
	local caster = keys.caster
	local ability = keys.ability
	local aftershock_damage = ability:GetSpecialValueFor("aftershock_damage")
	local damage = ability:GetSpecialValueFor("damage")
	local aoe = ability:GetSpecialValueFor("aoe")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local aftershock_delay = ability:GetSpecialValueFor("aftershock_delay")
	local stun = ability:GetSpecialValueFor("stun")
	local targetpoint = ability:GetCursorPosition()

	local ability_d = caster:FindAbilityByName("muramasa_d")
	local bonus_e_damage_passive = ability_d:GetSpecialValueFor("bonus_e_damage_passive")

	StartAnimation(caster, {duration=cast_delay + 0.1, activity=ACT_DOTA_CAST_ABILITY_1, rate=2})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.1)

    Timers:CreateTimer(cast_delay + 0.1, function()
		if caster:IsAlive() then	
			StartAnimation(caster, {duration=cast_delay + 0.1, activity=ACT_DOTA_ATTACK_EVENT, rate=1.2})
			local fRange = ability:GetSpecialValueFor("range")
		 	AbilityBlink(caster,targetpoint, fRange, {})

		 	local newpos = caster:GetAbsOrigin()

			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:EmitSound("Muramasa.E" .. math.random(1,3))
			EmitSoundOnLocationWithCaster(newpos, "Muramasa.EPop1" , caster)

			local particleeff1 = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient_hit.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin())
			local particleeff2 = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particleeff2, 0, caster:GetAbsOrigin())

			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			       	DoDamage(caster, v, damage + bonus_e_damage_passive , DAMAGE_TYPE_MAGICAL, 0, ability, false)	  
					v:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		       	end
		    end

		    if caster:HasModifier("modifier_muramasa_marble") then
   				Timers:CreateTimer(aftershock_delay, function()
					local particleeff3 = ParticleManager:CreateParticle("particles/econ/items/ursa/ursa_ti10/ursa_ti10_earthshock_energy_center.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(particleeff3, 0, newpos)
					local particleeff4 = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue_shockwave.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(particleeff4, 0, newpos)
					local particleeff5 = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_sfm_ink_swell_reveal_shockwave.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(particleeff5, 0, newpos)

					EmitSoundOnLocationWithCaster(newpos, "Muramasa.EPop2" , caster)

					local targets = FindUnitsInRadius(caster:GetTeam(), newpos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
					for k,v in pairs(targets) do
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					       	DoDamage(caster, v, aftershock_damage  , DAMAGE_TYPE_MAGICAL, 0, ability, false)	       	
				       	end
				    end
   				end)
			end

		end
	end)
end

function OnRCheck(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_muramasa_combo") then
		return
	end

	if not caster:HasModifier("modifier_muramasa_marble")then
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "No Marble")
    end
end

function OnR(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage_pure = ability:GetSpecialValueFor("damage_pure")
	local damage_magical = ability:GetSpecialValueFor("damage_magical")
	local delay_explosion = ability:GetSpecialValueFor("delay_explosion")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local width = ability:GetSpecialValueFor("width")
	local range = ability:GetSpecialValueFor("range")
	local targetpoint = ability:GetCursorPosition()
	local startpoint = caster:GetAbsOrigin()
	local silence = ability:GetSpecialValueFor("silence")

	StartAnimation(caster, {duration=cast_delay , activity=ACT_DOTA_ATTACK2, rate=2})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.1)

	if caster:HasModifier("modifier_muramasa_combo") then
		EmitGlobalSound("Muramasa.ComboR")
	else
		if(caster.CurrentChant == 1) then
			EmitGlobalSound("Muramasa.R")
		else
			EmitGlobalSound("Muramasa.R2")
		end
	end

	caster.CurrentChant = math.random(1,2)

	if caster:HasModifier("modifier_muramasa_marble") or caster.IsTameshiAcquired or caster:HasModifier("modifier_muramasa_combo") then
		if not caster:HasModifier("modifier_muramasa_combo") then
			if(caster.IsTameshiAcquired) and not caster:HasModifier("modifier_muramasa_marble") then
				local max_health_cost = ability:GetSpecialValueFor("max_health_cost")
				local damage_penalty = ability:GetSpecialValueFor("damage_penalty")

				DoDamage(caster,caster, caster:GetHealth() * 21 / 100, DAMAGE_TYPE_PURE, 0 , ability, false)

				damage_pure = damage_pure * (100 - damage_penalty) / 100
				damage_magical = damage_magical * (100 - damage_penalty) / 100
			else
				local damage_bonus_marble = ability:GetSpecialValueFor("damage_bonus_marble")
				caster:RemoveModifierByName("modifier_muramasa_marble")
				damage_pure = damage_pure * (100 + damage_bonus_marble) / 100
				damage_magical = damage_magical * (100 + damage_bonus_marble) / 100
			end
		else
			local ability_combo = caster:FindAbilityByName("muramasa_combo")
			local ult_cd = ability_combo:GetSpecialValueFor("ult_cd")
			local range_bonus = ability_combo:GetSpecialValueFor("range_bonus")

			range = range + range_bonus

			if(ability:IsCooldownReady()) then
			else
				ability:EndCooldown()
				ability:StartCooldown(ult_cd)
			end
		end
	end

	--check range here
	local dist = (targetpoint - startpoint):Length2D()
	if(dist < range) then
		local extend = range - dist
		local dirvec = (targetpoint - startpoint):Normalized()
    	targetpoint = targetpoint + dirvec * extend
	end

    Timers:CreateTimer(cast_delay , function()
		if caster:IsAlive() then	
			EmitGlobalSound("Muramasa.RSFX1")
			EmitGlobalSound("Muramasa.RSFX2")
			EmitGlobalSound("Muramasa.RSFX3")
			EmitGlobalSound("Muramasa.RSFX4")
			EmitGlobalSound("Muramasa.RSFX5")

			if(caster.IsKarmicAcquired) then
				if(caster:FindAbilityByName("muramasa_f"):IsCooldownReady()) then
					damage_pure = damage_pure + caster:FindAbilityByName("muramasa_f"):GetSpecialValueFor("bonus_pure_damage")
					SetKarmicCooldown(keys)
				end
			end

			local particleeff = ParticleManager:CreateParticle("particles/muramasa/muramasa_ult/muramasar.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particleeff, 0, startpoint)
			ParticleManager:SetParticleControl(particleeff, 1, targetpoint)

			local swordcreation = false
			local units = FindUnitsInLine(caster:GetTeam(), startpoint, targetpoint, caster, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
			for k,v in pairs(units) do 
				if (swordcreation == false) then
					if(caster:HasModifier("modifier_muramasa_combo")) then
						local ability_combo = caster:FindAbilityByName("muramasa_combo")
						local sword_duration = ability_combo:GetSpecialValueFor("sword_duration")
						local targetdummy = CreateUnitByName("dummy_unit", v:GetAbsOrigin() , false, caster, caster, caster:GetTeamNumber())
						targetdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
						targetdummy:AddNewModifier(caster, nil, "modifier_phased", {Duration=sword_duration})
						targetdummy:AddNewModifier(caster, nil, "modifier_kill", {Duration=sword_duration})
						ability_combo:ApplyDataDrivenModifier(caster, targetdummy, "modifier_muramasa_sword", {Duration=sword_duration})
						swordcreation = true
					end
				end

				if(caster.IsTameshiAcquired) then
					if((v:GetName() == "npc_dota_hero_lina" and v:HasModifier("modifier_aestus_domus_aurea_nero")) or (v:GetName() == "npc_dota_hero_ember_spirit" and v:HasModifier("modifier_unlimited_bladeworks")) or (v:GetName() == "npc_dota_hero_chen" and v:HasModifier("modifier_army_of_the_king_death_checker"))) then
						local bonus_isekai = ability:GetSpecialValueFor("bonus_isekai")
						DoDamage(caster, v, damage_pure * (100+bonus_isekai) / 100 , DAMAGE_TYPE_PURE, 0, ability, false) 		
						giveUnitDataDrivenModifier(caster, v, "silenced", silence)
						v:AddNewModifier(caster, ability, "modifier_silence", {Duration = silence})
						ability:ApplyDataDrivenModifier(caster, v, "modifier_muramasa_r_slow", {})
					else
						DoDamage(caster, v, damage_pure , DAMAGE_TYPE_PURE, 0, ability, false) 	
						giveUnitDataDrivenModifier(caster, v, "silenced", silence)
						v:AddNewModifier(caster, ability, "modifier_silence", {Duration = silence})
						ability:ApplyDataDrivenModifier(caster, v, "modifier_muramasa_r_slow", {})

					end
				else
					DoDamage(caster, v, damage_pure , DAMAGE_TYPE_PURE, 0, ability, false) 	
					giveUnitDataDrivenModifier(caster, v, "silenced", silence)
					v:AddNewModifier(caster, ability, "modifier_silence", {Duration = silence})
					ability:ApplyDataDrivenModifier(caster, v, "modifier_muramasa_r_slow", {})
				end
			end

				Timers:CreateTimer(delay_explosion, function()

				local particleeff = ParticleManager:CreateParticle("particles/muramasa/muramasa_ult/muramasar-blast.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl(particleeff, 0, startpoint)
				ParticleManager:SetParticleControl(particleeff, 1, targetpoint)

				EmitGlobalSound("Muramasa.RPop")

				local units = FindUnitsInLine(caster:GetTeam(), startpoint, targetpoint, caster, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
				for k,v in pairs(units) do 
					if(caster.IsTameshiAcquired) then
						if((v:GetName() == "npc_dota_hero_lina" and v:HasModifier("modifier_aestus_domus_aurea_nero")) or (v:GetName() == "npc_dota_hero_ember_spirit" and v:HasModifier("modifier_unlimited_bladeworks")) or (v:GetName() == "npc_dota_hero_chen" and v:HasModifier("modifier_army_of_the_king_death_checker"))) then
							local bonus_isekai = ability:GetSpecialValueFor("bonus_isekai")
							DoDamage(caster, v, damage_magical * (100+bonus_isekai) / 100 , DAMAGE_TYPE_MAGICAL, 0, ability, false) 	
						else
							DoDamage(caster, v, damage_magical , DAMAGE_TYPE_MAGICAL, 0, ability, false) 		
						end
					else
						DoDamage(caster, v, damage_magical , DAMAGE_TYPE_MAGICAL, 0, ability, false) 		
					end		
				end
			end)
		end
	end)
end

function OnSwordCreate(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    target.SwordParticle = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_sword2.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(target.SwordParticle, 0, target:GetAbsOrigin())
    target.SwordParticle2 = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_sword2_pop.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(target.SwordParticle2, 0, target:GetAbsOrigin())
end

function OnSwordThink(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local sword_mana_recovery = ability:GetSpecialValueFor("sword_mana_recovery")
    local sword_get_range = ability:GetSpecialValueFor("sword_get_range")

	local casterToTargetDistance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
    if casterToTargetDistance < sword_get_range then

        if caster.IsTameshiAcquired then
            caster:FindAbilityByName("muramasa_r_upgrade"):EndCooldown()
        else
            caster:FindAbilityByName("muramasa_r"):EndCooldown()
        end

        caster:EmitSound("Muramasa.SwordPick")
        caster:EmitSound("Muramasa.SwordPick2")

    	Timers:CreateTimer(0.1, function()
        caster:EmitSound("Muramasa.SwordPick3")
        end)
		local particleeff = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_sword_pickup.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())

    	caster:GiveMana(sword_mana_recovery)
        target:RemoveModifierByName("modifier_muramasa_sword")
    end
end

function OnSwordDestroy(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    if target.SwordParticle then
        ParticleManager:DestroyParticle(target.SwordParticle, true)
        ParticleManager:ReleaseParticleIndex(target.SwordParticle)
        target.SwordParticle = nil
    end
end

function OnCombo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = ability:GetSpecialValueFor("damage")
    local chant_duration = ability:GetSpecialValueFor("chant_duration")

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", chant_duration)
    StartAnimation(caster, {duration=chant_duration, activity=ACT_DOTA_CAST_ABILITY_5, rate=1})
    Timers:CreateTimer(0.7, function()
        FreezeAnimation(caster,chant_duration-1)
    end)

    EmitGlobalSound("Muramasa.Combo")
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_combo_cooldown", {Duration = ability:GetCooldown(1)})
    caster:RemoveModifierByName("modifier_combo_window")

    local particleeff1 = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff1, 0, caster:GetAbsOrigin())

    local swords = {}  -- Create an empty table to store particle effects

    for i = 1, chant_duration - 1 do
        Timers:CreateTimer(RandomFloat(0.4, 0.8) * i, function()
            local swordpoint = caster:GetAbsOrigin() + Vector(RandomInt(-600, 600), RandomInt(-600, 600), RandomInt(15, 40))
            local swordParticle = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_sword.vpcf", PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControl(swordParticle, 0, swordpoint)
            ParticleManager:SetParticleControl(swordParticle, 1, caster:GetAbsOrigin())
            table.insert(swords, swordParticle)  -- Add the particle effect to the table
        end)
    end

    for i = 1, 5 do
        Timers:CreateTimer(RandomFloat(1.5, 1.5) * i, function()
            local swordpoint = caster:GetAbsOrigin()
            local swordParticle = ParticleManager:CreateParticle("particles/muramasa/muramasa_combo_anvil_smash.vpcf", PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControl(swordParticle, 0, swordpoint)
            ParticleManager:SetParticleControl(swordParticle, 1, caster:GetAbsOrigin())
    		EmitGlobalSound("Muramasa.Anvil" .. math.random(1,6))
    		EmitGlobalSound("Muramasa.AnvilEcho" .. math.random(1,2))
        end)
    end

    Timers:CreateTimer(chant_duration + 0.2, function()
        ParticleManager:DestroyParticle(particleeff1, true)
        ParticleManager:ReleaseParticleIndex(particleeff1)

    	EmitGlobalSound("Muramasa.ComboPop5")

        local landingParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(landingParticle, 0, caster:GetAbsOrigin())

        ability:ApplyDataDrivenModifier(caster, caster, "modifier_muramasa_combo", {})

	    --EmitGlobalSound("Muramasa.DrawswordF")

        if caster.IsTameshiAcquired then
            caster:FindAbilityByName("muramasa_r_upgrade"):EndCooldown()
        else
            caster:FindAbilityByName("muramasa_r"):EndCooldown()
        end

        -- Clean up the stored sword particles
        for _, swordParticle in pairs(swords) do
            ParticleManager:DestroyParticle(swordParticle, true)
            ParticleManager:ReleaseParticleIndex(swordParticle)
        end
    end)
end

function OnQMarble(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local swords = ability:GetSpecialValueFor("swords")
	local range = ability:GetSpecialValueFor("range")
	local radius = ability:GetSpecialValueFor("radius")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local front = caster:GetForwardVector()

	StartAnimation(caster, {duration=cast_delay + 0.1, activity=ACT_DOTA_CAST_ABILITY_2, rate=2})

    Timers:CreateTimer(cast_delay + 0.5, function()
    	caster:EmitSound("Muramasa.QMarbleCast")

		for i = 1, swords do
    		Timers:CreateTimer(RandomFloat(0.05,0.15) * i, function()
				local vOrigin = caster:GetAbsOrigin() + Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), RandomInt(15,40))

				local gobWeapon = 
				{
					Ability = ability,
			        EffectName = "particles/muramasa/muramasa_sword_model.vpcf",
			        vSpawnOrigin = vOrigin,
			        fDistance = range + 100,
			        fStartRadius = 100,
			        fEndRadius = 100,
			        Source = caster,
			        bHasFrontalCone = false,
			        bReplaceExisting = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			        fExpireTime = GameRules:GetGameTime() + 1.5,
					bDeleteOnHit = true,
					vVelocity = front * 2500
				}

				ProjectileManager:CreateLinearProjectile(gobWeapon)
			end)
		end
    end)
end

function OnQMarbleHit(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")

	local ability_d = caster:FindAbilityByName("muramasa_d")
	local bonus_damage = ability_d:GetSpecialValueFor("bonus_tengu_damage_passive")

	DoDamage(caster, target, damage + bonus_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	target:EmitSound("Muramasa.QHit" .. math.random(1,3))
end

function OnQUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local hero = caster.HeroUnit

	caster:FindAbilityByName("muramasa_tengu"):SetLevel(ability:GetLevel())
end

function OnMarbleStart(keys)
	local caster = keys.caster
	if(caster.IsBlazeAcquired) then
		caster:SwapAbilities("muramasa_chant_upgrade", "muramasa_tengu", false, true)
	else
		caster:SwapAbilities("muramasa_chant", "muramasa_tengu", false, true)
	end
end

function OnMarbleEnd(keys)
	local caster = keys.caster
	if(caster.IsBlazeAcquired) then
	caster:SwapAbilities("muramasa_tengu", "muramasa_chant_upgrade", false, true)

	else
	caster:SwapAbilities("muramasa_tengu", "muramasa_chant", false, true)
	end
end

function SetKarmicCooldown(keys)
	local caster = keys.caster
	local ability_f = caster:FindAbilityByName("muramasa_f")
	ability_f:StartCooldown(ability_f:GetCooldown(ability_f:GetLevel()))
end

function OnKarmicKill(keys)
	local caster = keys.caster
	local ability_f = caster:FindAbilityByName("muramasa_f")
	local cd_reduce_on_kill = ability_f:GetSpecialValueFor("cd_reduce_on_kill")
	local ability_r = keys.ability
	local target = keys.unit

	if target:IsHero() then
		if(caster.IsTameshiAcquired) then
			local ability_r = caster:FindAbilityByName("muramasa_r_upgrade")
			local cd = ability_r:GetCooldownTimeRemaining()
			ability_r:EndCooldown()
			ability_r:StartCooldown(cd - cd_reduce_on_kill)
		else
			local ability_r = caster:FindAbilityByName("muramasa_r")
			local cd = ability_r:GetCooldownTimeRemaining()
			ability_r:EndCooldown()
			ability_r:StartCooldown(cd - cd_reduce_on_kill)
		end

		ability_f:EndCooldown()
	end
end

function OnPrideSA(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPrideAcquired) then

		hero.IsPrideAcquired = true
		hero:FindAbilityByName("muramasa_d"):SetLevel(2)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKarmicSA(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKarmicAcquired) then

		hero.IsKarmicAcquired = true

		UpgradeAttribute(hero, "fate_empty1", "muramasa_f", true)
		hero:FindAbilityByName("muramasa_f"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end


function OnTameshiSA(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTameshiAcquired) and not hero:HasModifier("modifier_muramasa_combo") then

		if hero:HasModifier("modifier_combo_window") then 
			hero:RemoveModifierByName("modifier_combo_window")
		end
		if hero:HasModifier("modifier_muramasa_combo") then 
			hero:RemoveModifierByName("modifier_muramasa_combo")
		end

		hero.IsTameshiAcquired = true

		UpgradeAttribute(hero, "muramasa_r", "muramasa_r_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBlazeSA(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBlazeAcquired) and not hero:HasModifier("modifier_muramasa_combo") then

		if hero:HasModifier("modifier_combo_window") then 
			hero:RemoveModifierByName("modifier_combo_window")
		end
		if hero:HasModifier("modifier_muramasa_combo") then 
			hero:RemoveModifierByName("modifier_muramasa_combo")
		end
		if hero:HasModifier("modifier_muramasa_chant") then 
			hero:RemoveModifierByName("modifier_muramasa_chant")
		end
		if hero:HasModifier("modifier_muramasa_marble") then 
			hero:RemoveModifierByName("modifier_muramasa_marble")
		end

		hero.IsBlazeAcquired = true

		UpgradeAttribute(hero, "muramasa_chant", "muramasa_chant_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function MuramasaCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if string.match(ability:GetAbilityName(), "muramasa_d") and not caster:HasModifier("modifier_muramasa_combo_cooldown") and not caster:HasModifier("modifier_muramasa_chant") and not caster:HasModifier("modifier_muramasa_marble") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 5})
		end
    end
end

function OnComboWindow(keys)
	local caster = keys.caster
	if(caster.IsBlazeAcquired) then
		caster:SwapAbilities("muramasa_chant_upgrade", "muramasa_combo", false, true)
	else
		caster:SwapAbilities("muramasa_chant", "muramasa_combo", false, true)
	end
end

function OnComboWindowBroken(keys)
	local caster = keys.caster
	if(caster.IsBlazeAcquired) then
		caster:SwapAbilities("muramasa_combo", "muramasa_chant_upgrade", false, true)
	else
		caster:SwapAbilities("muramasa_combo", "muramasa_chant", false, true)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_combo_window")
end
