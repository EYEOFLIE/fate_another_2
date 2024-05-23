mordred_clarent = class({})

function mordred_clarent:OnAbilityPhaseStart()
    EmitGlobalSound("mordred_clarent")
    return true
end

function mordred_clarent:OnAbilityPhaseInterrupted()
    StopGlobalSound("mordred_clarent")
end

function mordred_clarent:OnSpellStart()
	local caster = self:GetCaster()
	local targetPoint = self:GetCursorPosition()
	local ability = self
	local range = self:GetSpecialValueFor("range") - self:GetSpecialValueFor("width") -- We need this to take end radius of projectile into account
	--giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2)
	--StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_6, rate=1})
	local excal = 
	{
		Ability = self,
        EffectName = "",
        iMoveSpeed = self:GetSpecialValueFor("speed"),
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = range,
        fStartRadius = self:GetSpecialValueFor("width"),
        fEndRadius = self:GetSpecialValueFor("width"),
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * self:GetSpecialValueFor("speed")
	}		

	-- Create linear projectile
	Timers:CreateTimer(0.01, function()
		if caster:IsAlive() then
			excal.vSpawnOrigin = caster:GetAbsOrigin() 
			excal.vVelocity = caster:GetForwardVector() * self:GetSpecialValueFor("speed")
			local projectile = ProjectileManager:CreateLinearProjectile(excal)
			ScreenShake(caster:GetOrigin(), 5, 0.1, 2, 20000, 0, true)
		end
	end)
	
	-- for i=0,1 do
		Timers:CreateTimer(0.01, function() -- Adjust 2.5 to 3.2 to match the sound
			if caster:IsAlive() then
				-- Create Particle for projectile
				local casterFacing = caster:GetForwardVector()
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				dummy:SetForwardVector(casterFacing)
				Timers:CreateTimer( function()
						if IsValidEntity(dummy) then
							local newLoc = dummy:GetAbsOrigin() + self:GetSpecialValueFor("speed") * 0.03 * casterFacing
							dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
							-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.StartRadius, true, 0.15)
							return 0.03
						else
							return nil
						end
					end
				)
				
				local excalFxIndex = ParticleManager:CreateParticle( "particles/custom/mordred/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )
				ParticleManager:SetParticleControl(excalFxIndex, 4, Vector(self:GetSpecialValueFor("width"),0,0))

				Timers:CreateTimer( 1.65, function()
						ParticleManager:DestroyParticle( excalFxIndex, false )
						ParticleManager:ReleaseParticleIndex( excalFxIndex )
						Timers:CreateTimer( 0.5, function()
								dummy:RemoveSelf()
								return nil
							end
						)
						return nil
					end
				)
				return 
			end
		end)
end

function mordred_clarent:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
	if hTarget == nil then return end

	local caster = self:GetCaster()
	local target = hTarget 
	local damage = self:GetSpecialValueFor("damage") + caster:GetMaxMana()*self:GetSpecialValueFor("mana_percent")/100
	local arthur_bonus = damage * self:GetSpecialValueFor("arthur_bonus")/100 
	local ply = caster:GetPlayerOwner()
	if target:GetUnitName() == "gille_gigantic_horror" then damage = damage * 1.5 end
	if IsArthur(hTarget) then damage = damage + arthur_bonus end
	
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, self, false)
end