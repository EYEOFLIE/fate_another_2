muramasa_dash = class({})
muramasa_dash_upgrade = class({})

LinkLuaModifier("modifier_lock_turnrate", "abilities/muramasa/muramasa_dash", LUA_MODIFIER_MOTION_NONE)

function muramasa_dash_wrapper(ability)
	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local distance = self:GetSpecialValueFor("range")
		local ability = self
		local speed = self:GetSpecialValueFor("dash_speed")

		if caster:HasModifier("modifier_muramasa_marble") or caster:HasModifier("modifier_muramasa_combo") then
			speed = speed * 1.4
		end

		local point = self:GetCursorPosition()+caster:GetForwardVector()
		local direction = (point - caster:GetAbsOrigin()):Normalized()
		direction.z = 0
		local dist = distance --self:GetSpecialValueFor("dist")
		local casted_dist = (point - caster:GetAbsOrigin()):Length2D()
		if (casted_dist > dist )then
			point = caster:GetAbsOrigin() + (((point - caster:GetAbsOrigin()):Normalized()) * dist)
			casted_dist = dist
		end
		local sin = Physics:Unit(caster)
		--if caster:GetStrength() >= 25 and caster:GetAgility() >= 25 and caster:GetIntellect() >= 25 and caster:GetAbilityByIndex(3):GetName() ~= "nobu_combo"then      
	    --	if not caster:HasModifier("modifier_nobu_combo_cd") then
		--    	if caster.is3000Acquired and caster:FindAbilityByName("nobu_combo_upgrade"):IsCooldownReady() then 
		--    		caster:AddNewModifier(caster, self, "modifier_nobu_combo_window", {duration = 5} )
		--    	elseif not caster.is3000Acquired and caster:FindAbilityByName("nobu_combo"):IsCooldownReady() then 
		--    		caster:AddNewModifier(caster, self, "modifier_nobu_combo_window", {duration = 5} )
		--        end
		--    end
		--end
	    
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(direction * speed)
		caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	    caster:SetGroundBehavior (PHYSICS_GROUND_LOCK)
		local dash_time =  casted_dist/ speed
		caster:AddNewModifier(caster, self, "modifier_lock_turnrate", {duration = dash_time} )
		StartAnimation(caster, {duration= 1, activity=ACT_DOTA_CAST_ABILITY_6, rate= 2})

		caster:EmitSound("Muramasa.W" .. math.random(1,2))

		Timers:CreateTimer(0.3,function()
	        local hit_fx = ParticleManager:CreateParticle("particles/muramasa/muramasa_spin.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl( hit_fx, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))

			StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_7, rate=1})
			giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.2)

			local damage = self:GetSpecialValueFor("damage")
			local radius = self:GetSpecialValueFor("damage_radius")

			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
			       	DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)	       	
		       	end
		    end

			caster:OnPreBounce(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:SetGroundBehavior (PHYSICS_GROUND_NOTHING)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end)

		caster:OnPreBounce(function(unit, normal) 
			Timers:RemoveTimer("dash_dur")
			unit:OnPreBounce(nil)
			unit:SetBounceMultiplier(0)
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
	        unit:SetGroundBehavior (PHYSICS_GROUND_NOTHING)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end)
	end
end

muramasa_dash_wrapper(muramasa_dash)
muramasa_dash_wrapper(muramasa_dash_upgrade)

 
modifier_lock_turnrate = class({})

function modifier_lock_turnrate:DeclareFunctions()
	return { MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, }
							
end
function modifier_lock_turnrate:IsHidden() return true end
function modifier_lock_turnrate:RemoveOnDeath() return true end
function modifier_lock_turnrate:IsDebuff() return false end

function modifier_lock_turnrate:GetModifierTurnRate_Percentage()
	return 0
end

 



