nobu_3000 = class({})
nobu_3000_upgrade = class({})

function nobu_3000_wrapper(ability)
    function ability:OnSpellStart()
        self.ChannelTime = 0
        self.caster = self:GetCaster()
        self.particle_kappa = ParticleManager:CreateParticle("particles/nobu/3000-charge.vpcf", PATTACH_ABSORIGIN_FOLLOW,  self.caster)
       
        self.rightvec = self.caster:GetRightVector()
        self.leftvec = self.caster:GetLeftVector()
        self.target = self:GetCursorPosition()
        EmitGlobalSound("nobu_ulti_cast")
        if(self.dummies == nil) then
            self.dummies = {}
        end
        if self.caster:HasModifier("modifier_nobu_turnlock") then
            Timers:RemoveTimer("nobu_shoots")
            self.caster:RemoveModifierByName("modifier_nobu_turnlock")
            self.caster:StopAnimation()
            self.caster:RemoveModifierByName("modifier_nobu_e_window")
            --StartAnimation(  self.caster, {duration= 1 , activity=ACT_DOTA_CAST_ABILITY_4, rate= 1})
        end
        if( self.dummies ~= {}) then
            for i = 1, #self.dummies do
                if(self.dummies[i] ~= nil) then
                 ParticleManager:DestroyParticle( self.dummies[i].GunFx, true)
                 ParticleManager:ReleaseParticleIndex(self.dummies[i].GunFx)
                
                 self.dummies[i]:RemoveSelf()
                 self.dummies[i] = nil
                end 
            end
            self.dummies = {}
        end
        
        for i=1,5 do 
            local gun_spawn = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() *RandomInt(-200,200)
            local random1 = RandomInt(0, 300) -- position of gun spawn
            local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero
            local random3 = RandomInt(25,200)*Vector(0,0,1) 
             

            if random2 == 0 then 
                gun_spawn = gun_spawn + self.leftvec * random1 + random3
            else 
                gun_spawn = gun_spawn + self.rightvec * random1 + random3
            end
            self:CreateGun(gun_spawn) 
        end
    end

    function ability:CastFilterResultLocation(vLocation)
        local caster = self:GetCaster()
        if IsServer() and  caster:FindModifierByName("modifier_nobu_turnlock") then
            return UF_FAIL_CUSTOM
        else
            return UF_SUCESS
        end
    end

    function ability:GetCustomCastErrorLocation(vLocation)
        return "Can not be used while shooting"
    end

     
    function ability:OnChannelThink(fInterval)
        self.ChannelTime = self.ChannelTime + fInterval
        if(self.ChannelTime >= 0.06) then
     
            local gun_spawn = self.caster:GetAbsOrigin() + self.caster:GetForwardVector()*RandomInt(-200,200)
            local random1 = RandomInt(0, 300) -- position of gun spawn
            local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero
            local random3 = RandomInt(25,200)*Vector(0,0,1) --  
            

            if random2 == 0 then 
                gun_spawn = gun_spawn + self.leftvec * random1 + random3
            else 
                gun_spawn = gun_spawn + self.rightvec * random1 + random3
            end
            self:CreateGun(gun_spawn)
            self.ChannelTime = self.ChannelTime - 0.06
           
        end
        self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + Vector(0,0,2))
        self.caster:FaceTowards(self.target)

        return true
    end
     

    function ability:OnChannelFinish(bInterrupted)
        local vCasterOrigin = self.caster:GetAbsOrigin()
        local vCasterFW = self.caster:GetForwardVector()
        --self.caster:AddNewModifier(self.caster, self, "modifier_merlin_self_pause", {Duration = 0.3}) 
        giveUnitDataDrivenModifier(self.caster, self.caster, "pause_sealdisabled", 0.5)
        ParticleManager:DestroyParticle( self.particle_kappa, false)
        ParticleManager:ReleaseParticleIndex( self.particle_kappa)
        StartAnimation( self.caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})
        local aoe = self:GetSpecialValueFor("aoe")
        local range = self:GetSpecialValueFor("range")
        local position = self:GetCursorPosition()
        self.caster:StopSound("nobu_ulti_cast")
        EmitGlobalSound("nobu_ulti_end") 
        Timers:CreateTimer(0.15, function()
            local facing =  self.caster:GetForwardVector()
            facing.z = 0
            self:Shoot({
                Origin =  vCasterOrigin + vCasterFW * 120 + Vector(0,0,150),
                Speed = 10000,
                Facing = facing,
                AoE = aoe,
                Range = range,
            })
            Timers:CreateTimer(0.08, function()
                self.caster:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin(),self.caster))

            end)
            
            for i = 1, #self.dummies do
                if(self.dummies[i] == nil ) then return end
                Timers:CreateTimer(0.0165 * i, function()
                    if(self.dummies[i] == nil ) then return end
                    --local facing =  self.dummies[i]:GetForwardVector()
                    --facing.z = 0
                    if(self.caster.is3000Acquired) then
                        self.dummies[i]:EmitSound("nobu_shoot_laser")
                    else
                        self.dummies[i]:EmitSound("nobu_shoot_multiple_"..math.random(1,2))
                    end
                   
                self:Shoot({
                    Origin = self.dummies[i]:GetAbsOrigin()+vCasterFW*80,
                    Speed = 10000,
                    Facing =  facing,
                    AoE = aoe,
                    Range = range,
                })
                ParticleManager:DestroyParticle( self.dummies[i].GunFx, false)
                ParticleManager:ReleaseParticleIndex(self.dummies[i].GunFx)
                
                self.dummies[i]:RemoveSelf()
                self.dummies[i] = nil
                end)
        
            end
        end)
      
        
     
         
    end
    function ability:CreateGun(position)
        local vCasterOrigin = self.caster:GetAbsOrigin()
         --print(vCasterOrigin)
        self.Dummy = CreateUnitByName("dummy_unit", position, false, nil, nil, self.caster:GetTeamNumber())
        self.Dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
        self.Dummy:SetAbsOrigin(position)
     
        vCasterOrigin.z = 0
        local fwtarget =  self.target- vCasterOrigin 
        
         self.Dummy:SetForwardVector((fwtarget ):Normalized())
         --print((  self.target- vCasterOrigin ):Normalized())
         
        --self.Dummy:SetForwardVector(vCasterOrigin - self.Dummy:GetAbsOrigin())
        local GunFx
        if(self.caster.is3000Acquired) then
            GunFx = ParticleManager:CreateParticle( "particles/nobu/gun_no_destroy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.Dummy )
        else
            GunFx = ParticleManager:CreateParticle( "particles/nobu/gun.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.Dummy )
        end
        
         ParticleManager:SetParticleControl(GunFx, 3, position ) 
         ParticleManager:SetParticleControl(GunFx, 4, fwtarget ) 
        self.Dummy.GunFx = GunFx
        table.insert(self.dummies, self.Dummy)
        Timers:CreateTimer(3.2, function()
            ParticleManager:DestroyParticle(GunFx, true)
            ParticleManager:ReleaseParticleIndex(GunFx)
        end)
    end

    function ability:Shoot(keys)
        local projectileTable = {}
        if(self.caster.is3000Acquired) then
            --[[
              projectileTable = {
                EffectName = "particles/nobu/nobu_lasers.vpcf" ,
                Ability = self,
                vSpawnOrigin = keys.Origin,
                vVelocity = keys.Facing * keys.Speed,
                fDistance = keys.Range,
                fStartRadius = keys.AoE,
                fEndRadius = keys.AoE,
                Source =  self.caster,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                flExpireTime = GameRules:GetGameTime() + 0.13,
            }
            ]]
            local targets = FindUnitsInLine(  self.caster:GetTeamNumber(),
                                                 keys.Origin,
                                                 keys.Origin+keys.Speed*0.15*keys.Facing ,
                                                 nil,
                                                 keys.AoE,
                                                 DOTA_UNIT_TARGET_TEAM_ENEMY,
                                                 DOTA_UNIT_TARGET_ALL,
                                                 DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
                                                )
            local fx = ParticleManager:CreateParticle("particles/nobu/nobu_lasers_nonproj.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(fx, 1,   keys.Origin+keys.Speed*0.15*keys.Facing)       
            ParticleManager:SetParticleControl(fx, 9,  keys.Origin)           

            local hCaster = self:GetCaster()
            if targets == nil then return
            else
                local hCaster = self.caster
                if hCaster.StrategyAcquired and hCaster.IsStrategyReady then
                    hCaster:FindAbilityByName("nobu_strat"):ApplyStrategy()
                end
            end

            local damage = hCaster:FindAbilityByName(hCaster.DSkill):GetGunsDamage() * self:GetSpecialValueFor("damage_mod")

            for k,v in pairs(targets) do   
                local armor_dmg = self:GetSpecialValueFor("armor_dmg")
                hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(v, self, math.max(v:GetPhysicalArmorValue(false) * armor_dmg, 5), DAMAGE_TYPE_MAGICAL, 0)
                --local pure_perc = self:GetSpecialValueFor("pure_perc") / 100
                hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(v, self, damage, DAMAGE_TYPE_PHYSICAL, 0)
                --hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(v, self, damage * pure_perc, DAMAGE_TYPE_PURE, 0)

                if hCaster.ISDOW then
                    hCaster:FindAbilityByName(hCaster.DSkill):DOWShoot()
                end

                if(self.caster.is3000Acquired) then  
                    return false
                else
                    return true
                end
                  
                
            end 
                      
        else
              projectileTable = {
                EffectName = "particles/nobu/nobu_bullet.vpcf" ,
                Ability = self,
                vSpawnOrigin = keys.Origin,
                vVelocity = keys.Facing * keys.Speed,
                fDistance = keys.Range,
                fStartRadius = keys.AoE,
                fEndRadius = keys.AoE,
                Source =  self.caster,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                flExpireTime = GameRules:GetGameTime() + 0.13,
                 
            }
        end
       
        ProjectileManager:CreateLinearProjectile(projectileTable)
    end

     
    function ability:OnProjectileHit_ExtraData(target, location, data)
        if target == nil then
            return
        end
        local hCaster = self:GetCaster()

        local damage = hCaster:FindAbilityByName(hCaster.DSkill):GetGunsDamage() * self:GetSpecialValueFor("damage_mod")

        if hCaster.is3000Acquired then
            local armor_dmg = self:GetSpecialValueFor("armor_dmg")
            hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(target, self, target:GetPhysicalArmorValue(false) * armor_dmg, DAMAGE_TYPE_MAGICAL, 0)
        else           
            target:EmitSound("nobu_shot_impact_"..math.random(1,2))
        end

        hCaster:FindAbilityByName(hCaster.DSkill):GunDoDamage(target, self, damage, DAMAGE_TYPE_PHYSICAL, 0)  

        if hCaster.StrategyAcquired and hCaster.IsStrategyReady then
            hCaster:FindAbilityByName("nobu_strat"):ApplyStrategy()
        end 

        if(hCaster.ISDOW) then
            hCaster:FindAbilityByName(hCaster.DSkill):DOWShoot()
        end

        if(hCaster.is3000Acquired) then  
            return false
        else
            return true
        end
    end
end

nobu_3000_wrapper(nobu_3000)
nobu_3000_wrapper(nobu_3000_upgrade)
