modifier_hrunting_window = class({})

if IsServer() then
	function modifier_hrunting_window:OnCreated(args)
		local hero = self:GetParent()

		--[[local tStandardAbilities = {
	        "emiya_kanshou_byakuya",
	        "emiya_broken_phantasm",
	        "emiya_crane_wings",
	        "emiya_rho_aias",
	        "emiya_hrunting",
	        "emiya_unlimited_bladeworks",
	        "attribute_bonus_custom"
	    }

	    UpdateAbilityLayout(caster, tUBWAbilities)]]
		hero:SwapAbilities("emiya_clairvoyance", "emiya_hrunting", false, true) 
	end

	function modifier_hrunting_window:OnRefresh(args)
	end

	function modifier_hrunting_window:OnDestroy()	
		local hero = self:GetParent()
		local ubw = hero:FindAbilityByName("emiya_unlimited_bladeworks")

		ubw:SwitchAbilities(hero:HasModifier("modifier_unlimited_bladeworks"))


		--hero:SwapAbilities("emiya_hrunting", "emiya_clairvoyance", false, true)
	end
end

function modifier_hrunting_window:IsHidden()
	return true 
end

function modifier_hrunting_window:RemoveOnDeath()
	return true
end

if yedped == nil then
    yedped = {}
end 

function yedped:ppri()
	self.MRN = {}
	self.SSTier = {}
	self.STier = {}
	self.ATier = {}
	self.BTier = {}
	self.CTier = {}
	self.SSPlayers = 0
	self.SPlayers = 0
	self.APlayers = 0
	self.BPlayers = 0
	self.CPlayers = 0
	self.index = 0
	self.SSGroup = {}
	self.SGroup = {}
	self.AGroup = {}
	self.BGroup = {}
	self.CGroup = {}
	self.left_team = {}
	self.right_team = {}
	self.team = {}
	self.left_team_c = 0
	self.right_team_c = 0
	self.noteam = {}
end

function yedped:start()

	for i = 0, 13 do 
		if PlayerResource:IsValidPlayer(i) then
	
			if PlayerTables:GetTableValue("database", "db", i) == false then 
			    local asdio = iupoasldm
				asdio:initialize(i)
			end
		end
	end

	Timers:CreateTimer(5.0, function()
		for i = 0, 13 do 
			if PlayerTables:GetTableValue("database", "db", i) == true then 
				self.MRN[i] = iupoasldm.jyiowe[i].STT.MRT
				if iupoasldm.jyiowe[i].STT.mcs.tgn < 10 then 
					self:smdetect(i)
				end
				--SendChatToPanorama('Player ' .. i .. ': MMR ' .. self.MRN[i])
				--[[if self.MRN[i] > 1000 then 
					self:syipl(i, self.MRN[i])
				else
					if iupoasldm.jyiowe[i].STT.gmy.CDMR.tgn > 0 then 
						self:smdetect(i)
					else
						self:syipl(i, self.MRN[i])
					end
				end]]
			end
		end

		self:ablyo()

	end)

end

function yedped:jupa870(pId)
	if PlayerTables:GetTableValue("database", "db", pId) == true then 

		self.MRN[pId] = iupoasldm.jyiowe[pId].STT.MRT
		--SendChatToPanorama('Player ' .. pId .. ': MMR ' .. self.MRN[pId])
		
		self.noteam[pId] = 5
		if self.MRN[pId] > 1000 then 
			self:syipl(pId, self.MRN[pId])
		else
			if iupoasldm.jyiowe[pId].STT.gmy.CDMR.tgn > 0 then 
				self:smdetect(pId)
			else
				self:syipl(pId, self.MRN[pId])
			end
		end
		print('Player ' .. pId .. ': MMR ' .. self.MRN[pId])
	end

	if ServerTables:GetTableValue("Load", "player") >= 14 or IsInToolsMode() then 
		self:ablyo()
	end
end

function yedped:smdetect(playerId)
	local ssr = iupoasldm.jyiowe[playerId].STT.mcs
	local asdfi = tonumber(ssr.kd)
	local kinpi = tonumber(ssr.kda)
	local bonus = 0

	if asdfi > 2.0 and kinpi > 4.0 then 
		bonus = (asdfi - 2.0) * 10
		self.MRN[playerId] = 1600 + bonus
	elseif asdfi > 1.5 and kinpi > 3.0 then 
		bonus = (asdfi - 1.5) * 90 / 0.5
		self.MRN[playerId] = 1500 + bonus
	elseif asdfi > 1.0 or kinpi > 2.5 then 
		bonus = (asdfi - 1.0) * 150 / 0.5
		self.MRN[playerId] = 1300 + bonus
	elseif asdfi > 0.5 or kinpi > 2.0 then 
		bonus = (asdfi - 0.5) * 150 / 0.5
		self.MRN[playerId] = 1100 + bonus
	else
		bonus = asdfi * 90 / 0.5
		self.MRN[playerId] = 1000 + bonus
	end

	--if --[[self.MRN[playerId] < 1500 and]] iupoasldm.jyiowe[playerId].STT.gmy.CDMR.tgn < 5 then 
	--	self.MRN[playerId] = self.MRN[playerId] - 100 
	--end

	self:syipl(playerId, self.MRN[playerId])
end

function yedped:syipl(id, MMR)
	if MMR >= 1600 then 
		
		--self.SSTier[self.SSPlayers] = id
		self.SSGroup[id] = MMR
		self.SSPlayers = self.SSPlayers + 1
	elseif MMR >= 1500 then 
		
		--self.STier[self.SPlayers] = id
		self.SGroup[id] = MMR
		self.SPlayers = self.SPlayers + 1
	elseif MMR >= 1300 then 
		
		--self.ATier[self.APlayers] = i
		self.AGroup[id] = MMR
		self.APlayers = self.APlayers + 1
	elseif MMR >= 1100 then 
		
		--self.BTier[self.BPlayers] = id
		self.BGroup[id] = MMR
		self.BPlayers = self.BPlayers + 1
	else
		
		--self.CTier[self.CPlayers] = id
		self.CGroup[id] = MMR
		self.CPlayers = self.CPlayers + 1
	end
	--print('player ' .. id .. ' has MMR ' .. MMR)
end

function yedped:ablyo()

	for i = 1, 14 do
		if i == 1 or i == 4 or i == 5 or i == 8 or i == 9 or i == 12 or i == 14 then 
			self:maxcut(2)
		else
			self:maxcut(3)
		end
	end

	Timers:CreateTimer(0.1, function()
		CustomGameEventManager:Send_ServerToAllClients( "auto_balanze", {balance = true} )
		for n = 0,13 do
			PlayerResource:SetCustomTeamAssignment(n, 5)
			if self.MRN[n] == nil then 
				self.MRN[n] = "N/A"
			end
		end	
		CustomNetTables:SetTableValue("parsy", "mmr", self.MRN)
	end)

	--[[for i = 1, self.SSPlayers do 
		self:sephimkls(self.SSGroup, i, 5)
	end

	Timers:CreateTimer(0.1, function()
		for j = 1, self.SPlayers do 
			self:sephimkls(self.SGroup, j, 4)
		end

		Timers:CreateTimer(0.1, function()
			for k = 1, self.CPlayers do 
				self:sephimkls(self.CGroup, k, 1)
			end

			Timers:CreateTimer(0.1, function()
				local iMore = 0

				for l = 1, self.APlayers do 
					if l == 1 then 
						iMore = self.left_team_c - self.right_team_c
					end
					self:sephimkls(self.AGroup, l, 3, iMore)
				end

				Timers:CreateTimer(0.1, function()
					for m = 1, self.BPlayers do 
						if m == 1 then 
							iMore = self.left_team_c - self.right_team_c
						end
						self:sephimkls(self.BGroup, m, 2, iMore)
					end

					Timers:CreateTimer(0.1, function()
						CustomGameEventManager:Send_ServerToAllClients( "auto_balanze", {balance = true} )
						for n = 0,13 do
							PlayerResource:SetCustomTeamAssignment(n, 5)
						end	
					end)
				end)
			end)
		end)
	end)]]
end

function yedped:sephimkls(htable, i, group_tier, iMoreSide)

	if group_tier == 5 then
		--print('SS')
		if self.SSPlayers > 0 then 
			if i == 1 then
				self:maxout(htable, 2)
			elseif i == 2 then 
				self:maxout(htable, 3)
			elseif i%2 == 1 then 
				self:maxout(htable, 3)
			else
				self:maxout(htable, 2)
			end
		end
	elseif group_tier == 4 then 
		--print('S')
		if self.SPlayers > 0 then 
			if self.SSPlayers == 1 then 
				if i <= 2 then
					self:maxout(htable, 3)
				elseif i%2 == 1 then 
					self:maxout(htable, 2)
				else
					self:maxout(htable, 3)
				end
			elseif self.SSPlayers % 2 == 0 then
				if i == 1 then
					self:maxout(htable, 2)
				elseif i == 2 then 
					self:maxout(htable, 3)
				elseif i%2 == 1 then 
					self:maxout(htable, 3)
				else
					self:maxout(htable, 2)
				end
			else
				if i % 2 == 1 then 
					self:maxout(htable, 2)
				else
					self:maxout(htable, 3)
				end
			end
		end
	elseif group_tier == 1 then 
		--print('C')
		if self.CPlayers > 0 then 
			if i%2 == 1 then 
				self:minout(htable, 2)
			else
				self:minout(htable, 3)
			end
		end
	elseif group_tier == 3 then 
		--print('A')
		if self.APlayers > 0 then 
			if iMoreSide == 1 then 
				if i%2 == 1 then 
					self:maxout(htable, 3)
				else
					self:maxout(htable, 2)
				end
			else
				if i%2 == 1 then 
					self:maxout(htable, 2)
				else
					self:maxout(htable, 3)
				end
			end
		end
	else
		--print('B')
		if self.BPlayers > 0 then 
			if iMoreSide == 1 then 
				if i%2 == 1 then 
					self:maxout(htable, 3)
				else
					self:maxout(htable, 2)
				end
			else
				if i%2 == 1 then 
					self:maxout(htable, 2)
				else
					self:maxout(htable, 3)
				end
			end
		end
	end
end

function yedped:shuf()
	--self.team[0] = 3
	--CustomGameEventManager:Send_ServerToAllClients( "auto_balance", self.team )	
	
	for i = 0,13 do
		--SendChatToPanorama('Player ' .. i .. ': team ' .. self.team[i])
		--print('player ' .. i)
		--print('Team ' .. self.team[i])
		--SendChatToPanorama('Player ' .. i .. ': MMR ' .. self.MRN[i] .. ': actual team ' .. self.team[i])
		PlayerResource:SetCustomTeamAssignment(i, self.team[i])
		--local player_team = PlayerResource:GetCustomTeamAssignment(i)
		--SendChatToPanorama('Player ' .. i .. ': actual team ' .. player_team)
	end
	ServerTables:SetTableValue("AutoBalance", "auto_balance", true, true)
	
    --CustomGameEventManager:Send_ServerToAllClients("restart_scoreboard", {reset = true})
end

function yedped:maxcut(iTeam)
	local highest = 0
	local Id = -1 

	for pId, MMR in pairs (self.MRN) do 
		if not self.team[pId] then
		--print('player ' .. pId .. ' MMR ' .. MMR)
			if MMR > highest then 
				highest = MMR 
				Id = pId 
				--print('player ' .. Id .. ' Highest MMR ' .. highest)
			end
		end
	end

	if Id == -1 then 
		--SendChatToPanorama("ID Error")
		print('ID Error')
		return 
	end

	self.team[Id] = iTeam
end

function yedped:maxout(htable, iTeam)

	if htable == {} then
		print('no data in table')
	 	return  
	end

	local highest = 0
	local Id = -1 

	for pId, MMR in pairs (htable) do 
		--print('player ' .. pId .. ' MMR ' .. MMR)
		if MMR > highest then 
			highest = MMR 
			Id = pId 
			--print('player ' .. Id .. ' Highest MMR ' .. highest)
		end
	end

	if Id == -1 then 
		--SendChatToPanorama("ID Error")
		print('ID Error')
		return 
	end

	--if Id >= 0 then
	htable[Id] = nil
		--table.remove(htable, Id)
	--[[for k,v in pairs(htable) do 
		print(k,v)
	end]]
	--SendChatToPanorama("Player " .. Id .. " go to team " .. iTeam)
	self.team[Id] = iTeam
	if iTeam == 2 then 
		self.left_team[Id] = Id
		self.left_team_c = self.left_team_c + 1
	else
		self.right_team[Id] = Id
		self.right_team_c = self.right_team_c + 1
	end
end

function yedped:minout(htable, iTeam)

	if htable == {} then
		print('no data in table')
	 	return  
	end

	local lowest = 1100
	local Id = -1 

	for pId, MMR in pairs (htable) do 
		if MMR < lowest then 
			lowest = MMR 
			Id = pId 
			--print('player ' .. Id .. ' Lowest MMR ' .. lowest)
		end
	end

	if Id == -1 then 
		--SendChatToPanorama("ID Error")
		print('ID Error')
		return 
	end

	htable[Id] = nil

	self.team[Id] = iTeam
	if iTeam == 2 then 
		self.left_team[Id] = Id
		self.left_team_c = self.left_team_c + 1
	else
		self.right_team[Id] = Id
		self.right_team_c = self.right_team_c + 1
	end

end

if yedped_init == nil then 
	yedped_init = true
	yedped:ppri()
end