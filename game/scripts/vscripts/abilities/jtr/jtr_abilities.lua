
function OnSurgeryStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	caster.surgerytarget = target
	ability:ApplyDataDrivenModifier(caster, target, "modifier_jtr_surgery_heal", {})
end

function OnSurgeryInterrupt(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	caster.surgerytarget:RemoveModifierByName("modifier_jtr_surgery_heal")
end

function OnSurgeryHealThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local heal = ability:GetSpecialValueFor("heal")
	local cooldown_reduc = ability:GetSpecialValueFor("cooldown_reduc")
	local max_distance = ability:GetSpecialValueFor("max_distance")

	if not caster:IsAlive() or not target:IsAlive() then
		target:RemoveModifierByName("modifier_jtr_surgery_heal") 
		return 
	end 

	if caster ~= target and (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > max_distance then 
		target:RemoveModifierByName("modifier_jtr_surgery_heal") 
		return 
	end

	target:Heal(heal * 0.1, caster)

	for i=0, 5 do 
		local abilities = target:GetAbilityByIndex(i)
		if abilities ~= nil then
			if abilities.IsResetable ~= false then
				if not abilities:IsCooldownReady() then 
					local remain_cd = abilities:GetCooldownTimeRemaining()
					abilities:EndCooldown()
					abilities:StartCooldown( remain_cd - (cooldown_reduc * 0.1))
				end
			end
		else 
			break
		end
	end
end

function OnSurgeryHealDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:EndChannel(true)
end

function OnQuickStrikesUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsHolyMotherAcquired then 
		if ability:GetAbilityName() == "jtr_quick_strikes_curse_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_quick_strikes_upgrade"):GetLevel() then
				caster:FindAbilityByName("jtr_quick_strikes_upgrade"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_quick_strikes_upgrade" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):GetLevel() then
				caster:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):SetLevel(ability:GetLevel())
				return
			end
		end
	else
		if ability:GetAbilityName() == "jtr_quick_strikes_curse" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_quick_strikes"):GetLevel() then
				caster:FindAbilityByName("jtr_quick_strikes"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_quick_strikes" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_quick_strikes_curse"):GetLevel() then
				caster:FindAbilityByName("jtr_quick_strikes_curse"):SetLevel(ability:GetLevel())
				return
			end
		end
	end
end 

function OnQuickStrikesActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsHolyMotherAcquired then 
		if ability:GetAbilityName() == "jtr_quick_strikes_curse_upgrade" then 
			caster:FindAbilityByName("jtr_quick_strikes_upgrade"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_quick_strikes_upgrade" then 
			caster:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	else
		if ability:GetAbilityName() == "jtr_quick_strikes_curse" then 
			caster:FindAbilityByName("jtr_quick_strikes"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_quick_strikes" then 
			caster:FindAbilityByName("jtr_quick_strikes_curse"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function OnQuickStrikesStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local slashes = ability:GetSpecialValueFor("slashes")
	local interval = ability:GetSpecialValueFor("interval")
	local distance = 600
	local caster_origin = caster:GetAbsOrigin()	
	local damage = ability:GetSpecialValueFor("damage")
	local damage_type = DAMAGE_TYPE_PHYSICAL
	if caster.IsHolyMotherAcquired then 
        if IsFemaleServant(target) then
            damage_type = DAMAGE_TYPE_MAGICAL
        end
    end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_quick_strikes", {duration = (slashes + 1) * (interval + 0.05)})
	SpawnAttachedVisionDummy(caster, target, distance, (slashes + 1) * (interval + 0.05), false)
	local angle = 180 + caster:GetAnglesAsVector().y
	if angle >= 360 then 
		angle = angle - 360
	end
	caster.original_forward_vector = caster:GetForwardVector()
	local dashCaster = Physics:Unit(caster)

	Timers:CreateTimer(function()
		if slashes < 1 then 
			caster:SetAbsOrigin(target:GetAbsOrigin())
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:RemoveModifierByName("modifier_quick_strikes")
			local target_loc = target:GetAbsOrigin()
			local caster_loc = caster:GetAbsOrigin()
			target_loc.z = caster_loc.z
			local forward = (target_loc - caster_loc):Normalized() 
			if target_loc == nil then 
				forward = caster.original_forward_vector 
			end
			forward.z = 0
			caster:SetForwardVector(forward)
			caster:SetAngles(0, 0, 0)
			return nil 
		end
		if caster:IsAlive() and IsValidEntity(target) and not target:IsNull() and target:IsAlive() and (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 2500 and caster:HasModifier("modifier_quick_strikes") and not caster:HasModifier("round_pause") and not target:IsInvulnerable() then 
			caster:SetAbsOrigin(caster_origin)
			OnAmbushDealDamage(caster,ability,target)
			DoDamage(caster, target, damage, damage_type, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
			
			slashes = slashes - 1
			local new_angle = angle + 180 + RandomInt(60, 120)
		    if new_angle >= 360 then 
				new_angle = new_angle - 360
			end
			angle = new_angle
			local target_loc = target:GetAbsOrigin()
			local caster_loc = caster:GetAbsOrigin()
			local forward = (target_loc - caster_loc):Normalized() 
			if target_loc == nil then 
				forward = caster.original_forward_vector 
			end
			forward.z = 0
			ProjectileManager:ProjectileDodge(caster)
			caster:SetForwardVector(forward)
			caster:PreventDI()
			caster:SetPhysicsFriction(0)
			caster:SetPhysicsVelocity(forward * (distance + (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()) / interval)
	   		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	   		caster:FollowNavMesh(true)
			caster:SetAutoUnstuck(false)
	   		Timers:CreateTimer(0.2, function()  
				caster:PreventDI(false)
				caster:SetPhysicsVelocity(Vector(0,0,0))
				caster:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				if IsValidEntity(target) and target:IsAlive() then
					caster_origin = GetRotationPoint(target:GetAbsOrigin(),distance,new_angle)
					
					if caster:HasModifier("modifier_jtr_whitechapel_self") then 
						local stack = target:GetModifierStackCount("modifier_jtr_curse", caster) or 0
						ability:ApplyDataDrivenModifier(caster, target, "modifier_jtr_curse", {})
						target:SetModifierStackCount("modifier_jtr_curse", caster, stack + 1)
						if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
							ability:ApplyDataDrivenModifier(caster, target, "modifier_jtr_curse_slow", {})
							target:SetModifierStackCount("modifier_jtr_curse_slow", caster, stack + 1)
						end
					end
				end
			end)
		else
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:RemoveModifierByName("modifier_quick_strikes")
			caster:SetForwardVector(caster.original_forward_vector)
			caster:SetAngles(0, 0, 0)
			return nil
		end
		return interval + 0.05
	end)
end

function OnQuickStrikesCreate(keys)
	local caster = keys.caster 
	caster.swing_fx = ParticleManager:CreateParticle("particles/custom/jtr/jtr_slash.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(caster.swing_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(caster.swing_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

    caster.swing2_fx = ParticleManager:CreateParticle("particles/custom/jtr/jtr_slash.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(caster.swing2_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(caster.swing2_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)

end

function OnQuickStrikesDestroy(keys)
	local caster = keys.caster 
	ParticleManager:DestroyParticle(caster.swing_fx, false)
	ParticleManager:ReleaseParticleIndex(caster.swing_fx)
	ParticleManager:DestroyParticle(caster.swing2_fx, false)
	ParticleManager:ReleaseParticleIndex(caster.swing2_fx)
end

function OnCurseThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local curse_dps = ability:GetSpecialValueFor("curse_dps")
	local stack = target:GetModifierStackCount("modifier_jtr_curse", caster) 
	DoDamage(caster, target, curse_dps * stack * 0.1, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnTheMistStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius") 

	if caster.AuraDummy ~= nil and not caster.AuraDummy:IsNull() and IsValidEntity(caster.AuraDummy) then 
		caster.AuraDummy:RemoveModifierByName("modifier_jtr_the_mist_aura_enemies")
		ParticleManager:DestroyParticle(caster.mistfx, false)
		ParticleManager:ReleaseParticleIndex(caster.mistfx)
		ParticleManager:DestroyParticle(caster.AuraBorderFx, false)
		ParticleManager:ReleaseParticleIndex(caster.AuraBorderFx)
		Timers:RemoveTimer(caster.mistTimer)
		caster.AuraDummy:RemoveSelf()
		caster:RemoveModifierByName("modifier_jtr_the_mist_checker")
	end

	caster.AuraDummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.AuraDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.AuraDummy:SetDayTimeVisionRange(25)
	caster.AuraDummy:SetNightTimeVisionRange(25)

	caster.AuraDummy:EmitSound("jtr_smoke")
	caster:EmitSound("jtr_invis")
	caster:EmitSound("jtr_laugh_1")

	caster.mistfx = ParticleManager:CreateParticle("particles/custom/jtr/murderer_mist.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.mistfx, 0, caster:GetAbsOrigin())	
	ParticleManager:SetParticleControl(caster.mistfx, 1, Vector(radius,0,0))	

	caster.AuraBorderFx = ParticleManager:CreateParticleForTeam("particles/custom/jtr/jtr_invis_ring.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(caster.AuraBorderFx, 0, caster:GetAbsOrigin())	
	ParticleManager:SetParticleControl(caster.AuraBorderFx, 1, Vector(radius + 100,0,0))

	caster.mistTimer = Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(caster.mistfx, false)
		ParticleManager:ReleaseParticleIndex(caster.mistfx)
		ParticleManager:DestroyParticle(caster.AuraBorderFx, false)
		ParticleManager:ReleaseParticleIndex(caster.AuraBorderFx)
	end)

	
	--[[local enemy = PickRandomEnemy(caster)
	if enemy ~= nil then
		SpawnVisionDummy(enemy, caster:GetAbsOrigin(), 25, 5, false)
	end	]]

	ability:ApplyDataDrivenModifier(caster, caster.AuraDummy, "modifier_jtr_the_mist_aura_enemies", {})
	caster.AuraDummy:AddNewModifier(caster, ability, "modifier_kill", { Duration = duration})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_the_mist_checker", {})

	JackCheckCombo(caster,ability)
end

function OnTheMistCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	--[[local radius = ability:GetSpecialValueFor("radius") 

	target.AuraBorderFx = ParticleManager:CreateParticleForTeam("particles/custom/jtr/jtr_invis_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(target.AuraBorderFx, 0, Vector(radius + 100,0,0))	
	ParticleManager:SetParticleControl(target.AuraBorderFx, 1, Vector(radius + 100,0,0))

	target.MistParticle = ParticleManager:CreateParticle("particles/custom/jtr/murderer_mist.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(target.MistParticle, 0, target:GetAbsOrigin())	
	ParticleManager:SetParticleControl(target.MistParticle, 1, Vector(radius,0,0))	]]
end

LinkLuaModifier("modifier_vision_provider", "abilities/general/modifiers/modifier_vision_provider", LUA_MODIFIER_MOTION_NONE)

function OnTheMistParticleBlindCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	--local duration = ability:GetSpecialValueFor("duration")
	--caster.AuraDummy:AddNewModifier(target, nil, "modifier_vision_provider", {Duration = duration})
	--local radius = ability:GetSpecialValueFor("radius") 
	--target.MistBlind = ParticleManager:CreateParticleForPlayer("particles/custom/jtr/murderer_mist.vpcf", PATTACH_ABSORIGIN, target, target:GetPlayerOwner())
	--ParticleManager:SetParticleControl(target.MistBlind, 0, caster.AuraDummy:GetAbsOrigin())	
	--ParticleManager:SetParticleControl(target.MistBlind, 1, Vector(radius,0,0))
end

function OnTheMistParticleBlindDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	--caster.AuraDummy:RemoveModifierByName("modifier_vision_provider")
	--ParticleManager:DestroyParticle(target.MistBlind, true)
	--ParticleManager:ReleaseParticleIndex(target.MistBlind)
end

function OnTheMistDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target

	--if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	
	--[[ParticleManager:DestroyParticle(target.AuraBorderFx, false)
	ParticleManager:ReleaseParticleIndex(target.AuraBorderFx)
	ParticleManager:DestroyParticle(target.MistParticle, false)
	ParticleManager:ReleaseParticleIndex(target.MistParticle)]]
end

function OnTheMistSelfCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_the_mist_invis", {})
end

function OnTheMistSelfThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius") 
	local distance = (caster:GetAbsOrigin() - caster.AuraDummy:GetAbsOrigin()):Length2D() 
	if distance <= radius then
		if caster:HasModifier("modifier_jtr_the_mist_fade") then
			return 
		elseif caster:HasModifier("modifier_jtr_the_mist_invis") then
			return
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_the_mist_invis", {})
		end
	else
		caster:RemoveModifierByName("modifier_jtr_the_mist_invis")
	end
end

function OnTheMistSelfRemove(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:HasModifier("modifier_jtr_the_mist_invis") then 
		caster:RemoveModifierByName("modifier_jtr_the_mist_invis")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_the_mist_fade", {})
end

function OnTheMistSelfDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:HasModifier("modifier_jtr_the_mist_fade") then 
		caster:RemoveModifierByName("modifier_jtr_the_mist_fade")
	end
	if caster:HasModifier("modifier_jtr_the_mist_invis") then 
		caster:RemoveModifierByName("modifier_jtr_the_mist_invis")
	end
end

function OnTheMistSelfDeath(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_jtr_the_mist_checker") then 
		caster:RemoveModifierByName("modifier_jtr_the_mist_checker")
	end
end

function OnTheMistFadeStart(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_jtr_the_mist_invis") then 
		caster:RemoveModifierByName("modifier_jtr_the_mist_invis")
	end
end

function OnTheMistFadeDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_the_mist_invis", {})
end

function OnInvalidCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
end

function OnMariaUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsHolyMotherAcquired and caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):SetLevel(ability:GetLevel())
				return
			end
		end
	elseif not caster.IsHolyMotherAcquired and caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):SetLevel(ability:GetLevel())
				return
			end
		end
	elseif caster.IsHolyMotherAcquired and not caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):SetLevel(ability:GetLevel())
				return
			end
		end
	elseif not caster.IsHolyMotherAcquired and not caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper_curse"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper_curse"):SetLevel(ability:GetLevel())
				return
			end
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("jtr_maria_the_ripper"):GetLevel() then
				caster:FindAbilityByName("jtr_maria_the_ripper"):SetLevel(ability:GetLevel())
				return
			end
		end
	end
end 

function OnMariaActive(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsHolyMotherAcquired and caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_3" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_3" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif not caster.IsHolyMotherAcquired and caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_2" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_2" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif caster.IsHolyMotherAcquired and not caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper_upgrade_1" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse_upgrade_1" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	elseif not caster.IsHolyMotherAcquired and not caster.IsMurdererOfMistyNightAcquired then 
		if ability:GetAbilityName() == "jtr_maria_the_ripper" then 
			caster:FindAbilityByName("jtr_maria_the_ripper_curse"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		elseif ability:GetAbilityName() == "jtr_maria_the_ripper_curse" then 
			caster:FindAbilityByName("jtr_maria_the_ripper"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		end
	end
end

function OnMariaCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local cast_point = ability:GetSpecialValueFor("cast_point") 
	local reduced_cast_point = ability:GetSpecialValueFor("reduced_cast_point") 
	if caster.IsMurdererOfMistyNightAcquired then 
		if caster:HasModifier("modifier_jtr_the_mist_invis") or caster:HasModifier("modifier_jtr_whitechapel_self") or caster:HasModifier("modifier_jtr_the_mist_fade") then 
			ability:SetOverrideCastPoint(reduced_cast_point)
		else
			ability:SetOverrideCastPoint(cast_point)
		end
	end
end

function OnMariaStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local total_hit = ability:GetSpecialValueFor("total_hit") 

	StartAnimation(caster, {duration = 1.2, activity= ACT_DOTA_CAST_ABILITY_4 , rate=1.5})

	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = 1.1})
	giveUnitDataDrivenModifier(caster, caster, "dragged", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "revoked", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.1)

    target:EmitSound("jtr_maria_slashes")
	EmitGlobalSound("jtr_maria_the_ripper")

	for i = 1,total_hit do 
		Timers:CreateTimer(0.25 * i, function()  
			if caster:IsAlive() and target:IsAlive() then
				PerformSlash(caster, ability, target, i)
				if i == total_hit - 1 then 
					StartAnimation(caster, {duration = 1.2, activity= ACT_DOTA_CAST_ABILITY_4_END , rate=1.5})
				end
				if i == total_hit then 
					caster:RemoveModifierByName("jump_pause")
					if IsValidEntity(target) and target:IsAlive() then
						if target:HasModifier("modifier_jtr_whitechapel_female_enemies") and IsFemaleServant(target) then
							local curse_chance = ability:GetSpecialValueFor("curse") 
							if caster:HasModifier("modifier_jtr_holy_mother_buff") then 
								local bonus_curse = ability:GetSpecialValueFor("bonus_curse") 
								local stack = caster:GetModifierStackCount("modifier_jtr_holy_mother_buff", caster) or 0 * bonus_curse
								curse_chance = curse_chance + stack
							end
							if RandomInt(1, 100) <= curse_chance then 
								if IsUnExecute(target) then
									DoDamage(caster, target, 9999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_NONE, ability, false)
								else
									target:Execute(ability, caster, { bExecution = true })
									if not caster:FindAbilityByName("jtr_illusion_trap_curse"):IsCooldownReady() then 
										caster:FindAbilityByName("jtr_illusion_trap_curse"):EndCooldown() 
									end
									local curseIndex = ParticleManager:CreateParticle("particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownmarker.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
									ParticleManager:SetParticleControl(curseIndex, 0, target:GetAbsOrigin() + Vector(0,0,100))
									ParticleManager:SetParticleControl(curseIndex, 2, Vector(100,0,0))
									Timers:CreateTimer(1.0, function()  
										ParticleManager:DestroyParticle(curseIndex, false)
										ParticleManager:ReleaseParticleIndex(curseIndex)
										return 
									end)
								end
							end
						end
					end
				end
			else
				caster:RemoveModifierByName("jump_pause")
			end
			return 
		end)
	end
end

function PerformSlash(caster,ability,target,iHit)
	local damage_per_hit = ability:GetSpecialValueFor("damage_per_hit") 
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if caster.IsMurdererOfMistyNightAcquired then 
		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.1 })
		end
	end

	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100) 
	if iHit == 1 then 
		slasheff = "particles/custom/jtr/jtr_maria_a.vpcf"
		point1 = target:GetAbsOrigin() + Vector(0,0,100)
		point2 = target:GetAbsOrigin() + Vector(0,0,100)
	elseif iHit == 2 then 
		slasheff = "particles/custom/jtr/jtr_maria_b.vpcf"
		point1 = target:GetAbsOrigin() + Vector(0,0,100)
		point2 = target:GetAbsOrigin() + Vector(0,0,100)
	elseif iHit == 3 then 
		slasheff = "particles/custom/jtr/jtr_maria_c.vpcf"
		point1 = target:GetAbsOrigin() + Vector(0,0,300)
		point2 = target:GetAbsOrigin() + Vector(0,0,0)
	elseif iHit == 4 then 
		slasheff = "particles/custom/jtr/jtr_maria_d.vpcf"
		point1 = target:GetAbsOrigin() + Vector(-200,0,100)
		point2 = target:GetAbsOrigin() + Vector(200,0,100)
	end

	local hitIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(hitIndex, 0, target:GetAbsOrigin() + Vector(0,0,200))

	local slashIndex = ParticleManager:CreateParticle(slasheff, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(slashIndex, 1, point1)
	ParticleManager:SetParticleControl(slashIndex, 2, point2)

	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	Timers:CreateTimer(0.25, function()  
		ParticleManager:DestroyParticle(hitIndex, false)
		ParticleManager:ReleaseParticleIndex(hitIndex)
		ParticleManager:DestroyParticle(slashIndex, false)
		ParticleManager:ReleaseParticleIndex(slashIndex)
		return 
	end)

	if IsSpellBlocked(target) then return end

	local damage_type = DAMAGE_TYPE_MAGICAL

	if caster.IsHolyMotherAcquired then
		if IsFemaleServant(target) then
			damage_type = DAMAGE_TYPE_PURE
		end
	end
	OnAmbushDealDamage(caster,ability,target)		
	DoDamage(caster, target, damage_per_hit, damage_type, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
	
end

function OnAbilityCastCheck (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc)  then
		SendErrorMessage(caster:GetPlayerID(), "#Cannot_Travel")
		return 
	end 
	if IsLocked(caster) and not caster:HasModifier("modifier_jtr_whitechapel_self") then
		SendErrorMessage(caster:GetPlayerID(), "#Cannot_Blink")
        return
    end
end

function GhostWalkStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local origin = caster:GetAbsOrigin()
	local max_distance = ability:GetSpecialValueFor("distance")
	local min_distance = ability:GetSpecialValueFor("min_distance")
	
	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc)  then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	if IsLocked(caster) and not caster:HasModifier("modifier_jtr_whitechapel_self") then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end
	local distance = (target_loc - origin):Length2D()
	local forwardVec = (target_loc - origin):Normalized()
	if distance >= max_distance then 
		target_loc = origin + forwardVec * max_distance
		distance = max_distance
	elseif distance <= min_distance then 
		target_loc = origin + forwardVec * min_distance
		distance = min_distance
	end 
	local ghostwalk = {
		Ability = ability,
		EffectName = "",
		iMoveSpeed = 9999,
		vSpawnOrigin = origin,
		fDistance = distance,
		Source = caster,
		fStartRadius = 150,
        fEndRadius = 150,
		bHasFrontialCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.5,
		bDeleteOnHit = false,
		vVelocity = forwardVec * 9999,
	}
	local projectile = ProjectileManager:CreateLinearProjectile(ghostwalk)

	Timers:CreateTimer( 0.1, function()
		OnGhostWalkBlink (caster, target_loc, max_distance)
	end)
end

function GhostWalkHit (keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local base_dmg = ability:GetSpecialValueFor("base_dmg")

	local slashIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())

	caster:PerformAttack( target, true, true, true, true, false, false, false )

	DoDamage(caster, target, base_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
	Timers:CreateTimer(0.25, function()  
		ParticleManager:DestroyParticle(slashIndex, false)
		ParticleManager:ReleaseParticleIndex(slashIndex)
		return 
	end)
end

function OnGhostWalkBlink (hCaster, vTarget, fMaxDistance, tParams)

    local tParams = tParams or {}
    
    local bDodge = true
    if tParams.bDodgeProjectiles ~= nil then bDodge = tParams.bDodgeProjectiles end
    
    local bNavCheck = true
    if tParams.bNavCheck ~= nil then bNavCheck = tParams.bNavCheck end

    local vPos = hCaster:GetAbsOrigin()
    local vDifference = vTarget - vPos
    
    local vDirection = vDifference:Normalized()
    local fDistance = vDifference:Length()
    if fDistance >= fMaxDistance then fDistance = fMaxDistance end
    local vBlinkPos = vPos + (vDirection * fDistance)
    
    if bNavCheck then
		local i = 0
        local iStep = 10
        local iSteps = math.ceil(fDistance / iStep)

        while GridNav:IsBlocked( vBlinkPos ) or not GridNav:IsTraversable( vBlinkPos )do
            i = i + 1
            vBlinkPos = vPos + (vDirection * (fDistance - i * iStep))
            if i >= iSteps then break end
        end
    end

    ProjectileManager:ProjectileDodge(hCaster)
    FindClearSpaceForUnit(hCaster, vBlinkPos, true)
end


function OnInformationEraseStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local cooldown_forced = ability:GetSpecialValueFor("cooldown_forced") 

	if not IsSpellBlocked(target) then
		for i=0, 5 do 
			local abilities = target:GetAbilityByIndex(i)
			if abilities ~= nil then
				rCooldown = abilities:GetCooldownTimeRemaining() or 0
				abilities:EndCooldown()
				abilities:StartCooldown(rCooldown + cooldown_forced)
			else 
				break
			end
		end

		ApplyStrongDispel(target)
		target:RemoveModifierByName("modifier_heart_of_harmony")
	end
end

function OnHolyMotherKill(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.unit
	local kill_stack = caster:GetModifierStackCount("modifier_jtr_holy_mother_passive", caster) or 0
	
	if IsFemaleServant(target) then 
		if not caster:HasModifier("modifier_jtr_holy_mother_buff") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_holy_mother_buff", {})
		end
		caster:SetModifierStackCount("modifier_jtr_holy_mother_passive", caster, kill_stack + 1)
		caster:SetModifierStackCount("modifier_jtr_holy_mother_buff", caster, kill_stack + 1)
		caster:CalculateStatBonus(true)
	end 
end

function OnMentalPollutionDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_mental_pollution_cooldown", {duration = ability:GetCooldown(1)})
end

function OnMentalPollutionCooldownDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_mental_pollution_passive", {})
end

function OnSoulEaterDealDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local damage = keys.AttackDamage
	local target = keys.unit
	local mana_drain = ability:GetSpecialValueFor("mana_drain") 
	if caster:HasModifier("modifier_jtr_murderer_mist_buff") or caster:HasModifier("modifier_jtr_murderer_mist_buff_active") then 
		mana_drain = mana_drain / 2
	end
	local base_healing = ability:GetSpecialValueFor("base_healing")
	local agi_bonus = ability:GetSpecialValueFor("agi_bonus") / 100
	local healing_radius = ability:GetSpecialValueFor("healing_radius")
	local healing_cap = ability:GetSpecialValueFor("healing_cap") / 100 * caster:GetMaxHealth() 
	local total_heal = base_healing + (agi_bonus * caster:GetAgility()) 
	if total_heal > healing_cap then 
		total_heal = healing_cap 
	end 
	local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, healing_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for k,v in pairs(allies) do
		if IsValidEntity(v) and not v:IsNull() then
			v:Heal(total_heal, caster)
		end
	end

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	
	if not IsManaLess(target) then
		if target:GetMana() >= mana_drain then
			target:SetMana(target:GetMana() - mana_drain)
			caster:GiveMana(mana_drain)
		else
			caster:GiveMana(target:GetMana())
			target:SetMana(0)
		end
	end
end

function IsJackbeSeen(caster)
	local seen = false
	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see jack, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				seen = true 
				return seen
			end
		end
	end)

	return seen
end

function OnAmbushThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local active_time = ability:GetSpecialValueFor("active_time")
	local recharge_time = ability:GetSpecialValueFor("recharge_time")
	--[[if caster.bIsVisibleToEnemy == nil then 
		caster.bIsVisibleToEnemy = false 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff", {})
	end]]

	--caster.bIsVisibleToEnemy = IsJackbeSeen(caster)

	if IsJackbeSeen(caster) == true then
		if caster:IsInvisible() or caster:HasModifier("modifier_jtr_the_mist_fade") then 
			if caster:HasModifier("modifier_jtr_murderer_mist_cooldown") then
				caster:RemoveModifierByName("modifier_jtr_murderer_mist_cooldown")
			end
			if not caster:HasModifier("modifier_jtr_murderer_mist_buff") then
				caster:RemoveModifierByName("modifier_jtr_murderer_mist_cooldown_recharge")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff", {})
				return
			else
				return
			end
		else
			if caster:HasModifier("modifier_jtr_murderer_mist_buff") then
				caster:RemoveModifierByName("modifier_jtr_murderer_mist_buff")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff_active", {})
				return 
			else
				return 
			end
		end
	else
		if caster:HasModifier("modifier_jtr_murderer_mist_cooldown") then
			caster:RemoveModifierByName("modifier_jtr_murderer_mist_cooldown")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_cooldown_recharge", {})
			return 
		elseif caster:HasModifier("modifier_jtr_murderer_mist_cooldown_recharge") or caster:HasModifier("modifier_jtr_murderer_mist_buff_active") then
			return 
		elseif not caster:HasModifier("modifier_jtr_murderer_mist_buff") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff", {})
			return
		end
	end
end

function OnAmbushBroke(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if IsJackbeSeen(caster) == true then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_cooldown", {})
	else
		if caster:HasModifier("modifier_jtr_the_mist_invis") or caster:HasModifier("modifier_jtr_whitechapel_self") then 
			local the_mist = caster:FindAbilityByName("jtr_the_mist_upgrade")
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_cooldown_recharge", {Duration = the_mist:GetSpecialValueFor("fade_time")})
		else	
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_cooldown_recharge", {})
		end
	end
end

function OnAmbushRespawn(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	--if caster:HasModifier("modifier_jtr_murderer_mist_buff_active") then 
		caster:RemoveModifierByName("modifier_jtr_murderer_mist_buff_active")
	--elseif caster:HasModifier("modifier_jtr_murderer_mist_cooldown") then 
		caster:RemoveModifierByName("modifier_jtr_murderer_mist_cooldown")
	--elseif caster:HasModifier("modifier_jtr_murderer_mist_cooldown_recharge") then 
		caster:RemoveModifierByName("modifier_jtr_murderer_mist_cooldown_recharge")
	--end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff", {})
end

function OnAmbushRechargeBroke(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:IsAlive() then
		if IsJackbeSeen(caster) == true then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_cooldown", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_murderer_mist_buff", {})
		end
	end
end


function OnAmbushAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	OnAmbushDealDamage(caster,ability,target)
end

function OnAmbushDealDamage(caster,ability,target)
	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if caster.IsMurdererOfMistyNightAcquired and (caster:HasModifier("modifier_jtr_murderer_mist_buff") or caster:HasModifier("modifier_jtr_murderer_mist_buff_active")) then
		local ambush = caster:FindAbilityByName("jtr_murderer_on_misty_night")
		local agi_damage = ambush:GetSpecialValueFor("invis_agi_damage") 
		DoDamage(caster, target, caster:GetAgility() * agi_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function JackCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "jtr_the_mist") and caster:FindAbilityByName("jtr_whitechapel"):IsCooldownReady() and not caster:HasModifier("modifier_jtr_whitechapel_cooldown") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_whitechapel_window", {})
		end
	end
end

function OnWhiteChapelWindowCreate(keys)
	local caster = keys.caster 
	if caster.IsMurdererOfMistyNightAcquired then 
		caster:SwapAbilities("jtr_the_mist_upgrade", "jtr_whitechapel", false, true)
	else
		caster:SwapAbilities("jtr_the_mist", "jtr_whitechapel", false, true)
	end
end

function OnWhiteChapelWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsMurdererOfMistyNightAcquired then 
		caster:SwapAbilities("jtr_the_mist_upgrade", "jtr_whitechapel", true, false)
	else
		caster:SwapAbilities("jtr_the_mist", "jtr_whitechapel", true, false)
	end
end

function OnWhiteChapelWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_whitechapel_window")
end

function OnWhiteChapelStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")

	EmitGlobalSound("jtr_combo")

	caster:RemoveModifierByName("modifier_whitechapel_window")

	if caster.AuraDummy ~= nil and not caster.AuraDummy:IsNull() and IsValidEntity(caster.AuraDummy) then 
		caster.AuraDummy:RemoveModifierByName("modifier_jtr_the_mist_aura_enemies")
		ParticleManager:DestroyParticle(caster.mistfx, false)
		ParticleManager:ReleaseParticleIndex(caster.mistfx)
		ParticleManager:DestroyParticle(caster.AuraBorderFx, false)
		ParticleManager:ReleaseParticleIndex(caster.AuraBorderFx)
		Timers:RemoveTimer(caster.mistTimer)
		caster.AuraDummy:RemoveSelf()
		caster:RemoveModifierByName("modifier_jtr_the_mist_checker")
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_whitechapel_self", {})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_jtr_whitechapel_cooldown", {duration = ability:GetCooldown(1)})

	local masterCombo = caster.MasterUnit2:FindAbilityByName("jtr_whitechapel")
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(ability:GetCooldown(1))

    LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and playerHero:IsAlive() then
        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_jtr_whitechapel_enemies", {})
        	if IsFemaleServant(playerHero) then 
        		ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_jtr_whitechapel_female_enemies", {})
        	end
        elseif playerHero:GetTeamNumber() == caster:GetTeamNumber() and playerHero:IsAlive() and playerHero ~= caster then
        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_jtr_whitechapel_allies", {})
        end
    end)
end

function OnWhiteChapelDie(keys)
	local caster = keys.caster 
	LoopOverPlayers(function(player, playerID, playerHero)        
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_enemies")
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_allies")      
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_female_enemies")     
    end)
end

function OnWhiteChapelCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")

	caster.ParticleDummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.ParticleDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

	caster.Particle = ParticleManager:CreateParticle("particles/custom/jtr/invis_smoke.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster.ParticleDummy)

	ParticleManager:SetParticleControl(caster.Particle, 1, caster.ParticleDummy:GetAbsOrigin())

	if caster.IsHolyMotherAcquired then 
		if caster.IsMurdererOfMistyNightAcquired then 
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_3", "jtr_maria_the_ripper_upgrade_3", true, false)
		else
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_1", "jtr_maria_the_ripper_upgrade_1", true, false)
		end
		caster:SwapAbilities("jtr_quick_strikes_curse_upgrade", "jtr_quick_strikes_upgrade", true, false)
	else
		if caster.IsMurdererOfMistyNightAcquired then 
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_2", "jtr_maria_the_ripper_upgrade_2", true, false)
		else
			caster:SwapAbilities("jtr_maria_the_ripper_curse", "jtr_maria_the_ripper", true, false)
		end
		caster:SwapAbilities("jtr_quick_strikes_curse", "jtr_quick_strikes", true, false)
	end
	caster:SwapAbilities("jtr_ghost_walk", "jtr_dagger_throw", true, false)
	caster:SwapAbilities("jtr_illusion_trap_curse", "jtr_surgery", true, false)
end

function OnWhiteChapelThink(keys)
	local caster = keys.caster 
	caster.ParticleDummy:SetAbsOrigin(caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster.Particle, 1, caster.ParticleDummy:GetAbsOrigin())
end

function OnWhiteChapelDestroy(keys)
	local caster = keys.caster 
	if caster.IsHolyMotherAcquired then 
		if caster.IsMurdererOfMistyNightAcquired then 
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_3", "jtr_maria_the_ripper_upgrade_3", false, true)
		else
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_1", "jtr_maria_the_ripper_upgrade_1", false, true)
		end
		caster:SwapAbilities("jtr_quick_strikes_curse_upgrade", "jtr_quick_strikes_upgrade", false, true)
	else
		if caster.IsMurdererOfMistyNightAcquired then 
			caster:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_2", "jtr_maria_the_ripper_upgrade_2", false, true)
		else
			caster:SwapAbilities("jtr_maria_the_ripper_curse", "jtr_maria_the_ripper", false, true)
		end
		caster:SwapAbilities("jtr_quick_strikes_curse", "jtr_quick_strikes", false, true)
	end
	caster:SwapAbilities("jtr_ghost_walk", "jtr_dagger_throw", false, true)
	caster:SwapAbilities("jtr_illusion_trap_curse", "jtr_surgery", false, true)

	LoopOverPlayers(function(player, playerID, playerHero)        
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_enemies")
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_allies")      
        playerHero:RemoveModifierByName("modifier_jtr_whitechapel_female_enemies")     
    end)
    ParticleManager:DestroyParticle(caster.Particle, false)
	ParticleManager:ReleaseParticleIndex(caster.Particle)
	if IsValidEntity(caster.ParticleDummy) then
		caster.ParticleDummy:RemoveSelf()
	end
end

function OnIllusionTrapStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	caster.traptarget = target
	if not target:IsMagicImmune() then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_illusion_trap", {})
	end
end

function OnIllusionTrapThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local dps = ability:GetSpecialValueFor("dps") * 0.1
	DoDamage(caster, target, dps, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnIllusionTrapTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local attacker = keys.attacker 
	
	if attacker ~= caster then 
		if caster.traptarget:IsAlive() then
			caster.traptarget:RemoveModifierByName("modifier_illusion_trap")
		end
	end
end

function OnIllusionTrapDeath(keys)
	local caster = keys.caster 
	if caster.traptarget ~= nil then
		caster.traptarget:RemoveModifierByName("modifier_illusion_trap")
	end
end

function OnInformationEraseAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsInformationEraseAcquired) then

		hero.IsInformationEraseAcquired = true

		hero:FindAbilityByName("jtr_information_erase"):SetLevel(1)
		hero:SwapAbilities("jtr_information_erase", "fate_empty1", true, false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMentalPollutionAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMentalPollutionAcquired) then

		hero.IsMentalPollutionAcquired = true

		hero:FindAbilityByName("jtr_mental_pollution_passive"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSoulEaterAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSoulEaterAcquired) then

		hero.IsSoulEaterAcquired = true

		hero:FindAbilityByName("jtr_soul_eater_passive"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMurdererOnMistyNightAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMurdererOfMistyNightAcquired) then

		hero.IsMurdererOfMistyNightAcquired = true

		hero:FindAbilityByName("jtr_murderer_on_misty_night"):SetLevel(1)

		hero:AddAbility("jtr_the_mist_upgrade")
		hero:FindAbilityByName("jtr_the_mist_upgrade"):SetLevel(hero:FindAbilityByName("jtr_the_mist"):GetLevel())
		if not hero:FindAbilityByName("jtr_the_mist"):IsCooldownReady() then 
			hero:FindAbilityByName("jtr_the_mist_upgrade"):StartCooldown(hero:FindAbilityByName("jtr_the_mist"):GetCooldownTimeRemaining())
		end
		hero:SwapAbilities("jtr_the_mist", "jtr_the_mist_upgrade", false, true)
		hero:RemoveAbility("jtr_the_mist")

		if hero.IsHolyMotherAcquired then 
			hero:AddAbility("jtr_maria_the_ripper_upgrade_3")
			hero:AddAbility("jtr_maria_the_ripper_curse_upgrade_3")
			hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):GetLevel())
			hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):GetLevel())
			if not hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_jtr_whitechapel_self") then 
				hero:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_1", "jtr_maria_the_ripper_curse_upgrade_3", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):SetHidden(true)
			else
				hero:SwapAbilities("jtr_maria_the_ripper_upgrade_1", "jtr_maria_the_ripper_upgrade_3", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):SetHidden(true)
			end
		else
			hero:AddAbility("jtr_maria_the_ripper_upgrade_2")
			hero:AddAbility("jtr_maria_the_ripper_curse_upgrade_2")
			hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper"):GetLevel())
			hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper"):GetLevel())
			if not hero:FindAbilityByName("jtr_maria_the_ripper"):IsCooldownReady() then 
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_jtr_whitechapel_self") then 
				hero:SwapAbilities("jtr_maria_the_ripper_curse", "jtr_maria_the_ripper_curse_upgrade_2", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):SetHidden(true)
			else
				hero:SwapAbilities("jtr_maria_the_ripper", "jtr_maria_the_ripper_upgrade_2", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_2"):SetHidden(true)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnHolyMotherAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHolyMotherAcquired) then

		hero.IsHolyMotherAcquired = true

		hero:FindAbilityByName("jtr_holy_mother_passive"):SetLevel(1)

		hero:AddAbility("jtr_quick_strikes_upgrade")
		hero:AddAbility("jtr_quick_strikes_curse_upgrade")
		hero:FindAbilityByName("jtr_quick_strikes_upgrade"):SetLevel(hero:FindAbilityByName("jtr_quick_strikes"):GetLevel())
		hero:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):SetLevel(hero:FindAbilityByName("jtr_quick_strikes"):GetLevel())
		if not hero:FindAbilityByName("jtr_quick_strikes"):IsCooldownReady() then 
			hero:FindAbilityByName("jtr_quick_strikes_upgrade"):StartCooldown(hero:FindAbilityByName("jtr_quick_strikes"):GetCooldownTimeRemaining())
			hero:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):StartCooldown(hero:FindAbilityByName("jtr_quick_strikes"):GetCooldownTimeRemaining())
		end
		if hero:HasModifier("modifier_jtr_whitechapel_self") then 
			hero:SwapAbilities("jtr_quick_strikes_curse", "jtr_quick_strikes_curse_upgrade", false, true)
			hero:FindAbilityByName("jtr_quick_strikes_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("jtr_quick_strikes", "jtr_quick_strikes_upgrade", false, true)
			hero:FindAbilityByName("jtr_quick_strikes_curse_upgrade"):SetHidden(true)
		end
		hero:RemoveAbility("jtr_quick_strikes_curse")
		hero:RemoveAbility("jtr_quick_strikes")

		if hero.IsMurdererOfMistyNightAcquired then 
			hero:AddAbility("jtr_maria_the_ripper_upgrade_3")
			hero:AddAbility("jtr_maria_the_ripper_curse_upgrade_3")
			hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):GetLevel())
			hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):GetLevel())
			if not hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_2"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_jtr_whitechapel_self") then 
				hero:SwapAbilities("jtr_maria_the_ripper_curse_upgrade_2", "jtr_maria_the_ripper_curse_upgrade_3", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_3"):SetHidden(true)
			else
				hero:SwapAbilities("jtr_maria_the_ripper_upgrade_2", "jtr_maria_the_ripper_upgrade_3", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_3"):SetHidden(true)
			end
		else
			hero:AddAbility("jtr_maria_the_ripper_upgrade_1")
			hero:AddAbility("jtr_maria_the_ripper_curse_upgrade_1")
			hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper"):GetLevel())
			hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):SetLevel(hero:FindAbilityByName("jtr_maria_the_ripper"):GetLevel())
			if not hero:FindAbilityByName("jtr_maria_the_ripper"):IsCooldownReady() then 
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper"):GetCooldownTimeRemaining())
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):StartCooldown(hero:FindAbilityByName("jtr_maria_the_ripper"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_jtr_whitechapel_self") then 
				hero:SwapAbilities("jtr_maria_the_ripper_curse", "jtr_maria_the_ripper_curse_upgrade_1", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_upgrade_1"):SetHidden(true)
			else
				hero:SwapAbilities("jtr_maria_the_ripper", "jtr_maria_the_ripper_upgrade_1", false, true)
				hero:FindAbilityByName("jtr_maria_the_ripper_curse_upgrade_1"):SetHidden(true)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
	