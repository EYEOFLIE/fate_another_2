LinkLuaModifier("modifier_tauropolos_alter", "abilities/alter_atalanta/atalanta_alter_tauropolos_alter", LUA_MODIFIER_MOTION_NONE)

atalanta_alter_tauropolos_alter = class({})
atalanta_alter_tauropolos_alter_upgrade = class({})

function atalanta_tauropolos_alter_wrapper(ability)
    function ability:CastFilterResult()
    	local caster = self:GetCaster()
    	
    	if caster:HasModifier("modifier_tauropolos_alter") then
    		return UF_FAIL_CUSTOM
        elseif caster:HasModifier("modifier_tauropolos_alter_penalty") then
            return UF_FAIL_CUSTOM
    	end

    	return UF_SUCCESS
    end

    function ability:GetManaCost(iLevel)
        if self:GetCaster():HasModifier("modifier_atalanta_jump") and string.match(self:GetAbilityName(), "_upgrade") then 
            return self:GetSpecialValueFor("jump_cost")
        else
            return 800
        end
    end

    function ability:GetCastPoint()
        if self:GetCaster():HasModifier("modifier_atalanta_jump") and string.match(self:GetAbilityName(), "_upgrade") then 
            return self:GetSpecialValueFor("jump_cast")
        else
            return self:GetSpecialValueFor("cast_delay")
        end
    end

    function ability:GetBehavior()
        if self:GetCaster():HasModifier("modifier_atalanta_jump") then 
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
        else
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET
        end
    end

    function ability:GetCustomCastError()
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_tauropolos_alter") then
            return "Only one instance of Tauropolos can exist at one time."
        elseif caster:HasModifier("modifier_tauropolos_alter_penalty") then
            return "Tauropolos is not ready."
        end
    end

    function ability:OnAbilityPhaseStart()
        if( self:GetCaster():HasModifier( "modifier_atalanta_jump")) then
            EmitSoundOn("atalanta_ultimate_"..math.random(1,3),  self:GetCaster())
        else
            self:GetCaster():EmitSound("atalanta_ultimate_"..math.random(1,3))
        end
        return true
    end

    function ability:OnAbilityPhaseInterrupted()
        self:GetCaster():StopSound("atalanta_ultimate_1")
        self:GetCaster():StopSound("atalanta_ultimate_2")
        self:GetCaster():StopSound("atalanta_ultimate_3")
    end

    function ability:OnSpellStart()
    	local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local follow = 0
        if caster.BowAcquired and caster:HasModifier("modifier_atalanta_jump") then 
            duration = self:GetSpecialValueFor("jump_duration")
            follow = 1
        end
    	caster:AddNewModifier(caster, self, "modifier_tauropolos_alter", {duration = duration, follow = follow})
    end

    function ability:RefundCooldown(iCooldown)
        if not self:IsCooldownReady() then 
            local current_cooldown = self:GetCooldownTimeRemaining()
            self:EndCooldown()
            self:StartCooldown(math.max(0, current_cooldown - iCooldown))
        end
    end
end

atalanta_tauropolos_alter_wrapper(atalanta_alter_tauropolos_alter)
atalanta_tauropolos_alter_wrapper(atalanta_alter_tauropolos_alter_upgrade)

-------------------

modifier_tauropolos_alter = class({})
function modifier_tauropolos_alter:IsHidden() return true end
function modifier_tauropolos_alter:IsDebuff() return false end
function modifier_tauropolos_alter:RemoveOnDeath() return true end
function modifier_tauropolos_alter:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_tauropolos_alter:OnCreated(args)
    if IsServer() then
        self.ability = self:GetAbility()
        self.radius = self:GetAbility():GetAOERadius()
        self.caster = self:GetCaster()
        self.follow = args.follow
        self.frametime = 1
        self.frametime_mana = 0
        self.interval = 0.2
        self.damage = math.floor(self:GetAbility():GetSpecialValueFor("dps") * self.interval)
        self.heal = self:GetAbility():GetSpecialValueFor("heal")/100
        if self.caster.BowAcquired then
            self.bonus_stack = self:GetAbility():GetSpecialValueFor("bonus_stack")/100
            self.damage = self.damage + (self:GetAbility():GetSpecialValueFor("bonus_agi") * self.caster:GetAgility() * self.interval)
        end
        self.energy_gain = self:GetAbility():GetSpecialValueFor("energy_gain")
        self.bonus_energy = self:GetAbility():GetSpecialValueFor("bonus_energy")
        self.min_dist = self:GetAbility():GetSpecialValueFor("min_dist")
        self.max_dist = self:GetAbility():GetSpecialValueFor("max_dist")
        self.curse_stacks = self:GetAbility():GetSpecialValueFor("curse_stacks")/3
        self.target_loc = self:GetParent():GetAbsOrigin()
        self.quadrant = 1  -- Quadrants 1: NW, 2: NE, 3: SE, 4: SW

        self:StartIntervalThink(self.interval)
    end
end

function modifier_tauropolos_alter:OnIntervalThink()
    if IsServer() then
        if not self:GetCaster() or not self:GetCaster():IsAlive() then
            self:Destroy()
        end

        local firestorm_fx = ParticleManager:CreateParticle("particles/atalanta/abyssal_underlord_firestorm_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl( firestorm_fx, 0, self.target_loc)
        ParticleManager:SetParticleControl( firestorm_fx, 4, Vector(self.max_dist, 0, 0))

        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(firestorm_fx, false)
            ParticleManager:ReleaseParticleIndex(firestorm_fx)
        end)

        if self.follow == 1 then 
            self.target_loc = self:GetParent():GetAbsOrigin()
        end

        self.caster = self:GetCaster()
        EmitSoundOnLocationWithCaster(self.target_loc, "Ability.Powershot.Alt", self.caster)
        EmitSoundOnLocationWithCaster(self.target_loc, "Ability.Powershot.Alt2", self.caster)
        EmitSoundOnLocationWithCaster(self.target_loc, "Ability.Powershot.Alt3", self.caster)

        for pepega = 1,4 do
           	local castDistance = RandomInt(self.min_dist, self.max_dist)
            local angle = RandomInt(0, 90)
            local dy = castDistance * math.sin(angle)
            local dx = castDistance * math.cos(angle)
            local attackPoint = Vector(0, 0, 0)

            if self.quadrant == 1 then          -- NW
                attackPoint = Vector( self.target_loc.x - dx, self.target_loc.y + dy, self.target_loc.z )
            elseif self.quadrant == 2 then      -- NE
                attackPoint = Vector( self.target_loc.x + dx, self.target_loc.y + dy, self.target_loc.z )
            elseif self.quadrant == 3 then      -- SE
                attackPoint = Vector( self.target_loc.x + dx, self.target_loc.y - dy, self.target_loc.z )
            else                                -- SW
                attackPoint = Vector( self.target_loc.x - dx, self.target_loc.y - dy, self.target_loc.z )
            end

            self.quadrant = 4 % (self.quadrant + 1)

            Timers:CreateTimer(0.02*pepega, function()
                local iPillarFx = ParticleManager:CreateParticle("particles/atalanta/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl( iPillarFx, 0, attackPoint)
                ParticleManager:SetParticleControl( iPillarFx, 1, attackPoint)
                ParticleManager:SetParticleControl( iPillarFx, 2, attackPoint)

                Timers:CreateTimer(0.8, function()
                    ParticleManager:DestroyParticle(iPillarFx, false)
                    ParticleManager:ReleaseParticleIndex(iPillarFx)
                end)
            end)
        end

        local stack = self.curse_stacks
        local damage = self.damage
        local bonus_damage = 0
        if self.caster:HasModifier("modifier_atalanta_evil_beast") then 
            stack = stack * 2
        end
		Timers:CreateTimer(0.5, function()
            local ata_presence = FindUnitsInRadius(self.caster:GetTeam(),
                                        self.target_loc, 
                                        nil, 
                                        self.max_dist, 
                                        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
                                        DOTA_UNIT_TARGET_HERO, 
                                        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
                                        0, 
                                        false)
            for _,ata in pairs (ata_presence) do 
                if ata == self.caster then
                    self.caster:FindAbilityByName(self.caster.DSkill):Energy(self.energy_gain)
                    if self.caster:HasModifier("modifier_atalanta_evil_beast") then 
                        self.caster:FateHeal(self.damage * self.heal, self.caster, true)
                    end
                end
            end

			local units = FindUnitsInRadius(self.caster:GetTeam(),
                                        self.target_loc, 
                                        nil, 
                                        self.max_dist, 
                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                        DOTA_UNIT_TARGET_ALL, 
                                        DOTA_UNIT_TARGET_FLAG_NONE, 
                                        0, 
                                        false)

            if units[1] ~= nil then 
                if self.caster.EvolutionAcquired then
                    self.caster:FindAbilityByName(self.caster.DSkill):Energy(self.caster:FindAbilityByName("atalanta_passive_evolution"):GetSpecialValueFor("energy_gain"))
                end
            end

		    for _,unit in pairs(units) do
                local damage = self.damage
                local bonus_damage = 0 

                if self.caster.BowAcquired then
                    bonus_damage = damage * (self.bonus_stack * unit:GetModifierStackCount("modifier_atalanta_curse", self.caster))
                end
    		    DoDamage(self.caster, unit, damage + bonus_damage, DAMAGE_TYPE_MAGICAL, 0, self.ability, false)
    		    for i = 1, stack do
                    self.caster:FindAbilityByName(self.caster.DSkill):Curse(unit)
                end
		    end
		end)
    end
end

