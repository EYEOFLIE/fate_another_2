modifier_calydonian_hunt_sight = class({})

--[[function modifier_calydonian_hunt_sight:OnCreated(table)
	self:GetParent()
end]]

function modifier_calydonian_hunt_sight:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }
 
    return funcs
end

--function modifier_calydonian_hunt_sight:CheckState()
--end

function modifier_calydonian_hunt_sight:GetModifierProvidesFOWVision()
    return 1
end

function modifier_calydonian_hunt_sight:IsDebuff()
    return true
end

function modifier_calydonian_hunt_sight:RemoveOnDeath()
    return true
end

function modifier_calydonian_hunt_sight:GetTexture()
    return "custom/atalanta_calydonian_hunt"
end