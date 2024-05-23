heracles_courage = class({})

LinkLuaModifier("modifier_courage_self_buff", "abilities/heracles/modifiers/modifier_courage_self_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_courage_enemy_debuff", "abilities/heracles/modifiers/modifier_courage_enemy_debuff", LUA_MODIFIER_MOTION_NONE)

function heracles_courage:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function heracles_courage:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local radius = self:GetAOERadius()
	local modifier = caster:AddNewModifier(caster, self, "modifier_courage_self_buff", { Duration = self:GetSpecialValueFor("duration")})

	-- Apply stackable speed buff
	local currentStack = caster:GetModifierStackCount("modifier_courage_self_buff", self)
	if modifier then 
		currentStack = modifier:GetStackCount()	
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	for k,v in pairs(targets) do
		if not IsFacingUnit(v, caster, 90) then
			v:AddNewModifier(caster, self, "modifier_courage_enemy_debuff", { Stacks = currentStack,
																		  	  Duration = self:GetSpecialValueFor("enemy_duration") })
		end
	end 

	RemoveSlowEffect(caster)

	caster:EmitSound("Hero_Axe.Berserkers_Call")
	caster:EmitSound("Heracles_Roar_" .. math.random(1,6))

	-- Reduce Nine Lives cooldown if applicable
	if caster.IsEternalRageAcquired then
		ReduceCooldown(caster:FindAbilityByName("heracles_nine_lives"), 5)
	end	
end