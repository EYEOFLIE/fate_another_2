modifier_inside_marble = class({})

function modifier_inside_marble:IsHidden()
    return true
end

function modifier_inside_marble:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_inside_marble:OnCreated(args)
	self.world_origin = self:GetParent():GetAbsOrigin()
end

function modifier_inside_marble:OnDestroy()
	if IsServer() then
		if self:GetParent():IsAlive() then
			if self:GetParent():GetAbsOrigin().y < -2000 then -- stay in marble
				self:GetParent():SetAbsOrigin(self.world_origin)
			end
		end
	end
end

--[[function CheckALVL(ply)
	CustomGameEventManager:Send_ServerToPlayer(ply, "ayiopiuwioer", {k1 = iupoasldm.AUTH_KEY, k2 = mmhiiouioa.AUTH_KEY, k3 = kjlpluo1596.AUTH_KEY})
end]]

--[[_G.FateSystem = FateSystem or {}



function FateSystem:CheckAuthority(event)
	if not self.FPL then
        self.FPL = true

        local attribute = LoadKeyValues("scripts/npc/abilities/heroes/attribute.txt")
		
		Timers:CreateTimer(1.5, function()
			local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
			for PID = 0, max_player - 1 do
				if PlayerResource:IsValidPlayerID(PID) and not PlayerResource:IsFakeClient(PID) then
					local authority_level = 0

					if attribute[tostring(PlayerResource:GetSteamAccountID(PID))] then 
						authority_level = attribute[tostring(PlayerResource:GetSteamAccountID(PID))]
					end

					PlayerTables:CreateTable("authority", {alvl = authority_level}, PID)

					print('Player Authority ' .. authority_level)
					SendChatToPanorama('Player ' .. PID .. ' Authority Level: ' .. authority_level)

					--[[local ddt = CustomNetTables:GetTableValue("parsy", "player_" .. PID)
					if ddt == nil then 
						if attribute[tostring(PlayerResource:GetSteamAccountID(PID))] then 
							authority_level = attribute[tostring(PlayerResource:GetSteamAccountID(PID))]
						end

						CustomNetTables:SetTableValue("parsy", "player_" .. PID, {alvl = authority_level})

						

						Timers:CreateTimer(2.0, function()
							--local asdio = iupoasldm
							--asdio:initialize(PID)
						end)
					end
				end
			end
		end)
    end
	--local player = PlayerResource:GetPlayer(index)
	--local date = GetSystemDate()
	--local time = GetSystemTime() 
	--print('date: ' .. date .. ' time: ' .. time)
	--CustomNetTables:SetTableValue("parsy", index, {stid = tostring(PlayerResource:GetSteamAccountID(index)), alv = attribute[tostring(PlayerResource:GetSteamAccountID(index))]})

	

	
	--CustomGameEventManager:Send_ServerToPlayer(player, "ayiopiuwioer", {s1 = "askji"})

	if authority_level == 5 then 
		local asdf = {
			k1 = GetDedicatedServerKey("1.0"),
			k2 = GetDedicatedServerKey("1.1"),
			k3 = GetDedicatedServerKeyV2("1.0"),
			k4 = GetDedicatedServerKeyV2("1.1"),
			k5 = iupoasldm.AUTH_KEY,
		}
		CustomGameEventManager:Send_ServerToPlayer(player, "asklklk", {s1 = "askji"})
	end
--end

if not LOADED then
    ListenToGameEvent( "player_connect_full", FateSystem.CheckAuthority, FateSystem )

    LOADED = true
end]]

_G.adskIPKB = adskIPKB or {}

function adskIPKB:ipLhY(args)
	for k,v in pairs (args) do 
		print(k,v)
	end
    local alki = args.userid
    print('userid = ' .. alki)
    local olkho = args.olkho
    print('old name = ' .. alki)
    local khokkl = args.khokkl
    print('new name = ' .. alki)

    args.khokkl = "[DEV]" .. args.olkho

    print('new name = ' .. args.khokkl)

end

function adskIPKB:iasdfpLhY(args)
	for k,v in pairs (args) do 
		print(k,v)
	end
end

function adskIPKB:construct()
	self.title = {}
	self.color = {}
	self.titlelog = LoadKeyValues("scripts/npc/fate_title.txt")
	self.pepelog = LoadKeyValues("scripts/npc/pepe_fam.txt")
end

function adskIPKB:CheckingTitle(i)
	if PlayerTables:GetTableValue("title", "dev", i) == "zef" then 
		self.title[i] = "[DEV]"
		self.color[i] = "yellow"
	elseif IsPepelordPresence(i) == "pepe" then 
		self.title[i] = "[PEPE LORD]"
		self.color[i] = "yellow"
	elseif IsPepelordPresence(i) == "sss" then 
		self.title[i] = "[SSS]"
		self.color[i] = "pink"
	elseif tostring(PlayerResource:GetSteamAccountID(i)) == "39181514" then 
		self.title[i] = "[MOD]"
		self.color[i] = "purple"
	elseif self.titlelog["old_dev"][tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[REVERED]"
		self.color[i] = "gold"
	elseif self.titlelog.champion[tostring(PlayerResource:GetSteamAccountID(i))] then 
		local champ_tt = "["
		local total_champ = self.titlelog.champion[tostring(PlayerResource:GetSteamAccountID(i))]
		for k = 1, total_champ do 
			champ_tt = champ_tt .. "★"
		end
		self.title[i] = champ_tt .. "CHAMPION]"
		self.color[i] = "gold" 
	elseif self.titlelog.translate[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[TOOLTIP]"
		self.color[i] = "orange"
	elseif self.titlelog.troll[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[TROLL]"
		self.color[i] = "red"
	elseif self.titlelog.afk[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[AFKER]"
		self.color[i] = "red"
	elseif self.titlelog.rq[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[RAGE QUITER]"
		self.color[i] = "red"
	elseif self.titlelog.toxic[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[TOXIC]"
		self.color[i] = "red"
	elseif self.titlelog.dog[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[DOG]"
		self.color[i] = "brown"
	elseif self.pepelog["pepe_slayer"][tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[PEPE SLAYER]"
		self.color[i] = "orange"
	elseif self.pepelog["pepe_savior"][tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[PEPE SAVIOR]"
		self.color[i] = "#33FF33"
	elseif self.pepelog.pepe[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[PEPE]"
		self.color[i] = "#00CC00"
	elseif self.titlelog.lolicon[tostring(PlayerResource:GetSteamAccountID(i))] then 
		self.title[i] = "[LOLICON]"
		self.color[i] = "pink"
	else
		if PlayerTables:GetTableValue("database", "db", i) == true then 
			if iupoasldm.jyiowe[i].STT.mcs.tgn < 10 and iupoasldm.jyiowe[i].LD.ACD < 10 then 
				if yedped.MRN[i] >= 1200 then 
					self.title[i] = "[SMURF]"
					self.color[i] = "orange"
				else
					self.title[i] = "[NEWBIE]"
					self.color[i] = "#33FFFF"
				end
			else
				if iupoasldm.jyiowe[i].IFY.PM == -10 then 
					self.title[i] = "[BAN]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PM == -3 then 
					self.title[i] = "[RAGE QUITER]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PM == -2 then 
					self.title[i] = "[TOXIC]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PM == -1 then 
					self.title[i] = "[AFK]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PM == -4 then 
					self.title[i] = "[TROLL]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PM == -5 then 
					self.title[i] = "[DOG]"
					self.color[i] = "red"
				elseif iupoasldm.jyiowe[i].IFY.PP == 110 then 
					self.title[i] = ""
					self.color[i] = "#33FFFF"
				else
					self.title[i] = ""
					self.color[i] = "white"
				end
			end
			PlayerTables:CreateTable("player_mark", {PM = iupoasldm.jyiowe[i].IFY.PM}, i)
		else
			self.title[i] = ""
			self.color[i] = "white"
		end
	end
	CustomNetTables:SetTableValue("parsy", "title", self.title)
	CustomNetTables:SetTableValue("parsy", "title_color", self.color)
	             
end

function DiscordC(index, data)
	local playerId = data.playerId
	local reward = 2000
	print('lua recieve discord data')
	--print(playerId)
	if PlayerTables:GetTableValue("database", "db", playerId) == true then 
		print('get discord joined reward')
		if iupoasldm.jyiowe[playerId].IFY.ISD == false then
			iupoasldm.jyiowe[playerId].IFY.ISD = true 
			Timers:CreateTimer(3.0, function()
				print('delay grant reward CP')
				iupoasldm.jyiowe[playerId].IFY.CRY.CP = iupoasldm.jyiowe[playerId].IFY.CRY.CP + reward
				local ply = PlayerResource:GetPlayer(playerId)
				iupoasldm:sendDiscord(playerId)
				PlayerTables:SetTableValue("CP", "CP", iupoasldm.jyiowe[playerId].IFY.CRY.CP, playerId, true)
				CustomGameEventManager:Send_ServerToPlayer(ply, "fate_player_cp", {CP=iupoasldm.jyiowe[playerId].IFY.CRY.CP})
				iupoasldm:FastUpdate(playerId) 
			end)
		end
	end
end

adskIPKB.INITED = adskIPKB.INITED or false
if not adskIPKB.INITED then
	print('player info start')
	adskIPKB:construct()
	adskIPKB.INITED = true
	if IsServer() then
	    ListenToGameEvent( "player_changename", Dynamic_Wrap( adskIPKB, "ipLhY" ), self )
	    ListenToGameEvent( "player_info", Dynamic_Wrap( adskIPKB, "iasdfpLhY" ), self )
	    CustomGameEventManager:RegisterListener( "player_discord_clicked", DiscordC )
	end
end

function lkjasdfio(i)
	local asdf = LoadKeyValues("scripts/npc/abilities/heroes/attribute.txt")
	ppf = LoadKeyValues("scripts/npc/pepe_fam.txt")

	if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) and PlayerTables:GetTableValue("authority", "alvl", i) == false then
		local authority_level = 0


		local player = PlayerResource:GetPlayer(i)
        for k,v in pairs (player) do
            print(k,v)
            if type(v) == "table" then
                for a,b in pairs (v) do 
                    print(k,a,b)
                    if type(b) == "table" then
                        for c,d in pairs (b) do
                            print(k,a,c,d)
                        end
                    end
                end
            end
        end

		if asdf[tostring(PlayerResource:GetSteamAccountID(i))] then 
			authority_level = asdf[tostring(PlayerResource:GetSteamAccountID(i))]
		end
		CheckingPePeFam(i)
		local player = ServerTables:GetTableValue("Players", "total_player")
		ServerTables:SetTableValue("Players", "total_player", player + 1, true)
		PlayerTables:CreateTable("connection", {cstate = "connect", dTime = 0, qRound = 1, data_sent = false}, i)
		PlayerTables:CreateTable("authority", {alvl = authority_level}, i)
		PlayerTables:CreateTable("steam", {id = tostring(PlayerResource:GetSteamAccountID(i))}, i)
		print('Player Authority ' .. authority_level)
		SendChatToPanorama('Player ' .. i .. ' Authority Level: ' .. authority_level)
		if authority_level == 5 then
			if IsPepelordPresence(i) == "pepe" then 
				PlayerTables:CreateTable("title", {dev = "pepe"}, i)
				ServerTables:SetTableValue("Dev", "pepe", true, true)
			elseif IsPepelordPresence(i) == "sss" then 
				PlayerTables:CreateTable("title", {dev = "sss"}, i)
				ServerTables:SetTableValue("Dev", "sss", true, true)
			else
				PlayerTables:CreateTable("title", {dev = "zef"}, i)
				ServerTables:SetTableValue("Dev", "zef", true, true)
			end
		elseif authority_level == 4 then 
			if tostring(PlayerResource:GetSteamAccountID(i)) == "39181514" then
				PlayerTables:CreateTable("title", {dev = "mod"}, i)
				ServerTables:SetTableValue("Dev", "mod", true, true)
			end
		end
	end
end

function IsPepelordPresence(i)
	if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
		if tostring(PlayerResource:GetSteamAccountID(i)) == "179419427" then
			return "pepe" 
		elseif tostring(PlayerResource:GetSteamAccountID(i)) == "301222766" then
			return "sss" 
		end
	end

	return false 
end

function CheckingPePeFam(i)
	if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
		if ppf.pepe[tostring(PlayerResource:GetSteamAccountID(i))] == 1 then
			print('pepe is here')
			PlayerTables:CreateTable("pepe", {pepe = "pepe"}, i)
			ServerTables:SetTableValue("PEPE", "pepe", true, true)
			local total_pepe = ServerTables:GetTableValue("PEPE", "total")
			ServerTables:SetTableValue("PEPE", "total", total_pepe + 1, true)
			return 
		elseif ppf["pepe_savior"][tostring(PlayerResource:GetSteamAccountID(i))] == 1 then
			print('pepe savior is here')
			PlayerTables:CreateTable("pepe", {pepe = "pepe_savior"}, i)
			ServerTables:SetTableValue("PEPE", "savior", true, true)
			return 
		elseif ppf["pepe_savior"][tostring(PlayerResource:GetSteamAccountID(i))] == 1 then
			print('pepe slayer is here')
			PlayerTables:CreateTable("pepe", {pepe = "pepe_slayer"}, i)
			ServerTables:SetTableValue("PEPE", "slayer", true, true)
			return
		else
			PlayerTables:CreateTable("pepe", {pepe = "not_pepe"}, i)
			return
		end
	end
end
