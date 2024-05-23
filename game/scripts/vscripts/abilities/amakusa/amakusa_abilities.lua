
--[[function OnBlackKeyStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local stack_gain = ability:GetSpecialValueFor("stack_gain")

	if caster:HasModifier("modifier_right_hand") then 
		stack_gain = ability:GetSpecialValueFor("stack_gain_r")
		AddRightHandStacks(caster, -1)
	end

	AddBlackKey(caster, stack_gain)
end

function OnBlackKeyAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local stack_gain = ability:GetSpecialValueFor("stack_gain")

	if caster:HasModifier("modifier_right_hand") then 
		stack_gain = ability:GetSpecialValueFor("stack_gain_r")
	end

	if target:IsRealHero() then
		AddBlackKey(caster, stack_gain)
	end
end]]

LinkLuaModifier("modifier_black_key_count", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function AddBlackKey(caster, stacks)
	local ability = caster:FindAbilityByName("amakusa_black_key_passive")
	local max_stack = ability:GetSpecialValueFor("max_stacks")
	local set = caster:GetAbilityByIndex(0)

	if not caster:IsAlive() then 
		caster:RemoveModifierByName("modifier_black_key_count")
		caster.blackkey_stack = 0
		if set:IsActivated() then
			set:SetActivated(false)
		end
		return 
	end

	if not caster:HasModifier("modifier_black_key_count") then 
		caster:AddNewModifier(caster, ability, "modifier_black_key_count", {})
		--ability:ApplyDataDrivenModifier(caster, caster, "modifier_black_key_count", {})
	end

	if caster.blackkey_stack == nil then 
		caster.blackkey_stack = 0 
	end

	local current_stack = caster.blackkey_stack or caster:GetModifierStackCount("modifier_black_key_count", caster) or 0 

	if stacks + current_stack <= 0 then 
		caster:RemoveModifierByName("modifier_black_key_count")
		caster.blackkey_stack = 0
		if set:IsActivated() then
			set:SetActivated(false)
		end
		print('remove')
	else
		caster.blackkey_stack = math.min(stacks + current_stack, max_stack)
		caster:SetModifierStackCount("modifier_black_key_count", caster, caster.blackkey_stack)
		if not set:IsActivated() then 
			set:SetActivated(true)
		end
	end
end

--[[function OnBlackKeyCreate(keys)
	local caster = keys.caster 
	local set = caster:GetAbilityByIndex(0)

	set:SetActivated(true)
end

function OnBlackKeyDestroy(keys)
	local caster = keys.caster 
	local set = caster:GetAbilityByIndex(0)

	set:SetActivated(false)
end

function OnBlackKeyDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_black_key_count")
	caster.blackkey_stack = 0
end]]

function OnRightHandStart(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local max_stacks = ability:GetSpecialValueFor("max_stacks")

	if caster:HasModifier("modifier_baptism_window") then 
		caster:RemoveModifierByName("modifier_baptism_window")
	end

	caster.current_mana = caster:GetMana()
	caster.righthand_stack = 0 

	if caster:HasModifier('modifier_alternate_01') then 
	caster:EmitSound("Amakusa-SkinR")
	else
	caster:EmitSound("Amakusa.RightHand")
	end

	if caster.IsLeftHandAcquired then 
		local bonus_duration = math.floor(caster.current_mana / ability:GetSpecialValueFor("mana_per_dur")) 
		local bonus_stacks = math.floor(caster.current_mana / ability:GetSpecialValueFor("mana_per_stack")) 
		duration = duration + bonus_duration
		max_stacks = max_stacks + bonus_stacks
		caster.current_mana = 0
		caster:SetMana(0)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_left_hand", {Duration = duration})
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_right_hand", {Duration = duration})
	AddRightHandStacks(caster, max_stacks)

	for i = 0,3 do 
		local re_ability = caster:GetAbilityByIndex(i)
		if re_ability ~= nil and not re_ability:IsCooldownReady() then 
			re_ability:EndCooldown()
			--if i < 3 then
			AddRightHandStacks(caster, -1)
			--end
		end
	end

	AmakusaCheckCombo(caster,ability)
end

function AddRightHandStacks(caster, stacks)
	local current_stack = caster.righthand_stack or caster:GetModifierStackCount("modifier_right_hand", caster)

	if stacks + current_stack <= 0 then 
		caster:RemoveModifierByName("modifier_right_hand")
		caster.righthand_stack = 0
	else
		caster.righthand_stack = math.max(stacks + current_stack, 0)
		caster:SetModifierStackCount("modifier_right_hand", caster, caster.righthand_stack)
	end
end

function OnRightHandCreate(keys)
	local caster = keys.caster 
	if caster.IsLeftHandAcquired then 
		caster:SwapAbilities('amakusa_right_hand_upgrade', 'amakusa_blink', false, true)
	else
		caster:SwapAbilities('amakusa_right_hand', 'fate_empty2', false, true)
	end
end

function OnRightHandDestroy(keys)
	local caster = keys.caster 
	if caster.IsLeftHandAcquired then 
		caster:SwapAbilities('amakusa_right_hand_upgrade', 'amakusa_blink', true, false)
		caster:RemoveModifierByName("modifier_left_hand")
	else
		caster:SwapAbilities('amakusa_right_hand', 'fate_empty2', true, false)
	end
end

function OnRIghtHandThink(keys)
	local caster = keys.caster 
	caster:SetMana(caster.current_mana)
end

function OnRiftStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	local leap_range = ability:GetSpecialValueFor("distance")

	if IsLocked(caster) then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end

    AddRightHandStacks(caster, -1)

    if (target_loc - caster:GetAbsOrigin()):Length2D() > leap_range then
		target_loc = caster:GetAbsOrigin() + (((target_loc - caster:GetAbsOrigin()):Normalized()) * leap_range)
	end

	local frontvec = (target_loc - caster:GetAbsOrigin()):Normalized()

	ProjectileManager:ProjectileDodge(caster)

	FindClearSpaceForUnit(caster, target_loc, true)

	local blink_out = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_blink.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(blink_out, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(blink_out, 1, target_loc)
	ParticleManager:SetParticleControl(blink_out, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(blink_out, 5, caster:GetAbsOrigin())

	caster:EmitSound("Hero_Silencer.Curse.Cast")

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(blink_out, false)
		ParticleManager:ReleaseParticleIndex(blink_out)
	end)
end

function OnRevelationDetect (keys)
	local caster = keys.caster
	local ability = keys.ability 
	local detect_aoe = ability:GetSpecialValueFor("detect_aoe")
	local target = keys.unit
	--print('hero ' .. target:GetName())
	local t_ability = target:GetCurrentActiveAbility()
	--print('ability use ' .. t_ability:GetAbilityName())
	--print('behavior ' .. t_ability:GetBehavior())

	if t_ability ~= nil then
		if t_ability:IsItem() or IsSpellBook(t_ability:GetAbilityName()) then return end

		if t_ability:GetBehavior() == 8 then
			if t_ability:GetCursorTarget() == caster then 
				print('being target')
				ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_vision", {})
			end
		elseif t_ability:GetBehavior() == 48 then
			if (t_ability:GetCursorPosition() - caster:GetAbsOrigin()):Length2D() <= detect_aoe then 
				print('skill near amakusa')
				ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_vision", {})
			end
		end
	end
end

function OnRevelationTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.attacker 
	ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_vision", {})
end

function OnIDPing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("ping_duration")
	--local delay = 0

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_amakusa_identity_cooldown", {Duration = ability:GetCooldown(1)})

    LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and playerHero:IsAlive() then  	
        	--delay = delay + 0.15
        	--Timers:CreateTimer(delay, function()
        	local amakusa_ping = CreateUnitByName("amakusa_ping", playerHero:GetAbsOrigin(), false, caster, caster, caster:GetOpposingTeamNumber())
			amakusa_ping:FindAbilityByName("ping_sign_no_enemy_passive"):SetLevel(1)
			--amakusa_ping:NotOnMinimapForEnemies()
			Timers:CreateTimer(duration, function()
			    --amakusa_ping:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})
			    amakusa_ping:RemoveSelf()
        	end)
        end
    end)
end

function OnAntiRulerAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local damage = keys.DamageDeal
	if target:IsRealHero() and CheckClass(target) == 'Ruler' then
		local anti_ruler = ability:GetSpecialValueFor("anti_ruler") / 100
		DoDamage(caster, target, damage * anti_ruler, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

LinkLuaModifier("modifier_baptism_window", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function AmakusaCheckCombo2(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "amakusa_god_resolution") then
			caster.EUsed = true
			caster.ETime = GameRules:GetGameTime()
			if caster.ETimer ~= nil then 
				Timers:RemoveTimer(caster.ETimer)
				caster.ETimer = nil
			end
			caster.ETimer = Timers:CreateTimer(3.0, function()
				caster.EUsed = false
			end)
		else
			if string.match(ability:GetAbilityName(), "amakusa_black_key_passive") and caster:FindAbilityByName("amakusa_baptism"):IsCooldownReady() and not caster:HasModifier("modifier_right_hand") and not caster:HasModifier("modifier_amakusa_twin_cooldown") and not caster:HasModifier("modifier_amakusa_baptism_cooldown") then
		 		if caster.EUsed == true then 
					local newTime =  GameRules:GetGameTime()
					local duration = 3 - (newTime - caster.ETime)
					caster:AddNewModifier(caster, nil, "modifier_baptism_window", {Duration = duration})
				end
			end
		end
	end
end

function AmakusaCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsLeftHandAcquired then
			if string.match(ability:GetAbilityName(), 'amakusa_right_hand') and caster:FindAbilityByName("amakusa_twin_arm_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_amakusa_twin_cooldown") and not caster:HasModifier("modifier_amakusa_baptism_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_twin_arm_window", {})	
			end
		else
			if string.match(ability:GetAbilityName(), 'amakusa_right_hand') and caster:FindAbilityByName("amakusa_twin_arm"):IsCooldownReady() and not caster:HasModifier("modifier_amakusa_twin_cooldown") and not caster:HasModifier("modifier_amakusa_baptism_cooldown") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_twin_arm_window", {})	
			end
		end
	end
end

function OnTwinWindowCreate(keys)
	local caster = keys.caster
	if caster.IsIdentifyAcquired and caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm_upgrade", "amakusa_identity_discernment", true, false) 
	elseif not caster.IsIdentifyAcquired and caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm_upgrade", "fate_empty1", true, false) 
	elseif caster.IsIdentifyAcquired and not caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm", "amakusa_identity_discernment", true, false) 
	elseif not caster.IsIdentifyAcquired and not caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm", "fate_empty1", true, false) 
	end
end

function OnTwinWindowDestroy(keys)
	local caster = keys.caster
	if caster.IsIdentifyAcquired and caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm_upgrade", "amakusa_identity_discernment", false, true) 
	elseif not caster.IsIdentifyAcquired and caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm_upgrade", "fate_empty1", false, true) 
	elseif caster.IsIdentifyAcquired and not caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm", "amakusa_identity_discernment", false, true) 
	elseif not caster.IsIdentifyAcquired and not caster.IsLeftHandAcquired then
		caster:SwapAbilities("amakusa_twin_arm", "fate_empty1", false, true) 
	end
end

function OnTwinDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_twin_arm_window")
end

function OnTwinArmStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_loc = ability:GetCursorPosition()
	local delay = ability:GetSpecialValueFor("delay")
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")

	caster:RemoveModifierByName("modifier_twin_arm_window")

	EmitGlobalSound("Amakusa.Pre_Combo" .. RandomInt(1, 3))

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_amakusa_twin_cooldown", {duration=ability:GetCooldown(1)})

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", delay + 0.1)	
	if caster:HasModifier("modifier_alternate_01") then 
		StartAnimation(caster, {duration= delay, activity=ACT_DOTA_CAST_ABILITY_4, rate=1 / delay})
	end
	local blackhole = CreateUnitByName("dummy_unit", target_loc, false, caster, caster, caster:GetTeamNumber())
	blackhole:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	blackhole:AddNewModifier(caster, nil, "modifier_kill", {duration= delay + duration + 1.5})
	caster.blackhole = blackhole

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("amakusa_twin_arm")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
		local sword = Attachments:GetCurrentAttachment(caster, "attach_sword")
		if sword ~= nil and not sword:IsNull() then 
			sword:RemoveSelf() 
		end
	end

	local left_hand = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_left_ball.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(left_hand, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(),false)
	
	local right_hand = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_right_ball.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(right_hand, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(),false)
	
	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(left_hand, true)
		ParticleManager:ReleaseParticleIndex(left_hand)
		ParticleManager:DestroyParticle(right_hand, true)
		ParticleManager:ReleaseParticleIndex(right_hand)
		if caster:ScriptLookupAttachment("attach_sword") ~= nil then 
			if caster:HasModifier("modifier_alternate_01") then 
				Attachments:AttachProp(caster, "attach_sword", "models/amakusa/amakusa_sword2.vmdl")
			else
				Attachments:AttachProp(caster, "attach_sword", "models/amakusa/amakusa_sword.vmdl")
			end
		end
		if caster:IsAlive() then
			if not IsInSameRealm(caster:GetAbsOrigin(), caster.blackhole:GetAbsOrigin()) then
				caster.blackhole:SetAbsOrigin(caster:GetAbsOrigin())
			end
			if caster:HasModifier("modifier_alternate_01") then 
				StartAnimation(caster, {duration= 0.5, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=2})
			else
				StartAnimation(caster, {duration= 0.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=2})	
			end
			
			local black_hole = {
				Target = blackhole,
				Source = caster, 
				Ability = ability,
				EffectName = "particles/custom/amakusa/amakusa_combo_fire_orb_projectile.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin(),
				iMoveSpeed = 1500,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				bDodgeable = false
			}

			local black_hole2 = {
				Target = blackhole,
				Source = caster, 
				Ability = ability,
				EffectName = "particles/custom/amakusa/amakusa_ice_orb_projectile.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin(),
				iMoveSpeed = 1500,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
				bDodgeable = false
			}
			ProjectileManager:CreateTrackingProjectile(black_hole) 
			ProjectileManager:CreateTrackingProjectile(black_hole2) 
		end

		--[[Timers:CreateTimer(delay, function()
			ability:ApplyDataDrivenModifier(caster, caster.blackhole, "modifier_amakusa_combo_ally", {})
			ability:ApplyDataDrivenModifier(caster, caster.blackhole, "modifier_amakusa_combo_enemy", {})
			
			local black_hold_Index = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_combo_blackhole.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.blackhole)
	  		ParticleManager:SetParticleControl(black_hold_Index, 0, target_loc)
	  		ParticleManager:SetParticleControl(black_hold_Index, 2, Vector(radius,0,0))
	  		Timers:CreateTimer(duration + 0.5, function()
	  			ParticleManager:DestroyParticle(black_hold_Index, true)
				ParticleManager:ReleaseParticleIndex(black_hold_Index)
			end)
		end)]]
	end)
end

function OnTwinArmHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")

	if not target:HasModifier("modifier_amakusa_combo_ally") then
		EmitGlobalSound("Amakusa.Combo")
		target:EmitSound("Hero_Enigma.Black_Hole.Stop")
		ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_combo_ally", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_combo_enemy", {})
		local black_hold_Index = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_combo_blackhole.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(black_hold_Index, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(black_hold_Index, 2, Vector(radius + 200,0,0))
		Timers:CreateTimer(duration + 0.5, function()
		  	ParticleManager:DestroyParticle(black_hold_Index, false)
			ParticleManager:ReleaseParticleIndex(black_hold_Index)
		end)
	end
end

function OnTwinArmThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local mana_drain = ability:GetSpecialValueFor("mana_drain")
	local interval = 0.1
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetSpecialValueFor("dmg")
	local mana_burn = mana_drain * interval
	--print(target:GetName() .. ' mana burn = ' .. mana_burn)

	if target:IsAlive() and caster:IsAlive() then 
		if not IsManaLess(target) and target:GetMana() > 0 then 
			target:SetMana(target:GetMana() - mana_burn)
		end
	end

	local unit_location = target:GetAbsOrigin()
	local vector_distance = caster.blackhole:GetAbsOrigin() - unit_location
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
		-- If the target is greater than 40 units from the center, we move them 40 units towards it, otherwise we move them directly to the center
	if distance >= 40 then
		target:SetAbsOrigin(unit_location + (direction * radius / 40))
	else
		target:SetAbsOrigin(unit_location + direction * distance)
	end

	DoDamage(caster, target, dmg * interval, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnKyrieStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_mark = ability:GetSpecialValueFor("max_mark")
	caster:RemoveModifierByName("modifier_baptism_window")

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("amakusa_twin_arm")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_amakusa_baptism", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_amakusa_baptism_cooldown", {duration=ability:GetCooldown(1)})
	caster:SetModifierStackCount("modifier_amakusa_baptism", caster, max_mark)

end

function OnKyrieCreate(keys)
	local caster = keys.caster
	caster:SwapAbilities("amakusa_baptism_chant", "amakusa_black_key_passive", true, false)
end

function OnKyrieDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SwapAbilities("amakusa_baptism_chant", "amakusa_black_key_passive", false, true)
end

function OnKyrieChant(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local max_mark = ability:GetSpecialValueFor("max_mark")
	
	local current_stack = caster:GetModifierStackCount("modifier_amakusa_baptism", caster)

	if current_stack - 1 <= 0 then 
		caster:RemoveModifierByName("modifier_amakusa_baptism")
	end

	caster:EmitSound("Amakusa.Kyrie" .. (max_mark - current_stack + 1))

	caster:SetModifierStackCount("modifier_amakusa_baptism", caster, current_stack - 1)

	local black_key = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/custom/amakusa/amakusa_kyrie.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1500,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		bDodgeable = false
	}
	ProjectileManager:CreateTrackingProjectile(black_key) 
	caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
end

function OnKyrieHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local max_mark = ability:GetSpecialValueFor("max_mark")
	local slow_dur = ability:GetSpecialValueFor("slow_dur")
	local dmg_per_mark = ability:GetSpecialValueFor("dmg_per_mark") / 100
	local dmg_vamp = ability:GetSpecialValueFor("dmg_vamp") / 100
	local dmg_human = ability:GetSpecialValueFor("dmg_human") / 100
	local max_hp = target:GetMaxHealth()

	local damage = dmg_per_mark * max_hp

	if IsHuman(target) then 
		damage = dmg_human * max_hp
	elseif IsVampire(target) then 
		damage = dmg_vamp * max_hp
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, ability, false)

	if not IsValidEntity(target) or target:IsNull() then return end

	if target:IsAlive() then

		if not target:HasModifier("modifier_amakusa_baptism_mark") then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_baptism_mark", {})
		end
	
		if IsVampire(target) then 
			giveUnitDataDrivenModifier(caster, target, "rooted", slow_dur)
			giveUnitDataDrivenModifier(caster, target, "locked", slow_dur)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_baptism_mark_slow", {})
		elseif IsHuman(target) then 
			giveUnitDataDrivenModifier(caster, target, "locked", slow_dur)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_baptism_mark_slow", {})
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_amakusa_baptism_mark_slow", {})
		end

		local current_stack = target:GetModifierStackCount("modifier_amakusa_baptism_mark", caster) or 0
		target:SetModifierStackCount("modifier_amakusa_baptism_mark", caster, current_stack + 1)

		if current_stack + 1 >= max_mark then 
			giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
			target:Execute(ability, caster, { bExecution = true })
		end
	end
end

--------------------------------------

amakusa_black_key_passive = class({})

LinkLuaModifier("modifier_black_key_passive", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function amakusa_black_key_passive:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_right_hand") then 
		return 1 
	else
		return self:GetSpecialValueFor("cooldown")
	end
end

function amakusa_black_key_passive:GetManaCost(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_right_hand") then 
		return 0 
	else
		return 100
	end
end

function amakusa_black_key_passive:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self 
	local stack_gain = ability:GetSpecialValueFor("stack_gain")

	if caster:HasModifier("modifier_right_hand") then 
		stack_gain = ability:GetSpecialValueFor("stack_gain_r")
		AddRightHandStacks(caster, -1)
	end
	print('active gain stack')
	AddBlackKey(caster, stack_gain)

	if caster.IsChurchAcquired then 
		AmakusaCheckCombo2(caster,ability)
	end
end

function amakusa_black_key_passive:GetIntrinsicModifierName()
	return "modifier_black_key_passive"
end

------------------------------------

modifier_black_key_passive = class({})

function modifier_black_key_passive:IsHidden()
	return true 
end

function modifier_black_key_passive:IsDebuff()
	return false 
end

function modifier_black_key_passive:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_black_key_passive:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() or not args.target:IsHero() then return end
		local caster = self:GetCaster()
		local target = args.target
		local ability = self:GetAbility() 
		local stack_gain = ability:GetSpecialValueFor("stack_gain")

		if caster:HasModifier("modifier_right_hand") then 
			stack_gain = ability:GetSpecialValueFor("stack_gain_r")
		end

		print('caster = ' .. caster:GetName() .. ' , target ' .. target:GetName())
		if target:IsRealHero() then
			print('attack gain stack')
			AddBlackKey(caster, stack_gain)
		end
	end
end

----------------------------------

modifier_black_key_count = class({})

function modifier_black_key_count:OnCreated(args)
	local caster = self:GetCaster()
	--[[local set = caster:FindAbilityByName("amakusa_set")
	if set == nil then 
		set = caster:FindAbilityByName("amakusa_set_upgrade")
	end

	set:SetActivated(true)]]
end

function modifier_black_key_count:OnDestroy(args)
	local caster = self:GetCaster()
	--[[local set = caster:FindAbilityByName("amakusa_set")
	if set == nil then 
		set = caster:FindAbilityByName("amakusa_set_upgrade")
	end]]
	caster.blackkey_stack = 0
	--set:SetActivated(false)
end

function modifier_black_key_count:RemoveOnDeath()
	return true
end

function modifier_black_key_count:OnDeath()
	self.caster = self:GetParent()
	self.caster.blackkey_stack = 0
end

function modifier_black_key_count:IsHidden()
	return false 
end

function modifier_black_key_count:IsDebuff()
	return false 
end

function modifier_black_key_count:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------------

--[[amakusa_charisma = class({})

LinkLuaModifier("modifier_amakusa_charisma", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function amakusa_charisma:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_right_hand") then 
		return 0 
	else
		return self:GetSpecialValueFor("cooldown")
	end
end

function amakusa_charisma:GetManaCost(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_right_hand") then 
		return 0 
	else
		return 100
	end
end

function amakusa_charisma:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self 
	local cd_red = ability:GetSpecialValueFor("cd_red")
	local target = self:GetCursorTarget()

	target:Heal(self:GetSpecialValueFor("heal") * target:GetMaxHealth() / 100, caster)
	target:AddNewModifier(caster, ability, "modifier_amakusa_charisma", {Duration = self:GetSpecialValueFor("duration"),
																		Mana = self:GetSpecialValueFor("bonus_mana")})
	if caster:HasModifier("modifier_aestus_domus_aurea_nero") then 

	end

	for i = 0,5 do 
		if i ~= 3 and i ~= 4 then 
			local tability = target:GetAbilityByIndex(i)
			if tability ~= nil and not tability:IsCooldownReady() then
				local t_cd = tability:GetCooldownTimeRemaining() 
				tability:EndCooldown()
				tability:StartCooldown(t_cd - cd_red)
			end
		end
	end
end

modifier_amakusa_charisma = class({})

function modifier_amakusa_charisma:OnCreated(args)
	self.target = self:GetParent()
	self.Bonus_mana = args.Mana / 100
end

function modifier_amakusa_charisma:DeclareFunctions()
	return { MODIFIER_PROPERTY_MANA_BONUS }
end

function modifier_amakusa_charisma:GetModifierManaBonus()
	if IsManaLess(self.target) then 
		return 0 
	else
		return self.target:GetMaxMana() * self.Bonus_mana
	end
end

function modifier_amakusa_charisma:IsHidden()
	return false 
end

function modifier_amakusa_charisma:IsDebuff()
	return false 
end

function modifier_amakusa_charisma:GetAttributes()
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end]]

-----------------------------------------------------------

amakusa_set = class({})
amakusa_set_upgrade = class({})

function amakusa_set_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 1 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:OnUpgrade()
		local caster = self:GetCaster()
		local key = caster:FindAbilityByName("amakusa_black_key_passive")
		key:SetLevel(self:GetLevel())
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 0 
		else
			return 100
		end
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_black_key_count") then 
			local black_key_counter = 0
			local stacks = caster:GetModifierStackCount("modifier_black_key_count", caster) or caster.blackkey_stack

			AddBlackKey(caster, -stacks)
			caster:RemoveModifierByName("modifier_black_key_count")

			if caster:HasModifier("modifier_right_hand") then 
				AddRightHandStacks(caster, -1)
			end

			local black_key = {
				Target = nil,
				Ability = self,
				EffectName = "particles/custom/amakusa/amakusa_set.vpcf",
				vSourceLoc = nil,
				iMoveSpeed = 1500,
				bDrawsOnMinimap = false, 
				bVisibleToEnemies = true,
				bProvidesVision = false, 
				flExpireTime = GameRules:GetGameTime() + 10, 
				bDodgeable = true
			}

			caster:EmitSound("Amakusa.Set")

			Timers:CreateTimer('amakusa_set' .. caster:GetPlayerOwnerID(), {
				endTime = 0.05,
				callback = function()
				if black_key_counter == stacks then return nil end

				black_key_counter = black_key_counter + 1

				local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
				for i = 1, #enemies do
					if not caster:CanEntityBeSeenByMyTeam(enemies[i]) then
						enemies[i] = nil
					end
				end
				--table.sort( enemies )
				if #enemies > 0 then

					local frontward = caster:GetForwardVector()
					local leftvec = Vector(-frontward.y, frontward.x, 0)
					local rightvec = Vector(frontward.y, -frontward.x, 0)

					local random1 = RandomInt(0, 250)
					local random2 = RandomInt(0,1)
					local spawn = caster:GetAbsOrigin() + Vector(-frontward.x * 150, -frontward.y * 150, 300)

					if random2 == 0 then 
						spawn = spawn + leftvec*random1
					else 
						spawn = spawn + rightvec*random1
					end
						
					local random = RandomInt(1, #enemies)
					if not IsValidEntity(enemies[random]) or enemies[random]:IsNull() then 
						table.remove(enemies, random)
						if #enemies == 0 then return 0.05 end
						random = RandomInt(1, #enemies)
					end
					local direction = (enemies[random]:GetAbsOrigin() - spawn):Normalized()

					local angle = VectorToAngles(direction)

					local MCFx = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_set_cicle.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(MCFx, 0, spawn) 
					ParticleManager:SetParticleControl(MCFx, 1, Vector(0,0,angle.y + 90)) 

					black_key.Target = enemies[1]
					black_key.vSourceLoc = spawn
					
					ProjectileManager:CreateTrackingProjectile(black_key) 
					caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
					Timers:CreateTimer(0.7, function()
						ParticleManager:DestroyParticle(MCFx, true)
						ParticleManager:ReleaseParticleIndex(MCFx)
					end)
				end
				return 0.05
			end})
		end
	end

	function ability:OnProjectileHit_ExtraData(hTarget, vLocation, table)
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("dmg")
		local stun = self:GetSpecialValueFor("stun")

		if not IsValidEntity(hTarget) or hTarget:IsNull() then return end

		if caster.IsChurchAcquired then
			damage = damage + (self:GetSpecialValueFor("bonus_int") * caster:GetIntellect())
		end

		if not IsImmuneToCC(hTarget) and not hTarget:IsMagicImmune() then
			hTarget:AddNewModifier(caster, self, "modifier_stunned", {Duration = stun})
		end

		DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		
	end
end

amakusa_set_wrapper(amakusa_set)
amakusa_set_wrapper(amakusa_set_upgrade)

---------------------------

amakusa_bombard = class({})
amakusa_bombard_upgrade = class({})

function amakusa_bombard_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 1 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 0 
		else
			return 200
		end
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("aoe")
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target_loc = self:GetCursorTarget():GetAbsOrigin()
		local delay = self:GetSpecialValueFor("delay")
		local aoe = self:GetSpecialValueFor("aoe")
		local dmg = self:GetSpecialValueFor("dmg")
		local stun_duration = self:GetSpecialValueFor("stun_duration")
		local root = self:GetSpecialValueFor("root")

		if caster:HasModifier("modifier_right_hand") then 
			AddRightHandStacks(caster, -1)
		end

		caster:EmitSound("Amakusa.Set")

		local bombard_ring = {}
		local bombard_sword = {}
		local angle = 60
		local total_sword = 6

		if caster.IsChurchAcquired then 
			angle = 45
			total_sword = 8
		end

		for i = 0,(total_sword / 2) - 1 do
			bombard_ring[i] = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_bombard_ring.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(bombard_ring[i], 1, Vector(aoe + 100, 0, 0))
			ParticleManager:SetParticleControl(bombard_ring[i], 2, target_loc)
			ParticleManager:SetParticleControl(bombard_ring[i], 4, Vector(i * angle, 0, 0))
			ParticleManager:SetParticleControl(bombard_ring[i], 5, Vector(0, 0, (i * angle) + 90))
		end

		Timers:CreateTimer(delay + 1.0, function()
			for j = 0,(total_sword / 2) - 1 do 
				ParticleManager:DestroyParticle(bombard_ring[j], true)
				ParticleManager:ReleaseParticleIndex(bombard_ring[j])
			end
		end)

		for j = 0,total_sword - 1 do 
			local start_point = GetRotationPoint(target_loc,aoe + 100, j * angle) + Vector(0, 0, 300)
			bombard_sword[j] = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_bombard_sword.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(bombard_sword[j], 2, target_loc)
			ParticleManager:SetParticleControl(bombard_sword[j], 3, start_point)
			if j < (total_sword / 2) + 1 then
				ParticleManager:SetParticleControl(bombard_sword[j], 4, Vector((j * angle / 2), (j * angle / 2) - 45, j * angle) )
			else
				local k = total_sword - j
				ParticleManager:SetParticleControl(bombard_sword[j], 4, Vector((k * angle / 2) - 45, (k * angle / 2), j * angle) )
			end
		end

		EmitSoundOnLocationWithCaster(target_loc, "Hero_SkywrathMage.ConcussiveShot.Cast", caster)

		Timers:CreateTimer(delay, function()
			local blast_fx = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_bombard_blast.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(blast_fx, 3, target_loc + Vector(0,0,200))
			ParticleManager:SetParticleControl(blast_fx, 3, target_loc + Vector(0,0,200))
			ParticleManager:SetParticleControl(blast_fx, 5, Vector(aoe/20,0,0))
			ParticleManager:SetParticleControl(blast_fx, 6, Vector(aoe/2,0,0))

			EmitSoundOnLocationWithCaster(target_loc, "Hero_razor.lightning", caster)

			for i = 0,total_sword - 1 do 
				ParticleManager:DestroyParticle(bombard_sword[i], true)
				ParticleManager:ReleaseParticleIndex(bombard_sword[i])
			end
			
			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(blast_fx, true)
				ParticleManager:ReleaseParticleIndex(blast_fx)
			end)
			
			local enemies = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(enemies) do 

				if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) and not v:IsMagicImmune() then
					v:AddNewModifier(caster, self, "modifier_stunned", {Duration = stun_duration})
					giveUnitDataDrivenModifier(caster, v, "locked", root)
				end
				DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, self, false)				
			end
		end)
	end
end

amakusa_bombard_wrapper(amakusa_bombard)
amakusa_bombard_wrapper(amakusa_bombard_upgrade)

----------------------------------

amakusa_god_resolution = class({})
amakusa_god_resolution_upgrade = class({})

LinkLuaModifier("modifier_amakusa_god_buff", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amakusa_god_slow", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function amakusa_god_res_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 1 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_right_hand") then 
			return 0 
		else
			return 400
		end
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local pray_aoe = self:GetSpecialValueFor("pray_aoe")
		local pray_dmg = self:GetSpecialValueFor("pray_dmg")
		local pray_slow = self:GetSpecialValueFor("pray_slow")
		local pray_slow_dur = self:GetSpecialValueFor("pray_slow_dur")
		local god_duration = self:GetSpecialValueFor("god_duration")

		if caster:HasModifier("modifier_right_hand") then 
			AddRightHandStacks(caster, -1)
		end

		if caster:HasModifier("modifier_alternate_01") then
			caster:EmitSound("Amakusa.GodRes" .. RandomInt(1, 2))
		else
			caster:EmitSound("Amakusa.GodRes" .. RandomInt(3, 4))
		end

		caster:AddNewModifier(caster, self, "modifier_amakusa_god_buff", {Duration = god_duration})

		local light_wave = ParticleManager:CreateParticle("particles/custom/amakusa/amakusa_god_strike_immortal1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(light_wave, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(light_wave, 1, Vector(1,0,0))

		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle(light_wave, false)
			ParticleManager:ReleaseParticleIndex(light_wave)
		end)

		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, pray_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(enemies) do 
			if IsValidEntity(v) and not v:IsNull() then
				if not IsImmuneToSlow(v) and not v:IsMagicImmune() then
					v:AddNewModifier(caster, self, "modifier_amakusa_god_slow", {Duration = pray_slow_dur,
																				Slow = pray_slow})
				end

				if caster.IsAntiRulerAcquired then 
					giveUnitDataDrivenModifier(caster, v, "revoked", pray_slow_dur)
				end

				DoDamage(caster, v, pray_dmg, DAMAGE_TYPE_MAGICAL, 0, self, false)
			end
		end

		if caster.IsChurchAcquired then 
			AmakusaCheckCombo2(caster, self)
		end
	end
end

amakusa_god_res_wrapper(amakusa_god_resolution)
amakusa_god_res_wrapper(amakusa_god_resolution_upgrade)

-----------------------------------------

modifier_amakusa_god_slow = class({})

function modifier_amakusa_god_slow:OnCreated(args)
	self.slow = args.Slow 
end

function modifier_amakusa_god_slow:IsDebuff()
	return true 
end

function modifier_amakusa_god_slow:IsHidden()
	return false 
end

function modifier_amakusa_god_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_amakusa_god_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

------------------------------------------

modifier_amakusa_god_buff = class({})

LinkLuaModifier("modifier_amakusa_god_hit_slow", "abilities/amakusa/amakusa_abilities", LUA_MODIFIER_MOTION_NONE)

function modifier_amakusa_god_buff:OnCreated(args)
	local ability = self:GetAbility()
	self.atk_count = ability:GetSpecialValueFor("atk_count")
	self.light_dmg = ability:GetSpecialValueFor("light_dmg")
	self.light_aoe = ability:GetSpecialValueFor("light_aoe")
end

function modifier_amakusa_god_buff:IsDebuff()
	return false 
end

function modifier_amakusa_god_buff:IsHidden()
	return false 
end

function modifier_amakusa_god_buff:OnRefresh(args)
	if IsServer() then
		self:OnCreated(args)		
	end
end

function modifier_amakusa_god_buff:RemoveOnDeath()
	return true
end

function modifier_amakusa_god_buff:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_amakusa_god_buff:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_amakusa_god_buff:OnAttackLanded(args)
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local target = args.target
	local damage_type = DAMAGE_TYPE_MAGICAL
	local slow = ability:GetSpecialValueFor("light_slow_dur")

	if args.attacker ~= self:GetParent() or target:GetName() == "npc_dota_ward_base" then return end

	if caster.IsAntiRulerAcquired then 
		damage_type = DAMAGE_TYPE_PURE
	end

	local current_stack = self:GetStackCount() or 0 

	self:SetStackCount(math.min(self.atk_count, current_stack + 1))

	if self:GetStackCount() >= self.atk_count then 
		self:SetStackCount(0)
		StartAnimation(caster, {duration= 0.5, activity=ACT_DOTA_ATTACK_EVENT, rate=2})
		local light_strike = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(light_strike, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(light_strike, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(light_strike, 2, Vector(0,0,0))

		target:EmitSound("Hero_Invoker.SunStrike.Ignite.Apex")

		local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, self.light_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(enemies) do 
			if IsValidEntity(v) and not v:IsNull() then
				if caster.IsAntiRulerAcquired then 
					giveUnitDataDrivenModifier(caster, v, "revoked", slow)
				end
				if not IsImmuneToSlow(v) and not v:IsMagicImmune() then
					v:AddNewModifier(caster, ability, "modifier_amakusa_god_hit_slow", {Duration = slow,
																				Slow = ability:GetSpecialValueFor("light_slow")})
				end
				DoDamage(caster, v, self.light_dmg, damage_type, 0, ability, false)
			end
		end
	end
end

function modifier_amakusa_god_buff:GetEffectName()
	return "particles/custom/amakusa/amakusa_god.vpcf"
end

function modifier_amakusa_god_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-----------------------------------------

modifier_amakusa_god_hit_slow = class({})

function modifier_amakusa_god_hit_slow:OnCreated(args)
	self.slow = args.Slow 
end

function modifier_amakusa_god_hit_slow:IsDebuff()
	return true 
end

function modifier_amakusa_god_hit_slow:IsHidden()
	return false 
end

function modifier_amakusa_god_hit_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_amakusa_god_hit_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

-----------------------------------------

modifier_baptism_window = class({})
if IsServer() then
	function modifier_baptism_window:OnCreated(args)
		local caster = self:GetParent()
		if caster.IsAntiRulerAcquired then
			caster:SwapAbilities('amakusa_god_resolution_upgrade', 'amakusa_baptism', false, true)
		else
			caster:SwapAbilities('amakusa_god_resolution', 'amakusa_baptism', false, true)
		end
	end

	function modifier_baptism_window:OnDestroy()
		local caster = self:GetParent()
		if caster.IsAntiRulerAcquired then
			caster:SwapAbilities('amakusa_god_resolution_upgrade', 'amakusa_baptism', true, false)
		else
			caster:SwapAbilities('amakusa_god_resolution', 'amakusa_baptism', true, false)
		end
	end
end

function modifier_baptism_window:IsDebuff()
	return false 
end

function modifier_baptism_window:IsHidden()
	return true 
end

function modifier_baptism_window:GetAttributes()
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE}
end

function modifier_baptism_window:RemoveOnDeath()
	return true
end

function OnRevelationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRevelationAcquired) then

		hero.IsRevelationAcquired = true

		hero:FindAbilityByName("amakusa_revelation"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnLeftHandAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsLeftHandAcquired) then

		if hero:HasModifier("modifier_twin_arm_window") then 
			hero:RemoveModifierByName("modifier_twin_arm_window")
		end

		hero.IsLeftHandAcquired = true

		UpgradeAttribute(hero, "amakusa_right_hand", "amakusa_right_hand_upgrade", true)
		UpgradeAttribute(hero, "amakusa_twin_arm", "amakusa_twin_arm_upgrade", false)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnIdentifyAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsIdentifyAcquired) then

		if hero:HasModifier("modifier_twin_arm_window") then 
			hero:RemoveModifierByName("modifier_twin_arm_window")
		end

		hero.IsIdentifyAcquired = true

		hero:SwapAbilities("fate_empty1", "amakusa_identity_discernment", false, true)

		hero.IsRevelationAcquired = true

		hero:FindAbilityByName("amakusa_revelation"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnChurchAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsChurchAcquired) then

		hero.IsChurchAcquired = true

		UpgradeAttribute(hero, "amakusa_set", "amakusa_set_upgrade", true)
		UpgradeAttribute(hero, "amakusa_bombard", "amakusa_bombard_upgrade", true)

		if not hero:HasModifier("modifier_black_key_count") then 
			hero:FindAbilityByName("amakusa_set_upgrade"):SetActivated(false)
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAntiRulerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAntiRulerAcquired) then

		if hero:HasModifier("modifier_baptism_window") then 
			hero:RemoveModifierByName("modifier_baptism_window")
		end

		hero.IsAntiRulerAcquired = true

		UpgradeAttribute(hero, "amakusa_god_resolution", "amakusa_god_resolution_upgrade", true)
		hero:FindAbilityByName("amakusa_anti_ruler"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end