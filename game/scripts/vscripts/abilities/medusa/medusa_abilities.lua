
function MysticEyeCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and IsFacingUnit(v, caster, 120) then
			if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then
				if caster.IsMysticEyeImproved then
					ability:ApplyDataDrivenModifier(caster,v, "modifier_mystic_eye_enemy_upgrade", {})
				else
					ability:ApplyDataDrivenModifier(caster,v, "modifier_mystic_eye_enemy", {})
				end
			end
		end
	end
end

function OnMysticEyeStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster,caster, "modifier_mystic_eye_cooldown", {Duration = ability:GetCooldown(1)})
	caster:RemoveModifierByName("modifier_mystic_eye_passive")
	ability:ApplyDataDrivenModifier(caster,caster, "modifier_mystic_eye_active", {})
end

function OnMysticEyeActiveEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster, "modifier_mystic_eye_passive", {})
end

function OnMonstrousStrengthProc(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local proc_damage = ability:GetSpecialValueFor("proc_damage")
	if ability:IsCooldownReady() then
		if target:HasModifier("modifier_breaker_gorgon_stone") then
			proc_damage = ability:GetSpecialValueFor("proc_damage_2")
		end

		DoDamage(caster, target, proc_damage , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
end

function NailPull(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local drag = ability:GetSpecialValueFor("drag_duration")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
	RiderCheckCombo(caster, ability)
	caster:EmitSound("Rider.NailSwing")
	
	-- Create Particle
	local pullFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_nail_swing.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pullFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pullFxIndex, 1, Vector( radius, radius, radius ) )
	-- Destroy particle
	Timers:CreateTimer( 1.5, function()
		ParticleManager:DestroyParticle( pullFxIndex, false )
		ParticleManager:ReleaseParticleIndex( pullFxIndex )
	end)

	for k,v in pairs(targets) do
		if string.match(v:GetName(), "ward") or not IsValidEntity(v) or v:IsNull() or not v:IsAlive() then 
			goto excludetarget 
		end

		DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)

		if v:IsRealHero() then 
			if IsKnockbackImmune(v) or IsImmuneToCC(v) then 
				goto excludetarget 
			end

			v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.033 })
			giveUnitDataDrivenModifier(caster, v, "dragged", drag)
				
			local pullTarget = Physics:Unit(v)
			v:PreventDI()
			v:SetPhysicsFriction(0)
			v:SetPhysicsVelocity((caster:GetAbsOrigin() - v:GetAbsOrigin()):Normalized() * 1000)
			v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
			v:FollowNavMesh(false)

			Timers:CreateTimer(drag, function()
				v:PreventDI(false)
				v:SetPhysicsVelocity(Vector(0,0,0))
				v:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
			end)

			v:OnPhysicsFrame(function(unit)
				local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
				local dir = diff:Normalized()
				unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
				if diff:Length() < 50 then
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
				end
			end)
		else
			if not IsValidEntity(v) or v:IsNull() or not v:IsAlive() or IsImmuneToCC(v) then 
				goto excludetarget 
			end

			v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.033 })
			giveUnitDataDrivenModifier(caster, v, "dragged", drag)
				
			local pullTarget = Physics:Unit(v)
			v:PreventDI()
			v:SetPhysicsFriction(0)
			v:SetPhysicsVelocity((caster:GetAbsOrigin() - v:GetAbsOrigin()):Normalized() * 1000)
			v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
			v:FollowNavMesh(false)

			Timers:CreateTimer(drag, function()
				if IsValidEntity(v) and not v:IsNull() then 
					v:PreventDI(false)
					v:SetPhysicsVelocity(Vector(0,0,0))
					v:OnPhysicsFrame(nil)
					FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
				end
				
			end)

			v:OnPhysicsFrame(function(unit)
				if IsValidEntity(v) and not v:IsNull() then
					local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
					local dir = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
					if diff:Length() < 50 then
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
					end
				end
				
			end)
		end

		--[[if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			if not IsKnockbackImmune(v) and not IsImmuneToCC(v) then
				v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.033 })
				giveUnitDataDrivenModifier(caster, v, "dragged", drag)
				
				local pullTarget = Physics:Unit(v)
				v:PreventDI()
				v:SetPhysicsFriction(0)
				v:SetPhysicsVelocity((caster:GetAbsOrigin() - v:GetAbsOrigin()):Normalized() * 1000)
				v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
				v:FollowNavMesh(false)

				Timers:CreateTimer(drag_duration, function()
					if IsValidEntity(v) then
						v:PreventDI(false)
						v:SetPhysicsVelocity(Vector(0,0,0))
						v:OnPhysicsFrame(nil)
						FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
					end
				end)

				v:OnPhysicsFrame(function(unit)
					local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
					local dir = diff:Normalized()
					unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
					if diff:Length() < 50 then
						if IsValidEntity(unit) then
							unit:PreventDI(false)
							unit:SetPhysicsVelocity(Vector(0,0,0))
							unit:OnPhysicsFrame(nil)
						end
					end
				end)
			end
		end]]
		::excludetarget::
	end
end

function OnDashStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")
	local distance = ability:GetSpecialValueFor("distance")
	local width = ability:GetSpecialValueFor("width")
	local dur = distance / speed
	local dash = 
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

	local projectile = ProjectileManager:CreateLinearProjectile(dash)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	StartAnimation(caster, {duration=dur, activity=ACT_DOTA_RUN, rate=1.5})
	
	local dashFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( dashFxIndex, 0, caster:GetAbsOrigin() + Vector(0,0,50) )

	--caster:EmitSound("Astolfo_Slide_" .. math.random(1,5))
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local rider = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*speed)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("medusa_dash" .. caster:GetPlayerOwnerID(), {
		endTime = dur,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(dashFxIndex, true)
		ParticleManager:ReleaseParticleIndex(dashFxIndex)
		if caster.IsRidingAcquired then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_medusa_riding_passive", {})
		end
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("medusa_dash" .. caster:GetPlayerOwnerID())
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		ProjectileManager:DestroyLinearProjectile(projectile)
		ParticleManager:DestroyParticle(dashFxIndex, true)
		ParticleManager:ReleaseParticleIndex(dashFxIndex)
		if caster.IsRidingAcquired then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_medusa_riding_passive", {})
		end
	end)

end

function OnDashHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end

	local damage = ability:GetSpecialValueFor("damage") / 100 * caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false)

	target:EmitSound("Hero_Sniper.AssassinateDamage")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnBGStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local silence = ability:GetSpecialValueFor("silence")
	RiderCheckCombo(caster, ability)

	if caster:HasModifier('modifier_alternate_01') or caster:HasModifier('modifier_alternate_02') or caster:HasModifier('modifier_alternate_03') or caster:HasModifier('modifier_alternate_04') then 
		caster:EmitSound("Rider.Lily.BreakerGorgon")
	else
		caster:EmitSound("Medusa_Skill1")
	end

    local pcGlyph = ParticleManager:CreateParticle("particles/custom/rider/rider_breaker_gorgon_mark.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(pcGlyph, 0, targetPoint) 
    ParticleManager:ReleaseParticleIndex(pcGlyph)

    if caster.IsSealAcquired then
        local pcLight = ParticleManager:CreateParticle("particles/custom/rider/rider_breaker_gorgon_mark_attr.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(pcLight, 0, targetPoint) 
        ParticleManager:ReleaseParticleIndex(pcLight)
    end

	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		v:AddNewModifier(caster, nil, "modifier_silence", {Duration=silence})
		if not IsValidEntity(v) or v:IsNull() or IsImmuneToSlow(v) or IsImmuneToCC(v) or v:IsMagicImmune() then 
			goto excludetarget 
		end
		
		if caster.IsMysticEyeImproved then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_breaker_gorgon_upgrade", {}) 
			if v:HasModifier("modifier_mystic_eye_enemy_active") then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_breaker_gorgon_stone", {}) 
			end
		else
			ability:ApplyDataDrivenModifier(caster, v, "modifier_breaker_gorgon", {}) 
		end
		::excludetarget::
	end
end

-- Show particle on start
function OnBloodfortCast( keys )
	local caster = keys.caster
	local ability = keys.ability 

	ability:EndCooldown()
	caster:GiveMana(ability:GetManaCost(1))

	caster.sparkFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_emp_charge.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( caster.sparkFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( caster.sparkFxIndex, 1, caster:GetAbsOrigin() )

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bloodfort_tracker", {Duration=ability:GetSpecialValueFor("delay") - 0.04})

end

function OnBloodfortInterrupt(keys)
	local caster = keys.caster
	local ability = keys.ability 
	ParticleManager:DestroyParticle( caster.sparkFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.sparkFxIndex )
end

function OnBloodfortStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_bloodfort_tracker") then 
		OnBloodfortInterrupt(keys)
		return nil 
	end
	
	ParticleManager:DestroyParticle( caster.sparkFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.sparkFxIndex )

	if caster:GetMana() < ability:GetManaCost(1) then 
		return 
	end

	ability:StartCooldown(ability:GetCooldown(1))
	caster:SpendMana(ability:GetManaCost(1), ability)
	ability:ApplyDataDrivenModifier(caster,caster, "modifier_bloodfort_cooldown", {Duration = ability:GetCooldown(1)})

	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local seal_interval = ability:GetSpecialValueFor("seal_interval")
	local suck_counter = 1
	local damage = ability:GetSpecialValueFor("damage")
	local absorb = ability:GetSpecialValueFor("absorb")
	local mp_absorb = ability:GetSpecialValueFor("mp_absorb")
	local center = caster:GetAbsOrigin() 

	if caster:HasModifier('modifier_alternate_01') or caster:HasModifier('modifier_alternate_02') or caster:HasModifier('modifier_alternate_03') or caster:HasModifier('modifier_alternate_04') then 
		caster:EmitSound("Rider.Lily.BloodFort")
	else
		caster:EmitSound("Medusa_Skill2")
	end

	--[[local dummy = CreateUnitByName("dummy_unit", initCasterPoint, false, nil, nil, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_bloodfort_aura", {})
	if caster.IsSealAcquired then 
		ability:ApplyDataDrivenModifier(caster, dummy, "modifier_bloodfort_seal_aura", {})
	end]]

	-- Create Particle
	local sphereFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_spirit.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( sphereFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( sphereFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( sphereFxIndex, 6, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( sphereFxIndex, 10, Vector( radius, radius, radius ) )

	Timers:CreateTimer('medusa_bloodfort' .. caster:GetPlayerOwnerID(), {
		endTime = seal_interval,
		callback = function()
		if not caster:IsAlive() or suck_counter >= duration then 
			ParticleManager:DestroyParticle( sphereFxIndex, true )
			ParticleManager:ReleaseParticleIndex( sphereFxIndex )
			return nil
		end

		local targets = FindUnitsInRadius(caster:GetTeam(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if not IsValidEntity(v) or string.match(v:GetName(), "ward") or v:IsNull() or v:IsMagicImmune() then 
				goto excludetarget 
			end
			
			if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
				ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_slow", {}) 
			end

			v:SpendMana(mp_absorb, ability)
				
			caster:ApplyHeal(absorb, caster)
			caster:GiveMana(mp_absorb)

			if caster.IsSealAcquired then 
				local charm = ability:GetSpecialValueFor("charm")
				local forcemove = {
					UnitIndex = v:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
					Position = center
				}
				ExecuteOrderFromTable(forcemove) 
				Timers:CreateTimer(charm/2, function()
					if IsValidEntity(v) and not v:IsNull() then
						v:Stop()
					end
				end)
				if not IsImmuneToCC(v) then
					ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_seal", {})
				end
			end

			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

			::excludetarget::
		end

		suck_counter = suck_counter + 1
		return 1
	end})

	--[[Timers:CreateTimer( duration, function()
		ParticleManager:DestroyParticle( sphereFxIndex, false )
		ParticleManager:ReleaseParticleIndex( sphereFxIndex )
		if IsValidEntity(dummy) then
			dummy:RemoveSelf()
		end
	end) ]]
end

function OnBloodfortSuck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local center = keys.target
	if not caster:IsAlive() then return end
	--if target == nil then return end
	local damage = ability:GetSpecialValueFor("damage")
	local absorb = ability:GetSpecialValueFor("absorb")
	local mp_absorb = ability:GetSpecialValueFor("mp_absorb")
	local radius = ability:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius(caster:GetTeam(), center:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if v:GetName() ~= "npc_dota_ward_base" and not v:IsMagicImmune() and IsValidEntity(v) and not v:IsNull() then
			if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
				ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_slow", {}) 
			end

			v:SpendMana(mp_absorb, ability)
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			
			caster:ApplyHeal(absorb, caster)
			caster:SetMana(caster:GetMana() + mp_absorb)
			if caster.IsSealAcquired then 
				local forcemove = {
					UnitIndex = v:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
					Position = center:GetAbsOrigin()
				}
				ExecuteOrderFromTable(forcemove) 
				Timers:CreateTimer(0.1, function()
					v:Stop()
				end)
				if not IsImmuneToCC(v) then
					ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_seal", {})
				end
			end
		end
	end
end

function OnBloodfortSeal (keys)
	local caster = keys.caster
	local ability = keys.ability
	local center = keys.target
	local target = keys.unit 
	if not caster:IsAlive() then return end
	if target == nil then return end
	if target:GetName() ~= "npc_dota_ward_base" and not target:IsMagicImmune() then

		local forcemove = {
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
			Position = center:GetAbsOrigin()
		}
		ExecuteOrderFromTable(forcemove) 
		Timers:CreateTimer(0.1, function()
			target:Stop()
		end)
		ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_seal", {})
	end
end

function OnBloodfortDeath(keys)
	local caster = keys.caster 
	local target = keys.target 
	target:RemoveSelf()
end


-- Particle for starting to cast belle2
function OnBelle2Cast( keys )
	local caster = keys.caster
	local ability = keys.ability 

	ability:EndCooldown()
	caster:GiveMana(ability:GetManaCost(1))
	EmitGlobalSound("Medusa_Pre_Combo") 

	caster.chargeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_emp_charge.vpcf", PATTACH_ABSORIGIN, caster )
	caster.eyeFxIndex = ParticleManager:CreateParticle( "particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN, caster )

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bellerophon_2_tracker", {Duration=ability:GetSpecialValueFor("cast_delay") - 0.04})
end

function OnBelle2Interrupt(keys)
	local caster = keys.caster
	local ability = keys.ability 
	ParticleManager:DestroyParticle( caster.chargeFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.chargeFxIndex )
	ParticleManager:DestroyParticle( caster.eyeFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.eyeFxIndex )
	StopGlobalSound("Medusa_Pre_Combo")
end

function OnBelle2Start(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_bellerophon_2_tracker") then 
		OnBelle2Interrupt(keys)
		return nil 
	end

	caster:FindAbilityByName(caster.WSkill):StartCooldown(caster:FindAbilityByName(caster.WSkill):GetCooldown(caster:FindAbilityByName(caster.WSkill):GetLevel()))
	
	ParticleManager:DestroyParticle( caster.chargeFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.chargeFxIndex )
	ParticleManager:DestroyParticle( caster.eyeFxIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.eyeFxIndex )

	ability:StartCooldown(ability:GetCooldown(1))
	caster:SpendMana(ability:GetManaCost(1), ability)

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("medusa_bellerophon_2")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bellerophon_2_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	if caster:HasModifier("modifier_belle_2_window") then 
		caster:RemoveModifierByName("modifier_belle_2_window")
	end

	local width = ability:GetSpecialValueFor("width")
	local speed = ability:GetSpecialValueFor("speed")
	local range = ability:GetSpecialValueFor("range")
	local delay = ability:GetSpecialValueFor("cast_delay") - ability:GetChannelTime()

	if caster:HasModifier('modifier_alternate_01') or caster:HasModifier('modifier_alternate_03') or caster:HasModifier('modifier_alternate_03') or caster:HasModifier('modifier_alternate_04') then 
		EmitGlobalSound("Rider.Lily.Bellerophon") 
	else
		EmitGlobalSound("medusa_bellerophon_alt") 
	end
	
	
	-- Create Particle for projectile
	local belle2FxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_2_beam_charge.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( belle2FxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( belle2FxIndex, 1, Vector( width, width, width ) )
	ParticleManager:SetParticleControl( belle2FxIndex, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( belle2FxIndex, 6, Vector( 3, 0, 0 ) )

	local pegasusFx = ParticleManager:CreateParticle( "particles/custom/medusa/medusa_pegasus_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pegasusFx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pegasusFx, 1, Vector(0,0,caster:GetAnglesAsVector().y + 90) )
			
	Timers:CreateTimer( delay + (range/speed), function()
		ParticleManager:DestroyParticle( belle2FxIndex, false )
		ParticleManager:ReleaseParticleIndex( belle2FxIndex )
		ParticleManager:DestroyParticle( pegasusFx, true )
		ParticleManager:ReleaseParticleIndex( pegasusFx )
	end)

	StartAnimation(caster, {duration=delay + (range/speed), activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", delay + (range/speed))

	Timers:CreateTimer("belle2" .. caster:GetPlayerOwnerID(), {
		endTime = delay,
		callback = function()
		if not caster:IsAlive() then 
			ParticleManager:DestroyParticle( belle2FxIndex, false )
			ParticleManager:ReleaseParticleIndex( belle2FxIndex )
			ParticleManager:DestroyParticle( pegasusFx, true )
			ParticleManager:ReleaseParticleIndex( pegasusFx )
			return 
		end
		ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
		ParticleManager:SetParticleControl( belle2FxIndex, 2, caster:GetForwardVector() * speed )
		caster.belle2_forward = caster:GetForwardVector()
		local belle2 = 
		{
			Ability = ability,
	        EffectName = "",
	        iMoveSpeed = speed,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        fDistance = range - width + 200,
	        fStartRadius = width,
	        fEndRadius = width,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	        fExpireTime = GameRules:GetGameTime() + 1.0,
			bDeleteOnHit = false,
			vVelocity = caster.belle2_forward * speed
		}

		local projectile = ProjectileManager:CreateLinearProjectile(belle2)
		
		local belle = Physics:Unit(caster)
		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(caster.belle2_forward*speed)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)

		Timers:CreateTimer(range/speed, function()
			caster:OnPhysicsFrame(nil)
			caster:OnHibernate(nil)
			caster:OnPreBounce(nil)
			caster:SetAutoUnstuck(true)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			if caster.IsRidingAcquired then
				caster:FindAbilityByName(caster.WSkill):ApplyDataDrivenModifier(caster, caster, "modifier_medusa_riding_passive", {})
			end
		end)
	end})

	--[[locationDelta = caster:GetForwardVector() * keys.Range
	newLocation = caster:GetAbsOrigin() + locationDelta
	for i=1, 20 do
		if GridNav:IsBlocked(newLocation) or not GridNav:IsTraversable(newLocation) then
			--locationDelta =  caster:GetForwardVector() * (keys.Range - 100)
			newLocation = caster:GetAbsOrigin() + caster:GetForwardVector() * (20 - i) * 100
			if not IsInSameRealm(caster:GetAbsOrigin(), newLocation) then
				newLocation.y = caster:GetAbsOrigin().y
			end
		else
			break
		end
	end 
	caster:SetAbsOrigin(newLocation) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)]]
end

function OnBelle2Hit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stun = ability:GetSpecialValueFor("stun")
	local damage = ability:GetSpecialValueFor("damage")
	local wall_damage = ability:GetSpecialValueFor("wall_damage")
	local speed = ability:GetSpecialValueFor("speed")

	if caster.IsRidingAcquired then 
		local agi_ratio = ability:GetSpecialValueFor("agi_ratio")
		damage = damage + (caster:GetAgility() * agi_ratio)
	end 

	--[[if IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun * 0.5 })
	else
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
	end]]
	target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)

	if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then 
		local bell = caster:FindModifierByName("jump_pause")
		local duration = bell:GetRemainingTime()

		local knock = Physics:Unit(target)
		target:PreventDI()
		target:SetPhysicsFriction(0)
		target:SetPhysicsVelocity(caster.belle2_forward*speed)
		target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		--target:FollowNavMesh(false)	
	    --target:SetAutoUnstuck(false)
		giveUnitDataDrivenModifier(caster, target, "dragged", duration)

		target:OnPreBounce(function(unit, normal) 
			target:SetAutoUnstuck(false)
			target:SetPhysicsVelocity(caster.belle2_forward*speed)
			DoDamage(caster, unit, wall_damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)

			print('hit wall')
		end)

		Timers:CreateTimer(duration, function()
			target:OnPhysicsFrame(nil)
			target:OnHibernate(nil)
			target:OnPreBounce(nil)
			target:SetAutoUnstuck(true)
			target:SetBounceMultiplier(0)
			target:PreventDI(false)
			target:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		end)
	end
end

function RiderCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), caster.QSkill) then
			caster.QUsed = true
			caster.QTime = GameRules:GetGameTime()
			if caster.QTimer ~= nil then 
				Timers:RemoveTimer(caster.QTimer)
				caster.QTimer = nil
			end
			caster.QTimer = Timers:CreateTimer(7.0, function()
				caster.QUsed = false
			end)
		else
			if string.match(ability:GetAbilityName(), caster.ESkill) then
				if caster:FindAbilityByName(caster.WSkill):IsCooldownReady() and not caster:HasModifier("modifier_bellerophon_2_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 7 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_belle_2_window", {duration = duration})
					end
				end
			end
		end
	end
end

function OnBelle2WindowCreate(keys)
	local caster = keys.caster 
	if caster.IsRidingAcquired then
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "medusa_bellerophon_2_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), "medusa_bellerophon_2", false, true)
	end
end

function OnBelle2WindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.WSkill, caster:GetAbilityByIndex(1):GetAbilityName(), true, false)	
end

function OnBelle2WindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_belle_2_window")
end

function OnImproveMysticEyesAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMysticEyeImproved) then
	
		hero.IsMysticEyeImproved = true

		UpgradeAttribute(hero, 'medusa_mystic_eye', 'medusa_mystic_eye_upgrade', true)
		UpgradeAttribute(hero, 'medusa_breaker_gorgon', 'medusa_breaker_gorgon_upgrade', true)
		hero.FSkill = "medusa_mystic_eye_upgrade"
		hero.ESkill = "medusa_breaker_gorgon_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnRidingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRidingAcquired) then

		if hero:HasModifier("modifier_belle_2_window") then 
			hero:RemoveModifierByName("modifier_belle_2_window")
		end

		hero.IsRidingAcquired = true

		--hero:FindAbilityByName("medusa_riding_passive"):SetLevel(1)

		UpgradeAttribute(hero, 'medusa_bellerophon', 'medusa_bellerophon_upgrade', true)
		UpgradeAttribute(hero, 'medusa_highspeed', 'medusa_highspeed_upgrade', true)
		UpgradeAttribute(hero, 'medusa_bellerophon_2', 'medusa_bellerophon_2_upgrade', false)

		hero.WSkill = "medusa_highspeed_upgrade"
		hero.RSkill = "medusa_bellerophon_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSealAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSealAcquired) then

		if hero:HasModifier("modifier_belle_2_window") then 
			hero:RemoveModifierByName("modifier_belle_2_window")
		end

		hero.IsSealAcquired = true

		
		UpgradeAttribute(hero, 'medusa_bloodfort_andromeda', 'medusa_bloodfort_andromeda_upgrade', true)
		hero.DSkill = "medusa_bloodfort_andromeda_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMonstrousStrengthAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMonstrousStrengthAcquired) then

		hero.IsMonstrousStrengthAcquired = true

		hero:FindAbilityByName("medusa_monstrous_strength_passive"):SetLevel(1)
		UpgradeAttribute(hero, 'medusa_nail_swing', 'medusa_nail_swing_upgrade', true)
		hero.FSkill = "medusa_nail_swing_upgrade"
		--hero:SwapAbilities("medusa_monstrous_strength_passive", "fate_empty1", true, false) 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

--ATTEMPT ON LUA

modifier_belle_hit_check = class({})
function modifier_belle_hit_check:IsHidden()
	return true 
end

function modifier_belle_hit_check:RemoveOnDeath()
	return true
end

function modifier_belle_hit_check:GetDuration()
	return 0.11
end

LinkLuaModifier("modifier_belle_hit_check", "abilities/medusa/medusa_abilities", LUA_MODIFIER_MOTION_NONE)
medusa_bellerophon = class({})
medusa_bellerophon_upgrade = class({})

function medusa_bellerophon_wrapper(ability)
    function ability:GetAbilityTextureName()
        if self:GetCaster():HasModifier("modifier_alternate_04") then
            return "custom/medusa/medusa_bellerophon2"
        else
            return "custom/medusa/medusa_bellerophon"
        end
    end    

    function ability:GetChannelTime()
        return self:GetSpecialValueFor("cast_time")
    end

    function ability:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function ability:CastFilterResultLocation(hLocation)
        local caster = self:GetCaster()
        if IsServer() and not IsInSameRealm(caster:GetAbsOrigin(), hLocation) then
            return UF_FAIL_CUSTOM
        elseif IsOutOfMap(hLocation) then 
            return UF_FAIL_CUSTOM
        else
            return UF_SUCESS
        end
    end

    function ability:GetCustomCastErrorLocation(hLocation)
        return "#Invalid_Target_Location"
    end

    --[[function ability:OnAbilityPhaseStart()
    	local caster = self:GetCaster()
		local ability = self
		local targetPoint = ability:GetCursorPosition()
		local origin = caster:GetAbsOrigin()
		if (origin - targetPoint):Length2D() > 3000 or not IsInSameRealm(origin, targetPoint) or GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then 
			caster:Stop()
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target_Location")
			return
		end
    end]]

    function ability:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self 
	local targetPoint = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local origin = caster:GetAbsOrigin()
	local initialPosition = origin
	local ascendCount = 0
	local descendCount = 0
	if caster.IsRidingAcquired then 
		local bonus_agi = ability:GetSpecialValueFor("bonus_agi")
		damage = damage + (bonus_agi * caster:GetAgility())
	end
	
	local dist = (origin - targetPoint):Length2D() 
	--local dmgdelay = dist * 0.000416
	local hero_pause = 1.3
	local dmgdelay = 0.05
	
	-- Attach particle
	local belleFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_1_alternate.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( belleFxIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true )
	ParticleManager:SetParticleControlEnt( belleFxIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true )
	Timers:CreateTimer(hero_pause + dmgdelay, function()
		ParticleManager:DestroyParticle( belleFxIndex, false )
		ParticleManager:ReleaseParticleIndex( belleFxIndex )
	end)
	
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", hero_pause)
	Timers:CreateTimer(0.5, function()
		if caster:HasModifier('modifier_alternate_01') or caster:HasModifier('modifier_alternate_02') or caster:HasModifier('modifier_alternate_03') or caster:HasModifier('modifier_alternate_04') then 
			EmitGlobalSound("Rider.Lily.Bellerophon") 
		else
			EmitGlobalSound("Medusa_Bellerophon") 
		end
		
	end)

	local descendVec = Vector(0,0,0)
	descendVec = (targetPoint - Vector(origin.x, origin.y, 1150)):Normalized()
	Timers:CreateTimer(function()
		if ascendCount == 23 then return end
		caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,50))
		ascendCount = ascendCount + 1
		return 0.033
	end)


	Timers:CreateTimer(1.0, function()
		local origin = caster:GetAbsOrigin()

		if (origin - targetPoint):Length2D() > 2000 then return end
		if descendCount == 9 then 
			ParticleManager:DestroyParticle(caster.pegasus_particle, true)
			ParticleManager:ReleaseParticleIndex(caster.pegasus_particle)
			return nil
		end
		if descendCount == 0 then 
			local angle = caster:GetAnglesAsVector().y
			print('angle ' .. angle)
			local particle_name = "particles/custom/medusa/medusa_pegasus.vpcf"
			caster.pegasus_particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(caster.pegasus_particle, 0, origin)
			ParticleManager:SetParticleControl(caster.pegasus_particle, 1, (targetPoint - origin):Normalized() * (dist/0.3))
			ParticleManager:SetParticleControl(caster.pegasus_particle, 5, Vector(0,0,angle + 180))

		end

		caster:SetAbsOrigin(Vector(origin.x + descendVec.x * dist/6 ,
									origin.y + descendVec.y * dist/6,
									origin.z - 127))
		descendCount = descendCount + 1
		return 0.033
	end)

	-- this is when Rider makes a landing 
	Timers:CreateTimer(hero_pause, function() 
		local origin = caster:GetAbsOrigin()
		if (origin - targetPoint):Length2D() < 2000 then 
			-- set unit's final position first before checking if IsInSameRealm
			-- to allow Belle across river etc
			-- only if it is across realms do we try to adjust position
			caster:SetAbsOrigin(targetPoint)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local currentPosition = caster:GetAbsOrigin()
			if not IsInSameRealm(currentPosition, initialPosition) then
				local diffVector = currentPosition - initialPosition
				local normalisedVector = diffVector:Normalized()
				local length = diffVector:Length2D()
				local newPosition = currentPosition
				while length >= 0
					and (not IsInSameRealm(currentPosition, initialPosition)
						or GridNav:IsBlocked(currentPosition)
						or not GridNav:IsTraversable(currentPosition)
					)
				do
					currentPosition = currentPosition - normalisedVector * 10
					length = length - 10
				end
				caster:SetAbsOrigin(currentPosition)
				FindClearSpaceForUnit(caster, currentPosition, true)
			end
			if IsOutOfMap(caster:GetOrigin()) then 
	            local border = GetBorderMap(caster:GetOrigin())
	            caster:SetAbsOrigin(border)
	            FindClearSpaceForUnit(caster, border, true)
	        end
		else
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end
		caster:EmitSound("Misc.Crash")
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postlock", dmgdelay)
	end)

	-- this is when the damage actually applies(Put slam effect here)
	Timers:CreateTimer(hero_pause + dmgdelay, function()		
		-- Crete particle
		local belleImpactFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_1_impact.vpcf", PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl( belleImpactFxIndex, 0, targetPoint)
		ParticleManager:SetParticleControl( belleImpactFxIndex, 1, Vector( radius, radius, radius ) )
		
		Timers:CreateTimer( 1, function()
			ParticleManager:DestroyParticle( belleImpactFxIndex, false )
			ParticleManager:ReleaseParticleIndex( belleImpactFxIndex )
		end)

		local max_counter = 3 
		local interval = 0.03
		local damage_counter = 0

		Timers:CreateTimer('medusa_bell_dmg' .. caster:GetPlayerOwnerID(), {
			endTime = interval,
			callback = function()
            if damage_counter >= max_counter or not caster:IsAlive() then return end
            
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do

				if not IsValidEntity(v) or string.match(v:GetName(), "ward") or v:IsNull() or not v:IsAlive() or v:IsMagicImmune() then 
					goto excludetarget 
				end

				if not v:HasModifier("modifier_belle_hit_check") then
					v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
    				v:AddNewModifier(caster, ability, "modifier_belle_hit_check", {Duration = 0.1})
			    	DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end

				::excludetarget::
		    end
		    damage_counter = damage_counter + 1

            return interval
        end})


	    ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
		end)
    end
end

medusa_bellerophon_wrapper(medusa_bellerophon)
medusa_bellerophon_wrapper(medusa_bellerophon_upgrade)
