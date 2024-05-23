
LinkLuaModifier("modifier_jeanne_vision", "abilities/jeanne/modifiers/modifier_jeanne_vision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_divine_symbol", "abilities/jeanne/modifiers/modifier_jeanne_divine_symbol", LUA_MODIFIER_MOTION_NONE)

function OnMREXStart(keys)
	local caster = keys.caster
	caster.nMREXStack = 0
	if not caster:HasModifier("modifier_magic_resistance_ex_progress") then
		caster:FindAbilityByName("jeanne_magic_resistance_ex"):ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex_progress", {})
	end
	caster.MREXProgress = 0
	UpdateMREXProgress(caster)
end

function OnMREXDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	if caster.IsSaintImproved and caster:HasModifier("modifier_saint_buff") then return end
	--print("asdasd")
	ChangeMREXStack(keys, -1)
end

function OnMREXThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local max_stack = ability:GetSpecialValueFor("max_stack")
	local regen_duration = ability:GetSpecialValueFor("regen_duration")
	local progress = 1 / regen_duration * 0.05

	if caster:GetModifierStackCount("modifier_magic_resistance_ex_shield", caster) >= max_stack then
		caster.MREXProgress = 0
	else
		caster.MREXProgress = caster.MREXProgress + progress
		if caster.MREXProgress > 1 then
			caster.MREXProgress = caster.MREXProgress - 1
			ChangeMREXStack(keys, 1)
		end
	end

	UpdateMREXProgress(caster)
end

function OnMREXRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_stack = ability:GetSpecialValueFor("max_stack")
	ChangeMREXStack(keys, max_stack)
	caster.bIsLaPucelleActivatedThisRound = false
end

function ChangeMREXStack(keys, modifier)
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetSpecialValueFor("max_stack")

	if not caster.nMREXStack then caster.nMREXStack = 0 end
	if not caster:HasModifier("modifier_magic_resistance_ex_shield") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex_shield", {}) 
	end 

	local newStack = caster.nMREXStack + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		caster:RemoveModifierByName("modifier_magic_resistance_ex_shield")
	else
		caster:SetModifierStackCount("modifier_magic_resistance_ex_shield", caster, newStack)
	end
	caster.nMREXStack = newStack
end

function UpdateMREXProgress(caster)
	local progress = caster.MREXProgress * 100
	caster:SetModifierStackCount("modifier_magic_resistance_ex_progress", caster, progress)
end

function OnSaintThink(keys)
	local caster = keys.caster
	local ability = keys.ability

    local nRadiantAlive = 0
    local nDireAlive = 0
    local nDead = 0
    LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:IsAlive() then
            if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                nRadiantAlive = nRadiantAlive + 1
            else
                nDireAlive = nDireAlive + 1
            end
        else
        	nDead = nDead + 1
        end
    end)
    if caster:HasModifier("modifier_la_pucelle_spirit_form") then
    	if not caster:HasModifier("modifier_saint_buff") then
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_saint_buff", {})
    	end
    elseif (caster:GetTeam() == DOTA_TEAM_GOODGUYS and nRadiantAlive < nDireAlive) or (caster:GetTeam() == DOTA_TEAM_BADGUYS and nDireAlive < nRadiantAlive) then
    	if not caster:HasModifier("modifier_saint_buff") then
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_saint_buff", {})
    	end
    elseif nRadiantAlive == nDireAlive and caster.IsSaintImproved then
    	if not caster:HasModifier("modifier_saint_buff") then
    		ability:ApplyDataDrivenModifier(caster, caster, "modifier_saint_buff", {})
    	end
    else
    	if caster:HasModifier("modifier_saint_buff") then
    		caster:RemoveModifierByName("modifier_saint_buff")
    	end
    end

    if caster.IsSaintImproved and caster:HasModifier("modifier_saint_buff") then
    	local charisma = caster:FindAbilityByName("jeanne_charisma")
	    if charisma == nil then 
	    	charisma = caster:FindAbilityByName("jeanne_charisma_upgrade")
	    end

	    LoopOverPlayers(function(player, playerID, playerHero)
	        if playerHero:IsAlive() and playerHero:GetTeam() ~= caster:GetTeam() then
	            ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_saint_debuff", {})
	        end
	    end)
    	--charisma
    	if nDead > 0 then	
			local newKeys = keys
			newKeys.ability = charisma
			newKeys.target = caster
 			newKeys.Duration = 1.1
			OnIRStart(newKeys, false, true)
		end
    end
end

function OnSaintCreate(keys)
	local caster = keys.caster 
	if caster.IsRevelationAcquired then 
		caster:SwapAbilities("jeanne_charisma_upgrade", "jeanne_charisma_saint_upgrade", false, true)
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_3", "jeanne_purge_the_unjust_saint_upgrade_3", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_3", "jeanne_gods_resolution_saint_upgrade_3", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_3", "jeanne_luminosite_eternelle_saint_upgrade_3", false, true)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_2", "jeanne_purge_the_unjust_saint_upgrade_2", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_2", "jeanne_gods_resolution_saint_upgrade_2", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_3", "jeanne_luminosite_eternelle_saint_upgrade_3", false, true)
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_3", "jeanne_purge_the_unjust_saint_upgrade_3", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_1", "jeanne_gods_resolution_saint_upgrade_1", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_2", "jeanne_luminosite_eternelle_saint_upgrade_2", false, true)
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_2", "jeanne_purge_the_unjust_saint_upgrade_2", false, true)
			caster:SwapAbilities("jeanne_gods_resolution", "jeanne_gods_resolution_saint", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_2", "jeanne_luminosite_eternelle_saint_upgrade_2", false, true)
		end
	else
		caster:SwapAbilities("jeanne_charisma", "jeanne_charisma_saint", false, true)
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_1", "jeanne_purge_the_unjust_saint_upgrade_1", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_3", "jeanne_gods_resolution_saint_upgrade_3", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_1", "jeanne_luminosite_eternelle_saint_upgrade_1", false, true)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust", "jeanne_purge_the_unjust_saint", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_2", "jeanne_gods_resolution_saint_upgrade_2", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_1", "jeanne_luminosite_eternelle_saint_upgrade_1", false, true)
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_1", "jeanne_purge_the_unjust_saint_upgrade_1", false, true)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_1", "jeanne_gods_resolution_saint_upgrade_1", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle", "jeanne_luminosite_eternelle_saint", false, true)
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust", "jeanne_purge_the_unjust_saint", false, true)
			caster:SwapAbilities("jeanne_gods_resolution", "jeanne_gods_resolution_saint", false, true)
			caster:SwapAbilities("jeanne_luminosite_eternelle", "jeanne_luminosite_eternelle_saint", false, true)
		end
	end
end

function OnSaintDestroy(keys)
	local caster = keys.caster 
	if caster.IsRevelationAcquired then 
		caster:SwapAbilities("jeanne_charisma_upgrade", "jeanne_charisma_saint_upgrade", true, false)
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_3", "jeanne_purge_the_unjust_saint_upgrade_3", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_3", "jeanne_gods_resolution_saint_upgrade_3", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_3", "jeanne_luminosite_eternelle_saint_upgrade_3", true, false)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_2", "jeanne_purge_the_unjust_saint_upgrade_2", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_2", "jeanne_gods_resolution_saint_upgrade_2", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_3", "jeanne_luminosite_eternelle_saint_upgrade_3", true, false)
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_3", "jeanne_purge_the_unjust_saint_upgrade_3", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_1", "jeanne_gods_resolution_saint_upgrade_1", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_2", "jeanne_luminosite_eternelle_saint_upgrade_2", true, false)
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_2", "jeanne_purge_the_unjust_saint_upgrade_2", true, false)
			caster:SwapAbilities("jeanne_gods_resolution", "jeanne_gods_resolution_saint", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_2", "jeanne_luminosite_eternelle_saint_upgrade_2", true, false)
		end
	else
		caster:SwapAbilities("jeanne_charisma", "jeanne_charisma_saint", true, false)
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_1", "jeanne_purge_the_unjust_saint_upgrade_1", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_3", "jeanne_gods_resolution_saint_upgrade_3", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_1", "jeanne_luminosite_eternelle_saint_upgrade_1", true, false)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust", "jeanne_purge_the_unjust_saint", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_2", "jeanne_gods_resolution_saint_upgrade_2", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle_upgrade_1", "jeanne_luminosite_eternelle_saint_upgrade_1", true, false)
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust_upgrade_1", "jeanne_purge_the_unjust_saint_upgrade_1", true, false)
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_1", "jeanne_gods_resolution_saint_upgrade_1", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle", "jeanne_luminosite_eternelle_saint", true, false)
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
			caster:SwapAbilities("jeanne_purge_the_unjust", "jeanne_purge_the_unjust_saint", true, false)
			caster:SwapAbilities("jeanne_gods_resolution", "jeanne_gods_resolution_saint", true, false)
			caster:SwapAbilities("jeanne_luminosite_eternelle", "jeanne_luminosite_eternelle_saint", true, false)
		end
	end
end

function OnSaintDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_saint_buff")
end

function OnIDPing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("saint_vision_duration")
	--keys.Duration
	local delay = 0

	if caster.ServStat.radiantWin <= caster.ServStat.direWin and caster:GetTeam() == DOTA_TEAM_GOODGUYS or caster.ServStat.radiantWin >= caster.ServStat.direWin and caster:GetTeam() == DOTA_TEAM_BADGUYS then
		duration = ability:GetSpecialValueFor("saint_vision_duration_lose")        	
	end


	GameRules:SendCustomMessage("#identity_discernment_alert", 0, 0)
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and playerHero:IsAlive() then
        	--print("looping through " .. playerHero:GetName())
        	delay = delay + 0.15
        	Timers:CreateTimer(delay, function()
        		MinimapEvent( caster:GetTeamNumber(), caster, playerHero:GetAbsOrigin().x, playerHero:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2)
        	end)
        	-- Score is updated at end of round in addon_game_mode.lua. Since I'm already tracking score over there, I may as well use it...
        	
        	playerHero:AddNewModifier(caster, ability, "modifier_jeanne_vision", { Duration = duration })
        end
     end)
end

function OnIDRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- reset CD
	ability:EndCooldown()
	--print("asdasd")
end

function OnIRStart(keys, fromFlag, auto)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius_modifier")
	local duration = keys.Duration
	fromFlag = fromFlag or nil
	auto = auto or false
	local primaryStat = target:GetPrimaryAttribute()
	if fromFlag == true then
		if primaryStat == 0 then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_str_flag", {duration = duration})
		elseif primaryStat == 1 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_agi_flag", {duration = duration})
		elseif primaryStat == 2 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_int_flag", {duration = duration})
		end 
		if caster.IsRevelationAcquired then
			HardCleanse(target)
		end
	else
		if not auto then
			JeanneCheckCombo(caster,ability)
		end
		if primaryStat == 0 then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_str", {duration = duration})
		elseif primaryStat == 1 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_agi", {duration = duration})
		elseif primaryStat == 2 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_int", {duration = duration})
		end

		if caster.IsRevelationAcquired and target ~= caster then
			HardCleanse(target)
			--[[local base_damage = ability:GetSpecialValueFor("divine_base_damage")
			local int_ratio = ability:GetSpecialValueFor("divine_bonus_int")
			local reveal_radius = ability:GetSpecialValueFor("reveal_radius")
			target:AddNewModifier(caster, ability, "modifier_jeanne_divine_symbol", {Radius= reveal_radius, BaseDamage=base_damage, BonusInt=int_ratio, duration = duration })]]
		end
		--if not ability:IsCooldownReady() and ability:GetCooldownTimeRemaining() == ability:GetCooldown(ability:GetLevel()) then
			
		--end
	end
	SpawnAttachedVisionDummy(caster, target, radius, duration, true)

	if caster ~= target or not caster:HasModifier("modifier_saint_buff") then
		target:EmitSound("Hero_Dazzle.Shadow_Wave")
	end
	local jeanne_charisma_particle = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

	ParticleManager:SetParticleControl(jeanne_charisma_particle, 1, Vector(radius,0,0))
	-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(jeanne_charisma_particle, false)
		ParticleManager:ReleaseParticleIndex(jeanne_charisma_particle )
	end)
end

function OnCharismaUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsRevelationAcquired then 
		if ability:GetAbilityName() == "jeanne_charisma_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_charisma_saint_upgrade"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_charisma_saint_upgrade"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_charisma_saint_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_charisma_upgrade"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_charisma_upgrade"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	else
		if ability:GetAbilityName() == "jeanne_charisma" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_charisma_saint"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_charisma_saint"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_charisma_saint" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_charisma"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_charisma"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	end
end

function OnCharismaActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	for k = 6,15 do
		local charisma = caster:GetAbilityByIndex(k)
		if charisma ~= nil and string.match(charisma:GetAbilityName(), 'jeanne_charisma') then 
			charisma:EndCooldown()
			charisma:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			break
		end 
	end
end

function OnPurgeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("delay")
	local damage = ability:GetSpecialValueFor("damage")
	local silenceDuration = ability:GetSpecialValueFor("silence_duration")

	if caster.IsPunishmentAcquired then
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_purge_the_unjust_slow", {})
			end
		end
	end

	local markFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_marker.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( markFx, 0, targetPoint)
	EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.PenitenceImpact", caster)	

	local soundQueue = math.random(1,6)

	if caster:HasModifier('modifier_alternate_02') then 
		caster:EmitSound("Jeanne-W")
	else
		caster:EmitSound("Jeanne_Skill_" .. soundQueue)
	end

	Timers:CreateTimer(delay, function()

		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do	
			if IsValidEntity(v) and not v:IsNull() then
				if not v:IsMagicImmune() then	
			        giveUnitDataDrivenModifier(caster, v, "silenced", silenceDuration)
			        giveUnitDataDrivenModifier(caster, v, "disarmed", silenceDuration)
				end

		        if caster.IsRevelationAcquired then
		        	local reveal_duration = ability:GetSpecialValueFor("reveal_duration")
		        	v:AddNewModifier(caster, ability, "modifier_jeanne_vision", { Duration = reveal_duration })
		        end

				if caster.IsPunishmentAcquired then	
					DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, ability, false)
				else
			    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			    end
		    end
	    end

	    EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.TestOfFaith.Target", caster)		
		local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( purgeFx, 0, targetPoint)
		ParticleManager:SetParticleControl( purgeFx, 1, targetPoint)
		ParticleManager:SetParticleControl( purgeFx, 2, targetPoint)
	end)

	JeanneCheckCombo(caster,ability)
end

function OnPurgeUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsPunishmentAcquired and caster.IsRevelationAcquired then 
		if ability:GetAbilityName() == "jeanne_purge_the_unjust_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_3"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_3"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_purge_the_unjust_saint_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_3"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_3"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	elseif not caster.IsPunishmentAcquired and caster.IsRevelationAcquired then 
		if ability:GetAbilityName() == "jeanne_purge_the_unjust_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_2"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_2"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_purge_the_unjust_saint_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_2"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_2"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	elseif caster.IsPunishmentAcquired and not caster.IsRevelationAcquired then 
		if ability:GetAbilityName() == "jeanne_purge_the_unjust_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_1"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_saint_upgrade_1"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_purge_the_unjust_saint_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_1"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_upgrade_1"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	elseif not caster.IsPunishmentAcquired and not caster.IsRevelationAcquired then 
		if ability:GetAbilityName() == "jeanne_purge_the_unjust" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust_saint"):GetLevel() - 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust_saint"):SetLevel(ability:GetLevel() + 1)
				return
			end
		elseif ability:GetAbilityName() == "jeanne_purge_the_unjust_saint" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jeanne_purge_the_unjust"):GetLevel() + 1 then
				caster:FindAbilityByName("jeanne_purge_the_unjust"):SetLevel(ability:GetLevel() - 1)
				return
			end
		end
	end
end

function OnPurgeActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	for k = 6,15 do
		local purge = caster:GetAbilityByIndex(k)
		if purge ~= nil and string.match(purge:GetAbilityName(), 'jeanne_purge_the_unjust') then 
			purge:EndCooldown()
			purge:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			break
		end 
	end
end

function OnGodResolutionProc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage_percent = ability:GetSpecialValueFor("passive_damage_percentage")
	local duration = ability:GetSpecialValueFor("passive_revoke_duration")
	local damage = target:GetHealth() * damage_percent/100
	if caster.IsPunishmentAcquired then
		damage = target:GetMaxHealth() * damage_percent/100
	end
	--[[if not target:IsMagicImmune() then
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.1 })
	end]]

	local animation_duration = caster:GetAttackAnimationPoint()
	local rate = 10 / (24 * animation_duration)
	StartAnimation(caster, {duration=animation_duration, activity=ACT_DOTA_ATTACK_EVENT, rate=rate})

	if caster:HasModifier("modifier_saint_buff") then
		if not target:IsMagicImmune() then
			giveUnitDataDrivenModifier(caster, target, "revoked", duration)
		end
	end

	target:EmitSound("Hero_Chen.TeleportOut")
	local bashFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_sparks.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( bashFx, 0, target:GetAbsOrigin())
	local bashFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_penitence_c.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( bashFx2, 0, target:GetAbsOrigin())

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

end

function OnGodResolutionStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("active_total_damage")
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("active_duration")

	local elapsedTime = 0
	local tickPeriod = 0.2

	local tickDamage = damage * tickPeriod / duration

	local soundQueue = math.random(9,12)

	if caster:HasModifier('modifier_alternate_02') then 
		caster:EmitSound("Jeanne-E")
	else
		caster:EmitSound("Jeanne_Skill_" .. soundQueue)
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", duration)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gods_resolution_active_buff", {duration = duration})
	Timers:CreateTimer(0.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gods_resolution_anim", {})
	end)

	Timers:CreateTimer(function()
		if not caster:IsAlive() then return end
		elapsedTime = elapsedTime + tickPeriod
		if elapsedTime >= duration then 
			caster:StopSound("Hero_ArcWarden.MagneticField")
			caster:RemoveModifierByName("modifier_gods_resolution_anim")
			return 
		end
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() then
				if caster:HasModifier("modifier_saint_buff") and not IsImmuneToCC(v) then
					v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.1 })
				end

				if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
		        	ability:ApplyDataDrivenModifier(caster, v, "modifier_gods_resolution_slow", {}) 
		        end

		        DoDamage(caster, v, tickDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        end
	    end

		local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/gods_resolution/gods_resolution_active_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( purgeFx, 0, caster:GetAbsOrigin())

		if caster.IsDivineSymbolAcquired then 
			local pillar_dmg = ability:GetSpecialValueFor("pillar_dmg")
			local pillar_radius = ability:GetSpecialValueFor("pillar_radius")
			local vPillarLoc = caster:GetAbsOrigin() + RandomVector(radius * 0.75)

			local tPillarTargets = FindUnitsInRadius(caster:GetTeam(), vPillarLoc, nil, pillar_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for i = 1, #tPillarTargets do
				DoDamage(caster, tPillarTargets[i], pillar_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end

			local iPillarFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( iPillarFx, 0, vPillarLoc)
			ParticleManager:SetParticleControl( iPillarFx, 1, vPillarLoc)
			ParticleManager:SetParticleControl( iPillarFx, 2, vPillarLoc)

			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(iPillarFx, false)
				ParticleManager:ReleaseParticleIndex(iPillarFx)
			end)
		end		

		return tickPeriod
	end)

	caster:EmitSound("Hero_ArcWarden.MagneticField")
end

function OnGodResolutionUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	for k = 0,16 do
		local godres = caster:GetAbilityByIndex(k)
		if godres ~= nil and string.match(godres:GetAbilityName(), 'jeanne_gods_resolution') and godres ~= ability and godres:GetLevel() ~= ability:GetLevel() and ability ~= nil  then 
			godres:SetLevel(ability:GetLevel())
			break
		end 
	end
end

function OnGodResolutionActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	for k = 6,15 do
		local godres = caster:GetAbilityByIndex(k)
		if godres ~= nil and string.match(godres:GetAbilityName(), 'jeanne_gods_resolution') then 
			godres:EndCooldown()
			godres:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			break
		end 
	end
end

function OnLECastStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if #enemies == 0 then 
		--caster:EmitSound("Hero_Chen.HandOfGodHealHero")
		caster:EmitSound("Ruler.Luminosite")	
	else
		EmitGlobalSound("Hero_Chen.HandOfGodHealHero")
		EmitGlobalSound("Ruler.Luminosite")
	end
	Timers:CreateTimer(1.5, function()
		caster.IsLEWindupSoundAvailable = false
	end)
	if caster.LETargetTable then
		for i=1, #caster.LETargetTable do
			if IsValidEntity(caster.LETargetTable[i]) and caster.LETargetTable[i]:IsAlive() then
				caster.LETargetTable[i]:RemoveModifierByName("rooted")
				caster.LETargetTable[i]:RemoveModifierByName("locked")
				caster.LETargetTable[i]:RemoveModifierByName("modifier_luminosite_eternelle_saint_debuff")
			end
		end
	end
end

function OnLECastStop(keys)
	local caster = keys.caster 
	print('Stop Cast LE')
	caster:StopSound("Ruler.Luminosite")
	StopGlobalSound("Hero_Chen.HandOfGodHealHero")
	StopGlobalSound("Ruler.Luminosite")
end

function OnLEStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local range = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("flag_duration")
	local health = ability:GetSpecialValueFor("flag_health")
	local cc_duration = ability:GetSpecialValueFor("cc_duration")
	local travelTime = 1/3

	if caster.CurrentFlag and not caster.CurrentFlag:IsNull() then
		OnFlagCleanup(keys)
		--caster.CurrentFlag:RemoveModifierByName("modifier_luminosite_eternelle_flag_aura")
	end
	caster.LETargetTable = {}

	local projectileDestination = caster:GetAbsOrigin() + caster:GetForwardVector() * range
	for i=1, 20 do
		if GridNav:IsBlocked(projectileDestination) or not GridNav:IsTraversable(projectileDestination) then
			projectileDestination = projectileDestination - caster:GetForwardVector() * range/20 * i
		else
			break
		end
	end 
	local projectileRange = (caster:GetAbsOrigin() - projectileDestination):Length2D()

	-- Create invisible linear projectile to check for enemies on the trail
	local linearProjectile = 
	{
		Ability = keys.ability,
        -- EffectName = "particles/custom/reference/luminosite_eternelle/luminosite_eternelle.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = projectileRange - 375,
        fStartRadius = 300,
        fEndRadius = 300,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + travelTime,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * projectileRange / travelTime
	}
	ProjectileManager:CreateLinearProjectile(linearProjectile)

	-- Create particle dummy
	local origin_location = caster:GetAbsOrigin()
	local projectile = CreateUnitByName("dummy_unit", origin_location, false, caster, caster, caster:GetTeamNumber())
	projectile:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	projectile:SetAbsOrigin(origin_location)

	local particle_name = "particles/custom/ruler/luminosite_eternelle/luminosite_eternelle.vpcf"
	local throw_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, projectile)
	ParticleManager:SetParticleControl(throw_particle, 1, (projectileDestination - projectile:GetAbsOrigin()) / travelTime)
	projectile:SetForwardVector(caster:GetForwardVector())


	EmitGlobalSound("Ruler.Eternelle")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_luminosite_eternelle_anim", {})

	Timers:CreateTimer(travelTime, function()
		if IsValidEntity(projectile) then
			projectile:RemoveSelf()
		end

		local flag = CreateUnitByName("jeanne_banner", projectileDestination, true, caster, caster, caster:GetTeamNumber())
		flag:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
		--flag:SetAbsOrigin(projectileDestination)
		FindClearSpaceForUnit(flag, flag:GetAbsOrigin(), true)
		flag:SetBaseMaxHealth(health)
		caster.CurrentFlag = flag
		caster.CurrentFlagHealth = health

		ability:ApplyDataDrivenModifier(caster, flag, "modifier_luminosite_eternelle_flag_aura", {})

		if caster:HasModifier("modifier_saint_buff") then
			--ability:ApplyDataDrivenModifier(caster, flag, "modifier_luminosite_eternelle_flag_aura_debuff", {})
			local enemies1 = FindUnitsInRadius(caster:GetTeam(), flag:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			for a,b in pairs(enemies1) do
				if IsValidEntity(b) and not b:IsNull() then
					giveUnitDataDrivenModifier(caster, b, "locked", cc_duration)
					giveUnitDataDrivenModifier(caster, b, "rooted", cc_duration)
					giveUnitDataDrivenModifier(caster, b, "disarmed", cc_duration)
				end
			end
		end

		if caster.IsRevelationAcquired then			
			local reveal_duration = ability:GetSpecialValueFor("reveal_duration")
			local enemies2 = FindUnitsInRadius(caster:GetTeam(), flag:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			for i,j in pairs(enemies2) do
				if IsValidEntity(j) and not j:IsNull() then
					j:AddNewModifier(caster, ability, "modifier_jeanne_vision", { Duration = reveal_duration })
				end
			end
		end

		if caster.IsDivineSymbolAcquired then
			local charisma = caster:FindAbilityByName("jeanne_charisma")
			if charisma == nil then 
				charisma = caster:FindAbilityByName("jeanne_charisma_upgrade")
			end
			local targets = FindUnitsInRadius(caster:GetTeam(), flag:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				local newKeys = keys
				newKeys.ability = charisma
				newKeys.target = v
				newKeys.Duration = duration
				OnIRStart(newKeys, true)
			end
		end

		-- wow control points are an adventure
		local sacredZoneFx = ParticleManager:CreateParticle("particles/custom/ruler/luminosite_eternelle/sacred_zone.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(sacredZoneFx, 0, projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 1, Vector(1,1,range))
		ParticleManager:SetParticleControl(sacredZoneFx, 14, Vector(range,range,0))
		ParticleManager:SetParticleControl(sacredZoneFx, 4, Vector(-range * .9,0,0) + projectileDestination) -- Cross arm lengths
		ParticleManager:SetParticleControl(sacredZoneFx, 5, Vector(range * .9,0,0) + projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 6, Vector(0,-range * .9,0) + projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 7, Vector(0,range * .9,0) + projectileDestination)
		caster.CurrentFlagParticle = sacredZoneFx

		EmitSoundOnLocationWithCaster(projectileDestination, "Hero_Omniknight.GuardianAngel.Cast", caster)

		-- DebugDrawCircle(projectileDestination, Vector(255,0,0), 0.5, range, true, duration)
	end)
end

function OnLEHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local duration = ability:GetSpecialValueFor("cc_duration")
	--print(target:GetName() .. " hit by Luminosite Eternelle")
	-- apply CC
	table.insert(caster.LETargetTable, target)
	giveUnitDataDrivenModifier(caster, target, "locked", duration)
	giveUnitDataDrivenModifier(caster, target, "rooted", duration)
	giveUnitDataDrivenModifier(caster, target, "disarmed", duration)

	target:EmitSound("Hero_ArcWarden.Flux.Cast")
end

function OnLEAllyDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local victim = keys.unit
	local attacker = keys.attacker
	--[[if caster.IsSaintImproved and caster:HasModifier("modifier_saint_buff") then
		return
	end]]

	if not caster.CurrentFlag:IsNull() then
		caster.CurrentFlagHealth = caster.CurrentFlagHealth - 1
		if caster.CurrentFlagHealth <= 0 then
			OnFlagCleanup(keys)
		else
			caster.CurrentFlag:SetHealth(caster.CurrentFlagHealth)
		end
	end
end

function OnLEAllyLeft(keys)
	local caster = keys.caster 
	local target = keys.target 
	if caster.IsDivineSymbolAcquired then
		target:RemoveModifierByName("modifier_jeanne_charisma_str_flag")
		target:RemoveModifierByName("modifier_jeanne_charisma_agi_flag")
		target:RemoveModifierByName("modifier_jeanne_charisma_int_flag")
	end
end

function OnLEUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	for k = 0,16 do
		local flag = caster:GetAbilityByIndex(k)
		if flag ~= nil and string.match(flag:GetAbilityName(), 'jeanne_luminosite_eternelle') and flag ~= ability and flag:GetLevel() ~= ability:GetLevel() and ability ~= nil  then 
			flag:SetLevel(ability:GetLevel())
			break
		end 
	end
end

function OnLEActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	for k = 6,15 do
		local flag = caster:GetAbilityByIndex(k)
		if flag ~= nil and string.match(flag:GetAbilityName(), 'jeanne_luminosite_eternelle') then 
			print('start flag cooldown')
			flag:EndCooldown()
			flag:StartCooldown(ability:GetCooldown(ability:GetLevel()))
			break
		end 
	end
end

function OnFlagCleanup(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not caster.CurrentFlag:IsNull() and IsValidEntity(caster.CurrentFlag) then
		--caster.CurrentFlag:ForceKill(false)
		caster.CurrentFlag:RemoveSelf()
		ParticleManager:DestroyParticle( caster.CurrentFlagParticle, false )
		ParticleManager:ReleaseParticleIndex( caster.CurrentFlagParticle )
	end
end

function JeanneCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		--and caster:HasModifier("modifier_charisma_used")
		--and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady()
		--and caster:FindAbilityByName("jeanne_gods_resolution"):IsCooldownReady()
		--and caster:GetAbilityByIndex(2):GetName() ~= "jeanne_la_pucelle"
		
		if string.match(ability:GetAbilityName(), "jeanne_charisma") then 
			if string.match(GetMapName(), "fate_elim") then 
				if GameRules:GetGameTime() > 60 + _G.RoundStartTime and GameRules:GetGameTime() <= 115 + _G.RoundStartTime then
					caster.QUsed = true
					caster.QTime = GameRules:GetGameTime()
					if caster.QTimer ~= nil then 
						Timers:RemoveTimer(caster.QTimer)
						caster.QTimer = nil
					end
					caster.QTimer = Timers:CreateTimer(4.0, function()
						caster.QUsed = false
					end)
				end
			else
				caster.QUsed = true
				caster.QTime = GameRules:GetGameTime()
				if caster.QTimer ~= nil then 
					Timers:RemoveTimer(caster.QTimer)
					caster.QTimer = nil
				end
				caster.QTimer = Timers:CreateTimer(4.0, function()
					caster.QUsed = false
				end)
			end
		else
			if string.match(ability:GetAbilityName(), "jeanne_purge_the_unjust") and caster:FindAbilityByName(caster:GetAbilityByIndex(2):GetAbilityName()):IsCooldownReady() and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady() and not caster:HasModifier("modifier_la_pucelle_cooldown") then
				if caster.QUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 4 - (newTime - caster.QTime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_jeanne_la_pucelle_window", {Duration = duration})
				end
			end
			--[[if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
				if string.match(ability:GetAbilityName(), "jeanne_purge_the_unjust") and caster:FindAbilityByName("jeanne_gods_resolution_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady() and not caster:HasModifier("modifier_la_pucelle_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
							-- prevent la pucelle bug
							--[[if PlayerResource:GetConnectionState(caster:GetPlayerOwnerID()) == 3 then 
								SendErrorMessage(caster:GetPlayerOwnerID(), "#Player_" .. caster:GetPlayerOwnerID() .. "_is_disconnected")
								return
							end]]
			--[[			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jeanne_la_pucelle_window", {Duration = duration})
					end
				end
			elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then 
				if string.match(ability:GetAbilityName(), "jeanne_purge_the_unjust") and caster:FindAbilityByName("jeanne_gods_resolution_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady() and not caster:HasModifier("modifier_la_pucelle_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_jeanne_la_pucelle_window", {Duration = duration})
					end
				end
			elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
				if string.match(ability:GetAbilityName(), "jeanne_purge_the_unjust") and caster:FindAbilityByName("jeanne_gods_resolution_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady() and not caster:HasModifier("modifier_la_pucelle_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_jeanne_la_pucelle_window", {Duration = duration})
					end
				end
			elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then 
				if string.match(ability:GetAbilityName(), "jeanne_purge_the_unjust") and caster:FindAbilityByName("jeanne_gods_resolution"):IsCooldownReady() and caster:FindAbilityByName("jeanne_la_pucelle"):IsCooldownReady() and not caster:HasModifier("modifier_la_pucelle_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_jeanne_la_pucelle_window", {Duration = duration})
					end
				end
			end]]
		end
	end
end

function OnLaPucelleWindowStart(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "jeanne_la_pucelle", false, true)
end

function OnLaPucelleWindowDestroy(keys)
	local caster = keys.caster

	if caster:HasModifier("modifier_saint_buff") then 
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_saint_upgrade_3", "jeanne_la_pucelle", true, false)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_saint_upgrade_2", "jeanne_la_pucelle", true, false)			
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_saint_upgrade_1", "jeanne_la_pucelle", true, false)			
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_saint", "jeanne_la_pucelle", true, false)
		end
	else
		if caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_3", "jeanne_la_pucelle", true, false)
		elseif not caster.IsPunishmentAcquired and caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_2", "jeanne_la_pucelle", true, false)			
		elseif caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution_upgrade_1", "jeanne_la_pucelle", true, false)			
		elseif not caster.IsPunishmentAcquired and not caster.IsDivineSymbolAcquired then
			caster:SwapAbilities("jeanne_gods_resolution", "jeanne_la_pucelle", true, false)
		end
	end
end

function OnLaPucelleWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")
end

function OnIDAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsIDAcquired) then

		hero.bIsIDAcquired = true

		hero:SwapAbilities("jeanne_magic_resistance_ex", "jeanne_identity_discernment", false, true) 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSaintImproved(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSaintImproved) then

		hero.IsSaintImproved = true

		UpgradeAttribute(hero, 'jeanne_saint', 'jeanne_saint_upgrade', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnPunishmentAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPunishmentAcquired) then

		if caster:HasModifier("modifier_jeanne_la_pucelle_window") then 
			caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")
		end

		hero.IsPunishmentAcquired = true

		if hero:HasModifier("modifier_saint_buff") then 
			if hero.IsDivineSymbolAcquired then
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint_upgrade_2', 'jeanne_gods_resolution_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_2', 'jeanne_gods_resolution_upgrade_3', false)
			else
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint', 'jeanne_gods_resolution_saint_upgrade_1', true)
				UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_1', false)
			end
			if hero.IsRevelationAcquired then
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint_upgrade_2', 'jeanne_purge_the_unjust_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_2', 'jeanne_purge_the_unjust_upgrade_3', false)
			else
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint', 'jeanne_purge_the_unjust_saint_upgrade_1', true)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_1', false)
			end
		else
			if hero.IsDivineSymbolAcquired then
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint_upgrade_2', 'jeanne_gods_resolution_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_2', 'jeanne_gods_resolution_upgrade_3', true)
			else
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint', 'jeanne_gods_resolution_saint_upgrade_1', false)
				UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_1', true)
			end
			if hero.IsRevelationAcquired then
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint_upgrade_2', 'jeanne_purge_the_unjust_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_2', 'jeanne_purge_the_unjust_upgrade_3', true)
			else
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint', 'jeanne_purge_the_unjust_saint_upgrade_1', false)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_1', true)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDivineSymbolAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDivineSymbolAcquired) then

		if caster:HasModifier("modifier_jeanne_la_pucelle_window") then 
			caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")
		end

		hero.IsDivineSymbolAcquired = true

		if hero:HasModifier("modifier_saint_buff") then 
			if hero.IsPunishmentAcquired then
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint_upgrade_1', 'jeanne_gods_resolution_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_1', 'jeanne_gods_resolution_upgrade_3', false)
			else
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint', 'jeanne_gods_resolution_saint_upgrade_2', true)
				UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_2', false)
			end
			if hero.IsRevelationAcquired then
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint_upgrade_2', 'jeanne_luminosite_eternelle_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_2', 'jeanne_luminosite_eternelle_upgrade_3', false)
			else
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint', 'jeanne_luminosite_eternelle_saint_upgrade_1', true)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_1', false)
			end
		else
			if hero.IsPunishmentAcquired then
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint_upgrade_1', 'jeanne_gods_resolution_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_gods_resolution_upgrade_1', 'jeanne_gods_resolution_upgrade_3', true)
			else
				UpgradeAttribute(hero, 'jeanne_gods_resolution_saint', 'jeanne_gods_resolution_saint_upgrade_2', false)
				UpgradeAttribute(hero, 'jeanne_gods_resolution', 'jeanne_gods_resolution_upgrade_2', true)
			end
			if hero.IsRevelationAcquired then
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint_upgrade_2', 'jeanne_luminosite_eternelle_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_2', 'jeanne_luminosite_eternelle_upgrade_3', true)
			else
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint', 'jeanne_luminosite_eternelle_saint_upgrade_1', false)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_1', true)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnRevelationAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRevelationAcquired) then

		hero.IsRevelationAcquired = true

		if hero:HasModifier("modifier_saint_buff") then 
			UpgradeAttribute(hero, 'jeanne_charisma_saint', 'jeanne_charisma_saint_upgrade', true)
			UpgradeAttribute(hero, 'jeanne_charisma', 'jeanne_charisma_upgrade', false)

			if hero.IsPunishmentAcquired then
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint_upgrade_1', 'jeanne_purge_the_unjust_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_1', 'jeanne_purge_the_unjust_upgrade_3', false)
				
			else
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint', 'jeanne_purge_the_unjust_saint_upgrade_2', true)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_2', false)
				
			end

			if hero.IsDivineSymbolAcquired then
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint_upgrade_1', 'jeanne_luminosite_eternelle_saint_upgrade_3', true)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_1', 'jeanne_luminosite_eternelle_upgrade_3', false)
				
			else
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint', 'jeanne_luminosite_eternelle_saint_upgrade_2', true)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_2', false)
				
			end
		else
			UpgradeAttribute(hero, 'jeanne_charisma_saint', 'jeanne_charisma_saint_upgrade', false)
			UpgradeAttribute(hero, 'jeanne_charisma', 'jeanne_charisma_upgrade', true)

			if hero.IsPunishmentAcquired then
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint_upgrade_1', 'jeanne_purge_the_unjust_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_upgrade_1', 'jeanne_purge_the_unjust_upgrade_3', true)
				
			else
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust_saint', 'jeanne_purge_the_unjust_saint_upgrade_2', false)
				UpgradeAttribute(hero, 'jeanne_purge_the_unjust', 'jeanne_purge_the_unjust_upgrade_2', true)
				
			end

			if hero.IsDivineSymbolAcquired then
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint_upgrade_1', 'jeanne_luminosite_eternelle_saint_upgrade_3', false)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_upgrade_1', 'jeanne_luminosite_eternelle_upgrade_3', true)
				
			else
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle_saint', 'jeanne_luminosite_eternelle_saint_upgrade_2', false)
				UpgradeAttribute(hero, 'jeanne_luminosite_eternelle', 'jeanne_luminosite_eternelle_upgrade_2', true)
				
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end