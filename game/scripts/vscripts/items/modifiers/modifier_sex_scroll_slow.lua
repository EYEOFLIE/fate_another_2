modifier_sex_scroll_slow = class({})

function modifier_sex_scroll_slow:OnCreated()    
    self.slowPerc = -100.0
    self.slowDur = 4.0

    if IsServer() then
        self:StartIntervalThink(0.1)

        CustomNetTables:SetTableValue("sync","s_scroll_slow" .. self:GetParent():GetName(), { slow = self.slowPerc })
    end
end

function modifier_sex_scroll_slow:OnRefresh()
    self:OnCreated()
end

function modifier_sex_scroll_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_sex_scroll_slow:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then        
        return self.slowPerc
    elseif IsClient() then
        local slow = CustomNetTables:GetTableValue("sync","s_scroll_slow" .. self:GetParent():GetName()).slow
        return slow 
    end
end

function modifier_sex_scroll_slow:OnIntervalThink()
    if self.slowDur > 0 then
        self.state = {}
        self.slowPerc = self.slowPerc + (100.0 / 4.0 * 0.1)
        self.slowDur = self.slowDur - 0.1

        CustomNetTables:SetTableValue("sync","s_scroll_slow" .. self:GetParent():GetName(), { slow = self.slowPerc })
    else  
        self:StartIntervalThink(-1)
        self:Destroy()
    end
end

-----------------------------------------------------------------------------------
function modifier_sex_scroll_slow:GetEffectName()
    return "particles/items_fx/diffusal_slow.vpcf"
end

function modifier_sex_scroll_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sex_scroll_slow:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_sex_scroll_slow:IsPurgable()
    return false
end

function modifier_sex_scroll_slow:IsDebuff()
    return true
end


function modifier_sex_scroll_slow:RemoveOnDeath()
    return true
end

function modifier_sex_scroll_slow:GetTexture()
    return "custom/s_scroll"
end
-----------------------------------------------------------------------------------
