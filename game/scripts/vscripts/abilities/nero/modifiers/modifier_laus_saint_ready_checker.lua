modifier_laus_saint_ready_checker = class({})

function modifier_laus_saint_ready_checker:IsHidden()
	return true 
end

function modifier_laus_saint_ready_checker:OnCreated(args)
	if IsServer() then
		local caster = self:GetParent()
		if caster.IsSoverignsGloryAcquired then
			caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea_upgrade", true, false)
		else
			caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea", true, false)
		end
	end
end

function modifier_laus_saint_ready_checker:OnRefresh(args)
	self:OnCreated(args)
end

function modifier_laus_saint_ready_checker:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		if caster.IsSoverignsGloryAcquired then
			caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea_upgrade", false, true)
		else
			caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea", false, true)
		end
	end
end

function modifier_laus_saint_ready_checker:RemoveOnDeath()
	return true
end

function modifier_laus_saint_ready_checker:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end