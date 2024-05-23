modifier_murderer_mist_aura = class({})

LinkLuaModifier("modifier_murderer_mist", "abilities/jtr/modifiers/modifier_murderer_mist", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_murderer_mist_aura:OnCreated(args)
		self.AuraRadius = args.AuraRadius	
			
		self.AuraBorderFx = ParticleManager:CreateParticleForTeam("particles/custom/jtr/jtr_invis_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
		ParticleManager:SetParticleControl(self.AuraBorderFx, 0, Vector(args.AuraRadius + 100,0,0))	
		ParticleManager:SetParticleControl(self.AuraBorderFx, 1, Vector(args.AuraRadius + 100,0,0))

		self.MistParticle = ParticleManager:CreateParticle("particles/custom/jtr/murderer_mist.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.MistParticle, 0, self:GetParent():GetAbsOrigin())	
		ParticleManager:SetParticleControl(self.MistParticle, 1, Vector(args.AuraRadius + 300,0,0))	

		--particles/custom/jtr/jtr_invis_ring.vpcf

		CustomNetTables:SetTableValue("sync","jtr_mist_aura", { radius = self.AuraRadius })
	end

	function modifier_murderer_mist_aura:OnDestroy()
		ParticleManager:DestroyParticle(self.AuraBorderFx, false)
		ParticleManager:ReleaseParticleIndex(self.AuraBorderFx)
		ParticleManager:DestroyParticle(self.MistParticle, false)
		ParticleManager:ReleaseParticleIndex(self.MistParticle)
	end
end

function modifier_murderer_mist_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_murderer_mist_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_murderer_mist_aura:GetAuraRadius()
	local aura_radius = 0

	if IsServer() then
		aura_radius = self.AuraRadius
	else
		aura_radius = CustomNetTables:GetTableValue("sync","jtr_mist_aura").radius        
	end
	
	return aura_radius
end

function modifier_murderer_mist_aura:GetModifierAura()
	return "modifier_murderer_mist"
end

function modifier_murderer_mist_aura:IsHidden()
	return true 
end

function modifier_murderer_mist_aura:RemoveOnDeath()
	return true
end

function modifier_murderer_mist_aura:IsDebuff()
	return false 
end

function modifier_murderer_mist_aura:IsAura()
	return true 
end