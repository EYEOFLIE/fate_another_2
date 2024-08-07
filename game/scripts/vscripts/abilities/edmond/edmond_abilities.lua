
function OnEdmondTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local attacker = keys.attacker 
	if ability == nil then 
		ability = GetAbility(caster, "lord_of_vengeance") 
	end

	ability:ApplyDataDrivenModifier(caster, attacker, "modifier_edmond_vengeance", {})

	if not attacker:IsRealHero() then 
		attacker = attacker:GetPlayerOwner():GetAssignedHero()
		ability:ApplyDataDrivenModifier(caster, attacker, "modifier_edmond_vengeance", {})
	end

	if not ability:IsCooldownReady() then 
		return 
	end

	if attacker:IsRealHero() then 
		if not attacker.hateCooldown then 
			attacker.hateCooldown = true 
			Timers:CreateTimer(0.5, function()
				attacker.hateCooldown = false
			end)

			AddHate(caster, 1)
		end
	end
end

function BonusVengeance(caster, target, damage)
	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then 
		return damage
	end

	if not target:HasModifier("modifier_edmond_vengeance") then 
		return damage
	end

	local ability = GetAbility(caster, "lord_of_vengeance")
	local vengeance_bonus = (ability:GetSpecialValueFor("vengeance_bonus") / 100) + 1

	damage = damage * vengeance_bonus

	target:RemoveModifierByName('modifier_edmond_vengeance')

	return damage
end

function AddHate(caster, stacks)
	local ability = GetAbility(caster, "lord_of_vengeance")
	local max_stack = ability:GetSpecialValueFor("hate_stacks")
	local monte_duration = ability:GetSpecialValueFor("monte_duration")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_hate", {})

	local currentStacks = caster:GetModifierStackCount("modifier_edmond_hate", caster) or 0

	if (currentStacks + stacks >= max_stack) then 
		--caster:RemoveModifierByName("modifier_edmond_hate")
		if not caster:HasModifier("modifier_edmond_monte_cristo") then
			caster:RemoveModifierByName("modifier_edmond_hate")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_monte_cristo", {Duration = monte_duration})
			ability:StartCooldown(ability:GetCooldown(1))
			if caster.IsDeterminationAcquired then 
				HardCleanse(caster)
			end
		else
			caster:SetModifierStackCount("modifier_edmond_hate", caster,  max_stack - 1)
		end
	else
		caster:SetModifierStackCount("modifier_edmond_hate", caster, math.min(currentStacks + stacks, max_stack))
	end

end

function OnMonteCristoAttackStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local attack_range = 250

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > attack_range and not caster:HasModifier("jump_pause") then 
		--ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_monte_range", {})
		--local aspd = caster:GetAttacksPerSecond()
		--caster:SetModifierStackCount("modifier_edmond_monte_range", caster, aspd * 30)
	end
end

function OnMonteCristoAttackBeam(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local attack_range = 250

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > attack_range and not caster:HasModifier("jump_pause") then 
		local new_ability = GetAbility(caster, "dark_beam")
		local target_loc = target:GetAbsOrigin() 
		local beam = {
			caster = caster, 
			ability = new_ability,
		}

		OnDarkBeamStart(beam)	
	end
end

function OnMonteCristoAttackMalee(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local attack_damage = keys.AttackDamage 
	local attack_range = 250
	if ability == nil then 
		ability = GetAbility(caster, "lord_of_vengeance") 
	end
	local bonus_malee = ability:GetSpecialValueFor("monte_bonus_dmg")

	if caster.IsAvengerAcquired and target:IsRealHero() then 
		AddMerciless(caster, target, 1)
	end

	if caster:HasModifier("jump_pause") or (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= attack_range then 
		bonus_malee = BonusVengeance(caster, target, bonus_malee)
		DoDamage(caster, target, bonus_malee, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		local slash = ParticleManager:CreateParticle("particles/custom/edmond/edmond_swipe_right.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(slash, 0, target:GetAbsOrigin() )
		
	else
		--target:Heal(attack_damage, target)
		caster:RemoveModifierByName("modifier_edmond_monte_range")
	end
end

function AddMerciless(caster, target, stacks)
	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = GetAbility(caster, "lord_of_vengeance")
	local max_stack = ability:GetSpecialValueFor("merciless_stack")
	local merciless_stun = ability:GetSpecialValueFor("merciless_stun")
	local merciless_damage = ability:GetSpecialValueFor("merciless_damage")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_edmond_merciless", {})

	local currentStacks = target:GetModifierStackCount("modifier_edmond_merciless", caster) or 0

	if currentStacks + stacks >= max_stack then 
		target:RemoveModifierByName("modifier_edmond_merciless")
		target:AddNewModifier(caster, nil, "modifier_stunned", {Duration = merciless_stun})
		merciless_damage = BonusVengeance(caster, target, merciless_damage)
		DoDamage(caster, target, merciless_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	else
		target:SetModifierStackCount("modifier_edmond_merciless", caster, currentStacks + stacks)
	end

end

function OnDarkBeamStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local distance = ability:GetSpecialValueFor("distance")
	local width = ability:GetSpecialValueFor("width")
	local speed = ability:GetSpecialValueFor("speed")
	caster:EmitSound("Edmond.Beam")
	caster:EmitSound("Hero_Zuus.Attack")
	local dark_beam = 
	{
		Ability = ability,
        --EffectName = "particles/custom/fran/fran_lightning_shot.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance - width,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}
	ProjectileManager:CreateLinearProjectile(dark_beam)
	local angle = caster:GetAnglesAsVector().y
	local end_loc = GetRotationPoint(caster:GetAbsOrigin(),distance,angle)
	end_loc = GetGroundPosition(end_loc, nil)
	local beamfx = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_dark_beam.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(beamfx, 1, end_loc + Vector(0,0,200))
	ParticleManager:SetParticleControl(beamfx, 9, caster:GetAbsOrigin() + Vector(0,0,200))
	ParticleManager:SetParticleControl(beamfx, 10, Vector(width,0,0))
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle(beamfx, false)
		ParticleManager:ReleaseParticleIndex(beamfx)
	end)
end

function OnDarkBeamHit(keys)
	local target = keys.target
	if target == nil then return end

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster 
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")

	damage = BonusVengeance(caster, target, damage)

	target:EmitSound("Ability.PlasmaFieldImpact")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

end

function OnShadowStrikeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local slashes = ability:GetSpecialValueFor("slashes")
	local monte_attack_aoe = ability:GetSpecialValueFor("monte_attack_aoe")
	local search_radius = ability:GetSpecialValueFor("search_radius")
	local interval = ability:GetSpecialValueFor("interval")
	local damage = ability:GetSpecialValueFor("damage")
	local slash_count = 1

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_shadow_strike", {Duration = (slashes * interval) + 0.5})

	local forwardvec = (caster:GetAbsOrigin()-target:GetAbsOrigin()):Normalized()
	local angle = VectorToAngles(forwardvec).y 
	local loc = GetRotationPoint(target:GetAbsOrigin(), 100, angle)

	local startLoc = GetRotationPoint(target:GetAbsOrigin(),200,60)
	local endLoc = GetRotationPoint(target:GetAbsOrigin(),200,240)
	local fxIndex = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_slash_tgt_top.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( fxIndex, 0, startLoc)
	ParticleManager:SetParticleControl( fxIndex, 2, endLoc)				    

	caster:SetAbsOrigin(loc)

    if caster:HasModifier("modifier_alternate_01") then 
    	caster:EmitSound("Edmond.W" .. math.random(1,4))
    else
    	caster:EmitSound("Edmond.Shadow")
    end
	--caster:EmitSound("Edmond.Shadow")


	if caster:HasModifier("modifier_edmond_monte_cristo") then 
		local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, monte_attack_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
		for _,enemy in pairs (enemies) do 
			if IsValidEntity(enemy) and not enemy:IsNull() and enemy:IsAlive() then 
				DoDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				caster:PerformAttack( enemy, true, true, true, true, false, false, false )
			end
		end
	else
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		caster:PerformAttack( target, true, true, true, true, false, false, false )
	end

	Timers:CreateTimer('edmond_shadow' .. caster:GetPlayerOwnerID(), {
		endTime = interval,
		callback = function()

		if (slash_count > slashes) or not caster:IsAlive() or not caster:HasModifier("modifier_edmond_shadow_strike") then 
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:RemoveModifierByName('modifier_edmond_shadow_strike')
			if caster.IsWisdomAcquired then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_shadow", {})
			end
			return nil 
		end

		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
		if #enemies > 0 then
			local random = RandomInt(1, #enemies)
			caster:SetAbsOrigin(enemies[random]:GetAbsOrigin())
			startLoc = GetRotationPoint(enemies[random]:GetAbsOrigin(),200,60)
			endLoc = GetRotationPoint(enemies[random]:GetAbsOrigin(),200,240)
			local fxIndex = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_slash_tgt_top.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl( fxIndex, 0, startLoc)
			ParticleManager:SetParticleControl( fxIndex, 2, endLoc)		
			if caster:HasModifier("modifier_edmond_monte_cristo") then 
				startLoc = GetRotationPoint(enemies[random]:GetAbsOrigin(),200,300)
				endLoc = GetRotationPoint(enemies[random]:GetAbsOrigin(),200,120)
				local fxIndex = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_slash_tgt_top.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl( fxIndex, 0, startLoc)
				ParticleManager:SetParticleControl( fxIndex, 2, endLoc)	
				local targets = FindUnitsInRadius(caster:GetTeam(), enemies[random]:GetAbsOrigin(), nil, monte_attack_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
				for _,target in pairs (targets) do 
					if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then 
						DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						caster:PerformAttack( target, true, true, true, true, false, false, false )
					end
				end
			else
				if IsValidEntity(enemies[random]) and not enemies[random]:IsNull() and enemies[random]:IsAlive() then 
					DoDamage(caster, enemies[random], damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					caster:PerformAttack( enemies[random], true, true, true, true, false, false, false )
				end
			end
		else
			caster:RemoveModifierByName('modifier_edmond_shadow_strike')
		end

		slash_count = slash_count + 1 

		return interval
	end})
end

function OnBlackThunderStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local delay = ability:GetSpecialValueFor("delay")
	local slow_dururation = ability:GetSpecialValueFor("slow_dururation")
	
	Timers:CreateTimer(delay, function()


	if caster:HasModifier("modifier_alternate_01") then 
		caster:EmitSound("Edmond.W" .. math.random(5,6))   
    else
		caster:EmitSound("Edmond.Thunder")   
    end
    
		
		local thunderIndex = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_thunder.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl( thunderIndex, 0, target_loc )
		ParticleManager:SetParticleControl( thunderIndex, 1, Vector(0,0,0))	

		Timers:CreateTimer(1.0, function()
			ParticleManager:DestroyParticle(thunderIndex, false)
			ParticleManager:ReleaseParticleIndex(thunderIndex)
		end)
		
		EmitSoundOnLocationWithCaster(target_loc, "Hero_Leshrac.Lightning_Storm", caster)
		local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
		for _,enemy in pairs (enemies) do
			if IsValidEntity(enemy) and not enemy:IsNull() and enemy:IsAlive() then
				if not enemy:IsMagicImmune() and not IsImmuneToCC(enemy) and not IsImmuneToSlow(enemy) then
					ability:ApplyDataDrivenModifier(caster, enemy, "modifier_edmond_thunder_slow", {})
				end
				if caster:HasModifier("modifier_edmond_monte_cristo") then 
					if not enemy:IsMagicImmune() and not IsImmuneToCC(enemy) then 
						enemy:AddNewModifier(caster, nil, "modifier_stunned", {Duration = slow_dururation})
					end
				end
				DoDamage(caster, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end

	end)

end

function OnMonteCristoMythStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local flame_radius = ability:GetSpecialValueFor("flame_radius")
	local flame_damage = ability:GetSpecialValueFor("flame_damage")
	local monte_duration = ability:GetSpecialValueFor("monte_duration")
	local silence_disarm = ability:GetSpecialValueFor("silence_disarm")
	local old_monte_duration = 0
	local vengeance = GetAbility(caster, "lord_of_vengeance")

	caster:EmitSound("Hero_Clinkz.Death")

	local particle = ParticleManager:CreateParticle("particles/custom/gilles/smother_ground_fire.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle, 1, Vector(flame_radius,flame_radius,flame_radius)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(flame_radius,flame_radius,flame_radius)) 

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(particle, false)
		ParticleManager:ReleaseParticleIndex(particle)
	end)

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, flame_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
	for _,enemy in pairs (enemies) do 
		if IsValidEntity(enemy) and not enemy:IsNull() and enemy:IsAlive() then
			if not enemy:IsMagicImmune() then 
				ability:ApplyDataDrivenModifier(caster, enemy, "modifier_edmond_flame_slow", {})
				if caster.IsMonteMythAcquired then 
					giveUnitDataDrivenModifier(caster, enemy, "silenced", silence_disarm)
			        giveUnitDataDrivenModifier(caster, enemy, "disarmed", silence_disarm)
			    end
			end
			DoDamage(caster, enemy, flame_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end

	if caster:HasModifier("modifier_edmond_monte_cristo") then 
		local monte_buff = caster:FindModifierByName("modifier_edmond_monte_cristo")
		old_monte_duration = monte_buff:GetRemainingTime()
		print('monte duration left :' .. old_monte_duration)
	end

	if caster:HasModifier("modifier_alternate_01") then 
		EmitGlobalSound("Edmond.R" .. math.random(1,5))    
    else
		EmitGlobalSound("Edmond.Myth")    
    end

	caster:RemoveModifierByName("modifier_edmond_monte_cristo")
	vengeance:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_monte_cristo", {Duration = math.max(monte_duration, old_monte_duration)})

	if caster.IsDeterminationAcquired then 
		HardCleanse(caster)
	end

	if caster.IsMonteMythAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_hate_shield", {})
		caster.HateShield = ability:GetSpecialValueFor("hate_shield")
		caster:SetModifierStackCount("modifier_edmond_hate_shield", caster, caster.HateShield)
	end

	EdmondCheckCombo(caster,ability)
end

function OnHateShieldTakeDamage(keys)
	local caster = keys.caster 
	local attacker = keys.attacker
	local currentHealth = caster:GetHealth() 
	local damage_taken = keys.DamageTaken

	if attacker:HasModifier("modifier_edmond_vengeance") then 
		damage_taken = damage_taken * 0.5
	end

	damage_taken = math.ceil(damage_taken)

	caster.HateShield = caster.HateShield - damage_taken

	if caster.HateShield <= 0 then
		if currentHealth + caster.HateShield <= 0 then
			--print("lethal")
		else
			--print("rho broken, but not lethal")
			caster:RemoveModifierByName("modifier_edmond_hate_shield")
			caster:SetHealth(currentHealth + damage_taken + caster.HateShield)
			caster.HateShield = 0
		end
	else
		caster:SetHealth(caster:GetHealth() + keys.DamageTaken)
		caster:SetModifierStackCount("modifier_edmond_hate_shield", caster, caster.HateShield)
	end
end

function OnReviveStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()

	local dead = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, 100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_CLOSEST, false )
	if #dead > 0 then
		if not dead[1]:IsAlive() then
			dead[1].edmondRevive = dead[1]:GetAbsOrigin()
			EmitGlobalSound("Edmond.Revive")
			if IsTeamWiped(dead[1]) == false and _G.CurrentGameState == "FATE_ROUND_ONGOING" then 
				GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. FindName(dead[1]:GetName()) .. "</font> has been revived by <font color='#58ACFA'>" .. FindName(caster:GetName()) .. "</font>.", 0, 0)
				dead[1]:SetRespawnPosition(dead[1].edmondRevive)
				dead[1]:RespawnHero(false,false)
				dead[1]:SetHealth(dead[1]:GetMaxHealth())
				dead[1]:SetMana(dead[1]:GetMaxMana())
				ResetAbilities(dead[1])
	        	ResetItems(dead[1])
	        	HardCleanse(dead[1])
	        	dead[1]:AddNewModifier(dead[1], nil, "modifier_camera_follow", {duration = 1.0})
	        	dead[1]:EmitSound("Hero_Omniknight.Purification")
	        	local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, dead[1])
				ParticleManager:SetParticleControl(particle, 3, dead[1]:GetAbsOrigin())
				Timers:CreateTimer(0.1, function()
					ParticleManager:DestroyParticle( particle, false )
					ParticleManager:ReleaseParticleIndex( particle )
					dead[1]:SetRespawnPosition(dead[1].RespawnPos)
				end)
			else
				dead[1].edmondRevive = nil 
			end
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_esperer_cooldown", {Duration = ability:GetCooldown(1)})
		else
			ability:EndCooldown()
			caster:GiveMana(ability:GetManaCost(1))
		end
	else
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
	end
	--[[if target:IsRealHero() and target:GetTeam() == caster:GetTeam() then 
		target.edmondRevive = target:GetAbsOrigin()
		if IsTeamWiped(target) == false and _G.CurrentGameState == "FATE_ROUND_ONGOING" then 
			target:SetRespawnPosition(target.edmondRevive)
			target:RespawnHero(false,false)
			target:SetHealth(target:GetMaxHealth())
			target:SetMana(target:GetMaxMana())
			ResetAbilities(target)
        	ResetItems(target)
        	HardCleanse(target)
			Timers:CreateTimer(0.1, function()
				target:SetRespawnPosition(target.RespawnPos)
			end)
		else
			target.edmondRevive = nil 
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_esperer_cooldown", {Duration = ability:GetCooldown(1)})
	else
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
	end]]
end

function OnAvengerAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = keys.DamageDeal
	local bonus_human = ability:GetSpecialValueFor("bonus_damage_human") / 100

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsHuman(target) then
		DoDamage(caster, target, damage * bonus_human, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
end

function EdmondCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsMonteMythAcquired then
			if string.match(ability:GetAbilityName(), 'edmond_monte_cristo') and caster:FindAbilityByName("edmond_chateau_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_edmond_chateau_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_enfer_window", {})	
			end
		else
			if string.match(ability:GetAbilityName(), 'edmond_monte_cristo') and caster:FindAbilityByName("edmond_chateau"):IsCooldownReady() and not caster:HasModifier("modifier_edmond_chateau_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_enfer_window", {})	
			end
		end
	end
end

function OnEnferWindowCreate(keys)
	local caster = keys.caster
	if caster.IsMonteMythAcquired then
		caster:SwapAbilities("edmond_chateau_upgrade", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	else
		caster:SwapAbilities("edmond_chateau", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	end
end

function OnEnferWindowDestroy(keys)
	local caster = keys.caster
	if caster.IsAvengerAcquired and caster.IsDeterminationAcquired then
		caster:SwapAbilities("edmond_lord_of_vengeance_upgrade_3", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	elseif not caster.IsAvengerAcquired and caster.IsDeterminationAcquired then
		caster:SwapAbilities("edmond_lord_of_vengeance_upgrade_2", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	elseif caster.IsAvengerAcquired and not caster.IsDeterminationAcquired then
		caster:SwapAbilities("edmond_lord_of_vengeance_upgrade_1", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	elseif not caster.IsAvengerAcquired and not caster.IsDeterminationAcquired then
		caster:SwapAbilities("edmond_lord_of_vengeance", caster:GetAbilityByIndex(3):GetAbilityName(), true, false) 
	end
end

function OnEnferDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_edmond_enfer_window")
end

function OnComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local target_loc = ability:GetCursorPosition()
	local forwardvec = (target_loc - caster:GetAbsOrigin()):Normalized()
	local radius = ability:GetSpecialValueFor("radius")
	local range = ability:GetSpecialValueFor("range")
	local total_atk = ability:GetSpecialValueFor("total_atk")
	local last_damage = ability:GetSpecialValueFor("last_damage")
	local last_stun = ability:GetSpecialValueFor("last_stun")
	local interval = 0.2
	local speed = 3000
	local duration = range / speed
	local attack_count = 0
	local dummy_loc = {}

	caster:RemoveModifierByName("modifier_edmond_enfer_window")


	local audioNum = 0
	if caster:HasModifier("modifier_alternate_01") then 
		audioNum = math.random(1,2)
		EmitGlobalSound("Edmond.PrecomboSkin" .. audioNum)
    else
	EmitGlobalSound("Edmond.Precombo")  
    end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_edmond_chateau_cooldown", {duration=ability:GetCooldown(1)})

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.0)
	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.9})
		
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("edmond_chateau")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	local edmond = Physics:Unit(caster) 
	if caster:IsAlive() then
		caster:SetPhysicsVelocity(caster:GetForwardVector() * speed)
		caster:PreventDI()
	    caster:SetPhysicsFriction(0)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)
	    caster:OnPhysicsFrame(function(unit)
			local diff = target_loc - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(dir * speed)
			if diff:Length() <= 150 then 
				EndAnimation(unit)
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:OnHibernate(nil)
				unit:SetAutoUnstuck(true)
		        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        local FirstEnemy = FindUnitsInRadius(unit:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		        if unit:IsAlive() and #FirstEnemy > 0 then 
		        	StartAnimation(caster, {duration=total_atk * interval, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.9})	
		        	local particle_dummy = 	"particles/custom/edmond/edmond_dummy.vpcf"
		        	if unit:HasModifier("modifier_alternate_01") then 
		        	    particle_dummy = "particles/custom/edmond/edmond_dummy2.vpcf"   
		        	end 	
		        	--unit:AddEffects(EF_NODRAW)
		        	Timers:CreateTimer('edmond_combo_attack' .. caster:GetPlayerOwnerID(), {
		        		endTime = 0.0,
						callback = function()
						if attack_count >= total_atk + 1 then 
							unit:AddEffects(EF_NODRAW)
							local dummies = {}
							for i = 1, 10 do
								dummy_loc[i] = GetRotationPoint(target_loc,RandomInt(radius + 200, radius - 100),i * 36) + Vector(0,0,RandomInt(300,600))
								dummies[i] = ParticleManager:CreateParticle( particle_dummy, PATTACH_WORLDORIGIN, caster)
								ParticleManager:SetParticleControl(dummies[i], 0, dummy_loc[i])
								ParticleManager:SetParticleControl(dummies[i], 2, Vector(0, 0, (i * 36) - 90))
							end
							Timers:CreateTimer(1.0, function()
								for k,v in pairs(dummies) do 
									ParticleManager:DestroyParticle(v, true)
									ParticleManager:ReleaseParticleIndex(v)
								end
							end)
							return nil 
						else
							local angle = RandomInt(0, 360)
						    local startLoc = GetRotationPoint(target_loc,RandomInt(radius - 200, radius),angle)
						    local endLoc = GetRotationPoint(target_loc,RandomInt(radius - 200, radius),angle + RandomInt(160, 200))
						    unit:SetAbsOrigin(endLoc)

						    local fxIndex = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_enfer_slash.vpcf", PATTACH_ABSORIGIN, caster)
						    ParticleManager:SetParticleControl( fxIndex, 0, startLoc + Vector(0,0,RandomInt(100,200)))
						    ParticleManager:SetParticleControl( fxIndex, 1, endLoc + Vector(0,0,RandomInt(100,200)))
						    caster:EmitSound("Hero_Ursa.Attack")		

						    local unitGroup = FindUnitsInRadius(unit:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
						    for k,v in pairs(unitGroup)	do
						    	if IsValidEntity(v) and not v:IsNull() and not v:HasModifier("modifier_stunned") and not IsImmuneToCC(v) then 
						            v:AddNewModifier(unit, nil, "modifier_stunned", {Duration = (total_atk - attack_count + 1) * interval})
						        end
						        unit:PerformAttack( v, true, true, true, true, false, false, true )
						    end			
						end

						attack_count = attack_count + 1 
						return interval
		        	end})

		        	
					Timers:CreateTimer((total_atk * interval) + 0.5, function()	
						if unit:IsAlive() then
							local beam = {}
							for i = 1, 10 do
								beam[i] = ParticleManager:CreateParticle( "particles/units/heroes/hero_tinker/tinker_laser_aghs.vpcf", PATTACH_WORLDORIGIN, caster)
								ParticleManager:SetParticleControl(beam[i], 0, target_loc)
								ParticleManager:SetParticleControl(beam[i], 1, target_loc)
								ParticleManager:SetParticleControl(beam[i], 9, dummy_loc[i])
								EmitSoundOnLocationWithCaster(target_loc, "Ability.static.end", caster)
							end
							Timers:CreateTimer(1.0, function()
								for k,v in pairs(beam) do 
									ParticleManager:DestroyParticle(v, true)
									ParticleManager:ReleaseParticleIndex(v)
								end
							end)
							
							if caster:HasModifier("modifier_alternate_01") then 
								EmitGlobalSound("Edmond.ComboSkin" .. audioNum)
   							 else
								EmitGlobalSound("Edmond.Combo") 
    						end

							
							local enemies = FindUnitsInRadius(unit:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
							for k,v in pairs(enemies)	do
						    	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
						            if not v:IsMagicImmune() then 
										ability:ApplyDataDrivenModifier(unit,v, "modifier_edmond_chateau_curse", {})
										if not IsImmuneToCC(v) then 
											v:AddNewModifier(unit, nil, "modifier_stunned", {Duration = last_stun})
										end
									end
									DoDamage(unit, v, last_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						        end
						    end
						    local explosionfx = ParticleManager:CreateParticle( "particles/custom/edmond/edmond_enfer_explosion.vpcf", PATTACH_WORLDORIGIN, caster)
						    ParticleManager:SetParticleControl(explosionfx, 1, target_loc)
							ParticleManager:SetParticleControl(explosionfx, 3, target_loc)
						    ParticleManager:SetParticleControl(explosionfx, 4, Vector(radius,0,0))
							
							Timers:CreateTimer(0.5, function()	
								unit:RemoveEffects(EF_NODRAW)
								unit:RemoveModifierByName("jump_pause")
								ParticleManager:DestroyParticle(explosionfx, false)
								ParticleManager:ReleaseParticleIndex(explosionfx)
								if IsInSameRealm(origin, unit:GetAbsOrigin()) then
									unit:SetAbsOrigin(origin)
								else
									unit:SetAbsOrigin(unit:GetAbsOrigin())
								end
								FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
							end)
						else
							unit:RemoveEffects(EF_NODRAW)
							unit:RemoveModifierByName("jump_pause")
							if IsInSameRealm(origin, unit:GetAbsOrigin()) then
								unit:SetAbsOrigin(origin)
							else
								unit:SetAbsOrigin(unit:GetAbsOrigin())
							end
							FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
						end
					end)
				else
					unit:RemoveModifierByName("jump_pause")
				end
			end
		end)
	end
end

function OnCurseDPSThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local curse_dps = ability:GetSpecialValueFor("curse_dps")

	DoDamage(caster, target, curse_dps * 0.5, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnAvengerAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAvengerAcquired) then

		hero.IsAvengerAcquired = true

		hero:RemoveModifierByName("modifier_edmond_enfer_window")
		
		hero:FindAbilityByName("edmond_avenger"):SetLevel(1)

		if hero.IsDeterminationAcquired then
			UpgradeAttribute(hero, 'edmond_lord_of_vengeance_upgrade_2', 'edmond_lord_of_vengeance_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'edmond_lord_of_vengeance', 'edmond_lord_of_vengeance_upgrade_1', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDeterminationAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDeterminationAcquired) then

		hero.IsDeterminationAcquired = true

		hero:RemoveModifierByName("modifier_edmond_enfer_window")

		if hero.IsAvengerAcquired then
			UpgradeAttribute(hero, 'edmond_lord_of_vengeance_upgrade_1', 'edmond_lord_of_vengeance_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'edmond_lord_of_vengeance', 'edmond_lord_of_vengeance_upgrade_2', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnWisdomAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWisdomAcquired) then

		hero.IsWisdomAcquired = true

		UpgradeAttribute(hero, 'edmond_dark_beam', 'edmond_dark_beam_upgrade', true)
		UpgradeAttribute(hero, 'edmond_shadow_strike', 'edmond_shadow_strike_upgrade', true)
		UpgradeAttribute(hero, 'edmond_thunder', 'edmond_thunder_upgrade', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnEspererAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsEspererAcquired) then

		hero.IsEspererAcquired = true
	
		--hero:FindAbilityByName("edmond_esperer"):SetLevel(1)

		hero:SwapAbilities("fate_empty1", "edmond_esperer", false, true)

		--UpgradeAttribute(hero, 'fate_empty1', 'edmond_esperer', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMonteMythAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMonteMythAcquired) then

		hero.IsMonteMythAcquired = true

		hero:RemoveModifierByName("modifier_edmond_enfer_window")

		UpgradeAttribute(hero, 'edmond_monte_cristo', 'edmond_monte_cristo_upgrade', true)
		UpgradeAttribute(hero, 'edmond_chateau', 'edmond_chateau_upgrade', false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end


	
