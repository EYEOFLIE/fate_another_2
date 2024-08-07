require("abilities/lubu/lubu_abilities")
lubu_circular_blade = class({})
lubu_circular_blade_upgrade = class({})
LinkLuaModifier("modifier_lubu_circular_window", "abilities/lubu/lubu_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lubu_circular_tracker", "abilities/lubu/lubu_blade", LUA_MODIFIER_MOTION_NONE)

function lubu_blade_wrapper(blade)
	function blade:GetCastPoint()
		if self:CheckSequence() == 2 then
			return 0.1
		elseif self:CheckSequence() == 1 then
			return 0.2
		else
			return 0.2
		end
	end

	function blade:CheckSequence()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_lubu_circular_tracker") then
			local stack = caster:GetModifierStackCount("modifier_lubu_circular_tracker", caster)

			return stack
		else
			return 0
		end	
	end

	function blade:GetPlaybackRateOverride()
		if self:CheckSequence() == 2 then
			return 2.6
		elseif self:CheckSequence() == 1 then
			return 2.5
		else
			return 2.5
		end
	end

	function blade:GetCastAnimation()
		if self:CheckSequence() == 2 then
			return ACT_DOTA_CAST_ABILITY_1
		elseif self:CheckSequence() == 1 then
			return ACT_DOTA_ATTACK
		else
			return ACT_DOTA_ATTACK2
		end
	end

	function blade:GetCastRange(vLocation, hTarget)
		if self:CheckSequence() == 2 then
			return self:GetSpecialValueFor("third_aoe")
		elseif self:CheckSequence() == 1 then
			return self:GetSpecialValueFor("second_aoe")
		else
			return self:GetSpecialValueFor("first_aoe")
		end
	end

	function blade:GetAbilityTextureName()
		if self:CheckSequence() == 2 then
			return "custom/lubu/lubu_blade3"
		elseif self:CheckSequence() == 1 then
			return "custom/lubu/lubu_blade2"
		else
			return "custom/lubu/lubu_blade1"
		end
	end

	function blade:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local total_slash = self:GetSpecialValueFor("total_slash")
		local first_aoe = self:GetSpecialValueFor("first_aoe")
		local second_aoe = self:GetSpecialValueFor("second_aoe")
		local third_aoe = self:GetSpecialValueFor("third_aoe")
		local damage_1 = self:GetSpecialValueFor("damage_1")
		local damage_2 = self:GetSpecialValueFor("damage_2")
		local damage_3 = self:GetSpecialValueFor("damage_3")
		local third_knock = self:GetSpecialValueFor("third_knock")
		local window_duration = self:GetSpecialValueFor("window_duration")
		local radius = first_aoe
		local damage = damage_1
		local origin = caster:GetAbsOrigin()
		local delay = 0.2
		local blade_hit = false

		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", delay)

		if self:CheckSequence() == total_slash - 1 then
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 3)
			radius = third_aoe
			damage = damage_3
			Timers:CreateTimer(delay, function()
				origin = GetRotationPoint(origin, caster:GetBaseAttackRange(),caster:GetAnglesAsVector().y)
			end)
			ability:EndCooldown()
			caster:RemoveModifierByName('modifier_lubu_circular_window')
		elseif self:CheckSequence() == total_slash - 2 then
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 2)
			radius = second_aoe
			damage = damage_2
			ability:EndCooldown()
			Timers:CreateTimer(delay, function()
				origin = caster:GetAbsOrigin()
			end)
		else
			caster:AddNewModifier(caster, self, "modifier_lubu_circular_window", {Duration = window_duration})
			caster:AddNewModifier(caster, self, "modifier_lubu_circular_tracker", {Duration = window_duration})
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 1)
			ability:EndCooldown()
			Timers:CreateTimer(delay, function()
				origin = caster:GetAbsOrigin()
			end)
		end

		local dash = Physics:Unit(caster)
		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(caster:GetForwardVector()*500)
		caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
		caster:FollowNavMesh(false)

		if self:CheckSequence() < total_slash then 
			DoCleaveAttack(caster, caster, self, 0, 180, radius, radius, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf")
		end

		Timers:CreateTimer(delay, function()
			caster:OnPreBounce(nil)
			caster:OnPhysicsFrame(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:EmitSound('Lubu.Blade')
			if caster:IsAlive() then
				local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if self:CheckSequence() >= total_slash then 
						if IsValidEntity(v) and not v:IsNull() then
							if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								ApplyAirborne(caster, v, third_knock)
							end
							if caster.IsHoutengagekiAcquired then 
								local damage_3_per_str = ability:GetSpecialValueFor("damage_3_per_str")
								damage = damage + (damage_3_per_str * caster:GetStrength())
							end
							DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
							if caster.IsRuthlessWarriorAcquired then
								local MR = v:GetBaseMagicalResistanceValue()/100
			            		local dmg_deal = damage * (1-MR) 
								if k == 1 then 
									OnRuthlessDrain(caster, 1, dmg_deal)
									v:EmitSound('Hero_EarthShaker.Fissure')
								else
									OnRuthlessDrain(caster, 0, dmg_deal)
								end
							end
						end
					else
						if IsValidEntity(v) and not v:IsNull() then
							local angle = 180
							local caster_angle = caster:GetAnglesAsVector().y
							--print('lubu angle ' .. caster_angle)
					        local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

					        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

					        origin_difference_radian = origin_difference_radian * 180
					        local enemy_angle = origin_difference_radian / math.pi

					        enemy_angle = enemy_angle + 180.0
					        --print('enemy angle ' .. enemy_angle)

					        if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
					        	enemy_angle = 360 - enemy_angle
					        elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
					        	caster_angle = 360 - caster_angle 
					        end

							local result_angle = enemy_angle - caster_angle
							result_angle = math.abs(result_angle)

							if result_angle <= angle/2 then
								DoDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
								if caster.IsRuthlessWarriorAcquired then
									local reduction = GetPhysicalDamageReduction(v:GetPhysicalArmorValue(false))
			            			local dmg_deal = damage * (1-reduction) 
									if blade_hit == false then
										blade_hit = true
										OnRuthlessDrain(caster, 1, dmg_deal)
										v:EmitSound('Hero_Sven.Attack')
									else
										OnRuthlessDrain(caster, 0, dmg_deal) 
									end
								end
							end
						end
					end
				end
				if self:CheckSequence() >= total_slash then 
					if caster:HasModifier('modifier_lubu_circular_tracker') then 
						caster:RemoveModifierByName('modifier_lubu_circular_tracker')
					end
					local smashfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf', PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(smashfx, 0, GetRotationPoint(caster:GetAbsOrigin(), caster:GetBaseAttackRange(),caster:GetAnglesAsVector().y))
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(smashfx, false)
						ParticleManager:ReleaseParticleIndex(smashfx)
					end)
				end
			end
		end)
	end
end
	
lubu_blade_wrapper(lubu_circular_blade_upgrade)
lubu_blade_wrapper(lubu_circular_blade)		

modifier_lubu_circular_window = class({})	

function modifier_lubu_circular_window:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_lubu_circular_window:IsHidden()
	return false 
end

function modifier_lubu_circular_window:IsDebuff()
	return false 
end

function modifier_lubu_circular_window:RemoveOnDeath()
	return true 
end

if IsServer() then
	function modifier_lubu_circular_window:OnDestroy()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		local time = self:GetDuration() - self:GetRemainingTime()
		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()) - time)
	end
end

modifier_lubu_circular_tracker = class({})	

function modifier_lubu_circular_tracker:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_lubu_circular_tracker:IsHidden()
	return true 
end

function modifier_lubu_circular_tracker:IsDebuff()
	return false 
end

function modifier_lubu_circular_tracker:RemoveOnDeath()
	return true 
end