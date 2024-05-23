gilles_prelati_spellbook = class({})
gilles_prelati_spellbook_upgrade = class({})

LinkLuaModifier("modifier_prelati_regen", "abilities/gilles/modifiers/modifier_prelati_regen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_selfish_self_invul", "abilities/gilles/modifiers/modifier_selfish_self_invul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prelati_regen_block", "abilities/gilles/modifiers/modifier_prelati_regen_block", LUA_MODIFIER_MOTION_NONE)

function gilles_prelati_wrapper(ability)
    function ability:IsHiddenAbilityCastable()
        return true
    end

    function ability:OnSpellStart()
    	local caster = self:GetCaster()

    	caster:EmitSound("Hero_Warlock.ShadowWord")
    	caster:AddNewModifier(caster, self, "modifier_selfish_self_invul", { Duration = self:GetSpecialValueFor("duration") })
        caster:AddNewModifier(caster, self, "modifier_prelati_regen_block", { Duration = self:GetSpecialValueFor("block_duration") })
    	
    	self.ShieldFX = ParticleManager:CreateParticle("particles/custom/gilles_prelati_shield_aura.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(self.ShieldFX, 0, caster:GetAbsOrigin())
    end

    function ability:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        
        caster:StopSound("Hero_Warlock.ShadowWord")
        caster:RemoveModifierByName("modifier_selfish_self_invul")

        ParticleManager:DestroyParticle( self.ShieldFX, false )
        ParticleManager:ReleaseParticleIndex( self.ShieldFX )
    end

    function ability:GetIntrinsicModifierName()
        return "modifier_prelati_regen"
    end
end

gilles_prelati_wrapper(gilles_prelati_spellbook)
gilles_prelati_wrapper(gilles_prelati_spellbook_upgrade)