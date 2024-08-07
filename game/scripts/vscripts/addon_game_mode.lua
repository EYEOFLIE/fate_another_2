require("statcollection/init")
--require('lishuwen_ability')
--require('archer_ability')
require('master_ability')
--require('gille_ability')
--require('lancelot_ability')
--require('nursery_rhyme_ability')
require("libraries/fate_functions_server_client") --fix cast range bonus
require('libraries/notifications')
--require("martin_ban_module")
require('items')
require('precache')
require('authority')
require('libraries/util' )
require('libraries/playertables' )
require('modifiers/attributes')
require('modifiers/modifier_dme')
require('libraries/timers')
require('libraries/popups')
require('libraries/animations')
require('libraries/crowdcontrol')
require('libraries/physics')
require("libraries/attachments")
require('hero_selection')
require('libraries/servantstats')
require('libraries/alternateparticle')
require('modifiers/modifier_ttr')
require('libraries/keyvalues')
require('blink')
require('custom_chatbox')
--require('unit_voice')
require('wrappers')
require('event')
require('libs/vector_targeting')
require('libs/ascension')

_G.IsPickPhase = true
_G.IsPreRound = true
_G.RoundStartTime = 0
_G.nCountdown = 0
_G.CurrentGameState = "FATE_PRE_GAME"
_G.GameMap = ""
--_G.LaPucelleActivated = false
_G.FIRST_BLOOD_TRIGGERED = false
--_G.DRAFT_MODE = false

ENABLE_HERO_RESPAWN = false -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false -- Should we let people select the same hero as each other
HERO_SELECTION_TIME = 60.0 -- How long should we let people select their hero?
PRE_GAME_TIME = 0 -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0 -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0 -- How long should it take individual trees to respawn after being cut down/destroyed?
GOLD_PER_TICK = 0 -- How much gold should players get per tick?
GOLD_TICK_TIME = 0 -- How long should we wait in seconds between gold ticks?
RECOMMENDED_BUILDS_DISABLED = false -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1250.0 -- How far out should we allow the camera to go? 1134 is the default in Dota
MINIMAP_ICON_SIZE = 1 -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1 -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1 -- What icon size should we use for runes?
RUNE_SPAWN_TIME = 120 -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true -- Should we use a custom buyback time?
BUYBACK_ENABLED = false -- Should we allow people to buyback when they die?
DISABLE_FOG_OF_WAR_ENTIRELY = false -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?
USE_CUSTOM_TOP_BAR_VALUES = true -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals) Requires USE_CUSTOM_TOP_BAR_VALUES
ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false -- Should we disable the gold sound when players get gold?
END_GAME_ON_KILLS = false -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 9999 -- How many kills for a team should signify an end of game?
USE_CUSTOM_HERO_LEVELS = true -- Should we allow heroes to have custom levels?
MAX_LEVEL = 24 -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true -- Should we use custom XP values to level up heroes, or the default Dota numbers?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
VICTORY_CONDITION = 12 -- Round required for win
SPAWN_GOLD = 3000



XP_TABLE = {}
_G.XP_PER_LEVEL_TABLE = {}
BOUNTY_PER_LEVEL_TABLE = {}
XP_BOUNTY_PER_LEVEL_TABLE = {}
PRE_ROUND_DURATION = 12
PRESENCE_ALERT_DURATION = 30
ROUND_DURATION = 120
FIRST_BLESSING_PERIOD = 300
BLESSING_PERIOD = 480
BLESSING_MANA_REWARD = 15
DRAW_CHEST_DROP_PERIOD = 600
SPAWN_POSITION_RADIANT_DM = Vector(-5400, 762, 376)
SPAWN_POSITION_DIRE_DM = Vector(7200, 4250, 755)
SPAWN_POSITION_T1_TRIO = Vector(-796,7032,512)
SPAWN_POSITION_T2_TRIO = Vector(5676,6800,512)
SPAWN_POSITION_T3_TRIO = Vector(5780,2504,512)
SPAWN_POSITION_T4_TRIO = Vector(-888,1748,512)
SPAWN_POSITION_TRIO1 = Vector(-2492,4384,256)
SPAWN_POSITION_TRIO2 = Vector(3201,4582,256)
SPAWN_POSITION_TRIO3 = Vector(317,1220,384)
SPAWN_POSITION_FFA = {}
SPAWN_POSITION_FFA[2] = Vector(-2304,4012,256)
SPAWN_POSITION_FFA[3] = Vector(-2224,2816,256)
SPAWN_POSITION_FFA[6] = Vector(-2060,1972,256)
SPAWN_POSITION_FFA[7] = Vector(2448,2169,256)
SPAWN_POSITION_FFA[8] = Vector(3000,2804,256)
SPAWN_POSITION_FFA[9] = Vector(3040,3788,256)
SPAWN_POSITION_FFA[10] = Vector(3116,4804,256)
SPAWN_POSITION_FFA[11] = Vector(2764,5668,256)
SPAWN_POSITION_FFA[12] = Vector(-1964,5728,256)
SPAWN_POSITION_FFA[13] = Vector(-2208,4960,256)


TRIO_RUMBLE_CENTER = Vector(2436,4132,1000)
FFA_CENTER = Vector(368,3868,1000)
mode = nil
FATE_VERSION = "v2.0"
roundQuest = nil
IsGameStarted = false

-- XP and XP Bounty stuffs
XP_TABLE[0] = 0
XP_TABLE[1] = 200
for i=2,(MAX_LEVEL-1) do
    XP_TABLE[i] = XP_TABLE[i-1] + i * 100 -- XP required per level formula : Previous level XP requirement + Level * 100
end

-- EXP required to reach next level
_G.XP_PER_LEVEL_TABLE[0] = 0
_G.XP_PER_LEVEL_TABLE[1] = 200
_G.XP_PER_LEVEL_TABLE[24] = 0
for i=2,MAX_LEVEL-2 do
    _G.XP_PER_LEVEL_TABLE[i] = XP_TABLE[i+1] - XP_TABLE[i] -- XP required per level formula : Previous level XP requirement + Level * 100
end


_G.XP_PER_LEVEL_TABLE[MAX_LEVEL-1] = _G.XP_PER_LEVEL_TABLE[MAX_LEVEL-2] + 2400

for i=1, MAX_LEVEL do
    BOUNTY_PER_LEVEL_TABLE[i] = 1050 + i * 50
end

XP_BOUNTY_PER_LEVEL_TABLE[1] = 100
XP_BOUNTY_PER_LEVEL_TABLE[2] = 100 * 0.85 + 8 + 100
for i=3, MAX_LEVEL do
    XP_BOUNTY_PER_LEVEL_TABLE[i] = XP_BOUNTY_PER_LEVEL_TABLE[i-1] * 0.85 + i * 4 + 120 
    -- Bounty XP formula : Previous level XP + Current Level * 4 + 120(constant)
end

-- Client to Server message data tables
local winnerEventData = {
    winnerTeam = 3, -- 0: Radiant, 1: Dire, 2: Draw
    radiantScore = 0,
    direScore = 0
}
local victoryConditionData = {
    victoryCondition = 12
}


model_lookup = {}
model_lookup["npc_dota_hero_legion_commander"] = "models/saber/saber.vmdl"
model_lookup["npc_dota_hero_phantom_lancer"] = "models/lancer/lancer2.vmdl"
model_lookup["npc_dota_hero_spectre"] = "models/saber_alter/sbr_alter.vmdl"
model_lookup["npc_dota_hero_ember_spirit"] = "models/archer/archertest.vmdl"
model_lookup["npc_dota_hero_templar_assassin"] = "models/rider/rider.vmdl"
model_lookup["npc_dota_hero_doom_bringer"] = "models/berserker/berserker.vmdl"
model_lookup["npc_dota_hero_juggernaut"] = "models/assassin/asn.vmdl"
model_lookup["npc_dota_hero_bounty_hunter"] = "models/true_assassin/ta.vmdl"
model_lookup["npc_dota_hero_crystal_maiden"] = "models/caster/caster.vmdl"
model_lookup["npc_dota_hero_skywrath_mage"] = "models/gilgamesh/gilgamesh.vmdl"
model_lookup["npc_dota_hero_sven"] = "models/lancelot/lancelot.vmdl"
model_lookup["npc_dota_hero_vengefulspirit"] = "models/avenger/avenger.vmdl"
model_lookup["npc_dota_hero_huskar"] = "models/diarmuid/diarmuid2.vmdl"
model_lookup["npc_dota_hero_chen"] = "models/iskander/iskander.vmdl"
model_lookup["npc_dota_hero_shadow_shaman"] = "models/zc/gille.vmdl"
model_lookup["npc_dota_hero_lina"] = "models/nero/nero.vmdl"
model_lookup["npc_dota_hero_omniknight"] = "models/gawain/gawain.vmdl"
model_lookup["npc_dota_hero_enchantress"] = "models/tamamo/tamamo.vmdl"
model_lookup["npc_dota_hero_bloodseeker"] = "models/lishuen/lishuen.vmdl"
model_lookup["npc_dota_hero_mirana"] = "models/jeanne/jeanne.vmdl"
model_lookup["npc_dota_hero_queenofpain"] = "models/astolfo/astolfo.vmdl"
model_lookup["npc_dota_hero_phantom_assassin"] = "models/semi/semi.vmdl"
model_lookup["npc_dota_hero_beastmaster"] = "models/karna/karna.vmdl"
model_lookup["npc_dota_hero_naga_siren"] = "models/kuro/kuro.vmdl"
model_lookup["npc_dota_hero_riki"] = "models/jtr/jtr.vmdl"
model_lookup["npc_dota_hero_dark_willow"] = "models/okita/okita_new.vmdl"
model_lookup["npc_dota_hero_troll_warlord"] = "models/drake/drake.vmdl"

DoNotKillAtTheEndOfRound = {
    "tamamo_charm",
    "jeanne_banner"
}
voteResultTable = {
    0, -- 12 kills
    0,  -- 10
    0, -- 8
    0,  -- 6
    0  -- 4
}
--[[voteResultTable = {
    v_OPTION_1 = 0, -- 12 kills
    v_OPTION_2 = 0,  -- 10
    v_OPTION_3 = 0, -- 8
    v_OPTION_4 = 0,  -- 6
    v_OPTION_5 = 0  -- 4
}]]--



voteResults_DM = {
    12, 10, 8, 6, 4
}

voteResults_TRIO = {
    45, 40, 35, 30, 25
}

voteResults_FFA = {
    30, 27, 24, 21, 19
}

gameState = {
    "FATE_PRE_GAME",
    "FATE_PRE_ROUND",
    "FATE_ROUND_ONGOING",
    "FATE_POST_ROUND"
}

gameMaps = {
    "fate_elim_6v6",
    "fate_elim_7v7",
    "fate_ffa",
    "fate_trio_rumble_3v3v3v3",
    "fate_tutorial",
    "fate_trio"
}


if FateGameMode == nil then
    FateGameMode = class({})
end

-- Create the game mode when we activate
function Activate()
    GameRules.AddonTemplate = FateGameMode()
    GameRules.AddonTemplate:InitGameMode()
    require('libs/filters')
end


function Precache( context , pc)
    print("Starting precache")
        --PrecacheUnitByNameSync("npc_precache_everything", context)

        --PrecacheResource("soundfile", "soundevents/music/*.vsndevts", context)
        --[[Kill the default sound files
        PrecacheResource("soundfile", "soundevents/music/valve_dota_001/soundevents_stingers.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/music/valve_dota_001/soundevents_music.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/music/valve_dota_001/game_sounds_music.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/music/valve_dota_001/music/game_sounds_music.vsndevts", context)

        PrecacheResource("soundfile", "soundevents/bgm.vsndevts", context)]]
        --====================== Sound files ======================================--

               --======= General ========--
    PrecacheResource("soundfile", "soundevents/announcer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/misc_sound.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/event.vsndevts", context)

               --======= Skin Update ========--
    PrecacheResource("soundfile", "soundevents/hero_skin_update.vsndevts", context)

                        --======= BGM, Ally, Enemy ========--  
    PrecacheResource("soundfile", "soundevents/ally_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/enemy_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/bgm.vsndevts", context)
      --PrecacheResource("sounfile", "soundevents/saber_oath.vsndevts", context)

                        --============ Saber ==============--    
    PrecacheResource("soundfile", "soundevents/hero_saber.vsndevts", context)                
    PrecacheResource("soundfile", "soundevents/hero_saber_alter.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_nero.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_gawain.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_okita.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_mordred.vsndevts", context) 
    PrecacheResource("soundfile", "soundevents/hero_musashi.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_muramasa.vsndevts", context)

                        --============ Archer ==============--      
    PrecacheResource("soundfile", "soundevents/hero_chocolate.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_archer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_gilg.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_atalanta.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_robin.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_oda_nobunaga.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_ishtar.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_billy.vsndevts", context)
                        --============ Lancer ==============--  
    PrecacheResource("soundfile", "soundevents/hero_lancer.vsndevts", context)                
    PrecacheResource("soundfile", "soundevents/hero_zl.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_vlad.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_karna.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_scathach.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_bathory.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_kiyohime.vsndevts", context)
                       --============ Caster ==============--      
    PrecacheResource("soundfile", "soundevents/hero_caster.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_zc.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_tamamo.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_nursery_rhyme.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_kongming.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_hans.vsndevts", context)
                        --============ Rider ==============--         
    PrecacheResource("soundfile", "soundevents/hero_rider.vsndevts", context)  
    PrecacheResource("soundfile", "soundevents/hero_iskander.vsndevts", context) 
    PrecacheResource("soundfile", "soundevents/hero_drake.vsndevts", context)             
    PrecacheResource("soundfile", "soundevents/hero_astolfo.vsndevts", context )

                        --============ Assassin ==============--   
    PrecacheResource("soundfile", "soundevents/hero_fa.vsndevts", context)                
    PrecacheResource("soundfile", "soundevents/hero_ta.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_lishuwen.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_jtr.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/hero_king_hassan.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_semiramis.vsndevts", context)

                        --============ Berserker ==============--     
    PrecacheResource("soundfile", "soundevents/hero_atlanta_alter.vsndevts", context)   
    PrecacheResource("soundfile", "soundevents/hero_berserker.vsndevts", context)                
    PrecacheResource("soundfile", "soundevents/hero_lancelot.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_fran.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_lubu.vsndevts", context)
     
                        --============ Extra ==============--                                       
    PrecacheResource("soundfile", "soundevents/hero_mashu.vsndevts", context)                    
    PrecacheResource("soundfile", "soundevents/hero_avenger.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_ruler.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_amakusa.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_edmond.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_melt.vsndevts", context)
        
        --====================== Sound files : Voice ======================================--

                        --============ Saber ==============--  
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_legion_commander.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_lina.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_spectre.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_omniknight.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_tusk.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dark_willow.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_antimage.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_kunkka.vsndevts", context )

                        --============ Archer ==============--      
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_ember_spirit.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_skywrath_mage.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_drowranger.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_naga_siren.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sniper.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_gyrocopter.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_oracle.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_muerta.vsndevts", context )
                        --============ Lancer ==============--  
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_beastmaster.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_huskar.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_phantom_lancer.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_tidehunter.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_monkey_king.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_death_prophet.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_void_spirit.vsndevts", context )

                        --============ Caster ==============--    
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_crystalmaiden.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_enchantress.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_shadowshaman.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_windrunner.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_disruptor.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_necrolyte.vsndevts", context )
                       --============ Rider ==============--   
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_chen.vsndevts", context )                
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_templar_assassin.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_troll_warlord.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_queenofpain.vsndevts", context )

                        --============ Assassin ==============--  
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_bloodseeker.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_bounty_hunter.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_juggernaut.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_riki.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_skeleton_king.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_phantom_assassin.vsndevts", context )

                        --============ Berserker ==============--      
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_ursa.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_doom_bringer.vsndevts", context )    
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sven.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_zuus.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_axe.vsndevts", context )
                        --============ Extra ==============--           
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dragon_knight.vsndevts", context )    
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_mirana.vsndevts", context )    
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_enigma.vsndevts", context )    
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_vengefulspirit.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_night_stalker.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_nyx_assassin.vsndevts", context )

        -- Items
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
    PrecacheItemByNameSync("item_portal_key", context)
    PrecacheItemByNameSync("item_f_scroll", context)
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
    PrecacheUnitByNameSync( "iskandar_infantry", context )
    PrecacheUnitByNameSync( "iskandar_archer", context )
    PrecacheUnitByNameSync( "iskandar_cavalry", context )
    PrecacheResourceModel ( context )
    PrecacheResourceParticle ( context )

       -- Master, Stash, and System stuffs
    --[[PrecacheResource("model", "models/shirou/shirou.vmdl", context)
    PrecacheResource("model", "models/items/courier/catakeet/catakeet_boxes.vmdl", context)
    PrecacheResource("model", "models/konomama_hassan/konomama_hassan.vmdl", context)
    PrecacheResource("model", "models/femalehassan/femalehassan.vmdl", context)
    PrecacheResource("model", "models/rin/rin.vmdl", context)
    PrecacheResource("model", "models/altera/altera.vmdl", context)
    PrecacheResource("model", "models/okita/okita.vmdl", context)    
    PrecacheResource("model", "models/archer/kanshou.vmdl", context)
    PrecacheResource("model", "models/archer/byakuya.vmdl", context)
    PrecacheResource("model", "models/astolfo/astolfo_sword.vmdl", context)  
    PrecacheResource("model", "models/astolfo/astolfo_new_horn.vmdl", context)  
    PrecacheResource("model", "models/astolfo/astolfo_scabbard.vmdl", context)  
    PrecacheResource("model", "models/astolfo/astolfo_lance.vmdl", context)  
    PrecacheResource("model", "models/kuro/kuro_bow.vmdl", context)  
    PrecacheResource("model", "models/lubu/lubu_bow.vmdl", context)  
    PrecacheResource("model", "models/lubu/lubu_lance.vmdl", context)  
    PrecacheResource("model", "models/lubu/lubu_arrow.vmdl", context)  
    PrecacheResource("model", "models/lancelot/lancelot_rod.vmdl", context)  
    PrecacheResource("model", "models/lancelot/lancelot_arondite.vmdl", context)  
    PrecacheResource("model", "models/lancelot/lancelot_gun_by_zefiroft.vmdl", context)  
    PrecacheResource("model", "models/bathory/bathory_weapon.vmdl", context)  
    PrecacheResource("model", "models/iskander/waver.vmdl", context)  
    PrecacheResource("model", "models/iskandar/default/iskandar_gordius.vmdl", context)  
    PrecacheResource("model", "models/iskandar/salary/iskandar_salary_gordius.vmdl", context)  
    PrecacheResource("model", "models/lancelot/suit/lancelot_suit_by_zefiroft.vmdl", context)  
    PrecacheResource("model", "models/avenger/trueform/trueform.vmdl", context)  ]]


    --[[PrecacheResource( "particle", "particles/units/heroes/hero_silencer/silencer_global_silence_sparks.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_magical.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_physical.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_pure.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/gold_popup.vpcf", context)
    PrecacheResource( "particle", 'particles/units/heroes/hero_chaos_knight/chaos_knight_weapon_blur.vpcf', context)

    PrecacheResource("particle", "particles/custom/mordred/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", context)
    PrecacheResource("particle", "particles/custom/mordred/zuus_lightning_bolt.vpcf", context)]]
    --PrecacheResource("particle", "particles/custom/atalanta/rainbow_arrow.vpcf", context)
    --PrecacheResource("particle", "particles/custom/atalanta/normal_arrow.vpcf", context)
    --PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_ti8_sword_attack_a.vpcf", context)
    --PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_ti8_sword_attack_b.vpcf", context)
    --PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/jugg_attack_blur.vpcf", context)

    --[[
        PrecacheResource("particle", "particles/custom/gilgamesh/gilgamesh_sword_barrage_model.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", context)
        PrecacheResource("particle", "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", context)
        PrecacheResource("particle", "particles/custom/diarmuid/gae_dearg_slash.vpcf", context)
        PrecacheResource("particle", "particles/custom/diarmuid/gae_dearg_slash_flash.vpcf", context)
        PrecacheResource("particle", "particles/custom/diarmuid/diarmuid_yellow_trail.vpcf", context)
        PrecacheResource("particle", "particles/custom/diarmuid/diarmuid_red_trail.vpcf", context)
    ]]

    --[[local heroList = LoadKeyValues("scripts/npc/herolist.txt")
    for k,v in pairs (heroList) do        
        PrecacheResource('model', GetUnitKV(heroesTable[k], "Model"), context)
    end]]

        -- AOTK Soldier assets
    --[[PrecacheResource("model_folder", "models/heroes/chen", context)
    PrecacheResource("model_folder", "models/heroes/dragon_knight", context)
    PrecacheResource("model_folder", "models/heroes/chaos_knight", context)
    PrecacheResource("model_folder", "models/heroes/silencer", context)
    PrecacheResource("model_folder", "models/heroes/windrunner", context)
    PrecacheResource("model_folder", "models/heroes/juggernaut", context)
    PrecacheResource('model', "models/items/chaos_knight/blade_of_entropy/blade_of_entropy.vmdl", context)
    PrecacheResource('model', "models/items/chaos_knight/chaos_legion_helm/chaos_legion_helm.vmdl", context)
    PrecacheResource('model', "models/items/chaos_knight/rising_chaos_steed/rising_chaos_steed.vmdl", context)
    PrecacheResource('model', "models/items/windrunner/sparrowhawk_hood2/sparrowhawk_hood2.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal__weapon/whispertribunal__weapon.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal_arms/whispertribunal_arms.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal_belt/whispertribunal_belt.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal_head/whispertribunal_head.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal_shield/whispertribunal_shield.vmdl", context)
    PrecacheResource('model', "models/items/silencer/whispertribunal_shoulder/whispertribunal_shoulder.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/bladesrunner_arms/bladesrunner_arms.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/bladesrunner_back/bladesrunner_back.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/bladesrunner_head/bladesrunner_head.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/bladesrunner_weapon/bladesrunner_weapon.vmdl", context)
    PrecacheResource('resource', "materials/vgui/hud/heroportraits/portraitbackground_windrunner.vmat", context)
    PrecacheResource('resource', "materials/portraits_card/portrait_backgrounds/gyro.vmat", context)
    PrecacheResource('resource', "materials/vgui/hud/heroportraits/portraitbackground_moon.vmat", context)
    PrecacheResource('resource', "materials/vgui/hud/heroportraits/portraitbackground_desert.vmat", context)]]
    
    --[[PrecacheResource('model', "models/items/juggernaut/sinister_shadow_arms/sinister_shadow_arms.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/sinister_shadow_back/sinister_shadow_back.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/sinister_shadow_head/sinister_shadow_head.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/sinister_shadow_legs/sinister_shadow_legs.vmdl", context)
    PrecacheResource('model', "models/items/juggernaut/sinister_shadow_weapon/sinister_shadow_weapon.vmdl", context)]]

       -- Vector target
        --VectorTarget:Precache( context )

    print("precache complete")
end

function FateGameMode:PostLoadPrecache()
  --  print("[BAREBONES] Performing Post-Load precache")
end

--[[
This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
    It can be used to initialize state that isn't initializeable in InitFateGameMode() but needs to be done before everyone loads in.
    ]]
function FateGameMode:OnFirstPlayerLoaded()
  --  print("[BAREBONES] First Player has loaded")
end

--[[
This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
    It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
    ]]
function FateGameMode:OnAllPlayersLoaded()
   -- print("[BAREBONES] All Players have loaded into the game")
    
    --GameRules:SendCustomMessage("Game is currently in alpha phase of development and you may run into major issues that I hope to address ASAP. Please wait patiently for the official release.", 0, 0)
    GameRules:SendCustomMessage("#Fate_Choose_Hero_Alert_60", 0, 0)
    --FireGameEvent('cgm_timer_display', { timerMsg = "Hero Select", timerSeconds = 61, timerEnd = true, timerPosition = 100})

    -- initialize vector targeting
    --VectorTarget:Init({noOrderFilter = true })
    -- Send KV to fatepedia
    -- Announce the goal of game
    -- Reveal the vote winner
    local goal_win = LoadKeyValues("scripts/npc/fate_goal.txt")
    --local maxval = voteResultTable[1]
    local maxkey = 1
    if _G.GameMap ~= "fate_tutorial" then 
        maxkey = goal_win[_G.GameMap]
        --print('goal win = ' .. maxkey)
        if not string.match(_G.GameMap, "elim") then
            local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
            local total_player = ServerTables:GetTableValue("Players", "total_player")
            --print('max player = ' .. max_player .. ", total player = " .. total_player)
            maxkey = maxkey - ((max_player - total_player) * 2 )
            --print('goal win after reduction = ' .. maxkey)
        end
    end
    if IsInToolsMode() then 
        maxkey = 3
    end
   -- local votePool = nil
    --[[if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        --votePool = voteResults_DM
        --maxkey = voteResults_DM[1]
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        --[[for k = 1, 5 do 
            voteResults_TRIO[k] = voteResults_TRIO[k] - ((12 - #self.vUserIds) * 2)
        end
        votePool = voteResults_TRIO
        maxkey = voteResults_TRIO[1]
    elseif _G.GameMap == "fate_trio" then
        for k = 1, 5 do 
            voteResults_TRIO[k] = voteResults_TRIO[k] - ((9 - #self.vUserIds) * 3)
        end
        votePool = voteResults_TRIO
        maxkey = voteResults_TRIO[1]
    elseif _G.GameMap == "fate_ffa" then
        for k = 1, 5 do 
            voteResults_FFA[k] = voteResults_FFA[k] - ((10 - #self.vUserIds) * 2)
        end
        votePool = voteResults_FFA
        maxkey = voteResults_FFA[1]
    end

    for i=1, 5 do
        if voteResultTable[i] > maxval then
            maxval = i
            maxkey = votePool[i]
        end
    end  ]]
    
    
    local particleDummyOrigin
    if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        particleDummyOrigin = Vector(-7900,-8000, 200)--Vector(6250,-7200, 200)
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" or "fate_ffa" or _G.GameMap == "fate_trio" then
        particleDummyOrigin = Vector(6250,-7200, 200)
    end    
    --add global particle dummy in master's territory along with vision for both teams

    local particleDummy = CreateUnitByName("visible_dummy_unit", particleDummyOrigin, true, nil, nil, 4)
    particleDummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    AddFOWViewer(2, particleDummyOrigin, 500, 99999, false) -- duration -1 doesnt work lols
    AddFOWViewer(3, particleDummyOrigin, 500, 99999, false)
    _G.ParticleDummy = particleDummy

    --[[if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        local easterEggloc = Vector(6911, 6325, 384)
        local easterEggDummy = CreateUnitByName("altera_dummy", easterEggloc, true, nil, nil, 4)
        easterEggDummy:SetForwardVector(Vector(6915, 5540, 384) * -1)

        --local easterEggloc2 = Vector(-7795, 7112, 512)
       -- local easterEggDummy2 = CreateUnitByName("okita_dummy", easterEggloc2, true, nil, nil, 4)
        --easterEggDummy2:SetForwardVector(Vector(-7781, 6684, 512) * -1)
    end]]
    
    -- CUSTOM COLOURS
    badGuyColorIndex = 1
    goodGuyColorIndex = 1
    badColorTable = {{164,105,0},{254,134,194},{0,131,33},{101,217,247},{161,180,71},{244,164,96},{176,196,222}}
    goodColorTable = {{51,117,255},{102,255,191},{255,107,0},{191,0,191},{243,240,11},{255,20,147},{220,20,60}}
    for i=0, 13 do
        if PlayerResource:GetPlayer(i) ~= nil then
            local playerID = i
            local player = PlayerResource:GetPlayer(i)
            print(playerID)
            print(player:GetTeam())

            if player:GetTeam() == 2 then
                print("GOOD GUY COLOR")
                PlayerResource:SetCustomPlayerColor(i, goodColorTable[goodGuyColorIndex][1], goodColorTable[goodGuyColorIndex][2], goodColorTable[goodGuyColorIndex][3])
                goodGuyColorIndex = goodGuyColorIndex + 1
            else
                print("BAD GUY COLOR")
                PlayerResource:SetCustomPlayerColor(i, badColorTable[badGuyColorIndex][1], badColorTable[badGuyColorIndex][2], badColorTable[badGuyColorIndex][3])
                badGuyColorIndex = badGuyColorIndex + 1
            end
        end
    end

    VICTORY_CONDITION = maxkey
    victoryConditionData.victoryCondition = VICTORY_CONDITION
    --VICTORY_CONDITION = 1
    ServerTables:SetTableValue("Win", "goal", VICTORY_CONDITION, true)
end




--[[
This function is called once and only once when the game completely begins (about 0:00 on the clock). At this point,
    gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc. This function
        is useful for starting any game logic timers/thinkers, beginning the first round, etc.
        ]]
function FateGameMode:OnGameInProgress()
    GameRules:SendCustomMessage("Fate/Another II " .. FATE_VERSION .. " by ZeFiRoFT", 0, 0)
    GameRules:SendCustomMessage("<font color='#FF3399'>Vote Result:</font> Players have decided for victory score: <font color='#FF3399'>" .. VICTORY_CONDITION .. ".</font>", 0, 0)
    --self:CheckCondition()
    print("[FATE] The game has officially begun")

    
    --GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)

    Timers:CreateTimer(5.0, function()
        -- Set a think function for timer
        if GameRules:GetGameModeEntity():GetRecommendedItemsDisabled() == true then 
            print('no recommend shop')
            GameRules:GetGameModeEntity():SetRecommendedItemsDisabled(false)
        end
        if GameRules:IsDaytime() then
            GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)
        else
            GameRules:SetTimeOfDay(10.30)
            GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)
        end
        local CENTER_POSITION = Vector(0,0,0)
        local SHARD_DROP_PERIOD = 0
        if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            self.nCurrentRound = 1
            self:InitializeRound() -- Start the game after forcing a pick for every player
            BLESSING_PERIOD = 600
        elseif _G.GameMap == "fate_tutorial" then
            FIRST_BLESSING_PERIOD = 6000
            BLESSING_PERIOD = 600
        elseif _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio" then
            BLESSING_PERIOD = 300
            CENTER_POSITION = FFA_CENTER
            if self.votemodeResultTable.v_OPTION_2 > self.votemodeResultTable.v_OPTION_1 then
                SHARD_DROP_PERIOD = 180 
                CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
            end
            _G.CurrentGameState = "FATE_ROUND_ONGOING"
            ServerTables:SetTableValue("GameState", "state", "FATE_ROUND_ONGOING", true)
        elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
            BLESSING_PERIOD = 300
            CENTER_POSITION = TRIO_RUMBLE_CENTER
            if self.votemodeResultTable.v_OPTION_2 > self.votemodeResultTable.v_OPTION_1 then
                SHARD_DROP_PERIOD = 180
                CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
            end
            _G.CurrentGameState = "FATE_ROUND_ONGOING"
            ServerTables:SetTableValue("GameState", "state", "FATE_ROUND_ONGOING", true)
        end
        GameRules:GetGameModeEntity():SetThink( "OnGameTimerThink", self, 1 )
        IsPickPhase = false
        IsGameStarted = true
        GameRules:SendCustomMessage("#Fate_Game_Begin", 0, 0)
        if _G.GameMap ~= "fate_tutorial" then
            CreateUITimer("Next Holy Grail's Blessing", FIRST_BLESSING_PERIOD, "ten_min_timer")

            Timers:CreateTimer('round_10min_bonus', {
                endTime = FIRST_BLESSING_PERIOD,
                callback = function()
                    CreateUITimer("Next Holy Grail's Blessing", BLESSING_PERIOD, "ten_min_timer")
                    self:LoopOverPlayers(function(player, playerID, playerHero)
                        local hero = playerHero
                        local manaReward = BLESSING_MANA_REWARD
                        if hero:GetLevel() == 24 then 
                            manaReward = manaReward + 3 
                        end
                        hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
                        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana()+manaReward)
                        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
                        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana()+manaReward)
                        --NotifyManaAndShard(hero)
                        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
                    end)
                    --Notifications:TopToAll("#Fate_Timer_10minute", 5, nil, {color="rgb(255,255,255)", ["font-size"]="25px"})
                    Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})


                    return BLESSING_PERIOD
            end})
            --[[if string.match(GetMapName(), "fate_elim") then 
                CreateUITimer("Draw Chest Drop Cooldown", DRAW_CHEST_DROP_PERIOD, "draw_chest_timer")
                Timers:CreateTimer('draw_chest', {
                    endTime = DRAW_CHEST_DROP_PERIOD,
                    callback = function()
                    
                    self.bDrawChestDrop = true        

                end})
            end]]
        end
        if (_G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio") then
            if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
                CreateUITimer("PADORU Hat Drop", 180, "padoru_timer")
                Timers:CreateTimer('padoru_alert', {
                    endTime = 175,
                    callback = function()
                    Notifications:TopToAll({text="<font color='#58ACFA'>Padoru Hat</font> inbound! It will drop onto random location within center area.", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="35px"}})
                    EmitGlobalSound( "Merry_Padoru" )
                    Timers:CreateTimer(5, function()
                        local padoru_hat = CreateItem( "item_padoru_hat", nil, nil )
                        local hat_pos = CENTER_POSITION + Vector(RandomInt(-800,800), RandomFloat(-800, 800), 0)
                        local drop = CreateItemOnPositionForLaunch( hat_pos + Vector(0,0,500), padoru_hat )
                        padoru_hat:LaunchLootInitialHeight( false, 500, 50, 0.5, hat_pos )
                        --padoru_hat:SetAngles(0, 0, 0)
                    end)
                end})
            end    
            if self.votemodeResultTable.v_OPTION_2 > self.votemodeResultTable.v_OPTION_1 then
                Timers:CreateTimer('shard_drop_alert', {
                    endTime = SHARD_DROP_PERIOD - 5,
                    callback = function()
                    Notifications:TopToAll({text="<font color='#58ACFA'>Shard of Holy Grail </font> inbound! It will drop onto random location within center area.", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="35px"}})
                    EmitGlobalSound( "powerup_03" )
                    return SHARD_DROP_PERIOD
                end})
                Timers:CreateTimer('shard_drop_event', {
                    endTime = SHARD_DROP_PERIOD,
                    callback = function()
                    CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
                    --Notifications:TopToAll("#Fate_Timer_10minute", 5, nil, {color="rgb(255,255,255)", ["font-size"]="25px"})
                    for i=1, 1 do
                        local itemVector = CENTER_POSITION + Vector(RandomInt(-1300,1300), RandomFloat(-1300, 1300), 0)
                        CreateShardDrop(itemVector)
                    end
                    return SHARD_DROP_PERIOD
                end})
            end
        end
    end)



    -- add xp granter and level its skills
    local bIsDummyNeeded = true
    local dummyLevel = 0
    local dummyLoc = Vector(0,0,0)
    if _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio" then
        dummyLevel = 1
        dummyLoc = FFA_CENTER
    elseif _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        bIsDummyNeeded = false
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        dummyLevel = 2
        dummyLoc = TRIO_RUMBLE_CENTER
    end
    

    if bIsDummyNeeded then
        local xpGranter = CreateUnitByName("dummy_unit", Vector(0, 0, 1000), true, nil, nil, DOTA_TEAM_NEUTRALS)
        xpGranter:AddAbility("fate_experience_thinker")
        xpGranter:FindAbilityByName("fate_experience_thinker"):SetLevel(dummyLevel)
        xpGranter:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
        xpGranter:SetAbsOrigin(dummyLoc)
    end
end

function FateGameMode:RageQuit(playerId, quit_count, max_player)

    kjlpluo1596:rqinitialize(playerId, quit_count<= 4 and true)

    SendChatToPanorama("total rage quit player: " .. quit_count)
    --Timers:CreateTimer(0.5, function()
        
        if quit_count == 4 then 
            ServerTables:SetTableValue("GameState", "safe_to_leave", 1)
            GameRules:SendCustomMessage("This game can be continue", 0, 0)
            GameRules:SendCustomMessage("This game is safe to leave.", 0, 0)
        elseif quit_count == 6 then 
            GameRules:SendCustomMessage("NO MMR calculate in this game.", 0, 0)    
            GameRules:SendCustomMessage("Game will be shut down", 0, 0)   
            GameRules:SendCustomMessage("Everyone gain 10CP as compensation.", 0, 0)   
            GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
            for i = 0, 13 do 
                kjlpluo1596:rqinitialize(i, false)
            end
        end
    --end)
end

-- Cleanup a player when they leave
--"userid"    "player_controller"     // user ID on server
--"reason"    "short"     // see networkdisconnect enum protobuf
--"name"      "string"    // player name
--"networkid" "string"    // player network (i.e steam) id
--"xuid"      "uint64"    // steam id
--"PlayerID"  "short"
function FateGameMode:OnDisconnect(keys)
  --  print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
    --PrintTable(keys)

    --local name = keys.name
    --local networkid = keys.networkid
    --local reason = keys.reason
    local playerId = keys.PlayerID

    local connection_data = PlayerTables:GetAllTableValues("connection", playerId)
    local dc_time = 0
    local quit_round = connection_data["qRound"]
    
    --PlayerTables:CreateTable("connection", {cstate = "connect", dTime = 0, qRound = 1}, i)
    --PlayerTables:SetTableValue("connection", "qRound", self.nCurrentRound, playerId, true)
    PlayerTables:SetTableValue("connection", "cstate", "disconnect", playerId, true)
    
     Timers:CreateTimer(function()
        local conn_state = PlayerResource:GetConnectionState(playerId)
        local game_state = ServerTables:GetTableValue("GameState", "state")
        if game_state == "FATE_END_GAME" then return nil end

        --0 = No connection
        --1 = Bot
        --2 = Player
        --3 = Disconnected
        --4 = Abandoned
        --5 = Load
        --6 = Fail
        if conn_state == 4 or conn_state == 0 or keys.RQTest == 1 then 
            PlayerTables:SetTableValue("connection", "cstate", "rage_quit", playerId, true)
            PlayerTables:SetTableValue("connection", "qRound", self.nCurrentRound, playerId, true)
            local total_player = ServerTables:GetTableValue("Players", "total_player")
            local quit_count = ServerTables:GetTableValue("GameState", "quit_count")
            if IsInToolsMode() or (string.match(GetMapName(), "fate_elim") and total_player == 14) then
                if self.nRadiantScore == 11 or self.nDireScore == 11 and PlayerResource:GetPlayer(playerId):GetAssignedHero():IsAlive() then 
                    if ServerTables:GetTableValue("GameState", "state") == "FATE_END_GAME" then return nil end
                    Timers:CreateTimer(ROUND_DURATION, function()
                        if ServerTables:GetTableValue("GameState", "state") == "FATE_END_GAME" then return nil end
                        if ServerTables:GetTableValue("GameState", "state") == "FATE_ROUND_ONGOING" then 
                            ServerTables:SetTableValue("GameState", "quit_count", quit_count + 1)  
                            self:RageQuit(playerId, quit_count + 1) 
                            SendChatToPanorama("player " .. playerId .. " '" .. keys.name .. "' " .. " is rage quit")
                        end
                    end)
                    return nil
                else
                    ServerTables:SetTableValue("GameState", "quit_count", quit_count + 1)  
                    self:RageQuit(playerId, quit_count + 1) 
                    SendChatToPanorama("player " .. playerId .. " '" .. keys.name .. "' " .. " is rage quit")
                end
            end
            return nil
        elseif conn_state == 3 or conn_state == 5 then 
            return 1
        elseif conn_state == 2 then 
            PlayerTables:SetTableValue("connection", "cstate", "connect", playerId, true)
            return nil
        end
    end)   
    --[[Timers:CreateTimer(function() ------ RQ System
        local conn_state = PlayerResource:GetConnectionState(playerId)
        local game_state = ServerTables:GetTableValue("GameState", "state")
        if game_state == "FATE_END_GAME" then return nil end
        if conn_state == 4 or conn_state == 0 or keys.RQTest == 1 then 
            PlayerTables:SetTableValue("connection", "cstate", "rage_quit", playerId, true)
            local total_player = ServerTables:GetTableValue("Players", "total_player")
            local quit_count = ServerTables:GetTableValue("GameState", "quit_count")
            if IsInToolsMode() or (string.match(GetMapName(), "fate_elim") and total_player == 14) then
                if self.nRadiantScore == 11 or self.nDireScore == 11 then 
                    Timers:CreateTimer(ROUND_DURATION, function()
                        if ServerTables:GetTableValue("GameState", "state") == "FATE_ROUND_ONGOING" then 
                            ServerTables:SetTableValue("GameState", "quit_count", quit_count + 1)  
                            self:RageQuit(playerId, quit_count + 1, max_player) 
                            SendChatToPanorama("player " .. playerId .. " '" .. keys.name .. "' " .. " is rage quit")
                        end
                    end)
                    return nil
                else
                    ServerTables:SetTableValue("GameState", "quit_count", quit_count + 1)  
                    self:RageQuit(playerId, quit_count + 1, max_player) 
                    SendChatToPanorama("player " .. playerId .. " '" .. keys.name .. "' " .. " is rage quit")
                end
            end
            return nil
        elseif conn_state == 3 or conn_state == 5 then 
            return 1
        elseif conn_state == 2 then 
            return nil
        end
    end)]]


    --[[Timers:CreateTimer(60*10, function()    -- kick DC
        if PlayerResource:GetConnectionState(playerId) == 3 then 
            if IsServer() then
                DisconnectClient(playerId, true)
                SendChatToPanorama("player " .. playerId .. " '" .. keys.name .. "' " .. " has been kick due to long disconnect time.")
                --self:OnDisconnect({PlayerID=plyID})
            end
        end
    end)]]
    --end)     
    --local playerID = self.vPlayerList[userid]
    --print(name .. " just got disconnected from game! Player ID: " .. playerID)
    --PlayerResource:GetSelectedHeroEntity(playerID):ForceKill(false)
    --table.remove(self.vPlayerList, userid) -- remove player from list
end

function SendChatToPanorama(string)
    local table =
    {
        text = string
    }
    CustomGameEventManager:Send_ServerToAllClients( "player_chat_lua", table )
end

function FateGameMode:OnPlayerChat(keys)
   -- print ('[BAREBONES] PlayerSay')
    if keys == nil then print("empty keys") end
    -- Get the player entity for the user speaking
    local text = keys.text
    --SendChatToPanorama(text)
    --[[for k,v in pairs(keys) do
        print(k,v)
    end]]
    local userID = keys.userid
    --local is_team = keys.teamonly -- 0 == all, 1 == ally
    local playerid = keys.playerid
    if text == nil or userID == nil or playerid == nil then 
        SendChatToPanorama("Chat Error: text or userid or playerid not found by unknown ")
        return 
    end

    --[[local localUserID = self.vUserIds[playerid]
    if not localUserID or localUserID == nil then
        SendChatToPanorama("Chat Error: local user id not found by " .. playerid)
        return 
    end]]
    local plyID = playerid

    if plyID == nil then 
        SendChatToPanorama("Chat Error: player id not found by " .. playerid)
        return 
    end

    --local plyID = self.vPlayerList[userID]
    --if not plyID then return end
    --if IsDedicatedServer() then plyID = plyID - 1 end -- the index is off by 1 on dedi
    --if GameRules:IsCheatMode() then
    SendChatToPanorama(text .. " by player " .. plyID)
    --end
    local ply = PlayerResource:GetPlayer(plyID)
    if not ply then return end

    local hero = ply:GetAssignedHero()
    if hero == nil then return end

    --if hero:GetName() == "npc_dota_hero_wisp" then return end

    -- Match the text against something
    local matchA, matchB = string.match(text, "^-swap%s+(%d)%s+(%d)")
    if matchA ~= nil and matchB ~= nil then
        -- Act on the match
    end

    --[[if text == "-rainbowchocolate" then
        local loc = Vector(6911, 6325, 384)
        local dummy = CreateUnitByName("altera_dummy", loc, true, nil, nil, hero:GetTeamNumber())
        dummy:SetForwardVector(hero:GetForwardVector())
    end]]

    --[[if text == "-noshishouifudoit" then
            if hero:GetName() == "npc_dota_hero_wisp" then
                --local loc = Vector(-5400, 762, 376)
                --local dummy = CreateUnitByName("karna_dummy", loc, true, nil, nil, hero:GetTeamNumber())
                PrecacheUnitByNameAsync("npc_dota_hero_monkey_king", function()
                    local oldHero = PlayerResource:GetSelectedHeroEntity(plyID)
                    oldHero:SetRespawnsDisabled(true)

                    PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_monkey_king", 3000, 0)

                    UTIL_Remove(oldHero)
                end)
            end
    end]]

    --[[if text == "-kuroilyameme" then
        if hero:GetName() == "npc_dota_hero_wisp" then
            --local loc = Vector(-5400, 762, 376)
            --local dummy = CreateUnitByName("karna_dummy", loc, true, nil, nil, hero:GetTeamNumber())
            PrecacheUnitByNameAsync("npc_dota_hero_naga_siren", function()
                local oldHero = PlayerResource:GetSelectedHeroEntity(plyID)
                oldHero:SetRespawnsDisabled(true)

                PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_naga_siren", 3000, 0)

                UTIL_Remove(oldHero)
            end)
        end
    end]]
    --[[elseif text == "-elfearassassin" then
        if hero:GetName() == "npc_dota_hero_wisp" then
            --local loc = Vector(-5400, 762, 376)
            --local dummy = CreateUnitByName("karna_dummy", loc, true, nil, nil, hero:GetTeamNumber())
            PrecacheUnitByNameAsync("npc_dota_hero_phantom_assassin", function()
                local oldHero = PlayerResource:GetSelectedHeroEntity(plyID)
                oldHero:SetRespawnsDisabled(true)

                PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_phantom_assassin", 3000, 0)

                UTIL_Remove(oldHero)
            end)
        end
    end

    if text == "-okitasandaishouri" then
        if hero:GetName() == "npc_dota_hero_wisp" then
            --local loc = Vector(-5400, 762, 376)
            --local dummy = CreateUnitByName("karna_dummy", loc, true, nil, nil, hero:GetTeamNumber())
            PrecacheUnitByNameAsync("npc_dota_hero_dark_willow", function()
                local oldHero = PlayerResource:GetSelectedHeroEntity(plyID)
                oldHero:SetRespawnsDisabled(true)

                PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_dark_willow", 3000, 0)

                UTIL_Remove(oldHero)
            end)
        end
    end]]

    --[[if text == "-letwildhuntbegin" then
        if hero:GetName() == "npc_dota_hero_wisp" then
            --local loc = Vector(-5400, 762, 376)
            --local dummy = CreateUnitByName("karna_dummy", loc, true, nil, nil, hero:GetTeamNumber())
            PrecacheUnitByNameAsync("npc_dota_hero_troll_warlord", function()
                local oldHero = PlayerResource:GetSelectedHeroEntity(plyID)
                oldHero:SetRespawnsDisabled(true)

                PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_troll_warlord", 3000, 0)

                UTIL_Remove(oldHero)
            end)
        end
    end]]
    if text == "-hat" then 
        if PlayerTables:GetTableValue("authority", 'alvl', plyID) == 5 then
            local padoru_hat = CreateItem( "item_padoru_hat", nil, nil )
            local hat_pos = hero:GetAbsOrigin()
            local drop = CreateItemOnPositionForLaunch( hat_pos + Vector(0,0,500), padoru_hat )
            padoru_hat:LaunchLootInitialHeight( false, 500, 50, 0.5, hat_pos )
        end
    end

    if text == "-devtest" then 
        if PlayerTables:GetTableValue("authority", 'alvl', plyID) == 5 and tostring(PlayerResource:GetSteamAccountID(playerid)) == "96116520" then 
            VICTORY_CONDITION = 1
            victoryConditionData.victoryCondition = VICTORY_CONDITION
            CustomGameEventManager:Send_ServerToAllClients( "victory_condition_set", victoryConditionData )
        end
    end

    if text == "-debugskill" then 
        if c then 
            for i = 0, hero:GetAbilityCount() -1 do
                local ability = hero:GetAbilityByIndex(i)
                if ability ~= nil then 
                    print('ability ' .. i, ability:GetAbilityName())
                end
            end
        end
    end

    -- Below two commands are solely for test purpose, not to be used in normal games
    if text == "-testsetup" then
        if GameRules:IsCheatMode() then
            self:LoopOverPlayers(function(player, playerID, playerHero)
                local hero = playerHero
                hero.MasterUnit:SetMana(1000)
                hero.MasterUnit2:SetMana(1000)
                hero.MasterUnit:SetMaxHealth(1000)
                hero.MasterUnit:SetHealth(1000)
                hero.MasterUnit2:SetMaxHealth(1000)
                hero.MasterUnit2:SetHealth(1000)
                if IsManaLess(hero) and not string.match(hero:GetName(),"shaman") then -- hero:GetName() == "npc_dota_hero_juggernaut"
                    hero:SetBaseStrength(30)
                    hero:SetBaseAgility(30)
                else
                    hero:SetBaseStrength(25)
                    hero:SetBaseAgility(25)
                    hero:SetBaseIntellect(25)
                end
            end)
        end
    end

    if text == "-testsetup2" then
        if GameRules:IsCheatMode() then
            self:LoopOverPlayers(function(player, playerID, playerHero)
                local hero = playerHero
                hero.MasterUnit:SetMana(1000)
                hero.MasterUnit2:SetMana(1000)
                hero.MasterUnit:SetMaxHealth(1000)
                hero.MasterUnit:SetHealth(1000)
                hero.MasterUnit2:SetMaxHealth(1000)
                hero.MasterUnit2:SetHealth(1000)
            end)
        end
    end

    if text == "-inven" then
        if Convars:GetBool("sv_cheats") then
            for i=0, 16 do
                if hero:GetItemInSlot(i) then 
                    print(i, hero:GetItemInSlot(i):GetName())
                else
                    print("nil item")
                end
            end
        end
    end

    if text == "-unpause" then
        --[[for _,plyr in pairs(self.vPlayerList) do
        local hr = plyr:GetAssignedHero()
        hr:RemoveModifierByName("round_pause")
    end]]
        if GameRules:IsCheatMode() and GetMapName() ~= "fate_tutorial" then
            self:LoopOverPlayers(function(player, playerID, playerHero)
                local hr = playerHero
                hr:RemoveModifierByName("round_pause")
                --print("Looping through player" .. ply)
            end)
        end
    end
    if text == "-errortest" then
        --[[for _,plyr in pairs(self.vPlayerList) do
        local hr = plyr:GetAssignedHero()
        hr:RemoveModifierByName("round_pause")
    end]]
        if GameRules:IsCheatMode() then
            SendErrorMessage(plyID, "#test_msg")
        end
    end


    if text == "-declarewinner" then
        if Convars:GetBool("sv_cheats") then
            GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        end
    end
    -- manually end the round
    if text == "-finishround" then
        if Convars:GetBool("sv_cheats") then
            self:FinishRound(true, 0)
        end
    end


    if text == "-tt" then
        if Convars:GetBool("sv_cheats") then
            hero.ShardAmount = 10
            print("10 shards")
        end
    end

    if text == "-silence" then
        if Convars:GetBool("sv_cheats") then
            EmitGlobalSound("Silence_Test")
        end
    end

    --[[if text == "-gachi_true" then
        playerHero = ply:GetAssignedHero()
        playerHero.gachi = true
        print("kappa")
    end

    if text == "-gachi_false" then
        playerHero = ply:GetAssignedHero()
        playerHero.gachi = false
    end]]

    if text == "-bgmon" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_bgm_on", {} )
    end

    --[[if text == "-padoru" then
        playerHero = ply:GetAssignedHero()
        if not playerHero.pidor == true then
            LoopOverPlayers(function(player, playerID, playerHero)
                if playerHero.gachi == true then
                    CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="Game_Draw_Xmas"})
                end
            end)
        else
            PlayerResource:SetGold(plyID, 1, true)
        end
        if playerHero.padoru == nil then
            playerHero.padoru = 1
        else
            playerHero.padoru = playerHero.padoru + 1
            if playerHero.padoru > 10 then
                playerHero.pidor = true
                Timers:CreateTimer(10, function()
                    playerHero:RemoveModifierByName("round_pause")
                    DoDamage(playerHero, playerHero, 9999999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, playerHero:GetAbilityByIndex(1), false)
                    CustomGameEventManager:Send_ServerToPlayer(ply, "emit_horn_sound", {sound="Haru_Yo"})
                end)
            end
        end
    end]]

    if text == "-bgmoff" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_bgm_off", {} )
    end

    if text == "-bgmcheck" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_bgm_check", {} )
    end

    if text == "-roll" then
        DoRoll(plyID, 100)
    end

    if text == "-voice on" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "fate_enable_voice", {})
    end

    if text == "-voice off" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "fate_disable_voice", {})
    end

    --hero.AltPart:Switch(text)

    local rollText = string.match(text, "^-roll (%d+)")
    if rollText ~= nil then
        local rollAmount = tonumber(rollText)
        if rollAmount > 0 then
            DoRoll(plyID, tonumber(rollAmount))
        end
    end

    -- Sets default gold sent when -1 is typed. By default, hero.defaultSendGold is 300.
    local newDefaultGold = string.match(text, "^-set (%d+)")
    if newDefaultGold ~= nil then
        hero.defaultSendGold = newDefaultGold
    end

    local pID, goldAmt = string.match(text, "^-(%d%d?) (%d+)")

    if pID == nil and goldAmt == nil then
        local pID2 = string.match(text, "^-(%d%d?)") -- these 5 lines give a default 300/(whatever you set) gold to teammate if gold amount not specified.
        if pID2 ~= nil then
            pID = pID2
            goldAmt = hero.defaultSendGold
            print(goldAmt)
        end
    end

    if pID ~= nil and goldAmt ~= nil then
        print(goldAmt)
        --if GameRules:IsCheatMode() then
        --SendChatToPanorama("player " .. plyID .. " is trying to send " .. goldAmt .. " gold to player " .. pID)
        --end
        if PlayerResource:GetReliableGold(plyID) >= tonumber(goldAmt) and plyID ~= tonumber(pID) and PlayerResource:GetTeam(plyID) == PlayerResource:GetTeam(tonumber(pID)) and tonumber(goldAmt) > 0 then
            print('Gold Start : ' .. PlayerResource:GetReliableGold(plyID))
            local targetHero = PlayerResource:GetPlayer(tonumber(pID)):GetAssignedHero()
            hero:SetGold(0, false)
            hero:SetGold(hero:GetGold() - goldAmt, true)
            --hero:ModifyGold(-tonumber(goldAmt), true , 0)
            targetHero:SetGold(0, false)
            targetHero:SetGold(targetHero:GetGold() + goldAmt, true)
            --targetHero:ModifyGold(tonumber(goldAmt), true, 0)
            CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "fate_gold_sent", {goldAmt=tonumber(goldAmt), sender=hero:entindex(), recipent=targetHero:entindex()} )
            --GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> sent " .. goldAmt .. " gold to <font color='#58ACFA'>" .. targetHero.name .. "</font>" , hero:GetTeamNumber(), hero:GetPlayerOwnerID())
        elseif PlayerResource:GetReliableGold(plyID) < tonumber(goldAmt) and plyID ~= tonumber(pID) and PlayerResource:GetTeam(plyID) == PlayerResource:GetTeam(tonumber(pID)) and tonumber(goldAmt) > 0 then
            -- This elseif condition is for when your gold is below the default 300 or whatever you set, that you send the rest of your gold to teammate.
            local targetHero = PlayerResource:GetPlayer(tonumber(pID)):GetAssignedHero()
            goldAmt = PlayerResource:GetReliableGold(plyID)
            hero:SetGold(0, false)
            hero:SetGold(0, true)
            --hero:ModifyGold(-goldAmt, true , 0)
            targetHero:SetGold(0, false)
            targetHero:SetGold(targetHero:GetGold() + goldAmt, true)
            --targetHero:ModifyGold(goldAmt, true, 0)
            CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "fate_gold_sent", {goldAmt=tonumber(goldAmt), sender=hero:entindex(), recipent=targetHero:entindex()} )
            --GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> sent " .. goldAmt .. " gold to <font color='#58ACFA'>" .. targetHero.name .. "</font>" , hero:GetTeamNumber(), hero:GetPlayerOwnerID())
        end
    end

    -- handles -all commands
    local limit = string.match(text, "^-all (%d+)")
    -- distribute excess gold above 5K
    if text == "-all" then
        if PlayerResource:GetReliableGold(plyID) >= 5000 then
            DistributeGoldV2(hero, 4950)
        end
    end

    if text == "-dmg" then
        if hero.AntiSpamCooldown1 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, math.floor(playerHero.ServStat.damageDealt/playerHero.ServStat.round))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown1 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown1 = false
            end)
            Say(hero:GetPlayerOwner(), "Average damage done per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    if text == "-tank" then
        if hero.AntiSpamCooldown2 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, math.floor(playerHero.ServStat.damageTaken/playerHero.ServStat.round))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown2 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown2 = false
            end)
            Say(hero:GetPlayerOwner(), "Average damage taken per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    if text == "-c" then
        if hero.AntiSpamCooldown3 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, round(playerHero.ServStat.cScroll/playerHero.ServStat.round,2))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown3 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown3 = false
            end)
            Say(hero:GetPlayerOwner(), "Average number of C scrolls used per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    if text == "-ward" then
        if hero.AntiSpamCooldown4 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, round(playerHero.ServStat.ward/playerHero.ServStat.round,2))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown4 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown4 = false
            end)
            Say(hero:GetPlayerOwner(), "Average number of wards used per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    if text == "-bird" then
        if hero.AntiSpamCooldown5 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, round(playerHero.ServStat.familiar/playerHero.ServStat.round,2))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown5 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown5 = false
            end)
            Say(hero:GetPlayerOwner(), "Average number of familiars used per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    if text == "-avarice" then
        if hero.AntiSpamCooldown6 ~= true then
            hero.AntiSpamCooldown6 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown6 = false
            end)
            if hero.AvariceCount == nil then hero.AvariceCount = 0 end
            Say(hero:GetPlayerOwner(), "Total Avarice: " .. hero.AvariceCount, true) 
        end
    end

    if text == "-heal" then
        if hero.AntiSpamCooldown7 ~= true then
            local teamHeroes = {}
            local values = {}
            local rank = {}
            LoopOverPlayers(function(ply, plyID, playerHero)
                if playerHero:GetTeamNumber() == hero:GetTeamNumber() then
                    table.insert(teamHeroes, FindName(playerHero:GetName()))
                    table.insert(values, round(playerHero.ServStat.heal/playerHero.ServStat.round,2))
                end
            end)
            for index,value in spairs(values, function(values,a,b) return values[b] < values[a] end) do
                table.insert(rank, index)
            end
            hero.AntiSpamCooldown7 = true
            Timers:CreateTimer(20, function()
                hero.AntiSpamCooldown7 = false
            end)
            Say(hero:GetPlayerOwner(), "Average heal per round: ".."Top: "..tostring(teamHeroes[rank[1]])..", "..tostring(values[rank[1]])..". 2nd: "..tostring(teamHeroes[rank[2]])..", "..tostring(values[rank[2]])..". 3rd: "..tostring(teamHeroes[rank[3]])..", "..tostring(values[rank[3]])..".", true) 
        end
    end

    -- distribute excess gold above specified amount
    if limit then
        DistributeGoldV2(hero, tonumber(limit))
    end

    if text == "-resetcombo" then 
        if GameRules:IsCheatMode() or Convars:GetBool("sv_cheats") or IsInToolsMode() then
            LoopOverPlayers(function(ply, plyID, playerHero)
                RemoveComboCD(playerHero)
            end)
            
        end
    end

    if text == "-dbhruntproh" then 
        if IsInToolsMode() then
            print('db hrunt prob is working')
            ServerTables:SetTableValue("Condition", "dbhruntproh", true, true)
            if ServerTables:GetTableValue("GameMode", "mode") == "classic" then 
                print('classic mode')
            end
            if ServerTables:GetTableValue("Condition", "dbhruntproh") == true then
                print('double hrunt is prohibited')
            end
        end
    end

    if text == "-fastui" then 
        if IsInToolsMode() then
            CustomGameEventManager:Send_ServerToAllClients("close_ui", {close = true})
        end
    end

    local goldamountinchat = string.match(text, "^-getgold (%d+)")

    if goldamountinchat then
        if Convars:GetBool("sv_cheats") then
            PlayerResource:SetGold(plyID, tonumber(goldamountinchat), true)
        end
    end

    if text == "-resetgold" then
        if Convars:GetBool("sv_cheats") then
            LoopOverPlayers(function(ply, plyID, playerHero)
                PlayerResource:SetGold(plyID, 0, true)
                PlayerResource:SetGold(plyID, 0, false)
            end)
        end
    end

    if text == "-reconnect" then
        if GameRules:IsCheatMode() or IsInToolsMode() then
            self:OnPlayerReconnect({PlayerID=plyID})
        end
    end

    if text == "-dbtest" then
        if GameRules:IsCheatMode() or IsInToolsMode() then
            kjlpluo1596:initialize(plyID,1)
        end
    end

    if text == "-dc" then
        if GameRules:IsCheatMode() or IsInToolsMode() then
            self:OnDisconnect({PlayerID=plyID})
        end
    end

    if text == "-rq" then
        if GameRules:IsCheatMode() or IsInToolsMode() then
            self:OnDisconnect({PlayerID=plyID, RQTest=1})
        end
    end

    if text == "-sealtest" then
        if Convars:GetBool("sv_cheats") then
            hero.MasterUnit:SetMana(10)
            hero.MasterUnit2:SetMana(10)
        end
    end
    
    if text == "-ir" then
        if IsInToolsMode() then
          ROUND_DURATION = 86400
        end
    end

    -- Asks team for gold
    if text == "-goldpls" then
        --GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (gold amount) </font>to help him out!" , hero:GetTeamNumber(), hero:GetPlayerOwnerID())
        Notifications:RightToTeamGold(hero:GetTeam(), "<font color='#FF5050'>" .. FindName(hero:GetName()) .. "</font> at <font color='#FFD700'>" .. hero:GetGold() .. "g</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (goldamount)</font> to send gold!", 5, nil, {color="rgb(255,255,255)", ["font-size"]="20px"}, false)
    end

    local statID = string.match(text, "^-ss (%d+)")

    if statID and PlayerResource:GetPlayer(tonumber(statID)) then
        local herostat = PlayerResource:GetPlayer(tonumber(statID)):GetAssignedHero()
        herostat.ServStat:printconsole()
    end

    if text == "-ss" then
        hero.ServStat:printconsole()
    end

    if text == "-nplayer" then
        print(self.numberOfPlayersInTeam, "is the number of players in a team")
    end

    local heroText = string.match(text, "^-pick (.+)")
    if heroText ~= nil then
        if GameRules:IsCheatMode() then
            Selection:RemoveHero(heroText)
        end
    end

    local plyidd, alterna = string.match(text, "^-alternate(%d%d?) (%d+)")
    local alvl = PlayerTables:GetTableValue("authority", 'alvl', plyID)
    if plyidd ~= nil and alterna ~= nil then
        if alvl == 5 then 
            local serv = PlayerResource:GetPlayer(tonumber(plyidd)):GetAssignedHero()
            serv.Skin = alterna
            if serv:HasModifier("modifier_alternate_0" .. tonumber(alterna)) then 
                serv:RemoveAbility("alternative_0" .. tonumber(alterna))
                serv:RemoveModifierByName("modifier_alternate_0" .. tonumber(alterna))
            else
                serv:AddAbility("alternative_0" .. tonumber(alterna))
                serv:FindAbilityByName("alternative_0" .. tonumber(alterna)):SetLevel(1)
            end
            return false
        end
    end

    local ascension = string.match(text, "^-ascension")
    if ascension ~= nil then
        Ascension:Ascend(keys)
    end

    local undoascension = string.match(text, "^-undoascension")
    if undoascension ~= nil then
        Ascension:UndoAscension(keys)
    end



    if text == "-addbot" then 
        if alvl == 5 and IsInToolsMode() then 
            for i = 0, 13 do 
                if i == 0 then 
                    yedped:syipl(0, 1250)
                else
                    Tutorial:AddBot("npc_dota_hero_axe", "", "", false)
                    if i > 0 and i < 8 then
                        PlayerResource:SetCustomTeamAssignment(i, 3)
                    else
                        PlayerResource:SetCustomTeamAssignment(i, 2)
                    end
                    --Timers:CreateTimer(i * 0.1, function()
                        yedped:syipl(i, RandomInt(1000, 1700))
                    --end)
                end
            end
        end
    end
    --[[local botttid, team = string.match(text, "^-addbot(%d%d?) (%d+)")
    if botttid ~= nil and team ~= nil then
        if alvl == 5 and IsInToolsMode() then 
            Tutorial:AddBot("", "", "", false)
            PlayerResource:SetCustomTeamAssignment(tonumber(botttid), tonumber(team))
            yedped:syipl(tonumber(botttid), RandomInt(1000, 1600))
            yedped:syipl(plyID, 1250)
        end
    end]]

    local botid, team = string.match(text, "^-team(%d%d?) (%d+)")
    if botid ~= nil and team ~= nil then
        if alvl == 5 and IsInToolsMode() then 
            PlayerResource:SetCustomTeamAssignment(tonumber(botid), tonumber(team))
        end
    end

    if text == "-resetui" then 
        if alvl == 5 and IsInToolsMode() then 
            --yedped:ablyo()
            CustomGameEventManager:Send_ServerToAllClients("restart_scoreboard", {reset = true})
        end
    end

    if text == "-origin" then 
        if alvl == 5 and IsInToolsMode() then 
            --yedped:ablyo()
            print('origin = ' .. tostring(hero:GetOrigin()))
        end
    end

    if text == "-rebalance" then 
        if alvl == 5 and IsInToolsMode() then 
            yedped:ablyo()
            --CustomGameEventManager:Send_ServerToAllClients("restart_scoreboard", {reset = true})
        end
    end

    local rround = string.match(text, "restart_round")
    if rround ~= nil then 
        if alvl == 5 then 
            GameRules.AddonTemplate:FinishRound(true, 2)
        end
    end

    local kghi = string.match(text, 'keyd')
    if kghi ~= nil then 
        if alvl == 5 then 
            CheckALVL(ply)
        end
    end
end

function DoRoll(playerId, num)
  print(playerId)
    local roll = RandomInt(1, num)
    local message = "_gray__arrow_ _default_ Rolls _gold_" .. roll .. "_default_ out of " .. num
    local keys = {
        PlayerID = playerId,
        message = message,
        toAll = true
    }
    OnPlayerAltClick(nil, keys)
end

function OnPlayerAltClick(eventSourceIndex, keys)
    local playerId = keys.PlayerID
    local player = PlayerResource:GetPlayer(playerId)
    local altClickTime = player.altClickTime
    local currentTime = GetSystemTime()
    if currentTime == altClickTime then
        return
    end
    player.altClickTime = currentTime
    local message = SubstituteMessageCodes(keys.message)
    Say(player, message, not keys.toAll)
end

function OnPlayerSay(eventSourceIndex, args)
    local playerId = args.playerId
    local player = PlayerResource:GetPlayer(playerId)
    local message = args.message
    Say(player, message, true)
end

function OnPlayerRemoveBuff(iSource, args)
    local iPlayer = args.PlayerID
    local hUnit = EntIndexToHScript(args.iUnit)

    if iPlayer == hUnit:GetPlayerOwnerID() then
        hUnit:RemoveModifierByName(args.sModifier)
    end
end

function OnPlayerCastSeal(iSource, args)
    local iPlayer = args.PlayerID
    local hUnit = EntIndexToHScript(args.iUnit)
    local hAbility = EntIndexToHScript(args.iAbility)

    if iPlayer == hUnit:GetPlayerOwnerID() then
        if hUnit.HeroUnit and not hUnit.HeroUnit:IsAlive() then
            SendErrorMessage(iPlayer, "Hero is dead")
        end

        if hAbility:GetName() == "cmd_seal_4" then
            if IsManaLess(hUnit.HeroUnit) --[[hUnit.HeroUnit:GetName() == "npc_dota_hero_juggernaut" or hUnit.HeroUnit:GetName() == "npc_dota_hero_shadow_shaman"]] then
                SendErrorMessage(iPlayer, "Cannot use Command Seal 4")
            end
        end

        if hUnit:GetMana() < hAbility:GetManaCost(1) then
            SendErrorMessage(iPlayer, "Not enough mana")
        elseif hUnit:GetHealth() <= 1 then
            SendErrorMessage(iPlayer, "Not enough master health")
        else
            --For some reason this thing ignores the cast filter SeemsGood
            hUnit:CastAbilityNoTarget(hAbility, iPlayer)
        end
    end
end

function OnPlayerHotkeySeal(iSource, args)
    local iPlayer = args.PlayerID
    local hHero = EntIndexToHScript(args.iHero)
    local iAbility = args.iAbility

    if iPlayer == hHero:GetPlayerOwnerID() then
        if hHero and not hHero:IsAlive() then
            SendErrorMessage(iPlayer, "Hero is dead")
        end

        local hUnit = hHero.MasterUnit
        local hAbility = hUnit:GetAbilityByIndex(iAbility)
        
        if hAbility:GetName() == "cmd_seal_4" then
            if IsManaLess(hUnit.HeroUnit) --[[hUnit.HeroUnit:GetName() == "npc_dota_hero_juggernaut" or hUnit.HeroUnit:GetName() == "npc_dota_hero_shadow_shaman"]] then
                SendErrorMessage(iPlayer, "Cannot use Command Seal 4")
            end
        end

        if hUnit:GetMana() < hAbility:GetManaCost(1) then
            SendErrorMessage(iPlayer, "Not enough mana")
        elseif hUnit:GetHealth() <= 1 then
            SendErrorMessage(iPlayer, "Not enough master health")
        else
            --For some reason this thing ignores the cast filter SeemsGood
            hUnit:CastAbilityNoTarget(hAbility, iPlayer)
        end
    end
end

function DistributeGold(hero, cutoff)
    -- get gold amount of teammates
    -- exclude from table if more than stated amount
    -- sort them by amount of current gold
    local playerTable = {}
    local playerID = hero:GetPlayerID()
    if PlayerResource:GetReliableGold(playerID) < cutoff then return end
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() == hero:GetTeamNumber() and plyID ~= playerID then
            local pGold = PlayerResource:GetReliableGold(plyID)
            if pGold < 5000 then
                playerTable[plyID] = pGold
                print(playerHero:GetName())
            end
        end
    end)

    -- local sortedTable = spairs(playerTable, function(t,a,b) return t[b] < t[a] end)
    local residue = 0
    local goldPerPerson =  (PlayerResource:GetReliableGold(playerID)-cutoff)/#playerTable

    -- eligible players
    for pID,curGold in spairs(playerTable, function(t,a,b) return t[b] < t[a] end) do
        local eligibleGoldAmt = 5000 - PlayerResource:GetReliableGold(pID)
        -- only grant eligible amount of gold and save the rest on residue
        if goldPerPerson > eligibleGoldAmt then
            residue = residue + goldPerPerson - eligibleGoldAmt
            GiveGold(playerID, pID, eligibleGoldAmt)
        -- add residue up
        else
            if goldPerPerson + residue > eligibleGoldAmt then
                residue = goldPerPerson + residue - eligibleGoldAmt
                GiveGold(playerID, pID, eligibleGoldAmt)
            else
                GiveGold(playerID, pID, goldPerPerson+residue)
            end
        end
    end
end

function DistributeGoldV2(hero, cutoff)
    -- get gold amount of teammates
    -- exclude from table if more than 4950

    local goldTable = {}
    local plyIDTable = {}
    local playerID = hero:GetPlayerID()
    if PlayerResource:GetReliableGold(playerID) < cutoff then return end
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() == hero:GetTeamNumber() and plyID ~= playerID then
            local pGold = PlayerResource:GetReliableGold(plyID)
            if pGold < 4950 then
                table.insert(goldTable, pGold)
                table.insert(plyIDTable, plyID)
                --print(plyID)
                --print(pGold)
            end
        end
    end)

    -- quite hard to explain
    -- first attempt the scenario where u give everyone gold such that everyone reaches 4950 gold whereas you still have excess gold above cutoff, this is for the if statement
    -- else you start looking at the richest guy within the people who has less than 4950 gold. suppose the richest guy is 4400 gold, you will now attempt to give everyone gold such that
    -- everyone reaches 4400 or more. 
    -- If this is possible, the excess gold per person (assuming u have given everyone gold such that they reach 4400) can be computed, stored as moreGoldPerPerson. 
    -- The for loop proceeds to make everyone's gold (4400+moreGoldPerPerson). We then terminate the while loop by setting bRecurse = false
    -- However if this is still not possible, we kick the highest guy within the table out of plyIDTable, and also the associated 4400 gold within the goldTable. Because he is no longer eligible for gold
    -- The while loop condition is still satisfied, process repeats again but this time you look at 2nd richest guy among the people with <4950 gold.

    if (4950 * #plyIDTable - SumTable(goldTable)) <= (PlayerResource:GetReliableGold(playerID)-cutoff) then 
        for k,gold in spairs(goldTable) do
            local eligibleGoldAmt = 4950 - gold
            GiveGold(playerID, plyIDTable[k], eligibleGoldAmt)
            CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "fate_gold_sent", {goldAmt=tonumber(eligibleGoldAmt), sender=hero:entindex(), recipent=PlayerResource:GetPlayer(tonumber(plyIDTable[k])):GetAssignedHero():entindex()} )
        end
    else
        local bRecurse = true
        while (bRecurse == true) do
            local index, highestGold = MaxNumTable(goldTable)
            if (highestGold * #plyIDTable - SumTable(goldTable)) <= (PlayerResource:GetReliableGold(playerID)-cutoff) then 
                local moreGoldPerPerson = math.floor(((PlayerResource:GetReliableGold(playerID)-cutoff) - (highestGold * #plyIDTable - SumTable(goldTable)))/#plyIDTable)
                for k,gold in spairs(goldTable) do
                    local eligibleGoldAmt = highestGold - gold + moreGoldPerPerson
                    GiveGold(playerID, plyIDTable[k], eligibleGoldAmt)
                    CustomGameEventManager:Send_ServerToTeam(hero:GetTeamNumber(), "fate_gold_sent", {goldAmt=tonumber(eligibleGoldAmt), sender=hero:entindex(), recipent=PlayerResource:GetPlayer(tonumber(plyIDTable[k])):GetAssignedHero():entindex()} )
                end
                bRecurse = false
            else
                table.remove(goldTable,index)
                table.remove(plyIDTable,index)
            end
        end
    end
end

-- The overall game state has changed
function FateGameMode:OnGameRulesStateChange(keys)
    --print("[BAREBONES] GameRules State Changed")

    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
        self.bSeenWaitForPlayers = true
        print('wait player')
    elseif newState == DOTA_GAMERULES_STATE_INIT then
        print('init state') 
        --[[if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            if self.Draft == true and votemodeResultTable.v_OPTION_2 > votemodeResultTable.v_OPTION_1 then
                GameRules:SetPreGameTime(370)
            else
                GameRules:SetPreGameTime(60)
            end
        end]]
    elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        print('custom game setup')
        FateGameMode:OnPlayerConnects()
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    --SendToConsole("r_farz 5000")
    --Convars:SetInt("r_farz", 3300)
        Timers:CreateTimer(2, function()
            FateGameMode:OnAllPlayersLoaded()
            self:OnEventChecking()
            if string.match( GetMapName(), "fate_elim") then
                local total_player = ServerTables:GetTableValue("Players", "total_player")
                
                if ServerTables:GetTableValue("GameModeChoice", "dm") == true and self.votemodeResultTable.v_OPTION_2 >= 1 then
                    Selection = DraftSelectioN()
                    --Selection:UpdateTime()
                    ServerTables:SetTableValue("GameMode", "mode", "draft", true)
                    --_G.DRAFT_MODE = true
                else
                    if self.votemodeResultTable.v_OPTION_3 >= 1 then
                        ServerTables:SetTableValue("GameMode", "mode", "samehero", true)
                    end
                    Selection = HeroSelectioN()
                    --Selection:UpdateTime()
                    --_G.DRAFT_MODE = false
                    --[[Timers:CreateTimer(85, function()
                        GameRules:ForceGameStart()
                    end)]]
                end 
            else
                Selection = HeroSelectioN()
                --Selection:UpdateTime()          
            end
        end)            
    elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        -- screw 7.00
    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        FateGameMode:OnGameInProgress()
    end
end

-- An NPC has spawned somewhere in game. This includes heroes
function FateGameMode:OnNPCSpawned(keys)
   -- print("[BAREBONES] NPC Spawned")
    --[[for k,v in pairs(keys) do
        print(k,v)
    end]]
    local hero = EntIndexToHScript(keys.entindex)
    Wrappers.WrapUnit(hero)

    if hero:IsRealHero() and hero.bFirstSpawned == nil then
        local playerID = hero:GetPlayerID()
        if playerID ~= nil and playerID ~= -1 then
            FateGameMode:OnHeroInGame(hero)
        end
    end
end

--[[
This function is called once and only once for every player when they spawn into the game for the first time. It is also called
    if the player's hero is replaced with a new hero for any reason. This function is useful for initializing heroes, such as adding
        levels, changing the starting gold, removing/adding abilities, adding physics, etc.
        The hero parameter is the hero entity that just spawned in
        ]]
local team2HeroesSpawned = 0
local team3HeroesSpawn = 0

function FateGameMode:OnHeroInGame(hero)
  --  print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
    --Add a non-player hero to player list if it's missing(i.e generated by -createhero)
    if self.vBots[hero:GetPlayerID()] == 1 then
        print((hero:GetPlayerID()) .." is a bot!")
        self.vPlayerList[hero:GetPlayerID()] = hero:GetPlayerID()
        PlayerTables:CreateTable("hHero", {io = "nil", hero = "nil", hid = 0, skin = 0, hhero = "nil", master1 = "nil", master2 = "nil", master3 = "nil"}, hero:GetPlayerID())
    end
    if hero:GetName() == "npc_dota_hero_wisp" then
        PlayerTables:CreateTable("hHero", {io = hero:entindex(), hero = "nil", hid = 0, skin = 0, hhero = "nil", master1 = "nil", master2 = "nil", master3 = "nil"}, hero:GetPlayerOwnerID())
        local dummyPause = hero:GetAbilityByIndex(0)
        dummyPause:SetLevel(1)
        dummyPause:ApplyDataDrivenModifier(hero, hero, "modifier_dummy_pause", {duration=9999})
        return
    end
    local ability_count = hero:GetAbilityCount()
    --print('hero ' .. hero:GetName() .. ' has ' .. ability_count .. ' abilities.')
    for i = fate_ability_count[hero:GetName()], ability_count do
        local abil = hero:GetAbilityByIndex(i)
        if abil == nil then 
            break 
        end
        --if string.match(abil:GetAbilityName(), "special_bonus_unique") or string.match(abil:GetAbilityName(),string.gsub(hero:GetName(), "npc_dota_hero_", "")) then
            hero:RemoveAbility(abil:GetAbilityName())
        --    print('ability ' .. i .. ': abil_name ' .. abil:GetAbilityName() .. " deleted")
       -- end
        --print('ability ' .. i .. ': abil_name' .. abil:GetAbilityName())
    end

    -- Initialize stuffs
    hero:SetCustomDeathXP(0)
    hero.bFirstSpawned = true
    --UnitVoice(hero)
    hero.PresenceTable = {}
    hero.bIsDmgPopupDisabled = false
    hero.bIsAlertSoundDisabled = false
    hero:SetAbilityPoints(0)
    hero:SetGold(0, false)
    hero:SetGold(SPAWN_GOLD, true)
    hero.OriginalModel = hero:GetModelName()
    hero.BaseArmor = hero:GetPhysicalArmorBaseValue()
    hero.Notify = false
    hero.IsFreeWarpUse = false 
    hero.IsWarpCooldown = false
    LevelAllAbility(hero)
    local Skin = PlayerTables:GetTableValue("hHero", 'skin', hero:GetPlayerOwnerID()) or 0
    hero.Skin = Skin

    hero:AddItem(CreateItem("item_blink_scroll", nil, nil) ) 
    hero:AddItem(CreateItem("item_dummy_item_unusable", nil, nil))
    hero:AddItem(CreateItem("item_dummy_item_unusable", nil, nil))
    hero:AddItem(CreateItem("item_dummy_item_unusable", nil, nil))
    Timers:CreateTimer(0.25, function() hero:SwapItems(DOTA_ITEM_SLOT_2, DOTA_ITEM_SLOT_7) end)
    Timers:CreateTimer(0.5, function() hero:SwapItems(DOTA_ITEM_SLOT_3, DOTA_ITEM_SLOT_8) end)
    Timers:CreateTimer(0.75, function() hero:SwapItems(DOTA_ITEM_SLOT_4, DOTA_ITEM_SLOT_9) end)
        -- Give blink scroll
         -- Remove TP Scroll
        --[[local hTp = hero:FindItemInInventory('item_tpscroll')
        if hTp then
            hero:RemoveItem(hTp)
        end]]
    

    -- Removing Talents
    for i=0,23 do
        if hero:GetAbilityByIndex(i) ~= nil then
            local ability = hero:GetAbilityByIndex(i)
            if string.match(ability:GetName(),"special_bonus") then
                hero:RemoveAbility(ability:GetName())
            end
        end
    end
    --END

    -- Initialize Alternate Particles.
    hero.AltPart = AlternateParticle:initialise(hero)

    -- Initialize Servant Statistics, and related collection stuff
    hero.ServStat = ServantStatistics:initialise(hero)
    hero.ServStat:roundNumber(self.nCurrentRound) -- to properly initialise the current round number when player picks a hero late. 
    giveUnitDataDrivenModifier(hero, hero, "modifier_damage_collection", {})
    -- END

    PlayerTables:SetTableValue("hHero", "hhero", hero:entindex(), hero:GetPlayerOwnerID(), true)

    --if HasSpellBook(hero) then 
        GenerateAbilitiesData(hero)
    --end

    hero.defaultSendGold = 300
    hero.CStock = 10
    hero.ShardAmount = 0
    hero.IsHeroSpawn = true

    Timers:CreateTimer(1.0, function()
        if hero.Skin > 0 then 
            hero:AddAbility("alternative_0" .. hero.Skin)
            hero:FindAbilityByName("alternative_0" .. hero.Skin):SetLevel(1)
        end
        local team = hero:GetTeam()
        local currentRound = self.nCurrentRound
        if _G.GameMap == "fate_ffa" then 
            hero.RespawnPos = SPAWN_POSITION_FFA[hero:GetTeamNumber()]
            hero:SetAbsOrigin(hero.RespawnPos)
        elseif _G.GameMap == "fate_trio" then
            if team == 2 then
                hero.RespawnPos = SPAWN_POSITION_TRIO1
            elseif team == 3 then 
                hero.RespawnPos = SPAWN_POSITION_TRIO2
            elseif team == 6 then 
                hero.RespawnPos = SPAWN_POSITION_TRIO3
            end
            hero:SetAbsOrigin(hero.RespawnPos + RandomVector(150))
        elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then 
            if team == 2 then
                hero.RespawnPos = SPAWN_POSITION_T1_TRIO
            elseif team == 3 then 
                hero.RespawnPos = SPAWN_POSITION_T2_TRIO
            elseif team == 6 then 
                hero.RespawnPos = SPAWN_POSITION_T3_TRIO
            elseif team == 7 then 
                hero.RespawnPos = SPAWN_POSITION_T4_TRIO
            end
            hero:SetAbsOrigin(hero.RespawnPos + RandomVector(150))
        elseif _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            if team == 2 then
                if currentRound == 0 or currentRound == 1 then
                    hero.RespawnPos = SPAWN_POSITION_RADIANT_DM
                elseif currentRound % 2 == 0 then
                    hero.RespawnPos = SPAWN_POSITION_DIRE_DM
                end
            elseif team == 3 then
                if currentRound == 0 or currentRound == 1 then
                    hero.RespawnPos = SPAWN_POSITION_DIRE_DM
                elseif currentRound % 2 == 0 then
                    hero.RespawnPos = SPAWN_POSITION_RADIANT_DM
                end
            end
        end
        --print("Respawn location registered : " .. hero.RespawnPos.x .. " BY " .. hero:GetName() )
        if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            local index
                if team == 2 then
                    index = team2HeroesSpawned
                    team2HeroesSpawned = team2HeroesSpawned + 1
                else
                    index = team3HeroesSpawn
                    team3HeroesSpawn = team3HeroesSpawn + 1
                end
            local currentRound = self.nCurrentRound
            -- round 0 uses initial spawn position
            local spawnPos = GetRespawnPos(hero, currentRound == 0 and 1 or currentRound, index)
            -- hero seems to spawn in the air so we have to get ground position here
            hero:SetAbsOrigin(GetGroundPosition(spawnPos, nil))
        end
    end)
    hero.bIsDirectTransferEnabled = true -- True by default
    Attributes:ModifyBonuses(hero)

    -- Create Command Seal master for hero
    local master_area = 4500 + hero:GetPlayerOwnerID()*270
    local master = CreateUnitByName("master_1", Vector(master_area,-7050,0), true, hero, hero, hero:GetTeamNumber())
    master:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
    master:SetMana(0)

    hero.MasterUnit = master
    master.HeroUnit = hero
    LevelAllAbility(master)
        
    if IsManaLess(hero) then
        hero:FindAbilityByName("attribute_bonus_custom_no_int"):SetHidden(false)
    else
        hero:FindAbilityByName("attribute_bonus_custom"):SetHidden(false)
    end
    master:AddItem(CreateItem("item_master_transfer_items1", nil, nil))
    master:AddItem(CreateItem("item_master_transfer_items2", nil, nil))
    master:AddItem(CreateItem("item_master_transfer_items3", nil, nil))
    master:AddItem(CreateItem("item_master_transfer_items4", nil, nil))
    master:AddItem(CreateItem("item_master_transfer_items5", nil, nil))
    master:AddItem(CreateItem("item_master_transfer_items6", nil, nil))
    MinimapEvent( hero:GetTeamNumber(), hero, master:GetAbsOrigin().x, master:GetAbsOrigin().y + 500, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5 )

        -- Create attribute/stat master for hero
    --[[Timers:CreateTimer(function()
        if hero.MasterUnit ~= nil then ]]
            local master2 = CreateUnitByName("master_2", Vector(master_area,-7400,0), true, hero, hero, hero:GetTeamNumber())
            master2:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
            master2:SetMana(0)
                
            hero.MasterUnit2 = master2
            master2.HeroUnit = hero
            AddMasterAbility(master2, hero:GetName())
            LevelAllAbility(master2)
            --[[return nil 
        else 
            return 0.1
        end
    end)]]
    
    -- Create item transfer master for hero
    local master3 = CreateUnitByName("npc_dota_courier", Vector(master_area,-7225,200), true, hero, hero, hero:GetTeamNumber())
    master3:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
    hero.MasterUnit3 = master3
    master3.HeroUnit = hero
    master3:RemoveAbility("courier_return_to_base")
    master3:RemoveAbility("courier_go_to_secretshop")
    master3:RemoveAbility("courier_return_stash_items")
    master3:RemoveAbility("courier_take_stash_items")
    master3:RemoveAbility("courier_transfer_items")
    master3:RemoveAbility("courier_burst")
    master3:RemoveAbility("courier_shield")
    master3:RemoveAbility("courier_morph")
    master3:RemoveAbility("courier_take_stash_and_transfer_items")

    master3:AddAbility("master_item_transfer_1")
    master3:AddAbility("master_item_transfer_2")
    master3:AddAbility("master_item_transfer_3")
    master3:AddAbility("master_item_transfer_4")
    master3:AddAbility("master_item_transfer_5")
    master3:AddAbility("master_item_transfer_6")
    master3:AddAbility("master_passive")
    LevelAllAbility(master3)

    master3:SetDayTimeVisionRange(150)
    master3:SetNightTimeVisionRange(150)

    -- Ping master location on minimap
    local pingsign = CreateUnitByName("ping_sign", Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
    pingsign:FindAbilityByName("ping_sign_passive"):SetLevel(1)
    pingsign:SetAbsOrigin(Vector(4500 + hero:GetPlayerOwnerID()*350,-6500,0))
    -- Announce the summon
    local heroName = FindName(hero:GetName())
    hero.name = heroName
    GameRules:SendCustomMessage("#" .. hero:GetName() .."_summon", 0, 0)
    --GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. heroName .. "</font> has been summoned.", 0, 0)

    if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        if self.nCurrentRound == 0 and _G.CurrentGameState == "FATE_PRE_GAME" then
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 100)
        else
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 10)
        end
    elseif _G.GameMap == "fate_tutorial" then 
        TutorialMode:Initialize(hero)
    elseif _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_trio" then
        -- This is timed such that you can start moving when pick screen times out. If you pick a hero late and that game already started, math.max(0,<some negative number>) == 0 thus no pause.
        if _G.CurrentGameState == "FATE_PRE_GAME" then
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 20)
        end
    end

    self:PlayTeamPickSound(hero)

    -- Wait 1 second for loadup
    Timers:CreateTimer(1.0, function()
        --[[if Convars:GetBool("sv_cheats") then
            if _G.GameMap ~= "fate_tutorial" then
                -- hero:RemoveModifierByName("round_pause")
                hero.MasterUnit:SetMana(hero.MasterUnit:GetMaxMana())
                hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMaxMana())

                if IsManaLess(hero) then
                    hero:SetBaseStrength(30)
                    hero:SetBaseAgility(30)
                else
                    hero:SetBaseStrength(25)
                    hero:SetBaseAgility(25)
                    hero:SetBaseIntellect(25)
                end
            end
            NotifyManaAndShard(hero)
        end]]
        PlayerTables:SetTableValue("hHero", "master1", master:entindex(), hero:GetPlayerOwnerID(), true)
        PlayerTables:SetTableValue("hHero", "master2", master2:entindex(), hero:GetPlayerOwnerID(), true)
        PlayerTables:SetTableValue("hHero", "master3", master3:entindex(), hero:GetPlayerOwnerID(), true)
        master3:SetAbsOrigin(Vector(master_area,-7225,200))
        if _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_trio" then
            hero:HeroLevelUp(false)
            hero:HeroLevelUp(false)
        end
        CustomGameEventManager:Send_ServerToAllClients( "victory_condition_set", victoryConditionData ) -- Display victory condition for player
        --SendKVToFatepedia(player) -- send KV to fatepedia

        --[[if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
            self:DraftModeCon(hero)
        end]] 

        if hero:GetName() == "npc_dota_hero_troll_warlord" then
            Attachments:AttachProp(hero, "attach_gun2", "models/drake/drake_gun2.vmdl")
            --Attachments:AttachProp(hero, "attach_gun1", "models/drake/drake_gun1.vmdl")
            hero:FindAbilityByName("drake_sword"):ApplyDataDrivenModifier(hero, hero, "modifier_sword_buff", {})
            --hero:RemoveModifierByName("modifier_pistol_buff")
            Attachments:AttachProp(hero, "attach_sword", "models/drake/drake_sword.vmdl")
            --hero:FindAbilityByName("drake_sword"):ApplyDataDrivenModifier(hero, hero, "modifier_sword_buff", {})
        elseif hero:GetName() == "npc_dota_hero_phantom_assassin" then 
            hero:FindAbilityByName("semiramis_dual_class"):ApplyDataDrivenModifier(hero, hero, "modifier_semiramis_class_caster", {})
        elseif hero:GetName() == "npc_dota_hero_dark_willow" then 
            Attachments:AttachProp(hero, "attach_scabbard", "models/okita/okita_scabbard.vmdl") 
        elseif hero:GetName() == "npc_dota_hero_enigma" then 
            hero:GetAbilityByIndex(0):SetActivated(false)
            Attachments:AttachProp(hero, "attach_sword", "models/amakusa/amakusa_sword.vmdl") 
        elseif hero:GetName() == "npc_dota_hero_axe" then 
            Attachments:AttachProp(hero, "attach_lance", "models/lubu/lubu_lance2.vmdl")   
        elseif hero:GetName() == "npc_dota_hero_death_prophet" then 
            Attachments:AttachProp(hero, "attach_lance", "models/bathory/bathory_weapon.vmdl")   
        elseif hero:GetName() == "npc_dota_hero_sven" then 
            Attachments:AttachProp(hero, "attach_rod", "models/lancelot/lancelot_rod.vmdl")
        elseif hero:GetName() == "npc_dota_hero_zuus" then
            --_G.FranRevive = true
        --[[elseif hero:GetName() == "npc_dota_hero_monkey_king" then
            if ServerTables:GetTableValue("Condition", "divine") == 0 then 
                hero.MasterUnit2:AddAbility("fate_empty3")
                hero.MasterUnit2:FindAbilityByName("scathach_attribute_immortal"):StartCooldown(9999)
                hero.MasterUnit2:SwapAbilities("fate_empty3", "scathach_attribute_immortal", true, false)
                Say(hero:GetPlayerOwner(), "No divinity servant on enemy team.", true)
            end
        elseif hero:GetName() == "npc_dota_hero_riki" then
            if ServerTables:GetTableValue("Condition", "female") == 0 then 
                hero.MasterUnit2:AddAbility("fate_empty3")
                hero.MasterUnit2:FindAbilityByName("jtr_attribute_holy_mother"):StartCooldown(9999)
                hero.MasterUnit2:SwapAbilities("fate_empty3", "jtr_attribute_holy_mother", true, false)
                Say(hero:GetPlayerOwner(), "No female servant on enemy team.", true)
            end]]
        elseif hero:GetName() == "npc_dota_hero_queenofpain" then
            Attachments:AttachProp(hero, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
            if not hero:HasModifier('modifier_alternate_01') and not hero:HasModifier("modifier_alternate_02") and not hero:HasModifier("modifier_alternate_03") and not hero:HasModifier("modifier_alternate_04") then 
                Attachments:AttachProp(hero, "attach_scabbard", "models/astolfo/astolfo_scabbard.vmdl")
            end
        elseif hero:GetName() == "npc_dota_hero_naga_siren" then
            --Attachments:AttachProp(hero, "attach_attack2", "models/kuro/kuro_bow.vmdl")
        end

        local player = hero:GetPlayerOwner()

        local playerData = {
            masterUnit = hero.MasterUnit2:entindex(),
            shardUnit = hero.MasterUnit:entindex(),
            hero = hero:entindex()
        }

        CustomGameEventManager:Send_ServerToPlayer(player, "player_selected_hero", playerData)
        CustomGameEventManager:Send_ServerToPlayer(player, "player_selected_hero2", playerData)
        CustomGameEventManager:Send_ServerToAllClients("player_register_master_unit", playerData)
        self:InitialiseMissingPanoramaData(hero:GetPlayerOwner(),hero,hero.MasterUnit2)
        player:SetMusicStatus(DOTA_MUSIC_STATUS_NONE, 100000)
        if not hero:HasModifier("round_pause") and _G.CurrentGameState == "FATE_PRE_GAME" then 
            if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
                if self.nCurrentRound == 0 and _G.CurrentGameState == "FATE_PRE_GAME" then
                    giveUnitDataDrivenModifier(hero, hero, "round_pause", 75)
                else
                    giveUnitDataDrivenModifier(hero, hero, "round_pause", 9)
                end
            elseif _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_trio" then
                -- This is timed such that you can start moving when pick screen times out. If you pick a hero late and that game already started, math.max(0,<some negative number>) == 0 thus no pause.
                giveUnitDataDrivenModifier(hero, hero, "round_pause", 15)
            end
        end
    end)
end

function FateGameMode:PlayTeamPickSound(hero)
    for i=0, 13 do
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(i)            
        if playerHero ~= nil then
            if playerHero:GetTeam() == hero:GetTeam() then
                if playerHero:GetName() == "npc_dota_hero_phantom_lancer" and hero:GetName() == "npc_dota_hero_ember_spirit" then
                    playerHero:EmitSound("CuChulain_Ally_Emiya")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_ember_spirit" and (hero:GetName() == "npc_dota_hero_skywrath_mage" or hero:GetName() == "npc_dota_hero_phantom_lancer") then
                    playerHero:EmitSound("Emiya_Ally_Gilgamesh_CuChulainn")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_legion_commander" then
                    if hero:GetName() == "npc_dota_hero_omniknight" then
                        playerHero:EmitSound("Saber_Ally_Gawain")
                        break
                    elseif hero:GetName() == "npc_dota_hero_ember_spirit" then
                        playerHero:EmitSound("Saber_Ally_Emiya")
                        break
                    elseif hero:GetName() == "npc_dota_hero_tusk" and playerHero:HasModifier("modifier_alternate_06") then
                        playerHero:EmitSound("Arthur_Ally_Mordred")
                        break
                    end                    
                elseif playerHero:GetName() == "npc_dota_hero_omniknight" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Gawain_Ally_Saber")
                        break
                    elseif hero:GetName() == "npc_dota_hero_sven" then
                        playerHero:EmitSound("Gawain_Ally_Lancelot")
                        break
                    elseif hero:GetName() == "npc_dota_hero_tusk" then
                        playerHero:EmitSound("Gawain_Ally_Mordred")
                        break
                    end                    
                elseif playerHero:GetName() == "npc_dota_hero_shadow_shaman" and hero:GetName() == "npc_dota_hero_legion_commander" then
                    playerHero:EmitSound("Gilles_Ally_Arturia")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_chen" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Iskandar_Ally_Arturia")
                        break
                    elseif hero:GetName() == "npc_dota_hero_skywrath_mage" then
                        playerHero:EmitSound("Iskandar_Ally_Gilgamesh")
                        break
                    elseif hero:GetName() == "npc_dota_hero_disruptor" then
                        playerHero:EmitSound("Iskandar_Ally_Zhuge_Liang")
                        break
                    end                    
                elseif playerHero:GetName() == "npc_dota_hero_crystal_maiden" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Medea_Ally_Arturia")
                        break
                    elseif hero:GetName() == "npc_dota_hero_doom_bringer" then
                        playerHero:EmitSound("Medea_Ally_Heracles")
                        break
                    end                    
                elseif playerHero:GetName() == "npc_dota_hero_huskar" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Diarmuid_Ally_Arthuria_" .. math.random(1,2))
                        break
                    elseif hero:GetName() == "npc_dota_hero_phantom_lancer" then
                        playerHero:EmitSound("Diarmuid_Ally_CuChulainn")
                        break
                    end
                elseif playerHero:GetName() == "npc_dota_hero_templar_assassin" and hero:GetName() == "npc_dota_hero_crystal_maiden" then
                    playerHero:EmitSound("Medusa_Ally_Medea")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_skywrath_mage" and hero:GetName() == "npc_dota_hero_legion_commander" then
                    playerHero:EmitSound("Gilgamesh_Ally_Arturia")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_lina" and hero:GetName() == "npc_dota_hero_enchantress" then
                    playerHero:EmitSound("Nero_Ally_Tamamo")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_enchantress" and hero:GetName() == "npc_dota_hero_lina" then
                    playerHero:EmitSound("Tamamo_Ally_Nero")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_dark_willow" and hero:GetName() == "npc_dota_hero_juggernaut" then
                    playerHero:EmitSound("Okita_Ally_FA")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_necrolyte" and hero:GetName() == "npc_dota_hero_windrunner" then
                    playerHero:EmitSound("Hans_Ally_Nursery")
                    break   
                elseif playerHero:GetName() == "npc_dota_hero_monkey_king" and hero:GetName() == "npc_dota_hero_phantom_lancer" then
                    playerHero:EmitSound("Scathach_Ally_Cu")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_phantom_lancer" and hero:GetName() == "npc_dota_hero_monkey_king" then
                    playerHero:EmitSound("CuChulain_Ally_Scathach")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_tusk" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Mordred_Ally_Arthur")
                        break
                    elseif hero:GetName() == "npc_dota_hero_spectre" then
                        playerHero:EmitSound("Mordred_Ally_Arthur")
                        break
                    elseif hero:GetName() == "npc_dota_hero_sven" then
                        playerHero:EmitSound("Mordred_Ally_Lancelot")
                        break
                    elseif hero:GetName() == "npc_dota_hero_omniknight" then
                        playerHero:EmitSound("Mordred_Ally_Gawain")
                        break
                    end  
                elseif playerHero:GetName() == "npc_dota_hero_death_prophet" then
                    if hero:GetName() == "npc_dota_hero_skywrath_mage" then
                        playerHero:EmitSound("Bathory_Ally_Gilgamesh")
                        break
                    end  
                elseif playerHero:GetName() == "npc_dota_hero_enigma" then
                    if hero:GetName() == "npc_dota_hero_tusk" then
                        playerHero:EmitSound("Amakusa_Ally_Mordred")
                        break
                    elseif hero:GetName() == "npc_dota_hero_mirana" then
                        if hero:HasModifier("modifier_alternate_02") then
                            playerHero:EmitSound("Amakusa_Ally_Jeanne_Santa")
                            break
                        else
                            playerHero:EmitSound("Amakusa_Ally_Jeanne")
                            break
                        end
                    elseif hero:GetName() == "npc_dota_hero_phantom_assassin" then
                        playerHero:EmitSound("Amakusa_Ally_Semiramis")
                        break
                    end
                elseif playerHero:GetName() == "npc_dota_hero_night_stalker" then
                    if hero:GetName() == "npc_dota_hero_vengefulspirit" then
                        playerHero:EmitSound("Edmond_Ally_Angra")
                        break
                    elseif hero:GetName() == "npc_dota_hero_enigma" or hero:GetName() == "npc_dota_hero_mirana" then
                        playerHero:EmitSound("Edmond_Ally_Shirou_Jeanne")
                        break
                    end
                elseif playerHero:GetName() == "npc_dota_hero_disruptor" then
                    if hero:GetName() == "npc_dota_hero_legion_commander" or hero:GetName() == "npc_dota_hero_spectre" then
                        playerHero:EmitSound("Zhuge_Liang_Ally_Artoria")
                        break
                    elseif hero:GetName() == "npc_dota_hero_skywrath_mage" then
                        playerHero:EmitSound("Zhuge_Liang_Ally_Gilgamesh")
                        break
                    elseif hero:GetName() == "npc_dota_hero_chen" then
                        playerHero:EmitSound("Zhuge_Liang_Ally_Iskandar")
                        break
                    end 
                elseif playerHero:GetName() == "npc_dota_hero_skeleton_king" then 
                    if hero:GetName() == "npc_dota_hero_bounty_hunter" then 
                        playerHero:EmitSound("King_Hassan_Ally_Hassan")
                        break
                    end 
                end
            else
                if playerHero:GetName() == "npc_dota_hero_shadow_shaman" then
                    if hero:GetName() == "npc_dota_hero_mirana" then
                        playerHero:EmitSound("Gilles_Enemy_Jeanne")
                        break
                    elseif hero:GetName() == "npc_dota_hero_legion_commander" then
                        playerHero:EmitSound("Gilles_Enemy_Arturia")
                        break
                    end
                elseif playerHero:GetName() == "npc_dota_hero_drow_ranger" and hero:GetName() == "npc_dota_hero_mirana" then
                    playerHero:EmitSound("Atalanta_Enemy_Jeanne")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_huskar" and hero:GetName() == "npc_dota_hero_legion_commander" then
                    playerHero:EmitSound("Diarmuid_Enemy_Arthuria")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_skywrath_mage" and hero:GetName() == "npc_dota_hero_ember_spirit" then
                    playerHero:EmitSound("Gilgamesh_Enemy_Emiya")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_omniknight" and hero:GetName() == "npc_dota_hero_legion_commander" then
                    playerHero:EmitSound("Gawain_Enemy_Saber")
                    break
                elseif playerHero:GetName() == "npc_dota_hero_legion_commander" and hero:GetName() == "npc_dota_hero_omniknight" then
                    playerHero:EmitSound("Saber_Enemy_Gawain")
                    break
                end
            end

        end
    end
end

-- This is for swapping hero models in
function FateGameMode:OnHeroSpawned( keys )

end

-- An entity somewhere has been hurt. This event fires very often with many units so don't do too many expensive
-- operations here
function FateGameMode:OnEntityHurt(keys)
   -- print("[BAREBONES] Entity Hurt")
    --PrintTable(keys)
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)
end

function FateGameMode:OnItemLock(keys)
    --[[for k,v in pairs (keys) do
        print(k,v)
    end]]
end

function FateGameMode:OnGamePause(keys)
    print("Game Pause Start")
    for k,v in pairs (keys) do
        print(k,v)
    end
    local playerId = keys.userid
    local pm = PlayerTables:GetTableValue("player_mark", "PM", playerId) or 0 
    if pm < 0 or (IsInToolsMode() and PlayerTables:GetTableValue("authority", 'alvl', plyID) == 5) then 
        print('fck u can not pause')
        PauseGame(false)
    end
end

-- An item was picked up off the ground
function FateGameMode:OnItemPickedUp(keys)

   -- print("Item pickup")
    for k,v in pairs(keys) do print(k,v) end

    local heroEntity = nil
    local player = nil
    local item = EntIndexToHScript( keys.ItemEntityIndex )

    if keys.HeroEntityIndex ~= nil then
        heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
        player = PlayerResource:GetPlayer(keys.PlayerID)
        CheckItemCombination(heroEntity)
    end

    local itemname = keys.itemname
    if itemname == "item_shard_drop" then
        -- add shard
        UTIL_Remove( item ) -- otherwise it pollutes the player inventory
        if heroEntity then AddRandomShard(heroEntity) end
    elseif itemName == "item_shard_of_replenishment" or itemname == "item_shard_of_anti_magic" then
        if item:GetPurchaser():entindex() ~= keys.HeroEntityIndex and heroEntity ~= nil then
            heroEntity:DropItemAtPositionImmediate(item, heroEntity:GetAbsOrigin())
        end
    elseif itemname == "item_padoru_hat" then
        if not heroEntity:HasAnyAvailableInventorySpace() then
            --heroEntity:DropItemAtPositionImmediate(item, heroEntity:GetAbsOrigin())
        end
    end
end

function FateGameMode:DraftModeCon(hero)
    if IsDivineServant(hero) then 
        hero:AddAbility("divinity_servant_b")
        hero:FindAbilityByName("divinity_servant_b"):SetLevel(1)
        hero:SwapAbilities("divinity_servant_b", "divinity_servant_a", false, false)
        hero:RemoveAbility("divinity_servant_a")
        hero:RemoveModifierByName('modifier_divine_a')
    end
    if IsDragon(hero) then 
        hero:AddAbility("dragon_servant_b")
        hero:FindAbilityByName("dragon_servant_b"):SetLevel(1)
    end

    if Selection == nil then 
        Selection = DraftSelection()
    end

    if hero:GetPlayerOwner():GetTeamNumber() == 2 then 
        if Selection.RedMana > 0 then 
            hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + math.floor(math.min(30, Selection.RedMana) / Selection.PlayerTeam1Count))
            hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + math.floor(math.min(30, Selection.RedMana) / Selection.PlayerTeam1Count))
        end
    elseif hero:GetPlayerOwner():GetTeamNumber() == 3 then 
        if Selection.BlackMana > 0 then 
            hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + math.floor(math.min(30, Selection.RedMana) / Selection.PlayerTeam2Count))
            hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + math.floor(math.min(30, Selection.RedMana) / Selection.PlayerTeam2Count))
        end
    end
end

function FateGameMode:CheckCondition()

    if Convars:GetBool("sv_cheats") or IsInToolsMode() or GetMapName() == "fate_tutorial" then
        ServerTables:SetTableValue("Condition", "divine", 1, true)
        ServerTables:SetTableValue("Condition", "female", 1, true)
        return 
    end

    local divine = 0
    local female = 0
    local archer_summon = false
    local kuro_summon = false 
    local scat_summon = false
    local jtr_summon = false 
    local archer_team = 15
    local kuro_team = 14
    local hero_data = ServerTables:GetAllTableValues('HeroSelection')

    --print('check condition start')

    for playerId,hero in pairs(hero_data) do 
        if hero == "npc_dota_hero_monkey_king" then 
            scat_summon = true
            --print('scathach present')
            local divinedata = hero_data 
            for a,b in pairs(divinedata) do 
                if PlayerResource:GetTeam(playerId) ~= PlayerResource:GetTeam(a) then 
                    if CheckDivine(b) == true then 
                        divine = divine + 1
                        ServerTables:SetTableValue("Condition", "divine", divine, true)
                        
                        print('divinty present')
                    end
                end 
            end
        elseif hero == "npc_dota_hero_riki" then 
            jtr_summon = true
            --print('jack present')
            local femaledata = hero_data 
            for a,b in pairs(femaledata) do 
                if PlayerResource:GetTeam(playerId) ~= PlayerResource:GetTeam(a) then 
                    if CheckSex(b) == "Female" then 
                        female = female + 1
                        ServerTables:SetTableValue("Condition", "female", female, true)            
                        --print('female present')
                    end
                end 
            end
        elseif hero == "npc_dota_hero_ember_spirit" then 
            --print('emiya present')
            archer_summon = true
            archer_team = PlayerResource:GetTeam(playerId) 
            ServerTables:SetTableValue("Condition", "archer", playerId, true)
        elseif hero == "npc_dota_hero_naga_siren" then 
            --print('kuro present')
            kuro_summon = true
            kuro_team = PlayerResource:GetTeam(playerId) 
            ServerTables:SetTableValue("Condition", "kuro", playerId, true)
        end
    end 

    if scat_summon and divine == 0 then 
        local scat_ent = Entities:FindByClassname(nil, "npc_dota_hero_monkey_king")
        scat_ent.MasterUnit2:AddAbility("fate_empty3")
        scat_ent.MasterUnit2:FindAbilityByName("scathach_attribute_immortal"):StartCooldown(9999)
        scat_ent.MasterUnit2:SwapAbilities("fate_empty3", "scathach_attribute_immortal", true, false)
        Say(scat_ent:GetPlayerOwner(), "No divinity servant on enemy team.", true)
    end

    if jtr_summon and female == 0 then
        local jtr_ent = Entities:FindByClassname(nil, "npc_dota_hero_riki")
        jtr_ent.MasterUnit2:AddAbility("fate_empty3")
        jtr_ent.MasterUnit2:FindAbilityByName("jtr_attribute_holy_mother"):StartCooldown(9999)
        jtr_ent.MasterUnit2:SwapAbilities("fate_empty3", "jtr_attribute_holy_mother", true, false)
        Say(jtr_ent:GetPlayerOwner(), "No female servant on enemy team.", true)
    end

    if archer_summon and kuro_summon then 
        if string.match(GetMapName(), "fate_elim") then 
            if ServerTables:GetTableValue("GameMode", "mode") == "classic" and archer_team == kuro_team then
                print('no double hrunt rule activate')
                ServerTables:SetTableValue("Condition", "dbhruntproh", true, true)
                --_G.DoubleHruntingProhibit = true 
                GameRules:SendCustomMessage("Double Hrunting is prohibited in this match", 0, 0)
                GameRules:SendCustomMessage("Attribute: Hrunting will be removed when the other upgrade it.", 0, 0)
            end
        end 
    end 

    print('finish checking') 
end


function CreateShardDrop(location)
    --Spawn the treasure chest at the selected item spawn location
    local newItem = CreateItem( "item_shard_drop", nil, nil )
    local drop = CreateItemOnPositionForLaunch( location + Vector(0,0,1500), newItem )
    newItem:LaunchLootInitialHeight( false, 700, 50, 0.5, location )
end

function AddRandomShard(hero)
    local shardDropTable = {
        "master_shard_of_avarice",
        "master_shard_of_anti_magic",
        "master_shard_of_replenishment",
        "master_shard_of_prosperity"
    }
    local shardRealNameTable = {
        "Shard of Avarice",
        "Shard of Anti-Magic",
        "Shard of Replenishment",
        "Shard of Prosperity"
    }
    if not hero.ShardAmount then
        hero.ShardAmount = 1
    else
        hero.ShardAmount = hero.ShardAmount + 1
    end
    local masterUnit = hero.MasterUnit
    local avarice = 40 
    local amp = 20 
    local replensh = 20 
    local pros = 20
    local choice = 0
    local random = RandomInt(1, 100)
    if random <= avarice then 
        choice = 1
    elseif random > avarice and random <= avarice + amp then 
        choice = 2 
    elseif random > avarice + amp and random <= 100 - pros then 
        choice = 3
    else
        choice = 4 
    end
    local ability = masterUnit:FindAbilityByName(shardDropTable[choice])
    masterUnit:CastAbilityImmediately(ability, hero:GetPlayerOwnerID())
    Notifications:TopToAll({text=FindName(hero:GetName()) .. " has acquired <font color='#FF6600'>" .. shardRealNameTable[choice] .. "</font>!", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})

end

-- A player has reconnected to the game. This function can be used to repaint Player-based particles or change
-- state as necessary
function FateGameMode:OnPlayerReconnect(keys)
  --  print ( '[BAREBONES] OnPlayerReconnect' )
    --PrintTable(keys)
    local playerId = keys.PlayerID
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then 
        --print('reconnect test')
        Timers:CreateTimer(0.1, function()
            local userid = keys.PlayerID
            local ply = PlayerResource:GetPlayer(keys.PlayerID)
            if ply.reconnect == nil then 
                ply.reconnect = 0 
            end
            if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
                CustomNetTables:SetTableValue("draft", "draftmode", {playerId = userid, reconnect = ply.reconnect + 1})
            elseif ServerTables:GetTableValue("GameMode", "mode") == "classic" or ServerTables:GetTableValue("GameMode", "mode") == "samehero" then 
                CustomNetTables:SetTableValue("nselection", "hs", {playerId = userid, reconnect = ply.reconnect + 1})
                print('panel show?')
            end
        end)
    elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        Timers:CreateTimer(3.0, function()
            
            print("reinitiating the UI")
            for k,v in pairs (keys) do 
                print(k,v)
            end
            local userid = keys.PlayerID
            local ply = PlayerResource:GetPlayer(userid)
            local hero = ply:GetAssignedHero()

            if hero == nil then 
                local hhero = PlayerTables:GetTableValue("hHero", 'hhero', userid)
                hero = EntIndexToHScript(hhero)
                hero:SetPlayerID(keys.PlayerID)
                PlayerResource:GetPlayer(keys.PlayerID):SetAssignedHeroEntity(hero)
                local hmaster1 = PlayerTables:GetTableValue("hHero", 'master1', userid)
                local hmaster2 = PlayerTables:GetTableValue("hHero", 'master2', userid)
                local hmaster3 = PlayerTables:GetTableValue("hHero", 'master3', userid)
                local master1 = EntIndexToHScript(hmaster1)
                local master2 = EntIndexToHScript(hmaster2)
                local master3 = EntIndexToHScript(hmaster3)
                master3:SetAbsOrigin(Vector(4500 + userid*270,-7225,200))
                hero.MasterUnit = master1
                hero.MasterUnit:SetControllableByPlayer(keys.PlayerID, true)
                hero.MasterUnit2 = master2
                hero.MasterUnit2:SetControllableByPlayer(keys.PlayerID, true)
                hero.MasterUnit3 = master3
                hero.MasterUnit3:SetControllableByPlayer(keys.PlayerID, true)
            end

            local playerData = {
                masterUnit = hero.MasterUnit2:entindex(),
                shardUnit = hero.MasterUnit:entindex()
            }
            CustomGameEventManager:Send_ServerToPlayer(ply, "player_selected_hero", playerData)
            CustomGameEventManager:Send_ServerToPlayer(ply, "player_selected_hero2", playerData)

            --CustomGameEventManager:Send_ServerToAllClients( "victory_condition_set", victoryConditionData ) -- Send the winner to Javascript

            self:InitialiseMissingPanoramaData(ply,hero,hero.MasterUnit2)

            if ServerTables:GetAllTableValues("EventLimitedSkin") ~= false then
                local total_event = ServerTables:GetAllTableValues("EventLimitedSkin")
                for event,id in pairs(total_event) do
                    local event_data = PlayerTables:GetAllTableValues("limitedevent" .. id, playerId)
                    CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", event_data)
                end
            end

            local current_cp = PlayerTables:GetAllTableValues("CP", userid)
            local skinown = PlayerTables:GetAllTableValues("SkinOwn", userid)
            local skinnotown = PlayerTables:GetAllTableValues("SkinNotOwn", userid)

            CustomGameEventManager:Send_ServerToPlayer(ply, "fate_player_cp", current_cp)
            CustomGameEventManager:Send_ServerToPlayer(ply, "fate_skin_own", skinown)
            CustomGameEventManager:Send_ServerToPlayer(ply, "fate_skin_not_own", skinnotown)
            iupoasldm:sendDiscord(userid)

            self:OnEventChecking()
        end)
    end

    PlayerTables:SetTableValue("connection", "cstate", "connect", playerId, true)
end

function FateGameMode:InitialiseMissingPanoramaData(ply,hero,masterUnit)
    if hero == nil then 
        hero = ply:GetAssignedHero()
    end

    if masterUnit == nil then 
        masterUnit = hero.MasterUnit2
    end

    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer(ply, "servant_stats_updated", statTable)

    local winnerEventData = {}
    winnerEventData.radiantScore = self.nRadiantScore
    winnerEventData.direScore = self.nDireScore
    CustomGameEventManager:Send_ServerToPlayer(ply, "winner_decided", winnerEventData)

    local avariceData = {}
    avariceData.radiant_avarice = ServerTables:GetTableValue("avarice", "Radiant")
    avariceData.dire_avarice = ServerTables:GetTableValue("avarice", "Dire")
    CustomGameEventManager:Send_ServerToPlayer(ply, "avarice_upgrade", avariceData)

    local masterUnits = {}
    --local masterEntIndex = masterUnit:entindex()
    --local heroEntIndex = hero:entindex()
    --masterUnits[heroEntIndex] = masterEntIndex
    self:LoopOverPlayers(function(player, playerID, hero)
        if hero == nil then
          return
        end
        if masterUnit == nil then
          return
        end

        local masterEntIndex = masterUnit:entindex()
        local heroEntIndex = hero:entindex()
        masterUnits[heroEntIndex] = masterEntIndex
    end)

    CustomGameEventManager:Send_ServerToPlayer(ply, "player_register_all_master_units", masterUnits)

    RecreateUITimer(ply, "round_10min_bonus", "Next Holy Grail's Blessing", "ten_min_timer")
    RecreateUITimer(ply, "shard_drop_event", "Next Holy Grail's Shard", "shard_drop_timer")
    RecreateUITimer(ply, "beginround", "Pre-Round", "pregame_timer")
    RecreateUITimer(ply, "round_timer", "Round " .. self.nCurrentRound, "round_timer" .. self.nCurrentRound)
end

function RecreateUITimer(playerID, timerName, message, description)
    local timer = Timers.timers[timerName]
    if timer == nil then
      return
    end

    local endTime = timer.endTime
    if endTime == nil then
      return
    end

    local gameTime = GameRules:GetGameTime()
    local duration = endTime - gameTime

    local timerData = {
        timerMsg = message,
        timerDuration = duration,
        timerDescription = description
    }

    CustomGameEventManager:Send_ServerToPlayer(playerID, "display_timer", timerData)
end

-- An item was purchased by a player
function FateGameMode:OnItemPurchased( keys )
  --  print ( '[BAREBONES] OnItemPurchased : Purchased ' .. keys.itemname )
    --PrintTable(keys)

    -- The playerID of the hero who is buying something
    local plyID = keys.PlayerID
    local ply = PlayerResource:GetPlayer(plyID)
    if not plyID then return end

    -- The name of the item purchased
    local itemName = keys.itemname
    -- The cost of the item purchased
    local itemCost = keys.itemcost           

    local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
    PlayerResource:SetGold(plyID, 0, false)
    hero:SetGold(0, false)

    local extraCost = 0
    local isScroll = false

    local isPriceIncreased = not hero.IsInBase
    local isCStockMessage = false

    if not self.ShopList[_G.GameMap][itemName] then 
        print('non fate item detected.')
        SendErrorMessage(plyID,  "#Can_Not_Buy")
        hero:SetGold(0, false)
        hero:SetGold(hero:GetGold() + itemCost, true)
        if hero:HasItemInInventory(itemName) then 
            local non_fat_item = hero:FindItemInStash(itemName)
            non_fat_item:RemoveSelf()
        else
            local non_fat_droppedItem = Entities:FindAllByName(itemName)[1]
            non_fat_droppedItem:RemoveSelf()
        end
        return
    end

    --[[if hero.IsInBase then
        if itemName == "item_c_scroll" then
            if hero.CStock > 0 then
                hero.CStock = hero.CStock - 1
                --hero.ServStat:trueWorth(tonumber(itemCost))
                isPriceIncreased = false
            else
                SendErrorMessage(plyID, "#Out_Of_Stock_C_Scroll")
                isCStockMessage = true
                hero.CStock = hero.CStock - 1
            end
        --Lets just have this bandaid here ulu
        elseif itemName == "item_b_scroll" then
            hero.CStock = hero.CStock - 2
        elseif itemName == "item_a_scroll" then
            hero.CStock = hero.CStock - 4
        elseif itemName == "item_s_scroll" then
            hero.CStock = hero.CStock - 8
        elseif itemName == "item_ex_scroll" then
            hero.CStock = hero.CStock - 16
        else
            isPriceIncreased = false
        end

        if hero.CStock < 0 then
            while hero.CStock < 0 do
                extraCost = extraCost + 75
                hero.CStock = hero.CStock + 1
            end

            isPriceIncreased = true
            isScroll = true  
        else
            isPriceIncreased = false
        end
    end]]

    --[[if _G.GameMap == "fate_trio" then
        local item_available = LoadKeyValues("scripts/shops/" .. _G.GameMap .. "_shops.txt")
        PrintTable(item_available)
        for i = 1,#item_available["consumables"] do
        if item_available["consumables"]["item"] ~= itemName then 
            SendErrorMessage(plyID,  "#Not_Enough_Gold_Item")
            hero:SetGold(hero:GetGold() + itemCost, true)  
            local isItemDropped = true

            local stash = GetStashItems(hero)
            local oldStash = hero.stashState or {}
            for i = 1,6 do
                if stash[i] ~= oldStash[i] then
                    isItemDropped = false
                    break
                end
            end
            
            local itemsWithSameName = Entities:FindAllByName(itemName)
            local droppedItem
            local purchasedTime = -9999 

            for i = 1,#itemsWithSameName do
                print(itemsWithSameName[i])
                local item = itemsWithSameName[i]
                if item:GetPurchaser() == hero and item:GetPurchaseTime() > purchasedTime then
                    droppedItem = item
                    purchasedTime = item:GetPurchaseTime()
                end
            end

            if droppedItem == nil then
                print("Unexpected: Item was nil - " .. itemName)
            else
                if droppedItem:GetContainer() then
                    droppedItem:GetContainer():RemoveSelf()
                else
                    droppedItem:RemoveSelf()
                end
            end
            return
        end
    end  ]]

    --[[if string.match(_G.GameMap, "elim") and _G.CurrentGameState == "FATE_PRE_ROUND" then 
        if hero:HasItemInInventory(itemName)  then 
            local non_refresh_item = hero:FindItemInStash(itemName)
            if not non_refresh_item:IsCooldownReady() then 
                non_refresh_item:EndCooldown()
            end
        end
    end]]

    if isPriceIncreased then 
        if PlayerResource:GetGold(plyID) >= itemCost * 0.5 then
            --local unreliableGold = PlayerResource:GetUnreliableGold(plyID)
            hero:SetGold(0, false)
            hero:SetGold(hero:GetGold() - (itemCost * 0.5), true)
            --hero:ModifyGold(-itemCost * 0.5, false, 0)
            --local diff = math.max(itemCost * 0.5 - unreliableGold, 0)
            --hero:ModifyGold(-diff, true, 0)
        --[[elseif PlayerResource:GetGold(plyID) >= extraCost and isScroll == true then
            local unreliableGold = PlayerResource:GetUnreliableGold(plyID)
            hero:ModifyGold(-extraCost, false, 0)
            local diff = math.max(extraCost - unreliableGold, 0)
            hero:ModifyGold(-diff, true, 0)]]
        else
            SendErrorMessage(plyID,  "#Not_Enough_Gold_Item")
            hero:SetGold(0, false)
            hero:SetGold(hero:GetGold() + itemCost, true)
            --hero:ModifyGold(itemCost, true, 0)
            local isItemDropped = true

            local stash = GetStashItems(hero)
            local oldStash = hero.stashState or {}
            for i = 1,6 do
                if stash[i] ~= oldStash[i] then
                    isItemDropped = false
                    break
                end
            end
            
            local itemsWithSameName = Entities:FindAllByName(itemName)
            local droppedItem
            local purchasedTime = -9999 

            for i = 1,#itemsWithSameName do
                print(itemsWithSameName[i])
                local item = itemsWithSameName[i]
                if item:GetPurchaser() == hero and item:GetPurchaseTime() > purchasedTime then
                    droppedItem = item
                    purchasedTime = item:GetPurchaseTime()
                end
            end

            if droppedItem == nil then
                print("Unexpected: Item was nil - " .. itemName)
            else
                if droppedItem:GetContainer() then
                    if droppedItem:IsStackable() and droppedItem:GetCurrentCharges() > 1 then 
                        local charge = droppedItem:GetCurrentCharges()
                        droppedItem:SetCurrentCharges(charge - 1)
                    else
                        droppedItem:GetContainer():RemoveSelf()
                    end     
                else
                    if droppedItem:IsStackable() and droppedItem:GetCurrentCharges() > 1 then 
                        local charge = droppedItem:GetCurrentCharges()
                        droppedItem:SetCurrentCharges(charge - 1)
                    else
                        droppedItem:RemoveSelf()
                    end
                end
            end
        end
    end
    
    if (ply.bIsNewItemSystemDisabled and ply.bIsNewItemSystemDisabled == true) or not hero:IsAlive() then
        CheckItemCombination(hero)
        CheckItemCombinationInStash(hero)
        SaveStashState(hero)
    else
        AutoTransferItem(hero, itemName)
    end    

    if PlayerResource:GetGold(plyID) < 200 and hero.bIsAutoGoldRequestOn then
        Notifications:RightToTeamGold(hero:GetTeam(), "<font color='#FF5050'>" .. FindName(hero:GetName()) .. "</font> at <font color='#FFD700'>" .. hero:GetGold() .. "g</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (goldamount)</font> to send gold!", 7, nil, {color="rgb(255,255,255)", ["font-size"]="20px"}, true)
    end
end

function GetHeroItems(hero)
    local itemTable = {}
    for i=1,6 do
        local item = hero:GetItemInSlot(i)
        table.insert(itemTable, i, item and item:GetName())
    end
    return itemTable
end

function GetStashItems(hero)
    local stashTable = {}
    for i=1,6 do
        local item = hero:GetItemInSlot(i + 9)
        table.insert(stashTable, i, item and item:GetName())
    end
    return stashTable
end

function FindItemInStash(hero, itemname)
    for i= 10, 15 do
        local heroItem = hero:GetItemInSlot(i)
        if heroItem == nil then return nil end
        if heroItem:GetName() == itemname then
            return heroItem
        end
    end
    return nil
end


-- stash1 : old stash
-- stash2 : new stash
function FindStashDifference(stash1, stash2)
    local addedItems = {}
    for i=1, #stash2 do
        local IsItemFound = false
        for j=1, #stash1 do
            if stash1[j] == stash2[i] then IsItemFound = true break end -- Set flag to true and break from inner loop if same item is found
        end
        -- If item was not found, add item to return table
        if IsItemFound == false then
            table.insert(addedItems, stash2[i])
        end
    end

    return addedItems
end


-- An ability was used by a player
function FateGameMode:OnAbilityUsed(keys)
  --  print('[BAREBONES] AbilityUsed')

    local player = EntIndexToHScript(keys.PlayerID)
    local abilityname = keys.abilityname
    local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
    if hero == nil then 
        hero = EntIndexToHScript(keys.caster_entindex)
        if not hero:IsRealHero() then return end
    end

    local hero2 = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    --print(hero2)

    --[[if (hero and hero:GetName() == "npc_dota_hero_windrunner") and (abilityname and (abilityname == "nursery_rhyme_story_for_somebodys_sake" or abilityname == "nursery_rhyme_story_for_somebodys_sake_upgrade") ) then
        local comboAbil = hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake")
        if comboAbil == nil then 
            comboAbil = hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake_upgrade")
        end
        --print( comboAbil:GetLevelSpecialValueFor("time_limit", 2) )
        Timers:CreateTimer(comboAbil:GetSpecialValueFor("time_limit"), function()
            if hero.bIsNRComboSuccessful and hero:IsAlive() then
                self:FinishRound(false, 2)
            end
        end)
    end]]

    --[[if (hero and hero:GetName() == "npc_dota_hero_mirana") and (abilityname and abilityname == "jeanne_la_pucelle") then
        local comboAbil = hero:FindAbilityByName("jeanne_la_pucelle")
        Timers:CreateTimer(comboAbil:GetSpecialValueFor("delay") + 0.25, function()
            if hero.LaPucelleSuccess then
                local nRadiantAlive = 0
                local nDireAlive = 0

                if _G.CurrentGameState ~= "FATE_POST_ROUND" then
                    print("From La Pucelle")
      --              -- Check how many people are alive in each team
                    self:LoopOverPlayers(function(player, playerID, playerHero)
                        if playerHero:IsAlive() then
                            if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                                nRadiantAlive = nRadiantAlive + 1
                            else
                                nDireAlive = nDireAlive + 1
                            end
                        end
                    end)

                    if nRadiantAlive == nDireAlive then
    --                    -- Default Radiant Win
                        if self.nRadiantScore + 1 < self.nDireScore                            
                            then self:FinishRound(true,3)
          --              -- Default Dire Win
                        elseif self.nRadiantScore > self.nDireScore + 1
                            then  self:FinishRound(true,4)
                --        -- Draw
                        else                    
                            self:FinishRound(true, 2)
                        end
                    -- if remaining players are not equal
                    elseif nRadiantAlive > nDireAlive then
                        self:FinishRound(true, 0)
                    elseif nRadiantAlive < nDireAlive then
                        self:FinishRound(true, 1)
                    end
                end
            end
        end)
    end]]
    -- Check whether ability is an item active or not
    --[[if not string.match(abilityname,"item") then
        -- Check if hero is affected by Amaterasu
        if hero:HasModifier("modifier_amaterasu_ally") then
            if IsSpellBook(abilityname) then return end
            local tamamo = Entities:FindByClassname(nil, "npc_dota_hero_enchantress")
            local amaterasu = tamamo:FindAbilityByName("tamamo_amaterasu")
            if amaterasu == nil then 
                amaterasu = tamamo:FindAbilityByName("tamamo_amaterasu_upgrade")
            end
            
            if not IsManaLess(hero) then
                hero:SetMana(hero:GetMana() + amaterasu:GetSpecialValueFor("mana_amount"))
            end

            hero:SetHealth(hero:GetHealth()+amaterasu:GetSpecialValueFor("heal_amount"))
            hero:EmitSound("DOTA_Item.ArcaneBoots.Activate")
            local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
        end

        -- Check if a hero with Martial Arts is nearby
        --[[if hero:HasModifier("modifier_martial_arts_aura_enemy") then
            if IsSpellBook(abilityname) then return end

            local targets = FindUnitsInRadius(hero:GetTeam(), hero:GetOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for k,v in pairs(targets) do
                if v:HasAbility("lishuwen_martial_arts") then
                    local abil = v:FindAbilityByName("lishuwen_martial_arts")
                    --abil:ApplyDataDrivenModifier(v, hero, "modifier_mark_of_fatality", {})
                    ApplyMarkOfFatality(v, hero)
                    SpawnAttachedVisionDummy(v, hero, abil:GetLevelSpecialValueFor("vision_radius", abil:GetLevel()-1 ), abil:GetLevelSpecialValueFor("duration", abil:GetLevel()-1 ), false)
                end
            end
        end
    end]]
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function FateGameMode:OnNonPlayerUsedAbility(keys)
  --  print('[BAREBONES] OnNonPlayerUsedAbility')
    --PrintTable(keys)

    local abilityname= keys.abilityname
end

-- A player changed their name
function FateGameMode:OnPlayerChangedName(keys)
  --  print('[BAREBONES] OnPlayerChangedName')
    --PrintTable(keys)

    local newName = keys.newname
    local oldName = keys.oldName
end

-- A player leveled up an ability
function FateGameMode:OnPlayerLearnedAbility( keys)
 --   print ('[BAREBONES] OnPlayerLearnedAbility')
    --PrintTable(keys)

    local player = EntIndexToHScript(keys.player)
    local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function FateGameMode:OnAbilityChannelFinished(keys)
   -- print ('[BAREBONES] OnAbilityChannelFinished')
    --PrintTable(keys)

    local abilityname = keys.abilityname
    local interrupted = keys.interrupted == 1
end

-- A player leveled up
function FateGameMode:OnPlayerLevelUp(keys)
    --print ('[BAREBONES] OnPlayerLevelUp')
    --PrintTable(keys)

    local player = PlayerResource:GetPlayer(keys.player_id)
    local hero = EntIndexToHScript(keys.hero_entindex)
    --print(FindName(hero:GetName()) .. " is level up.")
    --local hero = player:GetAssignedHero()
    local level = keys.level
    hero.ServStat:getLvl(hero)
    --fuck 7.0
    --[[if level == 17 or level == 19 or level == 21 or level == 22 or level == 23 or level == 24 then
        hero:SetAbilityPoints(hero:GetAbilityPoints()+1)
    end]]

    hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 3)
    hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 3)
    NotifyManaAndShard(hero)
    CheckingComboEnable(hero)
    --Notifications:Top(player, "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", 5, nil, {color="rgb(255,255,255)", ["font-size"]="20px"})
    Notifications:Top(player, {text= "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", duration=5, style={color="rgb(255,255,255)", ["font-size"]="20px"}, continue=true})
    if level == 24 then
        Notifications:Top(player, {text= "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has ascended to max level! Your Master's max health has been increased by 2.", duration=8, style={color="rgb(255,140,0)", ["font-size"]="35px"}, continue=true})
        Notifications:Top(player, {text= "Exalted by your ascension, Holy Grail's Blessing from now on will award 3 more mana.", duration=8, style={color="rgb(255,140,0)", ["font-size"]="35px"}, continue=true})

        hero.MasterUnit:SetMaxHealth(hero.MasterUnit:GetMaxHealth()+2)
        hero.MasterUnit2:SetMaxHealth(hero.MasterUnit:GetMaxHealth())
    end
    MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
end

-- A player last hit a creep, a tower, or a hero
function FateGameMode:OnLastHit(keys)
  --  print ('[BAREBONES] OnLastHit')
    --PrintTable(keys)

    local isFirstBlood = keys.FirstBlood == 1
    local isHeroKill = keys.HeroKill == 1
    local isTowerKill = keys.TowerKill == 1
    local player = PlayerResource:GetPlayer(keys.PlayerID)
end

function FateGameMode:OnItemUsed(keys) -- not working
    local playerID = keys.PlayerID
    local itemName = keys.itemname

    print('item use check!')

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero:IsRealHero() then return end

    for i = 0, 17 do
        local item = hero:GetItemInSlot(i)
        if item ~= nil and item:GetName() == itemName then
            item:EndCooldown()
            item:StartCooldown(item:GetCooldown(1))
        end
    end
end

-- A player picked a hero
function FateGameMode:OnPlayerPickHero(keys)
   -- print ('[BAREBONES] OnPlayerPickHero')
    PrintTable(keys)
    local heroClass = keys.hero
    local heroEntity = EntIndexToHScript(keys.heroindex)
    local player = EntIndexToHScript(keys.player)

end

-- A player killed another player in a multi-team context
function FateGameMode:OnTeamKillCredit(keys)
  --  print ('[BAREBONES] OnTeamKillCredit')
    --PrintTable(keys)
    local p = keys.splitscreenplayer
    local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
    local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
    local numKills = keys.herokills
    local killerTeamNumber = keys.teamnumber
end


-- An entity died
function FateGameMode:OnEntityKilled( keys )
  --  print( '[BAREBONES] OnEntityKilled Called' )
    PrintTable( keys )

    -- The Unit that was Killed
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
    -- The Killing entity
    local killerEntity = nil

    if keys.entindex_attacker ~= nil then
        killerEntity = EntIndexToHScript( keys.entindex_attacker )
    end
    -- Check if Caster(4th) is around and grant him 1 Madness
    if not string.match(killedUnit:GetUnitName(), "dummy") then
        local targets = FindUnitsInRadius(0, killedUnit:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for k,v in pairs(targets) do
            if v:GetName() == "npc_dota_hero_shadow_shaman" and not v:HasModifier("modifier_prelati_regen_block") then
                local prelatiabil = v:FindAbilityByName("gilles_prelati_spellbook") or v:FindAbilityByName("gilles_prelati_spellbook_upgrade")
                if killedUnit:IsHero() then
                    v:GiveMana(v:GetMaxMana() * prelatiabil:GetSpecialValueFor("hero_regen") / 100) 
                else
                    v:GiveMana(v:GetMaxMana() * prelatiabil:GetSpecialValueFor("creep_regen") / 100)
                end
            elseif v:GetName() == "npc_dota_hero_riki" and v:HasModifier("modifier_surgical_procedure") then
                v:Heal(killedUnit:GetMaxHealth() * 0.3, v)
                v:GiveMana((killedUnit:GetMaxMana() or 0) * 0.3)
            end
        end
    end
    -- Change killer to be owning hero
    if not killerEntity:IsHero() then
        --print("Killed by neutral unit")
        if IsValidEntity(killerEntity:GetPlayerOwner()) then
            killerEntity = killerEntity:GetPlayerOwner():GetAssignedHero()
        end
    end

    if killedUnit.IsNurseryClone then
        local nursery = killedUnit.NurseryRhyme
        if killerEntity:GetTeamNumber() == nursery:GetTeamNumber() then return end

        print("Handling NR Tempest Double")
        -- Distribute XP to allies
        local alliedHeroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 4000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
        local realHeroCount = 0
        for i=1, #alliedHeroes do
            if alliedHeroes[i]:IsHero() and alliedHeroes[i]:GetName() ~= "npc_dota_hero_wisp" then
                realHeroCount = realHeroCount + 1
            end
        end

        for i=1, #alliedHeroes do
            if alliedHeroes[i]:IsHero() and alliedHeroes[i]:GetName() ~= "npc_dota_hero_wisp" then
                local exp_bounty = (XP_BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] / realHeroCount) * 0.25
                if killedUnit:IsHero() and killedUnit:GetLevel() > alliedHeroes[i]:GetLevel() then
                    local level_difference = killedUnit:GetLevel() - alliedHeroes[i]:GetLevel()
                    exp_bounty = exp_bounty * (level_difference * 0.1 + 1)
                end

                alliedHeroes[i]:AddExperience(exp_bounty, false, false)
            end
        end

        -- Give kill bounty
        local bounty = (BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()]) * 0.5
        killerEntity:SetGold(0, false)
        killerEntity:SetGold(killerEntity:GetGold() + bounty, true) 
        -- if killer has Golden Rule attribute, grant 50% more gold
        if killerEntity:HasAbility("gilgamesh_golden_rule_upgrade") then
            local extra_bounty = killerEntity:FindAbilityByName("gilgamesh_golden_rule_upgrade"):GetSpecialValueFor("bounty_bonus") / 100
            killerEntity:SetGold(0, false)
            killerEntity:SetGold(killerEntity:GetGold() + (bounty * extra_bounty), true)
        end
        --Granting XP to all heroes who assisted
        local assistTable = {}
        local allHeroes = HeroList:GetAllHeroes()
        for _,atker in pairs( allHeroes ) do
            for i = 0, killedUnit:GetNumAttackers() - 1 do
                local attackerID = killedUnit:GetAttacker( i )
                if atker:GetPlayerID() == attackerID then
                    local assister = PlayerResource:GetSelectedHeroEntity(attackerID)
                    if atker:GetTeam() == assister:GetTeam() and assister ~= killerEntity then
                        table.insert(assistTable, assister)
                        assister.ServStat:onAssist()
                        assister:SetGold( 0, false)
                        assister:SetGold(assister:GetGold() + 300, true)
                        local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, assister:GetPlayerOwner())
                        ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                        ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,300,0))
                        ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                        ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
                    end
                end
            end
        end

        return
    end

    if killedUnit:IsRealHero() then
        --[[local hTp = killedUnit:FindItemInInventory('item_tpscroll')
        if hTp then
            killedUnit:RemoveItem(hTp)
        end]]
        self.bIsCasuallyOccured = true -- someone died this round
        if killedUnit:GetName() == "npc_dota_hero_doom_bringer" and killedUnit:HasModifier("modifier_god_hand_stock") and killedUnit.bIsGHReady then
            killedUnit:SetTimeUntilRespawn(1)
        elseif killedUnit:GetName() == "npc_dota_hero_vengefulspirit" and killedUnit:HasModifier("modifier_4_days_loop") and killedUnit.DeathInLoop then
            killedUnit:SetTimeUntilRespawn(1)
        else
            killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel() + 3)
        end
        -- if killed by illusion, change the killer to the owner of illusion instead
        if killerEntity:IsIllusion() then
            killerEntity = PlayerResource:GetPlayer(killerEntity:GetPlayerID()):GetAssignedHero()
        end

        if killerEntity:GetUnitName() == "okita_shinsengumi" or killerEntity:GetUnitName() == "okita_hijikata" then 
            killerEntity = killerEntity:GetOwnerEntity()
        end

        if killedUnit:GetUnitName() == "npc_dota_hero_vengefulspirit" and killedUnit.IsWorldEvilAcquired then 
            local avenger_abil = killedUnit:FindAbilityByName("avenger_vengeance_mark_upgrade")
            avenger_abil:ApplyDataDrivenModifier(killedUnit, killerEntity, "modifier_all_the_world_evil", {})
        end

        -- if TK occured, do nothing and announce it
        if killerEntity:GetTeam() == killedUnit:GetTeam() then
            if killerEntity ~= killedUnit then
                killerEntity.ServStat:onTeamKill()
            end
            killedUnit.ServStat:onDeath()
            --GameRules:SendCustomMessage("<font color='#FF5050'>" .. killerEntity.name .. "</font> has slain friendly Servant <font color='#FF5050'>" .. killedUnit.name .. "</font>!", 0, 0)
            CustomGameEventManager:Send_ServerToAllClients( "fate_hero_killed", {killer=killerEntity:entindex(), victim=killedUnit:entindex(), assists=nil } )
        else
            killerEntity.ServStat:onKill()
            killedUnit.ServStat:onDeath()
            -- Add to death count
            --[[if killedUnit.DeathCount == nil then
                killedUnit.DeathCount = 1
                killedUnit.GetShard = 0
            else]]
            if killedUnit:GetName() == "npc_dota_hero_doom_bringer" then
                if not killedUnit.bIsGHReady or IsTeamWiped(killedUnit) or killedUnit.GodHandStock == 0 then
                    --killedUnit.DeathCount = killedUnit.DeathCount + 1
                    killedUnit.ServStat:onActualDeath()
                end
            elseif killedUnit:GetName() == "npc_dota_hero_vengefulspirit" then
                if not killedUnit.DeathInLoop or IsTeamWiped(killedUnit) or killedUnit.LoopStocks == 0 then
                    --killedUnit.DeathCount = killedUnit.DeathCount + 1
                    killedUnit.ServStat:onActualDeath()
                end
            else
                --killedUnit.DeathCount = killedUnit.DeathCount + 1
                killedUnit.ServStat:onActualDeath()
            end      

            if ServerTables:GetTableValue("PEPE", "pepe") == true and ServerTables:GetTableValue("PEPE", "slayer") == true then
                local atkId = killerEntity:GetPlayerOwnerID()
                local dieId = killedUnit:GetPlayerOwnerID()
                if PlayerTables:GetTableValue("pepe", "pepe", atkId) == "pepe_slayer" and PlayerTables:GetTableValue("pepe", "pepe", dieId) == "pepe" then 
                    local total_kill = ServerTables:GetTableValue("PEPE", "kill")
                    ServerTables:SetTableValue("PEPE", "kill", total_kill + 1, true)
                end   
            end      

            -- check if unit can receive a shard
            if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
                if killedUnit.ServStat:getActualDeath() == 7 and not killedUnit.GetGrailDeath then
                    killedUnit.ShardAmount = (killedUnit.ShardAmount or 0) + 1
                    killedUnit.GetGrailDeath = true
                    local statTable = CreateTemporaryStatTable(killedUnit)
                    CustomGameEventManager:Send_ServerToPlayer( killedUnit:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS
                end
            else
                if killedUnit.ServStat:getActualDeath() % 7 == 0 and killedUnit.ServStat:getActualDeath() / 7 > killedUnit.ServStat:getConGrail() then
                    killedUnit.ShardAmount = (killedUnit.ShardAmount or 0) + 1
                    killedUnit.ServStat:onConGrail()
                    local statTable = CreateTemporaryStatTable(killedUnit)
                    CustomGameEventManager:Send_ServerToPlayer( killedUnit:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS
                end
            end
            -- MVP killed
            if ServerTables:GetTableValue("MVP", "draw") == true then
                local reward_table = ServerTables:GetTableValue("MVP", "reward")
                if reward_table ~= false then
                    for k,v in pairs (reward_table) do
                        print(k,v)
                    end
                    if EntIndexToHScript(ServerTables:GetTableValue("MVP", "team1")) == killedUnit then 
                        if EntIndexToHScript(ServerTables:GetTableValue("MVP", "team2")) == killerEntity then 
                            GameRules:SendCustomMessage("<font color='#00FF00'>" .. FindName(killerEntity:GetName()) .."</font> has slayed <font color='#FF0000'>" .. FindName(killedUnit:GetName()) .."</font> ", 0, 0)
                            GameRules:SendCustomMessage("<font color='#000000'>Black Faction</font> won the round and get <font color='#FFFF28'>+" .. reward_table.Reward .."</font> <font color='#FFFF28'>" .. reward_table.RewardType .. "</font>.", 0, 0)
                            self:FinishRound(false, 1)
                            self:rewardMVP(killerEntity:GetTeamNumber())
                        else
                            self:rewardMVP(killerEntity:GetTeamNumber())
                            GameRules:SendCustomMessage("<font color='#FF0000'>" .. FindName(killedUnit:GetName()) .."</font> has been hunted down, All Black Faction players get <font color='#FFFF28'>+" .. reward_table.Reward .."</font> <font color='#FFFF28'>" .. reward_table.RewardType .. "</font>.", 0, 0)
                        end
                    elseif EntIndexToHScript(ServerTables:GetTableValue("MVP", "team2")) == killedUnit then 
                        if EntIndexToHScript(ServerTables:GetTableValue("MVP", "team1")) == killerEntity then 
                            GameRules:SendCustomMessage("<font color='#00FF00'>" .. FindName(killerEntity:GetName()) .."</font> has slayed <font color='#FF0000'>" .. FindName(killedUnit:GetName()) .."</font> ", 0, 0)
                            GameRules:SendCustomMessage("<font color='#FF0000'>Red Faction</font> won the round and get <font color='#FFFF28'>+" .. reward_table.Reward .."</font> <font color='#FFFF28'>" .. reward_table.RewardType .. "</font>.", 0, 0)
                            self:FinishRound(false, 0)
                            self:rewardMVP(killerEntity:GetTeamNumber())
                        else
                            self:rewardMVP(killerEntity:GetTeamNumber())
                            GameRules:SendCustomMessage("<font color='#FF0000'>" .. FindName(killedUnit:GetName()) .."</font> has been hunted down, All Red Faction player get <font color='#FFFF28'>+" .. reward_table.Reward .."</font> <font color='#FFFF28'>" .. reward_table.RewardType .. "</font>.", 0, 0)
                        end
                    end
                end
            end
            -- Distribute XP to allies
            local alliedHeroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 4000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
            local realHeroCount = 0
            for i=1, #alliedHeroes do
                if alliedHeroes[i]:IsHero() and alliedHeroes[i]:GetName() ~= "npc_dota_hero_wisp" then
                    realHeroCount = realHeroCount + 1
                end
            end

            for i=1, #alliedHeroes do
                if alliedHeroes[i]:IsHero() and alliedHeroes[i]:GetName() ~= "npc_dota_hero_wisp" then
                    local exp_bounty = XP_BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] / realHeroCount * 0.5

                    --print("Base Bounty: " .. exp_bounty)
                    if killedUnit:IsHero() and killedUnit:GetLevel() > alliedHeroes[i]:GetLevel() then
                        local level_difference = killedUnit:GetLevel() - alliedHeroes[i]:GetLevel()
                        exp_bounty = exp_bounty * (level_difference * 0.1 + 1)
                        --print("Bounty multiplier after: " .. exp_bounty)
                    end

                    alliedHeroes[i]:AddExperience(exp_bounty, false, false)
                end
            end

            -- Give kill bounty
            local bounty = BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()]

            if _G.FIRST_BLOOD_TRIGGERED == false then
                _G.FIRST_BLOOD_TRIGGERED = true

                bounty = bounty + 500
            end
            killerEntity:SetGold(0, false)
            killerEntity:SetGold(killerEntity:GetGold() + bounty, true)
            --ModifyGold(bounty , true, 0)
            -- if killer has Golden Rule attribute, grant 50% more gold
            if killerEntity:HasAbility("gilgamesh_golden_rule_upgrade") then
                local extra_bounty = killerEntity:FindAbilityByName("gilgamesh_golden_rule_upgrade"):GetSpecialValueFor("bounty_bonus") / 100
                killerEntity:SetGold(0, false)
                killerEntity:SetGold(killerEntity:GetGold() + (bounty * extra_bounty), true)
            end
            --Granting XP to all heroes who assisted
            local assistTable = {}
            local allHeroes = HeroList:GetAllHeroes()
            for _,atker in pairs( allHeroes ) do
                for i = 0, killedUnit:GetNumAttackers() - 1 do
                    local attackerID = killedUnit:GetAttacker( i )
                    if atker:GetPlayerID() == attackerID then
                        local assister = PlayerResource:GetSelectedHeroEntity(attackerID)
                        if atker:GetTeam() == assister:GetTeam() and assister ~= killerEntity then
                            table.insert(assistTable, assister)
                            assister.ServStat:onAssist()
                            assister:SetGold(0, false)
                            assister:SetGold(assister:GetGold() + 300, true)
                            local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, assister:GetPlayerOwner())
                            --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                            ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                            ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,300,0))
                            ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                            ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
                        end
                    end
                end
            end
            --print("Player collected bounty : " .. bounty - killedUnit:GetGoldBounty())
            -- Create gold popup
            if killerEntity:GetPlayerOwner() ~= nil then
                local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetPlayerOwner())
                --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,bounty,0))
                ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
            end

            -- Display gold message
            local assistString = "plus <font color='#FFFF66'>" .. #assistTable * 300 .. "</font> gold split between contributors!"
            --GameRules:SendCustomMessage("<font color='#FF5050'>" .. killerEntity.name .. "</font> has slain <font color='#FF5050'>" .. killedUnit.name .. "</font> for <font color='#FFFF66'>" .. bounty .. "</font> gold, " .. assistString, 0, 0)
            -- Convert to entindex before sending kill event to panorama
            for i=1, #assistTable do
                assistTable[i] = assistTable[i]:entindex()
            end
            CustomGameEventManager:Send_ServerToAllClients( "fate_hero_killed", {killer=killerEntity:entindex(), victim=killedUnit:entindex(), assists=assistTable } )


            --[[-- Give assist bounty
            for k, _ in pairs(killedUnit.assistTable) do
                if k:GetTeam() == killerEntity:GetTeam() then
                    k:ModifyGold(300 , true, 0)
                    local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, k:GetPlayerOwner())
                    --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                    ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                    ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,300,0))
                    ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                    ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
                end
            end]]


        end

        -- Need condition check for GH
        --if killedUnit:GetName() == "npc_dota_hero_doom_bringer" and killedUnit:GetPlayerOwner().IsGodHandAcquired then

        if _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_ffa"  or _G.GameMap == "fate_trio" then
            --print(PlayerResource:GetTeamKills(killerEntity:GetTeam()))
            --print(VICTORY_CONDITION)
            if PlayerResource:GetTeamKills(killerEntity:GetTeam()) >= VICTORY_CONDITION then
                self:PauseAllHero()
                ServerTables:SetTableValue("GameState", "state", "FATE_END_GAME", true)
                local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
                for i = 0, max_player - 1 do 
                    if PlayerResource:IsValidPlayer(i) then 
                        if i == killerEntity:GetPlayerOwnerID() then
                            kjlpluo1596:initialize(i,1)
                        else
                            kjlpluo1596:initialize(i,0)
                        end
                    end
                end
                my_http_post()
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( killerEntity:GetTeam() )
            end
        elseif _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killedUnit:IsRealHero() then
                self.nRadiantDead = self.nRadiantDead + 1
            else
                self.nDireDead = self.nDireDead + 1
            end

            local nRadiantAlive = 0
            local nDireAlive = 0
            self:LoopOverPlayers(function(player, playerID, playerHero)
                if playerHero:IsAlive() then
                    if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                        nRadiantAlive = nRadiantAlive + 1
                    else
                        nDireAlive = nDireAlive + 1
                    end
                end
            end)
            --print(_G.CurrentGameState)
            -- check for game state before deciding round
            if _G.CurrentGameState ~= "FATE_POST_ROUND" and ServerTables:GetTableValue("LaPucelle", "active") == false then
                if nRadiantAlive == 0 and nDireAlive ~= 0 then
                    --print("All Radiant heroes eliminated, removing existing timers and declaring winner...")

                    Timers:RemoveTimer('round_timer')
                    Timers:RemoveTimer('alertmsg')
                    Timers:RemoveTimer('alertmsg2')
                    Timers:RemoveTimer('timeoutmsg')
                    Timers:RemoveTimer('presence_alert')
                    self:FinishRound(false, 1)
                elseif nDireAlive == 0 and nRadiantAlive ~= 0 then
                    --print("All Dire heroes eliminated, removing existing timers and declaring winner...")

                    Timers:RemoveTimer('round_timer')
                    Timers:RemoveTimer('alertmsg')
                    Timers:RemoveTimer('alertmsg2')
                    Timers:RemoveTimer('timeoutmsg')
                    Timers:RemoveTimer('presence_alert')
                    self:FinishRound(false, 0)
                elseif nDireAlive == 0 and nRadiantAlive == 0 then
                    self:FinishRound(false, 2)
                --[[else
                    if self.nRadiantScore + 1 < self.nDireScore                            
                        then self:FinishRound(false,3)
                    -- Default Dire Win
                    elseif self.nRadiantScore > self.nDireScore + 1
                        then  self:FinishRound(false,4)
                    -- Draw
                    else                    
                        self:FinishRound(false, 2)
                    end]]
                end
            end
        end        
    end
end

function OnBalanceShuf(keys)
    yedped:shuf()
end

function OnVoteFinished(Index,keys)
    print("[FateGameMode]vote finished by player with result :" .. keys.killsVoted)
    local voteResult = keys.killsVoted
    voteResultTable[voteResult] = voteResultTable[voteResult] + 1
    --[[if voteResult == 1 then
        voteResultTable.v_OPTION_1 = voteResultTable.v_OPTION_1+1
    elseif voteResult == 2 then
        voteResultTable.v_OPTION_2 = voteResultTable.v_OPTION_2+1
    elseif voteResult == 3 then
        voteResultTable.v_OPTION_3 = voteResultTable.v_OPTION_3+1
    elseif voteResult == 4 then
        voteResultTable.v_OPTION_4 = voteResultTable.v_OPTION_4+1
    elseif voteResult == 5 then
        voteResultTable.v_OPTION_5 = voteResultTable.v_OPTION_5+1
    end]]
end

function FateGameMode:OnVoteMode(keys)
    print("[FateGameMode]vote mode finished by player with result :" .. keys.ModeVoted)
    local votemodeResult = keys.ModeVoted
    local playerId = keys.player 
    local player = PlayerResource:GetPlayer(playerId)
    --[[if player.authority_level == 5 and votemodeResult == 2 then 
        self.votemodeResultTable.v_OPTION_2 = 10 
    end]]
    if votemodeResult == 1 then
        self.votemodeResultTable.v_OPTION_1 = self.votemodeResultTable.v_OPTION_1+1
    elseif votemodeResult == 2 then
        self.votemodeResultTable.v_OPTION_2 = self.votemodeResultTable.v_OPTION_2+1
    elseif votemodeResult == 3 then
        self.votemodeResultTable.v_OPTION_3 = self.votemodeResultTable.v_OPTION_3+1
    end
end

function FateGameMode:OnGrailVote(keys)
    print("[FateGameMode]vote mode finished by player with result :" .. keys.GrailVoted)
    local votemodeResult = keys.GrailVoted
    if votemodeResult == 1 then
        self.votemodeResultTable.v_OPTION_1 = self.votemodeResultTable.v_OPTION_1+1
    elseif votemodeResult == 2 then
        self.votemodeResultTable.v_OPTION_2 = self.votemodeResultTable.v_OPTION_2+1
    end
end

function FateGameMode:OnBanHeroVote(keys)
    print("[FateGameMode]balance mode finished by player with result :" .. keys.BalanceVoted)
    local votemodeResult = keys.BalanceVoted
    if votemodeResult == 1 then
        self.voteBanHeroTable = 0
    elseif votemodeResult == 2 then
        self.voteBanHeroTable = 2
    elseif votemodeResult == 3 then
        self.voteBanHeroTable = 4
    elseif votemodeResult == 4 then
        self.voteBanHeroTable = 6
    end
end

function OnDirectTransferChanged(Index, keys)
    local playerID = keys.player
    local transferEnabled = keys.directTransfer

    PlayerResource:GetPlayer(playerID):GetAssignedHero().bIsDirectTransferEnabled = transferEnabled
    print("Direct tranfer set to " .. transferEnabled .. " for " .. PlayerResource:GetPlayer(playerID):GetAssignedHero():GetName())
end


function OnServantCustomizeActivated(Index, keys)
    local caster = EntIndexToHScript(keys.unitEntIndex)
    local ability = EntIndexToHScript(keys.abilEntIndex)
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local behav_string = tostring(ability:GetBehavior())
    if behav_string ~= "6293508" then
        return
    end
    if ability:GetManaCost(1) > caster:GetMana() then
        SendErrorMessage(hero:GetPlayerOwnerID(), "#Not_Enough_Master_Mana")
        return
    end
    if ability:IsCooldownReady() == false then
        return
    end
    caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

    hero:EmitSound("Item.DropGemWorld")
    local tomeFx = ParticleManager:CreateParticle("particles/units/heroes/hero_silencer/silencer_global_silence_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(tomeFx, 1, hero:GetAbsOrigin())

    --EmitSoundOnLocationForAllies(hero:GetAbsOrigin(), "Item.PickUpGemShop", hero)

    --ability:StartCooldown(ability:GetCooldown(1))
    --caster:SetMana(caster:GetMana() - ability:GetManaCost(1))
end

function OnConfig1Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsAutoGoldRequestOn = true else hero.bIsAutoGoldRequestOn = false end
end

function OnConfig2Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsDmgPopupDisabled = true else hero.bIsDmgPopupDisabled = false end
end

function OnConfig4Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsAlertSoundDisabled = true else hero.bIsAlertSoundDisabled = false end
end

function OnConfig8Checked(index, keys)
    local playerID = PlayerResource:GetPlayer(keys.player)
    if keys.bOption == 1 then playerID.bIsNewItemSystemDisabled = true else playerID.bIsNewItemSystemDisabled = false end
end

function OnConfig9Checked(index, keys)
    local playerID = PlayerResource:GetPlayer(keys.player)
    print(keys.bOption)
    if keys.bOption == 1 then playerID.bNotifyMasterManaDisabled = true else playerID.bNotifyMasterManaDisabled = false end
end

function OnConfig11Checked(index, keys)
    local player = PlayerResource:GetPlayer(keys.player)
    CustomGameEventManager:Send_ServerToPlayer( player, "custom_master_bar", {bOption= keys.bOption} )
end

function OnConfig13Checked(index, keys)
    local playerID = PlayerResource:GetPlayer(keys.player)
    if keys.bOption == 1 then playerID.bIsAutoCombineEnabled = true else playerID.bIsAutoCombineEnabled = false end
end

function OnConfig14Checked(index, keys)
    local playerID = PlayerResource:GetPlayer(keys.player)
    if keys.bOption == 1 then playerID.IsPadoruEnable = true else playerID.IsPadoruEnable = false end
end

function OnHeroClicked(Index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()

    print(hero:GetName())
    if hero:GetName() == 'npc_dota_hero_troll_warlord' then 
        if hero.IsOnBoarded then 
            print('Drake On Golden Hind')
        end
    end
    if hero.IsIntegrated or hero.IsMounted or hero.IsOnBoarded then
        -- Find the transport
        local units = FindUnitsInRadius(hero:GetTeam(), hero:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP, 0, FIND_CLOSEST, false)
        for k,v in pairs(units) do
            local unitname = v:GetUnitName()
            print(v:GetUnitName())
            if hero:IsAlive() and v:IsAlive() and v:GetOwnerEntity() == hero then
                if string.match(v:GetUnitName(), "medea_ancient_dragon") or string.match(v:GetUnitName(), "gille_gigantic_horror") or string.match(v:GetUnitName(), "drake_golden_hind") then
                    local playerData = {
                        transport = v:entindex()
                    }
                    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_selected_hero_in_transport", playerData )
                    break
                end
            end
        end
    end
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function FateGameMode:InitGameMode()
    FateGameMode = self
    self.ShopList = LoadKeyValues("scripts/npc/fate_itemlist.txt")
    --print('Init Game Mode')

    -- Find out which map we are using
    _G.GameMap = GetMapName()
    if _G.GameMap == "fate_elim_6v6" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 6)
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(1)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)  
        GameRules:SetPreGameTime(370) 
        ServerTables:CreateTable("MaxPlayers", {total_player = 12})
    elseif _G.GameMap == "fate_elim_7v7" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 7)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 7)
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(1)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)  
        GameRules:SetPreGameTime(370) 
        ServerTables:CreateTable("MaxPlayers", {total_player = 14})
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 3)
        GameRules:SetGoldPerTick(7.5)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)  
        GameRules:SetPreGameTime(105)
        ServerTables:CreateTable("MaxPlayers", {total_player = 12})
    elseif _G.GameMap == "fate_trio" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3)
        GameRules:SetGoldPerTick(7.5)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)  
        GameRules:SetPreGameTime(105)
        ServerTables:CreateTable("MaxPlayers", {total_player = 9})
    elseif _G.GameMap == "fate_ffa" then
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
        GameRules:SetGoldPerTick(7.5)
        GameRules:SetGoldTickTime(1.0)
        GameRules:SetStartingGold(0)
        GameRules:SetPreGameTime(105)
        ServerTables:CreateTable("MaxPlayers", {total_player = 10})
    elseif _G.GameMap == "fate_tutorial" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0)
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(0)
        GameRules:SetGoldTickTime(0.0)
        GameRules:SetStartingGold(0)    
        GameRules:SetPreGameTime(5)
        ServerTables:CreateTable("MaxPlayers", {total_player = 1})
    end
    -- Set game rules
    GameRules:SetCustomGameAllowBattleMusic(false)
    GameRules:SetCustomGameAllowHeroPickMusic(false)
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    GameRules:SetHeroSelectionTime(0)
    Convars:SetInt("dota_max_physical_items_purchase_limit", 200)
    Convars:SetInt("dota_max_disconnected_time", 600)
    -- Set music off
    SendToServerConsole("dota_music_battle_enable 0")
    SendToConsole("dota_music_battle_enable 0")  
    --GameRules:SetPreGameTime(60)
    --[[if _G.GameMap == "fate_elim_6v6" then
        GameRules:SetPreGameTime(370)
    else
        GameRules:SetPreGameTime(60)
    end]]
    GameRules:SetShowcaseTime(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetUseCustomHeroXPValues(true)
    GameRules:SetUseBaseGoldBountyOnHeroes(false)
    GameRules:SetIgnoreLobbyTeamsInCustomGame( true )
    GameRules:SetCustomGameSetupTimeout(20)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetCustomGameEndDelay(30)
    GameRules:SetCustomVictoryMessageDuration(30)
    GameRules:SetPostGameTime( 30 ) 
    GameRules:SetTimeOfDay(10.30)


    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT, 0)
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0)
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_MAGIC_RESISTANCE_PERCENT, 0)  
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0)
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT, 0)
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0)    
    --GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_, 0)

    -- Random seed for RNG
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    -- Event Hooks
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(FateGameMode, 'OnPlayerLevelUp'), self)
    --ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(FateGameMode, 'OnAbilityChannelFinished'), self)
    ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(FateGameMode, 'OnPlayerLearnedAbility'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(FateGameMode, 'OnEntityKilled'), self)
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(FateGameMode, 'OnConnectFull'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(FateGameMode, 'OnDisconnect'), self)
    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(FateGameMode, 'OnItemPurchased'), self)
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(FateGameMode, 'OnItemPickedUp'), self)
    ListenToGameEvent('dota_action_item', Dynamic_Wrap(FateGameMode, 'OnItemLock'), self) 
    ListenToGameEvent('dota_pause_event', Dynamic_Wrap(FateGameMode, 'OnGamePause'), self)
    --ListenToGameEvent('dota_inventory_player_got_item', Dynamic_Wrap(FateGameMode, 'OnItemAdded'), self)
    --ListenToGameEvent('last_hit', Dynamic_Wrap(FateGameMode, 'OnLastHit'), self)
    --ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(FateGameMode, 'OnNonPlayerUsedAbility'), self)
    --ListenToGameEvent('player_changename', Dynamic_Wrap(FateGameMode, 'OnPlayerChangedName'), self)
    --ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(FateGameMode, 'OnRuneActivated'), self)
    --ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(FateGameMode, 'OnPlayerTakeTowerDamage'), self)
    --ListenToGameEvent('tree_cut', Dynamic_Wrap(FateGameMode, 'OnTreeCut'), self)
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(FateGameMode, 'OnEntityHurt'), self)
    ListenToGameEvent('player_connect', Dynamic_Wrap(FateGameMode, 'PlayerConnect'), self)
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(FateGameMode, 'OnAbilityUsed'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(FateGameMode, 'OnGameRulesStateChange'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(FateGameMode, 'OnNPCSpawned'), self)
    ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(FateGameMode, 'OnPlayerPickHero'), self)
    ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(FateGameMode, 'OnTeamKillCredit'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(FateGameMode, 'OnPlayerReconnect'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(FateGameMode, 'OnPlayerChat'), self) 
    ListenToGameEvent('dota_item_used', Dynamic_Wrap(FateGameMode, 'OnItemUsed'), self) -- not working
    --ListenToGameEvent('player_spawn', Dynamic_Wrap(FateGameMode, 'OnPlayerSpawn'), self)
    --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(FateGameMode, 'OnDotaUnitEvent'), self)
    --ListenToGameEvent('nommed_tree', Dynamic_Wrap(FateGameMode, 'OnPlayerAteTree'), self)
    --ListenToGameEvent('player_completed_game', Dynamic_Wrap(FateGameMode, 'OnPlayerCompletedGame'), self)
    --ListenToGameEvent('dota_match_done', Dynamic_Wrap(FateGameMode, 'OnDotaMatchDone'), self)
    --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(FateGameMode, 'OnCombatLogEvent'), self)
    --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(FateGameMode, 'OnPlayerKilled'), self)
    --ListenToGameEvent('player_team', Dynamic_Wrap(FateGameMode, 'OnPlayerTeam'), self)

    -- Listen to vote result
    --CustomGameEventManager:RegisterListener( "vote_finished", OnVoteFinished )
    --CustomGameEventManager:RegisterListener( "game_vote", OnVoteMode )
    CustomGameEventManager:RegisterListener("game_vote", function(id, ...)
        Dynamic_Wrap(self, "OnVoteMode")(self, ...) 
    end)
    CustomGameEventManager:RegisterListener("grail_vote", function(id, ...)
        Dynamic_Wrap(self, "OnGrailVote")(self, ...) 
    end)
    CustomGameEventManager:RegisterListener("balance_vote", function(id, ...)
        Dynamic_Wrap(self, "OnBanHeroVote")(self, ...) 
    end)
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
    CustomGameEventManager:RegisterListener( "config_option_13_checked", OnConfig13Checked )
    CustomGameEventManager:RegisterListener( "config_option_14_checked", OnConfig14Checked )
    --CustomGameEventManager:RegisterListener("hotkey_purchase_item", HotkeyPurchaseItem)
    -- CustomGameEventManager:RegisterListener( "player_chat_panorama", OnPlayerChat )
    CustomGameEventManager:RegisterListener( "player_alt_click", OnPlayerAltClick )
    CustomGameEventManager:RegisterListener( "player_say_to_team", OnPlayerSay )
    CustomGameEventManager:RegisterListener("player_remove_buff", OnPlayerRemoveBuff )
    CustomGameEventManager:RegisterListener("player_cast_seal", OnPlayerCastSeal )
    CustomGameEventManager:RegisterListener("player_hotkey_seal", OnPlayerHotkeySeal )
    -- LUA modifiers
    LinkLuaModifier("modifier_ms_cap", "modifiers/modifier_ms_cap", LUA_MODIFIER_MOTION_NONE)


    -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
    --Convars:RegisterCommand( "command_example", Dynamic_Wrap(FateGameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
    --function FateGameMode:ExampleConsoleCommand()
    --end

    --[[-- Convars:RegisterCommand( "player_say", Dynamic_Wrap(FateGameMode, 'PlayerSay'), "Reads player chat", 0)
    Convars:RegisterCommand('player_say', function(...)
        local arg = {...}
        table.remove(arg,1)
        local cmdPlayer = Convars:GetCommandClient()
        keys = {}
        keys.ply = cmdPlayer
        keys.text = table.concat(arg, " ")
        self:PlayerSay(keys)
    end, "Player said something", 0)]]

    -- Initialized tables for tracking state
    
    self.nRadiantScore = 0
    self.nDireScore = 0

    self.nCurrentRound = 0
    self.nRadiantDead = 0
    self.nDireDead = 0
    self.nLastKilled = nil
    self.fRoundStartTime = 0

    self.bIsCasualtyOccured = false

    -- userID map
    self.vUserNames = {}
    self.vPlayerList = {}
    self.vSteamIds = {}
    self.vBots = {}
    self.vBroadcasters = {}
    self.IsGameEnd = false

    self.vPlayers = {}
    self.vRadiant = {}
    self.vDire = {}

    self.vPlayerShield = {}
    --IsFirstSeal = {}
    self.votemodeResultTable = {
        v_OPTION_1 = 0, -- 12 kills
        v_OPTION_2 = 0,  -- 10
        v_OPTION_3 = 0,  -- 10
    }
    self.MVPHuntReward = LoadKeyValues("scripts/npc/mvp_reward.txt")

    self.voteBanHeroTable = 0

    self.bSeenWaitForPlayers = false
    -- Active Hero Map
    self.vPlayerHeroData = {}
    self.bPlayersInit = false
    self.bDrawChestDrop = false
    self.MVPA = {}
    self.MVPB = {}

    ServerTables:CreateTable("GameMap", {map = _G.GameMap})
    ServerTables:CreateTable("GameState", {state = "FATE_PRE_GAME", quit_count = 0, safe_to_leave = 0})
    ServerTables:CreateTable("Players", {total_player = 0})
    ServerTables:CreateTable("LaPucelle", {active = false})
    ServerTables:CreateTable("GameMode", {mode = 'classic'})
    ServerTables:CreateTable("Condition", {dbhruntproh = false, archer = false, kuro = false, female = 0, divine = 0})
    ServerTables:CreateTable("Win", {goal = 0})
    ServerTables:CreateTable("Dev", {zef = false, pepe = false, mod = false, sss = false})
    ServerTables:CreateTable("PEPE", {slayer = false, savior = false, pepe = false, total = 0, kill = 0})
    ServerTables:CreateTable("Load", {player = 0})
    ServerTables:CreateTable("AutoBalance", {auto_balance = false})
    ServerTables:CreateTable("IsNewbie", {new = false})
    ServerTables:CreateTable("MVP", {draw = false, team1 = false, team2 = false, ffa = false, reward = false})

    if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
        CustomNetTables:SetTableValue("mode", "mode", {mode = true})
        ServerTables:CreateTable("GameModeChoice", {dm = false})
        ServerTables:CreateTable("Score", {nRadiantScore = 0, nDireScore = 0, round = 0})
        ServerTables:CreateTable("avarice", {Radiant = 0, Dire = 0})
        CustomGameEventManager:Send_ServerToAllClients("avarice_upgrade", {radiant_avarice = 0, dire_avarice = 0})
    elseif _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_trio" then 
        CustomNetTables:SetTableValue("mode", "grail_mode", {mode = true})
        ServerTables:CreateTable("GameModeChoice", {gm = false})
    end

    
end

function FateGameMode:calcMVPFFA()

end

function FateGameMode:startMVPMark()
    print('cal MVP')
    GameRules:SendCustomMessage("#Fate_MVP_Mark_Start", 0, 0)
    ServerTables:SetTableValue("MVP", "draw", true, true)
    --local max_player = ServerTables:GetTableValue("MaxPlayers", "total_player")
    for i = 0, 13 do
        if PlayerResource:IsValidPlayerID(i) then
            local playerHero = PlayerResource:GetSelectedHeroEntity(i)
            --print(playerHero:GetName())
            playerHero.ServStat.death = playerHero.ServStat.death or 0
            playerHero.ServStat.kill = playerHero.ServStat.kill or 0
            playerHero.ServStat.assist = playerHero.ServStat.assist or 0
            local mvp_point = math.max((3 * playerHero.ServStat.kill) + playerHero.ServStat.assist - (2 * playerHero.ServStat.death) - (2 * playerHero.ServStat.tkill), 1)

            if PlayerResource:GetTeam(i) == 2 then
                table.insert(self.MVPA, {playerId = i, mvpPoint = mvp_point, hero = playerHero})
            elseif PlayerResource:GetTeam(i) == 3 then
                table.insert(self.MVPB, {playerId = i, mvpPoint = mvp_point, hero = playerHero})
            end
        end
    end

    table.sort(self.MVPA, function(a,b) return a.mvpPoint > b.mvpPoint end)

    table.sort(self.MVPB, function(a,b) return a.mvpPoint > b.mvpPoint end)

    ServerTables:SetTableValue("MVP", "team1", self.MVPA[1]['hero']:entindex(), true)
    ServerTables:SetTableValue("MVP", "team2", self.MVPB[1]['hero']:entindex(), true)

    --local hMVPA = self.MVPA[1]['hero']
    --local hMVPB = self.MVPB[1]['hero']
    local duration = PRE_ROUND_DURATION + ROUND_DURATION

    Timers:CreateTimer(PRE_ROUND_DURATION, function()
        local hMVPA = EntIndexToHScript(ServerTables:GetTableValue("MVP", "team1"))
        local hMVPB = EntIndexToHScript(ServerTables:GetTableValue("MVP", "team2"))
        giveUnitDataDrivenModifier(hMVPA, hMVPB, "modifier_mvp_marker1", ROUND_DURATION)
        giveUnitDataDrivenModifier(hMVPB, hMVPA, "modifier_mvp_marker2", ROUND_DURATION)
    end)
    local reward = {}
    --local random = RandomInt(1, 3)

    for k,v in pairs(self.MVPHuntReward) do 
        --print(k,v)
        if v.IsCooldown == 0 then 
            reward = {
                ID = v.ID,
                Reward = v.Reward,
                RewardType = v.RewardType,
            } 
            ServerTables:SetTableValue("MVP", "reward", reward, true)
            v.IsCooldown = 1 
            Timers:CreateTimer(v.Cooldown, function()
               v.IsCooldown = 0  
            end)
            return 
        end
    end
end

function FateGameMode:resetMVP()
    self.MVPA[1]['hero']:RemoveModifierByName("modifier_mvp_marker2")
    self.MVPB[1]['hero']:RemoveModifierByName("modifier_mvp_marker1")
    self.MVPA = {}
    self.MVPB = {}
    ServerTables:SetTableValue("MVP", "team1", false, true)
    ServerTables:SetTableValue("MVP", "team2", false, true)
    ServerTables:SetTableValue("MVP", "draw", false, true)

end

function FateGameMode:rewardMVP(iTeam)
    local reward_table = ServerTables:GetTableValue("MVP", "reward")
    local reward_id = reward_table.ID
    local reward_object = reward_table.Reward
    print("id " .. reward_id)
    print("reward +" .. reward_object .. reward_table.RewardType)

    self:LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:GetTeamNumber() == iTeam then 
            if reward_id == 1 then 
                playerHero.MasterUnit:GiveMana(reward_object)
                playerHero.MasterUnit2:GiveMana(reward_object)
            elseif reward_id == 2 then 
                playerHero.MasterUnit:Heal(reward_object, playerHero.MasterUnit)
            elseif reward_id == 3 then 
                playerHero:SetGold(0, false)
                playerHero:SetGold(playerHero:GetGold() + reward_object, true)
            end
        end
    end)
end

function CountdownTimer()
    nCountdown = nCountdown + 1
    local t = nCountdown

    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "timer_think", broadcast_gametimer )
end

---------------------------------------------------------------------------
-- A timer that thinks every second
---------------------------------------------------------------------------
function FateGameMode:OnGameTimerThink()
    -- Stop thinking if game is paused
    if GameRules:IsGamePaused() == true then
        print('pausing')
        local xxx = CommandLineCheck("CDOTAGameRules")
        print('sdf' .. xxx)
        if CommandLineCheck("CDOTAGameRules") == true then 
            print('yes found it!')
            local playerid = CommandLineStr("Pause", "PlayerId")
            print(playerid)
        end
        return 1
    end
    CountdownTimer()
    return 1
end

-- reason_const
-- reliable
-- player_id_const
-- gold
function FateGameMode:ModifyGoldFilter(filterTable)
    -- Disable gold gain from hero kills
    --local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
    --local leaverCount = HasLeaversInTeam(hero)
    --print("gold = " .. filterTable["gold"])
    --print("reliable = " .. filterTable["reliable"])
    --print("reason = " .. filterTable["reason_const"])

    if filterTable["reason_const"] == DOTA_ModifyGold_HeroKill then
        --print('hero kill gold reason')
        filterTable["gold"] = 0
        filterTable["reliable"] = 1
        return false
    end

    if filterTable["reason_const"] == DOTA_ModifyGold_Unspecified then
        print('assist')
        filterTable["reliable"] = 1
        return true
    end

    if filterTable["reason_const"] == DOTA_ModifyGold_CreepKill then
        filterTable["reliable"] = 1
        return true
    end

    if filterTable["reliable"] == false then 
        return false 
    end

    -- filterTable["gold"] = filterTable["gold"] + filterTable["gold"] * (0.15 * leaverCount)
    return true
end

-- hero_entindex_const
-- reason_const
-- experience
-- player_id_const
function FateGameMode:ModifyExperienceFilter(filterTable)
    --[[local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
    local leaverCount = HasLeaversInTeam(hero)

    filterTable["experience"] = filterTable["experience"] + filterTable["experience"] * (0.15 * leaverCount)]]
    return true
end

function FateGameMode:TakeDamageFilter(filterTable)
    local damage = filterTable.damage
    local damageType = filterTable.damagetype_const

    if not filterTable.entindex_attacker_const then
        return
    end

    local attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
    local inflictor = nil
    if filterTable.entindex_inflictor_const then
        inflictor = EntIndexToHScript(filterTable.entindex_inflictor_const) -- the skill name
    end
    local victim = EntIndexToHScript(filterTable.entindex_victim_const)

    if attacker:HasModifier("modifier_love_spot_charmed") and victim:GetName() == "npc_dota_hero_huskar" then
        local loveSpotAbil = victim:FindAbilityByName("diarmuid_love_spot")
        if loveSpotAbil == nil then 
            loveSpotAbil = victim:FindAbilityByName("diarmuid_love_spot_upgrade")
        end
        local reduction = loveSpotAbil:GetLevelSpecialValueFor("damage_reduction", loveSpotAbil:GetLevel() - 1)
        filterTable.damage = filterTable.damage/100 * (100-reduction)
        damage = damage/100 * (100-reduction)
    end
    
    -- Functionality for the False Promise part of NR's new ult.
    if victim:HasModifier("modifier_qgg_oracle") then
        local hModifier = victim:FindModifierByName("modifier_qgg_oracle")
        local tInfo = { hAttacker = attacker, fDamage = damage, eDamageType = damageType }
        tInfo.hAbility = inflictor
        table.insert(hModifier.tDamageInstances, tInfo)
        return false
    end

    -- if Nursery Rhyme's Doppelganger is attemping to deal lethal damage
    if inflictor and inflictor:GetName() == "nursery_rhyme_doppelganger" and damage > victim:GetHealth() then
        --print("no u cant kill")
        victim:SetHealth(100000)
        victim.bIsInvulDuetoDoppel = true
    end
    if not attacker.bIsDmgPopupDisabled then
        if damageType == 1 or damageType == 2 or damageType == 4 then
            PopupDamage(victim, math.floor(damage), Vector(255,255,255), damageType)
        end
    end
    return true
end

function FateGameMode:ExecuteOrderFilter(filterTable)
    --[[for k,v in pairs(filterTable) do
        print(k,v)
    end]]
    local ability = EntIndexToHScript(filterTable.entindex_ability) -- the handle of item
    local target = EntIndexToHScript(filterTable.entindex_target)
    local units = filterTable.units
    local targetIndex = filterTable.entindex_target-- the inventory target
    --print('item slot: ' .. targetIndex)
    local playerID = filterTable.issuer_player_id_const
    local orderType = filterTable.order_type
    local xPos = tonumber(filterTable.position_x)
    local yPos = tonumber(filterTable.position_y)
    local zPos = tonumber(filterTable.position_z)
    local caster = nil
    if units["0"] then
        caster = EntIndexToHScript(units["0"])
    end
    -- Find items
    -- DOTA_UNIT_ORDER_PURASE_ITEM = 16
    -- DOTA_UNIT_ORDER_SELL_ITEM = 17
    -- DOTA_UNIT_ORDER_DISASSEMBLE_ITEM = 18
    -- DOTA_UNIT_ORDER_MOVE_ITEM = 19(drag and drop)

    -- attack command
    -- What do we do when handling the move between inventory and stash?
    if orderType == 11 then
    end

    if orderType == DOTA_UNIT_ORDER_RADAR then
        return false
    end
    if orderType == 19 then
        local currentItemIndex, itemName = nil
        local charges = -1
        for i=0, 16 do -- neutral slot = 16, tp slot = 15(but u cant drag BRUH)
            if ability == caster:GetItemInSlot(i) then
                currentItemIndex = i
                itemName = ability:GetName()
                charges = ability:GetCurrentCharges()
                break
            end
        end
        if currentItemIndex == nil then return false end
        --print('current index = ' .. currentItemIndex)
        --print('target index = ' .. targetIndex)
        if caster:GetItemInSlot(currentItemIndex):GetName() == "item_blink_scroll" and targetIndex > 5 then 
            return false
        elseif caster:GetItemInSlot(targetIndex) ~= nil then
            if caster:GetItemInSlot(targetIndex):GetName() == "item_blink_scroll" and currentItemIndex > 5 then 
                return false 
            end
        end
        caster:SwapItems(currentItemIndex, targetIndex)
        CheckItemCombination(caster)
        CheckItemCombinationInStash(caster)
        SaveStashState(caster)
        return false
    -- drop item from stash
    elseif orderType == 25 then 
        if caster:GetItemInSlot(targetIndex):GetName() == "item_blink_scroll" or caster:GetItemInSlot(targetIndex):GetName() == "item_shard_of_anti_magic" then
            return false 
        end
    -- What do we do when item is bought?
    elseif orderType == 16 then        
    -- What do we do when we sell items?
    elseif orderType == 17 then
        EmitSoundOnClient("General.Sell", caster:GetPlayerOwner())
        PlayerResource:SetGold(playerID, 0, false)
        caster:SetGold(0, false)
        caster:SetGold(caster:GetGold() + (GetItemCost(ability:GetName()) * 0.5), true)
        --caster:ModifyGold(GetItemCost(ability:GetName()) *0.5, true , 0)
        ability:RemoveSelf()
        SaveStashState(caster)
        return false
    --[[elseif orderType == 8 then  -- cast no target
        if ability:IsItem() and caster:IsRealHero() then 
            for i=0, 17 do 
                if caster:GetItemInSlot(i) ~= nil and caster:GetItemInSlot(i) ~= ability and caster:GetItemInSlot(i):GetAbilityName() == ability:GetAbilityName() then
                    caster:GetItemInSlot(i):EndCooldown()
                    caster:GetItemInSlot(i):StartCooldown(ability:GetCooldown(1))
                end
            end
            return true
        end
        return true]]
    end

    if orderType == DOTA_UNIT_ORDER_CAST_POSITION then
        print(ability:GetAbilityName())
        if ability:GetAbilityName() == "astolfo_hippogriff_raid" or ability:GetAbilityName() == "astolfo_hippogriff_raid_upgrade" then
            local location = Vector(xPos, yPos, zPos)
            local origin = caster:GetAbsOrigin()
            
            if (location - origin):Length2D() <= ability:GetCastRange() then
                local facing = caster:GetForwardVector()
                local offset = origin + facing * 10

                filterTable.position_x = tostring(offset.x)
                filterTable.position_y = tostring(offset.y)
                filterTable.position_z = tostring(offset.z)
            end
            caster.HippogriffCastLocation = location
       end
    end
    return true
end

function FateGameMode:ItemAddedFilter(args)
    local item = EntIndexToHScript(args.item_entindex_const)
    if item:GetName() == "item_tpscroll" then return false end

    return true
end

function FateGameMode:InitializeRound()
    -- Flag game mode as pre round, and display tip
    _G.IsPreRound = true
    ServerTables:SetTableValue("LaPucelle", "active", false, true)
    --_G.LaPucelleActivated = false
    _G.FIRST_BLOOD_TRIGGERED = false
    CreateUITimer("Pre-Round", PRE_ROUND_DURATION, "pregame_timer")
    --FireGameEvent('cgm_timer_display', { timerMsg = "Pre-Round", timerSeconds = 16, timerEnd = true, timerPosition = 0})
    --DisplayTip()
    GameRules:SendCustomMessage("Round "..self.nCurrentRound.." will begin in " .. PRE_ROUND_DURATION .. " seconds.", 0, 0)
    --Say(nil, string.format("Round %d will begin in " .. PRE_ROUND_DURATION .. " seconds.", self.nCurrentRound), false) -- Valve please

    local msg = {
        message = "Round " .. self.nCurrentRound .. " has begun!",
        duration = 4.0
    }
    local alertmsg = {
        message = "#Fate_Timer_30_Alert",
        duration = 4.0
    }
    local alertmsg2 = {
        message = "#Fate_Timer_10_Alert",
        duration = 4.0
    }
    local timeoutmsg = {
        message = "#Fate_Timer_Timeout",
        duration = 4.0
    }
    if self.nCurrentRound == 1 --[[or self.nCurrentRound == 10]] then
        if ServerTables:GetAllTableValues("EventPadoru") ~= false and ServerTables:GetTableValue("GameMode", "mode") == "classic" then 
            Notifications:TopToAll({text="<font color='#58ACFA'>Padoru Hat</font> inbound! It will drop onto random location within spawn area.", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="35px"}})
            EmitGlobalSound( "Merry_Padoru" )
            Timers:CreateTimer(5, function()
                local padoru_hat1 = CreateItem( "item_padoru_hat", nil, nil )
                local padoru_hat2 = CreateItem( "item_padoru_hat", nil, nil )
                local hat_pos1 = SPAWN_POSITION_RADIANT_DM + Vector(RandomInt(-200,200), RandomFloat(-200, 200), 0)
                local hat_pos2 = SPAWN_POSITION_DIRE_DM + Vector(RandomInt(-200,200), RandomFloat(-200, 200), 0)
                local drop1 = CreateItemOnPositionForLaunch( hat_pos1 + Vector(0,0,500), padoru_hat1 )
                local drop2 = CreateItemOnPositionForLaunch( hat_pos2 + Vector(0,0,500), padoru_hat2 )
                padoru_hat1:LaunchLootInitialHeight( false, 500, 50, 0.5, hat_pos1 )
                padoru_hat2:LaunchLootInitialHeight( false, 500, 50, 0.5, hat_pos2 )
            end)
        end
    end

    -- Set up heroes for new round
    self:LoopOverPlayers(function(ply, plyID, playerHero)
        local hero = playerHero

        if hero:GetName() == "npc_dota_hero_troll_warlord" then
            hero:RemoveModifierByName("modifier_board_drake")
        elseif hero:GetName() == "npc_dota_hero_phantom_assassin" then
            hero:RemoveModifierByName("modifier_semiramis_mounted")
        elseif hero:GetName() == "npc_dota_hero_shadow_shaman" then
            hero:RemoveModifierByName("modifier_integrate_gille")
        elseif hero:GetName() == "npc_dota_hero_crystal_maiden" then
            hero:RemoveModifierByName("modifier_mount_caster")
        end

        ResetAbilities(hero)
        ResetItems(hero)
        ResetMasterAbilities(hero)
        
        hero:RemoveModifierByName("round_pause")
        RemoveTroublesomeModifiers(hero)
        giveUnitDataDrivenModifier(hero, hero, "round_pause", PRE_ROUND_DURATION) -- Pause all heroes
        PlayerResource:SetGold(plyID, 0, false)
        --hero:SetGold(0, false)

        if hero.AvariceCount ~= nil then
            hero.MasterUnit:GiveMana(math.min(math.ceil(hero.AvariceCount/3), 2))
            hero.MasterUnit2:GiveMana(math.min(math.ceil(hero.AvariceCount/3), 2))
            if hero.AvariceCount >= 2 then 
                hero.MasterUnit:Heal(1, hero.MasterUnit)
            end
            --print("granted more mana")
        end

        if hero.ProsperityCount ~= nil then
            hero.MasterUnit:Heal(1, hero.MasterUnit)
        end

        -- Grant gold
        if self.nCurrentRound > 1 then
            hero.CStock = 10
            hero:SetGold(0, false)
            --print('Gold Before Round End : '.. hero:GetGold())
            local reliablegold = hero:GetGold()
            --PlayerResource:GetReliableGold(plyID)
            local unreliablegold = PlayerResource:GetUnreliableGold(plyID)
            --print('Reliable Gold Before Round End : '.. reliablegold)
            --print('Unreliable Gold Before Round End : '.. unreliablegold)
            if reliablegold < 5000 then
            --if hero:GetGold() < 5000 then    
                --print("[FateGameMode] " .. hero:GetName() .. " gained 3000 gold at the start of round")
                if hero.AvariceCount ~= nil then
                    hero:SetGold(hero:GetGold() + 3000 + (hero.AvariceCount * 300), true)
                    --hero:ModifyGold(3000 + hero.AvariceCount * 1500, true, 0)
                else
                    hero:SetGold(hero:GetGold() + 3000, true)
                    --hero:ModifyGold(3000, true, 0)
                    --PlayerResource:ModifyGold(plyID, 3000, true, 0)
                end
            end

            --local xpBonus = 100 + 
            hero.IsFreeWarpUse = false 
            hero.IsWarpCooldown = false
            hero:AddExperience(self.nCurrentRound * 120, false, false)
            if hero.ProsperityCount ~= nil then
                hero:AddExperience(self.nCurrentRound * 120 * 0.5, false, false)
            end
            --print('Gold Round Start : '.. hero:GetGold())
        end
    end)

    if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
        if self.nCurrentRound >= 6 and (self.nDireScore == self.nRadiantScore) then
            self:startMVPMark()
        end
    end

    Timers:CreateTimer('beginround', {
        endTime = PRE_ROUND_DURATION,
        callback = function()
            print("[FateGameMode]Round started.")
            _G.CurrentGameState = "FATE_ROUND_ONGOING"
            ServerTables:SetTableValue("GameState", "state", "FATE_ROUND_ONGOING", true)
            _G.IsPreRound = false
            _G.RoundStartTime = GameRules:GetGameTime()
            CreateUITimer(("Round " .. self.nCurrentRound), ROUND_DURATION, "round_timer" .. self.nCurrentRound)
            --FireGameEvent('cgm_timer_display', { timerMsg = ("Round " .. self.nCurrentRound), timerSeconds = 151, timerEnd = true, timerPosition = 0})
            --roundQuest = StartQuestTimer("roundTimerQuest", "Round " .. self.nCurrentRound, 150)

            self:LoopOverPlayers(function(player, playerID, playerHero)
                ResetItems(playerHero)
                if playerHero.AvariceCount ~= nil then
                    print('Avarice Count ' .. playerHero.AvariceCount)
                    if playerHero.AvariceCount >= 3 then 
                        AddInertiaModifier(playerHero)
                    end
                end
                --[[if playerHero:GetTeamNumber() == DOTA_TEAM_BADGUYS and self.nDireScore > self.nRadiantScore + 1 then
                    AddInertiaModifier(playerHero)
                elseif playerHero:GetTeamNumber() == DOTA_TEAM_GOODGUYS and self.nRadiantScore > self.nDireScore + 1 then
                    AddInertiaModifier(playerHero)
                end]]

                playerHero:RemoveModifierByName("round_pause")
                playerHero.ServStat:roundNumber(self.nCurrentRound)
            end)

            FireGameEvent("show_center_message",msg)

            if self.nCurrentRound == 1 then
                if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
                    EmitAnnouncerSound("Battle_Begins_" .. math.random(1,2) .. "_Xmas")
                else
                    EmitAnnouncerSound("Battle_Begins_" .. math.random(1,3))
                end
            elseif self.nRadiantScore == VICTORY_CONDITION - 1 and self.nDireScore == VICTORY_CONDITION - 1 then
                if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
                    EmitAnnouncerSound("Last_Round_Xmas")
                else
                    EmitAnnouncerSound("Last_Round_" .. math.random(1,2))
                end
            else
                if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
                    EmitAnnouncerSound("Round_Start_" .. math.random(1,3) .. "_Xmas")
                else
                    EmitAnnouncerSound("Round_Start_" .. math.random(1,2))
                end
            end
        end
    })

    Timers:CreateTimer('presence_alert', {
        endTime = PRESENCE_ALERT_DURATION + PRE_ROUND_DURATION,
        callback = function()
            GameRules:SendCustomMessage("#Fate_Presence_Alert", 0, 0)
        end
    })

    Timers:CreateTimer('round_30sec_alert', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION - 30,
        callback = function()
            FireGameEvent("show_center_message",alertmsg)
        end
    })

    Timers:CreateTimer('round_10sec_alert', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION - 10,
        callback = function()
            FireGameEvent("show_center_message",alertmsg2)
        end
    })

    Timers:CreateTimer('round_timer', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION,
        callback = function()
            print("[FateGameMode]Round timeout.")
            FireGameEvent("show_center_message",timeoutmsg)
            local nRadiantAlive = 0
            local nDireAlive = 0
            local Dead = false
            -- Check how many people are alive in each team
            self:LoopOverPlayers(function(player, playerID, playerHero)
                if playerHero:IsAlive() then
                    if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                        nRadiantAlive = nRadiantAlive + 1
                        --[[if playerHero:HasModifier("modifier_mvp_marker2") then 
                            nRadiantAlive = nRadiantAlive + 1
                        end]]
                    else
                        nDireAlive = nDireAlive + 1
                        --[[if playerHero:HasModifier("modifier_mvp_marker1") then 
                            nDireAlive = nDireAlive + 1
                        end]]
                    end 
                else
                    Dead = true              
                end
            end)

            if ServerTables:GetTableValue("LaPucelle", "active") == false then
            -- if nRadiantAlive > 6 then nRadiantAlive = 6 end
            -- if nDireAlive > 6 then nDireAlive = 6 end
            -- if remaining players are equal
                if nRadiantAlive == nDireAlive then
                    if ServerTables:GetTableValue("avarice", "Radiant") == true and ServerTables:GetTableValue("avarice", "Dire") == true then 
                        self:FinishRound(true, 2)
                    elseif ServerTables:GetTableValue("avarice", "Radiant") == true and ServerTables:GetTableValue("avarice", "Dire") == false and Dead == true then
                        self:FinishRound(true,5)     
                    elseif ServerTables:GetTableValue("avarice", "Radiant") == false and ServerTables:GetTableValue("avarice", "Dire") == true and Dead == true then
                        self:FinishRound(true,6) 
                    else 
                        -- Default Radiant Win
                        if self.nRadiantScore + 0 < self.nDireScore
                            then self:FinishRound(true,3)
                        -- Default Dire Win
                        elseif self.nRadiantScore > self.nDireScore + 0
                            then self:FinishRound(true,4)
                        -- Draw
                        else
                            --if self.nRadiantScore == self.nDireScore
                            --then 
                            self:FinishRound(true, 2)
                        end
                    end
                -- if remaining players are not equal
                elseif nRadiantAlive > nDireAlive then
                    self:FinishRound(true, 0)
                elseif nRadiantAlive < nDireAlive then
                    self:FinishRound(true, 1)
                end
            end
        end
    })
end

--[[
0 : Radiant
1 : Dire
2 : Draw
3 : Radiant(by default)
4 : Dire(by default)]]
function FateGameMode:FinishRound(IsTimeOut, winner)
    print("[FATE] Winner decided")
    --UTIL_RemoveImmediate( roundQuest ) -- Stop round timer
    print(self.nRadiantScore)
    if ServerTables:GetTableValue("MVP", "draw") == true then
        self:resetMVP()
    end
    _G.CurrentGameState = "FATE_POST_ROUND"   
    ServerTables:SetTableValue("GameState", "state", "FATE_POST_ROUND", true) 
    
    CreateUITimer(("Round " .. self.nCurrentRound), 0, "round_timer" .. self.nCurrentRound)
    CreateUITimer("Pre-Round", 0, "pregame_timer")

    -- clean up marbles and pause heroes for 5 seconds(as well as NR combo)
    self:LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:IsAlive() then
            giveUnitDataDrivenModifier(playerHero, playerHero, "round_pause", 5.0)
        end

        -- Remove marble abilities
        if playerHero:GetName() == "npc_dota_hero_ember_spirit" and playerHero:HasModifier("modifier_unlimited_bladeworks") then
            playerHero:RemoveModifierByName("modifier_unlimited_bladeworks")
        elseif playerHero:GetName() == "npc_dota_hero_chen" and playerHero:HasModifier("modifier_army_of_the_king_death_checker") then
            playerHero:RemoveModifierByName("modifier_army_of_the_king_death_checker")
        elseif playerHero:GetName() == "npc_dota_hero_doom_bringer" then -- god hand revive
            if playerHero.RespawnPos then
                playerHero:SetRespawnPosition(playerHero.RespawnPos)
            end 
        elseif playerHero:GetName() == "npc_dota_hero_vengefulspirit" then -- endless loop revive
            if playerHero.RespawnPos then
                playerHero:SetRespawnPosition(playerHero.RespawnPos)
            end
        elseif playerHero:GetName() == "npc_dota_hero_crystal_maiden" then
            playerHero:RemoveModifierByName("modifier_caster_death_checker")
            playerHero.IsTerritoryPresent = false
        elseif playerHero:GetName() == "npc_dota_hero_lina" then -- nero
            playerHero:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
        elseif playerHero:GetName() == "npc_dota_hero_enigma" then
            playerHero:RemoveModifierByName("modifier_right_hand")
            playerHero:RemoveModifierByName("modifier_amakusa_baptism")
        elseif playerHero:GetName() == "npc_dota_hero_tidehunter" then
            playerHero:RemoveModifierByName("modifier_vlad_rebellious_intent")
        elseif playerHero:GetName() == "npc_dota_hero_dark_willow" and playerHero:HasModifier("modifier_flag_summon") then -- shinsengumi
            playerHero:RemoveModifierByName("modifier_flag_summon")
        elseif playerHero:GetName() == "npc_dota_hero_disruptor" then
            playerHero:RemoveModifierByName("modifier_zhuge_liang_array_checker")
        elseif playerHero:GetName() == "npc_dota_hero_sven" then
            playerHero:RemoveModifierByName("modifier_gatling_weapon")
        elseif playerHero:GetName() == "npc_dota_hero_skeleton_king" then
            playerHero:RemoveModifierByName("modifier_kinghassan_combo_cast")
        elseif playerHero:GetName() == "npc_dota_hero_dragon_knight" then 
            playerHero:RemoveModifierByName("modifier_mashu_protect_self")
        end

        if playerHero:HasModifier("modifier_saint_debuff") then
            playerHero:RemoveModifierByName("modifier_saint_debuff")
        end
        if playerHero:HasModifier("modifier_story_for_someones_sake") then
            playerHero:RemoveModifierByName("modifier_story_for_someones_sake")
        end
        if playerHero:HasModifier("modifier_story_for_someones_sake_enemy") then
            playerHero:RemoveModifierByName("modifier_story_for_someones_sake_enemy")
        end
        if playerHero:HasModifier("modifier_gae_buidhe") or playerHero:HasModifier("modifier_gae_dearg") then
            playerHero:RemoveModifierByName("modifier_gae_buidhe")
            playerHero:RemoveModifierByName("modifier_gae_dearg")
        end

        if playerHero:HasModifier("modifier_mashu_combo_barrier") then
            playerHero:RemoveModifierByName("modifier_mashu_combo_barrier")
        end

        if playerHero:HasModifier("modifier_mount_caster") then
            playerHero:RemoveModifierByName("modifier_mount_caster")
        end

        if playerHero:GetName() == "npc_dota_hero_shadow_shaman" then
            playerHero:RemoveModifierByName("modifier_integrate_gille")
            playerHero:RemoveModifierByName("modifier_integrate")
        end

        if playerHero:GetName() == "npc_dota_hero_death_prophet" then
            playerHero:RemoveModifierByName("modifier_bathory_cage_check")
        end

        if playerHero:GetName() == "npc_dota_hero_troll_warlord" then
            playerHero:RemoveModifierByName("modifier_board_drake")
            playerHero:RemoveModifierByName("modifier_board")
            playerHero:RemoveModifierByName("modifier_golden_wild_hunt_check")
        end

        if playerHero:GetName() == "npc_dota_hero_phantom_assassin" then 
            playerHero:RemoveModifierByName("modifier_semiramis_mounted")
        end
    end)

    -- Remove all units
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
    local units2 = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
    for k,v in pairs(units) do
        if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
            for i=1, #DoNotKillAtTheEndOfRound do
                if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                    v:ForceKill(true)
                end
            end
        end
    end
    for k,v in pairs(units2) do
        if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
            for i=1, #DoNotKillAtTheEndOfRound do
                if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                    v:ForceKill(true)
                end
            end
        end
    end

    -- decide the winner
    if winner == 0 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_1", 0, 0)
        self.nRadiantScore = self.nRadiantScore + 1
        ServerTables:SetTableValue("Score", "nRadiantScore", self.nRadiantScore, true)
        winnerEventData.winnerTeam = 0
        GameRules.Winner = 2
        statCollection:submitRound(false)
        if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
            if self.nRadiantScore == 8 then 
                self:LoopOverPlayers(function(player, playerID, playerHero)
                    local hero = playerHero
                    if hero:GetTeam() == DOTA_TEAM_BADGUYS then 
                        hero.ShardAmount = hero.ShardAmount + 1
                        local statTable = CreateTemporaryStatTable(hero)
                        CustomGameEventManager:Send_ServerToPlayer( player, "servant_stats_updated", statTable ) -- Send the current stat info to JS
                    end
                end)
            end
        end
    elseif winner == 1 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_2", 0, 0)
        ServerTables:SetTableValue("Score", "nDireScore", self.nDireScore, true)
        self.nDireScore = self.nDireScore + 1
        winnerEventData.winnerTeam = 1
        GameRules.Winner = 3
        statCollection:submitRound(false)
        if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
            if self.nDireScore == 8 then 
                self:LoopOverPlayers(function(player, playerID, playerHero)
                    if playerHero:GetTeam() == 2 then 
                        playerHero.ShardAmount = playerHero.ShardAmount + 1
                        local statTable = CreateTemporaryStatTable(playerHero)
                        CustomGameEventManager:Send_ServerToPlayer( player, "servant_stats_updated", statTable ) -- Send the current stat info to JS
                    end
                end)
            end
        end
    elseif winner == 2 then
        GameRules:SendCustomMessage("#Fate_Round_Draw", 0, 0)
        winnerEventData.winnerTeam = 2
        EmitAnnouncerSound("Game_Draw")
        --[[if self.bDrawChestDrop == false then 
            self:calcMVP()
        end]]
    elseif winner == 3 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_1_By_Default", 0, 0)
        self.nRadiantScore = self.nRadiantScore + 1
        ServerTables:SetTableValue("Score", "nRadiantScore", self.nRadiantScore, true)
        winnerEventData.winnerTeam = 0
        GameRules.Winner = 2
        statCollection:submitRound(false)
        if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
            if self.nRadiantScore == 8 then 
                self:LoopOverPlayers(function(player, playerID, playerHero)
                    if playerHero:GetTeam() == 3 then 
                        playerHero.ShardAmount = playerHero.ShardAmount + 1
                        local statTable = CreateTemporaryStatTable(playerHero)
                        CustomGameEventManager:Send_ServerToPlayer( player, "servant_stats_updated", statTable ) -- Send the current stat info to JS
                    end
                end)
            end
        end
    elseif winner == 4 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_2_By_Default", 0, 0)
        self.nDireScore = self.nDireScore + 1
        ServerTables:SetTableValue("Score", "nDireScore", self.nDireScore, true)
        winnerEventData.winnerTeam = 1
        GameRules.Winner = 3
        statCollection:submitRound(false)
        if ServerTables:GetTableValue("GameMode", "mode") == "draft" then 
            if self.nDireScore == 8 then 
                self:LoopOverPlayers(function(player, playerID, playerHero)
                    if playerHero:GetTeam() == 2 then 
                        playerHero.ShardAmount = playerHero.ShardAmount + 1
                        local statTable = CreateTemporaryStatTable(playerHero)
                        CustomGameEventManager:Send_ServerToPlayer( player, "servant_stats_updated", statTable ) -- Send the current stat info to JS
                    end
                end)
            end
        end
    elseif winner == 5 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_1_By_Grail", 0, 0)
        self.nRadiantScore = self.nRadiantScore + 1
        ServerTables:SetTableValue("Score", "nRadiantScore", self.nRadiantScore, true)
        winnerEventData.winnerTeam = 0
        GameRules.Winner = 2
        statCollection:submitRound(false)
    elseif winner == 6 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_2_By_Grail", 0, 0)
        self.nDireScore = self.nDireScore + 1
        ServerTables:SetTableValue("Score", "nDireScore", self.nDireScore, true)
        winnerEventData.winnerTeam = 1
        GameRules.Winner = 3
        statCollection:submitRound(false)
    end

    if self.nRadiantScore == VICTORY_CONDITION or self.nDireScore == VICTORY_CONDITION then
        if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
            EmitAnnouncerSound("Game_End_Xmas") 
        else
            EmitAnnouncerSound("Game_End_" .. math.random(1,3)) 
        end   
    elseif self.nRadiantScore - self.nDireScore > 6 and winner == 0 then
        if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
            EmitAnnouncerSound("Landslide_Xmas") 
        else
            EmitAnnouncerSound("Landslide_" .. math.random(1,2))
        end
    elseif self.nDireScore - self.nRadiantScore > 6 and winner == 1 then
        if ServerTables:GetAllTableValues("EventPadoru") ~= false then 
            EmitAnnouncerSound("Landslide_Xmas") 
        else
            EmitAnnouncerSound("Landslide_" .. math.random(1,2))
        end
    end

    winnerEventData.radiantScore = self.nRadiantScore
    winnerEventData.direScore = self.nDireScore
    CustomNetTables:SetTableValue("score", "CurrentScore", { nRadiantScore = self.nRadiantScore, nDireScore = self.nDireScore })
    CustomGameEventManager:Send_ServerToAllClients( "winner_decided", winnerEventData ) -- Send the winner to Javascript
    GameRules:SendCustomMessage("#Fate_Round_Gold_Note", 0, 0)
    self:LoopOverPlayers(function(player, playerID, playerHero)
        local pHero = playerHero
        -- radiant = 2(equivalent to 0)
        -- dire = 3(equivalent to 1)

        if pHero:GetTeam() - 2 ~= winnerEventData.winnerTeam and winnerEventData.winnerTeam ~= 2 then
            pHero.MasterUnit:GiveMana(1)
            pHero.MasterUnit2:SetMana(pHero.MasterUnit:GetMana())
            --print("granted 1 mana to " .. pHero:GetName())
        end
    end)
    -- Set score
    mode = GameRules:GetGameModeEntity()
    mode:SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireScore )
    mode:SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantScore )
    self.nCurrentRound = self.nCurrentRound + 1
    ServerTables:SetTableValue("Score", "round", self.nCurrentRound, true)
    
    self:LoopOverPlayers(function(player, playerID, playerHero)
        local hero = playerHero
        hero.ServStat:EndOfRound(self.nRadiantScore,self.nDireScore)
    end)
    
    -- check for win condition
    if self.nRadiantScore == VICTORY_CONDITION then
        ServerTables:SetTableValue("GameState", "state", "FATE_END_GAME", true)
        GameRules:SendCustomMessage("Red Faction Victory!",0,0)
        kjlpluo1596:calcMVP()  
        self:PauseAllHero()
        self:LoopOverPlayers(function(player, playerID, playerHero)
            local hero = playerHero
            --giveUnitDataDrivenModifier(hero, hero, "round_pause", 20)
            if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
                hero.ServStat:EndOfGame("Won")
                kjlpluo1596:initialize(playerID,1)
                --PlayerTables:CreateTable("EndScore", {won = 1}, playerID)
            else
                hero.ServStat:EndOfGame("Lost")
                kjlpluo1596:initialize(playerID,0)
                --PlayerTables:CreateTable("EndScore", {won = 0}, playerID)
            end
            hero.ServStat:printconsole()          
        end)    
        my_http_post()
        Timers:CreateTimer(5.0, function()
            GameRules:SetSafeToLeave( true )
            GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        end)
        return
    elseif self.nDireScore == VICTORY_CONDITION then

        ServerTables:SetTableValue("GameState", "state", "FATE_END_GAME", true)
        GameRules:SendCustomMessage("Black Faction Victory!",0,0)
        kjlpluo1596:calcMVP()
        self:PauseAllHero()
        self:LoopOverPlayers(function(player, playerID, playerHero)
            local hero = playerHero
            --giveUnitDataDrivenModifier(hero, hero, "round_pause", 20)
            if hero:GetTeam() == DOTA_TEAM_BADGUYS then
                hero.ServStat:EndOfGame("Won")
                --PlayerTables:CreateTable("EndScore", {won = 1}, playerID)
                kjlpluo1596:initialize(playerID,1)
            else
                hero.ServStat:EndOfGame("Lost")
                --PlayerTables:CreateTable("EndScore", {won = 0}, playerID)
                kjlpluo1596:initialize(playerID,0)
            end
            hero.ServStat:printconsole()
        end)
        my_http_post()
        Timers:CreateTimer(5.0, function()
            GameRules:SetSafeToLeave( true )
            GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
        end)
        return
    end

    Timers:CreateTimer('roundend', {
        endTime = 5,
        callback = function()
            -- Remove all units
            local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
            local units2 = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
            for k,v in pairs(units) do
                if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
                    for i=1, #DoNotKillAtTheEndOfRound do
                        --print(v:GetUnitName())
                        if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                            if string.match(v:GetUnitName(), "drake_golden_hind") then 
                                if v.bigship ~= nil then 
                                    for _,p in pairs(v.bigship) do 
                                        if p ~= nil then 
                                            ParticleManager:DestroyParticle(p, true)
                                            ParticleManager:ReleaseParticleIndex(p)
                                        end
                                    end 
                                end
                            end
                            v:ForceKill(true)
                        end
                    end
                end
            end
            for k,v in pairs(units2) do
                if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
                    for i=1, #DoNotKillAtTheEndOfRound do
                        --print(v:GetUnitName())
                        if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                            if string.match(v:GetUnitName(), "drake_golden_hind") then 
                                if v.bigship ~= nil then 
                                    for _,p in pairs(v.bigship) do 
                                        if p ~= nil then 
                                            ParticleManager:DestroyParticle(p, true)
                                            ParticleManager:ReleaseParticleIndex(p)
                                        end
                                    end 
                                end
                            end
                            v:ForceKill(true)
                        end
                    end
                end
            end
            _G.IsPreRound = true

            local team2Index = 0
            local team3Index = 0

            self:LoopOverPlayers(function(player, playerID, playerHero)
                local respawnPos = playerHero.RespawnPos
                if self.nCurrentRound >= 2 then
                    local index
                    local team = playerHero:GetTeam()
                    if team == 2 then
                        index = team2Index
                        team2Index = team2Index + 1
                    else
                        index = team3Index
                        team3Index = team3Index + 1
                    end
                    respawnPos = GetRespawnPos(playerHero, self.nCurrentRound, index)
                end
                playerHero:SetRespawnPosition(respawnPos)
                playerHero:RespawnHero(false, false)
                ProjectileManager:ProjectileDodge(playerHero)
            end, true)
            self:InitializeRound()
            _G.CurrentGameState = "FATE_PRE_ROUND"
            ServerTables:SetTableValue("GameState", "state", "FATE_PRE_ROUND", true) 
        end
    })

end

function GetRespawnPos(playerHero, currentRound, index)
    local vColumn = Vector(0, -200 ,0)
    local vRow = Vector(200, 0, 0)

    -- [0] [1]
    -- [2] [3]
    -- [4] [x] x is default spawn
    local radiantOffset = vColumn * -1 + vRow * -.5
    local radiantSpawn = SPAWN_POSITION_RADIANT_DM + radiantOffset

    -- [0] [1]
    -- [2] [x]
    -- [4] [5] x is default spawn
    local direOffset = vColumn * 1 + vRow * -.5
    local direSpawn = SPAWN_POSITION_DIRE_DM + direOffset

    local row = index % 2
    local column = math.floor(index / 2)
    if index == 6 then -- for 7th player
        row = 2
        column = 1
    end
    local offset = vRow * row + vColumn * column

    local team = playerHero:GetTeam()
    local respawnSide = (team + currentRound) % 2
    local defaultRespawnPos = respawnSide == 1 and radiantSpawn or direSpawn
    return defaultRespawnPos + vRow * row + vColumn * column
end

function FateGameMode:OnModifierGainedFilter(hFilterTable)
    --DeepPrintTable(hFilterTable)
    local hCaster       = ( type(hFilterTable.entindex_caster_const) == "number" ) and EntIndexToHScript(hFilterTable.entindex_caster_const) or nil
    local hParent       = ( type(hFilterTable.entindex_parent_const) == "number" ) and EntIndexToHScript(hFilterTable.entindex_parent_const) or nil
    local hAbility      = ( type(hFilterTable.entindex_ability_const) == "number" ) and EntIndexToHScript(hFilterTable.entindex_ability_const) or nil
    local fDuration     = hFilterTable.duration
    local sModifierName = hFilterTable.name_const

    if hParent == nil or not IsValidEntity(hParent) then 
        return false 
    end 
       
    return true
end

function FateGameMode:LoopOverPlayers(callback, withDummy)
    for i=0, 13 do
        local playerID = i
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
        if playerHero and (playerHero:GetName() ~= "npc_dota_hero_wisp" or withDummy) then
            --print("Looping through hero " .. playerHero:GetName())
            if callback(player, playerID, playerHero) then
                break
            end
        end
    end
end

-- This function is called as the first player loads and sets up the FateGameMode parameters
function FateGameMode:CaptureGameMode()
    print("First player loaded in, setting parameters")
    if mode == nil then
        -- Set FateGameMode parameters
        mode = GameRules:GetGameModeEntity()


        --mode:SetCameraDistanceOverride(1600)
        mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
        mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
        mode:SetBuybackEnabled( BUYBACK_ENABLED )
        mode:SetCustomBackpackSwapCooldown(0.0)
        mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 13)
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.25)
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 11)
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.2)
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 1)
        mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.1)
        mode:SetAlwaysShowPlayerNames(false)
        --screw 7.23
        mode:SetCustomXPRequiredToReachNextLevel( XP_TABLE )
        mode:SetUseCustomHeroLevels ( true )
        mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
        mode:SetGoldSoundDisabled( true )
        --mode:GetRecommendedItemsDisabled()
        mode:SetRemoveIllusionsOnDeath( true )
        mode:SetStashPurchasingDisabled ( false )
        mode:SetAnnouncerDisabled( true )
        mode:SetLoseGoldOnDeath( false )
        mode:SetExecuteOrderFilter( Dynamic_Wrap( FateGameMode, "ExecuteOrderFilter" ), FateGameMode )
        mode:SetModifierGainedFilter( Dynamic_Wrap( FateGameMode, "OnModifierGainedFilter" ), FateGameMode )
        --mode:SetItemAddedToInventoryFilter(Dynamic_Wrap(FateGameMode, "ItemAddedFilter"), FateGameMode) (screw 7.23 x2)
        mode:SetModifyGoldFilter(Dynamic_Wrap(FateGameMode, "ModifyGoldFilter"), FateGameMode)
        mode:SetDamageFilter(Dynamic_Wrap(FateGameMode, "TakeDamageFilter"), FateGameMode)
        mode:SetModifyExperienceFilter(Dynamic_Wrap(FateGameMode, "ModifyExperienceFilter"), FateGameMode)
        mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
        --mode:SetRecommendedItemsDisabled(false)
        --[[if not GameRules:IsDaytime() then
            GameRules:SetTimeOfDay(10.30)
            mode:SetDaynightCycleDisabled(true)
        end]]
        self:OnFirstPlayerLoaded()

        if _G.GameMap == "fate_elim_6v6" or _G.GameMap == "fate_elim_7v7" then
            mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
        end
    end
end

function FateGameMode:OnEventChecking()
    local event_table = LoadKeyValues("scripts/npc/fate_event.txt")
    for k,v in pairs(event_table) do 
        print('event id: ' .. v.EventID)
        if ServerTables:GetAllTableValues("Event" .. v.EventID) ~= false then  
            print('available event: ' .. v.EventID)
            if v.EventType == 2 then 
                for pID = 0, DOTA_MAX_PLAYERS -1 do 
                    if PlayerResource:IsValidPlayerID(pID) then
                        FateEvent:StartLimitedSkinEvent(pID, v)
                    end
                end
            elseif v.EventType == 4 then 
                for pID = 0, DOTA_MAX_PLAYERS -1 do 
                    if PlayerResource:IsValidPlayerID(pID) then
                        local ply = PlayerResource:GetPlayer(pID)
                        CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", v)
                    end
                end
            elseif v.EventType == 5 then 
                for pID = 0, DOTA_MAX_PLAYERS -1 do 
                    if PlayerResource:IsValidPlayerID(pID) then
                        local ply = PlayerResource:GetPlayer(pID)
                        CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", v)
                    end
                end
            end
        end
    end
end

function FateGameMode:OnPlayerConnects()
    --CustomGameEventManager:Send_ServerToAllClients( "bgm_b4_game", {bgm=0} )
    Timers:CreateTimer(2.0, function()
        for i = 0, 13 do 
            iupoasldm:initialize(i)
        end

        Timers:CreateTimer(2.0, function()
            local red = GameRules:GetCustomGameTeamMaxPlayers(2)
            local black = GameRules:GetCustomGameTeamMaxPlayers(3)

            if (string.match(GetMapName(), "fate_elim") and ServerTables:GetTableValue("Load", "player") == red + black) or IsInToolsMode() then 
                --if ServerTables:GetTableValue("IsNewbie", "new") == false then
                    print('No Newbie')
                    CustomGameEventManager:Send_ServerToAllClients( "availablemode", {dm = true} )
                    ServerTables:SetTableValue("GameModeChoice", "dm", true, true)
                    if ServerTables:GetTableValue("SameHero", "samehero") == true then
                        CustomGameEventManager:Send_ServerToAllClients( "availablemode", {sh = true} )
                    end
                --end
            end
        end)
    end)
end

function FateGameMode:PauseAllHero()
    local all_hero = FindUnitsInRadius(2, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for k,v in pairs(all_hero) do
        if v:IsRealHero() then 
            giveUnitDataDrivenModifier(v, v, "round_pause", 60)
        end
    end
end

-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function FateGameMode:PlayerConnect(keys)
    print('[BAREBONES] PlayerConnect')
    PrintTable(keys)

    if keys.bot == 1 then
        -- This user is a Bot, so add it to the bots table
        self.vBots[keys.userid] = 1
    end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
-- Assign players
function FateGameMode:OnConnectFull(keys)
    --print ('[BAREBONES] OnConnectFull')
    --Timers:CreateTimer(2, function()
    PrintTable(keys)
    --end)
    FateGameMode:CaptureGameMode()

    --local entIndex = keys.index+1
    -- The Player entity of the joining user
    
    local userID = keys.userid
    local entIndex = userID + 1
    local ply = PlayerResource:GetPlayer(userID) --local ply = EntIndexToHScript(userID)
    self.vUserIds = self.vUserIds or {}
    self.vUserIds[userID] = ply

    --ServerTables:SetTableValue("Players", "total_player", entIndex, true)

    CustomNetTables:SetTableValue("mode", "balance_mode", {mode = true}) 
    ServerTables:SetTableValue("GameModeChoice", "balance", "auto", true)

    if GetMapName() == "fate_elim_7v7" and (entIndex == 14 or IsInToolsMode()) then 
        --ServerTables:CreateTable("GameModeChoice", {dm = true})
        --
        --CustomNetTables:SetTableValue("mode", "availablemode", {availablemode = true}) 
    elseif GetMapName() == "fate_elim_6v6" and (entIndex == 12 or IsInToolsMode()) then 
        --ServerTables:CreateTable("GameModeChoice", {dm = true})
        --CustomNetTables:SetTableValue("mode", "availablemode", {availablemode = true}) 
    end
    --[[local playerID = ply:GetPlayerID()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
        playerID = keys.index
        print("teams not assigned yet, using index as player ID = " .. playerID)
    end
    self.vPlayerList = self.vPlayerList or {}
    self.vPlayerList[keys.userid] = playerID
    SendChatToPanorama("player " .. playerID .. " got assigned to " .. keys.userid .. "index in player list")
    --print(self.vPlayerList[keys.userid])]]
end

function FateGameMode:MakeDraw()
    print("draw")
    self:FinishRound(false,2)
end

function my_http_post()
    SendChatToPanorama("Work in Progress")
    local matchData = {}
    mmhiiouioa:initialize()
    LoopOverPlayers(function(player, playerID, playerHero)
        local hero = playerHero
        local playerData = {GetSystemDate(), GetSystemTime(), GetMapName(), math.ceil(GameRules:GetGameTime()), hero.ServStat.playerName, hero.ServStat.steamId, hero.ServStat.heroName, hero.ServStat.lvl,
        hero.ServStat.round, hero.ServStat.radiantWin, hero.ServStat.direWin, hero.ServStat.winGame, hero.ServStat.kill, hero.ServStat.death, 
        hero.ServStat.assist, hero.ServStat.tkill, hero.ServStat.itemValue + hero.ServStat.goldWasted, hero.ServStat.itemValue, hero.ServStat.goldWasted,
        hero.ServStat.damageDealt, hero.ServStat.damageDealtBR, hero.ServStat.damageTaken, hero.ServStat.damageTakenBR, hero.ServStat.qseal, hero.ServStat.wseal,
        hero.ServStat.eseal, hero.ServStat.rseal, hero.ServStat.cScroll, hero.ServStat.bScroll, hero.ServStat.aScroll, hero.ServStat.sScroll, hero.ServStat.exScroll,
        hero.ServStat.ward, hero.ServStat.familiar, hero.ServStat.link, hero.ServStat.str, hero.ServStat.agi, hero.ServStat.int, hero.ServStat.atk, hero.ServStat.armor, 
        hero.ServStat.hpregen, hero.ServStat.mpregen, hero.ServStat.ms, hero.ServStat.shard1, hero.ServStat.shard2, hero.ServStat.shard3, hero.ServStat.shard4}
        table.insert(matchData, playerData)
    end)
    --[[for k,v in pairs(matchData) do
        for a,b in pairs(v) do
            SendChatToPanorama(b)
        end
    end]]
    --json encode
    --http post
end
