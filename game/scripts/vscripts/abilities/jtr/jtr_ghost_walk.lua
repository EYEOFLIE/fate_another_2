function OnAbilityCastCheck (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition()
	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc)  then
		SendErrorMessage(caster:GetPlayerID(), "#Cannot_Travel")
		return 
	end 
	if IsLocked(caster) and not caster:HasModifier("modifier_jtr_whitechapel_self") then
		SendErrorMessage(caster:GetPlayerID(), "#Cannot_Blink")
        return
    end
end

function GhostWalkStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target_loc = ability:GetCursorPosition() 
	local origin = caster:GetAbsOrigin()
	local max_distance = ability:GetSpecialValueFor("distance")
	local min_distance = ability:GetSpecialValueFor("min_distance")
	
	if GridNav:IsBlocked(target_loc) or not GridNav:IsTraversable(target_loc)  then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	if caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") or IsLockedJTR(caster) then
		ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
        return
    end
	local distance = (target_loc - origin):Length2D()
	local forwardVec = (target_loc - origin):Normalized()
	if distance >= max_distance then 
		target_loc = origin + forwardVec * max_distance
		distance = max_distance
	elseif distance <= min_distance then 
		target_loc = origin + forwardVec * min_distance
		distance = min_distance
	end 
	local ghostwalk = {
		Ability = ability,
		EffectName = "",
		iMoveSpeed = 9999,
		vSpawnOrigin = origin,
		fDistance = distance,
		Source = caster,
		fStartRadius = 150,
        fEndRadius = 150,
		bHasFrontialCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.5,
		bDeleteOnHit = false,
		vVelocity = forwardVec * 9999,
	}
	local projectile = ProjectileManager:CreateLinearProjectile(ghostwalk)

	if caster:HasModifier("modifier_murderer_mist_invis") or caster:HasModifier("modifier_whitechapel_murderer") then 
		ability:EndCooldown() 
		ability:StartCooldown(ability:GetSpecialValueFor("cd_mist"))
	else
		local ghostwalkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start_meteor_smoke.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl(ghostwalkIndex, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ghostwalkIndex, 1, caster:GetAbsOrigin())	
		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( ghostwalkIndex, false )
			ParticleManager:ReleaseParticleIndex( ghostwalkIndex )
		end)
	end
	Timers:CreateTimer( 0.1, function()
		OnGhostWalkBlink (caster, target_loc, max_distance)
	end)
end

function GhostWalkHit (keys)
	if keys.target == nil then return end
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local base_dmg = ability:GetSpecialValueFor("base_dmg")

	DoDamage(caster, target, base_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	caster:PerformAttack( target, true, true, true, true, false, false, false )
	local slashIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
	Timers:CreateTimer(0.25, function()  
		ParticleManager:DestroyParticle(slashIndex, false)
		ParticleManager:ReleaseParticleIndex(slashIndex)
		return 
	end)
end

function OnGhostWalkBlink (hCaster, vTarget, fMaxDistance, tParams)

    local tParams = tParams or {}
    local sOutEffect = tParams.sInEffect or "particles/items_fx/blink_dagger_start.vpcf"
    local sInEffect = tParams.sOutEffect or "particles/items_fx/blink_dagger_end.vpcf"
    local sOutSound = tParams.sOutSound or "Hero_Antimage.Blink_out"
    local sInSound = tParams.sInSound or "Hero_Antimage.Blink_in"
    
    local bDodge = true
    if tParams.bDodgeProjectiles ~= nil then bDodge = tParams.bDodgeProjectiles end
    
    local bNavCheck = true
    if tParams.bNavCheck ~= nil then bNavCheck = tParams.bNavCheck end

    local vPos = hCaster:GetAbsOrigin()
    local vDifference = vTarget - vPos
    
    local vDirection = vDifference:Normalized()
    local fDistance = vDifference:Length()
    if fDistance >= fMaxDistance then fDistance = fMaxDistance end
    local vBlinkPos = vPos + (vDirection * fDistance)
    
    if bNavCheck then
		local i = 0
        local iStep = 10
        local iSteps = math.ceil(fDistance / iStep)

        while GridNav:IsBlocked( vBlinkPos ) or not GridNav:IsTraversable( vBlinkPos )do
            i = i + 1
            vBlinkPos = vPos + (vDirection * (fDistance - i * iStep))
            if i >= iSteps then break end
        end
    end

    ProjectileManager:ProjectileDodge(hCaster)
    FindClearSpaceForUnit(hCaster, vBlinkPos, true)
end
