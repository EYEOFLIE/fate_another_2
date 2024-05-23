gilles_hysteria = class({})
gilles_hysteria_upgrade = class({})
modifier_gilles_hysteria = class({})

LinkLuaModifier("modifier_gilles_hysteria", "abilities/gilles/gilles_hysteria", LUA_MODIFIER_MOTION_NONE)

function hysteria_wrapper(abil)
	function abil:CastFilterResultTarget(hTarget)
		if hTarget:GetName() == "npc_dota_ward_base" or hTarget == self:GetCaster() or hTarget:HasModifier("modifier_gilles_hysteria") then 
			return UF_FAIL_CUSTOM 
		else
			local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
		
			return filter
		end
	end

	function abil:IsHiddenAbilityCastable()
		return true
	end

	function abil:GetCustomCastErrorTarget(hTarget)
		if hTarget:GetName() == "npc_dota_ward_base" then
			return "Cannot target wards"
		elseif hTarget == self:GetCaster() then
			return "Cannot target self"
		elseif hTarget:HasModifier("modifier_gilles_hysteria") then
			return "Already affected by Hysteria"
		else
			return "Invalid Target"
		end
	end

	--[[function gilles_hysteria:GetManaCost(iLevel)
		return (self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost") / 100)
	end]]

	function abil:OnSpellStart()
		local hCaster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
		
		hTarget:EmitSound("Hero_Nevermore.Shadowraze")

		hTarget:AddNewModifier(hCaster, self, "modifier_gilles_hysteria", { AttackSpeed = self:GetSpecialValueFor("attack_speed"),
																			Damage = self:GetSpecialValueFor("damage"),
																		 	Duration = self:GetSpecialValueFor("duration") })
	end
end

hysteria_wrapper(gilles_hysteria)
hysteria_wrapper(gilles_hysteria_upgrade)

function modifier_gilles_hysteria:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

if IsServer() then 
	function modifier_gilles_hysteria:OnCreated(args)
		self.Damage = args.Damage
		self.AttackSpeed = args.AttackSpeed
		self.hTarget = self:GetParent()

		CustomNetTables:SetTableValue("sync","gilles_hysteria_stat", { att_spd = self.AttackSpeed })

		if self.hTarget.Particle == nil then
			self.hTarget.Particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infested_unit.vpcf", PATTACH_OVERHEAD_FOLLOW, self.hTarget)
			ParticleManager:SetParticleControl(self.hTarget.Particle, 0, self.hTarget:GetAbsOrigin()) 
			ParticleManager:SetParticleControl(self.hTarget.Particle, 1, self.hTarget:GetAbsOrigin())
		end
	end

	function modifier_gilles_hysteria:OnRefresh(args)
		self.Damage = args.Damage
		self.AttackSpeed = args.AttackSpeed

		CustomNetTables:SetTableValue("sync","gilles_hysteria_stat", { att_spd = self.AttackSpeed })
	end

	function modifier_gilles_hysteria:OnDestroy()
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local fDamage = (self.hTarget:GetHealth() * self.Damage / 100)

		if not IsValidEntity(self.hTarget) or self.hTarget:IsNull() or not self.hTarget:IsAlive() then return end

		if not IsImmuneToCC(self.hTarget) then
			self.hTarget:AddNewModifier(hCaster, hAbility, "modifier_stunned", {Duration = hAbility:GetSpecialValueFor("stun_duration") })
		end
		
		DoDamage(hCaster, self.hTarget, fDamage, DAMAGE_TYPE_PURE, 0, hAbility, false)

		if hCaster.IsOuterGodAcquired then
			local bonus_int = hAbility:GetSpecialValueFor("bonus_int")
			local damage = bonus_int * hCaster:GetIntellect()
			if hCaster:GetTeam() ~= self.hTarget:GetTeam() then 
				DoDamage(hCaster, self.hTarget, damage, DAMAGE_TYPE_PURE, 0, hAbility, false)
			end
		end
			
		if self.hTarget.Particle ~= nil then
			ParticleManager:DestroyParticle(self.hTarget.Particle, true)
			ParticleManager:ReleaseParticleIndex(self.hTarget.Particle)
			self.hTarget.Particle = nil
		end	
	end
end

function modifier_gilles_hysteria:GetModifierAttackSpeedBonus_Constant()
	local att_spd = 0

	if IsServer() then
		att_spd = self.AttackSpeed
	else
		att_spd = CustomNetTables:GetTableValue("sync","gilles_hysteria_stat").att_spd
	end

	return att_spd
end

function modifier_gilles_hysteria:IsDebuff()
	return true
end

function modifier_gilles_hysteria:IsHidden() 
	return false 
end

function modifier_gilles_hysteria:GetTexture()
	return "custom/gilles/gilles_hysteria"
end