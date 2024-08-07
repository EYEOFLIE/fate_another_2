function OnIncantationStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local manarestore = ability:GetSpecialValueFor("mana_restore")
	local cd_reduction = ability:GetSpecialValueFor("cd_reduction")
	local han_bonus = ability:GetSpecialValueFor("han_bonus") / 100

	if target == caster then 
		manarestore = manarestore * (1 +  han_bonus)
	end

	if not IsManaLess(target) then
		target:GiveMana(manarestore)
	end

	if caster.IsIncantationAcquired then
		for i=0, 16 do 
			local abilities = target:GetAbilityByIndex(i)
			if abilities ~= nil then
				if abilities.IsResetable ~= false then
					if not abilities:IsCooldownReady() then 
						local remain_cd = abilities:GetCooldownTimeRemaining()
						abilities:EndCooldown()

						if target:HasModifier("modifier_hans_combo_buff") then
							abilities:StartCooldown(remain_cd - remain_cd * cd_reduction / 50)
						else
							abilities:StartCooldown(remain_cd - remain_cd * cd_reduction / 100)
						end
					end
				end
			else 
				break
			end
		end
	end

	target:EmitSound("Hans.IncantationSFX")
    local particle = ParticleManager:CreateParticle("particles/hans/incantation/hans_incantation.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target) --STILL QUESTIONABLE
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

    HansCheckCombo(caster,ability)
end

function OnNightingaleStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local hprestore = ability:GetSpecialValueFor("health_restore")
	local hppercrestore = ability:GetSpecialValueFor("health_restore_from_max_health")
	local bonus_duration_per_int = ability:GetSpecialValueFor("bonus_duration_per_int")
	local duration = ability:GetSpecialValueFor("buff_duration")

	hprestore = hprestore + target:GetMaxHealth() * hppercrestore / 100
	local stat = false 
	if target == caster then 
		stat = true 
	end

	if caster.IsNightingaleRefined then
		local int_scale = ability:GetSpecialValueFor("int_scale")
		hprestore = hprestore + (int_scale * caster:GetIntellect())
	end
	
	if target:HasModifier("modifier_hans_combo_buff") then
		hprestore = hprestore * 2
	end

	target:FateHeal(hprestore, caster, stat)

	caster:EmitSound("Hans.Nightingale")
	target:EmitSound("Hans.NightingaleSFX")
    local particle = ParticleManager:CreateParticle("particles/hans/nightingale/hans_nightingale.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target) --STILL QUESTIONABLE
    local bonusdur = caster:GetIntellect() * bonus_duration_per_int
    local totalduration = duration + bonusdur
	ability:ApplyDataDrivenModifier(caster, target, "modifier_hans_nightingale_buff", {duration = totalduration})
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
end

function OnComboWindow(keys)
	local caster = keys.caster
	if caster.IsLetterAcquired == true then
		caster:SwapAbilities(caster.RSkill, "hans_combo_upgrade", false, true)
	else
		caster:SwapAbilities(caster.RSkill, "hans_combo", false, true)
	end
end

function OnComboWindowBroken(keys)
	local caster = keys.caster	

	if caster.IsLetterAcquired == true then
		caster:SwapAbilities("hans_combo_upgrade" , caster.RSkill , false, true)
	else
		caster:SwapAbilities("hans_combo", caster.RSkill, false, true)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_hans_combo_window")
end

function HansCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
    	if string.match(ability:GetAbilityName(), "hans_incantation") and not caster:HasModifier("modifier_hans_combo_cooldown") then 
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_combo_window", {})
        end
    end
end

function OnComboStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local duration = ability:GetSpecialValueFor("duration")
	local bonus_duration_per_int = ability:GetSpecialValueFor("bonus_duration_per_int")
	local master_mana = ability:GetSpecialValueFor("master_mana_gain")
	local master_health = ability:GetSpecialValueFor("master_health_gain")
	local spell_amp = ability:GetSpecialValueFor("bonus_magical_damage")

	target.MasterUnit:GiveMana(master_mana)
	target.MasterUnit2:GiveMana(master_mana)
	target.MasterUnit:Heal(master_health, nil)
	target.MasterUnit2:Heal(master_health, nil)
	caster:RemoveModifierByName("modifier_hans_combo_window")
	EmitGlobalSound("Hans.Combo")

	StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.8})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_combo_cooldown", {Duration = ability:GetCooldown(1)})

	Timers:CreateTimer(0.3, function()
		FreezeAnimation(caster,cast_delay - 0.6)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.5)
	end)	


	Timers:CreateTimer(cast_delay, function()

		if caster:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/hans/combo/hans_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --STILL QUESTIONABLE
	   		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

		    local bonusdur = caster:GetIntellect() * bonus_duration_per_int
		    local totalduration = duration + bonusdur

			ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_combo_buff_self", {duration = totalduration})
			if target == caster then
			else
				ability:ApplyDataDrivenModifier(caster, target, "modifier_hans_combo_buff", {duration = totalduration})
			end
			ability:ApplyDataDrivenModifier(caster, target, "modifier_hans_combo_level_up", {duration = totalduration+2})

			GiveSpellAmp(caster,totalduration,spell_amp,caster,ability)
			if target == caster then
			else
				GiveSpellAmp(target,totalduration,spell_amp,caster,ability)
			end

			Timers:CreateTimer(totalduration+0.5, function()
				if target:HasModifier("modifier_hans_combo_level_up") then
					target:HeroLevelUp(true)						
					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_arc.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --STILL QUESTIONABLE
					ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_break_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --STILL QUESTIONABLE
					ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())					
					local particle = ParticleManager:CreateParticle("particles/econ/items/nightstalker/nightstalker_ti10_silence/nightstalker_ti10_aura_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --STILL QUESTIONABLE
					ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
					target:RemoveModifierByName("modifier_hans_combo_level_up")
				end
			end)
		end

	end)
end

function OnComboThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	local outofcombatrange = ability:GetSpecialValueFor("out_of_combat_range")
	local manarestore = ability:GetSpecialValueFor("bonus_mana_regen_out_of_combat")
	local healthrestore = ability:GetSpecialValueFor("bonus_health_regen_out_of_combat")
	local bonus_cd_red = ability:GetSpecialValueFor("bonus_cd_red")

	local targets = FindUnitsInRadius(target:GetTeam(), target:GetAbsOrigin(), nil, outofcombatrange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	if targets[1] ~= nil then
		return
	end

	if not IsManaLess(target) then	
		target:GiveMana(manarestore)
	end

	target:Heal(healthrestore, nil)

	for i=0, 5 do 
		local abilities = target:GetAbilityByIndex(i)
		if abilities ~= nil then
			if abilities.IsResetable ~= false then				

				if target == caster then 
					local remain_cd = abilities:GetCooldownTimeRemaining()
					abilities:EndCooldown()
					abilities:StartCooldown(remain_cd - bonus_cd_red / 2)
					break
				end

				if not abilities:IsCooldownReady() and target ~= caster then 
					local remain_cd = abilities:GetCooldownTimeRemaining()
					abilities:EndCooldown()
					abilities:StartCooldown(remain_cd - bonus_cd_red)
				end
			end
		else 
			break
		end
	end
end

function OnCommandFilter(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if target == caster or not target:IsRealHero() then 
		caster:Interrupt() 
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
        return 
	end
end


function OnMasterpieceOpen(keys)
	local caster = keys.caster
	local ability = keys.ability 

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_masterpiece_open", {})

		if caster.IsObservationAcquired then 
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "hans_masterpiece_match_girl_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hans_masterpiece_red_shoes_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "hans_masterpiece_snow_queen_upgrade", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hans_masterpiece_close", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "hans_masterpiece_match_girl", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "hans_masterpiece_red_shoes", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "hans_masterpiece_snow_queen", false, true)
			caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "hans_masterpiece_close", false, true)
		end

		if caster.IsThumbelinaAcquired then
			if caster.IsObservationAcquired then 
				caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "hans_masterpiece_thumbelina_upgrade", false, true)
			else
				caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "hans_masterpiece_thumbelina", false, true)
			end
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "fate_empty2", false, true)
		end
end

function OnMasterpieceUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local hero = caster.HeroUnit

	caster:FindAbilityByName("hans_masterpiece_red_shoes"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_snow_queen"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_match_girl"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_thumbelina"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_red_shoes_upgrade"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_snow_queen_upgrade"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_match_girl_upgrade"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("hans_masterpiece_thumbelina_upgrade"):SetLevel(ability:GetLevel())
end

function OnMasterpieceClose(keys)
	local caster = keys.caster
	local ability = keys.ability 

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)

	caster:RemoveModifierByName("modifier_hans_masterpiece_open")
end

function OnBiographyThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local outofcombatrange = ability:GetSpecialValueFor("out_of_combat_range")
	local manarestore = ability:GetSpecialValueFor("bonus_mana_regen_out_of_combat")

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, outofcombatrange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	if targets[1] ~= nil then
		return
	end
	
	caster:GiveMana(manarestore * caster:GetIntellect())
end

function OnBiographyUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local hero = caster.HeroUnit
	local ability_bonus_damage = ability:GetSpecialValueFor("bonus_spell_damage")

	if ability:GetLevel() == 2 then
		caster.IsIncantationAcquired = true
		if caster:FindModifierByName("modifier_hans_masterpiece_open") == nil then
			caster:SwapAbilities(caster.QSkill, "hans_incantation_upgrade", false, true)
		end
		caster:FindAbilityByName("hans_incantation_upgrade"):SetLevel(caster:FindAbilityByName("hans_incantation"):GetLevel())
		caster.QSkill = "hans_incantation_upgrade"
	end

	if ability:GetLevel() == 4 then
		if caster:FindModifierByName("modifier_hans_masterpiece_open") == nil then
			caster:SwapAbilities(caster.DSkill, "hans_naked_king", false, true)
		end
		caster.DSkill = "hans_naked_king"
	end

	if ability:GetLevel() == 5 then
		caster:SetModifierStackCount("modifier_hans_bonus_damage", caster, ability_bonus_damage)
	end
end

function OnRedShoes(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local delay = ability:GetSpecialValueFor("delay")
	local damage = ability:GetSpecialValueFor("damage")

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	caster:EmitSound("Hans.RedShoes")

	Timers:CreateTimer(delay, function()
		local particle = ParticleManager:CreateParticle("particles/hans/redshoes/hans_shoes.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --STILL QUESTIONABLE
   		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

		ability:ApplyDataDrivenModifier(caster, target, "modifier_hans_red_shoes", {})

		local bonusdamage = caster:GetModifierStackCount("modifier_hans_bonus_damage", caster) or 0
	    DoDamage(caster, target, damage + bonusdamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end)
end

function OnSnowQueen(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local targetPoint = ability:GetCursorPosition()

	caster:EmitSound("Hans.Snowqueen")

	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

		EmitSoundOnLocationWithCaster(targetPoint, "Hans.SnowQueenSFX", caster)
   		local particle = ParticleManager:CreateParticle("particles/hans/snowqueen/hans_snowqueen.vpcf", PATTACH_CUSTOMORIGIN, caster)
   		ParticleManager:SetParticleControl(particle, 0, targetPoint)

		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				if not IsImmuneToSlow(v) then
	        		ability:ApplyDataDrivenModifier(caster, v, "modifier_hans_snow_queen", {})
	        	end

				local bonusdamage = caster:GetModifierStackCount("modifier_hans_bonus_damage", caster) or 0
				local wskill = caster:FindAbilityByName(caster.WSkill)
				local wscale = wskill:GetSpecialValueFor("bonus_snow_queen_damage")
		       	DoDamage(caster, v, damage + bonusdamage + wscale, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	       	end
	    end
	end)
end

function OnHumanObserve(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local delay = ability:GetSpecialValueFor("cast_delay")
	local duration = ability:GetSpecialValueFor("duration")
	local spell_amp = ability:GetSpecialValueFor("bonus_spell_amp")

	Timers:CreateTimer(delay, function()
		if caster:IsAlive() and target:IsAlive() then
	   		local particle = ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/phantom_lancer_fall20_immortal/phantom_lancer_fall20_immortal_doppelganger_pattern_glow.vpcf", PATTACH_CUSTOMORIGIN, caster)
	   		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

			target:EmitSound("Hans.ObservationSFX")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_hans_observation", {})
			GiveSpellAmp(target,duration,spell_amp,caster,ability)
		end
	end)
end

function OnNakedKingStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local pid = caster:GetPlayerOwner():GetPlayerID()

	local duration = ability:GetSpecialValueFor( "illusion_duration" )
	local amount = ability:GetSpecialValueFor( "illusion_amount" )
	if caster.illusion == nil then 
		caster.illusion = {}
	end

	caster:EmitSound("Hans.NakedKingSFX")

	caster.illusion = CreateIllusions( caster, caster, {duration = duration, outgoing_damage = 0, incoming_damage = 100}, amount, 0, true, true )

	for i = 1,amount do 
		ability:ApplyDataDrivenModifier(caster, caster.illusion[i], "modifier_hans_illusion", {})
		--Attributes:ModifyBonuses(caster.illusion[i])
		caster.illusion[i]:SetHealth(caster:GetHealth())
		caster.illusion[i]:SetMana(caster:GetMana())

		local move = {
			UnitIndex = caster.illusion[i]:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	 		Position = caster.illusion[i]:GetAbsOrigin() + RandomVector(1000) , 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(move)
		end)
	end
	-- Summon spooky skeletal 
	--[[local spooky = CreateUnitByName("medea_skeleton_warrior", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	spooky:SetControllableByPlayer(pid, true)
	spooky:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	FindClearSpaceForUnit(spooky, spooky:GetAbsOrigin(), true)

	ability:ApplyDataDrivenModifier(caster, spooky, "modifier_hans_illusion", {})
	spooky:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})

	-- Set skeletal stat according to parameters
	spooky:SetMaxHealth(caster:GetMaxHealth())
	spooky:SetHealth(caster:GetHealth())
	spooky:SetMaxMana(caster:GetMaxMana())
	spooky:SetMana(caster:GetMana())
	spooky:SetModel("models/han/default/han_by_zefiroft.vmdl")
	spooky:SetOriginalModel("models/han/default/han_by_zefiroft.vmdl")
	spooky:SetModelScale(1.25)	

	local spooky2 = CreateUnitByName("medea_skeleton_warrior", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	spooky2:SetControllableByPlayer(pid, true)
	spooky2:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	FindClearSpaceForUnit(spooky2, spooky2:GetAbsOrigin(), true)

	ability:ApplyDataDrivenModifier(caster, spooky2, "modifier_hans_illusion", {})
	spooky2:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})

	-- Set skeletal stat according to parameters
	spooky2:SetMaxHealth(caster:GetMaxHealth())
	spooky2:SetHealth(caster:GetHealth())
	spooky2:SetMaxMana(caster:GetMaxMana())
	spooky2:SetMana(caster:GetMana())
	spooky2:SetModel("models/han/default/han_by_zefiroft.vmdl")
	spooky2:SetOriginalModel("models/han/default/han_by_zefiroft.vmdl")
	spooky2:SetModelScale(1.25)	]]
--[[
	local illusion = CreateIllusions( caster, caster, {outgoing_damage = 0,incoming_damage = incoming,duration = duration}, amount, 0, true, true )

	illusion[1].TempestDouble = true
	illusion[2].TempestDouble = true
	illusion[1]:SetBaseAgility(0)
	illusion[1]:SetBaseIntellect(0)
	illusion[1]:SetBaseStrength(0)
	illusion[2]:SetBaseAgility(0)
	illusion[2]:SetBaseIntellect(0)
	illusion[2]:SetBaseStrength(0)

	for i=30,0,-1 do
		
		if illusion[1]:GetAbilityByIndex(i) == nil then
		else
			illusion[1]:GetAbilityByIndex(i):SetLevel(0)
			illusion[2]:GetAbilityByIndex(i):SetLevel(0)
		end
	end

	ability:ApplyDataDrivenModifier(caster, illusion[1], "modifier_hans_illusion", {})
	ability:ApplyDataDrivenModifier(caster, illusion[2], "modifier_hans_illusion", {})
]]--
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_invis", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_naked_king_cooldown", {Duration = ability:GetCooldown(1)})
end

function OnAmbushDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_hans_invis")
end

function OnAmbushCast(keys)
	local caster = keys.caster
	local ability = keys.event_ability
	if IsSpellBook(ability:GetAbilityName()) then 
		return
	else
		caster:RemoveModifierByName("modifier_hans_invis")
	end
end

function OnTerritoryCreation(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("cast_delay")
	local root_duration = ability:GetSpecialValueFor("root_duration")
	local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
	local targetpos = caster:GetAbsOrigin() + Vector(1,1,0)


	Timers:CreateTimer(delay, function()

		EmitGlobalSound("Hans.Territory")
		EmitGlobalSound("Hans.TerritorySFX")

   		local particle = ParticleManager:CreateParticle("particles/hans/workshop/hansworkshop.vpcf", PATTACH_CUSTOMORIGIN, caster)
   		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

		local enemies = FindUnitsInRadius(caster:GetTeam(), targetpos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for k,v in pairs(enemies) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				giveUnitDataDrivenModifier(caster, v, "muted", debuff_duration)
				giveUnitDataDrivenModifier(caster, v, "silenced", debuff_duration)
				if not IsImmuneToCC(v) then
					giveUnitDataDrivenModifier(caster, v, "rooted", root_duration)
				end
	       	end
	    end

		for i=duration,0,-1 do	
			Timers:CreateTimer(i, function()

				local enemies = FindUnitsInRadius(caster:GetTeam(), targetpos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				local allies = FindUnitsInRadius(caster:GetTeam(), targetpos, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

					for k,v in pairs(enemies) do
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
							ability:ApplyDataDrivenModifier(caster, v, "modifier_hans_territory_debuff", {Duration = 1})
				       	end
				    end

					for k,v in pairs(allies) do
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
							ability:ApplyDataDrivenModifier(caster, v, "modifier_hans_territory_buff", {Duration = 1})
				       	end
				    end
			end)
		end
	end)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hans_territory_cooldown", {Duration = ability:GetCooldown(1)})
end

--[[
function OnMatchGirl(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local delay = ability:GetSpecialValueFor("cast_delay")
	local linger = ability:GetSpecialValueFor("linger_duration")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local dps = ability:GetSpecialValueFor("dps")
	local targetPoint = ability:GetCursorPosition()

	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

		local particle = ParticleManager:CreateParticle("particles/hans/matchgirl/hansfire.vpcf", PATTACH_CUSTOMORIGIN, caster)
   		ParticleManager:SetParticleControl(particle, 0, targetPoint)

		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
		       	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	       	end
	    end
	end)


	Timers:CreateTimer(delay, function()
		for i=linger,0,-1 do	
			Timers:CreateTimer(i, function()
				local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				       	DoDamage(caster, v, dps, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			       	end
			    end
			end)
		end
	end)
end
]]--

function OnThumbelina(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun")
	local revoke_duration = ability:GetSpecialValueFor("revoke")
	local targetPoint = ability:GetCursorPosition()

	caster:EmitSound("Hans.Thumbelina")

	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

		EmitSoundOnLocationWithCaster(targetPoint, "Hans.ThumbelinaSFX", caster)
		local particle = ParticleManager:CreateParticle("particles/hans/thumbelina/hansthumb.vpcf", PATTACH_CUSTOMORIGIN, caster)
   		ParticleManager:SetParticleControl(particle, 0, targetPoint)

		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then

				local bonusdamage = caster:GetModifierStackCount("modifier_hans_bonus_damage", caster) or 0
		       	DoDamage(caster, v, damage + bonusdamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

		       	if not IsImmuneToCC(v) then
					v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun_duration })
				end
				giveUnitDataDrivenModifier(caster, v, "pause_sealdisabled", revoke_duration)
	       	end
	    end
	end)
end

function OnRedShoesThink(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local randx = RandomInt(-25, 25)
	local randy = RandomInt(-25, 25)

	if target:IsAlive() then
		target:SetAbsOrigin(target:GetAbsOrigin() + Vector(randx, randy, 0))
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
	end
end

function OnNightingaleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsNightingaleRefined) then

		hero.IsNightingaleRefined = true

		if hero:FindModifierByName("modifier_hans_masterpiece_open") == nil then
			UpgradeAttribute(hero, "hans_nightingale", "hans_nightingale_upgrade" , true)
		else
			UpgradeAttribute(hero, "hans_nightingale", "hans_nightingale_upgrade" , false)
		end

		hero.WSkill = "hans_nightingale_upgrade"

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

		hero.IsTerritoryAcquired = true

		if hero:FindModifierByName("modifier_hans_masterpiece_open") == nil then
			UpgradeAttribute(hero, "hans_territory", "hans_territory_upgrade" , true)
		else
			UpgradeAttribute(hero, "hans_territory", "hans_territory_upgrade" , false)
		end

		hero.FSkill = "hans_territory_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnThumbelinaAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsThumbelinaAcquired) then

		hero.IsThumbelinaAcquired = true

		if hero:FindModifierByName("modifier_hans_masterpiece_open") == nil then
			if hero.IsObservationAcquired then
				UpgradeAttribute(hero, "hans_masterpiece_open_observation", "hans_masterpiece_open_upgrade" , true)
				hero.ESkill = "hans_masterpiece_open_upgrade"
			else
				UpgradeAttribute(hero, "hans_masterpiece_open", "hans_masterpiece_open_thumbelina" , true)
				hero.ESkill = "hans_masterpiece_open_thumbelina"
			end
		else
			if hero.IsObservationAcquired then
				hero:SwapAbilities(hero:GetAbilityByIndex(3):GetAbilityName(), "hans_masterpiece_thumbelina_upgrade", false, true)
				UpgradeAttribute(hero, "hans_masterpiece_open_observation", "hans_masterpiece_open_upgrade" , false)
				hero.ESkill = "hans_masterpiece_open_upgrade"
			else
				hero:SwapAbilities(hero:GetAbilityByIndex(3):GetAbilityName(), "hans_masterpiece_thumbelina", false, true)
				UpgradeAttribute(hero, "hans_masterpiece_open", "hans_masterpiece_open_thumbelina" , false)
				hero.ESkill = "hans_masterpiece_open_thumbelina"
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end


function OnObservationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsObservationAcquired) then

		hero.IsObservationAcquired = true

		if hero:FindModifierByName("modifier_hans_masterpiece_open") == nil then			
			if hero.IsThumbelinaAcquired then
				UpgradeAttribute(hero, "hans_masterpiece_open_thumbelina", "hans_masterpiece_open_upgrade" , true)
				hero.ESkill = "hans_masterpiece_open_upgrade"
			else
				UpgradeAttribute(hero, "hans_masterpiece_open", "hans_masterpiece_open_observation" , true)
				hero.ESkill = "hans_masterpiece_open_observation"
			end
		else
			if hero.IsThumbelinaAcquired then
				hero:SwapAbilities(hero:GetAbilityByIndex(0):GetAbilityName(), "hans_masterpiece_match_girl_upgrade", false, true)
				hero:SwapAbilities(hero:GetAbilityByIndex(1):GetAbilityName(), "hans_masterpiece_red_shoes_upgrade", false, true)
				hero:SwapAbilities(hero:GetAbilityByIndex(2):GetAbilityName(), "hans_masterpiece_snow_queen_upgrade", false, true)
				hero:SwapAbilities(hero:GetAbilityByIndex(3):GetAbilityName(), "hans_masterpiece_thumbelina_upgrade", false, true)
				UpgradeAttribute(hero, "hans_masterpiece_open_thumbelina", "hans_masterpiece_open_upgrade" , false)
				hero.ESkill = "hans_masterpiece_open_upgrade"
			else
				hero:SwapAbilities(hero:GetAbilityByIndex(0):GetAbilityName(), "hans_masterpiece_match_girl_upgrade", false, true)
				hero:SwapAbilities(hero:GetAbilityByIndex(1):GetAbilityName(), "hans_masterpiece_red_shoes_upgrade", false, true)
				hero:SwapAbilities(hero:GetAbilityByIndex(2):GetAbilityName(), "hans_masterpiece_snow_queen_upgrade", false, true)
				UpgradeAttribute(hero, "hans_masterpiece_open", "hans_masterpiece_open_observation" , false)
				hero.ESkill = "hans_masterpiece_open_observation"
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnLetterAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLetterAcquired) then

		hero.IsLetterAcquired = true
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end