
function OnElectricStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_charge = ability:GetSpecialValueFor("electric_power")
	caster.ElectricCharge = max_charge
    AddElectricCharge(keys, caster.ElectricCharge)
	if not caster:HasModifier("modifier_fran_electric_progress") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fran_electric_progress", {})
	end
	caster.ElectricProgress = 0
	UpdateElectricProgress(caster)
end

function OnElectricThink(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local max_stack = ability:GetSpecialValueFor("electric_power")
	local regen_duration = ability:GetSpecialValueFor("recharge_time")
	local progress = 0.05 / regen_duration

    local currentStack = caster:GetModifierStackCount("modifier_fran_electric_count", caster)

	if currentStack >= max_stack then
		caster.ElectricProgress = 0
        AddElectricCharge(keys, max_stack)
	else
		caster.ElectricProgress = caster.ElectricProgress + progress
		if caster.ElectricProgress > 1 then
			caster.ElectricProgress = caster.ElectricProgress - 1
			AddElectricCharge(keys, 1)
		end
	end

	UpdateElectricProgress(caster)
end

function OnElectricRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_charge = ability:GetSpecialValueFor("electric_power")
    caster.ElectricCharge = max_charge
	AddElectricCharge(keys, max_charge)
end

function AddElectricCharge(keys, modifier)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("fran_galvanism") or caster:FindAbilityByName("fran_galvanism_upgrade")
	local maxStack = ability:GetSpecialValueFor("electric_power")
	local regen_duration = ability:GetSpecialValueFor("recharge_time")

	if not caster.ElectricCharge then caster.ElectricCharge = 0 end

	local newStack = caster.ElectricCharge + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		ability:StartCooldown(ability:GetCooldown(1))
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fran_dysfunction", {Duration = (1 - caster.ElectricProgress) * regen_duration})
		if caster.IsImproveGalvanismAcquired then 
			caster:RemoveModifierByName("modifier_electric_buff")
		end
	else
		caster:RemoveModifierByName("modifier_fran_dysfunction")
		ability:EndCooldown()
		if caster.IsImproveGalvanismAcquired then 
			if not caster:HasModifier("modifier_electric_buff") then 
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_electric_buff", {})
			end
			caster:SetModifierStackCount("modifier_electric_buff", caster, newStack)
		end
	end

	caster:SetModifierStackCount("modifier_fran_electric_count", caster, newStack)
	caster.ElectricCharge = newStack
end

function UpdateElectricProgress(caster)
	local progress = caster.ElectricProgress * 100
	caster:SetModifierStackCount("modifier_fran_electric_progress", caster, progress)
end

function AddLightningStack(caster, target, count)
	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = caster:FindAbilityByName("fran_galvanism") or caster:FindAbilityByName("fran_galvanism_upgrade")

	local max_stack = ability:GetSpecialValueFor("mark_max")
	local stun_duration = ability:GetSpecialValueFor("mark_max_stun")
	local currentStack = target:GetModifierStackCount("modifier_fran_lightning_slow", caster) or 0 

	if currentStack + 1 >= max_stack then
		if not target:IsMagicImmune() and not IsImmuneToCC(target) then
    		ability:ApplyDataDrivenModifier(caster, target, "modifier_stunned", {Duration = stun_duration})
    		target:RemoveModifierByName("modifier_fran_lightning_slow")
			--target:EmitSound("Hero_NagaSiren.Ensnare.Cast")
        end
    else
    	target:RemoveModifierByName("modifier_fran_lightning_slow")
        ability:ApplyDataDrivenModifier(caster, target, "modifier_fran_lightning_slow", {})
        target:SetModifierStackCount("modifier_fran_lightning_slow", caster, math.min(max_stack, currentStack + count))
    end
end

function OnLamentHowlStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")

	caster:EmitSound("Hero_DarkWillow.Fear.Cast")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lament_cooldown", {Duration = ability:GetCooldown(1)})
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs (enemies) do
		if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) and v:IsAlive() then 
			ability:ApplyDataDrivenModifier(caster, v, "modifier_fran_lament", {})
		end
	end
end

function LamentRun(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	if not caster:IsAlive() then return end
	if target == nil then return end
	if target:GetName() ~= "npc_dota_ward_base" and not target:IsMagicImmune() and not target:HasModifier("pause_sealenabled") and not target:HasModifier("pause_sealdisabled") then
		local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

        local newPos = target:GetAbsOrigin() + direction * 1000
        target:MoveToPosition(newPos)

		--[[local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		local angle = VectorToAngles(direction).y
		local forcemove = {
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
			Position = GetRotationPoint(target:GetAbsOrigin(),500,angle), 
		}
		ExecuteOrderFromTable(forcemove)]]
		--print('howl')
	end
end

function OnLightningShotCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local electric_power = ability:GetSpecialValueFor("electric_power")
	if caster:GetModifierStackCount("modifier_fran_electric_count", caster) < electric_power then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Electric")
		return false
	end
end

function OnLightningShotStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local electric_power = ability:GetSpecialValueFor("electric_power")
	local distance = ability:GetSpecialValueFor("distance")
	local width = ability:GetSpecialValueFor("width")
	local speed = ability:GetSpecialValueFor("speed")
	local particle 

	if caster.IsOverloadAcquired then 
		particle = "particles/custom/fran/fran_lightning_shot_overload.vpcf"
	else
		particle = "particles/custom/fran/fran_lightning_shot.vpcf"
	end

	if caster.IsOverloadAcquired and caster:GetModifierStackCount("modifier_fran_electric_count", caster) == 0 then
		local hp_cost = ability:GetSpecialValueFor("hp_cost") / 100  * caster:GetMaxHealth()
		caster:SetHealth(math.max(1, caster:GetHealth() - hp_cost))
	else
		AddElectricCharge(keys, -electric_power)
	end

	local lightningshot = 
	{
		Ability = ability,
        --EffectName = "particles/custom/fran/fran_lightning_shot.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        fDistance = distance - width,
        fStartRadius = width,
        fEndRadius = width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * speed
	}
	ProjectileManager:CreateLinearProjectile(lightningshot)
	caster:EmitSound("Hero_Zuus.Attack")

	FranCheckCombo(caster,ability)

	local duration = distance / speed
	local dummyLoc = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()
	local dummy = CreateUnitByName("dummy_unit", dummyLoc, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy:SetForwardVector(forward)

	local fxIndex1 = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, dummy )
	ParticleManager:SetParticleControl( fxIndex1, 0, dummy:GetAbsOrigin() )

	Timers:CreateTimer(function()
		if IsValidEntity(dummy) then
			dummyLoc = dummyLoc + (speed * 0.05) * Vector(forward.x, forward.y, 0)
			dummy:SetAbsOrigin(GetGroundPosition(dummyLoc, nil))
			return 0.05
		else
			return nil
		end
	end)		

	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle( fxIndex1, true )
		ParticleManager:ReleaseParticleIndex( fxIndex1 )			
		Timers:CreateTimer(0.05, function()
			if IsValidEntity(dummy) then
				dummy:RemoveSelf()
			end
			return nil
		end)
		return nil
	end)
end

function OnLightningShotHit(keys)
	local target = keys.target
	if target == nil then return end

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local caster = keys.caster 
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")

	if not target:IsMagicImmune() and not IsImmuneToCC(target) and not IsImmuneToSlow(target) then 
		AddLightningStack(caster, target, 1)
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	caster:EmitSound("Hero_Zuus.ProjectileImpact")

end

function OnSmashStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local dist = math.max(0, ((caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6) - 170)
	local castRange = ability:GetSpecialValueFor("distance")
	local electric_power = ability:GetSpecialValueFor("electric_power")
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local inner_radius = ability:GetSpecialValueFor("inner_radius")
	local lightning_damage_per_charge = ability:GetSpecialValueFor("lightning_damage_per_charge")
	local inner_stun = ability:GetSpecialValueFor("inner_stun")
	local outer_stun = ability:GetSpecialValueFor("outer_stun")
	local particle 

	-- When you exit the ubw on the last moment, dist is going to be a pretty high number, since the targetPoint is on ubw but you are outside it
	-- If it's, then we can't use it like that. Either cancel Overedge, or use a default one.
	-- 2000 is a fixedNumber, just to check if dist is not valid. Over 2000 is surely wrong. (Max is close to 900)
	if dist > 2000 then
		dist = math.max(0, castRange - 170)  --Default one
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
    local fran = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 4000))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-13333))

	--caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 

	StartAnimation(caster, {duration=0.7, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.8})

	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		caster:EmitSound("Hero_Centaur.HoofStomp") 
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		local angle = VectorToAngles(caster:GetForwardVector()).y
		local Position = GetRotationPoint(caster:GetAbsOrigin(),170,angle)

	-- Stomp
		local stompParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( stompParticleIndex, 0, Position )
		ParticleManager:SetParticleControl( stompParticleIndex, 1, Vector( radius, radius, radius ) )
		
	-- Destroy particle
		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( stompParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( stompParticleIndex )
		end)
		local power = caster:GetModifierStackCount("modifier_fran_electric_count", caster) or 0
		AddElectricCharge(keys, -math.min(power, electric_power))
		local lightning_dmg = lightning_damage_per_charge * math.min(power, electric_power)
		if caster.IsOverloadAcquired and power < electric_power then
			local hp_cost = ability:GetSpecialValueFor("hp_cost") / 100  * caster:GetMaxHealth()
			caster:SetHealth(math.max(1, caster:GetHealth() - (hp_cost * (electric_power - power))))
			lightning_dmg = lightning_damage_per_charge * electric_power
		end
		print('Lightning Bonus ' .. lightning_dmg)

		if caster.IsOverloadAcquired then 
			particle = "particles/custom/fran/fran_smash_green.vpcf"
		else
			if power > 0 then 
				particle = "particles/custom/fran/fran_smash.vpcf"
			else
				particle = "particles/custom/fran/fran_smash_non.vpcf"
			end
		end

		local smashParticleIndex = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( smashParticleIndex, 0, Position )
		ParticleManager:SetParticleControl( smashParticleIndex, 1, Position )
		ParticleManager:SetParticleControl( smashParticleIndex, 2, Position )

		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( smashParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( stompParticleIndex )
		end)

        local targets = FindUnitsInRadius(caster:GetTeam(), Position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
				if not v:IsMagicImmune() and not IsImmuneToCC(v) then 
		       		if (Position - v:GetAbsOrigin()):Length2D() <= inner_radius then 
		       			v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = inner_stun})	       			
		       		else
		       			v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = outer_stun})
		       		end
		       	end
		       	if power > 0 or caster.IsOverloadAcquired then 
		       		if not v:IsMagicImmune() and not IsImmuneToCC(v) and not IsImmuneToSlow(v) then 
		       			AddLightningStack(caster, v, 1)
		       		end
		       		DoDamage(caster, v, lightning_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		       		
		       	end
		       	if IsValidEntity(v) and not v:IsNull() then
			       	if (Position - v:GetAbsOrigin()):Length2D() <= inner_radius then 
			       		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			       	end
			    end
	       	end
	    end
	end})
end

function OnElectricFieldStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local electric_power = ability:GetSpecialValueFor("electric_power")
	local delay = ability:GetSpecialValueFor("delay")
	local duration_per_charge = ability:GetSpecialValueFor("duration_per_charge")
	local radius = ability:GetSpecialValueFor("radius")
	local dmg_per_charge = ability:GetSpecialValueFor("dmg_per_charge")
	local heal_per_charge = ability:GetSpecialValueFor("heal_per_charge")
	local charge_gain_per_duration = ability:GetSpecialValueFor("charge_gain_per_duration")
	local currentCharge = caster:GetModifierStackCount("modifier_fran_electric_count", caster) or 0
	local particle = "particles/custom/fran/fran_electric_field.vpcf"
	local particle_pre = "particles/custom/fran/fran_ground_crack.vpcf"


	if currentCharge == 0 and not caster.IsOverloadAcquired then -- not enuf electric power
		ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Electric")
		return 
	end

	local charge_use = math.min(electric_power, currentCharge)
	caster.max_regain = charge_use
	AddElectricCharge(keys, -charge_use)
	if caster.IsOverloadAcquired then 
		particle = "particles/custom/fran/fran_electric_field_green.vpcf"
		particle_pre = "particles/custom/fran/fran_ground_crack_green.vpcf"
		local hp_cost = ability:GetSpecialValueFor("hp_cost") / 100  * caster:GetMaxHealth()
		caster:SetHealth(math.max(1, caster:GetHealth() - (hp_cost * (electric_power - currentCharge))))
		charge_use = electric_power
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", delay)
	StartAnimation(caster, {duration=delay, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.0})
	caster:EmitSound("Fran.Mad")

	local preParticleIndex = ParticleManager:CreateParticle( particle_pre, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( preParticleIndex, 0, caster:GetAbsOrigin() )

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle( preParticleIndex, true )
		ParticleManager:ReleaseParticleIndex( preParticleIndex )
		caster:EmitSound("Ability.static.end")
		if caster:IsAlive() then 
			local fieldFxIndex = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(fieldFxIndex, 3, caster:GetAbsOrigin())
			Timers:CreateTimer(0.2, function()
				ParticleManager:DestroyParticle( fieldFxIndex, true )
				ParticleManager:ReleaseParticleIndex( fieldFxIndex )
			end)
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					if not v:IsMagicImmune() and not IsImmuneToCC(v) and not IsImmuneToSlow(v) then 
			   			AddLightningStack(caster, v, charge_use)
			   		end
			       	DoDamage(caster, v, dmg_per_charge * charge_use, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		       	end
		    end
		    print('Lightning Damage ' .. dmg_per_charge * charge_use)
		    caster:FateHeal(heal_per_charge * charge_use, caster,true)
		    print('Heal ' .. heal_per_charge * charge_use)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_fran_mana_burst", {Duration = duration_per_charge * charge_use})
        	caster:SetModifierStackCount("modifier_fran_mana_burst", caster, charge_use)
        	if caster.IsMadEnhancementAcquired then  -- add berserk + immune cc
        		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fran_mad", {})
        		HardCleanse(caster)
        	end
        	FranCheckCombo(caster,ability)
        end
	end)
end

function OnElectricFieldThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local charge_gain_per_duration = ability:GetSpecialValueFor("charge_gain_per_duration")
	if caster.max_regain > 0 then 
		AddElectricCharge(keys, charge_gain_per_duration)
		caster.max_regain = caster.max_regain - 1 
	end
end

function OnElectricShieldDestroy (keys)
	local caster = keys.caster 
	caster.ElectricShieldAmount = 0
end

function OnElectricShieldTakeDamage(keys)
	local caster = keys.caster 
	local currentHealth = caster:GetHealth() 

	-- Create particles
	local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, keys.unit )
	ParticleManager:SetParticleControl( onHitParticleIndex, 2, keys.unit:GetAbsOrigin() )
	
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( onHitParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
	end)

	caster.ElectricShieldAmount = caster.ElectricShieldAmount - keys.DamageTaken
	if caster.ElectricShieldAmount <= 0 then
		if currentHealth + caster.ElectricShieldAmount <= 0 then
			--print("lethal")
		else
			--print("rho broken, but not lethal")
			caster:RemoveModifierByName("modifier_fran_elect_shield")
			caster:SetHealth(currentHealth + keys.DamageTaken + caster.ElectricShieldAmount)
			caster.ElectricShieldAmount = 0
		end
	else
		--print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		caster:SetHealth(currentHealth + keys.DamageTaken)
		caster:SetModifierStackCount("modifier_fran_elect_shield", caster, caster.ElectricShieldAmount)
	end
end

function OnBlastedTreeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local position = ability:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local electric_power = ability:GetSpecialValueFor("electric_power")
	local delay = ability:GetSpecialValueFor("delay")
	local base_lightning = ability:GetSpecialValueFor("base_lightning")
	local radius = ability:GetSpecialValueFor("radius")
	local bonus_lightning_per_stack = ability:GetSpecialValueFor("bonus_lightning_per_stack")	
	local lightning_dmg = ability:GetSpecialValueFor("lightning_dmg")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local currentCharge = caster:GetModifierStackCount("modifier_fran_electric_count", caster) or 0
	local interval = 0.1
	AddElectricCharge(keys, -currentCharge)
	if caster.IsBridalChestAcquired then 
		local bonus_dmg_per_stack = ability:GetSpecialValueFor("bonus_dmg_per_stack")
		lightning_dmg = lightning_dmg + (bonus_dmg_per_stack * currentCharge)
	end

	if caster.ElectricShieldAmount == nil then 
		caster.ElectricShieldAmount = 0
	end

	local bonus_lightning = math.max(0, currentCharge - electric_power) * bonus_lightning_per_stack

	local ascendFxIndex = ParticleManager:CreateParticle( "particles/custom/fran/fran_blast_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(ascendFxIndex, 0, position)
	ParticleManager:SetParticleControl(ascendFxIndex, 1, Vector(0,0,0))
	EmitSoundOnLocationWithCaster(position, "Hero_Razor.Storm.Cast", caster)

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle( ascendFxIndex, true )
		ParticleManager:ReleaseParticleIndex( ascendFxIndex )
		if caster:IsAlive() then 
			for i = 1, base_lightning + bonus_lightning do 
				Timers:CreateTimer(interval * i, function()
					local lightning_loc = RandomPointInCircle(position, radius)
					if i%8 == 0 then 
						if (caster:GetAbsOrigin() - position):Length2D() <= radius then
							lightning_loc = caster:GetAbsOrigin() 
						end
					end
					BlastedLightning(caster, ability, lightning_loc, lightning_dmg, lightning_aoe, "particles/custom/fran/fran_arc_lightning.vpcf")
				end)
			end
        end
	end)
end

function BlastedLightning(caster, ability, point, damage, aoe, particle)	
	EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
	local ThunderFX = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ThunderFX, 0, point + Vector(0,0,RandomInt(1200, 1500)))
	ParticleManager:SetParticleControl(ThunderFX, 1, point)
	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle( ThunderFX, true )
		ParticleManager:ReleaseParticleIndex( ThunderFX )
	end)
	
 	local thunder = FindUnitsInRadius(caster:GetTeam(), point, nil, aoe, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	for _,thundertarget in pairs (thunder) do
 		if IsValidEntity(thundertarget) and not thundertarget:IsNull() and thundertarget:IsAlive() then
	 		if thundertarget == caster then 
	 			local void_health = caster:GetMaxHealth() - caster:GetHealth()
	 			if caster.IsBridalChestAcquired and ability:GetName() == "fran_blasted_tree_upgrade" then 
	 				if damage > void_health then 
	 					local shield_gain = ability:GetSpecialValueFor("shield_gain")/100
	 					ability:ApplyDataDrivenModifier(caster, thundertarget, "modifier_fran_elect_shield", {})
	 					caster.ElectricShieldAmount = math.min(caster.ElectricShieldAmount + ((damage - void_health) * shield_gain), caster:GetMaxHealth())
	 					print('shield = ' .. caster.ElectricShieldAmount)
	 					caster:SetModifierStackCount("modifier_fran_elect_shield", caster, caster.ElectricShieldAmount)
	 				end
	 			end
	 			caster:FateHeal(damage, caster,true)
	 			local keys = {
	 				caster = caster,
	 			}
	 			AddElectricCharge(keys, 1)
	 		else
	 			if thundertarget:GetTeam() == caster:GetTeam() then 
	 				ability:ApplyDataDrivenModifier(caster, thundertarget, "modifier_fran_lightning_ally", {Duration = 0.5})
	 				if not thundertarget:HasModifier("modifier_lightning_resistance") then
	 					DoDamage(caster, thundertarget, damage/2, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NON_LETHAL, ability, false)
	 				end
	 				ApplyPurge(thundertarget)
	 				HardCleanse(thundertarget)
	 				thundertarget:RemoveModifierByName("modifier_fran_lightning_ally")
	 			else
			 		if not thundertarget:IsMagicImmune() then 
			 			if not IsImmuneToCC(thundertarget) then
			 				AddLightningStack(caster, thundertarget, 1)
			 			end
			 			ApplyPurge(thundertarget)
			 		end
			 		DoDamage(caster, thundertarget, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			 	end
			end
		end
 	end
 	if string.match(ability:GetAbilityName(), "fran_combo_blasted_tree") then
 		--print('combo') 
 		local revive = FindUnitsInRadius(caster:GetTeam(), point, nil, aoe, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_CLOSEST, false)
 		for k,v in pairs (revive) do 
 			--print(k,v)
 			if not v.fran_revive and not v:IsAlive() and v:IsRealHero() and v ~= caster and caster.max_revive > 0 and not v:HasModifier("modifier_lightning_resistance") then 
 				v.blastedrevive = v:GetAbsOrigin()
 				v.fran_revive = true 
 				Timers:CreateTimer(1.0, function()
	 				if IsTeamWiped(v) == false and _G.CurrentGameState == "FATE_ROUND_ONGOING" then 
	 					GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. FindName(v:GetName()) .. "</font> has been revived by <font color='#58ACFA'>" .. FindName(caster:GetName()) .. "</font> .", 0, 0)
						v:SetRespawnPosition(v.blastedrevive)
						v:RespawnHero(false,false)
						v:AddNewModifier(v, nil, "modifier_camera_follow", {duration = 1.0})
						v:EmitSound("Hero_Omniknight.Purification")
						ability:ApplyDataDrivenModifier(caster, v, "modifier_lightning_resistance", {})
						local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
						ParticleManager:SetParticleControl(particle, 3, v:GetAbsOrigin())
						Timers:CreateTimer(0.1, function()
							ParticleManager:DestroyParticle( particle, false )
							ParticleManager:ReleaseParticleIndex( particle )
							v:SetRespawnPosition(v.RespawnPos)
						end)
					else
						v.blastedrevive = nil 
					end
					v.fran_revive = nil
				end)
 				caster.max_revive = caster.max_revive - 1
 				break
 			end
 		end
 	end
end

function LightningAlly(keys)
	local caster = keys.caster
	local target = keys.unit 
	local attacker = keys.attacker 

	if target:GetHealth() <= 0 and caster == attacker then 
		target:SetHealth(1)
	end
end

function OnComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local electric_power = ability:GetSpecialValueFor("electric_power")
	local delay = ability:GetSpecialValueFor("delay")
	local base_lightning = ability:GetSpecialValueFor("base_lightning")
	local radius = ability:GetSpecialValueFor("radius")
	local lock_radius = ability:GetSpecialValueFor("lock_radius")
	local bonus_lightning_per_stack = ability:GetSpecialValueFor("bonus_lightning_per_stack")	
	local lightning_dmg = ability:GetSpecialValueFor("lightning_dmg")
	local lightning_aoe = ability:GetSpecialValueFor("lightning_aoe")
	local max_revive = ability:GetSpecialValueFor("max_revive")
	local blast_radius = ability:GetSpecialValueFor("blast_radius")
	local blast_damage = ability:GetSpecialValueFor("blast_damage") / 100
	local high_dmg_radius = ability:GetSpecialValueFor("hr")
	local high_dmg = ability:GetSpecialValueFor("hd") / 100
	local low_dmg_radius = ability:GetSpecialValueFor("lr")
	local low_dmg = ability:GetSpecialValueFor("ld") / 100
	local currentCharge = caster:GetModifierStackCount("modifier_fran_electric_count", caster) or 0
	local thunder_duration = 3.0 -- fix time for particle
	local total_thunder = (base_lightning + (bonus_lightning_per_stack*(currentCharge-electric_power)))
	local interval = thunder_duration / total_thunder
	caster.max_revive = max_revive
	AddElectricCharge(keys, -currentCharge)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_blasted_tree_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("fran_combo_blasted_tree")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	caster:RemoveModifierByName("modifier_blasted_tree_window")

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", delay + thunder_duration)
	StartAnimation(caster, {duration=delay + thunder_duration, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})

	local lockenemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, lock_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 	if lockenemies[1] ~= nil then 
 		-- play sound 
 		
 		giveUnitDataDrivenModifier(caster, lockenemies[1], "pause_sealenabled", delay + thunder_duration)
 		FindClearSpaceForUnit(lockenemies[1], caster:GetAbsOrigin(), true)
 	end	

 	EmitGlobalSound("Fran.Combo_Lock")

 	local tree = ParticleManager:CreateParticle( "particles/custom/fran/fran_blast_tree.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(tree, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(delay, function()

		local BlastFX = ParticleManager:CreateParticle( "particles/custom/fran/fran_combo_znight_endcap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		if caster.combo_ring == nil then 
			caster.combo_ring = ParticleManager:CreateParticleForTeam("particles/custom/lancelot/lancelot_combo_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
			ParticleManager:SetParticleControl(caster.combo_ring, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(caster.combo_ring, 1, Vector(radius,0,0))
			caster.combo_ring2 = ParticleManager:CreateParticleForTeam("particles/custom/lancelot/lancelot_combo_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
			ParticleManager:SetParticleControl(caster.combo_ring2, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(caster.combo_ring2, 1, Vector(low_dmg_radius,0,0))
		end
		ParticleManager:SetParticleControl(BlastFX, 0, caster:GetAbsOrigin())
		for i = 1, total_thunder do 
			Timers:CreateTimer(interval * i, function()
				local lightning_loc = RandomPointInCircle(caster:GetAbsOrigin(), radius)
				if i%8 == 0 then 
					lightning_loc = caster:GetAbsOrigin() 
				end
				BlastedLightning(caster, ability, lightning_loc, lightning_dmg, lightning_aoe, "particles/custom/fran/fran_arc_lightning_green.vpcf")	
			end)
		end
	end)
	Timers:CreateTimer(thunder_duration, function()
		EmitGlobalSound("Fran.Combo")
	end)

	Timers:CreateTimer(delay + thunder_duration, function()
		ParticleManager:DestroyParticle( caster.combo_ring, true )
        ParticleManager:ReleaseParticleIndex( caster.combo_ring )

        
		Timers:CreateTimer( 0.5, function()
            ParticleManager:DestroyParticle( caster.combo_ring2, true )
            ParticleManager:ReleaseParticleIndex( caster.combo_ring2 )
            caster.combo_ring = nil
            ParticleManager:DestroyParticle( tree, true )
            ParticleManager:ReleaseParticleIndex( tree )
        end)

		if caster.IsBridalChestAcquired then 
			blast_damage = blast_damage * (caster:GetMaxHealth() + caster:GetMaxMana())
		else
			blast_damage = blast_damage * (caster:GetHealth() + caster:GetMana())
		end

		local blasts = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, low_dmg_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
 		for k,v in pairs (blasts) do 
 			if v == caster then
 				ApplyStrongDispel(caster)
 				DoDamage(caster, caster, 99999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, ability, false)
 			else
 				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
	 				if not v:HasModifier("modifier_lightning_resistance") then
	 					if (caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() <= high_dmg_radius then 
	 						if caster:GetTeam() == v:GetTeam() then 
			 					ability:ApplyDataDrivenModifier(caster, v, "modifier_fran_lightning_ally", {Duration = 1})
			 				end
			 				
			 				if v == lockenemies[1] then 
			 					DoDamage(caster, v, blast_damage * high_dmg * 1.5, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			 				else
			 					DoDamage(caster, v, blast_damage * high_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			 				end
			 			else
			 				if caster:GetTeam() == v:GetTeam() then 
			 					ability:ApplyDataDrivenModifier(caster, v, "modifier_fran_lightning_ally", {Duration = 1})
			 				end
			 				DoDamage(caster, v, blast_damage * low_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			 			end
		 			end
		 		end
 			end
 		end
 	end)
end

function OnBlastedTreeReviveMark(keys)
	local target = keys.target 
	local caster = keys.caster 
	target.blastedrevive = target:GetAbsOrigin()
end

function OnBlastedTreeRevive(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if IsTeamWiped(target) == false and _G.CurrentGameState == "FATE_ROUND_ONGOING" then 
		target:SetRespawnPosition(target.blastedrevive)
		target:RespawnHero(false,false)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_lightning_resistance", {})
		Timers:CreateTimer(0.1, function()
			target:SetRespawnPosition(target.RespawnPos)
		end)
	else
		target.blastedrevive = nil 
	end
end

function FranCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		
		if string.match(GetMapName(), "fate_elim") then 
			if GameRules:GetGameTime() < 25 + _G.RoundStartTime then 
				return 
			end
		end

		if string.match(ability:GetAbilityName(), "fran_lightning_shot") then 
			caster.QUsed = true
			caster.QTime = GameRules:GetGameTime()
			if caster.QTimer ~= nil then 
				Timers:RemoveTimer(caster.QTimer)
				caster.QTimer = nil
			end
			caster.QTimer = Timers:CreateTimer(4.0, function()
				caster.QUsed = false
			end)
		else
			if caster.IsBridalChestAcquired then 
				if string.match(ability:GetAbilityName(), "fran_electric_field") and caster:FindAbilityByName("fran_blasted_tree_upgrade"):IsCooldownReady() and caster:FindAbilityByName("fran_combo_blasted_tree_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_blasted_tree_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_blasted_tree_window", {Duration = duration})
					end
				end
			else
				if string.match(ability:GetAbilityName(), "fran_electric_field") and caster:FindAbilityByName("fran_blasted_tree"):IsCooldownReady() and caster:FindAbilityByName("fran_combo_blasted_tree"):IsCooldownReady() and not caster:HasModifier("modifier_blasted_tree_cooldown") then
					if caster.QUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 4 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_blasted_tree_window", {Duration = duration})
					end
				end
			end
		end
	end
end

function OnComboWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsBridalChestAcquired then
		caster:SwapAbilities("fran_blasted_tree_upgrade", "fran_combo_blasted_tree_upgrade", false, true) 
	else
		caster:SwapAbilities("fran_blasted_tree", "fran_combo_blasted_tree", false, true) 
	end
end

function OnComboWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsBridalChestAcquired then
		caster:SwapAbilities("fran_blasted_tree_upgrade", "fran_combo_blasted_tree_upgrade", true, false) 
	else
		caster:SwapAbilities("fran_blasted_tree", "fran_combo_blasted_tree", true, false) 
	end
end

function OnComboWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_blasted_tree_window")
end

function OnBridalChestAttack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local chance = ability:GetSpecialValueFor("chance")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local bonus_per_stack = ability:GetSpecialValueFor("bonus_per_stack")
	local recharge_chance = ability:GetSpecialValueFor("recharge_chance")
	local currentCharge = caster:GetModifierStackCount("modifier_fran_electric_count", caster) or 0

	if RandomInt(1, 100) <= chance then 
		AddLightningStack(caster, target, 1)
		DoDamage(caster, target, base_damage + (bonus_per_stack * currentCharge), DAMAGE_TYPE_MAGICAL, 0, ability, false)
		
		if RandomInt(1, 100) <= recharge_chance then 
			AddElectricCharge(keys, recharge_chance)
		end
	end
end

function OnBridalChestAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBridalChestAcquired) then

		hero.IsBridalChestAcquired = true

		if hero:HasModifier("modifier_blasted_tree_window") then 
			hero:RemoveModifierByName("modifier_blasted_tree_window")
		end

		hero:FindAbilityByName("fran_bridal_chest"):SetLevel(1)

		UpgradeAttribute(hero, "fran_blasted_tree", "fran_blasted_tree_upgrade", true)
		UpgradeAttribute(hero, "fran_combo_blasted_tree", "fran_combo_blasted_tree_upgrade", false)
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMadEnhancementAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMadEnhancementAcquired) then

		hero.IsMadEnhancementAcquired = true

		if hero.IsOverloadAcquired then 
			UpgradeAttribute(hero, "fran_electric_field_upgrade_2", "fran_electric_field_upgrade_3", true)
		else
			UpgradeAttribute(hero, "fran_electric_field", "fran_electric_field_upgrade_1", true)
		end
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnLamentAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLamentAcquired) then

		hero.IsLamentAcquired = true
		
		hero:SwapAbilities("fate_empty1", "fran_lament", false, true)
		hero:RemoveAbility("fate_empty1")
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnOverloadAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsOverloadAcquired) then

		hero.IsOverloadAcquired = true

		if hero.IsMadEnhancementAcquired then 
			UpgradeAttribute(hero, "fran_electric_field_upgrade_1", "fran_electric_field_upgrade_3", true)
		else
			UpgradeAttribute(hero, "fran_electric_field", "fran_electric_field_upgrade_2", true)
		end

		UpgradeAttribute(hero, "fran_lightning_shot", "fran_lightning_shot_upgrade", true)
		UpgradeAttribute(hero, "fran_brutal_smash", "fran_brutal_smash_upgrade", true)
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveGalvanismAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveGalvanismAcquired) then

		hero.IsImproveGalvanismAcquired = true

		UpgradeAttribute(hero, "fran_galvanism", "fran_galvanism_upgrade", true)

		local stacks = hero:GetModifierStackCount("modifier_fran_electric_count", hero)
		hero:RemoveModifierByName("modifier_fran_electric_count")
		hero:RemoveModifierByName("modifier_fran_electric_progress")
		hero:FindAbilityByName("fran_galvanism_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_fran_electric_progress", {})
		hero:FindAbilityByName("fran_galvanism_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_fran_electric_count", {})
		hero:SetModifierStackCount("modifier_fran_electric_count", hero, stacks)
		
		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
