nobu_double_shots = class({})
nobu_double_shots_upgrade = class({})
LinkLuaModifier("modifier_nobu_turnlock", "abilities/nobu/nobu_double_shots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nobu_e_window", "abilities/nobu/nobu_double_shots", LUA_MODIFIER_MOTION_NONE)

 
function dbshot_wrapper(abil)
    function abil:OnSpellStart()
        local hCaster = self:GetCaster()
        local pID = hCaster:GetPlayerOwnerID()
        local duration = self:GetSpecialValueFor("duration")
        local aoe = self:GetSpecialValueFor("aoe")
        self.cast_range = self:GetSpecialValueFor("cast_range")
        local sps = self:GetSpecialValueFor("sps")
        local stop_delay = self:GetSpecialValueFor("delay_stop")
        Timers:RemoveTimer("nobu_shoots" .. pID)
        Timers:RemoveTimer("nobu_stop" .. pID)
        hCaster:AddNewModifier(hCaster, self, "modifier_nobu_turnlock", {duration = duration} ) 
          
        Timers:CreateTimer("nobu_stop" .. pID, {
    		endTime = stop_delay,
    		callback = function()
            hCaster:AddNewModifier(hCaster, self, "modifier_nobu_e_window", {duration = duration - stop_delay} )
            --[[if hCaster:IsAlive() and hCaster:GetAbilityByIndex(2) == self then
                hCaster:SwapAbilities("nobu_double_shots", "nobu_double_shots_stop", false, true)
                Timers:CreateTimer("nobu_stop_2", {
                    endTime = 4.5,
                    callback = function()
                    if hCaster:GetAbilityByIndex(2):GetName() == "nobu_double_shots_stop" then
                        hCaster:SwapAbilities("nobu_double_shots", "nobu_double_shots_stop", true, false)    
                    end 
                end})

            end]]
        end})
        local target = nil
        local origin_e = nil
        local direction_e = hCaster:GetForwardVector()
        if self:GetCursorTarget() ~= nil then
            target = self:GetCursorTarget()
            self.targetted = true
            self.target_enemy = target
        else
            target = self:GetCursorPosition()
            self.targetted = false
            self.target_enemy = nil
        end 

        local counter = 0
     
        --StartAnimation(hCaster, {duration= duration , activity=ACT_DOTA_CAST_ABILITY_3_END, rate= 3, bloop=true})  
           
        Timers:CreateTimer("nobu_shoots" .. pID, {
        	endTime = 0.0,
        	callback = function()
            counter = counter + 1 
            if hCaster:IsAlive() and hCaster:IsStunned() then 
                return 0.033 
            end

            if (counter >= duration * 30) or not hCaster:IsAlive() then 
                return nil 
            end

            local origin = hCaster:GetAbsOrigin()

            if IsValidEntity(self.target_enemy) then 
                if not self.target_enemy:CanEntityBeSeenByMyTeam(hCaster) then 
                    target = origin_e
                else
                    origin_e = self.target_enemy:GetAbsOrigin()
                    direction_e = (Vector(origin_e.x, origin_e.y, 0) - Vector(origin.x, origin.y, 0)):Normalized()
                end
            else
                direction_e = (Vector(target.x, target.y, 0) - Vector(origin.x, origin.y, 0)):Normalized()
            end

            hCaster:SetForwardVector(direction_e)

            if counter % (30/sps) ~= 0 then return  0.033 end -- this line to not trigger shot 

            local facing = hCaster:GetForwardVector()
            local vRightVect = hCaster:GetRightVector() 
            facing.z = 0

            if counter%20 == (30/sps) then
                hCaster:EmitSound("nobu_shoot_1")
                 
                self:Shoot({
                    Origin = origin + facing * 80 + Vector(0,0,100)+ vRightVect * 20,
                    Speed = 10000,
                    Facing = facing,
                    AoE = aoe,
                    Range = self.cast_range,
                })
            else
                hCaster:EmitSound("nobu_shoot_2")
                 
                self:Shoot({
                    Origin =  origin + facing * 80 + Vector(0,0,100) + vRightVect * -20,
                    Speed = 10000,
                    Facing = facing,
                    AoE = aoe,
                    Range = self.cast_range,
                })
            end
            
            return 0.033
        end})



            --[[if (not hCaster:IsAlive()) or  hCaster:IsStunned() then return  0.033 end
            if( counter >= duration*30) then return end
        	local origin = hCaster:GetAbsOrigin()
            if(self.target_enemy == hCaster)  then

                self.targetted = false
                self.target_enemy = nil
            end    
            if( self.targetted) then 
                if(   not  hCaster:CanEntityBeSeenByMyTeam(self.target_enemy)   ) then
                    self.targetted = false
                    target = origin_e
                    self.target_enemy = nil
                    
                else
                    origin_e = self.target_enemy:GetAbsOrigin()
                    direction_e = (Vector(origin_e.x, origin_e.y, 0) - Vector(origin.x, origin.y, 0)):Normalized()
                 
                end
            else
                direction_e = (Vector(target.x, target.y, 0) - Vector(origin.x, origin.y, 0)):Normalized()
              
            end
            hCaster:SetForwardVector(direction_e)
            if counter % 10 ~=  0 then return  0.033 end
            local facing = hCaster:GetForwardVector()
            local vRightVect = hCaster:GetRightVector() 
            facing.z = 0
            if counter%20 == 10 then
                hCaster:EmitSound("nobu_shoot_1")
                 
                self:Shoot({
                    Origin = origin + facing * 80 + Vector(0,0,100)+ vRightVect * 20,
                    Speed = 10000,
                    Facing = facing,
                    AoE = aoe,
                    Range = cast_range,
                })
            else
                hCaster:EmitSound("nobu_shoot_2")
                 
                self:Shoot({
                    Origin =  origin + facing * 80 + Vector(0,0,100) + vRightVect * -20,
                    Speed = 10000,
                    Facing = facing,
                    AoE = aoe,
                    Range = cast_range,
                })
            end
            
            return 0.033
            end})]]

      

        
        
       
       
    end

    function abil:Shoot(keys)
        local projectileTable = {
            EffectName = "particles/nobu/nobu_bullet.vpcf" ,
            Ability = self,
            vSpawnOrigin = keys.Origin,
            vVelocity = keys.Facing * keys.Speed,
            fDistance = keys.Range,
            fStartRadius = keys.AoE,
            fEndRadius = keys.AoE,
            Source = self:GetCaster(),
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            flExpireTime = GameRules:GetGameTime() + 0.33,
            
        }
        ProjectileManager:CreateLinearProjectile(projectileTable)
    end

    function abil:OnProjectileHit(target, location )
        if target == nil then
            return
        end
        local hCaster = self:GetCaster()

        local damage = hCaster:FindAbilityByName(hCaster.DSkill):GetGunsDamage() * self:GetSpecialValueFor("damage_mod")   

        if hCaster.NobuActionAcquired then
            local armor_pierce = self:GetSpecialValueFor("armor_pierce") / 100
            hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(target, self, damage * (1-armor_pierce), DAMAGE_TYPE_PHYSICAL, 0)
            hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(target, self, damage * armor_pierce, DAMAGE_TYPE_PHYSICAL, 2)

            local stun = self:GetSpecialValueFor("microstun_duration")
            local knock = self:GetSpecialValueFor("knock")
            local knockback = { should_stun = true,
                knockback_duration = stun,
                duration = stun,
                knockback_distance = knock,
                knockback_height = 0,
                center_x = hCaster:GetAbsOrigin().x,
                center_y = hCaster:GetAbsOrigin().y,
                center_z = hCaster:GetAbsOrigin().z 
            }

            target:AddNewModifier(hCaster, self, "modifier_knockback", knockback)
        else
            hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(target, self, damage, DAMAGE_TYPE_PHYSICAL, 0)
        end

        if hCaster.StrategyAcquired and hCaster.IsStrategyReady then
            hCaster:FindAbilityByName("nobu_strat"):ApplyStrategy()
        end


        target:EmitSound("nobu_shot_impact_"..math.random(1,2))

        if(hCaster.ISDOW) then
            hCaster:FindAbilityByName(hCaster.DSkill):DOWShoot()
        end
        return true 
    end
end

dbshot_wrapper(nobu_double_shots)
dbshot_wrapper(nobu_double_shots_upgrade)

modifier_nobu_turnlock = class({})

function modifier_nobu_turnlock:DeclareFunctions()
	return { MODIFIER_PROPERTY_DISABLE_TURNING, MODIFIER_EVENT_ON_ORDER ,   MODIFIER_EVENT_ON_UNIT_MOVED,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION, 
	MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE			}
end

function modifier_nobu_turnlock:OnUnitMoved( args )
	if self.position then
        local origin_diff = args.new_pos- self.position
        local origin_diff_norm = origin_diff:Normalized()
        if self:GetCaster():GetForwardVector():Dot(origin_diff_norm) < -0.5 then
            self.movementslowed = -40
        elseif self:GetCaster():GetForwardVector():Dot(origin_diff_norm) < 0 then
            self.movementslowed = -15
        else
            self.movementslowed = 0
        end
    end
    self.position  = self:GetCaster():GetAbsOrigin()
end
function modifier_nobu_turnlock:GetModifierMoveSpeedBonus_Percentage()
	return   self.movementslowed
end

function modifier_nobu_turnlock:GetOverrideAnimation()
    return  ACT_DOTA_CAST_ABILITY_3_END
end 

function modifier_nobu_turnlock:GetOverrideAnimationRate()
    return  3.0
end 

function modifier_nobu_turnlock:OnOrder(args)
    if args.unit ~= self:GetParent() then return end
 
	if( args.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET ) then
       
		self:GetAbility().target_enemy = args.target
		self:GetAbility().targetted = true
    else 
        if (args.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE) then
            if(args.target ~= nil) then
                self:GetAbility().target_enemy = args.target
                self:GetAbility().targetted = true
                 
            else
              
                local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),  self:GetCaster():GetAbsOrigin(), nil, self:GetAbility().cast_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
                if( targets[1] ~= nil and  self:GetCaster():CanEntityBeSeenByMyTeam(targets[1]) ) then
                    self:GetAbility().target_enemy = targets[1]
                    self:GetAbility().targetted = true
                end    
            end
        end
    end
end
 

function modifier_nobu_turnlock:IsHidden() return false end
function modifier_nobu_turnlock:RemoveOnDeath() return true end
function modifier_nobu_turnlock:IsDebuff() return true end
 
function modifier_nobu_turnlock:GetModifierDisableTurning()
	return 1
end
 
function modifier_nobu_turnlock:CheckState()
    local state =   { 
                        
                        [MODIFIER_STATE_DISARMED] = true,
   
                    }
    return state
end

modifier_nobu_e_window = class({})

function modifier_nobu_e_window:IsHidden()
    return true 
end

function modifier_nobu_e_window:OnCreated(args)
    if IsServer() then
        local caster = self:GetParent()
        if caster:GetAbilityByIndex(2):GetName() == caster.ESkill then
            caster:SwapAbilities(caster.ESkill, "nobu_double_shots_stop", false, true)
        end
    end
end

function modifier_nobu_e_window:OnRefresh(args)
    self:OnCreated(args)
end

function modifier_nobu_e_window:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        --EndAnimation(caster)
        if caster:GetAbilityByIndex(2):GetName() == "nobu_double_shots_stop" then
            caster:SwapAbilities(caster.ESkill, "nobu_double_shots_stop", true, false)
        end
    end
end

function modifier_nobu_e_window:RemoveOnDeath()
    return true
end

function modifier_nobu_e_window:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
