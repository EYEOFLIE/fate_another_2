LinkLuaModifier("modifier_atalanta_beast", "abilities/alter_atalanta/atalanta_alter_ora", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_beast_buff", "abilities/alter_atalanta/atalanta_alter_ora", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_beast_jump", "abilities/alter_atalanta/atalanta_alter_ora", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_atalanta_evil_beast", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_atalanta_combo_window", "abilities/alter_atalanta/atalanta_alter_ora", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_beast_enhance", "abilities/alter_atalanta/atalanta_alter_ora", LUA_MODIFIER_MOTION_NONE)

atalanta_alter_ora = class({})
atalanta_alter_ora_upgrade_1 = class({})
atalanta_alter_ora_upgrade_2 = class({})
atalanta_alter_ora_upgrade_3 = class({})

function atalanta_alter_ora_wrapper(ability)
    function ability:OnSpellStart()
    	local caster = self:GetCaster()
        local target = nil

        caster:EmitSound("atalanta_ora")

    	caster:AddNewModifier(caster, self, "modifier_atalanta_beast", {duration = self:GetSpecialValueFor("beast_duration")})
        caster:AddNewModifier(caster, self, "modifier_atalanta_beast_buff", {duration = self:GetSpecialValueFor("beast_duration")})
        if caster.BeastEnhancementAcquired then
            caster:AddNewModifier(caster, self, "modifier_atalanta_beast_enhance", {duration = self:GetSpecialValueFor("beast_duration")})
            caster:FindAbilityByName(caster.DSkill):Energy(self:GetSpecialValueFor("bonus_energy"))
        end
        caster:FindAbilityByName(caster.DSkill):Transform(self:GetSpecialValueFor("evil_duration"))

        if caster.WildBeastLogicAcquired then 
            local nearest_hero = FindUnitsInRadius(caster:GetTeam(),
                                                caster:GetAbsOrigin(), 
                                                nil, 
                                                self:GetSpecialValueFor("search"), 
                                                DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                                DOTA_UNIT_TARGET_HERO, 
                                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
                                                FIND_ANY_ORDER, 
                                                false)

            if #nearest_hero > 0 then
                if #nearest_hero == 1 then 
                    target = nearest_hero[1]
                else
                    local lowHpHero = nearest_hero[1]
                    local lowestHp  = nearest_hero[1]:GetHealth()

                    for i = 2, #nearest_hero do
                        local lowerHp = nearest_hero[i]:GetHealth()          

                        if math.abs(lowerHp) < math.abs(lowestHp) then
                            lowHpHero = nearest_hero[i]
                            lowestHp = lowerHp
                        end
                    end
                    target = lowHpHero
                end
                
                local aim_target = {
                    UnitIndex = caster:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    TargetIndex = target:entindex()
                }
                Timers:CreateTimer(0.1, function()
                    ExecuteOrderFromTable(aim_target)
                end)
                if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > 200 then
                    self:AtaJump(target)
                end
            end
        end

        --check combo
        if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 and caster:HasModifier("modifier_atalanta_alter_d_use") then       
            if caster:FindAbilityByName(caster.ESkill):IsCooldownReady() and not caster:HasModifier("modifier_atalanta_skia_cd") then
                local remain_time = caster:FindModifierByName("modifier_atalanta_alter_d_use"):GetRemainingTime()
                caster:AddNewModifier(caster, self, "modifier_atalanta_combo_window", {Duration = remain_time})
            end
        end
    end

    function ability:AtaJump(hTarget)
        local caster = self:GetCaster()
        self.JumpTarget = hTarget
        caster.JumpTarget = hTarget
        caster:AddNewModifier(caster, nil, "modifier_camera_follow", {duration = 1.0})
        caster:AddNewModifier(caster, self, "modifier_atalanta_beast_jump", {duration = 0.2})
    end

    function ability:GetAtaJumpTarget()
        return self:GetCaster().JumpTarget or self.JumpTarget
    end
end

atalanta_alter_ora_wrapper(atalanta_alter_ora)
atalanta_alter_ora_wrapper(atalanta_alter_ora_upgrade_1)
atalanta_alter_ora_wrapper(atalanta_alter_ora_upgrade_2)
atalanta_alter_ora_wrapper(atalanta_alter_ora_upgrade_3)

-------------------------------------

modifier_atalanta_beast = class({})

function modifier_atalanta_beast:IsHidden() return false end
function modifier_atalanta_beast:IsDebuff() return false end
function modifier_atalanta_beast:IsPurgable() return false end
function modifier_atalanta_beast:RemoveOnDeath() return true end
function modifier_atalanta_beast:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_atalanta_beast:OnCreated(args)
    self.caster = self:GetAbility():GetCaster()

    self:SetStackCount(self:GetAbility():GetSpecialValueFor("attack_count"))
    self:AttachEffect()
end

function modifier_atalanta_beast:OnRefresh(args)
    self:DeAttachEffect()
    self:OnCreated(args)
end

function modifier_atalanta_beast:OnDestroy()
    self:DeAttachEffect()
end

function modifier_atalanta_beast:AttachEffect()
    self.effect_fx = ParticleManager:CreateParticle("particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControl(self.effect_fx, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.effect_fx, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControl(self.effect_fx, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.effect_fx, 3, self.caster:GetAbsOrigin())
end

function modifier_atalanta_beast:DeAttachEffect()
    ParticleManager:DestroyParticle(self.effect_fx, true)
    ParticleManager:ReleaseParticleIndex(self.effect_fx)
end

-------------------------------------

modifier_atalanta_beast_buff = class({})

function modifier_atalanta_beast_buff:IsHidden() return true end
function modifier_atalanta_beast_buff:IsDebuff() return false end
function modifier_atalanta_beast_buff:IsPurgable() return false end
function modifier_atalanta_beast_buff:RemoveOnDeath() return true end
function modifier_atalanta_beast_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_atalanta_beast_buff:DeclareFunctions()
    local func = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
                    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
                    MODIFIER_EVENT_ON_ATTACK_LANDED
                }
    return func
end

function modifier_atalanta_beast_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end

function modifier_atalanta_beast_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_atalanta_beast_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("attack") - 100
end

function modifier_atalanta_beast_buff:OnAttackLanded(args)
    if IsServer() then
        if args.attacker ~= self:GetParent() then return end
        self.caster = self:GetParent()
        --if self:GetParent():HasModifier("modifier_atalanta_beast_jump") then return false end
        local beast = self.caster:FindModifierByName("modifier_atalanta_beast")
        local stack = self.caster:GetModifierStackCount("modifier_atalanta_beast", self.caster)
        self.caster:SetModifierStackCount("modifier_atalanta_beast", self.caster, stack - 1)

        local sweep_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_beast_sweep.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControl( sweep_fx, 0, args.target:GetAbsOrigin())

        --[[if self.caster.BeastEnhancementAcquired then 
            args.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_stunned", {duration = 0.1})
        end]]

        if beast:GetStackCount() <= 0 then 
            self:Destroy()
            self.caster:RemoveModifierByName("modifier_atalanta_beast")
            self.caster:RemoveModifierByName("modifier_atalanta_beast_enhance")
        end
    end
end

------------------------------------

modifier_atalanta_beast_jump = class({})

function modifier_atalanta_beast_jump:IsHidden() return true end
function modifier_atalanta_beast_jump:IsDebuff() return false end
function modifier_atalanta_beast_jump:IsPurgable() return false end
function modifier_atalanta_beast_jump:RemoveOnDeath() return true end
function modifier_atalanta_beast_jump:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_atalanta_beast_jump:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } 
end

function modifier_atalanta_beast_jump:GetModifierIncomingDamage_Percentage()
    return -50
end

function modifier_atalanta_beast_jump:CheckState()
    local state = { --[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_SILENCED] = true,
                    [MODIFIER_STATE_MUTED] = true,
                }
    return state
end

function modifier_atalanta_beast_jump:OnCreated()
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.htarget = self.caster.JumpTarget or self.ability:GetAtaJumpTarget()
    --print('ata jump target is ' .. self.htarget:GetUnitName())

    if IsServer() then
        self.speed = 5000
        self.fly_duration = 0.3
        self.jump_peak = 250
        self.targetpos = self.htarget:GetAbsOrigin()
        self.jump_start_pos = self.caster:GetOrigin()
        self.jump_distance = (self.targetpos - self.jump_start_pos):Length2D()
        self.jump_direction = (self.targetpos - self.jump_start_pos):Normalized()

        -- load data
        self.jump_duration = self.fly_duration--self.jump_distance/self.speed
        self.jump_hVelocity = self.jump_distance/self.fly_duration--self.speed

        -- sync
        self.elapsedTime = 0
        self.motionTick = {}
        self.motionTick[0] = 0
        self.motionTick[1] = 0
        self.motionTick[2] = 0

        -- vertical motion model
        -- self.gravity = -10*1000
        self.jump_gravity = -self.jump_peak/(self.jump_duration*self.jump_duration*0.125)
        self.jump_vVelocity = (-0.5)*self.jump_gravity*self.jump_duration

        if self:ApplyVerticalMotionController() == false then
            self:Destroy()
        end
        if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end
function modifier_atalanta_beast_jump:UpdateHorizontalMotion(me, dt)
    local UFilter = UnitFilter( self.htarget,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                self.caster:GetTeamNumber() )

    if not IsInSameRealm(self.caster:GetAbsOrigin(), self.htarget:GetAbsOrigin()) then 
        self:Destroy()
        return nil
    end

    if UFilter ~= UF_SUCCESS then
        self:Destroy()
        return nil
    end

    if (self.targetpos - self.htarget:GetAbsOrigin()):Length2D() > 500 then
        self:Destroy()
        return nil
    end

    self.targetpos = self.htarget:GetAbsOrigin() 

    if (self.htarget:GetOrigin() - self.caster:GetOrigin()):Length2D() < 150 then
        self:Destroy()
        return nil
    end

    self:SyncTime(1, dt)
    self.jump_distance = (self.targetpos - self.jump_start_pos):Length2D()
    self.jump_direction = (self.htarget:GetAbsOrigin() - self.caster:GetAbsOrigin()):Normalized()
    self.jump_hVelocity = self.jump_distance/self.fly_duration
    local target = self.jump_direction * self.jump_hVelocity * self.elapsedTime

    self.caster:SetOrigin(self.jump_start_pos + target)
end
function modifier_atalanta_beast_jump:UpdateVerticalMotion(me, dt)
    self:SyncTime(2, dt)

    local target = self.jump_vVelocity * self.elapsedTime + 0.5 * self.jump_gravity * self.elapsedTime * self.elapsedTime

    self.caster:SetOrigin(Vector(self.caster:GetOrigin().x, self.caster:GetOrigin().y, self.jump_start_pos.z + target))
end
function modifier_atalanta_beast_jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end
function modifier_atalanta_beast_jump:OnVerticalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end
function modifier_atalanta_beast_jump:OnDestroy()
    if IsServer() then
        self.caster:InterruptMotionControllers(true)

    end
end
function modifier_atalanta_beast_jump:SyncTime( iDir, dt )
    -- check if already synced
    if self.motionTick[1]==self.motionTick[2] then
        self.motionTick[0] = self.motionTick[0] + 1
        self.elapsedTime = self.elapsedTime + dt
    end

    -- sync time
    self.motionTick[iDir] = self.motionTick[0]
    
    -- end motion
    if self.elapsedTime >= self.jump_duration and self.motionTick[1] == self.motionTick[2] then
        self:Destroy()
    end
end

--------------------------------

modifier_atalanta_combo_window = class({})

function modifier_atalanta_combo_window:IsHidden() return true end
function modifier_atalanta_combo_window:IsDebuff() return false end
function modifier_atalanta_combo_window:IsPurgable() return false end
function modifier_atalanta_combo_window:RemoveOnDeath() return true end
function modifier_atalanta_combo_window:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then 
    function modifier_atalanta_combo_window:OnCreated(args)
        self.caster = self:GetParent()
        self.caster:SwapAbilities(self.caster.ESkill, self.caster.ComboSkill, false, true)
    end

    function modifier_atalanta_combo_window:OnDestroy()
        self.caster:SwapAbilities(self.caster.ESkill, self.caster.ComboSkill, true, false)
    end
end

--------------------------

modifier_atalanta_beast_enhance = class({})

function modifier_atalanta_beast_enhance:IsHidden() return true end
function modifier_atalanta_beast_enhance:IsDebuff() return false end
function modifier_atalanta_beast_enhance:IsPurgable() return false end
function modifier_atalanta_beast_enhance:RemoveOnDeath() return true end
function modifier_atalanta_beast_enhance:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end 

function modifier_atalanta_beast_enhance:DeclareFunctions()
    local func = {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
                    MODIFIER_EVENT_ON_ATTACK_START
                }
    return func 
end


function modifier_atalanta_beast_enhance:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
    return state
end


function modifier_atalanta_beast_enhance:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range")
end

function modifier_atalanta_beast_enhance:OnAttackStart(args)
    if args.attacker ~= self:GetParent() then return end
    self.caster = self:GetParent()

    if self.caster.BeastEnhancementAcquired then
        local target = args.target 
        if target == self.caster:GetAttackTarget() then 
            local dist = (target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
            if not string.match(target:GetUnitName(), "ward") and not string.match(target:GetUnitName(), "sentry_familiar") then
                if dist > 300 and dist < 1000 then
                    local aim_target = {
                        UnitIndex = self.caster:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = target:entindex()
                    }
                    Timers:CreateTimer(0.1, function()
                        ExecuteOrderFromTable(aim_target)
                    end)
                    self:GetAbility():AtaJump(target)
                    return false
                end
            end
        end
    end
    return true
end




