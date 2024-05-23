jtr_surgery = class({})

LinkLuaModifier("modifier_surgery_heal", "abilities/jtr/modifiers/modifier_surgery_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_whitechapel_window", "abilities/jtr/modifiers/modifier_whitechapel_window", LUA_MODIFIER_MOTION_NONE)

function jtr_surgery:GetManaCost(iLevel)
	if self:GetCaster():HasModifier("modifier_surgical_procedure") then
		return 0
	else
		return 200
	end
end

function jtr_surgery:OnSpellStart()
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	caster:AddNewModifier(caster, self, "modifier_surgery_heal", { Duration = self:GetSpecialValueFor("duration"),
																   HealAmt = self:GetSpecialValueFor("heal"),
																   CooldownReduction = self:GetSpecialValueFor("cooldown_reduc") })

	self:CheckCombo()
end

function jtr_surgery:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_surgery_heal")
end

function jtr_surgery:EndChannel(bInterrupted)
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_surgery_heal")
end

function jtr_surgery:CheckCombo()
	local caster = self:GetCaster()
	local ability = self
	if caster:GetStrength() >= 29.1 and caster:GetAgility() >= 29.1 and caster:GetIntellect() >= 29.1 then      
    	if caster:FindAbilityByName("jtr_whitechapel_murderer"):IsCooldownReady() 
    		and caster:HasModifier("modifier_murderer_mist") then

    		caster:AddNewModifier(caster, self, "modifier_whitechapel_window", { Duration = 4 })
        end
    end
end