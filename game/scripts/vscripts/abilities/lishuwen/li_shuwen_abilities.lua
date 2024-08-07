
function OnBerserkStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 

	if IsRevoked(caster) then
        ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
        return
    end

	HardCleanse(caster)

	caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_berserk", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_berserk_immune", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_berserk_cooldown", {Duration= ability:GetCooldown(1)})
end

function OnBerserkCreate(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_dragon_strikes_window") then return end
	--if caster:HasModifier("modifier_tiger_strikes_window") then return end
	if caster.bIsFuriousChainAcquired then 
		caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", "lishuwen_tiger_strike_upgrade", true, false)
	else
		caster:SwapAbilities("lishuwen_tiger_strike_berserk", "lishuwen_tiger_strike", true, false)
	end	
end

function OnBerserkDestroy(keys)
	local caster = keys.caster 
	--caster:RemoveModifierByName("modifier_tiger_strikes_window")
	if caster.bIsFuriousChainAcquired then 
		caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", "lishuwen_tiger_strike_upgrade", false, true)
	else
		caster:SwapAbilities("lishuwen_tiger_strike_berserk", "lishuwen_tiger_strike", false, true)
	end
end

function OnDualClassThink(keys)
	local caster = keys.caster 
	local str = math.ceil(caster:GetStrength()) 
	local agi = math.ceil(caster:GetAgility()) 

	caster:SetModifierStackCount("modifier_lishuwen_dual_class_hp", caster, agi)
	caster:SetModifierStackCount("modifier_lishuwen_dual_class_atk", caster, str)
end

function ApplyMarkOfFatality(caster,target,bActive)
	local abil = caster:FindAbilityByName("lishuwen_martial_arts")
	if abil == nil then 
		abil = caster:FindAbilityByName("lishuwen_martial_arts_upgrade")
	end

	if bActive == true then 

	else
		if target:HasModifier("modifier_mark_of_fatality_cooldown") then 
			return
		else
			abil:ApplyDataDrivenModifier(caster, target, "modifier_mark_of_fatality_cooldown", {}) 
		end
	end
	local max_stack = abil:GetSpecialValueFor("max_stack")
	-- add new stack
	local currentStack = target:GetModifierStackCount("modifier_mark_of_fatality", caster) or 0
	target:RemoveModifierByName("modifier_mark_of_fatality") 
	abil:ApplyDataDrivenModifier(caster, target, "modifier_mark_of_fatality", {}) 
	target:SetModifierStackCount("modifier_mark_of_fatality", abil, math.min(currentStack + 1, max_stack))
	--[[if (currentStack + 1) % 5 == 0 then 
		local silence_duration = ability:GetSpecialValueFor("silence_duration")
		giveUnitDataDrivenModifier(caster, target, "silenced", silence_duration)
	end]]
end

function OnMartialStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local silence_duration = ability:GetSpecialValueFor("silence_duration")

	if caster:GetName() == "npc_dota_hero_bloodseeker" then
		LishuwenCheckCombo(caster, ability)
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_martial_art_cooldown", {Duration= ability:GetCooldown(1)})

	if IsSpellBlocked(target) then 
		return 
	end

	giveUnitDataDrivenModifier(caster, target, "silenced", silence_duration)
	ApplyMarkOfFatality(caster,target,true)

	if caster.bIsMartialArtsImproved then 
		local active_stack = ability:GetSpecialValueFor("active_stack")
		for i = 1, active_stack - 1 do
			ApplyMarkOfFatality(caster,target,true)
		end
	end

	local pcMark = ParticleManager:CreateParticle("particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_start.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(pcMark)
	target:EmitSound("Hero_Nightstalker.Void")
end

function OnMartialDetect(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.unit 

	if not ability:IsItem() and not IsSpellBook(ability:GetAbilityName()) then 
		ApplyMarkOfFatality(caster,target, true)
	end
end

function OnMartialAttackStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local chance = ability:GetSpecialValueFor("critical_rate_percentage")

	if not target:HasModifier("modifier_mark_of_fatality") then return end

	if caster.bIsMartialArtsImproved then 
		local bonus = ability:GetSpecialValueFor("bonus_crit_rate_per_stack")
		local stack = target:GetModifierStackCount("modifier_mark_of_fatality", caster) or 0 
		chance = chance + (bonus * stack)
	end
	
	local roll = math.random(100)
	if roll < chance then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_martial_arts_crit_hit", {})
	end
end

function OnMartialAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target.li_burn_count == nil then
		target.li_burn_count = 0
	end

	if caster.bIsMartialArtsImproved then 
		if caster.bIsMartialArtsImproved then
			ApplyMarkOfFatality(caster, target, false)
		end
		if target:HasModifier("modifier_no_second_strike_shock") then
			if not IsManaLess(target) then
				local mana_drain = ability:GetSpecialValueFor("mana_drain")
				local currentmana = target:GetMana()
				target.li_burn_count = target.li_burn_count + math.min(mana_drain, currentmana)
				if currentmana >= mana_drain then
					target:SetMana(currentmana - mana_drain)
					DoDamage(caster, target, mana_drain, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				else
					target:SetMana(0)
					DoDamage(caster, target, currentmana, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					
				end
			end
		end
	end
end

function OnSphereBoundaryStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ProjectileManager:ProjectileDodge(caster)

	local stopOrder = {
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_invis", {})


end

function OnSphereBoundaryMove(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_lishuwen_invis")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_invis_move", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_move", {})
end

function OnSphereBoundaryBroke(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_lishuwen_invis")
	caster:RemoveModifierByName("modifier_lishuwen_invis_move")
end

function OnCosmicOrbitStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local number_attack = ability:GetSpecialValueFor("number_of_attacks")

	ProjectileManager:ProjectileDodge(caster)
	LishuwenCheckCombo(caster, ability)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit_attack", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit_speed", {})
	caster:EmitSound("Hero_Sven.WarCry")
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:EmitSound("Lishuwen.Berserk.W")
	end

	caster:SetModifierStackCount("modifier_lishuwen_cosmic_orbit_attack", caster, number_attack)
end

function OnCosmicOrbitAttackLanded(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	local current_stack = caster:GetModifierStackCount("modifier_lishuwen_cosmic_orbit_attack", caster)

	if current_stack > 1 then 
		caster:SetModifierStackCount("modifier_lishuwen_cosmic_orbit_attack", caster, current_stack - 1)
	else
		caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit")
		caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit_attack")
		caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit_speed")
	end

	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target, false)
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnTigerStrikesUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability 
	if caster.bIsFuriousChainAcquired then
		if ability:GetAbilityName() == "lishuwen_tiger_strike_upgrade" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):GetLevel() then 
			caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):SetLevel(ability:GetLevel())
		elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk_upgrade" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):GetLevel() then 
			caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):SetLevel(ability:GetLevel())
		end
		caster:FindAbilityByName("lishuwen_tiger_strike_2_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_3_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_berserk_2_upgrade"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_berserk_3_upgrade"):SetLevel(ability:GetLevel())
	else
		if ability:GetAbilityName() == "lishuwen_tiger_strike" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):GetLevel() then 
			caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):SetLevel(ability:GetLevel())
		elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike"):GetLevel() then 
			caster:FindAbilityByName("lishuwen_tiger_strike"):SetLevel(ability:GetLevel())
		end
		caster:FindAbilityByName("lishuwen_tiger_strike_2"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_3"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_berserk_2"):SetLevel(ability:GetLevel())
		caster:FindAbilityByName("lishuwen_tiger_strike_berserk_3"):SetLevel(ability:GetLevel())
	end
end

function OnTigerStrikeActive(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.bIsFuriousChainAcquired then 
		if ability:GetAbilityName() == "lishuwen_tiger_strike_upgrade" then 
			caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):StartCooldown(caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):GetLevel())
		elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk_upgrade" then 
			caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):StartCooldown(caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):GetLevel())
		end
	else
		if ability:GetAbilityName() == "lishuwen_tiger_strike" then 
			caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):StartCooldown(caster:FindAbilityByName("lishuwen_tiger_strike"):GetLevel())
		elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk" then 
			caster:FindAbilityByName("lishuwen_tiger_strike"):StartCooldown(caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):GetLevel())
		end
	end
end

function OnTigerStrikesCast(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	if target:GetName() == "npc_dota_ward_base" then
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
end

lishuwen_tiger_strike = class({})
lishuwen_tiger_strike_upgrade = class({})
lishuwen_tiger_strike_berserk = class({})
lishuwen_tiger_strike_berserk_upgrade = class({})
LinkLuaModifier("modifier_tiger_strikes_window", "abilities/lishuwen/li_shuwen_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiger_strikes_marker", "abilities/lishuwen/li_shuwen_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiger_first_strike_slow", "abilities/lishuwen/li_shuwen_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_furious_chain_buff", "abilities/lishuwen/li_shuwen_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiger_berserk_bypass_armor", "abilities/lishuwen/li_shuwen_abilities", LUA_MODIFIER_MOTION_NONE)

function tigerstrikewrapper(TPM)
	function TPM:GetCastPoint()
		if self:CheckSequence() == 2 then
			return 0.3
		elseif self:CheckSequence() == 1 then
			return 0.3
		else
			return 0.3
		end
	end

	function TPM:OnUpgrade()
		local caster = self:GetCaster()
		local ability = self
		if caster.bIsFuriousChainAcquired then
			if ability:GetAbilityName() == "lishuwen_tiger_strike_upgrade" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):GetLevel() then 
				caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade"):SetLevel(ability:GetLevel())
			elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk_upgrade" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):GetLevel() then 
				caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):SetLevel(ability:GetLevel())
			end
		else
			if ability:GetAbilityName() == "lishuwen_tiger_strike" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):GetLevel() then 
				caster:FindAbilityByName("lishuwen_tiger_strike_berserk"):SetLevel(ability:GetLevel())
			elseif ability:GetAbilityName() == "lishuwen_tiger_strike_berserk" and ability:GetLevel() ~= caster:FindAbilityByName("lishuwen_tiger_strike"):GetLevel() then 
				caster:FindAbilityByName("lishuwen_tiger_strike"):SetLevel(ability:GetLevel())
			end
		end
	end

	function TPM:CastFilterResultTarget(hTarget)
		local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())

		if filter == UF_SUCCESS then
			if hTarget:GetName() == "npc_dota_ward_base" then 
				return UF_FAIL_CUSTOM 
			else
				return UF_SUCCESS
			end
		else
			return filter
		end
	end

	function TPM:GetCustomCastError()
	    return "#Invalid_Target"
	end

	function TPM:CheckSequence()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_tiger_strikes_window") then
			local stack = caster:GetModifierStackCount("modifier_tiger_strikes_window", caster)

			return stack
		else
			return 0
		end	
	end

	function TPM:GetCastAnimation()
		if self:CheckSequence() == 2 then
			return ACT_DOTA_CAST_ABILITY_2_END
		elseif self:CheckSequence() == 1 then
			return ACT_DOTA_CAST_ABILITY_2_ES_ROLL
		else
			return ACT_DOTA_CAST_ABILITY_2
		end
	end

	function TPM:GetCastRange(vLocation, hTarget)
		if self:CheckSequence() < 1 then
			return self:GetSpecialValueFor("strike_1_range")
		else
			return self:GetSpecialValueFor("strike_2_range")
		end
	end

	function TPM:GetAbilityTextureName()
		if self:CheckSequence() == 3 then
			return "custom/lishuwen_fierce_tiger_strike_3"
		elseif self:CheckSequence() == 2 then
			return "custom/lishuwen_fierce_tiger_strike_2"
		else
			return "custom/lishuwen_fierce_tiger_strike"
		end
	end

	function TPM:SequenceSkill()
		local caster = self:GetCaster()	
		local ability = self
		local modifier = caster:FindModifierByName("modifier_tiger_strikes_window")

		if not modifier then
			caster:AddNewModifier(caster, ability, "modifier_tiger_strikes_window", {Duration = self:GetSpecialValueFor("window_duration")})
			caster:SetModifierStackCount("modifier_tiger_strikes_window", ability, 2)
		else
			caster:SetModifierStackCount("modifier_tiger_strikes_window", ability, modifier:GetStackCount() + 1)
		end
	end

	function TPM:GrantFuriousChainBuff()
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_furious_chain_buff")

		if not modifier then
			caster:AddNewModifier(caster, self, "modifier_furious_chain_buff", {Duration = self:GetSpecialValueFor("regen_duration"),
																				 RegenAmount = self:GetSpecialValueFor("regen_amount")})
			caster:SetModifierStackCount("modifier_furious_chain_buff", self, 1)
		else
			caster:AddNewModifier(caster, self, "modifier_furious_chain_buff", {Duration = self:GetSpecialValueFor("regen_duration"),
																				 RegenAmount = self:GetSpecialValueFor("regen_amount")})
			caster:SetModifierStackCount("modifier_furious_chain_buff", self, math.min(3, modifier:GetStackCount() + 1) )
		end
	end

	function TPM:OnSpellStart()
		local caster = self:GetCaster()

		ProjectileManager:ProjectileDodge(caster)

		if self:CheckSequence() == 3 then
			self:TigerStrike3()
		elseif self:CheckSequence() == 2 then
			self:TigerStrike2()
		else
			self:TigerStrike1()
		end
	end

	function TPM:TigerStrike1()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ability = self
		local damage_type = DAMAGE_TYPE_MAGICAL
		local damage = self:GetSpecialValueFor("damage_1")

		local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
		ParticleManager:SetParticleControl( trailFx, 1, caster:GetAbsOrigin() )

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( trailFx, 0, target:GetAbsOrigin() )

		self:SequenceSkill()
		self:EndCooldown()

		if IsSpellBlocked(target) then return end

		if caster:HasModifier("modifier_lishuwen_berserk") then 
			damage_type = DAMAGE_TYPE_PHYSICAL 
			--local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
			--target:AddNewModifier(caster, self, "modifier_tiger_berserk_bypass_armor", {Duration = 0.2, BypassArmor = math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue())})

			local crit_chance = ability:GetSpecialValueFor("critical_chance")
			local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
			if RandomInt(1, 100) <= crit_chance then 
				damage = damage * crit_damage
				self:CreateCritFx(target)
				caster:EmitSound("Hero_Juggernaut.BladeDance") 
			end
		end

		if caster.bIsFuriousChainAcquired then 
			self:GrantFuriousChainBuff()
			target:AddNewModifier(caster, self, "modifier_tiger_strikes_marker", {Duration = self:GetSpecialValueFor("window_duration")})
		end

		if caster.bIsMartialArtsImproved then
			ApplyMarkOfFatality(caster, target, false)
		end

		if not IsImmuneToSlow(target) then 
			target:AddNewModifier(caster, self, "modifier_tiger_first_strike_slow", {Duration = self:GetSpecialValueFor("slow_duration"),
																			   SlowPct = self:GetSpecialValueFor("slow_amount")})
		end

		target:EmitSound("Hero_EarthShaker.Attack")
		local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
	    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
	    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_first_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())

		if caster:HasModifier("modifier_lishuwen_berserk") then 
			caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
			local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
			DoDamage(caster, target, damage * bypass_armor, damage_type, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, ability, false)
			DoDamage(caster, target, damage * (1-bypass_armor), damage_type, 0, ability, false)
		else
			if caster:HasModifier('modifier_alternate_02') then 
				caster:EmitSound("Li-Boss-E1")
			else
				caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
			end	
			DoDamage(caster, target, damage, damage_type, 0, ability, false)
		end
	end


	function TPM:TigerStrike2()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ability = self
		local damage = ability:GetSpecialValueFor("damage_2")
		local stun_duration = ability:GetSpecialValueFor("stun_duration")

		caster:SetAbsOrigin(target:GetAbsOrigin()-(caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()*130)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		caster:SetForwardVector(target:GetAbsOrigin())

		self:SequenceSkill()
		self:EndCooldown()

		if IsSpellBlocked(target) then return end
		
		if caster.bIsFuriousChainAcquired then 
			self:GrantFuriousChainBuff()
			
			if target:HasModifier("modifier_tiger_strikes_marker") then 
				damage = damage * (1 + (self:GetSpecialValueFor("bonus_damage") / 100 ))
			else 
				damage = damage * (self:GetSpecialValueFor("damage_penalty") / 100 )
			end
		end

		if caster.bIsMartialArtsImproved then
			ApplyMarkOfFatality(caster, target, false)
		end

		if caster:HasModifier("modifier_lishuwen_berserk") then 
			
			--target:AddNewModifier(caster, self, "modifier_tiger_berserk_bypass_armor", {Duration = 0.2, BypassArmor = math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue())})
			local crit_chance = ability:GetSpecialValueFor("critical_chance")
			local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
			if RandomInt(1, 100) <= crit_chance then 
				damage = damage * crit_damage 
				self:CreateCritFx(target)
				caster:EmitSound("Hero_Juggernaut.BladeDance")
			end
		end

		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		end

		local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
	    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
	    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_second_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())

		target:EmitSound("Hero_EarthShaker.Attack")
		if caster:HasModifier("modifier_lishuwen_berserk") then 
			local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
			caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
			DoDamage(caster, target, damage * bypass_armor, DAMAGE_TYPE_PHYSICAL, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, ability, false)
			DoDamage(caster, target, damage * (1-bypass_armor), DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		else
			if caster:HasModifier('modifier_alternate_02') then 
				caster:EmitSound("Li-Boss-E2")
			else
				caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
			end	
			DoDamage(caster, target, damage , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		end
	end

	function TPM:TigerStrike3()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ability = self
		local damage = ability:GetSpecialValueFor("damage_3")
		local damage_type = DAMAGE_TYPE_PURE

		if IsSpellBlocked(target) then return end

		caster:RemoveModifierByName("modifier_tiger_strikes_window")
		
		self:EndCooldown()
		self:StartCooldown(self:GetSpecialValueFor("reduced_cooldown"))
		if string.match(self:GetAbilityName(), '_berserk') then 
			if caster.bIsFuriousChainAcquired then 
				caster:FindAbilityByName('lishuwen_tiger_strike_upgrade'):EndCooldown()
				caster:FindAbilityByName('lishuwen_tiger_strike_upgrade'):StartCooldown(self:GetSpecialValueFor("reduced_cooldown"))
			else
				caster:FindAbilityByName('lishuwen_tiger_strike'):EndCooldown()
				caster:FindAbilityByName('lishuwen_tiger_strike'):StartCooldown(self:GetSpecialValueFor("reduced_cooldown"))
			end
		else
			if caster.bIsFuriousChainAcquired then 
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk_upgrade'):EndCooldown()
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk_upgrade'):StartCooldown(self:GetSpecialValueFor("reduced_cooldown"))
			else
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk'):EndCooldown()
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk'):StartCooldown(self:GetSpecialValueFor("reduced_cooldown"))
			end
		end

		if caster.bIsMartialArtsImproved then
			ApplyMarkOfFatality(caster, target, false)
		end

		if caster.bIsFuriousChainAcquired then 
			self:GrantFuriousChainBuff()
			
			if target:HasModifier("modifier_tiger_strikes_marker") then 
				damage = damage * (1 + (self:GetSpecialValueFor("bonus_damage") / 100 ))
			else 
				damage = damage * (self:GetSpecialValueFor("damage_penalty") / 100 )
			end
		end

		target:RemoveModifierByName("modifier_tiger_strikes_marker")

		if caster:HasModifier("modifier_lishuwen_berserk") then 
			damage_type = DAMAGE_TYPE_PHYSICAL 
			
			--target:AddNewModifier(caster, self, "modifier_tiger_berserk_bypass_armor", {Duration = 0.2, BypassArmor = math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue())})

			local crit_chance = ability:GetSpecialValueFor("critical_chance")
			local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
			if RandomInt(1, 100) <= crit_chance then 
				damage = damage * crit_damage
				self:CreateCritFx(target)
				caster:EmitSound("Hero_Juggernaut.BladeDance") 
			end
		end

		--local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
		--ParticleManager:SetParticleControl( groundFx1, 0, target:GetAbsOrigin())
		local groundFx2 = ParticleManager:CreateParticle( "particles/custom/lishuwen/lishuwen_third_slam.vpcf", PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControl( groundFx2, 0, target:GetAbsOrigin())
		--ParticleManager:SetParticleControlOrientation(groundFx1, 1, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
		ParticleManager:SetParticleControlOrientation(groundFx2, 1, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
		local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_third_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
		
		target:EmitSound("Hero_EarthShaker.Attack")
		if caster:HasModifier("modifier_lishuwen_berserk") then 
			caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
			local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
			DoDamage(caster, target, damage * bypass_armor, damage_type, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, ability, false)
			DoDamage(caster, target, damage * (1-bypass_armor), damage_type, 0, ability, false)
		else
			if caster:HasModifier('modifier_alternate_02') then 
				caster:EmitSound("Li-Boss-E3")
			else
				caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
			end	
			DoDamage(caster, target, damage, damage_type, 0, ability, false)
		end
	end

	function TPM:CreateCritFx(target)
		local crit_fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN, target )
	    --ParticleManager:SetParticleControl( crit_fx, 0, target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin())
	    ParticleManager:SetParticleControl( crit_fx, 1, target:GetAbsOrigin())

	    Timers:CreateTimer(0.2, function()
			ParticleManager:DestroyParticle( crit_fx, false )
			ParticleManager:ReleaseParticleIndex( crit_fx )
			return nil
		end)
	end
end
tigerstrikewrapper(lishuwen_tiger_strike)
tigerstrikewrapper(lishuwen_tiger_strike_upgrade)
tigerstrikewrapper(lishuwen_tiger_strike_berserk)
tigerstrikewrapper(lishuwen_tiger_strike_berserk_upgrade)

modifier_furious_chain_buff = class({})

function modifier_furious_chain_buff:OnCreated(keys)
	if IsServer() then
		self.RegenAmount = keys.RegenAmount
	end
end

function modifier_furious_chain_buff:GetRegenAmount()
	if IsServer() then
		CustomNetTables:SetTableValue("sync","furious_chain_regen", { regen_amt = self.RegenAmount * self:GetStackCount() })
		return self.RegenAmount * self:GetStackCount()
	elseif IsClient() then
		local regen_at = CustomNetTables:GetTableValue("sync","furious_chain_regen").regen_amt
		return regen_at
	end	
end

function modifier_furious_chain_buff:GetModifierConstantHealthRegen()
	return self:GetRegenAmount()
end

function modifier_furious_chain_buff:GetModifierConstantManaRegen()
	return self:GetRegenAmount()
end

function modifier_furious_chain_buff:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
	return funcs
end

function modifier_furious_chain_buff:IsHidden()
	return false
end

function modifier_furious_chain_buff:IsDebuff()
	return false
end

function modifier_furious_chain_buff:RemoveOnDeath()
	return true
end

function modifier_furious_chain_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_furious_chain_buff:GetTexture()
	return "custom/lishuwen_attribute_furious_chain"
end

modifier_tiger_first_strike_slow = class({})

function modifier_tiger_first_strike_slow:OnCreated(keys)
	self.SlowPct = keys.SlowPct
end

function modifier_tiger_first_strike_slow:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then
        CustomNetTables:SetTableValue("sync","tiger_strike_slow", {slow = self.SlowPct})
    	return self.SlowPct
    elseif IsClient() then
        local tiger_strike_slow = CustomNetTables:GetTableValue("sync","tiger_strike_slow").slow
        return tiger_strike_slow 
    end
end

function modifier_tiger_first_strike_slow:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
	return funcs
end

function modifier_tiger_first_strike_slow:IsHidden()
	return false
end

function modifier_tiger_first_strike_slow:IsDebuff()
	return true
end

function modifier_tiger_first_strike_slow:RemoveOnDeath()
	return true
end

function modifier_tiger_first_strike_slow:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_tiger_first_strike_slow:GetTexture()
	return "custom/lishuwen_fierce_tiger_strike"
end

modifier_tiger_strikes_marker = class({})

function modifier_tiger_strikes_marker:OnCreated(table)
	
end

function modifier_tiger_strikes_marker:IsPurgable()
	return false
end

function modifier_tiger_strikes_marker:IsHidden()
	return false
end

function modifier_tiger_strikes_marker:IsDebuff()
	return true
end

function modifier_tiger_strikes_marker:RemoveOnDeath()
	return true
end

function modifier_tiger_strikes_marker:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_tiger_strikes_marker:GetTexture()
	return "custom/lishuwen_fierce_tiger_strike"
end

function modifier_tiger_strikes_marker:GetEffectName()
	return "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_crit_tgt.vpcf"
end

function modifier_tiger_strikes_marker:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_tiger_strikes_window = class({})

function modifier_tiger_strikes_window:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetParent()
		local time = self:GetDuration() - self:GetRemainingTime()
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()) - time)
		if string.match(ability:GetAbilityName(), '_berserk') then 
			if caster.bIsFuriousChainAcquired then 
				caster:FindAbilityByName('lishuwen_tiger_strike_upgrade'):StartCooldown(ability:GetCooldown(ability:GetLevel()) - time)
			else
				caster:FindAbilityByName('lishuwen_tiger_strike'):StartCooldown(ability:GetCooldown(ability:GetLevel()) - time)
			end
		else
			if caster.bIsFuriousChainAcquired then 
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk_upgrade'):StartCooldown(ability:GetCooldown(ability:GetLevel()) - time)
			else
				caster:FindAbilityByName('lishuwen_tiger_strike_berserk'):StartCooldown(ability:GetCooldown(ability:GetLevel()) - time)
			end
		end
		
	end
end

function modifier_tiger_strikes_window:IsPurgable()
	return false
end

function modifier_tiger_strikes_window:IsHidden()
	return false
end

function modifier_tiger_strikes_window:IsDebuff()
	return false
end

function modifier_tiger_strikes_window:RemoveOnDeath()
	return true
end

function modifier_tiger_strikes_window:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_tiger_strikes_window:GetTexture()
	return "custom/lishuwen_fierce_tiger_strike"
end

modifier_tiger_berserk_bypass_armor = class({})
if IsServer() then
	function modifier_tiger_berserk_bypass_armor:OnCreated(keys)
		self.BypassArmor = -keys.BypassArmor
	end
end

function modifier_tiger_berserk_bypass_armor:GetModifierPhysicalArmorBonus()
	if IsServer() then
        CustomNetTables:SetTableValue("sync","tiger_strike_bypass", {bypass = self.BypassArmor})
    	return self.BypassArmor
    elseif IsClient() then
        local tiger_strike_bypass = CustomNetTables:GetTableValue("sync","tiger_strike_bypass").bypass
        return tiger_strike_bypass 
    end
end

function modifier_tiger_berserk_bypass_armor:IsPurgable()
	return false
end

function modifier_tiger_berserk_bypass_armor:IsHidden()
	return true
end

function modifier_tiger_berserk_bypass_armor:IsDebuff()
	return true
end

function modifier_tiger_berserk_bypass_armor:GetAttributes()
  	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_tiger_berserk_bypass_armor:RemoveOnDeath()
	return true
end

function modifier_tiger_berserk_bypass_armor:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return funcs
end

function OnTigerStrike1Start(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage_1")
	local damage_type = DAMAGE_TYPE_MAGICAL
	caster.tiger_strike = 0

	ProjectileManager:ProjectileDodge(caster)

	local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
	ParticleManager:SetParticleControl( trailFx, 1, caster:GetAbsOrigin() )

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( trailFx, 0, target:GetAbsOrigin() )

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tiger_strikes_window", {}) 
	--caster.tiger_strike = 1 
	--OnTigerStrikeWindow(caster,ability)

	if IsSpellBlocked(target) then return end

	if caster:HasModifier("modifier_lishuwen_berserk") then 
		damage_type = DAMAGE_TYPE_PHYSICAL 
		local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tiger_berserk_bypass_armor", {}) 
		target:SetModifierStackCount("modifier_tiger_berserk_bypass_armor", caster, math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue()) )
		local crit_chance = ability:GetSpecialValueFor("critical_chance")
		local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
		if RandomInt(1, 100) <= crit_chance then 
			damage = damage * crit_damage 
		end
	end

	if caster.bIsFuriousChainAcquired then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tiger_strikes_marker", {}) 
		GrantFuriousChainBuff(caster)
	end

	DoDamage(caster, target, damage, damage_type, 0, ability, false)

	if not IsImmuneToSlow(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tiger_first_strike_slow", {}) 
	end

	target:EmitSound("Hero_EarthShaker.Attack")
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
	else
		caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
	end
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_first_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())

end

function OnTigerStrike2Start(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage_2")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	caster:SetAbsOrigin(target:GetAbsOrigin()-(caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()*130)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	caster:SetForwardVector(target:GetAbsOrigin())

	--caster.tiger_strike = 2 
	--OnTigerStrikeWindow(caster,ability)
	if caster:HasModifier("modifier_lishuwen_berserk") then
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_2_upgrade", "lishuwen_tiger_strike_berserk_3_upgrade", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_2", "lishuwen_tiger_strike_berserk_3", false, true)
		end
	else
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_2_upgrade", "lishuwen_tiger_strike_3_upgrade", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_2", "lishuwen_tiger_strike_3", false, true)
		end
	end

	ability:EndCooldown()

	if IsSpellBlocked(target) then return end

	if caster:HasModifier("modifier_lishuwen_berserk") then 
		local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tiger_berserk_bypass_armor", {}) 
		target:SetModifierStackCount("modifier_tiger_berserk_bypass_armor", caster, math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue()))
		local crit_chance = ability:GetSpecialValueFor("critical_chance")
		local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
		if RandomInt(1, 100) <= crit_chance then 
			damage = damage * crit_damage 
		end
	end

	if caster.bIsFuriousChainAcquired then 
		GrantFuriousChainBuff(caster)
		local tiger_strike_1 = caster:FindAbilityByName("lishuwen_tiger_strike_upgrade")
		local bonus_damage = ability:GetSpecialValueFor("bonus_damage") / 100
		local damage_penalty = ability:GetSpecialValueFor("damage_penalty") / 100
		if target:HasModifier("modifier_tiger_strikes_marker") then
			damage = damage * (1 + bonus_damage)
		else
			damage = damage * damage_penalty
		end
	end
	
	DoDamage(caster, target, damage , DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = stun_duration})
	end

	target:EmitSound("Hero_EarthShaker.Attack")
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
	else
		caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
	end
	
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_second_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnTigerStrike3Start(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local damage = ability:GetSpecialValueFor("damage_3")
	local damage_type = DAMAGE_TYPE_PURE
	
	ability:EndCooldown()
	caster:RemoveModifierByName("modifier_tiger_strikes_window")

	if IsSpellBlocked(target) then return end

	
	local tiger_strike_1 = caster:FindAbilityByName("lishuwen_tiger_strike")
	if tiger_strike_1 == nil then 
		tiger_strike_1 = caster:FindAbilityByName("lishuwen_tiger_strike_upgrade")
	end
	local reduce_cooldown = tiger_strike_1:GetSpecialValueFor("reduced_cooldown")
	local tiger_strike_berserk = caster:FindAbilityByName("lishuwen_tiger_strike_berserk")
	if tiger_strike_berserk == nil then 
		tiger_strike_berserk = caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade")
	end
	tiger_strike_1:EndCooldown()
	tiger_strike_1:StartCooldown(reduce_cooldown)
	tiger_strike_berserk:EndCooldown()
	tiger_strike_berserk:StartCooldown(reduce_cooldown)

	if caster:HasModifier("modifier_lishuwen_berserk") then 
		damage_type = DAMAGE_TYPE_PHYSICAL 
		local bypass_armor = ability:GetSpecialValueFor("bypass_armor") / 100
		ability:ApplyDataDrivenModifier(caster, target, "modifier_tiger_berserk_bypass_armor", {}) 
		target:SetModifierStackCount("modifier_tiger_berserk_bypass_armor", caster, math.ceil(bypass_armor * target:GetPhysicalArmorBaseValue()))
		local crit_chance = ability:GetSpecialValueFor("critical_chance")
		local crit_damage = ability:GetSpecialValueFor("critical_damage") / 100
		if RandomInt(1, 100) <= crit_chance then 
			damage = damage * crit_damage 
		end
	end

	if caster.bIsFuriousChainAcquired then 
		GrantFuriousChainBuff(caster)
		local bonus_damage = ability:GetSpecialValueFor("bonus_damage") / 100
		local damage_penalty = ability:GetSpecialValueFor("damage_penalty") / 100
		if target:HasModifier("modifier_tiger_strikes_marker") then
			damage = damage * (1 + bonus_damage)
		else
			damage = damage * damage_penalty
		end
	end

	target:RemoveModifierByName("modifier_tiger_strikes_marker")

	DoDamage(caster, target, damage , damage_type, 0, ability, false)

	target:EmitSound("Hero_EarthShaker.Attack")
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:EmitSound("Lishuwen.Berserk.E" .. math.random(1,2))
	else
		caster:EmitSound("Lishuwen_Attack" .. math.random(1,4))
	end
    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( groundFx1, 1, target:GetAbsOrigin())
	local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( groundFx2, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControlOrientation(groundFx1, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
	ParticleManager:SetParticleControlOrientation(groundFx2, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
	local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_third_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function GrantFuriousChainBuff(caster)
	local tiger_strike_1 = caster:FindAbilityByName("lishuwen_tiger_strike_upgrade")
	local stack = caster:GetModifierStackCount("modifier_furious_chain_buff", caster) or 0 
	tiger_strike_1:ApplyDataDrivenModifier(caster, caster, "modifier_furious_chain_buff", {})
	stack = stack + 1
	if stack >= 3 then 
		stack = 3 
	end
	caster:SetModifierStackCount("modifier_furious_chain_buff", caster, stack)
end

function OnTigerStrikeWindow(caster,ability)
	if caster:HasModifier("modifier_tiger_strikes_window") then
		if caster:HasModifier("modifier_lishuwen_berserk") then
			if caster.bIsFuriousChainAcquired then
				if caster.tiger_strike == 1 then
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_berserk_2_upgrade", false, true)
				elseif caster.tiger_strike == 2 then 
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_berserk_3_upgrade", false, true)
				end
			else
				if caster.tiger_strike == 1 then
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_berserk_2", false, true)
				elseif caster.tiger_strike == 2 then 
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_berserk_3", false, true)
				end
			end
		else
			if caster.bIsFuriousChainAcquired then
				if caster.tiger_strike == 1 then
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_2_upgrade", false, true)
				elseif caster.tiger_strike == 2 then 
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_3_upgrade", false, true)
				end
			else
				if caster.tiger_strike == 1 then
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_2", false, true)
				elseif caster.tiger_strike == 2 then 
					caster:SwapAbilities(ability:GetAbilityName(), "lishuwen_tiger_strike_3", false, true)
				end
			end
		end
	end
end

function OnTigerStrikeWindowCreate(keys)
	local caster = keys.caster 

	if caster:HasModifier("modifier_lishuwen_berserk") then
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", "lishuwen_tiger_strike_berserk_2_upgrade", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_berserk", "lishuwen_tiger_strike_berserk_2", false, true)
		end
	else
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_upgrade", "lishuwen_tiger_strike_2_upgrade", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike", "lishuwen_tiger_strike_2", false, true)
		end
	end
end

function OnTigerStrikeWindowDestroy(keys)
	local caster = keys.caster 

	if caster:HasModifier("modifier_lishuwen_berserk") then
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_berserk", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		end
	else
		if caster.bIsFuriousChainAcquired then
			caster:SwapAbilities("lishuwen_tiger_strike_upgrade", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		else
			caster:SwapAbilities("lishuwen_tiger_strike", caster:GetAbilityByIndex(2):GetAbilityName(), true, false)
		end
	end
	--caster.tiger_strike = 0
end

function OnTigerStrikeWindowDeath(keys)
	local caster = keys.caster 
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:RemoveModifierByName("modifier_lishuwen_berserk")
	end
	caster:RemoveModifierByName("modifier_tiger_strikes_window")
end

function OnNSSCastStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	if target:GetName() == "npc_dota_ward_base" then
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	elseif caster:HasModifier("modifier_lishuwen_berserk") then 
		caster:Interrupt()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Berserk_is_Actived")
		return
	end
    local windupFx = ParticleManager:CreateParticle( "particles/custom/lishuwen/lishuwen_no_second_strike_windup.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( windupFx, 0, caster:GetAbsOrigin() + Vector(0,0,100))
    ParticleManager:SetParticleControl( windupFx, 3, caster:GetAbsOrigin() + Vector(0,0,100))

	if caster:HasModifier('modifier_alternate_02') then 
		caster:EmitSound("Li-Boss-R")
	else
		caster:EmitSound("Lishuwen_NP1")
	end

    Timers:CreateTimer(cast_delay, function()
		ParticleManager:DestroyParticle( windupFx, false )
		ParticleManager:ReleaseParticleIndex( windupFx )
    end)
end

function OnNSSStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("initial_damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local revoke_duration = ability:GetSpecialValueFor("revoke_duration")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_nss_anim_accel", {Duration = 1.0})

	if IsSpellBlocked(target) then return end

	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target, false)
	end
	-- do damage and apply CC

	if caster.bIsMartialArtsImproved then
		if caster:HasModifier("modifier_lishuwen_cosmic_orbit_attack") then 
			local qi_bonus = ability:GetSpecialValueFor("bonus_qi_per_stack")
			local stack = caster:GetModifierStackCount("modifier_lishuwen_cosmic_orbit_attack", caster)
			damage = damage + (stack * qi_bonus)

			caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit_attack")
			caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit_speed")
			caster:RemoveModifierByName("modifier_lishuwen_cosmic_orbit")
		end
	end

	if caster.bIsCirculatoryShockAcquired then
		local shock_damage = ability:GetSpecialValueFor("shock_damage")
		if not IsManaLess(target) then 
			target:SetMana(target:GetMana() - shock_damage)
		end	
	else		
		giveUnitDataDrivenModifier(caster,target,"revoked",revoke_duration)
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)

	if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_no_second_strike_shock", {})
	
		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		end
	end

	if caster.bIsCirculatoryShockAcquired and not target:IsAlive() then
		target.MasterUnit:SetMana(target.MasterUnit:GetMana() - 1) 
		target.MasterUnit2:SetMana(target.MasterUnit2:GetMana() - 1) 
	end
	
	-- apply delay indicator
	EmitGlobalSound("Lishuwen.NoSecondStrike")
    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx1, 0, target:GetAbsOrigin())
    local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx2, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControlOrientation(groundFx1, 1, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    ParticleManager:SetParticleControlOrientation(groundFx2, 1, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_no_second_strike_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnNSSShock(keys)
	local caster = keys.caster 
	local target = keys.target 

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end
	local ability = keys.ability 
	local shock_damage = ability:GetSpecialValueFor("shock_damage")
	local stun_duration = ability:GetSpecialValueFor("shock_stun")
	if caster.bIsCirculatoryShockAcquired then 
		if target.li_burn_count == nil then
			target.li_burn_count = 0
		end
		local mana_ratio = ability:GetSpecialValueFor("mana_ratio") / 100
		local mana_shock_damage = (target.li_burn_count + shock_damage) * mana_ratio
		
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		target.li_burn_count = 0

		if target:IsAlive() and not IsManaLess(target) then
			DoDamage(caster, target, mana_shock_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	else
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})

		DoDamage(caster, target, shock_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		
	end
end

function OnDragonStrike1Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local fail_cd = ability:GetSpecialValueFor("third_strike_failure_cdr") / 100
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("lishuwen_raging_dragon_strike")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1) * fail_cd)
	ability:EndCooldown()
	ability:StartCooldown(ability:GetCooldown(1) * fail_cd)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_cooldown", {duration = ability:GetCooldown(ability:GetLevel()) * fail_cd})

	local tigerStrikeAbility = caster:FindAbilityByName("lishuwen_tiger_strike")
	local tigerStrikeBerserkAbility = caster:FindAbilityByName("lishuwen_tiger_strike_berserk")
	if caster.bIsFuriousChainAcquired then 
		tigerStrikeAbility = caster:FindAbilityByName("lishuwen_tiger_strike_upgrade")
		tigerStrikeBerserkAbility = caster:FindAbilityByName("lishuwen_tiger_strike_berserk_upgrade")
	end
	local tigerStrikeCooldown = tigerStrikeAbility:GetCooldown(tigerStrikeAbility:GetLevel())
	tigerStrikeAbility:StartCooldown(tigerStrikeCooldown)
	tigerStrikeBerserkAbility:StartCooldown(tigerStrikeCooldown)

	if IsSpellBlocked(target) then return end

	--GrantCosmicOrbitResist(caster)
	--[[if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end]]

	caster.targetTable = {} 
	-- fire linear projectile 
	local projectile = 
	{
		Ability = keys.ability,
        EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
        iMoveSpeed = 9999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() - 150, -- give 50 unit buffer 
        fStartRadius = 250,
        fEndRadius = 250,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 0.1,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 9999
	}
	ProjectileManager:CreateLinearProjectile(projectile)

	-- Wait 1 frame to receive target info
	Timers:CreateTimer(0.034, function()
		local startpoint = caster:GetAbsOrigin()
		local endpoint = nil
		for k,v in pairs(caster.targetTable) do
			
			ApplyMarkOfFatality(caster, v, false)
			endpoint = v:GetAbsOrigin()
			local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, v )
			ParticleManager:SetParticleControl( trailFx, 1, startpoint )
			ParticleManager:SetParticleControl( trailFx, 0, endpoint )
			startpoint = v:GetAbsOrigin()
			v:EmitSound("Hero_EarthShaker.Attack")
			DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	end)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_window", {})

	caster.dragon_strike = 1
	OnRagingDragonStrikeWindow(caster)

	caster:EmitSound("Hero_EarthShaker.Attack")
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_first_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnDragonStrike1ProjectileHit(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	table.insert(caster.targetTable,target)
	if not IsImmuneToSlow(target) then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_raging_dragon_strike_1_slow", {})
	end
end

function OnDragonStrike2Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	--GrantCosmicOrbitResist(caster)
	caster.dragon_strike = 2
	OnRagingDragonStrikeWindow(caster)
	--[[if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
	end]]

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		
		if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) then
			v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.StunDuration})
		end
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	end
	caster:EmitSound("Hero_Centaur.HoofStomp")
	local risingWindFx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_second_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, caster:GetAbsOrigin())
end

vectors = {
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(500,-500,400),
	Vector(-300, 400, 500),
	Vector(0,-500, 500),
	Vector(300, 0, 400),
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(-300, 400, 500),
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(500,-500,400),
	Vector(-300, 400, 500),
	Vector(0,-500, 500),
	Vector(0,0, 0)
}
--vectorsV2[i] = vectors[i]-vectors[i-1], if i-1==0, then vectors[i-1] == (0,0,0), vectors sum up to 0 for V2.
vectorsV2 = {
	Vector(500, 500, 500),
	Vector(-1000,-1000,-200),
	Vector(1000,0,100),
	Vector(-800, 900, 100),
	Vector(300,-900, 0),
	Vector(300, 500, -100),
	Vector(200, 500, 100),
	Vector(-1000,-1000,-200),
	Vector(200, 900, 200),
	Vector(800, 100, 0),
	Vector(-1000,-1000,-200),
	Vector(1000,0,100),
	Vector(-800, 900, 100),
	Vector(300,-900, 0),
	Vector(0,500, -500)
}

function OnDragonStrike3Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	local count = keys.Count
	local bonus_damage = ability:GetSpecialValueFor("third_strike_bonus_damage") / 100
	
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

	if #targets >= 1 then 
		local masterCombo = caster.MasterUnit2:FindAbilityByName("lishuwen_raging_dragon_strike")
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(masterCombo:GetCooldown(1))

		caster:RemoveModifierByName("modifier_raging_dragon_strike_cooldown")
		local abil = caster:FindAbilityByName("lishuwen_raging_dragon_strike")
		abil:EndCooldown()
		abil:StartCooldown(abil:GetCooldown(1))
		abil:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_cooldown", {duration = abil:GetCooldown(abil:GetLevel())})
	else
		return 
	end

	keys.Damage = keys.Damage + (caster:GetAverageTrueAttackDamage(caster) * bonus_damage)

	local endpoint = nil
	local counter = 0

	--[[if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
	end]]
	-- knock them up and create counter
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() then
			v.nDragonStrikeComboCount = 0
			ApplyAirborne(caster, v, keys.KnockupDuration)
		end
	end

	giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", keys.KnockupDuration)
	StartAnimation(caster, {duration=keys.KnockupDuration, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})

	local dummy = CreateUnitByName("godhand_res_locator", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=2})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration=2})

	Timers:CreateTimer(0.2, function()
		if counter == count then 
			local position = caster:GetAbsOrigin()
			local dummyPosition = dummy:GetAbsOrigin()
			if not IsInSameRealm(position, dummyPosition) then
				position = dummyPosition
			end
			FindClearSpaceForUnit(caster, position, true)
			return 
		end

		local target = nil

        for i=1, 50 do
			local curIndex = math.random(#targets)
			if targets[curIndex].nDragonStrikeComboCount < count then
				targets[curIndex].nDragonStrikeComboCount = targets[curIndex].nDragonStrikeComboCount + 1
				target = targets[curIndex]
				break
			end
		end
		--[[for k,v in pairs(targets) do
			if v.nDragonStrikeComboCount < 8 then
				v.nDragonStrikeComboCount = v.nDragonStrikeComboCount + 1
				target = v
			end
		end]]

		if target == nil then 

		else
			if IsValidEntity(target) and not target:IsNull() then
			--print(target:GetName() .. counter)
				ApplyMarkOfFatality(caster, target, false)
				local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
		    	ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
		    	
				DoCompositeDamage(caster, target, keys.Damage, DAMAGE_TYPE_COMPOSITE, 0, keys.ability, false)
			end
		end

		--newpoint = Vector(startpoint.x + RandomInt(1,600), startpoint.y + RandomInt(1, 600), startpoint.y+500)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_3_anim", {})
		local currentpoint = caster:GetAbsOrigin()
		local newpoint = currentpoint+vectorsV2[counter+1]*0.5
		caster:SetAbsOrigin(newpoint)
		local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( trailFx, 1, currentpoint )
		ParticleManager:SetParticleControl( trailFx, 0, newpoint )

		caster:EmitSound("Hero_Tusk.WalrusPunch.Target")
		counter = counter + 1
		return 0.08
	end)

	caster:EmitSound("Hero_Earthshaker.Pick")
	--EmitGlobalSound("Lishuwen.Shout")
	--local soundQueue = math.random(1,3)

	EmitGlobalSound("Lishuwen_Combo_3_" .. math.random(1,3))

    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( groundFx1, 1, caster:GetAbsOrigin())
    local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( groundFx2, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlOrientation(groundFx1, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    ParticleManager:SetParticleControlOrientation(groundFx2, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_third_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, caster:GetAbsOrigin())
end

WUsed = false
WTime = 0

function LishuwenCheckCombo(caster, ability) 
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if ability:GetAbilityName() == "lishuwen_cosmic_orbit" or ability:GetAbilityName() == "lishuwen_cosmic_orbit_upgrade" then
			WUsed = true
			WTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				WUsed = false
			end
			})
		else
			if caster.bIsMartialArtsImproved and caster.bIsFuriousChainAcquired then 
				if ability:GetAbilityName() == "lishuwen_martial_arts_upgrade" and caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):IsCooldownReady() and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady() and not caster:HasModifier("modifier_raging_dragon_strike_cooldown") then
					if WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 5 - (newTime - WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_dragon_strikes_window", {duration = duration})
					end
				end
			elseif not caster.bIsMartialArtsImproved and caster.bIsFuriousChainAcquired then 
				if ability:GetAbilityName() == "lishuwen_martial_arts" and caster:FindAbilityByName("lishuwen_tiger_strike_upgrade"):IsCooldownReady() and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady() and not caster:HasModifier("modifier_raging_dragon_strike_cooldown") then
					if WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 5 - (newTime - WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_dragon_strikes_window", {duration = duration})
					end
				end
			elseif caster.bIsMartialArtsImproved and not caster.bIsFuriousChainAcquired then 
				if ability:GetAbilityName() == "lishuwen_martial_arts_upgrade" and caster:FindAbilityByName("lishuwen_tiger_strike"):IsCooldownReady() and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady() and not caster:HasModifier("modifier_raging_dragon_strike_cooldown") then
					if WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 5 - (newTime - WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_dragon_strikes_window", {duration = duration})
					end
				end
			elseif not caster.bIsMartialArtsImproved and not caster.bIsFuriousChainAcquired then 
				if ability:GetAbilityName() == "lishuwen_martial_arts" and caster:FindAbilityByName("lishuwen_tiger_strike"):IsCooldownReady() and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady() and not caster:HasModifier("modifier_raging_dragon_strike_cooldown") then
					if WUsed == true then 
						local newTime =  GameRules:GetGameTime()
						local duration = 5 - (newTime - WTime)
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_dragon_strikes_window", {duration = duration})
					end
				end
			end
		end
	end
end

function OnDragonStrikeWindowCreate(keys)
	local caster = keys.caster 
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetAbilityName(), "lishuwen_raging_dragon_strike", false, true)
	--[[if caster:HasModifier("modifier_lishuwen_berserk") then 
		if caster.bIsFuriousChainAcquired then 
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", "lishuwen_raging_dragon_strike", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_berserk", "lishuwen_raging_dragon_strike", false, true)
		end
	else
		if caster.bIsFuriousChainAcquired then 
			caster:SwapAbilities("lishuwen_tiger_strike_upgrade", "lishuwen_raging_dragon_strike", false, true)
		else
			caster:SwapAbilities("lishuwen_tiger_strike", "lishuwen_raging_dragon_strike", false, true)
		end
	end]]
end

function OnDragonStrikeWindowDestroy(keys)
	local caster = keys.caster 
	-- remove combo window 
	if caster:HasModifier("modifier_raging_dragon_strike_window") then 
		caster:RemoveModifierByName("modifier_raging_dragon_strike_window")
	end
	
	if caster:HasModifier("modifier_lishuwen_berserk") then 
		if caster.bIsFuriousChainAcquired then 
			caster:SwapAbilities("lishuwen_tiger_strike_berserk_upgrade", "lishuwen_raging_dragon_strike", true, false)
		else
			caster:SwapAbilities("lishuwen_tiger_strike_berserk", "lishuwen_raging_dragon_strike", true, false)
		end
	else
		if caster.bIsFuriousChainAcquired then 
			caster:SwapAbilities("lishuwen_tiger_strike_upgrade", "lishuwen_raging_dragon_strike", true, false)
		else
			caster:SwapAbilities("lishuwen_tiger_strike", "lishuwen_raging_dragon_strike", true, false)
		end
	end
end

function OnDragonStrikeWindowDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_dragon_strikes_window")
end

function OnRagingDragonStrikeWindow(caster)
	if caster:HasModifier("modifier_raging_dragon_strike_window") then
		if caster.dragon_strike == 1 then
			caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_raging_dragon_strike_2", false, true)
		elseif caster.dragon_strike == 2 then 
			caster:SwapAbilities("lishuwen_raging_dragon_strike_2", "lishuwen_raging_dragon_strike_3", false, true)
		end
	end
end

function OnRagingDragonStrikeWindowDestroy(keys)
	local caster = keys.caster 
	if caster.dragon_strike == 1 then
		caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_raging_dragon_strike_2", true, false)
	elseif caster.dragon_strike == 2 then 
		caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_raging_dragon_strike_3", true, false)
	end
	caster.dragon_strike = 0
end

function OnCirculatoryShockAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsCirculatoryShockAcquired) then

		hero.bIsCirculatoryShockAcquired = true

		if hero.bIsMartialArtsImproved then 
			UpgradeAttribute(hero, "lishuwen_no_second_strike_upgrade_2", "lishuwen_no_second_strike_upgrade_3", true)
		else
			UpgradeAttribute(hero, "lishuwen_no_second_strike", "lishuwen_no_second_strike_upgrade_1", true)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMartialArtsImproved(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsMartialArtsImproved) then

		hero.bIsMartialArtsImproved = true

		UpgradeAttribute(hero, "lishuwen_martial_arts", "lishuwen_martial_arts_upgrade", true)
		UpgradeAttribute(hero, "lishuwen_sphere_boundary", "lishuwen_sphere_boundary_upgrade", true)
		UpgradeAttribute(hero, "lishuwen_cosmic_orbit", "lishuwen_cosmic_orbit_upgrade", true)

		if hero.bIsCirculatoryShockAcquired then 
			UpgradeAttribute(hero, "lishuwen_no_second_strike_upgrade_1", "lishuwen_no_second_strike_upgrade_3", true)
		else
			UpgradeAttribute(hero, "lishuwen_no_second_strike", "lishuwen_no_second_strike_upgrade_2", true)
		end

		hero:RemoveModifierByName("modifier_martial_arts_aura")
		hero:FindAbilityByName("lishuwen_martial_arts_upgrade"):ApplyDataDrivenModifier(hero, hero, "modifier_martial_arts_aura", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDualClassAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsDualClassAcquired) then

		hero.bIsDualClassAcquired = true

		hero:FindAbilityByName("lishuwen_berserk"):SetLevel(1)
		hero:SwapAbilities("lishuwen_berserk", "fate_empty1", true, false) 

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnFuriousChainAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.bIsFuriousChainAcquired) then

		if hero:HasModifier("modifier_raging_dragon_strike_window") then 
			hero:RemoveModifierByName("modifier_raging_dragon_strike_window")
		end

		if hero:HasModifier("modifier_dragon_strikes_window") then 
			hero:RemoveModifierByName("modifier_dragon_strikes_window")
		end

		if hero:HasModifier("modifier_tiger_strikes_window") then 
			hero:RemoveModifierByName("modifier_tiger_strikes_window")
		end

		hero.bIsFuriousChainAcquired = true

		if hero:HasModifier("modifier_lishuwen_berserk") then 
			UpgradeAttribute(hero, "lishuwen_tiger_strike", "lishuwen_tiger_strike_upgrade", false)
			UpgradeAttribute(hero, "lishuwen_tiger_strike_berserk", "lishuwen_tiger_strike_berserk_upgrade", true)
		else
			UpgradeAttribute(hero, "lishuwen_tiger_strike", "lishuwen_tiger_strike_upgrade", true)
			UpgradeAttribute(hero, "lishuwen_tiger_strike_berserk", "lishuwen_tiger_strike_berserk_upgrade", false)
		end

		--[[UpgradeAttribute(hero, "lishuwen_tiger_strike_2", "lishuwen_tiger_strike_2_upgrade", false)
		UpgradeAttribute(hero, "lishuwen_tiger_strike_3", "lishuwen_tiger_strike_3_upgrade", false)
		UpgradeAttribute(hero, "lishuwen_tiger_strike_berserk_2", "lishuwen_tiger_strike_berserk_2_upgrade", false)
		UpgradeAttribute(hero, "lishuwen_tiger_strike_berserk_3", "lishuwen_tiger_strike_berserk_3_upgrade", false)]]

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end



