diarmuid_gae_dearg =  class({})
diarmuid_gae_dearg_upgrade_1 =  class({})
diarmuid_gae_dearg_upgrade_2 =  class({})
diarmuid_gae_dearg_upgrade_3 =  class({})

LinkLuaModifier("modifier_gae_dearg", "abilities/diarmuid/modifiers/modifier_gae_dearg", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doublespear_dearg", "abilities/diarmuid/modifiers/modifier_doublespear_dearg", LUA_MODIFIER_MOTION_NONE)

function gae_dearg_wrapper(ability)
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
		local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber())

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
		--caster:EmitSound("ZL.Dearg_Cast")

		self.SoundQueue = math.random(1,3)

		caster:EmitSound("Diarmuid_GaeDearg_Alt" .. self.SoundQueue .. "_1")

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
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
		local ability = self	
		local target = self:GetCursorTarget()

		local original_pos = caster:GetAbsOrigin()

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff * 100)
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )	

		local flashIndex = ParticleManager:CreateParticle( "particles/custom/diarmuid/gae_dearg_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
	    ParticleManager:SetParticleControl( flashIndex, 2, original_pos )
	    ParticleManager:SetParticleControl( flashIndex, 3, caster:GetAbsOrigin() )

		if IsSpellBlocked(target) then return end -- Linken effect checker

		ApplyStrongDispel(target)

		caster:RemoveModifierByName("modifier_doublespear_dearg")

		local damage = 0
		local maxDamageDist = self:GetSpecialValueFor("max_damage_dist")
		local minDamageDist = self:GetSpecialValueFor("min_damage_dist")
		local min_damage = self:GetSpecialValueFor("min_damage")
		local max_damage = self:GetSpecialValueFor("max_damage")
		
		local distDiff =  minDamageDist - maxDamageDist
		local damageDiff = max_damage - min_damage
		local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 

		if distance <= maxDamageDist then 
			damage = max_damage
		elseif maxDamageDist < distance and distance < minDamageDist then
			damage = min_damage + damageDiff * (minDamageDist - distance) / distDiff
		elseif minDamageDist <= distance then
			damage = min_damage
		end

		EmitGlobalSound("Diarmuid_GaeDearg_Alt" .. self.SoundQueue .. "_2")

		target:EmitSound("Hero_Lion.Impale")
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=2})
		target:AddNewModifier(caster, nil, "modifier_silence", {duration=0.1})

		-- Add dagon particle
		local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
		local particle_effect_intensity = 600
		ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( dagon_particle, false )
			ParticleManager:ReleaseParticleIndex( dagon_particle )
		end)

		if caster.IsCrimsonRoseAcquired and not IsManaLess(target) and target:IsHero() then
			local mana_cut_per_stack = self:GetSpecialValueFor("mana_cut_per_stack")
			local revoke_per_stack = self:GetSpecialValueFor("revoke_per_stack")
			local duration = self:GetSpecialValueFor("duration")
			target:SetMana(target:GetMana() - mana_cut_per_stack)
			target:AddNewModifier(caster, ability, "modifier_gae_dearg", { ManaCut = mana_cut_per_stack, Revoked = revoke_per_stack, Duration = duration})
		end

		DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)	

		--EmitGlobalSound("ZL.Gae_Dearg")
		

	    --ParticleManager:SetParticleControlEnt(flashIndex, 3, caster, PATTACH_CUSTOMORIGIN, "attach_attack2", caster:GetAbsOrigin(), true)

		if (caster.IsDoubleSpearAcquired or caster:HasModifier("modifier_double_spearsmanship_active")) 
			and not caster:HasModifier("modifier_rampant_warrior") then
			local buidhe 
			if caster.IsGoldenRoseAcquired and caster.IsDoubleSpearAcquired then 
				buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe_upgrade_3")
			elseif not caster.IsGoldenRoseAcquired and caster.IsDoubleSpearAcquired then 
				buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe_upgrade_2")
			elseif caster.IsGoldenRoseAcquired and not caster.IsDoubleSpearAcquired then 
				buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe_upgrade_1")
			elseif not caster.IsGoldenRoseAcquired and not caster.IsDoubleSpearAcquired then 
				buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe")
			end
			if not buidhe:IsCooldownReady() then
				buidhe:DoubleSpearRefresh()
			end
		end
	end

	function ability:DoubleSpearRefresh()
		local current_cooldown = self:GetCooldownTimeRemaining()
		local caster = self:GetCaster()
		local window = self:GetSpecialValueFor("doublespear_window")

		self:EndCooldown()
		self:StartCooldown(self:GetSpecialValueFor("window_cooldown"))

		caster:AddNewModifier(caster, self, "modifier_doublespear_dearg", { Ability = self:entindex(), Duration = window,
																			RemainingCooldown = current_cooldown - window})
	end

	function ability:StartRemainingCooldown(flCooldown)
		if flCooldown > 0 then
			self:StartCooldown(flCooldown)
		end
	end
end

gae_dearg_wrapper(diarmuid_gae_dearg)
gae_dearg_wrapper(diarmuid_gae_dearg_upgrade_1)
gae_dearg_wrapper(diarmuid_gae_dearg_upgrade_2)
gae_dearg_wrapper(diarmuid_gae_dearg_upgrade_3)