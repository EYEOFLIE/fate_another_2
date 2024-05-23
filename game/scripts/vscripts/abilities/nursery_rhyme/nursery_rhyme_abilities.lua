
function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("duration")
	local income_dmg = ability:GetSpecialValueFor("income_dmg")
	
	local illusion = CreateIllusions( caster, caster, {duration = duration, outgoing_damage = 0, incoming_damage = income_dmg}, 1, 0, true, true )
	caster.ShapeShiftIllusion = illusion[1]
	if caster:HasModifier("modifier_alternate_01") then 
		caster.ShapeShiftIllusion:SetModel("models/nursery_rhyme/alice/nr_alice_by_zefiroft.vmdl")
		caster.ShapeShiftIllusion:SetOriginalModel("models/nursery_rhyme/alice/nr_alice_by_zefiroft.vmdl")
		caster.ShapeShiftIllusion:SetModelScale(1.05)	
	end
	ability:ApplyDataDrivenModifier(caster, caster.ShapeShiftIllusion, "modifier_nursery_rhyme_shapeshift_clone", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_nursery_rhyme_shapeshift_window", {})
	FindClearSpaceForUnit(illusion[1], caster:GetAbsOrigin(), true)
	caster.ShapeShiftDest = targetPoint
	caster.bIsSwapUsed = false 

	Attributes:ModifyBonuses(caster.ShapeShiftIllusion)
	caster.ShapeShiftIllusion:SetHealth(caster:GetHealth())
	-- Only GetMaxMana but no SetMaxMana wth valve
	caster.ShapeShiftIllusion:SetMana(caster:GetMana())

	local move = {
		UnitIndex = caster.ShapeShiftIllusion:entindex(), 
 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
 		Position = targetPoint, 
	}
	Timers:CreateTimer(0.1, function()
		ExecuteOrderFromTable(move)
	end)

	local itemModifiers = {
		"modifier_b_scroll",
		"modifier_a_scroll",
		"modifier_healing_scroll",
		"modifier_speed_gem",
		"modifier_berserk_scroll",
		"item_pot_regen"
	}

	for i = 1, #itemModifiers do
		if caster:HasModifier(itemModifiers[i]) then
			ability:ApplyDataDrivenModifier(caster, caster.ShapeShiftIllusion, itemModifiers[i], {duration = caster:FindModifierByName(itemModifiers[i]):GetRemainingTime()})		
		end
	end

	local cloneFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx, 0, caster:GetAbsOrigin())
	Timers:CreateTimer( 0.7, function()
		ParticleManager:DestroyParticle( cloneFx, false )
		ParticleManager:ReleaseParticleIndex( cloneFx )
	end)
	caster:EmitSound("Hero_Terrorblade.ConjureImage")
end

function OnShapeShiftEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	caster:RemoveModifierByName("modifier_phased")
    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Terrorblade.Metamorphosis", target)
	local cloneKillFx = ParticleManager:CreateParticle( "particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( cloneKillFx, 0, target:GetAbsOrigin()+Vector(0,0,100) )
	local explosionFx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 2, target:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_nursery_rhyme_shapeshift_window")
end

function OnShapeShiftWindowCreate(keys)
	local caster = keys.caster
	if caster.bIsFTAcquired then 
		caster:SwapAbilities("nursery_rhyme_shapeshift_upgrade", "nursery_rhyme_shapeshift_swap", false, true)
	else
		caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", false, true)
	end
end

function OnShapeShiftWindowDestroy(keys)
	local caster = keys.caster
	if caster.bIsFTAcquired then 
		caster:SwapAbilities("nursery_rhyme_shapeshift_upgrade", "nursery_rhyme_shapeshift_swap", true, false)
	else
		caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", true, false)
	end
end

function OnShapeShiftWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_nursery_rhyme_shapeshift_window")
end

function OnShapeShiftSwap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()
	caster:RemoveModifierByName("modifier_nursery_rhyme_shapeshift_window")
	if caster.bIsSwapUsed then return end

	caster:SetAbsOrigin(caster.ShapeShiftIllusion:GetAbsOrigin())
	caster.ShapeShiftIllusion:SetAbsOrigin(casterPos)
	caster.bIsSwapUsed = true
	local move = {
		UnitIndex = caster.ShapeShiftIllusion:entindex(), 
 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
 		Position = caster.ShapeShiftDest, 
	}

	ExecuteOrderFromTable(move)

	--caster.ShapeShiftIllusion:Hold()
end

function OnNamelessStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")

	if IsSpellBlocked(target) or target:IsMagicImmune() then 
		return 
	end -- Linken effect checker

	caster.NamelessTarget = target
	ApplyPurge(target)
	giveUnitDataDrivenModifier(caster, target, "revoked", duration)
	if caster:GetTeam() == target:GetTeam() then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest_ally", {})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest", {})
	end

	if caster.bIsReminiscenceAcquired then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_nursery_rhyme_nameless_window", {})
	end
end

function OnNamelessDebuffStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:AddEffects(EF_NODRAW)
	target:EmitSound("Hero_Winter_Wyvern.ColdEmbrace")
end

function OnNamelessEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveEffects(EF_NODRAW)
	target:StopSound("Hero_Winter_Wyvern.ColdEmbrace")
	target:RemoveModifierByName("revoked")
	if caster.bIsReminiscenceAcquired then
		caster:RemoveModifierByName("modifier_nursery_rhyme_nameless_window")
		if caster:GetTeam() == target:GetTeam() then 
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_nameless_forest_stat_steal_buff", {})
			ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest_stat_steal_debuff", {})
		end
	end
end

function OnNamelessForestWindowCreate(keys)
	local caster = keys.caster
	caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_reminiscence", false, true)
end

function OnNamelessForestWindowDestroy(keys)
	local caster = keys.caster
	caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_reminiscence", true, false)
end

function OnNamelessForestWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_nursery_rhyme_nameless_window")
end

function OnReminiscenceStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetTeam() == caster.NamelessTarget:GetTeam() then 
		if caster.NamelessTarget:HasModifier("modifier_nameless_forest_ally") then 
			caster.NamelessTarget:RemoveModifierByName("modifier_nameless_forest_ally")
		end
	else
		caster.NamelessTarget:RemoveModifierByName("modifier_nameless_forest")
	end
end

function OnEnigmaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local width = ability:GetSpecialValueFor("width")
	local length = ability:GetSpecialValueFor("length")
	local speed = ability:GetSpecialValueFor("speed")

	local enigmaProjectile = 
	{
		Ability = ability,
        EffectName = "particles/units/heroes/hero_tusk/tusk_ice_shards_projectile.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = length,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = true,
		vVelocity = caster:GetForwardVector() * speed,
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = 300
	}	

	local projectile = ProjectileManager:CreateLinearProjectile(enigmaProjectile)
	caster:EmitSound("Hero_Tusk.IceShards.Projectile")
	--caster:EmitSound("Hero_Tusk.IceShards.Cast")
	Timers:CreateTimer(1.0, function()
		caster:StopSound("Hero_Tusk.IceShards.Projectile")
	end)
end

function OnEnigmaHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local BaseStunDuration = ability:GetSpecialValueFor("stun_duration")
	if not IsImmuneToCC(target) then
		giveUnitDataDrivenModifier(caster, target, "locked", ability:GetSpecialValueFor("lock_duration"))
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = BaseStunDuration})
	end
	if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_white_queens_enigma_slow", {})
	end
	--giveUnitDataDrivenModifier(caster, target, "rooted", ability:GetSpecialValueFor("root_duration"))

	--ability:ApplyDataDrivenModifier(caster, target, "modifier_white_queens_enigma_dot", {})
	SpawnAttachedVisionDummy(caster, target, 300, 2, false)

	local iceFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff_model.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( iceFx, 0, target:GetAbsOrigin() + Vector(0,0,100) )
	target:EmitSound("Hero_Tusk.IceShards")

	DoDamage(caster, target, ability:GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL, 0, ability, false)

	Timers:CreateTimer(BaseStunDuration, function()
		ParticleManager:DestroyParticle( iceFx, false )
		ParticleManager:ReleaseParticleIndex( iceFx )
		return nil
	end)
	
end

function OnPlainsUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	local master_unit = caster.MasterUnit2

	if not master_unit then return end

	local attr = master_unit:FindAbilityByName("nursery_rhyme_attribute_nightmare")

	attr:SetLevel(ability:GetLevel())
end

function OnPlainStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local bounceCount = ability:GetSpecialValueFor("max_bounce")

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	ChainLightning(keys, caster, nil, target, nil, bounceCount, nil, true)
end

--[[ AIterative function that shoots chain lightning to eligible target until bounce > count ]]
function ChainLightning(keys, source, slocation, target, tlocation, count, CC, bIsFirstItrn)
	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("nursery_rhyme_the_plains_of_water_upgrade")
	end
	local bounceCount = ability:GetSpecialValueFor("max_bounce")
	local reduction_constant = ability:GetSpecialValueFor("dmg_reduction")
	local reduction = ((100-reduction_constant)/100) ^ (bounceCount - count)
	local damage = ability:GetSpecialValueFor("damage")
	local bounce_range = 550
	
	if not CC then CC = {} end -- temporal storage for list of CCs to be applied by W	

	if count <= 0 then return end

	if not bIsFirstItrn then
		damage = damage * reduction
	end

	if target ~= nil then
		if IsSpellBlocked(target) then return end

		tlocation = target:GetAbsOrigin()

		target:EmitSound("Hero_Winter_Wyvern.SplinterBlast.Target")

		if caster.bIsNightmareAcquired then 
			local bonus_int = ability:GetSpecialValueFor("bonus_int")
			damage = damage + (bonus_int * caster:GetIntellect())
			if not IsImmuneToSlow(target) then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_plains_of_water_slow", {})
			end
		end
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	else
		EmitSoundOnLocationWithCaster(tlocation, "Hero_Winter_Wyvern.SplinterBlast.Target", caster)
		bounce_range = 200 
	end	

	if source ~= nil then
		slocation = source:GetAbsOrigin()
	end

	local lightningFx = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/plains_of_water.vpcf", PATTACH_CUSTOMORIGIN, nil )

	ParticleManager:SetParticleControl(lightningFx, 0, slocation + Vector( 0, 0, 96 ))
	ParticleManager:SetParticleControl(lightningFx, 1, tlocation + Vector( 0, 0, 96 ))

	Timers:CreateTimer(0.4, function()
		if target ~= nil and IsValidEntity(target) and not target:IsNull() then
			tlocation = target:GetAbsOrigin()
		end

		local targets = FindUnitsInRadius(caster:GetTeam(), tlocation, nil, bounce_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
			
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v ~= target and not v:IsMagicImmune() then 
				ChainLightning(keys, target, tlocation, v, v:GetAbsOrigin(), count-1, CC, false)
				return
			end
		end

		local new_bounce = RandomPointInCircle(tlocation, bounce_range)
		ChainLightning(keys, target, tlocation, nil, new_bounce, count-1, CC, false)
		
		return
	end)
end

function OnCloneStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = keys.Duration
	local cloneHealth = target:GetMaxHealth() * keys.Health/100 

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	-- check for existing clone 
	if caster.bCloneExists then
		if IsValidEntity(caster.CurrentDoppelganger) and not caster.CurrentDoppelganger:IsNull() then
			caster.CurrentDoppelganger:ForceKill(false)
		end 
	end
	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local illusionSpawnLoc = Vector(0,0,0)
	
	if dist > 300 then 
		illusionSpawnLoc = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * 150
	else
		illusionSpawnLoc = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * dist/2
	end
	local illusion = CreateUnitByName("pseudo_illusion", illusionSpawnLoc, true, target, nil, target:GetTeamNumber()) 
	illusion:SetModel(target:GetModelName())
	illusion:SetOriginalModel(target:GetModelName())
	illusion:SetModelScale(target:GetModelScale())
	--illusion:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
	StartAnimation(illusion, {duration=duration, activity=ACT_DOTA_IDLE, rate=1})
	--illusion:SetPlayerID(target:GetPlayerID()) 
	--illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = 0, incoming_damage = 0 })
	--illusion:MakeIllusion()
	illusion:SetBaseMagicalResistanceValue(0)
	-- god why do i have to always wait 1 damn frame
	Timers:CreateTimer(0.033, function()
		illusion:SetBaseMaxHealth(cloneHealth)
		illusion:SetMaxHealth(cloneHealth)
		illusion:ModifyHealth(cloneHealth, nil, false, 0)
	end)
	Timers:CreateTimer(duration, function()
		if IsValidEntity(illusion) and not illusion:IsNull() then 
			illusion:ForceKill(false)
			illusion:AddEffects(EF_NODRAW)
			--illusion:SetAbsOrigin(Vector(10000,10000,0))
		end
	end)

	caster.CurrentDoppelganger = illusion
	caster.CurrentDoppelgangerOriginal = target
	caster.bCloneExists = true
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_doppelganger", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_doppelganger_enemy", {})
	giveUnitDataDrivenModifier(caster, illusion, "pause_sealdisabled", duration)

	target:EmitSound("Hero_Terrorblade.Sunder.Target")
	local cloneFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx, 0, target:GetAbsOrigin())
	local cloneFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx2, 0, illusion:GetAbsOrigin())
	Timers:CreateTimer( 0.7, function()
		ParticleManager:DestroyParticle( cloneFx, false )
		ParticleManager:ReleaseParticleIndex( cloneFx )
		ParticleManager:DestroyParticle( cloneFx2, false )
		ParticleManager:ReleaseParticleIndex( cloneFx2 )
	end)
end

function OnCloneTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageTaken = keys.DamageTaken
	local damageShared = keys.SharedDamage

	DoDamage(caster, caster.CurrentDoppelgangerOriginal, damageTaken*damageShared/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

--[[
slow applier when attribute is acquired
]]
function OnCloneThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.bIsFTAcquired then
		local int_ratio = ability:GetSpecialValueFor("int_ratio")
		if not IsFacingUnit(caster.CurrentDoppelgangerOriginal, caster.CurrentDoppelganger, 180) then
			ability:ApplyDataDrivenModifier(caster, caster.CurrentDoppelgangerOriginal, "modifier_doppelganger_lookaway_slow", {})
			DoDamage(caster, caster.CurrentDoppelgangerOriginal, caster:GetIntellect() * int_ratio , DAMAGE_TYPE_MAGICAL, 0, ability, false)
			
		end
	end
end

function OnCloneOriginalTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageTaken = keys.DamageTaken

	if caster.CurrentDoppelgangerOriginal.bIsInvulDuetoDoppel then
		caster.CurrentDoppelgangerOriginal:SetHealth(1)
		caster.CurrentDoppelgangerOriginal.bIsInvulDuetoDoppel = false

		caster.CurrentDoppelganger:ForceKill(false)
	end
end

function OnCloneDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local cloneKillFx = ParticleManager:CreateParticle( "particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( cloneKillFx, 0, caster.CurrentDoppelganger:GetAbsOrigin()+Vector(0,0,100) )

	caster.CurrentDoppelganger:AddEffects(EF_NODRAW)
	--illusion:SetModel("models/development/invisiblebox.vmdl")
	--illusion:SetOriginalModel("models/development/invisiblebox.vmdl")

	--caster.CurrentDoppelganger:SetHealth(1)
	--caster.CurrentDoppelganger:SetAbsOrigin(Vector(10000,10000,0))
	caster.CurrentDoppelgangerOriginal:RemoveModifierByName("modifier_doppelganger_enemy")
	caster.CurrentDoppelganger:ForceKill(false)
	caster.CurrentDoppelgangerOriginal = nil
	caster.bCloneExists = false
end

function OnCloneOriginalDeath(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.CurrentDoppelganger:ForceKill(false)
end

function OnQueensGlassGameStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")

	caster.GlassGameOrigin = caster:GetAbsOrigin()	
	caster.GlassGameAura = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.GlassGameAura:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.GlassGameAura:SetDayTimeVisionRange(25)
	caster.GlassGameAura:SetNightTimeVisionRange(25)

	caster.GlassGameAura:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
	ability:ApplyDataDrivenModifier(caster, caster.GlassGameAura, "modifier_nr_queens_glass_game_aura", {})

	local hAbility1 = caster:GetAbilityByIndex(0)
	local hAbility2 = caster:GetAbilityByIndex(1)
	local hAbility3 = caster:GetAbilityByIndex(2)

	caster.HealthOnActivate = caster:GetHealth()
	caster.ManaOnActivate = caster:GetMana()
	caster.QCooldown = hAbility1:GetCooldownTimeRemaining()
	caster.WCooldown = hAbility2:GetCooldownTimeRemaining()
	caster.ECooldown = hAbility3:GetCooldownTimeRemaining()

	EmitGlobalSound("NR.Chronosphere")
	EmitGlobalSound("NR.GlassGame.Begin")

	NRCheckCombo(caster, ability)

end

function OnQueensGlassGameActivate(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	local hAbility1 = caster:GetAbilityByIndex(0)
	local hAbility2 = caster:GetAbilityByIndex(1)
	local hAbility3 = caster:GetAbilityByIndex(2)

	hAbility1:EndCooldown()
	hAbility2:EndCooldown()
	hAbility3:EndCooldown()

	caster:SetHealth(caster.HealthOnActivate)
	caster:SetMana(caster.ManaOnActivate)

	if caster.bIsQGGImproved then
		for i=0, 5 do
			local hItem = caster:GetItemInSlot(i)
			if hItem ~= nil then
				hItem:EndCooldown()
			end
		end
	else		
		hAbility1:StartCooldown(caster.QCooldown)
		hAbility2:StartCooldown(caster.WCooldown)
		hAbility3:StartCooldown(caster.ECooldown)
	end

	caster:EmitSound("Hero_Weaver.TimeLapse")
	local iParticleIndex = ParticleManager:CreateParticle("particles/custom/nursery_rhyme/nursery_timelapse.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(iParticleIndex, 0, caster.GlassGameOrigin)
	ParticleManager:SetParticleControl(iParticleIndex, 2, caster:GetAbsOrigin())

	Timers:CreateTimer(1.5, function()
		ParticleManager:DestroyParticle(iParticleIndex, false)
		ParticleManager:ReleaseParticleIndex(iParticleIndex)
		return
	end)

	caster:SetAbsOrigin(caster.GlassGameOrigin)
end

function OnQueensGlassGameCreate(keys)
	local ability = keys.ability 
	local caster = keys.caster 
	local radius = ability:GetSpecialValueFor("radius")

	caster.iParticleIndex1 = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/queens_glass_game/queens_glass_game_aoe.vpcf", PATTACH_CUSTOMORIGIN, caster);
	ParticleManager:SetParticleControl(caster.iParticleIndex1, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(caster.iParticleIndex1, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(caster.iParticleIndex1, 3, Vector(radius, radius, radius))
	caster.iParticleIndex2 = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/queens_glass_game/queens_glass_game_bookswirl.vpcf", PATTACH_CUSTOMORIGIN, caster);
	ParticleManager:SetParticleControl(caster.iParticleIndex2, 1, caster:GetOrigin())
	ParticleManager:SetParticleControl(caster.iParticleIndex2, 3, Vector(1,1,1))
end

function OnQueensGlassGameDestroy(keys)
	local ability = keys.ability 
	local caster = keys.caster 
	ParticleManager:DestroyParticle(caster.iParticleIndex1, false)
	ParticleManager:ReleaseParticleIndex(caster.iParticleIndex1)
	ParticleManager:DestroyParticle(caster.iParticleIndex2, false)
	ParticleManager:ReleaseParticleIndex(caster.iParticleIndex2)
end

function OnQueensGlassGameWindowCreate(keys)
	local ability = keys.ability 
	local caster = keys.caster 
	local target = keys.target 
	print(target:GetName())
	if target == caster and target:GetName() == "npc_dota_hero_windrunner" then 
		if caster.bIsQGGImproved then
			target:SwapAbilities("nursery_rhyme_queens_glass_game_upgrade", "nursery_rhyme_queens_glass_game_activate", false, true)
		else
			target:SwapAbilities("nursery_rhyme_queens_glass_game", "nursery_rhyme_queens_glass_game_activate", false, true)
		end
		target:EmitSound("NR.Tick")
	end
end

function OnQueensGlassGameWindowDestroy(keys)
	local ability = keys.ability 
	local caster = keys.caster 
	local target = keys.target 
	if target == caster and target:GetName() == "npc_dota_hero_windrunner" then 
		if caster.bIsQGGImproved then
			target:SwapAbilities("nursery_rhyme_queens_glass_game_upgrade", "nursery_rhyme_queens_glass_game_activate", true, false)
		else
			target:SwapAbilities("nursery_rhyme_queens_glass_game", "nursery_rhyme_queens_glass_game_activate", true, false)
		end
		target:StopSound("NR.Tick")
	end
	if IsValidEntity(caster.GlassGameAura) then 
		caster.GlassGameAura:RemoveModifierByName("modifier_nr_queens_glass_game_aura")	
		caster.GlassGameAura:RemoveSelf()
	end
end

function OnQueenGlassGameDeath(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if IsValidEntity(caster.GlassGameAura) then 
		caster.GlassGameAura:RemoveModifierByName("modifier_nr_queens_glass_game_aura")
		caster.GlassGameAura:RemoveSelf()
	end
end

--[[
Round finish mechanics 
]]
function OnNRComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability	
	local cooldown = keys.ability:GetCooldown(1)
	local delay = ability:GetSpecialValueFor("time_limit")
	
	if GameRules:GetGameTime() > 60 + _G.RoundStartTime then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return 
	end

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_someones_sake_cooldown", {duration = ability:GetCooldown(1)})
	
	caster.bIsNRComboSuccessful = false
	caster.nNRComboQuoteCount = 1

	-- apply timer modifier for caster and all enemy heroes
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_someones_sake", {})
    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero ~= caster then
    		ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_story_for_someones_sake_enemy", {})
    	end
    end)

    GameRules:SendCustomMessage("#story_for_somebodys_sake_1", 0, 0)

    EmitGlobalSound("NR.GlobalPing")
    caster:EmitSound("NR.Tick")

    Timers:CreateTimer(delay, function()
        if caster.bIsNRComboSuccessful and caster:IsAlive() then
            GameRules.AddonTemplate:FinishRound(false, 2)
        end
    end)
end

function PingLocationForEnemies(keys)
	local caster = keys.caster
	local ability = keys.ability

	--[[if _G.LaPucelleActivated == true then
	end]]
	if caster.nNRComboQuoteCount == 3 then
		GameRules:SendCustomMessage("#story_for_somebodys_sake_2", 0, 0)
		--EmitGlobalSound("Hero_Wisp.Tether.Stop")
		EmitGlobalSound("Nursery_Rhyme_Combo_1")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	elseif caster.nNRComboQuoteCount == 4 then
		GameRules:SendCustomMessage("#story_for_somebodys_sake_3", 0, 0)
		--EmitGlobalSound("Hero_Wisp.Tether.Stop")
		EmitGlobalSound("Nursery_Rhyme_Combo_2")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	elseif caster.nNRComboQuoteCount == 5 then
		GameRules:SendCustomMessage("#story_for_somebodys_sake_4", 0, 0)
		--EmitGlobalSound("Hero_Wisp.Tether.Stop")
		EmitGlobalSound("Nursery_Rhyme_Combo_3")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	end
	caster.nNRComboQuoteCount = caster.nNRComboQuoteCount+1

    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
    		MinimapEvent( playerHero:GetTeamNumber(), playerHero, caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 2 )
    	end
    end)	
end

function OnNRComboEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:StopSound("NR.Tick")
	if caster:IsAlive() and ServerTables:GetTableValue("GameState", "state") == "FATE_ROUND_ONGOING" then 
		caster.bIsNRComboSuccessful = true 
		GameRules:SendCustomMessage("#story_for_somebodys_sake_5", 0, 0)
		EmitGlobalSound("Hero_Wisp.Tether.Stun")
		EmitGlobalSound("Nursery_Rhyme_Combo_4")

		local RedScreenFx = ParticleManager:CreateParticle("particles/custom/screen_red_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	end
end

function OnNRComboDeath(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:StopSound("NR.Tick")

    --[[LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero ~= caster then
    		playerHero:RemoveModifierByName("modifier_story_for_someones_sake_enemy")
    	end
    end)]]
	EmitGlobalSound("Hero_Wisp.Tether.Stun")
    GameRules:SendCustomMessage("<font color='#58ACFA'>The fabric of time has become normal again.</font>", 0, 0)
end

function NRCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.bIsQGGImproved then
			if caster.bIsReminiscenceAcquired then
				if ability == caster:FindAbilityByName("nursery_rhyme_queens_glass_game_upgrade") and caster:FindAbilityByName("nursery_rhyme_nameless_forest_upgrade"):IsCooldownReady() and caster:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake_upgrade"):IsCooldownReady() and (GameRules:GetGameTime() < 60 + _G.RoundStartTime) then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_somebodys_sake_window", {})
				end
			else
				if ability == caster:FindAbilityByName("nursery_rhyme_queens_glass_game_upgrade") and caster:FindAbilityByName("nursery_rhyme_nameless_forest"):IsCooldownReady() and caster:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake_upgrade"):IsCooldownReady() and (GameRules:GetGameTime() < 60 + _G.RoundStartTime) then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_somebodys_sake_window", {})
				end
			end
		else
			if caster.bIsReminiscenceAcquired then
				if ability == caster:FindAbilityByName("nursery_rhyme_queens_glass_game") and caster:FindAbilityByName("nursery_rhyme_nameless_forest_upgrade"):IsCooldownReady() and caster:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake"):IsCooldownReady() and (GameRules:GetGameTime() < 60 + _G.RoundStartTime) then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_somebodys_sake_window", {})
				end
			else
				if ability == caster:FindAbilityByName("nursery_rhyme_queens_glass_game") and caster:FindAbilityByName("nursery_rhyme_nameless_forest"):IsCooldownReady() and caster:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake"):IsCooldownReady() and (GameRules:GetGameTime() < 60 + _G.RoundStartTime) then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_somebodys_sake_window", {})
				end
			end
		end
	end
end

function OnStoryForSomebodysWindowCreate(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_nursery_rhyme_nameless_window")
	if caster.bIsReminiscenceAcquired and caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_story_for_somebodys_sake_upgrade", false, true)
	elseif not caster.bIsReminiscenceAcquired and caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_story_for_somebodys_sake_upgrade", false, true)
	elseif caster.bIsReminiscenceAcquired and not caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_story_for_somebodys_sake", false, true)
	elseif not caster.bIsReminiscenceAcquired and not caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_story_for_somebodys_sake", false, true)
	end
end

function OnStoryForSomebodysWindowDestroy(keys)
	local caster = keys.caster 
	if caster.bIsReminiscenceAcquired and caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_story_for_somebodys_sake_upgrade", true, false)
	elseif not caster.bIsReminiscenceAcquired and caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_story_for_somebodys_sake_upgrade", true, false)
	elseif caster.bIsReminiscenceAcquired and not caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_story_for_somebodys_sake", true, false)
	elseif not caster.bIsReminiscenceAcquired and not caster.bIsQGGImproved then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_story_for_somebodys_sake", true, false)
	end
end

function OnStoryForSomebodysWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_story_for_somebodys_sake_window")
end

function OnFTAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsFTAcquired) then

		hero.bIsFTAcquired = true

		hero:AddAbility("nursery_rhyme_shapeshift_upgrade")
		hero:FindAbilityByName("nursery_rhyme_shapeshift_upgrade"):SetLevel(1)
		hero:SwapAbilities("nursery_rhyme_shapeshift_upgrade", "nursery_rhyme_shapeshift", true, false) 
		if not hero:FindAbilityByName("nursery_rhyme_shapeshift"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_shapeshift_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_shapeshift"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_shapeshift")

		hero:AddAbility("nursery_rhyme_doppelganger_upgrade")
		hero:FindAbilityByName("nursery_rhyme_doppelganger_upgrade"):SetLevel(hero:FindAbilityByName("nursery_rhyme_doppelganger"):GetLevel())
		hero:SwapAbilities("nursery_rhyme_doppelganger_upgrade", "nursery_rhyme_doppelganger", true, false) 
		if not hero:FindAbilityByName("nursery_rhyme_doppelganger"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_doppelganger_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_doppelganger"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_doppelganger")
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnNightmareAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsNightmareAcquired) then
	
		hero.bIsNightmareAcquired = true

		hero:AddAbility("nursery_rhyme_the_plains_of_water_upgrade")
		hero:FindAbilityByName("nursery_rhyme_the_plains_of_water_upgrade"):SetLevel(hero:FindAbilityByName("nursery_rhyme_the_plains_of_water"):GetLevel())
		hero:SwapAbilities("nursery_rhyme_the_plains_of_water_upgrade", "nursery_rhyme_the_plains_of_water", true, false) 
		if not hero:FindAbilityByName("nursery_rhyme_the_plains_of_water"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_the_plains_of_water_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_the_plains_of_water"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_the_plains_of_water")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnReminiscenceAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsReminiscenceAcquired) then

		hero.bIsReminiscenceAcquired = true

		hero:AddAbility("nursery_rhyme_nameless_forest_upgrade")
		hero:FindAbilityByName("nursery_rhyme_nameless_forest_upgrade"):SetLevel(1)
		hero:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_nameless_forest", true, false) 
		if not hero:FindAbilityByName("nursery_rhyme_nameless_forest"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_nameless_forest_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_nameless_forest"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_nameless_forest")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveQGGAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsQGGImproved) then

		if hero:HasModifier("modifier_story_for_somebodys_sake_window") then 
			hero:RemoveModifierByName("modifier_story_for_somebodys_sake_window")
		end

		hero.bIsQGGImproved = true

		hero:AddAbility("nursery_rhyme_queens_glass_game_upgrade")
		hero:FindAbilityByName("nursery_rhyme_queens_glass_game_upgrade"):SetLevel(hero:FindAbilityByName("nursery_rhyme_queens_glass_game"):GetLevel())
		if hero:HasModifier("modifier_nr_queens_glass_game") then
			hero:FindAbilityByName("nursery_rhyme_queens_glass_game_upgrade"):SetHidden(true)
		else 
			hero:SwapAbilities("nursery_rhyme_queens_glass_game_upgrade", "nursery_rhyme_queens_glass_game", true, false) 
		end
		if not hero:FindAbilityByName("nursery_rhyme_queens_glass_game"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_queens_glass_game_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_queens_glass_game"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_queens_glass_game")

		hero:AddAbility("nursery_rhyme_story_for_somebodys_sake_upgrade")
		hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake_upgrade"):SetLevel(1)
		hero:SwapAbilities("nursery_rhyme_nameless_forest_upgrade", "nursery_rhyme_nameless_forest", true, false) 
		if not hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake"):IsCooldownReady() then 
			hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake_upgrade"):StartCooldown(hero:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake"):GetCooldownTimeRemaining())
		end
		hero:RemoveAbility("nursery_rhyme_story_for_somebodys_sake")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end