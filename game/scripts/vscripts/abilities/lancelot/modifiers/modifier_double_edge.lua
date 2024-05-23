modifier_double_edge = class({})

function modifier_double_edge:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			 MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			 MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			 MODIFIER_EVENT_ON_TAKEDAMAGE,
			 MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then
	function modifier_double_edge:OnCreated(args)
		self.AttackSpeed = args.AttackSpeed
		self.Movespeed = args.Movespeed
		self.DamageAmp = args.DamageAmp

		self.MaxAttackSpeed = args.MaxAttackSpeed
		self.MaxMovespeed = args.MaxMovespeed
		self.MaxDamageAmp = args.MaxDamageAmp

		CustomNetTables:SetTableValue("sync","double_edge", { attack_speed = self.AttackSpeed,
															  movespeed = self.Movespeed,
															  damage_amp = self.DamageAmp })

		self:StartIntervalThink(1)
	end

	function modifier_double_edge:OnRefresh(args)
		self:OnCreated(args)
	end

	function modifier_double_edge:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		self.AttackSpeed = math.min(self.AttackSpeed + 10, self.MaxAttackSpeed)
		self.Movespeed = math.min(self.Movespeed + 10, self.MaxMovespeed)
		self.DamageAmp = math.min(self.DamageAmp + 5, self.MaxDamageAmp)

		CustomNetTables:SetTableValue("sync","double_edge", { attack_speed = self.AttackSpeed,
															  movespeed = self.Movespeed,
															  damage_amp = self.DamageAmp })
	end

	function modifier_double_edge:OnTakeDamage(args)
		if args.unit ~= self:GetParent() then return end

		self.AttackSpeed = math.min(self.AttackSpeed + 10, self.MaxAttackSpeed)
		self.Movespeed = math.min(self.Movespeed + 10, self.MaxMovespeed)

		CustomNetTables:SetTableValue("sync","double_edge", { attack_speed = self.AttackSpeed,
															  movespeed = self.Movespeed,
															  damage_amp = self.DamageAmp })
	end

	function modifier_double_edge:OnIntervalThink()
		self.AttackSpeed = math.min(self.AttackSpeed + 10, self.MaxAttackSpeed)
		self.Movespeed = math.min(self.Movespeed + 10, self.MaxMovespeed)
		self.DamageAmp = math.min(self.DamageAmp + 5, self.MaxDamageAmp)

		CustomNetTables:SetTableValue("sync","double_edge", { attack_speed = self.AttackSpeed,
															  movespeed = self.Movespeed,
															  damage_amp = self.DamageAmp })
	end
end

function modifier_double_edge:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.AttackSpeed
	elseif IsClient() then
		local attack_speed = CustomNetTables:GetTableValue("sync","double_edge").attack_speed
		return attack_speed 
	end
end

function modifier_double_edge:GetModifierMoveSpeedBonus_Percentage()
	if IsServer() then
		return self.Movespeed
	elseif IsClient() then
		local movespeed = CustomNetTables:GetTableValue("sync","double_edge").movespeed
		return movespeed 
	end
end

function modifier_double_edge:GetModifierIncomingDamage_Percentage()
	if IsServer() then
		return self.DamageAmp
	elseif IsClient() then
		local damage_amp = CustomNetTables:GetTableValue("sync","double_edge").damage_amp
		return damage_amp 
	end
end

function modifier_double_edge:GetTexture()
	return "custom/lancelot_double_edge"
end

function modifier_double_edge:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_double_edge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end