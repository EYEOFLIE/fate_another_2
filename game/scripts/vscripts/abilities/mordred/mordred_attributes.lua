LinkLuaModifier("modifier_mordred_bc", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_bc_cooldown", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_overload", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)

mordred_attribute_overload = class({})

function mordred_attribute_overload:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.LightningOverloadAcquired) then

		if hero:HasModifier("modifier_mordred_combo_window") then 
			hero:RemoveModifierByName("modifier_mordred_combo_window")
		end

		hero.LightningOverloadAcquired = true

		UpgradeAttribute(hero, 'mordred_mmb_lightning', 'mordred_mmb_lightning_upgrade', false)

		if hero.CurseOfRetributionAcquired then 
			UpgradeAttribute(hero, 'mordred_clarent_upgrade_1', 'mordred_clarent_upgrade_3', true)
			hero.RSkill = 'mordred_clarent_upgrade_3'
		else
			UpgradeAttribute(hero, 'mordred_clarent', 'mordred_clarent_upgrade_2', true)
			hero.RSkill = 'mordred_clarent_upgrade_2'
		end

		UpgradeAttribute(hero, 'mordred_mana_burst_hit', 'mordred_mana_burst_hit_upgrade', true)

		if hero.RampageAcquired then 
			UpgradeAttribute(hero, 'mordred_slash_upgrade_1', 'mordred_slash_upgrade_3', true)
			UpgradeAttribute(hero, 'mordred_rush_upgrade_1', 'mordred_rush_upgrade_3', true)
			hero.QSkill = 'mordred_slash_upgrade_3'
			hero.ESkill = 'mordred_rush_upgrade_3'
		else
			UpgradeAttribute(hero, 'mordred_slash', 'mordred_slash_upgrade_2', true)
			UpgradeAttribute(hero, 'mordred_rush', 'mordred_rush_upgrade_2', true)
			hero.QSkill = 'mordred_slash_upgrade_2'
			hero.ESkill = 'mordred_rush_upgrade_2'
		end

		hero.WSkill = 'mordred_mana_burst_hit_upgrade'

		hero:FindAbilityByName("mordred_overload_passive"):SetLevel(1)
		
		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

mordred_attribute_pedigree = class({})

function mordred_attribute_pedigree:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.ImproveSecretPedigreeAcquired) then

		hero.ImproveSecretPedigreeAcquired = true

		UpgradeAttribute(hero, 'mordred_pedigree', 'mordred_pedigree_upgrade', true)
		hero.DSkill = 'mordred_pedigree_upgrade'

		hero:RemoveModifierByName('pedigree_buff')
		hero:AddNewModifier(hero, hero:FindAbilityByName("mordred_pedigree_upgrade"), "pedigree_buff", {})

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

mordred_attribute_curse = class({})

function mordred_attribute_curse:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.CurseOfRetributionAcquired) then

		if hero:HasModifier("modifier_mordred_combo_window") then 
			hero:RemoveModifierByName("modifier_mordred_combo_window")
		end

		hero.CurseOfRetributionAcquired = true

		--hero:SwapAbilities("fate_empty1", "mordred_curse_passive", false, true)
		hero:FindAbilityByName("mordred_curse_passive"):SetLevel(1)

		if hero.LightningOverloadAcquired then 
			UpgradeAttribute(hero, 'mordred_clarent_upgrade_2', 'mordred_clarent_upgrade_3', true)
			hero.RSkill = 'mordred_clarent_upgrade_3'
		else
			UpgradeAttribute(hero, 'mordred_clarent', 'mordred_clarent_upgrade_1', true)
			hero.RSkill = 'mordred_clarent_upgrade_1'
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

mordred_attribute_bc = class({})

function mordred_attribute_bc:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.BattleContinuationAcquired) then

		hero.BattleContinuationAcquired = true

		hero:FindAbilityByName("mordred_bc_passive"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

mordred_attribute_rampage = class({})

function mordred_attribute_rampage:OnSpellStart()
	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, self, hero.RampageAcquired) then

		hero.RampageAcquired = true

		if hero.LightningOverloadAcquired then 
			UpgradeAttribute(hero, 'mordred_slash_upgrade_2', 'mordred_slash_upgrade_3', true)
			UpgradeAttribute(hero, 'mordred_rush_upgrade_2', 'mordred_rush_upgrade_3', true)
			hero.QSkill = 'mordred_slash_upgrade_3'
			hero.ESkill = 'mordred_rush_upgrade_3'
		else
			UpgradeAttribute(hero, 'mordred_slash', 'mordred_slash_upgrade_1', true)
			UpgradeAttribute(hero, 'mordred_rush', 'mordred_rush_upgrade_1', true)
			hero.QSkill = 'mordred_slash_upgrade_1'
			hero.ESkill = 'mordred_rush_upgrade_1'
		end

		UpgradeAttribute(hero, 'mordred_mb_lightning', 'mordred_mb_lightning_upgrade', true)
		hero.FSkill = 'mordred_mb_lightning_upgrade'
		--hero:FindAbilityByName("mordred_rampage_passive"):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - self:GetManaCost(self:GetLevel()))
	end
end

mordred_bc_passive = class({})

function mordred_bc_passive:GetIntrinsicModifierName()
	return "modifier_mordred_bc"
end

modifier_mordred_bc = class({})

function modifier_mordred_bc:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE,
			 }
end

function modifier_mordred_bc:IsHidden() 
	if self:GetParent():HasModifier("modifier_mordred_bc_cooldown") then
		return true 
	end
	return false 
end

function modifier_mordred_bc:IsPermanent()
	return true
end

function modifier_mordred_bc:RemoveOnDeath()
	return false
end

function modifier_mordred_bc:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mordred_bc:OnTakeDamage(args)
	self.parent = self:GetParent()
	local caster = self:GetParent()
	if args.unit ~= self.parent then return end
	if args.damage > self:GetAbility():GetSpecialValueFor("dmg_threshold") then 
		return 
	end
	if caster:HasModifier("modifier_mordred_bc_cooldown") then return end

	if self.parent:GetHealth() <= 0 then
		local rush = caster:FindAbilityByName(caster.ESkill)
		--[[if caster:HasModifier("pedigree_off") then 
			if caster.RampageAcquired and caster.LightningOverloadAcquired then 
				rush = caster:FindAbilityByName("mordred_rush_burst_upgrade_3")
			elseif not caster.RampageAcquired and caster.LightningOverloadAcquired then 
				rush = caster:FindAbilityByName("mordred_rush_burst_upgrade_2")
			elseif caster.RampageAcquired and not caster.LightningOverloadAcquired then 
				rush = caster:FindAbilityByName("mordred_rush_burst_upgrade_1")
			elseif not caster.RampageAcquired and not caster.LightningOverloadAcquired then 
				rush = caster:FindAbilityByName("mordred_rush_burst")
			end
		end]]

		local damage = rush:GetSpecialValueFor("damage") + rush:GetSpecialValueFor("cast_time") * rush:GetSpecialValueFor("damage_per_second")
		local speed = rush:GetSpecialValueFor("speed") + rush:GetSpecialValueFor("cast_time") * rush:GetSpecialValueFor("speed_per_second")
		self.parent:SetHealth(args.damage)
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_mordred_bc_cooldown", {duration = self:GetAbility():GetCooldown(1)})
		StartAnimation(caster, {duration=self:GetAbility():GetSpecialValueFor("duration"), activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})

		caster:EmitSound("mordred_rush")
		caster.debil = args.attacker
		caster:AddNewModifier(caster, rush, "modifier_mordred_rush", {damage = damage,
																	speed = speed,
																	dolbayob_factor = 1})

		giveUnitDataDrivenModifier(caster, caster, "jump_pause_nosilence", 3)
	end
end

mordred_rampage_passive = class({})

function mordred_rampage_passive:GetIntrinsicModifierName()
	return "modifier_mordred_rampage"
end

LinkLuaModifier("modifier_mordred_rampage_stack", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_rampage_slow", "abilities/mordred/mordred_attributes", LUA_MODIFIER_MOTION_NONE)

modifier_mordred_rampage = class({})

function modifier_mordred_rampage:GetTexture()
	return "custom/mordred/mordred_rampage"
end

function modifier_mordred_rampage:IsHidden() 
	return false 
end

function modifier_mordred_rampage:IsPermanent()
	return true
end

function modifier_mordred_rampage:RemoveOnDeath()
	return true
end

function modifier_mordred_rampage:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mordred_rampage:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			 }
end

function modifier_mordred_rampage:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end

	self.parent = self:GetParent()

	if (self.parent:GetAbsOrigin() - args.target:GetAbsOrigin()):Length2D() > 200 then 
		local diff = (args.target:GetAbsOrigin() - self.parent:GetAbsOrigin() ):Normalized() 
		self.parent:SetAbsOrigin(args.target:GetAbsOrigin() - diff*100) 
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
	end

	local ability = self:GetAbility()
	local duration = ability:GetSpecialValueFor("rampage_mark_dur")
	local rampage_bonus = ability:GetSpecialValueFor("rampage_bonus")
	local stack = args.target:GetModifierStackCount("modifier_mordred_rampage_stack", self.parent) or 0
	
	args.target:AddNewModifier(self.parent, ability, "modifier_mordred_rampage_stack", {Duration = duration})
	if IsServer() then
		DoDamage(self.parent, args.target, stack*rampage_bonus, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
	if IsValidEntity(args.target) and not IsImmuneToCC(args.target) and not IsImmuneToSlow(args.target) and not args.target:IsMagicImmune() then 
		args.target:AddNewModifier(self.parent, ability, "modifier_mordred_rampage_slow", {Dduration = duration})
	end
end

modifier_mordred_rampage_slow = class({})

function modifier_mordred_rampage_slow:GetTexture()
	return "custom/mordred/mordred_rampage"
end

function modifier_mordred_rampage_slow:IsHidden() return true end

function modifier_mordred_rampage_slow:IsDebuff() return true end

function modifier_mordred_rampage_slow:OnCreated()
	self:SetStackCount(1)
end

function modifier_mordred_rampage_slow:OnRefresh()
	self:IncrementStackCount()
end

function modifier_mordred_rampage_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

	return funcs
end

function modifier_mordred_rampage_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("rampage_mark_slow")
end

modifier_mordred_rampage_stack = class({})

function modifier_mordred_rampage_stack:GetTexture()
	return "custom/mordred/mordred_rampage"
end

function modifier_mordred_rampage_stack:IsHidden() return false end

function modifier_mordred_rampage_stack:IsDebuff() return true end

function modifier_mordred_rampage_stack:OnCreated()
	self:SetStackCount(1)
end

function modifier_mordred_rampage_stack:OnRefresh()
	self:IncrementStackCount()
end

modifier_mordred_bc_cooldown = class({})

function modifier_mordred_bc_cooldown:GetTexture()
	return "custom/mordred/mordred_battle_continuation"
end

function modifier_mordred_bc_cooldown:IsHidden()
	return false 
end

function modifier_mordred_bc_cooldown:RemoveOnDeath()
	return false
end

function modifier_mordred_bc_cooldown:IsDebuff()
	return true 
end

function modifier_mordred_bc_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

mordred_overload_passive = class({})

function mordred_overload_passive:GetIntrinsicModifierName()
	return "modifier_mordred_overload"
end

modifier_mordred_overload = class({})

function modifier_mordred_overload:IsHidden() 
	return false
end

function modifier_mordred_overload:IsPermanent()
	return true
end

function modifier_mordred_overload:RemoveOnDeath()
	return false
end

function modifier_mordred_overload:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_mordred_overload:Doom()
	local caster = self:GetParent()

	if caster == nil then return end 

	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local slash = caster:FindAbilityByName(caster.QSkill)
	local hit = caster:FindAbilityByName(caster.WSkill)
	local rush = caster:FindAbilityByName(caster.ESkill)
	local kappa = (slash:GetLevel() + hit:GetLevel() + rush:GetLevel())
	local damage = kappa * self:GetAbility():GetSpecialValueFor("dmg_per_lvl")

	local iPillarFx = ParticleManager:CreateParticle("particles/custom/mordred/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl( iPillarFx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( iPillarFx, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( iPillarFx, 2, caster:GetAbsOrigin())

    caster:EmitSound("mordred_lightning")

    Timers:CreateTimer(1.0, function()
    	if iPillarFx ~= nil then
	        ParticleManager:DestroyParticle(iPillarFx, true)
	        ParticleManager:ReleaseParticleIndex(iPillarFx)
	    end
    end)

    --[[if caster.CurseOfRetributionAcquired then
        caster:FindAbilityByName("mordred_curse_passive"):ShieldCharge()
    end]]

    local visiondummy = SpawnVisionDummy(caster, caster:GetAbsOrigin(), radius, 2, true)

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
    	
    	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and not v:IsMagicImmune() and not IsImmuneToCC(v) then  
	        v:AddNewModifier(caster, self:GetAbility(), "modifier_stunned", {Duration = kappa * self:GetAbility():GetSpecialValueFor("stun_per_lvl")})
	        --end
	        --[[if k <= 4 and v:IsRealHero() then
		        Timers:CreateTimer(0.01, function()
		            local particle = ParticleManager:CreateParticle("particles/custom/mordred/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, v)
		            local target_point = v:GetAbsOrigin()
		            ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
		            ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, 2000))
		            ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
		        end)  
	        end  ]] 
	    end
	    if IsValidEntity(v) and not v:IsNull() and v:IsAlive() and not IsLightningResist(v) then         
	        DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
	    end
    end
end