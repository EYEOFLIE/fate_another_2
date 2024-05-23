
ishtar_d = class({})
ishtar_d_upgrade = class({})
ishtar_f = class({})
modifier_ishtar_gem = class{()}
modifier_ishtar_gem_consume = class{()}

LinkLuaModifier("modifier_ishtar_gem", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_gem_consume", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)

function ishtar_d_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end

	function abil:GetManaCost(iLevel)
		return 50
	end

	function abil:GetGoldCost(iLevel)
		return self:GetSpecialValueFor("gem_cost")
	end

	function abil:GetCastAnimation()
		return nil
	end

	function abil:CastFilterResult()
		local caster = self:GetCaster()

		if caster.Is then 
			return UF_SUCCESS
		else
			if self:IsMaxGem() then 
				return UF_FAIL_CUSTOM
			else
				return UF_SUCCESS
			end
		end
	end

	function abil:GetCustomCastError()
		return "Gems reach maximum stacks."
	end

	function abil:GetIntrinsicModifierName()
		return "modifier_ishtar_gem"
	end

	function abil:OnSpellStart()
		local caster = self:GetCaster()
		self:AddGem()
	end

	function abil:AddGem()
		local caster = self:GetCaster()
		caster:FindModifierByName("modifier_ishtar_gem"):AddGem(+1)
	end

	function abil:IsMaxGem()
		local caster = self:GetCaster()

		if caster.Is then 
			return false 
		else 
			local current_stack = gem:GetStackCount() or 0

			if current_stack >= self:GetSpecialValueFor("max_gem") then 
				return true 
			else
				return false 
			end
		end
	end
end

ishtar_d_wrapper(ishtar_d)
ishtar_d_wrapper(ishtar_d_upgrade)

---------------------------------------

function modifier_ishtar_gem:IsPassive()
	return true 
end

function modifier_ishtar_gem:IsDebuff()
	return false 
end

function modifier_ishtar_gem:IsHidden()
	return false 
end

function modifier_ishtar_gem:RemoveOnDeath()
	return false 
end

function modifier_ishtar_gem:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_gem:AddGem(iGems)
	self:SetStackCount(math.max(self:GetStackCount() + iGems, 0))
	if self:GetStackCount() + iGems <= 0 then 
		if self:GetParent():HasModifier("modifier_ishtar_gem_consume") then 
			self:GetParent():FindAbilityByName("ishtar_f"):ToggleAbility()
		end
	end
end

function modifier_ishtar_gem:OnDeath()
	if not self:GetParent().is then 
		self:AddGem(- self:GetAbility():GetSpecialValueFor("gem_loss"))
	end
end

----------------------------------------

function ishtar_f:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function ishtar_f:ResetToggleOnRespawn()
	return true 
end

function ishtar_f:GetCastAnimation()
	return nil 
end

function ishtar_f:CastFilterResult()
	local caster = self:GetCaster()

	if caster:FindModifierByName("modifier_ishtar_gem"):GetStackCount() <= 0 then 
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function ishtar_f:GetCustomCastError()
	return "Not enough Gems."
end

function ishtar_f:OnToggle()
	local caster = self:GetCaster()

	if not self:GetToggleState() and caster:HasModifier("modifier_ishtar_gem_consume") then 
		caster:RemoveModifierByName("modifier_ishtar_gem_consume")
	else
		caster:AddNewModifier(caster, self, "modifier_ishtar_gem_consume", {})
	end
end

-----------------------------------------

function modifier_ishtar_gem_consume:IsPassive()
	return false 
end

function modifier_ishtar_gem_consume:IsDebuff()
	return false 
end

function modifier_ishtar_gem_consume:IsHidden()
	return false 
end

function modifier_ishtar_gem_consume:RemoveOnDeath()
	return false 
end

function modifier_ishtar_gem_consume:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end