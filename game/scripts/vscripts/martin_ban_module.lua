_G.MartinBanModule = MartinBanModule or {}

MartinBanModule.BANNED_LIST = {
    --["102004185"] = true,
	--["389762858"] = true,
	--["280372246"] = true,
	--["56005771"] = true,
	--["178388989"] = true,
    --["8383838383838"] = true
}

--^ There input friend id only

function MartinBanModule:OnHeroPick(args)
    local entity = EntIndexToHScript(args.heroindex)
    --DeepPrintTable(args)
    --print(PlayerResource:GetSteamAccountID(entity:GetPlayerID()))
    if entity and args.hero and entity:IsRealHero() then
        if MartinBanModule.BANNED_LIST[tostring(PlayerResource:GetSteamAccountID(entity:GetPlayerID()))] then
            print(args)
            entity:RemoveSelf()
        end
    end
end

MartinBanModule.INITED = MartinBanModule.INITED or false
if not MartinBanModule.INITED then
    ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( MartinBanModule, "OnHeroPick" ), MartinBanModule )
end