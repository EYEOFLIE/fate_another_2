QUEST_1 = false
QUEST_2 = false
QUEST_3 = false
QUEST_3a = false
QUEST_3b = false
QUEST_4 = false
QUEST_4a = false
QUEST_4b = false
QUEST_5 = false
QUEST_6 = false
QUEST_7 = false
QUEST_8 = false
QUEST_9 = false
QUEST_9a = false
QUEST_9b = false
QUEST_9c = false
QUEST_10 = false
QUEST_10a = false
QUEST_10b = false
QUEST_10c = false
QUEST_10d = false
QUEST_10e = false
QUEST_11 = false
QUEST_11a = false
QUEST_11b = true
QUEST_12 = false
QUEST_12a = false
QUEST_12b = false
QUEST_13 = false
QUEST_14 = false
QUEST_14a = false
QUEST_14b = false
QUEST_15 = false
QUEST_16 = false
QUEST_16a = false
QUEST_Fail = false
function TutorialSaber(hero)
	local heroname = hero:GetName()
	local abilities = {}
	local tutorial_data = {
		hero = heroname,
		questID = 0,
		page = 1,
	}
	if heroname == "npc_dota_hero_legion_commander" then 
		Timers:CreateTimer(5.0, function()
			CustomNetTables:SetTableValue("tutorial", "hero",{heroname})
			print("Send Table Tutorial Saber !!!")
			CustomNetTables:SetTableValue("tutorial", "page", {page = 1})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 0})
		end)
	end
	for i = 0,5 do 
		table.insert(abilities, i+1 , hero:GetAbilityByIndex(i):GetAbilityName())
	end
	giveUnitDataDrivenModifier(hero, hero, "round_pause", 9999)
	CustomNetTables:SetTableValue("tutorial", "ability",abilities)
	CustomGameEventManager:RegisterListener("tutorial_fate_quest", QuestStart )
end

function QuestStart(self, args)
    local playerId = args.playerId
    local hero = EntIndexToHScript(args.servant) 
    questID = args.questID

    if hero:GetName() == "npc_dota_hero_legion_commander" then 
    	if questID == 1 and QUEST_1 == false then 
    		Quest1Start(hero)
    	elseif questID == 2 and QUEST_2 == false then 
    		Quest2Start(hero)
    	elseif questID == 3 and QUEST_3 == false then 
    		Quest3Start(hero)
    	elseif questID == 4 and QUEST_4 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 4 then return end
				Quest4Start(hero)
			return 5.0
			end)
    	elseif questID == 5 and QUEST_5 == false then 
    		Quest5Start(hero)
    	elseif questID == 6 and QUEST_6 == false then 
    		Quest6Start(hero)
    	elseif questID == 7 and QUEST_7 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 7 then return end
				Quest7Start(hero)
			return 20.0
			end)
    	elseif questID == 8 and QUEST_8 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 8 then return end
				Quest8Start(hero)
			return 5.0
			end)
    	elseif questID == 9 and QUEST_9 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 9 then return end
				Quest9Start(hero)
			return 10.0
			end)
    	elseif questID == 10 and QUEST_10 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 10 then return end
				Quest10Start(hero)
			return 20.0
			end)
    	elseif questID == 11 and QUEST_11 == false then 
    		Quest11Start(hero)
    	elseif questID == 12 and QUEST_12 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 12 then return end
				Quest12Start(hero)
			return 5.0
			end)
    	elseif questID == 13 and QUEST_13 == false then
    		Timers:CreateTimer(0.1, function()
				if questID > 13 then return end
				Quest13Start(hero)
			return 5.0
			end)
    	elseif questID == 14 and QUEST_14 == false then 
    		Timers:CreateTimer(0.1, function()
				if questID > 14 then return end
				Quest14Start(hero)
			return 5.0
			end)
    	elseif questID == 15 and QUEST_15 == false then 
    		Quest15Start(hero)
    	elseif questID == 16 and QUEST_15 == false then 
    		QUEST_15 = true
    		print('Quest 15 Finish')
			hero:RemoveModifierByName("modifier_quest_01")
			Timers:CreateTimer(2.0, function()
				CustomNetTables:SetTableValue("tutorial", "page", {page = 45})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 16})
			end)
    	elseif questID == 17 and QUEST_15 == true and QUEST_16 == false then 
    		Quest16Start(hero)
    	end
    end
end

function Quest1Start(hero)
	if Quest == nil then 
		Quest = {}
	end
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 1 then return end
		if Quest.QUEST_1 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		local herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(800,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
		FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
		for i = 0,5 do 
			herc:GetAbilityByIndex(i):SetLevel(1)
		end
		herc:GetAbilityByIndex(5):SetLevel(5)
		print(herc)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
	end
end

function Quest2Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 2 then return end
		if Quest.QUEST_2 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if IsValidEntity(herc) and herc:IsAlive() then 
			herc:SetHealth(herc:GetMaxHealth())
			herc:SetMana(herc:GetMaxMana())
			herc:RemoveModifierByName("round_pause")
		else 
			herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(300,0,0))
	        herc:RespawnHero(false, false) 
	    end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
	end
end

function Quest3Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 3 then return end
		if Quest.QUEST_3 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		print(herc:GetName())
		if IsValidEntity(herc) and herc:IsAlive() then 
			herc:SetHealth(herc:GetMaxHealth())
			herc:SetMana(herc:GetMaxMana())
			herc:RemoveModifierByName("round_pause")
		else 
			herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(300,0,0))
	        herc:RespawnHero(false, false) 
		end
		herc:GetAbilityByIndex(5):EndCooldown()
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local abilityindex = herc:FindAbilityByName("heracles_nine_lives"):entindex()
		local ninelives = {
			UnitIndex = herc:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, --Optional.  Only used when casting abilities
 			Position = hero:GetAbsOrigin(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.5, function()
			ExecuteOrderFromTable(ninelives)
		end)
	end
end

function Quest4Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 4 then return end
		if Quest.QUEST_4 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if herc == nil then 
			herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(200,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				herc:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(herc) and herc:IsAlive() then 
				herc:SetHealth(herc:GetMaxHealth())
				herc:SetMana(herc:GetMaxMana())
				herc:RemoveModifierByName("round_pause")
			else 
				herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(300,0,0))
		        herc:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				herc:GetAbilityByIndex(j):EndCooldown()
			end
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		herc:SetAbsOrigin(hero:GetAbsOrigin() + Vector(800,600,0))
		FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
		local walkex = {
			UnitIndex = herc:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
 			Position = herc:GetAbsOrigin() + Vector(0,-1200,0), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(walkex)
		end)
	end
end

function Quest5Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 5 then return end
		if Quest.QUEST_5 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 20)
		hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 20)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if IsValidEntity(herc) then 
			herc:RemoveSelf()
		end
	end
end

function Quest6Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 6 then return end
		if Quest.QUEST_6 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		if hero:GetLevel() < 8 then 
			for i = 1,8 - hero:GetLevel() do 
				hero:HeroLevelUp(true)
			end
		end

		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if IsValidEntity(herc) then 
			herc:RemoveSelf()
		end
	end
end

function Quest7Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 7 then return end
		if Quest.QUEST_7 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local master = hero.MasterUnit
		giveUnitDataDrivenModifier(hero, master, "modifier_quest_01", 9999)
		hero:SetMana(0)
		print(master:GetUnitName())
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if IsValidEntity(herc) then 
			herc:RemoveSelf()
		end
	end
end

function Quest8Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 8 then return end
		if Quest.QUEST_8 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if herc == nil then 
			herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(200,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				herc:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			herc:SetHealth(herc:GetMaxHealth())
			herc:SetMana(herc:GetMaxMana())
			for j = 0,5 do 
				herc:GetAbilityByIndex(j):EndCooldown()
			end
		end
		FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
		for i = 0,5 do 
			herc:GetAbilityByIndex(i):SetLevel(1)
		end
		herc:GetAbilityByIndex(5):SetLevel(5)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		giveUnitDataDrivenModifier(hero, hero.MasterUnit, "modifier_quest_01", 9999)
		local abilityindex = herc:FindAbilityByName("heracles_nine_lives"):entindex()
		local ninelives = {
			UnitIndex = herc:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, --Optional.  Only used when casting abilities
 			Position = hero:GetAbsOrigin(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.5, function()
			ExecuteOrderFromTable(ninelives)
		end)
	end
end

function Quest9Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 9 then return end
		if Quest.QUEST_9 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if herc == nil then 
			herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(200,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				herc:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(herc) and herc:IsAlive() then 
				herc:SetHealth(herc:GetMaxHealth())
				herc:SetMana(herc:GetMaxMana())
				herc:RemoveModifierByName("round_pause")
			else 
				herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(300,0,0))
		        herc:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				herc:GetAbilityByIndex(j):EndCooldown()
			end
		end
		FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		herc:SetAbsOrigin(hero:GetAbsOrigin() + Vector(200,0,0))
		giveUnitDataDrivenModifier(hero, hero.MasterUnit, "modifier_quest_01", 9999)
	end
end

function Quest10Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 10 then return end
		if Quest.QUEST_10 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if herc == nil then 
			herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(200,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				herc:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(herc) and herc:IsAlive() then 
				herc:SetHealth(herc:GetMaxHealth())
				herc:SetMana(herc:GetMaxMana())
				herc:RemoveModifierByName("round_pause")
			else 
				herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(300,0,0))
		        herc:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				herc:GetAbilityByIndex(j):EndCooldown()
			end
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)	
		hero:RemoveModifierByName("round_pause")
		herc:SetAbsOrigin(hero:GetAbsOrigin() + Vector(200,0,0))
		FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
		giveUnitDataDrivenModifier(hero, hero.MasterUnit, "modifier_quest_01", 9999)
		hero:SetMana(800)
	end
end

function Quest11Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 11 then return end
		if Quest.QUEST_11 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if IsValidEntity(herc) then 
			herc:RemoveSelf()
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local c_scroll = hero:FindItemInInventory("item_c_scroll")
		if not c_scroll then 
			c_scroll = CreateItem("item_c_scroll", hero, hero)
			hero:AddItem(c_scroll)
		end
		c_scroll:EndCooldown()
		local sasaki = Entities:FindByClassname(nil, "npc_dota_hero_juggernaut")
		if sasaki == nil then 
			sasaki = CreateUnitByName("npc_dota_hero_juggernaut", hero:GetAbsOrigin() + Vector(200,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				sasaki:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(sasaki) and sasaki:IsAlive() then 
				sasaki:SetHealth(sasaki:GetMaxHealth())
				sasaki:SetMana(sasaki:GetMaxMana())
				sasaki:RemoveModifierByName("round_pause")
			else 
				sasaki:SetRespawnPosition(hero:GetAbsOrigin() + Vector(200,0,0))
		        sasaki:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				sasaki:GetAbilityByIndex(j):EndCooldown()
			end
		end
		FindClearSpaceForUnit(sasaki, hero:GetAbsOrigin() + Vector(200,0,0), true)
		sasaki:GetAbilityByIndex(5):SetLevel(5)
		local abilityindex = sasaki:FindAbilityByName("false_assassin_tsubame_gaeshi"):entindex()
		local tg = {
			UnitIndex = sasaki:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
 			AbilityIndex = abilityindex, --Optional.  Only used when casting abilities
 			TargetIndex = hero:entindex(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(tg)
			print('tsubame')
		end)
	end
end

function Quest12Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 12 then return end
		if Quest.QUEST_12 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local sasaki = Entities:FindByClassname(nil, "npc_dota_hero_juggernaut")
		if IsValidEntity(sasaki) then 
			sasaki:RemoveSelf()
		end
		local c_scroll = hero:FindItemInInventory("item_c_scroll")
		if c_scroll then 
			hero:RemoveItem(c_scroll)
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local b_scroll = hero:FindItemInInventory("item_b_scroll")
		local a_scroll = hero:FindItemInInventory("item_a_scroll")
		if not b_scroll then 
			b_scroll = CreateItem("item_b_scroll", hero, hero)
			hero:AddItem(b_scroll)
		end
		if not a_scroll then 
			a_scroll = CreateItem("item_a_scroll", hero, hero)
			hero:AddItem(a_scroll)
		end
		b_scroll:EndCooldown()
		a_scroll:EndCooldown()
		local medusa = Entities:FindByClassname(nil, "npc_dota_hero_templar_assassin")
		if medusa == nil then 
			medusa = CreateUnitByName("npc_dota_hero_templar_assassin", hero:GetAbsOrigin() + Vector(-900,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				medusa:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(medusa) and medusa:IsAlive() then 
				medusa:SetHealth(medusa:GetMaxHealth())
				medusa:SetMana(medusa:GetMaxMana())
				medusa:RemoveModifierByName("round_pause")
			else 
				medusa:SetRespawnPosition(hero:GetAbsOrigin() + Vector(-900,0,0))
		        medusa:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				medusa:GetAbilityByIndex(j):EndCooldown()
			end
		end
		FindClearSpaceForUnit(medusa, hero:GetAbsOrigin() + Vector(-900,0,0), true)
		
		medusa:GetAbilityByIndex(5):SetLevel(5)
		local abilityindex = medusa:GetAbilityByIndex(5):entindex()
		local belle = {
			UnitIndex = medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, 
 			Position = hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(belle)
		end)
	end
end

function Quest13Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then
		if questID > 13 then return end
		if Quest.QUEST_13 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		local b_scroll = hero:FindItemInInventory("item_b_scroll")
		if b_scroll then 
			hero:RemoveItem(b_scroll)
		end
		local a_scroll = hero:FindItemInInventory("item_a_scroll")
		if a_scroll then 
			hero:RemoveItem(a_scroll)
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local medusa = Entities:FindByClassname(nil, "npc_dota_hero_templar_assassin")
		if medusa == nil then 
			medusa = CreateUnitByName("npc_dota_hero_templar_assassin", hero:GetAbsOrigin() + Vector(-500,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				medusa:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(medusa) and medusa:IsAlive() then 
				medusa:SetHealth(medusa:GetMaxHealth())
				medusa:SetMana(medusa:GetMaxMana())
				medusa:RemoveModifierByName("round_pause")
			else 
				medusa:SetRespawnPosition(hero:GetAbsOrigin() + Vector(-500,0,0))
		        medusa:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				medusa:GetAbilityByIndex(j):EndCooldown()
			end
		end
		FindClearSpaceForUnit(medusa, hero:GetAbsOrigin() + Vector(-500,0,0), true)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local s_scroll = hero:FindItemInInventory("item_s_scroll")
		if not s_scroll then 
			s_scroll = CreateItem("item_s_scroll", hero, hero)
			hero:AddItem(s_scroll)
		end
		s_scroll:EndCooldown()
		local move = {
			UnitIndex = medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
 			Position = medusa:GetAbsOrigin() + Vector(-800,0,0), 
		}
		Timers:CreateTimer(0.01, function()
			ExecuteOrderFromTable(move)
		end)
	end
end

function Quest14Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		if questID > 14 then return end
		if Quest.QUEST_14 == true then return end
		if hero:HasModifier("modifier_quest_01") then 
			hero:RemoveModifierByName("modifier_quest_01")
		end
		local s_scroll = hero:FindItemInInventory("item_s_scroll")
		if s_scroll then 
			hero:RemoveItem(s_scroll)
		end
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local medusa = Entities:FindByClassname(nil, "npc_dota_hero_templar_assassin")
		if medusa == nil then 
			medusa = CreateUnitByName("npc_dota_hero_templar_assassin", hero:GetAbsOrigin() + Vector(-500,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			for i = 0,5 do 
				medusa:GetAbilityByIndex(i):SetLevel(1)
			end
		else
			if IsValidEntity(medusa) and medusa:IsAlive() then 
				medusa:SetHealth(medusa:GetMaxHealth())
				medusa:SetMana(medusa:GetMaxMana())
				medusa:RemoveModifierByName("round_pause")
			else 
				medusa:SetRespawnPosition(hero:GetAbsOrigin() + Vector(-500,0,0))
		        medusa:RespawnHero(false, false) 
			end
			for j = 0,5 do 
				medusa:GetAbilityByIndex(j):EndCooldown()
			end
		end
		local scat = Entities:FindByClassname(nil, "npc_dota_hero_monkey_king")
		if scat == nil then 
			scat = CreateUnitByName("npc_dota_hero_monkey_king", hero:GetAbsOrigin() + Vector(500,0,0), true, nil, nil, hero:GetTeamNumber())
		end	
		FindClearSpaceForUnit(medusa, hero:GetAbsOrigin() + Vector(-500,0,0), true)
		FindClearSpaceForUnit(scat, hero:GetAbsOrigin() + Vector(500,0,0), true)
		for i = 0,5 do 
			scat:GetAbilityByIndex(i):SetLevel(1)
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
		local b_scroll = hero:FindItemInInventory("item_b_scroll")
		local a_scroll = hero:FindItemInInventory("item_a_scroll")
		if b_scroll then hero:RemoveItem(b_scroll) end
		if a_scroll then hero:RemoveItem(a_scroll) end
		local link_scroll = hero:FindItemInInventory("item_spirit_link")
		if not link_scroll then 
			link_scroll = CreateItem("item_spirit_link", hero, hero)
			hero:AddItem(link_scroll)
		end
		link_scroll:EndCooldown()
		local abilityindex = medusa:GetAbilityByIndex(5):entindex()
		local belle = {
			UnitIndex = medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, 
 			Position = hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(belle)
		end)
	end
end

function Quest15Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local link_scroll = hero:FindItemInInventory("item_spirit_link")
		if link_scroll then 
			hero:RemoveItem(link_scroll)
		end
		local scat = Entities:FindByClassname(nil, "npc_dota_hero_monkey_king")
		if IsValidEntity(scat) then 
			scat:RemoveSelf()
		end
		local medusa = Entities:FindByClassname(nil, "npc_dota_hero_templar_assassin")
		if IsValidEntity(medusa) then 
			medusa:RemoveSelf()
		end
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 9999)
		hero:RemoveModifierByName("round_pause")
	end
end

function Quest16Start(hero)
	if hero:GetName() == "npc_dota_hero_legion_commander" then 
		FindClearSpaceForUnit(hero, Vector(2000,2000,200), true)
		local current_lvl = hero:GetLevel() 
		local lvl = 24 - current_lvl
		for i = 1, lvl do 
			hero:HeroLevelUp(true)
		end
		local herc = Entities:FindByClassname(nil, "npc_dota_hero_doom_bringer")
		if herc == nil then 
			herc = CreateUnitByName("npc_dota_hero_doom_bringer", hero:GetAbsOrigin() + Vector(500,0,0), true, nil, nil, hero:GetOpposingTeamNumber())
			FindClearSpaceForUnit(herc, herc:GetAbsOrigin(), true)
			for i = 3,14 do 
				herc:GetAbilityByIndex(i):SetLevel(1)
			end
			for k = 0,2 do 
				herc:GetAbilityByIndex(k):SetLevel(5)
			end
			for m = 1, 23 do 
				herc:HeroLevelUp(true)
			end
			herc:GetAbilityByIndex(5):SetLevel(5)
			herc:FindAbilityByName("attribute_bonus_custom"):SetLevel(7)
			herc:FindAbilityByName("berserker_5th_god_hand"):SetLevel(0)
			herc:FindAbilityByName("berserker_5th_madmans_roar"):SetLevel(1)
		else
			if IsValidEntity(herc) and herc:IsAlive() then 
				herc:SetHealth(herc:GetMaxHealth())
				herc:SetMana(herc:GetMaxMana())
				herc:RemoveModifierByName("round_pause")
				herc:SetAbsOrigin(hero:GetAbsOrigin() + Vector(500,0,0))
			else 
				herc:SetRespawnPosition(hero:GetAbsOrigin() + Vector(500,0,0))
		        herc:RespawnHero(false, false) 
			end
			if herc:GetLevel() < 24 then 
				for i = 3,14 do 
					herc:GetAbilityByIndex(i):SetLevel(1)
				end
				for k = 0,2 do 
					herc:GetAbilityByIndex(k):SetLevel(5)
				end
				herc:GetAbilityByIndex(5):SetLevel(5)
				for m = 1, 23 do 
					herc:HeroLevelUp(true)
				end
				herc:FindAbilityByName("attribute_bonus_custom"):SetLevel(7)
				herc:FindAbilityByName("berserker_5th_god_hand"):SetLevel(0)
			end
		end
		for j = 0,5 do 
			herc:GetAbilityByIndex(j):EndCooldown()
		end		
		local b_scroll = herc:FindItemInInventory("item_b_scroll")
		local a_scroll = herc:FindItemInInventory("item_a_scroll")
		local c_scroll = herc:FindItemInInventory("item_c_scroll")
		local s_scroll = herc:FindItemInInventory("item_s_scroll")
		local blink_scroll = herc:FindItemInInventory("item_blink_scroll")
		if not b_scroll then 
			b_scroll = CreateItem("item_b_scroll", nil, nil)
			herc:AddItem(b_scroll)
		end
		if not a_scroll then 
			a_scroll = CreateItem("item_a_scroll", nil, nil)
			herc:AddItem(a_scroll)
		end
		if not c_scroll then 
			c_scroll = CreateItem("item_c_scroll", nil, nil)
			herc:AddItem(c_scroll)
		end
		if not s_scroll then 
			s_scroll = CreateItem("item_s_scroll", nil, nil)
			herc:AddItem(s_scroll)
		end
		if not blink_scroll then 
			blink_scroll = CreateItem("item_blink_scroll", nil, nil)
			herc:AddItem(blink_scroll)
		end
		if herc:GetBaseIntellect() < 10 then 
			herc:SetBaseIntellect(10.0)
		end
		Attributes:ModifyBonuses(herc)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_01", 5)
		giveUnitDataDrivenModifier(hero, hero, "modifier_quest_0000", 9999)
		Timers:CreateTimer(5.0, function()
			hero:RemoveModifierByName("modifier_quest_01")
			hero:RemoveModifierByName("round_pause")
			giveUnitDataDrivenModifier(herc, herc, "modifier_quest_000", 9999)
		end)
		
	end
end

function Quest1Create(keys)
	local caster = keys.caster
	if (questID == 7 and QUEST_7 == false) or (questID == 8 and QUEST_8 == false) or (questID == 9 and QUEST_9 == false) then
		if caster.MasterUnit:GetHealth() < 2 then 
			caster.MasterUnit:SetHealth(caster.MasterUnit:GetHealth() + 1)
			caster.MasterUnit2:SetHealth(caster.MasterUnit:GetHealth() + 1)
		end
		if caster.MasterUnit:GetMana() == 0 then 
			caster.MasterUnit:SetMana(2)
			caster.MasterUnit2:SetMana(2)
		end
		for i = 0,5 do
			caster.MasterUnit:GetAbilityByIndex(i):EndCooldown()
		end
	elseif (questID == 10 and QUEST_10 == false) then
		if caster.MasterUnit:GetHealth() < caster.MasterUnit:GetMaxHealth() then 
			caster.MasterUnit:SetHealth(caster.MasterUnit:GetMaxHealth())
			caster.MasterUnit2:SetHealth(caster.MasterUnit:GetMaxHealth())
		end
		if caster.MasterUnit:GetMana() <= 7 then 
			caster.MasterUnit:SetMana(7)
			caster.MasterUnit2:SetMana(7)
		end
		for i = 0,5 do
			caster.MasterUnit:GetAbilityByIndex(i):EndCooldown()
		end
	end
	if questID == 1 and QUEST_1 == false then
		for i = 1,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 2 and QUEST_2 == false then 
		caster:GetAbilityByIndex(0):SetActivated(false)
		caster:GetAbilityByIndex(0):EndCooldown()
		for i = 2,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 3 and QUEST_3 == false then 
		for i = 0,1 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
		for j = 3,5 do 
			caster:GetAbilityByIndex(j):SetActivated(false)
			caster:GetAbilityByIndex(j):EndCooldown()
		end
	elseif questID == 4 and QUEST_4 == false then 
		for i = 0,4 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
		caster:GetAbilityByIndex(5):SetActivated(true)
		caster:GetAbilityByIndex(5):EndCooldown()
	elseif questID == 8 and QUEST_8 == false then 
		for i = 0,5 do 
		caster:GetAbilityByIndex(i):SetActivated(false)
		caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 9 and QUEST_9 == false then 
		caster:GetAbilityByIndex(0):SetActivated(false)
		caster:GetAbilityByIndex(0):EndCooldown()
		for i = 2,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 10 and QUEST_10 == false then
		for i = 0,4 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 11 and QUEST_11 == false then
		for i = 0,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 12 and QUEST_12 == false then
		for i = 0,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 13 and QUEST_13 == false then
		for i = 0,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	elseif questID == 14 and QUEST_14 == false then
		for i = 0,5 do 
			caster:GetAbilityByIndex(i):SetActivated(false)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
	end
	if questID == 17 and QUEST_16 == false then
	else
		caster:FindItemInInventory("item_blink_scroll"):SetActivated(false)
	end
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())

end

function QuestEnd(keys)
	local caster = keys.caster 
	if keys.unit ~= nil and keys.unit:GetUnitName() == "master_1" then 
		caster:RemoveModifierByName("modifier_quest_01")
		for i = 0,5 do
			caster.MasterUnit:GetAbilityByIndex(i):EndCooldown()
		end
	else
		for i = 0,5 do
			caster:GetAbilityByIndex(i):SetActivated(true)
			caster:GetAbilityByIndex(i):EndCooldown()
		end
		caster:FindItemInInventory("item_blink_scroll"):SetActivated(true)
		caster:SetHealth(caster:GetMaxHealth())
		caster:SetMana(caster:GetMaxMana())
		giveUnitDataDrivenModifier(caster, caster, "round_pause", 9999)
	end
end

function QuestFail (keys)
	local caster = keys.caster
	QUEST_Fail = true 
	print(questID)
	if questID == 1 and QUEST_1 == false then
		Timers:CreateTimer(2.0, function()
			caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest1Start(caster)
	    	QUEST_Fail = false
		end)
    elseif questID == 2 and QUEST_2 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest2Start(caster)
	    	QUEST_Fail = false
	    end)
    elseif questID == 3 and QUEST_3 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest3Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 4 and QUEST_4 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest4Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 5 and QUEST_5 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest5Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 6 and QUEST_6 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest6Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 7 and QUEST_7 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest7Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 8 and QUEST_8 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest8Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 9 and QUEST_9 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest9Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 10 and QUEST_10 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest10Start(caster)
	    	QUEST_Fail = false
	    end)
    elseif questID == 11 and QUEST_11 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest11Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 12 and QUEST_12 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest12Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 13 and QUEST_13 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest13Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 14 and QUEST_14 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest14Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 15 and QUEST_15 == false then 
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest15Start(caster)
	    	QUEST_Fail = false
	    end)
	elseif questID == 17 and QUEST_16 == false then 
		print('Quest 16 Restart')
    	Timers:CreateTimer(2.0, function()
	    	caster:SetRespawnPosition(Vector(2000,2000,200))
	        caster:RespawnHero(false, false) 
	    	Quest16Start(caster)
	    	QUEST_Fail = false
	    end)
    end
end

function Quest1Finish(keys)
	local caster = keys.caster 
	if Quest == nil then 
		Quest = {}
	end
	if QUEST_1 == false and questID == 1 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(0):GetAbilityName() and keys.ability:GetCursorTarget():GetName() == "npc_dota_hero_doom_bringer" then 
			QUEST_1 = true 
			Quest.QUEST_1 = QUEST_1
			print('Quest 1 Finish')
			Timers:CreateTimer(1.4, function()
				if QUEST_1 == true then 
					caster:RemoveModifierByName("modifier_quest_01")
					Timers:CreateTimer(1.7, function()
						CustomNetTables:SetTableValue("tutorial", "page", {page = 7})
						CustomNetTables:SetTableValue("tutorial", "questID", {questID = 1})
					end)
				end
			end)
		end
	elseif QUEST_2 == false and questID == 2 then 
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(1):GetAbilityName() and keys.ability:GetCursorTarget():GetName() == "npc_dota_hero_doom_bringer" then 
			QUEST_2 = true 
			Quest.QUEST_2 = QUEST_2
			print('Quest 2 Finish')
			Timers:CreateTimer(0.5, function()
				if QUEST_2 == true then 
					caster:RemoveModifierByName("modifier_quest_01")
					Timers:CreateTimer(1.7, function()
						CustomNetTables:SetTableValue("tutorial", "page", {page = 9})
						CustomNetTables:SetTableValue("tutorial", "questID", {questID = 2})
					end)
				end
			end)
		end
	elseif QUEST_3 == false and questID == 3 then 
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(2):GetAbilityName() then 
			QUEST_3a = true 
			Quest.QUEST_3 = QUEST_3
			Timers:CreateTimer({
				endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
			    QUEST_3a = false
			    end
			})
			Timers:CreateTimer(function()
				if QUEST_3a == false then return end
				if caster.IsAvalonOnCooldown == true then 
					QUEST_3b = true 
					if QUEST_3a == true and QUEST_3b == true then 
						QUEST_3 = true 
						print('Quest 3 Finish')
						Timers:CreateTimer(2.0, function()
							CustomNetTables:SetTableValue("tutorial", "page", {page = 11})
							CustomNetTables:SetTableValue("tutorial", "questID", {questID = 3})
						end)
						caster:RemoveModifierByName("modifier_quest_01")
					end
					return 
				end
				return 0.05
			end)		
		end
	elseif QUEST_4 == false and questID == 4 then 
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(5):GetAbilityName() then 
			QUEST_4a = true 
			Timers:CreateTimer(2.0, function()
				if QUEST_4a == true and QUEST_4b == true then 
					QUEST_4 = true
					Quest.QUEST_4 = QUEST_4
					print('Quest 4 Finish')
					Timers:CreateTimer(1.0, function()
						CustomNetTables:SetTableValue("tutorial", "page", {page = 13})
						CustomNetTables:SetTableValue("tutorial", "questID", {questID = 4})
					end)
					caster:RemoveModifierByName("modifier_quest_01")
				end
			end)
		end
	elseif QUEST_5 == false and questID == 5 then 
		if caster:GetCurrentActiveAbility():GetAbilityName() == "saber_strike_air" then 
			QUEST_5 = true 
			Quest.QUEST_5 = QUEST_5
			Timers:CreateTimer(2.0, function()
				print('Quest 5 Finish')
				CustomNetTables:SetTableValue("tutorial", "page", {page = 17})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 5})
			end)
			caster:RemoveModifierByName("modifier_quest_01")
		end
	elseif QUEST_6 == false and questID == 6 then 
		if caster:GetCurrentActiveAbility():GetAbilityName() == "saber_max_excalibur" then 
			QUEST_6 = true 
			Quest.QUEST_6 = QUEST_6
			Timers:CreateTimer(7.0, function()
				print('Quest 6 Finish')
				CustomNetTables:SetTableValue("tutorial", "page", {page = 21})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 6})
			end)
			caster:RemoveModifierByName("modifier_quest_01")
		end
	elseif QUEST_7 == false and questID == 7 then 
		if not keys.unit:IsRealHero() then
			if keys.event_ability:GetAbilityName() == "cmd_seal_4" and keys.unit:GetUnitName() == "master_1" then 
				QUEST_7 = true 
				Quest.QUEST_7 = QUEST_7
				Timers:CreateTimer(2.0, function()
					print('Quest 7 Finish')
					CustomNetTables:SetTableValue("tutorial", "page", {page = 26})
					CustomNetTables:SetTableValue("tutorial", "questID", {questID = 7})
				end)
				keys.unit:RemoveModifierByName("modifier_quest_01")
			end
		end
	elseif QUEST_8 == false and questID == 8 then 
		if not keys.unit:IsRealHero() then
			if keys.event_ability:GetAbilityName() == "cmd_seal_3" and keys.unit:GetUnitName() == "master_1" then 
				Timers:CreateTimer(1.0, function()
					if caster:IsAlive() then 
						QUEST_8 = true 
						Quest.QUEST_8 = QUEST_8
						keys.unit:RemoveModifierByName("modifier_quest_01")
					end
				end)
				Timers:CreateTimer(2.0, function()
					print('Quest 8 Finish')
					CustomNetTables:SetTableValue("tutorial", "page", {page = 28})
					CustomNetTables:SetTableValue("tutorial", "questID", {questID = 8})
				end)
			end
		end
	elseif QUEST_9 == false and questID == 9 then 
		if not keys.unit:IsRealHero() then
			if keys.event_ability:GetAbilityName() == "cmd_seal_2" and keys.unit:GetUnitName() == "master_1" then 
				QUEST_9b = true 
				print('Seal Reset')
			end
		end
		if keys.event_ability:GetAbilityName() == caster:GetAbilityByIndex(1):GetAbilityName() then 
			if QUEST_9a == false then 
				QUEST_9a = true
				print('Caliburn 1')
				Timers:CreateTimer({
					endTime = 4, 
					callback = function()
				    QUEST_9a = false
				end})
			elseif QUEST_9a == true and QUEST_9c == false then 
				QUEST_9c = true 
				print('Caliburn 2')
				if QUEST_9a == true and QUEST_9b == true and QUEST_9c == true then 
					QUEST_9 = true 
					Quest.QUEST_9 = QUEST_9
					print('Quest 9 Finish')
					caster.MasterUnit:RemoveModifierByName("modifier_quest_01")
					Timers:CreateTimer(2.0, function()
						CustomNetTables:SetTableValue("tutorial", "page", {page = 30})
						CustomNetTables:SetTableValue("tutorial", "questID", {questID = 9})
					end)
				end
			end
		end
	elseif QUEST_10 == false and questID == 10 then 
		if not keys.unit:IsRealHero() then
			if keys.event_ability:GetAbilityName() == "cmd_seal_1" and keys.unit:GetUnitName() == "master_1" then 
				QUEST_10b = true 
				Timers:CreateTimer({
					endTime = 20, 
					callback = function()
					QUEST_10b = false
				end})
			elseif keys.event_ability:GetAbilityName() == "cmd_seal_2" and keys.unit:GetUnitName() == "master_1" then 
				QUEST_10c = true
			elseif keys.event_ability:GetAbilityName() == "cmd_seal_4" and keys.unit:GetUnitName() == "master_1" then 
				QUEST_10d = true
			end
		end
		if caster:IsRealHero() then
			if keys.event_ability:GetAbilityName() == caster:GetAbilityByIndex(5):GetAbilityName() then 
				if QUEST_10a == false then 
					QUEST_10a = true
					Timers:CreateTimer({
						endTime = 8, 
						callback = function()
					    QUEST_10a = false
					end})
				elseif QUEST_10e == false then 
					QUEST_10e = true 
					if QUEST_10a == true and QUEST_10b == true and QUEST_10c == true and QUEST_10d == true and QUEST_10e == true then 
						QUEST_10 = true 
						Quest.QUEST_10 = QUEST_10
						Timers:CreateTimer(3.0, function()
							print('Quest 10 Finish')
							caster.MasterUnit:RemoveModifierByName("modifier_quest_01")
							Timers:CreateTimer(2.0, function()
								CustomNetTables:SetTableValue("tutorial", "page", {page = 32})
								CustomNetTables:SetTableValue("tutorial", "questID", {questID = 10})
							end)
						end)
					end
				end
			end
		end
	elseif QUEST_11 == false and questID == 11 then 
		if keys.event_ability:GetAbilityName() == "item_c_scroll" and keys.ability:GetCursorTarget():GetName() == "npc_dota_hero_juggernaut" then 
			QUEST_11a = true 
			if QUEST_11a == true and QUEST_11b == true then 
				QUEST_11 = true 
				Quest.QUEST_11 = QUEST_11
				print('Quest 11 Finish')
				caster:RemoveModifierByName("modifier_quest_01")
				Timers:CreateTimer(2.0, function()
					CustomNetTables:SetTableValue("tutorial", "page", {page = 35})
					CustomNetTables:SetTableValue("tutorial", "questID", {questID = 11})
				end)
			end
		end
	elseif QUEST_12 == false and questID == 12 then 
		if keys.event_ability:GetAbilityName() == "item_b_scroll" then 
			QUEST_12a = true  
			Timers:CreateTimer({
				endTime = 20, 
				callback = function()
				QUEST_12a = false
			end})
		elseif keys.event_ability:GetAbilityName() == "item_a_scroll" then
			QUEST_12b = true 
			Timers:CreateTimer({
				endTime = 10, 
				callback = function()
				QUEST_12b = false
			end})
		end
	elseif QUEST_13 == false and questID == 13 then 
		if keys.event_ability:GetAbilityName() == "item_s_scroll" and keys.target:GetName() == "npc_dota_hero_templar_assassin" then 
			QUEST_13 = true 
			Quest.QUEST_13 = QUEST_13
			print('Quest 13 Finish')
			caster:RemoveModifierByName("modifier_quest_01")
			Timers:CreateTimer(2.0, function()
				CustomNetTables:SetTableValue("tutorial", "page", {page = 39})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 13})
			end)
		end	
	elseif QUEST_14 == false and questID == 14 then 
		if keys.event_ability:GetAbilityName() == "item_spirit_link" and keys.target:GetName() == "npc_dota_hero_monkey_king" then 
			QUEST_14a = true 
			Timers:CreateTimer({
				endTime = 7, 
				callback = function()
				QUEST_14a = false
			end})
		end	
	end
end

function Quest4Check(keys)
	if keys.target == nil then return end
	if GetMapName() == "fate_tutorial" then 
		if questID == 4 and QUEST_4 == false then 
			if keys.target:GetUnitName() == "npc_dota_hero_doom_bringer" then 
				QUEST_4b = true 
			end
		end
	end
end

function QuestCCheck (keys)
	if GetMapName() == "fate_tutorial" then 
		if keys.caster == "npc_dota_hero_juggernaut" then 
			if questID == 11 and QUEST_11 == false then 
				QUEST_11b = false 
			end
		end
	end
end

function QuestBCheck (keys)
	local caster = keys.caster
	if Quest == nil then 
		Quest = {}
	end
	if GetMapName() == "fate_tutorial" then 
		if questID == 12 and QUEST_12 == false then 
			if caster:IsAlive() and not caster:HasModifier("modifier_b_scroll") and QUEST_12a == true and QUEST_12b == true then
				QUEST_12 = true 
				Quest.QUEST_12 = QUEST_12
				print('Quest 12 Finish')
				caster:RemoveModifierByName("modifier_quest_01")
				Timers:CreateTimer(2.0, function()
					CustomNetTables:SetTableValue("tutorial", "page", {page = 37})
					CustomNetTables:SetTableValue("tutorial", "questID", {questID = 12})
				end)
			end
		elseif questID == 14 and QUEST_14 == false then 
			if caster:IsAlive() and caster:HasModifier("modifier_share_damage") and QUEST_14a == true then
				QUEST_14b = true 
				if QUEST_14b == true and QUEST_14a == true then 
					print('Quest 14 Finish')
					QUEST_14 = true 
					Quest.QUEST_14 = QUEST_14
					caster:RemoveModifierByName("modifier_quest_01")
					Timers:CreateTimer(2.0, function()
						CustomNetTables:SetTableValue("tutorial", "page", {page = 41})
						CustomNetTables:SetTableValue("tutorial", "questID", {questID = 14})
					end)
				end
			end
		end
	end
end

function QuestHercCheck (keys)
	local caster = keys.caster 
	if ability == nil then 
		ability = {}
	end
	for i = 0,5 do 
		ability[i] = caster:GetAbilityByIndex(i)
	end
	if QUEST_16a == true then return end
	local b_scroll = caster:FindItemInInventory("item_b_scroll")
	local a_scroll = caster:FindItemInInventory("item_a_scroll")
	local c_scroll = caster:FindItemInInventory("item_c_scroll")
	local s_scroll = caster:FindItemInInventory("item_s_scroll")
	local blink_scroll = caster:FindItemInInventory("item_blink_scroll")
	if not b_scroll then 
		b_scroll = CreateItem("item_b_scroll", caster, caster)
		caster:AddItem(b_scroll)
	end
	if not a_scroll then 
		a_scroll = CreateItem("item_a_scroll", caster, caster)
		caster:AddItem(a_scroll)
	end
	if not c_scroll then 
		c_scroll = CreateItem("item_c_scroll", caster, caster)
		caster:AddItem(c_scroll)
	end
	if not s_scroll then 
		s_scroll = CreateItem("item_s_scroll", caster, caster)
		caster:AddItem(s_scroll)
	end
	if not blink_scroll then 
		blink_scroll = CreateItem("item_blink_scroll", caster, caster)
		caster:AddItem(blink_scroll)
	end
	local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
	if not hero:IsAlive() then return end
	if not caster:HasModifier("modifier_madmans_roar_cooldown") and caster:GetMana() >= 700 and ability[0]:IsCooldownReady() and ability[1]:IsCooldownReady() and ability[2]:IsCooldownReady() then
		if (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 500 then 
			local fissure = {
				UnitIndex = caster:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
	 			AbilityIndex = ability[0]:entindex(), 
	 			Position = hero:GetAbsOrigin(), 
			}
			ExecuteOrderFromTable(fissure)
			QUEST_16a = true
			local berserk = {
				UnitIndex = caster:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 		AbilityIndex = ability[2]:entindex(), 
			}
			Timers:CreateTimer(0.4, function()
				ExecuteOrderFromTable(berserk)
				QUEST_16a = true
				local madman = caster:FindAbilityByName("berserker_5th_madmans_roar"):entindex()
				local mad = {
					UnitIndex = caster:entindex(), 
			 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			 		AbilityIndex = madman, 
				}
				Timers:CreateTimer(0.7, function()
					ExecuteOrderFromTable(mad)
					QUEST_16a = false
				end)
			end)
		else 
			local atk_move = {
				UnitIndex = caster:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 			TargetIndex = hero:entindex(), 
			}
			ExecuteOrderFromTable(atk_move)
			QUEST_16a = false
		end
	elseif caster:GetHealth() <= 1000 and ability[2]:IsCooldownReady() and caster:GetMana() >= 400 then 
		local berserk = {
			UnitIndex = caster:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = ability[2]:entindex(), 
		}
		ExecuteOrderFromTable(berserk)
		QUEST_16a = false
	elseif caster:GetMana() >= 800 and ability[5]:IsCooldownReady() and c_scroll:IsCooldownReady() and s_scroll:IsCooldownReady() then 
		if (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 700 then
			local s_root = {
				UnitIndex = caster:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
	 			AbilityIndex = s_scroll:entindex(), 
	 			TargetIndex = hero:entindex(), 
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(s_root)
				QUEST_16a = true
				local c_stun = {
					UnitIndex = caster:entindex(), 
		 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		 			AbilityIndex = c_scroll:entindex(), 
		 			TargetIndex = hero:entindex(), 
				}
				Timers:CreateTimer(0.4, function()
					ExecuteOrderFromTable(c_stun)
					QUEST_16a = true
					local ninelives = {
						UnitIndex = caster:entindex(), 
			 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			 			AbilityIndex = ability[5]:entindex(), 
			 			Position = hero:GetAbsOrigin(), 
					}
					Timers:CreateTimer(0.01, function()
						ExecuteOrderFromTable(ninelives)
						QUEST_16a = false
					end)
				end)
			end)
		else 
			local atk_move = {
				UnitIndex = caster:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 			TargetIndex = hero:entindex(), 
			}
			ExecuteOrderFromTable(atk_move)
			QUEST_16a = false
		end
	elseif ability[0]:IsCooldownReady() and caster:GetMana() >= 100 and (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 500 then 
		local fissure = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
	 		AbilityIndex = ability[0]:entindex(), 
	 		Position = hero:GetAbsOrigin(), 
		}
		ExecuteOrderFromTable(fissure)
		QUEST_16a = false
	elseif blink_scroll:IsCooldownReady() and (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 800 then 
		local blink = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION, 
	 		AbilityIndex = blink_scroll:entindex(), 
	 		Position = hero:GetAbsOrigin(), 
		}
		ExecuteOrderFromTable(blink)
		local atk_move = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 		TargetIndex = hero:entindex(), 
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(atk_move)
			QUEST_16a = false
		end)
	elseif a_scroll:IsCooldownReady() and hero:FaceTowards(caster:GetAbsOrigin()) and (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 500 and not caster:HasModifier("modifier_heracles_berserk") then 
		local a_barrier = {
			UnitIndex = caster:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = a_scroll:entindex(), 
		}
		ExecuteOrderFromTable(a_barrier)
		local atk_move = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 		TargetIndex = hero:entindex(), 
		}
		ExecuteOrderFromTable(atk_move)
		QUEST_16a = false
	elseif b_scroll:IsCooldownReady() and hero:FaceTowards(caster:GetAbsOrigin()) and (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 500 and not caster:HasModifier("modifier_heracles_berserk") then 
		local b_barrier = {
			UnitIndex = caster:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = b_scroll:entindex(), 
		}
		ExecuteOrderFromTable(b_barrier)
		local atk_move = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 		TargetIndex = hero:entindex(), 
		}
		ExecuteOrderFromTable(atk_move)
		QUEST_16a = false
	else
		local atk_move = {
			UnitIndex = caster:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 		TargetIndex = hero:entindex(), 
		}
		ExecuteOrderFromTable(atk_move)
		QUEST_16a = false
	end
end

function Quest16Finish (keys)
	if questID == 17 and QUEST_16 == false then 
		if keys.unit:GetUnitName() == "npc_dota_hero_doom_bringer" then 
			QUEST_16 = true 
			if QUEST_16 == true then 
				GameRules:SendCustomMessage("Tutorial Mode Finish!",0,0)
		        GameRules:SetSafeToLeave( true )
		        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
		    end
		end
	end
end


