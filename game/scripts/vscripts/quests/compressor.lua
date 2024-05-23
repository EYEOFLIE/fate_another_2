---
--- Created by JoBoDo.
--- DateTime: 5/09/2018 5:49 AM
---

--Saves quests into a string.


--[[
The first character in any system string is the version of the system, so that data can be changed and kept up to date over time and modifications
An inventory always starts (following the version) with an alphanumeric character and ends with a fullstop.
          Subsequent alphanumber characters before the full stop will denote information not directly related to the items but the inventory itself
              p will be followed by a number and denote the amount of slots purchased for this inventory
          An item is made up of a string chars. The first chunk is the item slot. It is followed by a dash to denote its end.
              The final inventory need not have a full stop
          The next 4 chars are the item ID. The following chars are the stack count.
          Between each item is a comma, to denote the end of the stack count
Following the list of items. There will be a p and then a number, denoting how many slots have been purchased in the inventory
]]


-- no task strings may contain upper case letters
--max of 26 (length of alphabet) tasks of each type (location, talkto, killType, event, ability) in a single stage of a quest. Must not contain upper case
--    unitType can not numbers (but can spell them ie satyrone, satyrtwo)
--    #can have 26 location + 26 talkto + 26 killType tasks  in the same stage. These do not intefere with eachother
-- all questID's must fall between 1000-1999 (max 999 quests in a game) by default

-->Possible improvement; code_letter for every task in every quest. This would significantly cut down the size of gather and kill.

local test_string = "1.00112{LabcTabcKa14b15c0Ma20b50c30Ga15b0c5EabcAa10b0c5,0054{LabcTabcKa14b15c0Ma20b50c30Ga15b0c5EabcAa10b0c5.001005009112115"
--  0011{Ga9
--[[        RAW DATA EXAMPLE
    Example: "1.00112{LabcTabcKa14b15c0Ma20b50c30Ga15b0c5EabcAa10b0c5,0054{LabcTabcKa14b15c0Ma20b50c30Ga15b0c5EabcAa10b0c5.001005009112115"


        Save Version
        . to denote seperation between version - active - completed
        active quests separated by ,
            first 3 characters = partial questID (all quest ID's are 4 characters long and start with the number 1 and this does not need to be saved in the string)
            subsquent characters until { are stageNum
            after { contains all the tasks
                A is an ability task and contains a single character for each ability_codename
                E is an event task and contains a single character for each event_codename
                G is a gather task and has 1 character for the item_codename followed by the amount obtained. End of digits followed by lowercase character denote new task
                K is a kill task and has 1 character for the unit codename followed by the amount killed. End of digits followed by lowercase character denote new task
                L is a location task and contains a single character for each completed location_codename
                M (many) is killType and has 1 character for the killtype codename followed by the amount killed. End of digits followed by lowercase character denote new task
                T is a talkto task and contains a single character for each completed talkto_codename
        location quests simply are 4 numbers each and they are a single long string of numbers
]]


--[[    DATA EXAMPLE

    active:
        q1001:
            questID: 1001
            stageNo: 1
            tasks:
                kill:
                    npc_dota_creature_lost_soul: 2
        q1010:
            questID: 1010
            stageNo: 2
            tasks:
        q1013:
            questID: 1013
            stageNo: 1
            tasks:
        q1078:
            questID: 1078
            stageNo: 1
            tasks:
    completed:
        q1000: true
]]

QUESTS_SAVE_VERSION = 3

local task_codes = {
    A = "useAbility",
    E = "event",
    G = "gather",
    K = "kill",
    L = "location",
    M = "killType",
    T = "talkto"
}
local function ResolveTask(code) return task_codes[code] or code end

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local compressor = {
    pack = function(data)
        local raw_data = QUESTS_SAVE_VERSION .. '.'
        if(type(data) ~= "table")then
            print(data)
        end

        --=======
        if data.active then
            for questID, qdata in pairs(data.active) do
                local stageNum = qdata.stageNo
                local all_tasks = qdata.tasks

                raw_data = raw_data .. questID:sub(3) .. stageNum --first two characters are q1
                if all_tasks then
                    raw_data = raw_data ..  '{'
                    for taskType, tasks in pairs(all_tasks) do
                        if taskType == 'location' then
                            raw_data = raw_data .. 'L'

                            for _, locationString in pairs(tasks) do
                                --abc
                                raw_data = raw_data .. locationString
                            end

                        elseif taskType == 'kill' then
                            raw_data = raw_data .. 'K'

                            for unitname, amount_killed in pairs(tasks) do
                                --a2b5c9
                                raw_data = raw_data .. unitname .. amount_killed
                            end

                        elseif taskType == 'killType' then
                            raw_data = raw_data .. 'M'

                            for unittype, amount_killed in pairs(tasks) do
                                --a5b50c30
                                raw_data = raw_data .. unittype .. amount_killed
                            end

                        elseif taskType == 'gather' then
                            raw_data = raw_data .. 'G'

                            for itemname, amount_gathered in pairs(tasks) do
                                --a90b15
                                raw_data = raw_data .. itemname .. amount_gathered
                            end

                        elseif taskType == 'talkto' then
                            raw_data = raw_data .. 'T'

                            for _, talkto_string in pairs(tasks) do
                                raw_data = raw_data .. talkto_string
                            end

                        elseif taskType == 'event' then
                            raw_data = raw_data .. 'E'

                            for _, event_string in pairs(tasks) do
                                --ab
                                raw_data = raw_data .. event_string
                            end

                        elseif taskType == 'useAbility' then
                            raw_data = raw_data .. 'A'

                            for abilityname, amount_used in pairs(tasks) do
                                --a50b0c9
                                raw_data = raw_data .. abilityname .. amount_used
                            end
                        end

                        raw_data = raw_data .. '*'
                    end
                    raw_data = raw_data:sub(1,-2)
                end
                raw_data = raw_data .. ','
            end
            raw_data = raw_data:sub(1,-2)
        end

        raw_data = raw_data .. '.' --dot needed to separate active/completed

        if data.completed then
            for questID, compressorQuestID in pairs(data.completed) do
                if (type(questID) == 'number') then
                    if (tostring(compressorQuestID):sub(1,1) ~= "q") then
                        compressorQuestID = 'q'..compressorQuestID
                    end
                    questID = compressorQuestID
                end                
                raw_data = raw_data .. questID:sub(3) --first 2 character are q1
            end
        end


        --=======
        return raw_data
    end,

    unpack = function(raw_data)
        local data = {
            active = {},
            completed = {}
        }

        local active_and_complete= split(raw_data, ".")
        local save_version = table.remove(active_and_complete, 1)

        local raw_active = active_and_complete[1]
        local raw_complete = active_and_complete[2]
        
        --last character will be a fullstop if there is no completed quests but there are active quests.
        --completed quests would show as nil in this example because nothing is afterit
        if not raw_complete and raw_data:sub(-1) ~= '.' then
            raw_active = nil
            raw_complete = active_and_complete[1]
        end

        if raw_active and #raw_active >= 1 then
            local quests_raw = split(raw_active, ',')

            for _, raw_quest in pairs(quests_raw) do
                local raw_info_and_tasks = split(raw_quest, "{")
                local raw_info = raw_info_and_tasks[1]

                local questID = 1 .. raw_info:sub(1,3)
                local stageNum = raw_info:sub(4)

                data.active['q' .. questID] = {
                    questID = questID,
                    stageNo = stageNum,
                    tasks = {}
                }

                if(raw_info_and_tasks[2]) then
                    local raw_tasks = split(raw_info_and_tasks[2], "*")

                    local tasks = {}
                    
                    for _, raw_task in ipairs(raw_tasks) do
                        local task_type = ResolveTask(raw_task:sub(1,1))
                        tasks[task_type] = {}

                        raw_task = raw_task:sub(2)

                        local match = {
                            kill = true,
                            killType = true,
                            gather = true,
                            useAbility = true
                        }

                        if match[task_type] then
                            while raw_task do
                                local compression_code = raw_task:sub(1,1)
                                raw_task = raw_task:sub(2)
                                local next_letter = raw_task:find('%l')
                                local until_letter = -1
                                if next_letter then until_letter = next_letter - 1 else until_letter = -1 end

                                local number = tonumber(raw_task:sub(1,until_letter))
                                tasks[task_type][compression_code] = number

                                if next_letter then
                                    raw_task = raw_task:sub(next_letter)
                                else
                                    raw_task = false
                                end
                            end
                        else
                            --everything else just needs single characters to be added in to an array
                            for i=1, #raw_task do
                                table.insert(tasks[task_type], raw_task:sub(i,i))
                            end
                        end
                    end

                    data.active['q' .. questID].tasks = tasks
                end
            end
        end

        if raw_complete then
            local sub_start = 1
            for i=1, #raw_complete/3 do
                local completed_quest_string = raw_complete:sub(sub_start,sub_start+2)
                completed_quest_string = '1' .. completed_quest_string
                table.insert(data.completed, completed_quest_string)                
                sub_start = sub_start + 3
            end
        end



        
        --we should have a full inventory table at this point
        --PrintTable(data)
        --print('-----')
        return data
    end
}
return compressor