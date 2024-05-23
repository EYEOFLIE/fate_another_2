true_assassin_selfmod = class({})

LinkLuaModifier("modifier_true_assassin_selfmod", "abilities/true_assassin/modifiers/modifier_true_assassin_selfmod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_selfmod_agility", "abilities/true_assassin/modifiers/modifier_selfmod_agility", LUA_MODIFIER_MOTION_NONE)

function true_assassin_selfmod:GetAOERadius()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_shaytan_arm_attribute") then
		return 425
	else
		return 0
	end
end

function true_assassin_selfmod:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local fHeal = self:GetSpecialValueFor("heal_amount")

	caster:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
	caster:Heal(fHeal, caster)
	caster:AddNewModifier(caster, ability, "modifier_true_assassin_selfmod", {	Duration = self:GetSpecialValueFor("duration"),
																			 	HealAmt = self:GetSpecialValueFor("actual_heal_over_time"),
																			 	BonusStats = self:GetSpecialValueFor("bonus_stats")
																			 })

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			return nil
	end)

	if caster.ShaytanArmAcquired then
		local casterStr = math.floor(caster:GetStrength() + 0.5) 
		local casterAgi = math.floor(caster:GetAgility() + 0.5)
		local casterInt = math.floor(caster:GetIntellect() + 0.5)

		if casterStr == casterAgi and casterStr == casterInt and casterAgi == casterInt then
			self:ReduceZabaniyaCooldown(true)
			if not caster.IsWeakeningVenomAcquired then
				caster:AddNewModifier(caster, ability, "modifier_selfmod_agility", { Duration = self:GetSpecialValueFor("duration"),
																					 AttackBonus = casterAgi
																					})
			end
			self:IntelligenceHeal(true)
		elseif casterStr >= casterAgi and casterStr >= casterInt then
			self:ReduceZabaniyaCooldown(false)
		elseif casterAgi > casterStr and casterAgi >= casterInt then
			if not caster.IsWeakeningVenomAcquired then
				caster:AddNewModifier(caster, ability, "modifier_selfmod_agility", { Duration = self:GetSpecialValueFor("duration"),
																					 AttackBonus = casterAgi * 3
																					 })
			end
		elseif casterInt > casterStr and casterInt > casterAgi then
			self:IntelligenceHeal(false)
		end
	end
end

function true_assassin_selfmod:IntelligenceHeal(halfEfficiency)
	local caster = self:GetCaster()
	local area = 425
	local amount = 15 * math.ceil(caster:GetIntellect())

	if halfEfficiency then amount = amount * 0.5 end

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, area, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for i = 1, #targets do
		targets[i]:Heal(amount, caster)

		if not IsManaLess(targets[i]) then
			targets[i]:GiveMana(amount)
		end

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, targets[i])
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
		-- Destroy particle after delay
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			return nil
		end)
	end
end

function true_assassin_selfmod:ReduceZabaniyaCooldown(halfEfficiency)
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("true_assassin_zabaniya")
	local cooldownPerStr = 0.5
	local casterStr = math.floor(caster:GetStrength()) 

	if halfEfficiency then cooldownPerStr = 0.25 end

	if not ability:IsCooldownReady() then
		local cooldown = ability:GetCooldownTimeRemaining()
		cooldown = cooldown - casterStr * cooldownPerStr
		ability:EndCooldown()
		if cooldown > 0 then
			ability:StartCooldown(cooldown)
		end
	end
end