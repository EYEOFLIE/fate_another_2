gilles_abyssal_contract = class({})
gilles_abyssal_contract_upgrade = class({})
modifier_squidlord_death_checker = class({})
modifier_squidlord_alive = class({})

LinkLuaModifier("modifier_squidlord_death_checker", "abilities/gilles/gilles_abyssal_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_squidlord_alive", "abilities/gilles/gilles_abyssal_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gilles_combo_window", "abilities/gilles/modifiers/modifier_gilles_combo_window", LUA_MODIFIER_MOTION_NONE)

--[[function gilles_abyssal_contract:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana()
end]]
function gilles_abyssal_contract_wrapper(ability)
	function ability:IsHiddenAbilityCastable()
		return true
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:CastFilterResultLocation(vLocation)
		if self:GetCaster():HasModifier("modifier_squidlord_alive") then
			return UF_FAIL_CUSTOM
		else	
			return UF_SUCCESS
		end
	end

	function ability:GetCustomCastErrorLocation(vLocation)
		return "Cannot Summon"
	end

	function ability:OnSpellStart()
		local hCaster = self:GetCaster()
		local vTargetPoint = self:GetCursorPosition()
		local fDelay = self:GetSpecialValueFor("summon_delay")
		local fSquidLordzHealth = self:GetSpecialValueFor("max_health")
		local fSquidLordzdamage = self:GetSpecialValueFor("attack_damage")
		local summon_duration = self:GetSpecialValueFor("summon_duration")
		local stun = self:GetSpecialValueFor("stun")
		local fAOE = self:GetAOERadius()
	
		if hCaster:HasModifier('modifier_alternate_02') then 
		EmitGlobalSound("Gilles-Pope-R")	
		else
		EmitGlobalSound("Gilles_Cool")	
		end	
		--hCaster:AddNewModifier(hCaster, self, "modifier_squidlord_alive", { Duration = fDelay - 0.1})

		AddFOWViewer(hCaster:GetTeamNumber(), vTargetPoint, fAOE, fDelay + 0.5, true)
	    hCaster:EmitSound("Hero_Warlock.Upheaval")

		local contractFx = ParticleManager:CreateParticle("particles/custom/gilles/abyssal_contract_smoke.vcpf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(contractFx, 0, vTargetPoint)
		ParticleManager:SetParticleControl(contractFx, 1, Vector(fAOE + 200,0,0))
		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle(contractFx, false)
			ParticleManager:ReleaseParticleIndex(contractFx)
		end)

		local contractFx2 = ParticleManager:CreateParticle("particles/custom/gilles/abyssal_contract_sigil.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(contractFx2, 0, vTargetPoint)
		Timers:CreateTimer(5.0, function()
			ParticleManager:DestroyParticle( contractFx2, false )
			ParticleManager:ReleaseParticleIndex( contractFx2 )
		end)

		Timers:CreateTimer(1.0, function()
			local contractFx4 = ParticleManager:CreateParticle("particles/custom/gilles/abyssal_contract_pulse.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(contractFx4, 0, vTargetPoint)
			ParticleManager:SetParticleControl(contractFx4, 1, Vector(fAOE + 200, 0, 0))
			Timers:CreateTimer(2.0, function()
				ParticleManager:DestroyParticle(contractFx4, false)
				ParticleManager:ReleaseParticleIndex(contractFx4)
			end)
		end)	

		Timers:CreateTimer(fDelay, function()
			if hCaster:IsAlive() then			
				-- Summon Gigantic Horror
				if IsValidEntity(hCaster.Squidlord) and hCaster.Squidlord:IsAlive() then
					FindClearSpaceForUnit(hCaster.Squidlord, vTargetPoint, true)
				else
					hCaster.Squidlord = CreateUnitByName("gille_gigantic_horror", vTargetPoint, true, nil, nil, hCaster:GetTeamNumber())

					if hCaster.IsAbyssalConnectionAcquired then				
						hCaster.Squidlord:SwapAbilities("fate_empty6", "gilles_squidlordz_integrate_data", false, true) 
						hCaster.Squidlord:SwapAbilities("fate_empty7", "gilles_squidlordz_contaminate", false, true) 
						hCaster.Squidlord:FindAbilityByName("gilles_squidlordz_contaminate"):SetLevel(self:GetLevel()) 
					end
					
					hCaster.Squidlord:SetControllableByPlayer(hCaster:GetPlayerID(), true)
					hCaster.Squidlord:SetOwner(hCaster)
					FindClearSpaceForUnit(hCaster.Squidlord, hCaster.Squidlord:GetAbsOrigin(), true)
					
					-- Level abilities
					hCaster.Squidlord:FindAbilityByName("gille_tentacle_wrap"):SetLevel(self:GetLevel())
					hCaster.Squidlord:FindAbilityByName("gille_subterranean_skewer"):SetLevel(self:GetLevel()) 
					hCaster.Squidlord:FindAbilityByName("gille_gigantic_horror_passive"):SetLevel(1)
				end
					
				hCaster.Squidlord:SetMaxHealth(fSquidLordzHealth)
				hCaster.Squidlord:SetBaseMaxHealth(fSquidLordzHealth)
				hCaster.Squidlord:SetHealth(fSquidLordzHealth)
				hCaster.Squidlord:SetBaseDamageMax(fSquidLordzdamage) 
				hCaster.Squidlord:SetBaseDamageMin(fSquidLordzdamage) 

				hCaster.Squidlord:AddNewModifier(hCaster, self, "modifier_kill", { duration = summon_duration })
				hCaster.Squidlord:AddNewModifier(hCaster, self, "modifier_squidlord_death_checker", { Duration = summon_duration })
				--hCaster:AddNewModifier(hCaster, self, "modifier_squidlord_alive", { Duration = summon_duration})

				EmitGlobalSound("ZC.Ravage")

				hCaster.Squidlord:SetDeathXP(self:GetLevel() * 50 + 100)
			    local playerData = { transport = hCaster.Squidlord:entindex() }
	            CustomGameEventManager:Send_ServerToPlayer( hCaster:GetPlayerOwner(), "player_summoned_transport", playerData )
				
				-- Damage enemies
				local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), vTargetPoint, nil, fAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(tEnemies) do
					if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
						ApplyAirborne(hCaster, v, 0.5)
						v:AddNewModifier(hCaster, self, "modifier_stunned", { duration = stun })					
					end	
					DoDamage(hCaster, v, self:GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL, 0, self, false)
								
				end

				if math.ceil(hCaster:GetStrength()) >= 25 and math.ceil(hCaster:GetAgility()) >= 25 and math.ceil(hCaster:GetIntellect()) >= 25 then
					if hCaster:FindAbilityByName("gille_larret_de_mort"):IsCooldownReady() and not hCaster:HasModifier("modifier_larret_de_mort_cooldown") and not hCaster:HasModifier("modifier_gilles_rlyeh_text_window") then
						hCaster:AddNewModifier(hCaster, self, "modifier_gilles_combo_window", { Duration = 4})
					end
				end

				EmitGlobalSound("ZC.Ravage")
				
				local ravageParticle = ParticleManager:CreateParticle("particles/custom/gilles/abyssal_contract_tentacles.vpcf", PATTACH_WORLDORIGIN, hSquidLordz)
				ParticleManager:SetParticleControl(ravageParticle, 0, vTargetPoint)
				ParticleManager:SetParticleControl(ravageParticle, 1, Vector(fAOE * 0.2, 0, 0))
				ParticleManager:SetParticleControl(ravageParticle, 2, Vector(fAOE * 0.4, 0, 0))
				ParticleManager:SetParticleControl(ravageParticle, 3, Vector(fAOE * 0.6, 0, 0))
				ParticleManager:SetParticleControl(ravageParticle, 4, Vector(fAOE * 0.8, 0, 0))
				ParticleManager:SetParticleControl(ravageParticle, 5, Vector(fAOE, 0, 0))

				Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( ravageParticle, false )
					ParticleManager:ReleaseParticleIndex( ravageParticle )
				end)
			end

			StopSoundEvent("Hero_Warlock.Upheaval", hCaster)
		end)
	end

	function ability:OnOwnerDied()
		if self:GetCaster().Squidlord ~= nil and IsValidEntity(self:GetCaster().Squidlord) and self:GetCaster().Squidlord:IsAlive() then
			self:GetCaster().Squidlord:ForceKill(true)
		end
	end

	function ability:OnUpgrade()
		local MasterUnit2 = self:GetCaster().MasterUnit2

		if MasterUnit2 then 
			MasterUnit2:FindAbilityByName("gilles_abyssal_connection_attribute"):SetLevel(self:GetLevel())
		end	
	end
end
gilles_abyssal_contract_wrapper(gilles_abyssal_contract)
gilles_abyssal_contract_wrapper(gilles_abyssal_contract_upgrade)

if IsServer() then 
	function modifier_squidlord_death_checker:OnDestroy()		
		self:GetCaster():RemoveModifierByName("modifier_squidlord_alive")

		local hAbility = self:GetCaster():FindAbilityByName("gilles_abyssal_contract")
		if hAbility == nil then 
			hAbility = self:GetCaster():FindAbilityByName("gilles_abyssal_contract_upgrade")
		end
		hAbility:EndCooldown()
		hAbility:StartCooldown(hAbility:GetCooldown(hAbility:GetLevel()))
	end
end

function modifier_squidlord_death_checker:IsHidden()
	return true
end

function modifier_squidlord_alive:IsHidden()
	return true
end

function modifier_squidlord_alive:IsPermanent()
	return false
end

function modifier_squidlord_alive:RemoveOnDeath()
	return true
end

function modifier_squidlord_alive:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function OnTentacleHookStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local targetPoint = ability:GetCursorPosition()
	local range = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("speed")
	local width = ability:GetSpecialValueFor("width")
	local forwardvec = (targetPoint - caster:GetAbsOrigin()):Normalized() 

	local hook = {
		Ability = ability,
		--EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = speed,
		vSpawnOrigin = caster:GetAbsOrigin() + forwardvec * 100,
		fDistance = range,
		Source = caster,
		fStartRadius = width,
        fEndRadius = width,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		fExpireTime = GameRules:GetGameTime() + 2,
		bDeleteOnHit = true,
		vVelocity = forwardvec * speed,
		
	}

    local projectile = ProjectileManager:CreateLinearProjectile(hook)
end

function OnTentacleHookHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	print(target:GetUnitName())
	if target:GetUnitName() == "gille_gigantic_horror" or caster.IsHookHit then return end
	caster.IsHookHit = true
	target:EmitSound("Hero_Pudge.AttackHookImpact")
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 

	target:AddNewModifier(target, ability, "modifier_stunned", {Duration = 0.75})
	local pullTarget = Physics:Unit(target)
	local pullVector = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * diff * 2
	target:PreventDI()
	target:SetPhysicsFriction(0)
	target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 2000))
	target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	target:FollowNavMesh(false)
	target:SetAutoUnstuck(false)

	Timers:CreateTimer({
		endTime = 0.25,
		callback = function()
		target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -2000))
	end
	})

  	Timers:CreateTimer(0.5, function()
		target:PreventDI(false)
		target:SetPhysicsVelocity(Vector(0,0,0))
		target:OnPhysicsFrame(nil)
		target:SetAutoUnstuck(true)
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)

	end)
  	Timers:CreateTimer(1.0, function()
		caster.IsHookHit = false
	end)
end

function OnTentacleWrapStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 
	if not IsImmuneToCC(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tentacle_wrap", {})
	end
	local fxCounter = 0
	Timers:CreateTimer(function()
		if fxCounter > 2 then return end 
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit_wrap.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(tentacleFx, 0, target:GetAbsOrigin() + Vector(0,0,100))
		ParticleManager:SetParticleControl(tentacleFx, 2, target:GetAbsOrigin() + Vector(0,0,100))
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( tentacleFx, false )
			ParticleManager:ReleaseParticleIndex( tentacleFx )
		end)
		fxCounter = fxCounter + 0.5
		return 0.5
	end)
end

function OnSubSkewerStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local range = ability:GetSpecialValueFor("range")
	local targetPoint = ability:GetCursorPosition()
	local diff = (targetPoint - casterLoc):Normalized()
	local frontward = caster:GetForwardVector()
	local skewer = 
	{
		Ability = ability,
        EffectName = "",
        iMoveSpeed = 3000,
        vSpawnOrigin = casterLoc - frontward*100,
        fDistance = range,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 3000
	}
	--local projectile = ProjectileManager:CreateLinearProjectile(skewer)
	Timers:CreateTimer(1.0, function()
		local projectile = ProjectileManager:CreateLinearProjectile(skewer)
		caster:EmitSound("Hero_Lion.Impale")
		print("generated projectile")
	end)

	local tentacleCounter1 = 0
	Timers:CreateTimer(1.0, function()
		if tentacleCounter1 > 10 then return end
		print("tentacles")
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(tentacleFx, 0, casterLoc + diff * 110 * tentacleCounter1)
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( tentacleFx, false )
			ParticleManager:ReleaseParticleIndex( tentacleFx )
		end)
		tentacleCounter1 = tentacleCounter1 + 1
		return 0.033
	end)
end

function OnSubSkewerHit(keys)
	if keys.target == nil then return end
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	
	local ability = keys.ability
	local caster = keys.caster
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	if not IsImmuneToCC(target) then
		ApplyAirborne(caster, target, stun_duration)
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnIntegrateStart(keys)
	local caster = keys.caster
	local hero = caster:GetOwnerEntity()
	local healthpercent = caster:GetHealthPercent() / 100
	local IntMaxhealth = caster:GetMaxHealth()+keys.Health
	local IntCurrenthealth = caster:GetHealth()+(keys.Health * healthpercent)
	local DeIntMaxhealth = caster:GetMaxHealth()-keys.Health
	local DeIntCurrenthealth = caster:GetHealth()-(keys.Health * healthpercent)

	Timers:CreateTimer(0.5, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsIntegrated then
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Unmount")
					return			
				else
					hero:RemoveModifierByName("modifier_integrate_gille")
					caster:RemoveModifierByName("modifier_integrate")
					caster:SetMaxHealth(DeIntMaxhealth)
					caster:SetHealth(DeIntCurrenthealth)
					hero.IsIntegrated = false
					SendMountStatus(hero)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then 
				hero.IsIntegrated = true
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_integrate_gille", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_integrate", {})  
				caster:SetMaxHealth(IntMaxhealth)
				caster:SetHealth(IntCurrenthealth)
				caster:EmitSound("ZC.Tentacle1")
				--caster:EmitSound("ZC.Laugh")
				SendMountStatus(hero)
				return 
			end
		end
	end)
end

function OnIntegrateDeath(keys)
	local caster = keys.caster
	local hero = caster:GetOwnerEntity()
	hero.IsIntegrated = false
	hero:RemoveModifierByName("modifier_integrate_gille")
	hero:RemoveModifierByName("modifier_squidlord_death_checker")
	SendMountStatus(hero)
end

--[[function OnIntegrateCanceled(keys)
	local caster = keys.caster
	if caster.AttemptingIntegrate then 
		caster.AttemptingIntegrate = false
		Timers:RemoveTimer("integrate_checker")
	end
end]]

function IntegrateFollow(keys)
	local caster = keys.caster
	local hero = caster:GetOwnerEntity()
	if IsValidEntity(caster) then
		hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,400))
	end
end