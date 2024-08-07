LinkLuaModifier("modifier_atalanta_curse", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_energy_curse_passive", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_active_curse", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_evil_beast", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_alter_d_use", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_curse_vision", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_curse_cooldown", "abilities/alter_atalanta/atalanta_alter_curse", LUA_MODIFIER_MOTION_NONE)

atalanta_alter_curse = class({})
atalanta_alter_curse_upgrade_1 = class({})
atalanta_alter_curse_upgrade_2 = class({})
atalanta_alter_curse_upgrade_3 = class({})

function atalanta_curse_wrapper(ability)
	function ability:GetIntrinsicModifierName()
		return "modifier_atalanta_energy_curse_passive"
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		EmitGlobalSound("atalanta_skia_channel")

		local units = FindUnitsInRadius(caster:GetTeam(),
	                                        caster:GetAbsOrigin(), 
	                                        nil, 
	                                        self:GetSpecialValueFor("active_search"), 
	                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
	                                        DOTA_UNIT_TARGET_ALL, 
	                                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
	                                        0, 
	                                        false)
		for _,unit in pairs(units) do
			if not unit or unit:IsNull() or not unit:IsAlive() then return end
			unit:RemoveModifierByName("modifier_atalanta_curse")
	    end

	    caster:AddNewModifier(caster, self, "modifier_atalanta_active_curse", {Duration = 0.5}) 
	    caster:AddNewModifier(caster, self, "modifier_atalanta_curse_cooldown", {Duration = self:GetCooldown(1)})

	    --check combo
	    if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then		
			if caster:FindAbilityByName(caster.WSkill):IsCooldownReady() and not caster:HasModifier("modifier_atalanta_skia_cd") then
				caster:AddNewModifier(caster, self, "modifier_atalanta_alter_d_use", {Duration = 4})
			end
		end
	end

	function ability:Energy(iGain)
		local caster = self:GetCaster()

		local stacks = self:GetEnergyStack(caster)
		local max_stack = self:GetSpecialValueFor("energy_stack")

		if caster.EvolutionAcquired then 
			local SelfEvol = caster:FindAbilityByName("atalanta_passive_evolution")
			SelfEvol:CurseEnergyHeal(iGain)
		else
			if caster:HasModifier("modifier_atalanta_evil_beast") then return end
		end

		if stacks >= max_stack  then return end

		local energy_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_lifesteal_purple.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(energy_fx, 0, caster:GetAbsOrigin())

		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle(energy_fx, false)
			ParticleManager:ReleaseParticleIndex(energy_fx)
		end)

		caster:FindModifierByName("modifier_atalanta_energy_curse_passive"):SetStackCount(math.min(stacks + iGain, max_stack))

		if stacks + iGain >= max_stack then 
			self:Transform(self:GetSpecialValueFor("evil_duration"))
		end
	end

	if IsServer() then
		function ability:ResetEnergyStack(hCaster)
			if self:GetEnergyStack(hCaster) > 0 then
				hCaster:SetModifierStackCount("modifier_atalanta_energy_curse_passive", hCaster, 0)
			end
		end

		function ability:GetEnergyStack(hCaster)
			return hCaster:GetModifierStackCount("modifier_atalanta_energy_curse_passive", hCaster) or 0
		end
	end

	function ability:OnOwnerSpawned()

	end

	function ability:Transform(iDuration)
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_atalanta_evil_beast") then 
			--caster:AddNewModifier(caster, self, "modifier_atalanta_energy_tracker", {Duration = 1.0})
			local remain_time = caster:FindModifierByName("modifier_atalanta_evil_beast"):GetRemainingTime()
			iDuration = iDuration + remain_time
			--caster:RemoveModifierByName("modifier_atalanta_evil_beast")
		end

		caster:AddNewModifier(caster, self, "modifier_atalanta_evil_beast", {Duration = iDuration})

	end

	function ability:Curse(target)
		local caster = self:GetCaster()

		if not target or not target:IsAlive() or target:IsNull() then return end

		local stacks = (target:HasModifier("modifier_atalanta_curse") and target:FindModifierByName("modifier_atalanta_curse"):GetStackCount()) or 0
		local max_stack = self:GetSpecialValueFor("curse_max_stack")

		if stacks >= max_stack  then
			--target:RemoveModifierByName("modifier_atalanta_curse")
		 	return 
		end

		target:AddNewModifier(caster, self, "modifier_atalanta_curse", {duration = self:GetSpecialValueFor("curse_duration")})
		target:FindModifierByName("modifier_atalanta_curse"):SetStackCount(math.min(stacks + 1, max_stack))
	end
end

atalanta_curse_wrapper(atalanta_alter_curse)
atalanta_curse_wrapper(atalanta_alter_curse_upgrade_1)
atalanta_curse_wrapper(atalanta_alter_curse_upgrade_2)
atalanta_curse_wrapper(atalanta_alter_curse_upgrade_3)

----------------------------------

modifier_atalanta_active_curse = class({})

function modifier_atalanta_active_curse:IsHidden() return true end
function modifier_atalanta_active_curse:IsDebuff() return false end
function modifier_atalanta_active_curse:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

----------------------------------

modifier_atalanta_alter_d_use = class({})

function modifier_atalanta_alter_d_use:IsHidden() return true end
function modifier_atalanta_alter_d_use:IsDebuff() return false end
function modifier_atalanta_alter_d_use:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

----------------------------------

modifier_atalanta_curse = class({})

function modifier_atalanta_curse:IsHidden() return false end
function modifier_atalanta_curse:IsDebuff() return true end
function modifier_atalanta_curse:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end

function modifier_atalanta_curse:GetTexture()
    return "custom/alter_atalanta/atalanta_curse"
end

function modifier_atalanta_curse:GetModifierProvidesFOWVision()
	return self:CanBeDetected()
end

function modifier_atalanta_curse:CanBeDetected(hHero)
    if not (self:GetCaster().CurseMoonAcquired and self:GetCaster():IsAlive() and self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("vision")) or self:GetParent():HasModifier("modifier_jtr_the_mist_debuff") then
        return 0
    end
    
    return 1
end

if IsServer() then
	function modifier_atalanta_curse:OnCreated()
		self.parent = self:GetParent()
		self.particle_4stacks = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_4stack.vpcf"
		if not self.particle_4stacks_fx then
	        self.particle_4stacks_fx = ParticleManager:CreateParticle(self.particle_4stacks, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	        ParticleManager:SetParticleControl(self.particle_4stacks_fx, 0, self.parent:GetAbsOrigin())
	        self:AddParticle(self.particle_4stacks_fx, true, false, -1, false, false)        
	    end
	end

	function modifier_atalanta_curse:OnDestroy()
		local caster = self:GetAbility():GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility() or caster:FindAbilityByName(caster.DSkill)

		if ability == nil then 
			ability = caster:FindAbilityByName(caster.DSkill)
		end

		local bonus_dmg = 0
		if caster.CurseMoonAcquired then 
			bonus_dmg = ability:GetSpecialValueFor("curse_dmg_agi") * caster:GetAgility()
		end
		local stacks = self:GetStackCount()
		local dmgval = ability:GetSpecialValueFor("curse_dmg") * stacks
		local search_radius = ability:GetSpecialValueFor("passive_search")
		if caster:HasModifier("modifier_atalanta_active_curse") then 
			search_radius = ability:GetSpecialValueFor("active_search")
		end
		--print('damage curse active = ' .. dmgval + bonus_dmg)
		DoDamage(caster, target, dmgval + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)

		local particle_kill_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_curse_kill.vpcf", PATTACH_ABSORIGIN, self:GetParent())        
		ParticleManager:SetParticleControlEnt(particle_kill_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle_kill_fx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)    
		ParticleManager:SetParticleControlEnt(particle_kill_fx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(1,0,0), true)
		
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle(particle_kill_fx, false)
			ParticleManager:ReleaseParticleIndex(particle_kill_fx)
		end)
		

		local atalanta = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		for _, ata in pairs (atalanta) do
			if ata == caster and caster:IsAlive() then 
				local consume_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_energy_consume.vpcf", PATTACH_CUSTOMORIGIN, target)    
				ParticleManager:SetParticleControlEnt(consume_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(consume_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)    
				ParticleManager:SetParticleControl(consume_fx, 2, Vector(2000,0,0))

				local dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
				Timers:CreateTimer(math.max(dist/2000,0.1), function()
					ability:Energy(stacks)
					ParticleManager:DestroyParticle(consume_fx, true)
					ParticleManager:ReleaseParticleIndex(consume_fx)
				end)

				--[[if target:IsRealHero() and caster.CurseMoonAcquired then
					target:AddNewModifier(caster, ability, "modifier_atalanta_curse_vision", {Duration = ability:GetSpecialValueFor("vision")})
				end]]
				return nil
			end
		end
	end
end

----------------------------------------------------------------

modifier_atalanta_energy_curse_passive = class({})

function modifier_atalanta_energy_curse_passive:IsHidden() return false end
function modifier_atalanta_energy_curse_passive:IsDebuff() return false end
function modifier_atalanta_energy_curse_passive:IsPurgable() return false end
function modifier_atalanta_energy_curse_passive:RemoveOnDeath() return false end
function modifier_atalanta_energy_curse_passive:IsPassive() return true end
function modifier_atalanta_energy_curse_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_atalanta_energy_curse_passive:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_atalanta_energy_curse_passive:GetTexture()
    return "custom/alter_atalanta/atalanta_energy"
end

function modifier_atalanta_energy_curse_passive:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end

	local caster = self:GetParent()

	local curse_stacks = 1

	if caster:HasModifier("modifier_atalanta_evil_beast") then 
		curse_stacks = curse_stacks * 2 
	end

	for i = 1, curse_stacks do
		self:GetAbility():Curse(args.target)
	end

	if caster.EvolutionAcquired then 
		self:GetAbility():Energy(self:GetParent():FindAbilityByName("atalanta_passive_evolution"):GetSpecialValueFor("energy_gain"))
	end
end

---------------------------------------------------------

modifier_atalanta_evil_beast = class({})

function modifier_atalanta_evil_beast:IsHidden() return false end
function modifier_atalanta_evil_beast:IsDebuff() return false end
function modifier_atalanta_evil_beast:IsPermanent() return false end
function modifier_atalanta_evil_beast:RemoveOnDeath() return true end
function modifier_atalanta_evil_beast:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_atalanta_evil_beast:GetTexture()
    return "custom/alter_atalanta/atalanta_evil_beast"
end

if IsServer() then
	function modifier_atalanta_evil_beast:OnCreated(args)
		self:AttachParticle()
		self.ability = self:GetAbility() or self:GetCaster():FindAbilityByName(self:GetCaster().DSkill)
		--self.boar_fx = ParticleManager:CreateParticle("particles/atalanta/atalanta_alter_evil_boar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		--ParticleManager:SetParticleControl(self.boar_fx, 0, self:GetParent():GetAbsOrigin())
		--ParticleManager:SetParticleControlForward(self.boar_fx, 0, self:GetParent():GetForwardVector())
	end

	function modifier_atalanta_evil_beast:OnRefresh(args)
		self:DetachParticle()
		self:OnCreated(args)
	end

	function modifier_atalanta_evil_beast:OnDestroy()
		--ParticleManager:DestroyParticle(self.boar_fx, true)
		--ParticleManager:ReleaseParticleIndex(self.boar_fx)
		self:DetachParticle()
		self.ability:ResetEnergyStack(self:GetParent())
	end
end

function modifier_atalanta_evil_beast:AttachParticle()
	local caster = self:GetParent()

	self.particle = ParticleManager:CreateParticle("particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_immortal_ambient.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(self.particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(self.particle, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 3, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 4, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 5, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 6, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 7, caster:GetAbsOrigin())
end

function modifier_atalanta_evil_beast:DetachParticle()
	ParticleManager:DestroyParticle(self.particle, true)
	ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_atalanta_evil_beast:DeclareFunctions()
	local func = { MODIFIER_EVENT_ON_ATTACK_LANDED}
	if self:GetParent():HasModifier("modifier_atalanta_evolution") then 
		func = { MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
	end
	return func 
end

function modifier_atalanta_evil_beast:GetModifierDamageOutgoing_Percentage()
	local bonus_atk = self:GetParent():GetModifierStackCount("modifier_atalanta_energy_curse_passive", self:GetParent()) or 0
	return bonus_atk
end

function modifier_atalanta_evil_beast:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end

	local caster = self:GetParent()
	local target = args.target
	local angle = 120
	local radius = self:GetAbility():GetSpecialValueFor("evil_splash")
	local evil_dmg = self:GetAbility():GetSpecialValueFor("evil_dmg")
	local attack = caster:GetAverageTrueAttackDamage(caster)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do	
		if IsValidEntity(v) and not v:IsNull()then		
			--[[local caster_angle = caster:GetAnglesAsVector().y

			local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

			local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

			origin_difference_radian = origin_difference_radian * 180
			local enemy_angle = origin_difference_radian / math.pi

			enemy_angle = enemy_angle + 180.0

			if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
				enemy_angle = 360 - enemy_angle
			elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
				caster_angle = 360 - caster_angle 
			end

			local result_angle = math.abs(enemy_angle - caster_angle)

			if result_angle <= angle/2 then]]
				DoDamage(caster, v, evil_dmg, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				self:GetAbility():Curse(v)
				self:GetAbility():Curse(v)
				if v ~= target then 
					DoDamage(caster, v, attack, DAMAGE_TYPE_PHYSICAL, 0, self:GetAbility(), false)
				end
			--end
		end
	end
end

-----------------------

modifier_atalanta_curse_vision = class({})

function modifier_atalanta_curse_vision:IsHidden() return false end
function modifier_atalanta_curse_vision:IsDebuff() return true end
function modifier_atalanta_curse_vision:IsPermanent() return false end
function modifier_atalanta_curse_vision:RemoveOnDeath() return true end
function modifier_atalanta_curse_vision:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_atalanta_curse_vision:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end

function modifier_atalanta_evil_beast:GetTexture()
    return "custom/alter_atalanta/atalanta_vision"
end

function modifier_atalanta_curse_vision:GetModifierProvidesFOWVision()
	return 1
end

---------------------------

modifier_atalanta_curse_cooldown = class({})

function modifier_atalanta_curse_cooldown:IsHidden() return false end
function modifier_atalanta_curse_cooldown:IsDebuff() return true end
function modifier_atalanta_curse_cooldown:RemoveOnDeath() return false end
function modifier_atalanta_curse_cooldown:IsPurgable() return false end
function modifier_atalanta_curse_cooldown:RemoveOnDeath() return false end
function modifier_atalanta_curse_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end