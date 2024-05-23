
function OnBattleContinuationStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local hp_condition = ability:GetSpecialValueFor("hp_condition")
	local duration = ability:GetSpecialValueFor("duration")
	if caster:GetHealthPercent() > hp_condition then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Condition_Not_Met")
		ability:EndCooldown()
		return 
	end
	if caster.IsProtectionOfFaithAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_battle_continuation_heal", {})
	end

	local PI1 = FxCreator("particles/custom/vlad/vlad_bc_cast.vpcf", PATTACH_CENTER_FOLLOW, caster,0, nil)
  	ParticleManager:SetParticleControlEnt(PI1, 2, caster, PATTACH_CENTER_FOLLOW, nil, caster:GetAbsOrigin(), false)
  	ParticleManager:SetParticleControlEnt(PI1, 3, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
	Timers:CreateTimer(duration + 0.5, function()
    	FxDestroyer(PI1, false)
  	end)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_battle_continuation", {})
	caster:EmitSound("Hero_LifeStealer.Rage")	
end

function OnBattleContinuationCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	caster.BCBuff = FxCreator("particles/custom/vlad/vlad_bc_buff.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
	ParticleManager:SetParticleControlEnt(caster.BCBuff, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
end

function OnBattleContinuationDestroy(keys)
	local caster = keys.caster 
	FxDestroyer(caster.BCBuff, false)
end

function OnBattleContinuationHealCreate(keys)
	local caster = keys.caster
	caster.BCHeal = FxCreator("particles/custom/vlad/vlad_bc_heal.vpcf", PATTACH_CENTER_FOLLOW, caster,2,nil)
end

function OnBattleContinuationHealThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local heal = ability:GetSpecialValueFor("heal")
	local heal_duration = ability:GetSpecialValueFor("heal_duration")
  	caster:ApplyHeal(heal / heal_duration,caster)
end

function OnBattleContinuationHealDestroy(keys)
	local caster = keys.caster
	FxDestroyer(caster.BCHeal, false)
end

function OnBleedAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local count_hit = ability:GetSpecialValueFor("stacks_onhit_melee")
  	if target == caster:GetAttackTarget() and target:IsRealHero() then
  		local bleed_stack = target:GetModifierStackCount("modifier_vlad_bleed", caster) or 0
  		--target:RemoveModifierByName("modifier_vlad_bleed")
  		--[[if ability == nil then 
  			ability = caster:FindAbilityByName("vlad_transfusion_upgrade")
  		end
    	ability:ApplyDataDrivenModifier(caster, target, "modifier_vlad_bleed", {})]]
    	if caster:HasModifier("modifier_vlad_rebellious_intent") then
    		AddBleed(caster,target,2)
    		--target:SetModifierStackCount("modifier_vlad_bleed", caster, bleed_stack + 2)
    	else 
    		AddBleed(caster,target,1)
    		--target:SetModifierStackCount("modifier_vlad_bleed", caster, bleed_stack + 1)
    	end
  	end
end

function OnBleedCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local redraw = false

	--  this stuff is to fix a counter to be redrawing without deleting previous(dirty copying) when enemy bleeding leaves and then enters the vision of vlad
    Timers:CreateTimer(function()
      	if target:HasModifier("modifier_vlad_bleed") then
        	if not caster:CanEntityBeSeenByMyTeam(target) then
        		--print("no redraw?")
        		redraw = true
        	else --if caster:CanEntityBeSeenByMyTeam(target) and redraw then
        		--print("redraw")
        		OnStackCountChanged(caster,target)
        		redraw = false
        	end
        	return 0.1
      	else
        	return nil
      	end
    end)
end

function OnStackCountChanged(caster,target)
    local counter = target:GetModifierStackCount("modifier_vlad_bleed", caster)
    local digit = 0
    if counter > 99 then
      digit = 3
    elseif counter > 9 then
      digit = 2
    else
      digit = 1
    end

    target.bleedCountFX = FxDestroyer(target.bleedCountFX, true)

    target.bleedCountFX = ParticleManager:CreateParticleForPlayer( "particles/custom/vlad/vlad_cl_popup.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, caster:GetPlayerOwner() )

    ParticleManager:SetParticleControlEnt( target.bleedCountFX, 0, target,  PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), false )
    ParticleManager:SetParticleControl( target.bleedCountFX, 1, Vector( 0, counter, 0 ) ) -- 0,counter,0
    ParticleManager:SetParticleControl( target.bleedCountFX, 2, Vector( 30, digit, 0 ) ) --duration, count of digits to draw, 0
    ParticleManager:SetParticleControl( target.bleedCountFX, 3, Vector( 252, 75, 75 ) ) --color
    ParticleManager:SetParticleControl( target.bleedCountFX, 4, Vector( 23,0,0) ) --size/radius, 0 ,0
end

function OnBleedThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if ability == nil then 
		ability = caster:FindAbilityByName("vlad_transfusion_upgrade")
	end
	local dmg = ability:GetSpecialValueFor("bleed_dmg")
	local interval = ability:GetSpecialValueFor("bleed_interval")
	local stack = target:GetModifierStackCount("modifier_vlad_bleed", caster)
	DoDamage(caster, target, dmg * stack, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnBleedDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	target.bleedCountFX = FxDestroyer(target.bleedCountFX , true)
end

function AddBleed(caster,target,stacks)

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local bleed = caster:FindAbilityByName("vlad_transfusion")
	if caster.IsBloodletterAcquired then 
		bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
	end
	local bleed_stack = target:GetModifierStackCount("modifier_vlad_bleed", caster) or 0
	bleed:ApplyDataDrivenModifier(caster, target, "modifier_vlad_bleed", {})
	if IsValidEntity(target) and not target:IsNull() then
		target:SetModifierStackCount("modifier_vlad_bleed", caster, bleed_stack + stacks)
	end
end

function ConsumeBloodPower(caster,stack,duration)
	local bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
	caster:RemoveModifierByName("modifier_transfusion_blood_power")
	bleed:ApplyDataDrivenModifier(caster, caster, "modifier_transfusion_blood_power", {duration = duration})
	caster:SetModifierStackCount("modifier_transfusion_blood_power", caster, stack)
end

function OnBleedSeek(caster)
	local bleedcounter = 0
	LoopOverPlayers(function(player, playerID, playerHero)
	    if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			local modbleed = playerHero:FindModifierByName("modifier_vlad_bleed") or nil
			if modbleed ~= nil then
				bleedcounter = bleedcounter + modbleed:GetStackCount()
			end
	    end
  	end)
	return bleedcounter
end

function OnTransfusionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_transfusion_self", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_transfusion_cooldown", {Duration = ability:GetCooldown(1)})
	caster:EmitSound("Hero_OgreMagi.Bloodlust.Target.FP")
	caster:EmitSound("Hero_DeathProphet.SpiritSiphon.Cast")

	if caster.IsBloodletterAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_impale_window", {})
	end
end

function OnTransfusionThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ability:GetSpecialValueFor("dmg")
	local heal = ability:GetSpecialValueFor("heal")
	local dmg_bonus = ability:GetSpecialValueFor("dmg_bonus")

	local CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge")
	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3")
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2")
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1")
	end
	local Wlevel = CeremonialPurge:GetLevel()
	dmg = dmg + (dmg_bonus * Wlevel)
  	heal = heal +(dmg_bonus * Wlevel)

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	FxDestroyer(caster.SuckOnFX,false)
	caster.SuckOnFX = {}
  	for k,v in pairs(targets) do
  		if IsValidEntity(v) and not v:IsNull() and v:HasModifier("modifier_vlad_bleed") then
  			local count = v:GetModifierStackCount("modifier_vlad_bleed", caster)
  			if count > 0 then
        	    caster:ApplyHeal(heal, caster)
        	    AddBleed(caster,v,-1)
        	    ability:ApplyDataDrivenModifier(caster, v, "modifier_vlad_transfusion_target", {})
        	    DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)

        	    --v:SetModifierStackCount("modifier_vlad_bleed", caster, count - 1)
        	    
        	    caster.SuckOnFX[k] = FxCreator("particles/custom/vlad/vlad_tf_ontarget_drain.vpcf",PATTACH_CENTER_FOLLOW,v,0,nil)
  				ParticleManager:SetParticleControlEnt( caster.SuckOnFX[k], 2, caster,  PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false )
        	    if caster.IsBloodletterAcquired then
        	    	local bloodpower_gain = ability:GetSpecialValueFor("bloodpower_gain") 
        	    	local bloodpower_cap = ability:GetSpecialValueFor("bloodpower_cap")
				  	local currentStack = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
				  	ability:ApplyDataDrivenModifier(caster, caster, "modifier_transfusion_blood_power", {})
				  	caster:SetModifierStackCount("modifier_transfusion_blood_power", caster, math.min(bloodpower_cap, currentStack + bloodpower_gain))
				end
        	else
        		v:RemoveModifierByName("modifier_vlad_bleed")
  			end
  		end
  	end
end

function OnTransfusionDestroy(keys)
	local caster = keys.caster 

	if caster.IsBloodletterAcquired then
		if not caster:HasModifier("modifier_transfusion_blood_power") then 
			caster:RemoveModifierByName("modifier_impale_window")
		end
	end
end

function OnTransfusionDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_vlad_transfusion_self")
	caster:RemoveModifierByName("modifier_transfusion_blood_power")
end

function OnBloodPowerCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster.BloodPower_duration = ability:GetSpecialValueFor("bloodpower_duration")
end

function OnBloodPowerThink(keys)
	local caster = keys.caster 
	caster.BloodPower_duration = caster.BloodPower_duration - 1 
end

function OnImpaleWindowStart(keys)
	local caster = keys.caster 
	caster:SwapAbilities("vlad_transfusion_upgrade", "vlad_impale", false, true)
end

function OnImpaleWindowDestroy(keys)
	local caster = keys.caster 
	caster:SwapAbilities("vlad_transfusion_upgrade", "vlad_impale", true, false)
end

function OnImpaleWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_impale_window")
end

function OnImpaleStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local stun_min = ability:GetSpecialValueFor("stun_min")
  	local stun_gain = ability:GetSpecialValueFor("stun_gain")
  	local stun_max = ability:GetSpecialValueFor("stun_max")
  	local damage = ability:GetSpecialValueFor("damage")
  	local dmg_gain = ability:GetSpecialValueFor("dmg_gain")
  	local delay = ability:GetSpecialValueFor("delay")
  	local radius_min = ability:GetSpecialValueFor("radius_min")
  	local radius_gain = ability:GetSpecialValueFor("radius_gain")
  	local radius_max = ability:GetSpecialValueFor("radius_max")
  	local bonus_bleed_stack = ability:GetSpecialValueFor("bonus_bleed_stack")
  	local point = ability:GetCursorPosition()

  	caster:RemoveModifierByName("modifier_vlad_transfusion_self")
  	caster:RemoveModifierByName("modifier_impale_window")

  	local bloodpower = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
  	caster:RemoveModifierByName("modifier_transfusion_blood_power")

  	local stun = math.max(stun_min, math.min(stun_min + (bloodpower * stun_gain), stun_max))
  	local radius = math.max(radius_min, math.min(radius_min + (bloodpower * radius_gain), radius_max))

  	local groundFX = ParticleManager:CreateParticle("particles/custom/vlad/vlad_ip_prespike.vpcf", PATTACH_CUSTOMORIGIN, caster)
  	ParticleManager:SetParticleControl(groundFX,0,point)
  	ParticleManager:SetParticleControl(groundFX,3,point)
  	ParticleManager:SetParticleControl(groundFX,4,Vector(radius, 0, 0))

  	local spikeFX = ParticleManager:CreateParticle("particles/custom/vlad/vlad_combo_ontarget_stun.vpcf", PATTACH_CUSTOMORIGIN, caster)
  	ParticleManager:SetParticleControl(spikeFX,0,point)

  	Timers:CreateTimer(delay, function()
	    local impaleFX1 = {}
	    local impaleFX2 = {}
	    local targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	    
	    if #targets ~= 0 then
	      	targets[1]:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	      	targets[1]:EmitSound("Hero_Leshrac.Split_Earth")
	    end

	    for k,v in pairs(targets) do
	    	if IsValidEntity(v) and not v:IsNull() then
		      	impaleFX1[k] = FxCreator("particles/custom/vlad/vlad_impale_bleed.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, 0, nil)
	  			ParticleManager:SetParticleControlEnt(impaleFX1[k], 1, v, PATTACH_ABSORIGIN_FOLLOW	, nil, v:GetAbsOrigin(), false)
	  
	  			impaleFX2[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget.vpcf", PATTACH_ABSORIGIN, v, 0, nil)
	  			ParticleManager:SetParticleControl(impaleFX2[k],4, Vector(2.7, 0, 0))

	  			if v:IsRealHero() then	
		      		AddBleed(caster,v,bonus_bleed_stack)
				end
				if not IsImmuneToCC(v) and not v:IsMagicImmune() then
					v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
				end

		      	DoDamage(caster, v, damage + (bloodpower * dmg_gain), DAMAGE_TYPE_MAGICAL, 0, ability, false)
		    end
	    end
	    
	end)

	Timers:CreateTimer(3, function()
	    FxDestroyer(spikeFX, false)
	    FxDestroyer(groundFX,false)
	    FxDestroyer(impaleFX1,false)
	    FxDestroyer(impaleFX2,false)
	end)
end

function OnRebelliousIntentToggle(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_rebellious_intent", {})
	VladCheckCombo(caster,ability)
end 

function OnRebelliousIntentToggleOff(keys)
	local caster = keys.caster 
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_vlad_rebellious_intent")
	VladCheckCombo(caster,ability)
end

function OnRebelliousIntentCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local str_per_stack = ability:GetSpecialValueFor("str_per_stack")
	local stacks_interval = ability:GetSpecialValueFor("stacks_interval") / 10
	caster.rebelstack = 0
	--print("rebel stack = " .. caster.rebelstack)
	Timers:CreateTimer(function()
		if caster.rebelstack < max_stacks and caster:HasModifier("modifier_vlad_rebellious_intent") then 
			caster:SetModifierStackCount("modifier_vlad_rebellious_intent", caster, caster.rebelstack + 1)
			caster.rebelstack = caster.rebelstack + 1
			caster:CalculateStatBonus(true)
			--print("rebel stack = " .. caster.rebelstack)
			local current_hp = caster:GetHealth()
			local max_hp = caster:GetMaxHealth()
			local difference_to_heal = ((current_hp + 15 * str_per_stack) / (max_hp + 15 * str_per_stack)) * max_hp - current_hp
			caster:ApplyHeal(difference_to_heal,caster)
			return stacks_interval
		else
			return nil 
		end
	end)
end

function OnRebelliousIntentDrain (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local drain_interval = ability:GetSpecialValueFor("drain_interval")
	local drain_per_sec = ability:GetSpecialValueFor("drain_per_sec") / 100
	local stack = caster:GetModifierStackCount("modifier_vlad_rebellious_intent", caster) or 0 
	if caster.rebelstack == max_stacks then 
		--[[local new_hp = caster:GetHealth() - (drain_per_sec * caster:GetMaxHealth() * drain_interval)

    	if new_hp < 1 then
    		new_hp = 1
    	end]]
    	caster:SetHealth(math.max(1, caster:GetHealth() - (drain_per_sec * caster:GetMaxHealth() * drain_interval)))
    end
end
	
function OnRebelliousIntentDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if not caster:IsAlive() then return end
	
	local str_per_stack = ability:GetSpecialValueFor("str_per_stack")
	caster:CalculateStatBonus(true)
	for i = 1, caster.rebelstack - 1 do
		local current_hp = caster:GetHealth()
        local max_hp = caster:GetMaxHealth()
        local difference_to_subtract = ((caster:GetHealth() + 15 * str_per_stack) / (caster:GetMaxHealth() + 15 * str_per_stack)) * caster:GetMaxHealth() - caster:GetHealth()
        --[[local new_hp = current_hp - difference_to_subtract
        if new_hp < 1 then
          new_hp = 1
        end]]
        caster:SetHealth(math.max(1, caster:GetHealth() - difference_to_subtract))
    end
end 

function OnRebelliousIntentDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_vlad_rebellious_intent")
end

function OnCeremonialPurgeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local delay = ability:GetSpecialValueFor("delay")
	local aoe_inner = ability:GetSpecialValueFor("aoe_inner")
	local aoe_outer = ability:GetSpecialValueFor("aoe_outer")
	local stun_inner = ability:GetSpecialValueFor("stun_inner")
	local stun_outer = ability:GetSpecialValueFor("stun_outer")
	local slow_duration = ability:GetSpecialValueFor("slow_duration")
	local dmg_inner = ability:GetSpecialValueFor("dmg_inner")
	local dmg_outer = ability:GetSpecialValueFor("dmg_outer")
	local hp_cost = ability:GetSpecialValueFor("hp_cost")
	local bleed_stack_inner = ability:GetSpecialValueFor("bleed_stack_inner")
	local bleed_stack_outer = ability:GetSpecialValueFor("bleed_stack_outer")
	local hp_max = caster:GetMaxHealth()
	local hp_current = caster:GetHealth() - (hp_max * hp_cost / 100)
	local bonus_dmg_bleed = 0

	if caster.IsImproveImpalingAcquired then 
		local bonus_dmg_per_bleed = ability:GetSpecialValueFor("bonus_dmg_per_bleed")
		local bleedcounter = OnBleedSeek(caster)
		bonus_dmg_bleed = bonus_dmg_per_bleed * bleedcounter
	end

	if caster.IsBloodletterAcquired then
		if not caster:HasModifier("modifier_vlad_transfusion_self") then 
			--caster:RemoveModifierByName("modifier_impale_window")
			if caster:HasModifier("modifier_transfusion_blood_power") then
				local bloodpower = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
				local bloodpowerduration = caster.BloodPower_duration
				local bonus_dmg_per_bloodpower = ability:GetSpecialValueFor("bonus_dmg_per_bloodpower") / 100
				local bloodpowercap = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("bloodpower_cap")
				local bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
				dmg_inner = dmg_inner + math.min(dmg_inner * bloodpower * bonus_dmg_per_bloodpower, dmg_inner * bloodpowercap * bonus_dmg_per_bloodpower)
				dmg_outer = dmg_outer + math.min(dmg_outer * bloodpower * bonus_dmg_per_bloodpower, dmg_outer * bloodpowercap * bonus_dmg_per_bloodpower)
				--[[if bloodpower > bloodpowercap then 
					ConsumeBloodPower(caster,bloodpower - bloodpowercap,bloodpowerduration)
				else 
					caster:RemoveModifierByName("modifier_transfusion_blood_power")
				end]]
			end
		end
	end

	if caster:IsAlive() then
		if hp_current > 1 then
			caster:SetHealth(hp_current)
		else
			caster:SetHealth(1)
		end
		
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.5})
		local CPSpin = FxCreator("particles/custom/vlad/vlad_cp_spin.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, 2, nil)
		ParticleManager:SetParticleControlEnt(CPSpin, 1, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max", caster:GetAbsOrigin(),false)
		if caster:HasModifier('modifier_alternate_01') then 
			ParticleManager:SetParticleControlEnt(CPSpin, 3, caster, PATTACH_POINT_FOLLOW	, "attach_lance_tip-1", caster:GetAbsOrigin(),false)
		else
			ParticleManager:SetParticleControlEnt(CPSpin, 3, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max-1", caster:GetAbsOrigin(),false)
		end
		ParticleManager:SetParticleControlEnt(CPSpin, 8, caster, PATTACH_POINT_FOLLOW	, "attach_lance_tip-1", caster:GetAbsOrigin(),false)

		Timers:CreateTimer(4, function()
		 	FxDestroyer(CPSpin, false)
		end)

	  	caster:EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")
		caster:EmitSound("Hero_Magnataur.ReversePolarity.Anim")

	  	giveUnitDataDrivenModifier(caster, caster, "drag_pause",0.5)
		Timers:CreateTimer(delay - ability:GetCastPoint(), function()
			local targets_outer = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_outer, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
			--[[ alternate way to pick which targets are in which aoe if some issues
			local targets_inner = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_inner, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
			for k,v in pairs(targets_outer) do
				if targets_inner[k] == v then
				(...)
			--]]
			for k,v in pairs(targets_outer) do
				if IsValidEntity(v) and not v:IsNull() then
					local distance = (v:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
					if distance < aoe_inner then
						DoDamage(caster, v, dmg_inner + bonus_dmg_bleed, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						if not IsImmuneToCC(v) then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun_inner })
						end
						if v:IsRealHero() then	
							AddBleed(caster,v,bleed_stack_inner)
						end	
					else
						DoDamage(caster, v, dmg_outer + bonus_dmg_bleed, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						if not IsImmuneToSlow(v) then
							ability:ApplyDataDrivenModifier(caster, v, "modifier_ceremonial_purge_slow", {})
						end
						if not IsImmuneToCC(v) then
		       				v:AddNewModifier(caster, nil, "modifier_stunned", { Duration = stun_outer })
		       			end
		       			if v:IsRealHero() then	
		       				AddBleed(caster,v,bleed_stack_outer)
						end	
						v:SetModifierStackCount("modifier_ceremonial_purge_slow", caster, bleed_stack)
					end
				end
			end
			if targets_outer[1] ~= nil then 
				targets_outer[1]:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end
		end)
	end
end

function OnCeremonialPurgeSlowCreate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	target:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
	target.CPSlowFx = FxCreator("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, 0, nil)
end 

function OnCeremonialPurgeSlowThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target 
	local stacks = target:GetModifierStackCount("modifier_ceremonial_purge_slow", caster)
	if stacks > 10 then
		target:SetModifierStackCount("modifier_ceremonial_purge_slow", caster, math.max(math.floor(stacks/2),6))
    elseif stacks > 5 then
    	target:SetModifierStackCount("modifier_ceremonial_purge_slow", caster, stacks-3)
    else
      	target:SetModifierStackCount("modifier_ceremonial_purge_slow", caster, stacks-1)
    end
    if target:GetModifierStackCount("modifier_ceremonial_purge_slow", caster) <= 0 then
      	target:RemoveModifierByName("modifier_ceremonial_purge_slow")
    end
end 

function OnCeremonialPurgeDestroy(keys)
	local caster = keys.caster
	local target = keys.target 
	FxDestroyer(target.CPSlowFx, false)
end

function OnCeremonialPurgeThink(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local free_mana = ability:GetSpecialValueFor("free_mana")
	local bonus_free_mana = ability:GetSpecialValueFor("bonus_free_mana")
	local currentHP = caster:GetHealthPercent()
	if not caster:IsAlive() then return end
	if caster.IsImproveImpalingAcquired then 
		free_mana = free_mana + bonus_free_mana 
	end
	if not caster:HasModifier("modifier_vlad_combo_window") then
		if math.ceil(currentHP) <= free_mana then
			if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_3_no_mana" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_3_no_mana", "vlad_ceremonial_purge_upgrade_3", true, false)
				end
			elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_2_no_mana" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_2_no_mana", "vlad_ceremonial_purge_upgrade_2", true, false)
				end
			elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_1_no_mana" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_1_no_mana", "vlad_ceremonial_purge_upgrade_1", true, false)
				end
			elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_no_mana" then 
					caster:SwapAbilities("vlad_ceremonial_purge_no_mana", "vlad_ceremonial_purge", true, false)
				end
			end 
		elseif currentHP > free_mana then
			if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_3" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_3_no_mana", "vlad_ceremonial_purge_upgrade_3", false, true)
				end
			elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_2" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_2_no_mana", "vlad_ceremonial_purge_upgrade_2", false, true)
				end
			elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge_upgrade_1" then 
					caster:SwapAbilities("vlad_ceremonial_purge_upgrade_1_no_mana", "vlad_ceremonial_purge_upgrade_1", false, true)
				end
			elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
				if caster:GetAbilityByIndex(1):GetAbilityName() ~= "vlad_ceremonial_purge" then 
					caster:SwapAbilities("vlad_ceremonial_purge_no_mana", "vlad_ceremonial_purge", false, true)
				end
			end 
		end
	end
end

function OnCeremonialPurgeCD(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3_no_mana"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2_no_mana"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1_no_mana"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		caster:FindAbilityByName("vlad_ceremonial_purge"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
		caster:FindAbilityByName("vlad_ceremonial_purge_no_mana"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end 
end

function OnCeremonialPurgeUpgrade(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		if ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_3" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3_no_mana"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3_no_mana"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_3_no_mana" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3"):SetLevel(ability:GetLevel())
			end
		end
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		if ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_2" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2_no_mana"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2_no_mana"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_2_no_mana" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2"):SetLevel(ability:GetLevel())
			end
		end
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		if ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_1" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1_no_mana"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1_no_mana"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "vlad_ceremonial_purge_upgrade_1_no_mana" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1"):SetLevel(ability:GetLevel())
			end
		end
	elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		if ability:GetAbilityName() == "vlad_ceremonial_purge" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge_no_mana"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge_no_mana"):SetLevel(ability:GetLevel())
			end
		elseif ability:GetAbilityName() == "vlad_ceremonial_purge_no_mana" then 
			if ability:GetLevel() ~= caster:FindAbilityByName("vlad_ceremonial_purge"):GetLevel() then
				caster:FindAbilityByName("vlad_ceremonial_purge"):SetLevel(ability:GetLevel())
			end
		end
	end
end

function OnCurseLanceStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local hp_cost = ability:GetSpecialValueFor("hp_cost")
	local hp_current = caster:GetHealth()
	local hp_max = caster:GetMaxHealth()
	hp_current = hp_current - (hp_max * hp_cost / 100)

	if caster:IsAlive() then
  		if hp_current > 1 then
  			caster:SetHealth(hp_current)
  		else
  			caster:SetHealth(1)
  		end  		

  		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cursed_lance_shield", {})

  		VladCheckCombo(caster,ability)
  		if caster.IsInstantCurseAcquired then 
  			ability:ApplyDataDrivenModifier(caster, caster, "modifier_instant_cursed_window", {})
  		end
  	end
end

function OnCurseLanceCreate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_shield = ability:GetSpecialValueFor("max_shield")
	local max_dmg = ability:GetSpecialValueFor("max_dmg")
	local duration = ability:GetSpecialValueFor("duration")

	if caster.IsInstantCurseAcquired then
		local bleedcounter = OnBleedSeek(caster)
		local bonus_shield_per_bleed = ability:GetSpecialValueFor("bonus_shield_per_bleed")
		local bonus_dmg_per_bleed = ability:GetSpecialValueFor("bonus_dmg_per_bleed")
		max_shield = max_shield + (bleedcounter * bonus_shield_per_bleed)
		max_dmg = max_dmg + (bleedcounter * bonus_dmg_per_bleed)
	end

	if caster.IsBloodletterAcquired then
		if not caster:HasModifier("modifier_vlad_transfusion_self") then 
			--caster:RemoveModifierByName("modifier_impale_window")
			if caster:HasModifier("modifier_transfusion_blood_power") then
				local bloodpower = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
				local bloodpowerduration = caster.BloodPower_duration
				local bonus_shield_per_bloodpower = ability:GetSpecialValueFor("bonus_dmg_per_bloodpower") / 100
				local bonus_dmg_per_bloodpower = ability:GetSpecialValueFor("bonus_dmg_per_bloodpower") / 100
				local bloodpowercap = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("bloodpower_cap")
				local bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
				max_shield = max_shield + math.min(max_shield * bloodpower * bonus_shield_per_bloodpower, max_shield * bloodpowercap * bonus_shield_per_bloodpower)
				max_dmg = max_dmg + math.min(max_dmg * bloodpower * bonus_dmg_per_bloodpower, max_dmg * bloodpowercap * bonus_dmg_per_bloodpower)
				--[[if bloodpower > bloodpowercap then 
					ConsumeBloodPower(caster,bloodpower - bloodpowercap,bloodpowerduration)
				else 
					caster:RemoveModifierByName("modifier_transfusion_blood_power")
				end]]
			end
		end
	end

	caster.CurseShieldAmount = max_shield
	caster.CurseMaxShield = max_shield
	caster.CurseMaxDamage = max_dmg
	caster.CurseShieldDuration = duration
	caster.cl_timer_tick = 0
	caster:EmitSound("hero_bloodseeker.rupture.cast")
	if caster.CLShield1 == nil then 
	else
		caster.CLShield1 = FxDestroyer(caster.CLShield1, false)
		caster.CLShield2 = FxDestroyer(caster.CLShield2, false)
	end
	caster.CLShield1 = FxCreator("particles/custom/vlad/vlad_cl_shield.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
	caster.CLShield2 = FxCreator("particles/custom/vlad/vlad_cl_shield2.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
end

function OnCurseLanceThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local aoe = ability:GetSpecialValueFor("aoe") 
	caster.CurseShieldDuration = caster.CurseShieldDuration - 1

	local dmg_counter = math.floor(((caster.CurseMaxShield - (caster.CurseShieldAmount or 0))/caster.CurseMaxShield)*(caster.CurseMaxDamage))
	--print("PAINTER VALUES ARE : "..dmg_counter.."    "..self.CL_SHIELDLEFT.."     ".. self.CL_MAX_SHIELD.."     ".. self.CL_MAX_DMG)
	local digit = 0
	if dmg_counter > 999 then
		digit = 4
	elseif dmg_counter > 99 then
		digit = 3
	elseif dmg_counter > 9 then
		digit = 2
	else
		digit = 1
		if dmg_counter == 0 then
			dmg_counter = 5200 --hacky and clean way (i guess?) to draw 0 ONCE without making code spaghetti ---- dont use dmg_counter for anything else if this is enabled
		end
	end
	FxDestroyer(caster.CLCountPopup, true)

	caster.CLCountPopup = ParticleManager:CreateParticleForPlayer( "particles/custom/vlad/vlad_cl_popup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster, caster:GetPlayerOwner() )

	ParticleManager:SetParticleControlEnt( caster.CLCountPopup, 0, caster,  PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false )
	ParticleManager:SetParticleControl( caster.CLCountPopup, 1, Vector( 0, dmg_counter, 0 ) )  -- 0,counter,0
	ParticleManager:SetParticleControl( caster.CLCountPopup, 2, Vector( 10, digit, 0 ) ) --duration, count of digits to draw, 0
	ParticleManager:SetParticleControl( caster.CLCountPopup, 3, Vector( 252, 75, 75 ) )--color
	ParticleManager:SetParticleControl( caster.CLCountPopup, 4, Vector( 30,0,0) ) --size/radius, 0 ,0

	if caster.CLIndicator == nil and caster.CurseShieldAmount <= 0 then 
		FxDestroyer(caster.CLShield2,false)
		caster.CLIndicator = ParticleManager:CreateParticleForTeam( "particles/custom/vlad/vlad_cl_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber())
		ParticleManager:SetParticleControlEnt( caster.CLIndicator, 0, caster,  PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false )
		ParticleManager:SetParticleControl( caster.CLIndicator, 1, Vector( aoe+50, 0, 0 ) )
	end

	if caster.CLExpire == nil and caster.CurseShieldDuration < 3  and max_shield ~= caster.CurseShieldAmount then --self.CL_SHIELDLEFT ~= self.CL_MAX_SHIELD and
		caster.CLExpire = FxCreator("particles/custom/vlad/vlad_cl_expiring.vpcf",PATTACH_POINT_FOLLOW,caster,3,"attach_hitloc")
		Timers:CreateTimer(function()
			if caster:HasModifier("modifier_cursed_lance_shield") then
				caster.cl_timer_tick = caster.cl_timer_tick + 1
				local cp_adjust = (9 + caster.cl_timer_tick - caster.CurseShieldDuration)/7
				local cp_vector = Vector(cp_adjust, cp_adjust/1.1, 1 )
				ParticleManager:SetParticleControl( caster.CLExpire, 4,  cp_vector)
				return 0.1
			else
				return nil
			end
		end)
	end
end

function OnCurseLanceTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.CurseShieldAmount ~= 0 then 
		local hp_current = caster:GetHealth()
		local damage = keys.DamageTaken
		caster.CurseShieldAmount = caster.CurseShieldAmount - damage
		if caster.CurseShieldAmount  <= 0 then
			if not (hp_current + caster.CurseShieldAmount <= 0) then
				if not caster.IsInstantCurseAcquired then
					caster:RemoveModifierByName("modifier_cursed_lance_shield")
				end
				caster:SetHealth(hp_current + caster.CurseShieldAmount + damage)
				caster.CurseShieldAmount = 0
			end
		else
			caster:SetHealth(hp_current + damage)
		end
	end
end

function OnCurseLanceDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ((caster.CurseMaxShield - math.max(caster.CurseShieldAmount or 0,0))/caster.CurseMaxShield)*(caster.CurseMaxDamage)
	if dmg > 0 then
		local CLPreExplosionFX = FxCreator("particles/custom/vlad/vlad_cl_preexplosion.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
		ParticleManager:SetParticleControlEnt( CLPreExplosionFX, 1, caster,  PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false )
		Timers:CreateTimer(0.3, function()
			local CLExplosionFX = FxCreator("particles/custom/vlad/vlad_cl_explosion.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
			ParticleManager:SetParticleControlEnt( CLExplosionFX, 1, caster,  PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false )
			ParticleManager:SetParticleControlEnt( CLExplosionFX, 3, caster,  PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false )
			caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
			caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
			Timers:CreateTimer(0.15, function()
				local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
			  		DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			end)
		end)
	end

	FxDestroyer(caster.CLCountPopup, true)
	FxDestroyer(caster.CLShield1, false)
	FxDestroyer(caster.CLShield2, false)
	FxDestroyer(caster.CLIndicator, true)
	FxDestroyer(caster.CLExpire, false)
	Timers:CreateTimer(1, function()
		FxDestroyer(CLPreExplosionFX, false)
		FxDestroyer(CLExplosionFX, false)
	end)
	if caster:HasModifier("modifier_instant_cursed_window") then
		caster:RemoveModifierByName("modifier_instant_cursed_window")
	end
end

function OnCurseLanceDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_cursed_lance_shield")
	caster:RemoveModifierByName("modifier_instant_cursed_window")
end

function OnInstantCurseStart(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_cursed_lance_shield")
	caster:RemoveModifierByName("modifier_instant_cursed_window")
end

function OnInstantCurseWindowStart(keys)
	local caster = keys.caster 
	if caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_cursed_lance_upgrade_3", "vlad_instant_curse", false, true)
	else
		caster:SwapAbilities("vlad_cursed_lance_upgrade_1", "vlad_instant_curse", false, true)
	end
	caster:FindAbilityByName("vlad_instant_curse"):StartCooldown(0.75)
end

function OnInstantCurseWindowDestroy(keys)
	local caster = keys.caster 
	if caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_cursed_lance_upgrade_3", "vlad_instant_curse", true, false)
	else
		caster:SwapAbilities("vlad_cursed_lance_upgrade_1", "vlad_instant_curse", true, false)
	end
end

function OnInstantCurseWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_instant_cursed_window")
end

function OnKazikliBeyStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local aoe_spikes = ability:GetSpecialValueFor("aoe_spikes")
	local aoe_lastspike = ability:GetSpecialValueFor("aoe_lastspike")
	local dmg_spikes = ability:GetSpecialValueFor("dmg_spikes")
	local dmg_lastspike = ability:GetSpecialValueFor("dmg_lastspike")
	local lastspike_bleed_stack = ability:GetSpecialValueFor("lastspike_bleed_stack")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local stun = ability:GetSpecialValueFor("stun")
	local activation = ability:GetSpecialValueFor("activation")
	local endcast_pause = ability:GetSpecialValueFor("endcast_pause")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local hitcounter = 1

	if caster.IsImproveImpalingAcquired then
		local bonus_dmg_per_bleed = ability:GetSpecialValueFor("bonus_dmg_per_bleed")
		local bleedcounter = OnBleedSeek(caster)
		dmg_lastspike = dmg_lastspike + (bleedcounter * bonus_dmg_per_bleed)
	end

	--check how many bloodpower stacks vlad has at start of cast and save number
	if caster.IsBloodletterAcquired then
		if not caster:HasModifier("modifier_vlad_transfusion_self") then 
			--caster:RemoveModifierByName("modifier_impale_window")
			if caster:HasModifier("modifier_transfusion_blood_power") then
				local bloodpower = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
				local bloodpowerduration = caster.BloodPower_duration
				local bonus_dmg_per_bloodpower = ability:GetSpecialValueFor("bonus_dmg_per_bloodpower") / 100
				local bloodpowercap = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("bloodpower_cap")
				local bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
				dmg_lastspike = dmg_lastspike + math.min(dmg_lastspike * bloodpower * bonus_dmg_per_bloodpower, dmg_lastspike * bloodpowercap * bonus_dmg_per_bloodpower)
				--[[if bloodpower > bloodpowercap then 
					ConsumeBloodPower(caster,bloodpower - bloodpowercap,bloodpowerduration)
				else 
					caster:RemoveModifierByName("modifier_transfusion_blood_power")
				end]]
			end
		end
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.99 + endcast_pause) -- 2.66 is ideal time if there is to be no endcast pause, for current values of activation and interval
	StartAnimation(caster, {duration = 2.4, activity = ACT_DOTA_CAST_ABILITY_4, rate = 0.4 })
	local PI4 = FxCreator("particles/custom/vlad/vlad_kb_hold.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster,0,nil)
	local PI5 = FxCreator("particles/custom/vlad/vlad_kb_hold_swirl.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
	ParticleManager:SetParticleControlEnt(PI5, 5, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(PI5, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(PI5, 7, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

	Timers:CreateTimer(activation - ability:GetCastPoint(),function()
		if caster:IsAlive() then
			--FX stuff
			if (hitcounter % 2) == 0 then
				caster:EmitSound("Hero_Lycan.Attack")
			else
				caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end

			if hitcounter == total_hit - 3 then
				if caster:HasModifier("modifier_alternate_01") then 
					EmitGlobalSound("ApoVlad.KB")
				else
					EmitGlobalSound("Vlad.KB")
				end
			elseif hitcounter == total_hit - 2 then
				local PI1 = {}
				local targets2 = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_lastspike, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets2) do
					if IsValidEntity(v) and not v:IsNull() then
						PI1[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget_prespike.vpcf", PATTACH_ABSORIGIN_FOLLOW, v,0,nil)
						ParticleManager:SetParticleControlEnt(PI1[k], 3, caster, PATTACH_POINT_FOLLOW	, "attach_hitloc", caster:GetAbsOrigin(),false)
					end
				end
			end

			--last strike
			if hitcounter == total_hit then
				local PI2 = {}
				local PI3 = {}
				local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
			  	dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
			  	dummy:SetDayTimeVisionRange(0)
			  	dummy:SetNightTimeVisionRange(0)
			  	dummy:SetAbsOrigin(caster:GetAbsOrigin())--]]
				
				FxDestroyer(PI4, false)--destroy vfx1
				FxDestroyer(PI5, false)
				local PI1 = ParticleManager:CreateParticle("particles/custom/vlad/vlad_kb_spikesend.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(PI1, 0, caster:GetAbsOrigin() + Vector(0,0,20))

				Timers:CreateTimer(2, function()
					FxDestroyer(PI1, false)
					if IsValidEntity(dummy) then
			    		dummy:RemoveSelf()
			    	end
			  	end)
        		caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
				ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 1500, 0, true)
				
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_lastspike, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for k,v in pairs(lasthitTargets) do
			        if IsValidEntity(v) and not v:IsNull() and v:GetName() ~= "npc_dota_ward_base" then
			        	if not v:IsMagicImmune() then
				        	v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
				  			if caster.IsImproveImpalingAcquired then
				  				giveUnitDataDrivenModifier(caster, v, "revoked", stun)
				  			end
				  			ApplyAirborneOnly(v, 2000, stun)

				        	if v:IsRealHero() then	
				        		AddBleed(caster,v,lastspike_bleed_stack)
							end

				  			PI2[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget.vpcf", PATTACH_ABSORIGIN, v, 0, nil)
						  	ParticleManager:SetParticleControl(PI2[k],4, Vector(3.7, 0, 0))
							PI3[k] = FxCreator("particles/custom/vlad/vlad_impale_bleed.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, 0, nil)
							ParticleManager:SetParticleControlEnt(PI3[k], 1, v, PATTACH_ABSORIGIN_FOLLOW, nil, v:GetAbsOrigin(), false)

				  			DoDamage(caster, v, dmg_lastspike, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				  		end
			        end
				end

				if #lasthitTargets ~= 0 then
					caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
				end

		        if caster.IsImproveImpalingAcquired then
		        	local lastspike_heal_per_target = ability:GetSpecialValueFor("lastspike_heal_per_target")
		        	caster:ApplyHeal(lastspike_heal_per_target * #lasthitTargets, caster)
		        end
				--remove ontarget VFX
				Timers:CreateTimer(1.5, function()
					FxDestroyer(PI1, false)
					FxDestroyer(PI2, false)
					FxDestroyer(PI3, false)
			  	end)
			--small spikes
			else
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_spikes, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
						if not v:IsMagicImmune() then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 0.4 })
							--[[if caster.IsImproveImpalingAcquired then
								giveUnitDataDrivenModifier(caster, v, "revoked", 0.4)
							end]]

					        if caster.IsImproveImpalingAcquired then
					        	if v:IsRealHero() then
					        		local spikes_bleed_stack = ability:GetSpecialValueFor("spikes_bleed_stack")
					        		AddBleed(caster,v,spikes_bleed_stack)
								end
					        end

							DoDamage(caster, v, dmg_spikes, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end
					end
				end
				hitcounter = hitcounter + 1
				return 0.1
			end
		else
			FxDestroyer(PI4, false)
			FxDestroyer(PI5, false)
			return nil
		end
	end)
end

function OnLordOfExecutionStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local aoe = ability:GetSpecialValueFor("aoe")
	local dmg = ability:GetSpecialValueFor("dmg")
	local heal = ability:GetSpecialValueFor("heal")
	local spike_bleed_stack = ability:GetSpecialValueFor("spike_bleed_stack")
	local penalty = ability:GetSpecialValueFor("penalty")
	local stun = ability:GetSpecialValueFor("stun")

	caster:RemoveModifierByName("modifier_vlad_combo_window")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lord_of_execution_cooldown", {duration = ability:GetCooldown(1)})
	
	local CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge")
	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3")
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2")
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then 
		CeremonialPurge = caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1")
	end

	CeremonialPurge:StartCooldown(CeremonialPurge:GetCooldown(CeremonialPurge:GetLevel()))
	local MasterCombo = caster.MasterUnit2:FindAbilityByName("vlad_combo")
	MasterCombo:EndCooldown()
  	MasterCombo:StartCooldown(MasterCombo:GetCooldown(1))

  	local TargetAssRavageFX = {}
	local TargetExecuteFX = {}
	giveUnitDataDrivenModifier(caster, caster, "silenced", penalty)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	EmitGlobalSound("Vlad.Combo")
	Timers:CreateTimer(0.15, function()
		local SpikeFieldFX = FxCreator("particles/custom/vlad/vlad_combo_aoe.vpcf",PATTACH_ABSORIGIN,caster,0,nil)
		ParticleManager:SetParticleControlEnt( SpikeFieldFX,0 , caster,  PATTACH_ABSORIGIN, nil, caster:GetAbsOrigin(), false )
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() then
				if not v:IsMagicImmune() then
					v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
					TargetAssRavageFX[k] = FxCreator("particles/custom/vlad/vlad_combo_ontarget_stun.vpcf",PATTACH_ABSORIGIN,v,0,nil)
					ApplyAirborneOnly(v, 2000, 0.2, 1500)
				end
				
				Timers:CreateTimer(1.6, function()
					if (k % 2 == 0) or k == 1 then
						v:EmitSound("Vlad.FX1")			
					end
				end)
			end
    	end
    	if targets[1] ~= nil then 
    		targets[1]:EmitSound("Vlad.FX2")
      		targets[1]:EmitSound("Hero_Lycan.Attack")
      	end

		Timers:CreateTimer(0.2, function()
			if #targets ~= 0 then
				targets[1]:EmitSound("Hero_NyxAssassin.SpikedCarapace")
				caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
			end
			caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
			caster:EmitSound("Hero_Lycan.Attack")
			Timers:CreateTimer(0.1,function()
				caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end)
			FxDestroyer(SpikeFieldFX, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() then 
					if not v:IsMagicImmune() then
						TargetExecuteFX[k] = FxCreator("particles/custom/vlad/vlad_combo_ontarget_execute.vpcf",PATTACH_ABSORIGIN_FOLLOW,v,0,nil)
						ParticleManager:SetParticleControlEnt( TargetExecuteFX[k], 1, v,  PATTACH_ABSORIGIN_FOLLOW, nil, v:GetAbsOrigin(), false )
						ParticleManager:SetParticleControlEnt( TargetExecuteFX[k], 5, v,  PATTACH_CENTER_FOLLOW, nil, v:GetAbsOrigin(), false )
						v:SetAbsOrigin(GetGroundPosition(v:GetAbsOrigin(),v))

						if v:IsRealHero() then	
							AddBleed(caster,v,spike_bleed_stack)
						end

						DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)

						Timers:CreateTimer(0.1,function()	
							if IsValidEntity(v) and not v:IsNull() and caster:IsAlive() and v:IsRealHero() and not v:IsAlive() then
			        			caster:ApplyHeal(heal,caster)
							end
						end)
					end
				end
			end
		end)
		Timers:CreateTimer(3,function()
			FxDestroyer(TargetAssRavageFX, false)
			FxDestroyer(TargetExecuteFX, false)
		end)
	end)
end

function OnInnocentMonsterAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage
	local damage_splash = damage*ability:GetSpecialValueFor("splash_percentage") / 100
    local splash_aoe = ability:GetSpecialValueFor("splash_aoe")
    local lifesteal = ability:GetSpecialValueFor("lifesteal") / 100
    if target == caster:GetAttackTarget() and caster:IsAlive() then

      	caster:ApplyHeal(damage * lifesteal, caster)

      	local PI1 = FxCreator("particles/custom/vlad/vlad_im_splash_blood.vpcf",PATTACH_ABSORIGIN,target,0,nil)
      	local targets_splash = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	    
      	Timers:CreateTimer(1,function()
        	FxDestroyer(PI1, false)
      	end)
      	for k,v in pairs(targets_splash) do
        	if IsValidEntity(v) and not v:IsNull() and v ~= target and v:IsRealHero() then
	          	caster:ApplyHeal(damage_splash * lifesteal, caster)
	          	
	          	if v:IsRealHero() then
			    	if caster:HasModifier("modifier_vlad_rebellious_intent") then
			    		AddBleed(caster,v,2)
			    	else 
			    		AddBleed(caster,v,1)
			    	end
			    end

			    DoDamage(caster, v, damage_splash, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        	end
      	end
    end
end

function OnInnocentMonsterThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local currentPercentHP = caster:GetHealthPercent()
	local HpLoss = 100 - currentPercentHP 
	if caster:IsAlive() then
		if HpLoss > 0 then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_innocent_monster_stack", {})
			caster:SetModifierStackCount("modifier_innocent_monster_stack", caster, HpLoss)
		else
			caster:RemoveModifierByName("modifier_innocent_monster_stack")
		end
	end
end

function OnInnocentMonsterDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_innocent_monster_stack")
end

function OnProtectionOfFaithTakeDamage(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local condition = ability:GetSpecialValueFor("condition")
	local duration = ability:GetSpecialValueFor("duration")
	local currentHP = caster:GetHealth() 
	local damage = keys.DamageTaken

	if caster:IsAlive() and not IsReviveSeal(caster) and ability:IsCooldownReady() and currentHP <= condition and not caster:HasModifier("modifier_protection_of_faith_cooldown") then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_protection_of_faith_cooldown", {Duration = ability:GetCooldown(1)}) 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_protection_of_faith_active", {}) 

		HardCleanse(caster)

		local PI1 = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    Timers:CreateTimer(duration + 0.25, function()
	        FxDestroyer(PI1, false)
	    end)
	end
end

function VladCheckCombo(caster, ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "vlad_rebellious_intent") then
			caster.QUsed = true
			caster.QTime = GameRules:GetGameTime()
			if caster.QTimer ~= nil then 
				Timers:RemoveTimer(caster.QTimer)
				caster.QTimer = nil
			end
			caster.QTimer = Timers:CreateTimer(6.0, function()
				caster.QUsed = false
			end)
		else
			local newTime =  GameRules:GetGameTime()
			
			if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
				if string.match(ability:GetAbilityName(), "vlad_cursed_lance") and caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("vlad_combo"):IsCooldownReady() and not caster:HasModifier("modifier_lord_of_execution_cooldown") then 
					if caster.QUsed == true then 
						local duration = 6 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_combo_window", {duration = duration})	
					end
				end
			elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
				if string.match(ability:GetAbilityName(), "vlad_cursed_lance") and caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("vlad_combo"):IsCooldownReady() and not caster:HasModifier("modifier_lord_of_execution_cooldown") then 
					if caster.QUsed == true then 
						local duration = 6 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_combo_window", {duration = duration})	
					end
				end
			elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
				if string.match(ability:GetAbilityName(), "vlad_cursed_lance") and caster:FindAbilityByName("vlad_ceremonial_purge_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("vlad_combo"):IsCooldownReady() and not caster:HasModifier("modifier_lord_of_execution_cooldown") then 
					if caster.QUsed == true then 
						local duration = 6 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_combo_window", {duration = duration})	
					end
				end
			elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
				if string.match(ability:GetAbilityName(), "vlad_cursed_lance") and caster:FindAbilityByName("vlad_ceremonial_purge"):IsCooldownReady() and caster:FindAbilityByName("vlad_combo"):IsCooldownReady() and not caster:HasModifier("modifier_lord_of_execution_cooldown") then 
					if caster.QUsed == true then 
						local duration = 6 - (newTime - caster.QTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_vlad_combo_window", {duration = duration})	
					end
				end
			end
		end
	end
end

function OnVladComboWindowCreate(keys)
	local caster = keys.caster

	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_3", "vlad_combo", false, true) 
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_2", "vlad_combo", false, true) 
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_1", "vlad_combo", false, true) 
	elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", false, true) 
	end

end

function OnVladComboWindowDestroy(keys)
	local caster = keys.caster

	if caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_3", "vlad_combo", true, false) 
	elseif not caster.IsImproveImpalingAcquired and caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_2", "vlad_combo", true, false) 
	elseif caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge_upgrade_1", "vlad_combo", true, false) 
	elseif not caster.IsImproveImpalingAcquired and not caster.IsBloodletterAcquired then
		caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", true, false) 
	end
end

function OnVladComboWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_vlad_combo_window")
end

function OnInnocentMonsterAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsInnocentMonsterAcquired) then

		hero.IsInnocentMonsterAcquired = true

		hero:FindAbilityByName("vlad_innocent_monster"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnProtectionOfFaithAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsProtectionOfFaithAcquired) then

		hero.IsProtectionOfFaithAcquired = true

		hero:FindAbilityByName("vlad_protection_of_faith"):SetLevel(1)

		UpgradeAttribute(hero, "vlad_battle_continuation", "vlad_battle_continuation_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImproveImpalingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveImpalingAcquired) then

		if hero:HasModifier("modifier_vlad_combo_window") then 
			hero:RemoveModifierByName("modifier_vlad_combo_window")
		end

		hero.IsImproveImpalingAcquired = true

		if hero.IsBloodletterAcquired then 
			UpgradeAttribute(hero, "vlad_ceremonial_purge_upgrade_2", "vlad_ceremonial_purge_upgrade_3", true)
			UpgradeAttribute(hero, "vlad_kazikli_bey_upgrade_2", "vlad_kazikli_bey_upgrade_3", true)
		else
			UpgradeAttribute(hero, "vlad_ceremonial_purge", "vlad_ceremonial_purge_upgrade_1", true)
			UpgradeAttribute(hero, "vlad_kazikli_bey", "vlad_kazikli_bey_upgrade_1", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnInstantCurseAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsInstantCurseAcquired) then

		if hero:HasModifier("modifier_vlad_combo_window") then 
			hero:RemoveModifierByName("modifier_vlad_combo_window")
		end

		hero.IsInstantCurseAcquired = true

		if hero.IsBloodletterAcquired then 
			UpgradeAttribute(hero, "vlad_cursed_lance_upgrade_2", "vlad_cursed_lance_upgrade_3", true)
		else
			UpgradeAttribute(hero, "vlad_cursed_lance", "vlad_cursed_lance_upgrade_1", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnBloodLetterAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsBloodletterAcquired) then

		if hero:HasModifier("modifier_vlad_combo_window") then 
			hero:RemoveModifierByName("modifier_vlad_combo_window")
		end

		if hero:HasModifier("modifier_instant_cursed_window") then 
			hero:RemoveModifierByName("modifier_instant_cursed_window")
		end

		hero.IsBloodletterAcquired = true

		if hero.IsImproveImpalingAcquired then 
			UpgradeAttribute(hero, "vlad_ceremonial_purge_upgrade_1", "vlad_ceremonial_purge_upgrade_3", true)
			UpgradeAttribute(hero, "vlad_kazikli_bey_upgrade_1", "vlad_kazikli_bey_upgrade_3", true)
		else
			UpgradeAttribute(hero, "vlad_ceremonial_purge", "vlad_ceremonial_purge_upgrade_2", true)
			UpgradeAttribute(hero, "vlad_kazikli_bey", "vlad_kazikli_bey_upgrade_2", true)
		end

		if hero.IsInstantCurseAcquired then 
			UpgradeAttribute(hero, "vlad_cursed_lance_upgrade_1", "vlad_cursed_lance_upgrade_3", true)
		else
			UpgradeAttribute(hero, "vlad_cursed_lance", "vlad_cursed_lance_upgrade_2", true)
		end

		UpgradeAttribute(hero, "vlad_transfusion", "vlad_transfusion_upgrade", true)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

--------------------------------------------------------------

vlad_ceremonial_purge = class({})
vlad_ceremonial_purge_upgrade_1 = class({})
vlad_ceremonial_purge_upgrade_2 = class({})
vlad_ceremonial_purge_upgrade_3 = class({})
LinkLuaModifier("modifier_ceremonial_purge_slow", "abilities/vlad/vlad_abilities", LUA_MODIFIER_MOTION_NONE)

function ceremonial_wrapper(CPA)
	function CPA:GetManaCost(iLevel)
		local caster = self:GetCaster()
		local condition_free_mana = self:GetSpecialValueFor("condition_free_mana")
	  	if caster:GetHealthPercent() <= condition_free_mana then
	    	return 0
	  	else
	    	return 200
	  	end
	end

	if IsClient() then
		function CPA:GetCastRange( vLocation, hTarget)
			return self:GetSpecialValueFor("aoe_outer")
		end

	  	return
	end

	function CPA:OnSpellStart()
	  	local caster = self:GetCaster()
		local ability = self
		local delay = ability:GetSpecialValueFor("delay")
		local aoe_inner = ability:GetSpecialValueFor("aoe_inner")
		local aoe_outer = ability:GetSpecialValueFor("aoe_outer")
		local stun_inner = ability:GetSpecialValueFor("stun_inner")
		local stun_outer = ability:GetSpecialValueFor("stun_outer")
		local slow_duration = ability:GetSpecialValueFor("slow_duration")
		local dmg_inner = ability:GetSpecialValueFor("dmg_inner")
		local dmg_outer = ability:GetSpecialValueFor("dmg_outer")
		local hp_cost = ability:GetSpecialValueFor("hp_cost")
		local bleed_stack_inner = ability:GetSpecialValueFor("bleed_stack_inner")
		local bleed_stack_outer = ability:GetSpecialValueFor("bleed_stack_outer")
		local hp_max = caster:GetMaxHealth()
		local hp_current = caster:GetHealth() - (hp_max * hp_cost / 100)
		local bonus_dmg_bleed = 0

		if caster.IsImproveImpalingAcquired then 
			local bonus_dmg_per_bleed = ability:GetSpecialValueFor("bonus_dmg_per_bleed")
			local bleedcounter = OnBleedSeek(caster)
			bonus_dmg_bleed = bonus_dmg_per_bleed * bleedcounter
		end

		if caster.IsBloodletterAcquired then
			if not caster:HasModifier("modifier_vlad_transfusion_self") then 
				--caster:RemoveModifierByName("modifier_impale_window")
				if caster:HasModifier("modifier_transfusion_blood_power") then
					local bloodpower = caster:GetModifierStackCount("modifier_transfusion_blood_power", caster) or 0
					local bloodpowerduration = caster.BloodPower_duration
					local bonus_dmg_per_bloodpower = ability:GetSpecialValueFor("bonus_dmg_per_bloodpower") / 100
					local bloodpowercap = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("bloodpower_cap")
					local bleed = caster:FindAbilityByName("vlad_transfusion_upgrade")
					dmg_inner = dmg_inner + math.min(dmg_inner * bloodpower * bonus_dmg_per_bloodpower, dmg_inner * bloodpowercap * bonus_dmg_per_bloodpower)
					dmg_outer = dmg_outer + math.min(dmg_outer * bloodpower * bonus_dmg_per_bloodpower, dmg_outer * bloodpowercap * bonus_dmg_per_bloodpower)
					--[[if bloodpower > bloodpowercap then 
						ConsumeBloodPower(caster,bloodpower - bloodpowercap,bloodpowerduration)
					else 
						caster:RemoveModifierByName("modifier_transfusion_blood_power")
					end]]
				end
			end
		end

		if caster:IsAlive() then
			caster:SetHealth(math.max(1, hp_current))
			
			StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.5})
			local CPSpin = FxCreator("particles/custom/vlad/vlad_cp_spin.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, 2, nil)
			ParticleManager:SetParticleControlEnt(CPSpin, 1, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max", caster:GetAbsOrigin(),false)
			ParticleManager:SetParticleControlEnt(CPSpin, 3, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max-1", caster:GetAbsOrigin(),false)
			ParticleManager:SetParticleControlEnt(CPSpin, 8, caster, PATTACH_POINT_FOLLOW	, "attach_lance_tip-1", caster:GetAbsOrigin(),false)

			Timers:CreateTimer(4, function()
			 	FxDestroyer(CPSpin, false)
			end)

			if caster:HasModifier("modifier_alternate_01") then 
				local angle = caster:GetAnglesAsVector().y
				for i = 0,15 do 
					Timers:CreateTimer(i * 0.03, function()
						caster:SetAngles(0, angle - (i * 24), 0)
					end)
					if i == 15 then
						caster:SetAngles(0, 0, 0)
					end
				end
			end

		  	caster:EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")
			caster:EmitSound("Hero_Magnataur.ReversePolarity.Anim")

		  	giveUnitDataDrivenModifier(caster, caster, "drag_pause",0.5)
			Timers:CreateTimer(delay - ability:GetCastPoint(), function()
				local targets_outer = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_outer, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
				
				if targets_outer[1] ~= nil then 
					targets_outer[1]:EmitSound("Hero_NyxAssassin.SpikedCarapace")
				end
				
				for k,v in pairs(targets_outer) do
					if IsValidEntity(v) and not v:IsNull() then
						local distance = (v:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
						if distance < aoe_inner then
							
							if not IsImmuneToCC(v) then
								v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun_inner })
							end
							if v:IsRealHero() then	
								AddBleed(caster,v,bleed_stack_inner)
							end	

							DoDamage(caster, v, dmg_inner + bonus_dmg_bleed, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						else
							
							if not IsImmuneToSlow(v) then
								v:AddNewModifier(caster, ability, "modifier_ceremonial_purge_slow", { Duration = slow_duration })
							end
							if not IsImmuneToCC(v) then
			       				v:AddNewModifier(caster, nil, "modifier_stunned", { Duration = stun_outer })
			       			end
			       			if v:IsRealHero() then	
			       				AddBleed(caster,v,bleed_stack_outer)
							end	
							--local bleed_stack = v:GetModifierStackCount("modifier_vlad_bleed", caster)
							--v:SetModifierStackCount("modifier_ceremonial_purge_slow", caster, bleed_stack)

							DoDamage(caster, v, dmg_outer + bonus_dmg_bleed, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end
					end
				end
				
			end)
		end
	end

	function CPA:GetCastAnimation()
	  return nil
	end

	function CPA:GetTexture()
	  return "custom/vlad_ceremonial_purge"
	end
end

ceremonial_wrapper(vlad_ceremonial_purge)
ceremonial_wrapper(vlad_ceremonial_purge_upgrade_1)
ceremonial_wrapper(vlad_ceremonial_purge_upgrade_2)
ceremonial_wrapper(vlad_ceremonial_purge_upgrade_3)

------------------------------------

modifier_ceremonial_purge_slow = class({})

function modifier_ceremonial_purge_slow:DeclareFunctions()
  	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  	}
  	return funcs
end

function modifier_ceremonial_purge_slow:GetModifierMoveSpeedBonus_Percentage()
  	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("slow_per_stack")
end

if IsServer() then
  	function modifier_ceremonial_purge_slow:OnCreated()
	    local parent = self:GetParent()
	  	local ability = self:GetAbility()
	  	local modbleed = parent:FindModifierByName("modifier_vlad_bleed") or nil
	  	if modbleed ~= nil then
	    	local count = modbleed:GetStackCount()
	      	self:SetStackCount(count)
	      	parent:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
	      	local PI1 = FxCreator("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, 0, nil)
	      	Timers:CreateTimer((ability:GetSpecialValueFor("stun_outer"))*2, function() -- start slow fading after double duration of stun
	        	if not self:IsNull() then
	          		self:StartIntervalThink(1)
	          		FxDestroyer(PI1, false)
	        	end
	      	end)
	    else
	      	self:Destroy()
	    end
  	end

  	function modifier_ceremonial_purge_slow:OnIntervalThink()
	    local count = self:GetStackCount()
	    if count > 10 then
	      	self:SetStackCount(math.max(math.floor(count/2),6))
	    elseif count > 5 then
	      	self:SetStackCount(count-3)
	    else
	      	self:DecrementStackCount()
	    end
	    if self:GetStackCount() <= 0 then
	      	self:Destroy()
	    end
  	end

  	function modifier_ceremonial_purge_slow:OnRefresh()
	    self:OnDestroy()
	    self:OnCreated()
 	end
  	function modifier_ceremonial_purge_slow:OnDestroy()
    	self:StartIntervalThink(-1)
  	end
end

function modifier_ceremonial_purge_slow:IsHidden()
  	return false
end

function modifier_ceremonial_purge_slow:IsDebuff()
  	return true
end

function modifier_ceremonial_purge_slow:RemoveOnDeath()
  	return true
end
