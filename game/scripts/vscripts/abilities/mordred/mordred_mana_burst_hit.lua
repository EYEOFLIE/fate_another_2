LinkLuaModifier("modifier_mordred_mb_silence", "abilities/mordred/mordred_mana_burst_hit.lua", LUA_MODIFIER_MOTION_NONE)

mordred_mana_burst_hit = class({})
--mordred_mana_burst_hit_burst = class({})
mordred_mana_burst_hit_upgrade = class({})

function mordred_mana_burst_hit_wrapper(ability)
	--[[function ability:OnUpgrade()
		local caster = self:GetCaster()
		if caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_mana_burst_hit_burst_upgrade" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_mana_burst_hit"):GetLevel() then
					caster:FindAbilityByName("mordred_mana_burst_hit"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_mana_burst_hit" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_mana_burst_hit_burst_upgrade"):GetLevel() then
					caster:FindAbilityByName("mordred_mana_burst_hit_burst_upgrade"):SetLevel(self:GetLevel())
				end
			end
		else
			if self:GetAbilityName() == "mordred_mana_burst_hit_burst" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_mana_burst_hit"):GetLevel() then
					caster:FindAbilityByName("mordred_mana_burst_hit"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_mana_burst_hit" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_mana_burst_hit_burst"):GetLevel() then
					caster:FindAbilityByName("mordred_mana_burst_hit_burst"):SetLevel(self:GetLevel())
				end
			end
		end
	end

	function ability:StartCD()
		local caster = self:GetCaster()
		if caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_mana_burst_hit_burst_upgrade" then
				caster:FindAbilityByName("mordred_mana_burst_hit"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_mana_burst_hit" then
				caster:FindAbilityByName("mordred_mana_burst_hit_burst_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		else
			if self:GetAbilityName() == "mordred_mana_burst_hit_burst" then
				caster:FindAbilityByName("mordred_mana_burst_hit"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_mana_burst_hit" then
				caster:FindAbilityByName("mordred_mana_burst_hit_burst"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		end
	end]]

	function ability:OnAbilityPhaseStart()
	    local caster = self:GetCaster()
		local target = self:GetCursorTarget()

        if caster:HasModifier('modifier_alternate_02') then 
			EmitSoundOn("Mordred-Armorless-W", caster)
        else
			EmitSoundOn("mordred_shut_up", caster)
        end
		--EmitSoundOn("mordred_shut_up", target)
	    return true
	end

	function ability:OnAbilityPhaseInterrupted()
	    local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		StopSoundOn("mordred_shut_up", caster)
		--StopSoundOn("mordred_shut_up", target)
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local mana_perc = self:GetSpecialValueFor("mana_percent")
		local mana = caster:GetMana() * mana_perc/100
		--self:StartCD()
		if caster:GetMana() < mana then
	        mana = caster:GetMana()
	    end
		
		if not caster:HasModifier("pedigree_off") then
			mana = 0
		end
		local damage = self:GetSpecialValueFor("damage") + mana * self:GetSpecialValueFor("mana_damage")/100

		local particle = ParticleManager:CreateParticle("particles/custom/mordred/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, target)
		local target_point = target:GetAbsOrigin()
		ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
		ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, 2000))
		ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))

		caster:SpendMana(mana, self)
		
		target:AddNewModifier(caster, self, "modifier_mordred_mb_silence", {duration = self:GetSpecialValueFor("duration")})

		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)

		--EmitSoundOn("mordred_lightning", caster)
		EmitSoundOn("mordred_lightning", target)
		
		if caster:HasModifier("pedigree_off") and caster:HasModifier("modifier_mordred_overload") then
	    	local kappa = caster:FindModifierByName("modifier_mordred_overload")
	    	kappa:Doom()
	   	end

		--[[if caster.CurseOfRetributionAcquired then
			caster:FindAbilityByName("mordred_curse_passive"):ShieldCharge()
		end]]
	end
end

mordred_mana_burst_hit_wrapper(mordred_mana_burst_hit)
--mordred_mana_burst_hit_wrapper(mordred_mana_burst_hit_burst)
mordred_mana_burst_hit_wrapper(mordred_mana_burst_hit_upgrade)

modifier_mordred_mb_silence = class({})

function modifier_mordred_mb_silence:CheckState()
    local state =   {
                        [MODIFIER_STATE_SILENCED] = true
                    }
    return state
end

function modifier_mordred_mb_silence:IsDebuff() return true end