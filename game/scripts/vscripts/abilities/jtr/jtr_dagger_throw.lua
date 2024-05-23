jtr_dagger_throw = class({})

LinkLuaModifier("modifier_jtr_dagger_mark", "abilities/jtr/modifiers/modifier_jtr_dagger_mark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jtr_dagger_slow", "abilities/jtr/modifiers/modifier_jtr_dagger_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dagger_throw_crit", "abilities/jtr/modifiers/modifier_dagger_throw_crit", LUA_MODIFIER_MOTION_NONE)

function jtr_dagger_throw:CastFilterResultTarget(hTarget)
	if hTarget:GetName() == "npc_dota_ward_base" then return UF_SUCCESS end

	local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
	
	return filter
end

function jtr_dagger_throw:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function jtr_dagger_throw:OnUpgrade()
	local hCaster = self:GetCaster()
	hCaster:FindAbilityByName("jtr_ghost_walk"):SetLevel(self:GetLevel())
end

function jtr_dagger_throw:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	if hTarget:GetName() == "npc_dota_ward_base" then 		
		hCaster:EmitSound("Hero_Antimage.Blink_out")

		hCaster:SetAbsOrigin(hTarget:GetAbsOrigin()-(hCaster:GetAbsOrigin() - hTarget:GetAbsOrigin()):Normalized() * 130)
		FindClearSpaceForUnit(hCaster, hCaster:GetAbsOrigin(), true)
		hCaster:SetForwardVector(hCaster:GetForwardVector() - hTarget:GetAbsOrigin())

		hCaster:EmitSound("Hero_Antimage.Blink_in")
	else
		local dagger_damage_1 = self:GetSpecialValueFor("base_damage") + (hCaster:GetAverageTrueAttackDamage(hTarget) * self:GetSpecialValueFor("dagger_ratio_1") / 100)
		local dagger_damage_2 = (hCaster:GetAverageTrueAttackDamage(hTarget) * self:GetSpecialValueFor("dagger_ratio_2") / 100)

		local info = {
			Target = hTarget,
			Source = hCaster, 
			Ability = self,
			EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
			vSpawnOrigin = hCaster:GetAbsOrigin(),
			iMoveSpeed = 1800,
			ExtraData = { slow = 0,
						  damage = dagger_damage_1,
						  blink = 1 }
		}

		ProjectileManager:CreateTrackingProjectile(info) 
		hCaster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

		if not hTarget:HasModifier("modifier_jtr_dagger_mark") then
			Timers:CreateTimer(0.3, function()
				if hCaster:IsAlive() and hTarget:IsAlive() then				
					local info2 = {
						Target = hTarget,
						Source = hCaster, 
						Ability = self,
						EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
						vSpawnOrigin = hCaster:GetAbsOrigin(),
						iMoveSpeed = 1800,
						ExtraData = { slow = 1,
									  damage = dagger_damage_2,
									  blink = 0 }
					}

					ProjectileManager:CreateTrackingProjectile(info2) 

					hCaster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")							
				end

				return
			end)
		end		
	end
end

function jtr_dagger_throw:OnProjectileHit_ExtraData(hTarget, vLocation, tExtraData)
	if hTarget == nil then return end

	if not IsValidEntity(hTarget) or hTarget:IsNull() or not hTarget:IsAlive() then return end

	local hCaster = self:GetCaster()
	local damage = tExtraData.damage or 100
	hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target")

	if tExtraData.slow and tExtraData.slow == 1 then
		if not IsImmuneToSlow(hTarget) and not IsImmuneToCC(hTarget) then
			hTarget:AddNewModifier(hCaster, self, "modifier_jtr_dagger_slow", { Duration = self:GetSpecialValueFor("duration"),
																				SlowPct = self:GetSpecialValueFor("slow_pct")})
		end
	end

	DoDamage(hCaster, hTarget, damage, DAMAGE_TYPE_PHYSICAL, 0, self, false)
	if IsValidEntity(hTarget) and hTarget:IsAlive() then
		if hTarget:HasModifier("modifier_jtr_dagger_mark") and (tExtraData.blink and tExtraData.blink == 1) then
			hCaster:EmitSound("Hero_Antimage.Blink_out")

			hCaster:SetAbsOrigin(hTarget:GetAbsOrigin()-(hCaster:GetAbsOrigin() - hTarget:GetAbsOrigin()):Normalized() * 130)
			FindClearSpaceForUnit(hCaster, hCaster:GetAbsOrigin(), true)
			hCaster:SetForwardVector(hCaster:GetForwardVector() - hTarget:GetAbsOrigin())

			hCaster:EmitSound("Hero_Antimage.Blink_in")

			hCaster:AddNewModifier(hCaster, self, "modifier_dagger_throw_crit", {Damage = self:GetSpecialValueFor("crit_damage"), Duration = 3.0 })
			hTarget:RemoveModifierByName("modifier_jtr_dagger_mark")
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		 		TargetIndex = hTarget:entindex()
		 	})
		else
			hTarget:AddNewModifier(hCaster, self, "modifier_jtr_dagger_mark", { Duration = self:GetSpecialValueFor("mark_duration") })
		end	
	
		if hCaster.IsMurdererOfMistyNightAcquired and hCaster:HasModifier("modifier_jtr_murderer_mist_buff") then
			local ambush = hCaster:FindAbilityByName("jtr_murderer_on_misty_night")
			local agi_damage = ambush:GetSpecialValueFor("invis_agi_damage") 
			DoDamage(hCaster, hTarget, hCaster:GetAgility() * agi_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		end
	end
	--hCaster:PerformAttack(hTarget, true, true, true, true, false, true, true)

end