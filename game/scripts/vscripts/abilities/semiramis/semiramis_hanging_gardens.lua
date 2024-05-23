semiramis_hanging_gardens = class({})

LinkLuaModifier("modifier_semiramis_babylon_quake", "abilities/semiramis/modifiers/modifier_semiramis_babylon_quake", LUA_MODIFIER_MOTION_NONE)

function semiramis_hanging_gardens:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	return true
end

function semiramis_hanging_gardens:OnSpellStart()
	local caster = self:GetCaster()
	local cast_delay = self:GetSpecialValueFor("cast_delay")
	local quake_radius = self:GetSpecialValueFor("quake_radius")
	local damage = self:GetSpecialValueFor("damage")
	local damage_radius = self:GetSpecialValueFor("damage_radius")
	local targetpoint = self:GetCursorPosition()

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", cast_delay)

	ScreenShake(caster:GetOrigin(), 3, 0.2, 3.5, 4000, 0, true)

		local cracks = ParticleManager:CreateParticle( "particles/semiramis/hanging_garden_crack.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl(cracks, 0, targetpoint)

	Timers:CreateTimer(cast_delay, function()
		ParticleManager:DestroyParticle(cracks, true)
		ScreenShake(caster:GetOrigin(), 7, 0.3, 2.5, 4000, 0, true)

		local tEnemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, quake_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(tEnemies) do
			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				v:AddNewModifier(caster,self, "modifier_semiramis_babylon_quake" , {})
			end	
		end

		local enemies = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(enemies) do
			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() then
				DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
			end	
		end

		local garden = nil

		if IsValidEntity(caster.HangingGardens) and caster.HangingGardens:IsAlive() then
			caster.HangingGardens:SetAbsOrigin(targetpoint)	
			caster.HangingGardens:Heal(caster.HangingGardens:GetMaxHealth(), nil)	
			garden = caster.HangingGardens
		else
			garden = CreateUnitByName("semiramis_hanging_gardens", targetpoint, true, nil, nil, caster:GetTeamNumber())		
		end	

		garden:SetMaxHealth(self:GetSpecialValueFor("garden_health"))
		garden:SetBaseDamageMin(self:GetSpecialValueFor("garden_damage"))
		garden:SetBaseDamageMax(self:GetSpecialValueFor("garden_damage"))
		garden:SetBaseMoveSpeed(self:GetSpecialValueFor("garden_movespeed"))

		if caster.AerialGardenAttribute then
			garden:FindAbilityByName("hanging_gardens_summon_skeletons"):SetLevel(2)
			garden:FindAbilityByName("hanging_gardens_mass_recall"):SetLevel(2)
			garden:FindAbilityByName("hanging_gardens_bombard"):SetLevel(2)

			garden:AddNewModifier(caster, nil, "modifier_kill", { Duration = self:GetSpecialValueFor("duration") })
		end	

		caster.HangingGardens = garden

		local rocks = ParticleManager:CreateParticle( "particles/semiramis/hanging_garden_build.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( rocks, 0, targetpoint)

		garden:SetControllableByPlayer(caster:GetPlayerID(), true)
		garden:SetOwner(caster)
		FindClearSpaceForUnit(caster.HangingGardens, garden:GetAbsOrigin(), true)

	end)
end