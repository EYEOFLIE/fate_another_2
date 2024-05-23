local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____skill_utils = require("libs.skill_utils")
local ApplySaWhenRevived = ____skill_utils.ApplySaWhenRevived
local GetMaster1 = ____skill_utils.GetMaster1
local InitSkillSlotChecker = ____skill_utils.InitSkillSlotChecker
local ____dota_ts_adapter = require("libs.dota_ts_adapter")
local BaseAbility = ____dota_ts_adapter.BaseAbility
local BaseModifier = ____dota_ts_adapter.BaseModifier
local registerAbility = ____dota_ts_adapter.registerAbility
local registerModifier = ____dota_ts_adapter.registerModifier
local musashi_ability = require("abilities.musashi.musashi_abilities")
____exports.musashi_attributes_battle_continuation = __TS__Class()
local musashi_attributes_battle_continuation = ____exports.musashi_attributes_battle_continuation
musashi_attributes_battle_continuation.name = "musashi_attributes_battle_continuation"
__TS__ClassExtends(musashi_attributes_battle_continuation, BaseAbility)
function musashi_attributes_battle_continuation.prototype.OnSpellStart(self)
    local Master2 = self:GetCaster()
    local Master1 = GetMaster1(Master2)
    Master1:SetMana(Master1:GetMana() - self:GetManaCost(-1))
    ApplySaWhenRevived(Master2, self, ____exports.musashi_attribute_battle_continuation.name)
end
musashi_attributes_battle_continuation = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_attributes_battle_continuation
)
____exports.musashi_attributes_battle_continuation = musashi_attributes_battle_continuation
____exports.musashi_attribute_battle_continuation = __TS__Class()
local musashi_attribute_battle_continuation = ____exports.musashi_attribute_battle_continuation
musashi_attribute_battle_continuation.name = "musashi_attribute_battle_continuation"
__TS__ClassExtends(musashi_attribute_battle_continuation, BaseModifier)
function musashi_attribute_battle_continuation.prototype.IsPurgable(self)
    return false
end
function musashi_attribute_battle_continuation.prototype.IsPurgeException(self)
    return false
end
function musashi_attribute_battle_continuation.prototype.IsPermanent(self)
    return true
end
function musashi_attribute_battle_continuation.prototype.RemoveOnDeath(self)
    return false
end
function musashi_attribute_battle_continuation.prototype.IsHidden(self)
    return true
end
musashi_attribute_battle_continuation = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_attribute_battle_continuation
)
____exports.musashi_attribute_battle_continuation = musashi_attribute_battle_continuation
____exports.musashi_attributes_improve_tengan = __TS__Class()
local musashi_attributes_improve_tengan = ____exports.musashi_attributes_improve_tengan
musashi_attributes_improve_tengan.name = "musashi_attributes_improve_tengan"
__TS__ClassExtends(musashi_attributes_improve_tengan, BaseAbility)
function musashi_attributes_improve_tengan.prototype.OnSpellStart(self)
    local Master2 = self:GetCaster()
    local Master1 = GetMaster1(Master2)
    local Hero = Master2:GetPlayerOwner():GetAssignedHero()
    Master1:SetMana(Master1:GetMana() - self:GetManaCost(-1))
    ApplySaWhenRevived(Master2, self, ____exports.musashi_attribute_improve_tengan.name)
    InitSkillSlotChecker(Hero, musashi_ability.musashi_tengan.name, musashi_ability.musashi_tenma_gogan.name, 0.03)
end
musashi_attributes_improve_tengan = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_attributes_improve_tengan
)
____exports.musashi_attributes_improve_tengan = musashi_attributes_improve_tengan
____exports.musashi_attribute_improve_tengan = __TS__Class()
local musashi_attribute_improve_tengan = ____exports.musashi_attribute_improve_tengan
musashi_attribute_improve_tengan.name = "musashi_attribute_improve_tengan"
__TS__ClassExtends(musashi_attribute_improve_tengan, BaseModifier)
function musashi_attribute_improve_tengan.prototype.OnCreated(self)
    self.Caster = self:GetParent()
    local ____opt_0 = self.Caster
    local ModifierTenganChargeCounter = ____opt_0 and ____opt_0:FindModifierByName(musashi_ability.musashi_modifier_tengan_chargecounter.name)
    if ModifierTenganChargeCounter ~= nil then
        ModifierTenganChargeCounter:ForceRefresh()
    end
end
function musashi_attribute_improve_tengan.prototype.GetModifierOverrideAbilitySpecial(self, event)
    local ____opt_4 = self.Caster
    local Tengan = ____opt_4 and ____opt_4:FindAbilityByName(musashi_ability.musashi_tengan.name)
    if event.ability == Tengan then
        if event.ability_special_value == "BonusDmgPerAgi" or event.ability_special_value == "MaxCharges" or event.ability_special_value == "RechargeTime" or event.ability_special_value == "TenganBonus" then
            return 1
        end
    end
    return 0
end
function musashi_attribute_improve_tengan.prototype.GetModifierOverrideAbilitySpecialValue(self, event)
    local Ability = self:GetAbility()
    if event.ability_special_value == "BonusDmgPerAgi" then
        return Ability and Ability:GetSpecialValueFor("BonusDmgPerAgi")
    elseif event.ability_special_value == "MaxCharges" then
        return Ability and Ability:GetSpecialValueFor("MaxCharges")
    elseif event.ability_special_value == "RechargeTime" then
        return Ability and Ability:GetSpecialValueFor("RechargeTime")
    elseif event.ability_special_value == "TenganBonus" then
        return Ability and Ability:GetSpecialValueFor("TenganBonus")
    end
    return 0
end
function musashi_attribute_improve_tengan.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function musashi_attribute_improve_tengan.prototype.IsPurgable(self)
    return false
end
function musashi_attribute_improve_tengan.prototype.IsPurgeException(self)
    return false
end
function musashi_attribute_improve_tengan.prototype.IsPermanent(self)
    return true
end
function musashi_attribute_improve_tengan.prototype.RemoveOnDeath(self)
    return false
end
function musashi_attribute_improve_tengan.prototype.IsHidden(self)
    return true
end
musashi_attribute_improve_tengan = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_attribute_improve_tengan
)
____exports.musashi_attribute_improve_tengan = musashi_attribute_improve_tengan
____exports.musashi_attributes_gorin_no_sho = __TS__Class()
local musashi_attributes_gorin_no_sho = ____exports.musashi_attributes_gorin_no_sho
musashi_attributes_gorin_no_sho.name = "musashi_attributes_gorin_no_sho"
__TS__ClassExtends(musashi_attributes_gorin_no_sho, BaseAbility)
function musashi_attributes_gorin_no_sho.prototype.OnSpellStart(self)
    local Master2 = self:GetCaster()
    local Master1 = GetMaster1(Master2)
    Master1:SetMana(Master1:GetMana() - self:GetManaCost(-1))
    ApplySaWhenRevived(Master2, self, ____exports.musashi_attribute_gorin_no_sho.name)
end
musashi_attributes_gorin_no_sho = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_attributes_gorin_no_sho
)
____exports.musashi_attributes_gorin_no_sho = musashi_attributes_gorin_no_sho
____exports.musashi_attribute_gorin_no_sho = __TS__Class()
local musashi_attribute_gorin_no_sho = ____exports.musashi_attribute_gorin_no_sho
musashi_attribute_gorin_no_sho.name = "musashi_attribute_gorin_no_sho"
__TS__ClassExtends(musashi_attribute_gorin_no_sho, BaseModifier)
function musashi_attribute_gorin_no_sho.prototype.IsPurgable(self)
    return false
end
function musashi_attribute_gorin_no_sho.prototype.IsPurgeException(self)
    return false
end
function musashi_attribute_gorin_no_sho.prototype.IsPermanent(self)
    return true
end
function musashi_attribute_gorin_no_sho.prototype.RemoveOnDeath(self)
    return false
end
function musashi_attribute_gorin_no_sho.prototype.IsHidden(self)
    return true
end
musashi_attribute_gorin_no_sho = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_attribute_gorin_no_sho
)
____exports.musashi_attribute_gorin_no_sho = musashi_attribute_gorin_no_sho
____exports.musashi_attributes_mukyuu = __TS__Class()
local musashi_attributes_mukyuu = ____exports.musashi_attributes_mukyuu
musashi_attributes_mukyuu.name = "musashi_attributes_mukyuu"
__TS__ClassExtends(musashi_attributes_mukyuu, BaseAbility)
function musashi_attributes_mukyuu.prototype.OnSpellStart(self)
    local Master2 = self:GetCaster()
    local Master1 = GetMaster1(Master2)
    local Hero = Master2:GetPlayerOwner():GetAssignedHero()
    Master1:SetMana(Master1:GetMana() - self:GetManaCost(-1))
    Hero:SwapAbilities(musashi_ability.musashi_mukyuu.name, "fate_empty1", true, false)
    ApplySaWhenRevived(Master2, self, ____exports.musashi_attribute_mukyuu.name)
end
musashi_attributes_mukyuu = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_attributes_mukyuu
)
____exports.musashi_attributes_mukyuu = musashi_attributes_mukyuu
____exports.musashi_attribute_mukyuu = __TS__Class()
local musashi_attribute_mukyuu = ____exports.musashi_attribute_mukyuu
musashi_attribute_mukyuu.name = "musashi_attribute_mukyuu"
__TS__ClassExtends(musashi_attribute_mukyuu, BaseModifier)
function musashi_attribute_mukyuu.prototype.GetModifierOverrideAbilitySpecial(self, event)
    local Caster = self:GetParent()
    local Ability = Caster:FindAbilityByName(musashi_ability.musashi_niou_kurikara.name)
    if event.ability == Ability then
        if event.ability_special_value == "DmgReduceWhileSlashing" or event.ability_special_value == "DmgReducePostSlashing" or event.ability_special_value == "BuffDuration" then
            return 1
        end
    end
    return 0
end
function musashi_attribute_mukyuu.prototype.GetModifierOverrideAbilitySpecialValue(self, event)
    local Ability = self:GetAbility()
    if event.ability_special_value == "DmgReduceWhileSlashing" then
        return Ability and Ability:GetSpecialValueFor("DmgReduceWhileSlashing")
    elseif event.ability_special_value == "DmgReducePostSlashing" then
        return Ability and Ability:GetSpecialValueFor("DmgReducePostSlashing")
    elseif event.ability_special_value == "BuffDuration" then
        return Ability and Ability:GetSpecialValueFor("BuffDuration")
    end
    return 0
end
function musashi_attribute_mukyuu.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function musashi_attribute_mukyuu.prototype.IsPurgable(self)
    return false
end
function musashi_attribute_mukyuu.prototype.IsPurgeException(self)
    return false
end
function musashi_attribute_mukyuu.prototype.IsPermanent(self)
    return true
end
function musashi_attribute_mukyuu.prototype.RemoveOnDeath(self)
    return false
end
function musashi_attribute_mukyuu.prototype.IsHidden(self)
    return true
end
musashi_attribute_mukyuu = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_attribute_mukyuu
)
____exports.musashi_attribute_mukyuu = musashi_attribute_mukyuu
____exports.musashi_attributes_niten_ichiryuu = __TS__Class()
local musashi_attributes_niten_ichiryuu = ____exports.musashi_attributes_niten_ichiryuu
musashi_attributes_niten_ichiryuu.name = "musashi_attributes_niten_ichiryuu"
__TS__ClassExtends(musashi_attributes_niten_ichiryuu, BaseAbility)
function musashi_attributes_niten_ichiryuu.prototype.OnSpellStart(self)
    local Master2 = self:GetCaster()
    local Master1 = GetMaster1(Master2)
    Master1:SetMana(Master1:GetMana() - self:GetManaCost(-1))
    ApplySaWhenRevived(Master2, self, ____exports.musashi_attribute_niten_ichiryuu.name)
end
musashi_attributes_niten_ichiryuu = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_attributes_niten_ichiryuu
)
____exports.musashi_attributes_niten_ichiryuu = musashi_attributes_niten_ichiryuu
____exports.musashi_attribute_niten_ichiryuu = __TS__Class()
local musashi_attribute_niten_ichiryuu = ____exports.musashi_attribute_niten_ichiryuu
musashi_attribute_niten_ichiryuu.name = "musashi_attribute_niten_ichiryuu"
__TS__ClassExtends(musashi_attribute_niten_ichiryuu, BaseModifier)
function musashi_attribute_niten_ichiryuu.prototype.OnCreated(self)
    local Caster = self:GetParent()
    self.DaiGoSei = Caster:FindAbilityByName(musashi_ability.musashi_dai_go_sei.name)
    self.GanryuuJima = Caster:FindAbilityByName(musashi_ability.musashi_ganryuu_jima.name)
    local ModifierDaiGoSeiHitsCounter = Caster:FindModifierByName(musashi_ability.musashi_modifier_dai_go_sei_hits_counter.name)
    if ModifierDaiGoSeiHitsCounter ~= nil then
        ModifierDaiGoSeiHitsCounter:SetStackCount(0)
    end
    if ModifierDaiGoSeiHitsCounter ~= nil then
        ModifierDaiGoSeiHitsCounter:ForceRefresh()
    end
    self.GanryuuJima:UpdateVectorValues()
end
function musashi_attribute_niten_ichiryuu.prototype.GetModifierOverrideAbilitySpecial(self, event)
    if event.ability == self.DaiGoSei then
        if event.ability_special_value == "HitsRequired" then
            return 1
        end
    elseif event.ability == self.GanryuuJima then
        if event.ability_special_value == "SlashRange" or event.ability_special_value == "SlashRadius" or event.ability_special_value == "BonusDmgPerAgi" then
            return 1
        end
    end
    return 0
end
function musashi_attribute_niten_ichiryuu.prototype.GetModifierOverrideAbilitySpecialValue(self, event)
    local Ability = self:GetAbility()
    if event.ability == self.DaiGoSei then
        if event.ability_special_value == "HitsRequired" then
            return Ability and Ability:GetSpecialValueFor("HitsRequired")
        end
    elseif event.ability == self.GanryuuJima then
        if event.ability_special_value == "SlashRange" then
            return Ability and Ability:GetSpecialValueFor("SlashRange")
        elseif event.ability_special_value == "SlashRadius" then
            return Ability and Ability:GetSpecialValueFor("SlashRadius")
        elseif event.ability_special_value == "BonusDmgPerAgi" then
            return Ability and Ability:GetSpecialValueFor("BonusDmgPerAgi")
        end
    end
    return 0
end
function musashi_attribute_niten_ichiryuu.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function musashi_attribute_niten_ichiryuu.prototype.IsPurgable(self)
    return false
end
function musashi_attribute_niten_ichiryuu.prototype.IsPurgeException(self)
    return false
end
function musashi_attribute_niten_ichiryuu.prototype.IsPermanent(self)
    return true
end
function musashi_attribute_niten_ichiryuu.prototype.RemoveOnDeath(self)
    return false
end
function musashi_attribute_niten_ichiryuu.prototype.IsHidden(self)
    return true
end
musashi_attribute_niten_ichiryuu = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_attribute_niten_ichiryuu
)
____exports.musashi_attribute_niten_ichiryuu = musashi_attribute_niten_ichiryuu
return ____exports
