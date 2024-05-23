nero_tres_fontaine_ardent = class({})
nero_tres_fontaine_ardent_upgrade = class({})

LinkLuaModifier("modifier_tres_target_marker", "abilities/nero/modifiers/modifier_tres_target_marker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tres_fontaine_nero", "abilities/nero/modifiers/modifier_tres_fontaine_nero", LUA_MODIFIER_MOTION_NONE)

function tres_fontainne_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster.IsSoverignsGloryAcquired then
			return caster:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):GetSpecialValueFor("ability_cd") 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("radius")
		local ability = self
		local damage = self:GetSpecialValueFor("bonus_damage")
		local interval_slash = self:GetSpecialValueFor("interval_slash")

		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
				
		local soundType = math.random(1,2)
		local doSound = true

		if soundType == 1 then
			caster:EmitSound("Nero_Skill_" .. math.random(1,4))
			doSound = false
		end

		if caster.IsPTBAcquired then
			damage = damage + (caster:GetAgility() * self:GetSpecialValueFor("bonus_agi"))
		end

		if #targets > 0 then
			local marker_duration = #targets * (interval_slash + 0.05)

			for i = 1, #targets do
				if IsValidEntity(targets[i]) and not targets[i]:IsNull() then
				targets[i]:AddNewModifier(caster, ability, "modifier_tres_target_marker", { Duration = marker_duration})
				end
			end

			caster:AddNewModifier(caster, ability, "modifier_tres_fontaine_nero", { Duration = marker_duration,
																					DamageOnHit = damage,
																					Radius = self:GetSpecialValueFor("max_range"),
																					AttackSound = doSound })
		end
	end
end

tres_fontainne_wrapper(nero_tres_fontaine_ardent)
tres_fontainne_wrapper(nero_tres_fontaine_ardent_upgrade)