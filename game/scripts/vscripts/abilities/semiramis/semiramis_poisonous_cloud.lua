semiramis_poisonous_cloud = class({})

LinkLuaModifier("modifier_poison_cloud_aura", "abilities/semiramis/modifiers/modifier_poison_cloud_aura", LUA_MODIFIER_MOTION_NONE)

function semiramis_poisonous_cloud:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function semiramis_poisonous_cloud:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function semiramis_poisonous_cloud:OnSpellStart()
	local caster = self:GetCaster()
	local cast_delay = self:GetSpecialValueFor("cast_delay")

	local particle = ParticleManager:CreateParticle( "particles/custom/semiramis/basmu_poison.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(self:GetAOERadius(),0,0))

	Timers:CreateTimer(cast_delay, function()

		CreateModifierThinker(caster, ability, "modifier_poison_cloud_aura", { Duration = self:GetSpecialValueFor("duration"),
																			   PoisonDamage = self:GetSpecialValueFor("damage"),
																			   AOE = self:GetAOERadius(),
																			   PoisonDuration = self:GetSpecialValueFor("poison_duration"),
																			   ResistReduc = self:GetSpecialValueFor("resist_reduc") }
								, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	end)
end