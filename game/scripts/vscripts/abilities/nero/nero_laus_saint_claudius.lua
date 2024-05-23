nero_laus_saint_claudius = class({})

LinkLuaModifier("modifier_laus_saint_burn", "abilities/nero/modifiers/modifier_laus_saint_burn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_laus_saint_claudius_cooldown", "abilities/nero/modifiers/modifier_laus_saint_claudius_cooldown", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_laus_saint_ready_checker", "abilities/nero/modifiers/modifier_laus_saint_ready_checker", LUA_MODIFIER_MOTION_NONE)


function nero_laus_saint_claudius:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber())

	if(filter == UF_SUCCESS) then
		if hTarget:GetName() == "npc_dota_ward_base" or not hTarget:HasModifier("modifier_aestus_domus_aurea_enemy") then 
			return UF_FAIL_CUSTOM 
		else
			return UF_SUCCESS
		end
	else
		return filter
	end
end

function nero_laus_saint_claudius:GetCustomCastErrorTarget(hTarget)
	if hTarget:GetName() == "npc_dota_ward_base" then
		return "#Cannot_Target_Wards"
	elseif not hTarget:HasModifier("modifier_aestus_domus_aurea_enemy") then
		return "#Target_Not_In_Theatre"
	else
		return "#Invalid_Target"
	end
end

function nero_laus_saint_claudius:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")
	local ability = self
	local aestus = caster:FindAbilityByName("nero_aestus_domus_aurea")
	local target_loc = target:GetAbsOrigin()

	EmitGlobalSound("Nero_NP4")
	caster:EmitSound("Hero_LegionCommander.Duel.Victory")
	--caster:SwapAbilities("nero_laus_saint_claudius", "nero_aestus_domus_aurea", false, true)

	local masterCombo = caster.MasterUnit2:FindAbilityByName("nero_laus_saint_claudius")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))

	caster:AddNewModifier(caster, ability, "modifier_laus_saint_claudius_cooldown", {Duration = ability:GetCooldown(1)})

	if caster:HasModifier("modifier_laus_saint_ready_checker") then
		caster:RemoveModifierByName("modifier_laus_saint_ready_checker")
	end

	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration") })

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", self:GetSpecialValueFor("stun_duration"))
	local distance = (caster:GetAbsOrigin() - target_loc):Length2D()
	local diff = target_loc - caster:GetAbsOrigin()

	StartAnimation(caster, {duration = 0.4, activity = ACT_DOTA_CAST_ABILITY_5, rate = 3})

	Timers:CreateTimer(0.5, function()		
		if caster:IsAlive() then
			StartAnimation(caster, {duration = 0.4, activity = ACT_DOTA_ATTACK_EVENT, rate = 1.5})
			--[[local slashFx1 = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_ABSORIGIN, caster )
			ParticleManager:SetParticleControl( slashFx1, 0, caster:GetAbsOrigin() + Vector(0,0,300))

			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( slashFx1, false )
				ParticleManager:ReleaseParticleIndex( slashFx1 )
			end)]]
			CreateSlashFx(caster, target_loc + Vector(1200, 1200, 300),target_loc + Vector(-1200, -1200, 300))
			caster:EmitSound("Hero_EmberSpirit.Attack")
		end
	end)

	Timers:CreateTimer(1.0, function()		
		if caster:IsAlive() then
			StartAnimation(caster, {duration = 1, activity = ACT_DOTA_ATTACK_EVENT_BASH, rate = 1.5})

			--[[local slashFx2 = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_ABSORIGIN, caster )
			ParticleManager:SetParticleControl( slashFx1, 0, caster:GetAbsOrigin() + Vector(0,0,300))

			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( slashFx2, false )
				ParticleManager:ReleaseParticleIndex( slashFx2 )
			end)]]

			caster:SetAbsOrigin(target_loc - diff:Normalized() * 100)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)		
			CreateSlashFx(caster, target_loc + Vector(1200, -1200, 300), target_loc + Vector(-1200, 1200, 300))	
			caster:EmitSound("Hero_EmberSpirit.Attack")		
		end
	end)

	Timers:CreateTimer(self:GetSpecialValueFor("stun_duration"), function()
		if caster:IsAlive() then			
			if aestus == nil then 
				aestus = caster:FindAbilityByName("nero_aestus_domus_aurea_upgrade")
			end
			
			StartAnimation(caster, {duration = 1, activity = ACT_DOTA_CAST_ABILITY_3_END, rate = 1.5})	
			
			local slashFx = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_WORLDORIGIN, nil )
			ParticleManager:SetParticleControl( slashFx, 0, target_loc + Vector(0,0,300))

			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( slashFx, false )
				ParticleManager:ReleaseParticleIndex( slashFx )
			end)
			if IsValidEntity(target) and not target:IsNull() then
				target:EmitSound("Hero_Lion.FingerOfDeath")
				DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
			end
			
			local enemies = FindUnitsInRadius(caster:GetTeam(), caster.CircleDummy:GetAbsOrigin(), nil, aestus:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

			for i = 1, #enemies do
				if IsValidEntity(enemies[i]) and not enemies[i]:IsNull() and enemies[i]:HasModifier("modifier_aestus_domus_aurea_enemy") then
					enemies[i]:AddNewModifier(caster, self, "modifier_laus_saint_burn", { Duration = self:GetSpecialValueFor("duration"),
																					  BurnDamage = self:GetSpecialValueFor("burn_damage") })				
				end
			end
			
			for i = 1,5 do
				local fire_loc = caster.CircleDummy:GetAbsOrigin() + RandomVector(aestus:GetSpecialValueFor("radius") * 1/5*i)
				local fire_loc2 = caster.CircleDummy:GetAbsOrigin() + RandomVector(aestus:GetSpecialValueFor("radius") * 1/5*i)
				--[[local dummy = CreateUnitByName("dummy_unit", fire_loc, false, caster, caster, caster:GetTeamNumber())
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

				local dummy2 = CreateUnitByName("dummy_unit", fire_loc2, false, caster, caster, caster:GetTeamNumber())
				dummy2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)]]

				local explosion_fx = ParticleManager:CreateParticle("particles/custom/tamamo/combo/fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(explosion_fx, 0, fire_loc)

				local explosion_fx2 = ParticleManager:CreateParticle("particles/custom/tamamo/combo/fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(explosion_fx2, 0, fire_loc2)
				
			    Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( explosion_fx, false )
					ParticleManager:ReleaseParticleIndex(explosion_fx)
					ParticleManager:DestroyParticle( explosion_fx2, false )
					ParticleManager:ReleaseParticleIndex(explosion_fx2)
					--[[if IsValidEntity(dummy) then
						dummy:RemoveSelf()
					end
					if IsValidEntity(dummy2) then
						dummy2:RemoveSelf()
					end]]
				end)
			end
			caster:RemoveModifierByName("modifier_aestus_domus_aurea_nero")
		end
	end)
end