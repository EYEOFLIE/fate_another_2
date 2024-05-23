---
--- Created by JoBoDo.
--- DateTime: 9/18/2017 2:14 PM
---


Quest = Quest or class({}, {
    DEFAULT_LOCATION_RADIUS = 300
})


function Quest:ToString()
    return "QuestID: " .. self.questID .. " | stage: " .. self.stageNum
end

function Quest:Debug(...)
    Debug("Quest", self.questID, "-", ...)
end

function Quest:Spew()
    print("*-*-*-*-*-*-*")
    self:Debug("PlayerID: ", self.playerID)
    print("*-*-*-*-*-*-*")
    self:Debug("taskListeners follow")
    PrintTable(self.taskListeners)
    print("*-*-*-*-*-*-*")
    self:Debug("injectionsFollow")
    PrintTable(self.injected)
    print("*-*-*-*-*-*-*")
    self:Debug("taskStatus follows")
    PrintTable(self.tasks)
    print("*-*-*-*-*-*-*")


end

function Quest:constructor(playerID, questID, args)
    args = args or {}
    self.playerID = tonumber(playerID)
    self.questID = tonumber(questID)
    
    self.stageNum = tonumber(args.stageNum) or 0
    self.loading = args.loading

    self.data = QuestService.data[tostring(questID)]
    if not self.data then
        self:Debug("QuestID does not exist in QuestService.data")
        self.bInitSuccess = false
        return false
    end

    if not self.data.stages[tostring(self.stageNum)] then
        self.bInitSuccess = false
        return false
    end

    self.canAbandon = not tobool(self.data.cantAbandon)
    self.onAbandon = self.data.onAbandon
    self:InitStage(self.stageNum)

    self.bInitSuccess = true
    return true
end

function Quest:GetStageNum()
    return self.stageNum
end

function Quest:GetHero()
    return Core:GetHero(self.playerID)
end

function Quest:GetNextTaskIndex()
    if not self.taskIndexes then
        self.taskIndexes = 0
    end
    self.taskIndexes = self.taskIndexes + 1
    return self.taskIndexes;
end

function Quest:GetQuestStatus()
    if self.stageNum == 0 then
        return 'available'
    elseif self.stageNum > 0 then
        return 'active'
    end
    if not self.stageNum then
        self:Debug("No stage num set")
        return false
    end

    self:Debug("Invalid stage num: ", self.stageNum)
    return false
end

function Quest:GetLastStageNum()
    local index = 0
    local bLastStageFound = false
    while bLastStageFound == false do
        if not self.data.stages[tostring(index + 1)] then
            bLastStageFound = true
        else
            index = index + 1
        end
    end
    return index
end

function Quest:GetUIInformation(status)

    if status == 'active' and self.stageNum == 0 then return false end
    if status == 'available' and self.stageNum ~= 0 then return false end

    local stageNum = self.stageNum

    if status == 'completed' then
        stageNum = self:GetLastStageNum()
    end

    local info = {
        details = {
            questID = self.questID,
            name = self.data.name,
            description = self.data.description,
            typeIcon = self.data.typeIcon,
            portrait = self.data.portrait,
        },
        tasks = {}
    }

    if stageNum ~= self.stageNum then
        info.details.name = self.data.name
    end

    local index = 0
    if(self.tasks) then
        for taskType, tasks in pairs(self.tasks) do
            for taskRef, task in pairs(tasks) do

                local index = index + 1
                local taskInfo = {
                    taskIndex = 1,
                    taskType = taskType,
                    taskObject = task.string,
                    completed = task.completed
                }

                local obtained = task.obtained
                if tonumber(obtained) then obtained = math.floor(tonumber(obtained)) end

                if(task.obtained and task.required) then
                    taskInfo.taskNumber = obtained .. ' / ' .. task.required
                end

                info.tasks[task.index] = taskInfo
            end
        end
    end

    if stageNum > 0 then
        local stageDescriptions = {}
        for i = 1, stageNum do
            local stageData = self.data.stages[tostring(i)]
            if stageData and stageData.description then
                table.insert(stageDescriptions, stageData.description)
            end
        end

        if tablelength(stageDescriptions) > 0 then
            info.stageDescriptions = stageDescriptions
        end
    end
    
    return info
end

function Quest:IsTaskComplete(taskID)
    if not self.taskIDs then
        self:Debug("Called IsTaskComplete but stage ", self.stageNum, " has no tasks configured")
        return false
    end

    local taskInfo = self.taskIDs[taskID]
    if not taskInfo then
        self:Debug("Could not find taskID ", taskID, " on stage num ", self.stageNum)
        return false
    end
    local taskType = taskInfo.taskType
    local ref = taskInfo.ref

    if not self.tasks[taskType] then
        self:Debug("No tasks of type ", taskType, "exist for stage ", self.stageNum," of quest")
        return false
    end

    if not self.tasks[taskType][ref] then
        self:Debug("No reference of ", ref, " could be found inside taskType ", taskType, " for stage ", self.stageNum)
        return false
    end

    if self.tasks[taskType][ref].completed == true then
        return true
    else
        return false
    end
end

function Quest:LoadProgress(progress)
    Debug("Quest", "LoadQuestProgress - incomplete function")
    --printTable(progress)

    if progress.kill then
        for compression_code, obtained in pairs(progress.kill) do
            for key, taskinfo in pairs(self.tasks.kill) do
                if compression_code == taskinfo.compression_code then
                    self.tasks.kill[key].obtained = obtained
                end

                if(self.tasks.kill[key].obtained >= self.tasks.kill[key].required) then
                    self.tasks.kill[key].completed = true;
                else
                    self.tasks.kill[key].completed = false;
                end
            end
        end
    end

    if progress.killType then
        for compression_code, obtained in pairs(progress.killType) do
            for key, taskinfo in pairs(self.tasks.killType) do
                if compression_code == taskinfo.compression_code then
                    self.tasks.killType[key].obtained = obtained
                end

                if(self.tasks.killType[key].obtained >= self.tasks.killType[key].required) then
                    self.tasks.killType[key].completed = true;
                else
                    self.tasks.killType[key].completed = false;
                end
            end
        end
    end

    if progress.location then
        for index, locationString in pairs(progress.location) do
            for _, compression_code in pairs(progress.location) do
                for key, taskinfo in pairs(self.tasks.location or {}) do
                    if compression_code == taskinfo.compression_code then
                        self.tasks.location[key].completed = true
                    end
                end
            end
        end
    end

    if progress.event then
        for index, eventName in pairs(progress.event) do
            for _, compression_code in pairs(progress.event) do
                for key, taskinfo in pairs(self.tasks.event or {}) do
                    if compression_code == taskinfo.compression_code then
                        self.tasks.event[key].completed = true
                    end
                end
            end
        end
    end

    if progress.talkto then
        for index, listenString in pairs(progress.talkto) do
            for _, compression_code in pairs(progress.talkto) do
                for key, taskinfo in pairs(self.tasks.talkto or {}) do
                    if compression_code == taskinfo.compression_code then
                        self.tasks.talkto[key].completed = true
                    end
                end
            end
        end
    end

    if progress.gather then
        for compression_code, obtained in pairs(progress.gather) do
            print(self.questID)
            for itemname, taskinfo in pairs(self.tasks.gather or {}) do
                if compression_code == taskinfo.compression_code then
                    self.tasks.gather[itemname].obtained = obtained
                end

                if(self.tasks.gather[itemname].obtained >= self.tasks.gather[itemname].required) then
                    self.tasks.gather[itemname].completed = true
                else
                    self.tasks.gather[itemname].completed = false
                end
            end
        end
    end

    if progress.useAbility then
        for compression_code, obtained in pairs(progress.useAbility) do
            for key, taskinfo in pairs(self.tasks.useAbility) do
                if compression_code == taskinfo.compression_code then
                    self.tasks.useAbility[key].obtained = obtained

                    if self.tasks.useAbility[key].obtained >= self.tasks.useAbility[key].required then
                        self.tasks.useAbility[key].completed = true
                    end
                end
            end
        end
    end

    self:TaskUpdated()
    --todo: insure that all the tasks are in their correct state after loading

    --Since this todo, I've added checks after adding the obtained amouts to se eif the task was completed.
    --Seems to be functioning correctly after some tests

end

function Quest:AttemptAbandon(bForce)
    if bForce or self.canAbandon then
        if self.onAbandon then
            self:OnAbandon()
        end
        self:Remove()
        return true
    end
    return false
end
function Quest:OnAbandon()
    if not self.onAbandon then return end
    if self.onAbandon.giveQuest then
        local questID = self.onAbandon.giveQuest.questID
        local stageNum = self.onAbandon.giveQuest.stageNum or 1
        QuestService:AttemptGiveQuest(self.playerID, questID, true, tonumber(stageNum))
    end

    if self.onAbandon.goToStage then
        local questID = self.onAbandon.goToStage.questID
        local stageNum = self.onAbandon.goToStage.stageNum
        if not questID or not stageNum then return end
        local quest = QuestService:GetActiveQuest(self.playerID, tonumber(questID))
        quest:SetStage(stageNum)
    end
end

function Quest:ClearQuestStage()

    self:RemoveListeners()
    self:RemoveTaskListeners()
    self:RemoveInjections()
    self.listeners = nil
    self.taskListeners = nil
    self.taskIDs = nil
end

function Quest:RemoveListeners()
    if(self.listeners) then
        for listener, bListening in pairs(self.listeners) do
            QuestService:RemoveListener(self.playerID, self.questID, listener)
        end
    end
end

function Quest:RemoveTaskListeners()
    if(self.taskListeners) then
        for listener, bListening in pairs(self.taskListeners) do
            QuestService:RemoveTaskListener(self.playerID, self.questID, listener)
        end
    end
end

function Quest:InitStage(stageNum)
    self:Debug("InitStage -", stageNum)
    self.bStageInitComplete = false

    self.stageData = self.data.stages[tostring(stageNum)]
    self.stageNum = stageNum

    --Start Quest notifications
    if stageNum == 1 then
        if not self.loading then
            local notificationText = {"- Started the quest '", self.data.name, "'"}
            Notifications:Top(self.playerID, {hero=Core:GetHero(self.playerID):GetUnitName(), imagestyle="landscape", style={["width"]="80px", ["height"]="40px"}, duration=5.0})
            Notifications:Top(self.playerID, {text=notificationText, style={color='green', ["font-size"]="25px", ["margin-left"]="15px", ["margin-right"]="105px"}, continue = true})
        else
            self.loading = nil
        end
    end

    if stageNum == 0 then
        QuestService.player[self.playerID].available[self.questID] = self
    else
        QuestService.player[self.playerID].available[self.questID] = nil
        QuestService.player[self.playerID].active[self.questID] = self
    end

    if self.stageData.inject then
        self:InjectParticles()
        self:InjectWorldParticles() -- must be reinjected when hero changes
        self:InjectDialogue()
        self:InjectLoot()
        self:InjectSpawns()
        self:InjectDungeons()
    end

    self:Debug("Setting up tasks")
    self:SetupTasks(stageNum)
    self:SetupListeners()

    self.bStageInitComplete = true
    self:TaskUpdated()
    QuestService:UpdateAvailableUI(self)
    QuestService:UpdateActiveUI(self)

    self:Run_OnInit()
end

function Quest:SetupListeners()
    if self.stageData.OnHeroDied then
        self:SetupListener('hero_died')
    end
end

function Quest:Run_OnInit()
    if not self.stageData.onInit then return end

    local runScript = self.stageData.onInit.runScript
    if runScript then
        local className = runScript.className
        local functionName = runScript.functionName
        local arguments = runScript.arguments or {}
        if not className or not functionName then 
            print("WARNING: ", "invalid class/function name")
            return            
        end
        if not _G[className] or not _G[className][functionName] then 
            print("WARNING: ", "class/function not found")
            return
        end
        Interactable:InteractableRunScript(self.playerID, className, functionName, arguments)
    end
end

function Quest:GoPriorStage()
    self:SetStage(self:GetStageNum() - 1)
end
function Quest:GoStage(args)
    local stageNum = tonumber(args.stage)
    if not stageNum then print("Quest",self.questID, "Was told to go to stage, but no stage was given") end
    self:SetStage(stageNum)
end

function Quest:OnHeroDied(hero, killer)
    if not self.stageData.OnHeroDied then return end
    if hero ~= Core:GetHero(self.playerID) then return end

    local goPriorStage = self.stageData.OnHeroDied.GoPriorStage
    if goPriorStage then
        self:GoPriorStage()
    end

    local goStage = self.stageData.OnHeroDied.GoStage
    if goStage then
        self:GoStage(goStage)
    end

    local runScript = self.stageData.OnHeroDied.runScript
    if runScript then
        local className = runScript.className
        local functionName = runScript.functionName
        local arguments = runScript.arguments or {}
        if not className or not functionName then 
            print("WARNING: ", "invalid class/function name")
            return            
        end
        if not _G[className] or not _G[className][functionName] then 
            print("WARNING: ", "class/function not found")
            return
        end
        Interactable:InteractableRunScript(self.playerID, className, functionName, arguments)
    end

    local removeQuest = self.stageData.OnHeroDied.RemoveQuest
    if removeQuest and tobool(removeQuest) then
        QuestService:RemoveQuest(self)
    end
end

function Quest:RemoveInjections()
    self:RemoveInjectedDialogue()
    self:RemoveInjectedParticles()
    self:RemoveInjectedWorldParticles()
    self:RemoveInjectedLoot()
    self:RemoveInjectedSpawns()
    self:RemoveInjectedDungeons()
end

function Quest:InjectSpawns()
    local injections = self.stageData.inject.spawns
    if not injections then return false end
    self.injected = self.injected or {}
    self.injected.spawns = self.injected.spawns or {}

    for spawnLocation, unitName in pairs(injections) do
        self:Debug("Found spawn to inject")

        self.injected.spawns[unitName] = self.injected.spawns[unitName] or {}
        table.insert(self.injected.spawns[unitName], spawnLocation)

        Event:Trigger('inject_spawn')
    end
end

function Quest:RemoveInjectedSpawns()

end 

function Quest:GetParticleReference()
    return 'quest_' .. self.questID
end

function Quest:InjectParticles()
    local injections = self.stageData.inject.particle
    if not injections then return false end
    self.injected = self.injected or {}
    self.injected.particles = self.injected.particles or {}

    for unitName, particleRef in pairs(injections) do
        self:Debug('found particle to inject')
        local particlePath = QuestService:GetParticlePath(self.playerID, self.questID, particleRef)

        if particlePath then
            self.injected.particles[unitName] = self.injected.particles[unitName] or {}
            self.injected.particles[unitName][particleRef] = true

            Event:Trigger('inject_unit_particle', {
                reference = self:GetParticleReference(),
                playerID = self.playerID,
                unitName = unitName,
                particleRef = particleRef,
                particlePath = particlePath
            })

        else
            self:Debug("Couldn't find particle path for ref ", particleRef)
        end
    end
end

function Quest:RemoveInjectedParticles()
    if not (self.injected and self.injected.particles) then return false end

    for unitName, particleInfo in pairs(self.injected.particles) do
        for particleRef, bBool in pairs(particleInfo) do
            self:Debug("RemoveInjectedParticles for unit ", unitName)
            Event:Trigger('remove_unit_injected_particle', {
                reference = self:GetParticleReference(),
                playerID = self.playerID,
                unitName = unitName,
                particleRef = particleRef
            })
        end
    end

    self.injected.particles = nil
end

function Quest:InjectWorldParticles()
    if not self.stageData or not self.stageData.inject then return end
    local injections = self.stageData.inject.world_particle
    if not injections then return end
    self.injected = self.injected or {}
    self.injected.world_particles = self.injected.world_particles or {}


    for index, particle_info in pairs(injections) do
        local path = particle_info.path
        local destination_entity = particle_info.target
        local amount = particle_info.amount
        print("INJECTING WORLD PARTICLE ", path, destination_entity, amount)

        local cps = particle_info.cps or {}

        local entities = Entities:FindAllByName(destination_entity)

        local placed = 0
        for i=1, #entities do
            local entity = entities[i]
            if (amount == nil) or (amount > placed) then
                print("CREATING A PARTICLE")
                local particle = ParticleManager:CreateParticle(path, PATTACH_ABSORIGIN, Core:GetHero(self.playerID))
                print("SETTING PARTICLE ", particle, " to ", entity:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 0, entity:GetAbsOrigin())

                for index, value in pairs(cps) do
                    local vecarray = split(value, "")
                    local vec = Vector(vecarray[1], vecarray[2], vecarray[3])
                    ParticleManager:SetParticleControl(particle, vec)
                end

                table.insert(self.injected.world_particles, particle)
                placed = placed + 1
            end
        end
    end
end

function Quest:RemoveInjectedWorldParticles()
    if not (self.injected and self.injected.world_particles) then return end

    for i=1, #self.injected.world_particles do
        print("REMOVING INJECTED WORLD PARTICLES", self.injected.world_particles[i])
        ParticleManager:DestroyParticle(self.injected.world_particles[i], false)
        ParticleManager:ReleaseParticleIndex(self.injected.world_particles[i])
    end
    self.injected.world_particles = nil
end
function Quest:GetDialogueReference()
    return 'quest_' .. self.questID
end

function Quest:InjectDialogue()
    local injections = self.stageData.inject
    if not injections or not injections.dialogue then
        self:Debug('no dialogue to inject')
        return false
    end
    if not self.data.injections then
        self:Debug("Quest was set up to inject dialogue but no dialogue trees were given")
        return false
    end

    self.injected = self.injected or {}
    self.injected.dialogue = self.injected.dialogue or {}

    for unitName, dialogueRef in pairs(injections.dialogue) do
        local split = string.gmatch(dialogueRef, '([^ ]+)')  --split by ' '
        for ref in split do
            local dialogue = self.data.injections[ref]
            if dialogue then
                self:Debug('found dialogue to inject')
                self.injected.dialogue[unitName] = self.injected.dialogue[unitName] or {}
                table.insert(self.injected.dialogue[unitName], ref)
    
                Event:Trigger('inject_dialogue', {
                    reference = self:GetDialogueReference(),
                    playerID = self.playerID,
                    unitName = unitName,
                    dialogue = dialogue
                })
            else
                self:Debug("No dialogue could be found for the injection reference:", dialogueRef)
            end
        end
    end
end

function Quest:RemoveInjectedDialogue()
    if not (self.injected and self.injected.dialogue) then return false end

    for unitName, dialogue in pairs(self.injected.dialogue) do

        Event:Trigger('remove_injected_dialogue',{
            reference = self:GetDialogueReference(),
            playerID = self.playerID,
            unitName = unitName,
        })
    end

    self.injected.dialogue = nil
end

function Quest:GetDungeonReference()
    return 'quest_' .. self.questID
end

function Quest:InjectDungeons()
    local injections = self.stageData.inject
    if not injections or not injections.dungeons then return false end

    self.injected = self.injected or {}
    self.injected.dungeons = self.injected.dungeons or {}

    for dungeon_name, dungeon_table in pairs(injections.dungeons) do
        self.injected.dungeons[dungeon_name] = dungeon_table

        Event:Trigger('inject_dungeon', {
            reference = self:GetDungeonReference(),
            playerID = self.playerID,
            dungeonName = dungeon_name,
            dungeonTable = dungeon_table
        })
    end
end

function Quest:RemoveInjectedDungeons()
    if not (self.injected and self.injected.dungeons) then return false end

    for dungeonName, dungeonTable in pairs(self.injected.dungeons) do
        Event:Trigger('deject_dungeon', {
            reference = self:GetDungeonReference(),
            playerID = self.playerID,
            dungeonName = dungeonName
        })
    end
    self.injected.dungeons = nil
end

function Quest:GetLootReference()
    return 'quest_' .. self.questID
end

function Quest:InjectLoot()
    local injections = self.stageData.inject
    if not injections or not injections.loot then return false end

    self.injected = self.injected or {}
    self.injected.loot = self.injected.loot or {}

    for unitName, lootTable in pairs(injections.loot) do
        self.injected.loot[unitName] = lootTable

        Event:Trigger('inject_loot', {
            reference = self:GetLootReference(),
            playerID = self.playerID,
            unitName = unitName,
            lootTable = lootTable
        })
    end
end

function Quest:RemoveInjectedLoot()

    if not (self.injected and self.injected.loot) then return false end

    for unitName, lootTable in pairs(self.injected.loot) do
        Event:Trigger('remove_injected_loot', {
            reference = self:GetLootReference(),
            playerID = self.playerID,
            unitName = unitName,
        })
    end

    self.injected.loot = nil
end

function Quest:SetStage(stageNum)
    return self:GoNextStage(stageNum)
end
function Quest:GoNextStage(stageNum)
    self:Debug('Quest:GoNextStage(', (stageNum or self.stageNum + 1),')')
    self:ClearQuestStage()

    if not stageNum then stageNum = self.stageNum + 1 end
    if stageNum < 0 then
        stageNum = 0
    end

    if not (self.data.stages[tostring(stageNum)]) then
        self:Complete()
        return false
    end

    self:InitStage(stageNum)
    self:IsStageComplete()

    
    if stageNum == 1 then
        QuestService:UpdateAvailabilityForQuest(self.playerID, self.questID)
        QuestService:RefreshAvailableQuests(self.playerID, self.questID)
    end
    return true
end

function Quest:Remove()
    self:Debug("Remove")
    self:RemoveInjections()
    self:RemoveTaskListeners()


    QuestService:RemoveQuest(self)
end

function Quest:IsQuestComplete()
    if self.data.stages[tostring(self.stageNum + 1)] then
        return false
    end
    return true
end

function Quest:Complete()
    QuestService.player[self.playerID].completed[self.questID] = true

    local hero = Core:GetHero(self.playerID):GetUnitName()
    Notifications:Top(self.playerID, {hero=hero, imagestyle="landscape", style={["width"]="80px", ["height"]="40px"}, duration=5.0})
    Notifications:Top(self.playerID, {text={"- Completed the quest '", self.data.name, "'"}, style={color='green', ["font-size"]="25px", ["margin-left"]="15px", ["margin-right"]="105px"}, continue = true})

    QuestService:QuestWasCompleted(self.playerID, self.questID)
    self:Remove()
end

function Quest:CompleteStage()

    self:ClearQuestStage()
    if self.stageData.onCompletion then
        self:GiveQuestRewards()
    end
end

function Quest:GiveQuestRewards()
    local rewards = self.stageData.onCompletion.rewards

    if rewards then
        local reward = {
            playerID = self.playerID,
            name = "Quest Complete",
            gold = rewards.gold,
            exp = rewards.exp
        }
    
        if rewards.items then
            reward.itemNames = {}
            for itemName, amount in pairs(rewards.items) do
                reward.itemNames[itemName] = {amount = amount}
            end
        end
    
        self:Debug("Giving reward for completing stage")
        --printTable(reward)
        if reward.gold or reward.exp or reward.items or reward.itemNames then
            Event:Trigger('grant_reward', reward)
        end
    end


    local consume = self.stageData.onCompletion.consume
    for itemName, amount in pairs(consume or {}) do
        Event:Trigger('inventory_remove_items', {
            playerID = self.playerID,
            itemName = itemName,
            amount = amount
        })
    end


    local quests = self.stageData.onCompletion.quests
    for questID, bForce in pairs(quests or {}) do
        QuestService:AttemptGiveQuest(self.playerID, tonumber(questID), tobool(bForce), 1)
    end

    local runScript = self.stageData.onCompletion.runScript
    if runScript then
        local className = runScript.className
        local functionName = runScript.functionName
        local arguments = runScript.arguments or {}
        if not className or not functionName then 
            print("WARNING: ", "invalid class/function name")
            return            
        end
        if not _G[className] or not _G[className][functionName] then 
            print("WARNING: ", "class/function not found")
            return
        end
        Interactable:InteractableRunScript(self.playerID, className, functionName, arguments)
    end
    return true
end

function Quest:TaskUpdated()

    QuestService:UpdateActiveUI(self)

    if not self.bStageInitComplete then
        return false
    end

    if self.stageNum > 0 then
        Event:Trigger("update_save_data", {
            playerID = self.playerID,
            system = "Quests",
            keys = {"active", ("q" .. self.questID)},
            value = self:GetInSaveFormat()
        })
    end

    self:Debug("Post bStageInitComplete")

    if(self:IsStageComplete()) then
        self:Debug("Stage", self.stageNum, "was completed")
        self:CompleteStage()

        if self:IsQuestComplete() then
            self:Complete()
        else
            self:GoNextStage()
        end
    end
end

function Quest:StageFailed()
    if self.stageData.onFail then
        self:RunSetStage(self.stageData.onFail.setStage)
    end
end


function Quest:SetupListener(type)
    self.listeners = self.listeners or {}
    self.listeners[type] = true
    QuestService:AddListener(self.playerID, self.questID, type, self)
    self:Debug('QuestService:AddListener(',self.playerID, self.questID, type, self, ')')
end

--todo: Test this properly
function Quest:RunSetStage(originalStageNum)
    self:Debug("RunSetStage", originalStageNum)
    local stageNum = originalStageNum

    if stageNum then
        if type(stageNum) == 'string' then
            if string.find(stageNum, '+') then
                local addStageNum = string.gsub(stageNum, '+', '')
                self:Debug("Adding ", addStageNum, "stages")
                addStageNum = tonumber(addStageNum)
                stageNum = self.stageNum + addStageNum
            elseif string.find(stageNum, '-') then
                local minusStageNum = string.gsub(stageNum, '-', '')
                minusStageNum = tonumber(minusStageNum)
                self:Debug("Removing", minusStageNum, "stages")
                stageNum = self.stageNum - minusStageNum
            end
        elseif stageNum < 0 then
            stageNum = self.stageNum + stageNum
        end
    end

    --make setStage a number
    stageNum = tonumber(stageNum)
    if not stageNum then
        self:Debug("RunSetStage: Could not turn ", originalStageNum, "into a number")
        return false
    end
    --Go to a specifically defined stage
    self:GoNextStage(stageNum)
    return true
end

function Quest:IsStageComplete()
    --stage can't be complete if it has no tasks. It must be forced elsewhere
    if not self.tasks then
        return false
    end

    if(self.tasks.location) then
        for locationString, taskInfo in pairs(self.tasks.location) do
            if not self:IsLocationTaskComplete(locationString) then
                return false
            end
        end
    end
    if(self.tasks.kill) then
        for unitName, _ in pairs(self.tasks.kill) do
            if not self:IsKillTaskComplete(unitName) then
                return false
            end
        end
    end
    if(self.tasks.killType) then
        for unitType, _ in pairs(self.tasks.killType) do
            if not self:IsKillTypeTaskComplete(unitType) then
                return false
            end
        end
    end
    if(self.tasks.gather) then
        for itemName, _ in pairs(self.tasks.gather) do
            if not self:IsGatherTaskCompleted(itemName) then
                return false
            end
        end
    end
    if(self.tasks.talkto) then
        for listenString, _ in pairs(self.tasks.talkto) do
            if not self:IsTalktoTaskCompleted(listenString) then
                return false
            end
        end
    end
    if(self.tasks.event) then
        for eventName, _ in pairs(self.tasks.event) do
            if not self:IsEventTaskCompleted(eventName) then
                return false
            end
        end
    end
    if(self.tasks.reachLevel) then
        if not self:IsReachLevelTaskCompleted() then
            return false
        end
    end
    if(self.tasks.reachTier) then
        if not self:IsReachTierTaskCompleted() then
            return false
        end
    end

    if self.tasks.useAbility then
        for abilityName, _ in pairs(self.tasks.useAbility) do
            self:Debug("Checking if task: ", abilityName, " is completed")
            if not self:IsUseAbilityTaskCompleted(abilityName) then
                return false
            end
        end
    end

    if self.tasks.obtainGateKey then
        for gateKey, _ in pairs(self.tasks.obtainGateKey) do
            self:Debug("Checking if task: ", gateKey, " is completed")
            if not self:IsObtainGateKeyTaskCompleted(gateKey) then
                return false
            end
        end
    end

    if self.tasks.completeQuest then
        for questID, _ in pairs(self.tasks.completeQuest) do
            self:Debug("Checking if task: ", questID, " is completed")
            if not self:IsCompleteQuestTaskCompleted(questID) then
                return false
            end
        end
    end

    --finally, if it reaches this point, all tasks should be completed
    return true
end

function Quest:GetInSaveFormat()
    local save = {}

    save.questID = self.questID
    save.stageNo = self.stageNum
    save.tasks = self:GetTasksInSaveFormat()

    return save
end

function Quest:GetTasksInSaveFormat()
    local tasks = {}

    --[[
        the following tasks dont need to be gotten in save format because they are only false/true and the info is permanent
            reachLevel:
            reachTier:
    ]]
    if not self.tasks then return tasks end

    if(self.tasks.location) then
        tasks.location = tasks.location or {}
        for locationString, taskInfo in pairs(self.tasks.location) do
            if(self:IsLocationTaskComplete(locationString)) then
                table.insert(tasks.location, taskInfo.compression_code)
            end
        end
        if(#tasks.location < 1) then
            tasks.location = nil
        end
    end

    if(self.tasks.kill) then
        tasks.kill = tasks.kill or {}
        for unitName, taskInfo in pairs(self.tasks.kill) do
            tasks.kill[taskInfo.compression_code] = taskInfo.obtained
        end
    end

    if(self.tasks.killType) then
        tasks.killType = tasks.killType or {}
        for unitType, taskInfo in pairs(self.tasks.killType) do
            tasks.killType[taskInfo.compression_code] = taskInfo.obtained
        end
    end

    if(self.tasks.gather)then
        tasks.gather = tasks.gather or {}
        for itemName, taskInfo in pairs(self.tasks.gather) do
            tasks.gather[taskInfo.compression_code] = taskInfo.obtained
        end
    end

    if(self.tasks.talkto)then
        tasks.talkto = tasks.talkto or {}
        for listenString, taskInfo in pairs(self.tasks.talkto) do
            if(taskInfo.completed) then
                table.insert(tasks.talkto, taskInfo.compression_code)
            end
        end
        if(#tasks.talkto < 1) then
            tasks.talkto = nil
        end
    end

    if self.tasks.event then
        tasks.event = tasks.event or {}
        for eventName, taskInfo in pairs(self.tasks.event) do
            if(taskInfo.completed) then
                table.insert(tasks.event, taskInfo.compression_code)
            end
        end

        if #tasks.event < 1 then
            tasks.event = nil
        end
    end

    if self.tasks.useAbility then
        tasks.useAbility = tasks.useAbility or {}
        for abilityName, taskInfo in pairs(self.tasks.useAbility) do
            tasks.useAbility[taskInfo.compression_code] = taskInfo.obtained
        end
    end


    return tasks
end

--[[
    TASKS FUNCTIONS
]]
function Quest:SetupTasks(stageNum)
    self:Debug("Setting up tasks for stage ", stageNum)
    self.taskData = self.stageData.tasks
    if(self.taskData)then
        self.tasks = {}

        self:SetupLocationTasks()
        self:SetupKillTasks()
        self:SetupKillTypeTasks()
        self:SetupGatherTasks()
        self:SetupTalktoTasks()
        self:SetupEventTasks()
        self:SetupReachLevelTask()
        self:SetupReachTierTask()
        self:SetupUseAbilityTask()
        self:SetupObtainGateKeyTask()
        self:SetupCompleteQuestTask()
    else
        self.tasks = nil
    end

    self:IsStageComplete()
end


function Quest:SetupTaskListener(type)
    self.taskListeners = self.taskListeners or {}
    self.taskListeners[type] = true
    QuestService:AddTaskListener(self.playerID, self.questID, type, self)
    self:Debug('QuestService:AddTaskListener(',self.playerID, self.questID, type, self, ')')
end

function Quest:WriteTaskNotifications(taskInfo)
    if not taskInfo.notificationSettings then return false end
    if taskInfo.completed then return false end

    local settings = taskInfo.notificationSettings

    local notificationArgs = {
        text = "Task Updated",
        style = {
            ["font-size"] =  '22px',
            color = 'orange',
        },
        duration = 4,
    }

    if settings.type == 'quantity' then
        --todo: Don't update the task when it's first given and set to 0
        if taskInfo.obtained <= 0 then return false end
        --change color
        --change text
        notificationArgs.text = taskInfo.obtained .. '/' .. taskInfo.required
        if settings.text then
            notificationArgs.text = notificationArgs.text .. ' ' .. settings.text
        end

        local perc = taskInfo.obtained / taskInfo.required
        if perc < 0.25 then
            notificationArgs.style.color = 'red'
        elseif perc < 0.5 then
            notificationArgs.style.color = 'orange'
        elseif perc < 0.75 then
            notificationArgs.style.color = 'yellow'
        elseif perc < 1 then
            notificationArgs.style.color = 'greenyellow'
        elseif perc >= 1 then
            notificationArgs.style.color = 'green'
        end

    elseif settings.type == 'singular' then
        if settings.text then
            notificationArgs.text = settings.text
        end
        notificationArgs.style.color = 'green'
    end

    Notifications:Top(self.playerID, notificationArgs)
end

function Quest:SetupLocationTasks()
    if not self.taskData.location then return false end

    for index, taskInfo in pairs(self.taskData.location) do
        self.tasks.location = self.tasks.location or {}

        local locationString = taskInfo.locationString
        local radius = taskInfo.radius or Quest.DEFAULT_LOCATION_RADIUS

        self.tasks.location[taskInfo.locationString] = {
            string = taskInfo.name, --todo: See if this errors when taskInfo.name is nil
            locationString = taskInfo.locationString,
            radius = radius,
            completed = false,
            index = self:GetNextTaskIndex(),
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                text = 'Location Visited'
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'location',
                ref = taskInfo.locationString
            }
        end


        local locationEntity = Entities:FindByName(nil, taskInfo.locationString)
        if locationEntity then

            local location = locationEntity:GetAbsOrigin()

            --todo: Replace with dummy_location unit?
            local unit = CreateUnitByName('dummy_unit_vulnerable_location_quest', location, false, nil, nil, DOTA_TEAM_GOODGUYS)
            unit:SetNeverMoveToClearSpace(true)
            unit.locationString = locationString
            unit:AddNewModifier(unit, nil, "quest_location_thinker", {radius = radius})

            self.locationDummies = self.locationDummies or {}
            table.insert(self.locationDummies, unit)

        else
            self:Debug("Could not find entity for location string ", taskInfo.locationString)
        end




    end

    self:SetupTaskListener('location')
end

function Quest:UpdateLocationTask(locationString)
    if self.tasks.location and self.tasks.location[locationString] then
        self:WriteTaskNotifications(self.tasks.location[locationString])

        self.tasks.location[locationString].completed = true
        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:IsLocationTaskComplete(locationString)
    if not self.tasks.location or not self.tasks.location[locationString] then
        self:Debug("Location task is not complete because quest does not have ", locationString, "as a location task")
        return false
    end
    return self.tasks.location[locationString].completed
end

function Quest:SetupKillTasks()
    if not self.taskData.kill then return false end

    for unitName, taskInfo in pairs(self.taskData.kill) do
        self.tasks.kill = self.tasks.kill or {}
        self.tasks.kill[unitName] = {
            string = taskInfo.description or unitName,
            required = tonumber(taskInfo.amount),
            obtained = 0,
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,
            notificationSettings = {
                text = 'Killed',
                type = 'quantity'
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'kill',
                ref = unitName
            }
        end
    end


    self:SetupTaskListener('kill')
end

function Quest:UpdateKillTask(unitName)
    if self.tasks.kill and self.tasks.kill[unitName] then

        --task was completed already
        if self.tasks.kill[unitName].completed then
            return
        end

        self.tasks.kill[unitName].obtained = self.tasks.kill[unitName].obtained + 1

        self:WriteTaskNotifications(self.tasks.kill[unitName])

        if(self.tasks.kill[unitName].obtained >= self.tasks.kill[unitName].required) then
            self.tasks.kill[unitName].completed = true;
        else
            self.tasks.kill[unitName].completed = false;
        end

        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:IsKillTaskComplete(unitName)
    if not self.tasks.kill or not self.tasks.kill[unitName] then
        self:Debug("Kill task is not complete because quest does not have ",unitName, "as a kill task")
        return false
    end

    local status = self.tasks.kill[unitName]
    if status.obtained >= status.required then
        return true
    end
    return false
end

function Quest:SetupKillTypeTasks()
    if not self.taskData.killType then return false end

    for unitType, taskInfo in pairs(self.taskData.killType) do
        self.tasks.killType = self.tasks.killType or {}
        self.tasks.killType[unitType] = {
            string = taskInfo.customName or unitType,
            required = tonumber(taskInfo.amount),
            obtained = 0,
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                text = 'Killed',
                type = 'quantity'
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'killType',
                ref = unitType
            }
        end
    end


    self:SetupTaskListener('killType')
end

--returns true if succesfully updated the task
function Quest:UpdateKillTypeTask(unitType)
    if self.tasks.killType and self.tasks.killType[unitType] then

        if self.tasks.killType[unitType].completed then
            return
        end

        self.tasks.killType[unitType].obtained = self.tasks.killType[unitType].obtained + 1

        self:WriteTaskNotifications(self.tasks.killType[unitType])

        if(self.tasks.killType[unitType].obtained >= self.tasks.killType[unitType].required) then
            self.tasks.killType[unitType].completed = true;
        else
            self.tasks.killType[unitType].completed = false;
        end

        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:IsKillTypeTaskComplete(unitType)
    if not self.tasks.killType or not self.tasks.killType[unitType] then
        self:Debug("KillType task is not complete because quest does not have ", unitType, " as a killType task")
        return false
    end

    local status = self.tasks.killType[unitType]

    if status.obtained >= status.required then
        self.tasks.killType[unitType].completed = true
        return true
    end
    return false
end

function Quest:SetupGatherTasks()
    if not self.taskData.gather then return false end

    self:SetupTaskListener('gather')

    for itemName, taskInfo in pairs(self.taskData.gather) do
        self.tasks.gather = self.tasks.gather or {}
        self.tasks.gather[itemName] = {
            required = tonumber(taskInfo.required),
            obtained = 0,
            string = taskInfo.customName or ('DOTA_Tooltip_ability_'..itemName),
            consume = tobool(taskInfo.consume) or false,
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                text = 'Gathered',
                type = 'quantity',
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'gather',
                ref = itemName
            }
        end

        Event:Trigger("inventory_request_item_update", {playerID = self.playerID, itemName = itemName})
    end

end

function Quest:UpdateGatherTask(itemName, totalAmount)
    self:Debug("Updating gather task : itemName: ", itemName, " total amount ", totalAmount)
    if self.tasks.gather and self.tasks.gather[itemName] then

        local taskDetails = self.tasks.gather[itemName]

        if not (taskDetails.completed and taskDetails.consume) then
            if(taskDetails.consume) then
                --If it gets consumed, we have to check it seperately here to add to the total amount, instead of simply resetting it
                --it's not actually the total amount added in this case, but simply the total inventory amount
                local remainingRequired = self.tasks.gather[itemName].required - self.tasks.gather[itemName].obtained
                if totalAmount > remainingRequired then totalAmount = remainingRequired end
                self.tasks.gather[itemName].obtained = self.tasks.gather[itemName].obtained + totalAmount
            else
                if totalAmount > self.tasks.gather[itemName].required then
                    totalAmount = self.tasks.gather[itemName].required
                end
                self.tasks.gather[itemName].obtained = totalAmount
            end

            self:WriteTaskNotifications(self.tasks.gather[itemName])

            if(taskDetails.obtained >= taskDetails.required) then
                self.tasks.gather[itemName].completed = true
            else
                self.tasks.gather[itemName].completed = false
            end

            if(taskDetails.consume) then
                Event:Trigger('inventory_remove_items', {
                    playerID = self.playerID,
                    itemName = itemName,
                    amount = totalAmount
                })
            end

            self:TaskUpdated()
            return true
        end
    end
    return false
end

function Quest:IsGatherTaskCompleted(itemName)
    if not self.tasks.gather or not self.tasks.gather[itemName] then
        self:Debug("Gather task is not complete because quest does not have ", itemName, "as a gather task")
        return false
    end

    local status = self.tasks.gather[itemName]

    if status.obtained >= status.required then
        return true
    end
    return false
end

function Quest:SetupTalktoTasks()
    if not self.taskData.talkto then return false end

    for index, taskInfo in pairs(self.taskData.talkto) do
        index = tonumber(index)
        self.tasks.talkto = self.tasks.talkto or {}
        self.tasks.talkto[taskInfo.listenString] = {
            listenString = taskInfo.listenString,
            string = taskInfo.description, --todo: Make sure this doesn't error out when
            completed = false,
            index = self:GetNextTaskIndex(),
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                type = 'singular',
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'talkto',
                ref = taskInfo.listenString
            }
        end

    end

    self:SetupTaskListener('talkto')
end

function Quest:UpdateTalktoTask(listenString)
    self:Debug("Updating talkto task for: ", listenString)
    if self.tasks.talkto and self.tasks.talkto[listenString] then

        self:WriteTaskNotifications(self.tasks.talkto[listenString])
        self.tasks.talkto[listenString].completed = true
        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:IsTalktoTaskCompleted(listenString)
    if not self.tasks.talkto or not self.tasks.talkto[listenString] then
        self:Debug("Talkto task is not complete because quest does not have ", listenString, " as a talktoTask")
        return false
    end

    local status = self.tasks.talkto[listenString]
    return status.completed
end

function Quest:SetupEventTasks()
    if not self.taskData.event then return false end

    for index, taskInfo in pairs(self.taskData.event) do
        self.tasks.event = self.tasks.event or {}
        local compression_code = taskInfo.compression_code


        self.tasks.event[taskInfo.eventName] = {
            eventName = taskInfo.eventName,
            string = taskInfo.description,
            completed = false,
            index = self:GetNextTaskIndex(),
            compression_code = compression_code,


            notificationSettings = {
                type = 'singular',
                text = 'Event Completed'
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'event',
                ref = taskInfo.eventName
            }
        end

    end

    self:SetupTaskListener('event')
end

function Quest:UpdateEventTask(eventName)
    if self.tasks.event and self.tasks.event[eventName] then

        self:WriteTaskNotifications(self.tasks.event[eventName])

        self.tasks.event[eventName].completed = true
        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:EventTaskFailed(eventName)
    if self.tasks.event and self.tasks[eventName] then
        self:StageFailed()
    end
end

function Quest:IsEventTaskCompleted(eventName)
    if not self.tasks.event or not self.tasks.event[eventName] then
        self:Debug("Event task is not complete because quest does not have ", eventName, " as a event task")
        return false
    end
    return self.tasks.event[eventName].completed
end

function Quest:SetupReachLevelTask()
    if not self.taskData.reachLevel then return false end

    self.tasks.reachLevel = {}
    self.tasks.reachLevel[1] = {
        level = tonumber(self.taskData.reachLevel.level),
        string = self.taskData.reachLevel.description,
        completed = false,
        index = self:GetNextTaskIndex(),

        notificationSettings = {
            type = 'singular',
            text = 'Level ' .. self.taskData.reachLevel.level .. ' Reached'
        }
    }

    if Core:GetTotalLevel(self:GetHero()) >= self.tasks.reachLevel[1].level then
        self.tasks.reachLevel[1].completed = true
        self:TaskUpdated()
    end

    self:SetupTaskListener('reachLevel')
end

function Quest:UpdateReachLevelTask(level)
    if not self.tasks.reachLevel then return false end
    if level == nil then
        level = Core:GetHero(self.playerID):GetLevel()
    end

    if level >= self.tasks.reachLevel[1].level then
        self:WriteTaskNotifications(self.tasks.reachLevel[1])
        self.tasks.reachLevel[1].completed = true
        self:TaskUpdated()
        return true
    end
    return true
end

function Quest:IsReachLevelTaskCompleted()
    if not self.tasks.reachLevel then return true end
    return self.tasks.reachLevel[1].completed
end

function Quest:SetupReachTierTask()
    if not self.taskData.reachTier then return false end

    self.tasks.reachTier = {}
    self.tasks.reachTier[1] = {
        level = tonumber(self.taskData.reachTier.tier),
        string = self.taskData.reachTier.description,
        completed = false,
        index = self:GetNextTaskIndex(),

        notificationSettings = {
            type = 'singular',
            text = 'Tier ' .. self.taskData.reachTier.tier .. ' Reached'
        }
    }

    local hero = self:GetHero()
    local tier = tonumber(GetHandeKeyValue(hero, "ClassTier")) or 1

    if tier >= self.tasks.reachTier[1].tier then
        self.tasks.reachTier[1].completed = true
        self:TaskUpdated()
    end

    self:SetupTaskListener('reachTier')
end

function Quest:UpdateReachTierTask()
    if not self.tasks.reachTier then return false end

    local tier = tonumber(GetHandleKeyValue(self:GetHero(), "ClassTier")) or 1

    if tier >= self.tasks.reachTier[1].tier then

        self:WriteTaskNotifications(self.tasks.reachTier[1])

        self.tasks.reachTier[1].completed = true
        self:TaskUpdated()
        return true
    end
    return false
end

function Quest:IsReachTierTaskCompleted()
    if not self.tasks.reachTier then return true end
    return self.tasks.reachTier[1].completed
end

function Quest:SetupUseAbilityTask()
    if not self.taskData.useAbility then return false end

    for abilityName, taskInfo in pairs(self.taskData.useAbility) do

        self.tasks.useAbility = self.tasks.useAbility or {}

        self.tasks.useAbility[abilityName] = {
            abilityName = abilityName,
            string = taskInfo.description or ('DOTA_Tooltip_ability_' ..abilityName),
            required = taskInfo.amount,
            obtained = 0,
            killEnemy = taskInfo.killEnemy,
            killEnemyType = taskInfo.killEnemyType,
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                type = 'quantity',
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'useAbility',
                ref = abilityName
            }
        end
    end

    self:SetupTaskListener('useAbility')
end

function Quest:UpdateUseAbilityTask(abilityName, amount)
    amount = amount or 1

    if not self.tasks.useAbility or not self.tasks.useAbility[abilityName] then return false end

    if not self.tasks.useAbility[abilityName].completed then
        self.tasks.useAbility[abilityName].obtained = self.tasks.useAbility[abilityName].obtained + amount
    end
    if self.tasks.useAbility[abilityName].obtained >= self.tasks.useAbility[abilityName].required then
        self.tasks.useAbility[abilityName].completed = true
    end

    self:TaskUpdated()
    return true
end

function Quest:IsUseAbilityTaskCompleted(abilityName)
    if not self.tasks.useAbility or not self.tasks.useAbility[abilityName] then
        self:Debug("UseAbility task is not completed because ", abilityName, "is not configured as a use ability task")
        return false
    end
    local status = self.tasks.useAbility[abilityName]
    self:Debug("Returning ", status.completed)
    return status.completed
end


function Quest:SetupObtainGateKeyTask()
    if not self.taskData.obtainGateKey then return false end

    for gate_key, taskInfo in pairs(self.taskData.obtainGateKey) do

        self.tasks.obtainGateKey = self.tasks.obtainGateKey or {}

        self.tasks.obtainGateKey[gate_key] = {
            gate_key = gate_key,
            string = taskInfo.description or "",
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                type = 'singular',
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'obtainGateKey',
                ref = gate_key
            }
        end
        
        local hero = self:GetHero()
        if hero:HasGateKey(gate_key) then
            self.tasks.obtainGateKey[gate_key].completed = true
            self:TaskUpdated()
        end
    end

    self:SetupTaskListener('obtainGateKey')
end

function Quest:UpdateObtainGateKeyTask(gateKey)
    amount = amount or 1

    if not self.tasks.obtainGateKey or not self.tasks.obtainGateKey[gateKey] then return false end

    if not self.tasks.obtainGateKey[gateKey].completed then
        self.tasks.obtainGateKey[gateKey].completed = true
    end

    self:TaskUpdated()
    return true
end

function Quest:IsObtainGateKeyTaskCompleted(gateKey)
    if not self.tasks.obtainGateKey or not self.tasks.obtainGateKey[gateKey] then
        self:Debug("obtainGateKey task is not completed because ", gateKey, "is not configured as a use ability task")
        return false
    end
    local status = self.tasks.obtainGateKey[gateKey]
    self:Debug("Returning ", status.completed)
    return status.completed
end

function Quest:SetupCompleteQuestTask()
    if not self.taskData.completeQuest then return false end

    for questID, taskInfo in pairs(self.taskData.completeQuest) do

        self.tasks.completeQuest = self.tasks.completeQuest or {}

        self.tasks.completeQuest[questID] = {
            questID = questID,
            string = taskInfo.description or "",
            index = self:GetNextTaskIndex(),
            completed = false,
            compression_code = taskInfo.compression_code,

            notificationSettings = {
                type = 'singular',
            }
        }

        local taskID = taskInfo.taskID
        if taskID then
            self.taskIDs = self.taskIDs or {}
            self.taskIDs[taskID] = {
                taskType = 'completeQuest',
                ref = questID
            }
        end
        
        if QuestService:HasCompletedQuest(self.playerID, questID) then
            self.tasks.completeQuest[questID].completed = true
            self:TaskUpdated()
        end
    end

    self:SetupTaskListener('completeQuest')
end

function Quest:UpdateCompleteQuestTask(questID)
    questID = tostring(questID)
    if not self.tasks.completeQuest or not self.tasks.completeQuest[questID] then return false end

    if not self.tasks.completeQuest[questID].completed then
        self.tasks.completeQuest[questID].completed = true
    end

    self:TaskUpdated()
    return true
end

function Quest:IsCompleteQuestTaskCompleted(questID)
    if not self.tasks.completeQuest or not self.tasks.completeQuest[questID] then
        self:Debug("completeQuest task is not completed because ", questID, "is not configured as a use complete quest task")
        return false
    end
    local status = self.tasks.completeQuest[questID]
    self:Debug("Returning ", status.completed)
    return status.completed
end
