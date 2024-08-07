
ishtar_e = class({})
ishtar_e_upgrade = class({})

function ishtar_e_wrapper(abil)
	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end

	function abil:GetAOERadius()
		return self:GetSpecialValueFor("aoe")
	end

	function abil:GetManaCost(iLevel)
		return 400
	end

	function abil:GetCastPoint()
		if self:GetCaster():HasModifier("modifier_ishtar_w_dash") then
			return 0
		else
			return self:GetSpecialValueFor("delay")
		end
	end

	function abil:GetCastRange(vLocation, hTarget)
		if self:GetCaster():HasModifier("modifier_ishtar_w_dash") then
			return self:GetSpecialValueFor("max_range")
		else
			return self:GetSpecialValueFor("range")
		end
	end

	function abil:GetAbilityTextureName()
		return "custom/ishtar/ishtar_e"
	end

	function abil:GetGemConsume(iMaxGemUse)
		local caster = self:GetCaster()
		local gem_consume = 0
		if caster:HasModifier("modifier_ishtar_gem_consume") then 
			local gem = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
			gem_consume = math.min(iMaxGemUse, gem)
			caster:FindAbilityByName(caster.DSkill):AddGem(-gem_consume)
		end
		return gem_consume
	end

	function abil:OnSpellStart()
		self.caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		self.delay = self:GetSpecialValueFor("delay")
		self.damage = self:GetSpecialValueFor("damage")
		self.bonus_damage = 0
		if self.caster.IsVenusAcquired then 
			self.bonus_damage = self:GetSpecialValueFor("bonus_agi") * self.caster:GetAgility()
		end
		local e_gem = self.caster:FindAbilityByName(self.caster.FSkill)
		self.max_range = self:GetSpecialValueFor("max_range")
		self.arrow = self:GetSpecialValueFor("arrows")
		self.max_arrow = e_gem:GetSpecialValueFor("EMax")
		self.target_arrow = {}
		self.origin_arrow = {}
		self.spawn_arrow = {}
		self.gem_consume = 0
		self.arrow_count = 0
		if self.caster:HasModifier("modifier_ishtar_gem_consume") then
			self.gem_consume = self:GetGemConsume(e_gem:GetSpecialValueFor("EGem"))
		end
		self.arrow = self.arrow + (self.gem_consume * e_gem:GetSpecialValueFor("EArrows"))
		self.angle = self.caster:GetAnglesAsVector().z
		local enemies_detect = FindUnitsInRadius(self.caster:GetTeam(), target_loc, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		local particleeff1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_e_cast.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
		ParticleManager:SetParticleControl(particleeff1, 0, self.caster:GetAbsOrigin() + Vector(0,0,200))

		Timers:CreateTimer(self.delay/2, function()
			self.caster:EmitSound("Ishtar.E" .. math.random(1,3))
			for i = 1, self.arrow do 
				local spawn_loc = self:GetSpawnLoc()
				self.origin_arrow[i] = spawn_loc
				--[[self.spawn_arrow[i] = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_track.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
				ParticleManager:SetParticleControlEnt(self.spawn_arrow[i], 0, self.caster, PATTACH_POINT, "attach_attack1", self.caster:GetAbsOrigin(), false)
				ParticleManager:SetParticleControl(self.spawn_arrow[i], 1, spawn_loc)
				ParticleManager:SetParticleControl(self.spawn_arrow[i], 2, Vector(900,0,0))
				Timers:CreateTimer(self.delay/2, function()
					ParticleManager:DestroyParticle(self.spawn_arrow[i], true)
					ParticleManager:ReleaseParticleIndex(self.spawn_arrow[i])
				end)]]
				--[[self.spawn_arrow[i] = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_laser_spawn.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
				ParticleManager:SetParticleControl(self.spawn_arrow[i], 1, spawn_loc)
				ParticleManager:SetParticleControlEnt(self.spawn_arrow[i], 9, self.caster, PATTACH_POINT, "attach_attack1", self.caster:GetAbsOrigin(), false)]]
			end
			self.spawn_arrow = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_track.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
			ParticleManager:SetParticleControl(self.spawn_arrow, 0, self.origin_arrow[1])
			ParticleManager:SetParticleControl(self.spawn_arrow, 1, Vector(self.arrow,0,0))
		end)
		Timers:CreateTimer(self.delay, function()
			ParticleManager:DestroyParticle(self.spawn_arrow, false)
			ParticleManager:ReleaseParticleIndex(self.spawn_arrow)
			if self.caster:IsAlive() then 
				EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Ishtar.Projectile" .. math.random(1,4) , self.caster)
				EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Ishtar.ProjectileBase" , self.caster)
				if #enemies_detect >= 1 then
					i = 1
					while i <= #enemies_detect do
						if IsValidEntity(enemies_detect[i]) and not enemies_detect[i]:IsNull() then
							if (target_loc - enemies_detect[i]:GetAbsOrigin()):Length2D() > self.max_range or not enemies_detect[i]:IsAlive() then 
								table.remove(enemies_detect, i)
								i = i - 1
							end
						end
						i = i + 1
					end
				end
				for j = 1, self.arrow do 
					--ParticleManager:DestroyParticle(self.spawn_arrow[j], true)
					--ParticleManager:ReleaseParticleIndex(self.spawn_arrow[j])
					if #enemies_detect >= 1 then
						local random = RandomInt(1, #enemies_detect)
						if not enemies_detect[random]:IsAlive() then 
							table.remove(enemies_detect, random)
							random = RandomInt(1, #enemies_detect)
						end
						self:CreateTrackingProjectile(self.origin_arrow[j], enemies_detect[random])
						--ParticleManager:DestroyParticle(self.spawn_arrow[j], true)
						--ParticleManager:ReleaseParticleIndex(self.spawn_arrow[j])
						local name = enemies_detect[random]:GetName()
						if self.target_arrow.name == nil then
							self.target_arrow.name = 1
						else
							self.target_arrow.name = self.target_arrow.name + 1
						end

						if self.target_arrow.name >= self.max_arrow then 
							table.remove(enemies_detect, random)
						end
						self.arrow_count = self.arrow_count + 1
					else
						local random_loc = target_loc + RandomVector(self:GetAOERadius() - 45)
						local distance = (self.origin_arrow[j] - random_loc):Length2D()
						--ParticleManager:SetParticleControl(self.spawn_arrow[j], 2, Vector(self:GetSpecialValueFor("speed"),0,0))
						--ParticleManager:SetParticleControl(self.spawn_arrow[j], 1, random_loc)
						local e_projectile = ParticleManager:CreateParticle("particles/ishtar/ishtar_proj_track.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
						ParticleManager:SetParticleControl(e_projectile, 0, self.origin_arrow[j])
						ParticleManager:SetParticleControl(e_projectile, 1, random_loc)
						ParticleManager:SetParticleControl(e_projectile, 2, Vector(self:GetSpecialValueFor("speed"),0,0))
						Timers:CreateTimer(distance/self:GetSpecialValueFor("speed"), function()
							ParticleManager:DestroyParticle(e_projectile, true)
							ParticleManager:ReleaseParticleIndex(e_projectile)
							local particleeff1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact_2.vpcf", PATTACH_CUSTOMORIGIN, nil)
							ParticleManager:SetParticleControl(particleeff1, 0, random_loc + Vector(0,0,10))
							local random_target = FindUnitsInRadius(self.caster:GetTeam(), random_loc, nil, 90, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
							for k,v in pairs(random_target) do 
								DoDamage(self.caster, v, self.damage + self.bonus_damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self, false)
								if self.caster.IsManaBurstGemAcquired then 
									self.caster:FindAbilityByName(self.caster.FSkill):AddManaBurstDebuff(v)
								end
							end
						end)
					end
				end
			end
		end)
	end

	function abil:GetSpawnLoc()
		local front = self.caster:GetForwardVector()
		local origin = self.caster:GetAbsOrigin() + (Vector(front.x,front.y,0) * 50)
		local leftvec = Vector(-front.y, front.x, 0)
		local rightvec = self.caster:GetRightVector() --Vector(front.y, -front.x, 0)
		--local vSpawnOrigin = Vector(0,0,0)
		local random1 = RandomInt(0, 100) -- position of weapon spawn
		local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

		local vSpawnOrigin = origin + (rightvec * RandomInt(-150, 150)) + Vector(0,0,RandomInt(400, 450))
		--[[if random2 == 0 then 
			vSpawnOrigin = origin + (leftvec * random1) + Vector(0,0,RandomInt(200, 400))
		else 
			vSpawnOrigin = origin + (rightvec * random1) + Vector(0,0,RandomInt(200, 400))
		end]]
		--print('e spawn ' .. vSpawnOrigin)
		return vSpawnOrigin
	end

	function abil:CreateTrackingProjectile(vSpawnLoc ,hTarget)

		local arrow = {
			Target = hTarget,
			Source = self:GetCaster(),
			Ability = self,	
			EffectName = "particles/ishtar/ishtar_proj_track.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			vSourceLoc= vSpawnLoc,
			bDrawsOnMinimap = false,
			bDodgeable = true,
			bIsAttack = false,
			flExpireTime = GameRules:GetGameTime() + 3,	
		}

		ProjectileManager:CreateTrackingProjectile(arrow)
	end

	function abil:OnProjectileHit(hTarget, vLocation)
		if hTarget == nil then return end

		hTarget:EmitSound("Ishtar.ProjectileLayer")
		hTarget:EmitSound("Ishtar.ProjectileHit" .. math.random(1,2))

		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")
		local bonus_damage = 0
		if caster.IsVenusAcquired then 
			bonus_damage = self:GetSpecialValueFor("bonus_agi") * caster:GetAgility()
		end
		DoDamage(caster, hTarget, damage + bonus_damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NONE, self, false)
		if caster.IsManaBurstGemAcquired then 
			caster:FindAbilityByName(caster.FSkill):AddManaBurstDebuff(hTarget)
		end

		local particleeff1 = ParticleManager:CreateParticle("particles/ishtar/ishtar_w_impact_2.vpcf", PATTACH_ABSORIGIN, hTarget)
		ParticleManager:SetParticleControl(particleeff1, 0, hTarget:GetAbsOrigin())
	end
end

ishtar_e_wrapper(ishtar_e)
ishtar_e_wrapper(ishtar_e_upgrade)