modifier_true_assassin_selfmod = class({})

function modifier_true_assassin_selfmod:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			 MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			 MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_true_assassin_selfmod:OnCreated(args)
	if IsServer() then
		local caster = self:GetParent()
		local casterStr = math.floor(caster:GetStrength() + 0.5) 
		local casterAgi = math.floor(caster:GetAgility() + 0.5)
		local casterInt = math.floor(caster:GetIntellect() + 0.5)

		print("Normal")
		print(caster:GetStrength(), caster:GetAgility(), caster:GetIntellect())

		print("Ceilings")
		print(casterStr, casterAgi, casterInt)

		self.HealAmt = args.HealAmt
		print(casterStr, casterAgi, casterInt)

		if casterStr == casterAgi and casterStr == casterInt and casterAgi == casterInt then
			CustomNetTables:SetTableValue("sync","self_mod_stats", { str_bonus = (args.BonusStats / 2),
																	 agi_bonus = (args.BonusStats / 2),
																	 int_bonus = (args.BonusStats / 2) })
			self.BonusStr = args.BonusStats / 2
			self.BonusAgi = args.BonusStats / 2
			self.BonusInt = args.BonusStats / 2
		elseif casterStr >= casterAgi and casterStr > casterInt then
			CustomNetTables:SetTableValue("sync","self_mod_stats", { str_bonus = args.BonusStats,
																	 agi_bonus = 0,
																	 int_bonus = 0 })
			self.BonusStr = args.BonusStats
			self.BonusAgi = 0
			self.BonusInt = 0			
		elseif casterAgi > casterStr and casterAgi >= casterInt then
			CustomNetTables:SetTableValue("sync","self_mod_stats", { str_bonus = 0,
																	 agi_bonus = args.BonusStats,
																	 int_bonus = 0 })
			self.BonusStr = 0
			self.BonusAgi = args.BonusStats
			self.BonusInt = 0
		elseif (casterInt > casterAgi and casterInt > casterStr) then
			CustomNetTables:SetTableValue("sync","self_mod_stats", { str_bonus = 0,
																	 agi_bonus = 0,
																	 int_bonus = args.BonusStats })
			self.BonusStr = 0
			self.BonusAgi = 0
			self.BonusInt = args.BonusStats		
		end

		self:StartIntervalThink(0.25)
	end
end

function modifier_true_assassin_selfmod:OnIntervalThink()
	local caster = self:GetParent()

	caster:Heal(self.HealAmt, caster)
end

function modifier_true_assassin_selfmod:GetModifierBonusStats_Strength()
	if IsServer() then       
        return self.BonusStr
    elseif IsClient() then
        local str_bonus = CustomNetTables:GetTableValue("sync","self_mod_stats").str_bonus
        return str_bonus 
    end
end

function modifier_true_assassin_selfmod:GetModifierBonusStats_Agility()
	if IsServer() then       
        return self.BonusAgi
    elseif IsClient() then
        local agi_bonus = CustomNetTables:GetTableValue("sync","self_mod_stats").agi_bonus
        return agi_bonus 
    end
end

function modifier_true_assassin_selfmod:GetModifierBonusStats_Intellect()
	if IsServer() then       
        return self.BonusInt
    elseif IsClient() then
        local int_bonus = CustomNetTables:GetTableValue("sync","self_mod_stats").int_bonus
        return int_bonus 
    end
end

function modifier_true_assassin_selfmod:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_true_assassin_selfmod:IsPurgable()
    return true
end

function modifier_true_assassin_selfmod:IsDebuff()
    return false
end

function modifier_true_assassin_selfmod:RemoveOnDeath()
    return true
end

function modifier_true_assassin_selfmod:GetTexture()
    return "custom/true_assassin_self_modification"
end