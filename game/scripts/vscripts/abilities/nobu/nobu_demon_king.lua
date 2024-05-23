nobu_demon_king_open = class({})
nobu_demon_king_open_upgrade = class({})
nobu_demon_king_close = class({})

nobu_dow = class({})
nobu_dogab = class({})
nobu_fool_of_owari = class({})
nobu_king_of_innovation = class({})

nobu_dow_passive = class({})

local tStandardAbilities = {
    "nobu_shot",
    "nobu_dash",
    "nobu_double_shots",
    "nobu_3000",
    "nobu_dash_upgrade",
    "nobu_3000_upgrade",
    "nobu_shot_upgrade",
}
 
local tDemonKingAbilities = {
    "nobu_dow",
    "nobu_dogab",
    "nobu_fool_of_owari",
    "nobu_king_of_innovation",
}

local tDemonKingAbilitiesUpgrade = {
    "nobu_dow",
    "nobu_dogab",
    "nobu_fool_of_owari",
    "nobu_king_of_innovation",
}

function nobu_dow:OnSpellStart()
    local hCaster = self:GetCaster()

    local currentAbility = tDemonKingAbilities
    if hCaster.Expanded then 
        currentAbility = tDemonKingAbilitiesUpgrade
    end
    hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], true, false)
    hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], true, false)
    if hCaster:HasModifier("modifier_nobu_turnlock") then 
        hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], true, false)
    else
        hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], true, false)
    end
    hCaster.ISDOW = true
    if(hCaster.Expanded) then
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_divinity_mark", false, true)
    else
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_dow_passive", false, true)
    end
    hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], true, false)



    --[[if(hCaster.NobuActionAcquired) then
    hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], true, false)
    else
    hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], true, false)
    end

    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], true, false)
    end

    if( hCaster:HasModifier("modifier_nobu_turnlock") ) then
        hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], true, false)
    end

    if(hCaster.is3000Acquired) then
        hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], true, false)
    end
  
    hCaster.ISDOW = true
    if(hCaster.Expanded) then
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_divinity_mark", false, true)
    else
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_dow_passive", false, true)
    end]]
end
function nobu_dogab:OnSpellStart()
    local hCaster = self:GetCaster()    

    local currentAbility = tDemonKingAbilities
    if hCaster.Expanded then 
        currentAbility = tDemonKingAbilitiesUpgrade
    end
    hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], true, false)
    hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], true, false)
    if hCaster:HasModifier("modifier_nobu_turnlock") then 
        hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], true, false)
    else
        hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], true, false)
    end
    hCaster:SwapAbilities("nobu_demon_king_close", "nobu_divinity_mark", false, true)
    if(hCaster.Expanded) then
        hCaster.isCharisma = true
    end
    hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], true, false)


    --[[if(hCaster.NobuActionAcquired) then
    hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], true, false)
    else
    hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], true, false)
    end

    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], true, false)
    end

    if( hCaster:HasModifier("modifier_nobu_turnlock") ) then
        hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], true, false)
    end   

    if(hCaster.is3000Acquired) then
        hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], true, false)
    end

    hCaster:SwapAbilities("nobu_demon_king_close", "nobu_divinity_mark", false, true)
    if(hCaster.Expanded) then
        hCaster.isCharisma = true
    end]]
end
function nobu_fool_of_owari:OnSpellStart()
    local hCaster = self:GetCaster()

    local currentAbility = tDemonKingAbilities
    if hCaster.Expanded then 
        currentAbility = tDemonKingAbilitiesUpgrade
    end
    hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], true, false)
    hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], true, false)
    if hCaster:HasModifier("modifier_nobu_turnlock") then 
        hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], true, false)
    else
        hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], true, false)
    end
    hCaster.isCharisma = true
    if(hCaster.Expanded) then
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_leader_of_innovation", false, true)
    else
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_charisma", false, true)
    end
    hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], true, false)



    --[[if(hCaster.NobuActionAcquired) then
    hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], true, false)
    else
    hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], true, false)
    end

    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], true, false)
    end

    if( hCaster:HasModifier("modifier_nobu_turnlock") ) then
        hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], true, false)
    end

    if(hCaster.is3000Acquired) then
        hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], true, false)
    end
    hCaster.isCharisma = true
    if(hCaster.Expanded) then
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_leader_of_innovation", false, true)
    else
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_charisma", false, true)
    end]]
end
function nobu_king_of_innovation:OnSpellStart()
    local hCaster = self:GetCaster()

    local currentAbility = tDemonKingAbilities
    if hCaster.Expanded then 
        currentAbility = tDemonKingAbilitiesUpgrade
    end
    hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], true, false)
    hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], true, false)
    if hCaster:HasModifier("modifier_nobu_turnlock") then 
        hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], true, false)
    else
        hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], true, false)
    end
    hCaster:SwapAbilities("nobu_demon_king_close", "nobu_leader_of_innovation", false, true)
    if(hCaster.Expanded) then 
        hCaster.ISDOW = true
    end
    hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], true, false)



    --[[if(hCaster.NobuActionAcquired) then
    hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], true, false)
    else
    hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], true, false)
    end

    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], true, false)
    end

    if( hCaster:HasModifier("modifier_nobu_turnlock") ) then
        hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], true, false)
    end

    if(hCaster.is3000Acquired) then
        hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], true, false)
    end
    
    hCaster:SwapAbilities("nobu_demon_king_close", "nobu_leader_of_innovation", false, true)
    if(hCaster.Expanded) then 
        hCaster.ISDOW = true
    end]]
end
 
function demonking_wrapper(ability)
    function ability:OnSpellStart()
        local hCaster = self:GetCaster()    
        local currentAbility = tDemonKingAbilities
        if hCaster.Expanded then 
            currentAbility = tDemonKingAbilitiesUpgrade
        end
        hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], false, true)
        hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], false, true)
        if hCaster:GetAbilityByIndex(2):GetName() ~= hCaster.ESkill then
            hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], false, true)
        else
            hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], false, true)
        end
        hCaster:SwapAbilities(hCaster.FSkill, "nobu_demon_king_close", false, true)
        hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], false, true)

        --[[if(hCaster.NobuActionAcquired) then
            hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], false, true)
        else
            hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], false, true)
        end

        if(hCaster.is3000Acquired) then
            hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], false, true)
        else
            hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], false, true)
        end

        if( hCaster:GetAbilityByIndex(2):GetName() ~= "nobu_double_shots" ) then
            hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], false, true)
            print("1")
        else
            hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], false, true)
            print("11")
        end

        if(hCaster.is3000Acquired) then
            hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], false, true)
        else
            hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], false, true)
        end
        
        hCaster:SwapAbilities("nobu_demon_king_close", "nobu_demon_king_open", true, false)]]
    end
end

demonking_wrapper(nobu_demon_king_open)
demonking_wrapper(nobu_demon_king_open_upgrade)
 
function nobu_demon_king_close:OnSpellStart()
    local hCaster = self:GetCaster()
    local currentAbility = tDemonKingAbilities
    if hCaster.Expanded then 
        currentAbility = tDemonKingAbilitiesUpgrade
    end
    hCaster:SwapAbilities(hCaster.QSkill, currentAbility[1], true, false)
    hCaster:SwapAbilities(hCaster.WSkill, currentAbility[2], true, false)
    if hCaster:HasModifier("modifier_nobu_turnlock") then 
        hCaster:SwapAbilities("nobu_double_shots_stop", currentAbility[3], true, false)
    else
        hCaster:SwapAbilities(hCaster.ESkill, currentAbility[3], true, false)
    end
    hCaster:SwapAbilities(hCaster.FSkill, "nobu_demon_king_close", true, false)
    hCaster:SwapAbilities(hCaster.RSkill, currentAbility[4], true, false)

   --[[ if(hCaster.NobuActionAcquired) then
    hCaster:SwapAbilities(tStandardAbilities[7], tDemonKingAbilities[1], true, false)
    else
    hCaster:SwapAbilities(tStandardAbilities[1], tDemonKingAbilities[1], true, false)
    end

    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[5], tDemonKingAbilities[2], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[2], tDemonKingAbilities[2], true, false)
    end

    if( hCaster:HasModifier("modifier_nobu_turnlock") ) then
        hCaster:SwapAbilities("nobu_double_shots_stop", tDemonKingAbilities[3], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[3], tDemonKingAbilities[3], true, false)
    end


    if(hCaster.is3000Acquired) then  
        hCaster:SwapAbilities(tStandardAbilities[6], tDemonKingAbilities[4], true, false)
    else
        hCaster:SwapAbilities(tStandardAbilities[4], tDemonKingAbilities[4], true, false)
    end]]
end

 
function nobu_dow:GetAbilityTextureName()
    if(self:GetCaster():HasModifier("modifier_nobu_expanding_attribute")) then
        return   "custom/nobu/nobu_option_1"
    else
        return   "custom/nobu/nobu_dow"
    end
end

function nobu_dogab:GetAbilityTextureName()
    if(self:GetCaster():HasModifier("modifier_nobu_expanding_attribute")) then
        return   "custom/nobu/nobu_option_2"
    else
        return   "custom/nobu/nobu_dogab"
    end
end

function nobu_fool_of_owari:GetAbilityTextureName()
    if(self:GetCaster():HasModifier("modifier_nobu_expanding_attribute")) then
        return   "custom/nobu/nobu_option_3"
    else
        return   "custom/nobu/nobu_fool_of_owari"
    end
end

function nobu_king_of_innovation:GetAbilityTextureName()
    if(self:GetCaster():HasModifier("modifier_nobu_expanding_attribute")) then
        return   "custom/nobu/nobu_option_4"
    else
        return   "custom/nobu/nobu_king_of_innovation"
    end
end
 