modifier_enuma_elish_bandaid = class({})

function modifier_enuma_elish_bandaid:IsHidden()
	return true
end

function modifier_enuma_elish_bandaid:IsDebuff()
	return true
end

function modifier_enuma_elish_bandaid:RemoveOnDeath()
	return true
end

function modifier_enuma_elish_bandaid:IsPurgable()
	return false
end