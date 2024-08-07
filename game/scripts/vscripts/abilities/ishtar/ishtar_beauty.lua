LinkLuaModifier("modifier_ishtar_beauty", "abilities/ishtar/ishtar_beauty", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_beauty_male", "abilities/ishtar/ishtar_beauty", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_ishtar_beauty_female", "abilities/ishtar/ishtar_beauty", LUA_MODIFIER_MOTION_NONE)
ishtar_beauty = class({})

function ishtar_beauty:GetIntrinsicModifierName()
	return "modifier_ishtar_beauty"
end

--------------------------

modifier_ishtar_beauty = class({})

function modifier_ishtar_beauty:IsHidden() return false end
function modifier_ishtar_beauty:IsDebuff() return false end
function modifier_ishtar_beauty:IsPassive() return true end
function modifier_ishtar_beauty:IsAura() return true end
function modifier_ishtar_beauty:IsAuraActiveOnDeath() return false end
function modifier_ishtar_beauty:IsPurgable() return false end
function modifier_ishtar_beauty:RemoveOnDeath() return false end
function modifier_ishtar_beauty:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("buff_radius")
end
function modifier_ishtar_beauty:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_ishtar_beauty:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end
function modifier_ishtar_beauty:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_ishtar_beauty:GetModifierAura()
	return "modifier_ishtar_beauty_female"
end
function modifier_ishtar_beauty:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_ishtar_beauty:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,}
end

if IsServer() then
	function modifier_ishtar_beauty:OnCreated(args)
		self.caster = self:GetParent()
		self.total_heal = 0
		self.interval = 0.4
		self:StartIntervalThink(self.interval)
		--print('beauty created')
	end

	function modifier_ishtar_beauty:OnIntervalThink()
		if self:GetParent():IsAlive() and self.total_heal > 0 then 
			local recovery_per_second = self:GetAbility():GetSpecialValueFor("recovery_per_second")
			local heal = math.min(self.total_heal, recovery_per_second * self.interval)
			self.total_heal = self.total_heal - heal
			print('heal ' .. heal)
			self:GetParent():FateHeal(heal, self:GetParent(), true)
			local heal_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(heal_fx, 0, self.caster:GetAbsOrigin() + Vector(0,0,100))
			Timers:CreateTimer(0.8, function()
				ParticleManager:DestroyParticle(heal_fx, false)
				ParticleManager:ReleaseParticleIndex(heal_fx)
			end)
		end
	end

	function modifier_ishtar_beauty:OnTakeDamage(args)
		if args.unit ~= self:GetParent() then return end

		local attacker = args.attacker

		if IsFemaleServant(attacker) == false then
			local recoverhealth = args.damage * (self:GetAbility():GetSpecialValueFor("recover_damage_taken") / 100)
			self.total_heal = self.total_heal + recoverhealth
		end
	end
end

-------------------------------

modifier_ishtar_beauty_male = class({})

function modifier_ishtar_beauty_male:IsHidden() return false end
function modifier_ishtar_beauty_male:IsDebuff() return false end
function modifier_ishtar_beauty_male:IsPassive() return false end
function modifier_ishtar_beauty_male:IsPurgable() return false end
function modifier_ishtar_beauty_male:RemoveOnDeath() return true end

function modifier_ishtar_beauty_male:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_ishtar_beauty_male:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,}
end
function modifier_ishtar_beauty_male:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("buff_male_mr")
end
function modifier_ishtar_beauty_male:GetEffectName()
	return "particles/ishtar/ishtar_beauty_star.vpcf"
end
function modifier_ishtar_beauty_male:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

----------------------------------------

modifier_ishtar_beauty_female = class({})

function modifier_ishtar_beauty_female:IsHidden() return true end
function modifier_ishtar_beauty_female:IsDebuff() return false end
function modifier_ishtar_beauty_female:IsPassive() return false end
function modifier_ishtar_beauty_female:IsPurgable() return false end
function modifier_ishtar_beauty_female:RemoveOnDeath() return true end
function modifier_ishtar_beauty_female:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_ishtar_beauty_female:OnCreated(args)
		if not IsFemaleServant(self:GetParent()) then 
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ishtar_beauty_male", {})
		end
	end
	function modifier_ishtar_beauty_female:OnDestroy()
		if not IsFemaleServant(self:GetParent()) then 
			self:GetParent():RemoveModifierByName("modifier_ishtar_beauty_male")
		end
	end
end