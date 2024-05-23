local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local ____exports = {}
local ____dota_ts_adapter = require("libs.dota_ts_adapter")
local BaseAbility = ____dota_ts_adapter.BaseAbility
local BaseModifier = ____dota_ts_adapter.BaseModifier
local registerAbility = ____dota_ts_adapter.registerAbility
local registerModifier = ____dota_ts_adapter.registerModifier
local ____skill_utils = require("libs.skill_utils")
local CheckComboStatsFulfilled = ____skill_utils.CheckComboStatsFulfilled
local InitComboSequenceChecker = ____skill_utils.InitComboSequenceChecker
local InitSkillSlotChecker = ____skill_utils.InitSkillSlotChecker
local ____sleep_timer = require("libs.sleep_timer")
local Sleep = ____sleep_timer.Sleep
____exports.musashi_accel_turn = __TS__Class()
local musashi_accel_turn = ____exports.musashi_accel_turn
musashi_accel_turn.name = "musashi_accel_turn"
__TS__ClassExtends(musashi_accel_turn, BaseAbility)
function musashi_accel_turn.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_07"
    self.SoundSfx = "musashi_accel_turn_sfx"
    self.Damage = 0
end
function musashi_accel_turn.prototype.OnSpellStart(self)
    self.Caster = self:GetCaster()
    self.Caster:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_accel_turn.name, {undefined = undefined})
    self:SetDamageParameters()
    self:CreateProjectile()
    self:PlaySound()
end
function musashi_accel_turn.prototype.SetDamageParameters(self)
    self.Damage = self:GetSpecialValueFor("Damage")
    self.DmgType = self:GetAbilityDamageType()
    self.DmgFlag = DOTA_DAMAGE_FLAG_NONE
end
function musashi_accel_turn.prototype.CreateProjectile(self)
    local ParticleStr = "particles/custom/musashi/musashi_accel_turn_basic.vpcf"
    local ____opt_0 = self.Caster
    if ____opt_0 and ____opt_0:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_accel_turn_unique.vpcf"
    end
    local ____opt_2 = self.Caster
    local Direction = ____opt_2 and ____opt_2:GetForwardVector():__unm()
    local ____ProjectileManager_CreateLinearProjectile_8 = ProjectileManager.CreateLinearProjectile
    local ____ParticleStr_6 = ParticleStr
    local ____self_Caster_7 = self.Caster
    local ____opt_4 = self.Caster
    ____ProjectileManager_CreateLinearProjectile_8(
        ProjectileManager,
        {
            EffectName = ____ParticleStr_6,
            Ability = self,
            Source = ____self_Caster_7,
            vSpawnOrigin = ____opt_4 and ____opt_4:GetAbsOrigin(),
            vVelocity = Direction * self:GetSpecialValueFor("ProjectileSpeed"),
            fDistance = self:GetSpecialValueFor("Range"),
            fStartRadius = self:GetSpecialValueFor("ProjectileRadius"),
            fEndRadius = self:GetSpecialValueFor("ProjectileRadius"),
            iUnitTargetTeam = self:GetAbilityTargetTeam(),
            iUnitTargetFlags = self:GetAbilityTargetFlags(),
            iUnitTargetType = self:GetAbilityTargetType()
        }
    )
end
function musashi_accel_turn.prototype.OnProjectileHit(self, target)
    if not IsServer() then
        return
    end
    DoDamage(
        self.Caster,
        target,
        self.Damage,
        self.DmgType,
        self.DmgFlag,
        self,
        false
    )
end
function musashi_accel_turn.prototype.PlaySound(self)
    local ____opt_9 = self.Caster
    if ____opt_9 ~= nil then
        ____opt_9:EmitSound(self.SoundVoiceline)
    end
    local ____opt_11 = self.Caster
    if ____opt_11 ~= nil then
        ____opt_11:EmitSound(self.SoundSfx)
    end
end
function musashi_accel_turn.prototype.GetCastRange(self)
    if IsServer() then
        return 0
    else
        return self:GetSpecialValueFor("Range")
    end
end
musashi_accel_turn = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_accel_turn
)
____exports.musashi_accel_turn = musashi_accel_turn
____exports.musashi_modifier_accel_turn = __TS__Class()
local musashi_modifier_accel_turn = ____exports.musashi_modifier_accel_turn
musashi_modifier_accel_turn.name = "musashi_modifier_accel_turn"
__TS__ClassExtends(musashi_modifier_accel_turn, BaseModifier)
function musashi_modifier_accel_turn.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.Direction = Vector(0, 0, 0)
    self.UnitsTravelled = 0
    self.DashRange = 0
    self.DashSpeed = 0
end
function musashi_modifier_accel_turn.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_13 = self.Ability
    self.Direction = ____opt_13 and ____opt_13:GetForwardVector():__unm()
    local ____opt_15 = self.Ability
    self.DashRange = ____opt_15 and ____opt_15:GetSpecialValueFor("Range")
    local ____opt_17 = self.Ability
    self.DashSpeed = ____opt_17 and ____opt_17:GetSpecialValueFor("DashSpeed")
    ProjectileManager:ProjectileDodge(self.Caster)
    self:StartIntervalThink(0.03)
end
function musashi_modifier_accel_turn.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    local ____opt_19 = self.Caster
    if ____opt_19 ~= nil then
        ____opt_19:SetForwardVector(self.Direction)
    end
    local ____opt_21 = self.Caster
    local CurrentOrigin = ____opt_21 and ____opt_21:GetAbsOrigin()
    local ____opt_23 = self.Caster
    local NewPosition = CurrentOrigin + (____opt_23 and ____opt_23:GetForwardVector()) * self.DashSpeed
    self.UnitsTravelled = self.UnitsTravelled + (NewPosition - CurrentOrigin):Length2D()
    local ____opt_25 = self.Caster
    if ____opt_25 ~= nil then
        ____opt_25:SetAbsOrigin(NewPosition)
    end
    if self.UnitsTravelled >= self.DashRange then
        self:Destroy()
    end
end
function musashi_modifier_accel_turn.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_27 = self.Caster
    if ____opt_27 ~= nil then
        ____opt_27:SetForwardVector(self.Caster:GetAbsOrigin():Normalized())
    end
    local ____FindClearSpaceForUnit_32 = FindClearSpaceForUnit
    local ____self_Caster_31 = self.Caster
    local ____opt_29 = self.Caster
    ____FindClearSpaceForUnit_32(
        ____self_Caster_31,
        ____opt_29 and ____opt_29:GetAbsOrigin(),
        true
    )
end
function musashi_modifier_accel_turn.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end
function musashi_modifier_accel_turn.prototype.GetOverrideAnimation(self)
    return ACT_DOTA_OVERRIDE_ABILITY_1
end
function musashi_modifier_accel_turn.prototype.GetOverrideAnimationRate(self)
    return 2
end
function musashi_modifier_accel_turn.prototype.CheckState(self)
    local ModifierTable = {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_COMMAND_RESTRICTED] = true}
    return ModifierTable
end
function musashi_modifier_accel_turn.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_accel_turn.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_accel_turn = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_accel_turn
)
____exports.musashi_modifier_accel_turn = musashi_modifier_accel_turn
____exports.musashi_dai_go_sei = __TS__Class()
local musashi_dai_go_sei = ____exports.musashi_dai_go_sei
musashi_dai_go_sei.name = "musashi_dai_go_sei"
__TS__ClassExtends(musashi_dai_go_sei, BaseAbility)
function musashi_dai_go_sei.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_cast_01"
    self.SoundSfx = "musashi_dai_go_sei_sfx"
end
function musashi_dai_go_sei.prototype.OnSpellStart(self)
    self.Caster = self:GetCaster()
    self.Victim = self:GetCursorTarget()
    local BuffDuration = self:GetSpecialValueFor("BuffDuration")
    local StunDuration = self:GetSpecialValueFor("StunDuration")
    local ____opt_33 = self.Caster
    if ____opt_33 ~= nil then
        ____opt_33:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_dai_go_sei.name, {duration = BuffDuration})
    end
    local ____opt_35 = self.Caster
    if ____opt_35 ~= nil then
        local ____opt_35_SetAbsOrigin_38 = ____opt_35.SetAbsOrigin
        local ____opt_36 = self.Victim
        ____opt_35_SetAbsOrigin_38(
            ____opt_35,
            ____opt_36 and ____opt_36:GetAbsOrigin()
        )
    end
    local ____FindClearSpaceForUnit_43 = FindClearSpaceForUnit
    local ____self_Caster_42 = self.Caster
    local ____opt_40 = self.Caster
    ____FindClearSpaceForUnit_43(
        ____self_Caster_42,
        ____opt_40 and ____opt_40:GetAbsOrigin(),
        true
    )
    self.Victim:AddNewModifier(self.Caster, self, "modifier_stunned", {duration = StunDuration})
    self:DealDamage()
    self:PlaySound()
end
function musashi_dai_go_sei.prototype.DealDamage(self)
    local Damage = self:GetSpecialValueFor("Damage")
    local Radius = self:GetSpecialValueFor("Radius")
    local DmgType = DAMAGE_TYPE_MAGICAL
    local DmgFlag = DOTA_DAMAGE_FLAG_NONE
    local ____FindUnitsInRadius_49 = FindUnitsInRadius
    local ____opt_44 = self.Caster
    local ____temp_48 = ____opt_44 and ____opt_44:GetTeam()
    local ____opt_46 = self.Victim
    local Targets = ____FindUnitsInRadius_49(
        ____temp_48,
        ____opt_46 and ____opt_46:GetAbsOrigin(),
        nil,
        Radius,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        FIND_ANY_ORDER,
        false
    )
    local ____opt_50 = self.Victim
    if ____opt_50 and ____opt_50:IsHero() and self.Victim:IsRealHero() then
        DmgType = DAMAGE_TYPE_PURE
        DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
    end
    for ____, Iterator in ipairs(Targets) do
        DoDamage(
            self.Caster,
            Iterator,
            Damage,
            DmgType,
            DmgFlag,
            self,
            false
        )
    end
end
function musashi_dai_go_sei.prototype.PlaySound(self)
    local ____opt_52 = self.Caster
    if ____opt_52 ~= nil then
        ____opt_52:EmitSound(self.SoundVoiceline)
    end
    local ____opt_54 = self.Caster
    if ____opt_54 ~= nil then
        ____opt_54:EmitSound(self.SoundSfx)
    end
end
function musashi_dai_go_sei.prototype.GetIntrinsicModifierName(self)
    return ____exports.musashi_modifier_dai_go_sei_hits_counter.name
end
musashi_dai_go_sei = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_dai_go_sei
)
____exports.musashi_dai_go_sei = musashi_dai_go_sei
____exports.musashi_modifier_dai_go_sei_hits_counter = __TS__Class()
local musashi_modifier_dai_go_sei_hits_counter = ____exports.musashi_modifier_dai_go_sei_hits_counter
musashi_modifier_dai_go_sei_hits_counter.name = "musashi_modifier_dai_go_sei_hits_counter"
__TS__ClassExtends(musashi_modifier_dai_go_sei_hits_counter, BaseModifier)
function musashi_modifier_dai_go_sei_hits_counter.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.HitsRequired = 0
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_56 = self.Ability
    self.HitsRequired = ____opt_56 and ____opt_56:GetSpecialValueFor("HitsRequired")
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.OnRefresh(self)
    if not IsServer() then
        return
    end
    self:OnCreated()
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.OnAttackLanded(self, event)
    if not IsServer() or event.attacker ~= self.Caster then
        return
    end
    if event.target:IsHero() and event.target:IsRealHero() then
        if self:GetStackCount() < self.HitsRequired then
            self:IncrementStackCount()
        end
    end
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    if stackCount == self.HitsRequired - 1 then
        InitSkillSlotChecker(self.Caster, ____exports.musashi_dai_go_sei.name, ____exports.musashi_dai_go_sei_wave.name, 5)
        self:SetStackCount(0)
    end
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.IsPermanent(self)
    return true
end
function musashi_modifier_dai_go_sei_hits_counter.prototype.IsHidden(self)
    if self:GetStackCount() == 0 then
        return true
    end
    return false
end
musashi_modifier_dai_go_sei_hits_counter = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_dai_go_sei_hits_counter
)
____exports.musashi_modifier_dai_go_sei_hits_counter = musashi_modifier_dai_go_sei_hits_counter
____exports.musashi_modifier_dai_go_sei = __TS__Class()
local musashi_modifier_dai_go_sei = ____exports.musashi_modifier_dai_go_sei
musashi_modifier_dai_go_sei.name = "musashi_modifier_dai_go_sei"
__TS__ClassExtends(musashi_modifier_dai_go_sei, BaseModifier)
function musashi_modifier_dai_go_sei.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_58 = self.Ability
    self.BonusAtkDmg = ____opt_58 and ____opt_58:GetSpecialValueFor("BonusAtkDmg")
    local ____opt_60 = self.Ability
    self.BonusAtkSpeed = ____opt_60 and ____opt_60:GetSpecialValueFor("BonusAtkSpeed")
    local ____opt_62 = self.Caster
    local ModifierTengan = ____opt_62 and ____opt_62:FindModifierByName(____exports.musashi_modifier_tengan.name)
    self.BonusAtkDmg = self.BonusAtkDmg + (ModifierTengan and ModifierTengan.TenganBonus or 0)
    self.BonusAtkSpeed = self.BonusAtkSpeed + (ModifierTengan and ModifierTengan.TenganBonus or 0)
    self:SetHasCustomTransmitterData(true)
    self:CreateParticle()
end
function musashi_modifier_dai_go_sei.prototype.OnRefresh(self)
    if not IsServer() then
        return
    end
    self:OnCreated()
    self:SendBuffRefreshToClients()
end
function musashi_modifier_dai_go_sei.prototype.AddCustomTransmitterData(self)
    local data = {BonusDmg = self.BonusAtkDmg, BonusAtkSpeed = self.BonusAtkSpeed}
    return data
end
function musashi_modifier_dai_go_sei.prototype.HandleCustomTransmitterData(self, data)
    self.BonusAtkDmg = data.BonusDmg
    self.BonusAtkSpeed = data.BonusAtkSpeed
end
function musashi_modifier_dai_go_sei.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_dai_go_sei_basic.vpcf"
    local BlueOrbParticleStr = "particles/custom/musashi/musashi_dai_go_sei_blueorb_basic.vpcf"
    local RedOrbParticleStr = "particles/custom/musashi/musashi_dai_go_sei_redorb_basic.vpcf"
    local ____opt_68 = self.Caster
    if ____opt_68 and ____opt_68:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_dai_go_sei_unique.vpcf"
        BlueOrbParticleStr = "particles/custom/musashi/musashi_dai_go_sei_blueorb_unique.vpcf"
        RedOrbParticleStr = "particles/custom/musashi/musashi_dai_go_sei_redorb_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_OVERHEAD_FOLLOW, self.Caster)
    local BlueOrbParticle = ParticleManager:CreateParticle(BlueOrbParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    local RedOrbParticle = ParticleManager:CreateParticle(RedOrbParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    ParticleManager:SetParticleControlEnt(
        BlueOrbParticle,
        1,
        self.Caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack2",
        Vector(0, 0, 0),
        false
    )
    ParticleManager:SetParticleControlEnt(
        RedOrbParticle,
        1,
        self.Caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        Vector(0, 0, 0),
        false
    )
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
    self:AddParticle(
        BlueOrbParticle,
        false,
        false,
        -1,
        false,
        false
    )
    self:AddParticle(
        RedOrbParticle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_dai_go_sei.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function musashi_modifier_dai_go_sei.prototype.GetModifierPreAttack_BonusDamage(self)
    return self.BonusAtkDmg
end
function musashi_modifier_dai_go_sei.prototype.GetModifierAttackSpeedBonus_Constant(self)
    return self.BonusAtkSpeed
end
function musashi_modifier_dai_go_sei.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_dai_go_sei.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_dai_go_sei = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_dai_go_sei
)
____exports.musashi_modifier_dai_go_sei = musashi_modifier_dai_go_sei
____exports.musashi_niou_kurikara = __TS__Class()
local musashi_niou_kurikara = ____exports.musashi_niou_kurikara
musashi_niou_kurikara.name = "musashi_niou_kurikara"
__TS__ClassExtends(musashi_niou_kurikara, BaseAbility)
function musashi_niou_kurikara.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_cast_03"
    self.Interval = 0
    self.SlashCount = 0
end
function musashi_niou_kurikara.prototype.OnAbilityPhaseStart(self)
    self.Caster = self:GetCaster()
    self.NiouSkill = self.Caster:FindAbilityByName(____exports.musashi_niou.name)
    self.Caster:CastAbilityImmediately(
        self.NiouSkill,
        self.Caster:GetEntityIndex()
    )
    self.Niou = self.NiouSkill.Niou
    local ____opt_70 = self.Niou
    if ____opt_70 ~= nil then
        ____opt_70:FaceTowards(self:GetCursorPosition())
    end
    return true
end
function musashi_niou_kurikara.prototype.OnAbilityPhaseInterrupted(self)
    local ____opt_72 = self.NiouSkill
    if ____opt_72 ~= nil then
        ____opt_72:DestroyNiou(0)
    end
end
function musashi_niou_kurikara.prototype.OnSpellStart(self)
    local ____opt_74 = self.Caster
    if ____opt_74 ~= nil then
        ____opt_74:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_niou_kurikara_slashing.name, {duration = 1.5})
    end
    local ____opt_76 = self.Niou
    if ____opt_76 ~= nil then
        ____opt_76:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_1, 1.1)
    end
    local ____opt_78 = self.Caster
    if not (____opt_78 and ____opt_78:HasModifier(____exports.musashi_modifier_ishana_daitenshou.name)) then
        local ____opt_80 = self.Caster
        if ____opt_80 ~= nil then
            ____opt_80:EmitSound(self.SoundVoiceline)
        end
    end
end
function musashi_niou_kurikara.prototype.OnUpgrade(self)
    local ____opt_82 = self.NiouSkill
    if ____opt_82 ~= nil then
        ____opt_82:SetLevel(self:GetLevel())
    end
end
function musashi_niou_kurikara.prototype.GetAOERadius(self)
    return self:GetSpecialValueFor("Radius")
end
musashi_niou_kurikara = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_niou_kurikara
)
____exports.musashi_niou_kurikara = musashi_niou_kurikara
____exports.musashi_modifier_niou_kurikara_slashing = __TS__Class()
local musashi_modifier_niou_kurikara_slashing = ____exports.musashi_modifier_niou_kurikara_slashing
musashi_modifier_niou_kurikara_slashing.name = "musashi_modifier_niou_kurikara_slashing"
__TS__ClassExtends(musashi_modifier_niou_kurikara_slashing, BaseModifier)
function musashi_modifier_niou_kurikara_slashing.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.SoundSfx = "musashi_niou_kurikara_sfx"
    self.TargetPoint = Vector(0, 0, 0)
    self.SlashCount = 0
end
function musashi_modifier_niou_kurikara_slashing.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_84 = self.Ability
    self.TargetPoint = ____opt_84 and ____opt_84:GetCursorPosition()
    giveUnitDataDrivenModifier(self.Caster, self.Caster, "pause_sealdisabled", 1.5)
    self:IncrementStackCount()
    self:StartIntervalThink(0.5)
end
function musashi_modifier_niou_kurikara_slashing.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    self:IncrementStackCount()
end
function musashi_modifier_niou_kurikara_slashing.prototype.OnStackCountChanged(self)
    if not IsServer() then
        return
    end
    self:DealDamage()
    self:CreateParticle()
    EmitSoundOnLocationWithCaster(self.TargetPoint, self.SoundSfx, self.Caster)
end
function musashi_modifier_niou_kurikara_slashing.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_86 = self.Caster
    local NiouSkill = ____opt_86 and ____opt_86:FindAbilityByName(____exports.musashi_niou.name)
    NiouSkill:DestroyNiou(1)
    local ____opt_88 = self.Ability
    local BuffDuration = ____opt_88 and ____opt_88:GetSpecialValueFor("BuffDuration")
    local ____opt_90 = self.Caster
    if ____opt_90 ~= nil then
        ____opt_90:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_niou_kurikara_postslashing_buff.name, {duration = BuffDuration})
    end
    local ____opt_92 = self.Caster
    local ModifierIshanaDaitenshou = ____opt_92 and ____opt_92:FindModifierByName(____exports.musashi_modifier_ishana_daitenshou.name)
    if ModifierIshanaDaitenshou ~= nil then
        ModifierIshanaDaitenshou:IncrementStackCount()
    end
end
function musashi_modifier_niou_kurikara_slashing.prototype.DealDamage(self)
    self.SlashCount = self.SlashCount + 1
    local ____opt_96 = self.Ability
    local Damage = ____opt_96 and ____opt_96:GetSpecialValueFor("DmgPerSlash")
    local ____opt_98 = self.Ability
    local DmgType = ____opt_98 and ____opt_98:GetAbilityDamageType()
    local ____opt_100 = self.Ability
    local TargetFlags = ____opt_100 and ____opt_100:GetAbilityTargetFlags()
    local DmgFlag = DOTA_DAMAGE_FLAG_NONE
    local Targets
    local ____opt_102 = self.Caster
    local ____temp_106 = ____opt_102 and ____opt_102:HasModifier(____exports.musashi_modifier_tenma_gogan.name)
    if not ____temp_106 then
        local ____opt_104 = self.Caster
        ____temp_106 = ____opt_104 and ____opt_104:HasModifier(____exports.musashi_modifier_ishana_daitenshou.name)
    end
    if ____temp_106 then
        DmgType = DAMAGE_TYPE_PURE
        DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_HPLOSS
        TargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local ____opt_107 = self.Caster
    local HasGorinNoSho = ____opt_107 and ____opt_107:HasModifier("musashi_attribute_gorin_no_sho")
    local ____FindUnitsInRadius_118 = FindUnitsInRadius
    local ____opt_109 = self.Caster
    local ____array_117 = __TS__SparseArrayNew(
        ____opt_109 and ____opt_109:GetTeam(),
        self.TargetPoint,
        nil
    )
    local ____opt_111 = self.Ability
    __TS__SparseArrayPush(
        ____array_117,
        ____opt_111 and ____opt_111:GetAOERadius()
    )
    local ____opt_113 = self.Ability
    __TS__SparseArrayPush(
        ____array_117,
        ____opt_113 and ____opt_113:GetAbilityTargetTeam()
    )
    local ____opt_115 = self.Ability
    __TS__SparseArrayPush(
        ____array_117,
        ____opt_115 and ____opt_115:GetAbilityTargetType(),
        TargetFlags,
        FIND_ANY_ORDER,
        false
    )
    Targets = ____FindUnitsInRadius_118(__TS__SparseArraySpread(____array_117))
    for ____, Iterator in ipairs(Targets) do
        if HasGorinNoSho then
            self:ApplyElementalDebuffs(Iterator)
        end
        DoDamage(
            self.Caster,
            Iterator,
            Damage,
            DmgType,
            DmgFlag,
            self.Ability,
            false
        )
    end
    local ____opt_119 = self.Caster
    local ModifierTengan = ____opt_119 and ____opt_119:FindModifierByName(____exports.musashi_modifier_tengan.name)
    if self.SlashCount == 4 and ModifierTengan then
        DmgType = DAMAGE_TYPE_PURE
        DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
        TargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        local ____FindUnitsInRadius_130 = FindUnitsInRadius
        local ____opt_121 = self.Caster
        local ____array_129 = __TS__SparseArrayNew(
            ____opt_121 and ____opt_121:GetTeam(),
            self.TargetPoint,
            nil
        )
        local ____opt_123 = self.Ability
        __TS__SparseArrayPush(
            ____array_129,
            ____opt_123 and ____opt_123:GetAOERadius()
        )
        local ____opt_125 = self.Ability
        __TS__SparseArrayPush(
            ____array_129,
            ____opt_125 and ____opt_125:GetAbilityTargetTeam()
        )
        local ____opt_127 = self.Ability
        __TS__SparseArrayPush(
            ____array_129,
            ____opt_127 and ____opt_127:GetAbilityTargetType(),
            TargetFlags,
            FIND_ANY_ORDER,
            false
        )
        Targets = ____FindUnitsInRadius_130(__TS__SparseArraySpread(____array_129))
        for ____, Iterator in ipairs(Targets) do
            DoDamage(
                self.Caster,
                Iterator,
                ModifierTengan.BonusDmg,
                DmgType,
                DmgFlag,
                self.Ability,
                false
            )
        end
        local ____opt_131 = self.Caster
        local ModifierTenmaGogan = ____opt_131 and ____opt_131:FindModifierByName(____exports.musashi_modifier_tenma_gogan.name)
        ModifierTengan:Destroy()
        if ModifierTenmaGogan ~= nil then
            ModifierTenmaGogan:Destroy()
        end
    end
end
function musashi_modifier_niou_kurikara_slashing.prototype.ApplyElementalDebuffs(self, Target)
    local ____opt_135 = self.Caster
    local GorinNoSho = ____opt_135 and ____opt_135:FindModifierByName("musashi_attribute_gorin_no_sho")
    local AttributeAbility = GorinNoSho and GorinNoSho:GetAbility()
    repeat
        local ____switch85 = self.SlashCount
        local ____cond85 = ____switch85 == 1
        if ____cond85 then
            do
                local DebuffDuration = AttributeAbility and AttributeAbility:GetSpecialValueFor("DebuffDuration")
                Target:AddNewModifier(self.Caster, AttributeAbility, ____exports.musashi_modifier_earth_debuff.name, {duration = DebuffDuration})
                break
            end
        end
        ____cond85 = ____cond85 or ____switch85 == 2
        if ____cond85 then
            do
                local DebuffDuration = AttributeAbility and AttributeAbility:GetSpecialValueFor("DebuffDuration")
                Target:AddNewModifier(self.Caster, AttributeAbility, ____exports.musashi_modifier_water_debuff.name, {duration = DebuffDuration})
                break
            end
        end
        ____cond85 = ____cond85 or ____switch85 == 3
        if ____cond85 then
            do
                local DebuffDuration = AttributeAbility and AttributeAbility:GetSpecialValueFor("FireBurnDuration")
                Target:AddNewModifier(self.Caster, AttributeAbility, ____exports.musashi_modifier_fire_debuff.name, {duration = DebuffDuration})
                break
            end
        end
        ____cond85 = ____cond85 or ____switch85 == 4
        if ____cond85 then
            do
                local DebuffDuration = AttributeAbility and AttributeAbility:GetSpecialValueFor("WindDuration")
                Target:AddNewModifier(self.Caster, AttributeAbility, ____exports.musashi_modifier_wind_debuff.name, {duration = DebuffDuration})
                break
            end
        end
    until true
end
function musashi_modifier_niou_kurikara_slashing.prototype.CreateParticle(self)
    local ____opt_147 = self.Caster
    if ____opt_147 and ____opt_147:HasModifier("modifier_ascended") then
        local AoeParticleStr = ""
        local CrackParticleStr = ""
        repeat
            local ____switch92 = self.SlashCount
            local ____cond92 = ____switch92 == 1
            if ____cond92 then
                do
                    AoeParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_earth.vpcf"
                    CrackParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_earth_crack.vpcf"
                    break
                end
            end
            ____cond92 = ____cond92 or ____switch92 == 2
            if ____cond92 then
                do
                    AoeParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_water.vpcf"
                    CrackParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_water_crack.vpcf"
                    break
                end
            end
            ____cond92 = ____cond92 or ____switch92 == 3
            if ____cond92 then
                do
                    AoeParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_fire.vpcf"
                    CrackParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_fire_crack.vpcf"
                    break
                end
            end
            ____cond92 = ____cond92 or ____switch92 == 4
            if ____cond92 then
                do
                    AoeParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_wind.vpcf"
                    CrackParticleStr = "particles/custom/musashi/musashi_niou_kurikara_unique_wind_crack.vpcf"
                    break
                end
            end
        until true
        local AoeParticle = ParticleManager:CreateParticle(AoeParticleStr, PATTACH_WORLDORIGIN, self.Caster)
        local CrackParticle = ParticleManager:CreateParticle(CrackParticleStr, PATTACH_WORLDORIGIN, self.Caster)
        ParticleManager:SetParticleControl(CrackParticle, 0, self.TargetPoint)
        ParticleManager:SetParticleControl(AoeParticle, 0, self.TargetPoint)
        ParticleManager:SetParticleControl(
            AoeParticle,
            1,
            Vector(1.5, 0, 0)
        )
        local ____ParticleManager_SetParticleControl_151 = ParticleManager.SetParticleControl
        local ____opt_149 = self.Ability
        ____ParticleManager_SetParticleControl_151(
            ParticleManager,
            AoeParticle,
            12,
            Vector(
                ____opt_149 and ____opt_149:GetAOERadius(),
                0,
                0
            )
        )
    else
        local AoeParticleStr = "particles/custom/musashi/musashi_niou_kurikara_basic.vpcf"
        local AoeParticle = ParticleManager:CreateParticle(AoeParticleStr, PATTACH_WORLDORIGIN, self.Caster)
        ParticleManager:SetParticleControl(AoeParticle, 0, self.TargetPoint)
        ParticleManager:SetParticleControl(
            AoeParticle,
            1,
            Vector(1.5, 0, 0)
        )
        local ____ParticleManager_SetParticleControl_154 = ParticleManager.SetParticleControl
        local ____opt_152 = self.Ability
        ____ParticleManager_SetParticleControl_154(
            ParticleManager,
            AoeParticle,
            2,
            Vector(
                ____opt_152 and ____opt_152:GetAOERadius(),
                0,
                0
            )
        )
    end
end
function musashi_modifier_niou_kurikara_slashing.prototype.GetModifierIncomingDamage_Percentage(self)
    local ____opt_155 = self:GetAbility()
    return ____opt_155 and ____opt_155:GetSpecialValueFor("DmgReduceWhileSlashing")
end
function musashi_modifier_niou_kurikara_slashing.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end
function musashi_modifier_niou_kurikara_slashing.prototype.GetOverrideAnimation(self)
    return ACT_DOTA_CHANNEL_ABILITY_1
end
function musashi_modifier_niou_kurikara_slashing.prototype.GetOverrideAnimationRate(self)
    return 0.5
end
function musashi_modifier_niou_kurikara_slashing.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_niou_kurikara_slashing.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_niou_kurikara_slashing = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_niou_kurikara_slashing
)
____exports.musashi_modifier_niou_kurikara_slashing = musashi_modifier_niou_kurikara_slashing
____exports.musashi_modifier_earth_debuff = __TS__Class()
local musashi_modifier_earth_debuff = ____exports.musashi_modifier_earth_debuff
musashi_modifier_earth_debuff.name = "musashi_modifier_earth_debuff"
__TS__ClassExtends(musashi_modifier_earth_debuff, BaseModifier)
function musashi_modifier_earth_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_earth_debuff.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function musashi_modifier_earth_debuff.prototype.GetModifierMoveSpeedBonus_Percentage(self)
    local ____opt_157 = self:GetAbility()
    return ____opt_157 and ____opt_157:GetSpecialValueFor("EarthSlow")
end
musashi_modifier_earth_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_earth_debuff
)
____exports.musashi_modifier_earth_debuff = musashi_modifier_earth_debuff
____exports.musashi_modifier_water_debuff = __TS__Class()
local musashi_modifier_water_debuff = ____exports.musashi_modifier_water_debuff
musashi_modifier_water_debuff.name = "musashi_modifier_water_debuff"
__TS__ClassExtends(musashi_modifier_water_debuff, BaseModifier)
function musashi_modifier_water_debuff.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.TargetPoint = Vector(0, 0, 0)
    self.PushSpeed = 0
end
function musashi_modifier_water_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Victim = self:GetParent()
    self.Attribute = self:GetAbility()
    local ____opt_159 = self.Caster
    local ModifierNiouKurikara = ____opt_159 and ____opt_159:FindModifierByName(____exports.musashi_modifier_niou_kurikara_slashing.name)
    self.TargetPoint = ModifierNiouKurikara.TargetPoint
    local ____opt_161 = self.Attribute
    self.PushSpeed = ____opt_161 and ____opt_161:GetSpecialValueFor("PushSpeed")
    local ____opt_163 = self.Victim
    if ____opt_163 ~= nil then
        ____opt_163:AddNewModifier(self.Caster, self.Attribute, "modifier_rooted", {duration = 1})
    end
    giveUnitDataDrivenModifier(
        self.Caster,
        self.Victim,
        "locked",
        self:GetDuration()
    )
    self:StartIntervalThink(0.03)
end
function musashi_modifier_water_debuff.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    local ____opt_165 = self.Victim
    local CurrentOrigin = ____opt_165 and ____opt_165:GetAbsOrigin()
    local ForwardVector = (self.TargetPoint - CurrentOrigin):Normalized()
    local ____opt_167 = self.Victim
    if ____opt_167 ~= nil then
        ____opt_167:SetForwardVector(ForwardVector)
    end
    local ____opt_169 = self.Victim
    local NewPosition = CurrentOrigin + (____opt_169 and ____opt_169:GetForwardVector()) * self.PushSpeed
    local ____opt_171 = self.Victim
    if ____opt_171 ~= nil then
        ____opt_171:SetAbsOrigin(NewPosition)
    end
    local ____Entities_FindByNameWithin_175 = Entities.FindByNameWithin
    local ____opt_173 = self.Victim
    local VictimEntity = ____Entities_FindByNameWithin_175(
        Entities,
        nil,
        ____opt_173 and ____opt_173:GetName(),
        self.TargetPoint,
        self.PushSpeed
    )
    if VictimEntity then
        self:Destroy()
    end
end
function musashi_modifier_water_debuff.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_176 = self.Victim
    if ____opt_176 ~= nil then
        ____opt_176:SetForwardVector(self.Victim:GetAbsOrigin():Normalized())
    end
    local ____FindClearSpaceForUnit_181 = FindClearSpaceForUnit
    local ____self_Victim_180 = self.Victim
    local ____opt_178 = self.Victim
    ____FindClearSpaceForUnit_181(
        ____self_Victim_180,
        ____opt_178 and ____opt_178:GetAbsOrigin(),
        true
    )
end
function musashi_modifier_water_debuff.prototype.CheckState(self)
    local ModifierTable = {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    return ModifierTable
end
musashi_modifier_water_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_water_debuff
)
____exports.musashi_modifier_water_debuff = musashi_modifier_water_debuff
____exports.musashi_modifier_fire_debuff = __TS__Class()
local musashi_modifier_fire_debuff = ____exports.musashi_modifier_fire_debuff
musashi_modifier_fire_debuff.name = "musashi_modifier_fire_debuff"
__TS__ClassExtends(musashi_modifier_fire_debuff, BaseModifier)
function musashi_modifier_fire_debuff.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.Damage = 0
end
function musashi_modifier_fire_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Victim = self:GetParent()
    self.Ability = self:GetAbility()
    local ____opt_182 = self.Ability
    local DebuffDuration = ____opt_182 and ____opt_182:GetSpecialValueFor("DebuffDuration")
    local ____opt_184 = self.Ability
    self.Damage = ____opt_184 and ____opt_184:GetSpecialValueFor("FireBurnDmgPerSec")
    self.DmgType = DAMAGE_TYPE_MAGICAL
    self.DmgFlag = DOTA_DAMAGE_FLAG_NONE
    self:StartIntervalThink(DebuffDuration)
    self:CreateParticle()
end
function musashi_modifier_fire_debuff.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    DoDamage(
        self.Caster,
        self.Victim,
        self.Damage,
        self.DmgType,
        self.DmgFlag,
        self.Ability,
        false
    )
end
function musashi_modifier_fire_debuff.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_niou_kurikara_fire_debuff_basic.vpcf"
    local ____opt_186 = self.Caster
    if ____opt_186 and ____opt_186:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_niou_kurikara_fire_debuff_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Victim)
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_fire_debuff.prototype.GetModifierIncomingDamage_Percentage(self)
    local ____opt_188 = self.Ability
    return ____opt_188 and ____opt_188:GetSpecialValueFor("FireIncreaseDmgTaken")
end
function musashi_modifier_fire_debuff.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
musashi_modifier_fire_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_fire_debuff
)
____exports.musashi_modifier_fire_debuff = musashi_modifier_fire_debuff
____exports.musashi_modifier_wind_debuff = __TS__Class()
local musashi_modifier_wind_debuff = ____exports.musashi_modifier_wind_debuff
musashi_modifier_wind_debuff.name = "musashi_modifier_wind_debuff"
__TS__ClassExtends(musashi_modifier_wind_debuff, BaseModifier)
function musashi_modifier_wind_debuff.prototype.CheckState(self)
    local ModifierTable = {[MODIFIER_STATE_STUNNED] = true}
    return ModifierTable
end
function musashi_modifier_wind_debuff.prototype.IsStunDebuff(self)
    return true
end
musashi_modifier_wind_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_wind_debuff
)
____exports.musashi_modifier_wind_debuff = musashi_modifier_wind_debuff
____exports.musashi_modifier_niou_kurikara_postslashing_buff = __TS__Class()
local musashi_modifier_niou_kurikara_postslashing_buff = ____exports.musashi_modifier_niou_kurikara_postslashing_buff
musashi_modifier_niou_kurikara_postslashing_buff.name = "musashi_modifier_niou_kurikara_postslashing_buff"
__TS__ClassExtends(musashi_modifier_niou_kurikara_postslashing_buff, BaseModifier)
function musashi_modifier_niou_kurikara_postslashing_buff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_niou_kurikara_postslashing_buff.prototype.GetModifierIncomingDamage_Percentage(self)
    local ____opt_190 = self:GetAbility()
    return ____opt_190 and ____opt_190:GetSpecialValueFor("DmgReducePostSlashing")
end
function musashi_modifier_niou_kurikara_postslashing_buff.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function musashi_modifier_niou_kurikara_postslashing_buff.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_niou_kurikara_postslashing_buff.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_niou_kurikara_postslashing_buff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_niou_kurikara_postslashing_buff
)
____exports.musashi_modifier_niou_kurikara_postslashing_buff = musashi_modifier_niou_kurikara_postslashing_buff
____exports.musashi_tengan = __TS__Class()
local musashi_tengan = ____exports.musashi_tengan
musashi_tengan.name = "musashi_tengan"
__TS__ClassExtends(musashi_tengan, BaseAbility)
function musashi_tengan.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_cast_02"
    self.SoundSfx = "musashi_tengan_sfx"
end
function musashi_tengan.prototype.OnAbilityPhaseStart(self)
    if IsServer() then
        self.Caster = self:GetCaster()
        self.ChargeCounter = self.Caster:FindModifierByName(____exports.musashi_modifier_tengan_chargecounter.name)
        if CheckComboStatsFulfilled(self.Caster) and not self.Caster:HasModifier(____exports.musashi_modifier_ishana_daitenshou_cooldown.name) then
            local SkillsSequence = {____exports.musashi_tengan.name, ____exports.musashi_dai_go_sei.name}
            InitComboSequenceChecker(
                self.Caster,
                SkillsSequence,
                ____exports.musashi_ganryuu_jima.name,
                ____exports.musashi_ishana_daitenshou.name,
                5
            )
        end
        if self.ChargeCounter:GetStackCount() > 0 then
            return true
        end
    end
    return false
end
function musashi_tengan.prototype.OnSpellStart(self)
    local BuffDuration = self:GetSpecialValueFor("BuffDuration")
    local RechargeTime = self:GetSpecialValueFor("RechargeTime")
    local ____opt_192 = self.Caster
    if ____opt_192 ~= nil then
        ____opt_192:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_tengan.name, {duration = BuffDuration})
    end
    local ____opt_194 = self.ChargeCounter
    if ____opt_194 ~= nil then
        local ____opt_195 = self.ChargeCounter
        local ____temp_197 = ____opt_195 and ____opt_195.RechargeTimer
        ____temp_197[#____temp_197 + 1] = RechargeTime
    end
    local ____opt_199 = self.ChargeCounter
    local ____temp_203 = (____opt_199 and ____opt_199:GetStackCount()) == self:GetSpecialValueFor("MaxCharges")
    if ____temp_203 then
        local ____opt_201 = self.Caster
        ____temp_203 = ____opt_201 and ____opt_201:HasModifier("musashi_attribute_improve_tengan")
    end
    if ____temp_203 then
        InitSkillSlotChecker(self.Caster, ____exports.musashi_tengan.name, ____exports.musashi_tenma_gogan.name, 2)
    end
    local ____opt_204 = self.ChargeCounter
    if ____opt_204 ~= nil then
        ____opt_204:DecrementStackCount()
    end
    self:PlaySound()
end
function musashi_tengan.prototype.PlaySound(self)
    local ____opt_206 = self.Caster
    if ____opt_206 ~= nil then
        ____opt_206:EmitSound(self.SoundVoiceline)
    end
    local ____opt_208 = self.Caster
    if ____opt_208 ~= nil then
        ____opt_208:EmitSound(self.SoundSfx)
    end
end
function musashi_tengan.prototype.GetIntrinsicModifierName(self)
    return ____exports.musashi_modifier_tengan_chargecounter.name
end
musashi_tengan = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_tengan
)
____exports.musashi_tengan = musashi_tengan
____exports.musashi_modifier_tengan_chargecounter = __TS__Class()
local musashi_modifier_tengan_chargecounter = ____exports.musashi_modifier_tengan_chargecounter
musashi_modifier_tengan_chargecounter.name = "musashi_modifier_tengan_chargecounter"
__TS__ClassExtends(musashi_modifier_tengan_chargecounter, BaseModifier)
function musashi_modifier_tengan_chargecounter.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.RechargeTimer = {}
end
function musashi_modifier_tengan_chargecounter.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Ability = self:GetAbility()
    local ____opt_210 = self.Ability
    local MaxCharges = ____opt_210 and ____opt_210:GetSpecialValueFor("MaxCharges")
    self:SetStackCount(MaxCharges)
    self:StartIntervalThink(1)
end
function musashi_modifier_tengan_chargecounter.prototype.OnRefresh(self)
    if not IsServer() then
        return
    end
    self:OnCreated()
end
function musashi_modifier_tengan_chargecounter.prototype.OnStackCountChanged(self)
    if not IsServer() then
        return
    end
    if self:GetStackCount() == 0 then
        local ____opt_212 = self.Ability
        if ____opt_212 ~= nil then
            ____opt_212:StartCooldown(self.RechargeTimer[1] or 0)
        end
    else
        local ____opt_214 = self.Ability
        if ____opt_214 ~= nil then
            ____opt_214:EndCooldown()
        end
    end
end
function musashi_modifier_tengan_chargecounter.prototype.OnIntervalThink(self)
    if not IsServer() or #self.RechargeTimer == 0 then
        return
    end
    do
        local i = 0
        while i < #self.RechargeTimer do
            local ____self_RechargeTimer_216, ____temp_217 = self.RechargeTimer, i + 1
            ____self_RechargeTimer_216[____temp_217] = ____self_RechargeTimer_216[____temp_217] - 1
            i = i + 1
        end
    end
    if self.RechargeTimer[1] == 0 then
        table.remove(self.RechargeTimer, 1)
        self:IncrementStackCount()
    end
end
function musashi_modifier_tengan_chargecounter.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_tengan_chargecounter.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_tengan_chargecounter.prototype.IsPermanent(self)
    return true
end
musashi_modifier_tengan_chargecounter = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_tengan_chargecounter
)
____exports.musashi_modifier_tengan_chargecounter = musashi_modifier_tengan_chargecounter
____exports.musashi_modifier_tengan = __TS__Class()
local musashi_modifier_tengan = ____exports.musashi_modifier_tengan
musashi_modifier_tengan.name = "musashi_modifier_tengan"
__TS__ClassExtends(musashi_modifier_tengan, BaseModifier)
function musashi_modifier_tengan.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.BonusDmg = 0
    self.TenganBonus = 0
end
function musashi_modifier_tengan.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    local Ability = self:GetAbility()
    local BaseDmg = Ability and Ability:GetSpecialValueFor("BaseDmg")
    local BonusDmgPerAgi = Ability and Ability:GetSpecialValueFor("BonusDmgPerAgi")
    self.TenganBonus = Ability and Ability:GetSpecialValueFor("TenganBonus")
    self.BonusDmg = BaseDmg + self.Caster:GetAgility() * BonusDmgPerAgi
    self:CreateParticle()
end
function musashi_modifier_tengan.prototype.OnRefresh(self)
    if not IsServer() then
        return
    end
    self:OnCreated()
end
function musashi_modifier_tengan.prototype.CreateParticle(self)
    local ____opt_224 = self.Caster
    if ____opt_224 and ____opt_224:HasModifier("modifier_ascended") then
        local ParticleStr = "particles/custom/musashi/musashi_tengan_unique.vpcf"
        local OverheadParticleStr = "particles/custom/musashi/musashi_tengan_overhead_unique.vpcf"
        local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
        local OverheadParticle = ParticleManager:CreateParticle(OverheadParticleStr, PATTACH_OVERHEAD_FOLLOW, self.Caster)
        self:AddParticle(
            Particle,
            false,
            false,
            -1,
            false,
            false
        )
        self:AddParticle(
            OverheadParticle,
            false,
            false,
            -1,
            false,
            false
        )
    else
        local ParticleStr = "particles/custom/musashi/musashi_tengan_basic.vpcf"
        local OverheadParticleStr = "particles/custom/musashi/musashi_tengan_overhead_basic.vpcf"
        local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
        local OverheadParticle = ParticleManager:CreateParticle(OverheadParticleStr, PATTACH_OVERHEAD_FOLLOW, self.Caster)
        ParticleManager:SetParticleControlEnt(
            OverheadParticle,
            10,
            self.Caster,
            PATTACH_OVERHEAD_FOLLOW,
            "attach_hitloc",
            Vector(0, 0, 0),
            false
        )
        self:AddParticle(
            Particle,
            false,
            false,
            -1,
            false,
            false
        )
        self:AddParticle(
            OverheadParticle,
            false,
            false,
            -1,
            false,
            false
        )
    end
end
function musashi_modifier_tengan.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_tengan.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_tengan = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_tengan
)
____exports.musashi_modifier_tengan = musashi_modifier_tengan
____exports.musashi_ganryuu_jima = __TS__Class()
local musashi_ganryuu_jima = ____exports.musashi_ganryuu_jima
musashi_ganryuu_jima.name = "musashi_ganryuu_jima"
__TS__ClassExtends(musashi_ganryuu_jima, BaseAbility)
function musashi_ganryuu_jima.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_01"
    self.DashPosition = Vector(0, 0, 0)
    self.SlashPosition = Vector(0, 0, 0)
    self.SecondSlashPosition = Vector(0, 0, 0)
end
function musashi_ganryuu_jima.prototype.OnVectorCastStart(self, vStartLocation, vDirection)
    self.Caster = self:GetCaster()
    self:SetVector(vStartLocation, vDirection)
    local ____opt_226 = self.Caster
    local ModifierGanryuuJima = ____opt_226 and ____opt_226:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_ganryuu_jima.name, {duration = 10})
    if ModifierGanryuuJima ~= nil then
        ModifierGanryuuJima:IncrementStackCount()
    end
    EmitGlobalSound(self.SoundVoiceline)
end
function musashi_ganryuu_jima.prototype.SetVector(self, vStartLocation, vDirection)
    self.DashPosition = vStartLocation
    self.SlashPosition = vDirection
    self.SecondSlashPosition = vDirection:__unm()
end
function musashi_ganryuu_jima.prototype.GetCastRange(self)
    if IsServer() then
        return 0
    else
        local ____opt_230 = self.Caster
        if ____opt_230 and ____opt_230:HasModifier("musashi_attribute_niten_ichiryuu") then
            return 1000
        else
            return self:GetSpecialValueFor("SlashRange")
        end
    end
end
function musashi_ganryuu_jima.prototype.GetVectorTargetRange(self)
    return self:GetSpecialValueFor("SlashRange")
end
function musashi_ganryuu_jima.prototype.GetVectorTargetStartRadius(self)
    return self:GetSpecialValueFor("SlashRadius")
end
function musashi_ganryuu_jima.prototype.GetVectorTargetEndRadius(self)
    return self:GetSpecialValueFor("SlashRadius")
end
function musashi_ganryuu_jima.prototype.GetVectorPosition(self)
    return self.DashPosition
end
function musashi_ganryuu_jima.prototype.GetVectorDirection(self)
    return self.SlashPosition
end
function musashi_ganryuu_jima.prototype.GetVector2Position(self)
    return self.SecondSlashPosition
end
function musashi_ganryuu_jima.prototype.UpdateVectorValues(self)
end
function musashi_ganryuu_jima.prototype.IsDualVectorDirection(self)
    return false
end
function musashi_ganryuu_jima.prototype.IgnoreVectorArrowWidth(self)
    return false
end
musashi_ganryuu_jima = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_ganryuu_jima
)
____exports.musashi_ganryuu_jima = musashi_ganryuu_jima
____exports.musashi_modifier_ganryuu_jima = __TS__Class()
local musashi_modifier_ganryuu_jima = ____exports.musashi_modifier_ganryuu_jima
musashi_modifier_ganryuu_jima.name = "musashi_modifier_ganryuu_jima"
__TS__ClassExtends(musashi_modifier_ganryuu_jima, BaseModifier)
function musashi_modifier_ganryuu_jima.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.DashPosition = Vector(0, 0, 0)
    self.SlashPosition = Vector(0, 0, 0)
    self.SecondSlashPosition = Vector(0, 0, 0)
end
function musashi_modifier_ganryuu_jima.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.GanryuuJima = self:GetAbility()
    self.DashPosition = self.GanryuuJima.DashPosition
    self.SlashPosition = self.GanryuuJima.SlashPosition
    self.SecondSlashPosition = self.GanryuuJima.SecondSlashPosition
    giveUnitDataDrivenModifier(self.Caster, self.Caster, "pause_sealdisabled", 1.5)
end
function musashi_modifier_ganryuu_jima.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    local Position = Vector(0, 0, 0)
    repeat
        local ____switch184 = stackCount
        local ____cond184 = ____switch184 == 0
        if ____cond184 then
            do
                Position = self.DashPosition
                local ____opt_232 = self.Caster
                local DashBuff = ____opt_232 and ____opt_232:AddNewModifier(self.Caster, self.GanryuuJima, ____exports.musashi_modifier_ganryuu_jima_dash.name, {undefined = undefined})
                DashBuff.TargetPoint = Position
                local ____DashBuff_TargetPoint_236 = DashBuff.TargetPoint
                local ____opt_234 = self.Caster
                ____DashBuff_TargetPoint_236.z = ____opt_234 and ____opt_234:GetAbsOrigin().z
                local ____DashBuff_TargetPoint_239 = DashBuff.TargetPoint
                local ____opt_237 = self.Caster
                DashBuff.NormalizedTargetPoint = (____DashBuff_TargetPoint_239 - (____opt_237 and ____opt_237:GetAbsOrigin())):Normalized()
                DashBuff:StartIntervalThink(0.03)
                break
            end
        end
        ____cond184 = ____cond184 or ____switch184 == 1
        if ____cond184 then
            do
                Position = self.SlashPosition
                break
            end
        end
        ____cond184 = ____cond184 or ____switch184 == 2
        if ____cond184 then
            do
                Position = self.SecondSlashPosition
                break
            end
        end
        ____cond184 = ____cond184 or ____switch184 == 3
        if ____cond184 then
            do
                self:Destroy()
                break
            end
        end
    until true
    if stackCount == 1 or stackCount == 2 then
        local ____opt_240 = self.Caster
        local SlashBuff = ____opt_240 and ____opt_240:AddNewModifier(self.Caster, self.GanryuuJima, ____exports.musashi_modifier_ganryuu_jima_slash.name, {undefined = undefined})
        SlashBuff.TargetPoint = Position
        SlashBuff:StartIntervalThink(0.03)
    end
end
function musashi_modifier_ganryuu_jima.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_242 = self.Caster
    if ____opt_242 ~= nil then
        ____opt_242:SetForwardVector(self.Caster:GetAbsOrigin():Normalized())
    end
    local ____opt_244 = self.Caster
    if ____opt_244 ~= nil then
        ____opt_244:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    end
    local ____FindClearSpaceForUnit_249 = FindClearSpaceForUnit
    local ____self_Caster_248 = self.Caster
    local ____opt_246 = self.Caster
    ____FindClearSpaceForUnit_249(
        ____self_Caster_248,
        ____opt_246 and ____opt_246:GetAbsOrigin(),
        true
    )
    local ____opt_250 = self.Caster
    local ModifierTengan = ____opt_250 and ____opt_250:FindModifierByName(____exports.musashi_modifier_tengan.name)
    if ModifierTengan ~= nil then
        ModifierTengan:Destroy()
    end
    local ____opt_254 = self.Caster
    local ModifierTenmaGogan = ____opt_254 and ____opt_254:FindModifierByName(____exports.musashi_modifier_tenma_gogan.name)
    if ModifierTenmaGogan then
        local ____opt_256 = self.GanryuuJima
        if ____opt_256 ~= nil then
            ____opt_256:EndCooldown()
        end
        local ____opt_258 = self.Caster
        if ____opt_258 ~= nil then
            local ____opt_258_GiveMana_261 = ____opt_258.GiveMana
            local ____opt_259 = self.GanryuuJima
            ____opt_258_GiveMana_261(
                ____opt_258,
                ____opt_259 and ____opt_259:GetManaCost(-1)
            )
        end
        if ModifierTenmaGogan ~= nil then
            ModifierTenmaGogan:IncrementStackCount()
        end
    end
end
function musashi_modifier_ganryuu_jima.prototype.CheckState(self)
    local ModifierTable = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
    return ModifierTable
end
function musashi_modifier_ganryuu_jima.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ganryuu_jima.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_ganryuu_jima = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ganryuu_jima
)
____exports.musashi_modifier_ganryuu_jima = musashi_modifier_ganryuu_jima
____exports.musashi_modifier_ganryuu_jima_dash = __TS__Class()
local musashi_modifier_ganryuu_jima_dash = ____exports.musashi_modifier_ganryuu_jima_dash
musashi_modifier_ganryuu_jima_dash.name = "musashi_modifier_ganryuu_jima_dash"
__TS__ClassExtends(musashi_modifier_ganryuu_jima_dash, BaseModifier)
function musashi_modifier_ganryuu_jima_dash.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.TargetPoint = Vector(0, 0, 0)
    self.NormalizedTargetPoint = Vector(0, 0, 0)
    self.SlashRange = 0
    self.UnitsTravelled = 0
    self.DashSpeed = 0
end
function musashi_modifier_ganryuu_jima_dash.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_265 = self.Ability
    self.SlashRange = ____opt_265 and ____opt_265:GetSpecialValueFor("SlashRange")
    local ____opt_267 = self.Ability
    self.DashSpeed = ____opt_267 and ____opt_267:GetSpecialValueFor("DashSpeed")
end
function musashi_modifier_ganryuu_jima_dash.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    local ____opt_269 = self.Caster
    if ____opt_269 ~= nil then
        ____opt_269:SetForwardVector(self.NormalizedTargetPoint)
    end
    local ____opt_271 = self.Caster
    local CurrentOrigin = ____opt_271 and ____opt_271:GetAbsOrigin()
    local ____opt_273 = self.Caster
    local NewPosition = CurrentOrigin + (____opt_273 and ____opt_273:GetForwardVector()) * self.DashSpeed
    self.UnitsTravelled = self.UnitsTravelled + (NewPosition - CurrentOrigin):Length2D()
    local ____opt_275 = self.Caster
    if ____opt_275 ~= nil then
        ____opt_275:SetAbsOrigin(NewPosition)
    end
    local ____Entities_FindByNameWithin_279 = Entities.FindByNameWithin
    local ____opt_277 = self.Caster
    local Musashi = ____Entities_FindByNameWithin_279(
        Entities,
        nil,
        ____opt_277 and ____opt_277:GetName(),
        self.TargetPoint,
        self.DashSpeed
    )
    if Musashi or self.UnitsTravelled >= self.SlashRange then
        self:Destroy()
    end
end
function musashi_modifier_ganryuu_jima_dash.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_280 = self.Caster
    local ModifierGanryuuJima = ____opt_280 and ____opt_280:FindModifierByName(____exports.musashi_modifier_ganryuu_jima.name)
    if ModifierGanryuuJima ~= nil then
        ModifierGanryuuJima:IncrementStackCount()
    end
end
function musashi_modifier_ganryuu_jima_dash.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end
function musashi_modifier_ganryuu_jima_dash.prototype.GetOverrideAnimation(self)
    return ACT_DOTA_OVERRIDE_ABILITY_1
end
function musashi_modifier_ganryuu_jima_dash.prototype.GetOverrideAnimationRate(self)
    return 2
end
function musashi_modifier_ganryuu_jima_dash.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ganryuu_jima_dash.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ganryuu_jima_dash.prototype.IsHidden(self)
    return true
end
musashi_modifier_ganryuu_jima_dash = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ganryuu_jima_dash
)
____exports.musashi_modifier_ganryuu_jima_dash = musashi_modifier_ganryuu_jima_dash
____exports.musashi_modifier_ganryuu_jima_slash = __TS__Class()
local musashi_modifier_ganryuu_jima_slash = ____exports.musashi_modifier_ganryuu_jima_slash
musashi_modifier_ganryuu_jima_slash.name = "musashi_modifier_ganryuu_jima_slash"
__TS__ClassExtends(musashi_modifier_ganryuu_jima_slash, BaseModifier)
function musashi_modifier_ganryuu_jima_slash.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.SoundSfx = "musashi_ganryuu_jima_sfx"
    self.TargetPoint = Vector(0, 0, 0)
    self.StartPosition = Vector(0, 0, 0)
    self.EndPosition = Vector(0, 0, 0)
    self.SlashRange = 0
    self.UnitsTravelled = 0
    self.DashSpeed = 0
end
function musashi_modifier_ganryuu_jima_slash.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_284 = self.Caster
    self.StartPosition = ____opt_284 and ____opt_284:GetAbsOrigin()
    local ____opt_286 = self.Ability
    self.SlashRange = ____opt_286 and ____opt_286:GetSpecialValueFor("SlashRange")
    local ____opt_288 = self.Ability
    self.DashSpeed = ____opt_288 and ____opt_288:GetSpecialValueFor("DashSpeed")
    local ____opt_290 = self.Caster
    if ____opt_290 ~= nil then
        ____opt_290:EmitSound(self.SoundSfx)
    end
end
function musashi_modifier_ganryuu_jima_slash.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    local ____opt_292 = self.Caster
    if ____opt_292 ~= nil then
        ____opt_292:SetForwardVector(self.TargetPoint)
    end
    local ____opt_294 = self.Caster
    local CurrentOrigin = ____opt_294 and ____opt_294:GetAbsOrigin()
    local ____opt_296 = self.Caster
    local NewPosition = CurrentOrigin + (____opt_296 and ____opt_296:GetForwardVector()) * self.DashSpeed
    self.UnitsTravelled = self.UnitsTravelled + (NewPosition - CurrentOrigin):Length2D()
    local ____opt_298 = self.Caster
    if ____opt_298 ~= nil then
        ____opt_298:SetAbsOrigin(NewPosition)
    end
    if self.UnitsTravelled >= self.SlashRange then
        self:Destroy()
    end
end
function musashi_modifier_ganryuu_jima_slash.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_300 = self.Caster
    self.EndPosition = ____opt_300 and ____opt_300:GetAbsOrigin()
    self:DealDamage()
    self:CreateParticle()
    local ____opt_302 = self.Caster
    local ModifierGanryuuJima = ____opt_302 and ____opt_302:FindModifierByName(____exports.musashi_modifier_ganryuu_jima.name)
    if ModifierGanryuuJima ~= nil then
        ModifierGanryuuJima:IncrementStackCount()
    end
end
function musashi_modifier_ganryuu_jima_slash.prototype.DealDamage(self)
    local ____opt_306 = self.Ability
    local DmgPerSlash = ____opt_306 and ____opt_306:GetSpecialValueFor("DmgPerSlash")
    local ____opt_308 = self.Ability
    local BonusDmgPerAgi = ____opt_308 and ____opt_308:GetSpecialValueFor("BonusDmgPerAgi")
    local Damage = DmgPerSlash + self.Caster:GetAgility() * BonusDmgPerAgi
    local ____opt_310 = self.Ability
    local DmgType = ____opt_310 and ____opt_310:GetAbilityDamageType()
    local DmgFlag = DOTA_DAMAGE_FLAG_NONE
    local ____FindUnitsInLine_323 = FindUnitsInLine
    local ____opt_312 = self.Caster
    local ____array_322 = __TS__SparseArrayNew(
        ____opt_312 and ____opt_312:GetTeam(),
        self.StartPosition,
        self.EndPosition,
        nil
    )
    local ____opt_314 = self.Ability
    __TS__SparseArrayPush(
        ____array_322,
        ____opt_314 and ____opt_314:GetSpecialValueFor("SlashRadius")
    )
    local ____opt_316 = self.Ability
    __TS__SparseArrayPush(
        ____array_322,
        ____opt_316 and ____opt_316:GetAbilityTargetTeam()
    )
    local ____opt_318 = self.Ability
    __TS__SparseArrayPush(
        ____array_322,
        ____opt_318 and ____opt_318:GetAbilityTargetType()
    )
    local ____opt_320 = self.Ability
    __TS__SparseArrayPush(
        ____array_322,
        ____opt_320 and ____opt_320:GetAbilityTargetFlags()
    )
    local Targets = ____FindUnitsInLine_323(__TS__SparseArraySpread(____array_322))
    for ____, Iterator in ipairs(Targets) do
        DoDamage(
            self.Caster,
            Iterator,
            Damage,
            DmgType,
            DmgFlag,
            self.Ability,
            false
        )
    end
    local ____opt_324 = self.Caster
    if ____opt_324 and ____opt_324:HasModifier(____exports.musashi_modifier_tengan.name) then
        local ____opt_326 = self.Ability
        local DmgDelay = ____opt_326 and ____opt_326:GetSpecialValueFor("DebuffDmgDelay")
        local TargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        local ____FindUnitsInLine_335 = FindUnitsInLine
        local ____array_334 = __TS__SparseArrayNew(
            self.Caster:GetTeam(),
            self.StartPosition,
            self.EndPosition,
            nil
        )
        local ____opt_328 = self.Ability
        __TS__SparseArrayPush(
            ____array_334,
            ____opt_328 and ____opt_328:GetSpecialValueFor("SlashRadius")
        )
        local ____opt_330 = self.Ability
        __TS__SparseArrayPush(
            ____array_334,
            ____opt_330 and ____opt_330:GetAbilityTargetTeam()
        )
        local ____opt_332 = self.Ability
        __TS__SparseArrayPush(
            ____array_334,
            ____opt_332 and ____opt_332:GetAbilityTargetType(),
            TargetFlags
        )
        local Targets = ____FindUnitsInLine_335(__TS__SparseArraySpread(____array_334))
        for ____, Iterator in ipairs(Targets) do
            Iterator:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_ganryuu_jima_debuff.name, {duration = DmgDelay})
        end
    end
end
function musashi_modifier_ganryuu_jima_slash.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_ganryuu_jima_basic.vpcf"
    local ____opt_336 = self.Caster
    if ____opt_336 and ____opt_336:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_ganryuu_jima_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_WORLDORIGIN, self.Caster)
    ParticleManager:SetParticleControl(Particle, 0, self.StartPosition)
    ParticleManager:SetParticleControl(Particle, 1, self.EndPosition)
end
function musashi_modifier_ganryuu_jima_slash.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end
function musashi_modifier_ganryuu_jima_slash.prototype.GetOverrideAnimation(self)
    return ACT_DOTA_OVERRIDE_ABILITY_2
end
function musashi_modifier_ganryuu_jima_slash.prototype.GetOverrideAnimationRate(self)
    return 4
end
function musashi_modifier_ganryuu_jima_slash.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ganryuu_jima_slash.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ganryuu_jima_slash.prototype.IsHidden(self)
    return true
end
musashi_modifier_ganryuu_jima_slash = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ganryuu_jima_slash
)
____exports.musashi_modifier_ganryuu_jima_slash = musashi_modifier_ganryuu_jima_slash
____exports.musashi_modifier_ganryuu_jima_debuff = __TS__Class()
local musashi_modifier_ganryuu_jima_debuff = ____exports.musashi_modifier_ganryuu_jima_debuff
musashi_modifier_ganryuu_jima_debuff.name = "musashi_modifier_ganryuu_jima_debuff"
__TS__ClassExtends(musashi_modifier_ganryuu_jima_debuff, BaseModifier)
function musashi_modifier_ganryuu_jima_debuff.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.BonusDmg = 0
end
function musashi_modifier_ganryuu_jima_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    local ____opt_338 = self.Caster
    local ModifierTengan = ____opt_338 and ____opt_338:FindModifierByName(____exports.musashi_modifier_tengan.name)
    self.BonusDmg = ModifierTengan.BonusDmg
    self:CreateParticle()
end
function musashi_modifier_ganryuu_jima_debuff.prototype.OnRefresh(self)
    if not IsServer() then
        return
    end
    self:OnCreated()
end
function musashi_modifier_ganryuu_jima_debuff.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    self:DealDamage()
end
function musashi_modifier_ganryuu_jima_debuff.prototype.DealDamage(self)
    local Victim = self:GetParent()
    local DmgType = DAMAGE_TYPE_PURE
    local DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
    DoDamage(
        self.Caster,
        Victim,
        self.BonusDmg,
        DmgType,
        DmgFlag,
        self:GetAbility(),
        false
    )
end
function musashi_modifier_ganryuu_jima_debuff.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_ganryuu_jima_debuff_basic.vpcf"
    local ____opt_340 = self.Caster
    if ____opt_340 and ____opt_340:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_ganryuu_jima_debuff_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_ganryuu_jima_debuff.prototype.IsDebuff(self)
    return true
end
function musashi_modifier_ganryuu_jima_debuff.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ganryuu_jima_debuff.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_ganryuu_jima_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ganryuu_jima_debuff
)
____exports.musashi_modifier_ganryuu_jima_debuff = musashi_modifier_ganryuu_jima_debuff
____exports.musashi_mukyuu = __TS__Class()
local musashi_mukyuu = ____exports.musashi_mukyuu
musashi_mukyuu.name = "musashi_mukyuu"
__TS__ClassExtends(musashi_mukyuu, BaseAbility)
function musashi_mukyuu.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_03"
    self.SoundSfx = "musashi_mukyuu_sfx"
end
function musashi_mukyuu.prototype.OnSpellStart(self)
    self.Caster = self:GetCaster()
    local BuffDuration = self:GetSpecialValueFor("BuffDuration")
    self.Caster:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_mukyuu.name, {duration = BuffDuration})
    InitSkillSlotChecker(
        self.Caster,
        ____exports.musashi_mukyuu.name,
        ____exports.musashi_tengen_no_hana.name,
        5,
        false
    )
    self:PlaySound()
end
function musashi_mukyuu.prototype.PlaySound(self)
    local ____opt_342 = self.Caster
    if ____opt_342 ~= nil then
        ____opt_342:EmitSound(self.SoundVoiceline)
    end
    local ____opt_344 = self.Caster
    if ____opt_344 ~= nil then
        ____opt_344:EmitSound(self.SoundSfx)
    end
end
musashi_mukyuu = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_mukyuu
)
____exports.musashi_mukyuu = musashi_mukyuu
____exports.musashi_modifier_mukyuu = __TS__Class()
local musashi_modifier_mukyuu = ____exports.musashi_modifier_mukyuu
musashi_modifier_mukyuu.name = "musashi_modifier_mukyuu"
__TS__ClassExtends(musashi_modifier_mukyuu, BaseModifier)
function musashi_modifier_mukyuu.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self:CreateParticle()
end
function musashi_modifier_mukyuu.prototype.CreateParticle(self)
    local ____opt_346 = self.Caster
    if ____opt_346 and ____opt_346:HasModifier("modifier_ascended") then
        local ParticleStr = "particles/custom/musashi/musashi_mukyuu_unique.vpcf"
        local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
        ParticleManager:SetParticleControlEnt(
            Particle,
            1,
            self.Caster,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0, 0, 0),
            false
        )
        self:AddParticle(
            Particle,
            false,
            false,
            -1,
            false,
            false
        )
    else
        local ParticleStr = "particles/custom/musashi/musashi_mukyuu_basic.vpcf"
        local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
        ParticleManager:SetParticleControlEnt(
            Particle,
            0,
            self.Caster,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0, 0, 0),
            false
        )
        ParticleManager:SetParticleControl(
            Particle,
            1,
            Vector(150, 0, 0)
        )
        self:AddParticle(
            Particle,
            false,
            false,
            -1,
            false,
            false
        )
    end
end
function musashi_modifier_mukyuu.prototype.CheckState(self)
    local ModifierTable = {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_UNTARGETABLE] = true}
    return ModifierTable
end
function musashi_modifier_mukyuu.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_mukyuu.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_mukyuu = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_mukyuu
)
____exports.musashi_modifier_mukyuu = musashi_modifier_mukyuu
____exports.musashi_tenma_gogan = __TS__Class()
local musashi_tenma_gogan = ____exports.musashi_tenma_gogan
musashi_tenma_gogan.name = "musashi_tenma_gogan"
__TS__ClassExtends(musashi_tenma_gogan, BaseAbility)
function musashi_tenma_gogan.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_05"
    self.SoundSfx = "musashi_tengan_sfx"
end
function musashi_tenma_gogan.prototype.OnSpellStart(self)
    self.Caster = self:GetCaster()
    local BuffDuration = self:GetSpecialValueFor("BuffDuration")
    local ____opt_348 = self.Caster
    if ____opt_348 ~= nil then
        ____opt_348:AddNewModifier(self.Caster, self, ____exports.musashi_modifier_tenma_gogan.name, {duration = BuffDuration})
    end
    self:PlaySound()
end
function musashi_tenma_gogan.prototype.PlaySound(self)
    local ____opt_350 = self.Caster
    if ____opt_350 ~= nil then
        ____opt_350:EmitSound(self.SoundVoiceline)
    end
    local ____opt_352 = self.Caster
    if ____opt_352 ~= nil then
        ____opt_352:EmitSound(self.SoundSfx)
    end
end
musashi_tenma_gogan = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_tenma_gogan
)
____exports.musashi_tenma_gogan = musashi_tenma_gogan
____exports.musashi_modifier_tenma_gogan = __TS__Class()
local musashi_modifier_tenma_gogan = ____exports.musashi_modifier_tenma_gogan
musashi_modifier_tenma_gogan.name = "musashi_modifier_tenma_gogan"
__TS__ClassExtends(musashi_modifier_tenma_gogan, BaseModifier)
function musashi_modifier_tenma_gogan.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    local ____opt_354 = self.Caster
    local ChargeCounter = ____opt_354 and ____opt_354:FindModifierByName(____exports.musashi_modifier_tengan_chargecounter.name)
    local ____opt_356 = self.Caster
    local Tengan = ____opt_356 and ____opt_356:FindAbilityByName(____exports.musashi_tengan.name)
    if ChargeCounter ~= nil then
        ChargeCounter:SetStackCount(0)
    end
    if ChargeCounter ~= nil then
        ChargeCounter:StartIntervalThink(-1)
    end
    if Tengan ~= nil then
        Tengan:StartCooldown(9999)
    end
    self:CreateParticle()
end
function musashi_modifier_tenma_gogan.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    repeat
        local ____switch258 = stackCount
        local ____cond258 = ____switch258 == 1
        if ____cond258 then
            do
                self:Destroy()
            end
            break
        end
    until true
end
function musashi_modifier_tenma_gogan.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local Ability = self:GetAbility()
    local DebuffDuration = Ability and Ability:GetSpecialValueFor("DebuffDuration")
    local ____opt_366 = self.Caster
    if ____opt_366 ~= nil then
        ____opt_366:AddNewModifier(self.Caster, Ability, ____exports.musashi_modifier_tenma_gogan_debuff.name, {duration = DebuffDuration})
    end
end
function musashi_modifier_tenma_gogan.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_tenma_gogan_basic.vpcf"
    local BodyParticleStr = "particles/custom/musashi/musashi_tenma_gogan_body.vpcf"
    local ____opt_368 = self.Caster
    if ____opt_368 and ____opt_368:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_tenma_gogan_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    local BodyParticle = ParticleManager:CreateParticle(BodyParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
    self:AddParticle(
        BodyParticle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_tenma_gogan.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_tenma_gogan.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_tenma_gogan = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_tenma_gogan
)
____exports.musashi_modifier_tenma_gogan = musashi_modifier_tenma_gogan
____exports.musashi_modifier_tenma_gogan_debuff = __TS__Class()
local musashi_modifier_tenma_gogan_debuff = ____exports.musashi_modifier_tenma_gogan_debuff
musashi_modifier_tenma_gogan_debuff.name = "musashi_modifier_tenma_gogan_debuff"
__TS__ClassExtends(musashi_modifier_tenma_gogan_debuff, BaseModifier)
function musashi_modifier_tenma_gogan_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    local Caster = self:GetCaster()
    local DebuffDuration = self:GetDuration()
    giveUnitDataDrivenModifier(Caster, Caster, "pause_sealdisabled", DebuffDuration)
end
function musashi_modifier_tenma_gogan_debuff.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_tenma_gogan_debuff.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_tenma_gogan_debuff.prototype.IsDebuff(self)
    return true
end
function musashi_modifier_tenma_gogan_debuff.prototype.IsStunDebuff(self)
    return true
end
musashi_modifier_tenma_gogan_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_tenma_gogan_debuff
)
____exports.musashi_modifier_tenma_gogan_debuff = musashi_modifier_tenma_gogan_debuff
____exports.musashi_tengen_no_hana = __TS__Class()
local musashi_tengen_no_hana = ____exports.musashi_tengen_no_hana
musashi_tengen_no_hana.name = "musashi_tengen_no_hana"
__TS__ClassExtends(musashi_tengen_no_hana, BaseAbility)
function musashi_tengen_no_hana.prototype.OnSpellStart(self)
    local Caster = self:GetCaster()
    local ModifierTengenNoHana = Caster:FindModifierByName(____exports.musashi_modifier_tengen_no_hana.name)
    if ModifierTengenNoHana then
        ModifierTengenNoHana:Destroy()
        return
    end
    local BuffDuration = self:GetSpecialValueFor("BuffDuration")
    Caster:AddNewModifier(Caster, self, ____exports.musashi_modifier_tengen_no_hana.name, {duration = BuffDuration})
end
musashi_tengen_no_hana = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_tengen_no_hana
)
____exports.musashi_tengen_no_hana = musashi_tengen_no_hana
____exports.musashi_modifier_tengen_no_hana = __TS__Class()
local musashi_modifier_tengen_no_hana = ____exports.musashi_modifier_tengen_no_hana
musashi_modifier_tengen_no_hana.name = "musashi_modifier_tengen_no_hana"
__TS__ClassExtends(musashi_modifier_tengen_no_hana, BaseModifier)
function musashi_modifier_tengen_no_hana.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_02"
    self.SoundSfx = "musashi_tengen_no_hana_sfx"
    self.Percentage = 0
    self.Radius = 0
end
function musashi_modifier_tengen_no_hana.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_370 = self.Ability
    self.Radius = ____opt_370 and ____opt_370:GetSpecialValueFor("Radius")
    local ____opt_372 = self.Ability
    local RampUpInterval = ____opt_372 and ____opt_372:GetSpecialValueFor("RampUpInterval")
    self:StartIntervalThink(RampUpInterval)
    self:CreateParticle()
    local ____opt_374 = self.Caster
    if ____opt_374 ~= nil then
        ____opt_374:EmitSound(self.SoundSfx)
    end
end
function musashi_modifier_tengen_no_hana.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    self:IncrementStackCount()
end
function musashi_modifier_tengen_no_hana.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    repeat
        local ____switch280 = stackCount
        local ____cond280 = ____switch280 == 0
        if ____cond280 then
            do
                local ____opt_376 = self.Ability
                self.Percentage = ____opt_376 and ____opt_376:GetSpecialValueFor("1SecPercentage")
                break
            end
        end
        ____cond280 = ____cond280 or ____switch280 == 1
        if ____cond280 then
            do
                local ____opt_378 = self.Ability
                self.Percentage = ____opt_378 and ____opt_378:GetSpecialValueFor("2SecPercentage")
                break
            end
        end
        ____cond280 = ____cond280 or ____switch280 == 2
        if ____cond280 then
            do
                local ____opt_380 = self.Ability
                self.Percentage = ____opt_380 and ____opt_380:GetSpecialValueFor("FullPercentage")
                self:Destroy()
                break
            end
        end
    until true
end
function musashi_modifier_tengen_no_hana.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_382 = self.Caster
    local ____temp_386 = ____opt_382 and ____opt_382:HasModifier(____exports.musashi_modifier_niou_kurikara_slashing.name)
    if not ____temp_386 then
        local ____opt_384 = self.Caster
        ____temp_386 = ____opt_384 and ____opt_384:HasModifier(____exports.musashi_modifier_ganryuu_jima.name)
    end
    if ____temp_386 then
        return
    end
    self.Percentage = self.Percentage / 100
    local ____opt_387 = self.Caster
    if ____opt_387 ~= nil then
        ____opt_387:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    end
    self:DealDamage()
    self:CreateAoeParticle()
    local ____opt_389 = self.Caster
    if ____opt_389 ~= nil then
        ____opt_389:EmitSound(self.SoundVoiceline)
    end
    local ____opt_391 = self.Ability
    if ____opt_391 ~= nil then
        ____opt_391:SetHidden(true)
    end
end
function musashi_modifier_tengen_no_hana.prototype.DealDamage(self)
    local ____opt_393 = self.Ability
    local FullDamage = ____opt_393 and ____opt_393:GetSpecialValueFor("FullDamage")
    local ____opt_395 = self.Ability
    local DmgType = ____opt_395 and ____opt_395:GetAbilityDamageType()
    local DmgFlag = DOTA_DAMAGE_FLAG_NONE
    local Damage = self.Percentage * FullDamage
    local ____opt_397 = self.Ability
    local StunDuration = (____opt_397 and ____opt_397:GetSpecialValueFor("StunDuration")) * self.Percentage
    local ____FindUnitsInRadius_410 = FindUnitsInRadius
    local ____opt_399 = self.Caster
    local ____array_409 = __TS__SparseArrayNew(____opt_399 and ____opt_399:GetTeam())
    local ____opt_401 = self.Caster
    __TS__SparseArrayPush(
        ____array_409,
        ____opt_401 and ____opt_401:GetAbsOrigin(),
        nil,
        self.Radius
    )
    local ____opt_403 = self.Ability
    __TS__SparseArrayPush(
        ____array_409,
        ____opt_403 and ____opt_403:GetAbilityTargetTeam()
    )
    local ____opt_405 = self.Ability
    __TS__SparseArrayPush(
        ____array_409,
        ____opt_405 and ____opt_405:GetAbilityTargetType()
    )
    local ____opt_407 = self.Ability
    __TS__SparseArrayPush(
        ____array_409,
        ____opt_407 and ____opt_407:GetAbilityTargetFlags(),
        FIND_ANY_ORDER,
        false
    )
    local Targets = ____FindUnitsInRadius_410(__TS__SparseArraySpread(____array_409))
    for ____, Iterator in ipairs(Targets) do
        DoDamage(
            self.Caster,
            Iterator,
            Damage,
            DmgType,
            DmgFlag,
            self.Ability,
            false
        )
        Iterator:AddNewModifier(self.Caster, self.Ability, "modifier_stunned", {duration = StunDuration})
    end
end
function musashi_modifier_tengen_no_hana.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_basic.vpcf"
    local ____opt_411 = self.Caster
    if ____opt_411 and ____opt_411:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_unique1.vpcf"
        if self.Caster:HasModifier(____exports.musashi_modifier_battle_continuation_active.name) then
            ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_unique2.vpcf"
        end
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_OVERHEAD_FOLLOW, self.Caster)
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_tengen_no_hana.prototype.CreateAoeParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoe_basic.vpcf"
    local MarkerParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoemarker_basic.vpcf"
    local ____opt_413 = self.Caster
    if ____opt_413 and ____opt_413:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoe_unique1.vpcf"
        MarkerParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoemarker_unique1.vpcf"
        if self.Caster:HasModifier(____exports.musashi_modifier_battle_continuation_active.name) then
            ParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoe_unique2.vpcf"
            MarkerParticleStr = "particles/custom/musashi/musashi_tengen_no_hana_aoemarker_unique2.vpcf"
        end
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_WORLDORIGIN, self.Caster)
    local MarkerParticle = ParticleManager:CreateParticle(MarkerParticleStr, PATTACH_WORLDORIGIN, self.Caster)
    local ____ParticleManager_SetParticleControl_417 = ParticleManager.SetParticleControl
    local ____opt_415 = self.Caster
    ____ParticleManager_SetParticleControl_417(
        ParticleManager,
        Particle,
        0,
        ____opt_415 and ____opt_415:GetAbsOrigin()
    )
    ParticleManager:SetParticleControl(
        Particle,
        2,
        Vector(self.Radius, self.Radius, self.Radius)
    )
    local ____ParticleManager_SetParticleControl_420 = ParticleManager.SetParticleControl
    local ____opt_418 = self.Caster
    ____ParticleManager_SetParticleControl_420(
        ParticleManager,
        MarkerParticle,
        0,
        ____opt_418 and ____opt_418:GetAbsOrigin()
    )
    ParticleManager:SetParticleControl(
        MarkerParticle,
        2,
        Vector(self.Radius, self.Radius, self.Radius)
    )
end
function musashi_modifier_tengen_no_hana.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_tengen_no_hana.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_tengen_no_hana = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_tengen_no_hana
)
____exports.musashi_modifier_tengen_no_hana = musashi_modifier_tengen_no_hana
____exports.musashi_battle_continuation = __TS__Class()
local musashi_battle_continuation = ____exports.musashi_battle_continuation
musashi_battle_continuation.name = "musashi_battle_continuation"
__TS__ClassExtends(musashi_battle_continuation, BaseAbility)
function musashi_battle_continuation.prototype.GetIntrinsicModifierName(self)
    return ____exports.musashi_modifier_battle_continuation.name
end
musashi_battle_continuation = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_battle_continuation
)
____exports.musashi_battle_continuation = musashi_battle_continuation
____exports.musashi_modifier_battle_continuation = __TS__Class()
local musashi_modifier_battle_continuation = ____exports.musashi_modifier_battle_continuation
musashi_modifier_battle_continuation.name = "musashi_modifier_battle_continuation"
__TS__ClassExtends(musashi_modifier_battle_continuation, BaseModifier)
function musashi_modifier_battle_continuation.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
end
function musashi_modifier_battle_continuation.prototype.OnTakeDamage(self, event)
    if not IsServer() or event.unit ~= self.Caster then
        return
    end
    local ____opt_421 = self.Ability
    local DmgThreshold = ____opt_421 and ____opt_421:GetSpecialValueFor("DmgThreshold")
    if not self.Caster:HasModifier("musashi_attribute_battle_continuation") or self.Caster:HasModifier(____exports.musashi_modifier_battle_continuation_cooldown.name) or self.Caster:HasModifier(____exports.musashi_modifier_tenma_gogan_debuff.name) or event.damage >= DmgThreshold or not IsRevivePossible(self.Caster) then
        return
    end
    if self.Caster:GetHealth() <= 0 then
        local ____opt_423 = self.Ability
        local BuffDuration = ____opt_423 and ____opt_423:GetSpecialValueFor("BuffDuration")
        self.Caster:SetHealth(1)
        self.Caster:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_battle_continuation_active.name, {duration = BuffDuration})
        local ____self_428 = self.Caster
        local ____self_428_AddNewModifier_429 = ____self_428.AddNewModifier
        local ____array_427 = __TS__SparseArrayNew(self.Caster, self.Ability, ____exports.musashi_modifier_battle_continuation_cooldown.name)
        local ____opt_425 = self.Ability
        __TS__SparseArrayPush(
            ____array_427,
            {duration = ____opt_425 and ____opt_425:GetCooldown(1)}
        )
        ____self_428_AddNewModifier_429(
            ____self_428,
            __TS__SparseArraySpread(____array_427)
        )
        local ____opt_430 = self.Ability
        if ____opt_430 ~= nil then
            ____opt_430:UseResources(true, false, false, true)
        end
    end
end
function musashi_modifier_battle_continuation.prototype.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function musashi_modifier_battle_continuation.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_battle_continuation.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_battle_continuation.prototype.IsPermanent(self)
    return true
end
function musashi_modifier_battle_continuation.prototype.IsHidden(self)
    return true
end
function musashi_modifier_battle_continuation.prototype.RemoveOnDeath(self)
    return false
end
musashi_modifier_battle_continuation = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_battle_continuation
)
____exports.musashi_modifier_battle_continuation = musashi_modifier_battle_continuation
____exports.musashi_modifier_battle_continuation_active = __TS__Class()
local musashi_modifier_battle_continuation_active = ____exports.musashi_modifier_battle_continuation_active
musashi_modifier_battle_continuation_active.name = "musashi_modifier_battle_continuation_active"
__TS__ClassExtends(musashi_modifier_battle_continuation_active, BaseModifier)
function musashi_modifier_battle_continuation_active.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_04"
    self.SoundSfx = "musashi_battle_continuation_sfx"
end
function musashi_modifier_battle_continuation_active.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    local ____opt_432 = self.Caster
    local TengenNoHana = ____opt_432 and ____opt_432:FindAbilityByName(____exports.musashi_tengen_no_hana.name)
    local ____opt_434 = self.Caster
    if ____opt_434 ~= nil then
        ____opt_434:CastAbilityImmediately(
            TengenNoHana,
            self.Caster:GetEntityIndex()
        )
    end
    ProjectileManager:ProjectileDodge(self.Caster)
    local ____opt_436 = self.Caster
    if ____opt_436 ~= nil then
        ____opt_436:Purge(
            false,
            true,
            false,
            false,
            false
        )
    end
    self:CreateParticle()
    self:PlaySound()
end
function musashi_modifier_battle_continuation_active.prototype.PlaySound(self)
    local ____opt_438 = self.Caster
    if ____opt_438 ~= nil then
        ____opt_438:EmitSound(self.SoundVoiceline)
    end
    local ____opt_440 = self.Caster
    if ____opt_440 ~= nil then
        ____opt_440:EmitSound(self.SoundSfx)
    end
end
function musashi_modifier_battle_continuation_active.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_battle_continuation_basic.vpcf"
    local ____opt_442 = self.Caster
    if ____opt_442 and ____opt_442:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_battle_continuation_unique.vpcf"
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    ParticleManager:SetParticleControlEnt(
        Particle,
        5,
        self.Caster,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0, 0, 0),
        false
    )
    self:AddParticle(
        Particle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_battle_continuation_active.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_DISABLE_HEALING}
end
function musashi_modifier_battle_continuation_active.prototype.GetMinHealth(self)
    return 1
end
function musashi_modifier_battle_continuation_active.prototype.GetDisableHealing(self)
    return 1
end
function musashi_modifier_battle_continuation_active.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_battle_continuation_active.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_battle_continuation_active = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_battle_continuation_active
)
____exports.musashi_modifier_battle_continuation_active = musashi_modifier_battle_continuation_active
____exports.musashi_modifier_battle_continuation_cooldown = __TS__Class()
local musashi_modifier_battle_continuation_cooldown = ____exports.musashi_modifier_battle_continuation_cooldown
musashi_modifier_battle_continuation_cooldown.name = "musashi_modifier_battle_continuation_cooldown"
__TS__ClassExtends(musashi_modifier_battle_continuation_cooldown, BaseModifier)
function musashi_modifier_battle_continuation_cooldown.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_battle_continuation_cooldown.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_battle_continuation_cooldown.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_battle_continuation_cooldown.prototype.RemoveOnDeath(self)
    return false
end
function musashi_modifier_battle_continuation_cooldown.prototype.IsDebuff(self)
    return true
end
musashi_modifier_battle_continuation_cooldown = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_battle_continuation_cooldown
)
____exports.musashi_modifier_battle_continuation_cooldown = musashi_modifier_battle_continuation_cooldown
____exports.musashi_niou = __TS__Class()
local musashi_niou = ____exports.musashi_niou
musashi_niou.name = "musashi_niou"
__TS__ClassExtends(musashi_niou, BaseAbility)
function musashi_niou.prototype.OnSpellStart(self)
    local Caster = self:GetCaster()
    self.Niou = CreateUnitByName(
        "musashi_niou",
        Caster:GetAbsOrigin(),
        false,
        Caster,
        Caster,
        Caster:GetTeam()
    )
    local ModelScale = self:GetSpecialValueFor("ModelScale")
    if Caster:HasModifier(____exports.musashi_modifier_ishana_daitenshou.name) then
        ModelScale = 6
    end
    self.Niou:SetModelScale(ModelScale)
    self.Niou:AddNewModifier(self.Niou, self, ____exports.musashi_modifier_niou.name, {undefined = undefined})
end
function musashi_niou.prototype.DestroyNiou(self, delay)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local ____opt_444 = self.Niou
        if ____opt_444 ~= nil then
            ____opt_444:ForceKill(false)
        end
        __TS__Await(Sleep(nil, delay))
        local ____opt_446 = self.Niou
        if ____opt_446 ~= nil then
            ____opt_446:Destroy()
        end
    end)
end
musashi_niou = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_niou
)
____exports.musashi_niou = musashi_niou
____exports.musashi_modifier_niou = __TS__Class()
local musashi_modifier_niou = ____exports.musashi_modifier_niou
musashi_modifier_niou.name = "musashi_modifier_niou"
__TS__ClassExtends(musashi_modifier_niou, BaseModifier)
function musashi_modifier_niou.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_niou.prototype.CheckState(self)
    local ModifierTable = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
    return ModifierTable
end
function musashi_modifier_niou.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_niou.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_niou.prototype.IsPermanent(self)
    return true
end
function musashi_modifier_niou.prototype.IsHidden(self)
    return true
end
musashi_modifier_niou = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_niou
)
____exports.musashi_modifier_niou = musashi_modifier_niou
____exports.musashi_dai_go_sei_wave = __TS__Class()
local musashi_dai_go_sei_wave = ____exports.musashi_dai_go_sei_wave
musashi_dai_go_sei_wave.name = "musashi_dai_go_sei_wave"
__TS__ClassExtends(musashi_dai_go_sei_wave, BaseAbility)
function musashi_dai_go_sei_wave.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_08"
    self.SoundSfx = "musashi_dai_go_sei_wave_sfx"
    self.Damage = 0
end
function musashi_dai_go_sei_wave.prototype.OnSpellStart(self)
    self.Caster = self:GetCaster()
    self:SetDamageParameters()
    self:CreateProjectile()
    self:PlaySound()
end
function musashi_dai_go_sei_wave.prototype.SetDamageParameters(self)
    self.Damage = self:GetSpecialValueFor("Damage")
    self.DmgType = self:GetAbilityDamageType()
    self.DmgFlag = DOTA_DAMAGE_FLAG_NONE
end
function musashi_dai_go_sei_wave.prototype.CreateProjectile(self)
    local ParticleStr = "particles/custom/musashi/musashi_dai_go_sei_wave_basic.vpcf"
    local ____opt_448 = self.Caster
    if ____opt_448 and ____opt_448:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_dai_go_sei_wave_unique.vpcf"
    end
    local ____opt_450 = self:GetCursorTarget()
    local ____temp_454 = ____opt_450 and ____opt_450:GetAbsOrigin()
    local ____opt_452 = self.Caster
    local Direction = (____temp_454 - (____opt_452 and ____opt_452:GetAbsOrigin())):Normalized()
    local ____ProjectileManager_CreateLinearProjectile_459 = ProjectileManager.CreateLinearProjectile
    local ____ParticleStr_457 = ParticleStr
    local ____self_Caster_458 = self.Caster
    local ____opt_455 = self.Caster
    ____ProjectileManager_CreateLinearProjectile_459(
        ProjectileManager,
        {
            EffectName = ____ParticleStr_457,
            Ability = self,
            Source = ____self_Caster_458,
            vSpawnOrigin = ____opt_455 and ____opt_455:GetAbsOrigin(),
            vVelocity = Direction * self:GetSpecialValueFor("ProjectileSpeed"),
            fDistance = self:GetSpecialValueFor("Range"),
            fStartRadius = self:GetSpecialValueFor("ProjectileRadius"),
            fEndRadius = self:GetSpecialValueFor("ProjectileRadius"),
            iUnitTargetTeam = self:GetAbilityTargetTeam(),
            iUnitTargetFlags = self:GetAbilityTargetFlags(),
            iUnitTargetType = self:GetAbilityTargetType()
        }
    )
end
function musashi_dai_go_sei_wave.prototype.OnProjectileHit(self, target)
    if not IsServer() then
        return
    end
    DoDamage(
        self.Caster,
        target,
        self.Damage,
        self.DmgType,
        self.DmgFlag,
        self,
        false
    )
end
function musashi_dai_go_sei_wave.prototype.PlaySound(self)
    local ____opt_460 = self.Caster
    if ____opt_460 ~= nil then
        ____opt_460:EmitSound(self.SoundVoiceline)
    end
    local ____opt_462 = self.Caster
    if ____opt_462 ~= nil then
        ____opt_462:EmitSound(self.SoundSfx)
    end
end
function musashi_dai_go_sei_wave.prototype.GetIntrinsicModifierName(self)
    return ____exports.musashi_modifier_dai_go_sei_wave_counter.name
end
musashi_dai_go_sei_wave = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_dai_go_sei_wave
)
____exports.musashi_dai_go_sei_wave = musashi_dai_go_sei_wave
____exports.musashi_modifier_dai_go_sei_wave_counter = __TS__Class()
local musashi_modifier_dai_go_sei_wave_counter = ____exports.musashi_modifier_dai_go_sei_wave_counter
musashi_modifier_dai_go_sei_wave_counter.name = "musashi_modifier_dai_go_sei_wave_counter"
__TS__ClassExtends(musashi_modifier_dai_go_sei_wave_counter, BaseModifier)
function musashi_modifier_dai_go_sei_wave_counter.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    self:IncrementStackCount()
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    local ____opt_464 = self.Ability
    if ____opt_464 ~= nil then
        ____opt_464:SetLevel(stackCount + 1)
    end
    self:StartIntervalThink(10)
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    self:StartIntervalThink(-1)
    self:SetStackCount(0)
    self:IncrementStackCount()
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.OnAbilityFullyCast(self, event)
    if not IsServer() or event.unit ~= self.Caster or event.ability ~= self.Ability then
        return
    end
    if self:GetStackCount() < 5 then
        self:IncrementStackCount()
    end
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.GetModifierOverrideAbilitySpecialValue(self, event)
    local ____opt_466 = self.Caster
    local DaiGoSei = ____opt_466 and ____opt_466:FindAbilityByName(____exports.musashi_dai_go_sei.name)
    if event.ability_special_value == "Damage" then
        local ____opt_468 = self.Ability
        local BaseDmg = ____opt_468 and ____opt_468:GetSpecialValueFor("BaseDamage")
        local ____opt_470 = self.Ability
        local BonusDmgFromAtkDmg = ____opt_470 and ____opt_470:GetSpecialValueFor("BonusDmgFromAtkDmg")
        local ____opt_472 = self.Ability
        local BonusDmgFromWBuff = ____opt_472 and ____opt_472:GetSpecialValueFor("BonusDmgFromWBuff")
        local Damage = BaseDmg + BonusDmgFromAtkDmg + BonusDmgFromWBuff
        return Damage
    elseif event.ability_special_value == "BaseDamage" then
        local AbilityLevel = DaiGoSei and DaiGoSei:GetLevel()
        return 100 * AbilityLevel
    elseif event.ability_special_value == "BonusDmgFromAtkDmg" then
        local ____opt_476 = self.Caster
        return ____opt_476 and ____opt_476:GetDamageMax()
    elseif event.ability_special_value == "BonusDmgFromWBuff" then
        local ____opt_478 = self.Caster
        if ____opt_478 and ____opt_478:HasModifier(____exports.musashi_modifier_dai_go_sei.name) then
            local BonusAtkDmg = DaiGoSei and DaiGoSei:GetSpecialValueFor("BonusAtkDmg")
            return 2 * BonusAtkDmg
        end
    end
    return 0
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.GetModifierOverrideAbilitySpecial(self, event)
    if event.ability == self.Ability then
        if event.ability_special_value == "Damage" or event.ability_special_value == "BaseDamage" or event.ability_special_value == "BonusDmgFromAtkDmg" or event.ability_special_value == "BonusDmgFromWBuff" then
            return 1
        end
    end
    return 0
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL}
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.IsHidden(self)
    if self:GetStackCount() <= 1 then
        return true
    end
    return false
end
function musashi_modifier_dai_go_sei_wave_counter.prototype.IsPermanent(self)
    return true
end
musashi_modifier_dai_go_sei_wave_counter = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_dai_go_sei_wave_counter
)
____exports.musashi_modifier_dai_go_sei_wave_counter = musashi_modifier_dai_go_sei_wave_counter
____exports.musashi_ishana_daitenshou = __TS__Class()
local musashi_ishana_daitenshou = ____exports.musashi_ishana_daitenshou
musashi_ishana_daitenshou.name = "musashi_ishana_daitenshou"
__TS__ClassExtends(musashi_ishana_daitenshou, BaseAbility)
function musashi_ishana_daitenshou.prototype.____constructor(self, ...)
    BaseAbility.prototype.____constructor(self, ...)
    self.SoundVoiceline = "antimage_anti_ability_manavoid_06"
    self.SoundBgm = "musashi_ishana_daitenshou_bgm"
end
function musashi_ishana_daitenshou.prototype.OnSpellStart(self)
    local Caster = self:GetCaster()
    local NiouKurikara = Caster:FindAbilityByName(____exports.musashi_niou_kurikara.name)
    if NiouKurikara ~= nil then
        NiouKurikara:EndCooldown()
    end
    Caster:GiveMana(NiouKurikara and NiouKurikara:GetManaCost(-1))
    Caster:AddNewModifier(Caster, self, ____exports.musashi_modifier_ishana_daitenshou.name, {duration = 10})
    Caster:AddNewModifier(
        Caster,
        self,
        ____exports.musashi_modifier_ishana_daitenshou_cooldown.name,
        {duration = self:GetCooldown(1)}
    )
    self:PlaySound()
end
function musashi_ishana_daitenshou.prototype.PlaySound(self)
    EmitGlobalSound(self.SoundVoiceline)
    EmitGlobalSound(self.SoundBgm)
end
musashi_ishana_daitenshou = __TS__DecorateLegacy(
    {registerAbility(nil)},
    musashi_ishana_daitenshou
)
____exports.musashi_ishana_daitenshou = musashi_ishana_daitenshou
____exports.musashi_modifier_ishana_daitenshou = __TS__Class()
local musashi_modifier_ishana_daitenshou = ____exports.musashi_modifier_ishana_daitenshou
musashi_modifier_ishana_daitenshou.name = "musashi_modifier_ishana_daitenshou"
__TS__ClassExtends(musashi_modifier_ishana_daitenshou, BaseModifier)
function musashi_modifier_ishana_daitenshou.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.MarkerPosition = Vector(0, 0, 0)
    self.StartPosition = Vector(0, 0, 0)
    self.SearchRadius = 0
end
function musashi_modifier_ishana_daitenshou.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_486 = self.Ability
    self.Victim = ____opt_486 and ____opt_486:GetCursorTarget()
    local ____opt_488 = self.Caster
    self.StartPosition = ____opt_488 and ____opt_488:GetAbsOrigin()
    local ____opt_490 = self.Victim
    self.MarkerPosition = ____opt_490 and ____opt_490:GetAbsOrigin()
    local ____opt_492 = self.Caster
    local NiouKurikara = ____opt_492 and ____opt_492:FindAbilityByName(____exports.musashi_niou_kurikara.name)
    local ____opt_494 = self.Caster
    if ____opt_494 ~= nil then
        ____opt_494:CastAbilityOnPosition(
            self.MarkerPosition,
            NiouKurikara,
            self.Caster:GetEntityIndex()
        )
    end
    local ____opt_496 = self.Ability
    self.SearchRadius = ____opt_496 and ____opt_496:GetSpecialValueFor("SearchRadius")
    self:CreateParticle()
end
function musashi_modifier_ishana_daitenshou.prototype.OnStackCountChanged(self, stackCount)
    if not IsServer() then
        return
    end
    repeat
        local ____switch375 = stackCount
        local ____cond375 = ____switch375 == 0
        if ____cond375 then
            do
                local ____Entities_FindByNameWithin_500 = Entities.FindByNameWithin
                local ____opt_498 = self.Victim
                local VictimEntity = ____Entities_FindByNameWithin_500(
                    Entities,
                    nil,
                    ____opt_498 and ____opt_498:GetName(),
                    self.MarkerPosition,
                    self.SearchRadius
                )
                local ____VictimEntity_503 = VictimEntity
                if ____VictimEntity_503 then
                    local ____opt_501 = self.Victim
                    ____VictimEntity_503 = ____opt_501 and ____opt_501:IsAlive()
                end
                if ____VictimEntity_503 then
                    local ____opt_504 = self.Caster
                    if ____opt_504 ~= nil then
                        ____opt_504:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_ishana_daitenshou_dash.name, {undefined = undefined})
                    end
                else
                    self:Destroy()
                end
                break
            end
        end
        ____cond375 = ____cond375 or ____switch375 == 1
        if ____cond375 then
            do
                local ____opt_506 = self.Caster
                if ____opt_506 ~= nil then
                    ____opt_506:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_ishana_daitenshou_slash.name, {undefined = undefined})
                end
                break
            end
        end
        ____cond375 = ____cond375 or ____switch375 == 2
        if ____cond375 then
            do
                self:Destroy()
                break
            end
        end
    until true
end
function musashi_modifier_ishana_daitenshou.prototype.CreateParticle(self)
    local MarkerParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_marker_basic.vpcf"
    local SwordParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_sword_basic.vpcf"
    local BodyParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_body_basic.vpcf"
    local ____opt_508 = self.Caster
    if ____opt_508 and ____opt_508:HasModifier("modifier_ascended") then
        MarkerParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_marker_unique.vpcf"
        SwordParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_sword_unique.vpcf"
        BodyParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_body_unique.vpcf"
    end
    local MarkerParticle = ParticleManager:CreateParticle(MarkerParticleStr, PATTACH_WORLDORIGIN, self.Caster)
    local SwordParticle = ParticleManager:CreateParticle(SwordParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    local BodyParticle = ParticleManager:CreateParticle(BodyParticleStr, PATTACH_POINT_FOLLOW, self.Caster)
    ParticleManager:SetParticleControl(MarkerParticle, 0, self.MarkerPosition)
    ParticleManager:SetParticleControlEnt(
        SwordParticle,
        0,
        self.Caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        Vector(0, 0, 0),
        false
    )
    self:AddParticle(
        MarkerParticle,
        false,
        false,
        -1,
        false,
        false
    )
    self:AddParticle(
        SwordParticle,
        false,
        false,
        -1,
        false,
        false
    )
    self:AddParticle(
        BodyParticle,
        false,
        false,
        -1,
        false,
        false
    )
end
function musashi_modifier_ishana_daitenshou.prototype.CheckState(self)
    local ModifierTable = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
    return ModifierTable
end
function musashi_modifier_ishana_daitenshou.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ishana_daitenshou.prototype.IsPurgeException(self)
    return false
end
musashi_modifier_ishana_daitenshou = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ishana_daitenshou
)
____exports.musashi_modifier_ishana_daitenshou = musashi_modifier_ishana_daitenshou
____exports.musashi_modifier_ishana_daitenshou_dash = __TS__Class()
local musashi_modifier_ishana_daitenshou_dash = ____exports.musashi_modifier_ishana_daitenshou_dash
musashi_modifier_ishana_daitenshou_dash.name = "musashi_modifier_ishana_daitenshou_dash"
__TS__ClassExtends(musashi_modifier_ishana_daitenshou_dash, BaseModifier)
function musashi_modifier_ishana_daitenshou_dash.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.DashSpeed = 0
end
function musashi_modifier_ishana_daitenshou_dash.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    local ____opt_510 = self:GetAbility()
    self.DashSpeed = ____opt_510 and ____opt_510:GetSpecialValueFor("DashSpeed")
    local ____opt_512 = self.Caster
    self.ModifierIshanaDaitenshou = ____opt_512 and ____opt_512:FindModifierByName(____exports.musashi_modifier_ishana_daitenshou.name)
    self.Victim = self.ModifierIshanaDaitenshou.Victim
    self:StartIntervalThink(0.03)
end
function musashi_modifier_ishana_daitenshou_dash.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    local ____opt_514 = self.Caster
    local CasterAbsOrigin = ____opt_514 and ____opt_514:GetAbsOrigin()
    local ____opt_516 = self.Victim
    local VictimAbsOrigin = ____opt_516 and ____opt_516:GetAbsOrigin()
    local Direction = (VictimAbsOrigin - CasterAbsOrigin):Normalized()
    local ____opt_518 = self.Caster
    if ____opt_518 ~= nil then
        ____opt_518:SetForwardVector(Direction)
    end
    local ____opt_520 = self.Caster
    local NewPosition = CasterAbsOrigin + (____opt_520 and ____opt_520:GetForwardVector()) * self.DashSpeed
    local ____opt_522 = self.Caster
    if ____opt_522 ~= nil then
        ____opt_522:SetAbsOrigin(NewPosition)
    end
    local ____Entities_FindByNameWithin_526 = Entities.FindByNameWithin
    local ____opt_524 = self.Caster
    local Musashi = ____Entities_FindByNameWithin_526(
        Entities,
        nil,
        ____opt_524 and ____opt_524:GetName(),
        VictimAbsOrigin,
        self.DashSpeed
    )
    if Musashi then
        self:Destroy()
    end
end
function musashi_modifier_ishana_daitenshou_dash.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    local ____opt_527 = self.ModifierIshanaDaitenshou
    if ____opt_527 ~= nil then
        ____opt_527:IncrementStackCount()
    end
    local ____opt_529 = self.Caster
    if ____opt_529 ~= nil then
        ____opt_529:SetForwardVector(self.Caster:GetAbsOrigin():Normalized())
    end
    local ____FindClearSpaceForUnit_534 = FindClearSpaceForUnit
    local ____self_Caster_533 = self.Caster
    local ____opt_531 = self.Caster
    ____FindClearSpaceForUnit_534(
        ____self_Caster_533,
        ____opt_531 and ____opt_531:GetAbsOrigin(),
        true
    )
end
function musashi_modifier_ishana_daitenshou_dash.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ishana_daitenshou_dash.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ishana_daitenshou_dash.prototype.IsHidden(self)
    return true
end
musashi_modifier_ishana_daitenshou_dash = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ishana_daitenshou_dash
)
____exports.musashi_modifier_ishana_daitenshou_dash = musashi_modifier_ishana_daitenshou_dash
____exports.musashi_modifier_ishana_daitenshou_slash = __TS__Class()
local musashi_modifier_ishana_daitenshou_slash = ____exports.musashi_modifier_ishana_daitenshou_slash
musashi_modifier_ishana_daitenshou_slash.name = "musashi_modifier_ishana_daitenshou_slash"
__TS__ClassExtends(musashi_modifier_ishana_daitenshou_slash, BaseModifier)
function musashi_modifier_ishana_daitenshou_slash.prototype.____constructor(self, ...)
    BaseModifier.prototype.____constructor(self, ...)
    self.SoundSfx = "musashi_ishana_daitenshou_sfx"
    self.SlashCount = 0
    self.QuickSlashCount = 0
end
function musashi_modifier_ishana_daitenshou_slash.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
    self.Caster = self:GetCaster()
    self.Ability = self:GetAbility()
    local ____opt_535 = self.Caster
    self.ModifierIshanaDaitenshou = ____opt_535 and ____opt_535:FindModifierByName(____exports.musashi_modifier_ishana_daitenshou.name)
    self.Victim = self.ModifierIshanaDaitenshou.Victim
    giveUnitDataDrivenModifier(self.Caster, self.Victim, "revoked", 1)
    local ____opt_537 = self.Ability
    local QuickSlashInterval = ____opt_537 and ____opt_537:GetSpecialValueFor("QuickSlashInterval")
    local ____opt_539 = self.Ability
    self.QuickSlashCount = ____opt_539 and ____opt_539:GetSpecialValueFor("QuickSlashCount")
    self:StartIntervalThink(QuickSlashInterval)
    EmitGlobalSound(self.SoundSfx)
end
function musashi_modifier_ishana_daitenshou_slash.prototype.OnIntervalThink(self)
    if not IsServer() then
        return
    end
    if self.SlashCount < self.QuickSlashCount then
        self:DealDamage()
        self.SlashCount = self.SlashCount + 1
    else
        self:Destroy()
    end
end
function musashi_modifier_ishana_daitenshou_slash.prototype.OnDestroy(self)
    if not IsServer() then
        return
    end
    self:PerformFinalSlash()
    local ____opt_541 = self.ModifierIshanaDaitenshou
    if ____opt_541 ~= nil then
        ____opt_541:IncrementStackCount()
    end
end
function musashi_modifier_ishana_daitenshou_slash.prototype.DealDamage(self)
    local ____opt_543 = self.Ability
    local QuickSlashMaxHpPercent = (____opt_543 and ____opt_543:GetSpecialValueFor("QuickSlashMaxHpPercent")) / 100
    local ____opt_545 = self.Victim
    local Damage = (____opt_545 and ____opt_545:GetMaxHealth()) * QuickSlashMaxHpPercent
    local ____opt_547 = self.Ability
    local DmgType = ____opt_547 and ____opt_547:GetAbilityDamageType()
    local DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_HPLOSS
    ApplyDamage({
        victim = self.Victim,
        attacker = self.Caster,
        damage = Damage,
        damage_type = DmgType,
        damage_flags = DmgFlag,
        ability = self.Ability
    })
end
function musashi_modifier_ishana_daitenshou_slash.prototype.PerformFinalSlash(self)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local ____opt_549 = self.Ability
        local FinalSlashDmgDelay = ____opt_549 and ____opt_549:GetSpecialValueFor("FinalSlashDmgDelay")
        __TS__Await(Sleep(nil, FinalSlashDmgDelay))
        local ____opt_551 = self.Ability
        local FinalSlashMaxHpPercent = (____opt_551 and ____opt_551:GetSpecialValueFor("FinalSlashMaxHpPercent")) / 100
        local ____opt_553 = self.Ability
        local ExecuteThresholdPercent = ____opt_553 and ____opt_553:GetSpecialValueFor("ExecuteThresholdPercent")
        local ____opt_555 = self.Victim
        local Damage = (____opt_555 and ____opt_555:GetMaxHealth()) * FinalSlashMaxHpPercent
        local ____opt_557 = self.Ability
        local DmgType = ____opt_557 and ____opt_557:GetAbilityDamageType()
        local DmgFlag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_HPLOSS
        ApplyDamage({
            victim = self.Victim,
            attacker = self.Caster,
            damage = Damage,
            damage_type = DmgType,
            damage_flags = DmgFlag,
            ability = self.Ability
        })
        self:CreateParticle()
        local ____opt_559 = self.Victim
        local CurrentHealth = ____opt_559 and ____opt_559:GetHealthPercent()
        if CurrentHealth <= ExecuteThresholdPercent then
            local ____opt_561 = self.Victim
            if ____opt_561 ~= nil then
                ____opt_561:Kill(self.Ability, self.Caster)
            end
        else
            local ____opt_563 = self.Victim
            local CurrentHealthPercent = ____opt_563 and ____opt_563:GetHealthPercent()
            local ____opt_565 = self.Victim
            if ____opt_565 ~= nil then
                ____opt_565:AddNewModifier(self.Caster, self.Ability, ____exports.musashi_modifier_ishana_daitenshou_debuff.name, {undefined = undefined})
            end
            local ____opt_567 = self.Victim
            local NewHealth = (____opt_567 and ____opt_567:GetMaxHealth()) * CurrentHealthPercent / 100
            local ____opt_569 = self.Victim
            if ____opt_569 ~= nil then
                ____opt_569:SetHealth(NewHealth)
            end
        end
    end)
end
function musashi_modifier_ishana_daitenshou_slash.prototype.CreateParticle(self)
    local ParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_slash_basic.vpcf"
    local ____opt_571 = self.ModifierIshanaDaitenshou
    local StartPosition = ____opt_571 and ____opt_571.StartPosition
    local ____opt_573 = self.Caster
    local EndPosition = ____opt_573 and ____opt_573:GetAbsOrigin()
    local ____opt_575 = self.Caster
    if ____opt_575 and ____opt_575:HasModifier("modifier_ascended") then
        ParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_slash_unique.vpcf"
        local PetalsParticleStr = "particles/custom/musashi/musashi_ishana_daitenshou_petals_unique.vpcf"
        local PetalsParticle = ParticleManager:CreateParticle(PetalsParticleStr, PATTACH_WORLDORIGIN, self.Caster)
        ParticleManager:SetParticleControl(PetalsParticle, 0, EndPosition)
        ParticleManager:SetParticleControl(PetalsParticle, 2, EndPosition)
        ParticleManager:SetParticleControl(PetalsParticle, 3, StartPosition)
    end
    local Particle = ParticleManager:CreateParticle(ParticleStr, PATTACH_WORLDORIGIN, self.Caster)
    ParticleManager:SetParticleControl(Particle, 0, StartPosition)
    ParticleManager:SetParticleControl(Particle, 1, EndPosition)
end
function musashi_modifier_ishana_daitenshou_slash.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ishana_daitenshou_slash.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ishana_daitenshou_slash.prototype.IsHidden(self)
    return true
end
musashi_modifier_ishana_daitenshou_slash = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ishana_daitenshou_slash
)
____exports.musashi_modifier_ishana_daitenshou_slash = musashi_modifier_ishana_daitenshou_slash
____exports.musashi_modifier_ishana_daitenshou_debuff = __TS__Class()
local musashi_modifier_ishana_daitenshou_debuff = ____exports.musashi_modifier_ishana_daitenshou_debuff
musashi_modifier_ishana_daitenshou_debuff.name = "musashi_modifier_ishana_daitenshou_debuff"
__TS__ClassExtends(musashi_modifier_ishana_daitenshou_debuff, BaseModifier)
function musashi_modifier_ishana_daitenshou_debuff.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.GetModifierExtraHealthPercentage(self)
    local ____opt_577 = self:GetAbility()
    return ____opt_577 and ____opt_577:GetSpecialValueFor("MaxHpReductionPercent")
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.GetModifierIncomingDamage_Percentage(self)
    local ____opt_579 = self:GetAbility()
    return ____opt_579 and ____opt_579:GetSpecialValueFor("ExtraIncomingDmgPercent")
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ishana_daitenshou_debuff.prototype.RemoveOnDeath(self)
    return true
end
musashi_modifier_ishana_daitenshou_debuff = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ishana_daitenshou_debuff
)
____exports.musashi_modifier_ishana_daitenshou_debuff = musashi_modifier_ishana_daitenshou_debuff
____exports.musashi_modifier_ishana_daitenshou_cooldown = __TS__Class()
local musashi_modifier_ishana_daitenshou_cooldown = ____exports.musashi_modifier_ishana_daitenshou_cooldown
musashi_modifier_ishana_daitenshou_cooldown.name = "musashi_modifier_ishana_daitenshou_cooldown"
__TS__ClassExtends(musashi_modifier_ishana_daitenshou_cooldown, BaseModifier)
function musashi_modifier_ishana_daitenshou_cooldown.prototype.OnCreated(self)
    if not IsServer() then
        return
    end
end
function musashi_modifier_ishana_daitenshou_cooldown.prototype.IsPurgable(self)
    return false
end
function musashi_modifier_ishana_daitenshou_cooldown.prototype.IsPurgeException(self)
    return false
end
function musashi_modifier_ishana_daitenshou_cooldown.prototype.IsDebuff(self)
    return true
end
function musashi_modifier_ishana_daitenshou_cooldown.prototype.RemoveOnDeath(self)
    return false
end
musashi_modifier_ishana_daitenshou_cooldown = __TS__DecorateLegacy(
    {registerModifier(nil)},
    musashi_modifier_ishana_daitenshou_cooldown
)
____exports.musashi_modifier_ishana_daitenshou_cooldown = musashi_modifier_ishana_daitenshou_cooldown
return ____exports
