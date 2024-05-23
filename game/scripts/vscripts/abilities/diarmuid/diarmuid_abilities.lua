
function OnLoveSpotStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_love_spot", {})
	DiarmuidCheckCombo(caster, ability)

	caster:EmitSound("Hero_Warlock.ShadowWord")
	Timers:CreateTimer(duration, function()
		caster:StopSound("Hero_Warlock.ShadowWord")
	end)
end

function OnLovespotThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local forcemove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
		Position = nil
	}
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and IsFemaleServant(v) and not v:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_love_spot_charmed", {})
			forcemove.UnitIndex = v:entindex()
			forcemove.Position = caster:GetAbsOrigin() 
			v:Stop()
			ExecuteOrderFromTable(forcemove) 
			--giveUnitDataDrivenModifier(caster, v, "pause_sealenabled", 0.5)
		    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
		    ParticleManager:SetParticleControl(particle, 0, v:GetAbsOrigin())
		end
	end
   	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
end

function OnMindsEyeStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local bonus_vision = ability:GetSpecialValueFor("bonus_vision")
	local vision_duration = ability:GetSpecialValueFor("vision_duration")
	local sightdummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	sightdummy:SetDayTimeVisionRange(caster:GetDayTimeVisionRange() + bonus_vision)
	sightdummy:SetNightTimeVisionRange(caster:GetNightTimeVisionRange() + bonus_vision)
	local sightdummypassive = sightdummy:FindAbilityByName("dummy_unit_passive")
	sightdummypassive:SetLevel(1)
	sightdummy:AddNewModifier(caster, nil, "modifier_kill", {Duration=vision_duration})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_minds_eye_active", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_minds_eye_cooldown", {Duration = ability:GetCooldown(1)})

	Timers:CreateTimer(function() 
		if not IsValidEntity(sightdummy) then return end
		if caster:IsAlive() then
			sightdummy:SetAbsOrigin(caster:GetAbsOrigin())
		else
			sightdummy:ForceKill(true)
		end
		return 0.2
	end)
end

function OnChargeStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	local rampant_cooldown = ability:GetSpecialValueFor("rampant_cooldown")
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_1_END, rate=1.0})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_warriors_charge_buff", {})

	if IsSpellBlocked(target) then return end -- Linken effect checker

	if caster.IsMindEyeAcquired then
		local stacks = ability:GetCurrentAbilityCharges() or 0
		if stacks > 0 then 
			ability:EndCooldown() 
		end
	end

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end

	if caster.IsMindEyeAcquired then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_warriors_charge_debuff", {})
		local debuff_stack = target:GetModifierStackCount("modifier_warriors_charge_debuff", caster) or 0 
		target:SetModifierStackCount("modifier_warriors_charge_debuff", caster, debuff_stack + 1)
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if not IsImmuneToSlow(v) then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_warriors_charge_slow", {})
		end
        DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        
    end

	--particle
	caster:EmitSound("Hero_Huskar.Life_Break")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnDoubleSpearCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_rampant_warrior") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Rampant_Warrior_Active")
		return
	end
end

function OnDoubleSpearStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_rampant_warrior") then 
		caster:GiveMana(ability:GetManaCost(1))
		ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Rampant_Warrior_Active")
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_spearsmanship_active", {})
	caster:EmitSound("Diarmuid_Skill_1")
end

function OnDoubleSpearProc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local proc_chance = ability:GetSpecialValueFor("passive_proc_chance")
	local active_proc_chance = ability:GetSpecialValueFor("active_proc_chance")
	local proc_rate = RandomInt(1, 100)

	if caster:HasModifier("modifier_double_spearsmanship_active") or caster:HasModifier("modifier_rampant_warrior") then
		proc_chance = active_proc_chance
	end

	if proc_rate <= proc_chance then 
		if not --[[caster.bIsDoubleAttackOnCD]] caster:HasModifier("modifier_double_spearsmanship_cooldown") then
			local atk_animation = RandomInt(1, 2)
			if atk_animation == 1 then 
				StartAnimation(caster, {duration=caster:GetBaseAttackTime(), activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=34/(24 * caster:GetBaseAttackTime())})
			else
				StartAnimation(caster, {duration=caster:GetBaseAttackTime(), activity=ACT_DOTA_ATTACK_EVENT, rate=33/(24 * caster:GetBaseAttackTime())})
			end
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_spearsmanship_cooldown", {})
			Timers:CreateTimer(0.033, function()
				caster:PerformAttack( target, true, true, true, true, false, false, false )
				--[[caster.bIsDoubleAttackOnCD = true
				Timers:CreateTimer(0.033, function()
					caster.bIsDoubleAttackOnCD = false
				end)]]
			end)
		end
	end
end

function OnGaeCastStart(keys)
	local caster = keys.caster
	local particleName = nil
	if keys.ability == caster:FindAbilityByName("diarmuid_gae_buidhe") then	
		caster:EmitSound("Diarmuid_GaeBuidhe_Alt" .. math.random(1,2) .. "_1")
		particleName = "particles/custom/diarmuid/diarmuid_gae_cast.vpcf"
	elseif keys.ability == caster:FindAbilityByName("diarmuid_gae_dearg") then
		caster:EmitSound("Diarmuid_GaeDearg_Alt" .. math.random(1,3) .. "_1")
		particleName = "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf"
	end

	if (keys.ability == caster:FindAbilityByName("diarmuid_gae_buidhe") and caster:HasModifier("modifier_doublespear_dearg")) or (keys.ability == caster:FindAbilityByName("diarmuid_gae_dearg") and caster:HasModifier("modifier_doublespear_buidhe")) then
		local CastReduction = caster.MasterUnit2:FindAbilityByName("diarmuid_attribute_double_spear_strike"):GetSpecialValueFor("cast_reduction")
		local NewCastPoint = keys.CastTime - CastReduction
		keys.ability:SetOverrideCastPoint(NewCastPoint)
	end

	local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnGaeBuidheStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")
	local hp_dmg_lock = ability:GetSpecialValueFor("hp_dmg_lock")

	caster:RemoveModifierByName("modifier_doublespear_buidhe")

	if IsSpellBlocked(target) then return end 

	local unitReduction = 10
	local currentStack = target:GetModifierStackCount("modifier_gae_buidhe", caster)
	local golden_rose_damage = 0
	local healthDiff = target:GetHealth()

	if caster:HasModifier("modifier_golden_rose_attribute") then
		golden_rose_damage = currentStack / 100 * damage
		DoDamage(caster, target, golden_rose_damage, DAMAGE_TYPE_PURE, 0, ability, false)
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	healthDiff = healthDiff - target:GetHealth()
	local nStacks = math.ceil(healthDiff * hp_dmg_lock / (unitReduction * 100) )

	if target:GetHealth() > 0 and target:IsAlive() and caster:IsAlive() and nStacks > 1 then
		target:RemoveModifierByName("modifier_gae_buidhe") 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_gae_buidhe", {}) 
		target:SetModifierStackCount("modifier_gae_buidhe", ability, currentStack + nStacks)
		if target:IsRealHero() then 
			target:CalculateStatBonus() 
		end
	end
	EmitGlobalSound("Diarmuid_GaeBuidhe_Alt" .. math.random(1,2) .. "_2")
	target:EmitSound("Hero_Lion.Impale")
	
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=2})

	local dagon_particle = ParticleManager:CreateParticle("particles/custom/diarmuid/diarmuid_gae_buidhe.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

	if (caster:HasModifier("modifier_doublespear_attribute") or caster:HasModifier("modifier_double_spearsmanship_active")) 
		and not caster:HasModifier("modifier_rampant_warrior") then
		local dearg = caster:FindAbilityByName("diarmuid_gae_dearg")
		
		OnDoubleSpearRefresh(caster,dearg)
	end
end

function OnGaeBuidheThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local stack = target:GetModifierStackCount("modifier_gae_buidhe", caster)
	local max_health = math.max(target:GetMaxHealth() - (10 * stack), 1)

	if target:GetHealth() > max_health and not (target:GetHealth() == 0) then
		target:SetHealth(max_health)
	elseif target:GetMaxHealth() < max_health or (target:GetHealth() == 0) or (not target:IsAlive()) then
		target:Kill(ability, caster)		
		target:RemoveModifierByName("modifier_gae_buidhe")
	end
end

function OnBuidheOwnerDeath(keys)
	local caster = keys.caster
    LoopOverHeroes(function(hero)
    	hero:RemoveModifierByName("modifier_gae_buidhe")
    end)
end

function OnBuidheBearerDeath(keys)
	--PrintTable(keys)
	local unit = keys.unit
	unit:RemoveModifierByName("modifier_gae_buidhe")
end

function OnDeargStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	if caster:HasModifier("modifier_rampant_warrior_combo") then
		keys.ability:EndCooldown()
		keys.ability:RefundManaCost()
		local modifier = caster:FindModifierByName("modifier_rampant_warrior_combo")
		local RWDuration = modifier:GetRemainingTime()
		local RW = caster:FindAbilityByName("diarmuid_rampant_warrior")
		local DurationPenalty = RW:GetSpecialValueFor("duration_penalty")
		caster:RemoveModifierByName("modifier_rampant_warrior_combo")
		caster:RemoveModifierByName("modifier_rampant_warrior")
		caster:FindAbilityByName("diarmuid_double_spearsmanship"):ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_combo", {duration = RWDuration - DurationPenalty})
		caster:FindAbilityByName("diarmuid_rampant_warrior"):ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior", {duration = RWDuration - DurationPenalty})
	end

	ApplyStrongDispel(target)

	local damage = 0
	local maxDamageDist = ability:GetSpecialValueFor("max_damage_dist")
	local minDamageDist = ability:GetSpecialValueFor("min_damage_dist")
	local min_damage = ability:GetSpecialValueFor("min_damage")
	local max_damage = ability:GetSpecialValueFor("max_damage")

	
	local distDiff =  minDamageDist - maxDamageDist
	local damageDiff = max_damage - min_damage
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 
	if distance <= maxDamageDist then 
		damage = max_damage
	elseif maxDamageDist < distance and distance < minDamageDist then
		damage = min_damage + damageDiff * (minDamageDist - distance) / distDiff
	elseif minDamageDist <= distance then
		damage = min_damage
	end

	local original_pos = caster:GetAbsOrigin()

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100)
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )

	EmitGlobalSound("Diarmuid_GaeDearg_Alt" .. math.random(1,3) .. "_2")

	if caster:HasModifier("modifier_crimson_rose_attribute") and not IsManaLess(target) and target:IsHero() then
		target:SetMana(target:GetMana() - 500)
		target:AddNewModifier(caster, ability, "modifier_gae_dearg", { Duration = self:GetSpecialValueFor("duration") })
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)

	target:EmitSound("Hero_Lion.Impale")
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=2})

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

	local flashIndex = ParticleManager:CreateParticle( "particles/custom/diarmuid/gae_dearg_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( flashIndex, 2, original_pos )
    ParticleManager:SetParticleControl( flashIndex, 3, caster:GetAbsOrigin() )

    --ParticleManager:SetParticleControlEnt(flashIndex, 3, caster, PATTACH_CUSTOMORIGIN, "attach_attack2", caster:GetAbsOrigin(), true)

	if (caster:HasModifier("modifier_doublespear_attribute") or caster:HasModifier("modifier_double_spearmanship_active")) 
		and not caster:HasModifier("modifier_rampant_warrior") then
		local buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe")
		
		OnDoubleSpearRefresh(caster,buidhe)
	end
end

function OnGaeDeargCreate(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stack = target:GetModifierStackCount("modifier_gae_dearg", caster)
	local revoke = ability:GetSpecialValueFor("revoke_per_stack")
	giveUnitDataDrivenModifier(caster, target, "revoked", revoke*stack)
end

function OnGaeDeargThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stack = target:GetModifierStackCount("modifier_gae_dearg", caster)
	local mana_cut = ability:GetSpecialValueFor("mana_cut_per_stack")
	local max_mana = target:GetMaxMana() - (mana_cut * stack)

	if target:GetMana() > max_mana then
		target:SetMana(max_mana)
	end	
end

function OnDoubleSpearRefresh(caster,ability)
	local current_cooldown = ability:GetCooldownTimeRemaining()
	local window = ability:GetSpecialValueFor("doublespear_window")

	ability:EndCooldown()

	if caster:HasModifier("modifier_doublespear_attribute") then
		window = window + self:GetSpecialValueFor("attribute_window")
	end
	if ability:GetAbilityName() == "diarmuid_gae_buidhe" then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_doublespear_buidhe", { Spear = ability, RemainingCooldown = current_cooldown - window})
	elseif  ability:GetAbilityName() == "diarmuid_gae_dearg" then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_doublespear_dearg", { Spear = ability, RemainingCooldown = current_cooldown - window})
	end
end

function OnDoubleSpearWindowDestroy(keys)
	local caster = keys.caster 
	local spear = keys.Spear 

	if spear == nil then 

	end

	local remainingcooldown = keys.RemainingCooldown 
	if remainingcooldown > 0 then
		spear:StartCooldown(remainingcooldown)
	end
end

function OnRampantWarriorStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_double_spearsmanship_active") then 
		caster:RemoveModifierByName("modifier_double_spearsmanship_active")
	end
	caster:RemoveModifierByName("modifier_rampant_warrior_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_cooldown", {duration = ability:GetCooldown(1)})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior", {})

	local masterCombo = caster.MasterUnit2:FindAbilityByName(ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:StartCooldown(ability:GetCooldown(1))
	EmitGlobalSound("Diarmuid_Combo_" .. math.random(1,2))
end

function DiarmuidCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsDoubleSpearAcquired then
			if string.match(ability:GetAbilityName(), 'diarmuid_love_spot') and caster:FindAbilityByName("diarmuid_double_spearsmanship_upgrade"):IsCooldownReady() and caster:FindAbilityByName("diarmuid_rampant_warrior"):IsCooldownReady() and not caster:HasModifier("modifier_rampant_warrior_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_window", {})	
			end
		else
			if string.match(ability:GetAbilityName(), 'diarmuid_love_spot') and caster:FindAbilityByName("diarmuid_double_spearsmanship"):IsCooldownReady() and caster:FindAbilityByName("diarmuid_rampant_warrior"):IsCooldownReady() and not caster:HasModifier("modifier_rampant_warrior_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_window", {})	
			end
		end
	end
end

function OnRampantWarriorWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsDoubleSpearAcquired then
		caster:SwapAbilities("diarmuid_double_spearsmanship_upgrade", "diarmuid_rampant_warrior", false, true)
	else
		caster:SwapAbilities("diarmuid_double_spearsmanship", "diarmuid_rampant_warrior", false, true)
	end
end

function OnRampantWarriorWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsDoubleSpearAcquired then
		caster:SwapAbilities("diarmuid_double_spearsmanship_upgrade", "diarmuid_rampant_warrior", true, false)
	else
		caster:SwapAbilities("diarmuid_double_spearsmanship", "diarmuid_rampant_warrior", true, false)
	end
end

function OnRampantWarriorWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_rampant_warrior_window")
end

function OnLoveSpotImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLoveSpotImproved) then

	    if hero:HasModifier("modifier_rampant_warrior_window") then 
	    	hero:RemoveModifierByName("modifier_rampant_warrior_window")
	    end

	    hero.IsLoveSpotImproved = true

		UpgradeAttribute(hero, 'diarmuid_love_spot', 'diarmuid_love_spot_upgrade', true)
		hero.DSkill = "diarmuid_love_spot_upgrade"

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMindEyeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMindEyeAcquired) then

	    hero.IsMindEyeAcquired = true

	    UpgradeAttribute(hero, 'diarmuid_minds_eye', 'diarmuid_minds_eye_upgrade', true)
	    UpgradeAttribute(hero, 'diarmuid_warriors_charge', 'diarmuid_warriors_charge_upgrade', true)
		hero.QSkill = "diarmuid_warriors_charge_upgrade"
		hero.FSkill = "diarmuid_minds_eye_upgrade"

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnGoldenRoseAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsGoldenRoseAcquired) then

	    hero.IsGoldenRoseAcquired = true
	    
	    if hero.IsDoubleSpearAcquired then 
			hero:AddAbility("diarmuid_gae_buidhe_upgrade_3")
			hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_3"):SetLevel(hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_3"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_buidhe_upgrade_3", "diarmuid_gae_buidhe_upgrade_2", true, false)
			hero:RemoveAbility("diarmuid_gae_buidhe_upgrade_2")
		else
			hero:AddAbility("diarmuid_gae_buidhe_upgrade_1")
			hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1"):SetLevel(hero:FindAbilityByName("diarmuid_gae_buidhe"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_buidhe"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_buidhe"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_buidhe_upgrade_1", "diarmuid_gae_buidhe", true, false)
			hero:RemoveAbility("diarmuid_gae_buidhe")
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnCrimsonRoseAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsCrimsonRoseAcquired) then

	    hero.IsCrimsonRoseAcquired = true
		
	    if hero.IsDoubleSpearAcquired then 
			hero:AddAbility("diarmuid_gae_dearg_upgrade_3")
			hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_3"):SetLevel(hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_2"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_3"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_2"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_dearg_upgrade_3", "diarmuid_gae_dearg_upgrade_2", true, false)
			hero:RemoveAbility("diarmuid_gae_dearg_upgrade_2")
		else
			hero:AddAbility("diarmuid_gae_dearg_upgrade_1")
			hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_1"):SetLevel(hero:FindAbilityByName("diarmuid_gae_dearg"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_dearg"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_1"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_dearg"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_dearg_upgrade_1", "diarmuid_gae_dearg", true, false)
			hero:RemoveAbility("diarmuid_gae_dearg")
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDoubleSpearAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDoubleSpearAcquired) then

	    if hero:HasModifier("modifier_doublespear_buidhe") then 
	    	hero:RemoveModifierByName("modifier_doublespear_buidhe")
	    end

	    if hero:HasModifier("modifier_doublespear_dearg") then 
	    	hero:RemoveModifierByName("modifier_doublespear_dearg")
	    end

	    if hero:HasModifier("modifier_rampant_warrior_window") then 
	    	hero:RemoveModifierByName("modifier_rampant_warrior_window")
	    end

	    if hero:HasModifier("modifier_double_spearsmanship_active") then 
	    	hero:RemoveModifierByName("modifier_double_spearsmanship_active")
	    end

	    hero.IsDoubleSpearAcquired = true

	    hero:AddAbility("diarmuid_double_spearsmanship_upgrade")
		hero:FindAbilityByName("diarmuid_double_spearsmanship_upgrade"):SetLevel(hero:FindAbilityByName("diarmuid_double_spearsmanship"):GetLevel())
		if not hero:FindAbilityByName("diarmuid_double_spearsmanship"):IsCooldownReady() then 
			hero:FindAbilityByName("diarmuid_double_spearsmanship_upgrade"):StartCooldown(hero:FindAbilityByName("diarmuid_double_spearsmanship"):GetCooldownTimeRemaining())
		end
		hero:SwapAbilities("diarmuid_double_spearsmanship_upgrade", "diarmuid_double_spearsmanship", true, false)
		hero:RemoveAbility("diarmuid_double_spearsmanship")

	    if hero.IsGoldenRoseAcquired then 
			hero:AddAbility("diarmuid_gae_buidhe_upgrade_3")
			hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_3"):SetLevel(hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_3"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_buidhe_upgrade_3", "diarmuid_gae_buidhe_upgrade_1", true, false)
			hero:RemoveAbility("diarmuid_gae_buidhe_upgrade_1")
		else
			hero:AddAbility("diarmuid_gae_buidhe_upgrade_2")
			hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2"):SetLevel(hero:FindAbilityByName("diarmuid_gae_buidhe"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_buidhe"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_buidhe"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_buidhe_upgrade_2", "diarmuid_gae_buidhe", true, false)
			hero:RemoveAbility("diarmuid_gae_buidhe")
		end
	  
	    if hero.IsCrimsonRoseAcquired then 
			hero:AddAbility("diarmuid_gae_dearg_upgrade_3")
			hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_3"):SetLevel(hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_1"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_3"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_1"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_dearg_upgrade_3", "diarmuid_gae_dearg_upgrade_1", true, false)
			hero:RemoveAbility("diarmuid_gae_dearg_upgrade_1")
		else
			hero:AddAbility("diarmuid_gae_dearg_upgrade_2")
			hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_2"):SetLevel(hero:FindAbilityByName("diarmuid_gae_dearg"):GetLevel())
			if not hero:FindAbilityByName("diarmuid_gae_dearg"):IsCooldownReady() then 
				hero:FindAbilityByName("diarmuid_gae_dearg_upgrade_2"):StartCooldown(hero:FindAbilityByName("diarmuid_gae_dearg"):GetCooldownTimeRemaining())
			end
			hero:SwapAbilities("diarmuid_gae_dearg_upgrade_2", "diarmuid_gae_dearg", true, false)
			hero:RemoveAbility("diarmuid_gae_dearg")
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end