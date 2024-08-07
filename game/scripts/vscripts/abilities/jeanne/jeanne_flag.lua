
jeanne_luminosite_eternelle = class({})
jeanne_luminosite_eternelle_upgrade_1 = class({})
jeanne_luminosite_eternelle_upgrade_2 = class({})
jeanne_luminosite_eternelle_upgrade_3 = class({})
modifier_jeanne_luminosite_channel = class({})
modifier_jeanne_luminosite_flag = class({})
modifier_jeanne_luminosite_buff = class({})
modifier_jeanne_luminosite_flag_buff = class({})
modifier_jeanne_sacrifice_cooldown = class({})

LinkLuaModifier("modifier_jeanne_luminosite_channel", "abilities/jeanne/jeanne_flag", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_luminosite_flag", "abilities/jeanne/jeanne_flag", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_luminosite_buff", "abilities/jeanne/jeanne_flag", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_luminosite_flag_buff", "abilities/jeanne/jeanne_flag", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_sacrifice_cooldown", "abilities/jeanne/jeanne_flag", LUA_MODIFIER_MOTION_NONE)

function jeanne_flag_wrapper(abil)
	function abil:GetAbilityTextureName()
		if self:GetCaster():HasModifier("modifier_jeanne_saint") then 
			return "custom/jeanne/jeanne_luminosite_eternelle_saint"
		else
			return "custom/jeanne/jeanne_luminosite_eternelle"
		end
	end

	function abil:GetManaCost(iLevel)
		return 800
	end

	function abil:GetChannelTime()
		return self:GetSpecialValueFor("channel_time")
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		self.chargetick = 0
		self.heal = self:GetSpecialValueFor("saint_heal_per_sec")
		self.base_radius = self:GetSpecialValueFor("base_radius")
		self.bonus_radius = self:GetSpecialValueFor("bonus_radius_per_sec")
		self.base_dr = self:GetSpecialValueFor("base_dr")
		self.bonus_dr_per_sec = self:GetSpecialValueFor("bonus_dr_per_sec")
		self.base_duration = self:GetSpecialValueFor("base_duration")
		self.heal_per_sec = self:GetSpecialValueFor("heal_per_sec")
		self.bonus_duration = self:GetSpecialValueFor("bonus_duration_per_sec")
		self.bonus_heal_per_sec = 0
		if self.caster.IsRevelationAcquired then 
			self.transfer_heal = self:GetSpecialValueFor("transfer_heal") / 100 * self.caster:GetMaxHealth()
			self.transfer_threshold = self:GetSpecialValueFor("transfer_threshold")
		end
		self.radius = self.base_radius
		self.dr_buff = self.base_radius
		self.trigger = false
		self.heal_tick = 0

		EmitGlobalSound("Hero_Chen.HandOfGodHealHero")
		EmitGlobalSound("Ruler.Luminosite")

		self:DestroyFlag()

		self:CreateZoneFx()
		
		self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_luminosite_channel", {Duration = self:GetSpecialValueFor("channel_time")})
		if self.caster:HasModifier("modifier_jeanne_saint") then 
			self:SaintHeal(self.heal, true, 0)
			--self.heal_tick = self.heal_tick + 1
		end
		if self.caster.IsDivineSymbolAcquired then 
			self.bonus_heal_per_sec = self:GetSpecialValueFor("bonus_heal_per_sec") * self.caster:GetIntellect()
		end
		--self:SaintHeal(self.heal_per_sec + self.bonus_heal_per_sec, false, 0)
	end

	function abil:OnChannelThink(flInterval)
		if not self.caster:HasModifier("modifier_jeanne_luminosite_channel") or not self.caster:IsAlive() then return nil end

		self.chargetick = self.chargetick + flInterval

		--print('charge time: ' .. self.chargetick)
		
		self.radius = math.floor(self.base_radius + (self.bonus_radius * self.chargetick))
		self.dr_buff = math.floor(self.base_dr + (self.bonus_dr_per_sec * self.chargetick))
		--print(self.dr_buff)

		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 1, Vector(1,1,self.radius))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 14, Vector(self.radius,self.radius,0))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 4, Vector(-self.radius * .9,0,0) + self.caster:GetAbsOrigin()) -- Cross arm lengths
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 5, Vector(self.radius * .9,0,0) + self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 6, Vector(0,-self.radius * .9,0) + self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 7, Vector(0,self.radius * .9,0) + self.caster:GetAbsOrigin())
		if self.chargetick == self.heal_tick then
			self.heal_tick = self.heal_tick + 1
			if self.caster:HasModifier("modifier_jeanne_saint") then 
				self:SaintHeal(self.heal, true, 0)
			end
			if self.caster.IsDivineSymbolAcquired then 
				self.bonus_heal_per_sec = self:GetSpecialValueFor("bonus_heal_per_sec") * self.caster:GetIntellect()
			end
			self:SaintHeal(self.heal_per_sec + self.bonus_heal_per_sec, false, 0)
		end
	end

	function abil:OnChannelFinish(bInterrupted)

		self.caster:RemoveModifierByName("modifier_jeanne_luminosite_channel")
		if self.caster:IsAlive() then
			EmitGlobalSound("Ruler.Eternelle")
			self.caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
			local percent_charge = self.chargetick/self:GetSpecialValueFor("channel_time") * 100
			local total_duration = self.base_duration + (self.bonus_duration * self.chargetick)
			if bInterrupted == false then 
				local success_heal = self:GetSpecialValueFor("success_heal")
				if self.caster.IsDivineSymbolAcquired then 
					local bonus_heal = self:GetSpecialValueFor("bonus_heal") * self.caster:GetIntellect()
					local cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction")
					success_heal = success_heal + bonus_heal
				end
				self:SaintHeal(success_heal, false, total_duration)
			end
			self:CreateFlag(self.caster:GetAbsOrigin(), total_duration, self.radius, self.dr_buff)
			self.trigger = true
		else
			self:RemoveZoneFx()
		end
	end

	function abil:SaintHeal(fHeal, bSaint, fDuration)
		local particle = "particles/ishtar/ishtar_heal.vpcf"
		if bSaint == false then 
			particle = "particles/custom/ruler/jeanne_heal.vpcf"
		end
		local ally = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs (ally) do
			v:FateHeal(fHeal, self.caster, true)
			local heal_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, v)
			ParticleManager:SetParticleControl(heal_fx, 0, v:GetAbsOrigin() + Vector(0,0,50))

			Timers:CreateTimer(0.8, function()
				ParticleManager:DestroyParticle(heal_fx, true)
				ParticleManager:ReleaseParticleIndex(heal_fx)
			end)

			if fDuration > 0 then
				if self.caster.IsDivineSymbolAcquired then 
					self:ReduceCooldown(v, self:GetSpecialValueFor("cooldown_reduction"))
				end
				if self.caster.IsRevelationAcquired then 
					self.caster:FindAbilityByName(self.caster.QSkill):ApplyCharisma(v, fDuration)
					HardCleanse(v)
					local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, v )
				    ParticleManager:SetParticleControl( dispel, 1, v:GetAbsOrigin() + Vector(0,0,30))

				    Timers:CreateTimer( 2.0, function()
				        ParticleManager:DestroyParticle( dispel, true )
				        ParticleManager:ReleaseParticleIndex( dispel )
				    end)
				end
			else
				if self.caster.IsRevelationAcquired then 
					self.caster:FindAbilityByName(self.caster.QSkill):ApplyCharisma(v, 1)
					--[[HardCleanse(v)
					local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, v )
				    ParticleManager:SetParticleControl( dispel, 1, v:GetAbsOrigin() + Vector(0,0,30))

				    Timers:CreateTimer( 1.0, function()
				        ParticleManager:DestroyParticle( dispel, true )
				        ParticleManager:ReleaseParticleIndex( dispel )
				    end)]]
				end
			end
		end
	end

	function abil:CreateZoneFx()
		self.caster.LuminositeZoneFx = ParticleManager:CreateParticle("particles/custom/ruler/luminosite_eternelle/sacred_zone.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 1, Vector(1,1,self.base_radius))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 12, Vector(255,200,130)) --color
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 14, Vector(self.base_radius,self.base_radius,0))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 4, Vector(-self.base_radius * .9,0,0) + self.caster:GetAbsOrigin()) -- Cross arm lengths
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 5, Vector(self.base_radius * .9,0,0) + self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 6, Vector(0,-self.base_radius * .9,0) + self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 7, Vector(0,self.base_radius * .9,0) + self.caster:GetAbsOrigin())
	end

	function abil:RemoveZoneFx()
		if self.caster.LuminositeZoneFx ~= nil then
			ParticleManager:DestroyParticle(self.caster.LuminositeZoneFx, true)
			ParticleManager:ReleaseParticleIndex(self.caster.LuminositeZoneFx)
		end
	end

	function abil:IsFlagExist()
		if self.caster.CurrentFlag ~= nil and not self.caster.CurrentFlag:IsNull() and IsValidEntity(self.caster.CurrentFlag) then
			return true 
		end
		return false 
	end

	function abil:ReduceCooldown(hTarget, fCDReduction)
		for i=0, 5 do 
			local abilities = hTarget:GetAbilityByIndex(i)
			if abilities ~= nil then
				if abilities.IsResetable ~= false then
					if not abilities:IsCooldownReady() then 
						local remain_cd = abilities:GetCooldownTimeRemaining()
						abilities:EndCooldown()
						if remain_cd > fCDReduction then
							abilities:StartCooldown( remain_cd - fCDReduction)
						end
					end
				end
			else 
				break
			end
		end
	end

	function abil:CreateFlag(vLoc, fDur, iRadius, iDR)
		local flag = CreateUnitByName("jeanne_flag", vLoc, true, self.caster, self.caster, self.caster:GetTeamNumber())
		flag:AddNewModifier(self.caster, nil, "modifier_kill", {duration = fDur})
		flag:SetAngles(0, -90, 0)
		--FindClearSpaceForUnit(flag, flag:GetAbsOrigin(), true)

		self.caster.CurrentFlag = flag
		flag:AddNewModifier(self.caster, self, "modifier_jeanne_luminosite_flag", {Duration = fDur, Radius = iRadius, DamageReduction = iDR})

		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 0, vLoc)
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 1, Vector(1,1,iRadius))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 14, Vector(iRadius,iRadius,0))
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 4, Vector(-iRadius * .9,0,0) + vLoc) -- Cross arm lengths
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 5, Vector(iRadius * .9,0,0) + vLoc)
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 6, Vector(0,-iRadius * .9,0) + vLoc)
		ParticleManager:SetParticleControl(self.caster.LuminositeZoneFx, 7, Vector(0,iRadius * .9,0) + vLoc)
	end

	function abil:DestroyFlag()
		if self:IsFlagExist() then
			self.caster.CurrentFlag:RemoveSelf()
		end
		self:RemoveZoneFx()
	end

	function abil:GetCurrentRadius()
		return self.radius 
	end

	function abil:GetDamageReduction()
		local dr = self.dr_buff
		print('damage reduction: ' .. dr)
		return dr
	end
end

jeanne_flag_wrapper(jeanne_luminosite_eternelle)
jeanne_flag_wrapper(jeanne_luminosite_eternelle_upgrade_1)
jeanne_flag_wrapper(jeanne_luminosite_eternelle_upgrade_2)
jeanne_flag_wrapper(jeanne_luminosite_eternelle_upgrade_3)

-----------------

function modifier_jeanne_luminosite_channel:IsHidden() return false end
function modifier_jeanne_luminosite_channel:IsDebuff() return false end
function modifier_jeanne_luminosite_channel:IsPurgable() return false end
function modifier_jeanne_luminosite_channel:RemoveOnDeath() return true end
function modifier_jeanne_luminosite_channel:IsAura() return true end
function modifier_jeanne_luminosite_channel:IsAuraActiveOnDeath() return false end
function modifier_jeanne_luminosite_channel:GetAuraRadius()
	local radius = self:GetAbility():GetCurrentRadius()
	--local radius = self.base_radius + (self.bonus_radius * (self:GetAbility():GetSpecialValueFor("channel_time") - self:GetRemainingTime()))
	return radius
end
function modifier_jeanne_luminosite_channel:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_jeanne_luminosite_channel:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end
function modifier_jeanne_luminosite_channel:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_jeanne_luminosite_channel:GetModifierAura()
	return "modifier_jeanne_luminosite_flag_buff"
end
function modifier_jeanne_luminosite_channel:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_luminosite_channel:GetTexture()
	return "custom/jeanne/jeanne_luminosite_eternelle"
end

function modifier_jeanne_luminosite_channel:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end

function modifier_jeanne_luminosite_channel:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function modifier_jeanne_luminosite_channel:GetOverrideAnimationRate()
	return 1.0
end

if IsServer() then
	function modifier_jeanne_luminosite_channel:OnCreated(args)
		self.caster = self:GetParent()
		self.base_radius = self:GetAbility():GetSpecialValueFor("base_radius")
		self.bonus_radius = self:GetAbility():GetSpecialValueFor("bonus_radius_per_sec")
		self.DamageReduction = self:GetAbility():GetDamageReduction()
		CustomNetTables:SetTableValue("sync","luminosite_eternelle", {damage_reduction = self.DamageReduction})
		self:StartIntervalThink(0.33)
	end

	function modifier_jeanne_luminosite_channel:OnIntervalThink()
		self.DamageReduction = self:GetAbility():GetDamageReduction()
		CustomNetTables:SetTableValue("sync","luminosite_eternelle", {damage_reduction = self.DamageReduction})
	end

	function modifier_jeanne_luminosite_channel:OnDestroy()

	end
end

--------------------

function modifier_jeanne_luminosite_flag:IsHidden() return false end
function modifier_jeanne_luminosite_flag:IsDebuff() return false end
function modifier_jeanne_luminosite_flag:IsPurgable() return false end
function modifier_jeanne_luminosite_flag:RemoveOnDeath() return true end
function modifier_jeanne_luminosite_flag:IsAura() return true end
function modifier_jeanne_luminosite_flag:IsAuraActiveOnDeath() return false end
function modifier_jeanne_luminosite_flag:GetAuraRadius()
	return self.radius
end
function modifier_jeanne_luminosite_flag:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_jeanne_luminosite_flag:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end
function modifier_jeanne_luminosite_flag:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_jeanne_luminosite_flag:GetModifierAura()
	return "modifier_jeanne_luminosite_buff"
end
function modifier_jeanne_luminosite_flag:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_jeanne_luminosite_flag:CheckState()
    local state = { [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                }
    return state
end

if IsServer() then
	function modifier_jeanne_luminosite_flag:OnCreated(args)
		self.caster = self:GetCaster()
		self.flag = self:GetParent()
		self.radius = args.Radius	
		self.dr = args.DamageReduction
		self:SetStackCount(self.dr)
		self:StartIntervalThink(0.33)
	end

	function modifier_jeanne_luminosite_flag:OnIntervalThink()

		if not self.caster:IsAlive() or (self.caster:GetAbsOrigin() - self.flag:GetAbsOrigin()):Length2D() > self.radius then 
			self:GetAbility():DestroyFlag()
		end
	end

	function modifier_jeanne_luminosite_flag:OnDestroy()
		self:GetAbility():RemoveZoneFx()
	end
end

-------------------------------------------

function modifier_jeanne_luminosite_buff:IsHidden() return false end
function modifier_jeanne_luminosite_buff:IsDebuff() return false end
function modifier_jeanne_luminosite_buff:IsPurgable() return false end
function modifier_jeanne_luminosite_buff:RemoveOnDeath() return true end
function modifier_jeanne_luminosite_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_luminosite_buff:GetTexture()
	return "custom/jeanne/jeanne_luminosite_eternelle"
end

function modifier_jeanne_luminosite_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_jeanne_luminosite_buff:GetEffectName()
	return "particles/econ/events/ti5/radiant_fountain_regen_lvl2_ti5.vpcf"
end

function modifier_jeanne_luminosite_buff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_jeanne_luminosite_buff:GetModifierIncomingDamage_Percentage()
	if IsServer() then
		local dr = self:GetAbility():GetDamageReduction()
		return -dr
	elseif IsClient() then
        local dr = CustomNetTables:GetTableValue("sync","luminosite_eternelle").damage_reduction or 0
        return -dr 
    end	
end

-------------------------------------------

function modifier_jeanne_luminosite_flag_buff:IsHidden() return true end
function modifier_jeanne_luminosite_flag_buff:IsDebuff() return false end
function modifier_jeanne_luminosite_flag_buff:IsPurgable() return false end
function modifier_jeanne_luminosite_flag_buff:RemoveOnDeath() return true end
function modifier_jeanne_luminosite_flag_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_jeanne_luminosite_flag_buff:GetTexture()
	return "custom/jeanne/jeanne_luminosite_eternelle"
end

function modifier_jeanne_luminosite_flag_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_jeanne_luminosite_flag_buff:OnTakeDamage(args)
	if self:GetCaster():HasModifier("modifier_jeanne_sacrifice_cooldown") then return end

	if args.unit ~= self:GetParent() or args.unit == self:GetCaster() then return end

	if self:GetAbility().trigger == true or not self:GetCaster().IsRevelationAcquired then return end 

	self.ally = self:GetParent()
	self.caster = self:GetCaster()

	if self.ally:GetHealthPercent() <= self:GetAbility().transfer_threshold then
		--self.caster:AddNewModifier(self.caster, self, "modifier_jeanne_sacrifice_cooldown", {Duration = self:GetAbility():GetSpecialValueFor("channel_time")})
		self.ally:FateHeal(self:GetAbility().transfer_heal, self.caster, true)
		self:GetAbility().trigger = true 
		DoDamage(self.caster, self.caster, self:GetAbility().transfer_heal, DAMAGE_TYPE_HP_REMOVAL, DOTA_DAMAGE_FLAG_NON_LETHAL, self:GetAbility(), false)	
		local sacrifice_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_give.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
		ParticleManager:SetParticleControlEnt(sacrifice_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(sacrifice_fx, 1, self.ally, PATTACH_POINT_FOLLOW, "attach_hitloc", self.ally:GetAbsOrigin(), true)
		
		Timers:CreateTimer(1.0, function()
			ParticleManager:DestroyParticle(sacrifice_fx, false)
			ParticleManager:ReleaseParticleIndex(sacrifice_fx)
		end)
	end
end

-----------------------------------

function modifier_jeanne_sacrifice_cooldown:IsHidden() return false end
function modifier_jeanne_sacrifice_cooldown:IsDebuff() return true end
function modifier_jeanne_sacrifice_cooldown:IsPurgable() return false end
function modifier_jeanne_sacrifice_cooldown:RemoveOnDeath() return true end
function modifier_jeanne_sacrifice_cooldown:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_jeanne_sacrifice_cooldown:GetTexture()
    return "custom/jeanne/jeanne_revelation"
end
