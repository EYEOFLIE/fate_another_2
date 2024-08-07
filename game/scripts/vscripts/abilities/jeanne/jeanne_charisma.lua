
jeanne_charisma = class({})
jeanne_charisma_upgrade = class({})
modifier_jeanne_q_use = class({})
modifier_jeanne_charisma_str_new = class({})
modifier_jeanne_charisma_agi_new = class({})
modifier_jeanne_charisma_int_new = class({})
modifier_jeanne_charisma_all_new = class({})

LinkLuaModifier("modifier_jeanne_q_use", "abilities/jeanne/jeanne_charisma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_charisma_str_new", "abilities/jeanne/jeanne_charisma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_charisma_agi_new", "abilities/jeanne/jeanne_charisma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_charisma_int_new", "abilities/jeanne/jeanne_charisma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_charisma_all_new", "abilities/jeanne/jeanne_charisma", LUA_MODIFIER_MOTION_NONE)

function jeanne_charisma_wrapper(abil)
	function abil:GetAbilityTextureName()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return "custom/jeanne/jeanne_charisma_saint"
		else
			return "custom/jeanne/jeanne_charisma"
		end
	end

	function abil:GetBehavior()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
		else
			if self:GetLevel() == 5 then 
				return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
			else
				return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
			end
		end
	end

	function abil:OnUpgrade()
		self:GetCaster().QLevel = self:GetLevel()
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		self.target = self:GetCursorTarget()
		self.duration = self:GetSpecialValueFor("duration")

		self:ApplyCharisma(self.target, self.duration)
		self.target:EmitSound("Hero_Dazzle.Shadow_Wave")

		if self.caster.IsRevelationAcquired and self.target ~= self.caster then
			HardCleanse(self.target)
			local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, self.target )
		    ParticleManager:SetParticleControl( dispel, 1, self.target:GetAbsOrigin() + Vector(0,0,30))

		    Timers:CreateTimer( 2.0, function()
		        ParticleManager:DestroyParticle( dispel, false )
		        ParticleManager:ReleaseParticleIndex( dispel )
		    end)
		end

		if math.ceil(self.caster:GetStrength()) >= 25 and math.ceil(self.caster:GetAgility()) >= 25 and math.ceil(self.caster:GetIntellect()) >= 25 then 
			self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_q_use", {Duration = 4})
		end
	end

	function abil:ApplyCharisma(hTarget, fDuration)
		self.vision_radius = self:GetSpecialValueFor("radius_modifier")
		
		SpawnAttachedVisionDummy(self:GetCaster(), hTarget, self.vision_radius, fDuration, true)

		local primaryStat = hTarget:GetPrimaryAttribute()
		--local bonus_stat = {Duration = self.duration, STR = 0, AGI = 0, INT = 0, ASPD = self:GetSpecialValueFor("bonus_aspd")}

		if primaryStat == 0 then --STR
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_jeanne_charisma_str_new", {Duration = fDuration})
		elseif primaryStat == 1 then --AGI
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_jeanne_charisma_agi_new", {Duration = fDuration})
		elseif primaryStat == 2 then --INT
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_jeanne_charisma_int_new", {Duration = fDuration})
		else --if primaryStat == 3 then --Universal
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_jeanne_charisma_all_new", {Duration = fDuration})
		end 
	end
end

jeanne_charisma_wrapper(jeanne_charisma)
jeanne_charisma_wrapper(jeanne_charisma_upgrade)

------------------------

function modifier_jeanne_q_use:IsHidden() return true end
function modifier_jeanne_q_use:IsDebuff() return false end
function modifier_jeanne_q_use:IsPurgable() return false end
function modifier_jeanne_q_use:RemoveOnDeath() return true end
function modifier_jeanne_q_use:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

-------------------------

function modifier_jeanne_charisma_str_new:IsHidden() return false end
function modifier_jeanne_charisma_str_new:IsDebuff() return false end
function modifier_jeanne_charisma_str_new:IsPurgable() return false end
function modifier_jeanne_charisma_str_new:RemoveOnDeath() return true end
function modifier_jeanne_charisma_str_new:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_charisma_str_new:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,}
end

if IsServer() then
	function modifier_jeanne_charisma_str_new:OnCreated(args)
		self.target = self:GetParent()
		self:AttachParticle()
	end

	function modifier_jeanne_charisma_str_new:OnRefresh(args)

	end

	function modifier_jeanne_charisma_str_new:OnDestroy()
		self:DetachParticle()
	end

	function modifier_jeanne_charisma_str_new:AttachParticle()
		self.charisma_fx = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.charisma_fx, 0, Vector(self:GetAbility():GetSpecialValueFor("radius_modifier")))
	end

	function modifier_jeanne_charisma_str_new:DetachParticle()
		ParticleManager:DestroyParticle(self.charisma_fx, true)
		ParticleManager:ReleaseParticleIndex(self.charisma_fx)
	end
end

function modifier_jeanne_charisma_str_new:GetTexture()
	return "custom/jeanne/jeanne_charisma"
end

function modifier_jeanne_charisma_str_new:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("stat_modifier")
end

function modifier_jeanne_charisma_str_new:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end

-------------------------

function modifier_jeanne_charisma_agi_new:IsHidden() return false end
function modifier_jeanne_charisma_agi_new:IsDebuff() return false end
function modifier_jeanne_charisma_agi_new:IsPurgable() return false end
function modifier_jeanne_charisma_agi_new:RemoveOnDeath() return true end
function modifier_jeanne_charisma_agi_new:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_charisma_agi_new:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

if IsServer() then
	function modifier_jeanne_charisma_agi_new:OnCreated(args)
		self.target = self:GetParent()
		self:AttachParticle()
	end

	function modifier_jeanne_charisma_agi_new:OnRefresh(args)

	end

	function modifier_jeanne_charisma_agi_new:OnDestroy()
		self:DetachParticle()
	end

	function modifier_jeanne_charisma_agi_new:AttachParticle()
		self.charisma_fx = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.charisma_fx, 0, Vector(self:GetAbility():GetSpecialValueFor("radius_modifier")))
	end

	function modifier_jeanne_charisma_agi_new:DetachParticle()
		ParticleManager:DestroyParticle(self.charisma_fx, true)
		ParticleManager:ReleaseParticleIndex(self.charisma_fx)
	end
end

function modifier_jeanne_charisma_agi_new:GetTexture()
	return "custom/jeanne/jeanne_charisma_agi"
end

function modifier_jeanne_charisma_agi_new:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("stat_modifier")
end

function modifier_jeanne_charisma_agi_new:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end

-------------------------

function modifier_jeanne_charisma_int_new:IsHidden() return false end
function modifier_jeanne_charisma_int_new:IsDebuff() return false end
function modifier_jeanne_charisma_int_new:IsPurgable() return false end
function modifier_jeanne_charisma_int_new:RemoveOnDeath() return true end
function modifier_jeanne_charisma_int_new:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_charisma_int_new:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

if IsServer() then
	function modifier_jeanne_charisma_int_new:OnCreated(args)
		self.target = self:GetParent()
		self:AttachParticle()
	end

	function modifier_jeanne_charisma_int_new:OnRefresh(args)

	end

	function modifier_jeanne_charisma_int_new:OnDestroy()
		self:DetachParticle()
	end

	function modifier_jeanne_charisma_int_new:AttachParticle()
		self.charisma_fx = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.charisma_fx, 0, Vector(self:GetAbility():GetSpecialValueFor("radius_modifier")))
	end

	function modifier_jeanne_charisma_int_new:DetachParticle()
		ParticleManager:DestroyParticle(self.charisma_fx, true)
		ParticleManager:ReleaseParticleIndex(self.charisma_fx)
	end
end

function modifier_jeanne_charisma_int_new:GetTexture()
	return "custom/jeanne/jeanne_charisma_int"
end

function modifier_jeanne_charisma_int_new:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("stat_modifier")
end

function modifier_jeanne_charisma_int_new:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end

-------------------------

function modifier_jeanne_charisma_all_new:IsHidden() return false end
function modifier_jeanne_charisma_all_new:IsDebuff() return false end
function modifier_jeanne_charisma_all_new:IsPurgable() return false end
function modifier_jeanne_charisma_all_new:RemoveOnDeath() return true end
function modifier_jeanne_charisma_all_new:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_charisma_all_new:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

if IsServer() then
	function modifier_jeanne_charisma_all_new:OnCreated(args)
		self.target = self:GetParent()
		self:AttachParticle()
	end

	function modifier_jeanne_charisma_all_new:OnRefresh(args)

	end

	function modifier_jeanne_charisma_all_new:OnDestroy()
		self:DetachParticle()
	end

	function modifier_jeanne_charisma_all_new:AttachParticle()
		self.charisma_fx = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.charisma_fx, 0, Vector(self:GetAbility():GetSpecialValueFor("radius_modifier")))
	end

	function modifier_jeanne_charisma_all_new:DetachParticle()
		ParticleManager:DestroyParticle(self.charisma_fx, true)
		ParticleManager:ReleaseParticleIndex(self.charisma_fx)
	end
end

function modifier_jeanne_charisma_all_new:GetTexture()
	return "custom/jeanne/jeanne_charisma_all"
end

function modifier_jeanne_charisma_all_new:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("stat_modifier") /2
end

function modifier_jeanne_charisma_all_new:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("stat_modifier") /2
end

function modifier_jeanne_charisma_all_new:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("stat_modifier") /2
end

function modifier_jeanne_charisma_all_new:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_aspd")
end