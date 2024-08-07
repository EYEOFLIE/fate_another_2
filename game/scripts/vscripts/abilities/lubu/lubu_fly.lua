
lubu_flying = class({})
lubu_flying_upgrade = class({})

LinkLuaModifier("modifier_lubu_fly", "abilities/lubu/lubu_fly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lubu_fly_slam", "abilities/lubu/lubu_fly", LUA_MODIFIER_MOTION_NONE)

function lubu_flying_wrapper(ability)
	function ability:GetAbilityTextureName()
       -- if self:GetCaster():HasModifier("modifier_alternate_03") then
        --    return "custom/lubu/lubu_god_force_skin"
        --else
            return "custom/lubu/lubu_flying"
        --end
    end    

    function ability:OnSpellStart()
    	self.caster = self:GetCaster()
		self.target = self:GetCursorTarget()

		self.caster.fly_target = self.target
		self.caster:EmitSound('Lubu.Arrow')
		self.caster:AddNewModifier(self.caster, self, "modifier_lubu_fly", {Duration = self:GetSpecialValueFor("duration")})
		print('lubu flying')
		if self.caster.IsMadEnhancementAcquired then
			local mad = self.caster:FindAbilityByName("lubu_bravary_upgrade")
			mad:ApplyDataDrivenModifier(self.caster, self.caster, "modifier_lubu_mad", {Duration = self:GetSpecialValueFor("duration")})
		end
	end

	function ability:GetFateTarget()
		return self:GetCursorTarget()
	end

	function ability:OnFlyingAttack()
		if not self.target:IsAlive() or not self.caster:IsAlive() then 
			return 
		end

		local hit_damage = self:GetSpecialValueFor("hit_damage")
		local slam_damage = self:GetSpecialValueFor("slam_damage")
		local slam_stun = self:GetSpecialValueFor("slam_stun")
		local slam_aoe = self:GetSpecialValueFor("slam_aoe")
		local anim_duration = 0.4
		DoDamage(self.caster, self.target, hit_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

		self.target:AddNewModifier(self.caster, self, "modifier_lubu_fly_slam", {Duration = anim_duration})

		giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealenabled", anim_duration + 0.1) 

		Timers:CreateTimer(anim_duration, function()
			if not self.caster:IsAlive() then 
				return 
			end
			if self.target:IsAlive() then
				self.target:AddNewModifier(self.caster, self, "modifier_stunned", {Duration = slam_stun})
			end
			local smashfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf', PATTACH_ABSORIGIN, self.caster)
			ParticleManager:SetParticleControl(smashfx, 0, self.target:GetAbsOrigin())
			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(smashfx, false)
				ParticleManager:ReleaseParticleIndex(smashfx)
			end)
			self.caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
			local slam_enemies = FindUnitsInRadius(self.caster:GetTeam(), self.target:GetAbsOrigin(), nil, slam_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(slam_enemies) do 
				if IsValidEntity(v) and not v:IsNull() then 
					DoDamage(self.caster, v, slam_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
				end
			end
		end)
	end
end

lubu_flying_wrapper(lubu_flying)
lubu_flying_wrapper(lubu_flying_upgrade)

---------------

modifier_lubu_fly = class({})

function modifier_lubu_fly:IsPassive()
	return false 
end

function modifier_lubu_fly:IsHidden()
	return false 
end

function modifier_lubu_fly:IsDebuff()
	return false 
end

function modifier_lubu_fly:IsPurgable()
	return false 
end

function modifier_lubu_fly:RemoveOnDeath()
	return true 
end

function modifier_lubu_fly:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_lubu_fly:GetTexture()
	return "custom/lubu/lubu_flying"
end

function modifier_lubu_fly:CheckState()
	return { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			 [MODIFIER_STATE_DISARMED] = true,
			 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_lubu_fly:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			 MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
			 MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			 MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			 MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE }
end

function modifier_lubu_fly:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_red")
end

function modifier_lubu_fly:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_lubu_fly:GetModifierProvidesFOWVision()
	return 1
end

function modifier_lubu_fly:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_lubu_fly:GetOverrideAnimationRate()
	return 2.0
end

if IsServer() then
	function modifier_lubu_fly:OnCreated(table)	
		self.caster = self:GetCaster()
		self.target = self:GetAbility():GetFateTarget()
		self.caster:MoveToTargetToAttack(self.target)
	    self:StartIntervalThink(0.034)
	end

	function modifier_lubu_fly:OnIntervalThink()

		if self.target:IsNull() or not self.target:IsAlive() or not self.caster:IsAlive() or not IsInSameRealm(self.caster:GetAbsOrigin(), self.target:GetAbsOrigin()) then
			self:Destroy()
	        return
	    end

	    if (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D() <= 275 then
	    	local diff = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin() ):Normalized() 
			self.caster:SetAbsOrigin(self.target:GetAbsOrigin() - diff*200) 
			FindClearSpaceForUnit(self.caster, self.caster:GetAbsOrigin(), true)
	        self:GetAbility():OnFlyingAttack()
	        self:Destroy()
	    end

	    if not self.fly_effect then
	    	self.fly_effect = true
	    	local forward_vec = self.caster:GetForwardVector()
	    	local right_vec = self.caster:GetRightVector()
	    	--print('right: ' .. (right_vec*100))
	    	local fly_run_effect = ParticleManager:CreateParticle('particles/custom/lubu/lubu_dash_lines.vpcf', PATTACH_ABSORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(fly_run_effect, 0, self.caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fly_run_effect, 1, (right_vec * 100) + Vector(0,-100,50))
			ParticleManager:SetParticleControl(fly_run_effect, 2, (-right_vec * 100) + Vector(0,100,10))
			ParticleManager:SetParticleControl(fly_run_effect, 3, -forward_vec * 20)
			ParticleManager:SetParticleControl(fly_run_effect, 4, -forward_vec * 30)
	    	Timers:CreateTimer(0.5, function()
	    		ParticleManager:DestroyParticle(fly_run_effect, true)
	    		ParticleManager:ReleaseParticleIndex(fly_run_effect)
	    		self.fly_effect = nil
	    	end)
	    end
	 
	 	if self.caster.IsMadEnhancementAcquired then
	 		self.caster:MoveToTargetToAttack(self.target)
	 	else
		 	if not self.caster:IsStunned() and not self.caster:IsRooted() then
		    	self.caster:MoveToTargetToAttack(self.target)
		    end
		end   
	end
end



---------------------------------------

modifier_lubu_fly_slam = class({})

function modifier_lubu_fly_slam:IsPassive()
	return false 
end

function modifier_lubu_fly_slam:RemoveOnDeath()
	return true 
end

function modifier_lubu_fly_slam:IsHidden()
	return false 
end

function modifier_lubu_fly_slam:IsDebuff()
	return true 
end

function modifier_lubu_fly_slam:IsPurgable()
	return false 
end

function modifier_lubu_fly_slam:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_lubu_fly_slam:GetTexture()
	return "custom/lubu/lubu_flying"
end

function modifier_lubu_fly_slam:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true,
			 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

if IsServer() then
	function modifier_lubu_fly_slam:OnCreated(table)	
		
			self.caster = self:GetAbility():GetCaster()
			self.ability = self:GetAbility()
			self.target = self:GetParent()
			
			self.tick_count = 0
			self.height = 360
		
			self.caster_angle = self.caster:GetAnglesAsVector().y

			self.target:SetAngles(-90, 0, 0)
			self.target:SetAbsOrigin(self.target:GetAbsOrigin() + Vector(0,0,self.height))

		    self:StartIntervalThink(0.033)
	end

	function modifier_lubu_fly_slam:OnIntervalThink()

		local UFilter = UnitFilter( self.target,
	                               self.ability:GetAbilityTargetTeam(),
	                               self.ability:GetAbilityTargetType(),
	                               self.ability:GetAbilityTargetFlags(),
	                               self.caster:GetTeamNumber() )

		if UFilter ~= UF_SUCCESS then
	        self:Destroy()
	        return nil
	    end

	    if self.tick_count == 0.4 then 
	    	self.target:SetAngles(0, 0, 0)
	    	local ground = GetGroundPosition(self.target:GetOrigin(), self.target)
			self.target:SetAbsOrigin(ground)
			self:Destroy()
			return nil
		end

	    self.height = self.height - 30	

	    self:Grip()
	    self.tick_count = self.tick_count + 0.034
	end

	function modifier_lubu_fly_slam:Grip()
		
		local target_loc = GetRotationPoint(self.caster:GetAbsOrigin(), 160, self.caster_angle + 45) + Vector(0,0,self.height)
		--local ground = GetGroundPosition(self.target:GetOrigin(), self.target)
		self.target:SetOrigin(target_loc)
	end


	function modifier_lubu_fly_slam:OnDestroy()
		self.target:SetAngles(0, 0, 0)    
		
		local ground = GetGroundPosition(self.target:GetOrigin(), self.target)
		self.target:SetAbsOrigin(ground)
	end
end




