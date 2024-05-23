nobu_double_shots_stop = class({})
 
function nobu_double_shots_stop:OnSpellStart()
    local hCaster = self:GetCaster()
    local pID = hCaster:GetPlayerOwnerID()
    Timers:RemoveTimer("nobu_shoots" .. pID)
    
    hCaster:RemoveModifierByName("modifier_nobu_turnlock")
    hCaster:RemoveModifierByName("modifier_nobu_e_window")    
end