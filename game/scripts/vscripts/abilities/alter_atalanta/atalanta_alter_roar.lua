atalanta_alter_roar = class({})
atalanta_alter_roar_upgrade = class({})

modifier_roar_slow = class({})

LinkLuaModifier("modifier_roar_slow", "abilities/alter_atalanta/atalanta_alter_roar", LUA_MODIFIER_MOTION_NONE)

function atlanta_roar_wrapper(ability)
	function ability:OnAbilityPhaseStart()
	    self:GetCaster():EmitSound("atalanta_detonate")
	    return true
	end

	function ability:OnAbilityPhaseInterrupted()
	    self:GetCaster():StopSound("atalanta_detonate")
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		local startpoint = caster:GetAbsOrigin() + caster:GetForwardVector()*10
		local endpoint = caster:GetAbsOrigin() + caster:GetForwardVector()*self:GetSpecialValueFor("distance")
		local width = self:GetSpecialValueFor("width")

		local roar_fx = ParticleManager:CreateParticle("particles/atalanta/beastmaster_primal_roar.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl( roar_fx, 0, startpoint)
		ParticleManager:SetParticleControl( roar_fx, 1, endpoint)

		Timers:CreateTimer(2, function()
			ParticleManager:DestroyParticle(roar_fx, false)
			ParticleManager:ReleaseParticleIndex(roar_fx)
		end)

		local enemies = FindUnitsInLine(caster:GetTeam(), startpoint, endpoint, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0)

		local stacks = self:GetSpecialValueFor("base_stacks")
		if caster:HasModifier("modifier_atalanta_evil_beast") then
            stacks = stacks * 2
        end
		local damage = self:GetSpecialValueFor("base_damage") 
		local max_knock = self:GetSpecialValueFor("max_knock")

		if caster.EvolutionAcquired and enemies[1] ~= nil then 
			caster:FindAbilityByName(caster.DSkill):Energy(1)
		end

		for _,v in ipairs(enemies) do
			if not IsImmuneToSlow(v) and not IsImmuneToCC(v) then
				v:AddNewModifier(caster, self, "modifier_roar_slow", {duration = self:GetSpecialValueFor("duration")})
			end

			if caster:HasModifier("modifier_atalanta_evil_beast") then
				if not IsImmuneToCC(v) then
					v:AddNewModifier(caster, self, "modifier_stunned", {Duration = 0.1})
				end
			end

			if caster.WildBeastLogicAcquired then 
				if not v:IsMagicImmune() then 
					v:AddNewModifier(caster, self, "modifier_silence", {duration = self:GetSpecialValueFor("silence")})
				end
			end

			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)


			for i = 1,stacks do
				caster:FindAbilityByName(caster.DSkill):Curse(v)
			end	
		end
	end
end

atlanta_roar_wrapper(atalanta_alter_roar)
atlanta_roar_wrapper(atalanta_alter_roar_upgrade)

-------------------------------------

function modifier_roar_slow:IsDebuff() return true end
function modifier_roar_slow:IsHidden() return false end
function modifier_roar_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_roar_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_slow") 
end
function modifier_roar_slow:OnCreated()
	local particle_slow_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle_slow_fx, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 0))
	self:AddParticle(particle_slow_fx, false, false, -1, false, true)
end