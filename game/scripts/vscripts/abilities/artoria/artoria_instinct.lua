artoria_instinct = class{()}
modifier_artoria_instinct_passive = class{()}
modifier_artoria_instinct_active = class{()}
modifier_artoria_instinct_cooldown = class{()}
modifier_artoria_instinct_crit = class{()}

LinkLuaModifier("modifier_artoria_instinct_passive", "abilities/artoria/artoria_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_artoria_instinct_active", "abilities/artoria/artoria_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_artoria_instinct_cooldown", "abilities/artoria/artoria_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_artoria_instinct_crit", "abilities/artoria/artoria_instinct", LUA_MODIFIER_MOTION_NONE)

function artoria_instinct:GetBehavior() 
	if self:GetCaster():HasModifier("") then 
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else 
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function artoria_instinct:GetCooldown(iLevel)
	if self:GetCaster():HasModifier("") then 
		return self:GetSpecialValueFor("cooldown")
	else 
		return 0
	end
end

function artoria_instinct:IsRefreshable()
	return false 
end

function artoria_instinct:GetManaCost(iLevel)
	return 0 
end

function artoria_instinct:GetIntrinsicModifierName()
	return "modifier_artoria_instinct_passive"
end

function artoria_instinct:GetAbilityTextureName()
	return "custom/artoria/saber_instinct"
end

function artoria_instinct:OnSpellStart()
	self.caster = self:GetCaster()

	self.caster:AddNewModifier(self.caster, self, "modifier_artoria_instinct_active", {Duration = self:GetSpecialValueFor("spellshield_duration")})
	self.caster:AddNewModifier(self.caster, self, "modifier_artoria_instinct_cooldown", {Duration = self:GetSpecialValueFor("cooldown")})
end

function artoria_instinct:GetModifierOverrideAbilitySpecialValue(self, event)
	self.caster = self:GetCaster()
	if event.ability_special_value == "evasion_rate" then
		local passive_evade = self:GetSpecialValueFor("evasion_rate")
		if self:GetCaster():HasModifier("") then 
			passive_evade = self.caster.MasterUnit2:GetSpecialValueFor("evasion_rate")
		end
		return passive_evade
	end
end

----------------------------------

function modifier_artoria_instinct_passive:IsHidden() 
	return true 
end

function modifier_artoria_instinct_passive:IsDebuff() 
	return false 
end 

function modifier_artoria_instinct_passive:IsPassive() 
	return true 
end

function modifier_artoria_instinct_passive:RemoveOnDeath() 
	return false 
end

function modifier_artoria_instinct_passive:IsRemoveOnRoundStart()
	return false 
end

function modifier_artoria_instinct_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_artoria_instinct_passive:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_EVASION_CONSTANT}
	if self:GetParent():HasModifier("") then 
		func = {MODIFIER_PROPERTY_EVASION_CONSTANT,
				MODIFIER_EVENT_ON_ATTACK_START,
				MODIFIER_EVENT_ON_ATTACK_LANDED}
	end
	return func 
end

function modifier_artoria_instinct_passive:GetModifierEvasion_Constant()
	if self:GetParent():HasModifier("modifier_artoria_instinct_active") then
		return self:GetAbility():GetSpecialValueFor("active_evasion_rate")
	else 
		return self:GetAbility():GetSpecialValueFor("evasion_rate")
	end
end

function modifier_artoria_instinct_passive:OnAttackStart(args)
	if IsServer() then
		if not self:GetParent():HasModifier("") then return end
		if args.attacker ~= self:GetParent() then return end

		self:GetParent():RemoveModifierByName("modifier_artoria_instinct_crit")

		local crit_rate = self:GetAbility():GetSpecialValueFor("crit_rate")
		if self:GetParent():HasModifier("modifier_artoria_instinct_active") then
			crit_rate = self:GetAbility():GetSpecialValueFor("active_evasion_rate")
		end
		if RandomInt(1, 100) <= crit_rate then 
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_artoria_instinct_crit", {Duration = 1.0})
		end
	end
end

-------------------------------------

function modifier_artoria_instinct_crit:IsHidden() 
	return true 
end

function modifier_artoria_instinct_crit:IsDebuff() 
	return false 
end 

function modifier_artoria_instinct_crit:IsPassive() 
	return false 
end

function modifier_artoria_instinct_crit:RemoveOnDeath() 
	return false 
end

function modifier_artoria_instinct_crit:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_artoria_instinct_crit:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_artoria_instinct_crit:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_ABSORIGIN, args.target)
	ParticleManager:SetParticleControl(particle, 0, args.target:GetAbsOrigin()) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
	self:GetParent():RemoveModifierByName("modifier_artoria_instinct_crit")
end

function modifier_artoria_instinct_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end

function modifier_artoria_instinct_crit:IsRemoveOnRoundStart()
	return true 
end

-----------------------------------------------------------

function modifier_artoria_instinct_active:IsHidden() 
	return false 
end

function modifier_artoria_instinct_active:IsDebuff() 
	return false 
end 

function modifier_artoria_instinct_active:IsPassive() 
	return false 
end

function modifier_artoria_instinct_active:RemoveOnDeath() 
	return true 
end

function modifier_artoria_instinct_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_artoria_instinct_active:GetEffectName()
	return "particles/items_fx/immunity_sphere_buff.vpcf"
end

function modifier_artoria_instinct_active:GetEffectAttachType()
	return "attach_hitloc"
end

function modifier_artoria_instinct_active:IsRemoveOnRoundStart()
	return true 
end

-----------------------------------------------------------

function modifier_artoria_instinct_cooldown:IsHidden() 
	return false 
end

function modifier_artoria_instinct_cooldown:IsDebuff() 
	return false 
end 

function modifier_artoria_instinct_cooldown:IsPassive() 
	return false 
end

function modifier_artoria_instinct_cooldown:RemoveOnDeath() 
	return false 
end

function modifier_artoria_instinct_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_artoria_instinct_cooldown:IsRemoveOnRoundStart()
	return false 
end