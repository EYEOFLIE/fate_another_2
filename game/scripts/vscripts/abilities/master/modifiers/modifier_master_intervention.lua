modifier_master_intervention = class({})

function modifier_master_intervention:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_master_intervention:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduc")
end

function modifier_master_intervention:OnCreated(args)
	self.shield = ParticleManager:CreateParticle( "particles/econ/events/ti10/mjollnir_shield_ti10.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.shield, 0, self:GetParent():GetAbsOrigin() + Vector(0,0,100))
end

function modifier_master_intervention:OnDestroy()
	ParticleManager:DestroyParticle( self.shield, false )
    ParticleManager:ReleaseParticleIndex( self.shield )
end