jtr_murderer_mist = class({})

LinkLuaModifier("modifier_murderer_mist_aura", "abilities/jtr/modifiers/modifier_murderer_mist_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_murderer_mist_invis", "abilities/jtr/modifiers/modifier_murderer_mist_invis", LUA_MODIFIER_MOTION_NONE)

function jtr_the_mist:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function jtr_the_mist:GetCastPoint()
	return 0.4
end

function jtr_the_mist:OnSpellStart()
	local caster = self:GetCaster()

	if self.AuraDummy ~= nil and not self.AuraDummy:IsNull() then 
		self.AuraDummy:RemoveSelf()
	end

	self.AuraDummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	self.AuraDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	self.AuraDummy:SetDayTimeVisionRange(25)
	self.AuraDummy:SetNightTimeVisionRange(25)

	self.AuraDummy:EmitSound("jtr_smoke")
	caster:EmitSound("jtr_invis")
	caster:EmitSound("jtr_laugh_1")


	--[[local enemy = PickRandomEnemy(caster)
	if enemy ~= nil then
		SpawnVisionDummy(enemy, caster:GetAbsOrigin(), 25, 5, false)
	end	]]

	self.AuraDummy:AddNewModifier(caster, self, "modifier_murderer_mist_aura", { Duration = self:GetSpecialValueFor("duration"),
																				 AuraRadius = self:GetSpecialValueFor("radius")})

	self.AuraDummy:AddNewModifier(caster, self, "modifier_kill", { Duration = self:GetSpecialValueFor("duration") })


	caster:AddNewModifier(caster, self, "modifier_murderer_mist_invis", { Duration = self:GetSpecialValueFor("duration"),
																		  FadeTime = self:GetSpecialValueFor("fade_time"),
																		  AgiDmg = self:GetSpecialValueFor("agi_dmg_pct"),
																		  BaseAgiDmg = self:GetSpecialValueFor("base_damage")
																		})
end