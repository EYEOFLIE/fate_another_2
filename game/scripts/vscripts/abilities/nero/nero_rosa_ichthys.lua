nero_rosa_ichthys = class({})
nero_rosa_ichthys_upgrade_1 = class({})
nero_rosa_ichthys_upgrade_2 = class({})
nero_rosa_ichthys_upgrade_3 = class({})

LinkLuaModifier("modifier_rosa_slow", "abilities/nero/modifiers/modifier_rosa_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rosa_buffer", "abilities/nero/modifiers/modifier_rosa_buffer", LUA_MODIFIER_MOTION_NONE)

function nero_rosa_wrapper(ability)
	function ability:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	
	function ability:GetCastRange(vLocation, hTarget)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
			return self:GetSpecialValueFor("aestus_range")
		else
			return self:GetSpecialValueFor("range")
		end
	end

	function ability:CastFilterResultTarget(hTarget)
		local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())

		if(filter == UF_SUCCESS) then
			if hTarget:GetName() == "npc_dota_ward_base" then 
				return UF_FAIL_CUSTOM 
			elseif self:GetCaster():HasModifier("modifier_aestus_domus_aurea_nero") and not hTarget:HasModifier("modifier_aestus_domus_aurea_enemy") then
				return UF_FAIL_CUSTOM 
			else
				return UF_SUCCESS
			end
		else
			return filter
		end
	end

	function ability:GetCustomCastErrorTarget(hTarget)
		if self:GetCaster():HasModifier("modifier_aestus_domus_aurea_nero") and not hTarget:HasModifier("modifier_aestus_domus_aurea_enemy") then
			return "Outside Theatre"
		else
			return "#Invalid_Target"
		end    
	end

	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster.IsSoverignsGloryAcquired then
			return caster:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):GetSpecialValueFor("ability_cd") 
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_aestus_domus_aurea_nero") then
			return 100
		else
			return 200
		end
	end

	function ability:OnAbilityPhaseStart()
		local caster = self:GetCaster()

		caster:EmitSound("Nero.Skill1")

		return true
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local damage = self:GetSpecialValueFor("damage")

		local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
		CreateSlashFx(caster, caster:GetAbsOrigin(), caster:GetAbsOrigin() + diff:Normalized() * diff:Length2D())
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		StartAnimation(caster, {duration = 1, activity = ACT_DOTA_CAST_ABILITY_3_END, rate = 1.5})	
		caster:MoveToTargetToAttack(target)

		if IsSpellBlocked(target) then return end

		
		if not target:HasModifier("modifier_rosa_buffer") and not IsImmuneToCC(target) then
			target:AddNewModifier(caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration") })
		end
			
		target:EmitSound("Hero_Lion.FingerOfDeath")

		if caster.IsAestusEstusAcquired then
			if not IsImmuneToSlow(target) then
				target:AddNewModifier(caster, self, "modifier_rosa_slow", {Duration = self:GetSpecialValueFor("slow_duration")})
			end
		end

		local slashFx = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_WORLDORIGIN, caster )
		ParticleManager:SetParticleControl( slashFx, 0, target:GetAbsOrigin() + Vector(0,0,300))

		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( slashFx, false )
			ParticleManager:ReleaseParticleIndex( slashFx )
		end)

		if caster:HasModifier("modifier_aestus_domus_aurea_nero") and caster.IsSoverignsGloryAcquired then               
	        if not target:HasModifier("modifier_rosa_buffer") then
	        	target:AddNewModifier(caster, self, "modifier_rosa_buffer", { Duration = self:GetSpecialValueFor("stun_cooldown")})
	        end
	    end

	    --[[local splashFx = ParticleManager:CreateParticle("particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf", PATTACH_WORLDORIGIN, caster )
		ParticleManager:SetParticleControl( splashFx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl( splashFx, 1, Vector(0,0,0))

		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( splashFx, false )
			ParticleManager:ReleaseParticleIndex( splashFx )
		end)]]

		

	    -- Too dumb to make particles, just call cleave function 4head
	    DoCleaveAttack(caster, caster, self, 0, 200, 400, 500, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf")

	    DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	    
	    self.Target = target

	    local slash = 
		{
			Ability = self,
	        EffectName = "",
	        iMoveSpeed = 5000,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        fDistance = 500 - 200,
	        fStartRadius = 200,
	        fEndRadius = 400,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = true,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	        fExpireTime = GameRules:GetGameTime() + 0.1,
			bDeleteOnHit = false,
			vVelocity = caster:GetForwardVector() * 5000
		}

		local projectile = ProjectileManager:CreateLinearProjectile(slash)
	end

	function ability:OnProjectileHit_ExtraData(hTarget, vLocation, table)
		if hTarget == nil or hTarget == self.Target then return end

		if not IsValidEntity(hTarget) or hTarget:IsNull() or not hTarget:IsAlive() then return end

		local damage = self:GetSpecialValueFor("damage") * self:GetSpecialValueFor("splash_damage") / 100
		local hCaster = self:GetCaster()

		
		if hCaster.IsSoverignsGloryAcquired and hCaster:HasModifier("modifier_aestus_domus_aurea_nero") then               
	        if not hTarget:HasModifier("modifier_rosa_buffer") and not IsImmuneToCC(hTarget) then
	        	hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("stun_duration") })
	        	hTarget:AddNewModifier(hCaster, self, "modifier_rosa_buffer", { Duration = self:GetSpecialValueFor("stun_cooldown") })
	        end
	    end

	    DoDamage(hCaster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
	end
end

nero_rosa_wrapper(nero_rosa_ichthys)
nero_rosa_wrapper(nero_rosa_ichthys_upgrade_3)
nero_rosa_wrapper(nero_rosa_ichthys_upgrade_2)
nero_rosa_wrapper(nero_rosa_ichthys_upgrade_1)