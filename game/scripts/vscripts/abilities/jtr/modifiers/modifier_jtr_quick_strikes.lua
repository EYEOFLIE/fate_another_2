modifier_jtr_quick_strikes = class({})
function modifier_jtr_quick_strikes:IsHidden() return false end
function modifier_jtr_quick_strikes:IsDebuff() return false end
function modifier_jtr_quick_strikes:RemoveOnDeath() return true end
function modifier_jtr_quick_strikes:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_UNSELECTABLE] = true,
                    [MODIFIER_STATE_UNTARGETABLE] = true}
    return state
end
function modifier_jtr_quick_strikes:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_OVERRIDE_ANIMATION,}
    return func
end
function modifier_jtr_quick_strikes:GetOverrideAnimation()
    return ACT_DOTA_RUN
end
function modifier_jtr_quick_strikes:IsMotionController() return true end
function modifier_jtr_quick_strikes:OnCreated(args)
    if IsServer() then
        self.ability = self:GetAbility()
        self.radius = self.ability:GetSpecialValueFor("attack_radius")
        self.parent = self:GetParent()
        self.time_elapsed = self.ability:GetSpecialValueFor("interval")
        self.forward = self.parent:GetForwardVector()
        self.target = self.ability:GetCursorTarget()
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.slashes = self.ability:GetSpecialValueFor("slashes")
        self.damage_type = DAMAGE_TYPE_PHYSICAL

        self.swing_fx = ParticleManager:CreateParticle("particles/custom/jtr/jtr_slash.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
                        ParticleManager:SetParticleControlEnt(self.swing_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(self.swing_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)

        self:AddParticle(self.swing_fx, false, false, -1, false, false)

        self.swing2_fx = ParticleManager:CreateParticle("particles/custom/jtr/jtr_slash.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
                        ParticleManager:SetParticleControlEnt(self.swing2_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(self.swing2_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)

        self:AddParticle(self.swing2_fx, false, false, -1, false, false)

        FindClearSpaceForUnit(self.parent, self.target:GetAbsOrigin(), true)

        self:StartIntervalThink(FrameTime())
    end
end
function modifier_jtr_quick_strikes:OnIntervalThink()
    if IsServer() then
        if self.time_elapsed >= 0.1 then
            self.time_elapsed = 0.01
            if self.slashes <= 0 then
                self:Destroy()
            end

            if self.target == nil then
                self:Destroy()
                return nil
            end

            if self.target:IsNull() then
                self:Destroy()
                return nil
            end

            if self.target:IsInvisible() then
                self:Destroy()
                return nil
            end

            if not self.target:IsAlive() then
                self:Destroy()
                return nil
            end

            --FindClearSpaceForUnit(self:GetParent(), self.target:GetAbsOrigin(), true)

            --[[local enemies = FindUnitsInRadius(  self:GetParent():GetTeamNumber(), 
                                                self.target:GetAbsOrigin(), 
                                                nil, 
                                                self.radius, 
                                                self:GetAbility():GetAbilityTargetTeam(), 
                                                self:GetAbility():GetAbilityTargetType(), 
                                                DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
                                                FIND_ANY_ORDER, 
                                                false)]]

            --for _,enemy in pairs(enemies) do
            if self.parent.IsHolyMotherAcquired then 
                if IsFemaleServant(self.target) then
                    self.damage_type = DAMAGE_TYPE_MAGICAL
                end
            end

            DoDamage(self.parent, self.target, self.damage, self.damage_type, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self.ability, false)

            --end
            local currentpoint = self.parent:GetAbsOrigin()
            local newpoint = currentpoint + vectorsV2[self.slashes+1]*0.5 
            self.parent:SetAbsOrigin(newpoint)
            --local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, caster )
            --ParticleManager:SetParticleControl( trailFx, 1, currentpoint )
            --ParticleManager:SetParticleControl( trailFx, 0, newpoint )

            self.slashes = self.slashes - 1
            self.parent:SetForwardVector((self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized())
            if self.slashes < 1 then
                FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
                self.parent:SetForwardVector(self.forward)
            end
        end
        self.time_elapsed = self.time_elapsed + FrameTime()
        self:HorizontalMotion(self.parent, FrameTime())
    end
end

function modifier_jtr_quick_strikes:HorizontalMotion(me, dt)
    local new_location = self.parent:GetAbsOrigin() + self.parent:GetForwardVector()*8000*dt
    if self.target and not self.target:IsNull() then
        if self.slashes < 1 then
            new_location = self.target:GetAbsOrigin()
        end
    end
    self.parent:SetAbsOrigin(new_location)
    FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
end