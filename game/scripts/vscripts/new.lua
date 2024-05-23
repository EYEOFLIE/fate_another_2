
if FateAnotherGameMode == nil then
    FateAnotherGameMode = class({})
end

function Precache(context)
	FateAnotherGameMode.PRECACHE_TIME_BEGIN = Time()
	FateAnotherGameMode:SelectionPrecache(context)
end

function Activate(value)
	print("ACTIVATE", value)
	FateAnotherGameMode:InitFateAnotherGameMode()
end

function FateAnotherGameMode:SelectionPrecache(context)

	print("Starting precache")

	----------------------- Items ---------------------------------------------
    PrecacheItemByNameSync("item_apply_modifiers", context)
    PrecacheItemByNameSync("item_mana_essence", context)
    PrecacheItemByNameSync("item_condensed_mana_essence", context)
    PrecacheItemByNameSync("item_teleport_scroll", context)
    PrecacheItemByNameSync("item_gem_of_speed", context)
    PrecacheItemByNameSync("item_scout_familiar", context)
    PrecacheItemByNameSync("item_berserk_scroll", context)
    PrecacheItemByNameSync("item_ward_familiar", context)
    PrecacheItemByNameSync("item_mass_teleport_scroll", context)
    PrecacheItemByNameSync("item_gem_of_resonance", context)
    PrecacheItemByNameSync("item_blink_scroll", context)
    PrecacheItemByNameSync("item_spirit_link" , context)
    PrecacheItemByNameSync("item_e_scroll", context)
    PrecacheItemByNameSync("item_d_scroll", context)
    PrecacheItemByNameSync("item_c_scroll", context)
    PrecacheItemByNameSync("item_b_scroll", context)
    PrecacheItemByNameSync("item_a_scroll", context)
    PrecacheItemByNameSync("item_a_plus_scroll", context)
    PrecacheItemByNameSync("item_s_scroll", context)
    PrecacheItemByNameSync("item_ex_scroll", context)
    PrecacheItemByNameSync("item_summon_skeleton_warrior", context)
    PrecacheItemByNameSync("item_summon_skeleton_archer", context)
    PrecacheItemByNameSync("item_summon_ancient_dragon", context)
    PrecacheItemByNameSync("item_all_seeing_orb", context)
    PrecacheItemByNameSync("item_shard_of_anti_magic", context)
    PrecacheItemByNameSync("item_shard_of_replenishment", context)
    PrecacheItemByNameSync("item_drake_onboard", context)
    PrecacheItemByNameSync("item_padoru_hat", context)

    --====================== Sound files ======================================--
               --======= General ========--
    PrecacheResource("soundfile", "soundevents/announcer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/misc_sound.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/event.vsndevts", context)

                        --======= BGM, Ally, Enemy ========--  
    PrecacheResource("soundfile", "soundevents/ally_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/enemy_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/bgm.vsndevts", context)


end

function FateAnotherGameMode:InitFateAnotherGameMode()
	print("Fate, Dota loaded, TIME SPENT FOR PRECACHES", Time() - self.PRECACHE_TIME_BEGIN)

	self.hFateSetting = {

							-- Core Info 
							nVictoryCondition = 12,
							nPreRoundDuration = 12, 
							nPostRoundDuration = 10,
							nRoundDuration = 120, 
							nPresenceAlertTime = 60,
							bGrailDrop = false,
							iTotalBan = 0,

							-- System Info 
							hGameState = "FATE_PRE_GAME",
							hGameMode = "CLASSIC", 
							bLapucelleActice = false,
							hEvent = false,
							iTotalPlayer = 0,
							iTotalLoad = 0,

							iRoundStartGold = 3000,
							iRoundGoldCap = 5000,

							iAssistGold = 300,

							iEXPperRound = 120,

							-- Round Info
							nRadiantScore = 0,
							nDireScore = 0,
							nCurrentRound = 0,
							
							-- Avarice 
							iMaxAvarice = 4,
							iBonusRoundGoldAvarice = 300,
							iBonusAvariceMana = 1, 
							iBonusMaxAvariceMana = 1, 
							iAvariceHP = 2,
							iBonusHPAvarice = 1,
							iAvariceRush = 3,
							iRushDurationAvarice = 15,

							--Propersity 
							iPropersityBonusEXP = 0.5,

							-- Blessing Info 
							iFirstBlessingPeriod = 300,
							iBlessingPeriod = 600,
							iBlessingRewardHP = 100,
							iBlessingRewardMana = 15,
							iShardDropPeriod = 300,

							-- Shop 
							fGoldCostOutBase = 0.5,

							-- Hero Info
							nMaxLevel = 24,
							iXPBounty = ,
							iGoldBounty = ,
							iXPBountyOverLVL = 0.1,

							-- Spawn Info 
							SPAWN_POSITION_RADIANT_DM = Vector(-5400, 762, 376),
							SPAWN_POSITION_DIRE_DM = Vector(7200, 4250, 755),
							SPAWN_POSITION_T1_TRIO = Vector(-796,7032,512),
							SPAWN_POSITION_T2_TRIO = Vector(5676,6800,512),
							SPAWN_POSITION_T3_TRIO = Vector(5780,2504,512),
							SPAWN_POSITION_T4_TRIO = Vector(-888,1748,512),
							SPAWN_POSITION_TRIO1 = Vector(-2492,4384,256),
							SPAWN_POSITION_TRIO2 = Vector(3201,4582,256),
							SPAWN_POSITION_TRIO3 = Vector(317,1220,384),

							-- Center Info 
							TRIO_RUMBLE_CENTER = Vector(2436,4132,1000),
							FFA_CENTER = Vector(368,3868,1000),
							CENTER = nil,

							-- Chat Info 
							fChatCommandCooldown = 15,


	}

	local hGameModeEntity = GameRules:GetGameModeEntity()

	hGameModeEntity:SetTopBarTeamValuesOverride( true )
	hGameModeEntity:SetTopBarTeamValuesVisible( true )
	hGameModeEntity:SetCustomBuybackCostEnabled( true )
    hGameModeEntity:SetCustomBuybackCooldownEnabled( true )
    hGameModeEntity:SetBuybackEnabled( false )
    hGameModeEntity:SetRemoveIllusionsOnDeath( true )
    hGameModeEntity:SetStashPurchasingDisabled ( false )
    hGameModeEntity:SetAnnouncerDisabled( true )
    hGameModeEntity:SetLoseGoldOnDeath( false )
    hGameModeEntity:SetFogOfWarDisabled(false)
    hGameModeEntity:SetGoldSoundDisabled( true )
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 13)
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.25)
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 11)
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.2)
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 1)
    hGameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.1)

    local iMaxLevel    = self.hFateSetting.nMaxLevel
	local iFirstLevel  = 200
	local fScaleValue  = 100
	local hGameXPTable = {}
	for i = 0, (iMaxLevel - 1) do
		local iCalcXP = iFirstLevel + (fScaleValue * i)

		table.insert(hGameXPTable, math.ceil(iCalcXP))
		--print(hGameXPTable[i + 1], i, "TEST XP VALUES")
	end

	local iBaseGoldBounty = 1050
	local iScaleGoldBounty = 50 
	local hGoldBountyTable = {}
	for i = 1, iMaxLevel do 
		hGoldBountyTable[i] = iBaseGoldBounty + (i * iScaleGoldBounty)
	end

	self.hFateSetting.iGoldBounty = hGoldBountyTable 

	local iBaseXPBounty = 50
	local iBonusXPBounty = 60 
	local iScaleXPBounty = 2 
	local hXPBountyTable = {}
	for i = 1, iMaxLevel do 
		hXPBountyTable[i] = (hXPBountyTable[i - 1] or 0) + (i * iScaleXPBounty) + iBonusXPBounty
	end

	self.hFateSetting.iXPBounty = hXPBountyTable 

	hGameModeEntity:SetCustomXPRequiredToReachNextLevel( hGameXPTable )
	hGameModeEntity:SetUseCustomHeroLevels( true )

	--GameRules:SetCustomGameSetupAutoLaunchDelay( IsInToolsMode() and 0 or 10.0 )

	GameRules:SetShowcaseTime(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetUseCustomHeroXPValues(true)
    GameRules:SetUseBaseGoldBountyOnHeroes(false)
    GameRules:SetCustomGameSetupTimeout(30)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetCustomGameEndDelay(30)
    GameRules:SetCustomVictoryMessageDuration(30)
    GameRules:SetPostGameTime( 30 ) 
    GameRules:SetTimeOfDay(10.30)
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    GameRules:SetHeroSelectionTime(0)
    Convars:SetInt("dota_max_physical_items_purchase_limit", 200)

    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(FateGameMode, 'OnPlayerLevelUp'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(FateGameMode, 'OnEntityKilled'), self)
    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(FateGameMode, 'OnItemPurchased'), self)
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(FateGameMode, 'OnItemPickedUp'), self)
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(FateGameMode, 'OnEntityHurt'), self)
    ListenToGameEvent('player_connect', Dynamic_Wrap(FateGameMode, 'PlayerConnect'), self)
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(FateGameMode, 'OnAbilityUsed'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(FateGameMode, 'OnGameRulesStateChange'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(FateGameMode, 'OnNPCSpawned'), self)
    ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(FateGameMode, 'OnPlayerPickHero'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(FateGameMode, 'OnPlayerChat'), self)

    CustomGameEventManager:RegisterListener( "game_vote", OnVoteMode )
    CustomGameEventManager:RegisterListener( "grail_vote", OnGrailVote )
    CustomGameEventManager:RegisterListener( "balance_vote", OnBanHeroVote )

    CustomGameEventManager:RegisterListener( "balance_shuf", OnBalanceShuf )
    CustomGameEventManager:RegisterListener( "direct_transfer_changed", OnDirectTransferChanged )
    CustomGameEventManager:RegisterListener( "servant_customize", OnServantCustomizeActivated )
    CustomGameEventManager:RegisterListener( "check_hero_in_transport", OnHeroClicked )
    CustomGameEventManager:RegisterListener( "config_option_1_checked", OnConfig1Checked )
    CustomGameEventManager:RegisterListener( "config_option_2_checked", OnConfig2Checked )
    CustomGameEventManager:RegisterListener( "config_option_4_checked", OnConfig4Checked )
    CustomGameEventManager:RegisterListener( "config_option_8_checked", OnConfig8Checked )
    CustomGameEventManager:RegisterListener( "config_option_9_checked", OnConfig9Checked )
    CustomGameEventManager:RegisterListener( "config_option_11_checked", OnConfig11Checked )
    CustomGameEventManager:RegisterListener( "player_alt_click", OnPlayerAltClick )
    CustomGameEventManager:RegisterListener( "player_say_to_team", OnPlayerSay )
    CustomGameEventManager:RegisterListener("player_remove_buff", OnPlayerRemoveBuff )
    CustomGameEventManager:RegisterListener("player_cast_seal", OnPlayerCastSeal )
    CustomGameEventManager:RegisterListener("player_hotkey_seal", OnPlayerHotkeySeal )

    if string.match(GetMapName(), "fate_elim") then
    	if string.match(GetMapName(), "7v7") then
    		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 7)
        	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 7)
        else
        	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6)
        	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 6)
        end
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(1)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)  
        GameRules:SetPreGameTime(370) 
        CustomNetTables:SetTableValue("mode", "mode", {mode = true})
    elseif string.match(GetMapName(), "tutorial") then
    	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0)
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(0)
        GameRules:SetGoldTickTime(0.0)
        GameRules:SetStartingGold(0)    
        GameRules:SetPreGameTime(5)
    else
    	if string.match(GetMapName(), "ffa") then
    		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )
	    elseif string.match(GetMapName(), "rumble") then
			GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3)
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3)
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3)
	        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 3)
	    else
	    	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3)
        	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3)
        	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3)
	    end
	    GameRules:SetGoldPerTick(7.5)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)
        GameRules:SetPreGameTime(120)
        CustomNetTables:SetTableValue("mode", "grail_mode", {mode = true})
    end

