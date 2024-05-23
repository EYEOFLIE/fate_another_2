LinkLuaModifier("modifier_quest_master", "modifiers/modifier_ttr", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_quest_001", "modifiers/modifier_ttr", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_quest_c_scroll", "modifiers/modifier_ttr", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_quest_final", "modifiers/modifier_ttr", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_quest_beam_taken", "modifiers/modifier_ttr", LUA_MODIFIER_MOTION_NONE)

TutorialMode = TutorialMode or class({})

function TutorialMode:Initialize(hero)
	self.QUEST_1 = false
	self.QUEST_2 = false
	self.QUEST_3 = false
	self.QUEST_3a = false
	self.QUEST_3b = false
	self.QUEST_4 = false
	self.QUEST_4a = false
	self.QUEST_4b = false
	self.QUEST_5 = false
	self.QUEST_6 = false
	self.QUEST_7 = false
	self.QUEST_8 = false
	self.QUEST_9 = false
	self.QUEST_9a = false
	self.QUEST_9b = false
	self.QUEST_9c = false
	self.QUEST_10 = false
	self.QUEST_10a = false
	self.QUEST_10b = false
	self.QUEST_10c = false
	self.QUEST_10d = false
	self.QUEST_10e = false
	self.QUEST_11 = false
	self.QUEST_11a = false
	self.QUEST_11b = true
	self.QUEST_12 = false
	self.QUEST_12a = false
	self.QUEST_12b = false
	self.QUEST_13 = false
	self.QUEST_14 = false
	self.QUEST_14a = false
	self.QUEST_14b = false
	self.QUEST_15 = false
	self.QUEST_16 = false
	self.QUEST_16a = false
	self.QUEST_Fail = false

	self.bridge_loc = Vector(1600,2000,200)
	self.out_of_game = Vector(20000,20000,0)
	self.respawn_loc = Vector(-5400, 762, 376)
	self.left_loc = Vector(-4000,800,100)

	self.Hero = hero

	local heroname = hero:GetName()
	local abilities = {}

	giveUnitDataDrivenModifier(hero, hero, "round_pause", nil )
	self.QuestListener = CustomGameEventManager:RegisterListener("tutorial_fate_quest", function(id, ...)
	    Dynamic_Wrap(self, "QuestSelect")(self, ...) 
	end)

	Timers:CreateTimer(5.0, function()
		for i = 0,5 do 
			table.insert(abilities, i+1 , hero:GetAbilityByIndex(i):GetAbilityName())
		end
		for j = 0,5 do 
			table.insert(abilities, j+7 , hero.MasterUnit2:GetAbilityByIndex(j):GetAbilityName()) 
		end
		CustomNetTables:SetTableValue("tutorial", "ability",abilities)

		CustomNetTables:SetTableValue("tutorial", "hero",{heroname})
		print("Send Table Tutorial " .. heroname .. " !!!")
		CustomNetTables:SetTableValue("tutorial", "page", {page = 1})
		CustomNetTables:SetTableValue("tutorial", "questID", {questID = 0})

		self.herc = CreateUnitByName("npc_dota_hero_doom_bringer", self.out_of_game, true, nil, nil, hero:GetOpposingTeamNumber())
		LevelAllAbility(self.herc)
		for k = 0,5 do 
			self.herc:GetAbilityByIndex(k):SetLevel(5)
		end
		Attributes:ModifyBonuses(self.herc)
		giveUnitDataDrivenModifier(hero, self.herc, "round_pause", nil )
		self.herc:AddEffects(EF_NODRAW)

		self.medusa = CreateUnitByName("npc_dota_hero_templar_assassin", self.out_of_game, true, nil, nil, hero:GetOpposingTeamNumber())
		self.medusa:AddAbility("medusa_bellerophon_upgrade")
		self.medusa:SwapAbilities("medusa_bellerophon_upgrade", "medusa_bellerophon", true, false)
		self.medusa:RemoveAbility("medusa_bellerophon")
		LevelAllAbility(self.medusa)
		for l = 0,5 do 
			self.medusa:GetAbilityByIndex(l):SetLevel(5)
		end
		Attributes:ModifyBonuses(self.medusa)
		giveUnitDataDrivenModifier(hero, self.medusa, "round_pause", nil )
		self.medusa:AddEffects(EF_NODRAW)	

		self.sasaki = CreateUnitByName("npc_dota_hero_juggernaut", self.out_of_game, true, nil, nil, hero:GetOpposingTeamNumber())
		self.sasaki:AddAbility("sasaki_tsubame_gaeshi_upgrade")
		self.sasaki:SwapAbilities("sasaki_tsubame_gaeshi_upgrade", "sasaki_tsubame_gaeshi", true, false)
		self.sasaki:RemoveAbility("sasaki_tsubame_gaeshi")
		LevelAllAbility(self.sasaki)
		self.sasaki.IsGanryuAcquired = true
		for m = 0,5 do 
			self.sasaki:GetAbilityByIndex(m):SetLevel(5)
		end
		Attributes:ModifyBonuses(self.sasaki)
		giveUnitDataDrivenModifier(hero, self.sasaki, "round_pause", nil )
		self.sasaki:AddEffects(EF_NODRAW)

		self.scat = CreateUnitByName("npc_dota_hero_monkey_king", self.out_of_game, true, nil, nil, hero:GetTeamNumber())
		LevelAllAbility(self.scat)
		for n = 0,5 do 
			self.scat:GetAbilityByIndex(n):SetLevel(5)
		end
		Attributes:ModifyBonuses(self.scat)
		giveUnitDataDrivenModifier(hero, self.scat, "round_pause", nil )
		self.scat:AddEffects(EF_NODRAW)

		for o = 1, 23 do 
			self.herc:HeroLevelUp(true)
			self.medusa:HeroLevelUp(true)
			self.sasaki:HeroLevelUp(true)
		end
	end)
end

function TutorialMode:QuestSelect(args)
	local playerId = args.playerId
    local hero = EntIndexToHScript(args.servant) 
    self.questID = args.questID

    self:QuestInitialize(hero)
    if hero:GetName() == "npc_dota_hero_legion_commander" then 
    	if not hero:HasModifier("modifier_quest_001") then
			hero:AddNewModifier(hero, nil, "modifier_quest_001", {})
		end
		self:ArtoriaQuest(hero)
	end

end

function TutorialMode:ArtoriaQuest(hero)
	if self.questID == 1 and self.QUEST_1 == false then 
    	self:Quest1Start(hero)
    elseif self.questID == 2 and self.QUEST_2 == false then 
    	self:Quest2Start(hero)
    elseif self.questID == 3 and self.QUEST_3 == false then 
    	self:Quest3Start(hero)
    elseif self.questID == 4 and self.QUEST_4 == false then 
    	self:Quest4Start(hero)
    	Timers:CreateTimer(3, function()
			if self.QUEST_4 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 8.0
		end)
    elseif self.questID == 5 and self.QUEST_5 == false then 
    	self:Quest5Start(hero)
    	Timers:CreateTimer(25, function()
			if self.QUEST_5 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 25
		end)
    elseif self.questID == 6 and self.QUEST_6 == false then 
    	self:Quest6Start(hero)
    	Timers:CreateTimer(25, function()
			if self.QUEST_6 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 25
		end)
    elseif self.questID == 7 and self.QUEST_7 == false then 
    	self:Quest7Start(hero)
    	Timers:CreateTimer(20, function()
			if self.QUEST_7 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 20.0
		end)
    elseif self.questID == 8 and self.QUEST_8 == false then 
    	self:Quest8Start(hero)
    	Timers:CreateTimer(5, function()
			if self.QUEST_8 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 7.0
		end)
    elseif self.questID == 9 and self.QUEST_9 == false then 
    	self:Quest9Start(hero)
    	Timers:CreateTimer(10, function()
			if self.QUEST_9 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 12.0
		end)
    elseif self.questID == 10 and self.QUEST_10 == false then 
    	self:Quest10Start(hero)
    	Timers:CreateTimer(20, function()
			if self.QUEST_10 == false and self.QUEST_Fail == false then
				self:QuestFail(hero)
			else
				return nil
			end
			return 20.0
		end)
    elseif self.questID == 11 and self.QUEST_11 == false then 
    	self:Quest11Start(hero)
    	Timers:CreateTimer(5, function()
			if self.QUEST_11 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 7.0
		end)
    elseif self.questID == 12 and self.QUEST_12 == false then 
    	self:Quest12Start(hero)
    	Timers:CreateTimer(5, function()
			if self.QUEST_12 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 8.0
		end)
    elseif self.questID == 13 and self.QUEST_13 == false then
    	self:Quest13Start(hero)
    	Timers:CreateTimer(3, function()
			if self.QUEST_13 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 6.0
		end)
    elseif self.questID == 14 and self.QUEST_14 == false then 
    	self:Quest14Start(hero)
    	Timers:CreateTimer(5, function()
			if self.QUEST_14 == false and self.QUEST_Fail == false then 
				self:QuestFail(hero)
			else
				return nil
			end
			return 8.0
		end)
    elseif self.questID == 15 and self.QUEST_15 == false then 
    	self:Quest15Start(hero)
    elseif self.questID == 16 and self.QUEST_15 == false then 
    	self.QUEST_15 = true
    	print('Quest 15 Finish')
    	CustomNetTables:SetTableValue("tutorial", "subquest", {quest15a = true})

		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 45})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 16})
		end)
    elseif self.questID == 17 and self.QUEST_15 == true and self.QUEST_16 == false then 
    	self:Quest16Start(hero)
    end
end

function TutorialMode:QuestInitialize(hero)
	if self.questID == 1 and self.QUEST_1 == false then
		for i = 1,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 2 and self.QUEST_2 == false then 
		hero:GetAbilityByIndex(0):SetActivated(false)
		hero:GetAbilityByIndex(0):EndCooldown()
		for i = 2,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 3 and self.QUEST_3 == false then 
		for i = 0,1 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
		for j = 3,5 do 
			hero:GetAbilityByIndex(j):SetActivated(false)
			hero:GetAbilityByIndex(j):EndCooldown()
		end
	elseif self.questID == 4 and self.QUEST_4 == false then 
		for i = 0,4 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
		hero:GetAbilityByIndex(5):SetActivated(true)
		hero:GetAbilityByIndex(5):EndCooldown()
	elseif self.questID == 5 and self.QUEST_5 == false then 
		for i = 0,5 do 
			if hero:GetAbilityByIndex(i):GetAbilityName() ~= "saber_strike_air" then
				hero:GetAbilityByIndex(i):SetActivated(false)
				hero:GetAbilityByIndex(i):EndCooldown()
			end
		end
	elseif self.questID == 6 and self.QUEST_6 == false then 
		for i = 0,1 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
		for j = 3,5 do 
			hero:GetAbilityByIndex(j):SetActivated(false)
			hero:GetAbilityByIndex(j):EndCooldown()
		end
	elseif self.questID == 8 and self.QUEST_8 == false then 
		for i = 0,5 do 
		hero:GetAbilityByIndex(i):SetActivated(false)
		hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 9 and self.QUEST_9 == false then 
		hero:GetAbilityByIndex(0):SetActivated(false)
		hero:GetAbilityByIndex(0):EndCooldown()
		for i = 2,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 10 and self.QUEST_10 == false then
		for i = 0,4 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 11 and self.QUEST_11 == false then
		for i = 0,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 12 and self.QUEST_12 == false then
		for i = 0,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 13 and self.QUEST_13 == false then
		for i = 0,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	elseif self.questID == 14 and self.QUEST_14 == false then
		for i = 0,5 do 
			hero:GetAbilityByIndex(i):SetActivated(false)
			hero:GetAbilityByIndex(i):EndCooldown()
		end
	end
	for j = 6,12 do 
		if hero:GetAbilityByIndex(j) ~= nil then
			if not hero:GetAbilityByIndex(j):IsActivated() then 
				hero:GetAbilityByIndex(j):SetActivated(false)
				hero:GetAbilityByIndex(j):EndCooldown()
			end
		end
	end

	if self.questID == 17 and self.QUEST_16 == false then
	else
		hero:FindItemInInventory("item_blink_scroll"):SetActivated(false)
	end
	hero:SetHealth(hero:GetMaxHealth())
	hero:SetMana(hero:GetMaxMana())
	hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
end

function TutorialMode:QuestEnd(hero)
	for i = 0,5 do
		hero:GetAbilityByIndex(i):SetActivated(true)
		hero:GetAbilityByIndex(i):EndCooldown()
	end
	for j = 0,5 do
		hero.MasterUnit:GetAbilityByIndex(j):SetActivated(true)
		hero.MasterUnit:GetAbilityByIndex(j):EndCooldown()
	end
	hero:FindItemInInventory("item_blink_scroll"):SetActivated(true)
	hero:SetHealth(hero:GetMaxHealth())
	hero:SetMana(hero:GetMaxMana())
	giveUnitDataDrivenModifier(hero, hero, "round_pause", nil)
	if not self.herc:IsAlive() then 
		self.herc:SetRespawnPosition(self.out_of_game)
	    self.herc:RespawnHero(false, false) 
	end

	if not self.medusa:IsAlive() then 
		self.medusa:SetRespawnPosition(self.out_of_game)
	    self.medusa:RespawnHero(false, false) 
	end

	if not self.sasaki:IsAlive() then 
		self.sasaki:SetRespawnPosition(self.out_of_game)
	    self.sasaki:RespawnHero(false, false) 
	end

	if not self.scat:IsAlive() then 
		self.scat:SetRespawnPosition(self.out_of_game)
	    self.scat:RespawnHero(false, false) 
	end

	if not self.herc:HasModifier("round_pause") then 
		for k = 0,5 do
			self.herc:GetAbilityByIndex(k):EndCooldown()
		end
		self.herc:SetHealth(self.herc:GetMaxHealth())
		self.herc:SetMana(self.herc:GetMaxMana())
		giveUnitDataDrivenModifier(hero, self.herc, "round_pause", nil)
		self.herc:SetAbsOrigin(self.out_of_game)
		self.herc:AddEffects(EF_NODRAW)
	end
	if not self.medusa:HasModifier("round_pause") then 
		for l = 0,5 do
			self.medusa:GetAbilityByIndex(l):EndCooldown()
		end
		self.medusa:SetHealth(self.medusa:GetMaxHealth())
		self.medusa:SetMana(self.medusa:GetMaxMana())
		giveUnitDataDrivenModifier(hero, self.medusa, "round_pause", nil)
		self.medusa:SetAbsOrigin(self.out_of_game)
		self.medusa:AddEffects(EF_NODRAW)
	end
	if not self.sasaki:HasModifier("round_pause") then 
		for m = 0,5 do
			self.sasaki:GetAbilityByIndex(m):EndCooldown()
		end
		self.sasaki:SetHealth(self.sasaki:GetMaxHealth())
		giveUnitDataDrivenModifier(hero, self.sasaki, "round_pause", nil)
		self.sasaki:SetAbsOrigin(self.out_of_game)
		self.sasaki:AddEffects(EF_NODRAW)
	end
	if not self.scat:HasModifier("round_pause") then 
		for n = 0,5 do
			self.scat:GetAbilityByIndex(n):EndCooldown()
		end
		self.scat:SetHealth(self.scat:GetMaxHealth())
		self.scat:SetMana(self.scat:GetMaxMana())
		giveUnitDataDrivenModifier(hero, self.scat, "round_pause", nil)
		self.scat:SetAbsOrigin(self.out_of_game)
		self.scat:AddEffects(EF_NODRAW)
	end
end

function TutorialMode:QuestFailThink(hero)
	if hero:IsAlive() then 
		self:QuestEnd(hero)
	else
		hero:SetRespawnPosition(self.respawn_loc)
	    hero:RespawnHero(false, false) 
	    hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
	    self:QuestEnd(hero)
	end
end

function TutorialMode:QuestFail(hero)
	self.QUEST_Fail = true 
	if self.questID == 1 and self.QUEST_1 == false and self.QUEST_Fail == true then
		Timers:CreateTimer(2.0, function()
	        self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest1Start(hero)
		    	self.QUEST_Fail = false
		    end)
		end)
    elseif self.questID == 2 and self.QUEST_2 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	        self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest2Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
    elseif self.questID == 3 and self.QUEST_3 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest3Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 4 and self.QUEST_4 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	        self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
		    	self:Quest4Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 5 and self.QUEST_5 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	        self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest5Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 6 and self.QUEST_6 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	        self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest6Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 7 and self.QUEST_7 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest7Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 8 and self.QUEST_8 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest8Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 9 and self.QUEST_9 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest9Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 10 and self.QUEST_10 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest10Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
    elseif self.questID == 11 and self.QUEST_11 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest11Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 12 and self.QUEST_12 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest12Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 13 and self.QUEST_13 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest13Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 14 and self.QUEST_14 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest14Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 15 and self.QUEST_15 == false and self.QUEST_Fail == true then 
    	Timers:CreateTimer(2.0, function()
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest15Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
	elseif self.questID == 17 and self.QUEST_16 == false and not hero:IsAlive() and self.herc:IsAlive() then 
		print('Quest 16 Restart')
    	Timers:CreateTimer(2.0, function()
    		if self.QUEST_16 == true then 
    			self.FinishTutorial(hero)
    			return 
    		end
	    	self:QuestFailThink(hero)
	        Timers:CreateTimer(2.0, function()
	        	self:QuestInitialize(hero)
		    	self:Quest16Start(hero)
		    	self.QUEST_Fail = false
		    end)
	    end)
    end
end

function TutorialMode:Quest1Start(hero)
	if self.questID > 1 or self.QUEST_1 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then  -- Invisible Air
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() + Vector(800,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)
	end
end

function TutorialMode:Quest2Start(hero)
	if self.questID > 2 or self.QUEST_2 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Caliburn
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() + Vector(200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)
	end
end

function TutorialMode:Quest3Start(hero)
	if self.questID > 3 or self.QUEST_3 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Avalon Counter
		self.QUEST_3a = false
		self.QUEST_3b = false
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() + Vector(200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)

		local abilityindex = self.herc:FindAbilityByName("heracles_nine_lives"):entindex()
		local ninelives = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
	 		AbilityIndex = abilityindex, --Optional.  Only used when casting abilities
	 		Position = hero:GetAbsOrigin(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.5, function()
			ExecuteOrderFromTable(ninelives)
		end)
	end
end

function TutorialMode:Quest4Start(hero)
	if self.questID > 4 or self.QUEST_4 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Excalibur Hit
		self.QUEST_4a = false
		self.QUEST_4b = false
		FindClearSpaceForUnit(hero, self.left_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() + Vector(800,800,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)
		self.herc:AddNewModifier(self.herc, nil, "modifier_quest_beam_taken", {})

		local walkex = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	 		Position = self.herc:GetAbsOrigin() + Vector(0,-1200,0), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(walkex)
		end)
	end
end

function TutorialMode:Quest5Start(hero)
	if self.questID > 5 or self.QUEST_5 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then  -- Strike Air Upgrade
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		hero:RemoveModifierByName("round_pause")

		if not self.quest5a_signal then
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest5a = false})
			self.quest5a_signal = true
		end

		if hero.MasterUnit2:GetMana() < 20 then
			CreateUITimer("Next Holy Grail's Blessing", 1, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 1,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 20)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 20)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    	CustomNetTables:SetTableValue("mode", "notify_mana",{notify = true})
			    end}
			)
		end
	end
end

function TutorialMode:Quest6Start(hero)
	if self.questID > 6 or self.QUEST_6 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then  -- Combo
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		hero:RemoveModifierByName("round_pause")

		if not self.quest6a_signal then
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest6a = false})
			self.quest6a_signal = true
		end

		if hero:GetLevel() < 9 then
			for i = 1,9 - hero:GetLevel() do 
				hero:HeroLevelUp(true)
			end
		end

		if hero.MasterUnit2:GetMana() < 20 then
			CreateUITimer("Next Holy Grail's Blessing", 1, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 1,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 20)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 20)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    	CustomNetTables:SetTableValue("mode", "notify_mana",{notify = true})
			    end}
			)
		end
	end
end

function TutorialMode:Quest7Start(hero)
	if self.questID > 7 or self.QUEST_7 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then  -- Seal 4
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		hero:RemoveModifierByName("round_pause")
		hero:SetMana(0)
		hero.MasterUnit:AddNewModifier(hero, nil, "modifier_quest_master", {})

		if not self.quest7a_signal then
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest7a = false})
			self.quest7a_signal = true
		end

		if hero.MasterUnit:GetMana() < 20 then
			CreateUITimer("Next Holy Grail's Blessing", 5, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 5,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 20)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 20)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    end}
			)
		end
	end
end

function TutorialMode:Quest8Start(hero)
	if self.questID > 8 or self.QUEST_8 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Seal 3
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() +Vector(200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)

		if not self.quest8a_signal then
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest8a = false})
			self.quest8a_signal = true
		end

		local abilityindex = self.herc:FindAbilityByName("heracles_nine_lives"):entindex()
		local ninelives = {
			UnitIndex = self.herc:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, --Optional.  Only used when casting abilities
 			Position = hero:GetAbsOrigin(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(ninelives)
		end)

		if hero.MasterUnit:GetMana() < 20 then
			CreateUITimer("Next Holy Grail's Blessing", 5, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 5,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 20)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 20)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    end}
			)
		end
	end
end

function TutorialMode:Quest9Start(hero)
	if self.questID > 9 or self.QUEST_9 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Seal 2 caliburn reset caliburn
		self.QUEST_9a = false
		self.QUEST_9b = false
		self.QUEST_9c = false
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() +Vector(200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)

		if hero.MasterUnit:GetMana() < 5 then
			CreateUITimer("Next Holy Grail's Blessing", 5, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 5,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 15)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 15)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    end}
			)
		end
	end
end

function TutorialMode:Quest10Start(hero)
	if self.questID > 10 or self.QUEST_10 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then  -- Seal 1 2 Excalibur
		self.QUEST_10a = false
		self.QUEST_10b = false
		self.QUEST_10c = false
		self.QUEST_10d = false
		self.QUEST_10e = false
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() +Vector(200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)
		hero:SetMana(800)

		if hero.MasterUnit:GetMana() < 5 then
			CreateUITimer("Next Holy Grail's Blessing", 5, "ten_min_timer")
			Timers:CreateTimer('round_10min_bonus', {
		        endTime = 5,
		        callback = function()
		        	Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})
					hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
			        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 15)
			        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
			        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 15)
			        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			    end}
			)
		end
	end
end

function TutorialMode:Quest11Start(hero)
	if self.questID > 11 or self.QUEST_11 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- C interrupt TG
		self.QUEST_11a = false
		self.QUEST_11b = true
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.sasaki, hero:GetAbsOrigin() + Vector(-200,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.sasaki:RemoveModifierByName("round_pause")
		self.sasaki:RemoveEffects(EF_NODRAW)


		if not hero:HasItemInInventory("item_c_scroll") then 
			self.c_scroll = CreateItem("item_c_scroll", hero, hero)
			hero:AddItem(self.c_scroll)
			self.c_scroll = hero:FindItemInInventory("item_c_scroll")
		end
		self.c_scroll:EndCooldown()


		self.sasaki:AddNewModifier(hero, nil, "modifier_quest_c_scroll", {})

		local abilityindex = self.sasaki:GetAbilityByIndex(5):entindex()
		local tg = {
			UnitIndex = self.sasaki:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
 			AbilityIndex = self.sasaki:GetAbilityByIndex(5):entindex(), --Optional.  Only used when casting abilities
 			TargetIndex = hero:entindex(), --Optional.  Only used when targeting the ground
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(tg)
		end)
	end
end

function TutorialMode:Quest12Start(hero)
	if self.questID > 12 or self.QUEST_12 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- B + A block damage from belle
		self.QUEST_12a = false
		self.QUEST_12b = false
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.medusa, hero:GetAbsOrigin() + Vector(-900,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.medusa:RemoveModifierByName("round_pause")
		self.medusa:RemoveEffects(EF_NODRAW)

		if self.c_scroll then 
			hero:RemoveItem(self.c_scroll)
		end


		if not hero:HasItemInInventory("item_b_scroll") then 
			self.b_scroll = CreateItem("item_b_scroll", hero, hero)
			hero:AddItem(self.b_scroll)
			self.b_scroll = hero:FindItemInInventory("item_b_scroll")
		end
		self.b_scroll:EndCooldown()


		if not hero:HasItemInInventory("item_a_scroll") then 
			self.a_scroll = CreateItem("item_a_scroll", hero, hero)
			hero:AddItem(self.a_scroll)
			self.a_scroll = hero:FindItemInInventory("item_a_scroll")
		end
		self.a_scroll:EndCooldown()


		local abilityindex = self.medusa:GetAbilityByIndex(5):entindex()
		local belle = {
			UnitIndex = self.medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, 
 			Position = hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(belle)
		end)
	end
end

function TutorialMode:Quest13Start(hero)
	if self.questID > 13 or self.QUEST_13 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- S  root medusa
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.medusa, hero:GetAbsOrigin() + Vector(-500,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.medusa:RemoveModifierByName("round_pause")
		self.medusa:RemoveEffects(EF_NODRAW)

		if self.c_scroll then 
			hero:RemoveItem(self.c_scroll)
		end

		if self.b_scroll then 
			hero:RemoveItem(self.b_scroll)
		end

		if self.a_scroll then 
			hero:RemoveItem(self.a_scroll)
		end


		if not hero:HasItemInInventory("item_s_scroll") then 
			self.s_scroll = CreateItem("item_s_scroll", hero, hero)
			hero:AddItem(self.s_scroll)
			self.s_scroll = hero:FindItemInInventory("item_s_scroll")
		end
		self.s_scroll:EndCooldown()

		local move = {
			UnitIndex = self.medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
 			Position = self.medusa:GetAbsOrigin() + Vector(-800,0,0), 
		}
		Timers:CreateTimer(0.01, function()
			ExecuteOrderFromTable(move)
		end)
	end
end

function TutorialMode:Quest14Start(hero)
	if self.questID > 14 or self.QUEST_14 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- link scathac : reduce damage from belle
		self.QUEST_14a = false
		self.QUEST_14b = false
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.medusa, hero:GetAbsOrigin() + Vector(-500,0,0), true)
		FindClearSpaceForUnit(self.scat, hero:GetAbsOrigin() + Vector(500,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.medusa:RemoveModifierByName("round_pause")
		self.medusa:RemoveEffects(EF_NODRAW)
		self.scat:RemoveModifierByName("round_pause")
		self.scat:RemoveEffects(EF_NODRAW)

		if self.c_scroll then 
			hero:RemoveItem(self.c_scroll)
		end

		if self.b_scroll then 
			hero:RemoveItem(self.b_scroll)
		end

		if self.a_scroll then 
			hero:RemoveItem(self.a_scroll)
		end

		if self.s_scroll then 
			hero:RemoveItem(self.s_scroll)
		end


		if not hero:HasItemInInventory("item_spirit_link") then 
			self.link_scroll = CreateItem("item_spirit_link", hero, hero)
			hero:AddItem(self.link_scroll)
			self.link_scroll = hero:FindItemInInventory("item_spirit_link")
		end
		self.link_scroll:EndCooldown()


		local abilityindex = self.medusa:GetAbilityByIndex(5):entindex()
		local belle = {
			UnitIndex = self.medusa:entindex(), 
 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
 			AbilityIndex = abilityindex, 
 			Position = hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.2, function()
			ExecuteOrderFromTable(belle)
		end)
	end
end

function TutorialMode:Quest15Start(hero)
	if self.questID > 15 or self.QUEST_15 == true then return end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- Camera Distance 1900
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		CustomNetTables:SetTableValue("tutorial", "subquest", {quest15a = false})

		if self.c_scroll then 
			hero:RemoveItem(self.c_scroll)
		end

		if self.b_scroll then 
			hero:RemoveItem(self.b_scroll)
		end

		if self.a_scroll then 
			hero:RemoveItem(self.a_scroll)
		end

		if self.s_scroll then 
			hero:RemoveItem(self.s_scroll)
		end

		if self.link_scroll then 
			hero:RemoveItem(self.link_scroll)
		end
	end
end

function TutorialMode:Quest16Start(hero)
	if self.questID > 17 or self.QUEST_16 == true then
		self:FinishTutorial(hero)
	 	return 
	end

	if hero:GetName() == "npc_dota_hero_legion_commander" then -- link scathac : reduce damage from belle
		FindClearSpaceForUnit(hero, self.bridge_loc, true)
		hero:AddNewModifier(hero, hero, "modifier_camera_follow", {duration = 1.0})
		FindClearSpaceForUnit(self.herc, hero:GetAbsOrigin() + Vector(500,0,0), true)
		hero:RemoveModifierByName("round_pause")
		self.herc:RemoveModifierByName("round_pause")
		self.herc:RemoveEffects(EF_NODRAW)
		self.herc:FindAbilityByName("attribute_bonus_custom"):SetLevel(7)

		local lvl = 24 - hero:GetLevel() 
		for i = 1, lvl do 
			hero:HeroLevelUp(true)
		end

		if not self.herc:HasItemInInventory("item_s_scroll") then 
			self.herc_s_scroll = CreateItem("item_s_scroll", hero, hero)
			self.herc:AddItem(self.herc_s_scroll)
			self.herc_s_scroll = self.herc:FindItemInInventory("item_s_scroll")
		end
		--self.herc_s_scroll:EndCooldown()

		if not self.herc:HasItemInInventory("item_c_scroll") then 
			self.herc_c_scroll = CreateItem("item_c_scroll", hero, hero)
			self.herc:AddItem(self.herc_c_scroll)
			self.herc_c_scroll = self.herc:FindItemInInventory("item_c_scroll")
		end
		--self.herc_c_scroll:EndCooldown()

		if not self.herc:HasItemInInventory("item_b_scroll") then 
			self.herc_b_scroll = CreateItem("item_b_scroll", hero, hero)
			self.herc:AddItem(self.herc_b_scroll)
			self.herc_b_scroll = self.herc:FindItemInInventory("item_b_scroll")
		end
		--self.herc_b_scroll:EndCooldown()

		if not self.herc:HasItemInInventory("item_a_scroll") then 
			self.herc_a_scroll = CreateItem("item_a_scroll", hero, hero)
			self.herc:AddItem(self.herc_a_scroll)
			self.herc_a_scroll = self.herc:FindItemInInventory("item_a_scroll")
		end
		--self.herc_a_scroll:EndCooldown()

		if not self.herc:HasItemInInventory("item_condensed_mana_essence") then 
			self.herc_pot = CreateItem("item_condensed_mana_essence", hero, hero)
			self.herc:AddItem(self.herc_pot)
			self.herc_pot = self.herc:FindItemInInventory("item_condensed_mana_essence")
		end
		--self.herc_pot:EndCooldown()

		if not blink_scroll then 
			blink_scroll = CreateItem("item_blink_scroll", nil, nil)
			self.herc:AddItem(blink_scroll)
		end
		if not self.herc:HasModifier("modifier_quest_final") then
			self.herc:AddNewModifier(self.herc, nil, "modifier_quest_final", {})
		end
	end
end



function TutorialMode:QuestFinish(hero)

	if self.QUEST_1 == false and self.questID == 1 and hero:IsAlive() then
		self.QUEST_1 = true 
		self:QuestEnd(hero)
		print('Quest 1 Finish')
		Timers:CreateTimer(0.5, function()
			if self.QUEST_1 == true then 
				CustomNetTables:SetTableValue("tutorial", "page", {page = 7})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 1})
			end
		end)
	elseif self.QUEST_2 == false and self.questID == 2 and hero:IsAlive() then
		self.QUEST_2 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(0.5, function()
			if self.QUEST_2 == true then 
				Timers:CreateTimer(1.7, function()
					CustomNetTables:SetTableValue("tutorial", "page", {page = 9})
					CustomNetTables:SetTableValue("tutorial", "questID", {questID = 2})
				end)
			end
		end)
	elseif self.QUEST_3 == false and self.questID == 3 and hero:IsAlive() then 
		self.QUEST_3 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 11})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 3})
		end)
	elseif self.QUEST_4 == false and self.questID == 4 and hero:IsAlive() then 
		self.QUEST_4 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(1.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 13})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 4})
		end)
	elseif self.QUEST_5 == false and self.questID == 5 and hero:IsAlive() then 
		self.QUEST_5 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 17})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 5})
		end)
	elseif self.QUEST_6 == false and self.questID == 6 and hero:IsAlive() then 
		self.QUEST_6 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 21})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 6})
		end)
	elseif self.QUEST_7 == false and self.questID == 7 and hero:IsAlive() then 
		self.QUEST_7 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 26})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 7})
		end)
	elseif self.QUEST_8 == false and self.questID == 8 and hero:IsAlive() then 
		self.QUEST_8 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(1.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 28})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 8})
		end)
	elseif self.QUEST_9 == false and self.questID == 9 and hero:IsAlive() then 
		self.QUEST_9 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 30})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 9})
		end)
	elseif self.QUEST_10 == false and self.questID == 10 and hero:IsAlive() then 
		self.QUEST_10 = true 
		Timers:CreateTimer(3.0, function()
			self:QuestEnd(hero)
			Timers:CreateTimer(2.0, function()
				CustomNetTables:SetTableValue("tutorial", "page", {page = 32})
				CustomNetTables:SetTableValue("tutorial", "questID", {questID = 10})
			end)
		end)
	elseif self.QUEST_11 == false and self.questID == 11 and hero:IsAlive() then 
		self.QUEST_11 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 35})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 11})
		end)
	elseif self.QUEST_12 == false and self.questID == 12 and hero:IsAlive() then 
		self.QUEST_12 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 37})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 12})
		end)
	elseif self.QUEST_13 == false and self.questID == 13 and hero:IsAlive() then 
		self.QUEST_13 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 39})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 13})
		end)
	elseif self.QUEST_14 == false and self.questID == 14 and hero:IsAlive() then 
		self.QUEST_14 = true 
		self:QuestEnd(hero)
		Timers:CreateTimer(2.0, function()
			CustomNetTables:SetTableValue("tutorial", "page", {page = 41})
			CustomNetTables:SetTableValue("tutorial", "questID", {questID = 14})
		end)
	elseif not hero:IsAlive() then
		self:QuestFail(hero)
	end
end

function TutorialMode:FinishTutorial(hero)
	if self.QUEST_16 == true and hero:IsAlive() then
		if not self.FinishState then
			giveUnitDataDrivenModifier(hero, hero, "round_pause", nil)
			GameRules:SendCustomMessage("Tutorial Mode Finish!",0,0)
			GameRules:SetSafeToLeave( true )
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			self.FinishState = true 
		end
	else
		self:QuestFail(hero)
	end
end

------------------------------------------------------------
modifier_quest_beam_taken = class({})

function modifier_quest_beam_taken:IsHidden() return true end

function modifier_quest_beam_taken:GetAttributes()
	return {MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_quest_beam_taken:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_quest_beam_taken:OnTakeDamage(args)
	local attacker = args.attacker
	local caster = self:GetParent()
	if TutorialMode.QUEST_4 == false and TutorialMode.questID == 4 then
		if attacker:GetName() == "npc_dota_hero_legion_commander" then 
			TutorialMode.QUEST_4b = true 
		end
	end
end

------------------------------------------------------------
modifier_quest_master = class({})

function modifier_quest_master:OnCreated(args)
	self.TutorialMode = TutorialMode()
end

function modifier_quest_master:IsHidden() return true end

function modifier_quest_master:DeclareFunctions()
	return {  MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_quest_master:GetAttributes()
	return {MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_quest_master:OnAbilityExecuted(args)
	local caster = self:GetParent()
	local hero = caster.HeroUnit
	if self.TutorialMode.QUEST_7 == false and self.TutorialMode.questID == 7 then
		if args.ability:GetAbilityName() == "cmd_seal_4" then 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest7a = true})
			self.TutorialMode:QuestFinish(hero)
		end
	elseif self.TutorialMode.QUEST_8 == false and self.TutorialMode.questID == 8 then
		if args.ability:GetAbilityName() == "cmd_seal_3" then 
			Timers:CreateTimer(1.0, function()
				CustomNetTables:SetTableValue("tutorial", "subquest", {quest8a = true})
				self.TutorialMode:QuestFinish(hero)
			end)
		end
	elseif TutorialMode.QUEST_9 == false and TutorialMode.questID == 9 then
		if args.ability:GetAbilityName() == "cmd_seal_2" then 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest9a = true})
			TutorialMode.QUEST_9b = true 
		end
	elseif TutorialMode.QUEST_10 == false and TutorialMode.questID == 10 then
		if args.ability:GetAbilityName() == "cmd_seal_1" then 
			TutorialMode.QUEST_10b = true 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest10a = true, quest10b = false})
			Timers:CreateTimer(20, function()
				TutorialMode.QUEST_10b = false 
			end)
		elseif args.ability:GetAbilityName() == "cmd_seal_2" then 
			TutorialMode.QUEST_10c = true 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest10b = true, quest10c = false})
			Timers:CreateTimer(8, function()
				TutorialMode.QUEST_10c = false 
			end)
		elseif args.ability:GetAbilityName() == "cmd_seal_4" then 
			TutorialMode.QUEST_10d = true 
			CustomNetTables:SetTableValue("tutorial", "subquest", {quest10c = true})
			Timers:CreateTimer(8, function()
				TutorialMode.QUEST_10d = false 
			end)
		end
	end
end

------------------------------------------------------------
modifier_quest_c_scroll = class({})

function modifier_quest_c_scroll:IsHidden() return true end

function modifier_quest_c_scroll:GetAttributes()
	return {MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_quest_c_scroll:DeclareFunctions()
	return {  MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_quest_c_scroll:OnAbilityExecuted(args)
	local caster = self:GetParent()
	if TutorialMode.QUEST_11 == false and TutorialMode.questID == 11 then
		if args.ability:GetAbilityName() == caster:GetAbilityByIndex(5):GetAbilityName() and args.ability:GetCursorTarget():GetName() == "npc_dota_hero_legion_commander" then 
			TutorialMode.QUEST_11b = false 
		end
	end
end

-----------------------------------------------------------

modifier_quest_001 = class({})
-- Artoria Quest
function modifier_quest_001:OnCreated()
	self.TutorialMode = TutorialMode()
	if self:GetParent():GetName() ~= "npc_dota_hero_legion_commander" then 
		self:Destroy()
	end
end

function modifier_quest_001:OnDestroy()
	if self:GetParent():GetName() == "npc_dota_hero_legion_commander" then 
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_quest_001", {})
	end
end

function modifier_quest_001:OnDeath()
	if self:GetParent():GetName() == "npc_dota_hero_legion_commander" and not self:GetParent():IsAlive() then 
		self.TutorialMode:QuestFail(self:GetParent())
	end
end

function modifier_quest_001:CheckState()
	local state = {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true}
	if self.TutorialMode.questID == 17 and self.TutorialMode.QUEST_15 == true and self.TutorialMode.QUEST_16 == false then 
		state = {[MODIFIER_STATE_ROOTED] = false, [MODIFIER_STATE_DISARMED] = false}
	end
    return state
end

function modifier_quest_001:IsHidden() return true end

function modifier_quest_001:GetAttributes()
	return {MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_quest_001:RemoveOnDeath()
	return false 
end

function modifier_quest_001:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_quest_001:OnTakeDamage(args)
	local attacker = args.attacker
	local caster = self:GetParent()
	if self.TutorialMode.QUEST_12 == false and self.TutorialMode.questID == 12 then
		if attacker:GetName() == "npc_dota_hero_templar_assassin" then 
			--[[Timers:CreateTimer(function()
				if TutorialMode.QUEST_12a == false then return nil end
				if TutorialMode.QUEST_12b == false then return nil end
				if caster:IsAlive() then 
					Timers:CreateTimer(1.0, function()
						TutorialMode:QuestFinish(caster)
					end)
					return nil
				end
				return 0.05
			end)]]
			if caster:IsAlive() and self.TutorialMode.QUEST_12a == true and self.TutorialMode.QUEST_12b == true then
				--Timers:CreateTimer(1.0, function()
					self.TutorialMode:QuestFinish(caster)
				--end)
			else 
				self.TutorialMode.QUEST_12a = false 
				self.TutorialMode.QUEST_12b = false 
			end
		end
	elseif self.TutorialMode.QUEST_14 == false and self.TutorialMode.questID == 14 then
		if attacker:GetName() == "npc_dota_hero_templar_assassin" then 
			if caster:IsAlive() and caster:HasModifier("modifier_share_damage") and self.TutorialMode.QUEST_14a == true then 
				self.TutorialMode.QUEST_14b = true 
				if self.TutorialMode.QUEST_14a == true and self.TutorialMode.QUEST_14b == true then
					Timers:CreateTimer(1.0, function()
						self.TutorialMode:QuestFinish(caster)
					end)
				end
			end
		end
	end
end

function modifier_quest_001:OnHeroKilled(args)
	print(args.unit:GetUnitName())
	if self.TutorialMode.questID == 17 and self.TutorialMode.QUEST_15 == true and self.TutorialMode.QUEST_16 == false then 
		print('kill some one')
		if args.target:GetUnitName() == "npc_dota_hero_doom_bringer" and self:GetParent():IsAlive() then 
			self.TutorialMode.QUEST_16 = true
			print('alr kill doom')
			self.TutorialMode:FinishTutorial(self:GetParent())
		end
	end
end

function modifier_quest_001:OnAbilityExecuted(args)
	local caster = self:GetParent()
	if self.TutorialMode.QUEST_1 == false and self.TutorialMode.questID == 1 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(0):GetAbilityName() and caster:GetCurrentActiveAbility():GetCursorTarget():GetName() == "npc_dota_hero_doom_bringer" then 
			Timers:CreateTimer(2.2, function()
				if (caster:GetAbsOrigin() - self.TutorialMode.herc:GetAbsOrigin()):Length2D() <= 200 then
					self.TutorialMode:QuestFinish(caster)
				end
			end)
		end
	elseif self.TutorialMode.QUEST_2 == false and self.TutorialMode.questID == 2 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(1):GetAbilityName() and caster:GetCurrentActiveAbility():GetCursorTarget():GetName() == "npc_dota_hero_doom_bringer" then 
			Timers:CreateTimer(1.0, function()
				self.TutorialMode:QuestFinish(caster)
			end)
		end
	elseif self.TutorialMode.QUEST_3 == false and self.TutorialMode.questID == 3 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(2):GetAbilityName() then 
			self.TutorialMode.QUEST_3a = true 
			local timer_3a = 0
			Timers:CreateTimer(function()
				if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_3a >= 5 then 
					self.TutorialMode.QUEST_3a = false 
					return nil
				end
				timer_3a = timer_3a + 0.1
				return 0.1
			end)
			Timers:CreateTimer(function()
				if self.TutorialMode.QUEST_3a == false then return end
				if caster.IsAvalonOnCooldown == true then 
					self.TutorialMode.QUEST_3b = true 
					if self.TutorialMode.QUEST_3a == true and self.TutorialMode.QUEST_3b == true then 
						Timers:CreateTimer(2, function()
							self.TutorialMode:QuestFinish(caster)
						end)
					end
					return nil
				end
				return 0.05
			end)		
		end
	elseif self.TutorialMode.QUEST_4 == false and self.TutorialMode.questID == 4 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(5):GetAbilityName() then 
			self.TutorialMode.QUEST_4a = true 
			Timers:CreateTimer(3.3, function()
				self.TutorialMode.QUEST_4a = false 
			end)
			Timers:CreateTimer(function()
				if self.TutorialMode.QUEST_4a == false then return end
				if self.TutorialMode.QUEST_4b == true then 
					if self.TutorialMode.QUEST_4a == true and self.TutorialMode.QUEST_4b == true then 
						self.TutorialMode:QuestFinish(caster)
					end
					return nil
				end
				return 0.05
			end)	
		end
	elseif self.TutorialMode.QUEST_5 == false and self.TutorialMode.questID == 5 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == "saber_strike_air" then 
			Timers:CreateTimer(1.5, function()
				self.TutorialMode:QuestFinish(caster)
			end)
		end
	elseif self.TutorialMode.QUEST_6 == false and self.TutorialMode.questID == 6 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == "saber_max_excalibur" or caster:GetCurrentActiveAbility():GetAbilityName() == "saber_max_excalibur_upgrade" then 
			CustomNetTables:SetTableValue("mode", "notify_mana",{notify = false})
			Timers:CreateTimer(5, function()
				self.TutorialMode:QuestFinish(caster)
			end)
		end
	elseif self.TutorialMode.QUEST_9 == false and self.TutorialMode.questID == 9 then
		if caster:GetCurrentActiveAbility():GetAbilityName() == caster:GetAbilityByIndex(1):GetAbilityName() and caster:GetCurrentActiveAbility():GetCursorTarget():GetName() == "npc_dota_hero_doom_bringer" then 
			if self.TutorialMode.QUEST_9a == false then 
				self.TutorialMode.QUEST_9a = true
				CustomNetTables:SetTableValue("tutorial", "subquest", {quest9a = false})
				print('Caliburn 1')
				local timer_9a = 0
				Timers:CreateTimer(function()
					if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_9a >= 4 then 
						self.TutorialMode.QUEST_9a = false 
						return nil
					end
					timer_9a = timer_9a + 0.1
					return 0.1
				end)
			elseif self.TutorialMode.QUEST_9a == true and self.TutorialMode.QUEST_9c == false then 
				self.TutorialMode.QUEST_9c = true 
				print('Caliburn 2')
				if self.TutorialMode.QUEST_9a == true and self.TutorialMode.QUEST_9b == true and self.TutorialMode.QUEST_9c == true then 
					Timers:CreateTimer(1, function()
						self.TutorialMode:QuestFinish(caster)
					end)
				end
			end
		end
	elseif self.TutorialMode.QUEST_10 == false and self.TutorialMode.questID == 10 then
		if args.ability:GetAbilityName() == caster:GetAbilityByIndex(5):GetAbilityName() then 
			if self.TutorialMode.QUEST_10a == false then 
				self.TutorialMode.QUEST_10a = true
				CustomNetTables:SetTableValue("tutorial", "subquest", {quest10a = false})
				local timer_10a = 0
				Timers:CreateTimer(function()
					if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_10a >= 8 then 
						self.TutorialMode.QUEST_10a = false 
						return nil
					end
					timer_10a = timer_10a + 0.1
					return 0.1
				end)
			elseif self.TutorialMode.QUEST_10a == true and self.TutorialMode.QUEST_10e == false then 
				self.TutorialMode.QUEST_10e = true
				if self.TutorialMode.QUEST_10a == true and self.TutorialMode.QUEST_10b == true and self.TutorialMode.QUEST_10c == true and self.TutorialMode.QUEST_10d == true and self.TutorialMode.QUEST_10e == true then 
					self.TutorialMode:QuestFinish(caster)
				end
			end
		end
	elseif self.TutorialMode.QUEST_11 == false and self.TutorialMode.questID == 11 then
		if args.ability:IsItem() and args.ability:GetAbilityName() == "item_c_scroll" and args.ability:GetCursorTarget():GetName() == "npc_dota_hero_juggernaut" then 
			self.TutorialMode.QUEST_11a = true 
			local timer_11a = 0
			Timers:CreateTimer(function()
				if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_11a >= 2 then 
					self.TutorialMode.QUEST_11a = false 
					return nil
				end
				timer_11a = timer_11a + 0.1
				return 0.1
			end)
			if self.TutorialMode.QUEST_11a == true and self.TutorialMode.QUEST_11b == true then 
				Timers:CreateTimer(1.2, function()
					self.TutorialMode:QuestFinish(caster)
				end)
			end
		end
	elseif self.TutorialMode.QUEST_12 == false and self.TutorialMode.questID == 12 then
		if args.ability:IsItem() and args.ability:GetAbilityName() == "item_b_scroll" then
			self.TutorialMode.QUEST_12a = true 
			local timer_12a = 0
			Timers:CreateTimer(function()
				if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_12a >= 20 then 
					self.TutorialMode.QUEST_12a = false 
					return nil
				end
				timer_12a = timer_12a + 0.1
				return 0.1
			end) 
		elseif args.ability:IsItem() and args.ability:GetAbilityName() == "item_a_scroll" then
			self.TutorialMode.QUEST_12b = true 
			local timer_12b = 0
			Timers:CreateTimer(function()
				if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_12b >= 10 then 
					self.TutorialMode.QUEST_12b = false 
					return nil
				end
				timer_12b = timer_12b + 0.1
				return 0.1
			end)  
		end
	elseif self.TutorialMode.QUEST_13 == false and self.TutorialMode.questID == 13 then
		if args.ability:IsItem() and args.ability:GetAbilityName() == "item_s_scroll" and args.ability:GetCursorTarget():GetName() == "npc_dota_hero_templar_assassin" then 
			Timers:CreateTimer(1.0, function()
				self.TutorialMode:QuestFinish(caster)
			end)
		end
	elseif self.TutorialMode.QUEST_14 == false and self.TutorialMode.questID == 14 then
		if args.ability:IsItem() and args.ability:GetAbilityName() == "item_spirit_link" and args.ability:GetCursorTarget():GetName() == "npc_dota_hero_monkey_king" then
			self.TutorialMode.QUEST_14a = true  
			local timer_14a = 0
			Timers:CreateTimer(function()
				if not caster:IsAlive() or self.TutorialMode.QUEST_Fail == true or timer_14a >= 7 then 
					self.TutorialMode.QUEST_14a = false 
					return nil
				end
				timer_14a = timer_14a + 0.1
				return 0.1
			end) 
		end
	end
end

--------------------------------------------------

modifier_quest_final = class({})

function modifier_quest_final:IsHidden() return true end

function modifier_quest_final:RemoveOnDeath() return false end

function modifier_quest_final:GetAttributes()
	return {MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_quest_final:DeclareFunctions()
	return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_quest_final:OnDeath()
	if not self:GetParent():IsAlive() and self.hero:IsAlive() then 
		TutorialMode.QUEST_16 = true
		print('doom is ded')
	end
end

function modifier_quest_final:OnCreated()

	self.TutorialMode = TutorialMode()
	self.herc = self:GetParent() 
	self.ability = {}

	self.hero = self.TutorialMode.Hero

	self.herc_pot = self.herc:FindItemInInventory("item_condensed_mana_essence")
	self.herc_s_scroll = self.herc:FindItemInInventory("item_s_scroll")
	self.herc_b_scroll = self.herc:FindItemInInventory("item_b_scroll")
	self.herc_c_scroll = self.herc:FindItemInInventory("item_c_scroll")
	self.herc_a_scroll = self.herc:FindItemInInventory("item_a_scroll")
	self.herc_blink = self.herc:FindItemInInventory("item_blink_scroll")

	for i = 0,6 do 
		self.ability[i] = self.herc:GetAbilityByIndex(i)
	end

	local fissure = {
		UnitIndex = self.herc:entindex(), 
	 	OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.ability[0]:entindex(), 
		Position = self.herc:GetAbsOrigin() + self.herc:GetForwardVector() * 200, 
		Queue = 0,
	}
	Timers:CreateTimer(0.1, function()
		ExecuteOrderFromTable(fissure)
		print('fissure')
		self.TutorialMode.QUEST_16a = true
		local berserk = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
	 		AbilityIndex = self.ability[2]:entindex(), 
	 		Queue = 1,
		}
		Timers:CreateTimer(0.4, function()
			ExecuteOrderFromTable(berserk)
			print('berserk')
			self.TutorialMode.QUEST_16a = true
			local mad = {
				UnitIndex = self.herc:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 		AbilityIndex = self.herc:FindAbilityByName("heracles_madmans_roar"):entindex(), 
		 		Queue = 2,
			}
			Timers:CreateTimer(0.4, function()
				print('mad?')
				
				self.herc:CastAbilityImmediately(self.herc:FindAbilityByName("heracles_madmans_roar"), 0)
				--ExecuteOrderFromTable(mad)
				print('yes madman')
				self.TutorialMode.QUEST_16a = true
				--[[Timers:CreateTimer(0.4, function()
					TutorialMode.QUEST_16a = false
				end)]]
				if not self.herc:HasModifier("modifier_heracles_madman_window") then
					self.TutorialMode.QUEST_16a = false 
					return nil 
				end
				return 0.5
			end)
		end)
	end)

	self:StartIntervalThink(3.0)
end

function modifier_quest_final:OnIntervalThink()
	-- currently in sequence action
	if self.TutorialMode.QUEST_16 == true then 
		self.TutorialMode:FinishTutorial(self.hero)
		return 
	end
	if self.TutorialMode.QUEST_16a == true or self.hero:HasModifier("pause_sealdisable") then return end

	--- Restock Item/ no refresh cd
	if not self.herc:HasItemInInventory("item_condensed_mana_essence") then 
		self.herc_pot = CreateItem("item_condensed_mana_essence", hero, hero)
		self.herc:AddItem(self.herc_pot)
		self.herc_pot = self.herc:FindItemInInventory("item_condensed_mana_essence")
	end

	if not self.herc:HasItemInInventory("item_s_scroll") then 
		self.herc_s_scroll = CreateItem("item_s_scroll", hero, hero)
		self.herc:AddItem(self.herc_s_scroll)
		self.herc_s_scroll = self.herc:FindItemInInventory("item_s_scroll")
	end

	if not self.herc:HasItemInInventory("item_c_scroll") then 
		self.herc_c_scroll = CreateItem("item_c_scroll", hero, hero)
		self.herc:AddItem(self.herc_c_scroll)
		self.herc_c_scroll = self.herc:FindItemInInventory("item_c_scroll")
	end

	if not self.herc:HasItemInInventory("item_b_scroll") then 
		self.herc_b_scroll = CreateItem("item_b_scroll", hero, hero)
		self.herc:AddItem(self.herc_b_scroll)
		self.herc_b_scroll = self.herc:FindItemInInventory("item_b_scroll")
	end

	if not self.herc:HasItemInInventory("item_a_scroll") then 
		self.herc_a_scroll = CreateItem("item_a_scroll", hero, hero)
		self.herc:AddItem(self.herc_a_scroll)
		self.herc_a_scroll = self.herc:FindItemInInventory("item_a_scroll")
	end

	-- Noob Bot 
	if not self.herc:HasModifier("modifier_madmans_roar_cooldown") and self.herc:GetMana() >= 700 and self.ability[0]:IsCooldownReady() and self.ability[1]:IsCooldownReady() and self.ability[2]:IsCooldownReady() and self.ability[6]:IsCooldownReady() then
		if (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 700 then 
			local fissure = {
				UnitIndex = self.herc:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
	 			AbilityIndex = self.ability[0]:entindex(), 
	 			Position = self.herc:GetAbsOrigin() + self.herc:GetForwardVector() * 200, 
	 			Queue = 0,
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(fissure)
				self.TutorialMode.QUEST_16a = true
				local berserk = {
					UnitIndex = self.herc:entindex(), 
			 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			 		AbilityIndex = self.ability[2]:entindex(), 
			 		Queue = 1,
				}
				Timers:CreateTimer(0.4, function()
					ExecuteOrderFromTable(berserk)
					self.TutorialMode.QUEST_16a = true
					local mad = {
						UnitIndex = self.herc:entindex(), 
				 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				 		AbilityIndex = self.herc:FindAbilityByName("heracles_madmans_roar"):entindex(), 
				 		Queue = 2,
					}
					Timers:CreateTimer(0.4, function()
						ExecuteOrderFromTable(mad)
						self.TutorialMode.QUEST_16a = true
						Timers:CreateTimer(0.4, function()
							self.TutorialMode.QUEST_16a = false
						end)
					end)
				end)
			end)
		else 
			local atk_move = {
				UnitIndex = self.herc:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 			TargetIndex = self.hero:entindex(), 
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(atk_move)
				self.TutorialMode.QUEST_16a = false
			end)
		end
	elseif self.herc:GetHealth() <= 1000 and self.ability[2]:IsCooldownReady() and self.herc:GetMana() >= 400 then 
		local berserk = {
			UnitIndex = self.herc:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = self.ability[2]:entindex(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(berserk)
			self.TutorialMode.QUEST_16a = true
			Timers:CreateTimer(0.5, function()
				self.TutorialMode.QUEST_16a = false
			end)
		end)
	elseif self.herc:GetMana() <= 500 and self.herc_pot:IsCooldownReady() then 
		local pot = {
			UnitIndex = self.herc:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = self.herc_pot:entindex(), 
		 	Queue = 0,
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(pot)
			self.TutorialMode.QUEST_16a = true
			Timers:CreateTimer(0.5, function()
				local atk_move = {
					UnitIndex = self.herc:entindex(), 
		 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
		 			TargetIndex = self.hero:entindex(), 
		 			Queue = 1,
				}
				Timers:CreateTimer(0.1, function()
					ExecuteOrderFromTable(atk_move)
					self.TutorialMode.QUEST_16a = false
				end)
			end)
		end)
	elseif self.herc:GetMana() >= 800 and self.ability[5]:IsCooldownReady() and self.herc_c_scroll:IsCooldownReady() and self.herc_s_scroll:IsCooldownReady() then 
		if (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 700 then
			local s_root = {
				UnitIndex = self.herc:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
	 			AbilityIndex = self.herc_s_scroll:entindex(), 
	 			TargetIndex = self.hero:entindex(), 
	 			Queue = 0,
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(s_root)
				self.TutorialMode.QUEST_16a = true
				local c_stun = {
					UnitIndex = self.herc:entindex(), 
		 			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		 			AbilityIndex = self.herc_c_scroll:entindex(), 
		 			TargetIndex = self.hero:entindex(), 
		 			Queue = 1,
				}
				Timers:CreateTimer(0.2, function()
					ExecuteOrderFromTable(c_stun)
					self.TutorialMode.QUEST_16a = true
					local ninelives = {
						UnitIndex = self.herc:entindex(), 
			 			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			 			AbilityIndex = self.ability[5]:entindex(), 
			 			Position = self.hero:GetAbsOrigin(), 
			 			Queue = 2,
					}
					Timers:CreateTimer(0.1, function()
						ExecuteOrderFromTable(ninelives)
						self.TutorialMode.QUEST_16a = false
					end)
				end)
			end)
		else 
			local atk_move = {
				UnitIndex = self.herc:entindex(), 
	 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 			TargetIndex = self.hero:entindex(), 
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(atk_move)
				self.TutorialMode.QUEST_16a = false
			end)
		end
	elseif self.ability[1]:IsCooldownReady() and self.herc:GetMana() >= 200 and (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 300 and not IsFacingUnit(self.hero, self.herc, 90) then 
		local courage = {
			UnitIndex = self.herc:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = self.ability[1]:entindex(), 
		 	Queue = 0,
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(courage)
			self.TutorialMode.QUEST_16a = true
			Timers:CreateTimer(0.5, function()
				local atk_move = {
					UnitIndex = self.herc:entindex(), 
		 			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
		 			TargetIndex = self.hero:entindex(), 
		 			Queue = 1,
				}
				Timers:CreateTimer(0.1, function()
					ExecuteOrderFromTable(atk_move)
					self.TutorialMode.QUEST_16a = false
				end)
			end)
		end)
	elseif self.ability[0]:IsCooldownReady() and self.herc:GetMana() >= 100 and (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 500 then 
		local fissure = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
	 		AbilityIndex = self.ability[0]:entindex(), 
	 		Position = self.hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(fissure)
			self.TutorialMode.QUEST_16a = true
			Timers:CreateTimer(0.4, function()
				self.TutorialMode.QUEST_16a = false
			end)
		end)
	elseif self.herc_blink:IsCooldownReady() and (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() >= 800 then 
		local blink = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION, 
	 		AbilityIndex = self.herc_blink:entindex(), 
	 		Position = self.hero:GetAbsOrigin(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(blink)
			self.TutorialMode.QUEST_16a = true
			local atk_move = {
				UnitIndex = self.herc:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
		 		TargetIndex = self.hero:entindex(), 
			}
			Timers:CreateTimer(0.2, function()
				ExecuteOrderFromTable(atk_move)
				self.TutorialMode.QUEST_16a = false
			end)
		end)
	elseif self.herc_a_scroll:IsCooldownReady() and self.hero:FaceTowards(self.herc:GetAbsOrigin()) and (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 500 and not self.herc:HasModifier("modifier_heracles_berserk") then 
		local a_barrier = {
			UnitIndex = self.herc:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = self.herc_a_scroll:entindex(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(a_barrier)
			self.TutorialMode.QUEST_16a = true
			local atk_move = {
				UnitIndex = self.herc:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
		 		TargetIndex = self.hero:entindex(), 
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(atk_move)
				self.TutorialMode.QUEST_16a = false
			end)
		end)
	elseif self.herc_b_scroll:IsCooldownReady() and self.hero:FaceTowards(self.herc:GetAbsOrigin()) and (self.hero:GetAbsOrigin() - self.herc:GetAbsOrigin()):Length2D() <= 500 and not self.herc:HasModifier("modifier_heracles_berserk") then 
		local b_barrier = {
			UnitIndex = self.herc:entindex(), 
		 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		 	AbilityIndex = self.herc_b_scroll:entindex(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(b_barrier)
			self.TutorialMode.QUEST_16a = true
			local atk_move = {
				UnitIndex = self.herc:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
		 		TargetIndex = self.hero:entindex(), 
			}
			Timers:CreateTimer(0.1, function()
				ExecuteOrderFromTable(atk_move)
				self.TutorialMode.QUEST_16a = false
			end)
		end)
	else
		local atk_move = {
			UnitIndex = self.herc:entindex(), 
	 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, 
	 		TargetIndex = self.hero:entindex(), 
		}
		Timers:CreateTimer(0.1, function()
			ExecuteOrderFromTable(atk_move)
			self.TutorialMode.QUEST_16a = false
		end)
	end
end








