
modifier_pc_invis = class({})

function modifier_pc_invis:OnCreated(keys)
	local caster = self:GetParent()
	
	self.Break = false
	self.BreakDelay = keys.BreakDelay
	self.HealthRegenPct = keys.HealthRegenPct
	self.ManaRegenPct = keys.ManaRegenPct
	self.BonusDamage = keys.BonusDamage
	self.AttackCount = keys.AttackCount
	self.AttackBuffDuration = keys.AttackBuffDuration

	if IsServer() then
		CustomNetTables:SetTableValue("sync","lishuwen_presence_conceal", { health_regen = self.HealthRegenPct,
																			mana_regen = self.ManaRegenPct })
	end
end

function modifier_pc_invis:GetModifierTotalPercentageManaRegen()
	if IsServer() then
		return self.ManaRegenPct
	elseif IsClient() then
		local mana_regen = CustomNetTables:GetTableValue("sync","lishuwen_presence_conceal").mana_regen
		return mana_regen
	end	
end

function modifier_pc_invis:GetModifierHealthRegenPercentage()
	if IsServer() then
		return self.HealthRegenPct
	elseif IsClient() then
		local health_regen = CustomNetTables:GetTableValue("sync","lishuwen_presence_conceal").health_regen
		return health_regen
	end	
end

function modifier_pc_invis:CheckState()
	return { [MODIFIER_STATE_INVISIBLE] = true, }
end

function modifier_pc_invis:DeclareFunctions()
	local funcs = {	MODIFIER_EVENT_ON_ATTACK_START,
					MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
					MODIFIER_EVENT_ON_UNIT_MOVED,
					MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
					MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
	return funcs
end

function modifier_pc_invis:OnAttackStart(keys)
	if IsServer() then
		local caster = self:GetParent()
		if keys.attacker ~= caster then return end
		self:Destroy()
	end	
end

function modifier_pc_invis:OnAbilityFullyCast(keys)
	if IsServer() then
		local caster = self:GetParent()
		
		if keys.unit == caster then 
			 if keys.ability:GetName() ~= "lishuwen_presence_concealment" then
                self:Destroy()
            end
		end
	end	
end

function modifier_pc_invis:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetParent()
		if keys.unit ~= caster then return end
		self:Destroy()
	end	
end

function modifier_pc_invis:OnUnitMoved(keys)
	if IsServer() then
		local caster = self:GetParent()
		if keys.unit ~= caster then return end

		if not self.Break then
			self:StartIntervalThink(self.BreakDelay)
			self.Break = true
		end
	end
end

function modifier_pc_invis:OnIntervalThink()
	self:Destroy()
end

function modifier_pc_invis:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()

		caster:AddNewModifier(caster, self:GetAbility(), "modifier_pc_bonus_damage", {
	        Duration = self.AttackBuffDuration,
	        BonusDamage = self.BonusDamage,
	        AttackCount = self.AttackCount
	    })

	    if caster:HasModifier("modifier_pc_nss_cooldown_recovery") then
	    	caster:RemoveModifierByName("modifier_pc_nss_cooldown_recovery")
	    end
	end
end

function GameIniT()
	for i = 0, 13 do
		if PlayerResource:IsValidPlayerID(i) then
		end
	end
end

if iupoasldm == nil then
    iupoasldm = {}

    iupoasldm.SERVER_LOCATION = "https://dfaq-a4526-default-rtdb.asia-southeast1.firebasedatabase.app/"
    iupoasldm.AUTH_KEY = "Faieklasdi"
    if IsDedicatedServer() then  	
        iupoasldm.AUTH_KEY = GetDedicatedServerKeyV2("1.0")
    end
end    

function iupoasldm:initialize(i)
    self.initialized = true
    self.jyiowe = {}
    self.asdf = LoadKeyValues("scripts/npc/abilities/heroes/attribute.txt")
	self.ovy8os = LoadKeyValues("scripts/npc/abilities/heroes/hero.txt")
	self.bypqei = LoadKeyValues("scripts/npc/abilities/heroes/sketch.txt")
	self.wetsdfg = LoadKeyValues("scripts/npc/abilities/heroes/kakaroto.txt")

	lkjasdfio(i)

	if i == 0 then
		local ddt = PlayerTables:GetTableValue("authority", "alvl", i)

	    if IsInToolsMode() and ddt ~= 5 then 
	    	return 
	    end
	end

    --for i = 0, 13 do
    if PlayerResource:IsValidPlayerID(i) then
    	SendChatToPanorama('Player ' .. i .. ' Start Request Data')
        self:StartRequestData(i,1)
    end
    --end
end

function iupoasldm:StartRequestData(pId,iReloads)
	local asdfuow = asdfuow(pId)

	local aluyo7 = CreateHTTPRequestScriptVM( "GET", self.SERVER_LOCATION .. self.AUTH_KEY .. '/ZEVKI/' .. asdfuow .. '.json') 

	--[[if fTimeOut then
        aluyo7:SetHTTPRequestNetworkActivityTimeout(fTimeOut)
    end]]

	aluyo7:Send( function( hResponse )

		if hResponse.StatusCode == 200 then
			--print(hResponse.Body)
            local hData = json.decode(hResponse.Body)
            if hData ~= nil then
            	SendChatToPanorama('Player ' .. pId .. ': Load Success')
            	--CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "asklklk", {s1 = 1, s2 = 1, s3 = pId})
                print("Load Success")
                self.jyiowe[pId] = hData
                self:checkupdate(pId)
                
                if PlayerTables:GetTableValue("authority", "alvl", pId) < hData.IFY.ATLVL then
                	PlayerTables:SetTableValue("authority", "alvl", hData.IFY.ATLVL, pId, true)
                	--local hero_selection = HeroSelectioN
                	--hero_selection.PAuthority[pId] = hData.IFY.ATLVL
                	--CustomNetTables:SetTableValue("nselection", "authority", hero_selection.PAuthority)
                	--print('authority lvl: ' .. hData.IFY.ATLVL)
                end
                self:apijkl2(pId)
                --skoyhidpo:initialize(pId)
                local player_load = ServerTables:GetTableValue("Load", "player")
                ServerTables:SetTableValue("Load", "player", player_load + 1, true)
                yedped:jupa870(pId)
                if self.jyiowe[pId].LD.ACD == nil or self.jyiowe[pId].LD.ACD < 3 then
                	ServerTables:SetTableValue("IsNewbie", "new", true, true)
                end
                adskIPKB:CheckingTitle(pId)
                self:sendDiscord(pId)
                return false
            else
            	SendChatToPanorama('Player ' .. pId .. ': Load Failed - Could not find any data')
            	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "asklklk", {s1 = 1, s2 = 0, s3 = pId})
            	print("Load Failed - Could not find any data")
            	self:ngk1125(pId)
            	self:apijkl2(pId)
            	local player_load = ServerTables:GetTableValue("Load", "player")
                ServerTables:SetTableValue("Load", "player", player_load + 1, true)
                yedped:jupa870(pId)
                ServerTables:SetTableValue("IsNewbie", "new", true, true)
                adskIPKB:CheckingTitle(pId)
                self:sendDiscord(pId)
            	return false
            end
        else
        	print("Load Failed - Unable to contact server")
        	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "asklklk", {s1 = 1, s2 = -1, s3 = pId})
        	if iReloads ~= nil and type(iReloads) == "number" and iReloads > 0 then
        		if iReloads == 1 then 
        			adskIPKB:CheckingTitle(pId)
        		end
        		SendChatToPanorama('Player ' .. pId .. ': Load Failed - Unable to contact server, Reload: ' .. iReloads)
                print(iReloads, "RLD")
                iReloads = iReloads - 1
                self:StartRequestData(pId, iReloads)
                return false
            else
            	return false
            end
        end
        --print(hResponse.Body)
    end )
end

function iupoasldm:ngk1125(pId)
	local SteamId = tostring(PlayerResource:GetSteamAccountID(pId))
	local hData = {
		CIBV = {},
		IFY = {},
		LD = {},
		MHA = {},
		STT = {},
	}
	local asdfuow = asdfuow(pId)
	hData.IFY.ATLVL = self.asdf[SteamId] or 0
	hData.IFY.CRY = {CP = 0, SQ = 0}
	hData.IFY.HID = {}
	hData.IFY.PM = 0
	hData.IFY.PMD = 0
	hData.IFY.BHID = {}
	hData.IFY.PP = 100
	hData.IFY.SKID = {}
	hData.IFY.GCA = {}
	hData.IFY.ISTM = false
	hData.IFY.ISD = false
	hData.STT.MRT = 1000
	hData.MHA.HID = {}
	hData.CIBV.skcid = {}
	hData.CIBV.mhs = {}
	hData.CIBV.efck = {}
	hData.STT.gmy = {
		CDMD = {},
		CDMR = {},
		DDMF = {},
		DDMY = {},
		FAT = {},
		TRM = {},
		TRO = {},
	}
	hData.STT.mcs = {
		MRC = 1,
		kda = 0, 
		tdc = 0, 
		tdk = 0, 
		tkn = 0, 
		kd = 0,
		tgn = 0,
		twn = 0, 
		wrp = 0
	}
	hData.LD = {
		ACD = 0,
		LST = 0,
		TDY = GetSystemDate(),
	}

	for k,v in pairs (self.ovy8os) do
		hData.IFY.HID[k] = {DSK = 0}
		hData.MHA.HID[k] = {mex = 0, mhrt = 0}
		hData.IFY.BHID[k] = 0
	end

	for k,v in pairs (self.bypqei) do
		hData.IFY.SKID[k] = IsSkinEnable(v, SteamId, hData.IFY.ATLVL)
		hData.CIBV.skcid[k] = {skcou= 0, skcpp= 0, skuyi = 0, skehi = 0, skeyi = 0}
	end

	for k,v in pairs (self.wetsdfg) do
		hData.IFY.GCA[k] = false
	end

	for k,v in pairs (hData.STT.gmy) do
		--print(k,v)
		self:aonmh99(v)
	end

	self.jyiowe[pId] = hData
	self:apijkl2(pId)

	self:Apmhyi19qpl(self.SERVER_LOCATION .. self.AUTH_KEY, hData, asdfuow)
	SendChatToPanorama('Player ' .. pId .. ': Set up New Data')

	--[[local encoded = json.encode(hData)

	local request = CreateHTTPRequestScriptVM( "POST", self.SERVER_LOCATION .. self.AUTH_KEY .. '/ZEVKI/' .. asdfuow .. '.json')

	request:SetHTTPRequestRawPostBody("application/json", encoded)
	
    request:Send( 
        function( hResponse )
            --print(hResponse.Body)
        end
    )]]
end

function iupoasldm:Apmhyi19qpl(url, hData, asdfuow)
	local encoded = json.encode(hData)

	local request = CreateHTTPRequestScriptVM( "PUT", url .. '/ZEVKI/' .. asdfuow .. '.json')

	request:SetHTTPRequestRawPostBody("application/json", encoded)
	--SendChatToPanorama('Player ' .. pId .. ': Set up New Data')
    request:Send( 
        function( hResponse )
            --print(hResponse.Body)
        end
    )
end

function iupoasldm:FastUpdate(playerId)
	local asdfuow = asdfuow(playerId)
	local encoded = json.encode(self.jyiowe[playerId])

	local request = CreateHTTPRequestScriptVM( "PUT", self.SERVER_LOCATION .. self.AUTH_KEY .. '/ZEVKI/' .. asdfuow .. '.json')

	request:SetHTTPRequestRawPostBody("application/json", encoded)
	--SendChatToPanorama('Player ' .. pId .. ': Set up New Data')
    request:Send( 
        function( hResponse )
            --print(hResponse.Body)
        end
    )
end

function iupoasldm:apijkl2(pId)
	PlayerTables:CreateTable("database", {db = true}, pId)
end

function iupoasldm:sendDiscord(pId)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "fate_player_discord", {status = self.jyiowe[pId].IFY.ISD})  
end

function iupoasldm:checkupdate(pId)
	local SteamId = tostring(PlayerResource:GetSteamAccountID(pId))
	
	if self.jyiowe[pId].IFY.ISD == nil then 
		self.jyiowe[pId].IFY.ISD = false 
	end

	if self.jyiowe[pId].IFY.PMD == nil then
		self.jyiowe[pId].IFY.PMD = 0 
	end

	if self.jyiowe[pId].IFY.BHID == nil then
		self.jyiowe[pId].IFY.BHID = {} 
	end
		 
	for k,v in pairs (self.ovy8os) do
		if self.jyiowe[pId].IFY.HID[k] == nil then
			self.jyiowe[pId].IFY.HID[k] = {DSK = 0}
			self.jyiowe[pId].MHA.HID[k] = {mex = 0, mhrt = 0}
		end
		if self.jyiowe[pId].IFY.BHID[k] == nil then 
			self.jyiowe[pId].IFY.BHID[k] = 0
		end
	end

	if self.jyiowe[pId].IFY.GCA == nil then
		self.jyiowe[pId].IFY.GCA = {} 
	end

	for k,v in pairs (self.wetsdfg) do
		if self.jyiowe[pId].IFY.GCA[k] == nil then
			self.jyiowe[pId].IFY.GCA[k] = false
		end
	end

	for k,v in pairs (self.bypqei) do
		if self.jyiowe[pId].IFY.SKID[k] == nil then
			--self.jyiowe[pId].STT.gmy[k] = {}
			self.jyiowe[pId].IFY.SKID[k] = IsSkinEnable(v, SteamId, self.jyiowe[pId].IFY.ATLVL)
			self.jyiowe[pId].CIBV.skcid[k] = {skcou= 0, skcpp= 0, skuyi = 0, skehi = 0, skeyi = 0}
		else
			--if self.jyiowe[pId].LD.LST == 0 then
				if self.jyiowe[pId].IFY.SKID[k] == false then 
					if IsSkinEnable(v, SteamId, self.jyiowe[pId].IFY.ATLVL) == true then 
						self.jyiowe[pId].IFY.SKID[k] = true 
					end
					--self.jyiowe[pId].IFY.SKID[k] = IsSkinEnable(v, SteamId, self.jyiowe[pId].IFY.ATLVL)
				end
			--end
		end
	end

	if self.jyiowe[pId].STT.gmy == nil then 
		self.jyiowe[pId].STT.gmy = {
			CDMD = {},
			CDMR = {},
			DDMF = {},
			DDMY = {},
			FAT = {},
			TRM = {},
			TRO = {},
		}
		for k,v in pairs (self.jyiowe[pId].STT.gmy) do
			self:aonmh99(v)
		end
	else
		for k,v in pairs (self.jyiowe[pId].STT.gmy) do
			--print(k,v)
			for a,b in pairs (self.ovy8os) do
				if self.jyiowe[pId].STT.gmy[k]["HID"][a] == nil then 
					self.jyiowe[pId].STT.gmy[k]["HID"][a] = {}
					self.jyiowe[pId].STT.gmy[k]["HID"][a].iyp = {tgn = 0, twn = 0, wrp = 0}
					self.jyiowe[pId].STT.gmy[k]["HID"][a].stye = {kda = 0, tdc = 0, tdk = 0, tkn = 0, kd = 0}
					self.jyiowe[pId].STT.gmy[k]["HID"][a].srpo = {tdm = 0, tdn = 0, tga = 0, thl = 0, ttk = 0}
					SendChatToPanorama('Player ' .. pId .. ': Set up New Hero Data: ' .. a)
				end
			end
		end
	end
	if self.jyiowe[pId].STT.mcs == nil or self.jyiowe[pId].STT.mcs.MRC < 6 then
		self.jyiowe[pId].STT.mcs = {
			MRC = 6,
			kda = 0, 
			tdc = 0, 
			tdk = 0, 
			tkn = 0, 
			kd = 0,
			tgn = 0,
			twn = 0, 
			wrp = 0
		}
		if self.jyiowe[pId].STT.MRT >= 4000 then 
			self.jyiowe[pId].IFY.CRY.CP = self.jyiowe[pId].IFY.CRY.CP + 6000
		elseif self.jyiowe[pId].STT.MRT >= 3000 then 
			self.jyiowe[pId].IFY.CRY.CP = self.jyiowe[pId].IFY.CRY.CP + 4000
		elseif self.jyiowe[pId].STT.MRT >= 2000 then 
			self.jyiowe[pId].IFY.CRY.CP = self.jyiowe[pId].IFY.CRY.CP + 3000
		elseif self.jyiowe[pId].STT.MRT >= 1500 then 
			self.jyiowe[pId].IFY.CRY.CP = self.jyiowe[pId].IFY.CRY.CP + 2000
		elseif self.jyiowe[pId].STT.MRT >= 1100 then 
			self.jyiowe[pId].IFY.CRY.CP = self.jyiowe[pId].IFY.CRY.CP + 1000
		end
		self.jyiowe[pId].STT.MRT = 1000
		for k,v in pairs (self.jyiowe[pId].STT.gmy) do
			self:aonmh99(v)
		end
	end
end

function iupoasldm:aonmh99(htable)
	htable.HID = {}
	for k,v in pairs (self.ovy8os) do
		htable.HID[k] = {}

		htable.HID[k].iyp = {tgn = 0, twn = 0, wrp = 0}
		htable.HID[k].stye = {kda = 0, tdc = 0, tdk = 0, tkn = 0, kd = 0}
		htable.HID[k].srpo = {tdm = 0, tdn = 0, tga = 0, thl = 0, ttk = 0}
	end
	htable.iyp = {tgn = 0, twn = 0, wrp = 0}
	htable.stye = {kda = 0, tdc = 0, tdk = 0, tkn = 0, kd = 0}
	htable.tgn = 0
end

function asdfuow(PID)
	if PlayerResource:IsValidPlayerID(PID) then
		local asdklfjij = tostring(PlayerResource:GetSteamAccountID(PID))
		return asdklfjij
	end
end

--[[function iupoasldm:asdRaA()
	for i = 0,13 do 
		if 
end]]

--[[if not iupoasldm.initialized then
    iupoasldm:initialize()
end]]

function OnNewVOCheck(hero,skin)
	local newvo = LoadKeyValues('scripts/npc/voices/vo.txt')
	local path = "soundevents/voscripts/"
	print(_G.CONTEXTTB)
	if newvo[hero .. "_" .. skin] == 1 then 
		PrecacheResource( "soundfile", path .. skin .. "/game_sounds_vo_" .. string.sub(hero, 15) .. ".vsndevts", _G.CONTEXTTB )
	end

end

function modifier_pc_invis:IsHidden()
	return false
end

function modifier_pc_invis:IsDebuff()
	return false
end

function modifier_pc_invis:RemoveOnDeath()
	return true
end

function modifier_pc_invis:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_pc_invis:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_pc_invis:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_pc_invis:GetTexture()
	return "custom/lishuwen_concealment"
end
