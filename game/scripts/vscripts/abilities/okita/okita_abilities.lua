
function OnAbilityCastInvisBroke(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster:HasModifier("modifier_shukuchi_invis") then 
		caster:RemoveModifierByName("modifier_shukuchi_invis")
	end
end

function OnFlagCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if IsValidEntity(caster.flag) and caster.flag:IsAlive() then
		caster:Interrupt()
    	SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Summon")
    	return
    end
    --OnSeiganStop(keys)
end

function OnFlagStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local flag_origin = caster:GetAbsOrigin() + caster:GetForwardVector() * 100
	local radius = ability:GetSpecialValueFor("radius")
	local min_summon = ability:GetSpecialValueFor("min_summon")
	local max_summon = ability:GetSpecialValueFor("max_summon")
	local duration = ability:GetSpecialValueFor("duration")
	local flag_health = ability:GetSpecialValueFor("flag_health")
	local summon_count = RandomInt(min_summon, max_summon)

	if IsValidEntity(caster.flag) and caster.flag:IsAlive() then
    	ability:EndCooldown()
    	caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
    	SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Summon")
    	return
    end

    --[[local iskandar = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)
    for _,iskander in pairs(iskandar) do
    	if iskander:GetName() == "npc_fate_hero_chen" then 
    		caster.bIskandarAllied = true
    	end
    end]]

	caster.flag = CreateUnitByName("okita_flag", flag_origin, true, nil, nil, caster:GetTeamNumber())
	caster.flag:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
	caster.flag:SetBaseMaxHealth(flag_health)
	caster.flag:SetForwardVector(caster:GetForwardVector())
	caster.flag:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.flag:FindAbilityByName("okita_flag_of_sincerity_passive"):SetLevel(1)
	caster.flag:SetOwner(caster)
	FindClearSpaceForUnit(caster.flag, flag_origin , true)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_flag_summon", {})

	caster.currentflaghealth = flag_health
	caster.flagorigin = flag_origin
	caster.flagradius = radius
	caster.duration = duration
	--[[if caster.flag:GetOrigin().y >= -2000 then 
		caster.flagspawnrealworld = true
	print('flag spawn real world')
	else 
	 	caster.flagspawnrealworld = false
	end]]

	if caster.cacheunit == nil then 
		caster.cacheunit = {}
	end

	if caster.shinsengumi == nil then 
		caster.shinsengumi = {}
	end

	for i = 1,summon_count do
		Timers:CreateTimer(i*0.1, function()
	    	caster.shinsengumi[i] = CreateUnitByName("okita_shinsengumi", flag_origin + RandomVector(150) , true, nil, nil, caster:GetTeamNumber())
	    	FindClearSpaceForUnit(caster.shinsengumi[i], flag_origin + RandomVector(150), true)
	    	caster.shinsengumi[i]:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
	    	caster.shinsengumi[i]:SetControllableByPlayer(caster:GetPlayerID(), true)
			caster.shinsengumi[i]:SetForwardVector(caster:GetForwardVector())
			caster.shinsengumi[i]:FindAbilityByName("okita_shinsengumi_passive"):SetLevel(1)
			caster.shinsengumi[i]:SetOwner(caster)
		end)
   	end

   	caster.shinsengumi_count = summon_count

   	if caster.IsCoadOfOathsAcquired then 
   		--[[if RandomInt(1, 100) <= ability:GetSpecialValueFor("summon_chance") then
	   		caster.Hijikata = CreateUnitByName("okita_hijikata", flag_origin + RandomVector(150) , true, nil, nil, caster:GetTeamNumber())
	    	FindClearSpaceForUnit(caster.Hijikata, flag_origin + RandomVector(150), true)
	    	caster.Hijikata:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
	    	caster.Hijikata:SetControllableByPlayer(caster:GetPlayerID(), true)
			caster.Hijikata:SetForwardVector(caster:GetForwardVector())
			caster.Hijikata:FindAbilityByName("okita_head_shinsengumi_passive"):SetLevel(1)
			caster.Hijikata:FindAbilityByName("okita_law_of_shinsengumi_passive"):SetLevel(1)
			caster.Hijikata:FindAbilityByName("okita_hijikata_undying_sincerity"):SetLevel(1)
			caster.Hijikata:SetOwner(caster)
			caster.shinsengumi_count = caster.shinsengumi_count + 1
		end]]
	end
   
	local color = Vector(130,215,255) -- blue
	if caster:HasModifier("modifier_alternate_01") then 
		color = Vector(255,100,180) -- pink
	elseif caster:HasModifier("modifier_alternate_02") then 
		color = Vector(255,255,160) -- gold
	end
   	--particle area 
   	local sacredZoneFx = ParticleManager:CreateParticle("particles/custom/okita/okita_flag_zone.vpcf", PATTACH_WORLDORIGIN, caster.flag)
	ParticleManager:SetParticleControl(sacredZoneFx, 0, flag_origin)
	ParticleManager:SetParticleControl(sacredZoneFx, 1, Vector(1,1,radius))
	ParticleManager:SetParticleControl(sacredZoneFx, 12, color)
	caster.CurrentFlagParticle = sacredZoneFx
end

function OnFlagTakeDamagePassive (keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity()
	local ability = keys.ability
	local currenthealth = caster:GetHealth()
	if caster:IsAlive() then
		currenthealth = currenthealth - 1
		caster:SetHealth(currenthealth)
		if currenthealth <= 0 then
			OnFlagDeath(hero)
		end
	end
end

function OnFlagThinkPassive (keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity()
	local ability = keys.ability 

	 -- apply shinsengumi brother buff
	local okita = FindUnitsInRadius(hero:GetTeam(), caster:GetOrigin(), nil, hero.flagradius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,h in pairs (okita) do
		if h:GetUnitName() == hero:GetUnitName() then 
			if hero.IsHeadBandAcquired then
				ability:ApplyDataDrivenModifier(caster, hero, "modifier_okita_headband_upgrade", {})	
			else
				ability:ApplyDataDrivenModifier(caster, hero, "modifier_okita_headband", {})	
			end
			if h:HasModifier("modifier_coat_of_oaths") then 
				for _,v in pairs(hero.shinsengumi) do
					if v and IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
						if hero.IsHeadBandAcquired then
							ability:ApplyDataDrivenModifier(caster, v, "modifier_okita_headband_upgrade", {})	
						else
							ability:ApplyDataDrivenModifier(caster, v, "modifier_okita_headband", {})	
						end
					end
				end
			end
		end
	end	

	if hero.shinsengumi_count <= 0 or not IsInSameRealm(caster:GetOrigin(), hero:GetOrigin()) then 
		hero:RemoveModifierByName("modifier_flag_summon")
    end

    for _,s in pairs(hero.shinsengumi) do
		if s and IsValidEntity(s) then
			if not IsInSameRealm(caster:GetAbsOrigin(), s:GetAbsOrigin()) then 
				s:ForceKill(true)
			end
        end
	end
end 

function OnSummonFlagDestroy(keys)
	local caster = keys.caster 
	if caster.flag == nil then return end

	OnFlagDeath(caster)
end

function OnFlagDeath(hero)

	ParticleManager:DestroyParticle( hero.CurrentFlagParticle, false )
	ParticleManager:ReleaseParticleIndex( hero.CurrentFlagParticle )

	for _,v in pairs(hero.shinsengumi) do
		if v and IsValidEntity(v) then
			--table.insert(hero.cacheunit, v)
	        v:ForceKill(true)
	    end
	end
	if IsValidEntity(hero.Hijikata) then 
		--table.insert(hero.cacheunit, hero.Hijikata)
		hero.Hijikata:ForceKill(true)
	end
	if IsValidEntity(hero.flag) then  
		hero.flag:ForceKill(true)
	end
	if hero:HasModifier("modifier_weak_buff") then 
		hero:RemoveModifierByName("modifier_weak_buff")
	end	

	hero.shinsengumi_count = 0
end

function OnOkitaDeath (keys)
	local caster = keys.caster 
	local ability = keys.ability 

	caster:RemoveModifierByName("modifier_flag_summon")
end

function OnFlagDeathPassive (keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity()

	hero:RemoveModifierByName("modifier_flag_summon")
end 

function OnShinsengumiThinkPassive (keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity()

	if not IsValidEntity(hero.flag) then
		if caster:IsAlive() then
        	caster:RemoveSelf()
        end
    end

	if math.abs((caster:GetOrigin() - hero.flagorigin):Length2D()) > hero.flagradius then
		local diff = caster:GetOrigin() - hero.flagorigin
		diff = diff:Normalized()

		caster:SetAbsOrigin(hero.flagorigin + diff * hero.flagradius)
	--print("Abs Origin To Set", (TheatreCenter + diff * self.TheatreSize))
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end
end 

function OnShinsengumiDeath (keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity()
	hero.shinsengumi_count = hero.shinsengumi_count - 1
	if hero.shinsengumi_count <= 0 then 
		hero:RemoveModifierByName("modifier_flag_summon")
	end
end

function OnLawShinsengumiCheck(keys)
	local caster = keys.caster 
	local hero = caster:GetOwnerEntity() 
	local ability = keys.ability
	local target = keys.target 
	if IsShinsengumi(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_law_of_shinsengumi_buff", {})
	end
end

function OnLawShinsengumiDestroy(keys)
	local target = keys.target 
	target:RemoveModifierByName("modifier_law_of_shinsengumi_buff")
end

function OnUndyingSincerityCast(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target  
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Interrupt() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
end

function OnUndyingSincerityStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target  
	local range = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("speed")
	local damage = ability:GetSpecialValueFor("damage")
	local stun = ability:GetSpecialValueFor("stun")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_undying_sincerity", {})

	local hijikata = Physics:Unit(caster) 
	if caster:IsAlive() then
		caster:SetPhysicsVelocity(caster:GetForwardVector() * speed)
		caster:PreventDI()
	    caster:SetPhysicsFriction(0)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)
	    caster:OnPhysicsFrame(function(unit)
			local diff = target:GetAbsOrigin() - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(dir * speed)
			if diff:Length() >= 1500 or not IsInSameRealm(target:GetAbsOrigin(), caster:GetAbsOrigin()) or target:IsInvulnerable() or target:IsInvisible() then 
				unit:RemoveModifierByName("modifier_undying_sincerity")
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:OnHibernate(nil)
				unit:SetAutoUnstuck(true)
		        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        return
			elseif diff:Length() <= 100 then
				unit:RemoveModifierByName("modifier_undying_sincerity")
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:OnHibernate(nil)
				unit:SetAutoUnstuck(true)
		        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)

		        if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then 
		        	target:AddNewModifier(unit, ability, "modifier_stunned", {Duration = stun})
		        end
		        DoDamage(unit, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
		        
		    end
		end)
	end
end

function AddExhaust(keys, modifier)
	local caster = keys.caster 

	if caster:HasModifier("modifier_coat_of_oaths") then return end

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	local ability = caster:FindAbilityByName("okita_weak_constitution")
	if ability == nil then 
		ability = caster:FindAbilityByName("okita_weak_constitution_upgrade")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_weak_constitution_progress", {})

	local current_stack = caster:GetModifierStackCount("modifier_weak_constitution_progress", caster) or 0 

	caster:SetModifierStackCount("modifier_weak_constitution_progress", caster, current_stack + modifier)
	caster.weak_progress = current_stack + modifier
end

function OnSoundAttack(keys)
	local caster = keys.caster 
	caster:EmitSound("Hero_Juggernaut.Attack")
end

function OnWeakConstitutionThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if caster:HasModifier("round_pause") then 
		caster:RemoveModifierByName("modifier_weak_constitution_progress")
		return
	end

	if caster:HasModifier("modifier_shukuchi_breath") or caster:HasModifier("modifier_coat_of_oaths") or caster:HasModifier("modifier_okita_flash_window") or caster:HasModifier("modifier_sandanzuki_window") or caster:HasModifier("modifier_sandanzuki_dash") or caster:HasModifier("modifier_tennen_base") then 
		return 
	end

	if not caster:HasModifier('modifier_weak_constitution_progress') then 
		return 
	end

	local current_stack = caster:GetModifierStackCount("modifier_weak_constitution_progress", caster) or 0 
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local base_cough = ability:GetSpecialValueFor("base_cough")
	local max_cough = ability:GetSpecialValueFor("max_cough")
	local base_cough_delay = ability:GetSpecialValueFor("base_cough_delay")

	if caster.weak_progress >= max_cough then
		Timers:RemoveTimer('cough_timer1'.. caster:GetPlayerOwnerID())
		Timers:RemoveTimer('cough_timer2'.. caster:GetPlayerOwnerID())
		caster.CoughTrigger1 = nil
		caster.CoughTrigger = nil
		caster:Stop()
		stun_duration = stun_duration * 2
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_weak_constitution", {})
		caster:EmitSound("Okita.Cough")
		caster:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		local bloodsplash = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_bloodstain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(bloodsplash, 1, caster:GetAbsOrigin())

		caster:RemoveModifierByName("modifier_weak_constitution_progress")
		caster.CoughTrigger = true

		Timers:CreateTimer(3, function()
			ParticleManager:DestroyParticle(bloodsplash, false)
			ParticleManager:ReleaseParticleIndex(bloodsplash)
		end)
	elseif caster.weak_progress >= (base_cough + max_cough)/2 then 
		stun_duration = stun_duration * 1.5
		if not caster.CoughTrigger1 then
			caster.CoughTrigger1 = true
			Timers:CreateTimer('cough_timer2' .. caster:GetPlayerOwnerID(), {
				endTime = ability:GetSpecialValueFor("base_cough_delay") / 2,
				callback = function()
				Timers:RemoveTimer('cough_timer1' .. caster:GetPlayerOwnerID())
		        if caster:IsAlive() then
					caster:Stop()
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_weak_constitution", {})
					caster:EmitSound("Okita.Cough")
					caster:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
					local bloodsplash = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_bloodstain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(bloodsplash, 1, caster:GetAbsOrigin())

					caster:RemoveModifierByName("modifier_weak_constitution_progress")
					caster.CoughTrigger1 = nil
					caster.CoughTrigger = nil

					Timers:CreateTimer(3, function()
						ParticleManager:DestroyParticle(bloodsplash, false)
						ParticleManager:ReleaseParticleIndex(bloodsplash)
					end)
				end
		    end})
		end
	elseif caster.weak_progress >= base_cough then 
		if not caster.CoughTrigger then
			caster.CoughTrigger = true
			Timers:CreateTimer('cough_timer1' .. caster:GetPlayerOwnerID(), {
				endTime = ability:GetSpecialValueFor("base_cough_delay"),
				callback = function()
		        if caster:IsAlive() then
					caster:Stop()
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_weak_constitution", {})
					caster:EmitSound("Okita.Cough")
					caster:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
					local bloodsplash = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_bloodstain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(bloodsplash, 1, caster:GetAbsOrigin())

					caster:RemoveModifierByName("modifier_weak_constitution_progress")
					caster.CoughTrigger = nil
					Timers:CreateTimer(3, function()
						ParticleManager:DestroyParticle(bloodsplash, false)
						ParticleManager:ReleaseParticleIndex(bloodsplash)
					end)
				end
		    end})
		end
	end
end

function OnWeakConstitutionRecovery(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if ability == nil then 
		ability = caster:FindAbilityByName("okita_weak_constitution_upgrade")
	end
	local recovery_progress = ability:GetSpecialValueFor("recovery")
	local base_cough = ability:GetSpecialValueFor("base_cough")

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	if caster.weak_progress > recovery_progress and caster.weak_progress < base_cough then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_weak_constitution_progress", {})
		caster:SetModifierStackCount("modifier_weak_constitution_progress", caster, caster.weak_progress - recovery_progress)
		caster.weak_progress = math.max(0, caster.weak_progress - recovery_progress)  
	else
		caster.weak_progress = 0
	end
	
end

function OnWeakConstitutionCreate(keys)
	local caster = keys.caster 
	caster.CoughTrigger = false 
end

function OnCoughUp (keys)
	local caster = keys.caster 

	if not caster:IsAlive() then return end

	--OnSeiganStop(keys)

	local ability = keys.ability 
	local hp_loss_percent = ability:GetSpecialValueFor("hp_loss_percent") / 100
	local hp_loss = caster:GetHealth() * hp_loss_percent
	local cough_up = {
		victim = caster,
		attacker = caster,
		damage = hp_loss,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL, --Optional.
		ability = ability, --Optional.
	}
	ApplyDamage(cough_up)	
end

function OnWeakConstitutionAttack (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local exhaust = ability:GetSpecialValueFor("exhaust")
	
	AddExhaust(keys, exhaust)
end

function OnShukuchiStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local leap_range = ability:GetSpecialValueFor("leap_range")
	local exhaust = ability:GetSpecialValueFor("exhaust")

	if IsLocked(caster) and not caster:HasModifier("modifier_hira_seigan_thinker") then
		keys.ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(1)) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end

    --OnSeiganStop(keys)

    if (target_loc - caster:GetAbsOrigin()):Length2D() > leap_range then
		target_loc = caster:GetAbsOrigin() + (((target_loc - caster:GetAbsOrigin()):Normalized()) * leap_range)
	end

	local frontvec = (target_loc - caster:GetAbsOrigin()):Normalized()

	ProjectileManager:ProjectileDodge(caster)
	AddExhaust(keys, exhaust)

	SetDashParticle(caster, caster:GetAbsOrigin(), frontvec, 2)

	FindClearSpaceForUnit(caster, target_loc, true)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_shukuchi_invis", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_shukuchi_breath", {})
end

function OnTennenAttack(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local max_stacks = ability:GetSpecialValueFor("max_stacks") 

	if not IsValidEntity(caster) or caster:IsNull() or not caster:IsAlive() then return end

	local current_stack = caster:GetModifierStackCount("modifier_tennen_passive", caster) or 0 

	if current_stack + 1 > max_stacks then 
		caster:RemoveModifierByName("modifier_tennen_bonus")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_tennen_bonus", {})
		caster:SetModifierStackCount("modifier_tennen_passive", caster, max_stacks)
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_tennen_bonus", {})
		caster:SetModifierStackCount("modifier_tennen_passive", caster, current_stack + 1)
		caster:CalculateStatBonus(true)
	end
end

function OnTennenThink(keys)
	local caster = keys.caster 
	if not caster:HasModifier("modifier_tennen_bonus") then 
		caster:SetModifierStackCount("modifier_tennen_passive", caster, 0)
	end
end

function OnTennenDeath(keys)
	local caster = keys.caster 
	caster:SetModifierStackCount("modifier_tennen_passive", caster, 0)
end

function OnTennenBonusDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local current_stack = caster:GetModifierStackCount("modifier_tennen_passive", caster)
	caster:SetModifierStackCount("modifier_tennen_passive", caster, current_stack - 1)
	caster:CalculateStatBonus(true)
end

function OnTenninRishinStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local exhaust = ability:GetSpecialValueFor("exhaust")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tennen_base", {})
	AddExhaust(keys, exhaust)

	--OnSeiganStop(keys)

	OkitaCheckCombo(caster, ability)
end 

function OnSeiganStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local shield = ability:GetSpecialValueFor("shield")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hira_seigan_shield", {})
	caster.IsShieldBreak = false
	caster.SeiganShield = shield
	caster.attacker = caster
	caster.SeiganStop = false
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_5, rate=2.0})
	Timers:CreateTimer(0.5, function()
		FreezeAnimation(caster)
	end)
	--[[caster.SeiganTimer = Timers:CreateTimer(duration - 0.1, function()
		if caster:IsAlive() then
			caster.IsShieldBreak = true
		end
	end)]]
end

function OnSeiganCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster.forwardvec = caster:GetForwardVector()
	caster:SwapAbilities(ability:GetAbilityName(), "okita_hira_seigan_stop", false, true)
	
	caster.seiganring = ParticleManager:CreateParticle("particles/custom/okita/hira_seigen_ring2.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.seiganring, 1, caster:GetAbsOrigin() + Vector(0,0, 100))

	caster.seiganshield = ParticleManager:CreateParticle("particles/custom/okita/hira_seigen_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(caster.seiganshield, 0, caster:GetAbsOrigin())
	caster:EmitSound("Hero_KeeperOfTheLight.Illuminate.Charge")
end

function OnSeiganDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability
	UnfreezeAnimation(caster)
	EndAnimation(caster)
	caster:SwapAbilities(ability:GetAbilityName(), "okita_hira_seigan_stop", true, false)

	ParticleManager:DestroyParticle(caster.seiganshield, true)
	ParticleManager:ReleaseParticleIndex(caster.seiganshield)

	ParticleManager:DestroyParticle(caster.seiganring, true)
	ParticleManager:ReleaseParticleIndex(caster.seiganring)
	
	caster:StopSound("Hero_KeeperOfTheLight.Illuminate.Charge")
	if caster.IsShieldBreak == true or caster.SeiganStop == false then 
		OnSeiganFireBeam(keys)
	end
end

function OnSeiganStop(keys)
	local caster = keys.caster 
	caster.SeiganStop = true
	UnfreezeAnimation(caster)
	EndAnimation(caster)
	caster:RemoveModifierByName("modifier_hira_seigan_shield")

	--[[if caster.SeiganTimer ~= nil then 
		Timers:RemoveTimer(caster.SeiganTimer)
		caster.SeiganTimer = nil
	end]]
end

function OnSeiganTakeDamage(keys)
	local caster = keys.caster 
	local currentHealth = caster:GetHealth() 

	-- Create particles
	local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( onHitParticleIndex, 2, caster:GetAbsOrigin() )
	
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( onHitParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
	end)

	caster.SeiganShield = caster.SeiganShield - keys.DamageTaken
	if caster.SeiganShield <= 0 then
		if currentHealth + caster.SeiganShield <= 0 then
			--print("lethal")
		else
			caster.SeiganShield = 0
			caster.IsShieldBreak = true
			caster.attacker = keys.attacker
			--print("rho broken, but not lethal")
			caster:RemoveModifierByName("modifier_hira_seigan_shield")
			caster:SetHealth(currentHealth + keys.DamageTaken + caster.SeiganShield)

			--Timers:RemoveTimer(caster.SeiganTimer)
		end
	else
		--print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		caster:SetHealth(currentHealth + keys.DamageTaken)
		caster:SetModifierStackCount("modifier_rho_aias", caster, caster.SeiganShield)
	end
end

function OnSeiganFireBeam(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local attacker = caster.attacker 
	local beam_width = ability:GetSpecialValueFor("beam_width")
	local beam_range = ability:GetSpecialValueFor("beam_range")
	local beam_speed = ability:GetSpecialValueFor("beam_speed")
	local fx = "particles/custom/okita/okita_seigan_beam.vpcf"
	local forwardvec = caster:GetForwardVector()

	local beam = {
		Ability = ability,
        EffectName = nil, --"particles/custom/false_assassin/fa_quickdraw.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = beam_range,
        fStartRadius = beam_width,
        fEndRadius = beam_width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = forwardvec * beam_speed
	}

	if attacker ~= caster then 
		local target_loc = attacker:GetAbsOrigin()
		local caster_loc = caster:GetAbsOrigin()
		target_loc.z = caster_loc.z
		forwardvec = (target_loc - caster_loc):Normalized() 
		if forwardvec == Vector(0,0,0) then 
			caster:SetAngles(0, 0, 0)
		end
		beam.vVelocity = forwardvec * beam_speed
		caster:SetForwardVector(forwardvec)

	end

	UnfreezeAnimation(caster)
	EndAnimation(caster)

	Timers:CreateTimer(0.1, function()
		local angle = caster:GetAnglesAsVector().y
		
		local end_point = GetRotationPoint(caster:GetAbsOrigin(),beam_range,angle)

		local projectile = ProjectileManager:CreateLinearProjectile(beam)
		StartAnimation(caster, {duration = beam_range / beam_speed + 0.2, activity=ACT_DOTA_ATTACK_EVENT, rate = 5.0})
		giveUnitDataDrivenModifier(caster, caster, "dragged", beam_range / beam_speed + 0.2)
		
		if caster:HasModifier("modifier_alternate_02") then
			fx = "particles/custom/okita/okita_seigan_beam_black.vpcf"
		end

		
		local seigan_beam = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(seigan_beam, 0, caster:GetAbsOrigin() + Vector(0,0,100))
		ParticleManager:SetParticleControl(seigan_beam, 1, end_point + Vector(0,0,100))
		caster:EmitSound("Hero_Invoker.EMP.Discharge")

		Timers:CreateTimer(beam_range / beam_speed + 0.2, function()
			ParticleManager:DestroyParticle( seigan_beam, false )
			ParticleManager:ReleaseParticleIndex( seigan_beam )
		end)
	end)
end

function OnSeiganBeamHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local min_damage = ability:GetSpecialValueFor("min_damage")
	local max_damage = ability:GetSpecialValueFor("max_damage")
	local shield = ability:GetSpecialValueFor("shield")
	local damage = min_damage + ((max_damage - min_damage) * (1 - caster.SeiganShield/shield))

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
end

--[[function OnSeiganChannelStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hira_seigan_thinker", {})
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_5, rate=2.0})
end

function OnSeiganCreate(keys)
	local caster = keys.caster 
	caster.SeiganCharge = 0
	caster.seiganring = ParticleManager:CreateParticle("particles/custom/okita/hira_seigen_ring2.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.seiganring, 1, caster:GetAbsOrigin() + Vector(0,0, 100))

	caster.seiganshield = ParticleManager:CreateParticle("particles/custom/okita/hira_seigen_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(caster.seiganshield, 0, caster:GetAbsOrigin())
	caster:EmitSound("Hero_KeeperOfTheLight.Illuminate.Charge")
end

function OnSeiganThink(keys)
	local caster = keys.caster 
	caster.SeiganCharge = caster.SeiganCharge + 0.1 
	if caster.SeiganCharge == 0.5 then 
		FreezeAnimation(caster)
	end
end

function OnSeiganDestroy(keys)
	local caster = keys.caster 
	ParticleManager:DestroyParticle(caster.seiganshield, true)
	ParticleManager:ReleaseParticleIndex(caster.seiganshield)

	ParticleManager:DestroyParticle(caster.seiganring, true)
	ParticleManager:ReleaseParticleIndex(caster.seiganring)
	caster:StopSound("Hero_KeeperOfTheLight.Illuminate.Charge")
end

function OnSeiganInterrupt(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local charge_damage = ability:GetSpecialValueFor("charge_damage")
	caster:RemoveModifierByName("modifier_hira_seigan_thinker")
	UnfreezeAnimation(caster)
	local exhaust = ability:GetSpecialValueFor("exhaust")
	exhaust = math.floor(exhaust * caster.SeiganCharge / 3)
	AddExhaust(keys, exhaust)


	local damage = base_damage + (charge_damage * caster.SeiganCharge)

	local count = 20 + 40 * caster.SeiganCharge / 3

	--StartAnimation(caster, {duration = 1.0, activity=ACT_DOTA_ATTACK, rate = 5.0})

	for i=1, math.floor(count/2) do
		Timers:CreateTimer(0.003*i, function()
			local angle = RandomInt(0, 360)
			local random1 = RandomInt(200, radius-1)
			local random2 = RandomInt(150, radius-1)
	        local startLoc = GetRotationPoint(caster:GetAbsOrigin(),random1,angle) 
	        local endLoc = GetRotationPoint(caster:GetAbsOrigin(),random2,angle + RandomInt(120, 240))
	        local fxIndex = ParticleManager:CreateParticle( "particles/okita/okita_jce_slash.vpcf", PATTACH_ABSORIGIN, caster)
	        ParticleManager:SetParticleControl( fxIndex, 0, startLoc + Vector(0,0,radius*math.abs(math.sqrt(1 - (random1/radius)^2))))
	        ParticleManager:SetParticleControl( fxIndex, 1, endLoc + Vector(0,0,radius*math.abs(math.sqrt(1 - (random2/radius)^2))))
	        ParticleManager:SetParticleControl( fxIndex, 3, endLoc + Vector(0,0,radius*math.abs(math.sqrt(1 - (random2/radius)^2))))
	        caster:EmitSound("Tsubame_Slash_" .. math.random(1,3))
	    end)
    end

    local unitGroup = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for i = 1, #unitGroup do
		DoDamage(caster, unitGroup[i], damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnSeiganSuccess(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local beam_width = ability:GetSpecialValueFor("beam_width")
	local beam_range = ability:GetSpecialValueFor("beam_range")
	local exhaust = ability:GetSpecialValueFor("exhaust")
	local fx = "particles/custom/okita/okita_seigan_beam.vpcf"
	AddExhaust(keys, exhaust)
	UnfreezeAnimation(caster)
	EndAnimation(caster)
	local forwardvec = caster:GetForwardVector()
	local speed = 2500
	caster:RemoveModifierByName("modifier_hira_seigan_thinker")
	StartAnimation(caster, {duration = beam_range / speed + 0.2, activity=ACT_DOTA_ATTACK_EVENT, rate = 5.0})


	local beam = {
		Ability = ability,
        EffectName = nil,--"particles/custom/false_assassin/fa_quickdraw.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = beam_range,
        fStartRadius = beam_width,
        fEndRadius = 150,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = forwardvec * speed
	}
	giveUnitDataDrivenModifier(caster, caster, "drag_pause", beam_range / speed + 0.2)
	local projectile = ProjectileManager:CreateLinearProjectile(beam)
	local dummy_loc = caster:GetAbsOrigin()
	local dummy = CreateUnitByName("dummy_unit", dummy_loc, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy:SetForwardVector(forwardvec)

	if caster:HasModifier("modifier_alternate_02") then
		fx = "particles/custom/okita/okita_seigan_beam_black.vpcf"
	end
	
	local seigan_beam = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, dummy)
	ParticleManager:SetParticleControl(seigan_beam, 0, caster:GetAbsOrigin() + Vector(0,0,100))
	ParticleManager:SetParticleControl(seigan_beam, 1, caster:GetAbsOrigin() + (Vector(forwardvec.x, forwardvec.y,0) * beam_range) + Vector(0,0,100)) 
	ParticleManager:SetParticleControl(seigan_beam, 3, dummy:GetAbsOrigin() + Vector(0,0,100))
	caster:EmitSound("Hero_Invoker.EMP.Discharge")


	Timers:CreateTimer(function()
		if IsValidEntity(dummy) then
			dummy_loc = dummy_loc + (speed * 0.05) * Vector(forwardvec.x, forwardvec.y, 0)
			dummy:SetAbsOrigin(GetGroundPosition(dummy_loc, nil))
			return 0.05
		else
			return nil
		end
	end)	

	Timers:CreateTimer(beam_range / speed + 0.2, function()
		ParticleManager:DestroyParticle( seigan_beam, false )
		ParticleManager:ReleaseParticleIndex( seigan_beam )
		if IsValidEntity(dummy) then
			dummy:RemoveSelf()
		end
	end)
end

function OnSeiganBeamHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	local base_damage = ability:GetSpecialValueFor("base_damage")
	local charge_damage = ability:GetSpecialValueFor("charge_damage")
	local damage = base_damage + (charge_damage * duration)

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
end

function OnSeiganTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.attacker
	local damage_taken = keys.DamageTaken
	local dmg_threshold = ability:GetSpecialValueFor("dmg_threshold")

	if caster:GetTeam() ~= target:GetTeam() then 
		if damage_taken >= dmg_threshold then
			if caster:IsChanneling() then 
				ability:EndChannel(true)
			end
			caster:RemoveModifierByName("modifier_hira_seigan_thinker")
		end
	end
end]]

function OnSandanzukiUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsKikuIchimonjiAcquired then 
		if ability:GetLevel() ~= caster:FindAbilityByName("okita_sandanzuki_charge3_upgrade"):GetLevel() then 
			caster:FindAbilityByName("okita_sandanzuki_charge3_upgrade"):SetLevel(ability:GetLevel())
		end
	else
		if ability:GetLevel() ~= caster:FindAbilityByName("okita_sandanzuki_charge3"):GetLevel() then 
			caster:FindAbilityByName("okita_sandanzuki_charge3"):SetLevel(ability:GetLevel())
		end
	end
end

function OnSandanzukiStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local exhaust = ability:GetSpecialValueFor("exhaust")

	--OnSeiganStop(keys)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sandanzuki_window", {})
	EmitSoundOn("Okita.FirstStep", caster)
	if exhaust > 30 then 
		AddExhaust(keys, exhaust - 30)
	end
end

function OnSandanzukiWindowCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if caster.IsKikuIchimonjiAcquired then
		caster:SwapAbilities("okita_sandanzuki_upgrade", "okita_sandanzuki_charge1", false, true)
	else
		caster:SwapAbilities("okita_sandanzuki", "okita_sandanzuki_charge1", false, true)
	end
end

function OnSandanzukiWIndowDestroy(keys)
	local caster = keys.caster 
	if caster.IsKikuIchimonjiAcquired then 
		caster:SwapAbilities("okita_sandanzuki_upgrade", caster:GetAbilityByIndex(5):GetAbilityName(), true, false)
	else
		caster:SwapAbilities("okita_sandanzuki", caster:GetAbilityByIndex(5):GetAbilityName(), true, false)
	end
end

function OnSandanzukiWIndowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_sandanzuki_window")
end

function OnSandanzukiDash(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local forwardvec = (target_loc - caster:GetAbsOrigin()):Normalized()
	local dash_speed = ability:GetSpecialValueFor("dash_speed")
	local distance = ability:GetSpecialValueFor("distance")
	local exhaust = ability:GetSpecialValueFor("exhaust")
	local target_point = caster:GetAbsOrigin() + (forwardvec * distance)
	local duration = distance / dash_speed

	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc) then
		ability:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	--OnSeiganStop(keys)

	local frontvec = (target_loc - caster:GetAbsOrigin()):Normalized()

	local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)
    dummy:SetOrigin(caster:GetOrigin() - frontvec * 100)
    dummy:SetForwardVector(frontvec)

	SetDashParticle(caster, caster:GetAbsOrigin(), frontvec, duration)

	AddExhaust(keys, exhaust)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sandanzuki_dash", {Duration = duration})
	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.5 / duration})

	ProjectileManager:ProjectileDodge(caster)

	if ability:GetAbilityName() == "okita_sandanzuki_charge1" then
		EmitSoundOn("Okita.SecondStep", caster)
		caster:SwapAbilities("okita_sandanzuki_charge1", "okita_sandanzuki_charge2", false, true)
	elseif ability:GetAbilityName() == "okita_sandanzuki_charge2" then
		EmitSoundOn("Okita.ThirdStep", caster)
		if caster.IsKikuIchimonjiAcquired then
			caster:SwapAbilities("okita_sandanzuki_charge2", "okita_sandanzuki_charge3_upgrade", false, true)
		else
			caster:SwapAbilities("okita_sandanzuki_charge2", "okita_sandanzuki_charge3", false, true)
		end
	elseif ability:GetAbilityName() == "okita_sandanzuki_charge3" or ability:GetAbilityName() == "okita_sandanzuki_charge3_upgrade" then
		EmitGlobalSound("Okita.Mumyo")
		local mumyo = 
		{
			Ability = ability,
	        --EffectName = "",
	        iMoveSpeed = dash_speed,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        fDistance = distance,
	        fStartRadius = 180,
	        fEndRadius = 180,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
	        fExpireTime = GameRules:GetGameTime() + 2.0,
			bDeleteOnHit = true,
			vVelocity = forwardvec * dash_speed
		}
		local projectile = ProjectileManager:CreateLinearProjectile(mumyo)
		caster:RemoveModifierByName("modifier_sandanzuki_window")
	end

	local okita = Physics:Unit(caster) 
	if caster:IsAlive() then
		caster:SetPhysicsVelocity(caster:GetForwardVector() * dash_speed)
		caster:PreventDI()
	    caster:SetPhysicsFriction(0)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)
	    caster:OnPhysicsFrame(function(unit)
			local diff = target_point - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(dir * dash_speed)
			local shadowfx = ParticleManager:CreateParticle( "particles/custom/okita/okita_sandan_shadow.vpcf", PATTACH_ABSORIGIN, caster )
    		ParticleManager:SetParticleControlEnt(shadowfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
    		Timers:CreateTimer(0.5, function()
    			ParticleManager:DestroyParticle(shadowfx, false)
				ParticleManager:ReleaseParticleIndex(shadowfx)
    		end)

			if not unit:HasModifier("modifier_sandanzuki_dash") or diff:Length() <= 150 then
				
				unit:RemoveModifierByName("modifier_sandanzuki_dash")
				EndAnimation(unit)
				unit:PreventDI(false)
				unit:SetBounceMultiplier(0)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:OnHibernate(nil)
				unit:OnPreBounce(nil)
				unit:SetAutoUnstuck(true)
		        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        if string.match(ability:GetAbilityName(), "okita_sandanzuki_charge3") then
		        	giveUnitDataDrivenModifier(caster, caster, "jump_pause_postlock", 0.2)
		        end
		    end
		end)
	    --[[Timers:CreateTimer(duration, function()
	    	ParticleManager:DestroyParticle(dash_fx, true)
	    	ParticleManager:ReleaseParticleIndex(dash_fx)
	    	if IsValidEntity(dummy) then
	    		dummy:RemoveSelf()
	    	end
	    end)]]
	end
end

function OnSandanzukiHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local damage = ability:GetSpecialValueFor("base_damage")
	local bonus_agi_ratio = ability:GetSpecialValueFor("bonus_agi_ratio")
	local exhaust = ability:GetSpecialValueFor("exhaust")
	local delay_duration = ability:GetSpecialValueFor("delay_duration")

	--[[local newkeys = {
		caster = caster, 
		ability = caster:FindAbilityByName("okita_tennen")
	}]]
	

	if caster.IsKikuIchimonjiAcquired then 
		damage = damage + bonus_agi_ratio * caster:GetAgility() 
	end

	local slash_loc = target:GetAbsOrigin()

	local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(slashIndex, 0, slash_loc)
    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))

    Timers:CreateTimer(0.4, function()
        local particle = ParticleManager:CreateParticle("particles/custom/okita/okita_sandan.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 1, slash_loc + Vector(0,0,100))
        ParticleManager:SetParticleControl(particle, 3, slash_loc + Vector(0,0,100))
    end)
    Timers:CreateTimer(delay_duration, function()
        EmitGlobalSound("Okita.Sandanzuki")
        local slash1 = ParticleManager:CreateParticle("particles/custom/okita/okita_sandan_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(slash1, 1, target:GetAbsOrigin() + Vector(-50,0,120))

        
        if IsValidEntity(target) and not target:IsNull() then
	        target:EmitSound("Tsubame_Slash_" .. math.random(1,3))
	        DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
	        --OnTennenAttack(newkeys)
	    end
    end)
    Timers:CreateTimer(delay_duration + 0.2, function()
        if IsValidEntity(target) and not target:IsNull() then
        	local slash2 = ParticleManager:CreateParticle("particles/custom/okita/okita_sandan_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        	ParticleManager:SetParticleControl(slash2, 1, target:GetAbsOrigin() + Vector(50,0,120))
	        target:EmitSound("Tsubame_Slash_" .. math.random(1,3))
	        DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
	        --OnTennenAttack(newkeys)
	    end
    end)
    Timers:CreateTimer(delay_duration + 0.4, function()
        if IsValidEntity(target) and not target:IsNull() then
        	local slash3 = ParticleManager:CreateParticle("particles/custom/okita/okita_sandan_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        	ParticleManager:SetParticleControl(slash3, 1, target:GetAbsOrigin() + Vector(0,0,80))
	        target:EmitSound("Tsubame_Focus")
	        DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)
	       -- OnTennenAttack(newkeys)
	    end
    end)
end

function OnCoatStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_coat_of_oaths", {})
	OkitaCheckCombo(caster, ability)
	if caster.Is then 
		HardCleanse(caster)
	else
		RemoveSlowEffect(caster)
	end
end

function OnMindEyeStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration") 
	--OnSeiganStop(keys)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_okita_mind_eye", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_okita_mind_eye_cooldown", {Duration = ability:GetCooldown(1)})
end

function OnMindEyeThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	ProjectileManager:ProjectileDodge(caster)
end

function OnMindEyeTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.attacker
	local distance = ability:GetSpecialValueFor("distance")
	if not target:IsRealHero() then 
		target = target:GetOwnerEntity()
	end
	if caster:GetTeam() ~= target:GetTeam() then
		caster:RemoveModifierByName("modifier_okita_mind_eye")
		caster:SetHealth(caster:GetHealth() + keys.DamageTaken)
		HardCleanse(caster)

		local backvec = -caster:GetForwardVector()
		local dashback = Physics:Unit(caster)
		local origin = caster:GetOrigin()

		caster:PreventDI()
		caster:SetPhysicsFriction(0)

		caster:SetPhysicsVelocity(backvec * distance * 3)
	   	caster:SetNavCollisionType(PHYSICS_NAV_HALT)
	   	StartAnimation(caster, {duration=0.33, activity=ACT_DOTA_CAST_ABILITY_3, rate=2.5})
	   	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.33)
		
		caster:OnPhysicsFrame(function(unit) -- pushback distance check
			local unitOrigin = unit:GetAbsOrigin()
			local diff = unitOrigin - origin
			local n_diff = diff:Normalized()
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
			if diff:Length() > distance or not caster:HasModifier("jump_pause") then -- if pushback distance is over 150, stop it
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				EndAnimation(unit)
				FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			end
		end)
	end
end

function OkitaCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "okita_coat_of_oaths") and not caster:HasModifier("modifier_zekken_cooldown") then
			if caster.IsKikuIchimonjiAcquired then
				if caster:FindAbilityByName("okita_sandanzuki_upgrade"):IsCooldownReady() and caster:FindAbilityByName("okita_zekken_upgrade"):IsCooldownReady() then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_zekken_window", {})	
				end
			else
				if caster:FindAbilityByName("okita_sandanzuki"):IsCooldownReady() and caster:FindAbilityByName("okita_zekken"):IsCooldownReady() then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_zekken_window", {})	
				end
			end
		end
	end
end

function OnZekkenWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsKikuIchimonjiAcquired then
		caster:SwapAbilities("okita_sandanzuki_upgrade", "okita_zekken_upgrade", false, true) 
	else
		caster:SwapAbilities("okita_sandanzuki", "okita_zekken", false, true) 
	end
end

function OnZekkenWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsKikuIchimonjiAcquired then
		caster:SwapAbilities("okita_sandanzuki_upgrade", "okita_zekken_upgrade", true, false) 
	else
		caster:SwapAbilities("okita_sandanzuki", "okita_zekken", true, false) 
	end
end

function OnZekkenWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_zekken_window")
end

function OnZekkenStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local forwardvec = (target_loc - caster:GetAbsOrigin()):Normalized()
	local dash_speed = ability:GetSpecialValueFor("dash_speed")
	local distance = ability:GetSpecialValueFor("distance")
	local exhaust = ability:GetSpecialValueFor("exhaust")
	local interval = ability:GetSpecialValueFor("interval")
	local atk_count = ability:GetSpecialValueFor("atk_count")
	local target_point = caster:GetAbsOrigin() + (forwardvec * distance)
	local duration = distance / dash_speed
	local IsInMarble = false
	caster.ZekkenTarget = nil
	caster.ZekkenSlashBack = nil
	caster.ZekkenSound = nil
	caster.ZekkenOrigin = caster:GetAbsOrigin()
	caster.last_hit_start = nil
	caster.last_hit_distance = 0

	--[[local origindummy = CreateUnitByName("visible_dummy_unit", caster.ZekkenOrigin, false, caster, caster, caster:GetTeamNumber())
    origindummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    origindummy:SetDayTimeVisionRange(0)
    origindummy:SetNightTimeVisionRange(0)]]
    if caster:HasModifier("modifier_alternate_02") then 
		EmitGlobalSound("OkitaAlter.Precombo")
	else
		EmitGlobalSound("Okita.Precombo")
	end
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("okita_zekken")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_zekken_cooldown", {Duration = ability:GetCooldown(1)})

	local mumyo = caster:FindAbilityByName("okita_sandanzuki")
	if mumyo == nil then 
		mumyo = caster:FindAbilityByName("okita_sandanzuki_upgrade")
	end
	mumyo:StartCooldown(mumyo:GetCooldown(mumyo:GetLevel()))

	caster:RemoveModifierByName("modifier_zekken_window")

	local frontvec = (target_loc - caster:GetAbsOrigin()):Normalized()

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_zekken_checker", {Duration = distance / dash_speed})
    StartAnimation(caster, {duration=distance / dash_speed, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.5})

	SetDashParticle(caster, caster:GetAbsOrigin(), frontvec, 1)

	local dash_fx = ParticleManager:CreateParticle("particles/custom/gilgamesh/enuma_elish/cracks_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(dash_fx, 0, caster:GetAbsOrigin())

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.0)

	local okita = Physics:Unit(caster) 
	if caster:IsAlive() then
		caster:SetPhysicsVelocity(caster:GetForwardVector() * dash_speed)
		caster:PreventDI()
	    caster:SetPhysicsFriction(0)
		caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)
	    caster:OnPhysicsFrame(function(unit)
	    	local shadowfx = ParticleManager:CreateParticle( "particles/custom/okita/okita_sandan_shadow.vpcf", PATTACH_ABSORIGIN, caster )
    		ParticleManager:SetParticleControlEnt(shadowfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
    		Timers:CreateTimer(0.5, function()
    			ParticleManager:DestroyParticle(shadowfx, false)
				ParticleManager:ReleaseParticleIndex(shadowfx)
    		end)
			local diff = target_point - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(dir * dash_speed)
			if diff:Length() <= 150 or unit:HasModifier("modifier_zekken") or not unit:HasModifier("modifier_zekken_checker") then
				EndAnimation(unit)
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:OnHibernate(nil)
				unit:SetAutoUnstuck(true)
		        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		        ParticleManager:DestroyParticle(dash_fx, true)
	    		ParticleManager:ReleaseParticleIndex(dash_fx)
	    		if unit:IsAlive() and unit.ZekkenTarget ~= nil then 
	    			if unit:HasModifier("modifier_inside_marble") then 
	    				IsInMarble = true 
	    			end
	    			giveUnitDataDrivenModifier(unit, unit.ZekkenTarget, "pause_sealenabled", interval * atk_count + 1.5)
	    			local center = unit.ZekkenTarget:GetAbsOrigin()
		    		unit:AddEffects(EF_NODRAW)
					local radius = ability:GetSpecialValueFor("radius")
					unit.last_hit_start = center + (forwardvec * radius)
					unit.last_hit_distance = (unit.ZekkenOrigin - unit.last_hit_start):Length2D()
					for i = 1, atk_count do 
						Timers:CreateTimer(i * interval, function()	
							AddExhaust(keys, 2)
							if IsInMarble == true and not unit:HasModifier("modifier_inside_marble") then 
								if (string.match(unit.ZekkenTarget:GetName(), "ember") and unit.ZekkenTarget:HasModifier("modifier_unlimited_bladeworks")) or (string.match(unit.ZekkenTarget:GetName(), "chen") and unit.ZekkenTarget:HasModifier("modifier_army_of_the_king_death_checker")) then 
									center = unit:GetAbsOrigin() 
									unit.ZekkenOrigin = unit:GetAbsOrigin() 
								else
									center = unit.ZekkenTarget:GetAbsOrigin()
								end
								IsInMarble = false 
							end
							local angle = RandomInt(0, 360)
				            local startLoc = GetRotationPoint(center,RandomInt(radius - 200, radius),angle)
				            local endLoc = GetRotationPoint(center,RandomInt(radius - 200, radius),angle + RandomInt(120, 240))
				            local fxIndex = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_tgt_serrakura.vpcf", PATTACH_ABSORIGIN, caster)
				            ParticleManager:SetParticleControl( fxIndex, 0, startLoc + Vector(0,0,RandomInt(100,200)))
				            ParticleManager:SetParticleControl( fxIndex, 1, endLoc + Vector(0,0,RandomInt(100,200)))
				            caster:EmitSound("Tsubame_Slash_" .. math.random(1,3))
							local unitGroup = FindUnitsInRadius(unit:GetTeam(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
				            if i == 15 then 
								unit:RemoveEffects(EF_NODRAW)
								unit.last_hit_start = center + (forwardvec * radius)
								unit:SetAbsOrigin(unit.last_hit_start)
								unit:SetForwardVector(-forwardvec)
								unit:SetAngles(0, 0, 0)
							end
				            for j = 1, #unitGroup do
				            	if #unitGroup ~= 0 then
					                
					                if IsValidEntity(unitGroup[j]) and not unitGroup[j]:IsNull() and not unitGroup[j]:HasModifier("modifier_stunned") and not IsImmuneToCC(unitGroup[j]) then 
					                	ApplyAirborne(unit, unitGroup[j], (atk_count - i) * interval)
					                end
					                unit:PerformAttack( unitGroup[j], true, true, true, true, false, false, true )
					            end
							end
							
						end)
					end

					Timers:CreateTimer(atk_count * interval + 0.5, function()	
						if unit:IsAlive() then
							unit:EmitSound("Tsubame_Focus")							
							local dash_speed = ability:GetSpecialValueFor("dash_speed")
							
							StartAnimation(unit, {duration=unit.last_hit_distance / dash_speed, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.5})
							ability:ApplyDataDrivenModifier(unit, unit, "modifier_zekken_checker", {Duration = unit.last_hit_distance / dash_speed + 0.1})
							local dash_back_speed = 200
							AddExhaust(keys, 10)
							unit:SetPhysicsVelocity(-forwardvec * dash_speed)
							unit:PreventDI()
						    unit:SetPhysicsFriction(0)
							unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
						    unit:FollowNavMesh(false)	
						    unit:SetAutoUnstuck(false)
						    unit:OnPhysicsFrame(function(unit)
						    	if not unit.ZekkenSlashBack then 
						    		CreateSlashFx(unit, unit:GetAbsOrigin() + Vector(0,0,200), unit.ZekkenOrigin + Vector(0,0,200))
						    		unit.ZekkenSlashBack = true 
						    	end
						    	local last_hit_radius = ability:GetSpecialValueFor("last_hit_radius")
								local last_hit_damage = ability:GetSpecialValueFor("last_hit_damage")
								local LastThrustTargets = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, last_hit_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
								for k,v in pairs (LastThrustTargets) do 
									if IsValidEntity(v) and not v:IsNull() and not v:HasModifier("modifier_zekken_checker") then 
										ability:ApplyDataDrivenModifier(unit, v, "modifier_zekken_checker", {})
										v:AddNewModifier(unit, nil, "modifier_stunned", {Duration = 1.0})
										DoDamage(unit, v, last_hit_damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
									end
								end
						    	unit:SetPhysicsVelocity(-forwardvec * dash_back_speed)
						    	if (unit:GetAbsOrigin() - unit.last_hit_start):Length() < 200 then 
						    		dash_back_speed = dash_back_speed + 1000 
							    	if dash_back_speed > dash_speed then 
							    		dash_back_speed = dash_speed
							    		
						    		end
						    	elseif (unit:GetAbsOrigin() - unit.last_hit_start):Length() >= unit.last_hit_distance - 200 and (unit:GetAbsOrigin() - unit.last_hit_start):Length() < unit.last_hit_distance - 50 then 
						    		
						    		dash_back_speed = dash_back_speed - 400
						    		if dash_back_speed < 200 then 
						    			dash_back_speed = 200 
						    		end
						    		local new_forward = (Vector(unit.ZekkenTarget:GetAbsOrigin().x, unit.ZekkenTarget:GetAbsOrigin().y, 0) - Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, 0)):Normalized()
						    		unit:SetForwardVector(new_forward)
						    		unit:SetAngles(0, 0, 0)
						    	elseif (unit:GetAbsOrigin() - unit.last_hit_start):Length() >= unit.last_hit_distance or not unit:HasModifier("modifier_zekken_checker") then 
						    		if not unit.ZekkenSound then 
						    			if unit:HasModifier("modifier_alternate_02") then 
						    				EmitGlobalSound("Okita.Zekken" .. RandomInt(1, 3))
						    			else
							    			EmitGlobalSound("Okita.Zekken1") 
							    		end
							    		unit.ZekkenSound = true 
							    	end
						    		unit:PreventDI(false)
									unit:SetPhysicsVelocity(Vector(0,0,0))
									unit:OnPhysicsFrame(nil)
									unit:OnHibernate(nil)
									unit:SetAutoUnstuck(true)
							        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
							        Timers:CreateTimer(1.0, function()
								        if unit.ZekkenTarget:IsAlive() and unit:IsAlive() and IsInSameRealm(unit:GetAbsOrigin(), unit.ZekkenTarget:GetAbsOrigin()) then  
								        	local newest_forward = (unit.ZekkenTarget:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
								        	local beam_distance = ability:GetSpecialValueFor("beam_distance")
											local beam_radius = ability:GetSpecialValueFor("beam_radius")
											AddExhaust(keys, exhaust - (atk_count * 2) - 10)
								        	local zekken_beam = 
											{
												Ability = ability,
											    --EffectName = "",
											    iMoveSpeed = 5000,
											    vSpawnOrigin = unit:GetAbsOrigin(),
											    fDistance = beam_distance,
											    fStartRadius = beam_radius,
											    fEndRadius = beam_radius,
											    Source = unit,
											    bHasFrontalCone = true,
											    bReplaceExisting = false,
											    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
											    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
											    iUnitTargetType = DOTA_UNIT_TARGET_ALL,
											    fExpireTime = GameRules:GetGameTime() + 2.0,
												bDeleteOnHit = false,
												vVelocity = newest_forward * 5000
											}
											local projectile = ProjectileManager:CreateLinearProjectile(zekken_beam)
											local beam_fx = ParticleManager:CreateParticle("particles/okita/okita_zekken_beam.vpcf", PATTACH_ABSORIGIN, unit)
							    			ParticleManager:SetParticleControl(beam_fx, 0, unit:GetAbsOrigin() + Vector(0,0,100))
							    			ParticleManager:SetParticleControl(beam_fx, 1, unit:GetAbsOrigin() + Vector(0,0,100))
							    			ParticleManager:SetParticleControl(beam_fx, 3, unit:GetAbsOrigin() + newest_forward*beam_distance + Vector(0,0,100))
											--Timers:CreateTimer(0.2, function()
												EmitGlobalSound("karna_vasavi_explosion")
											--end)
											StartAnimation(unit, {duration=(beam_distance / 5000) + 0.2, activity=ACT_DOTA_ATTACK_EVENT, rate=2.0})
											Timers:CreateTimer(beam_distance / 5000 + 0.2, function()
												unit:RemoveModifierByName("jump_pause")
												ParticleManager:DestroyParticle(beam_fx, true)
											end)
										else
											unit:RemoveModifierByName("jump_pause")
											return
										end	
									end)								
								end
							end)
						end
					end)
				else
					unit:RemoveModifierByName("jump_pause")
					return
				end

	    	elseif unit:IsAlive() then 
	    		local FindTarget = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil, 180, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		    	if FindTarget[1] ~= nil then 
		    		unit.ZekkenTarget = FindTarget[1]
		    		ability:ApplyDataDrivenModifier(unit, unit, "modifier_zekken", {Duration = interval * atk_count + 0.5})
		    	end
		    else
		    	unit:RemoveModifierByName("jump_pause")
		    	return
		    end
		end)
	else
		caster:RemoveModifierByName("jump_pause")
		return
	end
end

function OnZekkenBeamHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("okita_zekken_upgrade")
	end
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local beam_damage = ability:GetSpecialValueFor("beam_damage")
	if caster.IsKikuIchimonjiAcquired then
		local beam_kiku_agi_ratio = ability:GetSpecialValueFor("beam_kiku_agi_ratio")
		beam_damage = beam_damage + beam_kiku_agi_ratio * caster:GetAgility() 
	end

	DoDamage(caster, target, beam_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function SetDashParticle(caster, vOrigin, frontvec, duration)
	if duration == nil then 
		duration = 2
	end
	local dummy = CreateUnitByName("visible_dummy_unit", vOrigin, false, caster, caster, caster:GetTeamNumber())
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)
    dummy:SetOrigin(vOrigin - frontvec * 100)
    dummy:SetForwardVector(frontvec)

	local particle1 = ParticleManager:CreateParticle("particles/custom/atalanta/sting/ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
    ParticleManager:SetParticleControlEnt(particle1, 1, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetAbsOrigin(), false)
    ParticleManager:ReleaseParticleIndex(particle1)

    Timers:CreateTimer(duration, function()
		if IsValidEntity(dummy) then
        	dummy:RemoveSelf()
        end
    end)
end

okita_new_e = class({})
okita_new_e_upgrade = class({})

LinkLuaModifier("modifier_okita_flash_tracker", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_okita_beam_cooldown", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_okita_flash_window", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_okita_flash_dash", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_okita_flash_cast", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_okita_flash_dash_cd", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_beam_window", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_beam_ready", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_tennen_agi", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_dash_ready", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_thrust_ready", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_okita_tennen_count", "abilities/okita/okita_abilities", LUA_MODIFIER_MOTION_NONE) 

function okita_flash_wrapper(flash)
	function flash:CheckSequence()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_okita_flash_tracker") then
			local stack = caster:FindModifierByName("modifier_okita_flash_tracker"):GetStackCount()

			return stack
		else
			return 0
		end	
	end

	function flash:GetCastRange(vLocation, hTarget)
		if self:GetCaster():HasModifier("modifier_okita_beam_window") then
			if  self:GetCaster():HasModifier("modifier_okita_beam_ready") then
				return self:GetSpecialValueFor("beam_range")
			else
				return self:GetSpecialValueFor("thrust_range")
			end
		else
			return self:GetSpecialValueFor("leap_range")
		end
	end

	function flash:GetBehavior()
		if self:GetCaster():HasModifier("modifier_okita_beam_window") then
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
		else
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
		end
	end

	function flash:GetManaCost(iLevel)
		if self:GetCaster():HasModifier("modifier_okita_beam_window") and self:GetCaster():HasModifier("modifier_okita_beam_ready") then
			return 200
		else
			return 100
		end
	end

	function flash:GetAbilityTextureName()
		if self:GetCaster():HasModifier("modifier_okita_beam_window") and self:GetCaster():HasModifier("modifier_okita_beam_ready") then
			if self:GetCaster():HasModifier("modifier_alternate_02") then
				return "custom/okita/okita_alter_beam"
			else
				return "custom/okita/okita_beam"
			end
		else
			return "custom/okita/okita_flash"
		end
	end

	function flash:CastFilterResult()
		if self:GetCaster():HasModifier("modifier_okita_beam_window") then
			return UF_SUCCESS
		elseif IsLocked(self:GetCaster()) then
		    return UF_FAIL_CUSTOM
		end
		return UF_SUCCESS
	end

	function flash:GetCustomCastError()
	  	return "#Cannot_Blink"
	end

	function flash:GetCastAnimation()
		if self:GetCaster():HasModifier("modifier_okita_beam_window") then
			return ACT_DOTA_ATTACK_EVENT
		elseif self:CheckSequence() == 0 or self:CheckSequence() == 2 then
			return ACT_DOTA_ATTACK
		elseif self:CheckSequence() == 1 or self:CheckSequence() == 3 then
			return ACT_DOTA_ATTACK2
		elseif self:GetCaster():HasModifier("modifier_okita_dash_ready") then
			return ACT_DOTA_CAST_ABILITY_6
		end
	end

	function flash:OnLastFlash(args)
		self.caster = self:GetCaster()
		local exhaust = self:GetSpecialValueFor("exhaust")
		local keys = {
			caster = self.caster,
			ability = self,
		}
		AddExhaust(keys, exhaust)
		local target_loc = self:GetCursorPosition()
		local direction = (Vector(target_loc.x, target_loc.y, 0) - Vector(self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, 0)):Normalized()

		self.caster:SetForwardVector(direction)

		self.cast_anim = self:GetSpecialValueFor("cast_anim_cd")

		local damage = self:GetSpecialValueFor("thrust_damage")
		if self.caster.IsTennenAcquired then
			self.cast_anim = math.max(self.cast_anim - (self:GetSpecialValueFor("cast_rdr_agi") * self.caster:GetAgility()), 0.2)
			damage = damage * ((1 + (self:GetSpecialValueFor("bonus_damage")/100)) ^ 5)
		end
		
		if self.caster.IsTennenAcquired and not self.caster:HasModifier("modifier_okita_beam_cooldown") then
			local beam_damage = self:GetSpecialValueFor("beam_base_damage") + (self:GetSpecialValueFor("beam_atk_dmg")/100 * self.caster:GetAverageTrueAttackDamage(self.caster)) + (self:GetSpecialValueFor("beam_bonus_agi") * self.caster:GetAgility())
			self:DoBeam(self:GetSpecialValueFor("beam_width"), self:GetSpecialValueFor("beam_range"), beam_damage, direction)
			self.caster:AddNewModifier(self.caster, self, "modifier_okita_beam_cooldown", {Duration = self:GetSpecialValueFor("beam_cooldown")})
		else
			self:DoThrust(self:GetSpecialValueFor("thrust_width"), self:GetSpecialValueFor("thrust_range"), damage, direction)
		end
		self.caster:RemoveModifierByName("modifier_okita_beam_window")
	end

	function flash:OnVectorCastStart(vStartLocation, vDirection)
		if self:GetCaster():HasModifier("modifier_okita_beam_window") then 
			self:OnLastFlash()
			return nil
		else
			if self:GetCaster():HasModifier("modifier_sandanzuki_window") or self:GetCaster():IsRooted() then 
				self:EndCooldown() 
				self:GetCaster():GiveMana(self:GetManaCost(1))
				SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
				return 
			end
			if GridNav:IsBlocked(vStartLocation) or not GridNav:IsTraversable(vStartLocation) then
				self:EndCooldown() 
				self:GetCaster():GiveMana(self:GetManaCost(1))
				SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
				return 
			end
			self.caster = self:GetCaster()
			local exhaust = self:GetSpecialValueFor("exhaust")
			local keys = {
				caster = self.caster,
				ability = self,
			}
			AddExhaust(keys, exhaust)
			local new_forward = (vStartLocation - self.caster:GetAbsOrigin()):Normalized()
			new_forward.z = 0
			SetDashParticle(self.caster, self.caster:GetAbsOrigin(), new_forward, 2)
			local loc = GetGroundPosition(vStartLocation, nil)
			
			vDirection.z = 0
			local angle = VectorToAngles(vDirection)
			print(angle)
			--self.vector_range = self:GetSpecialValueFor("slash_range")

			self.caster:SetAngles(0, angle.y, 0)
			
			self.caster:SetAbsOrigin(loc)  
			self.cast_anim = self:GetSpecialValueFor("cast_anim_cd")
			local damage = self:GetSpecialValueFor("base_damage")
			if self.caster.IsTennenAcquired then
				self.cast_anim = math.max(self.cast_anim - (self:GetSpecialValueFor("cast_rdr_agi") * self.caster:GetAgility()), 0.15)
				damage = damage * ((1 + (self:GetSpecialValueFor("bonus_damage")/100)) ^ self:CheckSequence())
			end

			if self:CheckSequence() <= 3 then
				if self:CheckSequence() == 0 then
					self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_window", {Duration = 18})
					self:DoSlash(self:GetSpecialValueFor("slash_range"), damage, self:GetSpecialValueFor("slash_angle"), 1, vDirection)
				elseif self:CheckSequence() == 2 then
					self:DoSlash(self:GetSpecialValueFor("slash_range"), damage, self:GetSpecialValueFor("slash_angle"), 1, vDirection)
				elseif self:CheckSequence() == 1 or self:CheckSequence() == 3 then
					self:DoSlash(self:GetSpecialValueFor("slash_range"), damage, self:GetSpecialValueFor("slash_angle"), 2, vDirection)
				end
			elseif self:CheckSequence() >= 4 then 
				self:DoDash(self:GetSpecialValueFor("dash_range"), self:GetSpecialValueFor("thrust_width"), damage, vDirection) 
			end

			ProjectileManager:ProjectileDodge(self.caster)
			print("Vector Cast")
		end
		
	end

	function flash:AddSequence()
		if self:CheckSequence() >= 1 then
			if not self.caster:HasModifier("modifier_okita_flash_tracker") then 
				self.caster:RemoveModifierByName("modifier_okita_flash_window")
				return 
			end
		end
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_tracker", {Duration = 2.3})
		self:EndCooldown()
		VectorTarget:UpdateNettable(self)
		local sequence = self.caster:FindModifierByName("modifier_okita_flash_tracker")
		sequence:SetStackCount(math.min(sequence:GetStackCount()+1,6))
		if self.caster.IsTennenAcquired then 
			self.caster:AddNewModifier(self.caster, self, "modifier_okita_tennen_count", {Duration = self:GetSpecialValueFor("tennen_duration"), agi = self:GetSpecialValueFor("bonus_agi")})
			local tennen = self.caster:FindModifierByName("modifier_okita_tennen_count")
			tennen:SetStackCount(math.min(tennen:GetStackCount()+1,6))
		end
	end

	function flash:DoSlash(radius, damage, angle, bRight, direction)
		local slash_angle = 20
		if bRight == 2 then 
			slash_angle = 160
		end 
		local particle = "particles/custom/okita/okita_flash_slash_a.vpcf"

		local hero_angle =  VectorToAngles(direction)

		local slashFx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(slashFx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(slashFx, 1, Vector(radius, slash_angle, hero_angle.y + 90))

		Timers:CreateTimer(self.cast_anim, function()
			ParticleManager:DestroyParticle(slashFx, true)
			ParticleManager:ReleaseParticleIndex(slashFx)
		end)
		self.caster:EmitSound("Hero_Luna.Attack")
		self.caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
		--StartAnimation(self.caster, {duration=self.cast_anim+0.05, activity=anim, rate=3.0})
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_cast", {Duration = self.cast_anim})
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_dash", {Duration = self.cast_anim})
		local slash_hit = 0
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			local dist = (v:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
			if dist <= 150 then 
				slash_hit = slash_hit + 1
				DoDamage(self.caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
			else
				if IsFront(self.caster, v, angle) then
					slash_hit = slash_hit + 1
					DoDamage(self.caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
				end
			end
		end
		if slash_hit >= 1 then 
			if self:CheckSequence() == 3 then 
				self.caster:AddNewModifier(self.caster, self, "modifier_okita_dash_ready", {Duration = 1.8})
				--self.vector_range = self:GetSpecialValueFor("dash_range")
			end
			self:AddSequence()
		else
			self.caster:RemoveModifierByName("modifier_okita_flash_window")
		end
	end

	function flash:DoThrust(width, range, damage, direction)

		--StartAnimation(self.caster, {duration=self.cast_anim+0.05, activity=ACT_DOTA_ATTACK_EVENT, rate=3.0})
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_cast", {Duration = self.cast_anim})
		local slash_hit = 0
		local end_point = self.caster:GetAbsOrigin() + (direction * range)
		local angle = self.caster:GetAnglesAsVector()
		local thrustFx = ParticleManager:CreateParticle("particles/custom/okita/okita_flash_thrust.vpcf", PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(thrustFx, 0, end_point)
		ParticleManager:SetParticleControl(thrustFx, 2, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(thrustFx, 3, Vector(0,0,-angle.y + 90))

		Timers:CreateTimer(math.max(self.cast_anim, 0.25), function()
			ParticleManager:DestroyParticle(thrustFx, true)
			ParticleManager:ReleaseParticleIndex(thrustFx)
		end)
		self.caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
		local targets = FindUnitsInLine(self.caster:GetTeam(), self.caster:GetAbsOrigin(), end_point, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
		for k,v in pairs(targets) do
			print('enemy found')
			slash_hit = slash_hit + 1
			DoDamage(self.caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
			v:AddNewModifier(self.caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("thrust_stun")})
		end
		if slash_hit >= 1 then 
			if self.caster.IsTennenAcquired then 
				self.caster:AddNewModifier(self.caster, self, "modifier_okita_tennen_agi", {Duration = self:GetSpecialValueFor("tennen_duration")})
				local tennen = self.caster:FindModifierByName("modifier_okita_tennen_agi")
				tennen:SetStackCount(math.min(tennen:GetStackCount()+1,6))
			end
		end
		self.caster:RemoveModifierByName("modifier_okita_flash_tracker")
	end

	function flash:DoDash(distance, aoe, damage, direction)
		--StartAnimation(self.caster, {duration=self.cast_anim+0.05, activity=ACT_DOTA_ATTACK_EVENT, rate=3.0})
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_cast", {Duration = self.cast_anim})
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_dash", {Duration = self.cast_anim})
		self.speed = math.abs(math.ceil(distance/self.cast_anim))
		--print('speed = ' .. self.speed)
		self.slash_hit = 0
	 	local okita = Physics:Unit(self.caster) 
	 	self.caster:RemoveModifierByName("modifier_okita_dash_ready")
		if self.caster:IsAlive() then
			self.caster:SetPhysicsVelocity(direction * self.speed)
			self.caster:PreventDI()
		    self.caster:SetPhysicsFriction(0)
			self.caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		    self.caster:FollowNavMesh(false)	
		    self.caster:SetAutoUnstuck(false)
		    self.caster:OnPhysicsFrame(function(unit)
				--[[local diff = target_point - unit:GetAbsOrigin()
				local dir = diff:Normalized()
				unit:SetPhysicsVelocity(dir * dash_speed)]]
				local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if not v:HasModifier("modifier_okita_flash_dash_cd") then
						v:AddNewModifier(self.caster, self, "modifier_okita_flash_dash_cd", {Duration = self.cast_anim})
						self.slash_hit = self.slash_hit + 1
						DoDamage(self.caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
					end
				end
				if not unit:HasModifier("modifier_okita_flash_dash") then 
					unit:PreventDI(false)
					unit:SetBounceMultiplier(0)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					unit:OnHibernate(nil)
					unit:OnPreBounce(nil)
					unit:SetAutoUnstuck(true)
			        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			        --if self.caster.IsTennenAcquired then
				        if self.slash_hit >= 1 then 
							self:AddSequence()
							self.caster:AddNewModifier(self.caster, self, "modifier_okita_beam_window", {Duration = 2.5})
							if self.caster.IsTennenAcquired and not self.caster:HasModifier("modifier_okita_beam_cooldown") and not self.caster:HasModifier("modifier_okita_beam_ready") then 
								self.caster:AddNewModifier(self.caster, self, "modifier_okita_beam_ready", {})
							end
						end
					--end
			    end
			end)
		end
	end

	function flash:DoBeam(width, range, damage, direction)
		self.caster:AddNewModifier(self.caster, self, "modifier_okita_flash_cast", {Duration = self.cast_anim})
		local beam = {
			Ability = self,
	        EffectName = nil, --"particles/custom/false_assassin/fa_quickdraw.vpcf",
	        vSpawnOrigin = self.caster:GetAbsOrigin(),
	        fDistance = range - width + 100,
	        fStartRadius = width,
	        fEndRadius = width,
	        Source = self.caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = true,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	        fExpireTime = GameRules:GetGameTime() + 2.0,
			bDeleteOnHit = false,
			vVelocity = direction * 9999,
			ExtraData = { damage = damage }
		}
		local projectile = ProjectileManager:CreateLinearProjectile(beam)
		self.caster:RemoveModifierByName("modifier_okita_flash_tracker")

		local angle = VectorToAngles(direction).y
		
		local end_point = GetRotationPoint(self.caster:GetAbsOrigin(),range,angle)

		local fx = "particles/custom/okita/okita_seigan_beam.vpcf"

		if self.caster:HasModifier("modifier_alternate_02") then
			fx = "particles/custom/okita/okita_seigan_beam_black.vpcf"
		end

		local seigan_beam = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(seigan_beam, 0, self.caster:GetAbsOrigin() + Vector(0,0,100))
		ParticleManager:SetParticleControl(seigan_beam, 1, end_point + Vector(0,0,100))
		self.caster:EmitSound("Hero_Invoker.EMP.Discharge")

		Timers:CreateTimer(range / 9999 + 0.2, function()
			ParticleManager:DestroyParticle( seigan_beam, false )
			ParticleManager:ReleaseParticleIndex( seigan_beam )
		end)
	end

	function flash:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
		if hTarget == nil then return end

		if not IsValidEntity(hTarget) or hTarget:IsNull() or not hTarget:IsAlive() then return end

		local caster = self:GetCaster()
		local target = hTarget 
		local damage = tData.damage
		print('damage = ' .. damage)
		DoDamage(caster, target, damage , DAMAGE_TYPE_PURE, 0, self, false)
	end

	function flash:GetVectorTargetRange()
		if self:GetCaster():HasModifier("modifier_okita_dash_ready") then 
			return self:GetSpecialValueFor("dash_range")
		else
			return self:GetSpecialValueFor("slash_range") - 60
		end
	end 

	function flash:GetVectorTargetStartRadius()
		return 150
	end 

	function flash:GetVectorTargetEndRadius()
		return self:GetVectorTargetStartRadius()
	end 

	function flash:GetVectorPosition()
		return self.vectorTargetPosition
	end 

	function flash:GetVector2Position() -- world click
		return self.vectorTargetPosition2
	end 

	function flash:GetVectorDirection()
		return self.vectorTargetDirection
	end 

	function flash:UpdateVectorValues()
		--VectorTarget:UpdateNettable(self)
	end

	function flash:IsDualVectorDirection()
		return false
	end

	function flash:IgnoreVectorArrowWidth()
		return false
	end
end

okita_flash_wrapper(okita_new_e)
okita_flash_wrapper(okita_new_e_upgrade)

okita_beam = class({})	

function okita_beam_wrapper(beam)
	function beam:GetCastRange(vLocation, hTarget)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_okita_beam_ready") then 
			return 1000
		else
			return 600
		end
	end

	function beam:GetCastAnimation()
		return ACT_DOTA_ATTACK_EVENT
	end

	function beam:GetManaCost(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_okita_beam_ready") then 
			return 200
		else
			return 100
		end
	end

	function beam:GetAbilityTextureName()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_okita_beam_ready") then 
			if caster:HasModifier("modifier_alternate_02") then
				return "custom/okita/okita_alter_beam"
			else
				return "custom/okita/okita_beam"
			end
		else
			return "custom/okita/okita_flash"
		end
	end

	function beam:OnSpellStart()
		self.caster = self:GetCaster()
		local flash = self.caster:FindAbilityByName(self.caster.ESkill)
		local target_loc = self:GetCursorPosition()
		local new_forward = (target_loc - self.caster:GetAbsOrigin()):Normalized()
		new_forward.z = 0
		flash:OnLastFlash(new_forward)
		--[[self.caster = self:GetCaster()
		local exhaust = self:GetSpecialValueFor("exhaust")
		local keys = {
			caster = self.caster,
			ability = self,
		}
		AddExhaust(keys, exhaust)

		local target_loc = self:GetCursorPosition()
		local new_forward = (target_loc - self.caster):Normalized()
		new_forward.z = 0
		self.caster:SetForwardVector(new_forward)

		self.cast_anim = self:GetSpecialValueFor("cast_anim_cd")

		local damage = self:GetSpecialValueFor("base_damage")
		if self.caster.IsTennenAcquired then
			self.cast_anim = self.cast_anim - (self:GetSpecialValueFor("cast_rdr_agi") * self.caster:GetAgility())
			damage = damage * ((1 + (self:GetSpecialValueFor("bonus_damage")/100)) ^ self:CheckSequence())
		end
		
		if self.caster.IsTennenAcquired and not self.caster:HasModifier("modifier_okita_beam_cooldown") then
			local beam_damage = self:GetSpecialValueFor("beam_base_damage") + (self:GetSpecialValueFor("beam_atk_dmg") * self.caster:GetAverageTrueAttackDamage()) + (self:GetSpecialValueFor("beam_bonus_agi") * self.caster:GetAgility())
			self:DoBeam(self:GetSpecialValueFor("beam_width"), self:GetSpecialValueFor("beam_range"), beam_damage)
			self.caster:AddNewModifier(self.caster, self, "modifier_okita_beam_cooldown", {Duration = self:GetCooldown(5)})
		else
			self:DoThrust(self:GetSpecialValueFor("thrust_width"), self:GetSpecialValueFor("thrust_range"), damage)
		end]]
	end
end

okita_beam_wrapper(okita_beam)

modifier_okita_beam_window = class({})	

function modifier_okita_beam_window:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_beam_window:IsHidden()
	return true 
end

function modifier_okita_beam_window:IsDebuff()
	return false 
end

function modifier_okita_beam_window:RemoveOnDeath()
	return true 
end

if IsServer() then
	--[[function modifier_okita_beam_window:OnCreated(args)
		self.parent = self:GetParent()
		self.parent:SwapAbilities(self.parent.ESkill, "okita_beam", false, true)
	end
	function modifier_okita_beam_window:OnDestroy()
		self.parent:SwapAbilities(self.parent.ESkill, "okita_beam", true, false)
	end]]
end

modifier_okita_flash_window = class({})	

function modifier_okita_flash_window:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_flash_window:IsHidden()
	return true 
end

function modifier_okita_flash_window:IsDebuff()
	return false 
end

function modifier_okita_flash_window:RemoveOnDeath()
	return true 
end

if IsServer() then
	function modifier_okita_flash_window:OnDestroy()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		if self.ability == nil then 
			self.ability = self.parent:FindAbilityByName(self.parent.ESkill)
		end
		local time = self:GetDuration() - self:GetRemainingTime()
		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()) - time)
	end
end

modifier_okita_flash_tracker = class({})	

function modifier_okita_flash_tracker:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_flash_tracker:OnCreated(args)
	--self:SetStackCount(1)
end

function modifier_okita_flash_tracker:OnRefresh(args)
	--self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_okita_flash_tracker:IsHidden()
	return false 
end

function modifier_okita_flash_tracker:IsDebuff()
	return false 
end

if IsServer() then
	function modifier_okita_flash_tracker:OnDestroy()
		self.parent = self:GetParent()
		self.parent:RemoveModifierByName("modifier_okita_flash_window")
		self.ability = self:GetAbility()
		if self.ability == nil then 
			self.ability = self.parent:FindAbilityByName(self.parent.ESkill)
		end
		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
	end
end

function modifier_okita_flash_tracker:RemoveOnDeath()
	return true 
end

modifier_okita_flash_cast = class({})	

function modifier_okita_flash_cast:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_flash_cast:CheckState()
	return { [MODIFIER_STATE_SILENCED] = true,
			 [MODIFIER_STATE_MUTED] = true,
			 [MODIFIER_STATE_DISARMED] = true,
			 [MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_okita_flash_cast:IsHidden()
	return true 
end

function modifier_okita_flash_cast:IsDebuff()
	return true 
end

modifier_okita_flash_dash = class({})	

function modifier_okita_flash_dash:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_flash_dash:CheckState()
	return { [MODIFIER_STATE_INVULNERABLE] = true,
			 [MODIFIER_STATE_UNSELECTABLE] = true,
			 [MODIFIER_STATE_NO_HEALTH_BAR] = true,
			 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_okita_flash_dash:IsHidden()
	return true 
end

function modifier_okita_flash_dash:IsDebuff()
	return true 
end

modifier_okita_flash_dash_cd = class({})	

function modifier_okita_flash_dash_cd:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_flash_dash_cd:IsHidden()
	return true 
end

function modifier_okita_flash_dash_cd:IsDebuff()
	return true 
end

modifier_okita_tennen_count = class({})	

function modifier_okita_tennen_count:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_okita_tennen_count:OnCreated(args)
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_okita_tennen_agi", {Duration = self.ability:GetSpecialValueFor("tennen_duration")})
	end

	function modifier_okita_tennen_count:OnDestroy()
	end

	function modifier_okita_tennen_count:OnRefresh(args)
		if self:GetStackCount() < 6 then
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_okita_tennen_agi", {Duration = self.ability:GetSpecialValueFor("tennen_duration")})
		end
		--self:SetStackCount(self:GetStackCount() + 1)
	end
end

function modifier_okita_tennen_count:IsHidden()
	return false 
end

function modifier_okita_tennen_count:IsDebuff()
	return false 
end

function modifier_okita_tennen_count:GetTexture()
	return "custom/okita/okita_tennen"
end

modifier_okita_tennen_agi = class({})	

function modifier_okita_tennen_agi:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_okita_tennen_agi:OnCreated(args)
end

function modifier_okita_tennen_agi:OnDestroy()
	local total_buff = self:GetParent():GetModifierCount()
	local count = self:GetParent():FindModifierByName("modifier_okita_tennen_count")
	count:SetStackCount(count:GetStackCount() - 1)

	if count == 1 then 
		self:GetParent():RemoveModifierByName("modifier_okita_tennen_count")
	end
end

function modifier_okita_tennen_agi:OnRefresh(args)
	--self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_okita_tennen_agi:IsHidden()
	return true 
end

function modifier_okita_tennen_agi:IsDebuff()
	return false 
end

function modifier_okita_tennen_agi:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_okita_tennen_agi:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_okita_tennen_agi:GetTexture()
	return "custom/okita/okita_tennen"
end

modifier_okita_beam_cooldown = class({})

function modifier_okita_beam_cooldown:OnCreated(args)
	self.parent = self:GetParent()
	if self.parent:HasModifier("modifier_okita_beam_ready") then
		self.parent:RemoveModifierByName("modifier_okita_beam_ready")
	end
end

function modifier_okita_beam_cooldown:OnDestroy()
	self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_okita_beam_ready", {})
end

function modifier_okita_beam_cooldown:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_okita_beam_cooldown:IsHidden()
	return false 
end

function modifier_okita_beam_cooldown:IsDebuff()
	return true 
end 

function modifier_okita_beam_cooldown:GetTexture()
	return "custom/okita/okita_beam"
end

modifier_okita_beam_ready = class({})

function modifier_okita_beam_ready:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_okita_beam_ready:IsHidden()
	return true 
end

function modifier_okita_beam_ready:IsDebuff()
	return false 
end

modifier_okita_dash_ready = class({})

function modifier_okita_dash_ready:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_dash_ready:IsHidden()
	return true 
end

function modifier_okita_dash_ready:IsDebuff()
	return false 
end

modifier_okita_thrust_ready = class({})

function modifier_okita_thrust_ready:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_okita_thrust_ready:IsHidden()
	return true 
end

function modifier_okita_thrust_ready:IsDebuff()
	return false 
end

function OnBeamStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnBeamHit(keys)
	if keys.target == nil then return end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local beam_damage = ability:GetSpecialValueFor("beam_damage")
	if caster.IsKikuIchimonjiAcquired then
		local beam_kiku_agi_ratio = ability:GetSpecialValueFor("beam_kiku_agi_ratio")
		beam_damage = beam_damage + beam_kiku_agi_ratio * caster:GetAgility() 
	end

	DoDamage(caster, target, beam_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnHeadbandAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHeadBandAcquired) then

		hero.IsHeadBandAcquired = true

		UpgradeAttribute(hero, 'okita_flag_of_sincerity', 'okita_flag_of_sincerity_upgrade', true)
		UpgradeAttribute(hero, 'okita_coat_of_oaths', 'okita_coat_of_oaths_upgrade', true)
		hero.WSkill = "okita_coat_of_oaths_upgrade"
		hero.DSkill = "okita_flag_of_sincerity_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMindEyeAcquired(keys)
	local caster = keys.caster
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMindEyeAcquired) then

		hero.IsMindEyeAcquired = true

		if hero.IsPersistenceAcquired then
			hero:SwapAbilities("okita_weak_constitution_upgrade", "okita_mind_eye", false, true)
		else
			hero:SwapAbilities("okita_weak_constitution", "okita_mind_eye", false, true)
		end
		hero.FSkill = "okita_mind_eye"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKikuIchimonjiAcquired(keys)
	local caster = keys.caster
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKikuIchimonjiAcquired) then

		if hero:HasModifier("modifier_zekken_window") then 
			hero:RemoveModifierByName("modifier_zekken_window")
		end

		if hero:HasModifier("modifier_sandanzuki_window") then 
			hero:RemoveModifierByName("modifier_sandanzuki_window")
		end

		hero.IsKikuIchimonjiAcquired = true

		UpgradeAttribute(hero, 'okita_sandanzuki', 'okita_sandanzuki_upgrade', true)
		UpgradeAttribute(hero, 'okita_sandanzuki_charge3', 'okita_sandanzuki_charge3_upgrade', false)
		UpgradeAttribute(hero, 'okita_zekken', 'okita_zekken_upgrade', false)
		hero.RSkill = "okita_sandanzuki_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnPersistenceAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPersistenceAcquired) then

		hero.IsPersistenceAcquired = true
		
		if hero.IsMindEyeAcquired then 
			UpgradeAttribute(hero, 'okita_weak_constitution', 'okita_weak_constitution_upgrade', false)
		else
			UpgradeAttribute(hero, 'okita_weak_constitution', 'okita_weak_constitution_upgrade', true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKyokujiAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKyokujiAcquired) then

		hero.IsKyokujiAcquired = true

		UpgradeAttribute(hero, 'okita_shukuchi', 'okita_shukuchi_upgrade', true)
		hero.QSkill = "okita_shukuchi_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end	

function OnPeerlessAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.PeerlessAcquired) then

		hero.PeerlessAcquired = true

		UpgradeAttribute(hero, 'okita_tennen', 'okita_tennen_upgrade', true)
		UpgradeAttribute(hero, 'okita_hira_seigan', 'okita_hira_seigan_upgrade', true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end		

function OnTennenAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsTennenAcquired) then

		hero.IsTennenAcquired = true

		UpgradeAttribute(hero, 'okita_new_e', 'okita_new_e_upgrade', true)
		hero.ESkill = "okita_new_e_upgrade"
		hero.beam_cooldown = false
		hero:AddNewModifier(hero, nil, "modifier_okita_beam_ready", {})
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end										


	



	



