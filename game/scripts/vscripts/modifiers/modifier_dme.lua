------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- Sana , ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------
DraftSelection = DraftSelection or class({})

require('libraries/modifiers/modifier_nhs')

function DraftSelection:constructor()

	self.Time = 35
	self.tenCost = {}
	self.twentyCost = {}
	self.thirtyCost = {}
	self.Picked = {}
	self.PickedPlayer = {}
	self.PickedPlayerRed = {}
	self.PickedPlayerBlack = {}
	self.PreSelected = {}
	self.SelectedBar = {}
	self.SkinSelect = {}
	self.PlayerTeam1Count = PlayerResource:GetPlayerCountForTeam(2)
	self.PlayerTeam2Count = PlayerResource:GetPlayerCountForTeam(3)
	self.Banned = {}
	self.RedFraction = {}
	self.BlackFraction = {}
	self.RedTeam = {}
	self.BlackTeam = {}
	self.AvailableSkins = {}
	local heroList = LoadKeyValues("scripts/npc/herolist.txt")
	local skinList = LoadKeyValues("scripts/npc/skin.txt")
	heroList["npc_dota_hero_wisp"] = nil
	self.AllHeroes = heroList
	self.AvailableHeroes = heroList
	self.AvailableSkins = skinList
	self.RandomHero = {}
	self.UnselectedRed = {}
	self.UnselectedBlack = {}
	self.Unselected = {}
	self.Id = {}
	self.RedMana = 100
	self.BlackMana = 100
	self.Draft = "draft"
	
	for key, value in pairs (heroList) do
		local manacost = GetManaCost(key)
		if manacost == 10 then 
			self.tenCost[key] = value
		elseif manacost == 20 then 
			self.twentyCost[key] = value
		elseif manacost == 30 then 
			self.thirtyCost[key] = value
		end
	end

	local j = 0
	local k = 0
	for i = 0,self.PlayerTeam1Count + self.PlayerTeam2Count - 1 do
		local playerId = i
	    local player = PlayerResource:GetPlayer(playerId)
	    local id = PlayerResource:GetSteamAccountID(playerId)
	    print(id)
	    table.insert(self.Id, i, id)  
		if PlayerResource:GetTeam(playerId) == 2 then 
			j = j + 1
			table.insert(self.RedFraction, j, playerId)
			table.insert(self.RedTeam, playerId, playerId)
			table.sort( self.RedFraction)
		elseif PlayerResource:GetTeam(playerId) == 3 then 
			k = k + 1
			table.insert(self.BlackFraction, k, playerId)
			table.insert(self.BlackTeam, playerId, playerId)
			table.sort( self.BlackFraction)
		end
	end
	for a,b in pairs (self.RedFraction) do
		print(a,b)
	end

	--if GetMapName() == "fate_elim_6v6" then 
		print('draft mode')

		self.BanListener = CustomGameEventManager:RegisterListener("draft_hero_ban", function(id, ...)
	        Dynamic_Wrap(self, "OnBan")(self, ...) 
	    end)
	    self.SwitchListener = CustomGameEventManager:RegisterListener("draft_hero_switch", function(id, ...)
	        Dynamic_Wrap(self, "OnSwitch")(self, ...) 
	    end)
	    self.SkinListener = CustomGameEventManager:RegisterListener("draft_hero_skin", function(id, ...)
	        Dynamic_Wrap(self, "OnSkin")(self, ...) 
	    end)
	    self.PreSelectedListener = CustomGameEventManager:RegisterListener("draft_hero_preselect", function(id, ...)
	        Dynamic_Wrap(self, "OnPreSelect")(self, ...) 
	    end)
	    self.ChangePortraitListener = CustomGameEventManager:RegisterListener("draft_hero_changeportrait", function(id, ...)
	        Dynamic_Wrap(self, "OnSelectBar")(self, ...) 
	    end)
	    self.ClickListener = CustomGameEventManager:RegisterListener("draft_hero_click", function(id, ...)
	        Dynamic_Wrap(self, "OnSelect")(self, ...) 
	    end)
	    self.RandomListener = CustomGameEventManager:RegisterListener("draft_hero_random", function(id, ...)
	        Dynamic_Wrap(self, "OnRandom")(self, ...) 
	    end)
	    self.SummonListener = CustomGameEventManager:RegisterListener("draft_hero_summon", function(id, ...)
		    Dynamic_Wrap(self, "OnSummon")(self, ...) 
		end)
		self.SummonListener = CustomGameEventManager:RegisterListener("draft_hero_strategy", function(id, ...)
		    Dynamic_Wrap(self, "OnStrategy")(self, ...) 
		end)
	
	CustomNetTables:SetTableValue("draft", "all", self.AllHeroes)
	CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	CustomNetTables:SetTableValue("draft", "skin", self.AvailableSkins)
	CustomNetTables:SetTableValue("draft", "redteam", self.RedTeam)
	CustomNetTables:SetTableValue("draft", "blackteam", self.BlackTeam)
	CustomNetTables:SetTableValue("draft", "picked", self.Picked)
	CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)
	CustomNetTables:SetTableValue("draft", "banned", self.Banned)
	CustomNetTables:SetTableValue("draft", "red_unselected", self.UnselectedRed)
	CustomNetTables:SetTableValue("draft", "black_unselected", self.UnselectedBlack)
	CustomNetTables:SetTableValue("draft", "teamcount", {teamcount = self.PlayerTeam1Count})
	CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
	CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})
	self.Time = 7
	CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "load"})
	CustomNetTables:SetTableValue("draft", "draftmode", {draft = self.Draft})
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("draft", "ten", self.tenCost)
			CustomNetTables:SetTableValue("draft", "twenty", self.twentyCost)
			CustomNetTables:SetTableValue("draft", "thirty", self.thirtyCost)
			CustomNetTables:SetTableValue("draft", "panel", {game = "start"})
			CustomNetTables:SetTableValue("draft", "si", self.Id)
		end)
		Timers:CreateTimer(7.0, function()
		    self.FirstBan = self.RedFraction[self.PlayerTeam1Count]
		    self.SecondBan = self.BlackFraction[self.PlayerTeam2Count]
		    self.FirstPick = self.RedFraction[1]
		    --[[if self.BlackFraction[self.PlayerTeam2Count] == nil then 
		    	self.SecondBan = self.RedFraction[self.PlayerTeam1Count]
		    end]]
		    --[[if self.FirstBan == nil then 
		    	self.FirstBan = self.BlackFraction[self.PlayerTeam2Count]
		    	CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
		    else
		    	CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
		    end]]
			self.Time = 31
			self:UpdateTime()
			
			CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
		    CustomNetTables:SetTableValue("draft", "banorder", {playerId = self.FirstBan})
		    CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "ban"})
		    
		    print('draft data sending')
    	end)
	--end)

end

function DraftSelection:UpdateTime()
	if self.Time == "undefined" then return end
    self.Time = math.max(self.Time - 1, 0)
    CustomNetTables:SetTableValue("draft", "time", {time = self.Time})

    if self.Time > 0 then
        Timers:CreateTimer(1.0, function()
            self:UpdateTime()
        end)
    end
end

function DraftSelection:OnBan(args)
	local playerId = args.playerId
	if args.hero ~= nil then
	    local hero = args.hero

	    self.AvailableHeroes[hero] = nil
	    self.Banned[hero] = 1

	    CustomNetTables:SetTableValue("draft", "banned", self.Banned)
	    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	end
	local team = "2"
	self.Time = "undefined"
	CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
	CustomNetTables:SetTableValue("draft", "banorder", {playerId = nil})
	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
	if self.FirstBan == playerId then
    	print('second ban start')
    	if self.SecondBan == nil then 
    		self.SecondBan = self.RedFraction[self.PlayerTeam1Count]
    		team = "1"
    	
    	end
    	Timers:CreateTimer(1.0,function()
	    	CustomNetTables:SetTableValue("draft", "banorder", {playerId = self.SecondBan})
	    	CustomNetTables:SetTableValue("draft", "teamqueue", {team = team})
	    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "ban"})
	    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
	    	Timers:CreateTimer(0.2,function()
    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
    		end)
	    	self.Time = 31
	    	self:UpdateTime()
	    	if self.FirstBan == self.SecondBan then
	    		self.FirstBan = nil
	    	end
	    end)
	    return
    
    elseif self.SecondBan == playerId then
    	print('first pick start')
    	--[[if self.FirstPick == nil then 
    		self.FirstPick = self.BlackFraction[self.PlayerTeam2Count]
    		team = "2"
    	else 
    		team = "1"
    	end]]
    	
    	Timers:CreateTimer(1.0,function()
    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.FirstPick , playerID2 = nil})
	    	CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.FirstPick , playerID2 = nil})
	    	CustomNetTables:SetTableValue("draft", "banorder", {playerId = nil})
	    	CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
	    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
    		CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
	    	Timers:CreateTimer(0.2,function()
    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
    		end)
	    	self.Time = 31
	    	self:UpdateTime()
	    	self.RedPicked = true
	    end)
    	
    	--[[if self.FirstPick == self.BlackFraction[1] then 
    		self.RedPicked = false
    	end]]
    	
    	return
    end
    
end 

function DraftSelection:OnSwitch(args)
	local playerId = args.playerId
	local hero = args.hero

	self.Picked[playerId] = hero
end 

function DraftSelection:OnStrategy(args)
	if self.BlackFraction[1] == nil and self.RedFraction[1] == nil then 
		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
		CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
		self.Time = 11
		self:UpdateTime()
	end
end 

function DraftSelection:OnSkin(args)
	local playerId = args.playerId
    local hero = args.hero
    local skin = args.skin
    print('skin = ' .. skin)

    self.SkinSelect[hero] = skin

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)
end 

function DraftSelection:OnPreSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    self.PreSelected[playerId] = hero

    CustomNetTables:SetTableValue("draft", "preselect", self.PreSelected)
end

function DraftSelection:OnSelectBar(args)
	local playerId = args.playerId
    local hero = args.hero

    self.SelectedBar[playerId] = hero

    CustomNetTables:SetTableValue("draft", "select_bar", self.SelectedBar)
end

function DraftSelection:OnSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    self.Picked[playerId] = hero
    self.PickedPlayer[playerId] = playerId
    self.AvailableHeroes[hero] = nil
    self.SkinSelect[hero] = 0

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)

    local mana_cost = GetManaCost(hero)
    CustomNetTables:SetTableValue("draft", "picked", self.Picked)
    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
    CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)
    
    local pickedplayercount = 0
     
    if self.RedPicked == true then 
    	self.PickedPlayerRed[playerId] = playerId
    	for _,_ in pairs (self.PickedPlayerRed) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	if not self.FirstPicked and self.FirstPick == playerId then 
    		self.RedMana = self.RedMana - mana_cost 
    		self:UnSelectedCreate(self.RedMana, (self.PlayerTeam1Count - pickedplayercount),self.RedFraction)
    		table.remove(self.RedFraction, 1)
    		table.sort( self.RedFraction)
    		CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    		self.Time = "undefined"
			CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
			CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil })
    		Timers:CreateTimer(1.0,function()
    			if self.BlackFraction[1] == nil then
    				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
	    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
			    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
					self.Time = 11
			    	self:UpdateTime()
			    	return
			    else
			    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			   		if self.BlackFraction[2] == nil then
			   			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
			   			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
			    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
			    	else
			    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
			    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
			    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
			    	end
			    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
			    	Timers:CreateTimer(0.2,function()
			   			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			   		end)
			    	self.Time = 31
			    	self:UpdateTime()
			    	self.RedPicked = false 
			    	return
			    end
		    end)
    	else
    		self.RedMana = self.RedMana - mana_cost 
    		self:UnSelectedCreate(self.RedMana, (self.PlayerTeam1Count - pickedplayercount),self.RedFraction)
    		CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    		if self.RedFraction[2] == nil then
    			if self.RedFraction[1] == playerId then 
	    			table.remove(self.RedFraction, 1)
			    	table.sort( self.RedFraction)
	    			self.Time = "undefined"
					CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
					CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil })
					CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
		    		Timers:CreateTimer(1.0,function()
		    			if self.BlackFraction[1] == nil then
		    				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    				CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
							self.Time = 11
					    	self:UpdateTime()
					    	return
					    else
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
				    		if self.BlackFraction[2] == nil then
				    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
				    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	else
					    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	end
					    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
					    	Timers:CreateTimer(0.2,function()
				    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
				    		end)
					    	self.Time = 31
					    	self:UpdateTime()
					    	self.RedPicked = false 
					    	return
					    end
				    end)
	    		end
		    else 
		    	--[[if self.RedFraction[1] == playerId then 
		    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
		    	elseif self.RedFraction[2] == playerId then 
		    		CustomNetTables:SetTableValue("draft", "hilight", {playerID2 = nil})
		    	end]]
		    	if self.PickedPlayer[self.RedFraction[1]] ~= nil and self.PickedPlayer[self.RedFraction[2]] ~= nil then
	    			table.remove(self.RedFraction, 2)
	    			table.remove(self.RedFraction, 1)
	    			table.sort( self.RedFraction)
	    			self.Time = "undefined"
					CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
					CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
					Timers:CreateTimer(1.0,function()
						if self.BlackFraction[1] == nil then
							CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    				CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
							self.Time = 11
					    	self:UpdateTime()
					    	return
					    else
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
				    		if self.BlackFraction[2] == nil then
				    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
				    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	else
					    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	end
					    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
					    	Timers:CreateTimer(0.2,function()
				    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
				    		end)
					    	self.Time = 31
					    	self:UpdateTime()
					    	self.RedPicked = false 
					    	return
					    end
			    	end)
		    	end
			end
	    end
	else
		self.PickedPlayerBlack[playerId] = playerId
    	for _,_ in pairs (self.PickedPlayerBlack) do 
    		pickedplayercount = pickedplayercount + 1
    	end
		self.BlackMana = self.BlackMana - mana_cost 
		self:UnSelectedCreate(self.BlackMana, (self.PlayerTeam2Count - pickedplayercount),self.BlackFraction)
		CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})
		if self.BlackFraction[2] == nil then
			if self.BlackFraction[1] == playerId then 
				table.remove(self.BlackFraction, 1)
			   	table.sort( self.BlackFraction)
	    		self.Time = "undefined"
				CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
				CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
		    	Timers:CreateTimer(1.0,function()
		    		if self.RedFraction[1] == nil then
		    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
						self.Time = 11
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    else
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			    		if self.RedFraction[2] == nil then
			    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = nil})
			    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1],playerID2 = nil})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	else
				    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1], playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	end
				    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
				    	Timers:CreateTimer(0.2,function()
			    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			    		end)
				    	self.Time = 31
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    end
			    end)
	    	end
		else 
			--[[if self.BlackFraction[1] == playerId then 
				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
		    elseif self.BlackFraction[2] == playerId then 
		    	CustomNetTables:SetTableValue("draft", "hilight", {playerID2 = nil})
		    end]]
		   	if self.PickedPlayer[self.BlackFraction[1]] ~= nil and self.PickedPlayer[self.BlackFraction[2]] ~= nil then
	    		table.remove(self.BlackFraction, 2)
	    		table.remove(self.BlackFraction, 1)
	    		table.sort( self.BlackFraction)
	    		self.Time = "undefined"
				CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
				CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
				Timers:CreateTimer(1.0,function()
					if self.RedFraction[1] == nil then
						CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
						self.Time = 11
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    else
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			    		if self.RedFraction[2] == nil then
			    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = nil})
			    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1],playerID2 = nil})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	else
				    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1], playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	end
				    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
				    	Timers:CreateTimer(0.2,function()
			    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			    		end)
				    	self.Time = 31
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    end
			   	end)
		    end
		end
    end
end

function DraftSelection:OnRandom(args)
    local playerId = args.playerId
    local hero = self:Random()
    print(hero)
    self.Picked[playerId] = hero
	self.PickedPlayer[playerId] = playerId
	self.AvailableHeroes[hero] = nil
	self.SkinSelect[hero] = 0

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)
	CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	CustomNetTables:SetTableValue("draft", "picked", self.Picked)
	CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)

    local pickedplayercount = 0
    local mana_cost = 10
    if self.RedPicked == true then 
    	self.PickedPlayerRed[playerId] = playerId
    	for _,_ in pairs (self.PickedPlayerRed) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	if not self.FirstPicked and self.FirstPick == playerId then 
    		self.RedMana = self.RedMana - mana_cost 
    		self:UnSelectedCreate(self.RedMana, (self.PlayerTeam1Count - pickedplayercount),self.RedFraction)
    		table.remove(self.RedFraction, 1)
    		table.sort( self.RedFraction)
    		for a,b in pairs (self.RedFraction) do
				print(a,b)
			end
    		CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    		self.Time = "undefined"
			CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
			CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
    		Timers:CreateTimer(1.0,function()
    			if self.BlackFraction[1] == nil then
    				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
	    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
			    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
					self.Time = 11
			    	self:UpdateTime()
			    	return
			    else
			    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			   		if self.BlackFraction[2] == nil then
			   			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
			   			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
			    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
			    	else
			    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
			    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
			    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
			    	end
			    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
			    	Timers:CreateTimer(0.2,function()
			   			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			   		end)
			    	self.Time = 31
			    	self:UpdateTime()
			    	self.RedPicked = false 
			    	return
			    end
		    end)
    	else
    		self.RedMana = self.RedMana - mana_cost 
    		self:UnSelectedCreate(self.RedMana, (self.PlayerTeam1Count - pickedplayercount),self.RedFraction)
    		CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    		if self.RedFraction[2] == nil then
    			if self.RedFraction[1] == playerId then 
	    			table.remove(self.RedFraction, 1)
			    	table.sort( self.RedFraction)
	    			self.Time = "undefined"
					CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
					CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
					CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
		    		Timers:CreateTimer(1.0,function()
		    			if self.BlackFraction[1] == nil then
		    				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    				CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
							self.Time = 11
					    	self:UpdateTime()
					    	return
					    else
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
				    		if self.BlackFraction[2] == nil then
				    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
				    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	else
					    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	end
					    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
					    	Timers:CreateTimer(0.2,function()
				    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
				    		end)
					    	self.Time = 31
					    	self:UpdateTime()
					    	self.RedPicked = false 
					    	return
					    end
				    end)
	    		end
		    else 
		    	if self.RedFraction[1] == playerId then 
		    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
		    	elseif self.RedFraction[2] == playerId then 
		    		CustomNetTables:SetTableValue("draft", "hilight", {playerID2 = nil})
		    	end
		    	if self.PickedPlayer[self.RedFraction[1]] ~= nil and self.PickedPlayer[self.RedFraction[2]] ~= nil then
	    			table.remove(self.RedFraction, 2)
	    			table.remove(self.RedFraction, 1)
	    			table.sort( self.RedFraction)
	    			self.Time = "undefined"
					CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
					CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
					Timers:CreateTimer(1.0,function()
						if self.BlackFraction[1] == nil then
							CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    				CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
							self.Time = 11
					    	self:UpdateTime()
					    	return
					    else
					    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
				    		if self.BlackFraction[2] == nil then
				    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = nil})
				    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1],playerID2 = nil})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	else
					    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.BlackFraction[1] , playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.BlackFraction[1], playerID2 = self.BlackFraction[2]})
					    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "2"})
					    	end
					    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
					    	Timers:CreateTimer(0.2,function()
				    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
				    		end)
					    	self.Time = 31
					    	self:UpdateTime()
					    	self.RedPicked = false 
					    	return
					    end
			    	end)
		    	end
			end
	    end
	else
		self.PickedPlayerBlack[playerId] = playerId
    	for _,_ in pairs (self.PickedPlayerBlack) do 
    		pickedplayercount = pickedplayercount + 1
    	end
		self.BlackMana = self.BlackMana - mana_cost 
		self:UnSelectedCreate(self.BlackMana, (self.PlayerTeam2Count - pickedplayercount),self.BlackFraction)
		CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})
		if self.BlackFraction[2] == nil then
			if self.BlackFraction[1] == playerId then 
				table.remove(self.BlackFraction, 1)
			   	table.sort( self.BlackFraction)
	    		self.Time = "undefined"
				CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil})
				CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
		    	Timers:CreateTimer(1.0,function()
		    		if self.RedFraction[1] == nil then
		    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
						self.Time = 11
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    else
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			    		if self.RedFraction[2] == nil then
			    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = nil})
			    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1],playerID2 = nil})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	else
				    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1], playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	end
				    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
				    	Timers:CreateTimer(0.2,function()
			    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			    		end)
				    	self.Time = 31
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    end
			    end)
	    	end
		else 
			if self.BlackFraction[1] == playerId then 
				CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil })
		    elseif self.BlackFraction[2] == playerId then 
		    	CustomNetTables:SetTableValue("draft", "hilight", {playerID2 = nil})
		    end
		   	if self.PickedPlayer[self.BlackFraction[1]] ~= nil and self.PickedPlayer[self.BlackFraction[2]] ~= nil then
	    		table.remove(self.BlackFraction, 2)
	    		table.remove(self.BlackFraction, 1)
	    		table.sort( self.BlackFraction)
	    		self.Time = "undefined"
				CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
				CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "blank"})
				Timers:CreateTimer(1.0,function()
					if self.RedFraction[1] == nil then
						CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = nil , playerID2 = nil})
		    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = nil, playerID2 = nil})
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "strategy"})
						self.Time = 11
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    else
				    	CustomNetTables:SetTableValue("draft", "gamephrase", {gamephrase = "pick"})
			    		if self.RedFraction[2] == nil then
			    			CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = nil})
			    			CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1],playerID2 = nil})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	else
				    		CustomNetTables:SetTableValue("draft", "hilight", {playerID1 = self.RedFraction[1] , playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "pickorder", {playerID1 = self.RedFraction[1], playerID2 = self.RedFraction[2]})
				    		CustomNetTables:SetTableValue("draft", "teamqueue", {team = "1"})
				    	end
				    	CustomNetTables:SetTableValue("draft", "revert", {time = 0.2})
				    	Timers:CreateTimer(0.2,function()
			    			CustomNetTables:SetTableValue("draft", "revert", {time = 0})
			    		end)
				    	self.Time = 31
				    	self:UpdateTime()
				    	self.RedPicked = true 
				    	return
				    end
			   	end)
		    end
		end
    end
end

function DraftSelection:Random()
    local randomthirty = RandomInt(1, 100)
    local availablethirty = 0
    local availabletwenty = 0
    local availableten = 0
    if randomthirty == 1 then 	
	    for hero,_ in pairs(self.thirtyCost) do
	    	if not self.Banned[hero] and self.AvailableHeroes[hero] then
	        	availablethirty = availablethirty + 1
	    	end
	    end
	end

	if availablethirty > 0 then 
	    local randomIndex = RandomInt(1, availablethirty)
	    local index = 1
	    for hero,_ in pairs(self.thirtyCost) do
		    if self.AvailableHeroes[hero] then
		        if index == randomIndex then
	        		return hero
	        	end
	        	index = index + 1
	    	end
		end
    else
    	local random = RandomInt(1, 100)
    	if random <= 30 then
    		for hero,_ in pairs(self.twentyCost) do
		    	if not self.Banned[hero] and self.AvailableHeroes[hero] then
		        	availabletwenty = availabletwenty + 1
		    	end
		    end
		    if availabletwenty > 0 then 
		    	local randomIndex = RandomInt(1, availabletwenty)
		    	local index = 1
		    	for hero,_ in pairs(self.twentyCost) do
			    	if self.AvailableHeroes[hero] then
			        	if index == randomIndex then
			        		return hero
			        	end
			        	index = index + 1
			    	end
			    end
			end
		else
			for hero,_ in pairs(self.tenCost) do
		    	if not self.Banned[hero] and self.AvailableHeroes[hero] then
		        	availableten = availableten + 1
		    	end
		    end
		    if availableten > 0 then 
		    	local randomIndex = RandomInt(1, availableten)
		    	local index = 1
		    	for hero,_ in pairs(self.tenCost) do
			    	if self.AvailableHeroes[hero] then
			        	if index == randomIndex then
		        			return hero
			        	end
			        	index = index + 1
			    	end
				end
			end
    	end
    end
end

function DraftSelection:OnSummon(args)
	local playerId = args.playerId
    local hero = self.Picked[playerId]
    local skin = self.SkinSelect[self.Picked[playerId]] 
    local time = playerId
    if time > 0 then 
    	time = time / 2
    end
    if playerId == 0 then 
    	GameRules:ForceGameStart()
    	GameRules:SendCustomMessage("Fate/Another II by ZeFiRoFT", 0, 0)
    end
    
    --Timers:CreateTimer(time,function()
    	self:AssignHero(playerId, hero, skin, true)
    --end)
    --if skin > 0 then 


    --end

    --if IsDivine(hero) then 

    --end
    
end

function DraftSelection:UnSelectedCreate(mana, players,team)
	if team == self.BlackFraction then 
		self.UnselectedBlack = self:ManaCalculate(mana, players)
		CustomNetTables:SetTableValue("draft", "black_unselected", self.UnselectedBlack)
	elseif team == self.RedFraction then 
		self.UnselectedRed = self:ManaCalculate(mana, players)
		CustomNetTables:SetTableValue("draft", "red_unselected", self.UnselectedRed)
	end
end

function DraftSelection:ManaCalculate(mana, players)
	local currentMana = mana 
	local playercount = players 
	if currentMana / playercount == 10 then 
		for k,v in pairs (self.twentyCost) do
			if self.AvailableHeroes[k] then
				self.Unselected[k] = v
			end
		end
		for j,l in pairs (self.thirtyCost) do 
			if self.AvailableHeroes[j] then
				self.Unselected[j] = l
			end
		end
		return self.Unselected
	elseif currentMana / playercount > 10 and currentMana / playercount < 13 then  
		for j,l in pairs (self.thirtyCost) do 
			if self.AvailableHeroes[j] then
				self.Unselected[j] = l
			end
		end
		return self.Unselected
	end
end 

function DraftSelection:AssignHero(playerId, hero, skin)
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
                oldHero:SetRespawnsDisabled(true)
                PlayerResource:ReplaceHeroWith(playerId, hero, 3000, 0)
                UTIL_Remove(oldHero)
                local newHero = Entities:FindByClassname(nil, hero)
                Timers:CreateTimer(function()
		            if newHero ~= nil then 
				        if skin == 1 then 
				            print('skin = 1')
				            newHero:AddAbility("alternative_01")
				            newHero:FindAbilityByName("alternative_01"):SetLevel(1)
				            print('skin add')
				        end
				       	return nil 
				    else 
				        return 1
				    end
				end)
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

function GetManaCost(D2hero)
	for k,v in pairs (heroesTable) do 
		if D2hero == k then 
			local mana_cost = GetUnitKV(heroesTable[D2hero], "ManaCost")
			return mana_cost
		end
	end
	if not mana_cost then 
		local mana_cost = 0
		return mana_cost
	end
end

