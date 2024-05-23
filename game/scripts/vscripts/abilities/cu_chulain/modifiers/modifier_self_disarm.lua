modifier_self_disarm = class({})

function modifier_self_disarm:CheckState()
	return { [MODIFIER_STATE_DISARMED] = true }
end

function modifier_self_disarm:IsHidden()
	return true
end

function modifier_self_disarm:RemoveOnDeath()
	return true
end

function modifier_self_disarm:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

skoyhidpo = skoyhidpo or class({})

function skoyhidpo:construct()
	--Timers:CreateTimer(2.0, function()
		self.kiuok = LoadKeyValues("scripts/npc/abilities/heroes/sketch.txt")
		self.spcio = LoadKeyValues("scripts/npc/skin_shop.txt")
		self.unavi = LoadKeyValues("scripts/npc/skin_unavailable.txt")
		self.pepelog = LoadKeyValues("scripts/npc/pepe_fam.txt")
		local unavai = self:check()
		--[[for k,v in pairs (unavai) do
			print(k,v)
		end]]
 
		CustomNetTables:SetTableValue("skinshops", "list", self.kiuok)
	    CustomNetTables:SetTableValue("skinshops", "cost", self.spcio)
	    CustomNetTables:SetTableValue("skinshops", "unavai", unavai)

	    self.SkinCPBuyListener = CustomGameEventManager:RegisterListener("skinshop_cpbuy", function(id, ...)
		    Dynamic_Wrap(self, "BuyCPSkin")(self, ...) 
		end)

		--print('regist skin shops data')
	--end)
end

function skoyhidpo:check()

	local today = tostring(GetSystemDate())
	local date = tonumber(string.sub(today, 4, -4))
	local skinunavai = {}

	for k,v in pairs(self.unavi) do 
		if string.match(k, "WK") then 
			--[[local event_start = tonumber(v.StartDate)
			local event_end = tonumber(v.EndDate)
			if date < event_start or date > event_end then 
				for id, name in pairs(v.AvaiSkin) do 
					skinunavai[id] = name
				end
			end]]
		else
			for id, name in pairs(v) do 
				skinunavai[id] = name
			end
		end
	end
	return skinunavai
end

function skoyhidpo:initialize(i)
	
	--local player_data = {}
	--if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
	--	if PlayerTables:GetTableValue("database", "db", i) == true and iupoasldm.jyiowe[i].IFY ~= nil then 

	PlayerTables:CreateTable("SkinShopData", iupoasldm.jyiowe[i].IFY.SKID, i)
	local player = PlayerResource:GetPlayer(i)
	--[[for sid,skin in pairs(kiuok) do 
		player_data[sid] = iupoasldm.jyiowe[i].IFY.SKID[sid]
	end]]
	local skin_data = PlayerTables:GetAllTableValues("SkinShopData", i)
	--CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_shop", skin_data)

	PlayerTables:CreateTable("CP", iupoasldm.jyiowe[i].IFY.CRY, i)
	local current_cp = PlayerTables:GetAllTableValues("CP", i)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_player_cp", current_cp)

	local skinown = {}
	local skinnotown = {}
	local pepeskin = {}
	local ispepe = false

	if self.pepelog["pepe_savior"][tostring(PlayerResource:GetSteamAccountID(i))] then 
		ispepe = true
	elseif self.pepelog.pepe[tostring(PlayerResource:GetSteamAccountID(i))] then 
		ispepe = true
	end

	for sid,skin in pairs(self.kiuok) do 
		if iupoasldm.jyiowe[i].IFY.SKID[sid] == true then 
			skinown[sid] = skin 
			--print("owned : " .. sid .. " = " .. skin)
		else
			skinnotown[sid] = skin 
			if self.unavi["Pepe"][sid] and ispepe == true then 
				print('pepe skin regist')
				pepeskin[sid] = skin
			end
			--print("not owned : " .. sid .. " = " .. skin)
		end
	end
	PlayerTables:CreateTable("SkinOwn", skinown, i)
	PlayerTables:CreateTable("SkinNotOwn", skinnotown, i)

	CustomGameEventManager:Send_ServerToPlayer(player, "fate_pepe_skin", pepeskin)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_own", skinown)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_not_own", skinnotown)
	iupoasldm:sendDiscord(i)
	print('send shop data to player' .. i)
end

function skoyhidpo:BuyCPSkin(args)
	local playerId = args.playerId
	local skinid = args.skinId
	local player = PlayerResource:GetPlayer(playerId)
	local skin = args.skin

	iupoasldm.jyiowe[playerId].IFY.SKID[skinid] = true 
	PlayerTables:SetTableValue("SkinShopData", skinid, true, playerId, true)
	local skin_data = PlayerTables:GetAllTableValues("SkinShopData", playerId)

	PlayerTables:SetTableValue("SkinOwn", skinid, skin, playerId, true)
	PlayerTables:DeleteTableKey("SkinNotOwn", skinid, playerId)

	iupoasldm.jyiowe[playerId].IFY.CRY.CP = iupoasldm.jyiowe[playerId].IFY.CRY.CP - self.spcio[skinid]
	PlayerTables:SetTableValue("CP", "CP", iupoasldm.jyiowe[playerId].IFY.CRY.CP, playerId, true)
	local current_cp = PlayerTables:GetAllTableValues("CP", playerId)
	local skinown = PlayerTables:GetAllTableValues("SkinOwn", playerId)
	local skinnotown = PlayerTables:GetAllTableValues("SkinNotOwn", playerId)

	--CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_shop", skin_data)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_player_cp", current_cp)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_own", skinown)
	CustomGameEventManager:Send_ServerToPlayer(player, "fate_skin_not_own", skinnotown)

	iupoasldm:FastUpdate(playerId)
end

if skoyhidpo.init == nil then 
	skoyhidpo.init = true
	skoyhidpo:construct()
end