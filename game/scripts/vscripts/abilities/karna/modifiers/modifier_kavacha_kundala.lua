modifier_kavacha_kundala = class({})
modifier_kavacha_kundala_progress = class({})

function modifier_kavacha_kundala:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			 MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

if IsServer() then
	function modifier_kavacha_kundala:OnCreated(args)
		self.Caster = self:GetParent()
		self.Armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
		self.MagicResist = self:GetAbility():GetSpecialValueFor("bonus_resist")
		self.ArmorActive = true

		CustomNetTables:SetTableValue("sync","kavacha_kundala", { armor = self.Armor,
																  magic_resist = self.MagicResist })
	end

	function modifier_kavacha_kundala:OnIntervalThink()
		self.Armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
		self.MagicResist = self:GetAbility():GetSpecialValueFor("bonus_resist")
		self.ArmorActive = true

		CustomNetTables:SetTableValue("sync","kavacha_kundala", { armor = self.Armor,
																  magic_resist = self.MagicResist })

		self:StartIntervalThink(-1)

		if self.Caster:HasModifier("modifier_padoru") then 

		else
			if not self.Caster:HasModifier('modifier_alternate_01') and not self.Caster:HasModifier('modifier_alternate_02') then 
				self.Caster:SetModel("models/karna/default/karna_by_zefiroft.vmdl")
				self.Caster:SetOriginalModel("models/karna/default/karna_by_zefiroft.vmdl")
				self.Caster:SetModelScale(1.20)	
			end
		end

		local progress = self:GetParent():FindModifierByName("modifier_rune_of_ferocity_progress")
		if progress then
			progress:SetStackCount(100)
			progress:StartIntervalThink(-1)
		end
	end

	function modifier_kavacha_kundala:RemoveArmor(remove_duration)
		if self.ArmorActive == false then return end

		self.Armor = 0
		self.MagicResist = 0
		self.ArmorActive = false

		if self.Caster:HasModifier("modifier_padoru") then 

		else
			if not self.Caster:HasModifier('modifier_alternate_01') and not self.Caster:HasModifier('modifier_alternate_02') then 
				self.Caster:SetModel("models/karna/default/karna_armorless_by_zefiroft.vmdl")
				self.Caster:SetOriginalModel("models/karna/default/karna_armorless_by_zefiroft.vmdl")
				self.Caster:SetModelScale(1.20)	
			end
		end

		CustomNetTables:SetTableValue("sync","kavacha_kundala", { armor = self.Armor,
																  magic_resist = self.MagicResist })

		self:StartIntervalThink(remove_duration)
		local progress = self:GetParent():FindModifierByName("modifier_kavacha_kundala_progress")
		if progress then
			progress.TotalDuration = remove_duration
			progress.DurationLeft = remove_duration
			progress:StartIntervalThink(0.05)
		end
	end
end

function modifier_kavacha_kundala:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return self.MagicResist
	elseif IsClient() then
		local magic_resist = CustomNetTables:GetTableValue("sync","kavacha_kundala").magic_resist
        return magic_resist 
	end
end

function modifier_kavacha_kundala:GetModifierPhysicalArmorBonus()
	if IsServer() then
		return self.Armor
	elseif IsClient() then
		local armor = CustomNetTables:GetTableValue("sync","kavacha_kundala").armor
        return armor 
	end
end

function modifier_kavacha_kundala:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kavacha_kundala:IsDebuff()
	local progress = self:GetParent():GetModifierStackCount("modifier_kavacha_kundala_progress", self:GetParent())
	if progress >= 100 then
		return false
	else
		return true
	end
end


if IsServer() then
	function modifier_kavacha_kundala_progress:OnCreated(args)
		self:SetStackCount(100)
	end

	function modifier_kavacha_kundala_progress:OnIntervalThink()
		if self.DurationLeft == nil or self.DurationLeft == 0 then 
			self:SetStackCount(100)
			self:StartIntervalThink(-1) 
			return
		else
			self.DurationLeft = self.DurationLeft - 0.05
			self:SetStackCount(100 * (1 - self.DurationLeft / self.TotalDuration ))
		end
	end
end

function modifier_kavacha_kundala_progress:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kavacha_kundala_progress:IsHidden()
    return true
end

function modifier_kavacha_kundala_progress:IsDebuff()
    return false
end

function modifier_kavacha_kundala_progress:RemoveOnDeath()
    return false
end
