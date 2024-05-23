semiramis_poisonous_bite_upgrade = class({})

LinkLuaModifier("modifier_poisonous_bite", "abilities/semiramis/modifiers/modifier_poisonous_bite", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_poisonous_bite_slow", "abilities/semiramis/modifiers/modifier_poisonous_bite_slow", LUA_MODIFIER_MOTION_NONE)

function semiramis_poisonous_bite_upgrade:CastFilterResultTarget(hTarget)
	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())

	return filter
end

function semiramis_poisonous_bite_upgrade:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function semiramis_poisonous_bite_upgrade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local cast_delay = self:GetSpecialValueFor("cast_delay")
	local damage = self:GetSpecialValueFor("damage")
	local damage_per_int = self:GetSpecialValueFor("damage_per_int")

   	caster:EmitSound("Semi.AssassinR")

	Timers:CreateTimer(cast_delay / 2, function()
	   	target:EmitSound("Semi.AssassinRSFX")
	   	target:EmitSound("Semi.AssassinRSFX2")

	   	if caster.IsCharmAcquired then
			DoDamage(caster, target, damage + (damage_per_int * caster:GetIntellect()) , DAMAGE_TYPE_MAGICAL, 0, self, false)
		else
			DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		end

		target:AddNewModifier(caster, self, "modifier_poisonous_bite", { Duration = self:GetSpecialValueFor("duration"),
																		 Damage = self:GetSpecialValueFor("dps"),
																		 AOE = self:GetSpecialValueFor("radius") })

		if not IsImmuneToSlow(target) then
			target:AddNewModifier(caster, self, "modifier_poisonous_bite_slow", { Duration = self:GetSpecialValueFor("duration"),																	 
																				  Slow = self:GetSpecialValueFor("slow"),
																				  SlowInc = self:GetSpecialValueFor("slow_inc")})
		end
	end)
end