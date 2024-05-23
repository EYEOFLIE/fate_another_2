diarmuid_gae_buidhe =  class({})
diarmuid_gae_buidhe_upgrade_1 =  class({})
diarmuid_gae_buidhe_upgrade_2 =  class({})
diarmuid_gae_buidhe_upgrade_3 =  class({})

LinkLuaModifier("modifier_gae_buidhe", "abilities/diarmuid/modifiers/modifier_gae_buidhe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doublespear_buidhe", "abilities/diarmuid/modifiers/modifier_doublespear_buidhe", LUA_MODIFIER_MOTION_NONE)

function gae_buidhe_wrapper(ability)
	function ability:GetCooldown(iLevel)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_rampant_warrior") then
			return caster:FindAbilityByName("diarmuid_rampant_warrior"):GetSpecialValueFor("spear_cd")
		else
			return self:GetSpecialValueFor("cooldown")
		end
	end

	function ability:GetManaCost(iLevel)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_rampant_warrior") then
			return caster:FindAbilityByName("diarmuid_rampant_warrior"):GetSpecialValueFor("spear_mana")
		else
			return self:GetSpecialValueFor("manacost")
		end
	end

	function ability:CastFilterResultTarget(hTarget)
		local caster = self:GetCaster()
		local target_flag = DOTA_UNIT_TARGET_FLAG_NONE

		if caster:HasModifier("modifier_golden_rose_attribute") then
			target_flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		end

		local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, target_flag, caster:GetTeamNumber())

		if(filter == UF_SUCCESS) then
			if hTarget:GetName() == "npc_dota_ward_base" then 
				return UF_FAIL_CUSTOM 
			else
				return UF_SUCCESS
			end
		else
			return filter
		end	
	end

	function ability:GetCustomCastErrorTarget(hTarget)
		return "#Invalid_Target"
	end

	function ability:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		--caster:EmitSound("ZL.Buidhe_Cast")

		self.SoundQueue = math.random(1,2)

		caster:EmitSound("Diarmuid_GaeBuidhe_Alt" .. self.SoundQueue .. "_1")

		local particle = ParticleManager:CreateParticle("particles/custom/diarmuid/diarmuid_gae_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) 
		ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) 
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)

		return true
	end

	function ability:GetCastPoint()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_rampant_warrior") then
			return self:GetSpecialValueFor("cast_time") * (1 - caster:FindAbilityByName("diarmuid_rampant_warrior"):GetSpecialValueFor("cast_reduc")/100)
		else
			return self:GetSpecialValueFor("cast_time")
		end
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()	

		caster:RemoveModifierByName("modifier_doublespear_buidhe")

		if IsSpellBlocked(target) then return end 

		local unitReduction = 10
		local currentStack = target:GetModifierStackCount("modifier_gae_buidhe", caster) or 0
		local damage = self:GetSpecialValueFor("damage")
		local golden_rose_damage = 0
		local healthDiff = target:GetHealth()
		local hp_dmg_lock = self:GetSpecialValueFor("hp_dmg_lock")

		EmitGlobalSound("Diarmuid_GaeBuidhe_Alt" .. self.SoundQueue .. "_2")
		target:EmitSound("Hero_Lion.Impale")
		
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4_END, rate=2})

		local dagon_particle = ParticleManager:CreateParticle("particles/custom/diarmuid/diarmuid_gae_buidhe.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
		local particle_effect_intensity = 600
		ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( dagon_particle, false )
			ParticleManager:ReleaseParticleIndex( dagon_particle )
		end)

		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

		if IsValidEntity(target) and target:IsAlive() then 

			if caster.IsGoldenRoseAcquired then
				target.gae_buidhe_stack = target.gae_buidhe_stack or 0
				local bonus_per_stack = self:GetSpecialValueFor("bonus_per_stack") / 100
				golden_rose_damage = bonus_per_stack * target.gae_buidhe_stack * damage
				DoDamage(caster, target, golden_rose_damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
				target.gae_buidhe_stack = target.gae_buidhe_stack + 1
			end

			healthDiff = healthDiff - target:GetHealth()
			nStacks = math.ceil(healthDiff * hp_dmg_lock / (unitReduction * 100))

			if target:GetHealth() > 0 and target:IsAlive() and caster:IsAlive() and nStacks > 1 then
				--target:RemoveModifierByName("modifier_gae_buidhe") 
				target:AddNewModifier(caster, self, "modifier_gae_buidhe", { Stacks = currentStack + nStacks})
				if target:IsRealHero() then 
					target:CalculateStatBonus(true) 
				end
			end
		end
		

		if (caster.IsDoubleSpearAcquired or caster:HasModifier("modifier_double_spearsmanship_active")) 
			and not caster:HasModifier("modifier_rampant_warrior") then
			local dearg = nil
			if caster.IsCrimsonRoseAcquired and caster.IsDoubleSpearAcquired then 
				dearg = caster:FindAbilityByName("diarmuid_gae_dearg_upgrade_3")
			elseif not caster.IsCrimsonRoseAcquired and caster.IsDoubleSpearAcquired then 
				dearg = caster:FindAbilityByName("diarmuid_gae_dearg_upgrade_2")
			elseif caster.IsCrimsonRoseAcquired and not caster.IsDoubleSpearAcquired then 
				dearg = caster:FindAbilityByName("diarmuid_gae_dearg_upgrade_1")
			elseif not caster.IsCrimsonRoseAcquired and not caster.IsDoubleSpearAcquired then 
				dearg = caster:FindAbilityByName("diarmuid_gae_dearg")
			end
			if not dearg:IsCooldownReady() then
				dearg:DoubleSpearRefresh()
			end
		end
	end

	function ability:DoubleSpearRefresh()
		local current_cooldown = self:GetCooldownTimeRemaining()
		local caster = self:GetCaster()
		local window = self:GetSpecialValueFor("doublespear_window")

		self:EndCooldown()
		self:StartCooldown(self:GetSpecialValueFor("window_cooldown"))

		caster:AddNewModifier(caster, self, "modifier_doublespear_buidhe", { Ability = self:entindex(), Duration = window,
																			 RemainingCooldown = current_cooldown - window})
	end

	function ability:StartRemainingCooldown(flCooldown)
		if flCooldown > 0 then
			self:StartCooldown(flCooldown)
		end
	end

	function ability:OnOwnerDied()
		LoopOverHeroes(function(hero)
	    	hero:RemoveModifierByName("modifier_gae_buidhe")
	    end)
	end
end

gae_buidhe_wrapper(diarmuid_gae_buidhe)
gae_buidhe_wrapper(diarmuid_gae_buidhe_upgrade_1)
gae_buidhe_wrapper(diarmuid_gae_buidhe_upgrade_2)
gae_buidhe_wrapper(diarmuid_gae_buidhe_upgrade_3)