modifier_karna_combo_window = class({})

if IsServer() then
	function modifier_karna_combo_window:OnCreated(args)
		self.caster = self:GetParent()
		if self.caster.IndraAttribute then	
			self.caster:SwapAbilities("karna_vasavi_shakti_upgrade", "karna_combo_vasavi_upgrade", false, true)
		else	
			self.caster:SwapAbilities("karna_vasavi_shakti", "karna_combo_vasavi", false, true)
		end
	end

	function modifier_karna_combo_window:OnDestroy()
		if self.caster.IndraAttribute then	
			self.caster:SwapAbilities("karna_vasavi_shakti_upgrade", "karna_combo_vasavi_upgrade", true, false)
		else	
			self.caster:SwapAbilities("karna_vasavi_shakti", "karna_combo_vasavi", true, false)
		end
	end
end

function modifier_karna_combo_window:IsHidden()
	return true
end