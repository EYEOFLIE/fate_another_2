
jeanne_gods_resolution = class({})
jeanne_gods_resolution_upgrade_1 = class({})
jeanne_gods_resolution_upgrade_2 = class({})
jeanne_gods_resolution_upgrade_3 = class({})
modifier_jeanne_gods_resolution = class({})
modifier_jeanne_gods_resolution_slow = class({}) 
modifier_jeanne_gods_resolution_buff = class({})
modifier_jeanne_gods_resolution_buff2 = class({})

LinkLuaModifier("modifier_jeanne_gods_resolution", "abilities/jeanne/jeanne_god_resolution", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_gods_resolution_slow", "abilities/jeanne/jeanne_god_resolution", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_gods_resolution_buff", "abilities/jeanne/jeanne_god_resolution", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_gods_resolution_buff2", "abilities/jeanne/jeanne_god_resolution", LUA_MODIFIER_MOTION_NONE)

function jeanne_charisma_wrapper(abil)
	function abil:GetAbilityTextureName()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return "custom/jeanne/jeanne_gods_resolution_saint"
		else
			return "custom/jeanne/jeanne_gods_resolution"
		end
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		
		if self.caster:HasModifier('modifier_alternate_02') then 
			self.caster:EmitSound("Jeanne-E")
		else
			self.caster:EmitSound("Jeanne_Skill_" .. math.random(9,12))
		end

		giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealdisabled", self:GetSpecialValueFor("duration"))
		self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_gods_resolution", {Duration = self:GetSpecialValueFor("duration")})

		Timers:CreateTimer(self:GetSpecialValueFor("duration"), function()
			if self.caster:IsAlive() then 
				self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_gods_resolution_buff", {Duration = self:GetSpecialValueFor("buff_duration")})
				if self.caster.IsDivineSymbolAcquired then 
					self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_gods_resolution_buff2", {Duration = self:GetSpecialValueFor("buff_duration")})
				end
			end
		end)
	end
end

jeanne_charisma_wrapper(jeanne_gods_resolution)
jeanne_charisma_wrapper(jeanne_gods_resolution_upgrade_1)
jeanne_charisma_wrapper(jeanne_gods_resolution_upgrade_2)
jeanne_charisma_wrapper(jeanne_gods_resolution_upgrade_3)

----------------------------------

function modifier_jeanne_gods_resolution:IsHidden() return false end
function modifier_jeanne_gods_resolution:IsDebuff() return false end
function modifier_jeanne_gods_resolution:IsPassive() return false end
function modifier_jeanne_gods_resolution:IsAura() return true end
function modifier_jeanne_gods_resolution:IsAuraActiveOnDeath() return false end
function modifier_jeanne_gods_resolution:IsPurgable() return false end
function modifier_jeanne_gods_resolution:RemoveOnDeath() return true end
function modifier_jeanne_gods_resolution:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_jeanne_gods_resolution:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_jeanne_gods_resolution:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end
function modifier_jeanne_gods_resolution:GetAuraSearchFlags()
	return 0
end
function modifier_jeanne_gods_resolution:GetModifierAura()
	return "modifier_jeanne_gods_resolution_slow"
end
function modifier_jeanne_gods_resolution:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end
function modifier_jeanne_gods_resolution:GetAuraEntityReject(hEntity)
	if IsImmuneToCC(hEntity) or IsImmuneToSlow(hEntity) then
		return true
	end
	return false 
end
function modifier_jeanne_gods_resolution:GetTexture()
	return "custom/jeanne/jeanne_gods_resolution"
end

function modifier_jeanne_gods_resolution:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_jeanne_gods_resolution:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function modifier_jeanne_gods_resolution:GetOverrideAnimationRate()
	return 1.0
end

function modifier_jeanne_gods_resolution_buff2:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("channel_def")
end

function modifier_jeanne_gods_resolution_buff2:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("channel_def")
end

--[[function modifier_jeanne_gods_resolution:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("")
end]]

if IsServer() then
	function modifier_jeanne_gods_resolution:OnCreated(args)
		self.caster = self:GetParent()
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.duration = self:GetAbility():GetSpecialValueFor("duration")
		self.total_damage = self:GetAbility():GetSpecialValueFor("total_damage")
		self.interval = 0.2
		if self.caster.IsPunishmentAcquired then 
			self.interval = self.duration/self:GetAbility():GetSpecialValueFor("total_pillar")
			self.pillar_dmg = self:GetAbility():GetSpecialValueFor("pillar_dmg")
			self.pillar_radius = self:GetAbility():GetSpecialValueFor("pillar_radius")
			self.pillar_revoke = self:GetAbility():GetSpecialValueFor("pillar_revoke")
		end
		self:StartIntervalThink(self.interval)
		self.caster:EmitSound("Hero_ArcWarden.MagneticField")
	end

	function modifier_jeanne_gods_resolution:OnIntervalThink()

		if not self.caster:IsAlive() then 
			self:Destroy()
			return nil
		end 

		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsValidEntity(v) and not v:IsNull() then
				if self.caster:HasModifier("modifier_jeanne_saint") and not IsImmuneToCC(v) then
					v:AddNewModifier(self.caster, self:GetAbility(), "modifier_stunned", { Duration = self.interval/2 })
				end

		        DoDamage(self.caster, v, self.total_damage * self.interval / self.duration, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
		    end
		end

		if self.caster.IsPunishmentAcquired then 
			local vPillarLoc = self.caster:GetAbsOrigin() + RandomVector(self.radius * 0.75)

			local tPillarTargets = FindUnitsInRadius(self.caster:GetTeam(), vPillarLoc, nil, self.pillar_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs (tPillarTargets) do
				DoDamage(self.caster, v, self.pillar_dmg, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				ApplyPurge(v)	
				giveUnitDataDrivenModifier(self.caster, v, "revoked", self.pillar_revoke)
			end
			
			local iPillarFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( iPillarFx, 0, vPillarLoc)
			ParticleManager:SetParticleControl( iPillarFx, 1, vPillarLoc)
			ParticleManager:SetParticleControl( iPillarFx, 2, vPillarLoc)

			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(iPillarFx, false)
				ParticleManager:ReleaseParticleIndex(iPillarFx)
			end)
		end

		local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/gods_resolution/gods_resolution_active_circle.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
		ParticleManager:SetParticleControl( purgeFx, 0, self.caster:GetAbsOrigin())
	end

	function modifier_jeanne_gods_resolution:OnDestroy()
		self.caster:StopSound("Hero_ArcWarden.MagneticField")
	end
end

--------------------------------

function modifier_jeanne_gods_resolution_slow:IsHidden() return false end
function modifier_jeanne_gods_resolution_slow:IsDebuff() return true end
function modifier_jeanne_gods_resolution_slow:IsPurgable() return false end
function modifier_jeanne_gods_resolution_slow:RemoveOnDeath() return true end
function modifier_jeanne_gods_resolution_slow:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_jeanne_gods_resolution_slow:GetTexture()
	return "custom/jeanne/jeanne_gods_resolution"
end

function modifier_jeanne_gods_resolution_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_jeanne_gods_resolution_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_amount")
end

----------------------------

function modifier_jeanne_gods_resolution_buff:IsHidden() return false end
function modifier_jeanne_gods_resolution_buff:IsDebuff() return false end
function modifier_jeanne_gods_resolution_buff:IsPassive() return false end
function modifier_jeanne_gods_resolution_buff:IsPurgable() return false end
function modifier_jeanne_gods_resolution_buff:RemoveOnDeath() return true end
function modifier_jeanne_gods_resolution_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_jeanne_gods_resolution_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end
function modifier_jeanne_gods_resolution_buff:GetActivityTranslationModifiers()
	return "proc"
end
function modifier_jeanne_gods_resolution_buff:GetEffectName()
	return "particles/custom/ruler/jeanne_god.vpcf"
end

function modifier_jeanne_gods_resolution_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then 
	function modifier_jeanne_gods_resolution_buff:OnCreated(args)
		self.caster = self:GetParent()
		self.damage = self:GetAbility():GetSpecialValueFor("bonus_hp_dmg")/100 * self.caster:GetMaxHealth()
	end
	function modifier_jeanne_gods_resolution_buff:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		local target = args.target
		if self.caster:HasModifier("modifier_jeanne_saint") and not IsImmuneToCC(target) then
			target:AddNewModifier(self.caster, self:GetAbility(), "modifier_stunned", { Duration = 0.1 })
		end

		target:EmitSound("Hero_Chen.TeleportOut")
		local bashFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_sparks.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( bashFx, 0, target:GetAbsOrigin())
		local bashFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_penitence_c.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( bashFx2, 0, target:GetAbsOrigin())

		DoDamage(self.caster, target, self.damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)	
	end 
end

----------------------------

function modifier_jeanne_gods_resolution_buff2:IsHidden() return true end
function modifier_jeanne_gods_resolution_buff2:IsDebuff() return false end
function modifier_jeanne_gods_resolution_buff2:IsPassive() return false end
function modifier_jeanne_gods_resolution_buff2:IsPurgable() return false end
function modifier_jeanne_gods_resolution_buff2:RemoveOnDeath() return true end
function modifier_jeanne_gods_resolution_buff2:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_jeanne_gods_resolution_buff2:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_jeanne_gods_resolution_buff2:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_reg")
end

function modifier_jeanne_gods_resolution_buff2:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_jeanne_gods_resolution_buff2:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_def")
end

function modifier_jeanne_gods_resolution_buff2:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_def")
end