function OnBirdSummon(keys)
	local caster = keys.caster
	local targetpoint = keys.ability:GetCursorPosition()
	local duration = keys.ability:GetSpecialValueFor("duration")

	local bird = CreateUnitByName("semiramis_bird", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())	
	bird:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
	bird:AddNewModifier(caster, nil, "modifier_kill", {duration = 14})
	bird:SetOwner(caster)
	FindClearSpaceForUnit(bird, bird:GetAbsOrigin(), true)

   	caster:EmitSound("Semi.GardenDove")
   	
	Timers:CreateTimer(0.05, function()
		bird:MoveToPosition(targetpoint)
	end)
end

function GardenCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if caster:HasModifier("modifier_semiramis_mounted") then
		caster:RemoveModifierByName("modifier_semiramis_mounted")
	end
end

function OnLaserThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local targets = ability:GetSpecialValueFor("targets")
	local radius = ability:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	if enemies == nil then return end

	if IsValidEntity(caster) and caster:IsAlive() then
		local count = 1
		for k,v in pairs(enemies) do
			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				if count <= targets then
					DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

					local beamFx = ParticleManager:CreateParticle("particles/semiramis/beam_barrage.vpcf", PATTACH_WORLDORIGIN, caster)
					ParticleManager:SetParticleControl(beamFx, 9, caster:GetAbsOrigin() + Vector(0,0,200))
					ParticleManager:SetParticleControl(beamFx, 1, v:GetAbsOrigin())

			   		v:EmitSound("Semi.CasterESFX")

					count = count + 1
				end
			end	
		end
	end
end

function OnPoisonousBite(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local duration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_burst = ability:GetSpecialValueFor("damage_burst")
	local stay_range = ability:GetSpecialValueFor("stay_range")
	local radius = ability:GetSpecialValueFor("radius")
	local stay_dmg = ability:GetSpecialValueFor("stay_dmg") / 100
	local out_dmg = ability:GetSpecialValueFor("out_dmg") / 100

   	caster:EmitSound("Semi.AssassinR")

	Timers:CreateTimer(cast_delay - ability:GetCastPoint(), function()
		if caster:IsAlive() then
		   	target:EmitSound("Semi.AssassinRSFX")
		   	target:EmitSound("Semi.AssassinRSFX2")

			local particle = ParticleManager:CreateParticle("particles/semiramis/basmu_claw_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

			local particlewound = ParticleManager:CreateParticle("particles/custom/semiramis/open_wounds.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particlewound, 0, target:GetAbsOrigin())

			local dmg_flag = 0
			if caster.IsCharmAcquired and target:IsRealHero() and not IsFemaleServant(target) and target:GetName() ~= "npc_dota_hero_queenofpain" then 
				local bonus_male = ability:GetSpecialValueFor("bonus_male")
				damage = damage + bonus_male
			end

		   	if caster.IsOldestPoisonerAcquired then
				local damage_per_agi = ability:GetSpecialValueFor("damage_per_agi")
				damage = damage + (damage_per_agi * caster:GetAgility())
				local burst_per_int = ability:GetSpecialValueFor("burst_per_int")
				damage_burst = damage_burst + (burst_per_int * caster:GetIntellect())
			end

		   	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)

			ability:ApplyDataDrivenModifier(caster, target, "modifier_semiramis_poisonous_bite_debuff", {})

			Timers:CreateTimer(duration, function()

				ParticleManager:DestroyParticle(particlewound, true )

				if caster:IsAlive() then
					local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
					if(distance <= stay_range) then

					   	target:EmitSound("Semi.AssassinRSFXPop")
					   	target:EmitSound("Semi.AssassinRSFXPop2")

						local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
						for k,v in pairs(enemies) do
							if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
								DoDamage(caster, v, damage_burst * stay_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
								ability:ApplyDataDrivenModifier(caster, v, "modifier_semiramis_poisonous_bite_debuff", {})
							end	
						end

						local particle = ParticleManager:CreateParticle("particles/custom/semiramis/basmu_poison_d.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
						ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, 0))
					else
						DoDamage(caster, target, damage_burst * out_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
				end
			end)
		end
	end)
end

function OnLevelupQCas(keys)
	local caster = keys.caster
	local ability = keys.ability
	if string.match(ability:GetAbilityName(), "binding_chains") then
		if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_presence_concealment"):GetLevel() then
			caster:FindAbilityByName("semiramis_presence_concealment"):SetLevel(ability:GetLevel())
		end
	else
		if ability:GetLevel() ~= caster:FindAbilityByName(caster.QSkill):GetLevel() then
			caster:FindAbilityByName(caster.QSkill):SetLevel(ability:GetLevel())
		end
	end
end

function OnLevelupWCas(keys)
	local caster = keys.caster
	local ability = keys.ability
	if string.match(ability:GetAbilityName(), "semiramis_barrier") then
		if caster.IsOldestPoisonerAcquired then
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_snek_spit_poison_upgrade"):GetLevel() then
				caster:FindAbilityByName("semiramis_snek_spit_poison_upgrade"):SetLevel(ability:GetLevel())
			end
		else
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_snek_spit_poison"):GetLevel() then
				caster:FindAbilityByName("semiramis_snek_spit_poison"):SetLevel(ability:GetLevel())
			end
		end
	else
		if ability:GetLevel() ~= caster:FindAbilityByName(caster.WSkill):GetLevel() then
			caster:FindAbilityByName(caster.WSkill):SetLevel(ability:GetLevel())
		end
	end
end

function OnLevelupECas(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetLevel() ~= caster:FindAbilityByName(caster.ESkill):GetLevel() then
		caster:FindAbilityByName(caster.ESkill):SetLevel(ability:GetLevel())
	end
end

function OnLevelupRCas(keys)
	local caster = keys.caster
	local ability = keys.ability

	if string.match(ability:GetAbilityName(), "semiramis_hanging_gardens") then
		if caster.IsOldestPoisonerAcquired and caster.IsCharmAcquired then
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_bite_upgrade"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_bite_upgrade"):SetLevel(ability:GetLevel())
			end
		elseif not caster.IsOldestPoisonerAcquired and caster.IsCharmAcquired then
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_bite_charm"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_bite_charm"):SetLevel(ability:GetLevel())
			end
		elseif caster.IsOldestPoisonerAcquired and not caster.IsCharmAcquired then
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_bite_old"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_bite_old"):SetLevel(ability:GetLevel())
			end
		else
			if ability:GetLevel() ~= caster:FindAbilityByName("semiramis_poisonous_bite"):GetLevel() then
				caster:FindAbilityByName("semiramis_poisonous_bite"):SetLevel(ability:GetLevel())
			end
		end
	else
		if ability:GetLevel() ~= caster:FindAbilityByName(caster.RSkill):GetLevel() then
			caster:FindAbilityByName(caster.RSkill):SetLevel(ability:GetLevel())
		end
	end
end



function SemiramisChainsCast(keys)

	LinkLuaModifier("modifier_binding_chains", "abilities/semiramis/modifiers/modifier_binding_chains", LUA_MODIFIER_MOTION_NONE)

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local max_dur = ability:GetSpecialValueFor("max_dur")
	local min_dur = ability:GetSpecialValueFor("min_dur")
	local mr_red = ability:GetSpecialValueFor("mr_red")
	local bind_duration = 0

	local magic_res = target:GetBaseMagicalResistanceValue() / 100

	bind_duration = math.max(min_dur, max_dur * (1 - magic_res))

   	caster:EmitSound("Semi.CasterQ")
   	target:EmitSound("Semi.CasterQSFX")
   	target:EmitSound("Semi.CasterQSFX2")
	target:AddNewModifier(caster, ability, "modifier_binding_chains", { Duration = bind_duration, MagicResist =  mr_red })
	if caster.IsCharmAcquired and target:IsRealHero() and not IsFemaleServant(target) and target:GetName() ~= "npc_dota_hero_queenofpain" then
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = bind_duration})
	end
end

function OnBarrierStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local shield_amount = ability:GetSpecialValueFor("shield_amount")
	local max_shield = ability:GetSpecialValueFor("max_shield")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_semiramis_shield", {})

	caster.SemiShieldAmount = math.min(max_shield, (caster.SemiShieldAmount or 0) + shield_amount)

	UpdateBarriorUI(caster, "modifier_semiramis_shield", caster.SemiShieldAmount)

	
	--[[if caster.ShieldAmount == nil then 
		caster.ShieldAmount = keys.ShieldAmount
	else
		caster.ShieldAmount = caster.ShieldAmount + keys.ShieldAmount
	end
	if caster.ShieldAmount > keys.MaxShield then
		caster.ShieldAmount = keys.MaxShield
	end]]
	
   	caster:EmitSound("Semi.CasterW")
   	caster:EmitSound("Semi.CasterWSFX")

	-- Create particle
	--[[if caster.DurabilityParticleIndex == nil then
		local prev_amount = 0.0
		Timers:CreateTimer( function()
				-- Check if shield still valid
				if caster.ShieldAmount > 0 and caster:HasModifier( "modifier_semiramis_shield" ) then
					-- Check if it should update
					if prev_amount ~= caster.ShieldAmount then
						-- Change particle
						local digit = 0
						if caster.ShieldAmount > 999 then
							digit = 4
						elseif caster.ShieldAmount > 99 then
							digit = 3
						elseif caster.ShieldAmount > 9 then
							digit = 2
						else
							digit = 1
						end
						if caster.DurabilityParticleIndex ~= nil then
							-- Destroy previous
							ParticleManager:DestroyParticle( caster.DurabilityParticleIndex, true )
							ParticleManager:ReleaseParticleIndex( caster.DurabilityParticleIndex )
						end
						-- Create new one
						caster.DurabilityParticleIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_argos_durability.vpcf", PATTACH_CUSTOMORIGIN, caster )
						ParticleManager:SetParticleControlEnt( caster.DurabilityParticleIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
						ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 1, Vector( 0, math.floor( caster.ShieldAmount ), 0 ) )
						ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 2, Vector( 1, digit, 0 ) )
						ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 3, Vector( 100, 100, 255 ) )
						
						prev_amount = caster.ShieldAmount	
					end
					
					return 0.1
				else
					if caster.DurabilityParticleIndex ~= nil then
						ParticleManager:DestroyParticle( caster.DurabilityParticleIndex, true )
						ParticleManager:ReleaseParticleIndex( caster.DurabilityParticleIndex )
						caster.DurabilityParticleIndex = nil
					end
					return nil
				end
			end
		)
	end]]
end

function OnBarrierDamaged(keys)
	local caster = keys.caster 
	local currentHealth = caster:GetHealth() 

	caster.SemiShieldAmount = caster.SemiShieldAmount - keys.DamageTaken
	UpdateBarriorUI(caster, "modifier_semiramis_shield", caster.SemiShieldAmount)
	if caster.SemiShieldAmount <= 0 then
		if currentHealth + caster.SemiShieldAmount <= 0 then
		else
			caster:RemoveModifierByName("modifier_semiramis_shield")
			caster:SetHealth(currentHealth + keys.DamageTaken + caster.SemiShieldAmount)
			caster.SemiShieldAmount = 0
		end
	else
		caster:SetHealth(currentHealth + keys.DamageTaken)
	end
end

function OnBarrierThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName(caster.WSkill)
	end
	local regen = ability:GetSpecialValueFor("regen")
	local max_shield = ability:GetSpecialValueFor("max_shield")

	if not caster.IsAbsoluteAcquired and caster:HasModifier("modifier_semiramis_class_assassin") then 
		return 
	end

	if caster.SemiShieldAmount == nil then caster.SemiShieldAmount = 0 end
	
	if caster.SemiShieldAmount == max_shield then
		return
	end

	if caster.SemiShieldAmount <= 0 or not caster:HasModifier("modifier_semiramis_shield") then return end

	caster.SemiShieldAmount = math.min(max_shield, caster.SemiShieldAmount + regen)
	UpdateBarriorUI(caster, "modifier_semiramis_shield", caster.SemiShieldAmount)
	--[[if caster.ShieldAmount < keys.MaxShield then
		caster.ShieldAmount = caster.ShieldAmount + regen
		if caster.ShieldAmount > keys.MaxShield then
		caster.ShieldAmount = keys.MaxShield
		end
	end]]
end

--[[function UpdateBarriorUI(caster)
	if caster.DurabilityParticleIndex ~= nil then
		-- Destroy previous
		ParticleManager:DestroyParticle( caster.DurabilityParticleIndex, true )
		ParticleManager:ReleaseParticleIndex( caster.DurabilityParticleIndex )
	end
	if caster.ShieldAmount > 0 and caster:HasModifier( "modifier_semiramis_shield" ) then
		local digit = 0
		if caster.ShieldAmount > 999 then
			digit = 4
		elseif caster.ShieldAmount > 99 then
			digit = 3
		elseif caster.ShieldAmount > 9 then
			digit = 2
		else
			digit = 1
		end
		
		-- Create new one
		caster.DurabilityParticleIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_argos_durability.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControlEnt( caster.DurabilityParticleIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 1, Vector( 0, math.floor( caster.ShieldAmount ), 0 ) )
		ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 2, Vector( 1, digit, 0 ) )
		ParticleManager:SetParticleControl( caster.DurabilityParticleIndex, 3, Vector( 100, 100, 255 ) )
	end
end]]

function OnSnakePoisonStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local range = ability:GetSpecialValueFor("range")
	local aoe = ability:GetSpecialValueFor("aoe")
	local speed = 1500

   	caster:EmitSound("Semi.AssassinW")
   	caster:EmitSound("Semi.AssassinWSFX")
   	caster:EmitSound("Semi.AssassinWSFX2")

	local projectileTable = {
		EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
		Ability = ability,
		iMoveSpeed = speed,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = range,
		Source = caster,
		fStartRadius = aoe,
        fEndRadius = aoe,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + (range/speed) + 0.5,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end

function OnSnakePoisonHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 

	if target == nil then return end

	local damage = ability:GetSpecialValueFor("damage")
	if caster.IsOldestPoisonerAcquired then 
		local damage_per_agi = ability:GetSpecialValueFor("damage_per_agi")
		damage = damage + (damage_per_agi * caster:GetAgility())
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_semi_snek_poison", {})
	end
end

function OnSnakePoisonThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local dps = ability:GetSpecialValueFor("dps")

	DoDamage(caster, target, dps * 0.5, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
	local fx = ParticleManager:CreateParticle( "particles/econ/items/venomancer/veno_ti8_immortal_head/veno_ti8_immortal_gale_explosion_venom.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( fx, 3, target:GetAbsOrigin() + Vector(0,0, 120) )
	Timers:CreateTimer(0.3, function()
		ParticleManager:DestroyParticle(fx, true)
		ParticleManager:ReleaseParticleIndex(fx)
	end)
end

function OnRecallCreate(keys)
	local target = keys.target 
	local ability = keys.ability 

	target.RecallTimer = 0
	target.IsMRecallCanceled = false

	for k,v in pairs(keys) do
		print(k,v)
	end
end

function MassRecallThink(keys)
	local caster = keys.target
	local ability = keys.ability 

	caster.RecallTimer = caster.RecallTimer + 0.5
end

function OnRecallTakeDamage(keys)
	local target = keys.unit 
	local ability = keys.ability 

	if target:GetHealth() <= target:GetMaxHealth() / 2 then
		target.IsMRecallCanceled = true
		target:RemoveModifierByName("modifier_semiramis_mass_recall")
	end
end

function OnRecallDestroy(keys)
	local target = keys.target 
	local caster = keys.caster 
	local ability = keys.ability 
	local max_range = keys.MaxRange
	local delay = ability:GetSpecialValueFor("delay")

	if target.IsMRecallCanceled then
		return
	end

	if target.RecallTimer < delay then
		return
	end

	if IsInSameRealm(target:GetAbsOrigin() , caster:GetAbsOrigin()) then
		local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		if distance <= max_range then
			target:EmitSound("Semi.GardenMassTeleportPull")
			if caster:IsAlive() and target:IsAlive() then
				target:SetAbsOrigin(caster:GetAbsOrigin() + RandomVector(200))
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
			end
		end
	end
end

function OnMassRecallCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetLoc = ability:GetCursorPosition()
	local aoe = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("delay")

   	EmitGlobalSound("Semi.GardenMassTeleportCast")
   	
	local enemies = FindUnitsInRadius(caster:GetTeam(), targetLoc, nil, aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for k,v in pairs(enemies) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			if v == caster then
			else
    			ability:ApplyDataDrivenModifier(caster, v, "modifier_semiramis_mass_recall", {Duration = delay})
	    	end
	    end
	end
end



function OnClassSwap(keys)
	local caster = keys.caster
	local ability = keys.ability 
	
	if caster:HasModifier("modifier_dual_class_cooldown") then
		return 1
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dual_class_cooldown", {Duration = ability:GetCooldown(1)})

		if caster:HasModifier("modifier_combo_window") then 
			caster:RemoveModifierByName("modifier_combo_window")
		end

		if caster:HasModifier("modifier_semiramis_class_assassin")  then
			caster:RemoveModifierByName("modifier_semiramis_class_assassin")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_semiramis_class_caster", {})

			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)
		else
			caster:RemoveModifierByName("modifier_semiramis_class_caster")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_semiramis_class_assassin", {})
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "semiramis_presence_concealment", false, true)

			if caster.IsOldestPoisonerAcquired then
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "semiramis_snek_spit_poison_upgrade", false, true)
				caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "semiramis_poisonous_cloud_upgrade", false, true)
				if caster.IsCharmAcquired then
					caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "semiramis_poisonous_bite_upgrade", false, true)
				else
					caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "semiramis_poisonous_bite_old", false, true)
				end
			else
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "semiramis_snek_spit_poison", false, true)
				caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "semiramis_poisonous_cloud", false, true)
				if caster.IsCharmAcquired then
					caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "semiramis_poisonous_bite_charm", false, true)
				else
					caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), "semiramis_poisonous_bite", false, true)
				end
			end
		end
	end

end

function OnPassiveThink(keys)
	local caster = keys.caster
	local ability = keys.ability 

	caster:SetMana(caster:GetMana() + 1)
	-- body
end

function OnPresenceConcealmentDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_semiramis_presence_concealment")
end

function OnPresenceConcealmentStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_semiramis_presence_concealment", {})

    caster:EmitSound("KingHassan.WSFX")

	local particle = ParticleManager:CreateParticle("particles/econ/items/drow/drow_ti6/drow_ti6_silence_wave_ground_dust.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle,4, caster:GetAbsOrigin())		
	ParticleManager:SetParticleControl(particle,5, caster:GetAbsOrigin())		
end

function OnHangingGardensCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local quake_radius = ability:GetSpecialValueFor("quake_radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_radius = ability:GetSpecialValueFor("damage_radius")
	local targetpoint = ability:GetCursorPosition()

	local garden_health = ability:GetSpecialValueFor("garden_health")
	local garden_damage = ability:GetSpecialValueFor("garden_damage")
	local garden_movespeed = ability:GetSpecialValueFor("garden_movespeed")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay)

	ScreenShake(caster:GetOrigin(), 3, 0.2, 3.5, 4000, 0, true)

	local cracks = ParticleManager:CreateParticle( "particles/semiramis/hanging_garden_crack.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(cracks, 0, targetpoint)

	EmitGlobalSound("Semi.CasterR1")
	EmitGlobalSound("Semi.CasterR1SFX")


	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then

	   		EmitGlobalSound("Semi.CasterR2")
	   		EmitGlobalSound("Semi.CasterR2SFX")

			ParticleManager:DestroyParticle(cracks, true)
			ScreenShake(caster:GetOrigin(), 7, 0.3, 2.5, 4000, 0, true)

			local tEnemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, quake_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(tEnemies) do
				if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() and not IsImmuneToCC(v) then
					ability:ApplyDataDrivenModifier(caster,v, "modifier_semiramis_babylon_quake",{})
				end	
			end

			local enemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(enemies) do
				if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
					DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end	
			end

			local garden = nil

			print("garden parameter")
			print(garden_health)
			print(garden_damage)

			if IsValidEntity(caster.HangingGardens) and caster.HangingGardens:IsAlive() then
				garden = caster.HangingGardens
				caster.HangingGardens:SetAbsOrigin(targetpoint)	

				Timers:CreateTimer(0.05, function()
					garden:SetMaxHealth(garden_health)
					garden:SetBaseMaxHealth(garden_health)
					garden:SetHealth(garden_health - 1)
					garden:SetMana(garden:GetMaxMana() * 0.5)
					garden:SetBaseDamageMin(garden_damage)
					garden:SetBaseDamageMax(garden_damage)
					garden:SetBaseMoveSpeed(garden_movespeed)
				end)

				if garden:HasModifier("modifier_semiramis_babylon_quake") then
					garden:RemoveModifierByName("modifier_semiramis_babylon_quake")
				end
			else
				garden = CreateUnitByName("semiramis_hanging_gardens", targetpoint, true, nil, caster, caster:GetTeamNumber())	

				Timers:CreateTimer(0.05, function()
					garden:SetMaxHealth(garden_health)
					garden:SetBaseMaxHealth(garden_health)
					garden:SetHealth(garden_health - 1)
					garden:SetMana(garden:GetMaxMana() * 0.5)
					garden:SetBaseDamageMin(garden_damage)
					garden:SetBaseDamageMax(garden_damage)
					garden:SetBaseMoveSpeed(garden_movespeed)
					garden:AddItem(CreateItem("item_hanging_garden_dove" , nil, nil))
				end)
				garden:FindAbilityByName("semiramis_hanging_garden_sikera_usum"):SetActivated(false)
				caster.HangingGardens = garden	
			end	

			ability:ApplyDataDrivenModifier(caster,caster.HangingGardens, "modifier_semiramis_garden_checker",{Duration = ability:GetSpecialValueFor("duration") - 0.1})

			if caster.IsTerritoryAcquired then
				--garden:FindAbilityByName("semiramis_summon_birds"):SetLevel(2)
				garden:FindAbilityByName("hanging_gardens_mass_recall"):SetLevel(2)
				garden:FindAbilityByName("hanging_gardens_bombard"):SetLevel(2)
				garden:FindAbilityByName("hanging_garden_presence"):SetLevel(2)
				garden:FindAbilityByName("hanging_gardens_mount"):SetLevel(2)
				garden:FindAbilityByName("hanging_garden_passive_laser"):SetLevel(2)
				garden:SwapAbilities("fate_empty1", "hanging_garden_presence", false, true)
				garden:FindAbilityByName("semiramis_hanging_garden_sikera_usum"):SetLevel(2)
			end	

			garden:AddNewModifier(caster, nil, "modifier_kill", { Duration = ability:GetSpecialValueFor("duration") })


			local rocks = ParticleManager:CreateParticle( "particles/semiramis/hanging_garden_build.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( rocks, 0, targetpoint)

			garden:SetControllableByPlayer(caster:GetPlayerID(), true)
			garden:SetOwner(caster)
			FindClearSpaceForUnit(caster.HangingGardens, garden:GetAbsOrigin(), true)

			SemiCheckCombo(caster,ability)
		end
	end)
end

function OnAbsoluteGardenDetect(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:GetUnitName() == "semiramis_hanging_gardens" then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_semiramis_absolute_queen", {})
	end
end

function OnAbsoluteGardenDestroy(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_semiramis_absolute_queen")
end

function SemiCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if string.match(ability:GetAbilityName(), caster.RSkill) and not caster:HasModifier("modifier_tiatum_umu_cooldown") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 5})
		end
    end
end

function OnComboWindow(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster.RSkill, "semiramis_combo", false, true)
end

function OnComboWindowBroken(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_semiramis_class_assassin") then
		return
	else
		caster:SwapAbilities("semiramis_combo", caster.RSkill, false, true)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_combo_window")
end

function OnComboConditionCheck(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local targetpoint = ability:GetCursorPosition() 
	local min_range = ability:GetSpecialValueFor("minimum_range")
	local semi_range = ability:GetSpecialValueFor("semi_range")
	local garden = caster.HangingGardens

	local distancetogarden = (caster:GetAbsOrigin() - garden:GetAbsOrigin()):Length2D()
	local distancetotarget = (targetpoint - garden:GetAbsOrigin()):Length2D()

	if distancetogarden > semi_range then 
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Hero is Too Far")
        return 
	end

	if distancetotarget < min_range then 
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Too Close to Garden")
        return 
	end
end

function OnTiatumUmuCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetpoint = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local dps = ability:GetSpecialValueFor("dps")
	local duration = ability:GetSpecialValueFor("duration")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local garden = caster.HangingGardens

	local ult = caster:FindAbilityByName(caster.RSkill)
	ult:StartCooldown(ult:GetCooldown(ult:GetLevel()))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tiatum_umu_cooldown", {Duration = ability:GetCooldown(1)})	
	caster:RemoveModifierByName("modifier_combo_window")

   	EmitGlobalSound("Semi.Combo")

	if garden == nil then
		garden = CreateUnitByName("semiramis_hanging_gardens", targetpoint, true, nil, caster, caster:GetTeamNumber())		
		garden:SetMaxHealth(ult:GetSpecialValueFor("garden_health"))
		garden:SetMana(garden:GetMaxMana() * 0.4)
		garden:SetBaseDamageMin(ult:GetSpecialValueFor("garden_damage"))
		garden:SetBaseDamageMax(ult:GetSpecialValueFor("garden_damage"))
		garden:SetBaseMoveSpeed(ult:GetSpecialValueFor("garden_movespeed"))
		garden:SetControllableByPlayer(caster:GetPlayerID(), true)
		garden:SetOwner(caster)
		FindClearSpaceForUnit(caster.HangingGardens, garden:GetAbsOrigin(), true)
	end

	caster:SetAbsOrigin(garden:GetAbsOrigin())
	FindClearSpaceForUnit(caster, garden:GetAbsOrigin(), true)

	
	caster.IsMounted = true
	local mount = garden:FindAbilityByName("hanging_gardens_mount")
	mount:ApplyDataDrivenModifier(garden, caster, "modifier_semiramis_mounted", {})
	mount:ApplyDataDrivenModifier(garden, garden, "modifier_garden_mounted", {})  
	garden:FindAbilityByName("semiramis_hanging_garden_sikera_usum"):SetActivated(true)
	--garden:SwapAbilities("fate_empty8", "semiramis_hanging_garden_sikera_usum", false, true) 
	SendMountStatus(caster)

	giveUnitDataDrivenModifier(caster, garden, "jump_pause", cast_delay + duration + 0.25)
	--giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay + duration + 0.25)

	local slow = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
	for k,v in pairs(slow) do
		if IsInSameRealm(v:GetAbsOrigin(), caster:GetAbsOrigin()) then 
			ability:ApplyDataDrivenModifier(caster, v, "modifier_tiatum_umu_cast", {})	
		end
	end

	local charge = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_channel.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( charge, 0, garden:GetAbsOrigin() + Vector(0,0,200))

	Timers:CreateTimer(cast_delay - 0.8, function()
		local Shine = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_shine.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( Shine, 0, garden:GetAbsOrigin() + Vector(0,0,200))


		local blink_prevent = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		for k,v in pairs(blink_prevent) do
			if IsInSameRealm(v:GetAbsOrigin(), caster:GetAbsOrigin()) then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_tiatum_umu_execute", {})	
			end
		end
	end)

	Timers:CreateTimer(cast_delay + 0.1, function()
		local laser = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_laser.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( laser, 0, garden:GetAbsOrigin() + Vector(0,0,300))
		ParticleManager:SetParticleControl( laser, 1, targetpoint)

		Timers:CreateTimer(duration, function()
			local flek = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_ground_flek.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl(flek, 0, targetpoint)
			ParticleManager:DestroyParticle(laser,true)
		end)

		for i=duration,0,-0.1 do	
			Timers:CreateTimer(i, function()
				local enemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(enemies) do
					if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
						DoDamage(caster, v, dps/10, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end	
				end
			end)
		end
	end)

	Timers:CreateTimer(cast_delay + 0.05, function()
		local explosion = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_explosion_area.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( explosion, 0, targetpoint)
	end)

	Timers:CreateTimer(cast_delay + duration, function()
		local scorch = ParticleManager:CreateParticle( "particles/semiramis/tiatum_umu_scorch.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl(scorch, 0, targetpoint)
	end)
end

function OnMountStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_range = ability:GetSpecialValueFor("max_range")
	local hero = caster:GetOwnerEntity()

	local maxhealth = caster:GetMaxHealth()
	local curhealth = caster:GetHealth()

	Timers:CreateTimer(0, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsMounted then
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Unmount")

						caster:SetMaxHealth(maxhealth)
						caster:SetBaseMaxHealth(maxhealth)
						caster:SetHealth(curhealth)
					return			
				else
					hero:RemoveModifierByName("modifier_semiramis_mounted")
					caster:RemoveModifierByName("modifier_garden_mounted")
					caster:FindAbilityByName("semiramis_hanging_garden_sikera_usum"):SetActivated(false)
					--caster:SwapAbilities("semiramis_hanging_garden_sikera_usum", "fate_empty8", false, true) 
					hero.IsMounted = false
					SendMountStatus(hero)

					caster:SetMaxHealth(maxhealth)
					caster:SetBaseMaxHealth(maxhealth)
					caster:SetHealth(curhealth)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < max_range and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then 
				hero.IsMounted = true
				ability:ApplyDataDrivenModifier(caster, hero, "modifier_semiramis_mounted", {})
				ability:ApplyDataDrivenModifier(hero, caster, "modifier_garden_mounted", {})  
				--caster:SwapAbilities("fate_empty8", "semiramis_hanging_garden_sikera_usum", false, true) 
				caster:FindAbilityByName("semiramis_hanging_garden_sikera_usum"):SetActivated(true)
				SendMountStatus(hero)

					caster:SetMaxHealth(maxhealth)
					caster:SetBaseMaxHealth(maxhealth)
					caster:SetHealth(curhealth)
				return 
			end
		end
	end)
end

function OnHangingGardenSikeraUsum(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetpoint = ability:GetCursorPosition()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local dps = ability:GetSpecialValueFor("dps")
	local duration = ability:GetSpecialValueFor("duration")

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then

			EmitSoundOnLocationWithCaster(targetpoint, "Semi.GardenBasmu", {})
			EmitSoundOnLocationWithCaster(targetpoint, "Semi.GardenBasmu2", {})

			local cloud = ParticleManager:CreateParticle("particles/custom/semiramis/basmu_circle_parent.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(cloud, 0, targetpoint)

			local enemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(enemies) do
				if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
					DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end	
			end

			for i=duration,0,-0.5 do	
				Timers:CreateTimer(i, function()
					local enemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
					for k,v in pairs(enemies) do
						if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
							DoDamage(caster, v, dps/2, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end	
					end
				end)
			end

			Timers:CreateTimer(duration + 0.5, function()
				ParticleManager:DestroyParticle(cloud,true)
			end)
		end
	end)
end

function GardenFollow(keys)
	local garden = keys.caster
	local hero = keys.target
	if IsValidEntity(garden) then
		hero:SetAbsOrigin(garden:GetAbsOrigin() + Vector(0,0,450))
	else
		hero:RemoveModifierByName("modifier_semiramis_mounted")
	end
end

function OnMountedDestroy(keys)
	local hero = keys.target
	FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), true)
end

function OnGardenDeath(keys)
	local hero = keys.caster
	local garden = keys.target
	hero.IsMounted = false
	hero:RemoveModifierByName("modifier_semiramis_mounted")
	SendMountStatus(hero)
end

function OnPoisonousCloudCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("duration")

   	caster:EmitSound("Semi.AssassinE")

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then
			local poison_dummy = CreateUnitByName("dummy_unit", target_loc, false, caster, caster, caster:GetTeamNumber())
			poison_dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			ability:ApplyDataDrivenModifier(caster, poison_dummy, "modifier_semiramis_poisonous_cloud_buff", {})
			poison_dummy:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})
		end
	end)
end

function OnPoisonCloudThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local dummy = keys.target
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")

	local enemies = FindUnitsInRadius(caster:GetTeam(), dummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if enemies == nil then return end

   	caster:EmitSound("Semi.AssassinESFX")
	local cloud = ParticleManager:CreateParticle( "particles/custom/semiramis/basmu_poison.vpcf", PATTACH_CUSTOMORIGIN, dummy )
	ParticleManager:SetParticleControl( cloud, 0, dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl( cloud, 1, Vector(radius,0,0))

	for k,v in pairs(enemies) do
		if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			DoDamage(caster, v, damage * 0.25, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and not v:IsMagicImmune() then
				if caster.IsOldestPoisonerAcquired then 
					ability:ApplyDataDrivenModifier(caster, v, "modifier_semiramis_poisonous_cloud_amp", {})
				end
    			ability:ApplyDataDrivenModifier(caster, v, "modifier_semiramis_poisonous_cloud_debuff", {})
    			if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
    				ability:ApplyDataDrivenModifier(caster, v, "modifier_semiramis_poisonous_cloud_slow", {})
    			end
    		end
	    end
	end
end

function OnGardenPresenceThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local mana_drain_per_second = ability:GetSpecialValueFor("mana_drain_per_second")

	if caster:GetOwnerEntity():IsAlive() == false then
		DoDamage(caster, caster, 9999, DAMAGE_TYPE_PURE, 0, ability, false)
	end


	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if enemies == nil then return end

	if IsValidEntity(caster) and caster:IsAlive() then
		for k,v in pairs(enemies) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
		    		ability:ApplyDataDrivenModifier(caster, v, "modifier_garden_mana_drain_debuff", {})
				if not IsManaLess(v) then
					v:SetMana(v:GetMana() - mana_drain_per_second)
					caster:SetMana(caster:GetMana() + mana_drain_per_second)
		    	else
		    	end
		    end
		end
	end
end

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function OnDualClassAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDualClassAcquired) then

		UpgradeAttribute(hero, "semiramis_dual_class", "semiramis_dual_class_upgrade" , true)
		hero.DSkill = "semiramis_dual_class_upgrade"

		if hero:HasModifier("modifier_semiramis_class_assassin") then 
			hero:RemoveModifierByName("modifier_semiramis_class_caster")
		end

		hero.IsDualClassAcquired= true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnTerritoryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTerritoryAcquired) then

		if hero:HasModifier("modifier_combo_window") then
			hero:RemoveModifierByName("modifier_combo_window")
		end

		if hero:HasModifier("modifier_semiramis_class_assassin") then
			UpgradeAttribute(hero, "semiramis_hanging_gardens", "semiramis_hanging_gardens_upgrade" , false)
		else
			UpgradeAttribute(hero, "semiramis_hanging_gardens", "semiramis_hanging_gardens_upgrade" , true)
		end

		hero.IsTerritoryAcquired= true
		hero.RSkill = "semiramis_hanging_gardens_upgrade"
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAbsoluteAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAbsoluteAcquired) then

		hero.IsAbsoluteAcquired = true

		--hero:FindAbilityByName("semiramis_absolute_queen"):SetLevel(1)
		UpgradeAttribute(hero, "fate_empty1", "semiramis_absolute_queen" , true)
		if hero:HasModifier("modifier_semiramis_class_assassin") then
			if hero.IsCharmAcquired then 
				UpgradeAttribute(hero, "semiramis_binding_chains_charm", "semiramis_binding_chains_upgrade" , false)
				hero.QSkill = "semiramis_binding_chains_upgrade"
			else
				UpgradeAttribute(hero, "semiramis_binding_chains", "semiramis_binding_chains_absolute" , false)
				hero.QSkill = "semiramis_binding_chains_absolute"
			end
			UpgradeAttribute(hero, "semiramis_barrier", "semiramis_barrier_upgrade" , false)
			UpgradeAttribute(hero, "semiramis_beam_bombard", "semiramis_beam_bombard_upgrade" , false)
		else
			if hero.IsCharmAcquired then 
				UpgradeAttribute(hero, "semiramis_binding_chains_charm", "semiramis_binding_chains_upgrade" , true)
				hero.QSkill = "semiramis_binding_chains_upgrade"
			else
				UpgradeAttribute(hero, "semiramis_binding_chains", "semiramis_binding_chains_absolute" , true)
				hero.QSkill = "semiramis_binding_chains_absolute"
			end
			UpgradeAttribute(hero, "semiramis_barrier", "semiramis_barrier_upgrade" , true)
			UpgradeAttribute(hero, "semiramis_beam_bombard", "semiramis_beam_bombard_upgrade" , true)			
		end

		hero.WSkill = "semiramis_barrier_upgrade"
		hero.ESkill = "semiramis_beam_bombard_upgrade"
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnCharmerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCharmAcquired) then

		hero.IsCharmAcquired = true

		if hero:HasModifier("modifier_semiramis_class_assassin") then
			if hero.IsAbsoluteAcquired then 
				UpgradeAttribute(hero, "semiramis_binding_chains_absolute", "semiramis_binding_chains_upgrade" , false)
				hero.QSkill = "semiramis_binding_chains_upgrade"
			else
				UpgradeAttribute(hero, "semiramis_binding_chains", "semiramis_binding_chains_charm" , false)
				hero.QSkill = "semiramis_binding_chains_charm"
			end
			if hero.IsOldestPoisonerAcquired then 
				UpgradeAttribute(hero, "semiramis_poisonous_bite_old", "semiramis_poisonous_bite_upgrade" , true)
			else
				UpgradeAttribute(hero, "semiramis_poisonous_bite", "semiramis_poisonous_bite_charm" , true)
			end
		else
			if hero.IsAbsoluteAcquired then 
				UpgradeAttribute(hero, "semiramis_binding_chains_absolute", "semiramis_binding_chains_upgrade" , true)
				hero.QSkill = "semiramis_binding_chains_upgrade"
			else
				UpgradeAttribute(hero, "semiramis_binding_chains", "semiramis_binding_chains_charm" , true)
				hero.QSkill = "semiramis_binding_chains_charm"
			end
			if hero.IsOldestPoisonerAcquired then 
				UpgradeAttribute(hero, "semiramis_poisonous_bite_old", "semiramis_poisonous_bite_upgrade" , false)
			else
				UpgradeAttribute(hero, "semiramis_poisonous_bite", "semiramis_poisonous_bite_charm" , false)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnOldestPoisonerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsOldestPoisonerAcquired) then

		hero.IsOldestPoisonerAcquired= true

		if hero:HasModifier("modifier_semiramis_class_assassin") then
			UpgradeAttribute(hero, "semiramis_snek_spit_poison", "semiramis_snek_spit_poison_upgrade" , true)
			UpgradeAttribute(hero, "semiramis_poisonous_cloud", "semiramis_poisonous_cloud_upgrade" , true)
			if hero.IsCharmAcquired then 
				UpgradeAttribute(hero, "semiramis_poisonous_bite_charm", "semiramis_poisonous_bite_upgrade" , true)
			else
				UpgradeAttribute(hero, "semiramis_poisonous_bite", "semiramis_poisonous_bite_old" , true)
			end
		else
			UpgradeAttribute(hero, "semiramis_snek_spit_poison", "semiramis_snek_spit_poison_upgrade" , false)
			UpgradeAttribute(hero, "semiramis_poisonous_cloud", "semiramis_poisonous_cloud_upgrade" , false)
			if hero.IsCharmAcquired then 
				UpgradeAttribute(hero, "semiramis_poisonous_bite_charm", "semiramis_poisonous_bite_upgrade" , false)
			else
				UpgradeAttribute(hero, "semiramis_poisonous_bite", "semiramis_poisonous_bite_old" , false)
			end
		end
	
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end