LinkLuaModifier("modifier_atalanta_curse", "abilities/alter_atalanta/atalanta_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atalanta_curse_passive", "abilities/alter_atalanta/atalanta_curse", LUA_MODIFIER_MOTION_NONE)

atalanta_curse = class({})
atalanta_curse_upgrade = class({})

function atalanta_curse_wrapper(ability)
	function ability:GetIntrinsicModifierName()
		return "modifier_atalanta_curse_passive"
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		EmitGlobalSound("atalanta_skia_channel")
		Timers:CreateTimer(5.0, function()
			local units = FindUnitsInRadius(caster:GetTeam(),
	                                        caster:GetAbsOrigin(), 
	                                        nil, 
	                                        99999, 
	                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
	                                        DOTA_UNIT_TARGET_ALL, 
	                                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
	                                        0, 
	                                        false)
			for _,unit in pairs(units) do
				if not unit or unit:IsNull() or not unit:IsAlive() then return end
				unit:RemoveModifierByName("modifier_atalanta_curse")
	        end
	    end)
	    if caster:GetStrength() >= 24.1 and caster:GetAgility() >= 24.1 and caster:GetIntellect() >= 24.1 then		
				if caster:FindAbilityByName("atalanta_jump"):IsCooldownReady() and not caster:HasModifier("modifier_atalanta_skia_cd")  
					and caster:FindAbilityByName("atalanta_skia"):IsCooldownReady()  
			    	and caster:GetAbilityByIndex(2):GetName() == "atalanta_jump" then
					caster:SwapAbilities("atalanta_jump", "atalanta_skia", false, true)
					Timers:CreateTimer(4, function()
						caster:SwapAbilities("atalanta_jump", "atalanta_skia", true, false)
					end)
				end
			end
	end

	function ability:Curse(target)
		local caster = self:GetCaster()
		local stacks = 0
		local max_stack = self:GetSpecialValueFor("max_stack")

		if not target or not target:IsAlive() or target:IsNull() then return end

		if target:HasModifier("modifier_atalanta_curse") then
			stacks = target:FindModifierByName("modifier_atalanta_curse"):GetStackCount()
		end

		if stacks >= max_stack  then return end

		target:AddNewModifier(caster, self, "modifier_atalanta_curse", {duration = self:GetSpecialValueFor("duration")})
		target:FindModifierByName("modifier_atalanta_curse"):SetStackCount(stacks + 1)
	end
end

atalanta_curse_wrapper(atalanta_curse)
atalanta_curse_wrapper(atalanta_curse_upgrade)

modifier_atalanta_curse = class({})

function modifier_atalanta_curse:IsHidden() return false end
function modifier_atalanta_curse:IsDebuff() return true end
function modifier_atalanta_curse:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end

function modifier_atalanta_curse:GetTexture()
    return "custom/alter_atalanta/atalanta_curse_rofl"
end

function modifier_atalanta_curse:OnCreated()
	self.parent = self:GetParent()
	self.particle_4stacks = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_4stack.vpcf"
	if not self.particle_4stacks_fx then
        self.particle_4stacks_fx = ParticleManager:CreateParticle(self.particle_4stacks, PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControl(self.particle_4stacks_fx, 0, self.parent:GetAbsOrigin())
        self:AddParticle(self.particle_4stacks_fx, true, false, -1, false, false)        
    end
end

function modifier_atalanta_curse:GetModifierProvidesFOWVision()
	return self:CanBeDetected()
end

function modifier_atalanta_curse:CanBeDetected(hHero)
    if not (self:GetCaster().VisionAcquired and self:GetCaster():IsAlive() and self:GetStackCount() >= 10) or self:GetParent():HasModifier("modifier_murderer_mist_in") then
        return 0
    end
    
    return 1
end

function modifier_atalanta_curse:GetModifierIncomingDamage_Percentage(keys)
	if keys.attacker == self:GetCaster() then
		return self:GetStackCount()*(self:GetAbility():GetSpecialValueFor("amplify_per_stack"))*2
	else
		return self:GetStackCount()*(self:GetAbility():GetSpecialValueFor("amplify_per_stack"))
	end
end

function modifier_atalanta_curse:OnDestroy()
	local caster = self:GetCaster()
	local target = self:GetParent()

	local curse_skill = caster:FindAbilityByName("atalanta_curse_upgrade")
	if(curse_skill == nil) then
		curse_skill = caster:FindAbilityByName("atalanta_curse")
	end
	local dmgval = curse_skill:GetSpecialValueFor("detonate_damage")*self:GetStackCount()
	DoDamage(caster, target, dmgval, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_NON_LETHAL, curse_skill, false)


    local particle_kill = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_kill.vpcf"
	local particle_kill_fx = ParticleManager:CreateParticle(particle_kill, PATTACH_ABSORIGIN, self:GetParent())        
	ParticleManager:SetParticleControlEnt(particle_kill_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_kill_fx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)    
	ParticleManager:SetParticleControlEnt(particle_kill_fx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(1,0,0), true)
	ParticleManager:ReleaseParticleIndex(particle_kill_fx)
end

function modifier_atalanta_curse:OnTakeDamage(args)
	local caster = self:GetCaster()
	local target = self:GetParent()

	if not caster.EvolutionAcquired then return end
	if args.attacker ~= caster then return end
	if(  args.unit:GetTeam() == caster:GetTeam()) then return end
	if args.damage_type == 2 then
		caster:Heal(args.damage * 0.15, self:GetParent())
	end
end

modifier_atalanta_curse_passive = class({})

function modifier_atalanta_curse_passive:IsHidden() return false end
function modifier_atalanta_curse_passive:IsPermanent() return true end
function modifier_atalanta_curse_passive:RemoveOnDeath() return false end
function modifier_atalanta_curse_passive:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
end

--[[function modifier_atalanta_curse_passive:OnCreated()
	Timers:CreateTimer(0.1, function()
		self.parent = self:GetParent()
		local direction = self.parent:GetForwardVector()
		self.particle_modifier = "particles/hero/shadow_demon/shadow_demon_demonic_purge.vpcf"
		self.particle_modifier_fx = ParticleManager:CreateParticle(self.particle_modifier, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	    ParticleManager:SetParticleControl(self.particle_modifier_fx, 0, self.parent:GetAbsOrigin())
	    ParticleManager:SetParticleControl(self.particle_modifier_fx, 1, self.parent:GetAbsOrigin())
	    ParticleManager:SetParticleControl(self.particle_modifier_fx, 3, direction)
	    ParticleManager:SetParticleControl(self.particle_modifier_fx, 4, self.parent:GetAbsOrigin())
	    self:AddParticle(self.particle_modifier_fx, false, false, -1, false, false)
	end)
end]]

function modifier_atalanta_curse_passive:OnAttackLanded(args)
	if args.attacker ~= self:GetParent() then return end

	if self:GetParent().TornadoAcquired then
        local knockval = 0
        knockval = self:GetParent():FindAbilityByName("atalanta_passive_beast"):GetSpecialValueFor("attack_pull")
        local knockvalbonus = self:GetParent():FindAbilityByName("atalanta_passive_beast"):GetSpecialValueFor("attack_pull_from_curse")

		args.target:RemoveModifierByName("modifier_knockback")
		local knockback_pepega = (knockval + (args.target:HasModifier("modifier_atalanta_curse") and args.target:FindModifierByName("modifier_atalanta_curse"):GetStackCount() or 0)*knockvalbonus)
		 local knockback = { should_stun = false,
                        knockback_duration = 0.05,
                        duration = 0.05,
                        knockback_distance = -math.min(knockback_pepega, (args.attacker:GetAbsOrigin()-args.target:GetAbsOrigin()):Length2D()),
                        knockback_height = 0,
                        center_x = args.attacker:GetAbsOrigin().x,
                        center_y = args.attacker:GetAbsOrigin().y,
                        center_z = args.attacker:GetAbsOrigin().z }

		args.target:AddNewModifier(self:GetParent(), self, "modifier_knockback", knockback)
	end

	local caster = self:GetParent()
	local curse_skill = caster:FindAbilityByName("atalanta_curse_upgrade")
	if(curse_skill == nil) then
		curse_skill = caster:FindAbilityByName("atalanta_curse")
	end
	curse_skill:Curse(args.target)
end
