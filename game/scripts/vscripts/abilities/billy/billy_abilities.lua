function OnQ(keys)
    local caster = keys.caster
    local ability = keys.ability
    local targetPoint = ability:GetCursorPosition()

    local casterPos = caster:GetAbsOrigin()
    local direction = (targetPoint - casterPos):Normalized() 

    direction.z = 0

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local quickdraw_range = d_ability:GetSpecialValueFor("quickdraw_range")
    local bullet_speed = ability:GetSpecialValueFor("bullet_speed")
    local bullet_width = ability:GetSpecialValueFor("bullet_width")

    StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_ATTACK, rate=4})
    --EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Billy.Q" ..math.random(1,7), caster)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Billy.R" ..math.random(1,3), caster)

    local Bullet =
    {
        Ability = keys.ability,
        EffectName = "particles/billy/billy_q_projectile_model.vpcf",
        iMoveSpeed = bullet_speed,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = quickdraw_range,
        fStartRadius = bullet_width,
        fEndRadius = bullet_width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 3.0,
        bDeleteOnHit = true,
        vVelocity = direction * bullet_speed,  
    }
    ProjectileManager:CreateLinearProjectile(Bullet)

    OnAbilityReduceAmmo(keys)
end


function OnQHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

	local quickdraw_range = d_ability:GetSpecialValueFor("quickdraw_range")
	local quickdraw_effective_range = d_ability:GetSpecialValueFor("quickdraw_effective_range")
	local damage_reduction_outrange = ability:GetSpecialValueFor("damage_reduction_outrange")
	local cooldown_on_hit = ability:GetSpecialValueFor("cooldown_on_hit")

	local casterPos = caster:GetAbsOrigin()
	local targetPos = target:GetAbsOrigin()

	local distanceToCaster = (casterPos - targetPos):Length2D()

	if distanceToCaster > quickdraw_effective_range then
		damage = damage * (1 - (damage_reduction_outrange / 100)) -- Apply damage reduction
	end
    local pure_damage = d_ability:GetSpecialValueFor("pure_damage")
    DoDamage(caster, target, damage * (100 - pure_damage) / 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    DoDamage(caster, target, damage * pure_damage / 100, DAMAGE_TYPE_PURE, 0, ability, false)

    local ministun_duration = d_ability:GetSpecialValueFor("ministun_duration")
    local shot_divider = ability:GetSpecialValueFor("shot_divider")
    local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
    if stack % shot_divider == 0 then
        giveUnitDataDrivenModifier(caster, target, "modifier_stunned", ministun_duration)
    end

	if(ability:IsCooldownReady()) then
	else
	ability:EndCooldown()
	ability:StartCooldown(cooldown_on_hit)
	end

    if(caster.IsGambit) then
        local recover_mana_amount = d_ability:GetSpecialValueFor("recover_mana_amount")
        local recover_mana_chance = d_ability:GetSpecialValueFor("recover_mana_chance")
        local recover_ammo = ability:GetSpecialValueFor("recover_ammo")
        local recover_ammo_chance = ability:GetSpecialValueFor("recover_ammo_chance")

        local rng = RandomInt(1, 100)
        local rng2 = RandomInt(1, 100)

        if(rng < recover_mana_chance) then
            local mana = caster:GetMana()
            mana = mana + recover_mana_amount
            caster:SetMana(mana)
        end

        if(rng < recover_ammo_chance) then
            if not caster:HasModifier("modifier_ammo_reload") then
                local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
                caster:SetModifierStackCount("modifier_ammo_stack", caster, stack + 1)
            end
        end
    end

	local particleeff = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_dust_hit_shock.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_impact_splash.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("pparticles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike_tip_impact.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin())
	local particleeff = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_r_backstab_hit_blood.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleeff, 1, casterPos)

    target:EmitSound("Billy.Hit" ..math.random(1,6))
end

function AmmoCheck(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_ammo_reload") then
		caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "No Ammo")
        caster:EmitSound("Billy.Empty" ..math.random(1,3))
	end
end

function OnAbilityReduceAmmo(keys)
	local caster = keys.caster
	local ability = keys.ability

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

	local reload_duration = d_ability:GetSpecialValueFor("reload_duration")

	local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
	caster:SetModifierStackCount("modifier_ammo_stack", caster, stack - 1)

	if (stack - 1  <= 0) then
		d_ability:ApplyDataDrivenModifier(caster, caster, "modifier_ammo_reload", {duration = reload_duration})
		StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.25})
	end
end

function ApplyAmmoStackModifier(keys)
	local caster = keys.caster

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

	local ammo = d_ability:GetSpecialValueFor("ammo")

	-- Check if the caster is valid and apply the modifier
	if IsValidEntity(caster) then
		caster:SetModifierStackCount("modifier_ammo_stack", caster, ammo)
	end

	local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
	caster:SetModifierStackCount("modifier_ammo_stack", caster, ammo)
end

function OnW(keys)
	local caster = keys.caster
	local ability = keys.ability
    local reload_bonus_duration = ability:GetSpecialValueFor("reload_bonus_duration")
    local dash_duration = ability:GetSpecialValueFor("dash_duration")

    -- caster:EmitSound("Melt.W" ..math.random(1,3))
    local particleeff = ParticleManager:CreateParticle("particles/billy/billy_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,20))

    local modifier_name = "modifier_billy_w"

    -- Calculate the correct duration based on the modifier
    local dur
    if not caster:HasModifier("modifier_ammo_reload") then
        dur = dash_duration
        print("here22")
        print(dur)
    else
        dur = dash_duration + reload_bonus_duration
        print("here")
        print(dur)
    end

    -- Remove the existing modifier before applying the new one
    if caster:HasModifier(modifier_name) then
        caster:RemoveModifierByName(modifier_name)
    end

    -- Apply the modifier with the calculated duration
    ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = dur})
    BillyCheckCombo(caster,ability)
end

function OnD(keys)
    local caster = keys.caster
    local ability = keys.ability

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local ammo = d_ability:GetSpecialValueFor("ammo")
    local reload_duration = d_ability:GetSpecialValueFor("reload_duration")

    if not caster:HasModifier("modifier_ammo_reload") then
        caster:SetModifierStackCount("modifier_ammo_stack", caster, 0)

        StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=4})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_ammo_reload", {duration = reload_duration})
    else
        SendErrorMessage(caster:GetPlayerOwnerID(), "Reloading")
    end
end

function OnAutoAttack(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local auto_attack_bonus_from_q = ability:GetSpecialValueFor("auto_attack_bonus_from_q")

    local q_ability = caster:FindAbilityByName("billy_q")
    if caster.IsGambit then
        q_ability = caster:FindAbilityByName("billy_q_upgrade")
    end

    local damage = q_ability:GetSpecialValueFor("damage")

    DoDamage(caster, target, damage * auto_attack_bonus_from_q / 100 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
    OnAbilityReduceAmmo(keys)
end 

function OnF(keys)
	local caster = keys.caster
	local ability = keys.ability

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local ammo = d_ability:GetSpecialValueFor("ammo")
    local bonus_mana = ability:GetSpecialValueFor("mana_recover_per_w_level")

	caster:SetModifierStackCount("modifier_ammo_stack", caster, ammo)

	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=4})

    local mana = caster:GetMana()
    mana = mana + caster:FindAbilityByName("billy_w"):GetLevel() * bonus_mana
    caster:SetMana(mana)

	if(caster:HasModifier("modifier_ammo_reload")) then
		caster:RemoveModifierByName("modifier_ammo_reload")
	end
end

function OnReloadThink(keys)
	local caster = keys.caster
	local ability = keys.ability 

	local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
	if (stack <= 0) and not caster:HasModifier("modifier_ammo_reload") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ammo_reload", {})
		StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.25})
	end
end

function OnE(keys)
    local caster = keys.caster
    local ability = keys.ability
    local targetPoint = ability:GetCursorPosition()

    local casterPos = caster:GetAbsOrigin()
    local direction = (targetPoint - casterPos):Normalized()

    direction.z = 0

    local q_ability = caster:FindAbilityByName("billy_q")
    if caster.IsGambit then
        q_ability = caster:FindAbilityByName("billy_q_upgrade")
    end

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local quickdraw_range = d_ability:GetSpecialValueFor("quickdraw_range")
    local bullet_speed = q_ability:GetSpecialValueFor("bullet_speed")
    local bullet_width = q_ability:GetSpecialValueFor("bullet_width")

    local delay_per_shot = ability:GetSpecialValueFor("delay_per_shot")
    local aim_offset = ability:GetSpecialValueFor("aim_offset")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local range_penalty = ability:GetSpecialValueFor("range_penalty")

    local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
    local total_delay = cast_delay + delay_per_shot * stack
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_billy_e", {duration=total_delay})

    caster:EmitSound("Billy.EVoice"..math.random(1,2))

    Timers:CreateTimer(cast_delay, function()
        if not caster:IsAlive() then
            return
        end

        caster.ShotECount = 0

        for i = 1, stack do
            Timers:CreateTimer(cast_delay / 2 + delay_per_shot * i, function()
                caster.ShotECount = 0
                StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK, rate=4})

                local offsetX = RandomFloat(-200, 200)
                local offsetY = RandomFloat(-200, 200)

                local offsetTargetPoint = Vector(targetPoint.x + offsetX, targetPoint.y + offsetY, targetPoint.z)
                local offsetDirection = (offsetTargetPoint - casterPos):Normalized()

                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Billy.Q" ..math.random(1,6), caster)
                local rngnum = RandomInt(1, 8)
                if(rngnum <= 2) then    
                    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"Billy.ESFX" ..math.random(1,2), caster)
                end

                local Bullet =
                {
                    Ability = keys.ability,
                    EffectName = "particles/billy/billy_q_projectile_model.vpcf",
                    iMoveSpeed = bullet_speed,
                    vSpawnOrigin = caster:GetOrigin(),
                    fDistance = quickdraw_range - range_penalty,
                    fStartRadius = bullet_width - 20,
                    fEndRadius = bullet_width - 20,
                    Source = caster,
                    bHasFrontalCone = true,
                    bReplaceExisting = false,
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    fExpireTime = GameRules:GetGameTime() + 3.0,
                    bDeleteOnHit = true,
                    vVelocity = offsetDirection * bullet_speed,
                    shotNumber = caster.ShotECount + 1
                }
                ProjectileManager:CreateLinearProjectile(Bullet)
                OnAbilityReduceAmmo(keys)

                caster.ShotECount = caster.ShotECount + 1
            end)
        end
    end)
end

function OnEHit(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    local target = keys.target 

    local q_ability = caster:FindAbilityByName("billy_q")
    if caster.IsGambit then
        q_ability = caster:FindAbilityByName("billy_q_upgrade")
    end

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local damage = q_ability:GetSpecialValueFor("damage")
    local damage_per_level = q_ability:GetSpecialValueFor("damage_per_level")
    local quickdraw_range = d_ability:GetSpecialValueFor("quickdraw_range")
    local quickdraw_effective_range = d_ability:GetSpecialValueFor("quickdraw_effective_range")
    local damage_reduction_outrange = q_ability:GetSpecialValueFor("damage_reduction_outrange")

    local range_penalty = ability:GetSpecialValueFor("range_penalty")
    local damage_percentage_from_q = ability:GetSpecialValueFor("damage_percentage_from_q")

    local base_damage = damage
    local damage_increment = ability:GetSpecialValueFor("bonus_per_consecutive_shots")
    local shotNumber = keys.shotNumber or 1

    damage = (base_damage * damage_percentage_from_q / 100) + (damage_increment * (shotNumber - 1))
    damage = damage + (caster:GetLevel() * damage_per_level)

    local casterPos = caster:GetAbsOrigin()
    local targetPos = target:GetAbsOrigin()

    local distanceToCaster = (casterPos - targetPos):Length2D()

    if distanceToCaster > quickdraw_effective_range - (range_penalty/2) then
        damage = damage * (1 - (damage_reduction_outrange / 100))
    end

	local particleeff = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_dust_hit_shock.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_impact_splash.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
	local particleeff = ParticleManager:CreateParticle("pparticles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike_tip_impact.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin())
	local particleeff = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_r_backstab_hit_blood.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleeff, 1, casterPos)


    local pure_damage = d_ability:GetSpecialValueFor("pure_damage")
    DoDamage(caster, target, damage * (100 - pure_damage) / 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    DoDamage(caster, target, damage * pure_damage / 100, DAMAGE_TYPE_PURE, 0, ability, false)

    target:EmitSound("Billy.Hit" ..math.random(1,6))
    target:EmitSound("Billy.ESFX" ..math.random(1,2))
end

function OnR(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local casterPos = caster:GetAbsOrigin()
    local direction = (target:GetAbsOrigin() - casterPos):Normalized()
    direction.z = 0

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local bullet_speed = ability:GetSpecialValueFor("bullet_speed")
    local bullet_width = ability:GetSpecialValueFor("bullet_width")
    local max_range = ability:GetSpecialValueFor("max_range")

    local shot_count = ability:GetSpecialValueFor("shot_count")
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local delay_per_shot = ability:GetSpecialValueFor("delay_per_shot")

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1})
    giveUnitDataDrivenModifier(caster, caster, "modifier_stunned", cast_delay + delay_per_shot * shot_count + 0.1)
    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + delay_per_shot * shot_count - 0.1)

    local particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,10))
    local particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust_burst_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,10))
    local particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,10))

    -- Function to create and fire a single bullet
    local function FireBullet(finalShot)
        local Bullet = {
            Ability = keys.ability,
            EffectName = "particles/billy/billy_r_projectile_model.vpcf",
            iMoveSpeed = bullet_speed,
            vSpawnOrigin = caster:GetOrigin(),
            fDistance = max_range,
            fStartRadius = bullet_width,
            fEndRadius = bullet_width,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 2.0,
            bDeleteOnHit = true,
            vVelocity = direction * bullet_speed,
            finalShot = finalShot  -- Set the finalShot value based on the argument
        }
        ProjectileManager:CreateLinearProjectile(Bullet)
    end

    EmitGlobalSound("Billy.RVoice"..math.random(1,2))

    Timers:CreateTimer(cast_delay, function()
        if not caster:IsAlive() then
            return
        end

        caster.finalShot = false
        caster.rHits = 0

        local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
        if stack == 3 and caster.IsOutlaw then
            ability:EndCooldown()
            local cd = ability:GetCooldown(ability:GetLevel()) - ability:GetSpecialValueFor("last_ammo_cd_reduction")
            ability:StartCooldown(cd)
            caster.finalShot = true
        else
        end
        local shotsprog = 0
        -- Loop to fire shots with delay
        for i = 0, shot_count - 1 do
            Timers:CreateTimer(i * delay_per_shot, function()
                shotsprog = shotsprog + 1
                if(stack > 0) then
                    EmitGlobalSound("Billy.R" ..math.random(1,3))
                    if(shotsprog >= 2) and caster.finalShot then
                        FireBullet(true)
                    else
                        FireBullet(false)
                    end
                    OnAbilityReduceAmmo(keys)
                    stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
                else
                    return
                end
            end)
        end
    end)
end

function OnRHit(keys)
    local caster = keys.caster 
    local ability = keys.ability 
    local target = keys.target 
    local damage = ability:GetSpecialValueFor("damage_per_shot")
    local knockback_distance = ability:GetSpecialValueFor("knockback_distance")
    local finalShot = keys.finalShot
    --local cooldown_on_hit = ability:GetSpecialValueFor("cooldown_on_hit")
    caster.rHits = caster.rHits + 1

    local d_ability = caster:FindAbilityByName("billy_d")
    if caster.IsPistolImproved2 then
        d_ability = caster:FindAbilityByName("billy_d_2")
    elseif caster.IsPistolImproved then
        d_ability = caster:FindAbilityByName("billy_d_1")
    else
        d_ability = caster:FindAbilityByName("billy_d")
    end

    local pure_damage = d_ability:GetSpecialValueFor("pure_damage")

    if caster.IsOutlaw and caster.finalShot and caster.rHits == 3 then
        local last_ammo_bonus = ability:GetSpecialValueFor("last_ammo_bonus")
        DoDamage(caster, target, damage + last_ammo_bonus, DAMAGE_TYPE_PURE, 0, ability, false)
    else
        DoDamage(caster, target, damage * (100 - pure_damage) / 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        DoDamage(caster, target, damage * pure_damage / 100, DAMAGE_TYPE_PURE, 0, ability, false)
    end

    -- Calculate the direction from caster to target
    local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

    -- Move the target slightly in the opposite direction of the caster
    local new_position = target:GetAbsOrigin() + direction * knockback_distance
    target:SetAbsOrigin(new_position)

    -- Ensure the unit's position is valid
    FindClearSpaceForUnit(target, new_position, true)

    local particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_c_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
    local particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,60))
    ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
    local particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_b_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,60))
    ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
    local particleeff = ParticleManager:CreateParticle("pparticles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike_tip_impact.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin())
    local particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_assassinate_impact_distortion.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin())

    target:EmitSound("Billy.Hit" ..math.random(1,6))
end

function AmmoAudio(keys)
    local caster = keys.caster 
    caster:EmitSound("Billy.Reload")
end

function OnHandAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHand) then
        UpgradeAttribute(hero, "fate_empty1", "billy_f" , true)
        hero.FSkill = "billy_f"

        hero.IsHand= true
        NonResetAbility(hero)

        -- Set master 1's mana 
        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end
function OnOutlawAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsOutlaw) then
        UpgradeAttribute(hero, "billy_r", "billy_r_upgrade" , true)

        hero.IsOutlaw= true
        NonResetAbility(hero)

        -- Set master 1's mana 
        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end
function OnVisionAcquired(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsVision) then
        --UpgradeAttribute(hero, "billy_r", "billy_r_upgrade" , true)

        hero.IsVision= true
        ability:ApplyDataDrivenModifier(hero, hero, "modifier_billy_sa_vision", {})
        NonResetAbility(hero)

        -- Set master 1's mana 
        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end
function OnPistolAcquired(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPistolImproved2) then
        --UpgradeAttribute(hero, "billy_r", "billy_r_upgrade" , true)
        if not hero.IsPistolImproved then
            hero.IsPistolImproved = true
            keys.ability:EndCooldown()
            keys.ability:SetLevel(2)

            UpgradeAttribute(hero, "billy_d", "billy_d_1" , true)
            --hero:FindAbilityByName("billy_d"):SetLevel(2)
            --hero:FindAbilityByName("billy_d"):setabilitytexturename
        else
            hero.IsPistolImproved2 = true
            UpgradeAttribute(hero, "billy_d_1", "billy_d_2" , true)
            --hero:FindAbilityByName("billy_d"):SetLevel(3)
        end
        NonResetAbility(hero)
        -- Set master 1's mana 
        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end

function OnCombo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local targetpoint = target:GetAbsOrigin() or ability:GetCursorPosition()
    local cast_delay = ability:GetSpecialValueFor("cast_delay")
    local damage = ability:GetSpecialValueFor("damage")
    local radius = ability:GetSpecialValueFor("radius")
    local speed = ability:GetSpecialValueFor("speed")
    local shot_count = ability:GetSpecialValueFor("shot_count")
    local minimum_for_singles = ability:GetSpecialValueFor("minimum_for_singles")
    local delay_per_shot = ability:GetSpecialValueFor("delay_per_shot")

    local masterCombo = caster.MasterUnit2:FindAbilityByName("billy_combo")
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_billy_combo_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
    caster:RemoveModifierByName("modifier_combo_window")

    local particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,10))
    particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust_burst_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,10))
    particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,10))
    particleeff = ParticleManager:CreateParticle("particles/econ/items/dragon_knight/dk_2022_immortal/dk_2022_immortal_dragon_tail_dragon_impact_flare.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleeff, 1, caster:GetAbsOrigin() + Vector(0,0,10))
    particleeff = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold_glyph_flare.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay + 0.35)
    EmitGlobalSound("Billy.ComboVoice")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), 
        targetpoint, 
        nil, 
        radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO, 
        DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, 
        false
    )

    local target_bullet = {}
    local target_available = true
    ability.current_target = nil

    Timers:CreateTimer(cast_delay, function()
        EmitGlobalSound("Billy.ComboVoice2")
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,10))
        particleeff = ParticleManager:CreateParticle("particles/econ/events/ti10/hot_potato/disco_ball_death_flare.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,10))
        particleeff = ParticleManager:CreateParticle("particles/billy/billy_combo_flare_self.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,80))
        particleeff = ParticleManager:CreateParticle("particles/billy/billy_r_dust_burst_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,10))

        local ult = caster:FindAbilityByName("billy_e")
        ult:StartCooldown(ult:GetCooldown(ult:GetLevel()))

        for i = 1, #enemies do
            if enemies[i] == target then 
                ability.current_target = i 
            end
            if not IsValidEntity(enemies[i])
                or not enemies[i]:IsRealHero() 
                or not enemies[i]:IsAlive() 
                or not IsInSameRealm(caster:GetAbsOrigin(), enemies[i]:GetAbsOrigin()) 
                then 
                table.remove(enemies, i)
                if enemies[i] == target then 
                    ability.current_target = nil
                end
            end
        end

        if caster:IsAlive() then

            StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=0.6})
    
            local stack = caster:GetModifierStackCount("modifier_ammo_stack", caster) or 0
            local random = ability.current_target or RandomInt(1, #enemies) -- primary target index
            for a = 0, stack - 1 do
                if #enemies >= 1 then        
                    if #enemies < minimum_for_singles then -- focus fire
                        Timers:CreateTimer(a * delay_per_shot, function()
                            if not enemies[random]:IsAlive() then 
                                table.remove(enemies, random)
                                random = RandomInt(1, #enemies)
                            end

                            ShootProjectile(caster, enemies[random], ability, speed)
                            local name = enemies[random]:GetName()
                            target_bullet.name = (target_bullet.name or 0) + 1

                            if target_bullet.name >= shot_count then 
                                table.remove(enemies, random)
                                random = RandomInt(1, #enemies)
                            end
                        end)
                    else -- multiple fire
                        Timers:CreateTimer(a * delay_per_shot, function()
                            local index = a 
                            local total_enemies = #enemies
                            if index > total_enemies then 
                                index = index - total_enemies
                            end
                            ShootProjectile(caster, enemies[index], ability, speed)
                        end)
                    end
                else -- if no one in array, finding new target
                    Timers:CreateTimer(a * delay_per_shot, function()
                        enemies = FindUnitsInRadius(
                            caster:GetTeamNumber(), 
                            targetpoint, 
                            nil, 
                            radius, 
                            DOTA_UNIT_TARGET_TEAM_ENEMY, 
                            DOTA_UNIT_TARGET_HERO, 
                            DOTA_UNIT_TARGET_FLAG_NONE, 
                            FIND_ANY_ORDER, 
                            false
                        )
                        random = RandomInt(1, #enemies)
                        ShootProjectile(caster, enemies[index], ability, speed)
                    end)
                end
            end
            --[[if #enemies >= minimum_for_singles then
                -- Shoot each enemy once with delay
                for i, enemy in ipairs(enemies) do
                    Timers:CreateTimer(i * delay_per_shot, function()
                        if stack > 0 then
                            stack = stack - 1
                            if(enemy:IsAlive()) then
                                ShootProjectile(caster, enemy, ability, speed)
                            end
                        else
                            return
                        end
                    end)
                end
            else
                -- Shoot one random enemy multiple times with delay
                local random_enemy = enemies[RandomInt(1, #enemies)]
                for i = 1, shot_count do
                    Timers:CreateTimer(i * delay_per_shot, function()                       
                        if stack > 0 then
                            stack = stack - 1
                            if(random_enemy:IsAlive()) then
                                ShootProjectile(caster, random_enemy, ability, speed)
                            end
                        else
                            return
                        end
                    end)
                end
            end]]
        end     
    end)
end

function ShootProjectile(caster, target, ability, speed)
    EmitGlobalSound("Billy.R" .. math.random(1, 3))
    local projectile = {
        Target = target,
        Source = caster,
        Ability = ability,
        EffectName = "particles/billy/billy_combo_projectile.vpcf",
        iMoveSpeed = speed,
        vSourceLoc = caster:GetAbsOrigin(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        bDrawsOnMinimap = false,
        bDodgeable = true,
        bIsAttack = false,
        flExpireTime = GameRules:GetGameTime() + 3,
        bProvidesVision = true,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
end

function OnComboHit(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local damage = ability:GetSpecialValueFor("damage")

    if target and not target:IsNull() and target:IsAlive() then
        DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
        local particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_c_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
        particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,60))
        ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
        particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_b_charlie.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin() + Vector(0,0,60))
        ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin() + Vector(0,0,60))
        particleeff = ParticleManager:CreateParticle("particles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike_tip_impact.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(particleeff, 1, target:GetAbsOrigin())
        particleeff = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_assassinate_impact_distortion.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(particleeff, 0, target:GetAbsOrigin())

        target:EmitSound("Billy.Hit" .. math.random(1, 6))
    end
end

function BillyCheckCombo(caster, ability)
    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
        if string.match(ability:GetAbilityName(), "billy_w") and caster:FindAbilityByName("billy_e"):IsCooldownReady() and not caster:HasModifier("modifier_billy_combo_cooldown") then 
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_combo_window", {duration = 5})
        end
    end
end

function OnComboWindow(keys)
    local caster = keys.caster
    caster:SwapAbilities("billy_e", "billy_combo", false, true)
end

function OnComboWindowBroken(keys)
    local caster = keys.caster
    caster:SwapAbilities("billy_e", "billy_combo", true, false)
end

function OnComboWindowDeath(keys)
    local caster = keys.caster
    caster:RemoveModifierByName("modifier_combo_window")
end

function OnDamaged(keys)
    local caster = keys.caster 
    local currentHealth = caster:GetHealth() 
    local ability = keys.ability
    local damageTaken = keys.DamageTaken  -- Extract the damage taken
    local attacker = keys.attacker  -- Get the attacker entity

    -- Get the special values from the ability
    local pureEvasion = ability:GetSpecialValueFor("pure_evasion")
    local pureEvasion1000Range = ability:GetSpecialValueFor("pure_evasion_1000_range")
    local quadruple_range = ability:GetSpecialValueFor("quadruple_range")

    -- Calculate the evasion chance
    local evasionChance = pureEvasion  -- Default evasion chance

    -- Check if the attacker is valid and if the damage source is above 1000 unit range
    if IsValidEntity(attacker) and caster:GetRangeToUnit(attacker) > quadruple_range then
        evasionChance = pureEvasion1000Range  -- Set the evasion chance to the range-based value
    end

    -- Check if the evasion succeeds
    if RollPercentage(evasionChance) then
        caster:SetHealth(currentHealth + keys.DamageTaken)
    end
end
function OnGambitAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

    if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGambit) then
        UpgradeAttribute(hero, "billy_q", "billy_q_upgrade" , true)

        hero.IsGambit= true
        NonResetAbility(hero)

        -- Set master 1's mana 
        local master = hero.MasterUnit
        master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
    end
end