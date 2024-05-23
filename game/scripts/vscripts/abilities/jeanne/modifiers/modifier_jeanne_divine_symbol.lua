modifier_jeanne_divine_symbol = class({})

LinkLuaModifier("modifier_jeanne_vision", "abilities/jeanne/modifiers/modifier_jeanne_vision", LUA_MODIFIER_MOTION_NONE)

function modifier_jeanne_divine_symbol:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_jeanne_divine_symbol:OnCreated(args)
	if IsServer() then
		self.BaseDamage = args.BaseDamage
		self.BonusInt = args.BonusInt
		self.Radius = args.Radius
	end
end

if IsServer() then
	function modifier_jeanne_divine_symbol:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end
		
		local hTarget = args.target
		local hAttacker = args.attacker
		local base_damage = self.BaseDamage
		local int_ratio = self.BonusInt
		local fDamage = (hAttacker:GetIntellect() * int_ratio) + base_damage

		DoDamage(hAttacker, hTarget, fDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
	end
end

function modifier_jeanne_divine_symbol:IsDebuff()
	return false
end

function modifier_jeanne_divine_symbol:IsAura()
	return true 
end

function modifier_jeanne_divine_symbol:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_jeanne_divine_symbol:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_jeanne_divine_symbol:GetAuraRadius()
	return self.Radius
end

function modifier_jeanne_divine_symbol:GetModifierAura()
	return "modifier_jeanne_vision"
end

function modifier_jeanne_divine_symbol:GetTexture()
	return "custom/jeanne_attribute_divine_symbol"
end