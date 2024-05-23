---
--- Created by JoBoDo.
--- DateTime: 14/09/2018 2:26 AM
---

return function(playerID)
    if not QuestService.player[playerID] then return {} end

    local save = {
        active = {},
        completed = {}
    }

    for questID, quest in pairs(QuestService.player[playerID].active) do
        save.active['q' .. questID] = quest:GetInSaveFormat()
    end

    for questID, quest in pairs(QuestService.player[playerID].completed) do
        save.completed['q' .. questID] = true
    end

    return save
end