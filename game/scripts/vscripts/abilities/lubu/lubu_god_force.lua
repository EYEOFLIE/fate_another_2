require("abilities/lubu/lubu_abilities")
--ATTEMPT ON LUA

LinkLuaModifier("modifier_lubu_god_force", "abilities/lubu/lubu_god_force", LUA_MODIFIER_MOTION_NONE)

modifier_lubu_god_force = class({})

function modifier_lubu_god_force:IsHidden()
	return false 
end

function modifier_lubu_god_force:IsPurgable()
    return false
end

function modifier_lubu_god_force:RemoveOnDeath()
    return true
end

function modifier_lubu_god_force:OnCreated()
    local ability = self:GetAbility()

    if ability and not ability:IsNull() then
        self.movespeed_bonus = ability:GetSpecialValueFor("movespeed_bonus")
        self.turn_rate_reduction = ability:GetSpecialValueFor("turn_rate_reduction")
    else
        self.movespeed_bonus = 150 -- Default value if ability is missing
        self.turn_rate_reduction = -200 -- Default value if ability is missing
    end
end

function modifier_lubu_god_force:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return funcs
end

function modifier_lubu_god_force:GetModifierMoveSpeed_Absolute()
    return self.movespeed_bonus
end

function modifier_lubu_god_force:GetModifierTurnRate_Percentage()
    return self.turn_rate_reduction
end

function modifier_lubu_god_force:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end


lubu_god_force_new = class({})
lubu_god_force_new_upgrade = class({})

function lubu_god_force_new_wrapper(ability)

	 function ability:GetAbilityTextureName()
        if self:GetCaster():HasModifier("modifier_alternate_03") then
            return "custom/lubu/lubu_god_force_skin"
        else
            return "custom/lubu/lubu_god_force"
        end
    end    

    function ability:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local radius = ability:GetSpecialValueFor("radius")
	local interval = ability:GetSpecialValueFor("interval")
	local angle = ability:GetSpecialValueFor("angle")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_spin = ability:GetSpecialValueFor("damage_spin")
	local damage_thrust = ability:GetSpecialValueFor("damage_thrust")
	local mini_stun = ability:GetSpecialValueFor("mini_stun")
	local spin_stun = ability:GetSpecialValueFor("spin_stun")
	local thrust_stun = ability:GetSpecialValueFor("thrust_stun")
	local thrust_distance = ability:GetSpecialValueFor("thrust_distance")
	local thrust_width = ability:GetSpecialValueFor("thrust_width")
	local knock = ability:GetSpecialValueFor("knock")	
	local bonus_dmg = 0
	local hit_count = 0
	local targets
	local sound = false

    local modifierDuration = (total_hit + 1) * interval
    print("Modifier Duration: " .. modifierDuration) -- Print out the modifier duration for debugging purposes

    caster:AddNewModifier(caster, ability, "modifier_lubu_god_force", {Duration = modifierDuration})
	giveUnitDataDrivenModifier(caster,caster,"revoked", (total_hit + 1) * interval)

	local markfx = ParticleManager:CreateParticle('particles/units/heroes/hero_void_spirit/planeshift/void_spirit_planeshift_untargetable.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(markfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(markfx, 1, caster:GetAbsOrigin())
	Timers:CreateTimer(interval * total_hit, function()
		ParticleManager:DestroyParticle(markfx, false)
		ParticleManager:ReleaseParticleIndex(markfx)
	end)

	Timers:CreateTimer( function()
		if caster:IsAlive() and hit_count < total_hit + 1 then 
			local caster_angle = caster:GetAnglesAsVector().y
			caster:EmitSound("Hero_PhantomLancer.Attack")
			targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			if hit_count < 3 then 
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_dmg = ability:GetSpecialValueFor("bonus_hp_dmg")	/ 100 
					bonus_dmg = caster:GetMaxHealth() * bonus_hp_dmg
				end

				if hit_count == 0 then 
					if caster:HasModifier("modifier_alternate_03") then 
						print('dynasty lubu')
						StartAnimation(caster, {duration= (3*interval) - 0.05, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.5})
					else
						StartAnimation(caster, {duration= (3*interval) - 0.05, activity=ACT_DOTA_CAST_ABILITY_4, rate=2.3})
					end
				end
				local slashfxx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_new_r_grow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(slashfxx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(slashfxx, 1, Vector(radius, 12, 0))
				ParticleManager:SetParticleControl(slashfxx, 2, Vector((30 * hit_count) / math.max(1,hit_count), caster_angle + 180,((hit_count + 1) % 2) * 180)) --(roll,pitch,yaw)
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(slashfxx, false)
					ParticleManager:ReleaseParticleIndex(slashfxx)
				end)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
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

					    local result_angle = math.abs(enemy_angle - caster_angle)

					    if result_angle <= angle/2 then
					        if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = mini_stun})
							end
							if sound == false  then 
								v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
								sound = true 
							end
					        if caster.IsRuthlessWarriorAcquired then 
								local MR = v:GetBaseMagicalResistanceValue()/100
				            	local dmg_deal = (damage + bonus_dmg) * (1-MR) 
				            	if godforce_hit == false then
				            		OnRuthlessDrain(caster, 1, dmg_deal)
				            	else
				            		OnRuthlessDrain(caster, 0, dmg_deal)
				            	end
				            end
				            DoDamage(caster, v, damage + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					    end
					end
				end
				sound = false
			elseif hit_count == 3 then 
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_dmg = ability:GetSpecialValueFor("bonus_hp_dmg")	/ 100 
					bonus_dmg = caster:GetHealth() * bonus_hp_dmg
				end
				if caster:HasModifier("modifier_alternate_03") then
					StartAnimation(caster, {duration= (2*interval), activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})
					local angle = caster:GetAnglesAsVector().y
					for i = 0,15 do 
						Timers:CreateTimer(i * 0.04, function()
							caster:SetAngles(0, angle + (i * 24), 0)
						end)
						if i == 15 then
							caster:SetAngles(0, 0, 0)
						end
					end
				else
					StartAnimation(caster, {duration= (2*interval), activity=ACT_DOTA_CAST_ABILITY_4_END, rate=3.0})
				end
				
				local slashfxx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_new_r_grow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(slashfxx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(slashfxx, 1, Vector(radius, 7, 0))
				ParticleManager:SetParticleControl(slashfxx, 2, Vector(0, caster_angle, 0)) --(roll,pitch,yaw)
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(slashfxx, false)
					ParticleManager:ReleaseParticleIndex(slashfxx)
				end)
				
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull()then
						if not v:IsMagicImmune() and not IsImmuneToCC(v) then
							v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = spin_stun})
						end
					        
					    if caster.IsRuthlessWarriorAcquired then 
							local MR = v:GetBaseMagicalResistanceValue()/100
				           	local dmg_deal = (damage_spin + bonus_dmg) * (1-MR) 
				           	if godforce_hit == false then
				           		OnRuthlessDrain(caster, 1, dmg_deal)
				           	else
				           		OnRuthlessDrain(caster, 0, dmg_deal)
				           	end
				        end

				        if k == 1 then 
				           	v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
				        end
				        DoDamage(caster, v, damage_spin + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				    end
				end
			elseif hit_count == 4 then 
				if caster:HasModifier("modifier_alternate_03") then
					--[[local lancetip = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lance_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(lancetip, 0, caster, PATTACH_POINT_FOLLOW	, "attach_lance", caster:GetAbsOrigin(),false)
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(lancetip, false)
						ParticleManager:ReleaseParticleIndex(lancetip)
					end)]]
				else
					local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
					local lancetip = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lance_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, lance)
					ParticleManager:SetParticleControlEnt(lancetip, 0, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(lancetip, false)
						ParticleManager:ReleaseParticleIndex(lancetip)
					end)
				end
			elseif hit_count == 5 then
				EmitGlobalSound('Lubu.GodForce')
				caster:EmitSound("Hero_PrimalBeast.Uproar.Projectile.Split")
				local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
				local end_point = caster:GetAbsOrigin() + (Vector(caster:GetForwardVector().x, caster:GetForwardVector().y,0) * thrust_distance)
				local thrustfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_WORLDORIGIN, caster)
				--ParticleManager:SetParticleControlEnt(thrustfx, 0, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
				ParticleManager:SetParticleControl(thrustfx, 0, caster:GetAbsOrigin() + Vector(0,0,100))
				ParticleManager:SetParticleControl(thrustfx, 1, end_point + Vector(0,0,100))
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(thrustfx, false)
					ParticleManager:ReleaseParticleIndex(thrustfx)
				end)
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_thrust_dmg = ability:GetSpecialValueFor("bonus_hp_thrust_dmg")	/ 100 
					bonus_dmg = caster:GetHealth() * bonus_hp_thrust_dmg
				end
				targets = FindUnitsInLine(caster:GetTeam(), caster:GetAbsOrigin(), end_point, nil, thrust_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull()then
						if not v:IsMagicImmune() and not IsImmuneToCC(v) then
							v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = thrust_stun})
						end
					        
					    if caster.IsRuthlessWarriorAcquired then 
							local MR = v:GetBaseMagicalResistanceValue()/100
				           	local dmg_deal = (damage_thrust + bonus_dmg) * (1-MR) 
				           	if godforce_hit == false then
				           		OnRuthlessDrain(caster, 1, dmg_deal)
				           	else
				           		OnRuthlessDrain(caster, 0, dmg_deal)
				           	end
				        end

				        if k == 1 then 
				           	v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
				        end
				        DoDamage(caster, v, damage_thrust + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				        if IsValidEntity(v) and not v:IsNull() and not IsKnockbackImmune(v) and not v:IsMagicImmune() then
							local pushback = Physics:Unit(v)
							v:PreventDI()
							v:SetPhysicsFriction(0)
							v:SetPhysicsVelocity((v:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * knock)
							v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
							v:FollowNavMesh(false)
							Timers:CreateTimer(0.5, function()  
								if IsValidEntity(v) then
									v:PreventDI(false)
									v:SetPhysicsVelocity(Vector(0,0,0))
									v:OnPhysicsFrame(nil)
									FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
								end
							end)
						end
				    end
				end

			end

			hit_count = hit_count + 1 
			return interval
		else
			return nil 
		end
	end)
    end
end

lubu_god_force_new_wrapper(lubu_god_force_new)
lubu_god_force_new_wrapper(lubu_god_force_new_upgrade)