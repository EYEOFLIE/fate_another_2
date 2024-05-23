---
--- Created by JoBoDo.
--- DateTime: 9/18/2017 2:14 PM
---

--[[
    Particle Dependencies


    Unit Dependencies
        dummy_unit_vulnerable_location_quest --todo: Create dummy_location that simply fires the event that quests listen to

    Modifier Dependencies
        quest_location_thinker <- from quests_modifiers.lua

    KV Dependencies
        Quests.qkv

    Panorama Dependencies
        .js
        .css
        .xml

    Core Libraries  --these libraries should be contained within every new project
        Event
        Debug
        Notifications -- todo: Is this system kind of basic? Perhaps an upgrade (or at least look into better use of it)
        PlayerTables
        ChatCommands --todo: Remove dependencies inside ChatCommands from non-core libraries
        Util    --todo: remove dependencies inside util from non-core libraries

    Hard Lua Dependencies:
        Quest
        quests_modifiers

    Event Listeners:
        'inventory_item_removed' = {
            playerID = item owner,
            itemName = item name,
            totalAmount = current amount of item in inventories
        }

        'inventory_item_added' = {
            playerID = item owner,
            itemName = item name,
            totalAmount = current amount of item in inventories
        }

        'inventory_item_update = {
            playerID = inventory owner,
            itemName = itemName
            totalAmount = current amount of item in inventories
        }

        'enemy_killed' = {
            playerID = player that recieves credit for the kill
            unit = handle of the killed unit
        }

        'event_complete' = {
            playerID = player that participated in the event,
            eventName = name of the completed event
        }


        'location_visited' = {
            playerID = visiting player,
            locationName = name of the location
        }

        'listen_string' = {
            playerID = listening player
            listenString = the string that the quest is waiting to recieve
        }

        'level_up' = {
            playerID = player who levelled up,
            newLevel = the level that the hero has reached, will be automatically obtained if not sent through
        }

        'tier_up' = {
            playerID = player who tiered up
        }

        'ability_used' = {
            playerID = player who used the ability
            abilityName = name of the ability used
            todo: may need to recieve the actual ability event, so we can do things like check for specific units killed etc
        }

        'request_completed_log' = {
            playerID = player whos completed quests to show
        }

        'hero_died' = {
            hero = hero who died,
            killer = handle who killed hero
        }

    Events Sent:
        'grant_reward' = {
            playerID = playerID,
            gold = how much gold the player should receive
            exp = how much experience the player should receive
            items = {itemname: {amount: number, chance?: number}} the items the player should receive             --Only one
            itemNames = the names of the items the player should receive
        }

        'inject_spawn' = {  --todo: Write Zoning capabilities to handle these spawns
            reference = key that the injected spawn will be added to
            playerID = playerID that requested the spawn to be added
            unitName = unit to be spawned
            entityName = location that the unit should be spawned at
        }

        'remove_injected_spawn' = { --todo: Write zoning capabilities to remove these spawns
            reference = key to remove the injected spawn from
            playerID = playerID that requested the spawn be added
            unitName = unit to be removed from spawning
            entityName = entity that should have been spawning the unit
        }

        'inject_loot' = {
            reference = key that the injected loot will be added to
            playerID = playerID that requested the loot to be added
            unitName = unit that the loot should be injected to
            lootTable = collection of [itemName = chance], should not be sent in alongside itemName and chance
            itemName = item that should be dropped
            chance = chance of item to drop
        }

        'remove_injected_loot' = {
            reference = key that will be dropped from injected loot
            playerID = playerID that the injected loot will be dropped from
            unitName = unit that the injected loot will be dropped from
            itemName = [OPTIONAL] - sending in a specific itemName will only drop that item from tables --todo: unimplemented
        }


        'inject_dialogue' = {
            reference = key that that injected dialogue will be added to,
            playerID = playerID that the injected dialogue will be added for,
            unitName = unit that the injection should be added to
            dialogue = dialogue that should be added
        }

        'remove_injected_dialogue' = {
            reference = key that will be used to find the injected dialogue
            playerID = player that the injected dialogue should be removed from
            unitName = unit that we will be looking at for the injected dialogue
        }

        'inject_unit_particle' = {
            reference = key that the injected particle will be added to
            playerID = player that the injected particle will be added for
            unitName = unit that the injected particle will be given to
            particleRef = reference that will be used for the particle (so we don't give double particles)
            particlePath = file path of the particle
        }

        'remove_unit_injected_particle' = {
            reference = key that will be used to find the particle
            playerID = player that the particle will be removed from
            unitName = unit that the injected particle will be searched for on
            particleRef = reference that will be used to find the specific particle
        }


        'inventory_request_item_update' = {
            playerID = the player ID whos inventory we need to update
            itemName = itemName we are requesting
        }


        'inventory_remove_items' = {
            playerID = playerID
            itemName = itemName,
            amount = amount,
        }
]]


LinkLuaModifier( "quest_location_thinker", "core/systems/quests/quests_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "quest_location_aura", "core/systems/quests/quests_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

QuestService = QuestService or class({},{
    player = {},
    availabilityStatus = {},

    playerHasBeenInit = {},
    bCanInitQuests = {},

    availabilityReference = {},
    quest_is_required_by = {},

    listeners = {},
    taskListeners = {},

    particleData = {
        quest_start_nonrepeatable = "particles/quest/exclamation_yellow.vpcf",
        quest_start_repeatable = "particles/quest/exclamation_blue.vpcf",
        quest_class_change = "particles/quest/exclamation_purple.vpcf",
        quest_return = "particles/quest/flag_yellow.vpcf",
        chat = "particles/quest/chat.vpcf"
    }
})

QuestService.compressor = require("core/systems/quests/compressor")
QuestService.obtainer = require("core/systems/quests/obtainer")

DEBUG_HIDE_SECTIONS["QuestService"] = true
DEBUG_HIDE_SECTIONS["Quest"] = true

function QuestService:Activate()
    Debug("QuestService", "Activate")

    local questData = LoadKeyValues("scripts/kv/quests.qkv")
    if questData then
        QuestService.data = questData.Quests or {}
    else
        QuestService.data = {}
    end

    QuestService.repeatableQuests = {}
    for questID, data in pairs(QuestService.data) do
        data.questID = questID
        if tobool(data.repeatable) then
            QuestService.repeatableQuests[tonumber(questID)] = true
        end
        if not QuestService:IsQuestIngame(questID) then
            QuestService.data[questID] = nil
        end
    end

    QuestService:InitAvailabilityReferences()

    Event:Listen("hero_init", Dynamic_Wrap(QuestService, "OnHeroInit"), QuestService)

    Event:Listen('inventory_item_update', Dynamic_Wrap(QuestService, "OnItemUpdate"), QuestService)

    Event:Listen("enemy_killed", Dynamic_Wrap(QuestService, "OnEnemyKilled"), QuestService)
    Event:Listen("location_visited", Dynamic_Wrap(QuestService, "OnLocationVisited"), QuestService)
    Event:Listen("listen_string", Dynamic_Wrap(QuestService, "OnListenStringReceived"), QuestService)
    Event:Listen("level_up", Dynamic_Wrap(QuestService, "OnLevelUp"), QuestService)
    Event:Listen("tier_up", Dynamic_Wrap(QuestService, "OnTierUp"), QuestService)
    Event:Listen("ability_used", Dynamic_Wrap(QuestService, "OnUseAbility"), QuestService)
    Event:Listen("gatekey_obtained", Dynamic_Wrap(QuestService, "OnObtainGateKey"), QuestService)
    Event:Listen("quest_completed", Dynamic_Wrap(QuestService, "OnCompleteQuest"), QuestService)
    Event:Listen("event_complete", Dynamic_Wrap(QuestService, "OnEventComplete"), QuestService)
    Event:Listen("event_complete", Dynamic_Wrap(QuestService, "OnEventFail"), QuestService)
    Event:Listen("hero_died", Dynamic_Wrap(QuestService, "OnHeroDied"), QuestService)

    ChatCommands:RegisterCommand("quests", Dynamic_Wrap(QuestService, "DebugQuests"))
    ChatCommands:RegisterCommand("complete", Dynamic_Wrap(QuestService, "ForceCompleteQuest"))

    Timers:CreateTimer(function()
        Event:Trigger("storage_register_compressor", {
            system_name = "Quests",
            compressor = QuestService.compressor
        })
        Event:Trigger("storage_register_obtainer", {
            system_name = "Quests",
            obtainer = QuestService.obtainer
        })
    end)
    CustomGameEventManager:RegisterListener("abandon_quest", Dynamic_Wrap(QuestService, "AttemptAbandonQuest"))
    CustomGameEventManager:RegisterListener("request_pt_subs", Dynamic_Wrap(QuestService, "SubscribePT"))
end

function QuestService:GetRawQuestData(questID)
    questID = tostring(questID)
    return QuestService.data[questID]
end

function QuestService:GetPlayerTableName(playerID, type)
    return "quests_" .. playerID .. '_' .. type
end

function QuestService:GetParticlePath(playerID, questID, particleRef)
    if particleRef == 'quest_start' then
        if(QuestService.repeatableQuests[questID] and QuestService.player[playerID] and QuestService.player[playerID].completed[questID]) then
            particleRef = 'quest_start_repeatable'
        else
            particleRef = 'quest_start_nonrepeatable'
        end
    end

    return QuestService.particleData[particleRef]
end

function QuestService:IsQuestRepeatable(questID)
    local stringRepeatable = QuestService.data[tostring(questID)].repeatable
    if tobool(stringRepeatable) then
        return true
    end
    return false
end

function QuestService:GetActiveQuest(playerID, questID)
    questID = tonumber(questID)
    if QuestService.player[playerID] then
        return QuestService.player[playerID].active[questID]
    end
    return false
end

function QuestService:AttemptAbandonQuest(args)
    local playerID = args.PlayerID or args.playerID
    local questID = args.questID

    if QuestService.player[playerID] then
        local quest = QuestService.player[playerID].active[questID]
        if quest then
            quest:AttemptAbandon()
        end
    end

end

function QuestService:HasQuest(playerID, questID, stageNum)
    questID = tonumber(questID)
    stageNum = tonumber(stageNum)
    if QuestService.player[playerID] then
        local activeQuest = QuestService.player[playerID].active[questID]
        if not activeQuest then return false end
        if not stageNum then return true end

        if tonumber(stageNum) == activeQuest:GetStageNum() then
            return true
        else
            return false
        end
    end

    --print("QuestService.player[playerID] was nil")
    return false
end

function QuestService:HasCompletedQuest(playerID, questID)
    questID = tonumber(questID)
    if QuestService.player[playerID] and QuestService.player[playerID].completed[questID] then
        return true
    end
    return false
end

function QuestService:GetPlayerAvailableQuests(playerID)
    if QuestService.player[playerID] then
        return QuestService.player[playerID].available
    end
    return false
end

function QuestService:IsQuestAvailable(playerID, questID)
    questID = tonumber(questID)

    if QuestService.player[playerID] then
        if QuestService.player[playerID].available[questID] then
            return true
        end
        return false
    end
end

function QuestService:IsQuestIngame(questID)
    questID = tonumber(questID)
    local data = QuestService.data[tostring(questID)]
    if not data then
        return false
    end
    if tobool(data.inactive) then
        return false
    end

    local mapname = GetMapName()
    if data.restrictMaps then
        if data.restrictMaps.disabled then
            for index, mapName in pairs(data.restrictMaps.disabled) do
                if mapName == mapname then
                    return false
                end
            end
        end

        if data.restrictMaps.enabled then
            local questEnabled = false
            for index, mapName in pairs(data.restrictMaps.enabled) do
                if mapName == mapname then
                    questEnabled = true
                end
            end

            if questEnabled == false then
                return false
            end
        end

    end
    return true
end

function QuestService:DebugQuests(playerID, param1, param2, param3)
    local param = param1

    if param == 'pt' then
        local tables ={
            'active',
            'available',
            'completed'
        }

        for index, tType in ipairs(tables) do
            local tableName = QuestService:GetPlayerTableName(playerID, tType)
            local tableValues = PlayerTables:GetAllTableValues(tableName)

            print("*****", tableName, "*****")
            PrintTable(tableValues)
            print("*************************")
        end
    end

    --todo: replace debug quests functionality
    if param == 'active' then
        for questID, quest in pairs(QuestService.player[playerID].active) do
            print(quest:ToString())
        end

        return true
    elseif param == 'available' then
        for questID, quest in pairs(QuestService.player[playerID].available) do
            print(quest:ToString())
        end

        return true
    elseif param == 'completed' then
        for questID, bComplete in pairs(QuestService.player[playerID].completed) do
            print(questID, " | Complete")
        end

        return true
    elseif param == 'set' then
        local questID = tonumber(param2)
        local bComplete = false
        if param3 and param3 == 'c' then
            bComplete = true
        end

        if QuestService:IsQuestAvailable(playerID, questID) then
            local quest = QuestService.player[playerID].available[questID]
            if bComplete then
                quest:Complete()
            else
                quest:GoNextStage()
            end
            return true
        end

        local quest = QuestService:GetActiveQuest(playerID, questID)
        if quest then
            if bComplete then
                quest:Complete()
            else
                quest:GoNextStage()
            end
            return true
        end

        QuestService.player[playerID].available[tonumber(questID)] = Quest(playerID, questID)
        QuestService:AttemptGiveQuest(playerID, questID, true)

    elseif tonumber(param) ~= nil then
        local questID = tonumber(param)
        if QuestService:HasQuest(playerID, questID) then
            local quest = QuestService.player[playerID].active[questID]
            quest:Spew()
            return true
        elseif QuestService:IsQuestAvailable(playerID, questID) then
            Debug("QuestService", "Quest is available")
            local quest = QuestService.player[playerID].available[questID]
            quest:Spew()
            return true
        end
        QuestService:AttemptGiveQuest(playerID, tonumber(param), true)
    end
end

function QuestService:ClearPlayerQuests(playerID)

    if not QuestService.player[playerID] then return false end

    local allQuests = {}

    for questID, quest in pairs(QuestService.player[playerID].available) do
        quest:Remove()
    end

    for questID, quest in pairs(QuestService.player[playerID].active) do
        quest:Remove()
    end

    QuestService.player[playerID].completed = {}



    return true
end

function QuestService:ClearAndInitPlayer(playerID, continuedQuestData)

    QuestService.bCanInitQuests[playerID] = false
    QuestService:ClearPlayerQuests(playerID)
    QuestService.bCanInitQuests[playerID] = true

    QuestService.player[playerID] = {
        available = {}, -- questObject
        active = {}, -- questObject
        completed = {}, -- boolean value

        questByTask = { --tables are index == questObject
            location = {},
            gather = {},
            kill = {},
            talkto = {},
        }
    }

    if(continuedQuestData) then
        if(continuedQuestData.active)then
            for questID, questInfo in pairs(continuedQuestData.active) do
                questID = tonumber(questID)
                if QuestService:IsQuestIngame(questID) then
                    local stageNum = questInfo.stageNo
                    local taskProgress = questInfo.tasks
    
                    local quest = Quest(playerID, questID, {stageNum = stageNum, loading = true})
                    if quest then
                        QuestService.player[playerID].active[questID] = quest
                        -- check incase the quest was updated after it was init
                        if taskProgress and (quest:GetStageNum() == tonumber(stageNum)) then
                            quest:LoadProgress(taskProgress)
                        end
                    end
                end
            end
        end
        if continuedQuestData.completed then
            for questID, bCompleted in pairs(continuedQuestData.completed) do
                questID = tonumber(questID)
                if QuestService:IsQuestIngame(questID) and bCompleted then
                    QuestService.player[playerID].completed[questID] = bCompleted
                    QuestService:QuestWasCompleted(playerID, questID)
                end
            end
        end
    end

    QuestService:InitAvailabilityStatus(playerID)

    QuestService:SubscribePT(playerID, true)
    QuestService.playerHasBeenInit[playerID] = true

    QuestService:UpdateAvailability(playerID)
end

function QuestService:SubscribePT(playerID, bClearTable)
    if type(playerID) == 'table' then
        playerID = playerID.PlayerID --check incase this request comes from Panorama
    end

    local tableNames = {
        active = QuestService:GetPlayerTableName(playerID, 'active'),
        available = QuestService:GetPlayerTableName(playerID, 'available'),
        completed = QuestService:GetPlayerTableName(playerID, 'completed'),
        repeatable = QuestService:GetPlayerTableName(playerID, 'repeatable'),
    }

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "quests_subscribe_pt", {
        tableNames.active,
        tableNames.available,
        tableNames.completed,
        tableNames.repeatable
    })

    for status, tableName in pairs(tableNames) do
        if bClearTable then
            PlayerTables:CreateOrSubscribe(tableName, {}, {playerID})
            local tableKeys = TableKeys(PlayerTables:GetAllTableValues(tableName))
            PlayerTables:DeleteTableKeys(tableName, tableKeys)
        else
            PlayerTables:SetPlayerSubscriptions(tableName, {playerID})
        end
    end


end

--[[
    Creates a table which has respective quests listed by their prerequisite information
]]
function QuestService:InitAvailabilityReferences()

    --tier
    --maxTier
    --level
    --maxLevel
    --class
    --questReq

    local refs = {
        level = {},
        maxLevel = {},
        tier = {},
        maxTier = {},
        class = {},
        quests = {},
    }

    --[[
        a table of prerequsite names and whether a quest should be made true or false when the requisite value is met

        doesn't handle class or quests cause they are a little bit different
    ]]
    local refNames = {
        level = true,
        maxLevel = false,
        tier = true,
        maxTier = false,
    }

    for questID, data in pairs(self.data) do
        local questID = tonumber(questID)
        if QuestService:IsQuestIngame(questID) then
            local prereqs = data.prerequisites
            if prereqs then
                for refName, bIsAvailable in pairs(refNames) do
                    if prereqs[refName] then
                        local ref = tonumber(prereqs[refName])
                        refs[refName][ref] = refs[refName][ref] or {}
                        refs[refName][ref][questID] = bIsAvailable
                    end
                end

                local quests = prereqs.quests
                if(quests) then
                    for questThatGetsCompleted, quest_state in pairs(quests) do
                        questThatGetsCompleted = tonumber(questThatGetsCompleted)
                        refs.quests[questThatGetsCompleted] = refs.quests[questThatGetsCompleted] or {}
                        refs.quests[questThatGetsCompleted][questID] = quest_state

                        QuestService.quest_is_required_by[questThatGetsCompleted] = QuestService.quest_is_required_by[questThatGetsCompleted] or {}
                        table.insert(QuestService.quest_is_required_by[questThatGetsCompleted], questID)
                    end
                end

                --todo: Will a quest ever not be available to a specific class etc, this probably needs to be looked at.
                local class = prereqs.class
                if(class) then
                    class = string.lower(class)
                    refs.class[class] = refs.class[class] or {}
                    refs.class[class][questID] = true
                end
            end
        else
            print("Quest : ", questID, " Is not in the game")
        end
    end

    QuestService.availabilityReference = refs
end

--[[
    Creates a table that keeps track of if a quest prerequisite is met or not
]]
function QuestService:InitAvailabilityStatus(playerID)
    QuestService.availabilityStatus[playerID] = {}

    for questID, questData in pairs(QuestService.data) do
        questID = tonumber(questID)

        local status = {}
        status.tier = true
        status.level = true
        status.class = true

        QuestService.availabilityStatus[playerID][questID] = status

        QuestService:UpdateAvailabilityForQuest(playerID, questID)
    end

    QuestService:UpdateAvailabilityForTier(playerID)
    QuestService:UpdateAvailabilityForLevel(playerID)
    QuestService:UpdateAvailabilityForClass(playerID)
end

function QuestService:UpdateAvailability(playerID)

    Debug("QuestService", "UpdateAvailability")

    QuestService:UpdateAvailabilityForTier(playerID)
    QuestService:UpdateAvailabilityForLevel(playerID)
    QuestService:UpdateAvailabilityForClass(playerID)
    QuestService:UpdateAvailabilityForQuest(playerID)

    QuestService:RefreshAvailableQuests(playerID)
end

function QuestService:IsQuestAvailabilityMet(playerID, questID)
    --Debug("QuestService","IsQuestAvailabilityMet", playerID, questID)
    if not QuestService.player[playerID] then return false end
    if not QuestService:IsQuestIngame(questID) then return false end


    --A completed and not repeatable quest should not have its availability met
    if QuestService:HasCompletedQuest(playerID, questID) and not QuestService:IsQuestRepeatable(questID) then
        return false
    end

    local requirementsMet = true
    local status = QuestService.availabilityStatus[playerID][questID]
    if not (status.level and status.tier and status.class) then
        requirementsMet = false
    elseif(status.quests) then
        for questID, bQuestReqMet in pairs(status.quests) do
            if bQuestReqMet == false then requirementsMet = false end
        end
    end

    --Debug("QuestService", questID, " - requirements met status = ", requirementsMet)
    return requirementsMet
end


--[[
    RefreshAvailableQuests will attempt to give a quest when necessary
]]
function QuestService:RefreshAvailableQuests(playerID, triggeringQuest)
    Debug("QuestService", "RefreshAvailableQuests", playerID, triggeringQuest)

    --Ensure the player has been set up for quests
    if not QuestService.player[playerID] then QuestService:ClearAndInitPlayer(playerID) end
    
    local check_quest_ids = {}
    --if we send through a triggering quest, but isn't required by anything, then we need don't need to update any available quests
    if triggeringQuest then 
        local required_by = QuestService.quest_is_required_by[tonumber(triggeringQuest)]
        for i=1, #(required_by or {}) do table.insert(check_quest_ids, required_by[i]) end
        table.insert(check_quest_ids, triggeringQuest)
    else 
        local availability = QuestService.availabilityStatus[playerID]
        for questID, _ in pairs(availability) do table.insert(check_quest_ids, questID) end 
    end



    for i=1, #check_quest_ids do
        local questID = check_quest_ids[i]
        if QuestService:IsQuestAvailabilityMet(playerID, questID) then
            
            --if the quest isn't available, and the player doesn't have the quest already, then attempt to give it to them             
            if not QuestService:IsQuestAvailable(playerID, questID) and not QuestService:HasQuest(playerID, questID) then
                QuestService:AttemptGiveQuest(playerID, questID)
            end

        else
            --remove quests that are no longer available and in the available stage (stage 0)
            local quest = QuestService.player[playerID].available[questID]
            if quest then quest:Remove() end
        end
    end
end

function QuestService:RefreshHeroSpecific(playerID)
    local available_quests = QuestService:GetPlayerAvailableQuests(playerID)
    local active_quests = QuestService:GetPlayerActiveQuests(playerID)
    
    --world particles are attached to a specific hero and need to be refreshed to attach to new hero and appear in world again
    for questID, quest in pairs(available_quests) do
        quest:RemoveInjectedWorldParticles()
        quest:InjectWorldParticles()
    end
    --world particles are attached to a specific hero and need to be refreshed to attach to new hero and appear in world again
    for questID, quest in pairs(active_quests) do
        quest:RemoveInjectedWorldParticles()
        quest:InjectWorldParticles()
    end
end

function QuestService:GetPlayerActiveQuests(playerID)
    if not QuestService.player[playerID] then return {} end
    return QuestService.player[playerID].active
end

function QuestService:GetAvailableQuest(playerID, questID)
    questID = tonumber(questID)
    playerID = tonumber(playerID)
    if QuestService.player[playerID] and QuestService.player[playerID].available then
        return QuestService.player[playerID].available[questID]
    end
    return nil
end

function QuestService:AttemptGiveQuest(playerID, questID, bIgnoreCompletion, stageNum)
    Debug("QuestService", "AttemptGiveQuest: ", questID)
    --Debug("QuestService", "AttemptGiveQuest", questID, bForce, stageNum)

    if(QuestService.bCanInitQuests[playerID] == false) then
        Debug("QuestService", "Player " , playerID, "can not init quests")
        return false
    end
    if not QuestService.player[playerID] then QuestService:ClearAndInitPlayer(playerID) end

    questID = tonumber(questID)

    local quest_is_available = (QuestService.player[playerID].available[questID] ~= nil)
    local quest_is_active = (QuestService.player[playerID].active[questID] ~= nil)
    local quest_is_complete = (QuestService.player[playerID].completed[questID] ~= nil)

    local quest = (QuestService.player[playerID].available[questID] or QuestService.player[playerID].active[questID])
    if (quest_is_available or quest_is_active) and stageNum then
        quest:GoNextStage(stageNum)
        if quest_is_available then return true end
        if quest_is_active then return false end
    end

    --skip non-repeatable quests which are complete, unless they are skipped
    if quest_is_complete and not QuestService:IsQuestRepeatable(questID) and not bIgnoreCompletion then
        return false
    end

    --if we didn't have a quest yet, then we need to create one
    if not quest then
        --create the quest, it handles its own assignment depending on stage etc.
        Quest(playerID, questID, {stageNum = stageNum})
    end
end


--setting a value to false means the quest is unavailable due to a given prereq
function QuestService:UpdateAvailabilityForTier(playerID)
    local hero = Core:GetHero(playerID)
    local tier = tonumber(GetHandleKeyValue(hero, "ClassTier")) or 0

    for reqTier, refTable in pairs(QuestService.availabilityReference.tier) do
        reqTier = tonumber(reqTier)

        --todo: why is bool required here if we set true/false here anyway
        for questID, bool in pairs(refTable) do
            if tier >= reqTier then
                QuestService.availabilityStatus[playerID][questID].tier = true
            else
                QuestService.availabilityStatus[playerID][questID].tier = false
            end
        end
    end

    for maxTier, refTable in pairs(QuestService.availabilityReference.maxTier) do
        maxTier = tonumber(maxTier)

        --todo: why is bool required here if we set true/false here anyway
        for questID, bool in pairs(refTable) do
            if tier >= maxTier then
                QuestService.availabilityStatus[playerID][questID].tier = false
            else
                QuestService.availabilityStatus[playerID][questID].tier = true
            end
        end
    end
end

--setting a value to false means the quest is unavailable due to a given prereq
function QuestService:UpdateAvailabilityForLevel(playerID, level)
    if playerID < 0 then return end
    local hero = Core:GetHero(playerID)
    if not hero and not level then return false end
    local level = level or hero:GetLevel()

    for reqLevel, refTable in pairs(QuestService.availabilityReference.level) do
        reqLevel = tonumber(reqLevel)

        for questID, bool in pairs(refTable) do
            if level >= reqLevel then
                QuestService.availabilityStatus[playerID][questID].level = true
            else
                QuestService.availabilityStatus[playerID][questID].level = false
            end
        end
    end


    for maxLevel, refTable in pairs(QuestService.availabilityReference.maxLevel) do
        maxLevel = tonumber(maxLevel)

        for questID, bool in pairs(refTable) do
            if level >= maxLevel then
                QuestService.availabilityStatus[playerID][questID].level = false
            else
                QuestService.availabilityStatus[playerID][questID].level = true
            end
        end
    end


end

function QuestService:UpdateAvailabilityForClass(playerID)
    local hero = Core:GetHero(playerID)
    local player_class = string.lower(Core:GetCustomHeroName(hero:GetName(), true))
    Debug("QuestService", "UpdateAvailabilityForClass", hero:GetName())

    for quest_class_ref, questInfo in pairs(QuestService.availabilityReference.class) do
        for questID, QUEST_REQUIRES_CLASS in pairs(questInfo) do
            --requiresClass is true if the class is required, requiresClass is false if the class is required to NOT be said class
            QuestService.availabilityStatus[playerID][questID] = QuestService.availabilityStatus[playerID][questID] or {}
            
            local CLASS_MATCH = (player_class == quest_class_ref)
            local quest_available

            if     CLASS_MATCH and      QUEST_REQUIRES_CLASS == true then     quest_available = true
            elseif CLASS_MATCH and      QUEST_REQUIRES_CLASS == false then    quest_available = false
            elseif not CLASS_MATCH and  QUEST_REQUIRES_CLASS == true then     quest_available = false
            elseif not CLASS_MATCH and  QUEST_REQUIRES_CLASS == false then    quest_available = true 
            end

            QuestService.availabilityStatus[playerID][questID].class = quest_available
        end
    end
end

function QuestService:WipeQuest(playerID, questID)
    local questID = tonumber(questID)
    local active_quest = QuestService:GetActiveQuest(playerID, questID)
    active_quest:AttemptAbandon(true)
    QuestService.player[playerID].completed[questID] = nil
    QuestService:UpdateAvailability(playerID)
end

function QuestService:UpdateAvailabilityForQuest(playerID, questID)
    --Debug('QuestService', 'UpdateAvailabilityForQuest(', playerID, questID,')')

    --If no questID is sent then recall this function for every game-enabled quest
    if not questID then
        for questID, questData in pairs(QuestService.data) do
            if tobool(questData.inactive) == false then
                QuestService:UpdateAvailabilityForQuest(playerID, tonumber(questID))
            end
        end
    end

    local data = QuestService.data[tostring(questID)]
    local refs = QuestService.availabilityReference
    
    local trigger_quest_is_complete = (QuestService.player[playerID].completed[questID] ~= nil)
    local trigger_quest_is_not_complete = (trigger_quest_is_complete == false)
    local trigger_quest_is_available = false
    local trigger_quest_is_in_progress = false
    local trigger_quest_is_not_yet_available = false

    local quest = QuestService.player[playerID].active[questID]
    if quest then
        local status = quest:GetQuestStatus()
        if status == 'available' then trigger_quest_is_available = true 
        elseif status == 'active' then trigger_quest_is_in_progress = true end
    end

    local trigger_quest_is_not_yet_available = (trigger_quest_is_not_complete and (not trigger_quest_is_available) and (not trigger_quest_is_in_progress) )    

    if refs.quests and refs.quests[questID] then
        for questToUpdateID, quest_to_update_wants_state in pairs(refs.quests[questID]) do
            
            QuestService.availabilityStatus[playerID][questToUpdateID] = QuestService.availabilityStatus[playerID][questToUpdateID] or {
                tier = true,
                level = true,
                class = true,
            }
            QuestService.availabilityStatus[playerID][questToUpdateID].quests = QuestService.availabilityStatus[playerID][questToUpdateID].quests or {}

            --[[
                quest_to_update_wants_state = {
                    'complete', --quest is complete
                    'incomplete' --quest is incomplete
                    'in_progress',  --quest is active and past stage 0,
                        TODO: 'not_active',    --quest is not at stage 1 or further (priest class quest selection)
                    'available' --quest is active and at stage 0
                    'not_yet_available' --quest is unavailable and incomplete
                }
            ]]
            local quest_available = false

            

            if quest_to_update_wants_state == 'complete' and trigger_quest_is_complete then quest_available = true 
            elseif quest_to_update_wants_state == 'incomplete' and trigger_quest_is_not_complete then quest_available = true 
            elseif quest_to_update_wants_state == 'available' and trigger_quest_is_available then quest_available = true 
            elseif quest_to_update_wants_state == 'in_progress' and trigger_quest_is_in_progress then quest_available = true 
            elseif quest_to_update_wants_state == 'not_yet_available' and trigger_quest_is_not_yet_available then quest_available = true end

            QuestService.availabilityStatus[playerID][questToUpdateID].quests[questID] = quest_available
        end
    end
end

function QuestService:OnHeroInit(event)
    local args = event.params
    local playerID = args.playerID
    QuestService:ClearAndInitPlayer(playerID)
end

function QuestService:GiveQuest(playerID, questID, bForce)
    if not QuestService.player[playerID] then
        QuestService:ClearAndInitPlayer(playerID)
    end
end

--bGiveQuest is true if we want to give the player the quest to complete(in the event they don't yet have it)
function QuestService:ForceCompleteQuest(playerID, questID, bGiveQuest)
    questID = tonumber(questID)

    if not QuestService.player[playerID] then
        Debug("QuestService", "Could not force complete quest for player", playerID, "because they had not been init")
        return false
    end

    local quest = QuestService.player[playerID].active[questID]
    if not quest then
        if bGiveQuest then
            quest = Quest(playerID, questID)
        else
            return false
        end
    end
    quest:Complete()
end

function QuestService:LoadQuests(playerID, loadData)
    Debug("QuestService", "LoadQuests")
    --PrintTable(loadData)
    --print("*-*-*-*-*-*")

    local existingData = {
        active = {},
        completed = {},
    }


    if loadData and loadData.completed then
        for index, questID in ipairs(loadData.completed) do
            local questID_num = tonumber(questID)
            if questID_num then
                existingData.completed[questID_num] = true
            else
                BugReport:AutomatedReport("quest_service.lua - line 1031 - questID was nil after turning into a number... Index: '" .. index .. " questID: ".. questID)
            end
        end
    end
    --PrintTable(existingData.completed)

    if loadData and loadData.active then
        for index, questInfo in pairs(loadData.active) do
            local questID = tonumber(questInfo.questID)
            existingData.active[questID] = questInfo
        end
    end

    QuestService:ClearAndInitPlayer(playerID, existingData)
    QuestService:UpdateAvailability(playerID)
end

function QuestService:AddListener(playerID, questID, listenType, questObj)
    QuestService.listeners[listenType] = QuestService.listeners[listenType] or {}
    QuestService.listeners[listenType][playerID] = QuestService.listeners[listenType][playerID] or {}
    QuestService.listeners[listenType][playerID][questID] = questObj
end

function QuestService:RemoveListener(playerID, questID, listenType)
    QuestService.listeners[listenType][playerID][questID] = nil

    if tablelength(QuestService.listeners[listenType][playerID]) < 1 then
        QuestService.listeners[listenType][playerID] = nil
    end

    if tablelength(QuestService.listeners[listenType]) < 1 then
        QuestService.listeners[listenType] = nil
    end
end

function QuestService:AddTaskListener(playerID, questID, listenType, questObj)
    QuestService.taskListeners[listenType] = QuestService.taskListeners[listenType] or {}
    QuestService.taskListeners[listenType][playerID] = QuestService.taskListeners[listenType][playerID] or {}
    QuestService.taskListeners[listenType][playerID][questID] = questObj
end

function QuestService:RemoveTaskListener(playerID, questID, listenType)
    QuestService.taskListeners[listenType][playerID][questID] = nil

    if tablelength(QuestService.taskListeners[listenType][playerID]) < 1 then
        QuestService.taskListeners[listenType][playerID] = nil
    end

    if tablelength(QuestService.taskListeners[listenType]) < 1 then
        QuestService.taskListeners[listenType] = nil
    end
end

function QuestService:UpdateActiveUI(quest)

    local playerID = quest.playerID
    local tableName = QuestService:GetPlayerTableName(playerID, 'active')
    local tableKey = quest.questID

    if quest:GetQuestStatus() ~= 'active' then
        PlayerTables:DeleteTableKey(tableName, tableKey)
        return false
    end

    PlayerTables:SetTableValue(tableName, tableKey, quest:GetUIInformation('active'))
    return true
end

function QuestService:UpdateAvailableUI(quest)
    Debug("QuestService", "UpdatingAvailableUI for ", quest.data.name, " at status: ", quest:GetQuestStatus())

    local playerID = quest.playerID
    local tableKey = quest.questID
    local tableVersion = 'available'
    local availableTableName = QuestService:GetPlayerTableName(playerID, 'available')
    local repeatableTableName = QuestService:GetPlayerTableName(playerID, 'repeatable')

    local selectedTableName

    if quest:GetQuestStatus() ~= 'available' then
        PlayerTables:DeleteTableKey(availableTableName, tableKey)
        PlayerTables:DeleteTableKey(repeatableTableName, tableKey)
        return false
    end

    --determine whether the quest is newly available or repeatable
    if QuestService.player[playerID] and QuestService.player[playerID].completed[quest.questID] then
        Debug("QuestService", "Deleting table key in 'available' for ", quest.data.name)
        PlayerTables:DeleteTableKey(availableTableName, tableKey)
        PlayerTables:SetTableValue(repeatableTableName, tableKey, quest:GetUIInformation('completed'))
    else
        Debug("QuestService", "Deleting table key in 'repeatable' for ", quest.data.name)
        PlayerTables:DeleteTableKey(repeatableTableName, tableKey)
        PlayerTables:SetTableValue(availableTableName, tableKey, quest:GetUIInformation('available'))
    end

    return true
end

function QuestService:ShowUI(playerID)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "quest_show", {player = PlayerResource:GetPlayer(playerID)})
end

function QuestService:HideUI(playerID)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "quest_hide", {player = PlayerResource:GetPlayer(playerID)})

end

function QuestService:RemoveQuest(quest)
    Debug("QuestService", "RemoveQuest", quest.questID)
    local playerID = quest.playerID
    local questID = quest.questID

    local tableName = QuestService:GetPlayerTableName(playerID, 'active')

    if QuestService.player[playerID] then
        QuestService.player[playerID].active[questID] = nil
        QuestService.player[playerID].available[questID] = nil
    end

    Debug("QuestService", "Deleting key ", questID, 'from tableName', tableName)
    PlayerTables:DeleteTableKey(tableName, questID)

    Event:Trigger("update_save_data", {
        playerID = playerID,
        system = "Quests",
        keys = {"active", ("q" .. questID)},
        value = nil
    })

    QuestService:UpdateAvailabilityForQuest(playerID, questID)
    QuestService:RefreshAvailableQuests(playerID, questID)

end

function QuestService:QuestWasCompleted(playerID, questID)
    Debug("QuestService", "QuestWasCompleted - ", self.data[tostring(questID)].name)
    local availQuestTable = QuestService:GetPlayerTableName(playerID, 'available')
    PlayerTables:DeleteTableKey(availQuestTable, questID)

    Event:Trigger("update_save_data",{
        playerID = playerID,
        system = "Quests",
        keys = {"completed", ("q" .. questID)},
        value = true
    })
    Event:Trigger('quest_completed',{
		playerID = playerID,
		questID = questID
	})

    local rawData = QuestService.data[tostring(questID)]
    if not rawData then
        Debug("QuestService", "Couldn't find quest data for completed quest: ", questID)
        return false
    end

    local questData = {
        details = {
            questID = questID,
            name = rawData.name,
            description = rawData.description,
            portrait = rawData.portrait,
            typeIcon = rawData.typeIcon
        }
    }

    local bNoMoreStages = false
    local index = 0
    while bNoMoreStages == false do
        index = index + 1
        if not rawData.stages[tostring(index)] then
            bNoMoreStages = true
        end
    end
    local lastStage = index - 1

    local stageDescriptions = {}
    for i = 1, lastStage do
        local stageInfo = rawData.stages[tostring(i)]
        if stageInfo.description then
            table.insert(stageDescriptions, stageInfo.description)
        end
    end

    if tablelength(stageDescriptions) > 0 then
        questData.stageDescriptions = stageDescriptions
    end

    local tableName = QuestService:GetPlayerTableName(playerID, 'completed')
    PlayerTables:SetTableValue(tableName, questID, questData)

end


--[[

    EVENT LISTENERS

]]

function QuestService:OnItemUpdate(event)
    local args = event.params

    --if the item hasn't changed owner hasn't changed then there's no need to update gather quests
    if args.sameOwner then return end

    if QuestService.taskListeners.gather and QuestService.taskListeners.gather[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.gather[args.playerID]) do
            questObj:UpdateGatherTask(args.itemName, args.totalAmount)
        end
    end
end

function QuestService:OnInventoryFullUpdate(event)
    local args = event.params
    local playerID = args.playerID
    local items = args.items --list of itemName == count

    if not QuestService.player[playerID] then
        Debug("QuestService", "Requested full inventory update for playerID ", playerID, " but player has not been init")
        return false
    end

    for questID, quest in pairs(QuestService.player[playerID].active) do
        if quest.tasks.gather then
            for itemName, amount in pairs(items) do
                if quest.tasks.gather[itemName] then
                    quest:UpdateGatherTask(itemName, amount)
                end
            end
        end
    end
end

--todo: ensure that this event is triggered for every player involved in the kill
function QuestService:OnEnemyKilled(event)
    local args = event.params
    local enemyName = args.unit:GetUnitName()

    if(QuestService.taskListeners.kill and QuestService.taskListeners.kill[args.playerID]) then
        for questID, questObj in pairs(QuestService.taskListeners.kill[args.playerID]) do
            questObj:UpdateKillTask(enemyName)
        end
    end

    local enemyTypes = GetHandleKeyValue(enemyName, 'UnitTypes')
    if enemyTypes then
        enemyTypes = split(enemyTypes, ' ')
        
        if(QuestService.taskListeners.killType and QuestService.taskListeners.killType[args.playerID]) then
            for questID, questObj in pairs(QuestService.taskListeners.killType[args.playerID]) do
                for i=1, #enemyTypes do
                    questObj:UpdateKillTypeTask(enemyTypes[i])
                end
            end
        end
    end
end

function QuestService:OnLocationVisited(event)
    local args = event.params

    if QuestService.taskListeners.location and QuestService.taskListeners.location[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.location[args.playerID]) do
            questObj:UpdateLocationTask(args.locationName)
        end
    end

end

function QuestService:OnListenStringReceived(event)
    Debug("QuestService", "OnListenStringReceived")
    local args = event.params
    if QuestService.taskListeners.talkto and QuestService.taskListeners.talkto[args.playerID] then
        Debug("QuestService", "taskListeners.talkto and taskListeners.talkto[", args.playerID, "]")
        for questID, questObj in pairs(QuestService.taskListeners.talkto[args.playerID]) do
            if args.listeningQuest then
                if tonumber(args.listeningQuest) == questID then
                    questObj:UpdateTalktoTask(args.listenString)
                end
            else
                questObj:UpdateTalktoTask(args.listenString)
            end
        end
    end
end

function QuestService:OnEventComplete(event)
    local args = event.params
    if QuestService.taskListeners.event and QuestService.taskListeners.event[args.playerID] then
        Debug("QuestService", "Updating event ", args.eventName, " for player ", args.playerID)
        for questID, questObj in pairs(QuestService.taskListeners.event[args.playerID]) do
            Debug("QuestService", "Updating event ", args.eventName, " for quest", questID)
            questObj:UpdateEventTask(args.eventName)
        end
    end
end

function QuestService:OnEventFail(event)
    local args = event.params
    if QuestService.taskListeners.event and QuestService.taskListeners.event[args.playerID] then

        for questID, questObj in pairs(QuestService.taskListeners.event[args.playerID]) do
            questObj:EventTaskFailed(args.eventName)
        end
    end
end

function QuestService:OnHeroDied(event)
    local args = event.params
    local playerID = args.hero:GetPlayerOwnerID()
    if QuestService.listeners.hero_died and QuestService.listeners.hero_died[playerID] then
        for questID, questObj in pairs(QuestService.listeners.hero_died[playerID]) do
            questObj:OnHeroDied(args.hero, args.killer)
        end
    end
end

function QuestService:OnLevelUp(event)
    local args = event.params
    local playerID = args.playerID
    local newLevel = args.newLevel -- may be nil

    QuestService:UpdateAvailabilityForLevel(playerID, newLevel)
    QuestService:RefreshAvailableQuests(playerID)
    if QuestService.taskListeners.reachLevel and QuestService.taskListeners.reachLevel[playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.reachLevel[playerID]) do
            questObj:UpdateReachLevelTask(newLevel)
        end
    end
end

function QuestService:OnTierUp(event)
    local args = event.params
    QuestService:UpdateAvailabilityForTier(args.playerID)
    QuestService:RefreshAvailableQuests(args.playerID)
    if QuestService.taskListeners.reachTier and QuestService.taskListeners.reachTier[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.reachTier[args.playerID]) do
            questObj:UpdateReachTierTask()
        end
    end
end

function QuestService:OnUseAbility(event)
    local args = event.params
    local amount = args.amount or 1
    if QuestService.taskListeners.useAbility and QuestService.taskListeners.useAbility[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.useAbility[args.playerID]) do
            questObj:UpdateUseAbilityTask(args.abilityName, amount)
        end
    end
end

function QuestService:OnObtainGateKey(event)
    local args = event.params
    if QuestService.taskListeners.obtainGateKey and QuestService.taskListeners.obtainGateKey[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.obtainGateKey[args.playerID]) do
            questObj:UpdateObtainGateKeyTask(args.gateKey)
        end
    end
end

function QuestService:OnCompleteQuest(event)
    local args = event.params
    if QuestService.taskListeners.completeQuest and QuestService.taskListeners.completeQuest[args.playerID] then
        for questID, questObj in pairs(QuestService.taskListeners.completeQuest[args.playerID]) do
            questObj:UpdateCompleteQuestTask(args.questID)
        end
    end
end

Event:BindActivate(QuestService)