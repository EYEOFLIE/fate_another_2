gilles_rlyeh_text_open = class({})
gilles_rlyeh_text_close = class({})
gilles_rlyeh_text_open_upgrade = class({})
modifier_gilles_rlyeh_text_window = class({})

spell_book = {
    "gilles_torment",
    "gilles_smother",
    "gilles_hysteria",
    "gilles_grief",
    "gilles_misery"
}

LinkLuaModifier("modifier_gilles_rlyeh_text_window", "abilities/gilles/gilles_rlyeh_text", LUA_MODIFIER_MOTION_NONE)

function rlyeh_text_wrapper(abil)
    function abil:OnUpgrade()
        local hCaster = self:GetCaster()
        local upg = ""
        if hCaster.IsOuterGodAcquired then
            upg = "_upgrade"
        end
        for i = 1, #spell_book do 
            hCaster:FindAbilityByName(spell_book[i] .. upg):SetLevel(self:GetLevel())
        end
        --[[if hCaster.IsOuterGodAcquired then
            hCaster:FindAbilityByName("gilles_torment_upgrade"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_smother_upgrade"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_hysteria_upgrade"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_grief_upgrade"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_misery_upgrade"):SetLevel(self:GetLevel())
        else
            hCaster:FindAbilityByName("gilles_torment"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_smother"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_hysteria"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_grief"):SetLevel(self:GetLevel())
            hCaster:FindAbilityByName("gilles_misery"):SetLevel(self:GetLevel())
        end]]
    end

    function abil:OnSpellStart()
        local hCaster = self:GetCaster()
        if hCaster:HasModifier("modifier_gilles_combo_window") then 
            hCaster:RemoveModifierByName("modifier_gilles_combo_window")
        end

        local upg = ""
        if hCaster.IsOuterGodAcquired then
            upg = "_upgrade"
        end
        
        hCaster:AddNewModifier(hCaster, self, "modifier_gilles_rlyeh_text_window", {})

        hCaster:SwapAbilities("gilles_torment" .. upg, hCaster.QSkill, true, false)
        hCaster:SwapAbilities("gilles_smother" .. upg, hCaster.WSkill, true, false)
        hCaster:SwapAbilities("gilles_hysteria" .. upg, hCaster.ESkill, true, false)
        hCaster:SwapAbilities("gilles_grief" .. upg, hCaster.DSkill, true, false)
        hCaster:SwapAbilities("gilles_rlyeh_text_close", hCaster.FSkill, true, false)
        hCaster:SwapAbilities("gilles_misery" .. upg, hCaster.RSkill, true, false)

        --[[if hCaster.IsDemonicHordeAcquired then 
            hCaster:SwapAbilities("gilles_torment", "gilles_summon_jellyfish_upgrade", true, false)
        else
            hCaster:SwapAbilities("gilles_torment", "gilles_summon_jellyfish", true, false)
        end

        hCaster:SwapAbilities("gilles_smother", "gilles_rlyeh_text_open", true, false)

        if hCaster.IsSunkenCityAcquired then 
            hCaster:SwapAbilities("gilles_hysteria", "gilles_cthulhu_favour_upgrade", true, false)
        else
            hCaster:SwapAbilities("gilles_hysteria", "gilles_cthulhu_favour", true, false)
        end

        if hCaster.IsOuterGodAcquired then 
            hCaster:SwapAbilities("gilles_grief", "gilles_prelati_spellbook_upgrade", true, false)
        else
            hCaster:SwapAbilities("gilles_grief", "gilles_prelati_spellbook", true, false)
        end

        if hCaster.IsEyeOfArtAcquired then 
            hCaster:SwapAbilities("gilles_rlyeh_text_close", "gilles_eye_for_art_passive", true, false)
        else
            hCaster:SwapAbilities("gilles_rlyeh_text_close", "fate_empty1", true, false)
        end

        if hCaster.IsAbyssalConnectionAcquired then 
            hCaster:SwapAbilities("gilles_misery", "gilles_abyssal_contract_upgrade", true, false)
        else
            hCaster:SwapAbilities("gilles_misery", "gilles_abyssal_contract", true, false)
        end]]
    end
end

rlyeh_text_wrapper(gilles_rlyeh_text_open)
rlyeh_text_wrapper(gilles_rlyeh_text_open_upgrade)

function gilles_rlyeh_text_close:OnSpellStart()
    local hCaster = self:GetCaster()

    hCaster:RemoveModifierByName("modifier_gilles_rlyeh_text_window")

    local upg = ""
    if hCaster.IsOuterGodAcquired then
        upg = "_upgrade"
    end

    hCaster:SwapAbilities("gilles_torment" .. upg, hCaster.QSkill, false, true)
    hCaster:SwapAbilities("gilles_smother" .. upg, hCaster.WSkill, false, true)
    hCaster:SwapAbilities("gilles_hysteria" .. upg, hCaster.ESkill, false, true)
    hCaster:SwapAbilities("gilles_grief" .. upg, hCaster.DSkill, false, true)
    hCaster:SwapAbilities("gilles_rlyeh_text_close", hCaster.FSkill, false, true)
    hCaster:SwapAbilities("gilles_misery" .. upg, hCaster.RSkill, false, true)


    --[[if hCaster.IsDemonicHordeAcquired then 
        hCaster:SwapAbilities("gilles_torment", "gilles_summon_jellyfish_upgrade", false, true)
    else
        hCaster:SwapAbilities("gilles_torment", "gilles_summon_jellyfish", false, true)
    end

    hCaster:SwapAbilities("gilles_smother", "gilles_rlyeh_text_open", false, true)

    if hCaster.IsSunkenCityAcquired then 
        hCaster:SwapAbilities("gilles_hysteria", "gilles_cthulhu_favour_upgrade", false, true)
    else
        hCaster:SwapAbilities("gilles_hysteria", "gilles_cthulhu_favour", false, true)
    end

    if hCaster.IsOuterGodAcquired then 
        hCaster:SwapAbilities("gilles_grief", "gilles_prelati_spellbook_upgrade", false, true)
    else
        hCaster:SwapAbilities("gilles_grief", "gilles_prelati_spellbook", false, true)
    end

    if hCaster.IsEyeOfArtAcquired then 
        hCaster:SwapAbilities("gilles_rlyeh_text_close", "gilles_eye_for_art_passive", false, true)
    else
        hCaster:SwapAbilities("gilles_rlyeh_text_close", "fate_empty1", false, true)
    end

    if hCaster.IsAbyssalConnectionAcquired then 
        hCaster:SwapAbilities("gilles_misery", "gilles_abyssal_contract_upgrade", false, true)
    else
        hCaster:SwapAbilities("gilles_misery", "gilles_abyssal_contract", false, true)
    end]]
end

function modifier_gilles_rlyeh_text_window:OnCreated()
    local hCaster = self:GetCaster()

    
end

function modifier_gilles_rlyeh_text_window:OnDestroy()
    local hCaster = self:GetCaster()

    
end

function modifier_gilles_rlyeh_text_window:IsHidden()
    return true 
end 

function modifier_gilles_rlyeh_text_window:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end