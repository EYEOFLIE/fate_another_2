modifier_murderer_mist_invis = class({})

LinkLuaModifier("modifier_murderer_mist_slow", "abilities/jtr/modifiers/modifier_murderer_mist_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mist_fade", "abilities/jtr/modifiers/modifier_mist_fade", LUA_MODIFIER_MOTION_NONE)

function modifier_murderer_mist_invis:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

if IsServer() then 
	function modifier_murderer_mist_invis:OnCreated(args)
		self.State = {}
		self.FadeTime = args.FadeTime

		self:StartIntervalThink(0.033)
	end

	function modifier_murderer_mist_invis:OnRefresh(args)		
		self:OnCreated(args)
	end

	function modifier_murderer_mist_invis:OnIntervalThink()
		if (self:GetParent():HasModifier("modifier_murderer_mist") 
			or self:GetParent():HasModifier("modifier_whitechapel_murderer")) 
		and not (self:GetParent():HasModifier("modifier_inside_marble") or self:GetParent():HasModifier("modifier_jeanne_vision") or self:GetParent():HasModifier("modifier_mist_fade")) then
			self.State = { [MODIFIER_STATE_INVISIBLE] = true}
		else
			self.State = {}
		end
	end

	function modifier_murderer_mist_invis:CheckState()
		return self.State
	end

	function modifier_murderer_mist_invis:OnAttackLanded(args)
		if args.attacker ~= self:GetParent() then return end

		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_mist_fade", {Duration = self.FadeTime})

		--[[if not IsFacingUnit(args.target, args.attacker, 90) then
			DoDamage(args.attacker, args.target, self.OnHitDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)

			if not IsImmuneToSlow(args.target) then
				args.target:AddNewModifier(args.attacker, self:GetAbility(), "modifier_murderer_mist_slow", { Duration = 0.4,
																											  SlowPct = self.SlowPct })
			end
			args.target:EmitSound("jtr_backstab")
		end]]
	end

	function modifier_murderer_mist_invis:OnTakeDamage()

		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_mist_fade", {Duration = self.FadeTime})

	end
end

function modifier_murderer_mist_invis:IsHidden()
	return (not self:GetParent():HasModifier("modifier_murderer_mist"))
end

function modifier_murderer_mist_invis:GetEffectName()
	return "particles/generic_hero_status/status_invisibility_start.vpcf"
end

function modifier_murderer_mist_invis:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_murderer_mist_invis:GetTexture()
	return "custom/jtr/murderer_misty_night"
end
