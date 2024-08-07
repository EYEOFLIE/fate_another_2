
medusa_mystic_eye = class({})
modifier_mystic_eye_aura_passive = class({})
modifier_mystic_eye_cooldown = class({})
modifier_mystic_eye_active = class({})
modifier_mystic_eye_enemy = class({})
modifier_mystic_eye_active_enemy = class({})

LinkLuaModifier("modifier_mystic_eye_aura_passive", "abilities/medusa/medusa_mystic_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mystic_eye_cooldown", "abilities/medusa/medusa_mystic_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mystic_eye_active", "abilities/medusa/medusa_mystic_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mystic_eye_enemy", "abilities/medusa/medusa_mystic_eye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mystic_eye_active_enemy", "abilities/medusa/medusa_mystic_eye", LUA_MODIFIER_MOTION_NONE)

function medusa_mystic_eye:GetBehavior()
	if self:GetCaster() then 
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_AURA + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	else 
		return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end
end

function medusa_mystic_eye:GetCooldown(iLevel)
	if self:GetCaster() then 
		return self:GetSpecialValueFor("active_cooldown")
	else 
		return 0
	end
end

function medusa_mystic_eye:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function medusa_mystic_eye:OnSpellStart()
	self.caster = self:GetCaster()
	self.caster:AddNewModifier(self.caster, self, "modifier_mystic_eye_cooldown", {Duration = self:GetSpecialValueFor("active_cooldown")})
	self.caster:AddNewModifier(self.caster, self, "modifier_mystic_eye_active", {Duration = self:GetSpecialValueFor("active_duration")})
end

function medusa_mystic_eye:GetIntrinsicModifierName()
	return "modifier_mystic_eye_aura_passive"
end

------------------------------------------------------------------

function modifier_mystic_eye_aura_passive:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_mystic_eye_aura_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mystic_eye_aura_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_mystic_eye_aura_passive:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
end

function modifier_mystic_eye_aura_passive:GetAuraEntityReject(hEntity)
	if IsImmuneToCC(hEntity) or IsImmuneToSlow(hEntity) or hEntity:IsMagicImmune() then
		return false 
	else
		return true
	end
end

function modifier_mystic_eye_aura_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mystic_eye_aura_passive:GetModifierAura()
	return "modifier_mystic_eye_enemy"
end

function modifier_mystic_eye_aura_passive:IsPassive()
	return true 
end

function modifier_mystic_eye_aura_passive:IsHidden()
	return true 
end

function modifier_mystic_eye_aura_passive:IsDebuff()
	return false 
end

------------------------------------------------------------------

function modifier_mystic_eye_enemy:OnCreated(table)
	if IsServer() then
		self.MysticSlow	= self:GetAbility():GetSpecialValueFor("tt_slow")
		CustomNetTables:SetTableValue("sync","mystic_eye_slow", {ms_slow = self.MysticSlow})

		StartIntervalThink(0.1)
	end
end

function modifier_mystic_eye_enemy:OnIntervalThink()
	if self:IsHidden() == false then
		local keys = {keys.caster = self:GetCaster()}
		CCTime(keys)
	end
end

function modifier_mystic_eye_enemy:OnRefresh(table)
	self:OnCreated(table)
end

function modifier_mystic_eye_enemy:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

	return funcs
end

function modifier_mystic_eye_enemy:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then        
		if self:GetParent():HasModifier("modifier_mystic_eye_active_enemy") then 
			return 0 
		else
    		return self.MysticSlow
    	end
    elseif IsClient() then
    	if self:GetParent():HasModifier("modifier_mystic_eye_active_enemy") then 
			return 0 
		else
	        local mystic_eye_slow = CustomNetTables:GetTableValue("sync","mystic_eye_slow").ms_slow
	        return mystic_eye_slow 
	    end
    end
end

function modifier_mystic_eye_enemy:GetAttributes()
  return MODIFIER_ATTRIBUTE_NONE
end

function modifier_mystic_eye_enemy:IsDebuff()
	return true 
end

function modifier_mystic_eye_enemy:RemoveOnDeath()
	return true 
end

function modifier_mystic_eye_enemy:IsPassive()
	return false 
end

function modifier_mystic_eye_enemy:IsHidden()
	if self:GetParent():HasModifier("modifier_mystic_eye_active_enemy") then 
		return true 
	else
		return false 
	end
end

function modifier_mystic_eye_enemy:GetEffectName()
	return "particles/custom/rider/rider_mystic_eye_debuff.vpcf"
end

function modifier_mystic_eye_enemy:GetTexture()
    return "custom/medusa/medusa_mystic_eye"
end

function modifier_mystic_eye_enemy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

----------------------------------------------------------

function modifier_mystic_eye_active:OnCreated(table)
	self.caster = self:GetCaster()
	if self.caster.aura_fx == nil then
		self.caster.aura_fx = ParticleManager:CreateParticle("particles/custom/medusa/medusa_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
		ParticleManager:SetParticleControl(self.caster.aura_fx, 0, self.caster:GetAbsOrigin()) 
		ParticleManager:SetParticleControl(self.caster.aura_fx, 1, Vector(self:GetAbility():GetSpecialValueFor("active_radius"),0,0))
	end
end

function modifier_mystic_eye_active:OnDestroy()
	if self.caster.aura_fx ~= nil then
		ParticleManager:DestroyParticle(self.caster.aura_fx, true)
		ParticleManager:ReleaseParticleIndex(self.caster.aura_fx)
		self.caster.aura_fx = nil
	end	
end

function modifier_mystic_eye_active:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("active_radius")
end

function modifier_mystic_eye_active:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mystic_eye_active:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_mystic_eye_active:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_mystic_eye_active:GetAuraEntityReject(hEntity)
	return true
end

function modifier_mystic_eye_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mystic_eye_active:GetModifierAura()
	return "modifier_mystic_eye_active_enemy"
end

function modifier_mystic_eye_active:GetTexture()
    return "custom/medusa/medusa_mystic_eye"
end

function modifier_mystic_eye_active:IsPassive()
	return false 
end

function modifier_mystic_eye_active:IsHidden()
	return false 
end

function modifier_mystic_eye_active:IsDebuff()
	return false 
end

------------------------------------------------------------------

function modifier_mystic_eye_active_enemy:OnCreated(table)
	if IsServer() then
		self.MysticActiveSlow = self:GetAbility():GetSpecialValueFor("active_slow")
		CustomNetTables:SetTableValue("sync","mystic_eye_active_slow", {slow = self.MysticActiveSlow})

		StartIntervalThink(0.1)
	end
end

function modifier_mystic_eye_active_enemy:OnIntervalThink()
	local keys = {keys.caster = self:GetCaster()}
	CCTime(keys)
end

function modifier_mystic_eye_active_enemy:OnRefresh(table)
	self:OnCreated(table)
end

function modifier_mystic_eye_active_enemy:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT}

	return funcs
end

function modifier_mystic_eye_active_enemy:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then        
    	return self.MysticActiveSlow
    elseif IsClient() then
	    local mystic_eye_slow = CustomNetTables:GetTableValue("sync","mystic_eye_active_slow").slow
	    return mystic_eye_slow 
    end
end

function modifier_mystic_eye_active_enemy:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then        
    	return self.MysticActiveSlow
    elseif IsClient() then
	    local mystic_eye_slow = CustomNetTables:GetTableValue("sync","mystic_eye_active_slow").slow
	    return mystic_eye_slow 
    end
end

function modifier_mystic_eye_active_enemy:GetAttributes()
  return MODIFIER_ATTRIBUTE_NONE
end

function modifier_mystic_eye_active_enemy:IsDebuff()
	return true 
end

function modifier_mystic_eye_active_enemy:RemoveOnDeath()
	return true 
end

function modifier_mystic_eye_active_enemy:IsPassive()
	return false 
end

function modifier_mystic_eye_active_enemy:IsHidden()
	return false 
end

function modifier_mystic_eye_active_enemy:GetEffectName()
	return "particles/custom/rider/rider_mystic_eye_debuff.vpcf"
end

function modifier_mystic_eye_active_enemy:GetTexture()
    return "custom/medusa/medusa_mystic_eye"
end

function modifier_mystic_eye_active_enemy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

---------------------------------------------------------

function modifier_mystic_eye_cooldown:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_mystic_eye_cooldown:IsHidden()
	return false 
end

function modifier_mystic_eye_cooldown:IsDebuff()
	return true 
end 

function modifier_mystic_eye_cooldown:GetTexture()
	return "custom/medusa/medusa_mystic_eye"
end