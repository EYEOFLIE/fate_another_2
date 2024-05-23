LinkLuaModifier("mordred_combo_check", "abilities/mordred/mordred_top_secret", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mordred_armor_shred", "abilities/mordred/mordred_top_secret", LUA_MODIFIER_MOTION_NONE)

mordred_slash = class({})
--mordred_slash_upgrade = class({})
--mordred_slash_burst = class({})
mordred_slash_upgrade_1 = class({})
mordred_slash_upgrade_2 = class({})
mordred_slash_upgrade_3 = class({})

function mordred_slash_wrapper(ability)
	--[[function ability:OnUpgrade()
		local caster = self:GetCaster()
		if caster.RampageAcquired and caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash_upgrade" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_burst_upgrade_3"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_burst_upgrade_3"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_3" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_upgrade"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_upgrade"):SetLevel(self:GetLevel())
				end
			end
		elseif not caster.RampageAcquired and caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_burst_upgrade_2"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_burst_upgrade_2"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_2" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash"):GetLevel() then
					caster:FindAbilityByName("mordred_slash"):SetLevel(self:GetLevel())
				end
			end
		elseif caster.RampageAcquired and not caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash_upgrade" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_burst_upgrade_1"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_burst_upgrade_1"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_1" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_upgrade"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_upgrade"):SetLevel(self:GetLevel())
				end
			end
		elseif not caster.RampageAcquired and not caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash_burst"):GetLevel() then
					caster:FindAbilityByName("mordred_slash_burst"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "mordred_slash_burst" then
				if self:GetLevel() ~= caster:FindAbilityByName("mordred_slash"):GetLevel() then
					caster:FindAbilityByName("mordred_slash"):SetLevel(self:GetLevel())
				end
			end
		end
	end

	function ability:StartCD()
		local caster = self:GetCaster()
		local ability = self
		if caster.RampageAcquired and caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash_upgrade" then
				caster:FindAbilityByName("mordred_slash_burst_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_3" then
				caster:FindAbilityByName("mordred_slash_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif not caster.RampageAcquired and caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash" then
				caster:FindAbilityByName("mordred_slash_burst_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_2" then
				caster:FindAbilityByName("mordred_slash"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif caster.RampageAcquired and not caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash_upgrade" then
				caster:FindAbilityByName("mordred_slash_burst_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_slash_burst_upgrade_1" then
				caster:FindAbilityByName("mordred_slash_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif not caster.RampageAcquired and not caster.LightningOverloadAcquired then
			if self:GetAbilityName() == "mordred_slash" then
				caster:FindAbilityByName("mordred_slash_burst"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "mordred_slash_burst" then
				caster:FindAbilityByName("mordred_slash"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		end
	end]]

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		--self:StartCD()

		if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then		
			if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and not caster:HasModifier("modifier_mordred_mmb_cooldown") then
				caster:AddNewModifier(caster, self, "mordred_combo_check", {duration = 4})
			end
		end

		if caster:HasModifier("pedigree_off") and caster.LightningOverloadAcquired then
	    	local kappa = caster:FindModifierByName("modifier_mordred_overload")
	    	kappa:Doom()
	   	end

		local enemies = FindUnitsInRadius(  caster:GetTeamNumber(),
	                                        caster:GetAbsOrigin(),
	                                        nil,
	                                        500,
	                                        DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                        DOTA_UNIT_TARGET_ALL,
	                                        DOTA_UNIT_TARGET_FLAG_NONE,
	                                        FIND_ANY_ORDER,
	                                        false)
		if enemies[1] ~= nil then
			DoCleaveAttack(caster, enemies[1], self, 0, 200, 400, 500, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf")
	    end
	    for _,enemy in pairs(enemies) do
	    	if IsValidEntity(enemy) and not enemy:IsNull() then
	    		if IsFront(caster, enemy, 160) then
					if caster:HasModifier("pedigree_off") and not enemy:IsMagicImmune() then
						local mana = caster:GetMana() * self:GetSpecialValueFor("mana_percent")/100
						if not IsImmuneToCC(enemy) then
				       		enemy:AddNewModifier(caster, self, "modifier_stunned", {Duration = self:GetSpecialValueFor("duration")})
				        end
				        EmitSoundOn("mordred_lightning", enemy)
						DoDamage(caster, enemy, self:GetSpecialValueFor("mana_damage")/100 * mana, DAMAGE_TYPE_MAGICAL, 0, self, false)
				       	caster:SpendMana(mana, self)
				       	
				        
				        Timers:CreateTimer(0.01, function()
				        	if enemy:IsHero() then
					            local particle = ParticleManager:CreateParticle("particles/custom/mordred/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, enemy)
					            local target_point = enemy:GetAbsOrigin()
					            ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
					            ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, 2000))
					            ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
				        	end
				        end)
				    end
				    if caster.RampageAcquired then
				    	enemy:AddNewModifier(caster, self, "mordred_armor_shred", {Duration = 0.1, ArmorShred = self:GetSpecialValueFor("armor_shred")})
				    end
				    DoDamage(caster, enemy, self:GetSpecialValueFor("base_damage")/100 * caster:GetAverageTrueAttackDamage(caster) + self:GetSpecialValueFor("bonus_damage"), DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self, false)
				    --[[if caster.RampageAcquired then
				    	enemy:RemoveModifierByName("mordred_armor_shred")
				    end]]
				    
		        end
		    end
	    end
	end
end

mordred_slash_wrapper(mordred_slash)
--mordred_slash_wrapper(mordred_slash_upgrade)
--mordred_slash_wrapper(mordred_slash_burst)
mordred_slash_wrapper(mordred_slash_upgrade_1)
mordred_slash_wrapper(mordred_slash_upgrade_2)
mordred_slash_wrapper(mordred_slash_upgrade_3)

mordred_combo_check = class({})

function mordred_combo_check:IsHidden() return true end

function mordred_combo_check:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

mordred_armor_shred = class({})

function mordred_armor_shred:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

if IsServer() then
	function mordred_armor_shred:OnCreated(args)
		self.armor_shred = args.ArmorShred / 100
		self.ArmorReduction = (self:GetParent():GetPhysicalArmorValue(false)) * self.armor_shred 
	end
end

function mordred_armor_shred:GetModifierPhysicalArmorBonus()
	return self.ArmorReduction
end

function mordred_armor_shred:IsHidden()
	return true 
end