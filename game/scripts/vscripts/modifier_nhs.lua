------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------


HeroSelectioN = HeroSelectioN or class({})

function HeroSelectioN:constructor()

	_G.GameMap = GetMapName()

	if _G.GameMap == "fate_tutorial" then

		Selection = HeroSelection()
        Selection:UpdateTime() 
	else

		self.AllHeroes = {}
		self.AvailableHeroes = {}
		self.UnAvailableHeroes = {}
		self.Picked = {}
		self.SkinSelect = {}
		self.AvailableSkins = {}
		self.PickedPlayer = {}
        local heroList = LoadKeyValues("scripts/npc/herolist.txt")
        local skinList = LoadKeyValues("scripts/npc/skin.txt")
        local testList = LoadKeyValues("scripts/npc/herotest.txt")
		heroList["npc_dota_hero_wisp"] = nil
		self.AllHeroes = heroList
		self.AvailableHeroes = heroList
		self.AvailableSkins = skinList
		self.UnAvailableHeroes = testList
		self.RandomHero = {}
		self.HeroInfo = {}
		self.Id = {}
		self.SelectedBar = {}
		self.HeroSelectStart = "selection"


		for k,v in pairs (testList) do 
			if v == 1 and self.AllHeroes[k] == nil then 
				self.AllHeroes[k] = v 
			end
		end

		self.Time = 75 
		self:UpdateTime()

		for key, value in pairs (self.AllHeroes) do
			if value ~= 1 then return end
			local hero_info = GetHeroInfo(key)
			self.HeroInfo[key] = hero_info
		end
		--[[for a,b in pairs(self.HeroInfo) do
			for c,d in pairs(b) do
				print(a,c,d)
			end
		end]]

		if IsInToolsMode() then 		
			CustomNetTables:SetTableValue("nselection", "mode", {mode="tool"})
		end

		for i = 0,#GameRules.AddonTemplate.vUserIds - 1 do
			local id = PlayerResource:GetSteamAccountID(i)
		    table.insert(self.Id, i, id) 
		end
		
		self.SkinListener = CustomGameEventManager:RegisterListener("nselection_hero_skin", function(id, ...)
	        Dynamic_Wrap(self, "OnSkin")(self, ...) 
	    end)
	    self.ClickListener = CustomGameEventManager:RegisterListener("nselection_hero_pick", function(id, ...)
	        Dynamic_Wrap(self, "OnSelect")(self, ...) 
	    end)
	    self.ChangePortraitListener = CustomGameEventManager:RegisterListener("nselection_hero_changeportrait", function(id, ...)
	        Dynamic_Wrap(self, "OnSelectBar")(self, ...) 
	    end)
	    self.RandomListener = CustomGameEventManager:RegisterListener("nselection_hero_random", function(id, ...)
	        Dynamic_Wrap(self, "OnRandom")(self, ...) 
	    end)
	    self.SummonListener = CustomGameEventManager:RegisterListener("nselection_hero_summon", function(id, ...)
		    Dynamic_Wrap(self, "OnSummon")(self, ...) 
		end)
		self.SummonListener = CustomGameEventManager:RegisterListener("nselection_hero_strategy", function(id, ...)
		    Dynamic_Wrap(self, "OnStrategy")(self, ...) 
		end)


		CustomNetTables:SetTableValue("nselection", "all", self.AllHeroes)
        CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
        CustomNetTables:SetTableValue("nselection", "unavailable", self.UnAvailableHeroes)
        CustomNetTables:SetTableValue("nselection", "skin", self.AvailableSkins)
        
        CustomNetTables:SetTableValue("nselection", "game", LoadAKeyValues())
        CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
        CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
        CustomNetTables:SetTableValue("nselection", "time", {time = self.Time})

        CustomNetTables:SetTableValue("nselection", "gamephrase", {gamephrase = "load"})
        
        CustomNetTables:SetTableValue("nselection", "panel", {game = "start"})
        CustomNetTables:SetTableValue("nselection", "si", self.Id)
        CustomNetTables:SetTableValue("nhi", "info", self.HeroInfo)

        Timers:CreateTimer(2.0, function()
        	CustomNetTables:SetTableValue("nselection", "hs", {mode = self.HeroSelectStart})
        end)
        Timers:CreateTimer(5.0, function()
        	CustomNetTables:SetTableValue("nselection", "gamephrase", {gamephrase = "pick"})     	
        end)
	end
end

function HeroSelectioN:UpdateTime()
	if self.Time == "undefined" then return end
    self.Time = math.max(self.Time - 1, 0)
    CustomNetTables:SetTableValue("nselection", "time", {time = self.Time})
    --print(self.Time)
    if self.Time > 0 then
        Timers:CreateTimer(1.0, function()
            self:UpdateTime()
        end)
    end
end

function HeroSelectioN:OnSkin(args)
	local playerId = args.playerId
    local hero = args.hero
    local skin = args.skin
    print('skin = ' .. skin)

    self.SkinSelect[hero] = skin

    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
end 

function HeroSelectioN:OnSelectBar(args)
	local playerId = args.playerId
    local hero = args.hero
    --print('recieve pick data')
    self.SelectedBar[playerId] = hero
    --print('send data hero ' .. hero)
    CustomNetTables:SetTableValue("nselection", "select_bar", self.SelectedBar)
end

function HeroSelectioN:OnStrategy(args)
	local playerId = args.playerId
	local hero = self.Picked[playerId]
	
end 

function HeroSelectioN:OnSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    self.Picked[playerId] = hero
    self.AvailableHeroes[hero] = nil
    self.SkinSelect[hero] = 0
    self.PickedPlayer[playerId] = playerId

    CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
    CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
    CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
    CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=playerId}) 
end

function HeroSelectioN:OnRandom(args)
    local playerId = args.playerId
    local hero = nil

    if self.SelectedBar[playerId] ~= nil and self.SelectedBar[playerId] ~= "random" and self.AvailableHeroes[self.SelectedBar[playerId]] ~= nil and self.UnAvailableHeroes[self.SelectedBar[playerId]] ~= 1 then 
    	hero = self.SelectedBar[playerId] 
    else
    	hero = self:Random()
    end

    print(hero)
    self.Picked[playerId] = hero
	self.AvailableHeroes[hero] = nil
	self.SkinSelect[hero] = 0
	self.PickedPlayer[playerId] = playerId

    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
	CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
	CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
	CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
	CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=playerId}) 
end

function HeroSelectioN:Random()

    local availableHeroesNumber = 0
    for _,_ in pairs(self.AvailableHeroes) do
        availableHeroesNumber = availableHeroesNumber + 1
    end

    local randomIndex = RandomInt(1, availableHeroesNumber)

    local index = 1
    for hero,_ in pairs(self.AvailableHeroes) do
    	if self.AvailableHeroes[hero] then
        	if index == randomIndex then
        		return hero
			end
			index = index + 1
		end
	end
end

function HeroSelectioN:OnSummon(args)
	local playerId = args.playerId
    local hero = self.Picked[playerId]
    local skin = self.SkinSelect[self.Picked[playerId]] 
    
    self:AssignHero(playerId, hero, skin, true)
    
end

function HeroSelectioN:AssignHero(playerId, hero, skin)
    PrecacheUnitByNameAsync(hero, function()
        Timers:CreateTimer(function()
            local conn_state = PlayerResource:GetConnectionState(playerId)

            --0 = No connection
            --1 = Bot
            --2 = Player
            --3 = Disconnected

            if conn_state == 3 or conn_state == 0 then 
                return 1
            else
                local oldHero = PlayerResource:GetSelectedHeroEntity(playerId)

                if not oldHero.IsAssignHero then
	                oldHero:SetRespawnsDisabled(true)
	                PlayerResource:ReplaceHeroWith(playerId, hero, 3000, 0)
	                UTIL_Remove(oldHero)
	                local newHero = Entities:FindByClassname(nil, hero)
	                newHero.IsAssignHero = true
	                Timers:CreateTimer(function()
			            if newHero ~= nil then 
					        if skin > 0 then 
					            newHero:AddAbility("alternative_0" .. skin)
					            newHero:FindAbilityByName("alternative_0" .. skin):SetLevel(1)
					            print('skin add')
					        end
					       	return nil 
					    else 
					        return 1
					    end
					end)
				end
                return nil
            end
        end)        
    end)
end


heroesTable = {
		npc_dota_hero_legion_commander = "npc_dota_hero_saber",
		npc_dota_hero_spectre = "npc_dota_hero_saber_alter",
		npc_dota_hero_queenofpain = "npc_dota_hero_astolfo",
		npc_dota_hero_drow_ranger = "npc_dota_hero_atalanta",
		npc_dota_hero_vengefulspirit = "npc_dota_hero_avenger",
		npc_dota_hero_naga_siren = "npc_dota_hero_chloe",
		npc_dota_hero_phantom_lancer = "npc_dota_hero_lancer_5th",
		npc_dota_hero_huskar = "npc_dota_hero_diarmuid",
		npc_dota_hero_troll_warlord = "npc_dota_hero_drake",
		npc_dota_hero_ember_spirit = "npc_dota_hero_archer_5th",
		npc_dota_hero_omniknight = "npc_dota_hero_gawain",
		npc_dota_hero_skywrath_mage = "npc_dota_hero_gilgamesh",
		npc_dota_hero_shadow_shaman = "npc_dota_hero_gille",
		npc_dota_hero_doom_bringer = "npc_dota_hero_berserker_5th",
		npc_dota_hero_chen = "npc_dota_hero_iskander",
		npc_dota_hero_mirana = "npc_dota_hero_jeanne",
		npc_dota_hero_riki = "npc_dota_hero_jtr",
		npc_dota_hero_beastmaster = "npc_dota_hero_karna",
		npc_dota_hero_sven = "npc_dota_hero_lancelot",
		npc_dota_hero_bloodseeker = "npc_dota_hero_li",
		npc_dota_hero_crystal_maiden = "npc_dota_hero_caster_5th",
		npc_dota_hero_templar_assassin = "npc_dota_hero_rider_5th",
		npc_dota_hero_tusk = "npc_dota_hero_mordred",
		npc_dota_hero_lina = "npc_dota_hero_nero",
		npc_dota_hero_windrunner = "npc_dota_hero_nursery_rhyme",
		npc_dota_hero_dark_willow = "npc_dota_hero_okita",
		npc_dota_hero_juggernaut = "npc_dota_hero_false_assassin",
		npc_dota_hero_monkey_king = "npc_dota_hero_scathach",
		npc_dota_hero_phantom_assassin = "npc_dota_hero_semiramis",
		npc_dota_hero_enchantress = "npc_dota_hero_tamamo",
		npc_dota_hero_bounty_hunter = "npc_dota_hero_true_assassin",
		npc_dota_hero_tidehunter = "npc_dota_hero_vlad",
}

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
  	return math.floor(num * mult) / mult
end

function GetHeroInfo(D2hero)
	for k,v in pairs (heroesTable) do 
		if D2hero == k then 
			local str = GetUnitKV(heroesTable[D2hero], "AttributeStrengthGain") 
			if str ~= math.floor(str) then
				str = string.format("%.1f",str)
			end
			local agi = GetUnitKV(heroesTable[D2hero], "AttributeAgilityGain") 
			if agi ~= math.floor(agi) then
				agi = string.format("%.1f",agi)
			end
			local int = GetUnitKV(heroesTable[D2hero], "AttributeIntelligenceGain") 
			if int ~= math.floor(int) then
				int = string.format("%.1f",int)
			end

			local hero_info = {
				S1 = GetUnitKV(heroesTable[D2hero], "Ability1"),
				S2 = GetUnitKV(heroesTable[D2hero], "Ability2"),
				S3 = GetUnitKV(heroesTable[D2hero], "Ability3"),
				S4 = GetUnitKV(heroesTable[D2hero], "Ability4"),
				S5 = GetUnitKV(heroesTable[D2hero], "Ability5"),
				S6 = GetUnitKV(heroesTable[D2hero], "Ability6"),
				C = GetUnitKV(heroesTable[D2hero], "Combo"),
				A = GetUnitKV(heroesTable[D2hero], "AttributeNumber"),
				A1 = GetUnitKV(heroesTable[D2hero], "Attribute1"),
				A2 = GetUnitKV(heroesTable[D2hero], "Attribute2"),
				A3 = GetUnitKV(heroesTable[D2hero], "Attribute3"),
				A4 = GetUnitKV(heroesTable[D2hero], "Attribute4"),
				HP = GetUnitKV(heroesTable[D2hero], "StatusHealth"),
				--HPR = GetUnitKV(heroesTable[D2hero], "StatusHealthRegen"),
				--MP = GetUnitKV(heroesTable[D2hero], "StatusMana"),
				--MPR = GetUnitKV(heroesTable[D2hero], "StatusManaRegen"),
				--ARM = GetUnitKV(heroesTable[D2hero], "ArmorPhysical"),
				MR = GetUnitKV(heroesTable[D2hero], "MagicalResistance"),
				--ATK = (GetUnitKV(heroesTable[D2hero], "AttackDamageMin") + GetUnitKV(heroesTable[D2hero], "AttackDamageMax"))/2,
				STR = str,
				AGI = agi,
				INT = int,
				Class = CheckClass(D2hero), 
				Sex = CheckSex(D2hero),
				NP = GetUnitKV(heroesTable[D2hero], "NP"),
				DIF = GetUnitKV(heroesTable[D2hero], "Difficult"),
				Ty = GetUnitKV(heroesTable[D2hero], "SType"),
				Tr = GetUnitKV(heroesTable[D2hero], "Trait")
			}

			if GetUnitKV(heroesTable[D2hero], "AttributeNumber") == 5 then 
				hero_info["A5"] = GetUnitKV(heroesTable[D2hero], "Attribute5")
			end
			return hero_info
		end
	end
end
