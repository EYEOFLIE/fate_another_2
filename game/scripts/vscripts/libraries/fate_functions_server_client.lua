CDOTA_BaseNPC = IsServer() and CDOTA_BaseNPC or C_DOTA_BaseNPC
--[:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]
Say = IsServer() and Say
--[:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]

CBaseEntity = IsServer() and CBaseEntity or C_BaseEntity
--[:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]
CDOTABaseAbility = IsServer() and CDOTABaseAbility or C_DOTABaseAbility
--[:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]
CDOTA_Ability_Lua = IsServer() and CDOTA_Ability_Lua or C_DOTA_Ability_Lua
--[:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]
CDOTA_Item_Lua = IsServer() and CDOTA_Item_Lua or C_DOTA_Item_Lua

CDOTA_BaseNPC_Hero = IsServer() and CDOTA_BaseNPC_Hero or C_DOTA_BaseNPC_Hero

if IsServer() then
    local VALVE_Say = Say
    Say = function(hEntity, StringMessage, bteamOnly)
        if hEntity == nil then 
        --    print('Say: no player')
            return nil
        else
            return VALVE_Say(hEntity, StringMessage, bteamOnly)
        end
    end
end

CCModifierStatic = {
    modifier_stunned = true,
    drag_pause = true,
    rooted = true,
    locked = true,
    revoked = true,
    disarmed = true,
    modifier_silence = true,
    modifier_disarmed = true, 
    modifier_c_rule_breaker = true,
    modifier_light_of_galatine_slow = true,
    modifier_mordred_mb_silence = true,
    modifier_enkidu_hold = true,
    modifier_atalanta_calydonian_hunt_root = true,
    modifier_atalanta_calydonian_hunt_slow = true,
    modifier_phoebus_slow = true, 
    modifier_kuro_rosa_slow = true,
    modifier_ceremonial_purge_slow = true,
    modifier_fly_slow = true,
    modifier_bathory_slap_slow = true,
    modifier_bathory_dragon_voice_slow = true,
    modifier_bathory_dragon_voice_deaf = true,
    modifier_bathory_cage_target = true,
    modifier_bloodfort_slow = true,
    --modifier_mystic_eye_enemy_upgrade = true,
    modifier_breaker_gorgon_stone = true,
    modifier_breaker_gorgon = true,
    modifier_bloodfort_seal = true,
    modifier_golden_wild_hunt_slow = true,
    modifier_blizzard_slow = true,
    --modifier_la_black_luna_silence = true,
    modifier_gilles_jellyfish_slow = true,
    modifier_white_queens_enigma_slow = true,
    modifier_plains_of_water_slow = true,
    modifier_doppelganger_lookaway_slow = true, 
    modifier_nameless_forest = true, 
    --modifier_amaterasu_slow_enemy = true,
    modifier_subterranean_grasp = true,
    modifier_mystic_shackle = true,
    modifier_tamamo_ice_debuff = true,
    modifier_zhuge_liang_wood_trap = true,
    modifier_zhuge_thunder_storm_slow = true,
    modifier_zhuge_liang_acid_slow = true,
    modifier_hans_red_shoes = true,
    modifier_fissure_strike_slow = true,
    modifier_courage_enemy_debuff_slow = true,
    modifier_madmans_roar_slow_strong = true,
    modifier_madmans_roar_slow_moderate = true,
    modifier_fran_lightning_slow = true,
    modifier_purge_the_unjust_slow = true,
    modifier_gods_resolution_slow = true, 
    modifier_mashu_bunker_bolt_slow = true, 
    modifier_mashu_taunt = true, 
}

local VALVE_AddNewModifier = CDOTA_BaseNPC.AddNewModifier
CDOTA_BaseNPC.AddNewModifier = function(self, hCaster, hAbility, pszScriptName, hModifierTable)
    if self:IsNull() or self == nil then
    	print('add new modifier error: no target')
    	return nil
    else
        local dur = hModifierTable["Duration"] or hModifierTable["duration"]
        if self:IsRealHero() and hCaster:IsRealHero() and dur ~= nil and hCaster:GetTeam() ~= self:GetTeam() and CCModifierStatic[pszScriptName] == true then 
            hCaster.ServStat:doControl(dur)
        end
        if IsImmuneToCC(self) and pszScriptName == "modifier_stunned" then 
            for k,v in pairs(hModifierTable) do
                if string.match(k, "uration") then 
                    
                    hModifierTable[k] = v * 0.5
                end
            end
        end
        return VALVE_AddNewModifier(self, hCaster, hAbility, pszScriptName, hModifierTable)
    end
end

if IsServer() then
    local VALVE_SetModifierStackCount = CDOTA_BaseNPC.SetModifierStackCount
    CDOTA_BaseNPC.SetModifierStackCount = function(self, pszScriptName, hCaster, nStackCount)
        if self:IsNull() or self == nil then
        	print('set modifier stack count error: no target')
        	return nil
        else
            return VALVE_SetModifierStackCount(self, pszScriptName, hCaster, nStackCount)
        end
    end
end

local VALVE_GetModifierStackCount = CDOTA_BaseNPC.GetModifierStackCount
CDOTA_BaseNPC.GetModifierStackCount = function(self, pszScriptName, hCaster)
    if self:IsNull() or self == nil then
        print('get modifier stack count error: no target')
        return nil
    else
        return VALVE_GetModifierStackCount(self, pszScriptName, hCaster)
    end
end

local VALVE_HasModifier = CDOTA_BaseNPC.HasModifier
CDOTA_BaseNPC.HasModifier = function(self, pszScriptName)
    if self:IsNull() or self == nil then
        print('has modifier error: no target')
        return false
    else
        return VALVE_HasModifier(self, pszScriptName)
    end
end

--!------------------------------------------------------------

local VALVE_GetIntellect = CDOTA_BaseNPC_Hero.GetIntellect
CDOTA_BaseNPC_Hero.GetIntellect = function(self, skipNoConsume)
    --print("TESTING INTELLECT")
    skipNoConsume = skipNoConsume or false
    return VALVE_GetIntellect(self, skipNoConsume)
end
if IsServer() then
    --!!----------------------------------------------------------------------------------------------------------------------------------------------------------
    local VALVE_EmitSound = CBaseEntity.EmitSound
    CBaseEntity.EmitSound = function(self, soundname)
        if self:IsNull() or self == nil then
        	print('emit sound: no target')
        	return nil
        else
            return VALVE_EmitSound(self, soundname)
        end
    end

    --!!----------------------------------------------------------------------------------------------------------------------------------------------------------
    local VALVE_ApplyDataDrivenModifier = CDOTABaseAbility.ApplyDataDrivenModifier
    CDOTABaseAbility.ApplyDataDrivenModifier = function(self, hCaster, hTarget, pszModifierName, hModifierTable)
        if hTarget:IsNull() or hTarget == nil then
        	print('apply data driven modifier error: no target')
        	return nil
        else
            local dur = hModifierTable["Duration"] or hModifierTable["duration"]
            if hTarget:IsRealHero() and hCaster:IsRealHero() and dur ~= nil and hCaster:GetTeam() ~= hTarget:GetTeam() and CCModifierStatic[pszScriptName] == true then 
                hCaster.ServStat:doControl(dur)
            end
            return VALVE_ApplyDataDrivenModifier(self, hCaster, hTarget, pszModifierName, hModifierTable)
        end
    end

    CDOTA_BaseNPC.FateHeal = function(self, fHeal, hSource, bStatic)
        if bStatic == true and self:IsRealHero() and hSource:IsRealHero() then 
            local missing_hp = self:GetMaxHealth() - self:GetHealth()
            hSource.ServStat:onHeal(math.min(fHeal, missing_hp))
        end

        if self:HasModifier("modifier_zhuge_liang_array_heal_debuff") then 
            print('heal cut')
            print('heal before cut =' .. fHeal)
            local debuff = self:FindModifierByName("modifier_zhuge_liang_array_heal_debuff")
            local heal_debuff = debuff:GetStackCount()/100 
            fHeal = fHeal * heal_debuff
            print('heal after cut =' .. fHeal)
        end

        self:Heal(fHeal, hSource)
    end
end
--!!----------------------------------------------------------------------------------------------------------------------------------------------------------
--[[CDOTABaseAbility.GetCastRangeBonus = function(self, hTarget) --Crashes normal addons, because gaben released new patch with error in 24.02.2022 pizdec, only for LUA ABILITY, For items i think all fne.... cringe
    return self:GetCaster():GetCastRangeBonus()
end
local VALVE_CDOTA_Ability_Lua_GetCastRangeBonus = CDOTA_Ability_Lua.GetCastRangeBonus
CDOTA_Ability_Lua.GetCastRangeBonus = function(self, hTarget) --I DID IT FOR ALL BECASUE NOT WANNA RECIEVE ERRORS IN FUTURE
    return VALVE_CDOTA_Ability_Lua_GetCastRangeBonus(self, hTarget)
end
--!!----------------------------------------------------------------------------------------------------------------------------------------------------------
CDOTA_Item_Lua.GetCastRangeBonus = function(self, hTarget) --Predict Crash???
    return self:GetCaster():GetCastRangeBonus()
end]]

