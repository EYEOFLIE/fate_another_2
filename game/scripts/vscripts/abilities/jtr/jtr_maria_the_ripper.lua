jtr_maria_the_ripper = class({})

function jtr_maria_the_ripper:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_murderer_mist_invis") then
		return self:GetSpecialValueFor("reduced_cast_point")
	else
		return self:GetSpecialValueFor("cast_point")
	end
end

function jtr_maria_the_ripper:CastFilterResultTarget(hTarget)
	if hTarget:GetName() == "npc_dota_ward_base" then 
		return UF_FAIL_CUSTOM
	end

	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
	
	return filter
end

function jtr_maria_the_ripper:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function jtr_maria_the_ripper:GetCustomCastErrorTarget(hTarget)
	return "Cannot Target Wards"
end

function jtr_maria_the_ripper:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	StartAnimation(caster, {duration = 1.2, activity= ACT_DOTA_CAST_ABILITY_4 , rate=1.5})

	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = 1.1})
	giveUnitDataDrivenModifier(caster, caster, "dragged", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "revoked", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.1)

    target:EmitSound("jtr_maria_slashes")
	EmitGlobalSound("jtr_maria_the_ripper")

	Timers:CreateTimer(0.25, function()  
		if caster:IsAlive() and target:IsAlive() then
			self:PerformSlash(caster, target)
		else
			caster:RemoveModifierByName("jump_pause")
		end
		return 
	end)

	Timers:CreateTimer(0.5, function()  
		if caster:IsAlive() and target:IsAlive() then
			self:PerformSlash(caster, target)
		else
			caster:RemoveModifierByName("jump_pause")
		end
		return 
	end)

	Timers:CreateTimer(0.75, function()  
		if caster:IsAlive() and target:IsAlive() then
			StartAnimation(caster, {duration = 1.2, activity= ACT_DOTA_CAST_ABILITY_4_END , rate=1.5})
			self:PerformSlash(caster, target)
		else
			caster:RemoveModifierByName("jump_pause")
		end
		return 
	end)

	Timers:CreateTimer(1, function()  
		if caster:IsAlive() and target:IsAlive() then
			self:PerformSlash(caster, target)
			if target:HasModifier("modifier_whitechapel_murderer_enemy") and IsFemaleServant(target) then
				local curse_resistance = target:GetBaseMagicalResistanceValue() + (target:GetMagicalArmorValue() - target:GetBaseMagicalResistanceValue()) * 0.5
				print('Base Resistance = ' .. target:GetBaseMagicalResistanceValue())
				print('Bonus Resistance = ' .. target:GetMagicalArmorValue())
				print('Curse Resistance = ' .. curse_resistance)
				if curse_resistance > 30 then 
					curse_resistance = 30
				end
				if caster:HasModifier("modifier_holy_mother_buff") then
					local stack = caster:GetModifierStackCount("modifier_holy_mother_buff", caster) or 0
					curse_resistance = curse_resistance - stack
					if curse_resistance <= 0 then 
						curse_resistance = 0
					end
				end
				if RandomInt(1, 100) <= 100 - curse_resistance then 
					--DoDamage(caster, target, 9999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_NONE, self, false)
					if IsUnExecute(target) then
						DoDamage(caster, target, 9999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_NONE, self, false)
					else
						target:Execute(ability, caster, { bExecution = true })
						local curseIndex = ParticleManager:CreateParticle("particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownmarker_steam.vpcf", PATTACH_ABSORIGIN_FOLLOW, nil )
						ParticleManager:SetParticleControl(curseIndex, 0, target:GetAbsOrigin())
						ParticleManager:SetParticleControl(curseIndex, 2, Vector(50,0,0))
						Timers:CreateTimer(1.0, function()  
							ParticleManager:DestroyParticle(curseIndex, false)
							ParticleManager:ReleaseParticleIndex(curseIndex)
							return 
						end)
					end
				end
			end
		end

		caster:RemoveModifierByName("jump_pause")
		return 
	end)
end

function jtr_maria_the_ripper:PerformSlash(caster, target)
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized()
	local damage = self:GetSpecialValueFor("damage_per_hit") 

	if caster:HasModifier("modifier_efficient_killer") then
		damage = damage + caster:GetAgility() * 0.5
		target:AddNewModifier(caster, self, "modifier_stunned", { Duration = 0.1 })
	end

	caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100) 

	local slashIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())

	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	Timers:CreateTimer(0.25, function()  
		ParticleManager:DestroyParticle(slashIndex, false)
		ParticleManager:ReleaseParticleIndex(slashIndex)
		return 
	end)

	if IsSpellBlocked(target) then return end

	if IsFemaleServant(target) then
		DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_NONE, self, false)
	else 
		DoDamage(caster, target, damage * 0.7, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_NONE, self, false)
	end	
end