
function OnPCBroked(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_ta_invis")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis_checker", {}) 
end

function OnPCActived(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
end

function OnPCRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis_checker", {}) 
end

function OnPCAbilityUsed(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 
	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(keys.CastDelay, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + keys.CastDelay then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not caster.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCAttacked(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 

	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(keys.CastDelay, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + keys.CastDelay then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not caster.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCMoved(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if caster.IsPCImproved then return end
	caster.LastActionTime = GameRules:GetGameTime() 

	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(keys.CastDelay, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + keys.CastDelay then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not caster.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCRespawn1(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 
	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(keys.CastDelay, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + keys.CastDelay then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not caster.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCDamageTaken(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 
	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(keys.CastDelay, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + keys.CastDelay then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not caster.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function PCStopOrder(keys)
	--keys.caster:Stop() 
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
end

function OnDirkStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local stacks = ability:GetCurrentAbilityCharges()
	--local stacks = caster:GetModifierStackCount("modifier_dirk_daggers_show", caster) or 0 
	local speed = ability:GetSpecialValueFor("speed")
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
		AddDaggerStackNEW(caster, 1)
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
	if stacks == 0 then 
		caster:Stop()
		--ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#No_Daggers_Available")
		return
	else
		ability:EndCooldown()
	end

	--AddDaggerStack(keys, -1)

	local info = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		iMoveSpeed = speed
	}
	ProjectileManager:CreateTrackingProjectile(info) 
end 

function OnDirkHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local venom_stacks = target:GetModifierStackCount("modifier_dirk_poison", caster) or 0 
	local damage = ability:GetSpecialValueFor("damage")

	if IsSpellBlocked(target) then return end

    if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then
    	ability:ApplyDataDrivenModifier(caster, target, "modifier_dirk_poison_slow", {}) 
    end

    target:EmitSound("Hero_PhantomAssassin.Dagger.Target")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_dirk_poison", {}) 
	target:SetModifierStackCount("modifier_dirk_poison", caster, venom_stacks + 1)
	if caster.IsWeakeningVenomAcquired then 
		local weak_stacks = target:GetModifierStackCount("modifier_dirk_weakening_venom", caster) or 0 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_dirk_weakening_venom", {}) 
		target:SetModifierStackCount("modifier_dirk_weakening_venom", caster, weak_stacks + 1)
	end	

	DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
end 

function OnDirkAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	local stacks = ability:GetCurrentAbilityCharges()
	--local stacks = caster:GetModifierStackCount("modifier_dirk_daggers_show", caster) or 0 

	if caster.IsWeakeningVenomAcquired and stacks > 0 and caster:GetMana() >= ability:GetManaCost(1) then 
		--AddDaggerStack(keys, -1)
		AddDaggerStackNEW(caster, -1)
		caster:SpendMana(ability:GetManaCost(1), ability)

		local weak_stacks = target:GetModifierStackCount("modifier_dirk_weakening_venom", caster) or 0 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_dirk_weakening_venom", {}) 
		target:SetModifierStackCount("modifier_dirk_weakening_venom", caster, weak_stacks + 1)

		local venom_stacks = target:GetModifierStackCount("modifier_dirk_poison", caster) or 0 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_dirk_poison", {}) 
		target:SetModifierStackCount("modifier_dirk_poison", caster, venom_stacks + 1)
	end	
end

function OnDirkPoisonTick(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local venom_stacks = target:GetModifierStackCount("modifier_dirk_poison", caster)
	local dps = ability:GetSpecialValueFor("poison_dot")

	if not target:IsMagicImmune() then 
		DoDamage(caster, target, dps * venom_stacks, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnDaggerStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_daggers = ability:GetSpecialValueFor("max_daggers")
	caster.DaggerStack = max_daggers
    AddDaggerStack(keys, caster.DaggerStack)
	if not caster:HasModifier("modifier_dirk_daggers_progress") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dirk_daggers_progress", {})
	end
	caster.DaggerProgress = 0
	UpdateDaggerProgress(caster)
end

function OnDaggerThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local max_stack = ability:GetSpecialValueFor("max_daggers")
	local regen_duration = ability:GetSpecialValueFor("dagger_recharge")
	local progress = 0.05 / regen_duration

    local currentStack = caster:GetModifierStackCount("modifier_dirk_daggers_show", caster)

	if currentStack >= max_stack then
		caster.DaggerProgress = 0
        AddDaggerStack(keys, max_stack)
	else
		caster.DaggerProgress = caster.DaggerProgress + progress
		if caster.DaggerProgress > 1 then
			caster.DaggerProgress = caster.DaggerProgress - 1
			AddDaggerStack(keys, 1)
		end
	end

	UpdateDaggerProgress(caster)
end

function OnDaggerRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_daggers = ability:GetSpecialValueFor("max_daggers")
	AddDaggerStackNEW(caster, max_daggers)
    --[[caster.DaggerStack = max_daggers
	AddDaggerStack(keys, max_daggers)]]
end

function AddDaggerStackNEW(caster, modifier)
	local ability = caster:FindAbilityByName("hassan_dirk")
	if ability == nil then 
		ability = caster:FindAbilityByName("hassan_dirk_upgrade")
	end
	local maxStack = ability:GetSpecialValueFor("max_daggers")

	local current_stack = ability:GetCurrentAbilityCharges()

	local newStack = math.max(math.min(current_stack + modifier, maxStack), 0)

	if newStack == 0 then 
		ability:StartCooldown(ability:GetCooldown(1))
	else
		ability:EndCooldown()
	end

	ability:SetCurrentAbilityCharges(newStack)
end

function AddDaggerStack(keys, modifier)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("hassan_dirk")
	if ability == nil then 
		ability = caster:FindAbilityByName("hassan_dirk_upgrade")
	end
	local maxStack = ability:GetSpecialValueFor("max_daggers")


	if not caster.DaggerStack then caster.DaggerStack = 0 end

	local newStack = caster.DaggerStack + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		ability:StartCooldown(ability:GetCooldown(1))
	else
		ability:EndCooldown()
	end

	caster:SetModifierStackCount("modifier_dirk_daggers_show", caster, newStack)
	caster.DaggerStack = newStack
end

function UpdateDaggerProgress(caster)
	local progress = caster.DaggerProgress * 100
	caster:SetModifierStackCount("modifier_dirk_daggers_progress", caster, progress)
end

function OnWindProtectionThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_mr = ability:GetSpecialValueFor("bonus_mr")
	local max_debuff = ability:GetSpecialValueFor("penalty_mr")
	local mr_change = ability:GetSpecialValueFor("mr_change")
	caster.bIsVisibleToEnemy = false
	local max_stacks = max_mr / mr_change
	local max_debuff_stacks = math.abs(max_debuff / mr_change)

	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see astolfo, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				caster.bIsVisibleToEnemy = true
				return
			end
		end
	end)

	if caster.bIsVisibleToEnemy == true then
		--print("revealed")
		if caster:HasModifier("modifier_wind_protection_bonus") then
			local stacks = caster:GetModifierStackCount("modifier_wind_protection_bonus", caster)
			caster:SetModifierStackCount("modifier_wind_protection_bonus", caster, math.max(0, stacks - 1))
			if stacks - 1 == 0 then 
				caster:RemoveModifierByName("modifier_wind_protection_bonus")
			end
		--[[else
			if not caster:HasModifier("modifier_wind_protection_penalty") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_wind_protection_penalty", {})
			end
			local debuff_stacks = caster:GetModifierStackCount("modifier_wind_protection_penalty", caster) or 0 
			caster:SetModifierStackCount("modifier_wind_protection_penalty", caster, math.min(max_debuff_stacks, debuff_stacks + 1) )]]
		end
	elseif caster.bIsVisibleToEnemy == false then
		--[[if caster:HasModifier("modifier_wind_protection_penalty") then
			local stacks = caster:GetModifierStackCount("modifier_wind_protection_penalty", caster)
			caster:SetModifierStackCount("modifier_wind_protection_penalty", caster, math.max(0, stacks - 1))
			if stacks - 1 == 0 then 
				caster:RemoveModifierByName("modifier_wind_protection_penalty")
			end
		else]]
			if not caster:HasModifier("modifier_wind_protection_bonus") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_wind_protection_bonus", {})
			end
			local stacks = caster:GetModifierStackCount("modifier_wind_protection_bonus", caster) or 0 
			caster:SetModifierStackCount("modifier_wind_protection_bonus", caster, math.min(max_stacks, stacks + 1))
		--end
	end
end

function OnAmbushStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local fade_delay = ability:GetSpecialValueFor("fade_delay")
	
	if caster.IsPCImproved then
		local detect_range = ability:GetSpecialValueFor("detect_range")
		local detect_duration = ability:GetSpecialValueFor("detect_duration")
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, detect_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		for i=1, #units do
			print(units[i]:GetUnitName())
			if units[i]:GetUnitName() == "ward_familiar" or units[i]:GetUnitName() == "sentry_familiar" then
				local visiondummy = CreateUnitByName("sight_dummy_unit", units[i]:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
				visiondummy:SetDayTimeVisionRange(500)
				visiondummy:SetNightTimeVisionRange(500)
				AddFOWViewer(caster:GetTeamNumber(), visiondummy:GetAbsOrigin(), 500, detect_duration, false)
				visiondummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 100}) 
				local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
				unseen:SetLevel(1)
				Timers:CreateTimer(detect_duration, function()
					if IsValidEntity(visiondummy) and not visiondummy:IsNull() then
						visiondummy:RemoveSelf()
					end 
				end)
				break
			end
		end 
	end

	if caster.IsWeakeningVenomAcquired then 

		local recover_dagger = ability:GetSpecialValueFor("recover_dagger")
		AddDaggerStackNEW(caster, recover_dagger)
		--AddDaggerStack(keys, recover_dagger)
	end

	Timers:CreateTimer(fade_delay, function()
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ambush", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ambush_think", {})
		end
	end)

	TACheckCombo(caster, ability)
end

function OnAmbushBroken(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ambush")
end

function OnAmbushTakeDamage(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ambush_think")
end

function OnFirstHitStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_ambush")
	caster:RemoveModifierByName("modifier_first_hit")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_thrown", {}) 
end

function OnFirstHitLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(target) then caster:RemoveModifierByName("modifier_ambush_think") return end -- Linken effect checker

	if target:GetName() == "npc_dota_ward_base" then
		DoDamage(caster, target, 2, DAMAGE_TYPE_PURE, 0, ability, false)
	else
		DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
	caster:EmitSound("Hero_TemplarAssassin.Meld.Attack")
	caster:RemoveModifierByName("modifier_ambush_think")
end

function OnAbilityCast(keys)
	local caster = keys.caster 
	--[[for k,v in pairs(keys) do 
		print(k,v)
	end]]
	local ability = keys.event_ability
	print(ability:GetAbilityName())

	if string.match(ability:GetAbilityName(), 'hassan_combo') or string.match(ability:GetAbilityName(), 'hassan_ambush') then 
		print('hassan cast combo or ambush')
	else
		caster:RemoveModifierByName("modifier_ambush_think")
	end
end

function OnSelfModStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local str = math.floor(caster:GetStrength())
	local agi = math.floor(caster:GetAgility())
	local int = math.floor(caster:GetIntellect()) 
	local heal_amount = ability:GetSpecialValueFor("heal_amount")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
		return nil
	end)

	caster:FateHeal(heal_amount, caster, true)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod", {})

	if str > agi and str > int then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_str", {})
	elseif agi > str and agi > int then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_agi", {})
	elseif int > str and int > agi then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_int", {})
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_all", {})
	end

	if caster.IsShaytanArmAcquired then 
		local mod_str_cooldown = ability:GetSpecialValueFor("mod_str_cooldown")
		local mod_int_heal = ability:GetSpecialValueFor("mod_int_heal")
		local mod_agi_dmg = ability:GetSpecialValueFor("mod_agi_dmg")
		local radius = ability:GetSpecialValueFor("mod_int_heal_aoe")
		local zaba = caster:FindAbilityByName("hassan_zabaniya")
		if caster.IsShadowStrikeAcquired then 
			zaba = caster:FindAbilityByName("hassan_zabaniya_upgrade")
		end
		if str > agi and str > int then 
			if not zaba:IsCooldownReady() then 
				local cooldown = zaba:GetCooldownTimeRemaining()
				if cooldown > mod_str_cooldown * str then 
					zaba:EndCooldown()
					zaba:StartCooldown(cooldown - (mod_str_cooldown * str))
				else
					zaba:EndCooldown()
				end
			end
		elseif agi > str and agi > int then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_agi_dmg", {})
			caster:SetModifierStackCount("modifier_ta_self_mod_agi_dmg", caster, mod_agi_dmg * agi)
		elseif int > str and int > agi then 
			local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for k,v in pairs(allies) do 
				if IsValidEntity(v) and not v:IsNull() then
					v:FateHeal(mod_int_heal * int, caster, true)
					local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControl(particle1, 1, v:GetAbsOrigin())
					-- Destroy particle after delay
					Timers:CreateTimer( 2.0, function()
						ParticleManager:DestroyParticle( particle1, false )
						ParticleManager:ReleaseParticleIndex( particle1 )
						return nil
					end)
				end
			end
		else
			if not zaba:IsCooldownReady() then 
				local cooldown = zaba:GetCooldownTimeRemaining()
				if cooldown > mod_str_cooldown * str / 2 then 
					zaba:EndCooldown()
					zaba:StartCooldown(cooldown - (mod_str_cooldown * str / 2))
				else
					zaba:EndCooldown()
				end
			end
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_self_mod_agi_dmg", {})
			caster:SetModifierStackCount("modifier_ta_self_mod_agi_dmg", caster, mod_agi_dmg * agi / 2)
			local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for k,v in pairs(allies) do 
				if IsValidEntity(v) and not v:IsNull() then
					v:Heal(mod_int_heal * int / 2, caster)
					local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControl(particle1, 1, v:GetAbsOrigin())
					-- Destroy particle after delay
					Timers:CreateTimer( 2.0, function()
						ParticleManager:DestroyParticle( particle1, false )
						ParticleManager:ReleaseParticleIndex( particle1 )
						return nil
					end)
				end
			end
		end
	end
end

function OnSelfModCD(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsShaytanArmAcquired then
		caster:FindAbilityByName("hassan_self_modification_upgrade"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_upgrade_str"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_upgrade_int"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	else
		caster:FindAbilityByName("hassan_self_modification"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_str"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_agi"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("hassan_self_modification_int"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end
end

function OnSelfModRegen(keys)
	local caster = keys.caster
	local ability = keys.ability
	local heal = ability:GetSpecialValueFor("heal_over_time")

	caster:Heal(heal, caster)
end

function OnSelfModUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsShaytanArmAcquired then
		if ability:GetAbilityName() == "hassan_self_modification_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_str"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_upgrade_str" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_upgrade_agi" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_str"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_upgrade_int" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_upgrade_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_upgrade_str"):SetLevel(ability:GetLevel())
			end
		end
	else
		if ability:GetAbilityName() == "hassan_self_modification" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_str"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_str" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_agi" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_str"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_int"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_int"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "hassan_self_modification_int" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_agi"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_agi"):SetLevel(ability:GetLevel())
			end
			if ability:GetLevel() ~= caster:FindAbilityByName("hassan_self_modification_str"):GetLevel() then
				caster:FindAbilityByName("hassan_self_modification_str"):SetLevel(ability:GetLevel())
			end
		end
	end
end

function OnSelfModSwap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local str = math.floor(caster:GetStrength())
	local agi = math.floor(caster:GetAgility())
	local int = math.floor(caster:GetIntellect()) 

	if caster.IsShaytanArmAcquired then
		if str > agi and str > int then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_upgrade_str" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_upgrade_str"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_upgrade_str", false, true)
			end
		elseif agi > str and agi > int then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_upgrade_agi" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_upgrade_agi"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_upgrade_agi", false, true)
			end
		elseif int > str and int > agi then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_upgrade_int" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_upgrade_int"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_upgrade_int", false, true)
			end
		else
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_upgrade" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_upgrade"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_upgrade", false, true)
			end
		end
	else
		if str > agi and str > int then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_str" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_str"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_str", false, true)
			end
		elseif agi > str and agi > int then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_agi" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_agi"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_agi", false, true)
			end
		elseif int > str and int > agi then 
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification_int" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification_int"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification_int", false, true)
			end
		else
			if caster:GetAbilityByIndex(1):GetAbilityName() == "hassan_self_modification" then 
				return 
			else
				if not caster:GetAbilityByIndex(1):IsCooldownReady() then 
					--caster:FindAbilityByName("hassan_self_modification"):StartCooldown(caster:GetAbilityByIndex(1):GetCooldownTimeRemaining())
				end
				caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hassan_self_modification", false, true)
			end
		end
	end
end

function OnStealAbilityStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.bIsVisibleToEnemy = false
	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see astolfo, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				caster.bIsVisibleToEnemy = true
				return
			end
		end
	end)
end

function OnSnatchStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")
	local curse_damage = ability:GetSpecialValueFor("curse_damage")
	local bonus_str = 0 
	local bonus_agi = 0
	local bonus_int = 0
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local str = math.floor(caster:GetStrength())
	local agi = math.floor(caster:GetAgility())
	local int = math.floor(caster:GetIntellect()) 

	target:EmitSound("TA.SnatchStrike")
	caster:EmitSound("Hassan_Skill1")
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
		return nil
	end)

	-- Blood splat
	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)	
		
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	if caster.IsShaytanArmAcquired then 
		local snatch_str_dmg = ability:GetSpecialValueFor("snatch_str_dmg")
		local snatch_agi_dmg = ability:GetSpecialValueFor("snatch_agi_dmg")
		local snatch_int_dmg = ability:GetSpecialValueFor("snatch_int_dmg")
		if str > agi and str > int then 
			bonus_str = str * snatch_str_dmg
			DoDamage(caster, target, bonus_str, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		elseif agi > str and agi > int then 
			bonus_agi = agi * snatch_agi_dmg
			DoDamage(caster, target, bonus_agi, DAMAGE_TYPE_PURE, 0, ability, false)
		elseif int > str and int > agi then 
			bonus_int = int * snatch_int_dmg
			DoDamage(caster, target, bonus_int, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		else
			bonus_str = str * snatch_str_dmg
			bonus_agi = agi * snatch_agi_dmg
			bonus_int = int * snatch_int_dmg
			DoDamage(caster, target, bonus_str, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
			DoDamage(caster, target, bonus_agi, DAMAGE_TYPE_PURE, 0, ability, false)
			DoDamage(caster, target, bonus_int, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end

	if caster.IsShadowStrikeAcquired then 
		if target:HasModifier("modifier_zaba_curse") then 
			DoDamage(caster, target, curse_damage, DAMAGE_TYPE_PURE, 0, ability, false)
		end
	end
end

function OnZabCastStart(keys)
	local caster = keys.caster
	local target = keys.target
	local smokeFx = ParticleManager:CreateParticleForTeam("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_loadout.vpcf", PATTACH_CUSTOMORIGIN, target, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(smokeFx, 0, caster:GetAbsOrigin())
	caster.LastActionTime = GameRules:GetGameTime()  -- Zab cast should be classified as an action that resets 2s timer for Presence Concealment.
	caster.bIsVisibleToEnemy = false
	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see astolfo, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				caster.bIsVisibleToEnemy = true
				return
			end
		end
	end)
end

function OnZabStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	local projectileSpeed = ability:GetSpecialValueFor("speed")

	caster:EmitSound("Hero_Nightstalker.Trickling_Fear")

	local info = {
		Target = keys.target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/custom/ta/zabaniya_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		iMoveSpeed = projectileSpeed
	}

	--print(caster.bIsVisibleToEnemy)
	--if (caster:HasModifier("modifier_ambush") or not caster.bIsVisibleToEnemy) then caster.IsShadowStrikeActivated = true end
	--if caster:HasModifier("modifier_ambush") then caster.IsShadowStrikeActivated = true end

	ProjectileManager:CreateTrackingProjectile(info) 
	Timers:CreateTimer({
		endTime = 0.033,
		callback = function()
		local smokeFx = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_ulti_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(smokeFx, 0, caster:GetAbsOrigin())
		local smokeFx2 = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_ulti_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(smokeFx2, 0, target:GetAbsOrigin())
		local smokeFx3 = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_loadout.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(smokeFx3, 0, target:GetAbsOrigin())

		-- Destroy particle after delay
		Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( smokeFx, false )
				ParticleManager:ReleaseParticleIndex( smokeFx )
				ParticleManager:DestroyParticle( smokeFx2, false )
				ParticleManager:ReleaseParticleIndex( smokeFx2 )
				ParticleManager:DestroyParticle( smokeFx3, false )
				ParticleManager:ReleaseParticleIndex( smokeFx3 )
				return nil
		end)
		EmitGlobalSound("TA.Zabaniya") 

		if caster:HasModifier("modifier_alternate_02") then 
			EmitGlobalSound("FemaleTA.Zabaniya") 
		elseif caster:HasModifier("modifier_alternate_03") then
			EmitGlobalSound("Illya-Zaba" .. math.random(1,2)) 
		else
			EmitGlobalSound("Hassan_Zabaniya") 
		end

		target:EmitSound("TA.Darkness") 
	end
	})
end

function OnZabHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ability = keys.ability
	
	local damage = ability:GetSpecialValueFor("damage")
	local mana_burn = ability:GetSpecialValueFor("mana_burn")

	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(blood, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)

	local shadowFx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(shadowFx, 0, target:GetAbsOrigin())
	local smokeFx3 = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_fiendsgrip_hands.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(smokeFx3, 0, target:GetAbsOrigin())

	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( blood, false )
		ParticleManager:ReleaseParticleIndex( blood )
		ParticleManager:DestroyParticle( shadowFx, false )
		ParticleManager:ReleaseParticleIndex( shadowFx )
		return nil
	end)
	
	
	target:SetMana(target:GetMana() - mana_burn)
	caster:GiveMana(mana_burn / 2)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_zaba_curse", {})
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnZabCurseCreate(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	target.ZabaLockedHealth = target:GetHealth()
end

function OnZabCurseThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	local currentHealth = target:GetHealth()
	if target.ZabaLockedHealth < currentHealth then 
		target:SetHealth(target.ZabaLockedHealth)
	else
		target.ZabaLockedHealth = currentHealth
	end
end

function OnZabCurseDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	target.ZabaLockedHealth = nil 
end

function OnTADeath(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	
	target:RemoveModifierByName("modifier_zaba_curse")
end 

function OnDIStart(keys)
	local caster = keys.caster	
	local pid = caster:GetPlayerID()
	local ability = keys.ability
	if caster:GetUnitName() ~= "npc_dota_hero_bounty_hunter" then 
		ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
		return 
	end
	local duration = ability:GetSpecialValueFor("duration")
	local search_radius = ability:GetSpecialValueFor("search_radius")
	local DICount = 0
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("hassan_combo")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_delusional_illusion_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster:RemoveModifierByName("modifier_delusional_illusion_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_delusional_illusion_show", {})
	--caster:EmitSound("TA.Darkness")
	if caster:HasModifier("modifier_alternate_02") or caster:HasModifier("modifier_alternate_03") then 
		EmitGlobalSound("FemaleTA.Delusion") 
	else
		EmitGlobalSound("Hassan_Combo")
	end

	if caster.combo_ring == nil then 
		caster.combo_ring = ParticleManager:CreateParticleForTeam("particles/custom/ta/hassan_combo_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
		ParticleManager:SetParticleControl(caster.combo_ring, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(caster.combo_ring, 1, Vector(search_radius,0,0))
	end

	Timers:CreateTimer(function()
		if DICount > duration or not caster:IsAlive() then
			ParticleManager:DestroyParticle(caster.combo_ring, true)
			ParticleManager:ReleaseParticleIndex(caster.combo_ring)
			caster.combo_ring = nil
			return 
		end 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, search_radius
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v.IsDIOnCooldown ~= true then 
				--print("Target " .. v:GetName() .. " detected")
				--for ilu = 0, 2 do
				
				--end
				CreateDIDummy(keys, v)
			end
		end
		DICount = DICount + 0.33
		return 0.33
	end)
end

function CreateDIDummy(keys, target)
	target.IsDIOnCooldown = true
	local total_dummy = 3 
	local spawn_interval = 0.5
	local cooldown = 2.5
	local dummy_count = 0

	Timers:CreateTimer(cooldown, function() 
		target.IsDIOnCooldown = false 
	end)

	local zaba = {
		Target = target,
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSourceLoc = nil,
		iMoveSpeed = 1200,
		bDrawsOnMinimap = false, 
		bVisibleToEnemies = true,
		bProvidesVision = false, 
		flExpireTime = GameRules:GetGameTime() + 3, 
		bDodgeable = true
	}
	Timers:CreateTimer(0.1, function() 
		if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return nil end
		if dummy_count == total_dummy then return nil end 
		dummy_count = dummy_count + 1 

		local spawn = target:GetAbsOrigin() + RandomVector(RandomInt(250, 650)) 
		zaba.vSourceLoc = spawn

		local direction = (target:GetAbsOrigin() - spawn):Normalized()

		local angle = VectorToAngles(direction)

		local hassan_dummy = ParticleManager:CreateParticle("particles/custom/ta/combo_dummy" .. RandomInt(1, 2) .. ".vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(hassan_dummy, 0, spawn) 
		ParticleManager:SetParticleControl(hassan_dummy, 1, Vector(0,0,angle.y))

		local smokeFx = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_ulti_smoke.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(smokeFx, 0, spawn)

		local smokeFx3 = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_loadout.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(smokeFx3, 0, spawn)

		ProjectileManager:CreateTrackingProjectile(zaba) 

		EmitGlobalSound("TA.Darkness") 
		EmitSoundOnLocationWithCaster(spawn, "Hero_PhantomAssassin.Dagger.Cast", caster)

		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle(hassan_dummy, true)
			ParticleManager:ReleaseParticleIndex(hassan_dummy)
			ParticleManager:DestroyParticle(smokeFx, true)
			ParticleManager:ReleaseParticleIndex(smokeFx)
			ParticleManager:DestroyParticle(smokeFx3, true)
			ParticleManager:ReleaseParticleIndex(smokeFx3)
		end)
		return spawn_interval
	end)
end

function CreateDIDummies(caster, target)
	target.IsDIOnCooldown = true

	local origin = target:GetAbsOrigin() + RandomVector(650) 
	local illusion = CreateUnitByName("ta_combo_dummy", origin, false, caster, caster, caster:GetTeamNumber()) 
	local illusionskill = illusion:FindAbilityByName("true_assassin_combo_zab") 
	illusionskill:SetLevel(1)
	illusion:SetForwardVector(target:GetAbsOrigin() - illusion:GetAbsOrigin())
	illusion:CastAbilityOnTarget(target, illusionskill, 1)
	StartAnimation(illusion, {duration = 5, activity = ACT_DOTA_ATTACK, rate = 1}) --maybe take this out

	local origin = target:GetAbsOrigin() + RandomVector(550) 
	local illusion2 = CreateUnitByName("ta_combo_dummy_2", origin, false, caster, caster, caster:GetTeamNumber()) 
	local illusionskill2 = illusion2:FindAbilityByName("true_assassin_combo_zab") 
	illusionskill2:SetLevel(1)
	illusion2:SetForwardVector(target:GetAbsOrigin() - illusion2:GetAbsOrigin())
	illusion2:CastAbilityOnTarget(target, illusionskill2, 1)
	StartAnimation(illusion2, {duration = 5, activity = ACT_DOTA_ATTACK, rate = 1}) --maybe take this out

	local origin = target:GetAbsOrigin() + RandomVector(450) 
	local illusion3 = CreateUnitByName("ta_combo_dummy_3", origin, false, caster, caster, caster:GetTeamNumber()) 
	local illusionskill3 = illusion3:FindAbilityByName("true_assassin_combo_zab") 
	illusionskill3:SetLevel(1)
	illusion3:SetForwardVector(target:GetAbsOrigin() - illusion3:GetAbsOrigin())
	illusion3:CastAbilityOnTarget(target, illusionskill3, 1)
	StartAnimation(illusion3, {duration = 5, activity = ACT_DOTA_ATTACK, rate = 2}) --maybe take this out

	Timers:CreateTimer(2.5, function() 
		if IsValidEntity(illusion) then
			illusion:RemoveSelf()
		end
		if IsValidEntity(illusion2) then
			illusion2:RemoveSelf()
		end
		if IsValidEntity(illusion3) then
			illusion3:RemoveSelf()
		end
		target.IsDIOnCooldown = false 
		return 
	end)
end

function OnDIZabStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability

	local speed = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()

	local info = {
		Target = target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = caster,
		iMoveSpeed = 700
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	--local particle = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_fiendsgrip_hands_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	--ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- target effect location
	--ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin()) -- circle effect location
	local smokeFx = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_ulti_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(smokeFx, 0, caster:GetAbsOrigin())
	--local smokeFx2 = ParticleManager:CreateParticle("particles/custom/ta/zabaniya_ulti_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	--ParticleManager:SetParticleControl(smokeFx2, 0, target:GetAbsOrigin())
	local smokeFx3 = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_loadout.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(smokeFx3, 0, caster:GetAbsOrigin())
	
	EmitGlobalSound("TA.Darkness") 
	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast") 

	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
			--ParticleManager:DestroyParticle( particle, false )
			--ParticleManager:ReleaseParticleIndex( particle )
			ParticleManager:DestroyParticle( smokeFx, false )
			ParticleManager:ReleaseParticleIndex( smokeFx )
			--ParticleManager:DestroyParticle( smokeFx2, false )
			--ParticleManager:ReleaseParticleIndex( smokeFx2 )
			ParticleManager:DestroyParticle( smokeFx3, false )
			ParticleManager:ReleaseParticleIndex( smokeFx3 )
			return nil
	end)
end

function OnDIZabHit(keys)
	--print("Projectile hit")
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local damage = ability:GetSpecialValueFor("damage")

	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function TACheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		local self_mod = caster:FindAbilityByName("hassan_self_modification") or caster:FindAbilityByName("hassan_self_modification_upgrade")
		if caster:HasModifier("modifier_ta_self_mod_str") and math.ceil(caster:GetStrength() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
			return 
		elseif caster:HasModifier("modifier_ta_self_mod_agi") and math.ceil(caster:GetStrength() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
			return 
		elseif caster:HasModifier("modifier_ta_self_mod_int") and math.ceil(caster:GetAgility() - self_mod:GetSpecialValueFor("bonus_stat")) < 25 then 
			return 
		elseif caster:HasModifier("modifier_ta_self_mod_all") and math.ceil(caster:GetIntellect() - self_mod:GetSpecialValueFor("bonus_stat_half")) < 25 then 
			return 
		end

		if caster.IsShadowStrikeAcquired then
			if string.match(ability:GetAbilityName(), "hassan_ambush")  and caster:FindAbilityByName("hassan_combo_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_delusional_illusion_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_delusional_illusion_window", {})
			end
		else
			if string.match(ability:GetAbilityName(), "hassan_ambush")  and caster:FindAbilityByName("hassan_combo"):IsCooldownReady() and not caster:HasModifier("modifier_delusional_illusion_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_delusional_illusion_window", {})
			end
		end
	end
end

function OnDelusionWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsShadowStrikeAcquired then
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hassan_combo_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hassan_combo", false, true)
	end
end

function OnDelusionWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsPCImproved then 
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hassan_presence_concealment_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hassan_presence_concealment", false, true)
	end
end

function OnDelusionWindowDied(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_delusional_illusion_window")
end

function OnImprovePresenceConcealmentAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPCImproved) then

		if hero:HasModifier("modifier_delusional_illusion_window") then 
			hero:RemoveModifierByName("modifier_delusional_illusion_window")
		end

		hero.IsPCImproved = true

		UpgradeAttribute(hero, 'hassan_presence_concealment', 'hassan_presence_concealment_upgrade', true)
		hero:RemoveModifierByName("modifier_ta_invis_passive")

		if hero.IsWeakeningVenomAcquired then 
			UpgradeAttribute(hero, 'hassan_ambush_upgrade_2', 'hassan_ambush_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'hassan_ambush', 'hassan_ambush_upgrade_1', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnProtectionFromWindAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPFWAcquired) then
	
		local ability = keys.ability
		hero.IsPFWAcquired = true
		hero:FindAbilityByName("hassan_protection_from_wind"):SetLevel(1) 	

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnWeakeningVenomAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWeakeningVenomAcquired) then

		if hero:HasModifier("modifier_delusional_illusion_window") then 
			hero:RemoveModifierByName("modifier_delusional_illusion_window")
		end

		hero.IsWeakeningVenomAcquired = true

		UpgradeAttribute(hero, 'hassan_dirk', 'hassan_dirk_upgrade', true)

		--[[local stacks = hero:GetModifierStackCount("modifier_dirk_daggers_base", hero)
		hero:RemoveModifierByName("modifier_dirk_daggers_show")
		hero:RemoveModifierByName("modifier_dirk_daggers_progress")
		hero:FindAbilityByName("hassan_dirk_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_dirk_daggers_progress", {})
		hero:FindAbilityByName("hassan_dirk_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_dirk_daggers_show", {})
		hero:SetModifierStackCount("modifier_dirk_daggers_show", hero, stacks)]]

		if hero.IsPCImproved then 
			UpgradeAttribute(hero, 'hassan_ambush_upgrade_1', 'hassan_ambush_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'hassan_ambush', 'hassan_ambush_upgrade_2', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnShaytanArmAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsShaytanArmAcquired) then

		hero.IsShaytanArmAcquired = true

		local str = math.floor(hero:GetStrength())
		local agi = math.floor(hero:GetAgility())
		local int = math.floor(hero:GetIntellect()) 

		hero:AddAbility("hassan_self_modification_upgrade")
		hero:AddAbility("hassan_self_modification_upgrade_int")
		hero:AddAbility("hassan_self_modification_upgrade_agi")
		hero:AddAbility("hassan_self_modification_upgrade_str")
		hero:FindAbilityByName("hassan_self_modification_upgrade"):SetLevel(hero:FindAbilityByName("hassan_self_modification"):GetLevel())	
		hero:FindAbilityByName("hassan_self_modification_upgrade_int"):SetLevel(hero:FindAbilityByName("hassan_self_modification"):GetLevel())
		hero:FindAbilityByName("hassan_self_modification_upgrade_agi"):SetLevel(hero:FindAbilityByName("hassan_self_modification"):GetLevel())
		hero:FindAbilityByName("hassan_self_modification_upgrade_str"):SetLevel(hero:FindAbilityByName("hassan_self_modification"):GetLevel())
		
		if str > agi and str > int then 
			hero:SwapAbilities("hassan_self_modification_upgrade_str", "hassan_self_modification_str", true, false) 
		elseif agi > str and agi > int then 
			hero:SwapAbilities("hassan_self_modification_upgrade_agi", "hassan_self_modification_agi", true, false) 
		elseif int > str and int > agi then 
			hero:SwapAbilities("hassan_self_modification_upgrade_int", "hassan_self_modification_int", true, false) 
		else
			hero:SwapAbilities("hassan_self_modification_upgrade", "hassan_self_modification", true, false) 
		end

		
		if not hero:FindAbilityByName("hassan_self_modification"):IsCooldownReady() then 
			hero:FindAbilityByName("hassan_self_modification_upgrade"):StartCooldown(hero:FindAbilityByName("hassan_self_modification"):GetCooldownTimeRemaining())
			hero:FindAbilityByName("hassan_self_modification_upgrade_int"):StartCooldown(hero:FindAbilityByName("hassan_self_modification"):GetCooldownTimeRemaining())
			hero:FindAbilityByName("hassan_self_modification_upgrade_agi"):StartCooldown(hero:FindAbilityByName("hassan_self_modification"):GetCooldownTimeRemaining())
			hero:FindAbilityByName("hassan_self_modification_upgrade_str"):StartCooldown(hero:FindAbilityByName("hassan_self_modification"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("hassan_self_modification")
		hero:RemoveAbility("hassan_self_modification_int")
		hero:RemoveAbility("hassan_self_modification_str")
		hero:RemoveAbility("hassan_self_modification_agi")

		if hero.IsShadowStrikeAcquired then 
			UpgradeAttribute(hero, 'hassan_snatch_strike_upgrade_1', 'hassan_snatch_strike_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'hassan_snatch_strike', 'hassan_snatch_strike_upgrade_2', true)
		end

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnShadowStrikeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsShadowStrikeAcquired) then

		if hero:HasModifier("modifier_delusional_illusion_window") then 
			hero:RemoveModifierByName("modifier_delusional_illusion_window")
		end

		hero.IsShadowStrikeAcquired = true

		UpgradeAttribute(hero, 'hassan_zabaniya', 'hassan_zabaniya_upgrade', true)
		UpgradeAttribute(hero, 'hassan_combo', 'hassan_combo_upgrade', false)

		if hero.IsShaytanArmAcquired then 
			UpgradeAttribute(hero, 'hassan_snatch_strike_upgrade_2', 'hassan_snatch_strike_upgrade_3', true)
		else
			UpgradeAttribute(hero, 'hassan_snatch_strike', 'hassan_snatch_strike_upgrade_1', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end	

