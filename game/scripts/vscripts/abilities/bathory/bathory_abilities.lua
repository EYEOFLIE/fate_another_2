
function BathoryTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local currentHealth = caster:GetHealth()
	local backward = -caster:GetForwardVector()

	local max_damage = ability:GetSpecialValueFor("max_damage")
	local revive_health = ability:GetSpecialValueFor("revive_health")
	local dash_back = ability:GetSpecialValueFor("dash_back")

	if currentHealth <= 0 and ability:IsCooldownReady() and keys.DamageTaken <= max_damage and not caster:HasModifier("modifier_bathory_battle_continuation_cooldown")  and IsRevivePossible(caster) then
		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_battle_continuation_cooldown", {Duration = ability:GetCooldown(1)})

		ability:StartCooldown(ability:GetCooldown(1))
		local reviveFx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 3, caster:GetAbsOrigin())

		Timers:CreateTimer( 1, function()
			ParticleManager:DestroyParticle( reviveFx, false )
			ParticleManager:ReleaseParticleIndex( reviveFx)
		end)

		if IsReviveSeal(caster) then return end

		caster:SetHealth(revive_health)
		HardCleanse(caster)
		ProjectileManager:ProjectileDodge(caster)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.33)

		local dashback = Physics:Unit(caster)
		local origin = caster:GetOrigin()

		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(backward * dash_back * 3)
	   	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		
		Timers:CreateTimer( 0.33, function() 
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			HardCleanse(caster)
			ProjectileManager:ProjectileDodge(caster)
		end)	
	end
end

function OnInnocentStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_innocent", {})
	if caster.IsMentalAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_berserk", {})
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_innocent_cooldown", {Duration = ability:GetCooldown(1)})

	BathoryCheckCombo(caster,ability)
end

function OnInnocentCreate(keys)
	local caster = keys.caster 
	-- model change 
end

function OnInnocentDestroy(keys)
	local caster = keys.caster 
	-- model change 
end

function OnInnocentDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_bathory_innocent")
	if caster.IsMentalAcquired then 
		caster:RemoveModifierByName("modifier_bathory_berserk")
	end
end

function OnInnocentAttack(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_innocent_crit_hit", {})
end

function OnNightFlyStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")
	local distance = ability:GetSpecialValueFor("distance")
	local width = ability:GetSpecialValueFor("width")
	caster.nightfly_target = 0
	local NFProjectile = 
	{
		Ability = ability,
        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = distance,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}

	local projectile = ProjectileManager:CreateLinearProjectile(NFProjectile)
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK_EVENT, rate=1.0})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	--caster:EmitSound("Astolfo_Slide_" .. math.random(1,5))
	--caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local lancer = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*speed)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:EmitSound("Bathory.Skill1")

	if caster.IsTortureAcquired then 
		caster.nightfly = false
		caster.nightfly_girl = nil
	end

	Timers:CreateTimer("night_fly_dash" .. caster:GetPlayerOwnerID(), {
		endTime = 0.5,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		if caster.IsTortureAcquired and caster.nightfly then 
			caster.nightfly_girl:RemoveModifierByName("modifier_fly_girl")
		end
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("night_fly_dash" .. caster:GetPlayerOwnerID())
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		ProjectileManager:DestroyLinearProjectile(projectile)
		if caster.IsTortureAcquired and caster.nightfly then 
			caster.nightfly_girl:RemoveModifierByName("modifier_fly_girl")
		end
	end)

end

function OnNightFlyHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target == nil then return end

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if caster.IsTortureAcquired then
		if IsFemaleServant(target) and not caster.nightfly then 
			caster.nightfly = true
			if not IsImmuneToCC(target) then 
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fly_girl", {Duration = 0.5})
			end
			caster.nightfly_girl = target
		end
	end

	local damage = ability:GetSpecialValueFor("damage")
	local dmg_rdc = (100 - ability:GetSpecialValueFor("dmg_rdc"))/100
	local duration = ability:GetSpecialValueFor("duration")
	damage = damage * (dmg_rdc ^ caster.nightfly_target)

	if not IsImmuneToSlow(target) and not target:IsMagicImmune() then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_fly_slow", {})
	end

	if IsFemaleServant(target) then 
		damage = damage * (1 + GetSadismBonus(keys))
	end
	target:EmitSound("Hero_Sniper.AssassinateDamage")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
	caster.nightfly_target = caster.nightfly_target + 1
end

function OnNightFlyCatch(keys)
	local caster = keys.caster 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	target:SetAbsOrigin(caster:GetAbsOrigin())
end

function OnNightFlyCatchStop(keys)
	local target = keys.target 
	FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
end

function OnTailSlapStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ability:GetSpecialValueFor("dmg")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local stun_stack = ability:GetSpecialValueFor("stun_stack")
	local interval = 0.3
	local slap_counter = 0

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", (0.3 * total_hit) + 0.1)
	caster:EmitSound("Bathory.Skill2")

	Timers:CreateTimer('bathory_slap' .. caster:GetPlayerOwnerID(), {
		endTime = interval,
		callback = function()

		if slap_counter == total_hit or not caster:IsAlive() then return nil end

		slap_counter = slap_counter + 1

		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.0})

		local SmashFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_tail_slap.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(SmashFx, 0, target_loc) 

		Timers:CreateTimer(0.6, function()
			ParticleManager:DestroyParticle( SmashFx, true )
			ParticleManager:ReleaseParticleIndex( SmashFx )
		end)

		local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
		for _,enemy in pairs (enemies) do
			
			if IsValidEntity(enemy) and not enemy:IsNull() and not enemy:IsMagicImmune() and not IsImmuneToSlow(enemy) then
				ability:ApplyDataDrivenModifier(caster, enemy, "modifier_bathory_slap_slow", {})
				local stack = enemy:GetModifierStackCount("modifier_bathory_slap_slow", caster) or 0
				enemy:SetModifierStackCount("modifier_bathory_slap_slow", caster, math.min(stack + 1,stun_stack) )

				if stack + 1 >= stun_stack then 
					if not enemy:IsMagicImmune() and not IsImmuneToCC(enemy) and IsValidEntity(enemy) then
						enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
					end
				end
			end
			if IsFemaleServant(enemy) then 
				DoDamage(caster, enemy, dmg * (1 + GetSadismBonus(keys)), DAMAGE_TYPE_MAGICAL, 0, ability, false)
			else
				DoDamage(caster, enemy, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
			
		end
		return interval 
	end})
end

function OnIronMaidenCast(keys)
	local caster = keys.caster 
	if IsValidEntity(caster.ironmaiden) and caster.ironmaiden:IsAlive() then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Only_one_iron_maiden")
		return
	end
end

function OnIronMaidenStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local aoe = ability:GetSpecialValueFor("aoe")
	local delay = ability:GetSpecialValueFor("delay")
	local cage_health = ability:GetSpecialValueFor("cage_health")
	local duration = 0
	
	local IronMaidenFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_iron_maiden.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(IronMaidenFx, 0, target_loc + Vector(0,0,500)) 
	ParticleManager:SetParticleControl(IronMaidenFx, 1, target_loc) 
	ParticleManager:SetParticleControl(IronMaidenFx, 2, Vector(1.0,0,0)) 
	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(IronMaidenFx, true)
		ParticleManager:ReleaseParticleIndex(IronMaidenFx)
	end)
	Timers:CreateTimer(delay, function()
		if caster:IsAlive() then
			local min_duration = ability:GetSpecialValueFor("min_duration")
			local max_duration = ability:GetSpecialValueFor("max_duration")
			local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false )
			if enemies[1] ~= nil and IsValidEntity(enemies[1]) then 
				if IsImmuneToCC(enemies[1]) or IsBiggerUnit(enemies[1]) or enemies[1]:IsMagicImmune() then
					duration = min_duration
				else
					duration = max_duration
				end
				ability:ApplyDataDrivenModifier(caster, enemies[1], "modifier_bathory_cage_target", {Duration = duration})
				giveUnitDataDrivenModifier(caster, enemies[1], "revoked", duration)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_cage_check", {Duration = duration})
				----- create iron maiden dummy
				local ironmaiden = CreateUnitByName("bathory_iron_maiden", target_loc, false, caster, caster, caster:GetTeamNumber())
				ironmaiden:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
				--ironmaiden:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})
				ability:ApplyDataDrivenModifier(caster, ironmaiden, "modifier_bathory_cage_dummy", {Duration = duration})
				ironmaiden:SetMaxHealth(cage_health)
				ironmaiden:SetHealth(cage_health)
				--enemies[1]:SetAbsOrigin(ironmaiden:GetAbsOrigin())
				caster.ironmaiden = ironmaiden
				ironmaiden.targets = enemies[1]
				enemies[1].ironmaiden = ironmaiden
				--[[Timers:CreateTimer(duration + 0.1, function()
					if IsValidEntity(ironmaiden) then 
						ironmaiden:RemoveSelf()
						UTIL_Remove(ironmaiden)
					end
				end)]]
			end
		end
	end)
end

function OnIronMaidenCageStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 

	target:AddEffects(EF_NODRAW)
end

function OnIronMaidenThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local dps = ability:GetSpecialValueFor("dps")
	local hp_drain = ability:GetSpecialValueFor("hp_drain") / 100
	if IsFemaleServant(target) then 
		dps = dps * (1 + GetSadismBonus(keys))
	end
	if target.ironmaiden ~= nil and IsValidEntity(target.ironmaiden) and target.ironmaiden:IsAlive() and not target:HasModifier("jump_pause") and not target:HasModifier("modifier_quick_strikes") then
		DoDamage(caster, target, dps * 0.1, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
		caster:Heal(dps * hp_drain * 0.1, caster)
	else
		target:RemoveModifierByName("modifier_bathory_cage_target")
		target:RemoveModifierByName("revoked")
		--[[if IsValidEntity(target.ironmaiden) then 
			target.ironmaiden:RemoveSelf()
		end]]
		target.ironmaiden = nil
	end
end

function OnIronMaidenCageEnd(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 

	target:RemoveEffects(EF_NODRAW)
	target:RemoveModifierByName("revoked")
end

function OnIronMaidenDummyThink(keys)
	local caster = keys.caster 
	local target = keys.target 
	target.targets:SetAbsOrigin(target:GetAbsOrigin() + Vector(1,0,0))
end

function OnIronMaidenDeath(keys)
	local caster = keys.caster
	local target = keys.target 
	caster.ironmaiden.targets:RemoveModifierByName("modifier_bathory_cage_target")
	--[[if IsValidEntity(caster.ironmaiden) then 
 		caster.ironmaiden:RemoveSelf()
    	UTIL_Remove(caster.ironmaiden)
    end]]
end

function OnIronMaidenTargetDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_bathory_cage_check")
end

function OnIronMaidenDestroy(keys)
	local caster = keys.caster 
	--[[if IsValidEntity(caster.ironmaiden) then 
 		caster.ironmaiden:RemoveSelf()
    	UTIL_Remove(caster.ironmaiden)
    end]]
end

function OnLanceOff(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:ScriptLookupAttachment("attach_lance") ~= nil then 
		local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
		if lance ~= nil and not lance:IsNull() then lance:RemoveSelf() end
	end
	if caster:HasModifier("modifier_padoru") then 

	else
		if string.match(ability:GetAbilityName(), "bathory_combo_fresh_blood") then 
			if caster:HasModifier("modifier_alternate_01") then 
				caster:SetModel("models/bathory/school/bathory_schoolgirl_wing_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/school/bathory_schoolgirl_wing_by_zefiroft.vmdl")
				caster:SetModelScale(1.2)
			elseif caster:HasModifier("modifier_alternate_02") then 
				caster:SetModel("models/bathory/hunter/bathory_hunter_wing_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/hunter/bathory_hunter_wing_by_zefiroft.vmdl")
				caster:SetModelScale(1.2)
			else
				caster:SetModel("models/bathory/default/bathory_wing_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/default/bathory_wing_by_zefiroft.vmdl")
				caster:SetModelScale(1.15)
			end
		end
	end
end

function OnLanceOn(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:HasModifier("modifier_padoru") then 

	else
		if string.match(ability:GetAbilityName(), "bathory_combo_fresh_blood") then 
			if caster:HasModifier("modifier_alternate_01") then 
				caster:SetModel("models/bathory/school/bathory_schoolgirl_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/school/bathory_schoolgirl_by_zefiroft.vmdl")
				caster:SetModelScale(1.2)
			elseif caster:HasModifier("modifier_alternate_02") then 
				caster:SetModel("models/bathory/hunter/bathory_hunter_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/hunter/bathory_hunter_by_zefiroft.vmdl")
				caster:SetModelScale(1.2)
			else
				caster:SetModel("models/bathory/default/bathory_by_zefiroft.vmdl")
				caster:SetOriginalModel("models/bathory/default/bathory_by_zefiroft.vmdl")
				caster:SetModelScale(1.15)
			end
		end
	end
	if caster:ScriptLookupAttachment("attach_lance") ~= nil then 
		Attachments:AttachProp(caster, "attach_lance", "models/bathory/bathory_weapon.vmdl")  
	end 
end

function OnDragonCryStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local start_radius = ability:GetSpecialValueFor("start_radius")
	local end_radius = ability:GetSpecialValueFor("end_radius")
	local max_range = ability:GetSpecialValueFor("max_range")
	local speed = ability:GetSpecialValueFor("speed")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay + 1.2)
	StartAnimation(caster, {duration=cast_delay - 0.3, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_lance", {Duration = cast_delay + 1.2})

	if caster:HasModifier('modifier_alternate_02') then 
		EmitGlobalSound("Eli-R")
	else
		EmitGlobalSound("Bathory.Skill4_" .. math.random(1,2))
	end	
	
	Timers:CreateTimer(cast_delay - 0.3, function()
		StartAnimation(caster, {duration=1.3, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})
	end)

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then
			local sound = "Bathory.Voice_" .. math.random(1,2)
			EmitGlobalSound(sound)
			local waveFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_dragon_cry.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(waveFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(waveFx, 1, Vector(speed,0,0))
			ParticleManager:SetParticleControl(waveFx, 2, GetRotationPoint(caster:GetAbsOrigin(), max_range ,caster:GetAnglesAsVector().y))

			Timers:CreateTimer( 1.5, function()
				ParticleManager:DestroyParticle( waveFx, true )
				ParticleManager:ReleaseParticleIndex(waveFx)
			end)
			local dragoncry = 
			{
				Ability = ability,
		        EffectName = "particles/custom/bathory/bathory_dragon_cry_spiral.vpcf",
		        iMoveSpeed = speed,
		        vSpawnOrigin = caster:GetOrigin(),
		        fDistance = max_range - start_radius ,
		        fStartRadius = start_radius,
		        fEndRadius = end_radius,
		        Source = caster,
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        bVisibleToEnemies = true,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		        fExpireTime = GameRules:GetGameTime() + 2.0,
				bDeleteOnHit = false,
				vVelocity = caster:GetForwardVector() * speed
			}
			local cry_counter = 0
			Timers:CreateTimer(function()
				if caster:IsAlive() then
					if cry_counter < 10 then
						dragoncry.vSpawnOrigin = caster:GetAbsOrigin() 
						dragoncry.vVelocity = caster:GetForwardVector() * speed
						local projectile = ProjectileManager:CreateLinearProjectile(dragoncry)
						cry_counter = cry_counter + 1
						return 0.1 
					else
						return nil
					end
				else
					StopGlobalSound(sound)
					return nil
				end
			end)
		end
	end)
end

function OnDragonCryHit(keys)
	local caster = keys.caster
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = keys.ability 
	local total_damage = ability:GetSpecialValueFor("total_damage")
	if caster.IsDragonBreathAcquired then 
		local bonus_mana = ability:GetSpecialValueFor("bonus_mana") / 100
		total_damage = total_damage + (caster:GetMaxMana() * bonus_mana)
	end

	if target == nil then return end
	if IsFemaleServant(target) then 
		total_damage = total_damage * (1 + GetSadismBonus(keys))
	end
	if target:IsInvulnerable() and target:HasModifier("modifier_bathory_cage_target") then 
		DoDamage(caster, target, total_damage * 0.1 , DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
	elseif not target:IsInvulnerable() then
		
		if not target:IsMagicImmune() and not IsImmuneToCC(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_bathory_dragon_voice_slow", {Duration = 0.1})
		end
		if not target:HasModifier("modifier_bathory_dragon_voice_deaf") and not target:IsMagicImmune() then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_bathory_dragon_voice_deaf", {Duration = 0.1})
		end
		if caster.IsDragonBreathAcquired then 
			local distance = ability:GetSpecialValueFor("knock")
			if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < distance and not IsKnockbackImmune(target) and not IsImmuneToCC(target) then
				target:SetAbsOrigin(GetRotationPoint(target:GetAbsOrigin(), distance/10 ,caster:GetAnglesAsVector().y)) 
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
			end
		end

		DoDamage(caster, target, total_damage * 0.1 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnCharismaCreate(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability 

	if IsFemaleServant(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_bathory_charisma_girl", {})
	end
end

function OnCharismaDestroy(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability 

	if IsFemaleServant(target) then 
		target:RemoveModifierByName("modifier_bathory_charisma_girl")
	end
end


function BathoryCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "bathory_innocent") and not caster:HasModifier("modifier_bathory_combo_cooldown") then 
			if caster.IsDragonBreathAcquired then 
				if caster:FindAbilityByName("bathory_dragon_cry_upgrade"):IsCooldownReady() and caster:FindAbilityByName("bathory_combo_fresh_blood_upgrade"):IsCooldownReady()  then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_bloody_window", {})
				end
			else
				if caster:FindAbilityByName("bathory_dragon_cry"):IsCooldownReady() and caster:FindAbilityByName("bathory_combo_fresh_blood"):IsCooldownReady() then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_bloody_window", {})
				end
			end
		end
	end
end

function OnBloodWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsDragonBreathAcquired then 
		caster:SwapAbilities("bathory_dragon_cry_upgrade", "bathory_combo_fresh_blood_upgrade", false, true)
	else
		caster:SwapAbilities("bathory_dragon_cry", "bathory_combo_fresh_blood", false, true)
	end
end

function OnBloodWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsDragonBreathAcquired then 
		caster:SwapAbilities("bathory_dragon_cry_upgrade", "bathory_combo_fresh_blood_upgrade", true, false)
	else
		caster:SwapAbilities("bathory_dragon_cry", "bathory_combo_fresh_blood", true, false)
	end
end

function OnBloodWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_bathory_bloody_window")
end

function GetSadismBonus(keys)
	local caster = keys.caster 
	local sadism = caster:FindAbilityByName("bathory_charisma")
	local bonus_female = sadism:GetSpecialValueFor("bonus_female")/100 

	if caster.IsSadismAcquired then
		return bonus_female
	else
		return 0
	end
end

function OnFreshBloodStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local start_radius = ability:GetSpecialValueFor("start_radius")
	local end_radius = ability:GetSpecialValueFor("end_radius")
	local max_range = ability:GetSpecialValueFor("max_range")
	local speed = ability:GetSpecialValueFor("speed")
	local debuff_stack = ability:GetSpecialValueFor("debuff_stack")

	local masterCombo = caster.MasterUnit2:FindAbilityByName("bathory_combo_fresh_blood")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_combo_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster:RemoveModifierByName("modifier_bathory_bloody_window")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay - 1.2)
	StartAnimation(caster, {duration=cast_delay - 1.2, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
	EmitGlobalSound("Bathory.Precombo")

	local dragonvoice = caster:FindAbilityByName("bathory_dragon_cry")
	if dragonvoice == nil then 
		dragonvoice = caster:FindAbilityByName("bathory_dragon_cry_upgrade")
	end

	dragonvoice:StartCooldown(dragonvoice:GetCooldown(dragonvoice:GetLevel()))

	local ascendCount = 0
	local descendCount = 0

	Timers:CreateTimer(cast_delay - 1.2, function()

		local angle = caster:GetAnglesAsVector().y
		giveUnitDataDrivenModifier(caster, caster, "jump_pause", cast_delay)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bathory_lance", {Duration = cast_delay})
		StartAnimation(caster, {duration=cast_delay, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})
		
		local magic_loc = GetRotationPoint(caster:GetAbsOrigin(), 100 ,angle)
		local MCFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_magic_circle.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(MCFx, 0, magic_loc + Vector(0,0,20)) 

		local castle_loc = GetRotationPoint(caster:GetAbsOrigin(), 500 , angle + 180)
		local CastleFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_castle.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(CastleFx, 0, castle_loc + Vector(0,0,-500)) 
		ParticleManager:SetParticleControl(CastleFx, 1, castle_loc) 
		ParticleManager:SetParticleControl(CastleFx, 2, Vector(cast_delay,0,0)) 
		ParticleManager:SetParticleControl(CastleFx, 3, Vector(0,0,angle + 90)) 

		Timers:CreateTimer('fbd_ascend', {
			endTime = 0,
			callback = function()
		   	if ascendCount == 10 then return end
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,10))
			ascendCount = ascendCount + 1;
			return 0.033
		end
		})

		Timers:CreateTimer("fbd_descend", {
		    endTime = cast_delay,
		    callback = function()
		    	if descendCount == 10 then return end
				caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,-10))
				descendCount = descendCount + 1;
		      	return 0.033
		    end
		})

		Timers:CreateTimer(cast_delay, function()
			ParticleManager:DestroyParticle(CastleFx, true)
			ParticleManager:ReleaseParticleIndex(CastleFx)
			ParticleManager:DestroyParticle(MCFx, true)
			ParticleManager:ReleaseParticleIndex(MCFx)
			
			caster:RemoveModifierByName("modifier_bathory_lance")
		end)
	end)

	Timers:CreateTimer(cast_delay, function()
		if caster:IsAlive() then
			local freshblood = 
			{
				Ability = ability,
		        EffectName = "particles/custom/bathory/bathory_fresh_blood_spiral.vpcf",
		        iMoveSpeed = speed,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        fDistance = max_range - start_radius ,
		        fStartRadius = start_radius,
		        fEndRadius = end_radius,
		        Source = caster,
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        bVisibleToEnemies = true,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		        fExpireTime = GameRules:GetGameTime() + 2.0,
				bDeleteOnHit = false,
				vVelocity = caster:GetForwardVector() * speed
			}
			local dmg_counter = 0
			EmitGlobalSound("Bathory.Combo")
			local sound = "Bathory.Voice_" .. math.random(1,2)
			EmitGlobalSound(sound)

			local waveFx = ParticleManager:CreateParticle("particles/custom/bathory/bathory_dragon_cry.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(waveFx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(waveFx, 1, Vector(speed,0,0))
			ParticleManager:SetParticleControl(waveFx, 2, GetRotationPoint(caster:GetAbsOrigin(), max_range ,caster:GetAnglesAsVector().y))

			Timers:CreateTimer( 1.5, function()
				ParticleManager:DestroyParticle( waveFx, true )
				ParticleManager:ReleaseParticleIndex(waveFx)
			end)
			local cry_counter = 0
			Timers:CreateTimer(function()
				if caster:IsAlive() then
					if cry_counter < 10 then
						freshblood.vSpawnOrigin = caster:GetAbsOrigin() 
						freshblood.vVelocity = caster:GetForwardVector() * speed
						local projectile = ProjectileManager:CreateLinearProjectile(freshblood)
						cry_counter = cry_counter + 1
						return 0.1 
					else
						return nil
					end
				else
					StopGlobalSound(sound)
					return nil
				end
			end)
		end
	end)
end

function OnFreshBloodHit(keys)
	local caster = keys.caster
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = keys.ability 
	local total_damage = ability:GetSpecialValueFor("total_damage")
	local debuff_stack = ability:GetSpecialValueFor("debuff_stack")
	if caster.IsDragonBreathAcquired then 
		local bonus_mana = ability:GetSpecialValueFor("bonus_mana") / 100
		total_damage = total_damage + (caster:GetMaxMana() * bonus_mana)
	end

	if target == nil then return end
	if IsFemaleServant(target) then 
		total_damage = total_damage * (1 + GetSadismBonus(keys))
	end
	if target:IsInvulnerable() and target:HasModifier("modifier_bathory_cage_target") then 
		DoDamage(caster, target, total_damage / debuff_stack , DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
	elseif not target:IsInvulnerable() then
		
		if not target:HasModifier("modifier_bathory_fresh_blood_count") then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_bathory_fresh_blood_count", {Duration = 1})
		end
		local stack = target:GetModifierStackCount("modifier_bathory_fresh_blood_count", caster) or 0
		target:SetModifierStackCount("modifier_bathory_fresh_blood_count", caster, math.min(debuff_stack, stack + 1) )
		if stack + 1 >= debuff_stack then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_bathory_fresh_blood_debuff", {})
			ApplyStrongDispel(target)
			target:RemoveModifierByName("modifier_bathory_fresh_blood_count")
		end

		if caster.IsDragonBreathAcquired then 
			local distance = ability:GetSpecialValueFor("knock")
			if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < distance and not IsKnockbackImmune(target) and not IsImmuneToCC(target) then
				target:SetAbsOrigin(GetRotationPoint(target:GetAbsOrigin(), distance/10 ,caster:GetAnglesAsVector().y)) 
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
			end
		end

		DoDamage(caster, target, total_damage / debuff_stack , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnTerritoryCreationAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTerritoryCreationAcquired) then

		hero.IsTerritoryCreationAcquired = true

		hero:FindAbilityByName("bathory_territory"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDragonBreathAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDragonBreathAcquired) then

		hero.IsDragonBreathAcquired = true

		UpgradeAttribute(hero, "bathory_combo_fresh_blood", "bathory_combo_fresh_blood_upgrade", false)
		UpgradeAttribute(hero, "bathory_dragon_cry", "bathory_dragon_cry_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMentalAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMentalAcquired) then

		hero.IsMentalAcquired = true

		UpgradeAttribute(hero, "bathory_innocent", "bathory_innocent_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSadismAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSadismAcquired) then

		hero.IsSadismAcquired = true

		hero:FindAbilityByName("bathory_charisma"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnTortureAcquired (keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTortureAcquired) then

		hero.IsTortureAcquired = true

		UpgradeAttribute(hero, "bathory_fly", "bathory_fly_upgrade", true)
		UpgradeAttribute(hero, "bathory_iron_maiden", "bathory_iron_maiden_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end