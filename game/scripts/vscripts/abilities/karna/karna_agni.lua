karna_agni = class({})
karna_agni_upgrade = class({})

LinkLuaModifier("modifier_agni_karna", "abilities/karna/modifiers/modifier_agni_karna", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_armor_returned", "abilities/karna/modifiers/modifier_armor_returned", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_karna_combo_window", "abilities/karna/modifiers/modifier_karna_combo_window", LUA_MODIFIER_MOTION_NONE)

function karna_agni_wrapper(ability)
	function ability:OnSpellStart()
		local caster = self:GetCaster()

		caster:EmitSound("karna_skill_" .. math.random(1,4))

		caster:AddNewModifier(caster, self, "modifier_agni_karna", { Duration = self:GetSpecialValueFor("duration"),
																	 OnHitDamage = self:GetSpecialValueFor("on_hit_damage"),
																	 BurnDamage = self:GetSpecialValueFor("burn_damage"),
																	 BurnDuration = self:GetSpecialValueFor("burn_duration"),
																	 BurnAOE = self:GetSpecialValueFor("burn_aoe"),
																	 ExplodeAOE = self:GetSpecialValueFor("explode_aoe"),
																	 ExplodeDamage = self:GetSpecialValueFor("explode_damage"),
																	 ExplodeStun = self:GetSpecialValueFor("explode_stun"),
																	 ExplodeHitCount = self:GetSpecialValueFor("explode_hit_count")})

		self:CheckCombo()
	end

	function ability:CheckCombo()
		local caster = self:GetCaster()

		if caster:GetStrength() >= 24.1 and caster:GetAgility() >= 24.1 and caster:GetIntellect() >= 24.1 then
			if caster.IndraAttribute then		
				if caster:FindAbilityByName("karna_vasavi_shakti_upgrade"):IsCooldownReady() 
				and caster:FindAbilityByName("karna_combo_vasavi_upgrade"):IsCooldownReady() 
				and not caster:HasModifier("modifier_combo_vasavi_cooldown")
				and caster:HasModifier("modifier_armor_returned")		
				then
					caster:AddNewModifier(caster, self, "modifier_karna_combo_window", { Duration = caster:FindModifierByName("modifier_armor_returned"):GetRemainingTime() })
				end
			else
				if caster:FindAbilityByName("karna_vasavi_shakti"):IsCooldownReady() 
				and caster:FindAbilityByName("karna_combo_vasavi"):IsCooldownReady() 
				and not caster:HasModifier("modifier_combo_vasavi_cooldown")
				and caster:HasModifier("modifier_armor_returned")		
				then
					caster:AddNewModifier(caster, self, "modifier_karna_combo_window", { Duration = caster:FindModifierByName("modifier_armor_returned"):GetRemainingTime() })
				end
			end
		end
	end
end

karna_agni_wrapper(karna_agni)
karna_agni_wrapper(karna_agni_upgrade)