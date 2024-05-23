modifier_uncrowned_martial_arts = class({})

function modifier_uncrowned_martial_arts:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then
	function modifier_uncrowned_martial_arts:OnCreated(args)
		self.caster = self:GetParent()

		self.Active = false
		self.Evasion = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_evasion")
		self.Movespeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_movement_speed")
		self.AttackSpeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_attack_speed")

		self.EvasionGain = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("evasion_gain")
		self.MovespeedGain = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("movement_speed_gain")
		self.AttackSpeedGain = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("attack_speed_gain")

		self.MaxEvasion = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("max_evasion")
		self.MaxMovespeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("max_movement_speed")
		self.MaxAttackSpeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("max_attack_speed")

		CustomNetTables:SetTableValue("sync","uncrowned_martial_arts", { evasion = self.Evasion,
																		 movespeed = self.Movespeed,
																		 attack_speed = self.AttackSpeed })
	end

	function modifier_uncrowned_martial_arts:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		self.Evasion = math.min(self.Evasion + self.EvasionGain, self.MaxEvasion)
		self.Movespeed = math.min(self.Movespeed + self.MovespeedGain, self.MaxMovespeed)
		self.AttackSpeed = math.min(self.AttackSpeed + self.AttackSpeedGain, self.MaxAttackSpeed)

		CustomNetTables:SetTableValue("sync","uncrowned_martial_arts", { evasion = self.Evasion,
																		 movespeed = self.Movespeed,
																		 attack_speed = self.AttackSpeed })
		self:StartIntervalThink(2)
	end


	function modifier_uncrowned_martial_arts:OnIntervalThink()
		self.Evasion = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_evasion")
		self.Movespeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_movement_speed")
		self.AttackSpeed = self.caster.MasterUnit2:FindAbilityByName("karna_attribute_ucm"):GetSpecialValueFor("base_attack_speed")

		CustomNetTables:SetTableValue("sync","uncrowned_martial_arts", { evasion = self.Evasion,
																		 movespeed = self.Movespeed,
																		 attack_speed = self.AttackSpeed })
		self:StartIntervalThink(-1)
	end
end

function modifier_uncrowned_martial_arts:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.AttackSpeed
	elseif IsClient() then
		local attack_speed = CustomNetTables:GetTableValue("sync","uncrowned_martial_arts").attack_speed
        return attack_speed 
	end
end

function modifier_uncrowned_martial_arts:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then
		return self.Movespeed
	elseif IsClient() then
		local movespeed = CustomNetTables:GetTableValue("sync","uncrowned_martial_arts").movespeed
        return movespeed 
	end
end

function modifier_uncrowned_martial_arts:GetModifierEvasion_Constant()
	if IsServer() then
		return self.Evasion
	elseif IsClient() then
		local evasion = CustomNetTables:GetTableValue("sync","uncrowned_martial_arts").evasion
        return evasion 		
	end
end

function modifier_uncrowned_martial_arts:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_uncrowned_martial_arts:GetTexture()
	return "custom/karna/karna_uncrowned_martial_arts"
end