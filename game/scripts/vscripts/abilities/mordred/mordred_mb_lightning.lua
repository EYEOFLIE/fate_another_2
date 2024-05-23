mordred_mb_lightning = class({})
mordred_mb_lightning_upgrade = class({})

LinkLuaModifier("modifier_lightning_shield", "abilities/mordred/mordred_mb_lightning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_mb_cooldown", "abilities/mordred/mordred_mb_lightning", LUA_MODIFIER_MOTION_NONE)

function mordred_mb_wrapper(ability)
    function ability:GetAbilityDamageType()
        return DAMAGE_TYPE_MAGICAL
    end

    function ability:GetAOERadius()
        return self:GetSpecialValueFor("area_of_effect")
    end

    function ability:OnSpellStart()
        local caster = self:GetCaster()
        local ability = self
        local radius = self:GetSpecialValueFor("area_of_effect")
        local damage = self:GetSpecialValueFor("damage")

        local mana_perc = self:GetSpecialValueFor("mana_percent")
        local mana = caster:GetMana()*mana_perc/100

        if caster:GetMana() < mana then
            mana = caster:GetMana()
        end

        caster:AddNewModifier(caster, self, "modifier_mordred_mb_cooldown", {duration = self:GetCooldown(1)})

        local pedigree = caster:FindAbilityByName(caster.DSkill) 

        caster:AddNewModifier(caster, pedigree, "pedigree_off", {duration = pedigree:GetSpecialValueFor("duration")})
        pedigree:StartCooldown(pedigree:GetCooldown(1))

        if not caster:HasModifier("pedigree_off") then
            mana = 1
        end

        caster:SpendMana(mana, self)

        damage = damage + mana*self:GetSpecialValueFor("mana_damage")/100

        EmitSoundOn("mordred_teme", caster)

        local purgeFx = ParticleManager:CreateParticle("particles/custom/mordred/gods_resolution/gods_resolution_active_circle.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl( purgeFx, 0, caster:GetAbsOrigin())

        local iPillarFx = ParticleManager:CreateParticle("particles/custom/mordred/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl( iPillarFx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl( iPillarFx, 1, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl( iPillarFx, 2, caster:GetAbsOrigin())

        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(iPillarFx, false)
            ParticleManager:ReleaseParticleIndex(iPillarFx)
            ParticleManager:DestroyParticle(purgeFx, false)
            ParticleManager:ReleaseParticleIndex(purgeFx)
        end)

        if caster.RampageAcquired then
            caster:AddNewModifier(caster, self, "modifier_lightning_shield", {duration = self:GetSpecialValueFor("shield_dur")})
            caster:FindModifierByName("modifier_lightning_shield"):SetStackCount(self:GetSpecialValueFor("total_shield"))
        end
        --[[if caster.CurseOfRetributionAcquired then
            caster:FindAbilityByName("mordred_curse_passive"):ShieldCharge()
        end]]

        local visiondummy = SpawnVisionDummy(caster, caster:GetAbsOrigin(), radius, self:GetSpecialValueFor("vision_duration"), true)
        EmitSoundOn("mordred_lightning", caster)
        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do       
            if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
                DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
            end

            if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and not IsImmuneToCC(v) then
                v:AddNewModifier(caster, self, "modifier_stunned", {Duration = 0.7})
            end
            
            --[[Timers:CreateTimer(0.01, function()
                local particle = ParticleManager:CreateParticle("particles/custom/mordred/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, v)
                local target_point = v:GetAbsOrigin()
                ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
                ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, 2000))
                ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
            end)  ]]   
        end 
    end
end

mordred_mb_wrapper(mordred_mb_lightning)
mordred_mb_wrapper(mordred_mb_lightning_upgrade)

modifier_mordred_mb_cooldown = class({})

function modifier_mordred_mb_cooldown:GetTexture()
    return "custom/mordred/mordred_thunder"
end

function modifier_mordred_mb_cooldown:IsHidden()
    return false 
end

function modifier_mordred_mb_cooldown:RemoveOnDeath()
    return false
end

function modifier_mordred_mb_cooldown:IsDebuff()
    return true 
end

function modifier_mordred_mb_cooldown:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

modifier_lightning_shield = class({})

function modifier_lightning_shield:GetTexture()
    return "custom/mordred/mordred_thunder"
end

function modifier_lightning_shield:IsHidden()
    return false 
end

function modifier_lightning_shield:RemoveOnDeath()
    return true
end

function modifier_lightning_shield:IsDebuff()
    return false 
end

function modifier_lightning_shield:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_lightning_shield:OnCreated(args)
    if self.particle then 
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
    self.particle = ParticleManager:CreateParticle("particles/custom/mordred/mordred_lightning_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetStackCount(),0,0))
end

function modifier_lightning_shield:OnRefresh(args)
    self:OnCreated(args)
end

function modifier_lightning_shield:OnDestroy()
    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_lightning_shield:OnRefreshParticle(iStack)
    if self.particle then 
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
    self.particle = ParticleManager:CreateParticle("particles/custom/mordred/mordred_lightning_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 2, Vector(iStack,0,0))
end

function modifier_lightning_shield:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_lightning_shield:OnTakeDamage(args)
    self.parent = self:GetParent()
    local caster = self:GetParent()
    if args.unit ~= self.parent then return end

    local shield_amount = self:GetAbility():GetSpecialValueFor("shield_amount")

    local currentHealth = caster:GetHealth()

    local stack = self:GetStackCount()

    self.parent:SetModifierStackCount("modifier_lightning_shield", self.parent, stack- 1)
    self:OnRefreshParticle(stack - 1)

    if currentHealth == 0 then
        --print("lethal")
    else
        if shield_amount < args.damage then
            caster:SetHealth(currentHealth + shield_amount)
        else
            caster:SetHealth(currentHealth + args.damage)
        end
    end

    if stack - 1 == 0 then 
        self:Destroy()
    end
end