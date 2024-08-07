LinkLuaModifier("modifier_atalanta_evolution", "abilities/alter_atalanta/atalanta_alter_evolution", LUA_MODIFIER_MOTION_NONE)

atalanta_passive_evolution = class({})

function atalanta_passive_evolution:GetIntrinsicModifierName()
	return "modifier_atalanta_evolution"
end

function atalanta_passive_evolution:CurseEnergyHeal(iStacks)
	self.caster = self:GetCaster()
	self.energy_heal = self:GetSpecialValueFor("energy_heal") / 100

	self.caster:FateHeal(self.energy_heal * iStacks * self.caster:GetMaxHealth(), self.caster, true)

	local heal_fx = ParticleManager:CreateParticle("particles/econ/items/drow/drow_arcana/drow_arcana_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(heal_fx, 0, self.caster:GetAbsOrigin())

	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle(heal_fx, false)
		ParticleManager:ReleaseParticleIndex(heal_fx)
	end)
end

--------------------------------------

modifier_atalanta_evolution = class({})

function modifier_atalanta_evolution:IsHidden() return false end
function modifier_atalanta_evolution:IsDebuff() return false end
function modifier_atalanta_evolution:IsPassive() return true end
function modifier_atalanta_evolution:IsPurgable() return false end
function modifier_atalanta_evolution:RemoveOnDeath() return false end
function modifier_atalanta_evolution:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end