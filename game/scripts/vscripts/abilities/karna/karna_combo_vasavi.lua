karna_combo_vasavi = class({})
karna_combo_vasavi_upgrade = class({})

LinkLuaModifier("modifier_vasavi_hit", "abilities/karna/modifiers/modifier_vasavi_hit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combo_vasavi_cooldown", "abilities/karna/modifiers/modifier_combo_vasavi_cooldown", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vision_provider", "abilities/general/modifiers/modifier_vision_provider", LUA_MODIFIER_MOTION_NONE)

function Karna_combo_vasavi_wrapper(ability)
	function ability:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("cast_range")
	end

	function ability:GetCastPoint()
		return self:GetSpecialValueFor("cast_point")
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()

		local fire_delay = self:GetSpecialValueFor("fire_delay")
		local sound_delay = self:GetSpecialValueFor("prefire_delay")
		local range = self:GetSpecialValueFor("range")	

		EmitGlobalSound("karna_vasavi_start_" .. math.random(1,5))

		local masterCombo = caster.MasterUnit2:FindAbilityByName("karna_combo_vasavi")
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(self:GetCooldown(1))

		caster:RemoveModifierByName("modifier_karna_combo_window")

		local vasavi = caster:FindAbilityByName("karna_vasavi_shakti")
		if vasavi == nil then 
			vasavi = caster:FindAbilityByName("karna_vasavi_shakti_upgrade")
		end
		vasavi:StartCooldown(vasavi:GetCooldown(vasavi:GetLevel()))

		caster:AddNewModifier(caster, self, "modifier_combo_vasavi_cooldown", { Duration = self:GetCooldown(1) })

		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4)
		StartAnimation(caster, {duration=sound_delay, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.43})

		local weapon_spark_location = caster:GetOrigin() + Vector(caster:GetForwardVector().x, caster:GetForwardVector().y, 0) * 175 + Vector(0, 0, 125)

		self.WeaponSpark = ParticleManager:CreateParticle("particles/custom/karna/combo/combo_vasavi_attach.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(self.WeaponSpark, 0, weapon_spark_location) 
		--ParticleManager:SetParticleControlEnt(self.WeaponSpark, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon", caster:GetOrigin(), true)

		Timers:CreateTimer(sound_delay, function()
			if caster:IsAlive() then
				StartAnimation(caster, {duration=1.7, activity=ACT_DOTA_CAST_ABILITY_6, rate=0.59})
				EmitGlobalSound("karna_vasavi_end")
			end
			return
		end)

		Timers:CreateTimer(fire_delay, function()
			ParticleManager:DestroyParticle(self.WeaponSpark, true)
			ParticleManager:ReleaseParticleIndex(self.WeaponSpark)

			if caster:IsAlive() then
				local aoe = self:GetSpecialValueFor("beam_aoe")

				--forwardVec = GetGroundPosition(forwardVec, nil)

			    local projectileTable = {
					Ability = self,
					EffectName = "particles/custom/karna/combo/vasavi_beam.vpcf",
					iMoveSpeed = 10000,
					vSpawnOrigin = caster:GetAbsOrigin(),
					fDistance = range,
					Source = self:GetCaster(),
					fStartRadius = aoe,
			        fEndRadius = aoe,
					bHasFrontialCone = true,
					bReplaceExisting = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_ALL,
					fExpireTime = GameRules:GetGameTime() + 3,
					bDeleteOnHit = false,
					vVelocity = caster:GetForwardVector() * 3000,
				}

			    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)

			    self.Dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				self.Dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)			

			    self.LaserBeam = ParticleManager:CreateParticle("particles/custom/karna/combo/vasavi_shakti_beam_combo.vpcf", PATTACH_CUSTOMORIGIN, self.Dummy)
				ParticleManager:SetParticleControlEnt(self.LaserBeam, 0, caster, PATTACH_POINT_FOLLOW, "attach_lance", caster:GetOrigin(), true)
				ParticleManager:SetParticleControl(self.LaserBeam, 1, caster:GetOrigin())			
			end
			Timers:CreateTimer(range / 3000, function()
				ParticleManager:DestroyParticle(self.LaserBeam, false)
				ParticleManager:ReleaseParticleIndex(self.LaserBeam)

				ParticleManager:DestroyParticle(self.WeaponSpark, true)
				ParticleManager:ReleaseParticleIndex(self.WeaponSpark)
			end)
			return
		end)
	end

	function ability:OnProjectileThink(vLocation)
		vLocation = vLocation + Vector(0, 0, 32)
		self.Dummy:SetAbsOrigin(vLocation)
		
		ParticleManager:SetParticleControlEnt(self.LaserBeam, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_lance", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.LaserBeam, 1, vLocation)
	end

	function ability:OnProjectileHit_ExtraData(hTarget, vLocation, table)
		local hCaster = self:GetCaster()

		--if not IsValidEntity(hTarget) or hTarget:IsNull() or not hTarget:IsAlive() then return end
		
		if hTarget == nil then 
			local end_radius = self:GetSpecialValueFor("end_radius")
			local end_targets = FindUnitsInRadius(hCaster:GetTeam(), vLocation, nil, end_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

			local full_damage = self:GetSpecialValueFor("full_damage")
			local damage_difference = self:GetSpecialValueFor("full_damage") - self:GetSpecialValueFor("beam_damage")	
			local bonus_divine = self:GetSpecialValueFor("bonus_divine") / 100

			for i = 1, #end_targets do
				if IsValidEntity(end_targets[i]) and not end_targets[i]:IsNull() then
					if IsDivineServant(end_targets[i]) and hCaster.IndraAttribute then
						full_damage = full_damage * (1 + bonus_divine)
						damage_difference = damage_difference * (1 + bonus_divine)
					end

					if not end_targets[i]:HasModifier("modifier_vasavi_hit") then
						DoDamage(hCaster, end_targets[i], full_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
					else
						DoDamage(hCaster, end_targets[i], damage_difference, DAMAGE_TYPE_MAGICAL, 0, self, false)
					end
				end
			end
			
			local particle = ParticleManager:CreateParticle("particles/custom/karna/combo/vasavi_explode.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
			ParticleManager:SetParticleControl(particle, 0, vLocation) 
			ParticleManager:SetParticleControl(particle, 1, Vector(end_radius + 200, end_radius + 200, end_radius + 200)) 

			

			EmitGlobalSound("karna_vasavi_explosion")

			Timers:CreateTimer(2, function()
				ParticleManager:DestroyParticle(particle, false)
				ParticleManager:ReleaseParticleIndex(particle)
				if IsValidEntity(self.Dummy) then
					self.Dummy:RemoveSelf()
				end
				return
			end)

			return 
		else
			local damage = self:GetSpecialValueFor("beam_damage")
			local bonus_divine = self:GetSpecialValueFor("bonus_divine") / 100

			if IsDivineServant(hTarget) and hCaster.IndraAttribute then
				damage = damage * (1 + bonus_divine)
			end

			hTarget:AddNewModifier(hCaster, self, "modifier_vasavi_hit", { Duration = 2 })
			DoDamage(hCaster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		end	
	end
end

Karna_combo_vasavi_wrapper(karna_combo_vasavi)
Karna_combo_vasavi_wrapper(karna_combo_vasavi_upgrade)