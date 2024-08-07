
ishtar_d = class({})
ishtar_d_upgrade = class({})
ishtar_f = class({})
ishtar_f_upgrade = class({})
modifier_ishtar_gem = class({})
modifier_ishtar_gem_consume = class({})
modifier_ishtar_mana_burst_gem = class({})
modifier_ishtar_mana_burst_debuff = class({})
modifier_ishtar_combo_window = class({})

LinkLuaModifier("modifier_ishtar_gem", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_gem_consume", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_mana_burst_gem", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_mana_burst_debuff", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_combo_window", "abilities/ishtar/ishtar_d", LUA_MODIFIER_MOTION_NONE)

function ishtar_d_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end

	function abil:GetIntrinsicModifierName()
		return "modifier_ishtar_gem"
	end

	function abil:GetManaCost(iLevel)
		return 50
	end

	function abil:GetGoldCost(iLevel)
		return self:GetSpecialValueFor("gem_cost")
	end

	function abil:GetCastAnimation()
		return ACT_DOTA_ITEM_LOOK
	end

	function abil:CastFilterResult()
		local caster = self:GetCaster()
		if IsServer() then 
			if caster.IsGemsAcquired then 
				return UF_SUCCESS
			elseif caster:GetGold() < self:GetSpecialValueFor("gem_cost") then
				return UF_FAIL_CUSTOM	
			else
				if caster:GetModifierStackCount("modifier_ishtar_gem", caster) >= self:GetSpecialValueFor("max_gem") then 
					return UF_FAIL_CUSTOM
				else
					return UF_SUCCESS
				end
			end
		end
	end

	function abil:GetCustomCastError()
		if self:IsMaxGem() then 
			return "Gems reach maximum stacks."
		else
			return "Not enough gold."
		end
	end

	function abil:GetIntrinsicModifierName()
		return "modifier_ishtar_gem"
	end

	function abil:OnAbilityPhaseStart()
		self.gold_before = self:GetCaster():GetGold()
	end

	function abil:OnSpellStart()
		local caster = self:GetCaster()
		--local gem_cost = self:GetGoldCost(1)
		self.gold_after = self:GetCaster():GetGold()
		if self.gold_after >= self.gold_before then 
			caster:SpendGold(self:GetSpecialValueFor("gem_cost"), 0)
		end
		self:AddGem(self:GetSpecialValueFor("gem_gain"))
		local particleeff = ParticleManager:CreateParticle("particles/ishtar/ishtar_gem_pickup.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleeff, 0, caster:GetAbsOrigin())

		local num = RandomInt(0, 100)
    	if num <= 20 then
    	caster:EmitSound("Ishtar.Q")
    	end
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ishtar.QSFX", caster)

		--check combo
        if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 and caster:HasModifier("modifier_ishtar_q_use") then       
            if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and not caster:HasModifier("modifier_ishtar_combo_cooldown") then
                if string.match(GetMapName(), "fate_elim") then 
					if GameRules:GetGameTime() <= 30 + _G.RoundStartTime or GameRules:GetGameTime() > 115 + _G.RoundStartTime then
						return 
					end
				end
                local remain_time = caster:FindModifierByName("modifier_ishtar_q_use"):GetRemainingTime()
                caster:AddNewModifier(caster, self, "modifier_ishtar_combo_window", {Duration = remain_time})
            end
        end
		
	end

	if IsServer() then
		function abil:AddGem(iGemGain)
			local caster = self:GetCaster()
			
			if (iGemGain < 0) or (iGemGain > 0 and not self:IsMaxGem()) then
				local gem = caster:FindModifierByName("modifier_ishtar_gem")
				gem:SetStackCount(math.max(gem:GetStackCount() + iGemGain, 0))

				if gem:GetStackCount() <= 0 then 
					if caster:HasModifier("modifier_ishtar_gem_consume") then 
						caster:FindAbilityByName(caster.FSkill):ToggleAbility()
					end
				else
					if caster:HasModifier("modifier_ishtar_gem_consume") then 
						caster:RemoveModifierByName("modifier_ishtar_gem_consume")
						Timers:CreateTimer(0.033, function()
							caster:AddNewModifier(caster, caster:FindAbilityByName(caster.FSkill), "modifier_ishtar_gem_consume", {})
						end)
					end
				end
			end
		end

		function abil:GetCurrentGem()
			local caster = self:GetCaster()
			local stack = caster:FindModifierByName("modifier_ishtar_gem") and caster:FindModifierByName("modifier_ishtar_gem"):GetStackCount() or 0 
			return stack
		end

		function abil:IsMaxGem()
			local caster = self:GetCaster()

			if caster.IsGemsAcquired then 
				return false 
			else 
				local current_stack = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0

				if current_stack >= self:GetSpecialValueFor("max_gem") then 
					return true 
				else
					return false 
				end
			end
		end
	end
end

ishtar_d_wrapper(ishtar_d)
ishtar_d_wrapper(ishtar_d_upgrade)

---------------------------------------

function modifier_ishtar_gem:IsPassive() return true end
function modifier_ishtar_gem:IsDebuff() return false end
function modifier_ishtar_gem:IsHidden() return false end
function modifier_ishtar_gem:RemoveOnDeath() return false end
function modifier_ishtar_gem:IsPurgable() return false end
function modifier_ishtar_gem:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_gem:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_ishtar_gem:OnDeath(args)
	if args.unit ~= self:GetParent() then return end

	local caster = self:GetParent()

	local current_gem = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
	self:GetAbility():AddGem( -math.ceil(self:GetAbility():GetSpecialValueFor("gem_loss")/100 * current_gem))
end

----------------------------------------

function ishtar_f_wrapper(abil)
	function abil:GetBehavior()
		if self:GetCaster():HasModifier("modifier_ishtar_r_channel") then
			return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
		else
			return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
		end
	end

	function abil:GetIntrinsicModifierName()
		if string.match(self:GetAbilityName(), "upgrade") then
			return "modifier_ishtar_mana_burst_gem"
		else
			return nil
		end
	end

	function abil:ResetToggleOnRespawn()
		return true 
	end

	function abil:GetCastAnimation()
		return ACT_DOTA_ITEM_LOOK 
	end

	function abil:CastFilterResult()
		local caster = self:GetCaster()

		if caster:GetModifierStackCount("modifier_ishtar_gem", caster) <= 0 then 
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end

	function abil:GetCustomCastError()
		return "Not enough Gems."
	end

	function abil:OnToggle(args)
		if args ~= nil then 
			print('toggle has some table')
		end
		local caster = self:GetCaster()

		if not self:GetToggleState() and caster:HasModifier("modifier_ishtar_gem_consume") then 
			caster:RemoveModifierByName("modifier_ishtar_gem_consume")
		elseif self:GetToggleState() and not caster:HasModifier("modifier_ishtar_gem_consume") then 
			if caster:GetModifierStackCount("modifier_ishtar_gem", caster) > 0 then
				caster:AddNewModifier(caster, self, "modifier_ishtar_gem_consume", {})
			else
				self:ToggleAbility()
			end
		end
	end

	function abil:AddManaBurstDebuff(hTarget)
		if not IsValidEntity(hTarget) or hTarget:IsNull() or not hTarget:IsAlive() then return end
		if self:GetCaster().IsManaBurstGemAcquired then 
			local caster = self:GetCaster()
			local max_stack = self:GetSpecialValueFor("FStack")

			hTarget:AddNewModifier(caster, self, "modifier_ishtar_mana_burst_debuff", {Duration = self:GetSpecialValueFor("FDuration")})

			local debuff = hTarget:FindModifierByName("modifier_ishtar_mana_burst_debuff")
			debuff:SetStackCount(debuff:GetStackCount() + 1)

			if debuff:GetStackCount() >= max_stack then 
				hTarget:RemoveModifierByName("modifier_ishtar_mana_burst_debuff")
				if not IsImmuneToCC(hTarget) then
					hTarget:AddNewModifier(caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("FStun")})
				end
				DoDamage(caster, hTarget, self:GetSpecialValueFor("FDamage"), DAMAGE_TYPE_MAGICAL, 0, self, false)
			end
		end
	end
end

ishtar_f_wrapper(ishtar_f)
ishtar_f_wrapper(ishtar_f_upgrade)

-----------------------------------------

function modifier_ishtar_gem_consume:IsPassive() return false end
function modifier_ishtar_gem_consume:IsDebuff() return false end
function modifier_ishtar_gem_consume:IsHidden() return false end
function modifier_ishtar_gem_consume:IsPurgable() return false end
function modifier_ishtar_gem_consume:RemoveOnDeath() return true end
function modifier_ishtar_gem_consume:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_gem_consume:OnCreated(args)
	self.caster = self:GetParent()
	self:AttachParticle()
end

function modifier_ishtar_gem_consume:OnDestroy()
	self:DettachParticle()
end

function modifier_ishtar_gem_consume:AttachParticle(iCurrentGem)
	if iCurrentGem == nil then 
		iCurrentGem = self.caster:GetModifierStackCount("modifier_ishtar_gem", self.caster)
	end
	self.particle = true
	self.gem_holder = ParticleManager:CreateParticle("particles/ishtar/ishtar_gem_use.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.gem_holder, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.gem_holder, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.gem_holder, 2, Vector(math.min(iCurrentGem,10),0,0))
end

function modifier_ishtar_gem_consume:UpdateParticle(iCurrentGem)
	
	local delay = 0
	if self.particle == true then 
		print('update gem particle')
		self:DettachParticle()
		delay = 0.066
	end
	Timers:CreateTimer(delay, function()
		self:AttachParticle(iCurrentGem)
	end)
end

function modifier_ishtar_gem_consume:DettachParticle()
	self.particle = false
	ParticleManager:DestroyParticle(self.gem_holder, true)
	ParticleManager:ReleaseParticleIndex(self.gem_holder)
end


-----------------------------------------

function modifier_ishtar_mana_burst_gem:IsPassive() return true end
function modifier_ishtar_mana_burst_gem:IsDebuff() return false end
function modifier_ishtar_mana_burst_gem:IsHidden() return false end
function modifier_ishtar_mana_burst_gem:IsPurgable() return false end
function modifier_ishtar_mana_burst_gem:RemoveOnDeath() return false end
function modifier_ishtar_mana_burst_gem:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_ishtar_mana_burst_gem:GetTexture()
    return "custom/ishtar/sa_offering"
end
--[[function modifier_ishtar_mana_burst_gem:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
function modifier_ishtar_mana_burst_gem:GetModifierOverrideAbilitySpecial(event)
	local caster = self:GetParent()

	if event.ability:IsItem() then return end

    if string.match(event.ability:GetAbilityName(), "ishtar_q") then
        if event.ability_special_value == "GemArrow" then
        	print('q detect')
            return 1
        end
    elseif string.match(event.ability:GetAbilityName(), "ishtar_w") then
        if event.ability_special_value == "GemReduction" then
            return 1
        end
   	elseif string.match(event.ability:GetAbilityName(), "ishtar_e") then
        if event.ability_special_value == "GemArrows" or event.ability_special_value == "MaxArrow" then
            return 1
        end
    elseif string.match(event.ability:GetAbilityName(), "ishtar_r") then
        if event.ability_special_value == "GemArrowDamage" then
            return 1
        end
    elseif string.match(event.ability:GetAbilityName(), "ishtar_combo") then
        if event.ability_special_value == "GemDamage" then
            return 1
        end
    end
    return 0
end

function modifier_ishtar_mana_burst_gem:GetModifierOverrideAbilitySpecialValue(event)	
	local caster = self:GetParent()

	if event.ability:IsItem() then return end

	local Ability = caster:FindAbilityByName(caster.FSkill)
    if string.match(event.ability:GetAbilityName(), "ishtar_q") and event.ability_special_value == "GemArrow" then
    	print('q change value')
        return Ability and Ability:GetSpecialValueFor("QArrow")
    elseif string.match(event.ability:GetAbilityName(), "ishtar_w") and event.ability_special_value == "GemReduction" then
        return Ability and Ability:GetSpecialValueFor("WBonusBlock")
    elseif string.match(event.ability:GetAbilityName(), "ishtar_e") then 
    	if event.ability_special_value == "GemArrows" then
       		return Ability and Ability:GetSpecialValueFor("EArrows")
       	elseif event.ability_special_value == "MaxArrow" then
        	return Ability and Ability:GetSpecialValueFor("EMax")
        end
    elseif string.match(event.ability:GetAbilityName(), "ishtar_r") and event.ability_special_value == "GemArrowDamage" then
        return Ability and Ability:GetSpecialValueFor("RArrowDamage")
    elseif string.match(event.ability:GetAbilityName(), "ishtar_combo") and event.ability_special_value == "GemDamage" then
        return Ability and Ability:GetSpecialValueFor("CDamage")
    end
    return 0
end]]

-----------------------------------------

function modifier_ishtar_mana_burst_debuff:IsPassive() return false end
function modifier_ishtar_mana_burst_debuff:IsDebuff() return true end
function modifier_ishtar_mana_burst_debuff:IsHidden() return false end
function modifier_ishtar_mana_burst_debuff:IsPurgable() return false end
function modifier_ishtar_mana_burst_debuff:RemoveOnDeath() return true end
function modifier_ishtar_mana_burst_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

-------------------------------------------

function modifier_ishtar_combo_window:IsHidden() return true end
function modifier_ishtar_combo_window:IsDebuff() return false end
function modifier_ishtar_combo_window:IsPurgable() return false end
function modifier_ishtar_combo_window:RemoveOnDeath() return true end
function modifier_ishtar_combo_window:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then 
    function modifier_ishtar_combo_window:OnCreated(args)
        self.caster = self:GetParent()
        self.caster:SwapAbilities(self.caster.RSkill, self.caster.ComboSkill, false, true)
    end

    function modifier_ishtar_combo_window:OnDestroy()
        self.caster:SwapAbilities(self.caster.RSkill, self.caster.ComboSkill, true, false)
    end
end