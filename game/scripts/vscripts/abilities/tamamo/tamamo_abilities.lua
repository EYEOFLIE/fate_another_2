
function OnCurseCharmStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	if caster:HasModifier("modifier_mystic_shackle_window") then 
		caster:RemoveModifierByName("modifier_mystic_shackle_window")
	end

	if caster:HasModifier("modifier_tamamo_combo_window") then 
		caster:RemoveModifierByName("modifier_tamamo_combo_window")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_curse_charm_check", {})
	caster.CharmUp = false
	ability:EndCooldown()
end

function OnCurseCharmOpen(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_mystic_shackle_window") then 
		caster:RemoveModifierByName("modifier_mystic_shackle_window")
	end

	if caster:HasModifier("modifier_tamamo_combo_window") then 
		caster:RemoveModifierByName("modifier_tamamo_combo_window")
	end

	if caster.IsWitchcraftAcquired then 
		caster:SwapAbilities("tamamo_fiery_heaven_upgrade", caster:GetAbilityByIndex(0):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_frigid_heaven_upgrade", caster:GetAbilityByIndex(1):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_gust_heaven_upgrade", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_close_spellbook", "tamamo_curse_charm_upgrade", true, false)
	else
		caster:SwapAbilities("tamamo_fiery_heaven", caster:GetAbilityByIndex(0):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_frigid_heaven", caster:GetAbilityByIndex(1):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_gust_heaven", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		caster:SwapAbilities("tamamo_close_spellbook", "tamamo_curse_charm", true, false)
	end
end

function OnCurseCharmClose(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsWitchcraftAcquired then 
		caster:SwapAbilities("tamamo_close_spellbook", "tamamo_curse_charm_upgrade", false, true)		
	else
		caster:SwapAbilities("tamamo_close_spellbook", "tamamo_curse_charm", false, true)	
	end



	if caster.IsSpiritTheftAcquired then 
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "tamamo_subterranean_grasp_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "tamamo_subterranean_grasp", false, true)
	end

	if caster.IsMysticShackleAcquired then
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "tamamo_mantra_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "tamamo_mantra", false, true)
	end

	OnCurseCharmSwap(keys)

	if caster.CharmUp == true then 
		if ability == nil then 
			ability = caster:FindAbilityByName("tamamo_curse_charm_upgrade")
		end
		ability:StartCooldown(ability:GetCooldown(1))
	end
end

function OnPolygamistSwap(keys)
	local caster = keys.caster 

	if caster:HasModifier("modifier_fiery_heaven_indicator") then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "tamamo_poly_castration_fist_fire", false, true)
	elseif caster:HasModifier("modifier_frigid_heaven_indicator") then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "tamamo_poly_castration_fist_ice", false, true)
	elseif caster:HasModifier("modifier_gust_heaven_indicator") then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "tamamo_poly_castration_fist_wind", false, true)
	else 
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), "tamamo_poly_castration_fist", false, true)
	end
end

function OnCurseCharmSwap(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_curse_charm_check") then 
		return 
	end

	if caster.IsSpiritTheftAcquired and caster.IsWitchcraftAcquired then 
		if caster:HasModifier("modifier_fiery_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_fire_upgrade_3", false, true)
		elseif caster:HasModifier("modifier_frigid_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_ice_upgrade_3", false, true)
		elseif caster:HasModifier("modifier_gust_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_wind_upgrade_3", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_upgrade", false, true)
		end
	elseif not caster.IsSpiritTheftAcquired and caster.IsWitchcraftAcquired then 
		if caster:HasModifier("modifier_fiery_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_fire_upgrade_2", false, true)
		elseif caster:HasModifier("modifier_frigid_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_ice_upgrade_2", false, true)
		elseif caster:HasModifier("modifier_gust_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_wind_upgrade_2", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream", false, true)
		end
	elseif caster.IsSpiritTheftAcquired and not caster.IsWitchcraftAcquired then 
		if caster:HasModifier("modifier_fiery_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_fire_upgrade_1", false, true)
		elseif caster:HasModifier("modifier_frigid_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_ice_upgrade_1", false, true)
		elseif caster:HasModifier("modifier_gust_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_wind_upgrade_1", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_upgrade", false, true)
		end
	elseif not caster.IsSpiritTheftAcquired and not caster.IsWitchcraftAcquired then 
		if caster:HasModifier("modifier_fiery_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_fire", false, true)
		elseif caster:HasModifier("modifier_frigid_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_ice", false, true)
		elseif caster:HasModifier("modifier_gust_heaven_indicator") then
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream_wind", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), "tamamo_soulstream", false, true)
		end
	end
end

function OnCurseCharmCloseStart(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_curse_charm_check")
end

function ClearAllCharmBuff(caster)
	local charmTable = {
		"modifier_fiery_heaven_indicator",
		"modifier_frigid_heaven_indicator",
		"modifier_gust_heaven_indicator",
	}

	for i=1, #charmTable do
		if caster:HasModifier(charmTable[i]) then
			caster:RemoveModifierByName(charmTable[i])
		end
	end
end

function GetCharmCharge(caster)
	local arm_ability = caster:FindAbilityByName("tamamo_curse_charm")
	if arm_ability == nil then 
		arm_ability = caster:FindAbilityByName("tamamo_curse_charm_upgrade")
	end
	local chargeAmount = arm_ability:GetSpecialValueFor("charge")
	return chargeAmount
end

function OnFireCharmLoaded(keys)
	local caster = keys.caster
	local ability = keys.ability 
	caster.CharmUp = true
	ClearAllCharmBuff(caster)
	-- Apply stacks
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_fiery_heaven_indicator", caster, GetCharmCharge(caster))

	caster:RemoveModifierByName("modifier_curse_charm_check")

	if caster.IsPolygamistCastrationFistAcquired and caster.IsWitchcraftAcquired then 
		OnPolygamistSwap(keys)
	end
end

function OnCharmParticleCreate(keys)
	local caster = keys.caster 
	caster.dummy_orb = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.dummy_orb:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.relative_pos = Vector(150,0,0)
	caster.dummy_orb:SetAbsOrigin(caster:GetAbsOrigin() + caster.relative_pos)
	caster.rotate_angle = 0

	caster.curse_charm_orb = ParticleManager:CreateParticle(keys.Particle, PATTACH_ABSORIGIN_FOLLOW, caster.dummy_orb)
	ParticleManager:SetParticleControlEnt(caster.curse_charm_orb, 1, caster.dummy_orb, PATTACH_POINT_FOLLOW, "attach_origin", caster.dummy_orb:GetAbsOrigin(), false)
end

function OnCharmParticleThink(keys)
	local caster = keys.caster 
	local origin = caster:GetAbsOrigin() 
	local delta_rotation = 4
	caster.rotate_angle = caster.rotate_angle + delta_rotation
	caster.dummy_orb:SetAbsOrigin( RotatePosition( origin, QAngle( 0, -caster.rotate_angle, 0 ),origin + caster.relative_pos) )
end

function OnCharmParticleDestroy(keys)
	local caster = keys.caster 
	caster.dummy_orb:RemoveSelf() 
	ParticleManager:DestroyParticle( caster.curse_charm_orb, false )
	ParticleManager:ReleaseParticleIndex( caster.curse_charm_orb )
	OnCurseCharmSwap(keys)
	if caster.IsPolygamistCastrationFistAcquired and caster.IsWitchcraftAcquired then 
		OnPolygamistSwap(keys)
	end
end

function OnFreezeCharmLoaded(keys)
	local caster = keys.caster
	local ability = keys.ability 
	caster.CharmUp = true
	
	ClearAllCharmBuff(caster)
	-- Apply stacks
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_frigid_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_frigid_heaven_indicator", caster, GetCharmCharge(caster))

	caster:RemoveModifierByName("modifier_curse_charm_check")

	if caster.IsPolygamistCastrationFistAcquired and caster.IsWitchcraftAcquired then 
		OnPolygamistSwap(keys)
	end
end

function OnGustCharmLoaded(keys)
	local caster = keys.caster
	local ability = keys.ability 
	caster.CharmUp = true
	ClearAllCharmBuff(caster)
	-- Apply stacks
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gust_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_gust_heaven_indicator", caster, GetCharmCharge(caster))

	caster:RemoveModifierByName("modifier_curse_charm_check")

	if caster.IsPolygamistCastrationFistAcquired and caster.IsWitchcraftAcquired then 
		OnPolygamistSwap(keys)
	end
end

function OnSGStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	ability:ApplyDataDrivenModifier(caster, target, "modifier_subterranean_grasp_delay", {})
	SpawnAttachedVisionDummy(caster, target, 300, 3, false)
	target:EmitSound("Hero_Visage.GraveChill.Cast")
end

function OnSGApplyCC(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_subterranean_grasp", {})
	giveUnitDataDrivenModifier(caster, target, "rooted", duration)
	giveUnitDataDrivenModifier(caster, target, "locked", duration)
	if caster.IsSpiritTheftAcquired and target:HasModifier("modifier_amaterasu_enemy") then
		giveUnitDataDrivenModifier(caster, target, "revoked", duration)
	end
end

function OnSGDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:StopSound("Hero_Visage.GraveChill.Target")
end

function OnMantraCast(keys)
	local caster = keys.caster
	local target = keys.target 
	if target:GetName() == "npc_dota_ward_base" then
		caster:Interrupt()
		return
	end
end 

function OnMantraStart(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability
	local orbAmount = keys.OrbAmount
	local modifierName = 0
	if caster:GetTeam() ~= target:GetTeam() then
		if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	end
	
	if target:HasModifier("modifier_mantra_ally") or target:HasModifier("modifier_mantra_enemy") then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Target Already Affected By Mantra" } )
		keys.ability:EndCooldown()
		caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(1))
		return	
	end
	caster.MantraTarget = target
	caster.MantraLocation = caster:GetAbsOrigin()
	target.IsMantraProcOnCooldown = false 

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		modifierName = "modifier_mantra_ally"
		if caster.IsMysticShackleAcquired then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_mr_buff", {})
		end
	else
		if IsSpellBlocked(keys.target) then return end
		modifierName = "modifier_mantra_enemy"
		if caster.IsMysticShackleAcquired then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_mr_debuff", {})
		end
	end

	if caster.IsMysticShackleAcquired and not caster:HasModifier("modifier_mystic_shackle_cooldown") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mystic_shackle_window", {})
	end

	local castFx = ParticleManager:CreateParticle('particles/units/heroes/hero_oracle/oracle_purifyingflames_halo.vpcf', PATTACH_CUSTOMORIGIN, target) 
    ParticleManager:SetParticleControl(castFx, 0, target:GetOrigin())
    target:EmitSound("Tamamo.Mantra")

	-- Set stack amount1
	ability:ApplyDataDrivenModifier(caster, target, modifierName, {}) 
	target:SetModifierStackCount(modifierName, ability, orbAmount)
	for i=1, orbAmount do ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_vfx", {}) end
end

function OnMantraTakeDamage(keys)
	local caster = keys.caster 
	local target = caster.MantraTarget
	local attacker = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.DamageTaken
	local orbBlockAmt = 0
	local orbDamageEnemy = 0
	local currentStack = 0
	local modifierName = 0
	local currentHealth = target:GetHealth() 

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		modifierName = "modifier_mantra_ally"
		orbBlockAmt = keys.BlockAmt 
		if currentHealth == 0 then
			--print("lethal")
		else
			if orbBlockAmt < keys.DamageTaken then
				target:SetHealth(currentHealth + orbBlockAmt)
			else
				target:SetHealth(currentHealth + keys.DamageTaken)
			end
		end
	else
		if target.IsMantraProcOnCooldown then 
			return
		else
			--print(attacker:GetName() .. " attacked " .. target:GetName())
			target.IsMantraProcOnCooldown = true
			orbDamageEnemy = keys.Damage
			DoDamage(caster, target, orbDamageEnemy, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			Timers:CreateTimer(0.299, function()
				target.IsMantraProcOnCooldown = false
			end)
		end 
		modifierName = "modifier_mantra_enemy"
	end

	local shieldFx = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf', PATTACH_CUSTOMORIGIN, caster) 
    ParticleManager:SetParticleControl(shieldFx, 1, target:GetOrigin())
	target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")

	-- Set stack amount
	currentStack = target:GetModifierStackCount(modifierName, ability)
	--print("current mantra stack :" .. currentStack)
	target:RemoveModifierByName("modifier_mantra_vfx")

	if currentStack > 1 then
		target:SetModifierStackCount(modifierName, ability, currentStack-1)
	else
		target:RemoveModifierByName(modifierName)
	end
end

function OnShackleWindowCreate(keys)
	local caster = keys.caster
	caster:SwapAbilities("tamamo_mantra_upgrade", "tamamo_mystic_shackle", false, true)
end

function OnShackleWindowDestroy(keys)
	local caster = keys.caster
	caster:SwapAbilities("tamamo_mantra_upgrade", "tamamo_mystic_shackle", true, false)
end

function OnShackleWindowDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_mystic_shackle_window")
end

function OnShackleStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
    local targetPoint = ability:GetCursorPosition()
	local range = ability:GetSpecialValueFor("distance")
	local speed = 1500 
	local width = 150 
	caster.ShackleHit = false
	caster:RemoveModifierByName("modifier_mystic_shackle_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystic_shackle_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	if (math.abs(targetPoint.x - origin.x) < range) and (math.abs(targetPoint.y - origin.y) < range) then
		targetPoint = origin + ((targetPoint - caster:GetAbsOrigin()):Normalized() * range)
	end
	local dummy_origin = origin
	local forwardvector = (targetPoint - caster:GetAbsOrigin()):Normalized()

	caster.shackledummy = CreateUnitByName("dummy_unit", dummy_origin, false, caster, caster, caster:GetTeamNumber())
	caster.shackledummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.shackledummy:SetForwardVector(forwardvector)	

	caster.shackleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.shackledummy)
	ParticleManager:SetParticleControl( caster.shackleIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( caster.shackleIndex, 1, caster.shackledummy:GetAbsOrigin() )

	Timers:CreateTimer(function()
		if IsValidEntity(caster.shackledummy) then
			dummy_origin = GetGroundPosition(dummy_origin + (speed * 0.05) * Vector(forwardvector.x, forwardvector.y, 0), nil)								
			caster.shackledummy:SetAbsOrigin(dummy_origin)
			return 0.05
		else
			return nil
		end
	end)

    local shackle = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin() + Vector(forwardvector.x * 10, forwardvector.y * 10,0),
        fDistance = range,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = true,
		vVelocity = forwardvector * speed
	}
	local projectile = ProjectileManager:CreateLinearProjectile(shackle)

	Timers:CreateTimer( range/speed, function()
		if caster.ShackleHit == false then 
			ParticleManager:DestroyParticle( caster.shackleIndex, false )
			ParticleManager:ReleaseParticleIndex( caster.shackleIndex )
			if IsValidEntity(caster.shackledummy) then
				caster.shackledummy:RemoveSelf()
			end
		end
	end)
end

function OnShackleHit(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 

	if target == nil then 
		caster.ShackleHit = false 
		return 
	end 

	ParticleManager:DestroyParticle( caster.shackleIndex, false )
	ParticleManager:ReleaseParticleIndex( caster.shackleIndex )
	caster.shackledummy:RemoveSelf()
	local duration = ability:GetSpecialValueFor("duration")
    ability:ApplyDataDrivenModifier(caster, target, "modifier_mystic_shackle", {})
	giveUnitDataDrivenModifier(caster, caster, "locked", duration)
	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		giveUnitDataDrivenModifier(caster, target, "locked", duration)
	end
end

function OnShackleThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local range = ability:GetSpecialValueFor("distance")
	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	if dist > 2500 or target:IsMagicImmune() or target:IsInvulnerable() or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then
		target:RemoveModifierByName("modifier_mystic_shackle")
	elseif dist > range then
		local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
		local normal = diff:Normalized()
		target:SetAbsOrigin(caster:GetAbsOrigin()+ (normal * range))
		FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
	end
end

function OnAmaterasuStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	if caster.CurrentAmaterasuDummy ~= nil then
		if IsValidEntity(caster.CurrentAmaterasuDummy) or not caster.CurrentAmaterasuDummy:IsNull() then
			caster.CurrentAmaterasuDummy:RemoveModifierByName("modifier_amaterasu_aura_enemy")
			caster.CurrentAmaterasuDummy:RemoveModifierByName("modifier_amaterasu_aura")			
		end
	end

	TamamoCheckCombo(caster, ability)

	--EmitGlobalSound("Hero_KeeperOfTheLight.ManaLeak.Cast")
	caster.AmaterasuCastLoc = caster:GetAbsOrigin()
	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.CurrentAmaterasuDummy = dummy
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration= duration + 0.5})
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_amaterasu_aura", {})
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_amaterasu_aura_enemy", {})
	dummy.TempleDoors = CreateTempleDoorInCircle(caster, caster:GetAbsOrigin(), radius , duration)
	--EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Dazzle.Shallow_Grave", caster)

	if caster.IsTerritoryCreationAcquired then 
		local cooldown_reduction = ability:GetSpecialValueFor("cooldown_reduction")
		local silence = ability:GetSpecialValueFor("silence")
		local targets = FindUnitsInRadius(caster:GetTeam(), caster.AmaterasuCastLoc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull()then
				v:AddNewModifier(caster, ability, "modifier_silence", {Duration = silence})
			end
		end

		local allies = FindUnitsInRadius(caster:GetTeam(), caster.AmaterasuCastLoc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
		for i = 1, #allies do
			ability:ApplyDataDrivenModifier(caster, allies[i], "modifier_amaterasu_territory_heal", {})

			if allies[i] ~= caster then 
				--print(allies[i]:GetName())
				for j=0, 5 do 
					local Rability = allies[i]:GetAbilityByIndex(j)
					--print(Rability:GetAbilityName())
					if Rability ~= nil then 
						if Rability.IsResetable ~= false then
							local rCooldown = Rability:GetCooldownTimeRemaining()
							--print('Cooldown ' .. rCooldown)
							Rability:EndCooldown()
							if rCooldown > cooldown_reduction then
								Rability:StartCooldown(rCooldown - cooldown_reduction)
							end
						end
					end
				end
			end
		end
	end

	-- Particle
	local circleFx = ParticleManager:CreateParticle('particles/units/heroes/hero_dazzle/dazzle_weave.vpcf', PATTACH_CUSTOMORIGIN, dummy) 
    ParticleManager:SetParticleControl(circleFx, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(circleFx, 1, Vector(radius,0,0))
	local counter = 0
    Timers:CreateTimer(function()
    	if counter > duration or caster.CurrentAmaterasuDummy:IsNull() or not IsValidEntity(caster.CurrentAmaterasuDummy) then 
			ParticleManager:DestroyParticle( caster.CurrentAmaterasuParticle, false )
			ParticleManager:ReleaseParticleIndex( caster.CurrentAmaterasuParticle )
			return
    	end
    	if not dummy:IsNull() and IsValidEntity(dummy) then
			local circleFx = ParticleManager:CreateParticle('particles/custom/tamamo/tamamo_amaterasu_continuous.vpcf', PATTACH_CUSTOMORIGIN, dummy) 
			caster.CurrentAmaterasuParticle = circleFx
		    ParticleManager:SetParticleControl(circleFx, 0, dummy:GetOrigin())
		    ParticleManager:SetParticleControl(circleFx, 1, Vector(radius,0,0))
	   	end
	    counter = counter+1
	    return 0.9
    end)

    caster.AmaterasuLine = "Tamamo_Amaterasu_" .. math.random(1,3)
    caster:EmitSound(caster.AmaterasuLine)

	--EmitGlobalSound("Tamamo_NP1")
end

function OnAmaterasuThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local radius = ability:GetSpecialValueFor("radius")
	local diff = (caster:GetAbsOrigin() - caster.AmaterasuCastLoc):Length2D()
	if diff > radius or not caster:IsAlive() then
		target:RemoveModifierByName("modifier_amaterasu_aura_enemy")
		
		target:RemoveModifierByName("modifier_amaterasu_aura")
	end
end

function OnAmaterasuAllyCreate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if not IsManaLess(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_amaterasu_mana_ally", {})
	end
end

function OnAmaterasuAllyDestroy(keys)
	local target = keys.target
	target:RemoveModifierByName("modifier_amaterasu_mana_ally")
end

function OnAmaterasuEnemyCreate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if caster.IsTerritoryCreationAcquired then 
		if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_amaterasu_slow_enemy", {})
		end
	end
end

function OnAmaterasuEnemyDestroy(keys)
	local target = keys.target
	target:RemoveModifierByName("modifier_amaterasu_slow_enemy")
end

function OnAmaterasuAlliesUseAbility(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.unit 
	local t_ability = target:GetCurrentActiveAbility()

	if IsSpellBook(t_ability:GetAbilityName()) or t_ability:IsItem() then 
		return 
	end

    local amaterasu = caster:FindAbilityByName("tamamo_amaterasu")
    if amaterasu == nil then 
    	amaterasu = caster:FindAbilityByName("tamamo_amaterasu_upgrade")
    end

    if not IsManaLess(target) then
        target:SetMana(target:GetMana() + amaterasu:GetSpecialValueFor("mana_amount"))
    end

    target:SetHealth(target:GetHealth() + amaterasu:GetSpecialValueFor("heal_amount"))
    target:EmitSound("DOTA_Item.ArcaneBoots.Activate")
    local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
end

function OnAmaterasuHeal(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local heal = ability:GetSpecialValueFor("instant_heal") / 100 * 0.1
	target:FateHeal(heal * target:GetMaxHealth(), caster, true)
end

function OnAmaterasuEnd(keys)
	local target = keys.target
	local caster = keys.caster
	--if caster:HasModifier("modifier_tamamo_combo_window") then 
		caster:RemoveModifierByName("modifier_tamamo_combo_window")
	--end
	target:RemoveSelf()
	for i=1, #target.TempleDoors do
		target.TempleDoors[i]:RemoveSelf()
	end
	ParticleManager:DestroyParticle( caster.CurrentAmaterasuParticle, false )
	ParticleManager:ReleaseParticleIndex( caster.CurrentAmaterasuParticle )
end

function CreateTempleDoorInCircle(handle, center, multiplier, duration)
	local bannerTable = {}
	for i=1, 8 do
		local x = math.cos(i*math.pi/4) * multiplier
		local y = math.sin(i*math.pi/4) * multiplier
		local banner = CreateUnitByName("tamamo_templedoor_dummy", Vector(center.x + x, center.y + y, 0), true, nil, nil, handle:GetTeamNumber())
		banner:AddNewModifier(caster, nil, "modifier_kill", {duration= duration + 0.5})
		local diff = (handle:GetAbsOrigin() - banner:GetAbsOrigin())
    	banner:SetForwardVector(diff:Normalized()) 
    	banner.Diff = diff
		table.insert(bannerTable, banner)
	end
	return bannerTable
end

function OnPolygamistCastrationFistCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
	elseif IsFemaleServant(target) and target:IsMagicImmune() then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target_Female_With_Magic_Immune")
	end
end

function OnPolygamistStartCD(caster, ability)

	local poly_fist = {
		"tamamo_poly_castration_fist",
		"tamamo_poly_castration_fist_fire",
		"tamamo_poly_castration_fist_ice",
		"tamamo_poly_castration_fist_wind"
	}

	for i = 1, #poly_fist do 
		if caster:FindAbilityByName(poly_fist[i]):IsCooldownReady() then 
			caster:FindAbilityByName(poly_fist[i]):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function OnPolygamistCastrationFistStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage")
	local range = ability:GetSpecialValueFor("range")
	local final_damage = ability:GetSpecialValueFor("final_damage")
	local knockup = ability:GetSpecialValueFor("knockup")
	local knockback = ability:GetSpecialValueFor("knockback")
	local count = 0
	local damage_type = DAMAGE_TYPE_MAGICAL
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_polygamist_fist_cooldown", {Duration = ability:GetCooldown(1)})

	caster:EmitSound("tamamo_castration_fist_1")
	--giveUnitDataDrivenModifier(caster, caster, "dragged", 2.0)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 2.0)
	OnPolygamistStartCD(caster, ability)

	local charm = nil
	local modifier = nil
	if caster.IsWitchcraftAcquired then
		if caster:HasModifier("modifier_fiery_heaven_indicator") then 
			charm = "modifier_fiery_heaven_indicator"
			modifier = "modifier_tamamo_fire_debuff"
		elseif caster:HasModifier("modifier_frigid_heaven_indicator") then 
			charm = "modifier_frigid_heaven_indicator"
			modifier = "modifier_tamamo_ice_debuff"
		elseif caster:HasModifier("modifier_gust_heaven_indicator") then 
			charm = "modifier_gust_heaven_indicator"
			modifier = "modifier_tamamo_wind_debuff"
		end
		local bonus_dmg = ability:GetSpecialValueFor("bonus_damage_per_stack")
		local stacks = caster:GetModifierStackCount(charm, caster) or 0
	end

	if not IsFemaleServant(target) then
		damage_type = DAMAGE_TYPE_PURE
	end

	local original_forward_vector = caster:GetForwardVector()
	local face_target = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.5})

	if not caster:HasModifier("modifier_alternate_05") then 
		caster:SetAngles(-45, 0, 0)
	end

	local tama = Physics:Unit(caster)
	caster:OnHibernate(function(unit)
		if caster:IsAlive() and target:IsAlive() then
			caster:SetPhysicsVelocity(face_target * 1500)
		 	caster:PreventDI()
	    	caster:SetPhysicsFriction(0)
		  	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    	caster:FollowNavMesh(false)	
	    	caster:SetAutoUnstuck(false)
	    	caster:OnPhysicsFrame(function(unit)
				local diff = target:GetAbsOrigin() - unit:GetAbsOrigin()
				local dir = diff:Normalized()
				unit:SetPhysicsVelocity(dir * range *2)
				if not IsInSameRealm(unit:GetAbsOrigin(), target:GetAbsOrigin()) or diff:Length() > 1300 or not unit:HasModifier("jump_pause") --[[unit:HasModifier("dragged")]] then
					--unit:RemoveModifierByName("dragged")
					unit:RemoveModifierByName("jump_pause")
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					unit:OnHibernate(nil)
					unit:SetAutoUnstuck(true)
					unit:SetAngles(0, 0, 0)
		        	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        	--UnFreezeAnimation(unit)
		        	return
				elseif diff:Length() < 100 then
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					unit:OnHibernate(nil)
					unit:SetAutoUnstuck(true)
					unit:SetAngles(0, 0, 0)
		        	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        	--UnfreezeAnimation(unit)
		        	target:AddNewModifier(unit, ability, "modifier_stunned", { Duration = 0.35 })

		        	local trailFxIndex = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_kick_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControl( trailFxIndex, 1, target:GetAbsOrigin() )
					unit:SetForwardVector(face_target)
					target:EmitSound("Tamamo_Kick_Sfx")
					DoDamage(unit, target, damage, damage_type, 0, ability, false)
					
					if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
						if unit.IsWitchcraftAcquired then 
							if charm ~= nil and stacks ~= 0 then 
								local stacks = unit:GetModifierStackCount(charm, unit) or 0
								local bonus_dmg = ability:GetSpecialValueFor("bonus_damage_per_stack")
								local consume_stack = math.floor(stacks/3)
								
								stacks = stacks - consume_stack 
								ApplyCharm(unit, target, charm, modifier, consume_stack)
								if stacks >= 1 then 
									unit:SetModifierStackCount(charm, unit, stacks)
								else
									unit:RemoveModifierByName(charm)
								end

								DoDamage(unit, target, bonus_dmg * consume_stack, DAMAGE_TYPE_MAGICAL, 0, ability, false)
							end
						end
					end
			
					ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )

					
					Timers:CreateTimer(0.4, function()			
						if unit:IsAlive() and target:IsAlive() then
							unit:EmitSound("tamamo_castration_fist_2")
							ApplyAirborne(unit, target, 1.0)
							DoDamage(unit, target, damage, damage_type, 0, ability, false)
							if unit:HasModifier("modifier_alternate_05") then 
								StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_ATTACK_EVENT, rate=1.5})
							elseif unit:HasModifier("modifier_alternate_01") then 
								StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_ATTACK, rate=0.75})	
							else
								StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=1.5})
							end
							if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
								if unit.IsWitchcraftAcquired then 
									if charm ~= nil and stacks ~= 0 then 
										local stacks = unit:GetModifierStackCount(charm, unit) or 0
										local bonus_dmg = ability:GetSpecialValueFor("bonus_damage_per_stack")
										local consume_stack = stacks/2
										
										stacks = stacks - consume_stack 
										ApplyCharm(unit, target, charm, modifier, consume_stack)
										if stacks >= 1 then 
											unit:SetModifierStackCount(charm, unit, stacks)
										else
											unit:RemoveModifierByName(charm)
										end
										DoDamage(unit, target, bonus_dmg * consume_stack, DAMAGE_TYPE_MAGICAL, 0, ability, false)
									end
								end
							end
							local trailFxIndex = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_kick_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
							ParticleManager:SetParticleControl( trailFxIndex, 1, target:GetAbsOrigin() )
							target:EmitSound("Tamamo_Kick_Sfx")
							ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )

							Timers:CreateTimer(0.4, function()	
								if unit:IsAlive() and target:IsAlive() then	
									giveUnitDataDrivenModifier(unit,unit, "jump_pause", 0.6)
									if unit:HasModifier("modifier_alternate_05") then 
										StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=1.5})
									elseif unit:HasModifier("modifier_alternate_01") then 
										StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.2})
									else
										StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.5})
									end
									for i = 1, 10 do 
										Timers:CreateTimer(0.03 * i, function()	
											unit:SetAbsOrigin(unit:GetAbsOrigin() + Vector(-face_target.x * 40, -face_target.y * 40, 20) )
										end)
									end
								end
							end)

							Timers:CreateTimer(0.7, function()	
								if unit:IsAlive() and target:IsAlive() then	
									StartAnimation(unit, {duration=0.35, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.2})
									--FreezeAnimation(unit)
									for i = 1, 10 do 
										Timers:CreateTimer(0.03 * i, function()	
											unit:SetAbsOrigin(unit:GetAbsOrigin() + Vector(face_target.x * 40, face_target.y * 40, -20))
										end)
									end
								end
							end)

							Timers:CreateTimer(1.0, function()	
								if unit:IsAlive() and target:IsAlive() then	
									--UnFreezeAnimation(unit)
									unit:RemoveModifierByName("jump_pause")
									target:AddNewModifier(unit, ability, "modifier_stunned", { Duration = 0.4 })
									target:EmitSound("Tamamo_Kick_Sfx")
									local forward = unit:GetForwardVector()

									if not IsKnockbackImmune(target) and not IsImmuneToCC(target) then
										local target_phys = Physics:Unit(target)
										target:SetPhysicsFriction(0)
										target:SetPhysicsVelocity(forward * knockback * 2)
										target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)


										Timers:CreateTimer("kick_target_backjump", {
											endTime = 0.4,
											callback = function()
											target:OnPreBounce(nil)
											target:SetBounceMultiplier(0)
											target:PreventDI(false)
											target:SetPhysicsVelocity(Vector(0,0,0))
											FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
											return 
										end})

										target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
											Timers:RemoveTimer("kick_target_backjump")
											unit:OnPreBounce(nil)
											unit:SetBounceMultiplier(0)
											unit:PreventDI(false)
											unit:SetPhysicsVelocity(Vector(0,0,0))
											FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
										end)
									end

									--Timers:CreateTimer(0.4, function()				
									local explodeFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_ABSORIGIN, target )
									ParticleManager:SetParticleControl( explodeFx1, 0, target:GetAbsOrigin())
									local explodeFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
									ParticleManager:SetParticleControl( explodeFx2, 0, target:GetAbsOrigin())
									target:EmitSound("Ability.LightStrikeArray")
									unit:SetForwardVector(original_forward_vector)

									DoDamage(unit, target, final_damage, damage_type, 0, ability, false)
									if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
										if unit.IsWitchcraftAcquired then 
											if charm ~= nil and stacks ~= 0 then 
												local stacks = unit:GetModifierStackCount(charm, unit) or 0
												local bonus_dmg = ability:GetSpecialValueFor("bonus_damage_per_stack")
												
												ApplyCharm(unit, target, charm, modifier, stacks)
												unit:RemoveModifierByName(charm)
												DoDamage(unit, target, bonus_dmg * stacks, DAMAGE_TYPE_MAGICAL, 0, ability, false)
											end
										end
									end
										--return 
									--end)
								else
									--unit:RemoveModifierByName("dragged")
									unit:RemoveModifierByName("jump_pause")
									unit:SetForwardVector(original_forward_vector)
									FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
									return
								end
							end)
						else
							--unit:RemoveModifierByName("dragged")
							unit:RemoveModifierByName("jump_pause")
							unit:SetForwardVector(original_forward_vector)
							FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
							return
						end
					end)
				end
			end)
		else
			--caster:RemoveModifierByName("dragged")
			caster:RemoveModifierByName("jump_pause")
			caster:SetAngles(0, 0, 0)
			caster:SetForwardVector(original_forward_vector)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			return
		end
	end)
end

LinkLuaModifier("modifier_tamamo_fire_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_ice_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_wind_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)

function ApplyCharm(caster, target, charm, modifier, stacks)
	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target:IsMagicImmune() then return end
	local ability = nil
	if charm == "modifier_fiery_heaven_indicator" then 
		ability = caster:FindAbilityByName("tamamo_fiery_heaven_upgrade")
	elseif charm == "modifier_frigid_heaven_indicator" then 
		ability = caster:FindAbilityByName("tamamo_frigid_heaven_upgrade")
	elseif charm == "modifier_gust_heaven_indicator" then 
		ability = caster:FindAbilityByName("tamamo_gust_heaven_upgrade")
	end
	local currentstack = target:GetModifierStackCount(modifier, caster) or 0
	if not target:HasModifier(modifier) then
		target:AddNewModifier(caster, ability, modifier, {Duration = ability:GetSpecialValueFor("debuff_duration")})
	end
	target:SetModifierStackCount(modifier, caster, currentstack + stacks)
end

function OnWitchcraftAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local int_ratio = ability:GetSpecialValueFor("int_ratio")
	local max_stack = ability:GetSpecialValueFor("max_stack") / 100
	local charm = nil
	local modifier = nil

	if caster:HasModifier("modifier_fiery_heaven_indicator") then 
		charm = "modifier_fiery_heaven_indicator"
		modifier = "modifier_tamamo_fire_debuff"
	elseif caster:HasModifier("modifier_frigid_heaven_indicator") then 
		charm = "modifier_frigid_heaven_indicator"
		modifier = "modifier_tamamo_ice_debuff"
	elseif caster:HasModifier("modifier_gust_heaven_indicator") then 
		charm = "modifier_gust_heaven_indicator"
		modifier = "modifier_tamamo_wind_debuff"
	end

	local stacks = caster:GetModifierStackCount(charm, caster) or 0

	if charm ~= nil and stacks ~= 0 then 
		stacks = stacks - 1 
		ApplyCharm(caster, target, charm, modifier, 1)
		if stacks >= 1 then 
			caster:SetModifierStackCount(charm, caster, stacks)
		else
			caster:RemoveModifierByName(charm)
		end
	end

	if not target:IsMagicImmune() then 
		
		ability:ApplyDataDrivenModifier(caster, target, "modifier_witchcraft_mr_reduction", {})
		local current_stack = target:GetModifierStackCount("modifier_witchcraft_mr_reduction", caster) or 0
		local mr = target:GetBaseMagicalResistanceValue()
		current_stack = current_stack + 1 
		target:SetModifierStackCount("modifier_witchcraft_mr_reduction", caster, current_stack)

		DoDamage(caster, target, int_ratio * caster:GetIntellect(), DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function TamamoCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "tamamo_amaterasu") and caster:FindAbilityByName("tamamo_combo"):IsCooldownReady() and not caster:HasModifier("modifier_tamamo_combo_cooldown") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_tamamo_combo_window", {})
		end
	end
end

function OnComboWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsTerritoryCreationAcquired then 
		caster:SwapAbilities("tamamo_amaterasu_upgrade", "tamamo_combo", false, true)
	else
		caster:SwapAbilities("tamamo_amaterasu", "tamamo_combo", false, true)
	end
end

function OnComboWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsTerritoryCreationAcquired then 
		caster:SwapAbilities("tamamo_amaterasu_upgrade", "tamamo_combo", true, false)
	else
		caster:SwapAbilities("tamamo_amaterasu", "tamamo_combo", true, false)
	end
end

function OnComboWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_tamamo_combo_window")
end

function OnComboCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if not caster:HasModifier("modifier_amaterasu_ally") then 
		caster:Interrupt() 
		caster:RemoveModifierByName("modifier_tamamo_combo_window")
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Cast_Outside_of_Amaterasu")
	end
end

function OnComboStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local targetPoint = ability:GetCursorPosition() 
	local radius = ability:GetSpecialValueFor("radius")
	local total_orbs = ability:GetSpecialValueFor("small_orb")
	local projectileSpeed = 1900
	local ascendCount = 0
	local descendCount = 0
	
	local orb = 0
	
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 3.9)
	caster:StopSound(caster.AmaterasuLine)
	caster:RemoveModifierByName("modifier_tamamo_combo_window")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tamamo_combo_cooldown", { Duration = ability:GetCooldown(1)})

	local masterCombo = caster.MasterUnit2:FindAbilityByName("tamamo_combo")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	Timers:CreateTimer('tama_ascend', {
		endTime = 0,
		callback = function()
	   	if ascendCount == 15 then	   			   		
	   		if caster:HasModifier('modifier_alternate_03') then 
				caster:EmitSound("Tamamo-Police-Combo1")
	   		elseif caster:HasModifier('modifier_alternate_06') then 
				caster:EmitSound("Tamamo-Waifu-Combo1")
	   		elseif caster:HasModifier('modifier_alternate_07') then 
				caster:EmitSound("Tamamo-Summer-Combo1")	
			else	
	   			EmitGlobalSound("Tamamo_Combo1")	   		
	   		end	   		

		   	return 
		elseif ascendCount == 1 then
			if caster:HasModifier("modifier_alternate_05") then 
				StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.5})
			else
		   		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
		   	end
		end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + 35))
		ascendCount = ascendCount + 1;
		return 0.033
	end
	})	

	Timers:CreateTimer(0.5, function()
		orb = orb + 1
		if orb <= total_orbs then
			local projectileOrigin = caster:GetAbsOrigin() + Vector(0,0,25)
			local orb_target = RandomPointInCircle(targetPoint, radius * 0.7)

			if orb % 2 == 0 then
				StartAnimation(caster, {duration=0.1, activity=ACT_DOTA_ATTACK, rate=6})
				CreateFireIceProjectile(caster, ability,false, projectileOrigin, orb_target)
			else
				StartAnimation(caster, {duration=0.1, activity=ACT_DOTA_ATTACK2, rate=6})
				CreateFireIceProjectile(caster, ability,true, projectileOrigin, orb_target)
			end			

			return 0.1
		else
			return
		end
	end)

	Timers:CreateTimer(2.2, function()
		if caster:IsAlive() then
			if caster:HasModifier('modifier_alternate_03') then 
				caster:EmitSound("Tamamo-Police-Combo2")
	   		elseif caster:HasModifier('modifier_alternate_06') then 
				caster:EmitSound("Tamamo-Waifu-Combo2")
	   		elseif caster:HasModifier('modifier_alternate_07') then 
				caster:EmitSound("Tamamo-Summer-Combo2")	
			else	
	   			EmitGlobalSound("Tamamo_Combo2")	   		
	   		end	

	   		if caster:HasModifier("modifier_alternate_05") then 
				StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
			else  		
	   			StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})
	   		end
			local projectileOrigin = caster:GetAbsOrigin() + Vector(0, 0, 50)
			ThrowFinalProjectile(caster, ability, projectileOrigin, targetPoint)
		end
		
		return
	end)

	Timers:CreateTimer("tama_descend", {
	    endTime = 3.5,
	    callback = function()
	    	if descendCount == 15 then 
	    		caster:RemoveModifierByName("jump_pause")
		    	return 
		    end
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z - 35))
			descendCount = descendCount + 1;
	      	return 0.033
	    end
	})
end

function CreateFireIceProjectile(caster, ability,isFire, orbOrigin, targetLocation)
	local projectile = CreateUnitByName("dummy_unit", orbOrigin, false, caster, caster, caster:GetTeamNumber())
	projectile:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	projectile:SetAbsOrigin(orbOrigin)

	local particle_name = ""

	if isFire then
		particle_name = "particles/custom/tamamo/combo/combo_fire_orb_projectile.vpcf"
	else
		particle_name = "particles/custom/tamamo/combo/combo_ice_orb_projectile.vpcf"
	end

	local throw_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, projectile)
	ParticleManager:SetParticleControl(throw_particle, 0, orbOrigin)
	ParticleManager:SetParticleControl(throw_particle, 1, targetLocation)
	--ParticleManager:SetParticleControl(throw_particle, 1, (targetLocation - orbOrigin):Normalized() * 1900)

	local travelTime = (targetLocation - orbOrigin):Length() / 1900
	Timers:CreateTimer(travelTime, function()
		ParticleManager:DestroyParticle(throw_particle, false)
		ProjectileFireIceHit(caster, ability, isFire ,targetLocation, projectile)
	end)
end

function ProjectileFireIceHit(caster, ability, isFire, position, projectile)
	local targetPoint = position
	local radius = ability:GetSpecialValueFor("small_radius")
	local damage = ability:GetSpecialValueFor("small_damage")
	local stun = ability:GetSpecialValueFor("cc_duration")

	local particle_name = ""
	local sound_name = ""

	if isFire then
		particle_name = "particles/custom/tamamo/combo/fire_explosion.vpcf"
		sound_name = "Fire_Explosion_Sound"
	else
		particle_name = "particles/custom/tamamo/combo/ice_explosion.vpcf"
		sound_name = "Ice_Explosion_Sound"
	end	

	Timers:CreateTimer(0.15, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		projectile:EmitSound(sound_name)
		for k,v in pairs(targets) do
	        if IsValidEntity(v) and not v:IsNull() then
		        if isFire then
		        	v:AddNewModifier(caster, nil, "modifier_stunned", { Duration = stun })
		        else
		        	giveUnitDataDrivenModifier(caster,v, "rooted", stun)
		        	giveUnitDataDrivenModifier(caster,v, "locked", stun)
		        end	

		        DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		    end
		end
	    projectile:SetAbsOrigin(targetPoint)

	    local explosion_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, projectile)
		ParticleManager:SetParticleControl(explosion_fx, 0, projectile:GetAbsOrigin())
		
	    Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( explosion_fx, false )
			ParticleManager:ReleaseParticleIndex(explosion_fx)
			projectile:RemoveSelf()
		end)
	end)
end

function ThrowFinalProjectile(caster, ability, orbOrigin, targetLocation)
	local projectile = CreateUnitByName("dummy_unit", orbOrigin, false, caster, caster, caster:GetTeamNumber())
	projectile:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	projectile:SetAbsOrigin(orbOrigin)

	local throw_particle = ParticleManager:CreateParticle("particles/custom/tamamo/combo/combo_fire_orb_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, projectile)
	ParticleManager:SetParticleControl(throw_particle, 0, orbOrigin)
	ParticleManager:SetParticleControl(throw_particle, 1, targetLocation)
	--ParticleManager:SetParticleControl(throw_particle, 1, (targetLocation - orbOrigin):Normalized() * 1900)

	local travelTime = (targetLocation - orbOrigin):Length() / 1900
	Timers:CreateTimer(travelTime, function()
		ParticleManager:DestroyParticle(throw_particle, false)
		FinalProjectileHit(caster, ability, targetLocation, projectile)
	end)
end

function FinalProjectileHit(caster, ability, position, projectile)
	local targetPoint = position
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("final_damage")
	local stun = ability:GetSpecialValueFor("stun")

	local particle_name = "particles/custom/tamamo/combo/final_orb_explosion.vpcf"

	Timers:CreateTimer(0.15, function()
		projectile:EmitSound("Fire_Explosion_Sound")
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        if IsValidEntity(v) and not v:IsNull() then
		        v:AddNewModifier(caster, nil, "modifier_stunned", { Duration = stun })

		        DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		    end
		end
	    projectile:SetAbsOrigin(targetPoint)

	    local explosion_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, projectile)
		ParticleManager:SetParticleControl(explosion_fx, 0, projectile:GetAbsOrigin())
		ParticleManager:SetParticleControl(explosion_fx, 1, Vector(radius, radius, radius))
		
	    Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( explosion_fx, false )
			ParticleManager:ReleaseParticleIndex(explosion_fx)
			projectile:RemoveSelf()
		end)
	end)
end

function OnSpiritTheftAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSpiritTheftAcquired) then

		hero.IsSpiritTheftAcquired = true

		if hero:HasModifier("modifier_curse_charm_check") then 
			UpgradeAttribute(hero, "tamamo_soulstream", "tamamo_soulstream_upgrade", false)
			UpgradeAttribute(hero, "tamamo_subterranean_grasp", "tamamo_subterranean_grasp_upgrade", false)
			if hero.IsWitchcraftAcquired then 
				UpgradeAttribute(hero, "tamamo_soulstream_fire_upgrade_2", "tamamo_soulstream_fire_upgrade_3", false)
				UpgradeAttribute(hero, "tamamo_soulstream_ice_upgrade_2", "tamamo_soulstream_ice_upgrade_3", false)
				UpgradeAttribute(hero, "tamamo_soulstream_wind_upgrade_2", "tamamo_soulstream_wind_upgrade_3", false)
			else
				UpgradeAttribute(hero, "tamamo_soulstream_fire", "tamamo_soulstream_fire_upgrade_1", false)
				UpgradeAttribute(hero, "tamamo_soulstream_ice", "tamamo_soulstream_ice_upgrade_1", false)
				UpgradeAttribute(hero, "tamamo_soulstream_wind", "tamamo_soulstream_wind_upgrade_1", false)
			end
		else
			local charm = false
			local ice = false
			local fire = false
			local wind = false

			if hero:HasModifier("modifier_fiery_heaven_indicator") then
				fire = true	
			elseif hero:HasModifier("modifier_frigid_heaven_indicator") then 
				ice = true
			elseif hero:HasModifier("modifier_gust_heaven_indicator") then 
				wind = true
			else
				charm = true
			end
			
			UpgradeAttribute(hero, "tamamo_subterranean_grasp", "tamamo_subterranean_grasp_upgrade", true)
			if hero.IsWitchcraftAcquired then 
				UpgradeAttribute(hero, "tamamo_soulstream_fire_upgrade_2", "tamamo_soulstream_fire_upgrade_3", fire)
				UpgradeAttribute(hero, "tamamo_soulstream_ice_upgrade_2", "tamamo_soulstream_ice_upgrade_3", ice)
				UpgradeAttribute(hero, "tamamo_soulstream_wind_upgrade_2", "tamamo_soulstream_wind_upgrade_3", wind)
			else
				UpgradeAttribute(hero, "tamamo_soulstream_fire", "tamamo_soulstream_fire_upgrade_1", fire)
				UpgradeAttribute(hero, "tamamo_soulstream_ice", "tamamo_soulstream_ice_upgrade_1", ice)
				UpgradeAttribute(hero, "tamamo_soulstream_wind", "tamamo_soulstream_wind_upgrade_1", wind)
			end
			UpgradeAttribute(hero, "tamamo_soulstream", "tamamo_soulstream_upgrade", charm)
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(caster:GetMana())
	end
end

function OnMysticShackleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMysticShackleAcquired) then

		hero.IsMysticShackleAcquired = true

		if hero:HasModifier("modifier_curse_charm_check") then 
			UpgradeAttribute(hero, "tamamo_mantra", "tamamo_mantra_upgrade", false)
		else
			UpgradeAttribute(hero, "tamamo_mantra", "tamamo_mantra_upgrade", true)
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(caster:GetMana())
	end
end

function OnPolygamistCastrationFistAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPolygamistCastrationFist2Acquired) then

		-- lvl 1
		if not hero.IsPolygamistCastrationFistAcquired then

			hero.IsPolygamistCastrationFistAcquired = true

			if hero:HasModifier("modifier_fiery_heaven_indicator") then
				hero:SwapAbilities("fate_empty1", "tamamo_poly_castration_fist_fire", false, true)
			elseif hero:HasModifier("modifier_frigid_heaven_indicator") then
				hero:SwapAbilities("fate_empty1", "tamamo_poly_castration_fist_ice", false, true)
			elseif hero:HasModifier("modifier_gust_heaven_indicator") then
				hero:SwapAbilities("fate_empty1", "tamamo_poly_castration_fist_wind", false, true)
			else 
				hero:SwapAbilities("fate_empty1", "tamamo_poly_castration_fist", false, true)
			end

			keys.ability:SetLevel(2)
			keys.ability:EndCooldown()
		else
			-- lvl 2
			hero.IsPolygamistCastrationFist2Acquired = true
			hero:FindAbilityByName("tamamo_poly_castration_fist"):SetLevel(2)
			hero:FindAbilityByName("tamamo_poly_castration_fist_fire"):SetLevel(2)
			hero:FindAbilityByName("tamamo_poly_castration_fist_ice"):SetLevel(2)
			hero:FindAbilityByName("tamamo_poly_castration_fist_wind"):SetLevel(2)
		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(caster:GetMana())
	end
end

function OnWitchcraftAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsWitchcraftAcquired) then

		hero.IsWitchcraftAcquired = true

		hero:FindAbilityByName("tamamo_witchcraft"):SetLevel(1)

		if hero:HasModifier("modifier_curse_charm_check") then 
			UpgradeAttribute(hero, "tamamo_curse_charm", "tamamo_curse_charm_upgrade", false)
			UpgradeAttribute(hero, "tamamo_fiery_heaven", "tamamo_fiery_heaven_upgrade", true)
			UpgradeAttribute(hero, "tamamo_frigid_heaven", "tamamo_frigid_heaven_upgrade", true)
			UpgradeAttribute(hero, "tamamo_gust_heaven", "tamamo_gust_heaven_upgrade", true)

			if hero.IsSpiritTheftAcquired then 
				UpgradeAttribute(hero, "tamamo_soulstream_fire_upgrade_1", "tamamo_soulstream_fire_upgrade_3", false)
				UpgradeAttribute(hero, "tamamo_soulstream_ice_upgrade_1", "tamamo_soulstream_ice_upgrade_3", false)
				UpgradeAttribute(hero, "tamamo_soulstream_wind_upgrade_1", "tamamo_soulstream_wind_upgrade_3", false)
			else
				UpgradeAttribute(hero, "tamamo_soulstream_fire", "tamamo_soulstream_fire_upgrade_2", false)
				UpgradeAttribute(hero, "tamamo_soulstream_ice", "tamamo_soulstream_ice_upgrade_2", false)
				UpgradeAttribute(hero, "tamamo_soulstream_wind", "tamamo_soulstream_wind_upgrade_2", false)
			end
		else
			UpgradeAttribute(hero, "tamamo_curse_charm", "tamamo_curse_charm_upgrade", true)
			UpgradeAttribute(hero, "tamamo_fiery_heaven", "tamamo_fiery_heaven_upgrade", false)
			UpgradeAttribute(hero, "tamamo_frigid_heaven", "tamamo_frigid_heaven_upgrade", false)
			UpgradeAttribute(hero, "tamamo_gust_heaven", "tamamo_gust_heaven_upgrade", false)
			local charm = false
			local ice = false
			local fire = false
			local wind = false

			if hero:HasModifier("modifier_fiery_heaven_indicator") then
				fire = true	
			elseif hero:HasModifier("modifier_frigid_heaven_indicator") then 
				ice = true
			elseif hero:HasModifier("modifier_gust_heaven_indicator") then 
				wind = true
			else
				charm = true
			end
			
			if hero.IsSpiritTheftAcquired then 
				UpgradeAttribute(hero, "tamamo_soulstream_fire_upgrade_1", "tamamo_soulstream_fire_upgrade_3", fire)
				UpgradeAttribute(hero, "tamamo_soulstream_ice_upgrade_1", "tamamo_soulstream_ice_upgrade_3", ice)
				UpgradeAttribute(hero, "tamamo_soulstream_wind_upgrade_1", "tamamo_soulstream_wind_upgrade_3", wind)
			else
				UpgradeAttribute(hero, "tamamo_soulstream_fire", "tamamo_soulstream_fire_upgrade_2", fire)
				UpgradeAttribute(hero, "tamamo_soulstream_ice", "tamamo_soulstream_ice_upgrade_2", ice)
				UpgradeAttribute(hero, "tamamo_soulstream_wind", "tamamo_soulstream_wind_upgrade_2", wind)
			end

		end

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(caster:GetMana())
	end
end

function OnTerritoryCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTerritoryCreationAcquired) then

		if hero:HasModifier("modifier_tamamo_combo_window") then 
			hero:RemoveModifierByName("modifier_tamamo_combo_window")
		end

		hero.IsTerritoryCreationAcquired = true

		UpgradeAttribute(hero, "tamamo_amaterasu", "tamamo_amaterasu_upgrade", true)

		NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(caster:GetMana())
	end
end
