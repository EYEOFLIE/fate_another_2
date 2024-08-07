require("abilities/iskandar/iskandar_abilities")

iskandar_army_of_the_king = class({})
iskandar_army_of_the_king_upgrade = class({})
modifier_army_of_the_king_death_checker = class({})
modifier_army_of_the_king_freeze = class({})
modifier_army_of_the_king_infantry_bonus_stat = class({})
modifier_army_of_the_king_archer_bonus_stat = class({})
modifier_army_of_the_king_maharaja_bonus_stat = class({})
modifier_army_of_the_king_waver_bonus_stat = class({})
modifier_army_of_the_king_cavalry_bonus_stat = class({})
modifier_army_of_the_king_hepha_bonus_stat = class({})
modifier_iskandar_r_use = class({})

LinkLuaModifier("modifier_army_of_the_king_death_checker", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_freeze", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_iskandar_r_use", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_infantry_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_archer_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_maharaja_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_waver_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_cavalry_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_army_of_the_king_hepha_bonus_stat", "abilities/iskandar/iskandar_aotk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_inside_marble", "abilities/general/modifiers/modifier_inside_marble", LUA_MODIFIER_MOTION_NONE)

function iskandar_aotk_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
	end

	function abil:GetAbilityTextureName()
		return "custom/iskandar/iskander_army_of_the_king"
	end

	function abil:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("radius")
	end

	function abil:OnUpgrade()
		self:GetCaster():FindAbilityByName("iskandar_arrow_bombard"):SetLevel(self:GetLevel())
		self:GetCaster():FindAbilityByName("iskandar_bucephalus"):SetLevel(self:GetLevel())
	end

	function abil:CastFilterResultLocation(vLocation)
		if vLocation.x < 3000 and vLocation.y < -2000 then 
			return UF_FAIL_CUSTOM
		elseif vLocation.x > 3000 and vLocation.y < -2000 then 
			self:GetCaster().IsAOTKDominant = false
			return UF_SUCCESS 
		end
		self:GetCaster().IsAOTKDominant = true
		return UF_SUCCESS 
	end

	function abil:GetCustomCastError()
		return "#Already_Within_Reality_Marble"
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		self.cast_delay = self:GetSpecialValueFor("cast_delay")
		self.duration = self:GetSpecialValueFor("duration")
		self.soldierCount = self:GetSpecialValueFor("soldier_count")
		self.radius = self:GetSpecialValueFor("radius")
		self.marbleCenter = aotkCenter
		self.AOTKTagetTable = {}

		self.caster.AOTKSoldiers = self.caster.AOTKSoldiers or {}

		for k,v in pairs (self.caster.AOTKSoldiers) do 
			if IsValidEntity(v) and not v:IsNull() then 
				v:RemoveSelf()
				UTIL_Remove(v)
			end
		end

		self.caster.AOTKSoldiers = {}

	--if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
		self.caster:AddNewModifier(self.caster, self, "modifier_army_of_the_king_freeze", {Duration = self.cast_delay})
		giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealdisabled", self.cast_delay)

		EmitGlobalSound("Iskander.AOTK")

		-- particle
		--CreateGlobalParticle("particles/custom/iskandar/iskandar_aotk.vpcf", {[0] = self.caster:GetAbsOrigin()}, self.cast_delay)
		self:CreateAOTKCastFx()

		if math.ceil(self.caster:GetStrength()) >= 25 and math.ceil(self.caster:GetAgility()) >= 25 and math.ceil(self.caster:GetIntellect()) >= 25 then 
			self.caster:AddNewModifier(self.caster, self, "modifier_iskandar_r_use", {Duration = 5})
		end

		local firstRowPos = aotkCenter + Vector(300, -600,0) 
		--local maharajaPos = aotkCenter + Vector(600, 0,0)

		local infantrySpawnCounter = 0
		self.caster.AOTKSoldierCount = 0

		--self.caster.AOTKSoldierCount = self.soldierCount + self.soldierCount
	--print('soldier count: ' .. caster.AOTKSoldierCount)

		Timers:CreateTimer(function()
			if infantrySpawnCounter == self.soldierCount then return end
			self:GenerateSoldier("iskandar_infantry", firstRowPos + Vector(0,infantrySpawnCounter*100,0), "modifier_army_of_the_king_infantry_bonus_stat")
			infantrySpawnCounter = infantrySpawnCounter + 1
			return 0.03
		end)

		local archerSpawnCounter1 = 0
		Timers:CreateTimer(0.99, function()
			if archerSpawnCounter1 == (self.soldierCount / 2) then return end
			self:GenerateSoldier("iskandar_archer", aotkCenter + Vector(800, 700 - archerSpawnCounter1*100, 0), "modifier_army_of_the_king_archer_bonus_stat")
			archerSpawnCounter1 = archerSpawnCounter1 + 1
			return 0.03
		end)

		local archerSpawnCounter2 = 0
		Timers:CreateTimer(1.49, function()
			if archerSpawnCounter2 == (self.soldierCount / 2) then return end
			self:GenerateSoldier("iskandar_archer", aotkCenter + Vector(800, -700 + archerSpawnCounter2*100, 0), "modifier_army_of_the_king_archer_bonus_stat")
			archerSpawnCounter2 = archerSpawnCounter2 + 1
			return 0.03
		end)
	
		Timers:CreateTimer({
			endTime = self.cast_delay,
			callback = function()
			if self.caster:IsAlive() then 
			    self.caster.AOTKLocator = CreateUnitByName("ping_sign2", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
			    self.caster.AOTKLocator:FindAbilityByName("ping_sign_passive"):SetLevel(1)
			    self.caster.AOTKLocator:AddNewModifier(self.caster, nil, "modifier_kill", {duration = self.duration + 0.5})
			    self.caster.AOTKCastPos = self.caster:GetAbsOrigin()
			    self.caster.AOTKLocator:SetAbsOrigin(self.caster.AOTKCastPos)
				self:OnAOTKStart()
				self.caster:AddNewModifier(self.caster, self, "modifier_army_of_the_king_death_checker", {Duration = self.duration})
			end
		end})
	end

	function abil:OnAOTKStart()
		self.caster.IsAOTKActive = true
		self.caster:EmitSound("Ability.SandKing_SandStorm.loop")
		CreateUITimer("Army of the King", self.duration, "aotk_timer")

		-- Swap abilities

		self.caster:SwapAbilities("iskandar_spatha", "iskandar_summon_hephaestion", false, true)
		self.caster:SwapAbilities(self.caster.ESkill, "iskandar_arrow_bombard", false, true)

		if self.caster.IsBeyondTimeAcquired then
			self.caster:SwapAbilities("iskandar_army_of_the_king_upgrade", "iskandar_bucephalus", false, true)
		else 
			self.caster:SwapAbilities("iskandar_army_of_the_king", "fate_empty3", false, true)
		end

		self.caster.IsAOTKDominant = true
		-- Find eligible targets
		self.aotkTargets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(), nil, self.radius
	            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

		-- Remove any dummy or hero in jump

		for i = 1, #self.aotkTargets do
			if IsValidEntity(self.aotkTargets[i]) and not self.aotkTargets[i]:IsNull() then
				ProjectileManager:ProjectileDodge(self.aotkTargets[i]) -- Disjoint particles
				if self.aotkTargets[i]:HasModifier("jump_pause") or string.match(self.aotkTargets[i]:GetUnitName(),"dummy") or string.match(self.aotkTargets[i]:GetUnitName(),"flag") or self.aotkTargets[i]:HasModifier("spawn_invulnerable") and self.aotkTargets[i] ~= self.caster then 
					table.remove(self.aotkTargets, i)
				end
			end
		end

		if self.caster:GetAbsOrigin().x > 3000 and self.caster:GetAbsOrigin().y < -2000 then
			self.caster.IsAOTKDominant = false
		end

		--[[-- Check if Archer's UBW is already in place 
		for i=1, #aotkTargets do
			if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
				if aotkTargets[i]:GetName() == "npc_dota_hero_ember_spirit" and aotkTargets[i]:HasModifier("modifier_ubw_death_checker") then
					caster.IsAOTKDominant = false
					break
				end
			end
		end]]


	 	-- spawn sight dummy
		local truesightdummy = CreateUnitByName("sight_dummy_unit", aotkCenter, false, self.caster, self.caster, self.caster:GetTeamNumber())
		truesightdummy:AddNewModifier(caster, nil, "modifier_item_ward_true_sight", {true_sight_range = 3000}) 
		truesightdummy:AddNewModifier(caster, nil, "modifier_kill", {duration = self.duration}) 
		truesightdummy:SetDayTimeVisionRange(2500)
		truesightdummy:SetNightTimeVisionRange(2500)
		local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
		unseen:SetLevel(1)
		-- spawn sight dummy for enemies
		--[[local enemyTeamNumber = 0
		if caster:GetTeamNumber() == 0 then enemyTeamNumber = 1 end
		local truesightdummy2 = CreateUnitByName("sight_dummy_unit", aotkCenter, false, keys.caster, keys.caster, enemyTeamNumber)
		truesightdummy2:AddNewModifier(caster, caster, "modifier_kill", {duration = 12}) 
		truesightdummy2:SetDayTimeVisionRange(2500)
		truesightdummy2:SetNightTimeVisionRange(2500)
		local unseen2 = truesightdummy2:FindAbilityByName("dummy_unit_passive")
		unseen2:SetLevel(1)]]

		-- Summon soldiers

		if self.caster.IsAOTKDominant == false then 
			self.marbleCenter = ubwCenter 
			for i=1, #self.caster.AOTKSoldiers do
				local soldierHandle = self.caster.AOTKSoldiers[i]
				local soldierPos = self.caster.AOTKSoldiers[i]:GetAbsOrigin()
				local diffFromCenter = soldierPos - aotkCenter
				soldierHandle:SetAbsOrigin(diffFromCenter + self.marbleCenter)
			end
		end

		--local firstRowPos = self.marbleCenter + Vector(300, -500,0) 
		local maharajaPos = self.marbleCenter + Vector(600, 0,0)
		local waverPos = self.marbleCenter + Vector(0, -200,0)

		self:GenerateSoldier("iskandar_eumenes", maharajaPos, "modifier_army_of_the_king_maharaja_bonus_stat")
		if self.caster.IsBeyondTimeAcquired then
			self:GenerateSoldier("iskandar_waver", waverPos, "modifier_army_of_the_king_waver_bonus_stat")
		end

		if not self.caster.IsAOTKDominant then return end -- If Archer's UBW is already active, do not teleport units


		self.aotkTargetLoc = {}
		local diff = nil
		local aotkTargetPos = nil

		-- record location of units and move them into UBW(center location : 6000, -4000, 200)
		for i=1, #self.aotkTargets do
			if IsValidEntity(self.aotkTargets[i]) and not self.aotkTargets[i]:IsNull() then
				if self.aotkTargets[i]:GetName() ~= "npc_dota_ward_base" then
					self.aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_enemy")
					self.aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_ally")
					self.aotkTargets[i]:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
					self.aotkTargets[i]:RemoveModifierByName("modifier_zhuge_liang_array_checker")
					self.aotkTargets[i]:RemoveModifierByName("modifier_zhuge_liang_array_enemy")
					self.aotkTargets[i]:RemoveModifierByName("modifier_queens_glass_game")
					
					--if aotkTargets[i]:GetName() == "npc_dota_hero_bounty_hunter" or aotkTargets[i]:GetName() == "npc_dota_hero_riki" then
		            self.aotkTargets[i]:AddNewModifier(self.caster, nil, "modifier_inside_marble", { Duration = self.duration })
		            --end

		            --[[if IsIsekaiAbuser(aotkTargets[i]) then
	                    giveUnitDataDrivenModifier(caster, aotkTargets[i], "modifier_isekai_check", duration)
	                    giveUnitDataDrivenModifier(caster, aotkTargets[i], "modifier_isekai_abuser", duration + 5)
	                end]]
	                self.AOTKTagetTable[self.aotkTargets[i]] = self.aotkTargets[i]:GetAbsOrigin()
					aotkTargetPos = self.aotkTargets[i]:GetAbsOrigin()
			        self.aotkTargetLoc[i] = aotkTargetPos
			        diff = (self.caster.AOTKCastPos - aotkTargetPos)

			        local forwardVec = self.aotkTargets[i]:GetForwardVector()
			        -- scale position difference to size of AOTK
			        diff.y = diff.y * 0.7
			        if self.aotkTargets[i]:GetTeam() ~= self.caster:GetTeam() then 
			        	if diff.x <= 0 then 
			        		diff.x = diff.x * -1 
			        		forwardVec.x = forwardVec.x * -1
			        	end
			        elseif self.aotkTargets[i]:GetTeam() == self.caster:GetTeam() then
			        	if diff.x >= 0 then 
			        		diff.x = diff.x * -1
			        		forwardVec.x = forwardVec.x * -1
			        	end
			        end
			        self.aotkTargets[i]:SetAbsOrigin(aotkCenter - diff)
					FindClearSpaceForUnit(self.aotkTargets[i], self.aotkTargets[i]:GetAbsOrigin(), true)
					Timers:CreateTimer(0.1, function() 
						if self.caster:IsAlive() and IsValidEntity(self.aotkTargets[i]) then
							self.aotkTargets[i]:AddNewModifier(self.aotkTargets[i], nil, "modifier_camera_follow", {duration = 1.0})
						end
					end)
					Timers:CreateTimer(0.033, function()
						if self.caster:IsAlive() and IsValidEntity(self.aotkTargets[i]) then
							ExecuteOrderFromTable({
								UnitIndex = self.aotkTargets[i]:entindex(),
								OrderType = DOTA_UNIT_ORDER_STOP,
								Queue = false
							})
							self.aotkTargets[i]:SetForwardVector(forwardVec)
						end
					end)
				end
			end
	    end
	end

	function abil:GenerateSoldier(sUnit, vPosition, buff)
		local soldier = CreateUnitByName(sUnit, vPosition, true, nil, nil, self.caster:GetTeamNumber())
		
		if string.match(sUnit, "iskandar_eumenes") or string.match(sUnit, "iskandar_hephaestion") or string.match(sUnit, "iskandar_waver") then 
			soldier:SetControllableByPlayer(self.caster:GetPlayerID(), true)
			
			if string.match(sUnit, "iskandar_eumenes") then
				soldier:FindAbilityByName("iskandar_battle_horn"):SetLevel(self:GetLevel())
			elseif string.match(sUnit, "iskandar_hephaestion") then 
				soldier:FindAbilityByName("iskandar_hammer_and_anvil"):SetLevel(self:GetLevel())
				self.caster.hepha = soldier
			else
				soldier:FindAbilityByName("iskandar_brilliance_of_the_king"):SetLevel(self:GetLevel())
				soldier:FindAbilityByName("iskandar_brilliance_of_the_king"):StartCooldown(1)
				self.caster.waver = soldier				
			end
		end
		self.caster.AOTKSoldierCount = self.caster.AOTKSoldierCount + 1
			--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetUnitCanRespawn(false)
		soldier:SetOwner(self.caster)
		soldier.IsAOTKSoldier = true
			--soldier:SetForwardVector(Vector(-0.999991, 0.004154, -0.000000))
		table.insert(self.caster.AOTKSoldiers, soldier)
			--caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		self:StrengthenSoldier(soldier, buff)
		soldier:AddNewModifier(self.caster, nil, "modifier_kill", {Duration = 16})
	end

	function abil:CreateAOTKCastFx()
		self.AOTKCastFx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_aotk.vpcf", PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(self.AOTKCastFx, 0, self.caster:GetAbsOrigin())

		Timers:CreateTimer(self.cast_delay, function()
			ParticleManager:DestroyParticle(self.AOTKCastFx, true)
			ParticleManager:ReleaseParticleIndex(self.AOTKCastFx)
		end)
	end

	function abil:StrengthenSoldier(hUnit, buff)
		local bonus_atk = self:GetSpecialValueFor("infantry_bonus_damage")
		local bonus_hp = self:GetSpecialValueFor("infantry_bonus_health")
		if string.match(hUnit:GetUnitName(), "iskandar_eumenes") then
			bonus_atk = self:GetSpecialValueFor("maharaja_bonus_damage")
			bonus_hp = self:GetSpecialValueFor("maharaja_bonus_health")
		elseif string.match(hUnit:GetUnitName(), "iskandar_waver") then 
			bonus_atk = self:GetSpecialValueFor("waver_bonus_damage")
			bonus_hp = self:GetSpecialValueFor("waver_bonus_health")
		elseif string.match(hUnit:GetUnitName(), "hepha") then 
			bonus_atk = self:GetSpecialValueFor("hepha_bonus_damage")
			bonus_hp = self:GetSpecialValueFor("hepha_bonus_health")
		elseif string.match(hUnit:GetUnitName(), "iskandar_archer") then 
			bonus_atk = self:GetSpecialValueFor("archer_bonus_damage")
			bonus_hp = self:GetSpecialValueFor("archer_bonus_health")
		elseif string.match(hUnit:GetUnitName(), "iskandar_cavalry") then 
			bonus_atk = self:GetSpecialValueFor("cavalry_bonus_damage")
			bonus_hp = self:GetSpecialValueFor("cavalry_bonus_health")
		end
		hUnit:AddNewModifier(self.caster, self, buff, {Duration = 16, BonusAtk = bonus_atk * self:GetLevel(), BonusHP = bonus_hp * self:GetLevel()})
	end

	function abil:EndAOTK()
		if self.caster.IsAOTKActive == false then return end
		print("AOTK ended")
		-- Revert abilities

		self.caster:SwapAbilities("iskandar_spatha", "iskandar_summon_hephaestion", true, false)
		self.caster:SwapAbilities(self.caster.ESkill, "iskandar_arrow_bombard", true, false)

		if self.caster.IsBeyondTimeAcquired then
			self.caster:SwapAbilities("iskandar_army_of_the_king_upgrade", "iskandar_bucephalus", true, false)
		else 
			self.caster:SwapAbilities("iskandar_army_of_the_king", "fate_empty3", true, false)
		end

		CreateUITimer("Army of the King", 0, "aotk_timer")
		--Timers:RemoveTimer("aotk_timer")
		--UTIL_RemoveImmediate(aotkQuest)
		self.caster.IsAOTKActive = false
		if not self.caster.AOTKLocator:IsNull() and IsValidEntity(self.caster.AOTKLocator) then
			self.caster.AOTKLocator:RemoveSelf()
		end

		StopSoundEvent("Ability.SandKing_SandStorm.loop", self.caster)

		CleanUpHammer(self.caster)

		-- Remove soldiers 
		for i=1, #self.caster.AOTKSoldiers do
			if IsValidEntity(self.caster.AOTKSoldiers[i]) and not self.caster.AOTKSoldiers[i]:IsNull() then
				if self.caster.AOTKSoldiers[i]:IsAlive() then
					self.caster.AOTKSoldiers[i]:ForceKill(false)
				end
			end
		end

		if not self.caster.IsAOTKDominant then return end -- If Archer's UBW is already active, do not teleport units
		--[[for i=0, 9 do
		    local player = PlayerResource:GetPlayer(i)
		    if player ~= nil and player:GetAssignedHero() ~= nil then 
				player:StopSound("Iskander.AOTK_Ambient")
			end
		end]]
	    local units = FindUnitsInRadius(self.caster:GetTeam(), self.marbleCenter, nil, 3000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	 
	    for i=1, #units do
	    	if IsValidEntity(units[i]) and not units[i]:IsNull() then
				if string.match(units[i]:GetUnitName(),"dummy") or string.match(units[i]:GetUnitName(),"flag") or units[i] == self.caster then 
					table.remove(units, i)
				elseif IsAoTKSoldier(units[i]) then 
		    		units[i]:ForceKill(false)
		    		table.remove(units, i)
		    	end
			end
		end

		self.caster:SetAbsOrigin(self.caster.AOTKCastPos)

		for k,v in pairs (units) do
			if IsValidEntity(v) and not v:IsNull() then 
				-- Disjoint all projectiles
				ProjectileManager:ProjectileDodge(v)

				v:RemoveModifierByName("modifier_aestus_domus_aurea_enemy")
				v:RemoveModifierByName("modifier_aestus_domus_aurea_ally")
				v:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
				v:RemoveModifierByName("modifier_zhuge_liang_array_checker")
				v:RemoveModifierByName("modifier_zhuge_liang_array_enemy")
				v:RemoveModifierByName("modifier_inside_marble")
				v:RemoveModifierByName("modifier_annihilate_mute")

				if self.AOTKTagetTable[v] then 
					v:RemoveModifierByName("modifier_unlimited_bladeworks")
				    v:SetAbsOrigin(self.AOTKTagetTable[v]) 
				    v:Stop()
				    FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
				    Timers:CreateTimer(0.05, function() 
				    	if IsValidEntity(v) and not v:IsNull() and v:IsHero() then 
							v:AddNewModifier(v, nil, "modifier_camera_follow", {duration = 1.0})
						end
					end)
				else
					if IsValidEntity(v) and not v:IsNull() then
						diff = aotkCenter - v:GetAbsOrigin()
				    	if self.caster.AOTKCastPos ~= nil then 
				    		v:SetAbsOrigin(self.caster.AOTKCastPos - diff * 0.7)
				    		v:Stop()
				    	end
				    end

			    	FindClearSpaceForUnit(v, v:GetAbsOrigin(), true) 
					Timers:CreateTimer(0.05, function() 
						if IsValidEntity(v) and not v:IsNull() and v:IsHero() then
							v:AddNewModifier(v, nil, "modifier_camera_follow", {duration = 1.0})
						end
					end)
				end

				--[[if self.aotkTargets ~= nil then
			    	for j=1, #self.aotkTargets do
			    		if IsValidEntity(self.aotkTargets[j]) and not self.aotkTargets[j]:IsNull() then
				    		if v == self.aotkTargets[j] then
				    			if self.aotkTargets[j] ~= nil then
				    				v:RemoveModifierByName("modifier_unlimited_bladeworks")
				    				v:SetAbsOrigin(self.aotkTargetLoc[j]) 
				    				v:Stop()
				    			end
				    			FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
				    			Timers:CreateTimer(0.05, function() 
				    				if IsValidEntity(v) and not v:IsNull() and v:IsHero() then 
										v:AddNewModifier(v, nil, "modifier_camera_follow", {duration = 1.0})
									end
								end)
				    			return
				    		end
				    	end
			    	end 
		    	end

		    	diff = aotkCenter - v:GetAbsOrigin()
		    	if self.caster.AOTKCastPos ~= nil then 
		    		v:SetAbsOrigin(self.caster.AOTKCastPos - diff * 0.7)
		    		v:Stop()
		    	end

		    	FindClearSpaceForUnit(v, v:GetAbsOrigin(), true) 
				Timers:CreateTimer(0.05, function() 
					if IsValidEntity(v) and not v:IsNull() and v:IsHero() then
						v:AddNewModifier(v, nil, "modifier_camera_follow", {duration = 1.0})
					end
				end)]]
			end
		end
	end
end

iskandar_aotk_wrapper(iskandar_army_of_the_king)
iskandar_aotk_wrapper(iskandar_army_of_the_king_upgrade)

--------------------------

function modifier_army_of_the_king_freeze:IsHidden() return false end
function modifier_army_of_the_king_freeze:IsDebuff() return false end
function modifier_army_of_the_king_freeze:IsPurgable() return false end
function modifier_army_of_the_king_freeze:RemoveOnDeath() return true end
function modifier_army_of_the_king_freeze:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_army_of_the_king_freeze:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end

function modifier_army_of_the_king_freeze:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function modifier_army_of_the_king_freeze:GetOverrideAnimationRate()
	return 0.5
end

---------------------

function modifier_army_of_the_king_death_checker:IsHidden() return false end
function modifier_army_of_the_king_death_checker:IsDebuff() return false end
function modifier_army_of_the_king_death_checker:IsPurgable() return false end
function modifier_army_of_the_king_death_checker:RemoveOnDeath() return true end
function modifier_army_of_the_king_death_checker:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then 
	function modifier_army_of_the_king_death_checker:OnCreated(args)
		self.caster = self:GetParent()
		self.SandFx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(self.SandFx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.SandFx, 1, Vector(1500,1500,1500))
	end

	function modifier_army_of_the_king_death_checker:OnDestroy()
		ParticleManager:DestroyParticle(self.SandFx, true)
		ParticleManager:ReleaseParticleIndex(self.SandFx)
		if self.caster:HasModifier("modifier_annihilate_window") then 
			self.caster:RemoveModifierByName("modifier_annihilate_window")
		end

		self:GetAbility():EndAOTK()
	end
end

--------------------------

function modifier_iskandar_r_use:IsHidden() return true end
function modifier_iskandar_r_use:IsDebuff() return false end
function modifier_iskandar_r_use:IsPurgable() return false end
function modifier_iskandar_r_use:RemoveOnDeath() return true end
function modifier_iskandar_r_use:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------

function iskandar_soldier_mod_wrapper(mod)
	function mod:IsHidden() return false end
	function mod:IsDebuff() return false end
	function mod:IsPurgable() return false end
	function mod:RemoveOnDeath() return true end
	function mod:GetAttributes()
	    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
	end

	function mod:DeclareFunctions()
		return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,}
	end

	function mod:GetModifierBaseAttack_BonusDamage()
		return self.bonus_atk
	end

	if IsServer() then
		function mod:OnCreated(args)
			self.caster = self:GetCaster()
			self.target = self:GetParent()
			self.bonus_atk = args.BonusAtk
			self.bonus_hp = args.BonusHP

			local newHP = self.target:GetMaxHealth() + self.bonus_hp
			local newcurrentHP = self.target:GetHealth() + self.bonus_hp
			--print(newHP .. " " .. newcurrentHP)

			if self.caster.IsBeyondTimeAcquired then 
				local bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health") / 100
				newHP = newHP + self.caster:GetMaxHealth() * bonus_health
				newcurrentHP = newcurrentHP + self.caster:GetMaxHealth() * bonus_health
			end

			self.target:SetMaxHealth(newHP)
			self.target:SetBaseMaxHealth(newHP)
			self.target:SetHealth(newcurrentHP)
		end

		function mod:OnDestroy()
			local sustain = self:GetAbility():GetSpecialValueFor("sustain_limit")

			if self.caster:HasModifier("modifier_army_of_the_king_death_checker") then
				self.caster.AOTKSoldierCount = self.caster.AOTKSoldierCount - 1
				if self.caster.AOTKSoldierCount < sustain then
					self:GetAbility():EndAOTK()
					self.caster:RemoveModifierByName("modifier_army_of_the_king_death_checker")
				end
			end
		end
	end
end

iskandar_soldier_mod_wrapper(modifier_army_of_the_king_infantry_bonus_stat)
iskandar_soldier_mod_wrapper(modifier_army_of_the_king_archer_bonus_stat)
iskandar_soldier_mod_wrapper(modifier_army_of_the_king_maharaja_bonus_stat)
iskandar_soldier_mod_wrapper(modifier_army_of_the_king_waver_bonus_stat)
iskandar_soldier_mod_wrapper(modifier_army_of_the_king_cavalry_bonus_stat)
iskandar_soldier_mod_wrapper(modifier_army_of_the_king_hepha_bonus_stat)
