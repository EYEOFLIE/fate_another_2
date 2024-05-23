modifier_courage_self_buff = class({})

if IsServer() then
	function modifier_courage_self_buff:OnCreated(args)	
		self:SetStackCount(args.Stacks or 1)

		self.Particle = ParticleManager:CreateParticle("particles/custom/berserker/courage/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(self.Particle, 1, Vector(self:GetStackCount() + 1,1,1))
		ParticleManager:SetParticleControl(self.Particle, 3, Vector(400,1,1))	
	end

	function modifier_courage_self_buff:OnRefresh(args)
		self:SetStackCount(math.min(self:GetStackCount() + 1, 5))
		
		ParticleManager:SetParticleControl(self.Particle, 1, Vector(self:GetStackCount() + 1,1,1))
		ParticleManager:SetParticleControl(self.Particle, 3, Vector(400,1,1))
	end

	function modifier_courage_self_buff:OnDestroy()
		ParticleManager:DestroyParticle(self.Particle, false)
		ParticleManager:ReleaseParticleIndex(self.Particle)
	end
end

function modifier_courage_self_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			 MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_courage_self_buff:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("self_armor_reduc") * self:GetStackCount()
end

function modifier_courage_self_buff:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetStackCount()
end

function modifier_courage_self_buff:IsHidden()
	return false
end

function modifier_courage_self_buff:IsDebuff()
	return false
end

function modifier_courage_self_buff:RemoveOnDeath()
	return true
end

function modifier_courage_self_buff:GetAttributes()
  return MODIFIER_ATTRIBUTE_NONE
end

function modifier_courage_self_buff:GetTexture()
	return "custom/berserker_5th_courage"
end