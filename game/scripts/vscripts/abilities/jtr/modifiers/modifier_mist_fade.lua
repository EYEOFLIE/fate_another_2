modifier_mist_fade = = class({})

function modifier_mist_fade:IsHidden() return false end
function modifier_mist_fade:IsDebuff() return true end
function modifier_mist_fade:RemoveOnDeath() return true end