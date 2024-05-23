
territoryAbilHandle = nil -- Ability handle for Create Workshop
ATTRIBUTE_HG_INT_MULTIPLIER = 0

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initializes Workshop
]]
function OnTerritoryCreated(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local hero = ply:GetAssignedHero()
	local targetPoint = keys.target_points[1]
	local max_level_item = ability:GetSpecialValueFor("max_item_lvl")
	territoryAbilHandle = keys.ability
	

	-- Check if Workshop already exists 
	if caster.IsTerritoryPresent and caster:HasModifier("modifier_caster_death_checker") then
		ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Workshop_Exists")
		return 
	else
		caster.IsTerritoryPresent = true
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_caster_death_checker", {})

	-- Create Workshop at location
	local unitName = "medea_territory"
	if caster.IsTerritoryImproved then 
		unitName = "medea_territory_improved"
	end
	caster.Territory = CreateUnitByName(unitName, targetPoint, true, caster, caster, caster:GetTeamNumber()) 
	caster.Territory:SetControllableByPlayer(pid, true)
	caster.Territory:SetOwner(caster)
	LevelAllAbility(caster.Territory)
	ability:ApplyDataDrivenModifier(caster, caster.Territory, "modifier_territory_death_checker", {}) 

	--[[
	-- Create spy unit for enemies
	local enemyTeamNumber = 0
    LoopOverPlayers(function(ply, plyID)
        if ply:GetAssignedHero():GetTeamNumber() ~= caster:GetTeamNumber() then
        	enemyTeamNumber = ply:GetAssignedHero():GetTeamNumber()
        	return
        end
    end)
	enemydummy = CreateUnitByName("sight_dummy_unit", caster.Territory:GetAbsOrigin(), false, keys.caster, keys.caster, enemyTeamNumber)
	enemydummy:SetDayTimeVisionRange(300)
	enemydummy:SetNightTimeVisionRange(300)
	local unseen = enemydummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)
	Timers:CreateTimer(function() 
		if not caster.Territory:IsAlive() then 
			enemydummy:RemoveSelf()
			return 
		else
			if not enemydummy:IsNull() then 
				enemydummy:SetAbsOrigin(caster.Territory:GetAbsOrigin())
			end
			return 1.0
		end
	end)]]

	-- Do special handling for attribute
	Timers:CreateTimer(5, function() --because it takes 5 seconds for territory to be built
		if caster.IsTerritoryImproved and caster.IsTerritoryPresent and not caster.Territory:IsNull() then 
			local radius = keys.ability:GetSpecialValueFor("mana_regen_radius")
			local true_sight = keys.ability:GetSpecialValueFor("true_sight")
			truesightdummy = CreateUnitByName("sight_dummy_unit", caster.Territory:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			truesightdummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = true_sight}) 
			local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
			unseen:SetLevel(1)
			Timers:CreateTimer(function() 
				if not caster.IsTerritoryPresent and IsValidEntity(truesightdummy) then -- and not truesightdummy:IsNull() then 
					truesightdummy:RemoveSelf()
					return
				else
					truesightdummy:SetAbsOrigin(caster.Territory:GetAbsOrigin())
					return 1.0
				end
			end)

			-- Give out mana regen for nearby allies
			Timers:CreateTimer(function()
				if caster.Territory:IsNull() or not caster.IsTerritoryPresent then return end
			  	local targets = FindUnitsInRadius(caster:GetTeam(), caster.Territory:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
			        if IsValidEntity(v) and not v:IsNull() and not IsManaLess(v) then
			         	ability:ApplyDataDrivenModifier(caster, v, "modifier_territory_mana_regen", {Duration = 1.0}) 
			        end
			    end
				return 1.0
				end
			)
		end
	end)


	local warriorItem = CreateItem("item_summon_skeleton_warrior" , nil, nil)
	local archerItem = CreateItem("item_summon_skeleton_archer" , nil, nil)
	local dragItem = CreateItem("item_summon_ancient_dragon"  , nil, nil)
	local skillLevel = 1 + (caster:GetLevel() - 1)/3
	if skillLevel > max_level_item then 
		skillLevel = max_level_item 
	end
	warriorItem:SetLevel(skillLevel)
	archerItem:SetLevel(skillLevel)
	dragItem:SetLevel(skillLevel)

	-- Initialize territory
	caster.Territory:SetHealth(1)
	caster.Territory:SetMana(0)
	caster.Territory:SetBaseManaRegen(3) 
	caster.Territory:AddItem(warriorItem)
	caster.Territory:AddItem(archerItem)
	if caster.IsTerritoryImproved then
		caster.Territory:AddItem(dragItem)
		caster.Territory:AddItem(CreateItem("item_all_seeing_orb" , nil, nil))
	end
	giveUnitDataDrivenModifier(caster, caster.Territory, "pause_sealdisabled", 5.0)
	keys.ability:ApplyDataDrivenModifier(caster, caster.Territory, "modifier_territory_root", {}) 


	-- Constrcut territory over time
	local territoryConstTimer = 0
	Timers:CreateTimer(function()
		if territoryConstTimer == 10 then return end
		caster.Territory:SetHealth(caster.Territory:GetHealth() + caster.Territory:GetMaxHealth() / 10)
		territoryConstTimer = territoryConstTimer + 1
		return 0.5
		end
	)


end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Called when Caster(5th) is killed in order to clean up existing Workshop.
]]
function OnTerritoryOwnerDeath(keys)
	local caster = keys.caster
	if IsValidEntity(caster.Territory) and not caster.Territory:IsNull() and caster.Territory:IsAlive() then
		caster.Territory:Execute(keys.ability, caster.Territory)
	end
end

function OnDragonDeath(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_mount_caster") then 
		caster:RemoveModifierByName("modifier_mount_caster")
	end
end

--[[
	Author: Dun1007
	Date: 9.2.2015.
	
	Ping Caster's Workshop every 15 seconds to enemy
]]
function OnTerritoryPingThink(keys)
	local caster = keys.caster
	local enemyTeamNumber = 0
	--[[
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	enemyTeamNumber = playerHero:GetTeamNumber()
        	return
        end
    end)
	MinimapEvent( enemyTeamNumber, caster, caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )]]
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Called when Workshop is killed in order to clean up summons
]]
function OnTerritoryDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_caster_death_checker")
	if caster:HasModifier("modifier_mount_caster") then
		caster:RemoveModifierByName("modifier_mount_caster")
		caster.IsMounted = false
		SendMountStatus(caster)
	end
	--print(caster:GetUnitName())
	--print(hero:GetUnitName())
	caster.IsTerritoryPresent = false
	

	-- Find all summons and forcekill them
	local summons = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_UNITS_EVERYWHERE, false) 
	for k,v in pairs(summons) do
		print("Found unit " .. v:GetUnitName())
		if string.match(v:GetUnitName(), "medea_skeleton") or string.match(v:GetUnitName(), "medea_ancient_dragon") then
			if not v:IsNull() and IsValidEntity(v) then
				v:ForceKill(true) 
			end
		end
	end
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Explode Workshop and deal damage to nearby enemies

	caster : Workshop
	hero : Caster(5th)
]]

function OnTerritoryExplosionCastStart(keys)
	local caster = keys.caster
	local target = keys.target

	local fx = ParticleManager:CreateParticle("particles/custom/caster/workshop_explosion.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex( fx )
end

function OnTerritoryExplosion(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetOwner()
	local ability = keys.ability 
	local delay = ability:GetSpecialValueFor("delay")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local int_ratio = ability:GetSpecialValueFor("int_ratio")
	local inner_radius = ability:GetSpecialValueFor("inner_radius")
	local outer_radius = ability:GetSpecialValueFor("outer_radius")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", delay)



	Timers:CreateTimer(delay, function()
		if IsValidEntity(caster) and caster:IsAlive() then
			caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
			local damage = base_dmg + caster:GetMana() + hero:GetIntellect() * int_ratio 
			--if hero.IsTerritoryImproved then damage = damage + 300 end
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, outer_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() then
					local distance = (caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D()
					local multiplier = 1
					if distance > inner_radius then
						-- 2/3 damage at max distance
						multiplier = 1 - (distance - inner_radius) / (outer_radius - inner_radius) / 3
					end
					DoDamage(hero, v, damage * multiplier, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				end
			end
			-- particle
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- height of the bolt
			ParticleManager:SetParticleControl(particle, 1, Vector(outer_radius, 0, 0)) -- height of the bolt
			ParticleManager:ReleaseParticleIndex(particle)
			caster:Execute(ability, caster)
		end
		return
	end)
end

function OnManaDrainCast(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetUnitName() == caster:GetUnitName() then 
		caster:Stop()
		--ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target_Self")
		return
	end
	--PrintTable(keys)
	--print(direction)
	--local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	--caster:SetForwardVector(direction)
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize drain mana and run a timer to check if it is resolved

	caster : Workshop
	target : Target
	hero : Caster(5th)
]]
function OnManaDrainStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetOwner()
	local ability = keys.ability
	local particleName = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
	local int_ratio = ability:GetSpecialValueFor("int_ratio")
	local tick_interval = ability:GetSpecialValueFor("tick_interval")
	local break_distance = ability:GetSpecialValueFor("break_distance")

	caster.ManaDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)
	caster.ManaDrainTarget = target

	keys.ManaPerSec = math.floor(keys.ManaPerSec + (hero:GetIntellect() * int_ratio))

	caster.IsManaDrainChanneling = true
	local dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	-- If target is same team, grant mana
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		Timers:CreateTimer(function()  
			if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
			dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			if caster.IsManaDrainChanneling == false or caster:GetMana() == 0 or target:GetMana() == target:GetMaxMana() or dist > break_distance or not target:CanEntityBeSeenByMyTeam(caster) then 
				keys.ability:EndChannel(false)
				return 
			end
			caster:SpendMana(math.floor(keys.ManaPerSec * tick_interval), ability)
			target:GiveMana(math.floor(keys.ManaPerSec * tick_interval)) 
			return tick_interval
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	else
		Timers:CreateTimer(function()  
			if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
			dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			if caster.IsManaDrainChanneling == false or target:GetMana() == 0 or caster:GetMana() == caster:GetMaxMana() or dist > break_distance or not target:CanEntityBeSeenByMyTeam(caster) then 
				keys.ability:EndChannel(false)
				return 
			end
			target:SpendMana(math.floor(keys.ManaPerSec * tick_interval), ability)
			caster:GiveMana(math.floor(keys.ManaPerSec * tick_interval)) 
			return tick_interval
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end

end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	End Mana Drain
]]
function OnManaDrainEnd(keys)
	local caster = keys.caster
	caster.IsManaDrainChanneling = false
	ParticleManager:DestroyParticle(caster.ManaDrainParticle,false) 
	caster.ManaDrainTarget:StopSound("Hero_Lion.ManaDrain")
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Skeleton Summon

	caster : Workshop
	ability : The respective item

	Warrior parameters : keys.Health/keys.Damag/keys.ArmorRatio/keys.HealthRatio/keys.MSRatio
	Archer parameters : keys.DamageRatio instead of ArmorRatio
]]
function OnSummonSkeleton(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local pid = caster:GetPlayerOwner():GetPlayerID()
	local unitname = nil
	local duration = ability:GetSpecialValueFor("duration")

	if caster.IsMobilized then return end 

	caster:GetItemInSlot(0):StartCooldown(10)
	caster:GetItemInSlot(1):StartCooldown(10)

	if ability:GetName()  == "item_summon_skeleton_warrior"  then
		unitname =  "medea_skeleton_warrior"
	elseif ability:GetName()  == "item_summon_skeleton_archer" then
		unitname = "medea_skeleton_archer"
	end

	-- Summon spooky skeletal 
	local spooky = CreateUnitByName(unitname, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	spooky:SetControllableByPlayer(pid, true)
	spooky:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	LevelAllAbility(spooky)
	FindClearSpaceForUnit(spooky, spooky:GetAbsOrigin(), true)
	spooky:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})

	-- Set skeletal stat according to parameters
	spooky:SetMaxHealth(keys.Health)
	spooky:SetBaseMaxHealth(keys.Health)
	spooky:SetHealth(keys.Health)
	spooky:SetBaseDamageMax(keys.Damage)
	spooky:SetBaseDamageMin(keys.Damage)

	-- Bonus properties(give it 0.1 sec delay just in case)
	Timers:CreateTimer(0.1, function()
	
		spooky:SetMaxHealth(spooky:GetMaxHealth() + hero:GetIntellect()*keys.HealthRatio)
		spooky:SetHealth(spooky:GetMaxHealth())
		spooky:SetBaseMoveSpeed(spooky:GetBaseMoveSpeed() + hero:GetIntellect()*keys.MSRatio)
		if unitname == "medea_skeleton_warrior" then
			spooky:SetPhysicalArmorBaseValue(spooky:GetPhysicalArmorValue(false) + hero:GetIntellect()*keys.ArmorRatio)
		else
			spooky:SetBaseDamageMax(spooky:GetBaseDamageMin() + hero:GetIntellect()*keys.DamageRatio)
			spooky:SetBaseDamageMin(spooky:GetBaseDamageMax() + hero:GetIntellect()*keys.DamageRatio)
		end 
	end)


	
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Dragon Summon

	caster : Workshop
	ability : The respective item
]]
function OnSummonDragon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetOwner()
	local pid = caster:GetPlayerOwnerID()
	local duration = ability:GetSpecialValueFor("duration")
	local lvl_gain = ability:GetSpecialValueFor("lvl_gain")

	if caster.IsMobilized then return end 

	-- Kill the existing dragon
	if caster.dragon and IsValidEntity(caster.dragon) and not caster.dragon:IsNull() and caster.dragon:IsAlive() then 
		if hero:HasModifier("modifier_mount_caster") then 
			hero:RemoveModifierByName("modifier_mount_caster")
		end
		caster.dragon:ForceKill(true)
	end
	--[[local dragFind = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(dragFind) do
		print(v:GetClassname())
		if v:GetUnitName() == "medea_ancient_dragon" then
			v:ForceKill(true)
		end
	end]]

	local drag = CreateUnitByName("medea_ancient_dragon", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	--drag:SetPlayerID(pid) 
	caster.dragon = drag
	drag:SetControllableByPlayer(pid, true)
	drag:SetOwner(hero)
	LevelAllAbility(drag)
	FindClearSpaceForUnit(drag, drag:GetAbsOrigin(), true)
	drag:AddItem(CreateItem("item_caster_5th_mount" , nil, nil))
	drag:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})

	drag:SetMaxHealth(keys.Health)
	drag:SetHealth(keys.Health)
	drag:SetBaseDamageMax(keys.Damage)
	drag:SetBaseDamageMin(keys.Damage)
	drag:SetMana(drag:GetMaxMana() + hero:GetIntellect()*keys.ManaRatio)

	Timers:CreateTimer(0.1, function()
		-- Bonus properties(give it 0.1 sec delay just in case)
		local newHealth = drag:GetMaxHealth() + hero:GetIntellect()*keys.HealthRatio
		drag:SetMaxHealth(newHealth)
		drag:SetHealth(newHealth)
		drag:SetBaseMoveSpeed(drag:GetBaseMoveSpeed() + hero:GetIntellect()*keys.MSRatio)
	end)
	ability:ApplyDataDrivenModifier(hero, drag, "modifier_caster_dragon_checker", {Duration = duration - 0.1})

	local skillLevel = 1 + (hero:GetLevel() - 1)/lvl_gain
	if skillLevel > 8 then skillLevel = 8 end

	drag:FindAbilityByName("medea_dragon_frostbite"):SetLevel(skillLevel)
	drag:FindAbilityByName("medea_dragon_arcane_wrath"):SetLevel(skillLevel)
	drag:FindAbilityByName("medea_dragon_arcane_wrath"):SetActivated(false)
    local playerData = {
        transport = drag:entindex()
    }
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_summoned_transport", playerData )
    hero.IsMounted = false
	SendMountStatus(hero)
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Dragon Summon

	caster : Workshop
	ability : The respective item
]]
function CasterFarSight(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local hero = caster:GetOwner()
	local dist = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	local cast_range = ability:GetSpecialValueFor("cast_range")
	local duration = ability:GetSpecialValueFor("duration")

	if caster.IsMobilized then return end 

	if dist > cast_range then
		keys.ability:EndCooldown() 
		caster:GiveMana(100)
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Caster_Out_Of_Radius")
		return
	end

	local truesightdummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	truesightdummy:SetDayTimeVisionRange(radius)
	truesightdummy:SetNightTimeVisionRange(radius)
	truesightdummy:EmitSound("Hero_KeeperOfTheLight.BlindingLight") 

	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	
	Timers:CreateTimer(duration, function() DummyEnd(truesightdummy) return end)

	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_WORLDORIGIN, truesightdummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, truesightdummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_WORLDORIGIN, truesightdummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, truesightdummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	truesightdummy.circle_fx = circleFxIndex
	truesightdummy.dust_fx = dustFxIndex
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
			
	-- Destroy particle after delay
	Timers:CreateTimer( duration, function()
			ParticleManager:DestroyParticle( circleFxIndex, false )
			ParticleManager:DestroyParticle( dustFxIndex, false )
			ParticleManager:ReleaseParticleIndex( circleFxIndex )
			ParticleManager:ReleaseParticleIndex( dustFxIndex )
			return nil
		end
	)
end

function OnTerritoryMobilize(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetOwner()
	caster:RemoveModifierByName("modifier_territory_root")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mobilize", {})
	caster.IsMobilized = true

	
	caster:SwapAbilities("medea_territory_mana_drain", "fate_empty2", false, true)
	if hero.IsTerritoryImproved then
		caster:SwapAbilities("medea_territory_explosion_upgrade", "fate_empty3", false, true)
	else
		caster:SwapAbilities("medea_territory_explosion", "fate_empty3", false, true)
	end
	caster:SwapAbilities("medea_territory_mobilize", "medea_territory_immobilize", false, true) 
	caster:SwapAbilities("medea_territory_recall", "fate_empty4", false, true)
	caster:SwapAbilities("fate_empty_nothidden", "medea_territory_dimensional_jump", false, true)
end

function OnTerritoryImmobilize(keys)
	local caster = keys.caster
	local hero = caster:GetOwner()
	if caster.IsMobilized then 
		caster.IsMobilized = false
	else 
		return
	end
	caster:RemoveModifierByName("modifier_mobilize")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_territory_root", {}) 
	
	caster:SwapAbilities("medea_territory_mana_drain", "fate_empty2", true, false)
	if hero.IsTerritoryImproved then
		caster:SwapAbilities("medea_territory_explosion_upgrade", "fate_empty3", true, false)
	else
		caster:SwapAbilities("medea_territory_explosion", "fate_empty3", true, false)
	end
	caster:SwapAbilities("medea_territory_mobilize", "medea_territory_immobilize", true, false) 
	caster:SwapAbilities("medea_territory_recall", "fate_empty4", true, false)
	caster:SwapAbilities("fate_empty_nothidden", "medea_territory_dimensional_jump", true, false)
end

function OnDimensionalJump(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	local tParams = {
		bNavCheck = false,
	}
	AbilityBlink(caster, ability:GetCursorPosition(), ability:GetSpecialValueFor("distance"), tParams)
end

function OnTerritoryRecall(keys)
	local caster = keys.caster
	local target = caster:GetOwnerEntity()
    local ability = keys.ability

    ability:ApplyDataDrivenModifier(caster, target, "modifier_recall", {})

end

function OnRecallCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	caster.IsRecallCanceled = false
end

function OnRecallTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local hero = caster:GetOwner()
	caster.IsRecallCanceled = true
	hero:RemoveModifierByName("modifier_recall")
end

function OnRecallDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local hero = caster:GetOwner()
	if caster.IsRecallCanceled == false then 
		local location = caster:GetAbsOrigin()

        local pcTeleportOut = ParticleManager:CreateParticle("particles/custom/caster/caster_recall_out.vpcf", PATTACH_CUSTOMORIGIN, hero)
        ParticleManager:SetParticleControl(pcTeleportOut, 0, hero:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(pcTeleportOut)

        hero:SetAbsOrigin(location)
        FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), true)

        local pcTeleportIn = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:ReleaseParticleIndex(pcTeleportIn)
    end
end

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Issues stop order when Skeleton attempts attack a ward
]]
function StopAttack(keys)
	local caster = keys.caster
	local target = keys.target
	--if target:GetUnitName() == "ward_familiar" then caster:Stop() end
end 

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Applies stun when Skeleton's bash is successful
]]
function OnSkeleBashSucceed(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("bash_damage")
	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.BashDuration})
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	caster:Kill(ability, caster)
end

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Launch the breath of ice frontward
]]
function OnFrostbiteStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPos = keys.target_points[1] 
	local direction = targetPos - caster:GetAbsOrigin()
	direction = direction/direction:Length2D()
	local distance = ability:GetSpecialValueFor("distance")

	local icebreath = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 1000,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance - keys.EndRadius, -- We need this to take end radius of projectile into account
        fStartRadius = keys.EndRadius,
        fEndRadius = keys.EndRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 700
	}
	projectile = ProjectileManager:CreateLinearProjectile(icebreath)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl( pfx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pfx, 1, direction * 700 * 1.333 )
	ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( pfx, 9, caster:GetAbsOrigin() )

	caster:EmitSound("Hero_Jakiro.DualBreath")

	Timers:CreateTimer(0.8, function()
		ParticleManager:DestroyParticle(pfx, false)
	end)
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Apply damage and root to enemies hit by ice breath
]]
function OnFrostbiteHit(keys)
	local caster = keys.caster 
	local target = keys.target
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_frostbite_root", {})
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Attach effect when Arcane Wrath starts casting
]]
function OnArcaneWrathCast(keys)
	local caster = keys.caster 
	local pid = caster:GetPlayerOwnerID()
	local hero = caster:GetOwner()
	if not hero.IsMounted then
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return
	end

	local pfx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_casterribbons_arcana1.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( pfx, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z+300))
	caster:EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(pfx, false)
	end)
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	BOOM
]]
function OnArcaneWrathStart(keys)
	local caster = keys.caster
	local targetPos = keys.target_points[1]
	--provide vision
	local truesightdummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	truesightdummy:SetDayTimeVisionRange(keys.Radius)
	truesightdummy:SetNightTimeVisionRange(keys.Radius)
	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	Timers:CreateTimer(keys.StunDuration, function() DummyEnd(truesightdummy) return end)

    local targets = FindUnitsInRadius(caster:GetTeam(), targetPos, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
    	if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) then
    		v:AddNewModifier(caster, v, "modifier_stunned", {Duration = keys.StunDuration})
    	end
    	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    	
    end


	EmitSoundOnLocationWithCaster(targetPos, "Hero_ObsidianDestroyer.SanityEclipse.Cast", caster)
	local ArcaneWrathFx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_WORLDORIGIN, caster)
  	ParticleManager:SetParticleControl(ArcaneWrathFx, 0, targetPos) 
	ParticleManager:SetParticleControl(ArcaneWrathFx, 1, Vector(400, 0, 0)) 

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(ArcaneWrathFx, false)
	end)
end

function OnMountStart(keys)
	local caster = keys.caster
	local hero = caster:GetOwner()
	Timers:CreateTimer(0.2, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsMounted then
				-- If Caster is attempting to unmount on not traversable terrain,
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(hero:GetPlayerOwnerID(), "#Cannot_Unmount")
					return								
				else
					caster:FindAbilityByName("medea_dragon_arcane_wrath"):SetActivated(false)
					--caster:SwapAbilities("medea_dragon_arcane_wrath", "fate_empty2", true, true) 
					hero:RemoveModifierByName("modifier_mount_caster")
					caster:RemoveModifierByName("modifier_mount")
					hero.IsMounted = false
					SendMountStatus(hero)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then
				hero.IsMounted = true
				caster:FindAbilityByName("medea_dragon_arcane_wrath"):SetActivated(true)
				--caster:SwapAbilities("medea_dragon_arcane_wrath", "fate_empty2", true, true) 
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_mount_caster", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mount", {}) 
				SendMountStatus(hero)

				return
			end 
		end
	end)
end


--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Positions Caster on Dragon's back every tick as long as Caster is mounted
]]
function MountFollow(keys)
	local caster = keys.caster
	local hero = caster:GetOwner()
	if not caster:IsNull() and IsValidEntity(caster) then
		hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,460))
		hero:SetForwardVector(caster:GetForwardVector())
	end
end
--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Un-mounts Caster
]]
function OnMountDeath(keys)
	local caster = keys.caster
	local hero = caster:GetOwner()
	hero:RemoveModifierByName("modifier_mount_caster")
	caster:SwapAbilities("medea_dragon_arcane_wrath", "fate_empty2", false, true) 
	hero.IsMounted = false
	SendMountStatus(hero)
end

function OnItemStart(keys)
	local caster = keys.caster
	local randomitem = math.random(100)
	local item = nil
	local ability = keys.ability 
	local b_chance = ability:GetSpecialValueFor("b_chance")
	local a_chance = ability:GetSpecialValueFor("a_chance")
	local s_chance = ability:GetSpecialValueFor("s_chance")
	local b_chance_near_workshop = ability:GetSpecialValueFor("b_chance_near_workshop")
	local a_chance_near_workshop = ability:GetSpecialValueFor("a_chance_near_workshop")
	local s_chance_near_workshop = ability:GetSpecialValueFor("s_chance_near_workshop")
	local workshop_distance = ability:GetSpecialValueFor("workshop_distance")

	for i = 0,14 do
		if i == 14 and caster:GetItemInSlot(i) ~= nil then 
			ability:EndCooldown()
			caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Item_Slot")
			return 
		end
		if caster:GetItemInSlot(i) == nil then
            break 
        end
    end

	if (caster.IsTerritoryPresent and (caster.Territory:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < workshop_distance) --[[or caster.IsPrivilegeImproved]] then 
		if randomitem <= s_chance_near_workshop then 
			item = CreateItem("item_s_scroll", nil, nil) 
		elseif randomitem <= s_chance_near_workshop + a_chance_near_workshop then
			item = CreateItem("item_a_scroll", nil, nil) 
		elseif randomitem <= s_chance_near_workshop + a_chance_near_workshop + b_chance_near_workshop then
			item = CreateItem("item_b_scroll", nil, nil) 
		end	
	else 
		if randomitem <= s_chance then 
			item = CreateItem("item_s_scroll", nil, nil) 
		elseif randomitem <= s_chance + a_chance then
			item = CreateItem("item_a_scroll", nil, nil) 
		elseif randomitem <= s_chance + a_chance + b_chance then
			item = CreateItem("item_b_scroll", nil, nil) 
		end
	end

	caster:AddItem(item)
	CheckItemCombination(caster)
	CheckItemCombinationInStash(caster)
    SaveStashState(caster)
end

function OnArgosStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	if caster.IsArgosImproved then 
		--keys.MaxShield = keys.MaxShield + 150 
		--keys.ShieldAmount = keys.ShieldAmount + 100
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_argos_armor", {})
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_argos_shield", {})
	
	if caster.argosShieldAmount == nil then 
		caster.argosShieldAmount = keys.ShieldAmount
	else
		caster.argosShieldAmount = caster.argosShieldAmount + keys.ShieldAmount
	end
	if caster.argosShieldAmount > keys.MaxShield then
		caster.argosShieldAmount = keys.MaxShield
	end
	
	-- Create particle
	if caster.argosDurabilityParticleIndex == nil then
		local prev_amount = 0.0
		Timers:CreateTimer( function()
				-- Check if shield still valid
				if caster.argosShieldAmount > 0 and caster:HasModifier( "modifier_argos_shield" ) then
					-- Check if it should update
					if prev_amount ~= caster.argosShieldAmount then
						-- Change particle
						local digit = 0
						if caster.argosShieldAmount > 999 then
							digit = 4
						elseif caster.argosShieldAmount > 99 then
							digit = 3
						elseif caster.argosShieldAmount > 9 then
							digit = 2
						else
							digit = 1
						end
						if caster.argosDurabilityParticleIndex ~= nil then
							-- Destroy previous
							ParticleManager:DestroyParticle( caster.argosDurabilityParticleIndex, true )
							ParticleManager:ReleaseParticleIndex( caster.argosDurabilityParticleIndex )
						end
						-- Create new one
						caster.argosDurabilityParticleIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_argos_durability.vpcf", PATTACH_CUSTOMORIGIN, caster )
						ParticleManager:SetParticleControlEnt( caster.argosDurabilityParticleIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 1, Vector( 0, math.floor( caster.argosShieldAmount ), 0 ) )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 2, Vector( 1, digit, 0 ) )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 3, Vector( 100, 100, 255 ) )
						
						prev_amount = caster.argosShieldAmount	
					end
					
					return 0.1
				else
					if caster.argosDurabilityParticleIndex ~= nil then
						ParticleManager:DestroyParticle( caster.argosDurabilityParticleIndex, true )
						ParticleManager:ReleaseParticleIndex( caster.argosDurabilityParticleIndex )
						caster.argosDurabilityParticleIndex = nil
					end
					return nil
				end
			end
		)
	end
end

function OnArgosDamaged(keys)
	local caster = keys.caster 
	local currentHealth = caster:GetHealth() 

	caster.argosShieldAmount = caster.argosShieldAmount - keys.DamageTaken
	if caster.argosShieldAmount <= 0 then
		if currentHealth + caster.argosShieldAmount <= 0 then
			print("lethal")
		else
			print("argos broken, but not lethal")
			caster:RemoveModifierByName("modifier_argos_shield")
			caster:SetHealth(currentHealth + keys.DamageTaken + caster.argosShieldAmount)
			caster.argosShieldAmount = 0
		end
	else
		print("argos not broken, remaining shield : " .. caster.argosShieldAmount)
		caster:SetHealth(currentHealth + keys.DamageTaken)
	end
end

function OnAncientStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hecatic_graea_combo_window") then 
		caster:RemoveModifierByName("modifier_hecatic_graea_combo_window")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ancient_magic_check", {})
	ability:ToggleAbility()
end

function OnAncientOpen(keys)
	local caster = keys.caster 	

	if caster.IsWitchCraftAcquired then
		if caster.IsArgosImproved then
			caster:SwapAbilities("medea_wall_of_flame_upgrade", "medea_argos_upgrade", true, false) 
		else
			caster:SwapAbilities("medea_wall_of_flame_upgrade", "medea_argos", true, false) 
		end
		caster:SwapAbilities("medea_silence", "medea_ancient_magic_upgrade", true, false) 
		caster:SwapAbilities("medea_sacrifice", "medea_hecatic_graea_upgrade", true, false) 
		if caster.IsRBImproved then
			caster:SwapAbilities("medea_divine_words_upgrade", "medea_rule_breaker_upgrade", true, false)
		else
			caster:SwapAbilities("medea_divine_words_upgrade", "medea_rule_breaker", true, false)
		end
	else
		if caster.IsArgosImproved then
			caster:SwapAbilities("medea_wall_of_flame", "medea_argos_upgrade", true, false) 
		else
			caster:SwapAbilities("medea_wall_of_flame", "medea_argos", true, false) 
		end
		caster:SwapAbilities("medea_silence", "medea_ancient_magic", true, false) 
		caster:SwapAbilities("medea_sacrifice", "medea_hecatic_graea", true, false) 
		if caster.IsRBImproved then
			caster:SwapAbilities("medea_divine_words", "medea_rule_breaker_upgrade", true, false)
		else
			caster:SwapAbilities("medea_divine_words", "medea_rule_breaker", true, false)
		end
	end
	
	if caster.IsTerritoryImproved then
		caster:SwapAbilities("medea_mana_transfer", "medea_territory_creation_upgrade", true, false) 
	else
		caster:SwapAbilities("medea_mana_transfer", "medea_territory_creation", true, false) 
	end
	caster:SwapAbilities("medea_close_spellbook", "medea_item_construction", true, false)
end

function OnAncientClose(keys)
	local caster = keys.caster 

	
	if caster.IsWitchCraftAcquired then
		if caster.IsArgosImproved then
			caster:SwapAbilities("medea_wall_of_flame_upgrade", "medea_argos_upgrade", false, true) 
		else
			caster:SwapAbilities("medea_wall_of_flame_upgrade", "medea_argos", false, true) 
		end
		caster:SwapAbilities("medea_silence", "medea_ancient_magic_upgrade", false, true) 
		caster:SwapAbilities("medea_sacrifice", "medea_hecatic_graea_upgrade", false, true) 
		if caster.IsRBImproved then
			caster:SwapAbilities("medea_divine_words_upgrade", "medea_rule_breaker_upgrade", false, true)
		else
			caster:SwapAbilities("medea_divine_words_upgrade", "medea_rule_breaker", false, true)
		end
	else
		if caster.IsArgosImproved then
			caster:SwapAbilities("medea_wall_of_flame", "medea_argos_upgrade", false, true) 
		else
			caster:SwapAbilities("medea_wall_of_flame", "medea_argos", false, true) 
		end
		caster:SwapAbilities("medea_silence", "medea_ancient_magic", false, true) 
		caster:SwapAbilities("medea_sacrifice", "medea_hecatic_graea", false, true) 
		if caster.IsRBImproved then
			caster:SwapAbilities("medea_divine_words", "medea_rule_breaker_upgrade", false, true)
		else
			caster:SwapAbilities("medea_divine_words", "medea_rule_breaker", false, true)
		end
	end
	if caster.IsTerritoryImproved then
		caster:SwapAbilities("medea_mana_transfer", "medea_territory_creation_upgrade", false, true) 
	else
		caster:SwapAbilities("medea_mana_transfer", "medea_territory_creation", false, true) 
	end
	caster:SwapAbilities("medea_close_spellbook", "medea_item_construction", false, true)
end

function AncientLevelUp(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:FindAbilityByName("medea_silence"):SetLevel(ability:GetLevel())
	if caster.IsWitchCraftAcquired then
		caster:FindAbilityByName("medea_divine_words_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("medea_wall_of_flame_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("medea_divine_words"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("medea_wall_of_flame"):SetLevel(ability:GetLevel())
	end
	caster:FindAbilityByName("medea_mana_transfer"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("medea_sacrifice"):SetLevel(ability:GetLevel())
end

function OnFirewallStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	if caster.IsWitchCraftAcquired then 
		local int_ratio = keys.ability:GetSpecialValueFor("int_ratio")
		keys.Damage = keys.Damage + caster:GetIntellect()*int_ratio 
	end
	local ability = keys.ability 
	local range = ability:GetSpecialValueFor("radius")

	-- Flame spread particle
	local caster = keys.caster
	local angle = 0
	local increment_factor = 45
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector() * 1150
	local destination = origin + forward
	local ubwflame = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = 500,
        vSpawnOrigin = origin,
        fDistance = range,
        fStartRadius = 500,
        fEndRadius = 500,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = forward 
	}
	for i=1, 8 do
		-- Start rotating
		local theta = ( angle - i * increment_factor ) * math.pi / 180
		local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
		local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y
		local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
		ubwflame.vVelocity = new_forward * 500
		local projectile = ProjectileManager:CreateLinearProjectile(ubwflame)
	end 
	

    local targets = FindUnitsInRadius(caster:GetTeam(), casterPos, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
    	if IsValidEntity(v) and not v:IsNull() and v:GetName() ~= "npc_dota_ward_base" then
	    	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
		    	if not IsKnockbackImmune(v) then
					giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
					local pushback = Physics:Unit(v)
					v:PreventDI()
					v:SetPhysicsFriction(0)
					v:SetPhysicsVelocity((v:GetAbsOrigin() - casterPos):Normalized() * keys.Pushback * 2)
					v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
					v:FollowNavMesh(false)

					Timers:CreateTimer(0.5, function()  
						v:PreventDI(false)
						v:SetPhysicsVelocity(Vector(0,0,0))
						v:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
						return 
					end)
				end
			end
		end
	end
end

function OnSilenceStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
    	if IsValidEntity(v) and not v:IsNull() then
			v:AddNewModifier(caster, nil, "modifier_silence", {duration=keys.Duration})
			v:AddNewModifier(caster, nil, "modifier_disarmed", {duration=keys.Duration})
		end
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0 , targetPoint)
	ParticleManager:SetParticleControl(particle, 1 , Vector(300,0,0))
	ParticleManager:SetParticleControl(particle, 3 , Vector(300,0,0))

	caster:EmitSound("Medea_Skill_" .. math.random(4,6))

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(particle, false)
		return nil
	end)
end

function OnDWStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local rainCount = 0
	local damage = keys.Damage
	local max_count = keys.ability:GetSpecialValueFor("max_count")
	local stun_duration = keys.ability:GetSpecialValueFor("stun_duration")
	if caster.IsWitchCraftAcquired then 
		local int_ratio = keys.ability:GetSpecialValueFor("int_ratio")
		damage = damage + caster:GetIntellect() * int_ratio 
	end

	caster:EmitSound("Medea_Skill_" .. math.random(1,3))

	--local bonus_beams = math.floor(caster:GetIntellect() / 40)
	--print(bonus_beams)

    Timers:CreateTimer(0.5, function()
    	if rainCount == max_count then return end
    	caster:EmitSound("Hero_Luna.LucentBeam.Target")
    	local vecLocation = targetPoint + RandomVector(50)
		--[[local dummy = CreateUnitByName("dummy_unit", vecLocation, false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		dummy:SetAbsOrigin(vecLocation)]]
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, vecLocation)
		ParticleManager:SetParticleControl(particle, 1, vecLocation)
		ParticleManager:SetParticleControl(particle, 5, vecLocation)
		ParticleManager:SetParticleControl(particle, 6, vecLocation)
		--[[Timers:CreateTimer(2.0, function()
			if IsValidEntity(dummy) then
				dummy:RemoveSelf()
			end
		end)]]

		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

        for k,v in pairs(targets) do
        	if IsValidEntity(v) and not v:IsNull() then
	        	if v:HasModifier("modifier_c_rule_breaker") then
	        		v:AddNewModifier(caster, keys.ability, "modifier_stunned", { Duration = stun_duration })
	        	else
	        		v:AddNewModifier(caster, keys.ability, "modifier_stunned", { Duration = 0.01 })
	        	end
	        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        end
		end
		rainCount = rainCount + 1
      	return 0.35
    end
    )
end

function OnSacrificeStart(keys)
	local caster = keys.caster
	caster.SacFx = ParticleManager:CreateParticle("particles/custom/caster/sacrifice/caster_sacrifice_indicator.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( caster.SacFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl( caster.SacFx, 1, Vector(keys.Radius,0,0))

	caster:EmitSound("Medea_Skill_" .. math.random(7,8))
end

function RemoveSacrificeModifier(keys)
	local caster = keys.caster
	keys.caster:RemoveModifierByName("modifier_big_bad_voodoo_channeling")
	keys.caster:RemoveModifierByName("modifier_big_bad_voodoo_ally")
	Timers:CreateTimer(1.0, function()
	keys.caster:RemoveModifierByName("modifier_big_bad_voodoo_damage_bonus")
	end)

	ParticleManager:DestroyParticle( caster.SacFx, false )
	ParticleManager:ReleaseParticleIndex( caster.SacFx )
	caster.SacFx = nil
end

function MaledictStop( event )
	local caster = event.caster
	
	caster:StopSound("Hero_WitchDoctor.Maledict_Loop")
end

function OnSacrificeEnd(keys)
	local caster = keys.caster
	sac = false
	caster:RemoveModifierByName("modifier_sac_check")
end

function CreateSacrificeAllyParticle(keys)
	ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_buff_j.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
end

function OnMTStart(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.Duration
	local manatransferred = keys.Manatransferred / 2
	local durCount = 0
	if target == caster or IsManaLess(target) then 
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target_Self")
		return
	end

    local pcBeam = ParticleManager:CreateParticle("particles/econ/items/puck/puck_alliance_set/puck_dreamcoil_tether_aproset.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(pcBeam, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pcBeam, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    -- Laziness...
    caster.ManaTransferParticle = pcBeam
    caster:EmitSound("Hero_KeeperOfTheLight.Illuminate.Charge")

	caster.IsManaTransferActive = true
	Timers:CreateTimer(function()
		if durCount > duration then return end
		if caster:GetMana() == 0 then return end
		if target:GetMaxMana() == target:GetMana() then return end
		if caster.IsManaTransferActive then 
			local currentMana = caster:GetMana()
			local targetCurrentMana = target:GetMana()
			caster:SetMana(currentMana - manatransferred)
			target:SetMana(targetCurrentMana + manatransferred)
			durCount = durCount + 0.5
		else return end
	    return 0.5
    end
    )
end

function OnMTEnd(keys)
	local caster = keys.caster
	caster.IsManaTransferActive = false
    ParticleManager:DestroyParticle(caster.ManaTransferParticle, false)
    ParticleManager:ReleaseParticleIndex(caster.ManaTransferParticle)
    caster:StopSound("Hero_KeeperOfTheLight.Illuminate.Charge")
end

function OnAncientClosed(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ancient_magic_check")
end

function OnRBCreate(keys)
	local caster = keys.caster 
	local cast_time = keys.ability:GetCastPoint()
	if caster:GetName() == "npc_dota_hero_crystal_maiden" and (caster:HasModifier("modifier_alternate_01") or caster:HasModifier("modifier_alternate_02")) then
		Attachments:AttachProp(caster, "attach_attack2", "models/medea/medea_rule_breaker.vmdl")
	end
end

function OnRBDestroy(keys)
	local caster = keys.caster 
	local rulebreaker = Attachments:GetCurrentAttachment(caster, "attach_attack2")
	if rulebreaker ~= nil and not rulebreaker:IsNull() then
		rulebreaker:RemoveSelf()
	end
end

function OnRBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local revoke = keys.ability:GetSpecialValueFor("revoke")
	local ply = caster:GetPlayerOwner()
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	ApplyStrongDispel(target)
	caster:EmitSound("Medea_Rule_Breaker_" .. math.random(1,2))		
	ability:ApplyDataDrivenModifier(caster, target, "modifier_c_rule_breaker", {}) 


	if caster.IsRBImproved then
		local mana_steal = keys.ability:GetSpecialValueFor("mana_steal")
		giveUnitDataDrivenModifier(caster, target, "revoked", revoke)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_dagger_of_treachery", {}) 

		if target.MasterUnit:GetMana() > mana_steal then
			target.MasterUnit:SetMana(target.MasterUnit:GetMana() - mana_steal) 
			target.MasterUnit2:SetMana(target.MasterUnit2:GetMana() - mana_steal) 
				
			caster.MasterUnit:SetMana(caster.MasterUnit:GetMana() + mana_steal)
			caster.MasterUnit2:SetMana(caster.MasterUnit2:GetMana() + mana_steal)
		end		
	else
		giveUnitDataDrivenModifier(caster, target, "revoked", revoke)
	end
	
	CasterCheckCombo(caster,ability)	

	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.StunDuration})
	giveUnitDataDrivenModifier(caster, target, "silenced", keys.StunDuration)
end

function OnRBSealStolen(keys)
	local victim = keys.unit
	local caster = keys.caster
	local ability = keys.ability
	local hp_steal = keys.ability:GetSpecialValueFor("hp_steal")

	victim:EmitSound("Hero_Silencer.LastWord.Cast")
	caster:EmitSound("Medea_Steal_" .. math.random(1,2))

	if victim.MasterUnit:GetHealth() > hp_steal then
		victim.MasterUnit:SetHealth(victim.MasterUnit:GetHealth() - hp_steal) 
		--victim.MasterUnit2:SetHealth(victim.MasterUnit2:GetHealth() - 1) 
		
		if caster.MasterUnit:GetHealth() < caster.MasterUnit:GetMaxHealth() then
			caster.MasterUnit:SetHealth(caster.MasterUnit:GetHealth() + hp_steal)
			--caster.MasterUnit2:SetHealth(caster.MasterUnit2:GetHealth() + 1)
		end
	end
end

function OnHGStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = keys.BoltAmount
	local travelTime = 0.7
	local ascendTime = travelTime+2.0
	local descendTime = ascendTime+0.75
	local diff = (targetPoint - caster:GetAbsOrigin()) * 1/travelTime
	if caster.IsWitchCraftAcquired then
		local int_ratio = keys.ability:GetSpecialValueFor("int_ratio")
		keys.Damage = keys.Damage + caster:GetIntellect()*int_ratio
	end 

	local initTargets = 0
	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) or not IsInSameRealm(caster:GetOrigin(), targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(800) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	--keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_anim", {}) 
	StartAnimation(caster, {duration=descendTime, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	--EmitGlobalSound("Caster.Hecatic") 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", descendTime)
	Timers:CreateTimer(descendTime, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postdelay", 0.15)
	end)

	local high = 1000
	if caster:HasModifier("modifier_alternate_01") then
		high = 200 
	end

	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), high))
		--allows caster to jump over walls
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)

	Timers:CreateTimer(travelTime, function()  
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
			--caster:SetAbsOrigin(caster:GetGroundPosition(caster:GetAbsOrigin(), caster)+Vector(0,0,1000))
	return end) 
	
	Timers:CreateTimer(ascendTime, function()  
		caster:SetPhysicsVelocity( Vector( 0, 0, math.min(0,50 - high) ) )
	return end) 

	Timers:CreateTimer(descendTime, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)

	local isFirstLoop = false
	Timers:CreateTimer(0.7, function()
		-- For the first round of shots, find all servants within AoE and guarantee one ray hit
		if isFirstLoop == false then 
			isFirstLoop = true
			initTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(initTargets) do
				DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, v:GetAbsOrigin(), "particles/custom/caster/hecatic_graea/ray.vpcf")
			end
			maxBolt = maxBolt - #initTargets
		else
			if maxBolt <= boltCount then return end
		end
		local random = RandomInt(1, 100)

		local rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		while GridNav:IsBlocked(rayTarget) or not GridNav:IsTraversable(rayTarget) do
			rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		end
		if random <= 3 then 
 			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 	if targets[1] == nil then 
		 		rayTarget = rayTarget
		 	else
		 		rayTarget = targets[1]:GetAbsOrigin()
		 	end
		end
		DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, rayTarget, "particles/custom/caster/hecatic_graea/ray.vpcf")
	    boltCount = boltCount + 1
		return 0.1
    end
    )
	Timers:CreateTimer(1.0, function() 		
		if caster:HasModifier('modifier_alternate_03') then 
			EmitGlobalSound("Medea-Illya-R")
		else
			EmitGlobalSound("Caster.Hecatic")
		end	
		EmitGlobalSound("Caster.Hecatic_Spread")
		caster:EmitSound("Misc.Crash") 
		return
	end)
end

function DropRay(caster, damage, radius, ability, targetPoint, particle)
	local casterLocation = caster:GetAbsOrigin()
	if caster:HasModifier("modifier_alternate_01") then 
		casterLocation = casterLocation + Vector(0,0,550)
	end
	
	-- print(damage)
	-- Particle
	local fxIndex = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(fxIndex, 0, targetPoint)

	local portalLocation = casterLocation + (targetPoint - casterLocation):Normalized() * 300
	portalLocation.z = casterLocation.z
	ParticleManager:SetParticleControl(fxIndex, 4, portalLocation)

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(fxIndex, false)
		ParticleManager:ReleaseParticleIndex(fxIndex)
	end)

	local casterDirection = (portalLocation - targetPoint):Normalized()
	casterDirection.x = casterDirection.x * -1
	casterDirection.y = casterDirection.y * -1

	--DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, radius, true, 0.5)
		
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) then
    		v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 0.1})
    	end
    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    	
	end
end

function OnHGPStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = 10
	local barrageRadius = ability:GetSpecialValueFor("lasthit_radius")
	local lasthit_damage = ability:GetSpecialValueFor("lasthit_damage")
	local stun = ability:GetSpecialValueFor("stun")
	local travelTime = 0.7
	local ascendTime = travelTime+4.0
	local descendTime = ascendTime+0.75
	if caster.IsWitchCraftAcquired then 
		local int_ratio = ability:GetSpecialValueFor("int_ratio")
		keys.Damage = keys.Damage + caster:GetIntellect()*int_ratio 
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(1)) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("medea_hecatic_graea_powered")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_powered_cooldown", {duration = ability:GetCooldown(1)})
	caster:RemoveModifierByName("modifier_hecatic_graea_combo_window")

	local HGAbility = caster:FindAbilityByName("medea_hecatic_graea")
	if caster.IsWitchCraftAcquired then 
		HGAbility = caster:FindAbilityByName("medea_hecatic_graea_upgrade")
	end
	local HGCooldown = HGAbility:GetCooldown(HGAbility:GetLevel())
	HGAbility:StartCooldown(HGCooldown)

	local high = 1000
	if caster:HasModifier("modifier_alternate_01") then
		high = 0 
	end

	StartAnimation(caster, {duration=descendTime, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_anim", {}) 
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", descendTime)
	local diff = (targetPoint - caster:GetAbsOrigin()) * 1/travelTime
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), high))
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)
	Timers:CreateTimer(travelTime, function()  
		ParticleManager:CreateParticle("particles/custom/screen_purple_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
	return end) 
	Timers:CreateTimer(ascendTime, function()  
		local dummy = CreateUnitByName( "sight_dummy_unit", caster:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber() );
		caster:SetPhysicsVelocity( Vector( 0, 0, math.min(0,50 - high) ) )
		if IsValidEntity(dummy) then
			dummy:RemoveSelf()
		end
	return end) 
	Timers:CreateTimer(descendTime, function()  
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)

	Timers:CreateTimer(travelTime, function()
		if boltCount == maxBolt then return end

		local rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		while GridNav:IsBlocked(rayTarget) or not GridNav:IsTraversable(rayTarget) do
			rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		end
		if RandomInt(1, 100) <= 10 then 
 			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		 	if targets[1] == nil then 
		 		rayTarget = rayTarget
		 	else
		 		rayTarget = targets[1]:GetAbsOrigin()
		 	end
		end
		DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, rayTarget, "particles/custom/caster/hecatic_graea_powered/ray.vpcf")

	    boltCount = boltCount + 1
		return 0.1
    end
    )

	
	Timers:CreateTimer(travelTime+2.5, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), GetGroundPosition(caster:GetAbsOrigin(), caster), nil, barrageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) then
        		v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun})
        	end
        	DoDamage(caster, v, lasthit_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        	
		end
  	  	local particle = ParticleManager:CreateParticle("particles/custom/caster/hecatic_graea_powered/area.vpcf", PATTACH_WORLDORIGIN, caster)
  	  	ParticleManager:SetParticleControl(particle, 0, GetGroundPosition(caster:GetAbsOrigin(), caster)) 
  	  	-- print(radius)
	    ParticleManager:SetParticleControl(particle, 1, Vector(barrageRadius * 2.5, 1, 1))
	    ParticleManager:SetParticleControl(particle, 2, Vector(barrageRadius * 75, 1, 1))
	    caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
	    EmitGlobalSound("Medea_Combo_1")
		-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, barrageRadius, true, 1)
		return
    end
    )

	-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, radius, true, 1)

	Timers:CreateTimer(1.0, function() 
		EmitGlobalSound("Caster.Hecatic_Spread") 
		EmitGlobalSound("Caster.Hecatic") 
		caster:EmitSound("Misc.Crash") 
	return end)
end

function CasterCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "medea_rule_breaker") and not caster:HasModifier("modifier_hecatic_graea_powered_cooldown") and not caster:HasModifier("modifier_ancient_magic_check") then
			if caster.IsWitchCraftAcquired then 
				if caster:FindAbilityByName("medea_hecatic_graea_upgrade"):IsCooldownReady() and caster:FindAbilityByName("medea_hecatic_graea_powered_upgrade"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_combo_window", {})
				end
			else
				if caster:FindAbilityByName("medea_hecatic_graea"):IsCooldownReady() and caster:FindAbilityByName("medea_hecatic_graea_powered"):IsCooldownReady() then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_combo_window", {})
				end
			end
		end
	end
end

function OnHecaticComboWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsWitchCraftAcquired then 
		caster:SwapAbilities("medea_hecatic_graea_powered_upgrade", "medea_hecatic_graea_upgrade", true, false)
	else
		caster:SwapAbilities("medea_hecatic_graea_powered", "medea_hecatic_graea", true, false)
	end
end

function OnHecaticComboWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsWitchCraftAcquired then 
		caster:SwapAbilities("medea_hecatic_graea_powered_upgrade", "medea_hecatic_graea_upgrade", false, true)
	else
		caster:SwapAbilities("medea_hecatic_graea_powered", "medea_hecatic_graea", false, true)
	end
end

function OnHecaticComboWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_hecatic_graea_combo_window")
end

function OnImproveTerritoryCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTerritoryImproved) then

		hero.IsTerritoryImproved = true

		if hero:HasModifier("modifier_ancient_magic_check") then 
			UpgradeAttribute(hero, "medea_territory_creation", "medea_territory_creation_upgrade", false)
		else
			UpgradeAttribute(hero, "medea_territory_creation", "medea_territory_creation_upgrade", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveArgosAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsArgosImproved) then

		hero.IsArgosImproved = true

		if hero:HasModifier("modifier_ancient_magic_check") then 
			UpgradeAttribute(hero, "medea_argos", "medea_argos_upgrade", false)
		else
			UpgradeAttribute(hero, "medea_argos", "medea_argos_upgrade", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnWitchCraftAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWitchCraftAcquired) then

		if hero:HasModifier("modifier_hecatic_graea_combo_window") then 
			hero:RemoveModifierByName("modifier_hecatic_graea_combo_window")
		end

		hero.IsWitchCraftAcquired = true

		UpgradeAttribute(hero, "medea_hecatic_graea_powered", "medea_hecatic_graea_powered_upgrade", false)

		if hero:HasModifier("modifier_ancient_magic_check") then 
			UpgradeAttribute(hero, "medea_hecatic_graea", "medea_hecatic_graea_upgrade", false)
			UpgradeAttribute(hero, "medea_ancient_magic", "medea_ancient_magic_upgrade", false)
			UpgradeAttribute(hero, "medea_divine_words", "medea_divine_words_upgrade", true)
			UpgradeAttribute(hero, "medea_wall_of_flame", "medea_wall_of_flame_upgrade", true)
		else
			UpgradeAttribute(hero, "medea_hecatic_graea", "medea_hecatic_graea_upgrade", true)
			UpgradeAttribute(hero, "medea_ancient_magic", "medea_ancient_magic_upgrade", true)
			UpgradeAttribute(hero, "medea_divine_words", "medea_divine_words_upgrade", false)
			UpgradeAttribute(hero, "medea_wall_of_flame", "medea_wall_of_flame_upgrade", false)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDaggerOfTreacheryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRBImproved) then

		hero.IsRBImproved = true

		if hero:HasModifier("modifier_ancient_magic_check") then 
			UpgradeAttribute(hero, "medea_rule_breaker", "medea_rule_breaker_upgrade", false)
		else
			UpgradeAttribute(hero, "medea_rule_breaker", "medea_rule_breaker_upgrade", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
