LinkLuaModifier("modifier_atalanta_jump", "abilities/alter_atalanta/atalanta_alter_jump", LUA_MODIFIER_MOTION_BOTH) 
LinkLuaModifier("modifier_atalanta_jump_slow", "abilities/alter_atalanta/atalanta_alter_jump", LUA_MODIFIER_MOTION_NONE)

atalanta_alter_jump = class({})
atalanta_alter_jump_upgrade_1 = class({})
atalanta_alter_jump_upgrade_2 = class({})
atalanta_alter_jump_upgrade_3 = class({})

function atalanta_jump_wrapper(abil)
    function abil:OnSpellStart()
    	local caster = self:GetCaster()

    	caster:AddNewModifier(caster, self, "modifier_atalanta_jump", {})
    end

    function abil:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function abil:CastFilterResultLocation(hLocation)
        local caster = self:GetCaster()
        if IsServer() and not IsInSameRealm(caster:GetAbsOrigin(), hLocation) then
            return UF_FAIL_CUSTOM
        elseif IsOutOfMap(hLocation) then 
            return UF_FAIL_CUSTOM
        else
            return UF_SUCESS
        end
    end

    function abil:GetCustomCastErrorLocation(hLocation)
        return "#Wrong_Target_Location"
    end
end

atalanta_jump_wrapper(atalanta_alter_jump)
atalanta_jump_wrapper(atalanta_alter_jump_upgrade_1)
atalanta_jump_wrapper(atalanta_alter_jump_upgrade_2)
atalanta_jump_wrapper(atalanta_alter_jump_upgrade_3)

-----------------------------------

modifier_atalanta_jump = class({})
function modifier_atalanta_jump:IsHidden() return true end
function modifier_atalanta_jump:DeclareFunctions()
	return { MODIFIER_PROPERTY_DISABLE_TURNING, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end
function modifier_atalanta_jump:GetModifierDisableTurning()
	return 1
end
function modifier_atalanta_jump:GetModifierIncomingDamage_Percentage()
    return -50
end
function modifier_atalanta_jump:IsDebuff() return false end
function modifier_atalanta_jump:RemoveOnDeath() return true end
function modifier_atalanta_jump:CheckState()
    local state = { --[[[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_SILENCED] = true,]]
                    --[MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_MUTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                }
    return state
end
function modifier_atalanta_jump:OnCreated()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    if IsServer() then
        self.point = self.ability:GetCursorPosition()
        self.radius = self.ability:GetSpecialValueFor("radius")

        self.speed = self.ability:GetSpecialValueFor("speed")
        self.fly_duration = self.ability:GetSpecialValueFor("fly_duration")

        self.jump_start_pos = self.parent:GetOrigin()
        self.jump_distance = (self.point - self.jump_start_pos):Length2D()
        self.jump_direction = (self.point - self.jump_start_pos):Normalized()

        -- load data
        self.jump_duration = self.fly_duration--self.jump_distance/self.speed
        self.jump_hVelocity = self.jump_distance/self.fly_duration--self.speed

        self.jump_peak = self.ability:GetSpecialValueFor("max_height")
        
        --[[self.effect_duration = self.ability:GetSpecialValueFor("effect_duration")
        self.stun_height = self.ability:GetSpecialValueFor("stun_height")
        self.stun_damage = self.ability:GetSpecialValueFor("stun_damage")]]

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

        --[[local dash_fx = ParticleManager:CreateParticle("particles/heroes/anime_hero_uzume/uzume_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
                        ParticleManager:SetParticleControl(dash_fx, 0, self.parent:GetOrigin()) -- point 0: origin, point 2: sparkles, point 5: burned soil
                        ParticleManager:SetParticleControl(dash_fx, 2, self.parent:GetOrigin())
                        ParticleManager:SetParticleControl(dash_fx, 5, self.parent:GetOrigin())

        self:AddParticle(dash_fx, false, false, -1, true, false)]]

        if self:ApplyVerticalMotionController() == false then
            self:Destroy()
        end
        if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end
function modifier_atalanta_jump:UpdateHorizontalMotion(me, dt)
    self:SyncTime(1, dt)

    local target = self.jump_direction * self.jump_hVelocity * self.elapsedTime

    if not IsInSameRealm(self.parent:GetAbsOrigin(), self.jump_start_pos) then 
        if self.jump_start_pos.y < -2000 then 
            self.jump_start_pos = self.parent:GetAbsOrigin()
        end
    end
    self.parent:SetOrigin(self.jump_start_pos + target)
    --self.parent:FaceTowards(self.point)
end
function modifier_atalanta_jump:UpdateVerticalMotion(me, dt)
    self:SyncTime(2, dt)

    local target = self.jump_vVelocity * self.elapsedTime + 0.5 * self.jump_gravity * self.elapsedTime * self.elapsedTime

    self.parent:SetOrigin(Vector(self.parent:GetOrigin().x, self.parent:GetOrigin().y, self.jump_start_pos.z + target))
end
function modifier_atalanta_jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end
function modifier_atalanta_jump:OnVerticalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end
function modifier_atalanta_jump:OnDestroy()
    if IsServer() then
        self.parent:InterruptMotionControllers(true)
        if IsOutOfMap(self.parent:GetOrigin()) then 
            self:GetParent():SetAbsOrigin(self.jump_start_pos)
        end
    end
end
function modifier_atalanta_jump:SyncTime( iDir, dt )
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
        self:PlayEffects()
    end
end
function modifier_atalanta_jump:PlayEffects()
    if not self.do_damage then
        self.do_damage = true

        --[[local destruct_pfx =    ParticleManager:CreateParticle("particles/heroes/anime_hero_seth/seth_slam.vpcf", PATTACH_CUSTOMORIGIN, nil)
                                ParticleManager:SetParticleControl(destruct_pfx, 0, self.point)
                                ParticleManager:SetParticleControl(destruct_pfx, 1, Vector(self.radius, self.radius, self.radius))
                                ParticleManager:ReleaseParticleIndex(destruct_pfx)]]

        EmitSoundOnLocationWithCaster(self.point, "Hero_Leshrac.Split_Earth2", self.parent)
        EmitSoundOnLocationWithCaster(self.point, "Hero_Leshrac.Split_Earth3", self.parent) 

        

        local hit_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_earthshock.vpcf", PATTACH_ABSORIGIN, self.parent )
		ParticleManager:SetParticleControl( hit_fx, 0, GetGroundPosition(self.parent:GetAbsOrigin(), self.parent))
		ParticleManager:SetParticleControl( hit_fx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 300, 150))

        local hit_fx2 = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_shockwave.vpcf", PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( hit_fx2, 0, GetGroundPosition(self.parent:GetAbsOrigin(), self.parent))
        ParticleManager:SetParticleControl( hit_fx2, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 10, 0.5))
        ParticleManager:SetParticleControl( hit_fx2, 6, Vector(255, 255, 0))

        Timers:CreateTimer(3, function()
            ParticleManager:DestroyParticle( hit_fx, false )
            ParticleManager:DestroyParticle( hit_fx2, false )
            ParticleManager:ReleaseParticleIndex(hit_fx)
            ParticleManager:ReleaseParticleIndex(hit_fx2)
        end)

        local knock = 0
        local radius = self.radius
        local stacks = self:GetAbility():GetSpecialValueFor("curse_stacks")

        if self.parent:HasModifier("modifier_atalanta_evil_beast") then 
            stacks = stacks * 2 
        end

        if self.parent.BowAcquired then 
            self.parent:FindAbilityByName(self.parent.RSkill):RefundCooldown(self:GetAbility():GetSpecialValueFor("tauropolos_red"))
        end

        if self.parent.WildBeastLogicAcquired then 
            self.knock_radius = self:GetAbility():GetSpecialValueFor("knock_radius")
            local slam_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_slam.vpcf", PATTACH_ABSORIGIN, self.parent )
            ParticleManager:SetParticleControl( slam_fx, 0, GetGroundPosition(self.parent:GetAbsOrigin(), self.parent))
            ParticleManager:SetParticleControl( slam_fx, 7, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
            local enemies2 = FindUnitsInRadius(  self.parent:GetTeamNumber(),
                                                self.point, 
                                                nil, 
                                                self.knock_radius, 
                                                self.ability:GetAbilityTargetTeam(), 
                                                self.ability:GetAbilityTargetType(), 
                                                self.ability:GetAbilityTargetFlags(), 
                                                FIND_ANY_ORDER, 
                                                false)
            for _,enemy in ipairs(enemies2) do
                local dist = (self.parent:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
                print('distance = ' .. dist)
                local knockback = { should_stun = true,
                                                knockback_duration = 0.5,
                                                duration = 0.5,
                                                knockback_distance = -math.min( dist, self.radius),
                                                knockback_height = 50,
                                                center_x = self.parent:GetAbsOrigin().x,
                                                center_y = self.parent:GetAbsOrigin().y,
                                                center_z = self.parent:GetAbsOrigin().z }

                enemy:AddNewModifier(self.parent, self.ability, "modifier_knockback", knockback)

            end
        end

        local enemies = FindUnitsInRadius(  self.parent:GetTeamNumber(),
                                            self.point, 
                                            nil, 
                                            self.radius, 
                                            self.ability:GetAbilityTargetTeam(), 
                                            self.ability:GetAbilityTargetType(), 
                                            self.ability:GetAbilityTargetFlags(), 
                                            FIND_ANY_ORDER, 
                                            false)

        if enemies[1] ~= nil then
            if self.parent.EvolutionAcquired then 
                self.parent:FindAbilityByName(self.parent.DSkill):Energy(self.parent:FindAbilityByName("atalanta_passive_evolution"):GetSpecialValueFor("energy_gain"))
            end
        end

        for _,enemy in ipairs(enemies) do

            if not IsImmuneToCC(enemy) and not IsImmuneToSlow(enemy) then
                enemy:AddNewModifier(self.parent, self.ability, "modifier_atalanta_jump_slow", {Duration = self:GetAbility():GetSpecialValueFor("slow_dur")})
            end

            self.damage = self:GetAbility():GetSpecialValueFor("damage")
            DoDamage(self.parent, enemy, self.damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)

            if self.parent:HasModifier("modifier_atalanta_evil_beast") then 
                enemy:AddNewModifier(self.parent, self.ability, "modifier_stunned", {Duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
            end

            for i = 1, stacks do
                self.parent:FindAbilityByName(self.parent.DSkill):Curse(enemy)
            end 
        end
    end
end

------------------------------

modifier_atalanta_jump_slow = class({})

function modifier_atalanta_jump_slow:IsDebuff() return true end
function modifier_atalanta_jump_slow:IsHidden() return false end
function modifier_atalanta_jump_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_atalanta_jump_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ms_slow") 
end
function modifier_atalanta_jump_slow:OnCreated()
    local particle_slow_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_slow_fx, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 0))
    self:AddParticle(particle_slow_fx, false, false, -1, false, true)
end