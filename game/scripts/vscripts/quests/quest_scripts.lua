---
--- Created by JoBoDo.
--- DateTime: 9/30/2017 10:33 PM
---

QuestScripts = QuestScripts or class({})

function QuestScripts:GiveGateKey(playerID, args)
    local hero = Core:GetHero(playerID)
    if args.gate_key and tostring(args.gate_key) then
        hero:AddGateKey(args.gate_key)
    end
end
function QuestScripts:AbandonQuest(playerID, args)
    local hero = Core:GetHero(playerID)
    local questID = args.questID
    if not questID then print("Could not abandon a quest without the 'questID' field") return end
    local quest = QuestService:GetActiveQuest(playerID, questID)
    if not quest then return end
    quest:AttemptAbandon(true)
end

function QuestScripts:WipeQuest(playerID, args)
    local questID = args.questID
    if not questID then print("Could not wipe a quest without the 'questID' field") return end
    local wipe_quests = split(questID, ' ')
    for i=1, #wipe_quests do
        local questID = tonumber(wipe_quests[i])
        QuestService:WipeQuest(playerID, questID)
    end
end

function QuestScripts:GoPriorStage(playerID, args)
    local questID = args.questID
    local quest = QuestService:GetActiveQuest(playerID, questID)
    if not quest then print("Player did not have quest", questID, " active"); return end
    quest:SetStage(quest:GetStageNum() - 1)
end
function QuestScripts:GoStage(playerID, args)
    local questID = args.questID
    if not args.stage then print("No stage defined for Runscript GoToStage", questID); return end
    local stage = tonumber(args.stage)
    local quest = QuestService:GetActiveQuest(playerID, questID)
    if not quest then print("Player did not have quest", questID, " active"); return end
    quest:SetStage(stage)
end

function QuestScripts:CheckQuestItemReset(playerID, args)
    local hero = Core:GetHero(playerID)
    local questID = args.questID
    local items = args.items
    if not questID or not items then
        print("CheckQuestItemReset | incomplete script call")
        return
    end
    local quest = QuestService:GetActiveQuest(playerID, questID)
    if not quest then 
        print("CheckQuestItemReset", questID, " not active")
        return 
    end

    local successResult = args.successResult
    local failResult = args.failResult

    print("Checking questID ", questID)

    local success = true
    for itemname, check_amount in pairs(items) do
        local check_amount = tonumber(check_amount)
        local has_amount = InventoryService:CountItemsOfPlayer(playerID, itemname, true, true, true)
        print("Has:", has_amount, " Checking for: ", check_amount)
        if has_amount < check_amount then
            success = false
        end
    end

    print("Checking questID ", questID, success)
    
    --run successResult
    if success and successResult then
        print("Running Success")
        if successResult.go_next_stage then
            quest:GoNextStage()
        end
    end

    if not success and failResult then
        print("Running fail")
        --run fail result
        if failResult.go_prior_stage then
            local new_stage = quest:GetStageNum() - 1
            print("Set quest: ", quest.data.name, questID,  " to stage ", new_stage)
            quest:SetStage(new_stage)
        end
    end
end


function QuestScripts:quest_1085_children_found(event)

    local unit = event.activator


    if not unit:IsRealHero() or not unit:IsControllableByAnyPlayer() then
        return false
    end

    local playerID = unit:GetPlayerOwnerID()


    if not QuestService:HasQuest(playerID, 1085, 6) then
        Debug("quest_triggers.lua", "Player: ", playerID, " did not have quest 1085 at stage 6")
        return false
    end

    print("Checking unit : ", unit:GetUnitName())
    --print("'modifier_disguise_troll' : ", unit:HasModifier('modifier_disguise_troll'))

    if not unit:HasModifier('modifier_disguise_troll') then
        Notifications:Top(playerID, {text="Must be wearing disguise to free children!", style={color="red", ["font-size"]="28px"}, duration = 4})
        return false
    end

    CutsceneService:Run(playerID, "Free_Centaur_Children")
end

function QuestScripts:quest_1133_leave_desert(playerID, args)
    local instance = InstanceManager:GetInstance('desert_scenario_lost_ruins')
    if instance and instance:HasPlayer(playerID) then 
        instance:RemovePlayer(playerID)
    end

    Event:Trigger('location_visited',{
        playerID = playerID,
        locationName = 'crossroads_caravan_spawner'
    })
    
    MovePlayerUnitsToPoint(
        Core:GetHero(playerID),
        Entities:FindByName(nil, 'desert_south_exit_target'):GetAbsOrigin()
    )
end

function QuestScripts:quest_1133_go_to_desert(playerID, args)
    if InstanceManager:StartInstance(playerID, 'desert_scenario_lost_ruins') then
        MovePlayerUnitsToPoint(
            Core:GetHero(playerID),
            Vector(-10949.8, -7634.36, -255.687)
        )
        
        Event:Trigger('location_visited',{
			playerID = playerID,
			locationName = 'desert_ruins_entrance'
		})
    else
        Notifications:Top(playerID, {
			text="WARNING_DESERT_IN_USE", style={color="red", ["font-size"]="25px"}, duration = 3
        })    
    end
end

function QuestScripts:quest_1127_StartCaravan(playerID, args)

    --stopped caravan starting if instance is null
    local instance = InstanceManager:StartInstance(playerID, 'desert_scenario_1')
    if instance == false then return end

    MovePlayerUnitsToPoint(
        Core:GetHero(playerID), 
        Entities:FindByName(nil, 'desert_entrance_scenario_01a'):GetAbsOrigin())

    Timers:CreateTimer(function() 
        local origin = Entities:FindByName(nil, 'desert_pathway_1'):GetAbsOrigin()
        --configure settings
        local the_formation = Formation({
            waypoint_origin = 1,
            waypoints = {
                'desert_pathway_1',
                'desert_pathway_2',
                'desert_pathway_3',
                'desert_pathway_4',
                'desert_pathway_5',
                'desert_pathway_6',
                'desert_pathway_7'
            }
        })
    
        --configure units
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_master_generic', Vector(0, 0, 0), {
            parent=true,
            group='civ',
            scale = 150,
            hasNoAttack = true
        })
        the_formation:CreateUnit('npc_dota_creature_npc_caravan', Vector(-2.5, 0, 0), {
            group='civ',
            hasNoAttack = true
        })
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(1.75, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(1.75, -2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-1.5, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-1.5, -2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-4.75, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-4.75, -2.5, 0), {group='guard'})

        the_formation:SetAIStateShare('civ', AI_STATE_AGGRESSIVE, {
            civ = AI_STATE_IDLE,
            guard = AI_STATE_AGGRESSIVE
        })
        the_formation:SetAIStateShare('guard', AI_STATE_AGGRESSIVE, {
            civ = AI_STATE_IDLE,
            guard = AI_STATE_AGGRESSIVE
        })
    
        --finalize creation
        the_formation:RotateToDirection_Immediate(the_formation:GetDirectionTo(the_formation:GetNextWaypoint()))
        the_formation:GoNextWaypoint()
        local origin = Entities:FindByName(nil, 'desert_pathway_1'):GetAbsOrigin()
        local direction = ((Entities:FindByName(nil, 'desert_pathway_2'):GetAbsOrigin()) - origin):Normalized()
        the_formation:RotateToDirection_Immediate(direction)
    
        the_formation.next_command = 'rotate_to_face_next_waypoint'
    
        the_formation:RegisterListener(FORMATION_EVENT_MOVEMENT_COMPLETE, function(the_formation) 
            the_formation:RemoveSelf()
            Event:Trigger('event_complete', {
                playerID = playerID,
                eventName = 'desert_travel_n_to_s'
            })
        end)

        instance:AddEndCallback(function() 
            print("removeselfkgo")
            if the_formation then
                the_formation:RemoveSelf()
            end
        end)
    end)
    
end

function QuestScripts:quest_1167_StartCaravan(playerID, args)

    --stopped caravan starting if instance could not be started
    local instance = InstanceManager:StartInstance(playerID, 'desert_scenario_1')
    if instance == false then return end
    MovePlayerUnitsToPoint(
        Core:GetHero(playerID), 
        Entities:FindByName(nil, 'desert_entrance_scenario_01b'):GetAbsOrigin())

    Timers:CreateTimer(function() 
        local origin = Entities:FindByName(nil, 'desert_pathway_7'):GetAbsOrigin()
        --configure settings
        local the_formation = Formation({
            waypoint_origin = 7,
            waypoints = {
                'desert_pathway_1',
                'desert_pathway_2',
                'desert_pathway_3',
                'desert_pathway_4',
                'desert_pathway_5',
                'desert_pathway_6',
                'desert_pathway_7',
            },
            waypoint_direction = -1,
        })
    
        --configure units
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_master_generic', Vector(0, 0, 0), {
            parent=true,
            group='civ',
            scale = 150,
            hasNoAttack = true
        })
        the_formation:CreateUnit('npc_dota_creature_npc_caravan', Vector(-2.5, 0, 0), {
            group='civ',
            hasNoAttack = true
        })
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(1.75, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(1.75, -2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-1.5, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-1.5, -2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-4.75, 2.5, 0), {group='guard'})
        the_formation:CreateUnit('npc_dota_creature_npc_caravan_guard', Vector(-4.75, -2.5, 0), {group='guard'})

        the_formation:SetAIStateShare('civ', AI_STATE_AGGRESSIVE, {
            civ = AI_STATE_IDLE,
            guard = AI_STATE_AGGRESSIVE
        })
        the_formation:SetAIStateShare('guard', AI_STATE_AGGRESSIVE, {
            civ = AI_STATE_IDLE,
            guard = AI_STATE_AGGRESSIVE
        })
    
        --finalize creation
        the_formation:RotateToDirection_Immediate(the_formation:GetDirectionTo(the_formation:GetNextWaypoint()))
        the_formation:GoNextWaypoint()
        local origin = Entities:FindByName(nil, 'desert_pathway_7'):GetAbsOrigin()
        local direction = ((Entities:FindByName(nil, 'desert_pathway_6'):GetAbsOrigin()) - origin):Normalized()
        the_formation:RotateToDirection_Immediate(direction)
    
        the_formation.next_command = 'rotate_to_face_next_waypoint'
    
        the_formation:RegisterListener(FORMATION_EVENT_MOVEMENT_COMPLETE, function(the_formation) 
            the_formation:RemoveSelf()
            Event:Trigger('event_complete', {
                playerID = playerID,
                eventName = 'desert_travel_s_to_n'
            })
        end)


        instance:AddEndCallback(function() 
            print("removeselfkgo")
            if the_formation then
                the_formation:RemoveSelf()
            end
        end)

    end)
    
end


function QuestScripts:quest_1145_SeedCarrier(playerID, args)
    EVENTS_TABLE.ACTIVE_EVENTS = EVENTS_TABLE.ACTIVE_EVENTS or {}
    EVENTS_TABLE.ACTIVE_EVENTS['seed_carrier'] = true

    local spawner = Entities:FindByName(nil, 'worldwoods_seed_carrier_1')
    local unit = CreateUnitByName(
        'npc_dota_creature_seed_carrier', 
        spawner:GetAbsOrigin(), 
        true,
        nil, nil, DOTA_TEAM_GOODGUYS)

    CoreAI:MakeInstance( unit, spawner )

    --todo, this event will listen forever
    Event:Listen("ai_end_patrol", function(self, args)
        if args.unit ~= unit then return end
        Event:Trigger('event_complete', {
            playerID = playerID,
            eventName = 'seed_carrier'
        })
        unit:RemoveSelf()
        EVENTS_TABLE.ACTIVE_EVENTS['seed_carrier'] = nil
    end)

    
    
end