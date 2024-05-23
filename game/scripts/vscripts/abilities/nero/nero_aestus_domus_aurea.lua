nero_aestus_domus_aurea = class({})
nero_aestus_domus_aurea_upgrade = class({}) 

LinkLuaModifier("modifier_aestus_domus_aurea_enemy", "abilities/nero/modifiers/modifier_aestus_domus_aurea_enemy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aestus_domus_aurea_ally", "abilities/nero/modifiers/modifier_aestus_domus_aurea_ally", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aestus_domus_aurea_nero", "abilities/nero/modifiers/modifier_aestus_domus_aurea_nero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_laus_saint_ready_checker", "abilities/nero/modifiers/modifier_laus_saint_ready_checker", LUA_MODIFIER_MOTION_NONE)

function aestus_domus_wrapper(ability)
	function ability:GetAOERadius()
		local radius = self:GetSpecialValueFor("radius")
		local caster = self:GetCaster()

		return radius
	end

	function ability:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		self.soundQueue = math.random(1,5)

		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	    if #enemies == 0 then 
		    if caster:HasModifier('modifier_alternate_02') then 
	        	caster:EmitSound("Nero-Empe-R")
			elseif caster:HasModifier('modifier_alternate_03') then 
	        	caster:EmitSound("Nero-Dress-R")
			else
	        	caster:EmitSound("nero_aestus_cast_" .. self.soundQueue)
			end
	    else		    
	    	if caster:HasModifier('modifier_alternate_02') then 
	        	EmitGlobalSound("Nero-Empe-R")
			elseif caster:HasModifier('modifier_alternate_03') then 
	        	EmitGlobalSound("Nero-Dress-R")
			else
	        	EmitGlobalSound("nero_aestus_cast_" .. self.soundQueue)
			end
	    end

		return true
	end

	function ability:OnAbilityPhaseInterrupted()
		local caster = self:GetCaster()
		caster:StopSound("Nero-Empe-R")
		StopGlobalSound("Nero-Empe-R")
		StopGlobalSound("Nero-Dress-R")
		caster:StopSound("nero_aestus_cast_" .. self.soundQueue)
		StopGlobalSound("nero_aestus_cast_" .. self.soundQueue)
	end

	function ability:CastFilterResult()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end

	function ability:GetCustomCastError()
		return "#Aestus_Domus_is_Active"
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local delay = self:GetSpecialValueFor("form_delay")
		local ability = self	
		local radius = self:GetSpecialValueFor("radius")

		--giveUnitDataDrivenModifier(caster, caster, "locked", delay)
		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", delay)

		Timers:CreateTimer(delay, function()
			if caster:IsAlive() then					
				self:ReduceCooldown()
				caster:EmitSound("Hero_LegionCommander.Duel.Victory")
				caster.CircleDummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				caster.CircleDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				caster.CircleDummy:SetDayTimeVisionRange(radius)
				caster.CircleDummy:SetNightTimeVisionRange(radius)

				caster.CircleDummy:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), nil))
				
				ability.FxDestroyed = false	

				ability.TheatreRingFx = ParticleManager:CreateParticle("particles/custom/nero/nero_domus_ring_border.vpcf", PATTACH_WORLDORIGIN, caster.CircleDummy)
				ParticleManager:SetParticleControl(ability.TheatreRingFx, 0, caster.CircleDummy:GetAbsOrigin())	
				ParticleManager:SetParticleControl(ability.TheatreRingFx, 1, Vector(radius + 100,0,0))	

				--ability:CreateBannerInCircle(caster, caster:GetAbsOrigin(), radius)
				ability.ColosseumParticle = ParticleManager:CreateParticle("particles/custom/nero/nero_new_ring.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
				ParticleManager:SetParticleControl(ability.ColosseumParticle, 1, Vector(self:GetAOERadius() + 100, 0, 0))
				ParticleManager:SetParticleControl(ability.ColosseumParticle, 2, caster.CircleDummy:GetAbsOrigin())

				local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for i = 1, #enemies do
					if enemies[i]:IsAlive() then
						enemies[i]:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_enemy", { ResistReduc = ability:GetSpecialValueFor("resist_reduc"),
																										  ArmorReduc = ability:GetSpecialValueFor("armor_reduc"),
																										  MovespeedReduc = ability:GetSpecialValueFor("movespeed_reduc"),
																										  TheatreCenterX = caster:GetAbsOrigin().x,
																										  TheatreCenterY = caster:GetAbsOrigin().y,
																										  TheatreCenterZ = caster:GetAbsOrigin().z,
																										  TheatreSize = radius,
																										  Duration = ability:GetSpecialValueFor("duration")})
					end
				end

				for i = 1, #allies do
					if allies[i]:IsAlive() and allies[i] ~= caster then
						print(allies[i]:GetName())
						allies[i]:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_ally", { TheatreCenterX = caster:GetAbsOrigin().x,
																										TheatreCenterY = caster:GetAbsOrigin().y,
																										TheatreCenterZ = caster:GetAbsOrigin().z,
																										TheatreSize = radius,
																										Duration = ability:GetSpecialValueFor("duration")})
					end
				end
				local nero_buff = {
					Resist = 0,
					Armor = 0,
					Movespeed = 0,
					TheatreCenterX = caster:GetAbsOrigin().x,
					TheatreCenterY = caster:GetAbsOrigin().y,
					TheatreCenterZ = caster:GetAbsOrigin().z,
					TheatreSize = radius,
					Duration = ability:GetSpecialValueFor("duration")
				}

				if caster.IsSoverignsGloryAcquired then 
					nero_buff.Resist = ability:GetSpecialValueFor("bonus_mr")
					nero_buff.Armor = ability:GetSpecialValueFor("bonus_armor")
					nero_buff.Movespeed = ability:GetSpecialValueFor("bonus_ms")
				end

				caster:AddNewModifier(caster, ability, "modifier_aestus_domus_aurea_nero", nero_buff)

				ability:CheckCombo()

			else 
				return
			end
		end)

		Timers:CreateTimer(delay + 0.5, function()
			if caster:IsAlive() then
				if caster:HasModifier('modifier_alternate_03') then 
				else
				EmitGlobalSound("Nero.NP2.1")
				end
			end
		end)	
	end

	function ability:ReduceCooldown()
		local caster = self:GetCaster()
		local tres_fontaine = caster:FindAbilityByName("nero_tres_fontaine_ardent")
		if tres_fontaine == nil then 
			tres_fontaine = caster:FindAbilityByName("nero_tres_fontaine_ardent_upgrade")
		end
		local gladiusanus = caster:FindAbilityByName("nero_gladiusanus_blauserum")
		if gladiusanus == nil then 
			gladiusanus = caster:FindAbilityByName("nero_gladiusanus_blauserum_upgrade")
		end
		local rosa = caster:FindAbilityByName("nero_rosa_ichthys")
		if rosa == nil then 
			if caster.IsSoverignsGloryAcquired and caster.IsAestusEstusAcquired then
				rosa = caster:FindAbilityByName("nero_rosa_ichthys_upgrade_3")
			elseif not caster.IsSoverignsGloryAcquired and caster.IsAestusEstusAcquired then
				rosa = caster:FindAbilityByName("nero_rosa_ichthys_upgrade_2")
			elseif caster.IsSoverignsGloryAcquired and not caster.IsAestusEstusAcquired then
				rosa = caster:FindAbilityByName("nero_rosa_ichthys_upgrade_1")
			end
		end
		if tres_fontaine:GetCooldownTimeRemaining() > 1 then
			tres_fontaine:EndCooldown()
			tres_fontaine:StartCooldown(1)
		end

		if gladiusanus:GetCooldownTimeRemaining() > 1 then
			gladiusanus:EndCooldown()
			gladiusanus:StartCooldown(1)
		end

		if rosa:GetCooldownTimeRemaining() > 1 then
			rosa:EndCooldown()
			rosa:StartCooldown(1)
		end
	end

	function ability:OnOwnerDied()	
		if self.TheatreRingFx and not self.FxDestroyed then
			self:DestroyFx()
		end

		local caster = self:GetCaster()
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3500, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for i = 1, #units do
			if units[i]:HasModifier("modifier_aestus_domus_aurea_enemy") or units[i]:HasModifier("modifier_aestus_domus_aurea_ally") then
				units[i]:RemoveModifierByName("modifier_aestus_domus_aurea_enemy")
				units[i]:RemoveModifierByName("modifier_aestus_domus_aurea_ally")
			end
		end
	end

	function ability:DestroyFx()
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(self.TheatreRingFx, false)
		ParticleManager:ReleaseParticleIndex(self.TheatreRingFx)
		ParticleManager:DestroyParticle(self.ColosseumParticle, false)
		ParticleManager:ReleaseParticleIndex(self.ColosseumParticle)
		--FxDestroyer(caster.TheatreRingFx, false)

		if IsValidEntity(caster.CircleDummy) then
			caster.CircleDummy:RemoveSelf()
		end

		self.FxDestroyed = true
	end

	function ability:CreateBannerInCircle(handle, center, multiplier)
		local vCenterLoc = Vector(center.x, center.y, 0)
		vCenterLoc = GetGroundPosition(vCenterLoc, nil)
		self.ColosseumParticle = ParticleManager:CreateParticle("particles/custom/nero/colosseum_ring.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(self.ColosseumParticle, 1, Vector(self:GetAOERadius() + 100, 0, 0))
		ParticleManager:SetParticleControl(self.ColosseumParticle, 2, vCenterLoc)
	end

	function ability:CheckCombo()
		local caster = self:GetCaster()
		local ability = self

		if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
	    	if caster:FindAbilityByName("nero_laus_saint_claudius"):IsCooldownReady() and not caster:HasModifier("modifier_laus_saint_claudius_cooldown") then
	    		caster:AddNewModifier(caster, ability, "modifier_laus_saint_ready_checker", { Duration = 6})
	    	end
	    end
	end
end

aestus_domus_wrapper(nero_aestus_domus_aurea)
aestus_domus_wrapper(nero_aestus_domus_aurea_upgrade)