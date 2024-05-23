modifier_gilles_combo_window = class({})

if IsServer() then
	function modifier_gilles_combo_window:OnCreated(args)
		if self:GetParent().IsAbyssalConnectionAcquired then
			print('. . .')
			self:GetParent():SwapAbilities("gilles_abyssal_contract_upgrade", "gille_larret_de_mort", false, true) 
		else
			print(' bad')
			self:GetParent():SwapAbilities("gilles_abyssal_contract", "gille_larret_de_mort", false, true)
		end 
	end

	function modifier_gilles_combo_window:OnRefresh(args)
	end

	function modifier_gilles_combo_window:OnDestroy()
		if self:GetParent().IsAbyssalConnectionAcquired then
			self:GetParent():SwapAbilities("gille_larret_de_mort", "gilles_abyssal_contract_upgrade", false, true)
		else
			self:GetParent():SwapAbilities("gille_larret_de_mort", "gilles_abyssal_contract", false, true)
		end
	end
end

function modifier_gilles_combo_window:IsHidden()
	return true 
end

function modifier_gilles_combo_window:RemoveOnDeath()
	return true
end