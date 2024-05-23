modifier_tres_fontaine_nero = class({})
if IsServer() then
	function modifier_tres_fontaine_nero:OnCreated(args)		
		self.DamageOnHit = args.DamageOnHit
		print(self.DamageOnHit)
		self.Radius = args.Radius
		self.AttackSound = args.AttackSound
		self.Interval = self:GetAbility():GetSpecialValueFor("interval_slash")
		self:StartIntervalThink(self.Interval)
	end

	function modifier_tres_fontaine_nero:OnIntervalThink()
		local caster = self:GetParent()
		local target_search = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		local continue_possible = true

		for i = 1, #target_search do
			if target_search[i]:HasModifier("modifier_tres_target_marker") then
				local diff = target_search[i]:GetAbsOrigin() - caster:GetAbsOrigin()
				local angle = VectorToAngles(diff:Normalized()).y
				if angle > 360 then 
					angle = angle - 360 
				end
				caster:SetAbsOrigin(target_search[i]:GetAbsOrigin() - diff:Normalized() * 100)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)				

				caster:PerformAttack(target_search[i], true, true, true, true, false, false, false)

				if self.AttackSound == 1 then
					caster:EmitSound("Nero_Attack_" .. math.random(1,4))
				end

				StartAnimation(caster, {duration = self.Interval, activity = ACT_DOTA_CAST_ABILITY_1_END, rate = 3})
				DoDamage(caster, target_search[i], self.DamageOnHit, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				CreateSlashFx(caster, GetRotationPoint(target_search[i]:GetAbsOrigin(),200,angle + 90), GetRotationPoint(target_search[i]:GetAbsOrigin(),200,angle - 90))
				target_search[i]:RemoveModifierByName("modifier_tres_target_marker")
				caster:EmitSound("Hero_EmberSpirit.Attack")
				break
			elseif i == #target_search then
				continue_possible = false
			end
		end

		if not continue_possible then
			self:Destroy()
		end
	end

	function modifier_tres_fontaine_nero:OnDestroy()	
		local caster = self:GetCaster()

		local ability = caster:FindAbilityByName("nero_tres_fontaine_ardent")
		if ability == nil then 
			ability = caster:FindAbilityByName("nero_tres_fontaine_ardent_upgrade")
		end
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))	
	end
end

function modifier_tres_fontaine_nero:CheckState()
	return { [MODIFIER_STATE_INVULNERABLE] = true,
			 [MODIFIER_STATE_NO_HEALTH_BAR]	= true,
			 [MODIFIER_STATE_STUNNED] = true,
			 [MODIFIER_STATE_SILENCED] = true,
			 [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
end

function modifier_tres_fontaine_nero:IsHidden()
	return true 
end

function modifier_tres_fontaine_nero:RemoveOnDeath()
	return true
end

function modifier_tres_fontaine_nero:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end