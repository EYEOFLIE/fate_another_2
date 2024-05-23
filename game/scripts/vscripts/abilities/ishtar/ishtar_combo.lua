LinkLuaModifier("modifier_ishtar_combo_cooldown", "abilities/ishtar/ishtar_combo", LUA_MODIFIER_MOTION_NONE)

modifier_ishtar_combo_cooldown = class({})
function modifier_ishtar_combo_cooldown:RemoveOnDeath()
	return false 
end
function modifier_ishtar_combo_cooldown:IsDebuff()
	return true
end
function modifier_ishtar_combo_cooldown:IsHidden()
	return false
end


ishtar_combo = class({})
function ishtar_combo:GetVectorTargetRange()
	local ability = self
	local arrow_range = ability:GetSpecialValueFor("arrow_range")
	return arrow_range
end

function ishtar_combo:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
end

function ishtar_combo:OnVectorCastStart(vStartLocation, vDirection)
	local caster = self:GetCaster()
	local ability = self
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local speed = ability:GetSpecialValueFor("speed")
	local arrow_range = ability:GetSpecialValueFor("arrow_range")

	local portal_location = ability:GetVectorPosition()
	local target_location = vStartLocation + vDirection * arrow_range
	local cast_location = caster:GetAbsOrigin()

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 0.2)

	local portal1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/portal/ishtar_portal.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(portal1, 0, cast_location + Vector(100,0,0))	

	caster:MoveToPosition(caster:GetAbsOrigin() + Vector(150,0,0))

	caster:RemoveModifierByName("modifier_ishtar_combo_window")
	caster:AddNewModifier(caster, self, "modifier_ishtar_combo_cooldown", {duration = self:GetCooldown(1)})

	EmitGlobalSound("Ishtar.ComboStart")

    Timers:CreateTimer(0.3, function()
		if caster:IsAlive() then
			local portal2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/portal/ishtar_portal.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(portal2, 0, portal_location + Vector(100,0,700))	
		end
	end)

    Timers:CreateTimer(1, function()

		giveUnitDataDrivenModifier(caster, caster, "jump_pause", 2.4)
		if caster:IsAlive() then
		caster:SetAbsOrigin(portal_location + Vector(0,0,700))
		EmitGlobalSound("Ishtar.ComboTeleport")
		    Timers:CreateTimer(0.4, function()
				caster:SetForwardVector(vDirection)
			end)
		end
	end)

    Timers:CreateTimer(1.7, function()
		if caster:IsAlive() then
		EmitGlobalSound("Ishtar.Combo2")
		end
	end)

    Timers:CreateTimer(2.1, function()
		if caster:IsAlive() then
		StartAnimation(caster, {duration=2, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.5})

		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())

		local particleeffhand = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_buff.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particleeffhand, 0, caster:GetAbsOrigin() + Vector(0,0,160))	
		EmitGlobalSound("Ishtar.RComboChargeSFXOuter")
		end
	end)


    Timers:CreateTimer(1.6, function()
	end)

    Timers:CreateTimer(2.6, function()
		if caster:IsAlive() then
		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 2, caster:GetAbsOrigin())
		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 2, caster:GetAbsOrigin())    	
		end

		EmitGlobalSound("Ishtar.ComboLaunch")

    	Timers:CreateTimer(0.2, function()
			EmitGlobalSound("Ishtar.ComboCharging")
		end)
	end)

    Timers:CreateTimer(3.7, function()
		if caster:IsAlive() then

		EmitGlobalSound("Ishtar.ComboJabalLaunch")

		EmitGlobalSound("Ishtar.Shoot")
		EmitGlobalSound("Ishtar.ComboShoot")
		EmitGlobalSound("Ishtar.ComboShoot2")


		local targetdummy = CreateUnitByName("dummy_unit", target_location , false, caster, caster, caster:GetTeamNumber())
		targetdummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
		targetdummy:AddNewModifier(caster, nil, "modifier_phased", {duration=9})
		targetdummy:AddNewModifier(caster, nil, "modifier_kill", {duration=9})

		local projectile = {
	    	Target = targetdummy,
			Source = caster,
			Ability = ability,	
        	EffectName = "particles/ishtar/ishtar_combo/projectile/ishtar_projectile_main_main.vpcf",
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


    	Timers:CreateTimer(0.3, function()
			local portalex = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(portalex, 2, caster:GetAbsOrigin())	

			caster:SetAbsOrigin(cast_location)
			EmitGlobalSound("Ishtar.ComboTeleport")

			local p = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(p, 2, cast_location)	
		end)
    end)

end

function ishtar_combo:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
	local ability = self
	local caster = ability:GetCaster()
	local impact_radius = ability:GetSpecialValueFor("impact_radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_per_gem = ability:GetSpecialValueFor("damage_per_gem")

	EmitGlobalSound("Ishtar.ComboImpact1")
	EmitGlobalSound("Ishtar.ComboImpact2")
	EmitGlobalSound("Ishtar.ComboImpact3")
	EmitGlobalSound("Ishtar.ComboImpact4")
	Timers:CreateTimer(0.23, function()
		EmitGlobalSound("Ishtar.ComboImpactOuter")
	end)

	stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	damage = damage + stack * damage_per_gem

	local targets = FindUnitsInRadius(caster:GetTeam(), hTarget:GetAbsOrigin(), nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	       	DoDamage(caster, v ,damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)	       	
       	end
    end

	local dps = ability:GetSpecialValueFor("dps")
	local dps_duration = ability:GetSpecialValueFor("dps_duration")

	for i=0.25,dps_duration do
		Timers:CreateTimer(i, function()
			local targets = FindUnitsInRadius(caster:GetTeam(), hTarget:GetAbsOrigin(), nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			       	DoDamage(caster, v ,dps/4 , DAMAGE_TYPE_MAGICAL, 0, ability, false)	  
			    end     	
		    end
		end)
	end

    local pcExplosion = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/impact/ishtar_combo_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:SetParticleControl(pcExplosion, 0, hTarget:GetAbsOrigin())
end