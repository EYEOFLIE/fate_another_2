
ishtar_combo = class({})
ishtar_combo_beam = class({})
modifier_ishtar_combo_walk = class({})
modifier_ishtar_combo_cast = class({})
modifier_ishtar_combo_vision = class({})
modifier_ishtar_combo_thinker = class({})
modifier_ishtar_combo_camera = class({})
modifier_ishtar_combo_cooldown = class({})
LinkLuaModifier("modifier_ishtar_combo_walk", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ishtar_combo_cast", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_combo_vision", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_combo_thinker", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_combo_camera", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ishtar_combo_cooldown", "abilities/ishtar/ishtar_combo_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_vision", "abilities/jeanne/modifiers/modifier_jeanne_vision", LUA_MODIFIER_MOTION_NONE)

function ishtar_combo:GetBehavior()
	if self:GetCaster():IsRealHero() then 
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_HIDDEN
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function ishtar_combo:GetManaCost(iLevel)
	if self:GetCaster():IsRealHero() then 
		return 800
	else
		return 0
	end
end

function ishtar_combo:CastFilterResult()
	local caster = self:GetCaster()
	if caster:GetAbsOrigin().y < -2000 then
	    return UF_FAIL_CUSTOM
	else
	    return UF_SUCESS
	end
end

function ishtar_combo:GetCustomCastError()
	return "#Inside_Reality_Marble"
end

function ishtar_combo:GetGemConsume()
	local caster = self:GetCaster()
	local gem_consume = 0
	if caster:HasModifier("modifier_ishtar_gem_consume") then 
		local gem = caster:GetModifierStackCount("modifier_ishtar_gem", caster) or 0
		gem_consume = gem
		caster:FindAbilityByName(caster.DSkill):AddGem(-gem)
	end
	return gem_consume
end

function ishtar_combo:OnSpellStart()
	self.caster = self:GetCaster()
	self.origin = self.caster:GetAbsOrigin()
	self.player = self.caster:GetPlayerOwner()
	local masterCombo = self.caster.MasterUnit2:FindAbilityByName("ishtar_combo")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(self:GetCooldown(1))
	self.caster:RemoveModifierByName("modifier_ishtar_combo_window")
	self.caster:AddNewModifier(self.caster, self, "modifier_ishtar_combo_cooldown", {duration = self:GetCooldown(1)})

	self.aoe = self:GetSpecialValueFor("aoe")
	self.damage = self:GetSpecialValueFor("damage")
	local c_gem = self.caster:FindAbilityByName(self.caster.FSkill)
	self.gem_damage = c_gem:GetSpecialValueFor("CDamage")
	self.dps = self:GetSpecialValueFor("dps")
	self.dps_duration = self:GetSpecialValueFor("dps_duration")
	self.speed = 10000
	self.gem_consume = self:GetGemConsume()
	self.bonus_damage = self.gem_damage * self.gem_consume
	self.beam = self.caster:FindAbilityByName("ishtar_combo_beam")

	self.walk_distance = 300
	self.orb_charge = 2
	self.portal_in_loc = GetRotationPoint(self.caster:GetAbsOrigin(), self.walk_distance, self.caster:GetAnglesAsVector().y)
	self.center_map = Vector(0,2000,1000)
	if not string.match(GetMapName(), "fate_elim") then 
		self.center_map = Vector(0,2500,1000)
	end

	self.base_camera = Convars:GetInt("dota_camera_distance") or 1900
    self.bonus_camera = 100
    self.current_camera = Convars:GetInt("dota_camera_distance") or 1900

	giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealdisabled", self:GetSpecialValueFor("delay_before_tele") + 0.1)
	self.caster:AddNewModifier(self.caster, self, "modifier_ishtar_combo_walk", {duration = self:GetSpecialValueFor("delay_before_tele")})

	self.portal_in_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/portal/ishtar_portal.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.portal_in_fx, 0, self.portal_in_loc)	

	EmitGlobalSound("Ishtar.ComboStart")

	Timers:CreateTimer(self:GetSpecialValueFor("delay_before_tele")/2, function()
		if self.caster:IsAlive() then
			self.portal_out_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/portal/ishtar_portal.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
			ParticleManager:SetParticleControl(self.portal_out_fx, 0, self.center_map)	
		end
	end)

	Timers:CreateTimer(self:GetSpecialValueFor("delay_before_tele"), function()
		self.caster:RemoveModifierByName("modifier_ishtar_combo_walk")
		if self.caster:IsAlive() then 
			
			for i=2, 13 do
				if self.caster:GetTeamNumber() ~= i then
					AddFOWViewer(i, self.center_map, 500, self:GetSpecialValueFor("cast"), false)
				end
			end
			AddFOWViewer(self.caster:GetTeamNumber(), self.center_map, 10000, self:GetSpecialValueFor("cast") - 1, false)
			self.channel_dummy = self.caster:FindAbilityByName("ishtar_combo_dummy")
			self.channel_dummy:SetChanneling(true)
			
			EmitGlobalSound("Ishtar.ComboTeleport")
			self.caster:SetOrigin(self.center_map)

			giveUnitDataDrivenModifier(self.caster, self.caster, "jump_pause", self:GetSpecialValueFor("cast"))
			self.caster:AddNewModifier(self.caster, self, "modifier_ishtar_combo_cast", {duration = self:GetSpecialValueFor("cast") + 0.5})
			self.caster:AddNewModifier(self.caster, self, "modifier_ishtar_combo_vision", {duration = self:GetSpecialValueFor("reveal")})
			StartAnimation(self.caster, {duration=self.orb_charge, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.0})
			Timers:CreateTimer(0.1, function()
				self:ZoomOut()
				self.hand_fx1 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/ishtar_hand_yellow_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControlEnt(self.hand_fx1, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin() + Vector(0,0,50), false)
				ParticleManager:SetParticleControlEnt(self.hand_fx1, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin() + Vector(0,0,50), false)
			end)
			Timers:CreateTimer(self.orb_charge, function()
				EmitGlobalSound("Ishtar.Combo2")
				ParticleManager:DestroyParticle(self.hand_fx1, true)
				ParticleManager:ReleaseParticleIndex(self.hand_fx1)
				StartAnimation(self.caster, {duration=self:GetSpecialValueFor("cast") - self.orb_charge + 0.5, activity=ACT_DOTA_CAST_ABILITY_5, rate=1.0})
				self.charge_fx1 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControl(self.charge_fx1, 0, self.caster:GetAbsOrigin())
				self.charge_fx2 = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_cast_gather2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControl(self.charge_fx2, 0, self.caster:GetAbsOrigin())
				self.charge_arrow_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar-r/r_combo_model.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControlEnt(self.charge_arrow_fx, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_arrow", self.caster:GetAbsOrigin(), false)
				self.ring_fx = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/ishtar_combo_ring.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
				ParticleManager:SetParticleControlEnt(self.ring_fx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), false)
			end)
			Timers:CreateTimer(self.orb_charge + 1.0, function() 
				EmitGlobalSound("Ishtar.RComboChargeSFXOuter")
				FreezeAnimation(self.caster)
			end)
			Timers:CreateTimer(4.5, function()
				ParticleManager:DestroyParticle(self.charge_fx1, true)
				ParticleManager:ReleaseParticleIndex(self.charge_fx1)
				ParticleManager:DestroyParticle(self.charge_fx2, true)
				ParticleManager:ReleaseParticleIndex(self.charge_fx2)
				ParticleManager:DestroyParticle(self.charge_arrow_fx, true)
				ParticleManager:ReleaseParticleIndex(self.charge_arrow_fx)
				ParticleManager:DestroyParticle(self.ring_fx, true)
				ParticleManager:ReleaseParticleIndex(self.ring_fx)
				EmitGlobalSound("Ishtar.ComboLaunch")
				UnfreezeAnimation(self.caster)
				Timers:CreateTimer(0.2, function()
					EmitGlobalSound("Ishtar.ComboCharging")
				end)
			end)
		end
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle(self.portal_in_fx, false)
			ParticleManager:DestroyParticle(self.portal_out_fx, false)
			ParticleManager:ReleaseParticleIndex(self.portal_in_fx)
			ParticleManager:ReleaseParticleIndex(self.portal_out_fx)
		end)

		Timers:CreateTimer(self:GetSpecialValueFor("cast"), function()
			if self.caster:IsAlive() then 

				EmitGlobalSound("Ishtar.ComboJabalLaunch")

				EmitGlobalSound("Ishtar.Shoot")
				EmitGlobalSound("Ishtar.ComboShoot")
				EmitGlobalSound("Ishtar.ComboShoot2")


				self.target_loc = self.beam.target_loc or self.beam:GetTargetLoc(self.caster) 
				if self.target_loc.y < -2000 then 
					self.target_loc = self.beam:GetTargetLoc(self.caster)
				end
				local distance = (self.target_loc - self.caster:GetOrigin()):Length2D()
				local direction = (Vector(self.target_loc.x, self.target_loc.y, 0) - Vector(self.caster:GetOrigin().x, self.caster:GetOrigin().y, 0)):Normalized()
				self.caster:SetForwardVector(direction)
				self.throw_particle = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/projectile/ishtar_projectile_main_main.vpcf", PATTACH_WORLDORIGIN, self.caster)
				--ParticleManager:SetParticleControlEnt(self.throw_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_arrow", self.caster:GetAbsOrigin(), false)
				ParticleManager:SetParticleControl(self.throw_particle, 0, self.caster:GetOrigin() + Vector(0,0,300))
				ParticleManager:SetParticleControl(self.throw_particle, 1, self.target_loc)
				ParticleManager:SetParticleControl(self.throw_particle, 2, Vector(self.speed,0,0))

				self.throw_particle2 = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/r_combo_model_jump.vpcf", PATTACH_WORLDORIGIN, self.caster)
				ParticleManager:SetParticleControl(self.throw_particle2, 0, self.caster:GetOrigin())
				ParticleManager:SetParticleControl(self.throw_particle2, 1, (self.target_loc - self.caster:GetOrigin()):Normalized() * (self.speed - 100))
				ParticleManager:SetParticleControl(self.throw_particle2, 9, self.caster:GetOrigin())

				self.channel_dummy:EndChannel(true)
				self.channel_dummy:SetChanneling(false)

				Timers:CreateTimer(distance/self.speed, function()
					ParticleManager:DestroyParticle(self.throw_particle, false)
					ParticleManager:ReleaseParticleIndex(self.throw_particle)
					ParticleManager:DestroyParticle(self.throw_particle2, false)
					ParticleManager:ReleaseParticleIndex(self.throw_particle2)

					local pcExplosion = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/impact/ishtar_combo_impact.vpcf", PATTACH_WORLDORIGIN, self.caster)
		    		ParticleManager:SetParticleControl(pcExplosion, 0, self.target_loc + Vector(0,0,50))
		    		ParticleManager:SetParticleControl(pcExplosion, 1, self.target_loc + Vector(0,0,50))
		    		ParticleManager:SetParticleControl(pcExplosion, 3, self.target_loc + Vector(0,0,50))

					EmitGlobalSound("Ishtar.ComboImpact1")
					EmitGlobalSound("Ishtar.ComboImpact2")
					EmitGlobalSound("Ishtar.ComboImpact3")
					EmitGlobalSound("Ishtar.ComboImpact4")

					Timers:CreateTimer(0.23, function()
						EmitGlobalSound("Ishtar.ComboImpactOuter")
						ParticleManager:DestroyParticle(pcExplosion, false)
						ParticleManager:ReleaseParticleIndex(pcExplosion)
						local origin = self:GetOriginLoc()
						self.portal_in_fx2 = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
						ParticleManager:SetParticleControl(self.portal_in_fx2, 2, self.caster:GetOrigin())	
						self.portal_out_fx2 = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
						ParticleManager:SetParticleControl(self.portal_out_fx2, 2, origin)	
					end)

					local target_area = FindUnitsInRadius(self.caster:GetTeam(), self.target_loc, nil, self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
					for k,v in pairs(target_area) do 
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
							DoDamage(self.caster, v, self.damage + self.bonus_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
						end
					end
					CreateModifierThinker(self.caster, self, "modifier_ishtar_combo_thinker", { Duration = self.dps_duration,
																						 Damage = self.dps,
																						 Radius = self.aoe}
																						, self.target_loc, self.caster:GetTeamNumber(), false)
					Timers:CreateTimer(0.5, function()
						EmitGlobalSound("Ishtar.ComboTeleport")
						self:ZoomIn()
						--self.caster:SetAbsOrigin(self:GetOriginLoc())
						FindClearSpaceForUnit(self.caster,self:GetOriginLoc(), true)
						self.caster:AddNewModifier(self.caster, nil, "modifier_camera_follow", {duration = 1.0})
					end)
				end)
			end


		end)
	end)

end

if IsServer() then
	function ishtar_combo:ZoomOut()
		local count_tick = 0
	    local max_tick = 10

	    --[[LoopOverPlayers(function(player, playerID, playerHero)
	        if playerHero:GetTeamNumber() ~= self.caster:GetTeamNumber() and playerHero:IsAlive() and not playerHero:IsInvisible() then
	        	playerHero:AddNewModifier(self.caster, self, "modifier_jeanne_vision", { Duration = self:GetSpecialValueFor("reveal") })
	        end
	    end)]]

	    if not string.match(GetMapName(), "fate_elim") then return end
	    if self.CameraTimerDown ~= nil then 
	        Timers:RemoveTimer(self.CameraTimerDown)
	        self.CameraTimerDown = nil
	    end

	    if self.caster:IsAlive() then 
	        self.CameraTimerUp = Timers:CreateTimer(function()
	            if not self.caster:IsAlive() then 
	                CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.base_camera} )
	                return nil 
	            end
	            if count_tick == max_tick then 
	                return nil 
	            end
	            self.current_camera = math.min(self.current_camera + self.bonus_camera, 1900 + (max_tick * self.bonus_camera))
	            CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.current_camera} )
	            count_tick = count_tick + 1
	            return 0.033
	        end)
	    else
	        CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.base_camera} )
	    end

	end

	function ishtar_combo:ZoomIn()
		local count_tick = 0
	    local max_tick = 10

	    if not string.match(GetMapName(), "fate_elim") then return end
	    if self.CameraTimerUp ~= nil then 
	        Timers:RemoveTimer(self.CameraTimerUp)
	        self.CameraTimerUp = nil
	    end

	    if self.caster:IsAlive() then 
	        self.CameraTimerDown = Timers:CreateTimer(function()
	            if not self.caster:IsAlive() then 
	                CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.base_camera} )
	                return nil 
	            end
	            if count_tick == max_tick then 
	                return nil 
	            end
	            self.current_camera = math.max(self.current_camera - self.bonus_camera, 1900)
	            CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.current_camera} )
	            count_tick = count_tick + 1
	            return 0.033
	        end)
	    else
	        CustomGameEventManager:Send_ServerToPlayer( self.player, "cam_distance", {camera= self.base_camera} )
	    end

	end
end

function ishtar_combo:GetOriginLoc()
	return self.origin
end

-------------------------------------

function ishtar_combo_beam:GetCastAnimation()
	return nil 
end

function ishtar_combo_beam:CastFilterResultLocation(hLocation)
	if IsServer() then
		local caster = self:GetCaster()
		if IsServer() and not IsInSameRealm(caster:GetAbsOrigin(), hLocation) then
		    return UF_FAIL_CUSTOM
		else
		    return UF_SUCESS
		end
	end
end

function ishtar_combo_beam:GetCustomCastErrorLocation(hLocation)
	return "#Cannot_Target_Reality_Marble"
end

function ishtar_combo_beam:GetAOERadius()
	return 800
end

function ishtar_combo_beam:OnSpellStart()
	print('combo beam actived')
	self.caster = self:GetCaster()
	self.target_loc = self:GetCursorPosition()
	self:SetTargetLoc(self.target_loc)
	--print('combo loc ' .. self.target_loc)
end

function ishtar_combo_beam:GetCastRange(vLocation, hTarget)
	return 10000
end

function ishtar_combo_beam:SetTargetLoc(vLocation)
	self.caster.combo_loc = vLocation
	self.caster:RemoveModifierByName("modifier_ishtar_combo_vision")
	print('register combo location')
end

function ishtar_combo_beam:GetTargetLoc(hCaster)
	if hCaster.combo_loc == nil then 
		local enemies_hero = FindUnitsInRadius(hCaster:GetTeam(), Vector(0,0,0), nil, 10000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		local i = 1
		while i <= #enemies_hero do
			if IsValidEntity(enemies_hero[i]) and not enemies_hero[i]:IsNull() then
				if enemies_hero[i]:GetAbsOrigin().y < 2000 or not enemies_hero[i]:IsAlive() then 
					table.remove(enemies_hero, i)
					i = i - 1
				end
			end
			i = i + 1
		end
		if #enemies_hero >= 1 then
			local random = RandomInt(1, #enemies_hero)
			hCaster.combo_loc = enemies_hero[random]:GetAbsOrigin()
		else
			hCaster.combo_loc = hCaster:FindAbilityByName(hCaster.ComboSkill):GetOriginLoc()
		end
	end
	return hCaster.combo_loc
end

------------------------------

function modifier_ishtar_combo_walk:IsHidden() return true end
function modifier_ishtar_combo_walk:IsDebuff() return false end
function modifier_ishtar_combo_walk:IsPurgable() return false end
function modifier_ishtar_combo_walk:RemoveOnDeath() return true end
function modifier_ishtar_combo_walk:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_combo_walk:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_ishtar_combo_walk:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_ishtar_combo_walk:GetOverrideAnimation()
	return ACT_DOTA_RUN 
end

function modifier_ishtar_combo_walk:OnCreated(args)
	self.caster = self:GetParent()
	if IsServer() then 
		self.walk_duration = self:GetAbility():GetSpecialValueFor("delay_before_tele") 
		self.distance = self:GetAbility().walk_distance
		self.elapsedTime = 0
		self.speed = self.distance / self.walk_duration
		self.portal_in_loc = self:GetAbility().portal_in_loc
		if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end

function modifier_ishtar_combo_walk:UpdateHorizontalMotion(me, dt)

	if not self.caster:IsAlive() then 
		self:Destroy()
        return nil
    end

  	if (self.caster:GetOrigin() - self.portal_in_loc):Length2D() < 50 then
        self:Destroy()
        return nil
    end

    local pos = self.caster:GetOrigin()
    local direction = self.portal_in_loc - pos
    direction.z = 0     
    local target = pos + direction:Normalized() * (self.speed * dt)

    self.caster:SetOrigin(target)

    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime >= self.walk_duration then 
    	self:Destroy()
        return nil
    end
end

--------------------------------------

function modifier_ishtar_combo_vision:IsHidden() return true end
function modifier_ishtar_combo_vision:IsDebuff() return false end
function modifier_ishtar_combo_vision:IsPurgable() return false end
function modifier_ishtar_combo_vision:RemoveOnDeath() return true end
function modifier_ishtar_combo_vision:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_ishtar_combo_vision:OnCreated(args)
		self.caster = self:GetParent()
		self.caster:SwapAbilities(self.caster.RSkill, "ishtar_combo_beam", false, true)
		--self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ishtar_combo_camera", {duration = 1.0, ZoomOut = 1, camera = 1900})
	end

	function modifier_ishtar_combo_vision:OnDestroy()
		self.caster:SwapAbilities(self.caster.RSkill, "ishtar_combo_beam", true, false)
		--self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ishtar_combo_camera", {duration = 1.0, ZoomOut = -1, camera = 2400})
	end
end

------------------------------------------------

function modifier_ishtar_combo_camera:IsHidden() return true end
function modifier_ishtar_combo_camera:IsDebuff() return false end
function modifier_ishtar_combo_camera:IsPurgable() return false end
function modifier_ishtar_combo_camera:RemoveOnDeath() return true end
function modifier_ishtar_combo_camera:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--[[function modifier_ishtar_combo_camera:OnCreated(args)
	self.caster = self:GetParent()
	if IsServer() then
		self.pID = args.pID
		print('player id ' .. self.pID)
	    self.ply = PlayerResource:GetPlayer(self.pID)
		self.count_tick = 0
	    self.max_tick = 10
		self.base_camera = 1900
	    self.bonus_camera = 100
	    self.current_camera = args.camera
	    self:StartIntervalThink(0.34)
	    self.ZoomOut = args.ZoomOut
	end
end

function modifier_ishtar_combo_camera:OnIntervalThink()
	if self.count_tick >= self.max_tick then 
		self:Destroy()
	end
	if self.ZoomOut == 1 then
		self.current_camera = math.min(self.current_camera + (self.bonus_camera * self.ZoomOut), self.base_camera + (self.max_tick * self.bonus_camera))
	else
		self.current_camera = math.max(self.current_camera - self.bonus_camera, self.base_camera)
	end
    CustomGameEventManager:Send_ServerToPlayer( self.ply, "cam_distance", {camera= self.current_camera} )

	self.count_tick = self.count_tick + 1 
end]]

-------------------------------------------

function modifier_ishtar_combo_cast:IsHidden() return false end
function modifier_ishtar_combo_cast:IsDebuff() return false end
function modifier_ishtar_combo_cast:IsPurgable() return false end
function modifier_ishtar_combo_cast:RemoveOnDeath() return true end
function modifier_ishtar_combo_cast:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ishtar_combo_cast:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,}
end

function modifier_ishtar_combo_cast:OnCreated(args)
	--[[self.caster = self:GetParent()
	self.aoe = self:GetAbility():GetSpecialValueFor("aoe")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.gem_damage = self:GetAbility():GetSpecialValueFor("gem_damage")
	self.dps = self:GetAbility():GetSpecialValueFor("dps")
	self.dps_duration = self:GetAbility():GetSpecialValueFor("dps_duration")
	self.speed = 10000
	self.gem_consume = self:GetAbility():GetGemConsume()
	self.bonus_damage = self.gem_damage * self.gem_consume]]
end

function modifier_ishtar_combo_cast:OnDestroy()
	--[[if self.caster:IsAlive() then 
		self.target_loc = self:GetAbility():GetTargetLoc()
		local distance = (self.target_loc - self.caster:GetOrigin()):Length2D()

		self.throw_particle = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/projectile/ishtar_projectile_main_main.vpcf", PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(self.throw_particle, 0, self.caster:GetOrigin())
		ParticleManager:SetParticleControl(self.throw_particle, 1, (self.target_loc - self.caster:GetOrigin()):Normalized() * self.speed)
		ParticleManager:SetParticleControl(self.throw_particle, 9, self.caster:GetOrigin())

		Timers:CreateTimer(distance/self.speed, function()
			ParticleManager:DestroyParticle(self.throw_particle, false)
			ParticleManager:ReleaseParticleIndex(self.throw_particle)

			local pcExplosion = ParticleManager:CreateParticle("particles/ishtar/ishtar_combo/impact/ishtar_combo_impact.vpcf", PATTACH_WORLDORIGIN, nil)
    		ParticleManager:SetParticleControl(pcExplosion, 0, self.target_loc)

			EmitGlobalSound("Ishtar.ComboImpact1")
			EmitGlobalSound("Ishtar.ComboImpact2")
			EmitGlobalSound("Ishtar.ComboImpact3")
			EmitGlobalSound("Ishtar.ComboImpact4")

			Timers:CreateTimer(0.23, function()
				EmitGlobalSound("Ishtar.ComboImpactOuter")
				ParticleManager:DestroyParticle(pcExplosion, false)
				ParticleManager:ReleaseParticleIndex(pcExplosion)
				local origin = self:GetAbility():GetOriginLoc()
				self.portal_in_fx2 = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
				ParticleManager:SetParticleControl(self.portal_in_fx2, 2, self.caster:GetOrigin())	
				self.portal_out_fx2 = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_darkrift_end_lensflare.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
				ParticleManager:SetParticleControl(self.portal_out_fx2, 2, origin)	
			end)

			local target_area = FindUnitsInRadius(self.caster:GetTeam(), self.target_loc, nil, self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(target_area) do 
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
					DoDamage(self.caster, v, self.damage + self.bonus_damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				end
			end
			CreateModifierThinker(self.caster, self:GetAbility(), "modifier_ishtar_combo_thinker", { Duration = self.dps_duration,
																				 Damage = self.dps,
																				 Radius = self.aoe}
																				, self.target_loc, self.caster:GetTeamNumber(), false)
			Timers:CreateTimer(0.5, function()
				EmitGlobalSound("Ishtar.ComboTeleport")
				self.caster:AddNewModifier(self.caster, nil, "modifier_camera_follow", {duration = 1.0})
				self.caster:SetAbsOrigin(self:GetAbility():GetOriginLoc())
			end)
		end)
	end]]
end

----------------------

if IsServer() then
	function modifier_ishtar_combo_thinker:OnCreated(args)
		self.caster = self:GetCaster()
		self.dps = self:GetAbility():GetSpecialValueFor("dps") * 0.5
		self.aoe = self:GetAbility():GetSpecialValueFor("aoe")

		self.ThinkCount = 0

		self:StartIntervalThink(0.48)
	end

	function modifier_ishtar_combo_thinker:OnIntervalThink()

		local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

		for k,v in pairs(targets) do 
			if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then 
				DoDamage(self.caster, v, self.dps, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
			end
		end

		self.ThinkCount = self.ThinkCount + 1

		if self.ThinkCount >= 5 then
			self:Destroy()
		end
	end
end

---------------------------------------

function modifier_ishtar_combo_cooldown:IsHidden() return false end
function modifier_ishtar_combo_cooldown:IsDebuff() return true end
function modifier_ishtar_combo_cooldown:IsPurgable() return false end
function modifier_ishtar_combo_cooldown:RemoveOnDeath() return false end
function modifier_ishtar_combo_cooldown:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end









