LinkLuaModifier("modifier_mordred_rush", "abilities/mordred/mordred_rush", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_mordred_rampage", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)

mordred_rush = class({})
--mordred_rush_burst = class({})
mordred_rush_upgrade_1 = class({})
mordred_rush_upgrade_2 = class({})
mordred_rush_upgrade_3 = class({})

function mordred_rush_wrapper(ability)
    --[[function ability:OnUpgrade()
        local caster = self:GetCaster()
        if caster.RampageAcquired and caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush_burst_upgrade_3"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush_burst_upgrade_3"):SetLevel(self:GetLevel())
                end
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_3" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush"):SetLevel(self:GetLevel())
                end
            end
        elseif not caster.RampageAcquired and caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush_burst_upgrade_2"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush_burst_upgrade_2"):SetLevel(self:GetLevel())
                end
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_2" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush"):SetLevel(self:GetLevel())
                end
            end
        elseif caster.RampageAcquired and not caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush_burst_upgrade_1"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush_burst_upgrade_1"):SetLevel(self:GetLevel())
                end
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_1" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush"):SetLevel(self:GetLevel())
                end
            end
        elseif not caster.RampageAcquired and not caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush_burst"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush_burst"):SetLevel(self:GetLevel())
                end
            elseif self:GetAbilityName() == "mordred_rush_burst" then
                if self:GetLevel() ~= caster:FindAbilityByName("mordred_rush"):GetLevel() then
                    caster:FindAbilityByName("mordred_rush"):SetLevel(self:GetLevel())
                end
            end
        end
    end]]

    --[[function ability:StartCD()
        local caster = self:GetCaster()
        if caster.RampageAcquired and caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                caster:FindAbilityByName("mordred_rush_burst_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_3" then
                caster:FindAbilityByName("mordred_rush"):StartCooldown(self:GetCooldown(self:GetLevel()))
            end
        elseif not caster.RampageAcquired and caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                caster:FindAbilityByName("mordred_rush_burst_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_2" then
                caster:FindAbilityByName("mordred_rush"):StartCooldown(self:GetCooldown(self:GetLevel()))
            end
        elseif caster.RampageAcquired and not caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                caster:FindAbilityByName("mordred_rush_burst_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
            elseif self:GetAbilityName() == "mordred_rush_burst_upgrade_1" then
                caster:FindAbilityByName("mordred_rush"):StartCooldown(self:GetCooldown(self:GetLevel()))
            end
        elseif not caster.RampageAcquired and not caster.LightningOverloadAcquired then
            if self:GetAbilityName() == "mordred_rush" then
                caster:FindAbilityByName("mordred_rush_burst"):StartCooldown(self:GetCooldown(self:GetLevel()))
            elseif self:GetAbilityName() == "mordred_rush_burst" then
                caster:FindAbilityByName("mordred_rush"):StartCooldown(self:GetCooldown(self:GetLevel()))
            end
        end
    end]]

    function ability:GetAbilityTextureName()
        if self:GetCaster():HasModifier("modifier_alternate_03") then
            return "custom/mordred/mordred_rush_summer"
        else
            return "custom/mordred/mordred_rush"
        end
    end    

    function ability:GetChannelTime()
        return self:GetSpecialValueFor("cast_time")
    end

    function ability:OnSpellStart()
        --self:StartCD()
    	self.ChannelTime = 0
    	self.particle_kappa = ParticleManager:CreateParticle("particles/custom/mordred/max_excalibur/charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        self.target = self:GetCursorTarget()
    end

    function ability:OnChannelThink(fInterval)
        self.ChannelTime = self.ChannelTime + fInterval
        self:GetCaster():FaceTowards(self:GetCursorTarget():GetAbsOrigin())
    end

    function ability:OnChannelFinish(bInterrupted)
    	local caster = self:GetCaster()

    	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})

        if caster:HasModifier('modifier_alternate_02') then 
            caster:EmitSound("Mordred-Armorless-E")
        else
            caster:EmitSound("mordred_rush")
        end

    	if caster:HasModifier("pedigree_off") and caster:HasModifier("modifier_mordred_overload") then
        	local kappa = caster:FindModifierByName("modifier_mordred_overload")
        	kappa:Doom()
       	end

    	self.damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_per_second")*self.ChannelTime
    	self.speed = self:GetSpecialValueFor("speed") + self:GetSpecialValueFor("speed_per_second")*self.ChannelTime
    	caster:AddNewModifier(caster, self, "modifier_mordred_rush", {damage = self.damage,
    																	speed = self.speed,
                                                                        time = self.ChannelTime,
    																	dolbayob_factor = 0,
                                                                        Duration = 4,})
    	--[[self.range = self:GetSpecialValueFor("distance")*self.ChannelTime/2

    	local qdProjectile = 
    	{
    		Ability = self,
            EffectName = nil,
            iMoveSpeed = 1800,
            vSpawnOrigin = caster:GetOrigin(),
            fDistance = self.range,
            fStartRadius = 300,
            fEndRadius = 300,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 2.0,
    		bDeleteOnHit = false,
    		vVelocity = caster:GetForwardVector() * 1800
    	}

    	local projectile = ProjectileManager:CreateLinearProjectile(qdProjectile)
    	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 1.0)
    	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
    	local sin = Physics:Unit(caster)
    	caster:SetPhysicsFriction(0)
    	caster:SetPhysicsVelocity(caster:GetForwardVector() * 1800)
    	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

    	Timers:CreateTimer("mordred_rush", {
    		endTime = self.range/self:GetSpecialValueFor("distance"),
    		callback = function()
    		caster:OnPreBounce(nil)
    		caster:SetBounceMultiplier(0)
    		caster:PreventDI(false)
    		caster:SetPhysicsVelocity(Vector(0,0,0))
    		caster:RemoveModifierByName("pause_sealenabled")
    		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    	return end
    	})

    	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
    		Timers:RemoveTimer("mordred_rush")
    		unit:OnPreBounce(nil)
    		unit:SetBounceMultiplier(0)
    		unit:PreventDI(false)
    		unit:SetPhysicsVelocity(Vector(0,0,0))
    		caster:RemoveModifierByName("pause_sealenabled")
    		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
    	end)]]
    end
end

mordred_rush_wrapper(mordred_rush)
--mordred_rush_wrapper(mordred_rush_burst)
mordred_rush_wrapper(mordred_rush_upgrade_1)
mordred_rush_wrapper(mordred_rush_upgrade_2)
mordred_rush_wrapper(mordred_rush_upgrade_3)

--[[function mordred_rush:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget == nil then return end

	local caster = self:GetCaster()
	if self.damage == nil then self.damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_per_second")*2 end
	--print(self.damage)

	--giveUnitDataDrivenModifier(caster, hTarget, "rooted", duration)
	--giveUnitDataDrivenModifier(caster, hTarget, "locked", duration)

	DoDamage(caster, hTarget, self.damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
end]]
modifier_mordred_rush = class({})

function modifier_mordred_rush:OnCreated(hui)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
    if self.parent:HasModifier("modifier_alternate_03") then 
        self.parent:SetModel("models/mordred/summer/summer_mordred_surf_by_zefiroft.vmdl")
        self.parent:SetOriginalModel("models/mordred/summer/summer_mordred_surf_by_zefiroft.vmdl")
    end
	if IsServer() then
		if hui.dolbayob_factor == 1 then
			self.target = self.parent.debil
            self.ability = self.parent:FindAbilityByName(self.parent.ESkill)
		else
			self.target = self.ability.target
		end
		self.damage = hui.damage
		self.speed = hui.speed
        self.time = hui.time or nil
        self.targetpos = self.target:GetAbsOrigin()

		self:StartIntervalThink(FrameTime())
		if self:ApplyHorizontalMotionController() == false then
            self.parent:RemoveModifierByName("modifier_mordred_rush")
        end
	end
end

function modifier_mordred_rush:IsHidden() return true end
function modifier_mordred_rush:IsDebuff() return false end
function modifier_mordred_rush:RemoveOnDeath() return true end
function modifier_mordred_rush:GetPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_mordred_rush:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_SILENCED] = true,
                    [MODIFIER_STATE_MUTED] = true,
                    [MODIFIER_STATE_COMMAND_RESTRICTED] = true, }

    if self.target and not self.target:IsNull() and self.target:HasFlyMovementCapability() then
        state[MODIFIER_STATE_FLYING] = true
    else
        state[MODIFIER_STATE_FLYING] = false
    end
    
    return state
end
function modifier_mordred_rush:OnRefresh(hui)
    self:OnCreated(hui)
end
function modifier_mordred_rush:OnDestroy()
    if self.parent:HasModifier("modifier_alternate_03") then 
        self.parent:SetModel("models/mordred/summer/summer_mordred_by_zefiroft.vmdl")
        self.parent:SetOriginalModel("models/mordred/summer/summer_mordred_by_zefiroft.vmdl")
    end
    if IsServer() then
        self.parent:InterruptMotionControllers(true)
        if self.parent:HasModifier("jump_pause_nosilence") then
        	self.parent:RemoveModifierByName("jump_pause_nosilence")
        end

        if self.ability.particle_kappa then
            ParticleManager:DestroyParticle(self.ability.particle_kappa, false)
            ParticleManager:ReleaseParticleIndex(self.ability.particle_kappa)
        end
    end
end
function modifier_mordred_rush:UpdateHorizontalMotion(me, dt)
    local UFilter = UnitFilter( self.target,
                                self.ability:GetAbilityTargetTeam(),
                                self.ability:GetAbilityTargetType(),
                                self.ability:GetAbilityTargetFlags(),
                                self.parent:GetTeamNumber() )

    if not IsInSameRealm(self.parent:GetAbsOrigin(), self.target:GetAbsOrigin()) then 
        self.parent:RemoveModifierByName("modifier_mordred_rush")

        return nil
    end

    if UFilter ~= UF_SUCCESS then
        self.parent:RemoveModifierByName("modifier_mordred_rush")
        return nil
    end

    if (self.targetpos - self.target:GetAbsOrigin()):Length2D() > 300 then
        self.parent:RemoveModifierByName("modifier_mordred_rush")

        return nil
    end

    self.targetpos = self.target:GetAbsOrigin() 

    if (self.target:GetOrigin() - self.parent:GetOrigin()):Length2D() < 150 then
        self:BOOM()

        self.parent:RemoveModifierByName("modifier_mordred_rush")
        return nil
    end

    self:Rush(me, dt)
end
function modifier_mordred_rush:BOOM()
    local position = self.target:GetAbsOrigin()
    local damage = self.damage

    if self.parent:HasModifier("pedigree_off") and self.parent:HasModifier("modifier_mordred_overload") then
    	local kappa = self.parent:FindModifierByName("modifier_mordred_overload")
    	kappa:Doom()
   	end

   	local duck = 0
   	if self.parent.RampageAcquired then
   		duck = self:GetAbility():GetSpecialValueFor("stun")
        local dur = 4
        if self.time ~= nil then 
            dur = dur + (self.time * 2)
        end
        self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_mordred_rampage", {Duration = dur})
   	end

    local knockback = { should_stun = duck,
                        knockback_duration = 0.5,
                        duration = 1.0,
                        knockback_distance = 150,
                        knockback_height = 50,
                        center_x = self.parent:GetAbsOrigin().x,
                        center_y = self.parent:GetAbsOrigin().y,
                        center_z = self.parent:GetAbsOrigin().z }

	self.target:AddNewModifier(self.parent, self.ability, "modifier_knockback", knockback)

    local enemies = FindUnitsInRadius(  self.parent:GetTeamNumber(),
                                        position,
                                        nil,
                                        self.ability:GetSpecialValueFor("radius"),
                                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                                        DOTA_UNIT_TARGET_ALL,
                                        DOTA_UNIT_TARGET_FLAG_NONE,
                                        FIND_ANY_ORDER,
                                        false)

    local blow_fx =     ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, self.parent)
                        ParticleManager:SetParticleControl(blow_fx, 0, position)
                        ParticleManager:ReleaseParticleIndex(blow_fx)

    if self.parent:HasModifier("pedigree_off") and self.parent.RampageAcquired then
	    for _, enemy in pairs(enemies) do
	        if enemy and not enemy:IsNull() and IsValidEntity(enemy) and enemy ~= self.target and not enemy:IsMagicImmune() then
	            DoDamage(self.parent, enemy, damage, DAMAGE_TYPE_MAGICAL, 0, self.ability, false)
	        end
	    end
	end
	
	if not self.target:IsMagicImmune() then
		DoDamage(self.parent, self.target, damage, DAMAGE_TYPE_MAGICAL, 0, self.ability, false)
	end

    EmitSoundOnLocationWithCaster(position, "Archer.HruntHit", self.parent)
end
function modifier_mordred_rush:Rush(me, dt)
    --[[if self.parent:IsStunned() then
        return nil
    end]]

    if not IsInSameRealm(self.parent:GetAbsOrigin(), self.target:GetAbsOrigin()) then 
        self.parent:RemoveModifierByName("modifier_mordred_rush")
        return nil
    end

    local pos = self.parent:GetOrigin()
    local targetpos = self.target:GetOrigin()

    local direction = targetpos - pos
    direction.z = 0     
    local target = pos + direction:Normalized() * (self.speed * dt)

    self.parent:SetOrigin(target)
    self.parent:FaceTowards(targetpos)
end
function modifier_mordred_rush:OnHorizontalMotionInterrupted()
    if IsServer() then
        self.parent:RemoveModifierByName("modifier_mordred_rush")
    end
end