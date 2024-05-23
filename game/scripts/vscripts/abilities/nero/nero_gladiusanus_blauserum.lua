nero_gladiusanus_blauserum = class({})
nero_gladiusanus_blauserum_upgrade = class({})

LinkLuaModifier("modifier_gladiusanus_blauserum", "abilities/nero/modifiers/modifier_gladiusanus_blauserum", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pari_tenu_blauserum", "abilities/nero/modifiers/modifier_gladiusanus_blauserum", LUA_MODIFIER_MOTION_NONE)

function gladiusanus_blauserum_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster.IsSoverignsGloryAcquired then
			return caster:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):GetSpecialValueFor("ability_cd") 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
			return 100 
		else
			return 200
		end
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self

		if caster.IsPTBAcquired then 
			caster:AddNewModifier(caster, ability, "modifier_pari_tenu_blauserum", { Duration = self:GetSpecialValueFor("duration"),
																		 		 	AttackSpeed = self:GetSpecialValueFor("bonus_aspd") })
		end
		--[[if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster:HasModifier("modifier_gladiusanus") then
			local stacks = caster:GetModifierStackCount("modifier_gladiusanus", ability) 
			local damage = self:GetSpecialValueFor("base_damage") + stacks * self:GetSpecialValueFor("bonus_damage")

			local aoeTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			caster:EmitSound("Hero_Clinkz.DeathPact")

			local flameFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(flameFx, 2, caster:GetAbsOrigin())

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) 
			ParticleManager:SetParticleControl(particle, 1, Vector(500, 500, 500)) 
			ParticleManager:SetParticleControl(particle, 3, Vector(500, 500, 500)) 

			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( flameFx, false )
				ParticleManager:ReleaseParticleIndex( flameFx )
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)

	        for k, v in pairs(aoeTargets) do
	        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        end
		end]]

		caster:AddNewModifier(caster, ability, "modifier_gladiusanus_blauserum", { Duration = self:GetSpecialValueFor("duration"),
																		  Damage = self:GetSpecialValueFor("base_damage"),
																		  BonusDamage = self:GetSpecialValueFor("bonus_damage"),
																		  StunDuration = self:GetSpecialValueFor("stun_duration"),
																		  TotalHit = self:GetSpecialValueFor("total_hit"),
																		  MarkDuration = self:GetSpecialValueFor("mark_dur") })

	end
end

gladiusanus_blauserum_wrapper(nero_gladiusanus_blauserum)
gladiusanus_blauserum_wrapper(nero_gladiusanus_blauserum_upgrade)