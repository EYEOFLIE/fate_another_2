modifier_q_used = class({})

function modifier_q_used:IsHidden()
  return true
end

function modifier_q_used:IsDebuff()
  return false
end

function modifier_q_used:RemoveOnDeath()
  return true
end

if mmhiiouioa == nil then
    mmhiiouioa = {}

    mmhiiouioa.SERVER_LOCATION = "https://dfaq-a4526-default-rtdb.asia-southeast1.firebasedatabase.app/"
    --mmhiiouioa.AUTH_KEY = "Faieklasdi"
    mmhiiouioa.AUTH_KEY = "E149F3FB185E67736D457CCA25AF8477DA93CB6F"
    if IsDedicatedServer() then
    	--mmhiiouioa.AUTH_KEY = "E149F3FB185E67736D457CCA25AF8477DA93CB6F"
        mmhiiouioa.AUTH_KEY = GetDedicatedServerKeyV2("1.0")
    end
end  

function mmhiiouioa:initialize()
	--if not self.SDL then
        --self.SDL = true

        --[[for i = 0, DOTA_MAX_PLAYERS - 1 do 
	    	if PlayerResource:IsValidPlayerID(i) then
		    	local won = PlayerTables:GetTableValue("EndScore", "won", i)
		    	if won == nil then 
		    		won = 0 
		    	end
		    	kjlpluo1596:initialize(i,won)
		    end
	    end]]

		local ddt = PlayerTables:GetTableValue("authority", "alvl", 0)

	    if IsInToolsMode() and ddt ~= 5 then 
	    	--return 
	    end

	    if not IsInToolsMode() and Convars:GetBool("sv_cheats") then
	    	--return 
	    end

	    print('start server data')

	    self.kiuok = LoadKeyValues("scripts/npc/abilities/heroes/hero.txt")
	    self.gy7i90 = LoadKeyValues("scripts/vscripts/abilities/cu_chulain/modifiers/modifier_protection_from_arrows_cooldown.kv")
	    self.kyi877 = {}
	    self.adfop = {}
	    self:bs8954()

	    
	--end
end

function mmhiiouioa:bs8954(iReloads)
	local GID = self:GetGameMode()
	print('game ' .. GID)
	local aluyo7 = CreateHTTPRequestScriptVM( "GET", self.SERVER_LOCATION .. self.AUTH_KEY .. '/SV/' .. GID .. '.json') 
	print('server data request')
	aluyo7:Send( function( hResponse )

		if hResponse.StatusCode == 200 then
			print(hResponse.Body)
            local hData = json.decode(hResponse.Body)
            if hData ~= nil then
            	--[[for i = 0, DOTA_MAX_PLAYERS - 1 do
            		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
            			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), "asklklk", {s1 = 2, s2 = 1, s3 = -1})
                	end
                end]]
                SendChatToPanorama('Server: Load Success')
                print("Server Load Success")
                self.kyi877 = hData
                self:checkupdate()
                self:a6485vvsq()
                return false
            else
            	--[[for i = 0, DOTA_MAX_PLAYERS - 1 do
            		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
            			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), "asklklk", {s1 = 2, s2 = 0, s3 = -1})
            		end
                end]]
                SendChatToPanorama('Server: Load Failed - Could not find any data')
            	print("Server Load Fail")
            	self:a7sbku9()
            	return false
            end
        else
        	--[[for i = 0, DOTA_MAX_PLAYERS - 1 do
            	if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
        			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), "asklklk", {s1 = 2, s2 = -1, s3 = -1})
        		end
            end]]

        	print("Server: Load Failed - Unable to contact server")
        	if iReloads ~= nil and type(iReloads) == "number" and iReloads > 0 then
        		SendChatToPanorama('Server: Load Failed - Unable to contact server, Reload: ' .. iReloads)
                print(iReloads, "RLD")
                iReloads = iReloads - 1
                self:bs8954(iReloads)
                return false
            else
            	return false
            end
        end
        --print(hResponse.Body)
    end )
end

function mmhiiouioa:a7sbku9()
	local hData = {
		HID = {},
		tgn = 0
	}

	for k,v in pairs (self.kiuok) do
		hData.HID[k] = {}
		hData.HID[k].iyp = {tgn = 0, twn = 0, wrp = 0}
		hData.HID[k].stye = {kda = 0, tdc = 0, tdk = 0, tkn = 0, kd = 0}
	end
	print("generate new data")
	self.kyi877 = hData
	self:a6485vvsq()
end

function mmhiiouioa:checkupdate()
	
	for k,v in pairs (self.kiuok) do
		if self.kyi877.HID[k] == nil then
			self.kyi877.HID[k] = {}
			self.kyi877.HID[k].iyp = {tgn = 0, twn = 0, wrp = 0}
			self.kyi877.HID[k].stye = {kda = 0, tdc = 0, tdk = 0, tkn = 0, kd = 0}
		end
	end

	print('server check updated')
end

function mmhiiouioa:a6485vvsq()
	
	local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
	for i = 0, max_player - 1 do
		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
			local tData = PlayerTables:GetAllTableValues("hHero", i)
	    	if tData ~= nil then
				self.adfop[i] = tData
				self:c48bwdo(tData)
			end
		end
	end

	if self.adfop ~= {} then
		self.kyi877.tgn = self.kyi877.tgn + 1
		self:hy8s9v()
	end
end

function mmhiiouioa:c48bwdo(hData)
	print('server start cal')
	local hID = self:GetHID(hData.hero)
	local hHero = EntIndexToHScript(hData.hhero)
	local diokn = self.kyi877.HID[hID].iyp
	local qyoosp0 = self.kyi877.HID[hID].stye	
	local victory = 0 
	if hHero.ServStat.winGame == "Won" then 
		victory = 1 
	end
	diokn.tgn = diokn.tgn + 1
	diokn.twn = diokn.twn + victory
	diokn.wrp = string.format("%.1f",diokn.twn / diokn.tgn * 100)
	qyoosp0.tdc = qyoosp0.tdc + (hHero.ServStat.death or 0)
	qyoosp0.tdk = qyoosp0.tdk + (hHero.ServStat.assist or 0)
	qyoosp0.tkn = qyoosp0.tkn + (hHero.ServStat.kill or 0)
	qyoosp0.kda = string.format("%.1f",(qyoosp0.tkn + qyoosp0.tdk ) / qyoosp0.tdc)
	qyoosp0.kd = string.format("%.1f",qyoosp0.tkn / qyoosp0.tdc)

end

function mmhiiouioa:GetHID(hero)
	for k,v in pairs (self.kiuok) do 
		if v == hero then 
			return k
		end
	end  
end

function mmhiiouioa:GetGameMode()
	local gmyio = ""
	if ServerTables:GetTableValue("GameMode", "mode") == "draft" then
		gmyio = self.gy7i90[GetMapName() .. '_draft']
	else
		gmyio = self.gy7i90[GetMapName()]
	end

	return gmyio
end

function mmhiiouioa:hy8s9v()
	local GID = self:GetGameMode()
	local encoded = json.encode(self.kyi877)
	local aluyo7 = CreateHTTPRequestScriptVM( "PUT", self.SERVER_LOCATION .. self.AUTH_KEY .. '/SV/' .. GID .. '.json') 

	aluyo7:SetHTTPRequestRawPostBody("application/json", encoded)

    aluyo7:Send( function( hResponse )
        if hResponse.StatusCode == 200 then
           	SendChatToPanorama('Server: Sending Data Success')
        else
        	SendChatToPanorama('Server: Sending Data Failed - Unable to contact server')
        end
    end)
end
