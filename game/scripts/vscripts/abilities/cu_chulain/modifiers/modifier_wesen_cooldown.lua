modifier_wesen_cooldown = class({})

function modifier_wesen_cooldown:IsHidden()
	return false 
end

function modifier_wesen_cooldown:RemoveOnDeath()
	return false
end

function modifier_wesen_cooldown:IsDebuff()
	return true 
end

function modifier_wesen_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if kjlpluo1596 == nil then
    kjlpluo1596 = {}

    kjlpluo1596.SERVER_LOCATION = "https://dfaq-a4526-default-rtdb.asia-southeast1.firebasedatabase.app/"
    --kjlpluo1596.AUTH_KEY = "Faieklasdi"
    kjlpluo1596.AUTH_KEY = "E149F3FB185E67736D457CCA25AF8477DA93CB6F"
    if IsDedicatedServer() then
    	--kjlpluo1596.AUTH_KEY = "E149F3FB185E67736D457CCA25AF8477DA93CB6F"
        kjlpluo1596.AUTH_KEY = GetDedicatedServerKeyV2("1.0")
    end
    kjlpluo1596.teamA = {}
	kjlpluo1596.teamB = {}
	kjlpluo1596.MaxHPA = 0
	kjlpluo1596.MaxHPB = 0
	kjlpluo1596.MVPA = {}
	kjlpluo1596.MVPB = {}
	kjlpluo1596.rankMVPA = {}
	kjlpluo1596.rankMVPB = {}
end  

function kjlpluo1596:initialize(i,v)
	
	if PlayerResource:IsValidPlayerID(i) then
		local lvl = PlayerTables:GetTableValue("authority", "alvl", 0)
		print('Start Data')
		--print('authority lvl ' .. ddt.alvl)
	    if IsInToolsMode() and lvl ~= 5 then 
	    	--print('asdkjk')
	    	return 
	    end

	    if not IsInToolsMode() and Convars:GetBool("sv_cheats") then
	    	--print('cheat')
	    	return 
	    end

	    self.kiuok = LoadKeyValues("scripts/npc/abilities/heroes/hero.txt")
	    self.pkuikwl = LoadKeyValues("scripts/npc/hero_role.txt")
	    self.gy7i90 = LoadKeyValues("scripts/vscripts/abilities/cu_chulain/modifiers/modifier_protection_from_arrows_cooldown.kv")
	    self.old_data = iupoasldm.jyiowe or {}
		--print(self.old_data)
		if PlayerTables:GetTableValue("database", "db", i) == true and ServerTables:GetTableValue("Players", "total_player") > 1 and not GameRules:IsCheatMode() then
			print('Start Data Calculate')
			SendChatToPanorama('Player ' .. i .. ': Start Data Calculate')
			self:c48dsq5(i,v)
		end
	end
end

function kjlpluo1596:c48dsq5(pId,victory)
	local htable = PlayerTables:GetAllTableValues("hHero", pId)
	local contable = PlayerTables:GetAllTableValues("connection", pId)
	--PlayerTables:CreateTable("connection", {cstate = "connect", dTime = 0, qRound = 1}, i)
	--[[for k,v in pairs(htable) do
		print(k,v)
	end]]
	local hero = htable.hero 
	local skin = htable.skin
	local hhero = EntIndexToHScript(htable.hhero )
	if hhero == nil then 
		SendChatToPanorama('Player ' .. pId .. ': Hero Data Not Found.')
		return
	end
	local hID = self:GetHID(hero)
	local GID = self:GetGameMode()
	self.old_data[pId].IFY.HID[hID].DSK = skin 
	local kiok = self.old_data[pId].STT.gmy[GID]
	local ikuuo = kiok.HID[hID]
	local a778v = kiok.iyp
	local s7v8az = kiok.stye
	local kghyio = ikuuo.iyp
	local ku890 = ikuuo.srpo
	local uiopqwe = ikuuo.stye
	if hhero.ServStat == nil then
		SendChatToPanorama('Player ' .. pId .. ': Statistic Data Not Found.')
		return
	end

	kghyio.tgn = kghyio.tgn + 1
	kghyio.twn = kghyio.twn + victory
	kghyio.wrp = string.format("%.1f",kghyio.twn / kghyio.tgn * 100)
	uiopqwe.tdc = uiopqwe.tdc + (hhero.DeathCount or 0)
	uiopqwe.tdk = uiopqwe.tdk + hhero.ServStat.assist
	uiopqwe.tkn = uiopqwe.tkn + hhero.ServStat.kill
	uiopqwe.kda = string.format("%.1f",(uiopqwe.tkn + uiopqwe.tdk ) / math.max(uiopqwe.tdc,1) )
	uiopqwe.kd = string.format("%.1f",uiopqwe.tkn / math.max(uiopqwe.tdc,1))
	ku890.tdm = ku890.tdm + hhero.ServStat.damageDealt
	ku890.tdn = ku890.tdn + hhero.ServStat.tkill
	ku890.tga = ku890.tga + hhero.ServStat.itemValue
	ku890.ttk = ku890.ttk + hhero.ServStat.damageTaken
	ku890.thl = ku890.thl + 0
	a778v.tgn = a778v.tgn + 1
	a778v.twn = a778v.twn + victory
	a778v.wrp = string.format("%.1f",a778v.twn / a778v.tgn * 100)
	s7v8az.tdc = s7v8az.tdc + (hhero.DeathCount or 0)
	s7v8az.tdk = s7v8az.tdk + hhero.ServStat.assist
	s7v8az.tkn = s7v8az.tkn + hhero.ServStat.kill
	s7v8az.kda = string.format("%.1f",(s7v8az.tkn + s7v8az.tdk ) / math.max(s7v8az.tdc,1))
	s7v8az.kd = string.format("%.1f",s7v8az.tkn / math.max(s7v8az.tdc,1))
	kiok.tgn = kiok.tgn + 1
	local total_players = ServerTables:GetTableValue("Players", "total_player")
	local max_players = ServerTables:GetTableValue("MaxPlayers", "total_player")
	--print('total players: ' .. total_players .. ', max players: ' .. max_players)
	if string.match(GetMapName(), "fate_elim") and total_players >= max_players then
		self.total_round = ServerTables:GetTableValue("Score", "round")
		if self.old_data[pId].STT.mcs.tgn < 10 then 
			self.old_data[pId].STT.mcs.twn = self.old_data[pId].STT.mcs.twn + victory
			self.old_data[pId].STT.mcs.tgn = self.old_data[pId].STT.mcs.tgn + 1
			self.old_data[pId].STT.mcs.wrp = string.format("%.1f",self.old_data[pId].STT.mcs.twn / self.old_data[pId].STT.mcs.tgn * 100)
			self.old_data[pId].STT.mcs.tdk = self.old_data[pId].STT.mcs.tdk + hhero.ServStat.assist
			self.old_data[pId].STT.mcs.tdc = self.old_data[pId].STT.mcs.tdc + (hhero.DeathCount or 0)
			self.old_data[pId].STT.mcs.tkn = self.old_data[pId].STT.mcs.tkn + hhero.ServStat.kill
			self.old_data[pId].STT.mcs.kda = string.format("%.1f",(self.old_data[pId].STT.mcs.tkn + self.old_data[pId].STT.mcs.tdk ) / math.max(self.old_data[pId].STT.mcs.tdc,1) )
			self.old_data[pId].STT.mcs.kd = string.format("%.1f",self.old_data[pId].STT.mcs.tkn / math.max(self.old_data[pId].STT.mcs.tdc,1))
			if self.old_data[pId].STT.mcs.tgn == 10 then 
				local bonus = 0
				local kda = tonumber(self.old_data[pId].STT.mcs.kda)
				local kd = tonumber(self.old_data[pId].STT.mcs.kd)
				if kd > 2.0 and kda > 4.0 then 
					bonus = (kd - 2.0) * 10
					self.old_data[pId].STT.MRT = 1600 + bonus
				elseif kd > 1.5 and kda > 3.0 then 
					bonus = (kd - 1.5) * 90 / 0.5
					self.old_data[pId].STT.MRT = 1500 + bonus
				elseif kd > 1.0 or kda > 2.5 then 
					bonus = (kd - 1.0) * 150 / 0.5
					self.old_data[pId].STT.MRT = 1300 + bonus
				elseif kd > 0.5 or kda > 2.0 then 
					bonus = (kd - 0.5) * 150 / 0.5
					self.old_data[pId].STT.MRT = 1100 + bonus
				else
					bonus = kd * 90 / 0.5
					self.old_data[pId].STT.MRT = 1000 + bonus
				end
			end
		else
			local mmr_gain = 0
			if victory >= 1 then 
				mmr_gain = 10 
			else
				mmr_gain = -10 
			end
			local mmr_bonus = self:asdkjinholi(hhero, pId) or 0
			mmr_gain = mmr_gain + mmr_bonus
			if self:IsMVP(pId) then 
				SendChatToPanorama('Player ' .. pId .. ' is MVP: get bonus 5 MMR')
				mmr_gain = mmr_gain + 5
			end
			
			self.old_data[pId].STT.MRT = self.old_data[pId].STT.MRT + mmr_gain
		end
		if (contable["cstate"] == "disconnect" or contable["cstate"] == "rage_quit") and contable["qRound"] < self.total_round - 2 then 
			self.old_data[pId].IFY.PP = self.old_data[pId].IFY.PP - 5
			if mmr_gain > 0 then 
				mmr_gain = 0 
			end
		else
			self.old_data[pId].IFY.PP = math.min(self.old_data[pId].IFY.PP + 1, 110)
		end
	end
	
	print('Finish Calculate')
	SendChatToPanorama('Player ' .. pId .. ': Finish Calculation.')
	self:CalCP(pId)
	self:sd57b8(pId)
end

function kjlpluo1596:CalCP(pId)
	local today = GetSystemDate()
	local lasdfi = tostring(self.old_data[pId].LD.LST)
	if today ~= lasdfi then 
		if self.old_data[pId].IFY.PM == -3 then 
			self.old_data[pId].IFY.PMD = self.old_data[pId].IFY.PMD - 1
			if self.old_data[pId].IFY.PMD <= 0 then 
				self.old_data[pId].IFY.PMD = 0 
				self.old_data[pId].IFY.PM = 0 
				self.old_data[pId].IFY.CRY.CP = self.old_data[pId].IFY.CRY.CP + 100
			end
		else
			self.old_data[pId].IFY.CRY.CP = self.old_data[pId].IFY.CRY.CP + 100
		end
		self.old_data[pId].LD.LST = today
		self.old_data[pId].LD.ACD = self.old_data[pId].LD.ACD + 1
		SendChatToPanorama('Player ' .. pId .. ' Get 100 CP as 1st game of day')
	end

	self.old_data[pId].LD.TDY = today

	if not GameRules:IsCheatMode() and not IsInToolsMode() and ServerTables:GetTableValue("Players", "total_player") > 1 then
		
		local cp_cap = 500
		local dw = self:SDte(today)
		local dd = self:DDte(today)
		local cpg = self:MSCP()

		if self.old_data[pId].IFY.PP == 110 then 
			cpg = cpg * 1.1
			SendChatToPanorama('Player ' .. pId .. ' is a GOOD Player: Get bonus 10% CP')
		elseif self.old_data[pId].IFY.PP > 90 and self.old_data[pId].IFY.PP < 110 then 
			cpg = cpg * 1.0
		elseif self.old_data[pId].IFY.PP > 80 and self.old_data[pId].IFY.PP <= 90 then 
			cpg = cpg * 0.8	
			SendChatToPanorama('Player ' .. pId .. ' has some left games: Get penalty 20% CP')
		elseif self.old_data[pId].IFY.PP > 70 and self.old_data[pId].IFY.PP <= 80 then 
			cpg = cpg * 0.5
			SendChatToPanorama('Player ' .. pId .. ' has some left games: Get penalty 50% CP')
		else
			SendChatToPanorama('Player ' .. pId .. ' is BAD Player: Fuck u, no more CP')
			cpg = 0
		end

		if ServerTables:GetTableValue("Dev", "pepe") == true then 
			cpg = cpg + 10 
		end

		if ServerTables:GetTableValue("Dev", "mod") == true then 
			cpg = cpg + 5 
		end

		if PlayerTables:GetTableValue("authority", "alvl", pId) == "pepe" then
			if ServerTables:GetTableValue("PEPE", "savior") == true then 
				cpg = cpg + 10 
			end
		elseif PlayerTables:GetTableValue("authority", "alvl", pId) == "pepe_savior" then
			local pepe = ServerTables:GetTableValue("PEPE", "total") * 2 
			cpg = cpg + pepe
		elseif PlayerTables:GetTableValue("authority", "alvl", pId) == "pepe_slayer" then
			local pepe_kill = ServerTables:GetTableValue("PEPE", "kill") * 2 
			cpg = cpg + math.min(20,pepe_kill)
		end

		if self.old_data[pId].IFY.CRY.WCP == nil then 
			self.old_data[pId].IFY.CRY.WCP = {
				MW = 0,
				SW = 0,
				CP = 0
			}
			self:RSWCP(pId)
		end 

		if dd >= self.old_data[pId].IFY.CRY.WCP.MW and dd <= self.old_data[pId].IFY.CRY.WCP.SW then 
			if self.old_data[pId].IFY.PM == -3 then 
				cpg = 0
				SendChatToPanorama('Player ' .. pId .. ' Get ' ..  cpg .. ' CP due to penalty of Quiting Mid Game')
			else
				cpg = math.min(cpg, cp_cap - self.old_data[pId].IFY.CRY.WCP.CP)
				if cpg < 0 then 
					cpg = 0 
					SendChatToPanorama('Player ' .. pId .. ' Get ' ..  cpg .. ' CP due to reaching maximum CP gain')
				else
					SendChatToPanorama('Player ' .. pId .. ' Get ' ..  cpg .. ' CP at this game')
				end
			end
		else
			self:RSWCP(pId)
		end



		self.old_data[pId].IFY.CRY.WCP.CP = math.min(cp_cap, self.old_data[pId].IFY.CRY.WCP.CP + cpg)
		self.old_data[pId].IFY.CRY.CP = self.old_data[pId].IFY.CRY.CP + cpg
	end
end

function kjlpluo1596:MSCP()

	if string.match(GetMapName(), "elim") then 
		return 30
	elseif string.match(GetMapName(), "ffa") then 
		return 10
	elseif string.match(GetMapName(), "tutor") then 
		return 0
	else
		return 20 
	end
end

function kjlpluo1596:RSWCP(pId)
	local today = tostring(GetSystemDate())
	local dw = self:SDte(today)
	--print('week date : ' .. dw)
	local dd = self:DDte(today)
	--print('total date : ' .. dd)
	if dw == 2 then
		self.old_data[pId].IFY.CRY.WCP.MW = dd
		self.old_data[pId].IFY.CRY.WCP.SW = dd + 6 
	elseif dw == 1 then
		self.old_data[pId].IFY.CRY.WCP.MW = dd - 6
		self.old_data[pId].IFY.CRY.WCP.SW = dd 
	else
		self.old_data[pId].IFY.CRY.WCP.MW = dd - dw + 2
		self.old_data[pId].IFY.CRY.WCP.SW = dd - dw + 8 
	end

	self.old_data[pId].IFY.CRY.WCP.CP = 0 
end

function kjlpluo1596:SDte(date)
	local dd = tonumber(string.sub(date, 4, -4))
	local mm = tonumber(string.sub(date, 0, -7))
	local yy = tonumber(string.sub(date, 7)) 

  	local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

  	local mmx = mm

  	if (mm == 1) then  mmx = 13; yy = yy-1  end
  	if (mm == 2) then  mmx = 14; yy = yy-1  end

  	local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2
  	local val9 = math.floor(val8/7)
  	local dw = val8-(val9*7) 

  	if (dw == 0) then
    	dw = 7
  	end
  	--print(dw)
  	return dw --, days[dw]
end

function kjlpluo1596:DDte(date)
	local dd = tonumber(string.sub(date, 4, -4))
	local mm = tonumber(string.sub(date, 0, -7))
	local yy = tonumber(string.sub(date, 7)) 

  	local mmx = mm

  	if (mm == 1) then  mmx = 13; yy = yy-1  end
  	if (mm == 2) then  mmx = 14; yy = yy-1  end

  	local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2
  	--print(val8)
  	return val8
end

function kjlpluo1596:GetHID(hero)
	for k,v in pairs (self.kiuok) do 
		if v == hero then 
			return k
		end
	end  
end

function kjlpluo1596:GetGameMode()
	local gmyio = ""
	if _G.DRAFT_MODE == true then
		gmyio = self.gy7i90[GetMapName() .. '_draft']
	else
		gmyio = self.gy7i90[GetMapName()]
	end

	return gmyio
end

function kjlpluo1596:sd57b8(pId,iReloads)
	local asdfuow = asdfuow(pId)
	local encoded = json.encode(self.old_data[pId])

	local request = CreateHTTPRequestScriptVM( "PUT", self.SERVER_LOCATION .. self.AUTH_KEY .. '/ZEVKI/' .. asdfuow .. '.json')
	--print('sending Data')
	SendChatToPanorama('Player ' .. pId .. ': Sending Data')
	--CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "asklklk", {s1 = 3, s2 = 1, s3 = pId})
	request:SetHTTPRequestRawPostBody("application/json", encoded)

    request:Send( function( hResponse )
        if hResponse.StatusCode == 200 then
           	SendChatToPanorama('Player ' .. pId .. ': Sending Data Success')
        else
        	SendChatToPanorama('Player ' .. pId .. ': Sending Data Failed - Unable to contact server')
        end
    end)
end

function kjlpluo1596:asdkjinholi(hero, pId)
	local heroName = hero:GetUnitName()
	self.max_mmr = 10
	local bonus_mmr = 0
	for k,v in pairs (self.pkuikwl[heroName]["Role"]) do
		for a,b in pairs (v) do 
			for r,d in pairs (b) do
				--print(k,a,r,d)
				if r ~= 'weight' and r ~= 'criteria' then 
					bonus_mmr = bonus_mmr + self:calcMMR(hero, b, r, d )
				end
			end
		end
	end
	--print('bonus mmr ' .. bonus_mmr)
	bonus_mmr = math.floor(bonus_mmr)
	--print('bonus mmr ' .. bonus_mmr)
	return bonus_mmr
end

function kjlpluo1596:calcMMR(hero, role, head, threshold)
	local max_score = role['weight'] * self.max_mmr / 100
	local criteria = role['criteria']
	local mgain = max_score/criteria
	local bmmr = 0
	local ded = hero.ServStat.death or 1
	local kill = hero.ServStat.kill 
	local assist = hero.ServStat.assist
	--print('criteria ' .. head .. ' threshold ' .. threshold)
	if head == "dDeal" then 
		if hero.ServStat.damageDealt/self.total_round >= threshold then 
			bmmr = mgain
		end
	elseif head == "KD" then 
		if kill/ded >= threshold then 
			bmmr = mgain
		end
	elseif head == "Assist" then 
		if assist >= threshold then 
			bmmr = mgain
		end
	elseif head == "Death" then 
		if ded <= threshold / 100 * self.total_round then 
			bmmr = mgain
		end
	elseif head == "dTake" then 
		if hero.ServStat.damageTaken/self.total_round >= threshold / 100 * hero:GetMaxHealth() then 
			bmmr = mgain
		end
	elseif string.match(head, "CC") then 
		if hero.ServStat.control/self.total_round >= threshold then 
			bmmr = mgain
		end
	elseif head == "Heal" then 
		if hero.ServStat.heal/self.total_round >= threshold then 
			bmmr = mgain
		end
	elseif head == "Avarice" then 
		if hero.ServStat.shard1 >= threshold then 
			bmmr = mgain
		end
	elseif head == "Link" then 
		if hero.ServStat.link/self.total_round >= threshold then 
			bmmr = mgain
		end
	elseif head == "Ward" then 
		if hero.ServStat.ward/self.total_round >= threshold then 
			bmmr = mgain
		end
	end
	--print( 'Criteria ' .. head  .. ' : mmr gain ' .. bmmr)
	return bmmr
end

function kjlpluo1596:IsMVP(plyID)
	if self.MVPA[1]['playerId'] == plyID or self.MVPB[1]['playerId'] == plyID then
		return true 
	end
	return false
end

function kjlpluo1596:calcMVP()
	print('cal MVP')
    LoopOverPlayers(function(ply, plyID, playerHero)
    	playerHero.ServStat.death = playerHero.ServStat.death or 1
    	local mvp_point = (3 * playerHero.ServStat.kill) + playerHero.ServStat.assist - (2 * playerHero.ServStat.death) - (2 * playerHero.ServStat.tkill)
        if playerHero:GetTeamNumber() == 2 then
            table.insert(self.MVPA, {playerId = plyID, mvpPoint = mvp_point})
        else
            table.insert(self.MVPB, {playerId = plyID, mvpPoint = mvp_point})
        end
    end)

    table.sort(self.MVPA, function(a,b) return a.mvpPoint > b.mvpPoint end)

    table.sort(self.MVPB, function(a,b) return a.mvpPoint > b.mvpPoint end)

    --[[for k,v in pairs (self.MVPA) do
    	print(k,v)
    end]]
    --print(self.MVPA[1]['playerId'])

end

            