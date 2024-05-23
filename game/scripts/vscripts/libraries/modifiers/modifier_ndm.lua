------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- Sana , ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------
DraftSelectioN = DraftSelectioN or class({})

function DraftSelectioN:constructor()

	self.AllHeroes = {}
	self.AvailableHeroes = {}
	self.UnAvailableHeroes = {}
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
	self.BanOrder = {}
	self.PickOrder = {}
	self.DC_count = {}
	self.PlayerTeam1Count = GameRules:GetCustomGameTeamMaxPlayers(2)
	self.PlayerTeam2Count = GameRules:GetCustomGameTeamMaxPlayers(3)
	self.max_player = self.PlayerTeam1Count + self.PlayerTeam2Count
	self.BannedHeroes = {}
	self.RedFaction = {}
	self.BlackFaction = {}
	self.RedTeamNumber = "1"
	self.BlackTeamNumber = "2"
	self.RedTeam = {}
	self.BlackTeam = {}
	self.AvailableSkins = {}
	self.HiddenHero = LoadKeyValues("scripts/npc/hero_hidden.txt")
	local heroList = LoadKeyValues("scripts/npc/herolist.txt")
    local heroList2 = LoadKeyValues("scripts/npc/herolist.txt")
    local testList = LoadKeyValues("scripts/npc/herotest.txt")
    heroList["npc_dota_hero_wisp"] = nil
	heroList2["npc_dota_hero_wisp"] = nil
	self.AllHeroes = heroList
	self.AvailableHeroes = heroList2
    self.AvailableSkins = LoadKeyValues("scripts/npc/skin.txt")
    self.skinTier = LoadKeyValues("scripts/npc/skinaccess.txt")
    self.UnAvailableHeroes = testList
    self.ContributeUnlock = LoadKeyValues("scripts/npc/contributeunlock.txt")
    self.Unique = LoadKeyValues("scripts/npc/unique.txt")
	self.skinAccess = {}
	self.skintier = {}
	self.PAuthority = {}
	self.Id = {}

	self.Draft = {
		draft = "draft",
		strategy_time = 10,
		standby_time = 5,
		ban = true,
		total_ban = GameRules.AddonTemplate.voteBanHeroTable or 0,
		load_time = 5,
		ban_time = 20 ,
		pick_time = 30 ,
		show_time = 2,
		ban_order = 0,
		pick_order = 1,
		total_pick_order = 1 + (self.max_player/2),
		devPresence = false,
		GamePhase = "load"
	} 

	CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=0} )

	if self.Draft.total_ban == 0 then 
		self.Draft.ban_time = 0
		self.Draft.ban = false
	else
		CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Ban_Mode" .. self.Draft.total_ban} )
	end
	

	for k,v in pairs (testList) do 
		if v == 1 and self.AllHeroes[k] == nil then 
			self.AllHeroes[k] = v 
		end
	end

	if IsInToolsMode() then 		
		CustomNetTables:SetTableValue("draft", "mode", {mode="tool"})
		for i = 0, 13 do 
            if i > 0 then 
                Tutorial:AddBot("npc_dota_hero_wisp", "", "", false)
                if i > 0 and i < 8 then
                    PlayerResource:SetCustomTeamAssignment(i, 3)
                else
                    PlayerResource:SetCustomTeamAssignment(i, 2)
                end

            end
        end
	end

	local j = 0
	local k = 0
	for i = 0, self.max_player - 1 do
		if PlayerResource:IsValidPlayer(i) then
			local playerId = i
		    local player = PlayerResource:GetPlayer(playerId)
		    local id = PlayerResource:GetSteamAccountID(playerId)
		    print(id)
		    table.insert(self.Id, i, id)  
		    local alvl = PlayerTables:GetTableValue("authority", 'alvl', i) or 0
			table.insert(self.PAuthority, i, alvl) 
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

			local alvl = PlayerTables:GetTableValue("authority", 'alvl', i)

			if alvl == 5 then 
			   	self.Draft.devPresence = true
			   	Timers:CreateTimer(3.0, function()

			    	for l = 0, self.max_player - 1 do 
			    		if PlayerResource:IsValidPlayerID(l) then
				   			if PlayerTables:GetTableValue("authority", 'alvl', l) < 4 then
				   				PlayerTables:SetTableValue("authority", "alvl", 4, l, true)
			    				self.PAuthority[l] = 4
				   				CustomNetTables:SetTableValue("draft", "authority", self.PAuthority)
				   			end
				   		end
			    	end
			    	SendChatToPanorama('Zefiroft is here')
			    	CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Dev_Presence"} )
			    end)
			end

			if PlayerTables:GetTableValue("database", "db", i) == true then 
				local new_lvl = iupoasldm.jyiowe[i].IFY.ATLVL
				skoyhidpo:initialize(i)
				if alvl < new_lvl and not self.Draft.devPresence then
					self.PAuthority[i] = new_lvl
					CustomNetTables:SetTableValue("draft", "authority", self.PAuthority)
				end
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

	self.Time = self.Draft.load_time
	self:UpdateTime()
	CustomNetTables:SetTableValue("draft", "time", {time = self.Time})
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
	CustomNetTables:SetTableValue("draft", "draftmode", {draft = self.Draft.draft})
	Timers:CreateTimer(self.Draft.load_time, function()
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')

		CustomNetTables:SetTableValue("draft", "panel", {game = "start"})
		CustomNetTables:SetTableValue("draft", "si", self.Id)
		if self.Draft.total_ban > 0 then
			self:StartBanPhase()
		else
			self:StartPickPhase()
		end
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

	self.Time = self.Draft.ban_time
	self.Draft.GamePhase = "ban"
	self.BanOrder = {
		red = {},
		black = {},
	}

	for i = 1,self.Draft.total_ban do 
		if i % 2 < 1 then 
			--self.BanOrder.black['playerId' .. (math.floor(i/2) + 1)] = self.BlackFaction[self.PlayerTeam2Count - math.floor(i/2) + 1]
			--table.insert(self.BanOrder, i, {teamNum = self.BlackTeamNumber, playerId = self.BlackFaction[self.PlayerTeam2Count - math.floor(i/2) + 1]})
			table.insert(self.BanOrder.black, math.floor(i/2), {playerId = self.BlackFaction[self.PlayerTeam2Count - math.floor(i/2) + 1]})
		else
			--self.BanOrder.red['playerId' .. math.floor(i/2)] = self.RedFaction[self.PlayerTeam1Count - math.floor(i/2)]
			--table.insert(self.BanOrder, i, {teamNum = self.RedTeamNumber, playerId = self.RedFaction[self.PlayerTeam1Count - math.floor(i/2)]})
			table.insert(self.BanOrder.red, (math.floor(i/2) + 1), {playerId = self.RedFaction[self.PlayerTeam1Count - math.floor(i/2)]})
		end
	end
	if IsInToolsMode() then 
		print('draft dev mode check ban order')
		for k,v in pairs (self.BanOrder) do 
			--print(k,v)
			for a,b in pairs (v) do
				--print(k,a,b)
				for c,d in pairs (b) do 
					print(k,a,c,d)
				end
			end
		end
		self.BanOrder.red[1] = {playerId = 0}
	end	
	--print(self.BanOrder[self.ban_order])
	CustomNetTables:SetTableValue("draft", "banorder", self.BanOrder)
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
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

function DraftSelectioN:OnPreSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    self.PreSelected[playerId] = hero

    CustomNetTables:SetTableValue("draft", "preselect", self.PreSelected)
end

function DraftSelectioN:OnDCBan()

	Timers:CreateTimer('draft_ban_timer', {
		endTime = self.Draft.ban_time,
		callback = function()
		self.Time = "undefined"
		--Timers:RemoveTimer('draft_timer')
		--Timers:RemoveTimer('draft_ban_timer')
		self.Draft.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
		Timers:CreateTimer(self.Draft.show_time, function()	
			self:StartPickPhase()
		end)
		--[[local player_ban = {
			playerId = self.BanOrder[self.Draft.ban_order]['playerId'],
		    hero = nil,
		}
        self:OnBan(player_ban)]]
    end})
end

function DraftSelectioN:OnBan(args)
	local playerId = args.playerId

	--[[if IsInToolsMode() then 
		self.Draft.total_ban = 1
	end	]]

	if self.BannedPlayer[playerId] == playerId then
	   	return 
	end

	if self.Draft.GamePhase == "blank" then 
    	print('blank state')
    	return 
    end

	if args.hero ~= nil then
	    local hero = args.hero

	    self.AvailableHeroes[hero] = nil
	    self.BannedHeroes[hero] = playerId

	    CustomNetTables:SetTableValue("draft", "banned", self.BannedHeroes)
	    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	    self.BannedPlayer[playerId] = hero 
	else
		self.BannedPlayer[playerId] = playerId
	end

	
	CustomNetTables:SetTableValue("draft", "bannedplayer", self.BannedPlayer)

	self.Draft.ban_order = self.Draft.ban_order + 1

	--[[self.Time = "undefined"
	Timers:RemoveTimer('draft_timer')
	Timers:RemoveTimer('draft_ban_timer')
	self.Draft.GamePhase = "blank"
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})]]

	--[[if self.Draft.ban_order <= self.Draft.total_ban then	
		Timers:CreateTimer(self.Draft.show_time, function()
			self.Draft.GamePhase = "ban"
			CustomNetTables:SetTableValue("draft", "banorder", self.BanOrder[self.Draft.ban_order])
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
			self.Time = self.Draft.ban_time
			self:UpdateTime()
			self:OnDCBan()
		end)
	else
		CustomNetTables:SetTableValue("draft", "banorder", {playerId = nil})]]
	if self.Draft.ban_order >= self.Draft.total_ban then	
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_ban_timer')
		self.Draft.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
		Timers:CreateTimer(self.Draft.show_time, function()	
			self:StartPickPhase()
		end)
	end
end

function DraftSelectioN:OnSkin(args)
	local playerId = args.playerId
    local hero = args.hero
    local skin = args.skin

    if self.Unique["01"]["hero"] == hero then
    	if self.Unique["01"]["owner"][tostring(PlayerResource:GetSteamAccountID(playerId))] then
    		if (skin == 0 or skin == self.AvailableSkins[hero]) and self.SkinSelect[hero] ~= self.Unique["01"]["skin"] then 
    			skin = self.Unique["01"]["skin"]
    		end
    	end
    end

    print('skin = ' .. skin)

    self.SkinSelect[hero] = skin

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)

    local player = PlayerResource:GetPlayer(playerId)

    local sID = GetSID(hero .. "_" .. skin)
    --print(sID)

    if self.skinTier["LimitedSkin"][hero .. "_" .. skin] == 1 then 
		self.skintier[hero] = 4
	elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
		self.skintier[hero] = 3
	elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
    	self.skintier[hero] = 2
    elseif self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 or self.skinTier["FreeSkin"][hero .. "_" .. skin] == 1 then 
    	self.skintier[hero] = 1
    else
    	self.skintier[hero] = 0
    end

    if IsEventSkin(sID) then 
		print('event skin')
		self.skinAccess[playerId] = true
		
    elseif PlayerTables:GetTableValue("database", "db", playerId) == true and iupoasldm.jyiowe[playerId].IFY ~= nil then 
		print('skin pick from database')
		if iupoasldm.jyiowe[playerId].IFY.SKID[sID] == true then 
			self.skinAccess[playerId] = true
		else
			self.skinAccess[playerId] = false
		end

		if self.Draft.devPresence == true then
			if iupoasldm.jyiowe[playerId].IFY.SKID[sID] == false then 
				local alvl = PlayerTables:GetTableValue("authority", 'alvl', playerId)
				local id = PlayerResource:GetSteamAccountID(playerId)
				if IsSkinEnable(skin, id, alvl) then 
					self.skinAccess[playerId] = true
				end
			end
		end
		--end
	else
		if self.skinTier["FreeSkin"][hero .. "_" .. skin] == 1 then 
	    	self.skinAccess[playerId] = true
	    elseif self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] > 0) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		self.skinAccess[playerId] = true
	    	else
	    		self.skinAccess[playerId] = false
	    	end
	    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] >= 3) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		self.skinAccess[playerId] = true
	    	else
	    		self.skinAccess[playerId] = false
	    	end
	    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] >= 4) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		self.skinAccess[playerId] = true
	    	else
	    		self.skinAccess[playerId] = false
	    	end
	    elseif self.skinTier["LimitedSkin"][hero .. "_" .. skin] == 1 then 
	    	if self.PAuthority[playerId] == 5 then 
	    		self.skinAccess[playerId] = true
	    	else
	    		self.skinAccess[playerId] = false
	    	end
	    else
	    	self.skinAccess[playerId] = true
	    end
	end

    CustomNetTables:SetTableValue("draft", "skintier", self.skintier)
    CustomNetTables:SetTableValue("draft", "skinaccess", self.skinAccess)
end 

function DraftSelectioN:GetSkin(pId, hero)
	local skin = 0
	local hID = 0
	local sID = 0 

	if PlayerTables:GetTableValue("database", "db", pId) == true and iupoasldm.jyiowe[pId].IFY ~= nil then 
		hID = GetHID(hero)
			--print(hID)
			--print('data base get')
			--print('default skin ' .. self.ddta[pId].IFY.HID[hID].DSK)
		if hID == nil then 
			SendChatToPanorama('Player ' .. pId .. ' : Hero ID not found')
			print('Hero ID not found')
		else
			if iupoasldm.jyiowe[pId].IFY.HID[hID].DSK > 0 then
					--print('default skin check')
				sID = GetSID(hero .. "_" .. iupoasldm.jyiowe[pId].IFY.HID[hID].DSK)
					--print(self.ddta[pId].IFY.HID[hID].DSK)
					--print(sID)
				if sID == nil then
					SendChatToPanorama('Player ' .. pId .. ' : Skin ID not found')
					print('Skin ID not fount')
				else
					if iupoasldm.jyiowe[pId].IFY.SKID[sID] == true then
						skin = iupoasldm.jyiowe[pId].IFY.HID[hID].DSK
						SendChatToPanorama('Player ' .. pId .. ' default skin = ' .. skin)
						print(hero .. ' default skin = ' .. skin)
					else
						skin = 0
					end
				end
			end
		end
	end

	return skin
end

function DraftSelectioN:StartPickPhase()
	
	self.Time = self.Draft.pick_time
	self.Draft.GamePhase = "pick"

	for i = 1, self.Draft.total_pick_order do 
		if i == 1 then 
			table.insert(self.PickOrder, i, {teamNum = self.RedTeamNumber, playerId1 = self.RedFaction[i], playerId2 = nil})
		elseif i == self.Draft.total_pick_order then 
			if self.Draft.total_pick_order % 2 == 0 then 
				table.insert(self.PickOrder, i, {teamNum = self.BlackTeamNumber, playerId1 = self.BlackFaction[self.PlayerTeam1Count], playerId2 = nil})				
			else
				table.insert(self.PickOrder, i, {teamNum = self.RedTeamNumber, playerId1 = self.RedFaction[self.PlayerTeam2Count], playerId2 = nil})
			end
		elseif i % 2 == 0 then 
			table.insert(self.PickOrder, i, {teamNum = self.BlackTeamNumber, playerId1 = self.BlackFaction[i - 1], playerId2 = self.BlackFaction[i]})
		else
			table.insert(self.PickOrder, i, {teamNum = self.RedTeamNumber, playerId1 = self.RedFaction[i - 1], playerId2 = self.RedFaction[i]})
		end
	end

	if IsInToolsMode() then
		self.Draft.pick_order = 2 
		self.Draft.total_pick_order = 2
		self.PickOrder[self.Draft.pick_order] = {teamNum = "1", playerId1 = 0, playerId2 = nil}
	end

	CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.Draft.pick_order])
	CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.Draft.pick_order])
	CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})

	--self.pick_order = self.pick_order + 1
	self:UpdateTime()
	self:OnDCRandom()
end

function DraftSelectioN:OnDCRandom()

	Timers:CreateTimer('draft_random_timer', {
		endTime = self.Draft.pick_time,
		callback = function()
		print('time out random')
		local player1 = {
			playerId = self.PickOrder[self.Draft.pick_order]['playerId1'],
		    hero = nil,
		    teamNum = self.PickOrder[self.Draft.pick_order]['teamNum']
		}
        self:OnRandom(player1)

        if self.PickOrder[self.Draft.pick_order]['playerId2'] ~= nil then 
        	local player2 = {
				playerId = self.PickOrder[self.Draft.pick_order]['playerId2'],
			    hero = nil,
			    teamNum = self.PickOrder[self.Draft.pick_order]['teamNum']
			}
	        self:OnRandom(player2)
	    end
    end})
end

function DraftSelectioN:OnSelectBar(args)
	local playerId = args.playerId
    local hero = args.hero
    --print('recieve pick data')
    self.SelectedBar[playerId] = hero
    --print('send data hero ' .. hero)
    CustomNetTables:SetTableValue("draft", "select_bar", self.SelectedBar)
end

function DraftSelectioN:OnSelect(args)
	local playerId = args.playerId
    local hero = args.hero
    local team = args.teamNum

	if self.PickOrder[self.Draft.pick_order]['playerId1'] ~= playerId and self.PickOrder[self.Draft.pick_order]['playerId2'] ~= playerId then 
		return 
	end
	
	if self.PickedPlayer[playerId] == playerId then
	   	return 
	end

	if self.HiddenHero[hero] == 1 then 
		self.Picked[playerId] = hero
		self.PickedPlayer[playerId] = playerId
   		self.SkinSelect[hero] = 0
   		self.HiddenHero[hero] = 0

   		CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)
    	CustomNetTables:SetTableValue("draft", "picked", self.Picked)
    	CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)
    	CustomNetTables:SetTableValue("draft", "hidden", self.HiddenHero)
    else
		if self.AvailableHeroes[hero] == nil then 
			return 
		end

		if self.Draft.GamePhase == "blank" then 
	    	print('blank state')
	    	return 
	    end

		self.Picked[playerId] = hero
		self.PickedPlayer[playerId] = playerId
	    self.AvailableHeroes[hero] = nil
	    self.SkinSelect[hero] = 0

	    print('servant ' .. hero .. ' has been picked')

	    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)
	    CustomNetTables:SetTableValue("draft", "picked", self.Picked)
	    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
	    CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)
	end
	self:OnSummon({playerId = playerId})
    self:NextSelect()
end

function DraftSelectioN:NextSelect()
	if self.Draft.pick_order == 1 then 
    	self.Draft.pick_order =  self.Draft.pick_order + 1
    	self.Draft.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.Draft.show_time, function()
			self.Draft.GamePhase = "pick"
			CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.Draft.pick_order])
			CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.Draft.pick_order])
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
			self.Time = self.Draft.pick_time
			self:UpdateTime()
			self:OnDCRandom()
		end)
	elseif self.Draft.pick_order >= self.Draft.total_pick_order then 
		self.Draft.GamePhase = "blank"
		CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
		self.Time = "undefined"
		Timers:RemoveTimer('draft_timer')
		Timers:RemoveTimer('draft_random_timer')
		Timers:CreateTimer(self.Draft.show_time, function()
			self.Draft.GamePhase = "strategy"
			CustomNetTables:SetTableValue("draft", "hilight", {playerId1 = nil , playerId2 = nil})
		    CustomNetTables:SetTableValue("draft", "pickorder", {playerId1 = nil, playerId2 = nil})
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
			ServerTables:CreateTable("HeroSelection", self.Picked)
			
			self.Time = self.Draft.strategy_time + self.Draft.standby_time
			self:UpdateTime()
			Timers:CreateTimer(self.Draft.strategy_time + self.Draft.standby_time + 3, function() 
				GameRules:ForceGameStart()
			    CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=1} )	
			end)
			Timers:CreateTimer(self.Draft.strategy_time , function()
				self:OnSummonTimer()
				GameRules.AddonTemplate:CheckCondition()
			end)
		end)
	else
		if self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId2']] then 
			self.Draft.pick_order = self.Draft.pick_order + 1
			self.Draft.GamePhase = "blank"
			CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
			self.Time = "undefined"
			Timers:RemoveTimer('draft_timer')
			Timers:RemoveTimer('draft_random_timer')
			Timers:CreateTimer(self.Draft.show_time, function()
				self.Draft.GamePhase = "pick"
				CustomNetTables:SetTableValue("draft", "pickorder", self.PickOrder[self.Draft.pick_order])
				CustomNetTables:SetTableValue("draft", "hilight", self.PickOrder[self.Draft.pick_order])
				CustomNetTables:SetTableValue("draft", "gamephase", {gamephase = self.Draft.GamePhase})
				self.Time = self.Draft.pick_time
				self:UpdateTime()
				self:OnDCRandom()
			end)
		end
		if self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId1']] and not self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 =  nil, playerId2 = self.PickOrder[self.Draft.pick_order]['playerId2']})
		elseif not self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId1']] and self.PickedPlayer[self.PickOrder[self.Draft.pick_order]['playerId2']] then 
			CustomNetTables:SetTableValue("draft", "hilight", {teamNum = team ,playerId1 = self.PickOrder[self.Draft.pick_order]['playerId1'] , playerId2 = nil})
		end
	end

	if IsInToolsMode() then
		self.Draft.pick_order = 3 
	end
end

function DraftSelectioN:OnRandom(args)
	local playerId = args.playerId
    local hero = nil
    local team = args.teamNum
	
	if self.PickOrder[self.Draft.pick_order]['playerId1'] ~= playerId and self.PickOrder[self.Draft.pick_order]['playerId2'] ~= playerId then 
		print('not player turn')
		return 
	end

	if self.PickedPlayer[playerId] == playerId then
		print('player already picked')
	   	return 
	end

	if self.Draft.GamePhase == "blank" then 
    	print('blank state')
    	return 
    end

    if self.SelectedBar[playerId] == nil and self.PreSelected[playerId] ~= nil then 
    	self.SelectedBar[playerId] = self.PreSelected[playerId]
    end

    if self.SelectedBar[playerId] ~= nil and self.SelectedBar[playerId] ~= "random" and (self.AvailableHeroes[self.SelectedBar[playerId]] ~= nil or self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1) then 
    	if self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1 then 
    		if self.PAuthority[playerId] >= 1 or PlayerTables:GetTableValue("authority", 'alvl', playerId) > 0 then 
    			hero = self.SelectedBar[playerId] 
    		else
    			hero = self:Random()
    		end
    	else
    		hero = self.SelectedBar[playerId] 
    	end
    else
    	hero = self:Random()
    end

    self.Picked[playerId] = hero
    self.PickedPlayer[playerId] = playerId
    self.AvailableHeroes[hero] = nil
    self.SkinSelect[hero] = 0

    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)	    
    CustomNetTables:SetTableValue("draft", "picked", self.Picked)
    CustomNetTables:SetTableValue("draft", "available", self.AvailableHeroes)
    CustomNetTables:SetTableValue("draft", "pickedplayer", self.PickedPlayer)

    print('hero random ' .. hero)
    self:OnSummon({playerId = playerId})
    self:NextSelect()
end

function DraftSelectioN:Random()

	local hero_pool = {}
	local index = 0

	for hero,_ in pairs(self.AvailableHeroes) do
		if hero ~= "npc_dota_hero_wisp" and not self.BannedHeroes[hero] then
			index = index + 1
			--print('index = ' .. index .. ' , ' .. hero)
			table.insert(hero_pool, index, hero)
		end
	end

	local randomIndex = RandomInt(1, index)
	--print('total hero = ' .. index)
	--print('random = ' .. randomIndex)
	local hero_select = hero_pool[randomIndex]
	--print('hero name ' .. hero_select)

	if self.AvailableHeroes[hero_select] == 1 then 
		return hero_select
	else
		self:Random()
	end
end

function DraftSelectioN:OnSummonTimer()
	print('max player = ' .. self.max_player)
	for i = 0, self.max_player - 1 do
		Timers:CreateTimer(i * 0.1, function()
			if PlayerResource:IsValidPlayer(i) then
				local ddt = PlayerTables:GetAllTableValues("hHero", i)
				local Hero = PlayerResource:GetSelectedHeroEntity(i) or EntIndexToHScript(ddt.hhero)
				if Hero == nil then 
					self:OnSpawn({playerId = i})
				else
					if string.match(Hero:GetUnitName(), "wisp") then
						self:OnSummon({playerId = i})
					else
						local skin = self:LastCheckSkin(i, Hero:GetUnitName(), self.SkinSelect[self.Picked[i]]) 
						--if skin > 0 then
							print('hero skin = ' .. Hero.Skin)
							if Hero.Skin ~= skin then     						
								if Hero.Skin > 0 then
									print('remove skin')
									Hero:RemoveAbility("alternative_0" .. Hero.Skin)
									Hero:RemoveModifierByName("modifier_alternate_0" .. Hero.Skin)
									Hero.Skin = 0
								end
								Timers:CreateTimer(0.5, function()
									if skin > 0 then
										Hero:AddAbility("alternative_0" .. skin)
										Hero:FindAbilityByName("alternative_0" .. skin):SetLevel(1)
										Hero.Skin = skin
									end
								end)
							end
						--[[else
							if Hero.Skin > 0 then
								Hero:RemoveAbility("alternative_0" .. Hero.Skin)
								Hero:RemoveModifierByName("alternative_0" .. Hero.Skin)
							end
						end]]
					end
				end
			end
		end)
	end		
end

function DraftSelectioN:LastCheckSkin(playerId, hero, skin)
	local real_skin = 0
	print('checking skin')
	local sID = GetSID(hero .. "_" .. skin)

	if IsEventSkin(sID) then 
		real_skin = skin
		
    elseif PlayerTables:GetTableValue("database", "db", playerId) == true and iupoasldm.jyiowe[playerId].IFY ~= nil then 

		if iupoasldm.jyiowe[playerId].IFY.SKID[sID] == true then 
			real_skin = skin
		else
			real_skin = 0
		end
		if self.Draft.devPresence == true then
			if iupoasldm.jyiowe[playerId].IFY.SKID[sID] == false then 
				local alvl = PlayerTables:GetTableValue("authority", 'alvl', playerId)
				local id = PlayerResource:GetSteamAccountID(playerId)
				if IsSkinEnable(skin, id, alvl) then 
					real_skin = skin
				end
			end
		end
	else
		if self.skinTier["FreeSkin"][hero .. "_" .. skin] == 1 then 
	    	real_skin = skin
	    elseif self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] > 0) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		real_skin = skin
	    	else
	    		real_skin = 0
	    	end
	    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] >= 3) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		real_skin = skin
	    	else
	    		real_skin = 0
	    	end
	    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] >= 4) or (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= nil and self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == 1) then 
	    		real_skin = skin
	    	else
	    		real_skin = 0
	    	end
	    elseif self.skinTier["LimitedSkin"][hero .. "_" .. skin] == 1 then 
	    	if self.PAuthority[playerId] == 5 then 
	    		real_skin = skin
	    	else
	    		real_skin = 0
	    	end
	    end
	end

	print('real skin :' .. real_skin)
	return real_skin
end

function DraftSelectioN:OnSummon(args)
	local playerId = args.playerId
    local hero = self.Picked[playerId]
    local skin = self.SkinSelect[hero] or 0

    if hero == nil then 
    	SendChatToPanorama('Player ' .. playerId .. ' : No hero select at summon phase, random new one')
    	hero = self:Random()
    	self.Picked[playerId] = hero
    	self.AvailableHeroes[hero] = nil
    	self.SkinSelect[hero] = 0
		self.PickedPlayer[playerId] = playerId
		ServerTables:SetTableValue("HeroSelection", playerId, hero, true)
    end

    SendChatToPanorama('Player ' .. playerId .. ' : Summon ritual Servant ' .. hero .. ' has started.')

    if skin > 0 then
    	skin = self:LastCheckSkin(playerId, hero, skin)
    end

    self.SkinSelect[hero] = skin
    CustomNetTables:SetTableValue("draft", "skinselect", self.SkinSelect)

    PlayerTables:SetTableValue("hHero", "hero", hero, playerId, true)
    PlayerTables:SetTableValue("hHero", "skin", skin, playerId, true)
    --print('summon hero ' .. hero)

    PrecacheUnitByNameAsync(hero, function()
	  	self:AssignHero(playerId, hero, skin, true)
	end)

    

    --[[local htable = PlayerTables:GetAllTableValues("hHero", playerId)
	for k,v in pairs(htable) do
		print(k,v)
	end]]

end

function DraftSelectioN:OnSpawn(args)
	local playerId = args.playerId
	local hero = self.Picked[playerId]
	local newHero = CreateHeroForPlayer(hero, PlayerResource:GetPlayer(playerId))
    PlayerResource:GetPlayer(playerId):SetAssignedHeroEntity(newHero)
	PlayerTables:SetTableValue("hHero", "hhero", newHero:entindex(), playerId, true)
	newHero:SetControllableByPlayer(playerId, true)
    newHero:AddNewModifier(newHero, nil, "modifier_camera_follow", {duration = 1.0})
end

function DraftSelectioN:AssignHero(playerId, hero, skin)
	local ddt = PlayerTables:GetAllTableValues("hHero", playerId)
    --PrecacheUnitByNameAsync(hero, function()
    local oldHero = PlayerResource:GetSelectedHeroEntity(playerId) or EntIndexToHScript(ddt.hhero) or EntIndexToHScript(ddt.io) 
    if oldHero == nil then
    		SendChatToPanorama('Player ' .. playerId .. ' : Summon Spirit had been Deleted!!!')
            self:OnSpawn({playerId = playerId})
        else
        	if not string.match(oldHero:GetUnitName(),"wisp") then 
	    		SendChatToPanorama('Player ' .. playerId .. ' : Double Summon BRUHHH!!!')
	    		return nil 
	    	end
		    if string.match(oldHero:GetUnitName(),"wisp") and not oldHero.IsHeroSpawn then
		    	oldHero.IsHeroSpawn = true
				oldHero:SetRespawnsDisabled(true)
				PlayerResource:ReplaceHeroWith(playerId, hero, 3000, 0)
				if string.match(oldHero:GetUnitName(),"wisp") then
					UTIL_Remove(oldHero)
				end
				--print(newHero:GetName())
				local hnewhero = PlayerTables:GetTableValue("hHero", 'hhero', playerId)
				local newHero = PlayerResource:GetSelectedHeroEntity(playerId) or EntIndexToHScript(hnewhero)
				
				newHero.IsHeroSpawn = true

				--[[Timers:CreateTimer('skin_apply' .. playerId , {
					endTime = 0,
					callback = function()
					if newHero ~= nil then 
						if skin > 0 then 
							newHero:AddAbility("alternative_0" .. skin)
							newHero:FindAbilityByName("alternative_0" .. skin):SetLevel(1)
						end
						if newHero:GetName() == "npc_dota_hero_antimage" and ServerTables:GetTableValue("Dev", "sss") == true and tostring(PlayerResource:GetSteamAccountID(playerId)) == "301222766" then 
							newHero:AddAbility("ascension_skill")
							newHero:FindAbilityByName("ascension_skill"):SetLevel(1)
						end
						return nil 
					else 
						return 1
					end
				end})]]
				--[[Timers:CreateTimer('player_rec' .. playerId, {
					endTime = 0,
					callback = function()
					local conn_state = PlayerResource:GetConnectionState(playerId)

			            --0 = No connection
			            --1 = Bot
			            --2 = Player
			            --3 = Disconnected

			        if conn_state == 3 or conn_state == 0 then 
			        	SendChatToPanorama('Player ' .. playerId .. ' : is dc while spawn hero')
			        	if self.DC_count[playerId] == nil then 
			        		self.DC_count[playerId] = 1
			        	end
			        	self.DC_count[playerId] = self.DC_count[playerId] + 1
			        	return 1
			        else
			        	print('player ' .. newHero:GetPlayerOwnerID() .. ' is the owner of ' .. newHero:GetName())
			        	--if PlayerResource:GetPlayer(playerId):GetAssignedHero():GetName() ~= hero then 
			        	if self.DC_count[playerId] and self.DC_count[playerId] > 0 then 
			        		SendChatToPanorama('Player ' .. playerId .. ' : dc while spawn hero')
			        		newHero:SetPlayerID(playerId)
			        		PlayerResource:GetPlayer(playerId):SetAssignedHeroEntity(newHero)
			        		PlayerTables:SetTableValue("hHero", "hhero", newHero:entindex(), playerId, true)
			        		newHero.MasterUnit:SetControllableByPlayer(playerId, true)
			        		newHero.MasterUnit2:SetControllableByPlayer(playerId, true)
			        		newHero.MasterUnit3:SetControllableByPlayer(playerId, true)
			        		local hmaster1 = PlayerTables:GetTableValue("hHero", 'master1', playerId)
			        		local master1 = EntIndexToHScript(hmaster1)
			        		master1:SetControllableByPlayer(playerId, true)
			        		local hmaster2 = PlayerTables:GetTableValue("hHero", 'master2', playerId)
			        		local master2 = EntIndexToHScript(hmaster2)
			        		master2:SetControllableByPlayer(playerId, true)
			        		local hmaster3 = PlayerTables:GetTableValue("hHero", 'master3', playerId)
			        		local master3 = EntIndexToHScript(hmaster3)
			        		master3:SetControllableByPlayer(playerId, true)
			        	end

			        	return nil 
			        end
				end})]]
			end
        end
end