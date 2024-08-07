
ishtar_r = class({})
ishtar_r_upgrade = class({})
modifier_ishtar_r_channel = class({})
LinkLuaModifier("modifier_ishtar_r_channel", "abilities/ishtar/ishtar_r", LUA_MODIFIER_MOTION_NONE)

function ishtar_r_wrapper(abil)
	function abil:GetBehavior()
		if self:GetCaster():HasModifier("modifier_ishtar_gem_consume") then
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
		else
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
		end
	end

	function abil:GetManaCost(iLevel)
		return 800
	end

	function abil:GetCastRange(vLocation, hTarget)
		if self:GetCaster():HasModifier("modifier_ishtar_gem_consume") then
			return self:GetSpecialValueFor("gem_range") 
		else
			return self:GetSpecialValueFor("range")
		end
	end

	function abil:GetChannelTime()
		if self:GetCaster():HasModifier("modifier_ishtar_gem_consume") then
			return 0 
		else
			return self:GetSpecialValueFor("max_channel")
		end
	end

	function abil:GetAOERadius()
		if self:GetCaster():HasModifier("modifier_ishtar_gem_consume") then
			return self:GetSpecialValueFor("gem_aoe")
		else
			return 0
		end
	end

	function abil:GetAbilityTextureName()
		return "custom/ishtar/ishtar_r"
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
		if not self.caster:HasModifier("modifier_ishtar_gem_consume") then 
			self.caster:AddNewModifier(self.caster, self, "modifier_ishtar_r_channel", {duration = self:GetSpecialValueFor("max_channel")})
			self.chargetick = 0
			self:EndCooldown()
			self:RefundManaCost()
			self.channel = true
			self.arrow_charge = false
			StartAnimation(self.caster, {duration=self:GetSpecialValueFor("max_channel") + 0.4, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
			EmitGlobalSound("Ishtar.R" .. math.random(1,3))
			self.charge_fx1 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather_blue.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(self.charge_fx1, 0, self.caster:GetAbsOrigin())
			self.charge_fx2 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2_white.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(self.charge_fx2, 0, self.caster:GetAbsOrigin())
			self.charge_fx3 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_buff_blue.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControlEnt(self.charge_fx3, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), false)
			
		else
			self.channel = false
			self:EndChannel(true)
			local target_loc = self:GetCursorPosition()
			local r_gem = self.caster:FindAbilityByName(self.caster.FSkill)
			self.gem_delay = self:GetSpecialValueFor("gem_delay")
			self.gem_range = self:GetSpecialValueFor("gem_range")
			self.gem_aoe = self:GetSpecialValueFor("gem_aoe")
			self.gem_burst_damage = self:GetSpecialValueFor("gem_burst_damage")
			self.gem_consume = self:GetGemConsume(r_gem:GetSpecialValueFor("RGem"))
			self.gem_bonus_arrow = self.gem_consume * r_gem:GetSpecialValueFor("RArrow")
			print('total bonus arrow = ' .. self.gem_bonus_arrow)
			self.gem_arrow_damage = r_gem:GetSpecialValueFor("RArrowDamage")
			self.gem_arrow_aoe = r_gem:GetSpecialValueFor("RArrowAoe")
			local ascendCount = 0
			local descendCount = 0
			self.target_arrow = {}
			self.origin_arrow = {}
			self.arrow_fx = {}
			self.bonus_damage = 0
			if self.caster.IsVenusAcquired then 
				self.bonus_damage = self:GetSpecialValueFor("bonus_agi") * self.caster:GetAgility()
			end
			StartAnimation(self.caster, {duration=self.gem_delay + 1.2, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.5})
			giveUnitDataDrivenModifier(self.caster, self.caster, "jump_pause",self.gem_delay + 1.2)

			EmitGlobalSound("Ishtar.R" .. math.random(1,3))

			Timers:CreateTimer('ishtar_r_ascend' .. self.caster:GetPlayerOwnerID(), {
				endTime = 0,
				callback = function()
			   	if ascendCount == 15 then 
			   		
			   		self.charge_fx1 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather_blue.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleControl(self.charge_fx1, 0, self.caster:GetAbsOrigin())
					self.charge_fx2 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2_white.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleControl(self.charge_fx2, 0, self.caster:GetAbsOrigin())
					self.charge_fx3 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_buff_blue.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleControlEnt(self.charge_fx3, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), false)
					self.charge_arrow_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_outline_model.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleControlEnt(self.charge_arrow_fx, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_arrow", self.caster:GetAbsOrigin(), false)
			   		for i = 1, self.gem_bonus_arrow do 
						local spawn_loc = self.caster:GetAttachmentOrigin(self.caster:ScriptLookupAttachment("attach_bow"))
						self.origin_arrow[i] = spawn_loc
					end
			   		return 
			   	end
				self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + Vector(0,0,50))
				ascendCount = ascendCount + 1;
				return 0.033
			end})

			Timers:CreateTimer("ishtar_r_descend" .. self.caster:GetPlayerOwnerID(), {
			    endTime = 0.33 + self.gem_delay + 0.3,
			    callback = function()
			    if descendCount == 15 then 
			    	local ground = GetGroundPosition(self.caster:GetAbsOrigin(), self.caster)
			    	self.caster:SetAbsOrigin(ground)
			    	return 
			    end
				self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + Vector(0,0,-50))
				descendCount = descendCount + 1;
			    return 0.033
			end})

			Timers:CreateTimer("ishtar_r_fire" .. self.caster:GetPlayerOwnerID(), {
				endTime = 0.33 + self.gem_delay,
			    callback = function()
			    local projectileOrigin = self.caster:GetAbsOrigin()
			    ParticleManager:DestroyParticle(self.charge_fx1, true)
				ParticleManager:DestroyParticle(self.charge_fx2, true)
				ParticleManager:DestroyParticle(self.charge_fx3, true)
				ParticleManager:DestroyParticle(self.charge_arrow_fx, true)
				ParticleManager:ReleaseParticleIndex(self.charge_fx1)
				ParticleManager:ReleaseParticleIndex(self.charge_fx2)
				ParticleManager:ReleaseParticleIndex(self.charge_fx3)
				ParticleManager:ReleaseParticleIndex(self.charge_arrow_fx)

				EmitGlobalSound("Ishtar.Shoot")

				Timers:CreateTimer(0.1, function()
					EmitGlobalSound("Ishtar.RLaunch")
				end)
				self.throw_particle = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_outline_model_jump.vpcf", PATTACH_WORLDORIGIN, self.caster)
				ParticleManager:SetParticleControl(self.throw_particle, 0, projectileOrigin)
				ParticleManager:SetParticleControl(self.throw_particle, 1, (target_loc - projectileOrigin):Normalized() * (self:GetSpecialValueFor("speed") - 100))
				ParticleManager:SetParticleControl(self.throw_particle, 9, projectileOrigin)

				local travelTime = (target_loc - projectileOrigin):Length() / self:GetSpecialValueFor("speed")
				Timers:CreateTimer(travelTime, function()
					ParticleManager:DestroyParticle(self.throw_particle, false)
					ParticleManager:ReleaseParticleIndex(self.throw_particle)
					self:OnArrowLand(target_loc, 1)
				end)
				for i = 1, self.gem_bonus_arrow do 
					local random_loc = target_loc + RandomVector(self:GetAOERadius() - (self.gem_aoe/2))
					local distance = (self.origin_arrow[i] - random_loc):Length2D()
					self.arrow_fx[i] = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_bonus_gem_arrow_" .. math.min(i,8) .. ".vpcf", PATTACH_CUSTOMORIGIN, self.caster)
					ParticleManager:SetParticleControl(self.arrow_fx[i], 0, self.origin_arrow[i])
					ParticleManager:SetParticleControl(self.arrow_fx[i], 1, random_loc)
					ParticleManager:SetParticleControl(self.arrow_fx[i], 2, Vector(self:GetSpecialValueFor("speed") * 1.5,0,0))
					
					Timers:CreateTimer(distance/self:GetSpecialValueFor("speed"), function()
						Timers:CreateTimer(0.2, function()
							ParticleManager:DestroyParticle(self.arrow_fx[i], false)
							ParticleManager:ReleaseParticleIndex(self.arrow_fx[i])
						end)
						self:OnArrowLand(random_loc, 2)
					end)
				end
			end})    
		end
	end

	function abil:OnArrowLand(vLocation, iArrow)
		if iArrow == 1 then -- main one

			EmitSoundOnLocationWithCaster(vLocation , "Ishtar.RImpact" , self.caster)
			EmitSoundOnLocationWithCaster(vLocation , "Ishtar.RImpact2" , self.caster)
			EmitSoundOnLocationWithCaster(vLocation , "Ishtar.RImpact3" , self.caster)

			local pot_hit = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/impact/ishtar_r_impact_parent.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pot_hit, 0, vLocation)	

			local lightning_aoe = ParticleManager:CreateParticle("particles/ishtar/ishtar_r_impact_lightning.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(lightning_aoe, 1, vLocation)	
			ParticleManager:SetParticleControl(lightning_aoe, 2, Vector(self.gem_aoe + 100,0,0))

			Timers:CreateTimer(0.3, function()
				ParticleManager:DestroyParticle(lightning_aoe, false)
				ParticleManager:DestroyParticle(pot_hit, false)
				ParticleManager:ReleaseParticleIndex(lightning_aoe)
				ParticleManager:ReleaseParticleIndex(pot_hit)
			end)

			local main_aoe = FindUnitsInRadius(self.caster:GetTeam(), vLocation, nil, self.gem_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs (main_aoe) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					DoDamage(self.caster, v, self.gem_burst_damage + self.bonus_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
					if self.caster.IsManaBurstGemAcquired then 
						self.caster:FindAbilityByName(self.caster.FSkill):AddManaBurstDebuff(v)
					end
				end	       	
			end
		else
			local arrow_aoe = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_r_gem_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(arrow_aoe, 0, vLocation)	
			ParticleManager:SetParticleControl(arrow_aoe, 1, vLocation)	
			ParticleManager:SetParticleControl(arrow_aoe, 2, Vector(self.gem_arrow_aoe,self.gem_arrow_aoe + 50,self.gem_arrow_aoe - 50))

			Timers:CreateTimer(0.3, function()
				ParticleManager:DestroyParticle(arrow_aoe, false)
				ParticleManager:ReleaseParticleIndex(arrow_aoe)
			end)
			
			local bonus_aoe = FindUnitsInRadius(self.caster:GetTeam(), vLocation, nil, self.gem_arrow_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs (bonus_aoe) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
					DoDamage(self.caster, v, self.gem_arrow_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
					if self.caster.IsManaBurstGemAcquired then 
						self.caster:FindAbilityByName(self.caster.FSkill):AddManaBurstDebuff(v)
					end
				end	       	
			end
		end
	end

	function abil:OnChannelThink(flInterval)
		if not self.channel then 
			self:EndChannel(true)
			return 
		end

		self.chargetick = self.chargetick + flInterval
		if self.chargetick >= self:GetSpecialValueFor("min_channel") then 
			self.charge_duration = self.chargetick - self:GetSpecialValueFor("min_channel")
			if not self.arrow_charge then 
				self.arrow_charge = true
				FreezeAnimation(self.caster)
				self.charge_arrow_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_outline_model.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControlEnt(self.charge_arrow_fx, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_arrow", self.caster:GetAbsOrigin(), false)
				self.indicator_fx = ParticleManager:CreateParticleForTeam("particles/ui_mouseactions/custom_range_finder_cone.vpcf", PATTACH_CUSTOMORIGIN, self.caster, self.caster:GetTeamNumber())
				ParticleManager:SetParticleControl(self.indicator_fx, 1, self.caster:GetAbsOrigin() + Vector(0,0,50))
				ParticleManager:SetParticleControl(self.indicator_fx, 4, Vector(0,255,0))
			end
			local distance = self:GetSpecialValueFor("range") + (self:GetSpecialValueFor("range_bonus_channel") * self.charge_duration)
			local end_point = GetRotationPoint(self.caster:GetAbsOrigin(), distance, self.caster:GetAnglesAsVector().y)
			ParticleManager:SetParticleControl(self.indicator_fx, 3, Vector(self:GetSpecialValueFor("width"),self:GetSpecialValueFor("width") + (10 * self.charge_duration),0))
			ParticleManager:SetParticleControl(self.indicator_fx, 2, end_point + Vector(0,0,50))
		end
	end

	function abil:OnChannelFinish(bInterrupted)
		if not self.channel then return end

		if self.chargetick < self:GetSpecialValueFor("min_channel") then 
			self:StartCooldown(self:GetCooldown(self:GetLevel()) * 0.25)
			self:GetCaster():SpendMana(self:GetManaCost(self:GetLevel()) * 0.25, self)
			EndAnimation(self.caster)
		else
			ParticleManager:DestroyParticle(self.indicator_fx, true)
			ParticleManager:ReleaseParticleIndex(self.indicator_fx)
			EmitGlobalSound("Ishtar.Shoot")
			self.charge_duration = self.chargetick - self:GetSpecialValueFor("min_channel")
			self:StartCooldown(self:GetCooldown(self:GetLevel()))
			self:GetCaster():SpendMana(self:GetManaCost(self:GetLevel()), self)
			giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealdisabled", 0.4)
			UnfreezeAnimation(self.caster)
			print('ishtar charge duration = ' .. self.charge_duration)
			local Arrow =
			{
				Ability = self,
		        EffectName = "particles/ishtar/ishtar-r/ishtar_r_projectile_blue.vpcf",
		        vSpawnOrigin = self:GetCaster():GetOrigin() + Vector(0,0,60),
		        fDistance = self:GetSpecialValueFor("range") + (self:GetSpecialValueFor("range_bonus_channel") * self.charge_duration),
		        fStartRadius = self:GetSpecialValueFor("width"),
		        fEndRadius = self:GetSpecialValueFor("width") + (10 * self.charge_duration),
		        Source = self:GetCaster(),
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		        fExpireTime = GameRules:GetGameTime() + 3.0,
		        bProvidesVision = true,
		        iVisionRadius = self:GetSpecialValueFor("width") + (10 * self.charge_duration),
				bDeleteOnHit = false,
				vVelocity = self:GetCaster():GetForwardVector() * (self:GetSpecialValueFor("speed") + (self:GetSpecialValueFor("speed_bonus_channel") * self.charge_duration)),		
			}
			self.channel_arrow = ProjectileManager:CreateLinearProjectile(Arrow)
			Timers:CreateTimer(0.1, function()
				EmitGlobalSound("Ishtar.RLaunch")
			end)
		end
		self.caster:RemoveModifierByName("modifier_ishtar_r_channel")
		ParticleManager:DestroyParticle(self.charge_fx1, true)
		ParticleManager:DestroyParticle(self.charge_fx2, true)
		ParticleManager:DestroyParticle(self.charge_fx3, true)
		ParticleManager:DestroyParticle(self.charge_arrow_fx, true)
		ParticleManager:ReleaseParticleIndex(self.charge_fx1)
		ParticleManager:ReleaseParticleIndex(self.charge_fx2)
		ParticleManager:ReleaseParticleIndex(self.charge_fx3)
		ParticleManager:ReleaseParticleIndex(self.charge_arrow_fx)
		--self.charge_arrow_fx = nil
	end

	function abil:OnProjectileHit(hTarget, vLocation)
		if hTarget == nil then return end

		self.bonus_damage = 0
		if self.caster.IsVenusAcquired then 
			self.bonus_damage = self:GetSpecialValueFor("bonus_agi") * self.caster:GetAgility()
		end

		DoDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage") + (self:GetSpecialValueFor("damage_bonus_channel") * self.charge_duration) + self.bonus_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

		if hTarget:IsRealHero() then 

			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin() , "Ishtar.RImpact" , self.caster)
			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin() , "Ishtar.RImpact2" , self.caster)
			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin() , "Ishtar.RImpact3" , self.caster)

			local pot_hit = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/impact/ishtar_r_impact_parent.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pot_hit, 0, hTarget:GetAbsOrigin())	

			local lightning_aoe = ParticleManager:CreateParticle("particles/ishtar/ishtar_r_impact_lightning.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(lightning_aoe, 1, hTarget:GetAbsOrigin())	
			ParticleManager:SetParticleControl(lightning_aoe, 2, Vector(self:GetSpecialValueFor("impact_radius") + 100,0,0))

			Timers:CreateTimer(0.3, function()
				ParticleManager:DestroyParticle(lightning_aoe, false)
				ParticleManager:DestroyParticle(pot_hit, false)
				ParticleManager:ReleaseParticleIndex(lightning_aoe)
				ParticleManager:ReleaseParticleIndex(pot_hit)
			end)

			ProjectileManager:DestroyLinearProjectile(self.channel_arrow)
			local targets = FindUnitsInRadius(self:GetCaster():GetTeam(), vLocation, nil, self:GetSpecialValueFor("impact_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			       	DoDamage(self:GetCaster(), v, self:GetSpecialValueFor("damage_impact"), DAMAGE_TYPE_MAGICAL, 0, self, false)	       	
		       		if self.caster.IsManaBurstGemAcquired then 
						self.caster:FindAbilityByName(self.caster.FSkill):AddManaBurstDebuff(hTarget)
					end
		       	end
		    end
		end
	end
end

ishtar_r_wrapper(ishtar_r)
ishtar_r_wrapper(ishtar_r_upgrade)

--------------------------------

function modifier_ishtar_r_channel:IsHidden() return true end
function modifier_ishtar_r_channel:IsDebuff() return false end
function modifier_ishtar_r_channel:IsPurgable() return false end
function modifier_ishtar_r_channel:RemoveOnDeath() return true end
function modifier_ishtar_r_channel:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_ishtar_r_channel:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end
