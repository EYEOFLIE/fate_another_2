gilles_cthulhu_favour = class({})
gilles_cthulhu_favour_upgrade = class({})
modifier_cthulhu_favour_thinker = class({})
modifier_cthulhu_favour_aura = class({})
modifier_cthulhu_favour_mr = class({})

LinkLuaModifier("modifier_cthulhu_favour_thinker", "abilities/gilles/gilles_cthulhu_favour", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cthulhu_favour_aura", "abilities/gilles/gilles_cthulhu_favour", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cthulhu_favour_mr", "abilities/gilles/gilles_cthulhu_favour", LUA_MODIFIER_MOTION_NONE)

--[[function gilles_cthulhu_favour:GetManaCost(iLevel)
	return (self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost") / 100)
end]]

function gilles_cthulhu_wrapper(ability)
	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:IsHiddenAbilityCastable()
		return true
	end

	function ability:OnSpellStart()
		local hCaster = self:GetCaster()
		local vTargetLocation = self:GetCursorPosition()
		local tModifierArgs = { AOE = self:GetAOERadius(),
				  				Duration = self:GetSpecialValueFor("duration") }
		
		EmitSoundOnLocationWithCaster(vTargetLocation, "Gilles_Cthulhu_Cast", hCaster)

		local particleIndex = ParticleManager:CreateParticle("particles/custom/gilles/cthulhu_favour_cast.vpcf", PATTACH_WORLDORIGIN, hCaster)
	 	ParticleManager:SetParticleControl(particleIndex, 0, vTargetLocation) 

		Timers:CreateTimer(1.0, function()
			local thinker = CreateModifierThinker(hCaster, self, "modifier_cthulhu_favour_thinker", tModifierArgs, vTargetLocation, hCaster:GetTeamNumber(), false)
			ParticleManager:DestroyParticle(particleIndex, false)
			ParticleManager:ReleaseParticleIndex(particleIndex)
			if hCaster.IsSunkenCityAcquired then 
				tModifierArgs.MR = self:GetSpecialValueFor("mr_red")
				CreateModifierThinker(hCaster, self, "modifier_cthulhu_favour_aura", tModifierArgs, vTargetLocation, hCaster:GetTeamNumber(), false)
			end
			return
		end)	
	end
end

gilles_cthulhu_wrapper(gilles_cthulhu_favour)
gilles_cthulhu_wrapper(gilles_cthulhu_favour_upgrade)

if IsServer() then 
	function modifier_cthulhu_favour_thinker:OnCreated(args)
		self.ParticleIndex = ParticleManager:CreateParticle("particles/custom/gilles/cthulhu_favour_circle.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	 	ParticleManager:SetParticleControl(self.ParticleIndex, 0, self:GetParent():GetAbsOrigin()) 
	 	ParticleManager:SetParticleControl(self.ParticleIndex, 1, Vector(args.AOE, args.AOE, args.AOE))
	 	ParticleManager:SetParticleControl(self.ParticleIndex, 2, Vector(args.AOE, 0, 0))
	 	ParticleManager:SetParticleControl(self.ParticleIndex, 16, Vector(args.AOE, 0, 0))

	 	if self:GetCaster().IsSunkenCityAcquired then
	 		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Gilles_Cthulhu_Root", self:GetCaster())
	 		self.HellIndex = ParticleManager:CreateParticle("particles/custom/gilles/cthulhu_hellborn.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	 		ParticleManager:SetParticleControl(self.HellIndex, 0, self:GetParent():GetAbsOrigin() + Vector(0,0,50)) 
	 		ParticleManager:SetParticleControl(self.HellIndex, 1, Vector(args.AOE, 0, 0))
	 		local tEnemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			local root = self:GetAbility():GetSpecialValueFor("root")
			for _,v in pairs(tEnemies) do

				if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() and not IsImmuneToCC(v) then
					giveUnitDataDrivenModifier(self:GetCaster(), v, "rooted", root)
					giveUnitDataDrivenModifier(self:GetCaster(), v, "locked", root)
				end
			end
	 	end

	 	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("spawn_interval"))
	end

	function modifier_cthulhu_favour_thinker:OnIntervalThink()
		local spawn_loc = RandomPointInCircle(self:GetParent():GetAbsOrigin(), self:GetAbility():GetAOERadius() - 75)
		local targets = FindUnitsInRadius(self:GetCaster():GetTeam(), spawn_loc, nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		
		for _,v in pairs(targets) do	

			if IsValidEntity(v) and not v:IsNull() and not IsImmuneToCC(v) then
				v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", { Duration = 0.01 })
			end
			DoDamage(self:GetCaster(), v, self:GetAbility():GetSpecialValueFor("spawn_damage"), DAMAGE_TYPE_PHYSICAL, 0, self:GetAbility(), false)
		end

		EmitSoundOnLocationWithCaster(spawn_loc, "Gilles_Cthulhu_Explode", self:GetCaster())

		local particleIndex = ParticleManager:CreateParticle("particles/custom/gilles/cthulhu_favour_splash.vpcf", PATTACH_WORLDORIGIN, nil)
	 	ParticleManager:SetParticleControl(particleIndex, 3, spawn_loc) 

		Timers:CreateTimer( 1.5, function()
			ParticleManager:DestroyParticle( particleIndex, true )
			ParticleManager:ReleaseParticleIndex( particleIndex )
			return nil
		end)

		local tentacle = CreateUnitByName("gilles_cthulhu_tentacle", spawn_loc, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		tentacle:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
		tentacle:SetOwner(self:GetCaster())
		tentacle:AddNewModifier(self:GetCaster(), nil, "modifier_kill", {duration = self:GetRemainingTime() })		
	end

	function modifier_cthulhu_favour_thinker:OnDestroy()
		local fAOE = self:GetAbility():GetAOERadius()
		local particleIndex = ParticleManager:CreateParticle("particles/custom/gilles/cthulhu_favour_splash.vpcf", PATTACH_WORLDORIGIN, nil)
	 	ParticleManager:SetParticleControl(particleIndex, 0, self:GetParent():GetAbsOrigin())
	 	ParticleManager:SetParticleControl(particleIndex, 1, Vector(fAOE * 0.2, 0, 0))
		ParticleManager:SetParticleControl(particleIndex, 2, Vector(fAOE * 0.4, 0, 0))
		ParticleManager:SetParticleControl(particleIndex, 3, Vector(fAOE * 0.6, 0, 0))
		ParticleManager:SetParticleControl(particleIndex, 4, Vector(fAOE * 0.8, 0, 0))
		ParticleManager:SetParticleControl(particleIndex, 5, Vector(fAOE, 0, 0)) 

		if self:GetCaster().IsSunkenCityAcquired then
	 		local tEnemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, fAOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		
			for _,v in pairs(tEnemies) do

				if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
					if not IsImmuneToCC(v) then
						v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", { Duration = self:GetAbility():GetSpecialValueFor("stun")})
					end
					DoDamage(self:GetCaster(), v, self:GetAbility():GetSpecialValueFor("stun_damage"), DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				end
			end
			ParticleManager:DestroyParticle(self.HellIndex, false)
			ParticleManager:ReleaseParticleIndex(self.HellIndex)
	 	end

		Timers:CreateTimer( 1.5, function()
			ParticleManager:DestroyParticle( particleIndex, true )
			ParticleManager:ReleaseParticleIndex( particleIndex )
			return nil
		end)

		ParticleManager:DestroyParticle(self.ParticleIndex, false)
		ParticleManager:ReleaseParticleIndex(self.ParticleIndex)
	end
end

-------------------------------------------------

function modifier_cthulhu_favour_aura:OnCreated(args)
	print('sunken is here')
end

function modifier_cthulhu_favour_aura:IsAura()
	return true 
end

function modifier_cthulhu_favour_aura:IsHidden()
	return true 
end

function modifier_cthulhu_favour_aura:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

function modifier_cthulhu_favour_aura:GetModifierAura()
	return "modifier_cthulhu_favour_mr"
end

function modifier_cthulhu_favour_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_cthulhu_favour_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

-----------------------------------------------

if IsServer() then
	function modifier_cthulhu_favour_mr:OnCreated(args)		
		self.MR_Reduction = self:GetAbility():GetSpecialValueFor("mr_red")
		--self.mr_stack = self:GetAbility():GetSpecialValueFor("mr_red")
		--CustomNetTables:SetTableValue("sync","cthulhu_mr", { magic_resist = self.MR_Reduction})	
		self.MS_Reduction = self:GetAbility():GetSpecialValueFor("ms_red")
		--self.ms_stack = self:GetAbility():GetSpecialValueFor("ms_red")
		--CustomNetTables:SetTableValue("sync","cthulhu_ms", { move_speed = self.MS_Reduction})	
		print(self.MR_Reduction)
		self:SetStackCount(1)
		self:StartIntervalThink(1)	
	end
end

function modifier_cthulhu_favour_mr:GetTexture()
	return "custom/gilles/gilles_sunken_city"
end

function modifier_cthulhu_favour_mr:OnIntervalThink()
	self:IncrementStackCount()
	--print('think + 1')
	--if IsServer() then
	--	self.MR_Reduction = self.MR_Reduction + self.mr_stack
	--	CustomNetTables:SetTableValue("sync","cthulhu_mr", { magic_resist = self.MR_Reduction})	
	--	self.MS_Reduction = self.MS_Reduction + self.ms_stack
	----	CustomNetTables:SetTableValue("sync","cthulhu_ms", { move_speed = self.MS_Reduction})	
	--end
end

function modifier_cthulhu_favour_mr:IsHidden()
	return false 
end

function modifier_cthulhu_favour_mr:IsDebuff()
	return true 
end

function modifier_cthulhu_favour_mr:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			 MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			 }
end

function modifier_cthulhu_favour_mr:GetModifierMagicalResistanceBonus()
	--if IsServer() then
		return self:GetAbility():GetSpecialValueFor("mr_red") * self:GetStackCount() --self.MR_Reduction
	--elseif IsClient() then
	--	local magic_resist = CustomNetTables:GetTableValue("sync","cthulhu_mr").magic_resist
   --     return magic_resist 
	--end
end

function modifier_cthulhu_favour_mr:GetModifierMoveSpeedBonus_Percentage()
	--if IsServer() then
		return self:GetAbility():GetSpecialValueFor("ms_red") * self:GetStackCount() --self.MS_Reduction
	--elseif IsClient() then
	--	local move_speed = CustomNetTables:GetTableValue("sync","cthulhu_ms").move_speed
    --    return move_speed 
	--end
end