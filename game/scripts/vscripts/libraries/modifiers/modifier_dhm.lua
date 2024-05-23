------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- Sana , ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------
DraftSelectioN = DraftSelectioN or class({})

function DraftSelectioN:constructor()

	self.AllHeroes = {}
	self.AvailableHeroes = {}
	self.UnAvailableHeroes = {}
	self.tenCost = {}
	self.twentyCost = {}
	self.SkinSelect = {}
	self.AvailableSkins = {}
	self.Picked = {}
	self.PickedPlayer = {}
	self.BannedPlayer = {}
	self.PickedPlayerRed = {}
	self.PickedPlayerBlack = {}
	self.PreBanned = {}
	self.PreSelected = {}
	self.SelectedBar = {}
	self.BannedBar = {}
	self.PlayerTeam1Count = PlayerResource:GetPlayerCountForTeam(2)
	self.PlayerTeam2Count = PlayerResource:GetPlayerCountForTeam(3)
	self.BannedHeroes = {}
	self.RedFaction = {}
	self.BlackFaction = {}
	self.RedTeamNumber = "1"
	self.BlackTeamNumber = "2"
	self.RedTeam = {}
	self.BlackTeam = {}
	self.AvailableSkins = {}
	local heroList = LoadKeyValues("scripts/npc/herolist.txt")
    local skinList = LoadKeyValues("scripts/npc/skin.txt")
    local skinTier = LoadKeyValues("scripts/npc/skinaccess.txt")
    local testList = LoadKeyValues("scripts/npc/herotest.txt")
    local ContributeUnlock = LoadKeyValues("scripts/npc/contributeunlock.txt")
	heroList["npc_dota_hero_wisp"] = nil
	self.AllHeroes = heroList
	self.AvailableHeroes = heroList
	self.AvailableSkins = skinList
	self.UnAvailableHeroes = testList
	self.skinTier = skinTier
	self.ContributeUnlock = ContributeUnlock
	self.skinAccess = {}
	self.PAuthority = {}
	--self.UnselectedRed = {}
	--self.UnselectedBlack = {}
	self.Id = {}
	--self.RedMana = 100
	--self.BlackMana = 100
	self.Draft = "draft"
	self.strategy_time = 10 
	self.standby_time = 10
	self.total_ban = 4
	self.load_time = 5
	self.ban_time = 10 
	self.show_time = 2
	self.ban_order = 1
	self.BanOrder = {}
	self.total_pick_order = 1 + math.ceil((#GameRules.AddonTemplate.vUserIds - 1)/2)
	self.pick_time = 15 
	self.PickOrder = {}
	self.pick_order = 1
	self.GamePhase = "load"

	CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=0} )
	
	--[[for key, value in pairs (heroList) do
		local manacost = GetManaCost(key)
		if manacost == 10 then 
			self.tenCost[key] = value
		elseif manacost == 20 then 
			self.twentyCost[key] = value
		end
	end]]

	if IsInToolsMode() then 		
		CustomNetTables:SetTableValue("draft", "mode", {mode="tool"})
	end

	local j = 0
	local k = 0
	for i = 0, #GameRules.AddonTemplate.vUserIds - 1 do
		local playerId = i
	    local player = PlayerResource:GetPlayer(playerId)
	    local id = PlayerResource:GetSteamAccountID(playerId)
	    print(id)
	    table.insert(self.Id, i, id)  
		if PlayerResource:GetTeam(playerId) == 2 then 
			j = j + 1
			table.insert(self.RedFaction, j, playerId)
			table.insert(self.RedTeam, playerId, playerId)
			table.sort( self.RedFaction)
		elseif PlayerResource:GetTeam(playerId) == 3 then 
			k = k + 1
			table.insert(self.BlackFaction, k, playerId)
			table.insert(self.BlackTeam, playerId, playerId)
			table.sort( self.BlackFaction)
		end
		if player ~= nil then
			if not player.authority_level or player.authority_level == nil then 
			   	local args = {
			   		index = i,
			   		userid = i + 1,
			   	}
			   	_G.AuthorityModule:CheckAuthority(args)
			   	--print("authority level " .. player.authority_level)
			   	table.insert(self.PAuthority, i, player.authority_level) 
			else
			   	table.insert(self.PAuthority, i, player.authority_level) 
			end
		end
	end

	self.BanListener = CustomGameEventManager:RegisterListener("draft_hero_ban", function(id, ...)
	    Dynamic_Wrap(self, "OnBan")(self, ...) 
	end)
	self.BanListener = CustomGameEventManager:RegisterListener("draft_hero_preban", function(id, ...)
	    Dynamic_Wrap(self, "OnPreBan")(self, ...) 
	end)
	self.SkinListener = CustomGameEventManager:RegisterListener("draft_hero_skin", function(id, ...)
	    Dynamic_Wrap(self, "OnSkin")(self, ...) 
	end)
	self.PreSelectedListener = CustomGameEventManager:RegisterListener("draft_hero_preselect", function(id, ...)
	    Dynamic_Wrap(self, "OnPreSelect")(self, ...) 
	end)
	self.ClickListener = CustomGameEventManager:RegisterListener("draft_hero_pick", function(id, ...)
	    Dynamic_Wrap(self, "OnSelect")(self, ...) 
	end)
	self.ChangePortraitListener = CustomGameEventManager:RegisterListener("draft_hero_changeportrait", function(id, ...)
	    Dynamic_Wrap(self, "OnSelectBar")(self, ...) 
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
	self.SwitchListener = CustomGameEventManager:RegisterListener("draft_hero_switch", function(id, ...)
	    Dynamic_Wrap(self, "OnSwitch")(self, ...) 
	end)

	CustomNetTables:SetTableValue("draft", "all", self.AllHeroes)
	CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	CustomNetTables:SetTableValue("draft", "unavailable", self.UnAvailableHeroes)
	CustomNetTables:SetTableValue("draft", "skin", self.AvailableSkins)

	CustomNetTables:SetTableValue("draft", "skintier", self.skinTier)
    CustomNetTables:SetTableValue("draft", "skinaccess", self.skinAccess)
    CustomNetTables:SetTableValue("draft", "authority", self.PAuthority)

    CustomNetTables:SetTableValue("draft", "game", LoadAKeyValues())
	CustomNetTables:SetTableValue("draft", "redteam", self.RedTeam)
	CustomNetTables:SetTableValue("draft", "blackteam", self.BlackTeam)
	CustomNetTables:SetTableValue("draft", "picked", self.Picked)
	CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)
	CustomNetTables:SetTableValue("draft", "bannedplayer", self.BannedPlayer)
	CustomNetTables:SetTableValue("draft", "banned", self.BannedHeroes)
	--CustomNetTables:SetTableValue("draft", "red_unselected", self.UnselectedRed)
	--CustomNetTables:SetTableValue("draft", "black_unselected", self.UnselectedBlack)
	--CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
	--CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})

	self.Time = self.load_time
	self:UpdateTime()
	CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
	CustomNetTables:SetTableValue("draft", "draftmode", {draft = self.Draft})
	Timers:CreateTimer(self.load_time, function()
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		--CustomNetTables:SetTableValue("draft", "ten", self.tenCost)
		--CustomNetTables:SetTableValue("draft", "twenty", self.twentyCost)
			--CustomNetTables:SetTableValue("draft", "thirty", self.thirtyCost)
		CustomNetTables:SetTableValue("draft", "panel", {game = "start"})
		CustomNetTables:SetTableValue("draft", "si", self.Id)
		self:StartBanPhase()
	end)
end

function DraftSelectioN:UpdateTime()
	if self.Time == "undefined" then return end
    self.Time = math.max(self.Time - 1, 0)
    CustomNetTables:SetTableValue("draft", "time", {time = self.Time})

    if self.Time > 0 then
    	Timers:CreateTimer('draft_timer', {
			endTime = 1.0,
			callback = function()
            self:UpdateTime()
        end})
    end
end

function DraftSelectioN:StartBanPhase()	
	if IsInToolsMode() then 
		self.total_ban = 2
	end	
	self.Time = self.ban_time
	self.GamePhase = "ban"

	for i = 1,self.total_ban do 
		if i % 2 < 1 then 
			table.insert(self.BanOrder, i, {teamNum = self.BlackTeamNumber, playerId = self.BlackFaction[self.PlayerTeam2Count - math.floor(i/2) + 1]})
		else
			table.insert(self.BanOrder, i, {teamNum = self.RedTeamNumber, playerId = self.RedFaction[self.PlayerTeam1Count - math.floor(i/2)]})
		end
	end
	--print(self.BanOrder[self.ban_order])
	CustomNetTables:SetTableValue("draft", "banorder", self.BanOrder[self.ban_order])
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
	CustomNetTables:SetTableValue("draft", "pickorder", {playerId1 = nil, playerId2 = nil})
	self:UpdateTime()
	self:OnDCBan()
end

function DraftSelectioN:OnPreBan(args)
	local playerId = args.playerId
    local hero = args.hero
    --print('recieve pick data')
    self.BannedBar[playerId] = hero
    --print('send data hero ' .. hero)
    CustomNetTables:SetTableValue("draft", "ban_bar", self.BannedBar)
end

function DraftSelectioN:OnDCBan()

	Timers:CreateTimer('draft_ban_timer', {
		endTime = self.ban_time,
		callback = function()
		local player_ban = {
			playerId = self.BanOrder[self.ban_order]['playerId'],
		    hero = nil,
		}
        self:OnBan(player_ban)
    end})
end

function DraftSelectioN:OnBan(args)
	local playerId = args.playerId

	if IsInToolsMode() then 
		self.total_ban = 1
	end	

	if self.BannedPlayer[playerId] == playerId then
	   	return 
	end

	if self.GamePhase == "blank" then 
    	print('blank state')
    	return 
    end

	if args.hero ~= nil then
	    local hero = args.hero

	    self.AvailableHeroes[hero] = nil
	    self.BannedHeroes[hero] = 1

	    CustomNetTables:SetTableValue("draft", "banned", self.BannedHeroes)
	    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	end

	self.BannedPlayer[playerId] = playerId
	CustomNetTables:SetTableValue("draft", "bannedplayer", self.BannedPlayer)

	self.ban_order = self.ban_order + 1

	if self.ban_order <= self.total_ban then
		
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_ban_timer')
		self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		Timers:CreateTimer(self.show_time, function()
			self.GamePhase = "ban"
			CustomNetTables:SetTableValue("draft", "banorder", self.BanOrder[self.ban_order])
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = self.ban_time
			self:UpdateTime()
			self:OnDCBan()
		end)
	else
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_ban_timer')
		self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		CustomNetTables:SetTableValue("draft", "banorder", {playerId = nil})
		Timers:CreateTimer(self.show_time, function()	
			self:StartPickPhase()
		end)
	end
end

function DraftSelectioN:OnSkin(args)
	local playerId = args.playerId
    local hero = args.hero
    local skin = args.skin
    print('skin = ' .. skin)

    self.SkinSelect[hero] = skin

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)

    local player = PlayerResource:GetPlayer(playerId)
    if player.authority_level == nil then 
    	local args = {
    		index = playerId,
    		userid = playerId + 1,
    	}
    	_G.AuthorityModule:CheckAuthority(args)
    end

    if self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level ~= nil and player.authority_level > 0) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
    		self.skinAccess[playerId] = true
    	else
    		self.skinAccess[playerId] = false
    	end
    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level ~= nil and player.authority_level >= 3) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
    		self.skinAccess[playerId] = true
    	else
    		self.skinAccess[playerId] = false
    	end
    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level ~= nil and player.authority_level >= 4) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
    		self.skinAccess[playerId] = true
    	else
    		self.skinAccess[playerId] = false
    	end
    else
    	self.skinAccess[playerId] = true
    end

    CustomNetTables:SetTableValue("draft", "skinaccess", self.skinAccess)
end 

function DraftSelectioN:StartPickPhase()
	
	self.Time = self.pick_time
	self.GamePhase = "pick"

	if IsInToolsMode() then
		self.pick_order = 2 
		self.total_pick_order = 2
	end

	for i = 1, self.total_pick_order do 
		if i == 1 then 
			table.insert(self.PickOrder, i, {teamNum = self.BlackTeamNumber, playerId1 = self.BlackFaction[i], playerId2 = nil})
		elseif i == self.total_pick_order then 
			if self.total_pick_order % 2 == 0 then 
				table.insert(self.PickOrder, i, {teamNum = self.RedTeamNumber, playerId1 = self.RedFaction[self.PlayerTeam1Count], playerId2 = nil})				
			else
				table.insert(self.PickOrder, i, {teamNum = self.BlackTeamNumber, playerId1 = self.BlackFaction[self.PlayerTeam2Count], playerId2 = nil})
			end
		elseif i % 2 == 0 then 
			table.insert(self.PickOrder, i, {teamNum = self.RedTeamNumber, playerId1 = self.RedFaction[i - 1], playerId2 = self.RedFaction[i]})
		else
			table.insert(self.PickOrder, i, {teamNum = self.BlackTeamNumber, playerId1 = self.BlackFaction[i - 1], playerId2 = self.BlackFaction[i]})
		end
	end

	CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.pick_order])
	CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.pick_order])
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})

	--self.pick_order = self.pick_order + 1
	self:UpdateTime()
	self:OnDCRandom()
end

function DraftSelectioN:OnDCRandom()

	Timers:CreateTimer('draft_random_timer', {
		endTime = self.pick_time,
		callback = function()
		local player1 = {
			playerId = self.PickOrder[self.pick_order]['playerId1'],
		    hero = nil,
		    teamNum = self.PickOrder[self.pick_order]['teamNum']
		}
        self:OnRandom(player1)

        if self.PickOrder[self.pick_order]['playerId2'] ~= nil then 
        	local player2 = {
				playerId = self.PickOrder[self.pick_order]['playerId2'],
			    hero = nil,
			    teamNum = self.PickOrder[self.pick_order]['teamNum']
			}
	        self:OnRandom(player2)
	    end
    end})
end

function DraftSelectioN:OnPreSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    self.PreSelected[playerId] = hero

    CustomNetTables:SetTableValue("draft", "preselect", self.PreSelected)
end

function DraftSelectioN:OnSelectBar(args)
	local playerId = args.playerId
    local hero = args.hero

    self.SelectedBar[playerId] = hero

    CustomNetTables:SetTableValue("draft", "select_bar", self.SelectedBar)
end

function DraftSelectioN:OnSelect(args)
	local playerId = args.playerId
    local hero = args.hero
    local team = args.teamNum

    print('servant ' .. hero .. ' has been picked')

	if self.PickOrder[self.pick_order]['playerId1'] ~= playerId and self.PickOrder[self.pick_order]['playerId2'] ~= playerId then 
		return 
	end
	
	if IsInToolsMode() then
		self.pick_order = 3 
	end
	if self.PickedPlayer[playerId] == playerId then
	   	return 
	end

	if self.AvailableHeroes[hero] == nil then 
		return 
	end

	if self.GamePhase == "blank" then 
    	print('blank state')
    	return 
    end

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

    if self.pick_order == 1 then 
    	self.pick_order =  self.pick_order + 1
    	self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.show_time, function()
			self.GamePhase = "pick"
			CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.pick_order])
			CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.pick_order])
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = self.pick_time
			self:UpdateTime()
			self:OnDCRandom()
		end)
	elseif self.pick_order >= self.total_pick_order then 
		self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.show_time, function()
			self.GamePhase = "strategy"
			CustomNetTables:SetTableValue("draft", "hilight", {playerId1 = nil , playerId2 = nil})
		    CustomNetTables:SetTableValue("draft", "pickorder", {playerId1 = nil, playerId2 = nil})
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = self.strategy_time + self.standby_time
			self:UpdateTime()
			self:OnSummonTimer()
		end)
	else
		if self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			self.pick_order = self.pick_order + 1
			self.GamePhase = "blank"
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = "undefined"
			Timers:RemoveTimer('draft_timer')
			Timers:RemoveTimer('draft_random_timer')
			Timers:CreateTimer(self.show_time, function()
				self.GamePhase = "pick"
				CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.pick_order])
				CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.pick_order])
				CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
				self.Time = self.pick_time
				self:UpdateTime()
				self:OnDCRandom()
			end)
		end
		if self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and not self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 =  nil, playerId2 = self.PickOrder[self.pick_order]['playerId2']})
		elseif not self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 = self.PickOrder[self.pick_order]['playerId1'] , playerId2 = nil})
		end
	end

    --[[if team == "1" then 
    	self.PickedPlayerRed[playerId] = hero
    	for _,_ in pairs (self.PickedPlayerRed) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	self.RedMana = self.RedMana - mana_cost 
    	CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    	Timers:CreateTimer(0.05, function()
	    	self.UnselectedRed = self:ManaCalculate(self.RedMana, self.PlayerTeam1Count - pickedplayercount)
			CustomNetTables:SetTableValue("draft", "red_unselected", self.UnselectedRed)
		end)
    elseif team == "2" then 
    	self.PickedPlayerBlack[playerId] = hero
    	for _,_ in pairs (self.PickedPlayerBlack) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	self.BlackMana = self.BlackMana - mana_cost 
    	CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})
    	Timers:CreateTimer(0.05, function()
	    	self.UnselectedBlack = self:ManaCalculate(self.BlackMana, self.PlayerTeam2Count - pickedplayercount)
			CustomNetTables:SetTableValue("draft", "black_unselected", self.UnselectedBlack)
		end)
	end]]
end

function DraftSelectioN:OnRandom(args)
	local playerId = args.playerId
    local hero = nil
    local team = args.teamNum
    local mana_cost = 10

    if self.PickOrder[self.pick_order]['playerId1'] ~= playerId and self.PickOrder[self.pick_order]['playerId2'] ~= playerId then 
		print('not player pick')
		return 
	end

	if self.PickedPlayer[playerId] == playerId then
		print('player already picked')
    	return 
    end

    if self.GamePhase == "blank" then 
    	print('blank state')
    	return 
    end

    if self.SelectedBar[playerId] ~= nil and self.SelectedBar[playerId] ~= "random" and (self.AvailableHeroes[self.SelectedBar[playerId]] ~= nil or self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1) then 
    	if self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1 then 
    		if PlayerResource:GetPlayer(playerId).authority_level >= 1 then 
    			hero = self.SelectedBar[playerId] 
    			mana_cost = GetManaCost(hero)
    		else
    			hero = self:Random()
    			mana_cost = 10
    		end
    	else
    		hero = self.SelectedBar[playerId] 
    		mana_cost = GetManaCost(hero)
    	end
    else
    	hero = self:Random()
    	if self.AvailableHeroes[hero] == nil then 
    		hero = self:Random()
    	end
    	mana_cost = 10
    end

    print('servant ' .. hero .. ' has been random')
    if IsInToolsMode() then
		self.pick_order = 3 
	end

    self.Picked[playerId] = hero
    self.PickedPlayer[playerId] = playerId
    self.AvailableHeroes[hero] = nil
    self.SkinSelect[hero] = 0

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)
	    
    CustomNetTables:SetTableValue("draft", "picked", self.Picked)
    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
    CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)

    local pickedplayercount = 0

    if self.pick_order == 1 then 
    	self.pick_order = self.pick_order + 1
    	self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.show_time, function()
			self.GamePhase = "pick"
			CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.pick_order])
			CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.pick_order])
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = self.pick_time
			self:UpdateTime()
			self:OnDCRandom()
		end)
	elseif self.pick_order >= self.total_pick_order then 
		self.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.show_time, function()
			self.GamePhase = "strategy"
			CustomNetTables:SetTableValue("draft", "hilight", {playerId1 = nil , playerId2 = nil})
		    CustomNetTables:SetTableValue("draft", "pickorder", {playerId1 = nil, playerId2 = nil})
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = self.strategy_time + self.standby_time
			self:UpdateTime()
			self:OnSummonTimer()
		end)
	else
		if self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			self.pick_order =  self.pick_order + 1
			self.GamePhase = "blank"
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
			self.Time = "undefined"
			Timers:RemoveTimer('draft_timer')
			Timers:RemoveTimer('draft_random_timer')
			Timers:CreateTimer(self.show_time, function()
				self.GamePhase = "pick"
				CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.pick_order])
				CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.pick_order])
				CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.GamePhase})
				self.Time = self.pick_time
				self:UpdateTime()
				self:OnDCRandom()
			end)
		end
		if self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and not self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 =  nil, playerId2 = self.PickOrder[self.pick_order]['playerId2']})
		elseif not self.PickedPlayer[self.PickOrder[self.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 = self.PickOrder[self.pick_order]['playerId1'] , playerId2 = nil})
		end
	end

    --[[if team == "1" then 
    	self.PickedPlayerRed[playerId] = hero
    	for _,_ in pairs (self.PickedPlayerRed) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	self.RedMana = self.RedMana - mana_cost 
    	CustomNetTables:SetTableValue("draft", "red_mana", {mana = self.RedMana})
    	Timers:CreateTimer(0.05, function()
	    	self.UnselectedRed = self:ManaCalculate(self.RedMana, self.PlayerTeam1Count - pickedplayercount)
			CustomNetTables:SetTableValue("draft", "red_unselected", self.UnselectedRed)
		end)
    elseif team == "2" then 
    	self.PickedPlayerBlack[playerId] = hero
    	for _,_ in pairs (self.PickedPlayerBlack) do 
    		pickedplayercount = pickedplayercount + 1
    	end
    	self.BlackMana = self.BlackMana - mana_cost 
    	CustomNetTables:SetTableValue("draft", "black_mana", {mana = self.BlackMana})
    	Timers:CreateTimer(0.05, function()
	    	self.UnselectedBlack = self:ManaCalculate(self.BlackMana, self.PlayerTeam2Count - pickedplayercount)
			CustomNetTables:SetTableValue("draft", "black_unselected", self.UnselectedBlack)
		end)
	end]]
end
    	
function DraftSelectioN:Random()
    local availabletwenty = 0
    local availableten = 0
   
    local random = RandomInt(1, 100)
    if random <= 20 then
    	for hero,_ in pairs(self.twentyCost) do
	    	if not self.BannedHeroes[hero] and self.AvailableHeroes[hero] then
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
	    	if not self.BannedHeroes[hero] and self.AvailableHeroes[hero] then
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

function DraftSelectioN:OnSummonTimer()
	local heroes_cache = {}
	for playerId,servant in pairs(self.Picked) do 
		heroes_cache[servant] = 1 
	end
	Timers:CreateTimer(1, function()
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = 'strategy'})
	end)
	--PrecacheUnitFromTableAsync(heroes_cache, function() end)
	Timers:CreateTimer('draft_summon_timer', {
		endTime = self.strategy_time,
		callback = function()
		
			for i = 0, #GameRules.AddonTemplate.vUserIds - 1 do
			    self:OnSummon({playerId = i})
		    end
		
    end})

    Timers:CreateTimer(self.standby_time + self.strategy_time, function()
    	GameRules:ForceGameStart()
    	GameRules:SendCustomMessage("Fate/Another II by ZeFiRoFT", 0, 0)
    	Timers:CreateTimer(1, function()
    		CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=1} )
    	end)
    end)
end

function DraftSelectioN:OnSummon(args)
	local playerId = args.playerId
    local hero = self.Picked[playerId]
    local skin = self.SkinSelect[self.Picked[playerId]] or 0
    local time = playerId
    local player = PlayerResource:GetPlayer(playerId)

    if hero == nil then 
    	hero = self:Random()
    	self.Picked[playerId] = hero
    	self.AvailableHeroes[hero] = nil
    	self.SkinSelect[hero] = 0
		self.PickedPlayer[playerId] = playerId
    end

    if self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level == nil or player.authority_level == 0) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level == nil or player.authority_level < 3) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
    	if (player.authority_level == nil or player.authority_level < 4) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    end

    self.SkinSelect[hero] = skin

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)

    Timers:CreateTimer(playerId * 0.1, function()
		PrecacheUnitByNameAsync(hero, function()
		    self:AssignHero(playerId, hero, skin, true)
		end)
	end)

    --[[if not self.game_start then 
    	self.game_start = true
    	GameRules:ForceGameStart()
    	GameRules:SendCustomMessage("Fate/Another II by ZeFiRoFT", 0, 0)
    	CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=1} )
    end]]
end

function DraftSelectioN:AssignHero(playerId, hero, skin)
    --PrecacheUnitByNameAsync(hero, function()
        --Timers:CreateTimer(function()
            local conn_state = PlayerResource:GetConnectionState(playerId)

            --0 = No connection
            --1 = Bot
            --2 = Player
            --3 = Disconnected

            --if conn_state == 3 or conn_state == 0 then 
            --    return 1
            --else
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
                --return nil
            --end
       -- end)        
   -- end)
end

function DraftSelectioN:ManaCalculate(mana, pick_players)
	local unselected = {}
	local non_pick_player = math.ceil(#GameRules.AddonTemplate.vUserIds / 2) - pick_players
	local average_mana = mana / math.max(1, pick_players) 
	--[[print('player picked: ' .. pick_players)
	print('player left: ' .. non_pick_player)
	print('mana average: ' .. average_mana)]]
	if math.abs(average_mana) <= 10 then 
		for hero,_ in pairs (self.twentyCost) do
			if self.AvailableHeroes[hero] then
				unselected[hero] = 1
			end
		end
	end
	return unselected
end 

--[[heroesTable = {
	npc_dota_hero_zuus = "npc_dota_hero_fran_chan",
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
}]]

function GetManaCost(D2hero)
	local mana_cost = GetUnitKV(heroesTable[D2hero], "ManaCost") or 0	
	if mana_cost == 0 then 
		print('Servant ' .. D2hero .. ' was not found.')
	end
	return mana_cost
end