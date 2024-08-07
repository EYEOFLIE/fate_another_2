
jeanne_purge_the_unjust = class({})
jeanne_purge_the_unjust_upgrade_1 = class({})
jeanne_purge_the_unjust_upgrade_2 = class({})
jeanne_purge_the_unjust_upgrade_3 = class({})
modifier_jeanne_purge_slow = class({}) 
modifier_jeanne_combo_window = class({})

LinkLuaModifier("modifier_jeanne_purge_slow", "abilities/jeanne/jeanne_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_combo_window", "abilities/jeanne/jeanne_purge", LUA_MODIFIER_MOTION_NONE)

function jeanne_purge_wrapper(abil)
	function abil:GetAbilityTextureName()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return "custom/jeanne/jeanne_purge_saint"
		else
			return "custom/jeanne/jeanne_purge"
		end
	end

	function abil:GetBehavior()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
		else
			if self:GetLevel() == 5 then 
				return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
			else
				return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
			end
		end
	end

	function abil:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function abil:OnUpgrade()
		self:GetCaster().WLevel = self:GetLevel()
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		self.target_loc = self:GetCursorPosition()
		self.radius = self:GetSpecialValueFor("radius")
		self.delay = self:GetSpecialValueFor("delay")
		self.damage = self:GetSpecialValueFor("damage")
		self.silence = self:GetSpecialValueFor("silence_duration")
		self.slow_dur = self:GetSpecialValueFor("slow_duration")

		local markFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_marker.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
		ParticleManager:SetParticleControl( markFx, 0, self.target_loc)
		EmitSoundOnLocationWithCaster(self.target_loc, "Hero_Chen.PenitenceImpact", self.caster)	

		if self.caster:HasModifier('modifier_alternate_02') then 
			self.caster:EmitSound("Jeanne-W")
		else
			self.caster:EmitSound("Jeanne_Skill_" .. math.random(1,6))
		end

		Timers:CreateTimer(self.delay, function()

			local targets = FindUnitsInRadius(self.caster:GetTeam(), self.target_loc, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do	
				if IsValidEntity(v) and not v:IsNull() then
					if not v:IsMagicImmune() then	
					    giveUnitDataDrivenModifier(self.caster, v, "silenced", self.silence)
					    giveUnitDataDrivenModifier(self.caster, v, "disarmed", self.silence)
					end

					DoDamage(self.caster, v, self.damage, DAMAGE_TYPE_MAGICAL, 0, self, false)	

					if self.caster.IsPunishmentAcquired then 
						ApplyPurge(v)		
						v:AddNewModifier(self.caster, self, "modifier_jeanne_purge_slow", {Duration = self.slow_dur})
					end	    	
			    end
		    end

		    if self.caster.IsRevelationAcquired then 
		    	self.heal = self:GetSpecialValueFor("heal")
		    	local allies = FindUnitsInRadius(self.caster:GetTeam(), self.target_loc, nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(allies) do	
					v:FateHeal(self.heal, self.caster, true)
					local heal_fx = ParticleManager:CreateParticle("particles/custom/ruler/jeanne_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControl(heal_fx, 0, v:GetAbsOrigin())

					Timers:CreateTimer(0.5, function()
						ParticleManager:DestroyParticle(heal_fx, false)
						ParticleManager:ReleaseParticleIndex(heal_fx)
					end)
				end
			end

		    EmitSoundOnLocationWithCaster(self.target_loc, "Hero_Chen.TestOfFaith.Target", self.caster)		
			local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( purgeFx, 0, self.target_loc)
			ParticleManager:SetParticleControl( purgeFx, 1, self.target_loc)
			ParticleManager:SetParticleControl( purgeFx, 2, self.target_loc)
		end)

		--check combo
        if math.ceil(self.caster:GetStrength()) >= 25 and math.ceil(self.caster:GetAgility()) >= 25 and math.ceil(self.caster:GetIntellect()) >= 25 and self.caster:HasModifier("modifier_jeanne_q_use") then       
            if self.caster:FindAbilityByName(self.caster.ESkill):IsCooldownReady() and not self.caster:HasModifier("modifier_la_pucelle_cooldown") then
                if string.match(GetMapName(), "fate_elim") then 
					if GameRules:GetGameTime() <= 60 + _G.RoundStartTime or GameRules:GetGameTime() > 115 + _G.RoundStartTime then
						return 
					end
				end
                local remain_time = self.caster:FindModifierByName("modifier_jeanne_q_use"):GetRemainingTime()
                self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_combo_window", {Duration = remain_time})
            end
        end
	end
end

jeanne_purge_wrapper(jeanne_purge_the_unjust)
jeanne_purge_wrapper(jeanne_purge_the_unjust_upgrade_1)
jeanne_purge_wrapper(jeanne_purge_the_unjust_upgrade_2)
jeanne_purge_wrapper(jeanne_purge_the_unjust_upgrade_3)

--------------------

function modifier_jeanne_purge_slow:IsHidden() return false end
function modifier_jeanne_purge_slow:IsDebuff() return true end
function modifier_jeanne_purge_slow:IsPurgable() return true end
function modifier_jeanne_purge_slow:RemoveOnDeath() return true end
function modifier_jeanne_purge_slow:GetAttributes()
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_jeanne_purge_slow:GetTexture()
	return "custom/jeanne/jeanne_purge"
end

function modifier_jeanne_purge_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_jeanne_purge_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end

---------------------

function modifier_jeanne_combo_window:IsHidden() return true end
function modifier_jeanne_combo_window:IsDebuff() return false end
function modifier_jeanne_combo_window:IsPurgable() return false end
function modifier_jeanne_combo_window:RemoveOnDeath() return true end
function modifier_jeanne_combo_window:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then 
    function modifier_jeanne_combo_window:OnCreated(args)
        self.caster = self:GetParent()
        self.caster:SwapAbilities(self.caster.ESkill, self.caster.ComboSkill, false, true)
    end

    function modifier_jeanne_combo_window:OnDestroy()
        self.caster:SwapAbilities(self.caster.ESkill, self.caster.ComboSkill, true, false)
    end
end