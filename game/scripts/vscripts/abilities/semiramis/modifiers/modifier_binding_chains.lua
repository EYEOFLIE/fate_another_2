modifier_binding_chains = class({})

if IsServer() then
	function modifier_binding_chains:OnCreated(args)
		local target = self:GetParent()
		self.mr_red = args.MagicResist
		CustomNetTables:SetTableValue("sync","semi_bind", { magic_resist = self.mr_red})
		self:InitializeParticles()
	end

	function modifier_binding_chains:OnRefresh(args)
		self:OnDestroy()
		self:OnCreated(args)
	end

	function modifier_binding_chains:OnDestroy()
		self:RemoveParticles()
	end

	function modifier_binding_chains:InitializeParticles()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local portal_loc = caster:GetAbsOrigin() + Vector(0, 0, 250)

		self.chain_1 = ParticleManager:CreateParticle("particles/custom/semiramis/binding_chains.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl(self.chain_1, 0, target:GetAbsOrigin() + RandomVector(25) + Vector(0, 0, RandomInt(30, 100)))
		ParticleManager:SetParticleControl(self.chain_1, 3, target:GetAbsOrigin() + RandomVector(25) + Vector(0, 0, RandomInt(50, 80)))
	end

	function modifier_binding_chains:RemoveParticles()
		ParticleManager:DestroyParticle( self.chain_1, true )
		ParticleManager:ReleaseParticleIndex( self.chain_1 )
	end
end

function modifier_binding_chains:DeclareFunctions()	 
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_binding_chains:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return self.mr_red
	elseif IsClient() then
		local magic_resist = CustomNetTables:GetTableValue("sync","semi_bind").magic_resist
        return magic_resist 
	end
end

function modifier_binding_chains:CheckState()
	return { [MODIFIER_STATE_ROOTED] = true, 
			 [MODIFIER_STATE_SILENCED] = true }
end

function modifier_binding_chains:IsDebuff()
	return true
end

function modifier_binding_chains:RemoveOnDeath()
	return true
end