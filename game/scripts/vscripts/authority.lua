
if AuthorityModule == nil then 
    print("[Authority] Checking")
    AuthorityModule = {}
    _G.AuthorityModule = AuthorityModule
end
-- Current Dev Level
AuthorityModule.Level_5 = {
	["96116520"] = true,
	["291133156"] = true,
}

-- VIP Level: Old Dev need to be respected
AuthorityModule.Level_4 = {
	["322802270"] = true,
	["46946755"] = true,
	["41473395"] = true,
	["68982413"] = true,
	["83624577"] = true,
	["89167938"] = true,
    ["181266012"] = true, --Goeniko
}

-- Contributor Level
AuthorityModule.Level_3 = {
	["133583351"] = true, -- Onichi
	["44960119"] = true, -- gish
	["49297047"] = true, -- classicstar
	["127185614"] = true, -- บาส
	["174925529"] = true, -- ไอซ์
	["16184560"] = true, -- บูม
    ["120380006"] = true, --เบ้น
	["104669537"] = true, -- ryudo 
    ["217324153"] = true, --hentai
    ["194317463"] = true, -- yo
    ["49020355"] = true, --เกรซ
    ["75996662"] = true, --กอริล่า
    ["344242723"] = true, --แอสซาซิน
    ["179419427"] = true, --เนิด
    ["177310581"] = true, --joka
    ["257341283"] = true, --ฮาฮา
    ["992561617"] = true, --ฟิว
    ["838298693"] = true, --ไนท์
    ["61236324"] = true, --ไททัน
    ["90958414"] = true, --SoSoon
    ["64400324"] = true, --เทอเรอเดด
    ["157413679"] = true, --wonder
    ["180712875"] = true, --ฃินา
    ["39181514"] = true, --NISE
    ["102126937"] = true, --Azusa
}

-- Balancer Level
AuthorityModule.Level_2 = {
	["120166692"] = true, --Comrade
}

-- Tester Level
AuthorityModule.Level_1 = {
	["107078405"] = true,
	["204067816"] = true, -- ko gil
	["267558196"] = true, -- WUW
	["48836072"] = true, -- waifustealer	
    ["108882970"] = true, --สิงโต
    ["130557974"] = true, --หมา   
    ["919069943"] = true, --sana 
    ["326573316"] = true, --pezlug 
    ["125680288"] = true, --SNG
    ["171622143"] = true, --mafu 
    ["86549529"] = true, --spring 
    ["118158970"] = true, --Akuma 
    ["185970099"] = true, --โตโต้
    ["937095899"] = true, --Ab 
    ["468551536"] = true, --Bao
    ["139107182"] = true, --terralio
    ["384211538"] = true, --จิน
    ["25975666"] = true, --พริก
    ["82282908"] = true, --โรส
    ["52459602"] = true, --ราคุ
    ["124506060"] = true, --เรมิ
    ["165925598"] = true, --เดด
    ["87002377"] = true, --วิน
    ["767728007"] = true, --Fannie
    ["44125501"] = true, --LKC
    ["950132982"] = true, --LLLLL
    ["110348871"] = true, --memo
    ["170614282"] = true, --Yang
    ["311532152"] = true, --Zlodemon
    ["105182094"] = true, --Fate
    ["195154539"] = true, --SilverTribe
    ["377123230"] = true, --Pettanko
    ["349888297"] = true, --Xer[s]
    ["33382559"] = true, --Matz
    ["118522455"] = true, --Megumin
    ["79388689"] = true, --Glacial
    ["118791339"] = true, --Snejik
    ["178793406"] = true, --Sol
    ["38790020"] = true, --Mystes
    ["56962601"] = true, --藤原佐為
    ["249550101"] = true, --kyonko
    ["65177003"] = true, --Brssiu
    ["126863914"] = true, --Yui_sys
    ["178103625"] = true, --TOMARUN
    ["148557108"] = true, --Vocal
    ["104987959"] = true, --Irisviel
    ["149487114"] = true, --โอ
    ["143558058"] = true, --Nayu69
    ["126804327"] = true, --Poptunic
    ["156600361"] = true, --cherrim
    ["318259387"] = true, --点炮狂魔女巫
    ["301222766"] = true, --Seraph of Darkness
    ["102137809"] = true, --Kazkura
    ["80118133"] = true, --Shirakiin
    ["1001092376"] = true, --นมหวาน
    ["850429391"] = true, --Astolfo
    ["112100065"] = true, --洋葱骑士
    ["180602314"] = true, --QQQQQQQQ
    ["111781221"] = true, --宮廷玉液酒
    ["129880666"] = true, --彼方
    ["138531650"] = true, --我今晚能来你家吗？
    ["127364122"] = true, --Nigma
    ["217742414"] = true, --DapaAsli
    ["386948250"] = true, --Dhika
    ["863517475"] = true, --Matthew K
    ["1150987769"] = true, --Mordred
    ["221409615"] = true, --Dieter
    ["149483321"] = true, --I do not see my victory
    ["384915121"] = true, --Ezral
    ["179335389"] = true, --Vergil
    ["136265310"] = true, --Black Magician Girl
    ["200974450"] = true, --CaptGuardian
    ["155068590"] = true, --Ruri
    ["190378247"] = true, --Maple Pears
    ["92851019"] = true, --CEASAFA
}

function AuthorityModule:CheckAuthority(args)
	local entIndex = args.index
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex+1)
	local userID = args.userid
    local player = PlayerResource:GetPlayer(entIndex)
	--if PlayerResource:GetSteamAccountID(entIndex) ~= nil then 
		if AuthorityModule.Level_5[tostring(PlayerResource:GetSteamAccountID(entIndex))] then
            player.authority_level = 5 
            return
        elseif AuthorityModule.Level_4[tostring(PlayerResource:GetSteamAccountID(entIndex))] then
            player.authority_level = 4 
            return
        elseif AuthorityModule.Level_3[tostring(PlayerResource:GetSteamAccountID(entIndex))] then
            player.authority_level = 3 
            return
        elseif AuthorityModule.Level_2[tostring(PlayerResource:GetSteamAccountID(entIndex))] then
            player.authority_level = 2 
            return
        elseif AuthorityModule.Level_1[tostring(PlayerResource:GetSteamAccountID(entIndex))] then
            player.authority_level = 1 
            return
        else
        	player.authority_level = 0
            return
        end
    --else
    	--player.authority_level = nil
    --end
    --print("Authority Level: " .. player.authority_level)
end



function AuthorityModule:OnCommand(keys)
	if keys == nil then print("empty keys") end
    -- Get the player entity for the user speaking
    local text = keys.text
    --SendChatToPanorama(text)
    local userID = keys.userid
    local localUserID = GameRules.AddonTemplate.vUserIds[userID]
    if not localUserID then return end
    local plyID = localUserID:GetPlayerID()

    local ply = PlayerResource:GetPlayer(plyID)
    if not ply then return end
    local hero = ply:GetAssignedHero()

    --[[local pID, MutedTime = string.match(text, "^-mutedworld (%d%d?) (%d+)")
    if MutedTime == nil then 
    	MutedTime = 9999
    end

    if pID ~= nil then
    	if ply.authority_level == 5 and (ply.authority_level > PlayerResource:GetPlayer(pID).authority_level or PlayerResource:GetPlayer(pID).authority_level == nil) then 
    		-- send mute to panorama
    	end
    end

    local debugtext = string.match(text, "^-debugskills (%d%d?)")
    if debugtext ~= nil then
    	if ply.authority_level >= 1 and ply.authority_level ~= nil then 
    		GetHeroInfo(player:GetAssignedHero())
    	end
    end]]

    local plyidd, alterna = string.match(text, "^-alternate(%d%d?) (%d+)")
    if plyidd ~= nil and alterna ~= nil then
        if ply.authority_level == 5 then 
            local serv = PlayerResource:GetPlayer(tonumber(plyidd)):GetAssignedHero()
            if serv:HasModifier("modifier_alternate_0" .. tonumber(alterna)) then 
                serv:RemoveAbility("alternative_0" .. tonumber(alterna))
            else
                serv:AddAbility("alternative_0" .. tonumber(alterna))
                serv:FindAbilityByName("alternative_0" .. tonumber(alterna)):SetLevel(1)
            end
        end
    end

    local rround = string.match(text, "restart_round")
    if rround ~= nil then 
        if ply.authority_level == 5 then 
            GameRules.AddonTemplate:FinishRound(true, 2)
        end
    end
end

AuthorityModule.INITED = AuthorityModule.INITED or false
if not AuthorityModule.INITED then
    print('authority init')
    --ListenToGameEvent( "player_chat", Dynamic_Wrap( AuthorityModule, "OnCommand" ), AuthorityModule )
    AuthorityModule.INITED = true
end


