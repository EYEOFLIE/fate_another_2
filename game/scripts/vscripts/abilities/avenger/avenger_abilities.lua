
function OnDPStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()
	local targetPoint = ability:GetCursorPosition()
	local health_cost = ability:GetSpecialValueFor("health_cost")
	local range = ability:GetSpecialValueFor("range")
	local penalty_cooldown = ability:GetSpecialValueFor("penalty_cooldown")
	local currentHealthCost = 0
    local ply = caster:GetPlayerOwner()

	if IsLocked(caster) then 
		ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
		return
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		ability:EndCooldown()  
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	local currentStack = caster:GetModifierStackCount("modifier_dark_passage", caster) or 0
	currentHealthCost = health_cost * 2 ^ currentStack
	if currentStack == 0 and caster:HasModifier("modifier_dark_passage") then currentStack = 1 end
	caster:RemoveModifierByName("modifier_dark_passage") 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_dark_passage", {}) 
	caster:SetModifierStackCount("modifier_dark_passage", caster, currentStack + 1)

	local hp_drain = {
		victim = caster,
		attacker = caster,
		damage = currentHealthCost,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL, --Optional.
		ability = ability, --Optional.
	}
	ApplyDamage(hp_drain)

	if caster:GetHealth() == 1 then 
		ability:EndCooldown()
		ability:StartCooldown(penalty_cooldown)
	end

	--[[if caster:GetHealth() <= currentHealthCost then
		caster:SetHealth(1)
		ability:EndCooldown()
		ability:StartCooldown(penalty_cooldown)
	else
		caster:SetHealth(caster:GetHealth() - currentHealthCost)
	end]]

	local particle_in = "particles/custom/avenger/avenger_dark_passage_start.vpcf"
	local particle_out = "particles/custom/avenger/avenger_dark_passage_end.vpcf"
	if caster:HasModifier("modifier_true_form") then 
		particle_in = "particles/custom/avenger/avenger_dark_passage_start_trueform.vpcf"
		particle_out = "particles/custom/avenger/avenger_dark_passage_end_trueform.vpcf"
	end
	
	-- Create particle at start point
	local startParticleIndex = ParticleManager:CreateParticle( particle_in, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( startParticleIndex, 0, caster:GetAbsOrigin() )
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( startParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( startParticleIndex )
	end)
	
	caster:EmitSound("Hero_Antimage.Blink_out")
	
	local diff = targetPoint - caster:GetAbsOrigin()
	Timers:CreateTimer(0.033, function()
		if diff:Length2D() > range then
			targetPoint = caster:GetAbsOrigin() + diff:Normalized() * range
		end

		local i = 1
		while GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) do
			i = i+1
			targetPoint = caster:GetAbsOrigin() + diff:Normalized() * (range - i*50)
		end
		caster:SetAbsOrigin(targetPoint)
		FindClearSpaceForUnit(caster, targetPoint, true)
		ProjectileManager:ProjectileDodge(caster)
		caster:EmitSound("Hero_Antimage.Blink_in")
			
		-- Create end particle
		-- Create particle at start point
		local endParticleIndex = ParticleManager:CreateParticle( particle_out, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( endParticleIndex, 0, caster:GetAbsOrigin() )
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( endParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( endParticleIndex )
		end)
	end)
end

function OnDarkPassageRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_dark_passage")
	ability:EndCooldown()
end

function OnMurderStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_murderous_instinct", {}) 
end 

function OnMurderCrit(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_murderous_instinct_crit_hit", {}) 
end 

function OnMurderBash(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:HasModifier("modifier_murderous_instinct_bash_cooldown") or target:IsMagicImmune() then return end
	
	local damage = ability:GetSpecialValueFor("bash_dmg")
	local bash_stun = ability:GetSpecialValueFor("bash_stun")

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = bash_stun})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_murderous_instinct_bash_cooldown", {})
	end 

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end 

function OnMurder(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local manareg = 0
	if target:GetName() == "npc_dota_creature" then 
		--print("Avenger killed a unit")
		manareg = caster:GetMaxMana() * keys.ManaRegen / 100
	elseif target:IsHero() then
		--print("Avenger killed a hero")
		manareg = caster:GetMaxMana() * keys.ManaRegenHero / 100
		caster:RemoveModifierByName("modifier_dark_passage")

		if caster:HasModifier("modifier_murderous_instinct") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_murderous_instinct", {})
		end
	end
	caster:SetMana(caster:GetMana() + manareg)
end

function OnAttackRemain(keys)
	local caster = keys.caster
	local target = keys.target
	--print(target:GetName())
	if target:GetUnitName() == "avenger_remain" then
		DoDamage(caster, target, 9999, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnMurderUpgrade(keys)
	local caster = keys.caster 
	if caster.IsWorldEvilAcquired then 
		caster:FindAbilityByName("avenger_unlimited_remains_upgrade"):SetLevel(keys.ability:GetLevel())
	else
		caster:FindAbilityByName("avenger_unlimited_remains"):SetLevel(keys.ability:GetLevel())
	end
end

function OnRemainStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local spawn_number = keys.SpawnNumber

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_avenger_death_checker", {})
	
	local attackmove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = nil
	}
	caster:EmitSound("Hero_Nevermore.Shadowraze")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + caster:GetForwardVector() * 200) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	for i=1, spawn_number do
		local remain = CreateUnitByName("avenger_remain", caster:GetAbsOrigin() + caster:GetForwardVector() * 200, true, nil, nil, caster:GetTeamNumber()) 
		--remain:SetControllableByPlayer(caster:GetPlayerID(), true)
		remain:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
		LevelAllAbility(remain)
		FindClearSpaceForUnit(remain, remain:GetAbsOrigin(), true)
		if caster.IsWorldEvilAcquired then 
			remain:RemoveAbility("avenger_remain_passive")
			remain:AddAbility("avenger_remain_upgrade_passive")
			remain:FindAbilityByName("avenger_remain_upgrade_passive"):SetLevel(ability:GetLevel())
		else
			remain:FindAbilityByName("avenger_remain_passive"):SetLevel(ability:GetLevel())
		end
		remain:AddNewModifier(caster, nil, "modifier_kill", {duration = 24})
		Timers:CreateTimer(3.0, function() 
			if not remain:IsAlive() then return end
			attackmove.UnitIndex = remain:entindex()
			attackmove.Position = remain:GetAbsOrigin() + RandomVector(1000) 
			ExecuteOrderFromTable(attackmove)
			return 3.0
		end)
	end

	AvengerCheckCombo(caster, ability)
end

function OnRemainSearchTarget(keys)
	local caster = keys.caster

	local ability = keys.ability 
	local detect_range = ability:GetSpecialValueFor("detect_range")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, detect_range , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

	for k,v in pairs (targets) do
		if v:HasModifier("modifier_all_the_world_evil") then 
			print('evil curse detect')
			ability:ApplyDataDrivenModifier(caster, caster, "avenger_remain_self_buff", {})
			local aim_target = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = v:entindex()
			}
			ExecuteOrderFromTable(aim_target)
			return nil 
		end
	end


	if caster:HasModifier("avenger_remain_self_buff") then
		caster:RemoveModifierByName("avenger_remain_self_buff")
	end

	for k,v in pairs (targets) do
		if v:HasModifier("modifier_verg_marker") then 
			local aim_target = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = v:entindex()
			}
			ExecuteOrderFromTable(aim_target)
			return nil 
		end
	end

end

function OnRemainDeath(keys)
	local caster = keys.caster
	local delay = 0 
	if caster.IsAtTheEndOfFourNightsAcquired then 
		delay = 10 
		local remain_abil = caster:FindAbilityByName("avenger_unlimited_remains")
		if remain_abil == nil then 
			remain_abil = caster:FindAbilityByName("avenger_unlimited_remains_upgrade")
		end
		local newkeys = {
			caster = caster,
			ability = remain_abil,
			SpawnNumber = 6,
		}
		OnRemainStart(newkeys)
	end
	Timers:CreateTimer(delay, function()
		local summons = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		for k,v in pairs(summons) do
			--print("Found unit " .. v:GetUnitName())
			if IsValidEntity(v) and not v:IsNull() and v:GetUnitName() == "avenger_remain" and v:GetOwner() == caster then
				v:ForceKill(true) 
			end
		end
	end)
end

function OnRemainExplode(keys)
	local caster = keys.caster
	local target = keys.target
	if (target:GetName() == "npc_dota_ward_base") or caster.IsDamageDone then
		return
	end
	caster.IsDamageDone = true
	caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if v:HasModifier("modifier_all_the_world_evil") then 
			local bonus_damage = keys.ability:GetSpecialValueFor("bonus_damage")
			DoDamage(caster, v, keys.Damage + bonus_damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		else
			DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		end
    end

    caster:ForceKill(true)
end

function OnRemainMultiplyStart(keys)
	local caster = keys.caster
	Timers:CreateTimer(0.033, function()
		local avenger = caster:GetPlayerOwner():GetAssignedHero()
		local remainabil = avenger:FindAbilityByName("avenger_unlimited_remains")
		if remainabil == nil then 
			remainabil = avenger:FindAbilityByName("avenger_unlimited_remains_upgrade")
		end
		local period = remainabil:GetLevelSpecialValueFor("multiply_period", remainabil:GetLevel()-1)	
		Timers:CreateTimer(period, function() 
			if not IsValidEntity(caster) or not caster:IsAlive() then return end
			OnRemainMultiply(keys)
			return period
		end)	
	end)

end

function OnRemainMultiply(keys)
	local caster = keys.caster
	local attackmove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = nil
	}
	local remain = CreateUnitByName("avenger_remain", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	--remain:SetControllableByPlayer(caster:GetPlayerID(), true)
	remain:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	LevelAllAbility(remain)
	FindClearSpaceForUnit(remain, remain:GetAbsOrigin(), true)
	remain:FindAbilityByName("avenger_remain_passive"):SetLevel(keys.ability:GetLevel())
	remain:AddNewModifier(caster, nil, "modifier_kill", {duration = 24})
	Timers:CreateTimer(3.0, function() 
		if not remain:IsAlive() then return end
		attackmove.UnitIndex = remain:entindex()
		attackmove.Position = remain:GetAbsOrigin() + RandomVector(1000) 
		ExecuteOrderFromTable(attackmove)
		return 3.0
	end)
end

function OnZarichTawrichStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_point = ability:GetCursorPosition() 
	local origin = caster:GetAbsOrigin()
	local forwardvec = caster:GetForwardVector() 
	local rightvec = caster:GetRightVector() 
	local distance = ability:GetSpecialValueFor("distance")
	local speed = ability:GetSpecialValueFor("speed")
	local width = ability:GetSpecialValueFor("width")
	local self_disarm = ability:GetSpecialValueFor("self_disarm")


	if (target_point - origin):Length2D() < distance then 
		target_point = origin + (target_point - origin):Normalized() * distance 
	end

	local range = (target_point - origin):Length2D()
	local duration = range / speed

	local leftorigin = origin + -rightvec * width /2
	leftorigin.z = origin.z
	local rightorigin = origin + rightvec * width /2
	rightorigin.z = origin.z

	local tawrich = {
		Ability = ability,
		iMoveSpeed = speed,
		vSpawnOrigin = leftorigin,
		fDistance = range,
		Source = caster,
		fStartRadius = width,
        fEndRadius = width,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = forwardvec * speed,		
	}

	local zarich = {
		Ability = ability,
		iMoveSpeed = speed,
		vSpawnOrigin = rightorigin,
		fDistance = range ,
		Source = caster,
		fStartRadius = width,
        fEndRadius = width,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 3,
		bDeleteOnHit = false,
		vVelocity = forwardvec * speed,		
	}

	local tawrich_projectile = ProjectileManager:CreateLinearProjectile(tawrich)
	local zarich_projectile = ProjectileManager:CreateLinearProjectile(zarich)

	giveUnitDataDrivenModifier(caster, caster, "disarmed", self_disarm)

	local dummyL = CreateUnitByName("dummy_unit", leftorigin + Vector(0,0,80), false, caster, caster, caster:GetTeamNumber())
	dummyL:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummyL:SetForwardVector(forwardvec)

	local dummyR = CreateUnitByName("dummy_unit", rightorigin + Vector(0,0,80), false, caster, caster, caster:GetTeamNumber())
	dummyR:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummyR:SetForwardVector(forwardvec)

	local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/avenger/avenger_tawrich_zarich.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyL )
	ParticleManager:SetParticleControl( fxIndex1, 1, target_point -rightvec * width /2 + Vector(0,0,80) )
	ParticleManager:SetParticleControl( fxIndex1, 2, Vector(speed,0,0) )

	local fxIndex2 = ParticleManager:CreateParticle( "particles/custom/avenger/avenger_tawrich_zarich.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummyR )
	ParticleManager:SetParticleControl( fxIndex2, 1, target_point + rightvec * width /2 + Vector(0,0,80)  )
	ParticleManager:SetParticleControl( fxIndex2, 2, Vector(speed,0,0) )	

	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle( fxIndex1, false )
		ParticleManager:ReleaseParticleIndex( fxIndex1 )	
		ParticleManager:DestroyParticle( fxIndex2, false )
		ParticleManager:ReleaseParticleIndex( fxIndex2 )
		if IsValidEntity(dummyL) then	
			dummyL:RemoveSelf()	
		end
		if IsValidEntity(dummyR) then
			dummyR:RemoveSelf()	
		end	
	end)

end

function OnZarichTawrichHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end 

	local cc_duration = ability:GetSpecialValueFor("active_cc_duration")

	if target.ZarichTawrichHit == nil then 
		target.ZarichTawrichHit = 0 
	end

	if target.ZarichTawrichHit < 1 then 
		if not IsImmuneToCC(target) then
			if not target:IsMagicImmune() then
				giveUnitDataDrivenModifier(caster, target, "silenced", cc_duration)
			end
			giveUnitDataDrivenModifier(caster, target, "disarmed", cc_duration)
		end
	end

	target.ZarichTawrichHit = target.ZarichTawrichHit + 1

	Timers:CreateTimer(1.0,function()
		target.ZarichTawrichHit = 0 
	end)

	ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_zarich_damage", {}) 
	if not IsImmuneToSlow(target) and not target:IsMagicImmune() and not IsImmuneToCC(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_zarich_slow", {}) 
	end
end

function OnZarichTawrichDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local total_damage = ability:GetSpecialValueFor("total_damage")

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	DoDamage(caster, target, total_damage / 6, DAMAGE_TYPE_PHYSICAL, 0, ability, false)

	target:EmitSound("Hero_BountyHunter.Jinada")
	local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnZarichAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local passive_silence = ability:GetSpecialValueFor("passive_silence_chance")
	local cc_duration = ability:GetSpecialValueFor("passive_silence_duration")

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:IsMagicImmune() then return end
	if target:HasModifier("modifier_tawrich_zarich_cooldown") then return end

	if RandomInt(1, 100) <= passive_silence then 
		if not IsImmuneToCC(target) then
			giveUnitDataDrivenModifier(caster, target, "silenced", cc_duration)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_zarich_cooldown ", {}) 
		end
	end
end

function OnTawrichAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local passive_disarm = ability:GetSpecialValueFor("passive_disarm_chance")
	local cc_duration = ability:GetSpecialValueFor("passive_disarm_duration")

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:HasModifier("modifier_tawrich_zarich_cooldown") then return end

	if RandomInt(1, 100) <= passive_disarm then 
		if not IsImmuneToCC(target) then
			giveUnitDataDrivenModifier(caster, target, "disarmed", cc_duration)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_zarich_cooldown", {}) 
		end
	end
end

function OnZTUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsWorldEvilAcquired then 
		caster:FindAbilityByName("avenger_vengeance_mark_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("avenger_vengeance_mark"):SetLevel(ability:GetLevel())
	end
end

function OnVengeanceStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")

	if IsSpellBlocked(target) then return end

	ability:ApplyDataDrivenModifier(caster, target, "modifier_vengeance_mark", {})

	if caster.IsWorldEvilAcquired then
		if not target:IsMagicImmune() then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_all_the_world_evil", {})
		end
	end

	caster:EmitSound("Hero_DoomBringer.Devour")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death_bonus.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnVengeanceEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local return_percentage = ability:GetSpecialValueFor("return_percentage") / 100
	DoDamage(target, caster, damage * return_percentage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NON_LETHAL, ability, false)
end

function OnTFStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_true_form", {}) 
	AvengerCheckCombo(caster, ability)

    caster:EmitSound("Avenger.TransformShort")
end

function OnTFCreate(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_padoru") then 

	else
		caster.OriginModel = caster:GetModelName()
		caster.OriginModelSize = caster:GetModelScale()
		caster:SetModel("models/angra_mainyu/avenger_morph_by_zefiroft.vmdl")
	    caster:SetOriginalModel("models/angra_mainyu/avenger_morph_by_zefiroft.vmdl")
	    caster:SetModelScale(1.8)
	end

    if caster.IsWorldEvilAcquired then 
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark_upgrade", false, true) 
    	caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains_upgrade", false, true) 
    else
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", false, true) 
    	caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", false, true) 
    end
    if caster.IsDemonIncarnateAcquired then
    	caster:SwapAbilities("avenger_true_form_upgrade", "avenger_demon_core_upgrade", false, true)
    else
    	caster:SwapAbilities("avenger_true_form", "avenger_demon_core", false, true)
    end
end

function OnTFDestroy(keys)
	local caster = keys.caster
	
	if caster:HasModifier("modifier_padoru") then 

	else
		if caster:HasModifier("modifier_alternate_01") then
			caster:SetModel("models/angra_mainyu/shirou/angra_emiya_by_zefiroft.vmdl")
		    caster:SetOriginalModel("models/angra_mainyu/shirou/angra_emiya_by_zefiroft.vmdl")
		    caster:SetModelScale(1.2)
		else
			caster:SetModel("models/angra_mainyu/avenger_by_zefiroft.vmdl")
	    	caster:SetOriginalModel("models/angra_mainyu/avenger_by_zefiroft.vmdl")
	    	caster:SetModelScale(1.8)
		end
	end

	
    if caster.IsWorldEvilAcquired then 
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark_upgrade", true, false) 
    	caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains_upgrade", true, false) 
    else
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", true, false) 
    	caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", true, false) 
    end
    if caster.IsDemonIncarnateAcquired then
    	caster:SwapAbilities("avenger_true_form_upgrade", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
    else
    	caster:SwapAbilities("avenger_true_form", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
    end

    if caster:HasModifier("modifier_demon_core") then 
    	caster:RemoveModifierByName("modifier_demon_core")
    end
end

function OnTFDeath(keys)
	local caster = keys.caster 

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	caster:RemoveModifierByName("modifier_true_form")
end

function OnTFUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsDemonIncarnateAcquired then 
		caster:FindAbilityByName("avenger_demon_core_upgrade"):SetLevel(ability:GetLevel())
	else
		caster:FindAbilityByName("avenger_demon_core"):SetLevel(ability:GetLevel())
	end
end

function OnOverdriveAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local bonus_aspd = ability:GetSpecialValueFor("overdrive_bonus_aspd")
	local max_stack = ability:GetSpecialValueFor("overdrive_max_aspd")

	max_stack = math.floor((max_stack - bonus_aspd) / bonus_aspd)

	if target == caster.overdrive_target and caster:HasModifier("modifier_overdrive") then
		local current_stack = caster:GetModifierStackCount("modifier_overdrive", caster)
		current_stack = current_stack + 1 
		if current_stack > max_stack then 
			current_stack = max_stack
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_overdrive", {})
		caster:SetModifierStackCount("modifier_overdrive", caster, current_stack)
	else
		caster.overdrive_target = target 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_overdrive", {})
		caster:SetModifierStackCount("modifier_overdrive", caster, 1)
	end
end

function OnOverdriveDestroy(keys)
	local caster = keys.caster 
	caster.overdrive_target = nil 
end

function OnDCToggleOn(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_demon_core", {})
end

function OnDCToggleOff(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_demon_core")
end

function OnDCTick(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("avenger_demon_core_upgrade")
	end
	local mana_cost = ability:GetSpecialValueFor("mana_cost_per_second")
	-- If Demon Core is not toggled on or caster has less than 50 mana, remove buff 
	if not ability:GetToggleState() or caster:GetMana() < mana_cost * 0.25 or not caster:HasModifier("modifier_true_form") then 
		caster:RemoveModifierByName("modifier_demon_core")
		ability:ToggleAbility()
		return
	end
	-- Reduce mana and process attribute stuffs
	caster:SpendMana(mana_cost * 0.25, ability)
	--caster:SetMana(caster:GetMana() - 25) 
	if caster.IsDemonIncarnateAcquired then 
		local cd_reduction = ability:GetSpecialValueFor("cd_reduction_per_sec")
		local trueform = caster:FindAbilityByName("avenger_true_form_upgrade")
		local trueformcd = trueform:GetCooldownTimeRemaining() 
		trueform:EndCooldown()
		trueform:StartCooldown(trueformcd - cd_reduction * 0.25)
	end
end

function OnVergAvestaDamageTrack (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("avenger_verg_avesta_upgrade")
	end
	local target = keys.target
	local attacker = keys.attacker
	local dmg_take = keys.DamageTaken
	local marker_duration = ability:GetSpecialValueFor("duration")
	if caster.IsAvengerAcquired then
		dmg_take = dmg_take * ability:GetSpecialValueFor("dmg_take") / 100
	end

	caster.verg_damage_taken = math.min(caster.verg_damage_taken + (dmg_take or 0) , caster:GetMaxHealth())

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_verg_damage_tracker_progress",{})

	if caster.verg_counter_fx then 
		ParticleManager:DestroyParticle(caster.verg_counter_fx, true)
		ParticleManager:ReleaseParticleIndex(caster.verg_counter_fx)
	end

	caster.verg_counter_fx = ParticleManager:CreateParticleForTeam( "particles/custom/vlad/vlad_cl_popup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster, caster:GetTeamNumber() )

	local digit = 0
	if caster.verg_damage_taken > 999 then
		digit = 4
	elseif caster.verg_damage_taken > 99 then
		digit = 3
	elseif caster.verg_damage_taken > 9 then
		digit = 2
	else
		digit = 1
		--if dmg_counter == 0 then
		--	dmg_counter = 5200 --hacky and clean way (i guess?) to draw 0 ONCE without making code spaghetti ---- dont use dmg_counter for anything else if this is enabled
		--end
	end

	ParticleManager:SetParticleControlEnt( caster.verg_counter_fx, 0, caster,  PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false )
	ParticleManager:SetParticleControl( caster.verg_counter_fx, 1, Vector( 0, caster.verg_damage_taken, 0 ) )  -- 0,counter,0
	ParticleManager:SetParticleControl( caster.verg_counter_fx, 2, Vector( 10, digit, 0 ) ) --duration, count of digits to draw, 0
	ParticleManager:SetParticleControl( caster.verg_counter_fx, 3, Vector( 252, 75, 75 ) )--color
	ParticleManager:SetParticleControl( caster.verg_counter_fx, 4, Vector( 30,0,0) ) --size/radius, 0 ,0

	ability:ApplyDataDrivenModifier(caster, attacker, "modifier_verg_marker", {})		

	if not attacker:IsRealHero() then
		local attacker2 = attacker:GetPlayerOwner():GetAssignedHero()
		if attacker2 == nil then 
			attacker2 = attacker:GetOwnerEntity()
		end

		if attacker2 == nil then 
			attacker2 = attacker:GetOwner()
		end
		
		if IsValidEntity(attacker2) and not attacker2:IsNull() then
			ability:ApplyDataDrivenModifier(caster, attacker2, "modifier_verg_marker", {})	
		end
	end

	caster:SetModifierStackCount("modifier_verg_damage_tracker", caster, math.min( caster.vergstack + (dmg_take / 10), caster:GetMaxHealth() / 10))
	caster:SetModifierStackCount("modifier_verg_damage_tracker_progress", caster, math.min(math.floor(caster.verg_damage_taken / 10), math.floor(caster:GetMaxHealth() / 10) ))

end

function OnVergAvestaReset (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("avenger_verg_avesta_upgrade")
	end

	caster.vergstack = caster:GetModifierStackCount("modifier_verg_damage_tracker", caster) or 0
	--caster:SetModifierStackCount("modifier_verg_damage_tracker", caster, math.min(caster.vergstack, caster:GetMaxHealth()) / 10)

	if caster:HasModifier("modifier_verg_damage_tracker_progress") then return end

	caster:SetModifierStackCount("modifier_verg_damage_tracker", caster, 0)
	caster.verg_damage_taken = 0
end

function OnVergNoTrack (keys)
	local caster = keys.caster 
	ParticleManager:DestroyParticle(caster.verg_counter_fx, true)
	ParticleManager:ReleaseParticleIndex(caster.verg_counter_fx)
	caster.verg_damage_taken = 0
	caster:SetModifierStackCount("modifier_verg_damage_tracker", caster, 0)
end

function OnVergAvestaStart (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local multiplier = ability:GetSpecialValueFor("multiplier") / 100
	local max_range = ability:GetSpecialValueFor("max_range")
	local damage = caster.verg_damage_taken * multiplier

	EmitGlobalSound("Avenger.Berg")
	EmitGlobalSound("Avenger.BergShout")

	local verg_particle = ParticleManager:CreateParticle("particles/custom/avenger/avenger_verg_avesta.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(verg_particle, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle( verg_particle, false )
		ParticleManager:ReleaseParticleIndex( verg_particle )
	end)
	
	local VergMarker = FindUnitsInRadius(caster:GetTeam(), Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_UNITS_EVERYWHERE, false)
	for k,targets in pairs(VergMarker) do
		if IsValidEntity(targets) and not targets:IsNull() and targets:IsAlive() and targets:HasModifier("modifier_verg_marker") and (caster:GetAbsOrigin() - targets:GetAbsOrigin()):Length2D() <= max_range and IsInSameRealm(caster:GetAbsOrigin(), targets:GetAbsOrigin()) then
			targets:RemoveModifierByName("modifier_verg_marker")
			if not targets:IsMagicImmune() and not IsInvulAbility(targets) then
				DoDamage(caster, targets, damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
			end
		end
	end

	caster:RemoveModifierByName("modifier_verg_damage_tracker_progress")
	caster:SetModifierStackCount("modifier_verg_damage_tracker", caster, 0)
	
	
end

function OnAvengerAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = keys.DamageDeal
	local bonus_human = ability:GetSpecialValueFor("bonus_damage_human") / 100

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsHuman(target) then
		DoDamage(caster, target, damage * bonus_human, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
end

function OnAvengerAttacked(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = keys.DamageTaken
	local damage_threshold = ability:GetSpecialValueFor("damage_threshold")
	local mana_regen = ability:GetSpecialValueFor("mana_regen")

	if damage >= damage_threshold then
		caster:GiveMana(mana_regen)
	end
end

function AvengerCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then 
		if string.match(ability:GetAbilityName(), "avenger_true_form") then
			caster.EUsed = true
			caster.ETime = GameRules:GetGameTime()
			if caster.ETimer ~= nil then 
				Timers:RemoveTimer(caster.ETimer)
				caster.ETimer = nil
			end
			caster.ETimer = Timers:CreateTimer(4.0, function()
				caster.EUsed = false
			end)
		else
			if string.match(ability:GetAbilityName(), "avenger_unlimited_remains") then
				caster.EUsed = caster.EUsed or false 
				if caster.EUsed == true and not caster:HasModifier("modifier_4_days_loop_cooldown") then 
					local newTime =  GameRules:GetGameTime()
					local duration = 4 - (newTime - caster.ETime)

					if caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then
						if caster:FindAbilityByName("avenger_verg_avesta_upgrade"):IsCooldownReady() and caster:FindAbilityByName("avenger_combo_endless_loop_upgrade"):IsCooldownReady() then
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_loop_window", {Duration = duration})
						end
					elseif caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then
						if caster:FindAbilityByName("avenger_verg_avesta_upgrade"):IsCooldownReady() and caster:FindAbilityByName("avenger_combo_endless_loop"):IsCooldownReady() then
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_loop_window", {Duration = duration})
						end
					elseif not caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then
						if caster:FindAbilityByName("avenger_verg_avesta"):IsCooldownReady() and caster:FindAbilityByName("avenger_combo_endless_loop_upgrade"):IsCooldownReady() then
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_loop_window", {Duration = duration})
						end
					elseif not caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then
						if caster:FindAbilityByName("avenger_verg_avesta"):IsCooldownReady() and caster:FindAbilityByName("avenger_combo_endless_loop"):IsCooldownReady() then
							ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_loop_window", {Duration = duration})
						end
					end
				end
			end
		end
	end
end 

function OnEndlessLoopWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta_upgrade", "avenger_combo_endless_loop_upgrade", false, true)
	elseif caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta_upgrade", "avenger_combo_endless_loop", false, true)
	elseif not caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta", "avenger_combo_endless_loop_upgrade", false, true)
	elseif not caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta", "avenger_combo_endless_loop", false, true)
	end
end

function OnEndlessLoopWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta_upgrade", "avenger_combo_endless_loop_upgrade", true, false)
	elseif caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta_upgrade", "avenger_combo_endless_loop", true, false)
	elseif not caster.IsAvengerAcquired and caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta", "avenger_combo_endless_loop_upgrade", true, false)
	elseif not caster.IsAvengerAcquired and not caster.IsAtTheEndOfFourNightsAcquired then 
		caster:SwapAbilities("avenger_verg_avesta", "avenger_combo_endless_loop", true, false)
	end
end

function OnEndlessLoopWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_endless_loop_window")
end

function On4DaysLoopStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local revive_stack = ability:GetSpecialValueFor("revive_stock")
	local duration = ability:GetSpecialValueFor("duration")

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("avenger_combo_endless_loop")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_4_days_loop_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	EmitGlobalSound("Avenger.Darkness")
	EmitGlobalSound("Avenger.Berg")

	caster.DeathInLoop = true 
	Timers:CreateTimer(duration, function()
		caster.DeathInLoop = false 
	end)
	caster.LoopStocks = revive_stack
	caster.CurrentHp = caster:GetHealth()
	caster.CurrentMana = caster:GetMana()
	caster.Combo_origin = caster:GetAbsOrigin()

	caster.dummy_revive = CreateUnitByName("godhand_res_locator", caster.Combo_origin, false, caster, caster, caster:GetTeamNumber())
	caster.dummy_revive:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	caster.dummy_revive:AddNewModifier(caster, nil, "modifier_phased", {Duration=duration + 0.5})
	caster.dummy_revive:AddNewModifier(caster, nil, "modifier_kill", {Duration=duration + 0.5})

	caster:RemoveModifierByName("modifier_endless_loop_window")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_4_days_loop", {})
	caster:SetModifierStackCount("modifier_4_days_loop", caster, revive_stack)
end

function On4DaysLoopThink (keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if not caster:IsAlive() then return end

	ResetAbilities(caster)
	ResetItems(caster)
	caster:SetHealth(caster.CurrentHp)
	caster:SetMana(caster.CurrentMana)
	caster:EmitSound("Avenger.Consume")
	if caster.IsAtTheEndOfFourNightsAcquired then
		local current_stock = caster:GetModifierStackCount("modifier_4_days_loop", caster)
		caster:SetModifierStackCount("modifier_4_days_loop", caster, current_stock - 1)
		caster.LoopStocks = caster.LoopStocks - 1
		if caster.LoopStocks <= 0 then
			caster:RemoveModifierByName("modifier_4_days_loop")
		end
	end
end

--dead while in loop
function On4DaysLoopDead (keys)
	local caster = keys.caster
	local ability = keys.ability
	local start_hp = caster.CurrentHp
	local start_mana = caster.CurrentMana


	Timers:CreateTimer(0.5, function()
		if IsTeamWiped(caster) == false and not IsReviveSeal(caster) and caster.LoopStocks > 0 and caster:HasModifier("modifier_4_days_loop") and _G.CurrentGameState == "FATE_ROUND_ONGOING" then
			print('revive ?')
			if not caster:HasModifier("modifier_4_days_loop") then return end
			caster:SetRespawnPosition(caster.dummy_revive:GetAbsOrigin())
			caster:RespawnHero(false,false)
			caster:SetHealth(caster.CurrentHp)
			caster:SetMana(caster.CurrentMana)
			ResetAbilities(caster)
			ResetItems(caster)
			caster:EmitSound("Avenger.Consume")
			caster.LoopStocks = caster.LoopStocks - 1
			if caster.IsAtTheEndOfFourNightsAcquired then
				local current_stock = caster:GetModifierStackCount("modifier_4_days_loop", caster)

				caster:SetModifierStackCount("modifier_4_days_loop", caster, current_stock - 1)
				if caster.LoopStocks <= 0 then
					caster:RemoveModifierByName("modifier_4_days_loop")
				end
			else
				caster:RemoveModifierByName("modifier_4_days_loop")
			end
			caster.DeathInLoop = true
		else
			caster:SetRespawnPosition(caster.RespawnPos)
			caster.DeathInLoop = false
		end
		if IsValidEntity(dummy) then
			dummy:RemoveSelf()
		end
	end)
end

function OnDarkPassageAcquired (keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDarkPassageAcquired) then

		hero.IsDarkPassageAcquired = true

		UpgradeAttribute(hero, 'avenger_dark_passage', 'avenger_dark_passage_upgrade', true)
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDemonIncarnateAcquired (keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDemonIncarnateAcquired) then

		hero.IsDemonIncarnateAcquired = true

		if hero:HasModifier("modifier_true_form") then 
			UpgradeAttribute(hero, 'avenger_demon_core', 'avenger_demon_core_upgrade', true)
			UpgradeAttribute(hero, 'avenger_true_form', 'avenger_true_form_upgrade', false)			
		else
			UpgradeAttribute(hero, 'avenger_demon_core', 'avenger_demon_core_upgrade', false)
			UpgradeAttribute(hero, 'avenger_true_form', 'avenger_true_form_upgrade', true)			
		end

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnWorldEvilAcquired (keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWorldEvilAcquired) then

		hero.IsWorldEvilAcquired = true

		if hero:HasModifier("modifier_true_form") then 
			UpgradeAttribute(hero, 'avenger_vengeance_mark', 'avenger_vengeance_mark_upgrade', true)
			UpgradeAttribute(hero, 'avenger_unlimited_remains', 'avenger_unlimited_remains_upgrade', true)
		else
			UpgradeAttribute(hero, 'avenger_vengeance_mark', 'avenger_vengeance_mark_upgrade', false)
			UpgradeAttribute(hero, 'avenger_unlimited_remains', 'avenger_unlimited_remains_upgrade', false)
		end
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAvengerAcquired (keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAvengerAcquired) then

		if hero:HasModifier("modifier_endless_loop_window") then 
			hero:RemoveModifierByName("modifier_endless_loop_window")
		end

		hero.IsAvengerAcquired = true

		UpgradeAttribute(hero, 'avenger_verg_avesta', 'avenger_verg_avesta_upgrade', true)

		hero:FindAbilityByName("avenger_avenger"):SetLevel(1)
		hero:SwapAbilities("fate_empty1", "avenger_avenger", false, true)

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAtTheEndOfFourNightsAcquired (keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAtTheEndOfFourNightsAcquired) then

		if hero:HasModifier("modifier_endless_loop_window") then 
			hero:RemoveModifierByName("modifier_endless_loop_window")
		end

		hero.IsAtTheEndOfFourNightsAcquired = true

		UpgradeAttribute(hero, 'avenger_combo_endless_loop', 'avenger_combo_endless_loop_upgrade', false)
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end