
function OnFairyDmgTaken(keys)
    local caster = keys.caster
    local ability = keys.ability 
    local damage_threshold = ability:GetSpecialValueFor("damage_threshold")
    if caster:GetHealth() <= damage_threshold and not IsReviveSeal(caster) and caster:IsAlive() and not caster:HasModifier("modifier_blessing_of_fairy_cooldown") then 
        caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_fairy_magic_immunity", {})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_blessing_of_fairy_cooldown", {duration = ability:GetCooldown(1)})
    	ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
    end
end

function OnEternalTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local damage_taken = keys.DamageTaken
	local dmg_block = ability:GetSpecialValueFor("dmg_block") 
	local parry_chance = ability:GetSpecialValueFor("parry_chance_passive")
	local currentHealth = caster:GetHealth()
	if caster:HasModifier("modifier_eternal_arms_mastership_active") then 
		parry_chance = ability:GetSpecialValueFor("parry_chance_active")
		local bonus_dmg_block = ability:GetSpecialValueFor("bonus_dmg_block_per_str")
		dmg_block = dmg_block + (bonus_dmg_block * caster:GetStrength())
	end

	if RandomInt(1, 100) <= parry_chance then 
		--print('current health ' .. currentHealth)
		--print('damage taken ' .. damage_taken)
		--print('parry damage ' .. dmg_block)
		if currentHealth <= 0 then 
			if currentHealth + dmg_block - damage_taken > 0 then 
				caster:SetHealth(currentHealth + dmg_block)
			end
		else
			caster:Heal(math.min(damage_taken, dmg_block), caster)
		end
	end
end

function OnEternalAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local critical_chance = ability:GetSpecialValueFor("critical_chance_passive")
	if caster:HasModifier("modifier_eternal_arms_mastership_active") then 
		critical_chance = ability:GetSpecialValueFor("critical_chance_active")
	end

	if RandomInt(1, 100) <= critical_chance then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_eternal_arms_mastership_crit", {})
	end
end

function OnEternalStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_eternal_arms_mastership_active", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_eternal_arms_mastership_cooldown", {duration = ability:GetCooldown(1)})
end

function OnKoHUPgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.KoH == nil then 
		caster.KoH = {}
		caster.KoH[1] = "lancelot_vortigern"
		caster.KoH[2] = "fate_empty2"
		caster.KoH[3] = "fate_empty3"
		caster.KoH[4] = "fate_empty4"
		caster.KoH[5] = "fate_empty5"
	end

	if caster.KoHA == nil then 
		caster.KoHA = {}
		caster.KoHA[1] = "lancelot_caliburn"
		caster.KoHA[2] = "fate_empty2"
		caster.KoHA[3] = "fate_empty3"
		caster.KoHA[4] = "fate_empty4"
		caster.KoHA[5] = "fate_empty5"
	end

	if ability:GetLevel() == 2 then 
		caster:RemoveAbility("fate_empty2")	
		caster.KoH[2] = "lancelot_gae_bolg"
		caster.KoHA[2] = "lancelot_vajra"
	elseif ability:GetLevel() == 3 then 
		caster.KoH[3] = "lancelot_rule_breaker"
		caster.KoHA[3] = "lancelot_rosa_ichthys"
		caster:RemoveAbility("fate_empty3")	
	elseif ability:GetLevel() == 4 then 
		caster.KoH[4] = "lancelot_nine_lives"
		caster.KoHA[4] = "lancelot_brahmastra_kundala"
		caster:RemoveAbility("fate_empty4")	
	elseif ability:GetLevel() == 5 then 
		caster.KoH[5] = "lancelot_tsubame_gaeshi"
		caster.KoHA[5] = "lancelot_gae_dearg"
		caster:RemoveAbility("fate_empty5")	
	end
	if caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:FindAbilityByName("lancelot_knight_of_honor_arsenal_upgrade"):SetLevel(ability:GetLevel())
	elseif caster.IsKnightOfOwnerArsenalAcquired then 
		caster:FindAbilityByName("lancelot_knight_of_honor_arsenal"):SetLevel(ability:GetLevel())
	end
end

function OnKoHStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:EndCooldown() 
	ability:ToggleAbility()
    if caster:HasModifier("modifier_arondite") then
    	caster:Stop()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Arondite_actived")
        return 
    elseif caster:HasModifier("modifier_gatling_weapon") then
    	caster:Stop()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Gatling_actived")
        return 
    end
    caster.IsKnightUsed = false 
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_knight_of_honor_check", {})
end

function OnKoHOpen (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local delay = 0

	if caster:HasModifier("modifier_lancelot_nuke_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_lancelot_nuke_window")
	end

	if caster:HasModifier("modifier_lancelot_arondite_overload_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_lancelot_arondite_overload_window")
	end

	if caster:HasModifier("modifier_gatling_weapon") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_gatling_weapon")
	end

	Timers:CreateTimer(delay, function()
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.KoH[1], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.KoH[2], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.KoH[3], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.KoH[4], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "lancelot_close_spellbook", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.KoH[5], false, true)
	end)

end

function OnKoHClose (keys)
	local caster = keys.caster 
	local ability = keys.ability 

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)

	
	if caster.IsKnightUsed == true and not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		ability:StartCooldown(ability:GetCooldown(1))
	end
end

function OnKoHAStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:EndCooldown() 
	ability:ToggleAbility()
    if caster:HasModifier("modifier_arondite") then
    	caster:Stop()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Arondite_actived")
        return 
    elseif caster:HasModifier("modifier_gatling_weapon") then
    	caster:Stop()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Gatling_actived")
        return 
    end
    
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_knight_of_honor_arsenal_check", {})
end

function OnKoHAOpen (keys)
	local caster = keys.caster 
	local ability = keys.ability 

	local delay = 0

	if caster:HasModifier("modifier_lancelot_nuke_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_lancelot_nuke_window")
	end

	if caster:HasModifier("modifier_lancelot_arondite_overload_window") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_lancelot_arondite_overload_window")
	end

	if caster:HasModifier("modifier_gatling_weapon") then 
		delay = 0.1 
		caster:RemoveModifierByName("modifier_gatling_weapon")
	end

	Timers:CreateTimer(delay, function()
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.KoHA[1], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.KoHA[2], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.KoHA[3], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.KoHA[4], false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), "lancelot_close_spellbook", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.KoHA[5], false, true)
	end)
	
end

function OnKoHAClose (keys)
	local caster = keys.caster 
	
	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetAbilityName(), caster.QSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetAbilityName(), caster.WSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), caster.ESkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetAbilityName(), caster.DSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetAbilityName(), caster.FSkill, false, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetAbilityName(), caster.RSkill, false, true)
end

function OnKnightClosed(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ToggleAbility()
	if caster:HasModifier("modifier_knight_of_honor_check") then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	elseif caster:HasModifier("modifier_knight_of_honor_arsenal_check") then 
		caster:RemoveModifierByName("modifier_knight_of_honor_arsenal_check")
	end
end

function OnVortigernStart(keys)
	--ArsenalReturnMana(keys.caster)
	local caster = keys.caster
	local ability = keys.ability
	caster.IsKnightUsed = true
	if not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	end
	local target_points = ability:GetCursorPosition()
	local forward = ( target_points - caster:GetAbsOrigin() ):Normalized() -- caster:GetForwardVector() 
	local angle = 120
	local increment_factor = 30
	local origin = caster:GetAbsOrigin()
	local destination = origin + forward
	local radius = ability:GetSpecialValueFor("radius")

	if (math.abs(destination.x - origin.x) < 0.01) and (math.abs(destination.y - origin.y) < 0.01) then
		destination = caster:GetForwardVector() + caster:GetAbsOrigin()
	end
	
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.70) -- Beam interval * 9 + 0.44
	EmitGlobalSound("Saber_Alter.Vortigern")
	StartAnimation(caster, {duration=0.70, activity=ACT_DOTA_ATTACK2, rate=2})

	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = 3000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = radius,
		Source = caster,
		fStartRadius = 75,
        fEndRadius = 120,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0,
	}
	
	--[[local casterAngle = QAngle(0, 120 ,0)
	Timers:CreateTimer(function() 
			if vortigernCount == 10 then vortigernCount = 0 return end -- finish spell
			vortigernBeam.vVelocity = RotatePosition(caster:GetAbsOrigin(), casterAngle, forward * 3000) 
			local projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 24;
			print(casterAngle.y)
			vortigernCount = vortigernCount + 1; 
			
			return 0.040 
		end
	)]]
	
	-- Base variables


	vortigernCount = 0
	Timers:CreateTimer( function()
			-- Finish spell, need to include the last angle as well
			-- Note that the projectile limit is currently at 9, to increment this, need to create either dummy or thinker to store them
			if vortigernCount == 9 then return end
			
			-- Start rotating
			local theta = ( angle - vortigernCount * increment_factor ) * math.pi / 180
			local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
			local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y

			local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
			vortigernBeam.vVelocity = new_forward * 3000
			vortigernBeam.fExpireTime = GameRules:GetGameTime() + 0.4
			
			-- Fire the projectile
			local projectile = ProjectileManager:CreateLinearProjectile( vortigernBeam )
			vortigernCount = vortigernCount + 1
			
			-- Create particles
			local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/saber_alter/saber_alter_vortigern_line.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex1, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex1, 1, vortigernBeam.vVelocity )
			ParticleManager:SetParticleControl( fxIndex1, 2, Vector( 0.2, 0.2, 0.2 ) )
			
			Timers:CreateTimer( 0.2, function()
					ParticleManager:DestroyParticle( fxIndex1, false )
					ParticleManager:ReleaseParticleIndex( fxIndex1 )
					return nil
				end
			)
			
			return 0.06
		end
	)
end

function OnVortigernHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	local StunDuration = ability:GetSpecialValueFor("stun_duration")
	local vortSwingDamage = 5
	local low_end = ability:GetSpecialValueFor("low_end")

	damage = damage * (low_end + vortigernCount * vortSwingDamage) / 100	
	StunDuration = StunDuration * (low_end + vortigernCount * 5)/100

	if target.IsVortigernHit ~= true then
		target.IsVortigernHit = true
		Timers:CreateTimer(0.54, function() target.IsVortigernHit = false return end)

		if not target:IsMagicImmune() and not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = StunDuration})
		end

		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			
	end

end

function GBAttachEffect(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)
	EmitGlobalSound("Lancelot.Growl_Local")
end


function OnGBTargetHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	caster.IsKnightUsed = true
	if not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	end
	local ply = caster:GetPlayerOwner()
	local HBThreshold = ability:GetSpecialValueFor("heart_break")
	local Damage = ability:GetSpecialValueFor("damage")
	local stun = ability:GetSpecialValueFor("stun")

	local flashIndex = ParticleManager:CreateParticle( "particles/custom/diarmuid/gae_dearg_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( flashIndex, 2, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( flashIndex, 3, caster:GetAbsOrigin() )

	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK2, rate=3})

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	target:EmitSound("Hero_Lion.Impale")

	if IsSpellBlocked(target) then -- no damage but play the effect
	else
		giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
		
		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		end

		-- Blood splat
		local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)	
		local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)	

		DoDamage(caster, target, Damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			if target:GetHealthPercent() < HBThreshold and not target:IsMagicImmune() and not IsUnExecute(target) then
				local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
				target:Execute(ability, caster, { bExecution = true })
				
				Timers:CreateTimer( 3.0, function()
					ParticleManager:DestroyParticle( hb, false )
					ParticleManager:ReleaseParticleIndex(hb)
				end)
			end  -- check for HB
		end

		
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splat, false )
			ParticleManager:DestroyParticle( culling_kill_particle, false )
			ParticleManager:ReleaseParticleIndex(culling_kill_particle)	
		end)
	end
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:DestroyParticle( flashIndex, false )
	end)
end

function OnRBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local revoke = ability:GetSpecialValueFor("revoke") 
	caster.IsKnightUsed = true
	if not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	end
	
	if IsSpellBlocked(target) then return end -- Linken effect checker
	ApplyStrongDispel(target)
	--caster:EmitSound("Medea_Rule_Breaker_" .. math.random(1,2))		
	giveUnitDataDrivenModifier(caster, target, "revoked", revoke)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_l_rule_breaker", {}) 

	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.StunDuration})
end

function OnNineCast(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_heracles_berserk") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_use_while_Berserked")
		return 
	end
	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_4, rate=2.0})
end

function OnNineStart(keys)
	
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local berserker = Physics:Unit(caster)
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance
	local pause_time = ability:GetSpecialValueFor("pause_time") 
	caster.IsKnightUsed = true
	if not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	end

	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*distance)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", pause_time)
	caster:EmitSound("Hero_OgreMagi.Ignite.Cast")

	StartAnimation(caster, {duration=1, activity=ACT_DOTA_RUN, rate=0.5})

	function DoNineLanded(caster)
		caster:OnPreBounce(nil)
		caster:OnPhysicsFrame(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		Timers:RemoveTimer(caster.NineTimer)
		caster.NineTimer = nil
		if caster:IsAlive() then
			OnNineLanded(caster, ability)
			return 
		end
		return
	end

	caster.NineTimer = Timers:CreateTimer(1.0, function()
		DoNineLanded(caster)
	end)

	caster:OnPhysicsFrame(function(unit)
		if CheckDummyCollide(unit) then
			DoNineLanded(unit)
		end
	end)

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		DoNineLanded(unit)
	end)

end

function OnNineLanded(caster, ability)
	local tickdmg = ability:GetSpecialValueFor("damage")
	local lasthitdmg = ability:GetSpecialValueFor("damage_lasthit")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local returnDelay = ability:GetSpecialValueFor("interval")
	local radius = ability:GetSpecialValueFor("radius")
	local lasthitradius = ability:GetSpecialValueFor("radius_lasthit")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local mini_stun = ability:GetSpecialValueFor("mini_stun")
	local revoke = ability:GetSpecialValueFor("revoke")
	local post_nine = ability:GetSpecialValueFor("post_nine")
	local nineCounter = 0
	local casterInitOrigin = caster:GetAbsOrigin() 


	-- main timer
	Timers:CreateTimer(function()
		if caster:IsAlive() then -- only perform actions while caster stays alive
			local particle = ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector() * -1)
			ParticleManager:SetParticleControl(particle, 1, Vector(0,0,(nineCounter % 2) * 180))
			ParticleManager:SetParticleControl(particle, 2, Vector(1,1,radius))
			ParticleManager:SetParticleControl(particle, 3, Vector(radius / 250,1,1))

			caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 

			if nineCounter == total_hit - 1 then -- if it is last strike

				StartAnimation(caster, {duration = 1.0, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate = 3.0})
				caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
				caster:RemoveModifierByName("pause_sealdisabled") 
				caster:AddNewModifier(caster, ability, "modifier_stunned", { Duration = post_nine })
				ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 1500, 0, true)
				-- do damage to targets

				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
				for k,v in pairs(lasthitTargets) do
					if IsValidEntity(v) and not v:IsNull() and v:GetName() ~= "npc_dota_ward_base" then
						if not v:IsMagicImmune() then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun_duration })
						end
						DoDamage(caster, v, lasthitdmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)

						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
						-- push enemies back
							if not IsKnockbackImmune(v) then
								local pushback = Physics:Unit(v)
								v:PreventDI()
								v:SetPhysicsFriction(0)
								v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
								v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
								v:FollowNavMesh(false)
								Timers:CreateTimer(0.5, function()  
									v:PreventDI(false)
									v:SetPhysicsVelocity(Vector(0,0,0))
									v:OnPhysicsFrame(nil)
									FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
								end)
							end
						end
					end
				end

				EmitGlobalSound("Lancelot.Growl" )

				ParticleManager:SetParticleControl(particle, 2, Vector(1,1,lasthitradius))
				ParticleManager:SetParticleControl(particle, 3, Vector(lasthitradius / 350,1,1))
				ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/last_hit.vpcf", PATTACH_ABSORIGIN, caster)

				-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, lasthitradius, true, 0.5)
			else
				-- if its not last hit, do regular hit stuffs

				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
						if not v:IsMagicImmune() then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = mini_stun })
						end
						DoDamage(caster, v, tickdmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
				end
				if caster:HasModifier("modifier_alternate_01") then 
					if nineCounter % 2 == 0 then 
						StartAnimation(caster, {duration = returnDelay, activity=ACT_DOTA_ATTACK, rate = 2.5})
					else
						StartAnimation(caster, {duration = returnDelay, activity=ACT_DOTA_ATTACK2, rate = 2.5})
					end
				else
					if nineCounter % 2 == 0 then 
						StartAnimation(caster, {duration = returnDelay * 2, activity=ACT_DOTA_CAST_ABILITY_3_END, rate = 1.0})
					end
				end
				--[[local random_anim = RandomInt(1, 2)
					StartAnimation(caster, {duration = returnDelay * 2, activity=ACT_DOTA_CAST_ABILITY_3_END, rate = 1.0})
				if random_anim == 1 then 
					StartAnimation(caster, {duration = returnDelay, activity=ACT_DOTA_ATTACK, rate = 2.5})
				else
					StartAnimation(caster, {duration = returnDelay, activity=ACT_DOTA_ATTACK2, rate = 2.5})
				end]]

				ParticleManager:SetParticleControl(particle, 2, Vector(1,1,radius))
				ParticleManager:SetParticleControl(particle, 3, Vector(radius / 350,1,1))
				-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)

				nineCounter = nineCounter + 1
				return returnDelay
			end

		end 
	end)
end

function TGPlaySound(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end

	EmitGlobalSound("Lancelot.Growl" )

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, caster:GetAbsOrigin() + diff/2)
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(600,0,150))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.4,0,0))
end

function OnTGStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local pause = ability:GetSpecialValueFor("pause")
	local damage = ability:GetSpecialValueFor("damage")
	local lasthit_damage = ability:GetSpecialValueFor("lasthit_damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	caster.IsKnightUsed = true
	if not caster.IsImproveKnightOfOwnerAcquired and not caster.IsKnightOfOwnerArsenalAcquired then 
		caster:RemoveModifierByName("modifier_knight_of_honor_check")
	end

	--target:TriggerSpellReflect(ability)
	--if IsSpellBlocked(target) then return end -- Linken effect checker
	EmitGlobalSound("FA.Chop")

	giveUnitDataDrivenModifier(caster, caster, "dragged", pause)
	giveUnitDataDrivenModifier(caster, caster, "revoked", pause)
		
    Timers:CreateTimer(0.2, function()
		caster:AddNewModifier(caster, nil, "modifier_phased", {duration=pause})	
	end)

	local particle = ParticleManager:CreateParticle("particles/custom/false_assassin/tsubame_gaeshi/slashes.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 

	Timers:CreateTimer(0.5, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			
			DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
			local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))

			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	Timers:CreateTimer(0.7, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	
			DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
			local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
		    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
		    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
		    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))

			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	Timers:CreateTimer(0.9, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			if target:HasModifier("modifier_instinct_active") and target:GetName() == "npc_dota_hero_legion_commander" then
				lasthit_damage = 0
			end -- if target has instinct up, block the last hit

			if IsSpellBlocked(target) and target:GetName() == "npc_dota_hero_legion_commander" then
			else
				target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
			
				DoDamage(caster, target, lasthit_damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
			end

			local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
		else
			ParticleManager:DestroyParticle(particle, true)
		end
		local position = caster:GetAbsOrigin()

		FindClearSpaceForUnit(caster, position, true)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.2)
	return end)
end

function CaliburnExplode( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target

	-- Create particle
	local slashFxIndex = ParticleManager:CreateParticle( "particles/custom/saber/caliburn/slash.vpcf", PATTACH_ABSORIGIN, target )
	local explodeFxIndex = ParticleManager:CreateParticle( "particles/custom/saber/caliburn/explosion.vpcf", PATTACH_ABSORIGIN, target )
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( slashFxIndex, false )
		ParticleManager:DestroyParticle( explodeFxIndex, false )
		return nil
	end)
end

function OnCaliburnHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local mini_stun = ability:GetSpecialValueFor("mini_stun")

	if not IsImmuneToSlow(target) and not IsImmuneToCC(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_caliburn_slow", {}) 
	end

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", { Duration = mini_stun })
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())

	local aoedmg = keys.Damage * keys.AoEDamage / 100
	DoDamage(caster, target , keys.Damage - aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v , aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end

    caster:EmitSound("Saber.Caliburn")
end

function OnRIStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local range = ability:GetSpecialValueFor("range")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	CreateSlashFx(caster, caster:GetAbsOrigin(), caster:GetAbsOrigin() + diff:Normalized() * diff:Length2D())
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	StartAnimation(caster, {duration = 1, activity = ACT_DOTA_ATTACK2, rate = 1.5})	
	caster:MoveToTargetToAttack(target)
	caster.rosatarget = target

	if IsSpellBlocked(target) then return end

	if not target:IsMagicImmune() and not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end

	target:EmitSound("Hero_Lion.FingerOfDeath")

	if not IsImmuneToCC(target) and not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_lancelot_rosa_slow", {})
	end

	local slashFx = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( slashFx, 0, target:GetAbsOrigin() + Vector(0,0,300))

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( slashFx, false )
		ParticleManager:ReleaseParticleIndex( slashFx )
	end)

	-- Too dumb to make particles, just call cleave function 4head
	DoCleaveAttack(caster, caster, ability, 0, 200, 400, 500, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf")
	local slash = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 5000,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 500 - 200,
        fStartRadius = 200,
        fEndRadius = 400,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 0.1,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 5000
	}
	local projectile = ProjectileManager:CreateLinearProjectile(slash)
end

function OnRIHit(keys)
	local caster = keys.caster
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local ability = keys.ability
	if target == nil then return end
	local damage = ability:GetSpecialValueFor("damage")
	damage = damage / 2
	if target ~= caster.rosatarget then 
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnGaeCastStart(keys)
	local caster = keys.caster
	local particleName = nil

	caster:EmitSound("Lancelot.Growl_Local")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnDeargStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local original_pos = caster:GetAbsOrigin()

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100)
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )	

	local flashIndex = ParticleManager:CreateParticle( "particles/custom/diarmuid/gae_dearg_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( flashIndex, 2, original_pos )
	ParticleManager:SetParticleControl( flashIndex, 3, caster:GetAbsOrigin() )

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

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

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)

	target:EmitSound("Hero_Lion.Impale")
	--StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=2})

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

end

function OnBrahmastraKundalaStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target_point = ability:GetCursorPosition()
	local small_radius = ability:GetSpecialValueFor("small_radius")
	local large_radius = ability:GetSpecialValueFor("radius")
	local full_damage = ability:GetSpecialValueFor("damage")
	local delay = ability:GetSpecialValueFor("delay")
	local half_damage = full_damage * 0.5
	
	local target_ray = ParticleManager:CreateParticleForTeam("particles/custom/karna/brahmastra_kundala/brahmastra_kundala_ray.vpcf", PATTACH_ABSORIGIN, caster, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(target_ray, 0, target_point) 
	ParticleManager:SetParticleControl(target_ray, 1, Vector(100,0,0))

	local visiondummy = SpawnVisionDummy(caster, target_point, small_radius, delay + 1, false)
	caster:EmitSound("Lancelot.Growl_Local")
	
	EmitSoundOnLocationForAllies(target_point, "karna_brahmastra_kundala_cast", caster)	

	local throw_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(throw_particle, 1, (target_point + Vector(0, 0, 1500) - caster:GetAbsOrigin()):Normalized() * 2500)

	Timers:CreateTimer(delay, function()  
        local outer_targets = FindUnitsInRadius(caster:GetTeam(), target_point, nil, large_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        
        for k,v in pairs(outer_targets) do
        	if IsValidEntity(v) and not v:IsNull() then
	        	local distance = (v:GetAbsOrigin() - target_point):Length2D()
	        	local far = 1 - (distance / large_radius )

	        	if distance <= small_radius then
	            	DoDamage(caster, v, full_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	            else
	            	DoDamage(caster, v, half_damage + ((1 - (distance - small_radius))/(large_radius - small_radius) * half_damage), DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        	end
	        end
        end 

        --caster.brahmastraDummy = CreateUnitByName("dummy_unit", target_point, false, caster, caster, caster:GetTeamNumber())
		--caster.brahmastraDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

        local particle = ParticleManager:CreateParticle("particles/custom/karna/brahmastra_kundala/brahmastra_kundala_explosion_beam.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target_point) 

		EmitGlobalSound("karna_brahmastra_kundala_explosion")

		Timers:CreateTimer(2, function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
			ParticleManager:DestroyParticle(target_ray, false)
			ParticleManager:ReleaseParticleIndex(target_ray)
			ParticleManager:DestroyParticle(throw_particle, false)
			ParticleManager:ReleaseParticleIndex(throw_particle)
			--self.Dummy:RemoveSelf()

			return
		end)

        return 
    end)
end

function OnVajraStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
    local targetPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local range = ability:GetSpecialValueFor("range")
    local slowRadius = ability:GetSpecialValueFor("slow_radius")
    local rootRadius = ability:GetSpecialValueFor("root_radius")
    local root_duration = ability:GetSpecialValueFor("root_duration")
    local damage = ability:GetSpecialValueFor("damage")
    caster.VajraHit = false

    if (math.abs(targetPoint.x - origin.x) < range) and (math.abs(targetPoint.y - origin.y) < range) then
		targetPoint = origin + ((targetPoint - caster:GetAbsOrigin()):Normalized() * range)
	end
	local dummy_origin = origin
	local forwardvector = caster:GetForwardVector()
	local angle = caster:GetAnglesAsVector()
	print(angle.y)
	caster.vajradummy = CreateUnitByName("dummy_unit", dummy_origin, false, caster, caster, caster:GetTeamNumber())
	caster.vajradummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.vajradummy:SetForwardVector(forwardvector)	

	caster.vajraIndex = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_vajra.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.vajradummy )
	ParticleManager:SetParticleControl( caster.vajraIndex, 0, caster.vajradummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( caster.vajraIndex, 1, Vector(0, angle.y, 0) )

	Timers:CreateTimer(function()
		if IsValidEntity(caster.vajradummy) then
			dummy_origin = GetGroundPosition(dummy_origin + (speed * 0.05) * Vector(forwardvector.x, forwardvector.y, 0), nil)								
			caster.vajradummy:SetAbsOrigin(dummy_origin)
			return 0.05
		else
			return nil
		end
	end)

    --local lightning_part = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
    --ParticleManager:SetParticleControl(lightning_part, 0, targetPoint)
    --ParticleManager:SetParticleControl(fireFx, 1, Vector(duration,0,0))
    --particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_start.vpcf
    --particles/econ/items/zeus/arcana_chariot/zeus_arcana_loadout_start_core.vpcf
    --particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_strike.vpcf
    
    caster:EmitSound("Hero_Zuus.GodsWrath.PreCast")

    local vajra = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = range,
        fStartRadius = rootRadius,
        fEndRadius = rootRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = true,
		vVelocity = caster:GetForwardVector() * speed
	}
	local projectile = ProjectileManager:CreateLinearProjectile(vajra)

	Timers:CreateTimer( range/speed, function()
		if caster.VajraHit == false then 
			ParticleManager:DestroyParticle( caster.vajraIndex, true )
			ParticleManager:ReleaseParticleIndex( caster.vajraIndex )
			if IsValidEntity(caster.vajradummy) then
				caster.vajradummy:RemoveSelf()
			end
			local lightning_impact_part = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_strike.vpcf", PATTACH_WORLDORIGIN, nil)
    		ParticleManager:SetParticleControl(lightning_impact_part, 0, targetPoint)
    		ParticleManager:SetParticleControl(lightning_impact_part, 1, targetPoint)
    		ParticleManager:SetParticleControl(lightning_impact_part, 2, targetPoint)
    		ParticleManager:SetParticleControl(lightning_impact_part, 6, targetPoint)
    
    		EmitSoundOnLocationWithCaster(targetPoint, "Hero_Zuus.GodsWrath.Target", caster)

			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, slowRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

    		for k, v in pairs(targets) do
    			if IsValidEntity(v) and not v:IsNull() then
	    			if not IsImmuneToCC(v) and not IsImmuneToSlow(v) then
			      		ability:ApplyDataDrivenModifier(caster, v, "modifier_vajra_slow", {})
			      	end
			      	if (targetPoint - v:GetAbsOrigin()):Length2D() <= rootRadius then 
			      		if not IsImmuneToCC(v) then
				      		giveUnitDataDrivenModifier(caster, v, "locked", root_duration)
				      		ability:ApplyDataDrivenModifier(caster, v, "modifier_vajra_root", {})
				      	end
			      		v:EmitSound("Hero_Zuus.GodsWrath")
			      	end   

	    			if not IsLightningResist(v) then
			    		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
			    	end
		    	end        
		    end 
		end
	end)
end

function OnVajraHit(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 

	if target == nil then 
		caster.VajraHit = false 
		return 
	end 
	ParticleManager:DestroyParticle( caster.vajraIndex, true )
	ParticleManager:ReleaseParticleIndex( caster.vajraIndex )
	if IsValidEntity(caster.vajradummy) then
		caster.vajradummy:RemoveSelf()
	end
	local slowRadius = ability:GetSpecialValueFor("slow_radius")
    local rootRadius = ability:GetSpecialValueFor("root_radius")
    local root_duration = ability:GetSpecialValueFor("root_duration")
    local damage = ability:GetSpecialValueFor("damage")

    local lightning_impact_part = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_strike.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(lightning_impact_part, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(lightning_impact_part, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(lightning_impact_part, 2, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(lightning_impact_part, 6, target:GetAbsOrigin())
    target:EmitSound("Hero_Zuus.GodsWrath.Target")
    caster.VajraHit = true

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, slowRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

    for k, v in pairs(targets) do
    	if IsValidEntity(v) and not v:IsNull() then
	    	if not IsImmuneToCC(v) and not IsImmuneToSlow(v) then
	      		ability:ApplyDataDrivenModifier(caster, v, "modifier_vajra_slow", {})
	      	end
	      	if (target:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() <= rootRadius then 
	      		if not IsImmuneToCC(v) then
		      		giveUnitDataDrivenModifier(caster, v, "locked", root_duration)
		      		ability:ApplyDataDrivenModifier(caster, v, "modifier_vajra_root", {})
		      	end
	      		v:EmitSound("Hero_Zuus.GodsWrath")
	      	end    

	      	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)        
	    end 
	end
end

function OnSMGCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:HasModifier("modifier_arondite") then
    	caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Arondite_actived")
        return 
    end
end

function OnSMGStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_point = ability:GetCursorPosition() 
	local frontward = caster:GetForwardVector()
	local range = ability:GetSpecialValueFor("range")
    local start_radius = ability:GetSpecialValueFor("start_radius")
    local end_radius = ability:GetSpecialValueFor("end_radius")
    local speed = ability:GetSpecialValueFor("speed")

    local smg = 
    {
        Ability = ability,
        --EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = range,
        fStartRadius = start_radius,
        fEndRadius = end_radius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * speed
    }
   
    local projectile = ProjectileManager:CreateLinearProjectile(smg)

    caster:EmitSound("Heckler_Koch_MP5_Unsuppressed")
    
    -- Initialize local variables
    local current_point = caster:GetAbsOrigin()
    local currentForwardVec = caster:GetForwardVector()
    local current_radius = start_radius
    local current_distance = 0
    local forwardVec = (target_point - current_point ):Normalized()
    local end_point = current_point + range * forwardVec
    local difference = end_radius - start_radius
    
    -- Loop creating particles
    while current_distance < range do
        -- Create particle
        local particleIndex = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_smg.vpcf", PATTACH_CUSTOMORIGIN, caster )
        ParticleManager:SetParticleControl( particleIndex, 0, current_point )
        ParticleManager:SetParticleControl( particleIndex, 1, Vector(current_radius, 0, 0 ) )
        
        Timers:CreateTimer( 1.0, function()
            ParticleManager:DestroyParticle( particleIndex, false )
            ParticleManager:ReleaseParticleIndex( particleIndex )
            return nil
        end)
        
        -- Update current point
        current_point = current_point + current_radius * forwardVec
        current_distance = current_distance + current_radius
        current_radius = start_radius + current_distance / range * difference
    end
    
    -- Create particle
    local particleIndex = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_smg.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( particleIndex, 0, end_point )
    ParticleManager:SetParticleControl( particleIndex, 1, Vector( end_radius, 0, 0 ) )
        
    Timers:CreateTimer( 1.0, function()
        ParticleManager:DestroyParticle( particleIndex, true )
        ParticleManager:ReleaseParticleIndex( particleIndex )
        return nil
    end)

    if caster.IsImproveKnightOfOwnerAcquired then 
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_smg_overheat_stack", {})
    	local max_stack = ability:GetSpecialValueFor("max_stack")
    	local stack = caster:GetModifierStackCount("modifier_smg_overheat_stack", caster) or 0 
    	caster:SetModifierStackCount("modifier_smg_overheat_stack", caster, stack + 1)
    	caster.SMG_Overheat_stack = stack + 1
    	if caster:GetModifierStackCount("modifier_smg_overheat_stack", caster) >= max_stack then 
    		local overheat_duration = ability:GetSpecialValueFor("overheat_duration")
    		ability:StartCooldown(overheat_duration)
    	end
    end

    LancelotCheckCombo(caster,ability)
end

function OnSMGHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if target == nil then return end

	local damage = ability:GetSpecialValueFor("damage")

	DoDamage(caster, target, damage, ability:GetAbilityDamageType(), 0, ability, false) 

	if caster.IsImproveKnightOfOwnerAcquired then 
		local mini_stun = ability:GetSpecialValueFor("mini_stun")
		if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
			--target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = mini_stun})
		end
	end
end

function OnSMGRecharge(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.SMG_Overheat_stack > 1 and caster.SMG_Overheat_stack < 10 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_smg_overheat_stack", {})
		caster:SetModifierStackCount("modifier_smg_overheat_stack", caster, caster.SMG_Overheat_stack - 1)
	end
	caster.SMG_Overheat_stack = caster.SMG_Overheat_stack - 1 
end

function OnGatlingCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:HasModifier("modifier_arondite") then
    	caster:Stop()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Arondite_actived")
        return 
    end
end

function OnGatlingStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gatling_weapon", {})
	caster.forward_gatling = caster:GetForwardVector()
	caster.forward_angle = caster:GetAnglesAsVector().y
	LancelotCheckCombo(caster,ability)
end

function OnGatlingStop(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_gatling_weapon")
end

function OnGatlingCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:ScriptLookupAttachment("attach_rod") ~= nil then 
		local rod = Attachments:GetCurrentAttachment(caster, "attach_rod")
		if rod ~= nil and not rod:IsNull() then 
			rod:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_gun", "models/lancelot/lancelot_gun_by_zefiroft.vmdl")
	end
	caster:EmitSound("Lancelot.Gatling")
	
	if caster.IsImproveKnightOfOwnerAcquired then 
		caster:SwapAbilities("lancelot_gatling_upgrade", "lancelot_gatling_stop", false, true)
		--ability:ApplyDataDrivenModifier(caster, caster, "modifier_gatling_walk", {})
	else
		caster:SwapAbilities("lancelot_gatling", "lancelot_gatling_stop", false, true)
	end
end

function OnGatlingDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:ScriptLookupAttachment("attach_gun") ~= nil then 
		local gatling = Attachments:GetCurrentAttachment(caster, "attach_gun")
		if gatling ~= nil and not gatling:IsNull() then 
			gatling:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_rod", "models/lancelot/lancelot_rod.vmdl")
	end
	caster:SetAngles(0, 0, 0)
	caster:StopSound("Lancelot.Gatling")
	
	if caster.IsImproveKnightOfOwnerAcquired then 
		caster:SwapAbilities("lancelot_gatling_upgrade", "lancelot_gatling_stop", true, false)
		--caster:RemoveModifierByName("modifier_gatling_walk")
	else
		caster:SwapAbilities("lancelot_gatling", "lancelot_gatling_stop", true, false)
	end
end

function OnGatlingFire(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local width = ability:GetSpecialValueFor("width")
	local distance = ability:GetSpecialValueFor("distance")
	local speed = ability:GetSpecialValueFor("speed")
	local aoe = ability:GetSpecialValueFor("aoe")
	local mana_cost = ability:GetSpecialValueFor("mana_cost")
	local interval = ability:GetSpecialValueFor("interval")

	if caster:IsStunned() then 
		caster:RemoveModifierByName("modifier_gatling_weapon")
	end

	caster:SetAngles(0, caster.forward_angle, 0)
	--caster:SetForwardVector(caster.forward_gatling)
	local gatling = 
    {
        Ability = ability,
        EffectName = "particles/custom/lancelot/lancelot_gatling.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance,
        fStartRadius = aoe,
        fEndRadius = aoe,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
        bDeleteOnHit = true,
        vVelocity = caster.forward_gatling * speed
    }
	
	if caster:GetMana() < mana_cost * interval then 
		caster:RemoveModifierByName("modifier_gatling_weapon")
		ability:EndChannel(true)
	else
		caster:SetMana(caster:GetMana() - (mana_cost * interval))
		local random = RandomInt(1, 2)
		local angle = 90
		if random == 1 then 
			angle = 270
		end
		gatling.vSpawnOrigin = GetRotationPoint(caster:GetAbsOrigin(),math.random(0,width/2),caster:GetAnglesAsVector().y + angle) + Vector(0,0,math.random(0, 50) )

		local projectile = ProjectileManager:CreateLinearProjectile(gatling)
	end
end

function OnGatlingWalk(keys)
	local caster = keys.caster 
	caster:SetAngles(0, caster.forward_angle, 0)
	--caster:SetForwardVector(caster.forward_gatling)
end

function OnGatlingHit(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if target == nil then return end

	local damage = ability:GetSpecialValueFor("damage")

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
end

function OnDoubleEdgeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local base_aspd = ability:GetSpecialValueFor("base_aspd")
	local base_ms = ability:GetSpecialValueFor("base_ms")
	local base_dmg_amp = ability:GetSpecialValueFor("base_dmg_amp")
	local duration = ability:GetSpecialValueFor("duration")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_thinker", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_ms", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_as", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_damage_amp", {})
	caster:SetModifierStackCount("modifier_double_edge_as", caster, base_aspd)
	caster:SetModifierStackCount("modifier_double_edge_ms", caster, base_ms)
	caster:SetModifierStackCount("modifier_double_edge_damage_amp", caster, base_dmg_amp)

	LancelotCheckCombo(caster,ability)

	if caster.IsKnightOfTheLakeAcquired then 
		LancelotCheckCombo2(caster,ability)
		HardCleanse(caster)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_mad", {})
		giveUnitDataDrivenModifier(caster, caster, "revoked", duration )
		
	end
end

function OnDoubleEdgeThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local stack_gain = ability:GetSpecialValueFor("stack_gain")
	local max_aspd = ability:GetSpecialValueFor("max_aspd")
	local max_ms = ability:GetSpecialValueFor("max_ms")
	local max_dmg_amp = ability:GetSpecialValueFor("max_dmg_amp")

	local aspd = caster:GetModifierStackCount("modifier_double_edge_as", caster)
	local ms = caster:GetModifierStackCount("modifier_double_edge_ms", caster)
	local dmg_amp = caster:GetModifierStackCount("modifier_double_edge_damage_amp", caster)

	caster:SetModifierStackCount("modifier_double_edge_as", caster, math.min(max_aspd, aspd + stack_gain))
	caster:SetModifierStackCount("modifier_double_edge_ms", caster, math.min(max_ms, ms + stack_gain))
	caster:SetModifierStackCount("modifier_double_edge_damage_amp", caster, math.min(max_dmg_amp, dmg_amp + stack_gain))
end

function OnAronditeCreate(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_rod") ~= nil then 
		local rod = Attachments:GetCurrentAttachment(caster, "attach_rod")
		if rod ~= nil and not rod:IsNull() then 
			rod:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_sword", "models/lancelot/lancelot_arondight.vmdl")
	end
end

function OnAronditeDestroy(keys)
	local caster = keys.caster 
	if caster:ScriptLookupAttachment("attach_rod") ~= nil then 
		local arondite = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if arondite ~= nil and not arondite:IsNull() then 
			arondite:RemoveSelf() 
		end
		Attachments:AttachProp(caster, "attach_rod", "models/lancelot/lancelot_rod.vmdl")
	end
end

function OnAronditeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local damage = ability:GetSpecialValueFor("damage")
	local heal = ability:GetSpecialValueFor("heal")
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")

	if caster:HasModifier("modifier_gatling_weapon") then
		caster:RemoveModifierByName("modifier_gatling_weapon")
    end

	local groundcrack = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local warp = ParticleManager:CreateParticle("particles/custom/lancelot/lancelot_arondite_aoe_warp.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(warp,0, caster:GetAbsOrigin())

    caster:EmitSound("lancelot_arthur_" .. math.random(1,3))

    -- Destroy particle after delay
    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( groundcrack, false )
        ParticleManager:ReleaseParticleIndex( groundcrack )
        FxDestroyer(warp,false)
    end)

	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_arondite", {})
	
	caster:Heal(heal, caster)

	local roar = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(roar) do 
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false) 
		if IsValidEntity(v) and not v:IsNull() and not IsImmuneToSlow(v) and not IsImmuneToCC(v) then 
			ability:ApplyDataDrivenModifier(caster, v, "modifier_arondite_slow", {})
		end
	end

	if caster.IsKnightOfTheLakeAcquired then 
		LancelotCheckCombo2(caster,ability)
	end
end

function OnAronditeEternalFlame(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local flame_mana = ability:GetSpecialValueFor("flame_mana")

	if caster:GetMana() > flame_mana then
        caster:SetMana(caster:GetMana() - flame_mana)
        local flame = 
        {
            Ability = ability,
            EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
            iMoveSpeed = 1000,
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = 300,
            fStartRadius = 100,
            fEndRadius = 200,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 0.5,
            bDeleteOnHit = false,
            vVelocity = caster:GetForwardVector() * 1000
        }
        ProjectileManager:CreateLinearProjectile(flame)
        caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")

        if caster.IsImproveEternalArmsMastershipAcquired then 
	    	local armor_shred = ability:GetSpecialValueFor("armor_shred") / 100
	    	local armor = target:GetPhysicalArmorBaseValue()
	    	local debuff_stack = target:GetModifierStackCount("modifier_arondite_shred", caster) or 0
	    	ability:ApplyDataDrivenModifier(caster, target, "modifier_arondite_shred", {})
	    	target:SetModifierStackCount("modifier_arondite_shred", caster, math.min(armor,debuff_stack + (armor_shred * armor)))
	    end
    end
end

function OnAronditeEternalFlameHit(keys)
    local caster = keys.caster
    local target = keys.target

    if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

    local ability = keys.ability
    local flame_damage = ability:GetSpecialValueFor("flame_damage")
    DoDamage(caster, target, flame_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function LancelotCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		
		if string.match(GetMapName(), "fate_elim") then 
			if GameRules:GetGameTime() < 15 + _G.RoundStartTime then 
				return 
			end
		end

		if string.match(ability:GetAbilityName(), caster.WSkill) then
			caster.WUsed = true
			caster.WTime = GameRules:GetGameTime()
			if caster.WTimer ~= nil then 
				Timers:RemoveTimer(caster.WTimer)
				caster.WTimer = nil
			end
			caster.WTimer = Timers:CreateTimer(3.0, function()
				caster.WUsed = false
			end)
		else
			if string.match(ability:GetAbilityName(), caster.QSkill) and not caster:HasModifier("modifier_nuke_cooldown") and not caster:HasModifier("modifier_lancelot_arondite_overload_cooldown") then 
				if caster.WUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 3 - (newTime - caster.WTime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_lancelot_nuke_window", {duration = duration})
				end
			end
		end
	end
end

function LancelotCheckCombo2(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), caster.RSkill) then
			local over_stat = ability:GetSpecialValueFor("bonus_allstat")
			if math.ceil(caster:GetStrength() - over_stat) >= 25 and math.ceil(caster:GetAgility() - over_stat) >= 25 and math.ceil(caster:GetIntellect() - over_stat) >= 25 then
				caster.RUsed = true
				caster.RTime = GameRules:GetGameTime()
				if caster.RTimer ~= nil then 
					Timers:RemoveTimer(caster.RTimer)
					caster.RTimer = nil
				end
				caster.RTimer = Timers:CreateTimer(3.0, function()
					caster.RUsed = false
				end)
			end
		else
			if string.match(ability:GetAbilityName(), caster.WSkill) and caster:FindAbilityByName(caster.ESkill):IsCooldownReady() and not caster:HasModifier("modifier_nuke_cooldown") and not caster:HasModifier("modifier_lancelot_arondite_overload_cooldown") then 
				if caster.RUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 3 - (newTime - caster.RTime)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_lancelot_arondite_overload_window", {duration = duration})
				end
			end
		end
	end
end

function OnNukeWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.DSkill, "lancelot_nuke", false, true) 
	--[[if caster.IsKnightOfOwnerArsenalAcquired and caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_arsenal_upgrade", "lancelot_nuke", false, true) 
	elseif caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_arsenal", "lancelot_nuke", false, true) 
	elseif caster.IsBlessingOfFairyAcquired and not caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_blessing_of_fairy", "lancelot_nuke", false, true) 
	elseif not caster.IsBlessingOfFairyAcquired and not caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("fate_empty1", "lancelot_nuke", false, true) 
	end]]
end

function OnNukeWindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.DSkill, "lancelot_nuke", true, false) 
	--[[if caster.IsKnightOfOwnerArsenalAcquired and caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_arsenal_upgrade", "lancelot_nuke", true, false) 
	elseif caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_arsenal", "lancelot_nuke", true, false) 
	elseif caster.IsBlessingOfFairyAcquired and not caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_blessing_of_fairy", "lancelot_nuke", true, false) 
	elseif not caster.IsBlessingOfFairyAcquired and not caster.IsKnightOfOwnerArsenalAcquired and not caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("fate_empty1", "lancelot_nuke", true, false) 
	end]]
end

function OnNukeWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_lancelot_nuke_window")
end

function OnAronditeOverloadWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.ESkill, "lancelot_arondite_overload", false, true) 
	--[[if caster.IsImproveKnightOfOwnerAcquired and caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_3", "lancelot_arondite_overload", false, true)
	elseif caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_2", "lancelot_arondite_overload", false, true) 
	elseif caster.IsImproveKnightOfOwnerAcquired and not caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_1", "lancelot_arondite_overload", false, true) 
	elseif not caster.IsImproveKnightOfOwnerAcquired and not caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor", "lancelot_arondite_overload", false, true) 
	end]]
end

function OnAronditeOverloadWindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster.ESkill, "lancelot_arondite_overload", true, false) 
	--[[if caster.IsImproveKnightOfOwnerAcquired and caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_3", "lancelot_arondite_overload", true, false)
	elseif caster.IsKnightOfOwnerArsenal2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_2", "lancelot_arondite_overload", true, false)  
	elseif caster.IsImproveKnightOfOwnerAcquired and not caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor_upgrade_1", "lancelot_arondite_overload", true, false) 
	elseif not caster.IsImproveKnightOfOwnerAcquired and not caster.IsImproveKnightOfOwner2Acquired then 
		caster:SwapAbilities("lancelot_knight_of_honor", "lancelot_arondite_overload", true, false) 
	end]]
end

function OnAronditeOverloadWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_lancelot_arondite_overload_window")
end

function OnNukeStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local targetPoint = ability:GetCursorPosition() 
    local nuke_radius = ability:GetSpecialValueFor("nuke_radius")
    local radius = ability:GetSpecialValueFor("radius")
    local nuke_damage = ability:GetSpecialValueFor("nuke_damage")
    local damage = ability:GetSpecialValueFor("damage")
    local nuke_stun = ability:GetSpecialValueFor("nuke_stun")
    if not IsInSameRealm(caster:GetAbsOrigin(), targetPoint) then 
        caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(keys.ability:GetLevel()-1)) 
        keys.ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Location")
        return
    end

    EmitGlobalSound("Lancelot.Nuke_Alert") 
    caster:RemoveModifierByName("modifier_lancelot_nuke_window")
    if caster:HasModifier("modifier_lancelot_arondite_overload_window") then 
    	caster:RemoveModifierByName("modifier_lancelot_arondite_overload_window")
    end

    if caster:HasModifier("modifier_gatling_weapon") then
		caster:RemoveModifierByName("modifier_gatling_weapon")
    end

    -- Set master's combo cooldown
    local masterCombo = caster.MasterUnit2:FindAbilityByName("lancelot_nuke")
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(ability:GetCooldown(1))
    caster:FindAbilityByName("lancelot_arondite_overload"):StartCooldown(ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_nuke_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

    local nukemsg = {
        message = "Engaging Enemy, HQ.",
        duration = 2.0
    }
    FireGameEvent("show_center_message",nukemsg)

    local f16 = CreateUnitByName("f16_dummy", Vector(0, 0, 0), true, nil, nil, caster:GetTeamNumber())
    f16:SetOwner(caster)
    local visiondummy = CreateUnitByName("sight_dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(1500)
    visiondummy:SetNightTimeVisionRange(1500)
    visiondummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 8})

    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)
    local nukeMarker = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_nuke_calldown_marker_c.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( nukeMarker, 0, targetPoint)
    ParticleManager:SetParticleControl( nukeMarker, 1, Vector(300, 300, 300))
    -- Destroy particle after delay
    Timers:CreateTimer( 3.0, function()
        ParticleManager:DestroyParticle( nukeMarker, false )
        ParticleManager:ReleaseParticleIndex( nukeMarker )
    end)

    Timers:CreateTimer(1.0, function()
    	EmitGlobalSound("Lancelot.Nuke")
    end)
    
    -- Create F16 nunit
    Timers:CreateTimer(1.97, function()
        EmitGlobalSound("Lancelot.Nuke_Beep")
        EmitGlobalSound("Lancelot.Helicoptor")
        
        -- Set up unit
        LevelAllAbility(f16)
        FindClearSpaceForUnit(f16, f16:GetAbsOrigin(), true)
        f16:SetAbsOrigin(targetPoint)
        Timers:CreateTimer(0.033, function()
            f16:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
        end)
    end)
    
    
    -- Move jet around
    local flyCount = 0
    local t = 0
    Timers:CreateTimer(2.0, function()
        if flyCount == 121 then f16:ForceKill(true) return end
        t = t+0.12
        SpinInCircle(f16, targetPoint, t, 650)
        flyCount = flyCount + 1
        return 0.033
    end)

    local barrageCount = 0
    Timers:CreateTimer(2.0, function()
    	if caster.combo_ring == nil then 
			caster.combo_ring = ParticleManager:CreateParticleForTeam("particles/custom/lancelot/lancelot_combo_circle.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeamNumber())
			ParticleManager:SetParticleControl(caster.combo_ring, 0, targetPoint)
			ParticleManager:SetParticleControl(caster.combo_ring, 1, Vector(radius,0,0))
			caster.combo_ring2 = ParticleManager:CreateParticleForTeam("particles/custom/lancelot/lancelot_combo_circle.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeamNumber())
			ParticleManager:SetParticleControl(caster.combo_ring2, 0, targetPoint)
        	ParticleManager:SetParticleControl(caster.combo_ring2, 1, Vector(nuke_radius,0,0))
		end

        if flyCount == 121 then 
        	f16:ForceKill(true) 
        	ParticleManager:DestroyParticle( caster.combo_ring, true )
            ParticleManager:ReleaseParticleIndex( caster.combo_ring )
        	return 
        end

        local barrageVec1 = RandomVector(RandomInt(100, radius))
        local targets1 = FindUnitsInRadius(caster:GetTeam(), targetPoint + barrageVec1, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets1) do
            
            if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then 
            	v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 0.75}) 

            	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
            	
            end
        end
        -- particle
        if caster.AltPart.combo == 0 then
            local barrageImpact1 = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_nuke_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( barrageImpact1, 0, targetPoint+barrageVec1)
            ParticleManager:SetParticleControl( barrageImpact1, 1, Vector(300, 300, 300))
            Timers:CreateTimer( 2.0, function()
                ParticleManager:DestroyParticle( barrageImpact1, false )
                ParticleManager:ReleaseParticleIndex( barrageImpact1 )
            end)
        else
            local barrageImpact1 = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( barrageImpact1, 0, targetPoint+barrageVec1)
            ParticleManager:SetParticleControl( barrageImpact1, 1, Vector(300, 300, 300))
            Timers:CreateTimer( 2.0, function()
                ParticleManager:DestroyParticle( barrageImpact1, false )
                ParticleManager:ReleaseParticleIndex( barrageImpact1 )
            end)
        end

        local barrageImpact2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_impact_sparks.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( barrageImpact2, 0, targetPoint+barrageVec1)
        visiondummy:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")
        -- Destroy particle after delay
        Timers:CreateTimer( 2.0, function()
            ParticleManager:DestroyParticle( barrageImpact2, false )
            ParticleManager:ReleaseParticleIndex( barrageImpact2 )
        end)
    
        barrageCount = barrageCount + 1
        return 0.033
    end)

    Timers:CreateTimer(4.5, function()
        --EmitGlobalSound("Lancelot.TacticalNuke") 
    end)

    Timers:CreateTimer(7.0, function()
        EmitGlobalSound("Lancelot.Nuke_Impact")
        local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, nuke_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
            
            if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then 
            	v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = nuke_stun}) 

            	DoDamage(caster, v, nuke_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
            	
            end
        end
        -- particle
        local impactFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(2500, 2500, 1500))
        ParticleManager:SetParticleControl( impactFxIndex, 2, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 3, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 4, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 5, Vector(2500, 2500, 2500))

        local mushroom = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_nuke_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( mushroom, 0, targetPoint)

        -- Destroy particle after delay
        Timers:CreateTimer( 2.0, function()
            ParticleManager:DestroyParticle( impactFxIndex, false )
            ParticleManager:ReleaseParticleIndex( impactFxIndex )
            ParticleManager:DestroyParticle( mushroom, false )
            ParticleManager:ReleaseParticleIndex( mushroom )
            ParticleManager:DestroyParticle( caster.combo_ring2, true )
            ParticleManager:ReleaseParticleIndex( caster.combo_ring2 )
        end)
    end)
end

lastPos = Vector(0,0,0)
function SpinInCircle(unit, center, t, multiplier)
    local x = math.cos(t) * multiplier
    local y = math.sin(t) * multiplier
    lastPos = unit:GetAbsOrigin()
    unit:SetAbsOrigin(Vector(center.x + x, center.y + y, 750))
    local diff = (unit:GetAbsOrigin() - lastPos):Normalized() 
    unit:SetForwardVector(diff) 


end

function OnAronditeOverloadStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage") / 100 * caster:GetAverageTrueAttackDamage(caster)
	local stun = ability:GetSpecialValueFor("stun")
	local forward = caster:GetForwardVector()

	caster:RemoveModifierByName("modifier_lancelot_arondite_overload_window")
    if caster:HasModifier("modifier_lancelot_nuke_window") then 
    	caster:RemoveModifierByName("modifier_lancelot_nuke_window")
    end

    -- Set master's combo cooldown
    local masterCombo = caster.MasterUnit2:FindAbilityByName("lancelot_nuke")
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(ability:GetCooldown(1))
    caster:FindAbilityByName("lancelot_nuke"):StartCooldown(ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_lancelot_arondite_overload_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.5 + cast_delay)
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_arondite_overload_effect", {Duration = 1.2 + cast_delay})
    StartAnimation(caster, {duration = cast_delay - 0.3, activity = ACT_DOTA_CAST_ABILITY_5, rate = 30/36 * (cast_delay - 0.3)})

    Timers:CreateTimer(cast_delay - 0.3, function()
    	if caster:IsAlive() then
    		StartAnimation(caster, {duration = 0.8, activity = ACT_DOTA_ATTACK_EVENT_BASH, rate = 1.8})
    		EmitGlobalSound("Lancelot.Growl" )
    	end
    end)

    Timers:CreateTimer(cast_delay, function()
    	if caster:IsAlive() then

			local slash = ParticleManager:CreateParticle("particles/custom/lancelot/lancelot_arondite_overload.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(slash, 0, caster:GetAbsOrigin() )

	    	local fxIndex1 = ParticleManager:CreateParticle("particles/custom/lancelot/judgement_beams.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(fxIndex1, 0, target_loc)

			EmitGlobalSound("Saber_Alter.Vortigern")

			Timers:CreateTimer( 0.5, function()
				ParticleManager:DestroyParticle( fxIndex1, false )
				ParticleManager:ReleaseParticleIndex( fxIndex1 )
			end)

			local targets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() then
					if not v:IsMagicImmune() then 
				        v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun}) 
				    end
				    
				    if IsDragon(v) then 
				    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				    else
				    	DoDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
				    end
				end
			end

			Timers:CreateTimer(0.8, function()
				if caster:IsAlive() then
					

					local targets2 = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
					for k,v in pairs(targets2) do
						if IsValidEntity(v) and not v:IsNull() then
						    DoDamage(caster, v, caster:GetMaxMana(), DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end
					end
					caster:SetMana(0)

					-- Create particles
					local fxIndex3 = ParticleManager:CreateParticle("particles/custom/lancelot/judgement_final.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(fxIndex3, 0, target_loc)
					ParticleManager:SetParticleControl(fxIndex3, 1, Vector(radius, radius, radius))
					ParticleManager:SetParticleControl(fxIndex3, 2, target_loc)
					
					local fxIndex4 = ParticleManager:CreateParticle("particles/custom/lancelot/judgement_final_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(fxIndex4, 0, target_loc)
					ParticleManager:SetParticleControl(fxIndex4, 1, Vector(radius, radius, radius))

					Timers:CreateTimer( 0.2, function()
						ParticleManager:DestroyParticle(fxIndex3, false)
						ParticleManager:ReleaseParticleIndex(fxIndex3)
						ParticleManager:DestroyParticle(fxIndex4, false)
						ParticleManager:ReleaseParticleIndex(fxIndex4)
					end)
				end
			end)
		end
    end)
end


function OnImproveEternalArmsMastershipAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveEternalArmsMastershipAcquired) then

		hero.IsImproveEternalArmsMastershipAcquired = true

		if hero:HasModifier("modifier_knight_of_honor_check") or hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
			UpgradeAttribute(hero, 'lancelot_eternal_arms_mastership', 'lancelot_eternal_arms_mastership_upgrade', false)
			if hero.IsKnightOfTheLakeAcquired then
				UpgradeAttribute(hero, 'lancelot_arondite_upgrade_2', 'lancelot_arondite_upgrade_3', false)
				hero.RSkill = "lancelot_arondite_upgrade_3"
			else
				UpgradeAttribute(hero, 'lancelot_arondite', 'lancelot_arondite_upgrade_1', false)
				hero.RSkill = "lancelot_arondite_upgrade_1"
			end
		else
			UpgradeAttribute(hero, 'lancelot_eternal_arms_mastership', 'lancelot_eternal_arms_mastership_upgrade', true)
			if hero.IsKnightOfTheLakeAcquired then
				UpgradeAttribute(hero, 'lancelot_arondite_upgrade_2', 'lancelot_arondite_upgrade_3', true)
				hero.RSkill = "lancelot_arondite_upgrade_3"
			else
				UpgradeAttribute(hero, 'lancelot_arondite', 'lancelot_arondite_upgrade_1', true)
				hero.RSkill = "lancelot_arondite_upgrade_1"
			end 
		end

		hero.FSkill = "lancelot_eternal_arms_mastership_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBlessingOfFairyAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBlessingOfFairyAcquired) then

		hero.IsBlessingOfFairyAcquired = true

		hero:FindAbilityByName("lancelot_blessing_of_fairy"):SetLevel(1)

		if not hero.IsKnightOfOwnerArsenalAcquired then
			if hero:HasModifier("modifier_knight_of_honor_check") then 
				hero:FindAbilityByName("lancelot_blessing_of_fairy"):SetHidden(true)
			else
				hero:SwapAbilities("lancelot_blessing_of_fairy", "fate_empty1", true, false) 
			end
			hero.DSkill = "lancelot_blessing_of_fairy"
			--hero:RemoveAbility("fate_empty1")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveKnightOfOwnerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveKnightOfOwner2Acquired) then

		--if _G.DRAFT_MODE == false then 
			local arsenal = caster:FindAbilityByName("lancelot_attribute_knight_of_owner_arsenal")
			if arsenal:IsCooldownReady() then
				arsenal:StartCooldown(9999)
				caster:AddAbility("fate_empty3")
				caster:SwapAbilities("fate_empty3", "lancelot_attribute_knight_of_owner_arsenal", true, false)
				SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_be_upgraded_with_Knight_of_Owner_(Arsenal)")
			end	
		--end

		--[[if hero:HasModifier("modifier_knight_of_honor_check") then 
			hero:RemoveModifierByName("modifier_knight_of_honor_check")
		elseif hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
			hero:RemoveModifierByName("modifier_knight_of_honor_arsenal_check")
		end]]

		-- lvl 1
		if not hero.IsImproveKnightOfOwnerAcquired then
			hero.IsImproveKnightOfOwnerAcquired = true
			keys.ability:EndCooldown()
			keys.ability:SetLevel(2)

			if hero:HasModifier("modifier_knight_of_honor_check") or hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
				UpgradeAttribute(hero, 'lancelot_gatling', 'lancelot_gatling_upgrade', false)
				UpgradeAttribute(hero, 'lancelot_knight_of_honor', 'lancelot_knight_of_honor_upgrade_1', false)
			else
				UpgradeAttribute(hero, 'lancelot_gatling', 'lancelot_gatling_upgrade', true)
				UpgradeAttribute(hero, 'lancelot_knight_of_honor', 'lancelot_knight_of_honor_upgrade_1', true)
			end

			hero.QSkill = "lancelot_gatling_upgrade"
			hero.ESkill = "lancelot_knight_of_honor_upgrade_1"

			-- KoH upgrade
			hero:FindAbilityByName("lancelot_vortigern"):SetLevel(hero:FindAbilityByName("lancelot_vortigern"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_gae_bolg"):SetLevel(hero:FindAbilityByName("lancelot_gae_bolg"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_rule_breaker"):SetLevel(hero:FindAbilityByName("lancelot_rule_breaker"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_nine_lives"):SetLevel(hero:FindAbilityByName("lancelot_nine_lives"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(hero:FindAbilityByName("lancelot_tsubame_gaeshi"):GetLevel() + 2)
		else
			hero.IsImproveKnightOfOwner2Acquired = true

			if hero:HasModifier("modifier_knight_of_honor_check") or hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
				UpgradeAttribute(hero, 'lancelot_knight_of_honor_upgrade_1', 'lancelot_knight_of_honor_upgrade_3', false)
			else
				UpgradeAttribute(hero, 'lancelot_knight_of_honor_upgrade_1', 'lancelot_knight_of_honor_upgrade_3', true) 
			end

			hero.ESkill = "lancelot_knight_of_honor_upgrade_3"

			-- KoH upgrade
			hero:FindAbilityByName("lancelot_vortigern"):SetLevel(hero:FindAbilityByName("lancelot_vortigern"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_gae_bolg"):SetLevel(hero:FindAbilityByName("lancelot_gae_bolg"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_rule_breaker"):SetLevel(hero:FindAbilityByName("lancelot_rule_breaker"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_nine_lives"):SetLevel(hero:FindAbilityByName("lancelot_nine_lives"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(hero:FindAbilityByName("lancelot_tsubame_gaeshi"):GetLevel() + 2)

			-- KoH Arsenal Upgrade
			if hero.IsKnightOfOwnerArsenalAcquired then 
				hero:FindAbilityByName("lancelot_caliburn"):SetLevel(hero:FindAbilityByName("lancelot_caliburn"):GetLevel() + 1)
				hero:FindAbilityByName("lancelot_vajra"):SetLevel(hero:FindAbilityByName("lancelot_vajra"):GetLevel() + 1)
				hero:FindAbilityByName("lancelot_rosa_ichthys"):SetLevel(hero:FindAbilityByName("lancelot_rosa_ichthys"):GetLevel() + 1)
				hero:FindAbilityByName("lancelot_brahmastra_kundala"):SetLevel(hero:FindAbilityByName("lancelot_brahmastra_kundala"):GetLevel() + 1)
				hero:FindAbilityByName("lancelot_gae_dearg"):SetLevel(hero:FindAbilityByName("lancelot_gae_dearg"):GetLevel() + 1)
			end
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKnightOfOwnerArsenalAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKnightOfOwnerArsenal2Acquired) then

		--if _G.DRAFT_MODE == false then 
			local koh = caster:FindAbilityByName("lancelot_attribute_improve_knight_of_owner")
			if koh:IsCooldownReady() then
				koh:StartCooldown(9999)
				caster:AddAbility("fate_empty3")
				caster:SwapAbilities("fate_empty3", "lancelot_attribute_improve_knight_of_owner", true, false)
				--UpgradeAttribute(caster, 'lancelot_attribute_improve_knight_of_owner', 'fate_empty1', true)
				SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_be_upgraded_with_Improve_Knight_of_Owner")
			end	
		--end

		--[[if hero:HasModifier("modifier_knight_of_honor_check") then 
			hero:RemoveModifierByName("modifier_knight_of_honor_check")
		elseif hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
			hero:RemoveModifierByName("modifier_knight_of_honor_arsenal_check")
		end]]

		-- lvl 1
		if not hero.IsKnightOfOwnerArsenalAcquired then
			hero.IsKnightOfOwnerArsenalAcquired = true
			keys.ability:EndCooldown()
			keys.ability:SetLevel(2)
			if hero.IsImproveKnightOfOwner2Acquired and hero.IsImproveKnightOfOwnerAcquired then
				hero:FindAbilityByName("lancelot_knight_of_honor_arsenal"):SetLevel(hero:FindAbilityByName("lancelot_knight_of_honor_upgrade_3"):GetLevel())
			elseif not hero.IsImproveKnightOfOwner2Acquired and hero.IsImproveKnightOfOwnerAcquired then
				hero:FindAbilityByName("lancelot_knight_of_honor_arsenal"):SetLevel(hero:FindAbilityByName("lancelot_knight_of_honor_upgrade_1"):GetLevel())
			elseif not hero.IsImproveKnightOfOwner2Acquired and not hero.IsImproveKnightOfOwnerAcquired then
				hero:FindAbilityByName("lancelot_knight_of_honor_arsenal"):SetLevel(hero:FindAbilityByName("lancelot_knight_of_honor"):GetLevel())
			end

			if hero:HasModifier("modifier_knight_of_honor_check") then 
				hero:FindAbilityByName("lancelot_knight_of_honor_arsenal"):SetHidden(true)
			else
				if hero.IsBlessingOfFairyAcquired then
					hero:SwapAbilities("lancelot_knight_of_honor_arsenal", "lancelot_blessing_of_fairy", true, false) 
				else
					hero:SwapAbilities("lancelot_knight_of_honor_arsenal", "fate_empty1", true, false)
					--hero:RemoveAbility("fate_empty1") 
				end
			end

			hero.DSkill = "lancelot_knight_of_honor_arsenal"

			-- KoH A + 1
			hero:FindAbilityByName("lancelot_caliburn"):SetLevel(hero:FindAbilityByName("lancelot_caliburn"):GetLevel() + 1)
			hero:FindAbilityByName("lancelot_vajra"):SetLevel(hero:FindAbilityByName("lancelot_vajra"):GetLevel() + 1)
			hero:FindAbilityByName("lancelot_rosa_ichthys"):SetLevel(hero:FindAbilityByName("lancelot_rosa_ichthys"):GetLevel() + 1)
			hero:FindAbilityByName("lancelot_brahmastra_kundala"):SetLevel(hero:FindAbilityByName("lancelot_brahmastra_kundala"):GetLevel() + 1)
			hero:FindAbilityByName("lancelot_gae_dearg"):SetLevel(hero:FindAbilityByName("lancelot_gae_dearg"):GetLevel() + 1)
		
		else
			hero.IsKnightOfOwnerArsenal2Acquired = true

			if hero:HasModifier("modifier_knight_of_honor_check") or hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
				UpgradeAttribute(hero, 'lancelot_knight_of_honor_arsenal', 'lancelot_knight_of_honor_arsenal_upgrade', false)
				UpgradeAttribute(hero, 'lancelot_knight_of_honor', 'lancelot_knight_of_honor_upgrade_2', false)
			else
				UpgradeAttribute(hero, 'lancelot_knight_of_honor_arsenal', 'lancelot_knight_of_honor_arsenal_upgrade', true)
				UpgradeAttribute(hero, 'lancelot_knight_of_honor', 'lancelot_knight_of_honor_upgrade_2', true)
			end

			hero.DSkill = "lancelot_knight_of_honor_arsenal_upgrade"
			hero.ESkill = "lancelot_knight_of_honor_upgrade_2"

			-- KoH A + 2
			hero:FindAbilityByName("lancelot_caliburn"):SetLevel(hero:FindAbilityByName("lancelot_caliburn"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_vajra"):SetLevel(hero:FindAbilityByName("lancelot_vajra"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_rosa_ichthys"):SetLevel(hero:FindAbilityByName("lancelot_rosa_ichthys"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_brahmastra_kundala"):SetLevel(hero:FindAbilityByName("lancelot_brahmastra_kundala"):GetLevel() + 2)
			hero:FindAbilityByName("lancelot_gae_dearg"):SetLevel(hero:FindAbilityByName("lancelot_gae_dearg"):GetLevel() + 2)

		end

		-- KoH + 1 
			hero:FindAbilityByName("lancelot_vortigern"):SetLevel(math.min(hero:FindAbilityByName("lancelot_vortigern"):GetLevel() + 1,5))
			hero:FindAbilityByName("lancelot_gae_bolg"):SetLevel(math.min(hero:FindAbilityByName("lancelot_gae_bolg"):GetLevel() + 1,5))
			hero:FindAbilityByName("lancelot_rule_breaker"):SetLevel(math.min(hero:FindAbilityByName("lancelot_rule_breaker"):GetLevel() + 1,5))
			hero:FindAbilityByName("lancelot_nine_lives"):SetLevel(math.min(hero:FindAbilityByName("lancelot_nine_lives"):GetLevel() + 1,5))
			hero:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(math.min(hero:FindAbilityByName("lancelot_tsubame_gaeshi"):GetLevel() + 1,5))

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKnightOfTheLakeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKnightOfTheLakeAcquired) then

		hero.IsKnightOfTheLakeAcquired = true

		if hero:HasModifier("modifier_knight_of_honor_check") or hero:HasModifier("modifier_knight_of_honor_arsenal_check") then 
			if hero.IsImproveEternalArmsMastershipAcquired then
				UpgradeAttribute(hero, 'lancelot_arondite_upgrade_1', 'lancelot_arondite_upgrade_3', false)
				hero.RSkill = "lancelot_arondite_upgrade_3"
			else
				UpgradeAttribute(hero, 'lancelot_arondite', 'lancelot_arondite_upgrade_2', false)
				hero.RSkill = "lancelot_arondite_upgrade_2"
			end
			UpgradeAttribute(hero, 'lancelot_double_edge', 'lancelot_double_edge_upgrade', false)
		else
			if hero.IsImproveEternalArmsMastershipAcquired then
				UpgradeAttribute(hero, 'lancelot_arondite_upgrade_1', 'lancelot_arondite_upgrade_3', true)
				hero.RSkill = "lancelot_arondite_upgrade_3"
			else
				UpgradeAttribute(hero, 'lancelot_arondite', 'lancelot_arondite_upgrade_2', true)
				hero.RSkill = "lancelot_arondite_upgrade_2"
			end
			UpgradeAttribute(hero, 'lancelot_double_edge', 'lancelot_double_edge_upgrade', true)
		end

		hero.WSkill = "lancelot_double_edge_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end