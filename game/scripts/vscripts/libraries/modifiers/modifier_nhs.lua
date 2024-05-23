------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------


HeroSelectioN = HeroSelectioN or class({})
FATE_DEFAULT_MAX_PLAYERS_FFA = 10
FATE_DEFAULT_MAX_PLAYERS_TRIO = 9
FATE_DEFAULT_MAX_PLAYERS_RUMBLE = 12
FATE_DEFAULT_MAX_PLAYERS_7v7 = 14
FATE_DEFAULT_MAX_PLAYERS_6v6 = 12

function HeroSelectioN:constructor()

	_G.GameMap = GetMapName()

	if _G.GameMap == "fate_tutorial" then

		Selection = HeroSelection()
        Selection:UpdateTime() 
	else
		print('hero selection start')
		self.AllHeroes = {}
		self.AvailableHeroes = {}
		self.UnAvailableHeroes = {}
		self.Picked = {}
		self.SkinSelect = {}
		self.AvailableSkins = {}
		self.PickedPlayer = {}
		self.SpecBanPlayer = {}
		self.NewbieBanPlayer = {}
		self.BanHero = {}
		self.BanVotedPlayer = {}
		self.SameHeroVote = {}
		self.SameHeroVotedPlayer = {}
        local heroList = LoadKeyValues("scripts/npc/herolist.txt")
        local heroList2 = LoadKeyValues("scripts/npc/herolist.txt")
        local heroes = LoadKeyValues("scripts/npc/heroes.txt")
        local skinList = LoadKeyValues("scripts/npc/skin.txt")
        local skinTier = LoadKeyValues("scripts/npc/skinaccess.txt")
        local testList = LoadKeyValues("scripts/npc/herotest.txt")
        self.roleList = LoadKeyValues("scripts/npc/hero_role.txt")
        self.SpecBan = LoadKeyValues("scripts/npc/spec_ban.txt")
        self.NewbieBan = LoadKeyValues("scripts/npc/newbie_ban.txt")
        self.Unique = LoadKeyValues("scripts/npc/unique.txt")
        local ContributeUnlock = LoadKeyValues("scripts/npc/contributeunlock.txt")
		heroList["npc_dota_hero_wisp"] = nil
		heroList2["npc_dota_hero_wisp"] = nil
		self.AllHeroes = heroList
		self.AvailableHeroes = heroList2
		self.AvailableSkins = skinList
		self.UnAvailableHeroes = testList
		self.skinTier = skinTier
		self.ContributeUnlock = ContributeUnlock
		self.skinAccess = {}
		self.PAuthority = {}
		self.skintier = {}
		self.HeroInfo = {}
		self.Id = {}
		self.DC_count = {}
		self.SelectedBar = {}
		self.ddta = {}
		self.HeroSelectStart = "selection"
		self.AutoBalance = 0
		self.total_ban = GameRules.AddonTemplate.voteBanHeroTable or 0
		self.ban = true
		self.sameheromode = false
		self.devPresence = false
		self.pepelord = false
		self.load_time = 5
		self.ban_time = 20
		self.pick_time = 60 
		self.strategy_time = 10 
		self.standby_time = 10
		self.max_player = FATE_DEFAULT_MAX_PLAYERS_TRIO 
		if _G.GameMap == "fate_elim_7v7" then 
			self.max_player = FATE_DEFAULT_MAX_PLAYERS_7v7
		elseif _G.GameMap == "fate_elim_6v6" then 
			self.max_player = FATE_DEFAULT_MAX_PLAYERS_6v6
		elseif _G.GameMap == "fate_ffa" then 
			self.max_player = FATE_DEFAULT_MAX_PLAYERS_FFA
		elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then 
			self.max_player = FATE_DEFAULT_MAX_PLAYERS_RUMBLE
		end

		CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=0} )
		print('total ban ' .. self.total_ban)

		if self.total_ban == 0 then 
			self.ban_time = 0
			self.ban = false
		else
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Ban_Mode" .. self.total_ban} )
		end

		if ServerTables:GetTableValue("GameMode", "mode") == "samehero" then 
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Same_Hero_Mode"} )
			self.sameheromode = true
			self.AllHeroes["npc_dota_hero_chen"] = nil
			self.AvailableHeroes["npc_dota_hero_chen"] = nil
			self.AllHeroes["npc_dota_hero_ember_spirit"] = nil
			self.AvailableHeroes["npc_dota_hero_ember_spirit"] = nil
			self.AllHeroes["npc_dota_hero_vengefulspirit"] = nil
			self.AvailableHeroes["npc_dota_hero_vengefulspirit"] = nil
		else
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Clasic_Mode"} )
		end
		--[[for a,b in pairs (skinTier) do 
			for c,d in pairs (b) do 
				print(a,c,d)
			end
		end]]

		for k,v in pairs (testList) do 
			if v == 1 and self.AllHeroes[k] == nil then 
				self.AllHeroes[k] = v 
			end
		end

		for key, value in pairs (self.AllHeroes) do
			if value ~= 1 then return end
			local hero_info = GetHeroInfo(key, heroes[key], self.roleList[key])
			self.HeroInfo[key] = hero_info
		end

		--[[for h, a in pairs (self.UnAvailableHeroes) do
			if a ~= 1 then return end
			local hero_info = GetHeroInfo(h)
			self.HeroInfo[h] = hero_info
		end]]
			
		--[[for a,b in pairs(self.HeroInfo) do
			for c,d in pairs(b) do
				print(a,c,d)
			end
		end]]

		if IsInToolsMode() then 		
			CustomNetTables:SetTableValue("nselection", "mode", {mode="tool"})
		end

		--print(#GameRules.AddonTemplate.vUserIds)
		local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
		for i = 0, self.max_player - 1 do
			if PlayerResource:IsValidPlayer(i) then
				--local oldHero = PlayerResource:GetSelectedHeroEntity(i)
				--UTIL_Remove(oldHero)
				local id = PlayerResource:GetSteamAccountID(i)
			    table.insert(self.Id, i, id) 
			    local alvl = PlayerTables:GetTableValue("authority", 'alvl', i)
			    table.insert(self.PAuthority, i, alvl) 

			    if self.SpecBan[tostring(id)] then 
			    	SendChatToPanorama('Player ' .. i .. ' was in hero ban list')
			    	for k,v in pairs (self.SpecBan[tostring(id)]) do
				    	if self.SpecBan[tostring(id)][k] == 1 then 
				    		SendChatToPanorama('Player ' .. i .. ': ' .. k .. ' was banned')
				    		if self.SpecBanPlayer[i] == nil then 
								self.SpecBanPlayer[i] = {}
							end
				    		self.SpecBanPlayer[i][k] = 1
				    	end
				    end
			    end

			    if PlayerTables:GetTableValue("database", "db", i) == false then 
			    	local asdio = iupoasldm
					asdio:initialize(i)
					--self.ddta = iupoasldm.jyiowe

			    end

			    Timers:CreateTimer('alvlcheck' .. i , {
					endTime = 2,
					callback = function()
					if PlayerTables:GetTableValue("database", "db", i) == true then 
						local new_lvl = iupoasldm.jyiowe[i].IFY.ATLVL
						skoyhidpo:initialize(i)
						if iupoasldm.jyiowe[i].LD.ACD == nil or iupoasldm.jyiowe[i].LD.ACD < 3 then 
							SendChatToPanorama('Player ' .. i .. ' was new to game')
							for k,v in pairs (self.NewbieBan) do
								SendChatToPanorama('Player ' .. i .. ': ' .. k .. ' was banned to newbie')
								--print(k,v)
								if self.NewbieBanPlayer[i] == nil then 
									self.NewbieBanPlayer[i] = {}
								end
								self.NewbieBanPlayer[i][k] = 1
								CustomNetTables:SetTableValue("nselection", "newban", self.NewbieBanPlayer)
							end
						end

						--print('lvl authority ' .. new_lvl)
						--print('old lvl ' .. alvl)
						if alvl < new_lvl and not self.devPresence then
							self.PAuthority[i] = new_lvl
							CustomNetTables:SetTableValue("nselection", "authority", self.PAuthority)
							--print('lvl authority update' .. new_lvl)
						end
						return nil 
					--else 
						--iupoasldm:initialize(i)
						--return 1
					end
				end})

			    if ServerTables:GetTableValue("Dev", "zef") == true then 
			    	Timers:CreateTimer(3.0, function()
			    		--local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
			    		--for j = 0, max_player - 1 do 
			    			--if PlayerResource:IsValidPlayerID(j) then
				    			if PlayerTables:GetTableValue("authority", 'alvl', i) < 4 then
				    				PlayerTables:SetTableValue("authority", "alvl", 4, i, true)
				    				self.PAuthority[i] = 4
				    				CustomNetTables:SetTableValue("nselection", "authority", self.PAuthority)
				    			end
				    		--end
			    		--end
			    	end)
			    end
			    
			end
		    --[[local player = PlayerResource:GetPlayer(i)
		    if player ~= nil then
			    if not player.authority_level or player.authority_level == nil then 
			    	CheckAuthority(i)
			    	--print("authority level " .. player.authority_level)
			    	table.insert(self.PAuthority, i, player.authority_level) 
			    else
			    	table.insert(self.PAuthority, i, player.authority_level) 
			    end
			end]]
		end

		if ServerTables:GetTableValue("Dev", "zef") == true then 
			self.devPresence = true
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Dev_Presence"} )
		end

		if ServerTables:GetTableValue("Dev", "pepe") == true then 
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Pepe_Presence"} )
		end

		if ServerTables:GetTableValue("Dev", "sss") == true then 
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_SSS_Presence"} )
		end

		if ServerTables:GetTableValue("Dev", "mod") == true then 
			self.devPresence = true
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Mod_Presence"} )
		end

		if ServerTables:GetTableValue("PEPE", "pepe") == true and ServerTables:GetTableValue("PEPE", "slayer") == true then 
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Pepe_Slayer"} )
		end

		if ServerTables:GetTableValue("PEPE", "pepe") == true and ServerTables:GetTableValue("PEPE", "savior") == true then 
			CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=0, chattype=0, text="#Fate_Pepe_Savior"} )
		end

		if ServerTables:GetTableValue("AutoBalance", "auto_balance") == true then 
			for p = 0,13 do 
				if PlayerResource:IsValidPlayerID(p) and PlayerTables:GetTableValue("database", "db", p) == true then 
					SendChatToPanorama('Player ' .. p .. ': MMR ' .. yedped.MRN[p] .. ': actual team ' .. yedped.team[p])
				else
					SendChatToPanorama('Player ' .. p .. ' error')
				end
			end
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
	    self.SkinListener = CustomGameEventManager:RegisterListener("nselection_hero_ban", function(id, ...)
	        Dynamic_Wrap(self, "OnBan")(self, ...) 
	    end)
	    self.SkinListener = CustomGameEventManager:RegisterListener("nselection_hero_same_hero", function(id, ...)
	        Dynamic_Wrap(self, "OnSameHeroVote")(self, ...) 
	    end)
	    self.SummonListener = CustomGameEventManager:RegisterListener("nselection_hero_summon", function(id, ...)
		    Dynamic_Wrap(self, "OnSummon")(self, ...) 
		end)
		self.SummonListener = CustomGameEventManager:RegisterListener("nselection_hero_spawn", function(id, ...)
		    Dynamic_Wrap(self, "OnSpawn")(self, ...) 
		end)
		self.SummonListener = CustomGameEventManager:RegisterListener("nselection_hero_strategy", function(id, ...)
		    Dynamic_Wrap(self, "OnStrategy")(self, ...) 
		end)

		CustomNetTables:SetTableValue("nselection", "all", self.AllHeroes)
        CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
        CustomNetTables:SetTableValue("nselection", "unavailable", self.UnAvailableHeroes)
        CustomNetTables:SetTableValue("nselection", "skin", self.AvailableSkins)
        CustomNetTables:SetTableValue("nselection", "banhero", self.BanHero)
        CustomNetTables:SetTableValue("nselection", "votebanplayer", self.BanVotedPlayer)
        CustomNetTables:SetTableValue("nselection", "sameherovoteplayer", self.SameHeroVotedPlayer)

        CustomNetTables:SetTableValue("nselection", "skintier", self.skintier)
        CustomNetTables:SetTableValue("nselection", "skinaccess", self.skinAccess)
        CustomNetTables:SetTableValue("nselection", "authority", self.PAuthority)

        CustomNetTables:SetTableValue("nselection", "specban", self.SpecBanPlayer)
        
        CustomNetTables:SetTableValue("nselection", "game", LoadAKeyValues())
        CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
        CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
        CustomNetTables:SetTableValue("nselection", "time", {time = self.Time})
        CustomNetTables:SetTableValue("nhi", "info", self.HeroInfo)
        CustomNetTables:SetTableValue("nselection", "gamephrase", {gamephrase = "load"})
        
        CustomNetTables:SetTableValue("nselection", "panel", {game = "start"})
        CustomNetTables:SetTableValue("nselection", "si", self.Id)
        if self.sameheromode == true then 
        	CustomNetTables:SetTableValue("nselection", "mode", {mode="samehero"})
        end
        
        --CustomGameEventManager:Send_ServerToAllClients( "new_hero_selection", {Selection = "new"} ) 

        Timers:CreateTimer(self.AutoBalance, function()
        	CustomNetTables:SetTableValue("nselection", "ban", {ban = self.ban})

	        self.Time = self.load_time + self.ban_time + self.pick_time + self.strategy_time + self.standby_time
			self:UpdateTime()

	        Timers:CreateTimer(1.0, function()
	        	CustomNetTables:SetTableValue("nselection", "hs", {mode = self.HeroSelectStart})
	        end)
	        Timers:CreateTimer(self.load_time, function()
	        	CustomNetTables:SetTableValue("nselection", "gamephrase", {gamephrase = "pick"})  
	        	Timers:CreateTimer(self.ban_time, function() 

	        		if self.total_ban > 0 then
	        			self:OnBanFinal()
		        		CustomNetTables:SetTableValue("nselection", "banhero", self.BanHero)
		        	end

		        	Timers:CreateTimer(self.pick_time, function() 

		        		Timers:CreateTimer(self.strategy_time + self.standby_time + 5, function() 
				        	GameRules:ForceGameStart()
			    			CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=1} )	
			    			GameRules.AddonTemplate:CheckCondition()
			    		end)
			    		if self.sameheromode == true then 
			    			self:OnSameHeroVoteFinal()
			    		else
		        			self:OnDCRandom()
		        		end
		        		Timers:CreateTimer(self.strategy_time, function() 
			    			self:OnSummonTimer()
			    			
			        	end)
		        	end)
		        end)
	        end)
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

function HeroSelectioN:OnDCRandom()
	for k,v in pairs (self.SelectedBar) do 
		print(k,v)
		if self.PickedPlayer[k] ~= k and not self.Picked[k] then
			SendChatToPanorama('Player ' .. k .. ' has pre selected hero')
			self:OnRandom({playerId = k})
		end
	end
	local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
	for i = 0, max_player - 1 do
		if PlayerResource:IsValidPlayer(i) and not self.PickedPlayer[i] then
			if self.PickedPlayer[i] ~= i and not self.Picked[i] then 
				SendChatToPanorama('Player ' .. i .. ' didnt selected any hero')
				self:OnRandom({playerId = i})
			end
		end
	end
end

function HeroSelectioN:OnSkin(args)
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

    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)

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

		if self.devPresence == true then
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

    CustomNetTables:SetTableValue("nselection", "skintier", self.skintier)
    CustomNetTables:SetTableValue("nselection", "skinaccess", self.skinAccess)
end 

function HeroSelectioN:GetSkin(pId, hero)
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
	PrecacheUnitByNameAsync(hero, function(...) end)
	local player = PlayerResource:GetPlayer(playerId)
	player.IsPrecacheHero = true
end 

function HeroSelectioN:OnBan(args)
	local playerId = args.playerId
    local hero = args.hero

    print('player : ' .. playerId .. ', hero : ' .. hero)

	self.BanVotedPlayer[playerId] = playerId
	CustomNetTables:SetTableValue("nselection", "votebanplayer", self.BanVotedPlayer)

	if not self.BanHero[hero] then 
    	--if self.total_ban > 0 then
	    	self.BanHero[hero] = hero 
	    --	self.total_ban = self.total_ban - 1
	    --end
	end
end

function HeroSelectioN:OnSameHeroVote(args)
	local playerId = args.playerId
    local hero = args.hero

    print('player : ' .. playerId .. 'vote hero : ' .. hero)

	self.SameHeroVotedPlayer[playerId] = playerId
	CustomNetTables:SetTableValue("nselection", "sameherovoteplayer", self.SameHeroVotedPlayer)

	self.SameHeroVote[hero] = (self.SameHeroVote[hero] or 0) + 1
end

function HeroSelectioN:OnSameHeroVoteFinal()
	self.same_hero = {}

	if self.SameHeroVote == {} then 
		local hero_random = self:Random()
		self.SameHeroVote[hero_random] = 1
	end

	for hero, vote_count in pairs(self.SameHeroVote) do 
		print(hero, vote_count)
		table.insert(self.same_hero, {hero = hero, votePoint = vote_count})
	end

	table.sort(self.same_hero, function(a,b) return a.votePoint > b.votePoint end)

	Timers:CreateTimer(0.1, function()
		local hero = self.same_hero[1]['hero']
		local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
		for i = 0, max_player - 1 do
			if PlayerResource:IsValidPlayer(i) then
				self.Picked[i] = hero
			    self.SkinSelect[hero] = self:GetSkin(i, hero)
			    if self.SkinSelect[hero] == nil then 
			    	self.SkinSelect[hero] = 0
			    end

			    CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
			    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
			    CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=i}) 
			end
		end
	end)
end

function HeroSelectioN:OnBanFinal()

	local ban_pool = {}
	local index = 0

	for hero,_ in pairs(self.BanHero) do
		index = index + 1
		table.insert(ban_pool, index, hero)
	end

	if index < self.total_ban then return end

	local randomIndex = RandomInt(1, index)
	local hero_select = ban_pool[randomIndex]
	self.BanHero[hero_select] = nil 
	table.remove(ban_pool,index)
	index = index - 1
	--print('total hero = ' .. index)
	--print('random = ' .. randomIndex)
	
	--local total_ban_hero = #self.BanHero
	if index > self.total_ban then
		self:OnBanFinal()
	end

end

function HeroSelectioN:OnSelect(args)
	local playerId = args.playerId
    local hero = args.hero

    local player = PlayerResource:GetPlayer(playerId)
    local PID = PlayerResource:GetSteamAccountID(playerId)

    if self.SpecBan[tostring(PID)] then 
    	SendChatToPanorama('Player ' .. playerId .. ' was in hero ban list')
    	if self.SpecBan[tostring(PID)][hero] == 1 then 
    		SendChatToPanorama('Player ' .. playerId .. ': ' .. hero .. ' was banned')
    		return 
    	end
    end

    if self.NewbieBanPlayer[playerId] then 
    	SendChatToPanorama('Player ' .. playerId .. ' is Newbie')
    	if self.NewbieBanPlayer[playerId][hero] == 1 then 
    		SendChatToPanorama('Player ' .. playerId .. ': ' .. hero .. ' was banned')
    		return 
    	end
    end

    if self.BanHero[hero] then 
    	return 
    end

    if self.AvailableHeroes[hero] == 1 then  
    	print('available hero') 	
	    self.Picked[playerId] = hero
	    self.AvailableHeroes[hero] = nil
	    self.SkinSelect[hero] = self:GetSkin(playerId, hero)
	    if self.SkinSelect[hero] == nil then 
	    	self.SkinSelect[hero] = 0
	    end
	    self.PickedPlayer[playerId] = playerId

	    CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
	    CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
	    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
	    CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
	    CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=playerId}) 	
	elseif self.UnAvailableHeroes[hero] == 1 and (self.PAuthority[playerId] > 0 or PlayerTables:GetTableValue("authority", 'alvl', playerId) > 0) then 
		print('test hero')
		self.Picked[playerId] = hero
	    self.UnAvailableHeroes[hero] = nil
	    self.SkinSelect[hero] = self:GetSkin(playerId, hero)
	    if self.SkinSelect[hero] == nil then 
	    	self.SkinSelect[hero] = 0
	    end
	    self.PickedPlayer[playerId] = playerId

	    CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
	    CustomNetTables:SetTableValue("nselection", "unavailable", self.UnAvailableHeroes)
	    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
	    CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
	    CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=playerId})  
	end

	self:OnSummon({playerId = playerId})
end

function HeroSelectioN:OnRandom(args)
    local playerId = args.playerId
    local hero = nil

    local player = PlayerResource:GetPlayer(playerId)
    local PID = PlayerResource:GetSteamAccountID(playerId)

    if self.SelectedBar[playerId] ~= nil and self.SelectedBar[playerId] ~= "random" and (self.AvailableHeroes[self.SelectedBar[playerId]] ~= nil or self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1) and self.BanHero[self.SelectedBar[playerId]] == nil then 
    	if self.UnAvailableHeroes[self.SelectedBar[playerId]] == 1 then 
    		if (self.PAuthority[playerId] >= 1 or PlayerTables:GetTableValue("authority", 'alvl', playerId) > 0) then 
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

    if self.SpecBan[tostring(PID)] then 
    	SendChatToPanorama('Player ' .. playerId .. ' was in hero ban list')
    	if self.SpecBan[tostring(PID)][hero] == 1 then 
    		SendChatToPanorama('Player ' .. playerId .. ': ' .. hero .. ' was banned')
    		hero = self:Random() 
    	end
    end

    if self.NewbieBanPlayer[playerId] then 
    	SendChatToPanorama('Player ' .. playerId .. ' is Newbie')
    	if self.NewbieBanPlayer[playerId][hero] == 1 then 
    		SendChatToPanorama('Player ' .. playerId .. ': ' .. hero .. ' was banned')
    		hero = self:Random() 
    	end
    end

    print(hero)
    self.Picked[playerId] = hero
	self.AvailableHeroes[hero] = nil
	self.SkinSelect[hero] = self:GetSkin(playerId, hero)
	if self.SkinSelect[hero] == nil then 
	    self.SkinSelect[hero] = 0
	end
	self.PickedPlayer[playerId] = playerId

    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
	CustomNetTables:SetTableValue("nselection", "available", self.AvailableHeroes)
	CustomNetTables:SetTableValue("nselection", "picked", self.Picked)
	CustomNetTables:SetTableValue("nselection", "pickedplayer", self.PickedPlayer)
	CustomGameEventManager:Send_ServerToAllClients( "preheroselect",  {hero=hero,playerId=playerId}) 

	self:OnSummon({playerId = playerId})
end

function HeroSelectioN:Random()

	local hero_pool = {}
	local index = 0

	for hero,_ in pairs(self.AvailableHeroes) do
		if hero ~= "npc_dota_hero_wisp" and not self.BanHero[hero] then
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

function HeroSelectioN:OnSummonTimer()

	ServerTables:CreateTable("HeroSelection", self.Picked)

	local max_player = math.max(ServerTables:GetTableValue("MaxPlayers", "total_player"), self.max_player)
	for i = 0, max_player - 1 do
		Timers:CreateTimer(i * 0.5, function()
			
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

    --[[Timers:CreateTimer(self.standby_time + self.strategy_time, function()
    	--GameRules:ForceGameStart()
    	--GameRules:SendCustomMessage("Fate/Another II by ZeFiRoFT", 0, 0)
    	Timers:CreateTimer(1, function()
    		GameRules:ForceGameStart()
    		CustomGameEventManager:Send_ServerToAllClients( "bgm_intro", {bgm=1} )
    	end)
    end)]]
end

function HeroSelectioN:LastCheckSkin(playerId, hero, skin)
	local real_skin = 0
	local sID = GetSID(hero .. "_" .. skin)

	if IsEventSkin(sID) then 
		real_skin = skin
		
    elseif PlayerTables:GetTableValue("database", "db", playerId) == true and iupoasldm.jyiowe[playerId].IFY ~= nil then 

		if iupoasldm.jyiowe[playerId].IFY.SKID[sID] == true then 
			real_skin = skin
		else
			real_skin = 0
		end
		if self.devPresence == true then
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


	--[[if IsEventSkin(sID) then 
		real_skin = skin
		return real_skin
	end
	if PlayerTables:GetTableValue("database", "db", playerId) == true and self.ddta[playerId].IFY ~= nil then 
		print('skin database')
		if self.skinAccess[playerId] == false then
			real_skin = 0
			sID = GetSID(hero .. "_" .. skin)
			if self.ddta[playerId].IFY.SKID[sID] == true then 
				real_skin = skin
				print('skin :' .. real_skin)
			end
		else
			real_skin = skin
		end
	else
		if self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] == 0) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
	    		real_skin = 0
	    	else
	    		real_skin = skin
	    	end
	    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] < 3) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
	    		real_skin = 0
	    	else
	    		real_skin = skin
	    	end
	    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
	    	if (self.PAuthority[playerId] < 4) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
	    		real_skin = 0
	    	else
	    		real_skin = skin
	    	end
	    elseif self.skinTier["LimitedSkin"][hero .. "_" .. skin] == 1 then 
	    	if self.PAuthority[playerId] == 5 then 
	    		real_skin = skin
	    	else
	    		real_skin = 0
	    	end
	    end
	end]]
	self.SkinSelect[hero] = real_skin
	CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
	print('real skin :' .. real_skin)
	return real_skin
end

function HeroSelectioN:OnSpawn(args)
	local playerId = args.playerId
	local hero = self.Picked[playerId]
	local newHero = CreateHeroForPlayer(hero, PlayerResource:GetPlayer(playerId))
    PlayerResource:GetPlayer(playerId):SetAssignedHeroEntity(newHero)
	PlayerTables:SetTableValue("hHero", "hhero", newHero:entindex(), playerId, true)
	newHero:SetControllableByPlayer(playerId, true)
    newHero:AddNewModifier(newHero, nil, "modifier_camera_follow", {duration = 1.0})
end

function HeroSelectioN:OnSummon(args)
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

    --[[if self.skinTier["NormalSkin"][hero .. "_" .. skin] == 1 then 
    	if (self.PAuthority[playerId] == 0) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    elseif self.skinTier["HeroicSkin"][hero .. "_" .. skin] == 1 then 
    	if (self.PAuthority[playerId] < 3) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    elseif self.skinTier["UltimateSkin"][hero .. "_" .. skin] == 1 then 
    	if (self.PAuthority[playerId] < 4) and (self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] == nil or self.ContributeUnlock[hero .. "_" .. skin][tostring(PlayerResource:GetSteamAccountID(playerId))] ~= 1) then 
    		skin = 0
    	end
    end]]
    if skin > 0 then
    	skin = self:LastCheckSkin(playerId, hero, skin)
    end

    self.SkinSelect[hero] = skin
    CustomNetTables:SetTableValue("nselection", "skinselect", self.SkinSelect)
    print('summon hero ' .. hero)

    PlayerTables:SetTableValue("hHero", "hero", hero, playerId, true)
    PlayerTables:SetTableValue("hHero", "skin", skin, playerId, true)

    local htable = PlayerTables:GetAllTableValues("hHero", playerId)
	--[[for k,v in pairs(htable) do
		print(k,v)
	end]]
    
	PrecacheUnitByNameAsync(hero, function()
	  	self:AssignHero(playerId, hero, skin, true)
	end)
end

function HeroSelectioN:AssignHero(playerId, hero, skin)
	local ddt = PlayerTables:GetAllTableValues("hHero", playerId)
    --PrecacheUnitByNameAsync(hero, function()
    local oldHero = PlayerResource:GetSelectedHeroEntity(playerId) or (ddt ~= nil and EntIndexToHScript(ddt.hhero)) or (ddt ~= nil and EntIndexToHScript(ddt.io) )
    --local hero_name = oldHero:GetUnitName()
    --print(hero_name)
    
    --if oldHero == nil or not IsValidEntity(oldHero) then 
    	--SendChatToPanorama('Player ' .. playerId .. ' : No Wisp dummy BRUHHH!!!')
    	--local newHero = CreateHeroForPlayer(hero, PlayerResource:GetPlayer(playerId))
    	--PlayerResource:GetPlayer(playerId):SetAssignedHeroEntity(newHero)
		--PlayerTables:SetTableValue("hHero", "hhero", newHero:entindex(), playerId, true)
		--newHero:SetControllableByPlayer(playerId, true)
    	--newHero:SetGold(0, false)
    	--newHero:SetGold(3000, true)
    	--newHero:AddNewModifier(newHero, nil, "modifier_camera_follow", {duration = 1.0})
    	--newHero.IsHeroSpawn = true
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
    --else
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

    	
	--end
        --[[Timers:CreateTimer(function()
            local conn_state = PlayerResource:GetConnectionState(playerId)

            --0 = No connection
            --1 = Bot
            --2 = Player
            --3 = Disconnected

            if conn_state == 3 or conn_state == 0 then 
                return 1
            else
                local oldHero = PlayerResource:GetSelectedHeroEntity(playerId)
                if not oldHero.IsHeroSpawn then
		            oldHero:SetRespawnsDisabled(true)
		            PlayerResource:ReplaceHeroWith(playerId, hero, 3000, 0)
		            UTIL_Remove(oldHero)
		            local newHero = PlayerResource:GetSelectedHeroEntity(playerId)
		            newHero.IsHeroSpawn = true
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
			end
            return nil
        end) ]]       
   -- end)
end


function GetHeroInfo(D2hero, hero, roleList)
			
	local str = GetUnitKV(hero, "AttributeStrengthGain") 
	if str ~= math.floor(str) then
		str = string.format("%.1f",str)
	end
	local agi = GetUnitKV(hero, "AttributeAgilityGain") 
	if agi ~= math.floor(agi) then
		agi = string.format("%.1f",agi)
	end
	local int = GetUnitKV(hero, "AttributeIntelligenceGain") 
	if int ~= math.floor(int) then
		int = string.format("%.1f",int)
	end

	local hero_info = {
		--[[S1 = GetUnitKV(heroesTable[D2hero], "Ability1"),
		S2 = GetUnitKV(heroesTable[D2hero], "Ability2"),
		S3 = GetUnitKV(heroesTable[D2hero], "Ability3"),
		S4 = GetUnitKV(heroesTable[D2hero], "Ability4"),
		S5 = GetUnitKV(heroesTable[D2hero], "Ability5"),
		S6 = GetUnitKV(heroesTable[D2hero], "Ability6"),
		C = GetUnitKV(heroesTable[D2hero], "Combo"),
		A1 = GetUnitKV(heroesTable[D2hero], "Attribute1"),
		A2 = GetUnitKV(heroesTable[D2hero], "Attribute2"),
		A3 = GetUnitKV(heroesTable[D2hero], "Attribute3"),
		A4 = GetUnitKV(heroesTable[D2hero], "Attribute4"),]]
		A = GetUnitKV(hero, "AttributeNumber"),
		HP = GetUnitKV(hero, "StatusHealth"),
		--HPR = GetUnitKV(heroesTable[D2hero], "StatusHealthRegen"),
		--MP = GetUnitKV(heroesTable[D2hero], "StatusMana"),
		--MPR = GetUnitKV(heroesTable[D2hero], "StatusManaRegen"),
		--ARM = GetUnitKV(heroesTable[D2hero], "ArmorPhysical"),
		MR = GetUnitKV(hero, "MagicalResistance"),
		--ATK = (GetUnitKV(heroesTable[D2hero], "AttackDamageMin") + GetUnitKV(heroesTable[D2hero], "AttackDamageMax"))/2,
		STR = str,
		AGI = agi,
		INT = int,
		Class = roleList["Class"], --CheckClass(D2hero), 
		Sex = roleList["Sex"], --CheckSex(D2hero),
		NP = GetUnitKV(hero, "NP"),
		DIF = GetUnitKV(hero, "Difficult"),
		Ty = roleList["Roles"], --GetUnitKV(hero, "SType"),
		Tr = roleList["Trait"], --GetUnitKV(hero, "Trait")
	}

	--if GetUnitKV(hero, "AttributeNumber") == 5 then 
	--	hero_info["A5"] = GetUnitKV(hero, "Attribute5")
	--end
	
	return hero_info
end

function GetHID(hero)
	local kiuok = LoadKeyValues("scripts/npc/abilities/heroes/hero.txt")
	for k,v in pairs (kiuok) do 
		if v == hero then 
			return k
		end
	end  
end

function GetSID(skin)
	local kiuok = LoadKeyValues("scripts/npc/abilities/heroes/sketch.txt")
	for k,v in pairs (kiuok) do 
		if v == skin then 
			print(v)
			return k
		end
	end  
end

function IsSkinEnable(skin, SteamId, authority)
	local qqeiuojk = LoadKeyValues("scripts/npc/skinaccess.txt")
    local asdfioyjkl = LoadKeyValues("scripts/npc/contributeunlock.txt")

    if authority == 5 then 
    	return true 
    elseif authority == 4 then 
    	if qqeiuojk['LimitedSkin'][skin] == 1 then 
    		return false 
    	else
    		return true 
    	end
    elseif authority == 3 then
    	if qqeiuojk['LimitedSkin'][skin] == 1 then 
    		return false 
    	elseif qqeiuojk['UltimateSkin'][skin] == 1 then 
    		if asdfioyjkl[skin][SteamId] == 1 then
    			return true 
    		else
    			return false 
    		end
    	elseif qqeiuojk['HeroicSkin'][skin] == 1 then 
    		return true 
    	elseif qqeiuojk['NormalSkin'][skin] == 1 then 
    		return true 
    	elseif qqeiuojk['FreeSkin'][skin] == 1 then 
    		return true 
    	end
    elseif authority >= 1 then
    	if qqeiuojk['LimitedSkin'][skin] == 1 then 
    		return false 
    	elseif qqeiuojk['UltimateSkin'][skin] == 1 then 
    		if asdfioyjkl[skin][SteamId] == 1 then
    			return true 
    		else
    			return false 
    		end
    	elseif qqeiuojk['HeroicSkin'][skin] == 1 then 
    		if asdfioyjkl[skin][SteamId] == 1 then
    			return true 
    		else
    			return false 
    		end
    	elseif qqeiuojk['NormalSkin'][skin] == 1 then 
    		return true 
    	elseif qqeiuojk['FreeSkin'][skin] == 1 then 
    		return true 
    	end
    else
    	return false 
    end
	
end