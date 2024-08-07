LinkLuaModifier("modifier_atalanta_skia", "abilities/alter_atalanta/atalanta_alter_skia", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_skia_cd", "abilities/alter_atalanta/atalanta_alter_skia", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_tauropolos_alter_penalty", "abilities/alter_atalanta/atalanta_alter_skia", LUA_MODIFIER_MOTION_NONE)

atalanta_alter_skia = class({})
atalanta_alter_skia_upgrade = class({})

function atalanta_skia_wrapper(ability)
	function ability:GetBehavior()
		if self:GetCaster():IsRealHero() then 
			return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
		else
			return DOTA_ABILITY_BEHAVIOR_PASSIVE
		end
	end

	function ability:GetManaCost(iLevel)
		if self:GetCaster():IsRealHero() then 
			return 800
		else
			return 0
		end
	end

	function ability:CastFilterResultLocation(hLocation)
	    local caster = self:GetCaster()
	    if IsServer() and not IsInSameRealm(caster:GetAbsOrigin(), hLocation) then
	        return UF_FAIL_CUSTOM
	    elseif caster:GetAbsOrigin().y < -2000 then
	    	return UF_FAIL_CUSTOM
	    else
	        return UF_SUCESS
	    end
	end

	function ability:GetCustomCastErrorLocation(hLocation)
		if self:GetCaster():GetAbsOrigin().y < -2000 then
			return "#Inside_Reality_Marble"
		end
	    return "#Wrong_Target_Location"
	end

	function ability:OnSpellStart()
		--self:GetCaster():EmitSound("atalanta_skia_channel")
		self.caster = self:GetCaster()
		local ability = self
		local masterCombo = self.caster.MasterUnit2:FindAbilityByName("atalanta_alter_skia")
		self.skia_loc = self:GetCursorPosition()
		self.fly_dur = self:GetSpecialValueFor("fly_duration")
	    masterCombo:EndCooldown()
	    masterCombo:StartCooldown(ability:GetCooldown(1))
	    self.caster:AddNewModifier(self.caster, self, "modifier_atalanta_skia_cd", {duration = ability:GetCooldown(1)})
	    
	    self.caster:FindAbilityByName(self.caster.ESkill):StartCooldown(self.caster:FindAbilityByName(self.caster.ESkill):GetCooldown(self.caster:FindAbilityByName(self.caster.ESkill):GetLevel()))
	end

	function ability:GetAOERadius()
	    return self:GetSpecialValueFor("radius")
	end

	function ability:OnChannelFinish(bInterrupted)
		if bInterrupted then
			--self:GetCaster():StopSound("atalanta_skia_channel")
			return
		end
		
		EmitGlobalSound("atalanta_skia")
		self.caster:RemoveModifierByName("modifier_atalanta_combo_window")
		self.caster:AddNewModifier(self.caster, self, "modifier_atalanta_skia", {duration = self.fly_dur})
		giveUnitDataDrivenModifier(self.caster, self.caster, "jump_pause",self.fly_dur)
		self.caster:AddNewModifier(self.caster, self, "modifier_tauropolos_alter_penalty", {duration = self.fly_dur + self:GetSpecialValueFor("r_penalty")})
		Timers:CreateTimer(1.45, function()
			LoopOverPlayers(function(player, playerID, playerHero)
		        --print("looping through " .. playerHero:GetName())
		        if playerHero.gachi == true then
		            -- apply legion horn vsnd on their client
		            CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="john_cena"})
		            --caster:EmitSound("Hero_LegionCommander.PressTheAttack")
		        end
	    	end)
		end)
	end

	function ability:GetSkiaLoc()
	    return self.skia_loc
	end
end

atalanta_skia_wrapper(atalanta_alter_skia)
atalanta_skia_wrapper(atalanta_alter_skia_upgrade)

----------------------------------------

modifier_atalanta_skia = class({})

function modifier_atalanta_skia:IsHidden() return true end

function modifier_atalanta_skia:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.target = self:GetAbility():GetSkiaLoc()
		self.time_elapsed = 0
		self.kappa = false
		self.fly_dur = self:GetAbility():GetSpecialValueFor("fly_duration")
		StartAnimation(self.parent, {duration=self.fly_dur + 0.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.3})
		self:StartIntervalThink(FrameTime())
		local ground = GetGroundPosition(self.parent:GetAbsOrigin(), self.parent)
		self.mark = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_combo_mark.vpcf", PATTACH_CUSTOMORIGIN, self.parent)
		ParticleManager:SetParticleControl(self.mark, 0, ground + Vector(0,0,50))
		ParticleManager:SetParticleControl(self.mark, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"),0,0))
	end
end

function modifier_atalanta_skia:CheckState()
    local state = { --[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    --[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    --[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    --[MODIFIER_STATE_ROOTED] = true,
                    --[MODIFIER_STATE_DISARMED] = true,
                    --[MODIFIER_STATE_SILENCED] = true,
                    --[MODIFIER_STATE_MUTED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true,
			 		[MODIFIER_STATE_NO_HEALTH_BAR]	= true,
                    [MODIFIER_STATE_STUNNED] = true
                }
    return state
end

function modifier_atalanta_skia:OnIntervalThink()
	self.time_elapsed = self.time_elapsed + FrameTime()
	if self.time_elapsed >= self.fly_dur then
		self:Destroy()
		return
	end
	if self.kappa == false then
		self.kappa = true
		local belleFxIndex = ParticleManager:CreateParticle( "particles/atalanta/rider_bellerophon_1.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.parent )
		ParticleManager:SetParticleControlEnt( belleFxIndex, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( belleFxIndex, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true )
		Timers:CreateTimer(self.fly_dur, function()
			ParticleManager:DestroyParticle( belleFxIndex, false )
			ParticleManager:ReleaseParticleIndex( belleFxIndex )
		end)
	end
	local direction = (self.target - GetGroundPosition(self.parent:GetAbsOrigin(), self.parent)):Normalized()
	local distance = (GetGroundPosition(self.parent:GetAbsOrigin(), self.parent) - self.target):Length2D()

	local old_position = self.parent:GetAbsOrigin()
	local new_position = old_position + direction*distance*FrameTime()/(self.fly_dur - self.time_elapsed)

	if self.time_elapsed < 2.15 then
		new_position = new_position + Vector(0, 0, 150)
	else
		local z_dist = self.parent:GetAbsOrigin().z - self.target.z
		new_position = new_position + Vector(0, 0, -z_dist*FrameTime()/(self.fly_dur-self.time_elapsed))
	end
	self.parent:SetAbsOrigin(new_position)
	local ground = GetGroundPosition(self.parent:GetAbsOrigin(), self.parent)
	ParticleManager:SetParticleControl(self.mark, 0, ground + Vector(0,0,50))
end

function modifier_atalanta_skia:OnDestroy()
	self.parent = self:GetParent()
	local caster = self:GetParent()

	if IsServer() then
		ParticleManager:DestroyParticle(self.mark, true)
		ParticleManager:ReleaseParticleIndex(self.mark)
	

		if caster:GetHealth() <= 1 then 
			return 0
		end

		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		if self.parent.CurseMoonAcquired then 
			self.damage = self.damage * (1 + ( self:GetAbility():GetSpecialValueFor("bonus_dmg_energy")/100 * self.parent:FindAbilityByName(self.parent.DSkill):GetEnergyStack(self.parent)))
		end

		local stacks = self:GetAbility():GetSpecialValueFor("curse_stacks")
		if self.parent:HasModifier("modifier_atalanta_evil_beast") then
	        stacks = stacks * 2
	    end

		ScreenShake(self:GetParent():GetAbsOrigin(), 20, 2.0, 3.0, 2000, 0, true)

		--self.parent:EmitSound("Misc.Crash")
		Timers:CreateTimer(0.05, function()
			FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end)
		Timers:CreateTimer(0.3, function()
			self.parent:EmitSound("atalanta_skia_pop")
		end)
		self.parent:EmitSound("atalanta_skia_pop2")

		local slam_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_skia.vpcf", PATTACH_WORLDORIGIN, self.parent )
		ParticleManager:SetParticleControl( slam_fx, 0, self.parent:GetAbsOrigin() + Vector(0,0,50))
		ParticleManager:SetParticleControl( slam_fx, 4, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))

		local hit_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_earthshock.vpcf", PATTACH_ABSORIGIN, self.parent )
		ParticleManager:SetParticleControl( hit_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hit_fx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 500, 300))
		local explodeFx1 = ParticleManager:CreateParticle("particles/atalanta/lancer_gae_bolg_hit.vpcf", PATTACH_ABSORIGIN, self.parent )
		ParticleManager:SetParticleControl( explodeFx1, 0, self.parent:GetAbsOrigin())
		local explodeFx5 = ParticleManager:CreateParticle("particles/atalanta/combo_impact_flek.vpcf", PATTACH_ABSORIGIN, self.parent )
		ParticleManager:SetParticleControl( explodeFx5, 0, self.parent:GetAbsOrigin())

		Timers:CreateTimer(3, function()
			ParticleManager:DestroyParticle( slam_fx, false )
			ParticleManager:DestroyParticle( explodeFx1, false )
			ParticleManager:DestroyParticle( hit_fx, false )
			ParticleManager:ReleaseParticleIndex(hit_fx)
			ParticleManager:ReleaseParticleIndex(slam_fx)
			ParticleManager:ReleaseParticleIndex(explodeFx1)
		end)

		local enemies = FindUnitsInRadius(  self.parent:GetTeamNumber(),
	                                            self.parent:GetAbsOrigin(), 
	                                            nil, 
	                                            self:GetAbility():GetSpecialValueFor("radius"), 
	                                            DOTA_UNIT_TARGET_TEAM_ENEMY, 
	                                            DOTA_UNIT_TARGET_ALL, 
	                                            0, 
	                                            FIND_ANY_ORDER, 
	                                            false)
		
	    for _,enemy in ipairs(enemies) do 
			enemy:RemoveModifierByName("modifier_atalanta_curse") 
			DoDamage(self.parent, enemy, self.damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
			if self.parent.CurseMoonAcquired then 
				local knockback = { should_stun = false,
		                                knockback_duration = 0.5,
		                                duration = 0.5,
		                                knockback_distance = -(enemy:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D(),
		                                knockback_height = 0,
		                                center_x = self.parent:GetAbsOrigin().x,
		                                center_y = self.parent:GetAbsOrigin().y,
		                                center_z = self.parent:GetAbsOrigin().z }
				enemy:AddNewModifier(self.parent, self:GetAbility(), "modifier_knockback", knockback)
			end
			for i = 1,stacks do
				self.parent:FindAbilityByName(self.parent.DSkill):Curse(enemy)
			end	
			enemy:AddNewModifier(self.parent, self:GetAbility(), "modifier_stunned", {Duration = self:GetAbility():GetSpecialValueFor("stun")})
	    end
	end
end

modifier_atalanta_skia_cd = class({})

function modifier_atalanta_skia_cd:GetTexture()
    return "custom/alter_atalanta/atalanta_skia"
end

function modifier_atalanta_skia_cd:IsHidden()
    return false 
end

function modifier_atalanta_skia_cd:RemoveOnDeath()
    return false
end

function modifier_atalanta_skia_cd:IsDebuff()
    return true 
end

function modifier_atalanta_skia_cd:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

---------------------------

modifier_tauropolos_alter_penalty = class({})

function modifier_tauropolos_alter_penalty:GetTexture()
    return "custom/alter_atalanta/atalanta_skia"
end

function modifier_tauropolos_alter_penalty:IsHidden()
    return false 
end

function modifier_tauropolos_alter_penalty:RemoveOnDeath()
    return false
end

function modifier_tauropolos_alter_penalty:IsDebuff()
    return true 
end

function modifier_tauropolos_alter_penalty:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end