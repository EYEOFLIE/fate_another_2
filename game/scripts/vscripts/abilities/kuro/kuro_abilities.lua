
function SharingPainStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	
	KuroCheckCombo(caster,ability)
	if target:IsMagicImmune() or IsSpellBlocked(target) then return end
	caster.sharingpaintarget = target
	if target:GetTeam() == caster:GetTeam() then 
		if target == caster then 	
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_sharing_of_pain_tracker", {})
			ability:ApplyDataDrivenModifier(caster, caster.sharingpaintarget, "modifier_sharing_of_pain_ally_target", {})
		end
	else
		if caster.IsKuroMagicAcquired then 
			local mana_drain = ability:GetSpecialValueFor("mana_drain")
			local stun_duration = ability:GetSpecialValueFor("stun_duration")
			if not IsManaLess(target) then
				local current_mana = caster.sharingpaintarget:GetMana()
				local mana_loss = caster.sharingpaintarget:GetMaxMana() * mana_drain / 100
				if current_mana >= mana_loss then 
					caster.sharingpaintarget:SetMana(current_mana - mana_loss)
					caster:SetMana(caster:GetMana() + mana_loss)
				elseif current_mana < mana_loss then 
					caster.sharingpaintarget:SetMana(1)
					caster:SetMana(caster:GetMana() + current_mana)
				end
				target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
			end
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_sharing_of_pain_tracker", {})
		ability:ApplyDataDrivenModifier(caster, caster.sharingpaintarget, "modifier_sharing_of_pain_enemy_target", {})
	end	
end 

function SharingPainTrackingDamage (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	
	if caster.sharingpaintarget:IsMagicImmune() or IsSpellBlocked(caster.sharingpaintarget) then return end
	if caster.sharingpaintarget:HasModifier("modifier_sharing_of_pain_enemy_target") then
		local dmg_ratio = ability:GetSpecialValueFor("dmg_ratio") / 100
		DoDamage(caster, caster.sharingpaintarget, keys.DamageTaken * dmg_ratio, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, ability, false)
	elseif caster.sharingpaintarget:HasModifier("modifier_sharing_of_pain_ally_target") then
		local ally_ratio = ability:GetSpecialValueFor("ally_ratio") / 100
		if caster:GetHealth() > keys.DamageTaken * ally_ratio then 
			caster:Heal(keys.DamageTaken * ally_ratio, caster)
			if caster.sharingpaintarget:GetHealth() > keys.DamageTaken * ally_ratio then
				DoDamage(caster, caster.sharingpaintarget, keys.DamageTaken * ally_ratio, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, ability, false)
			else
				caster.sharingpaintarget:SetHealth(1)
				if caster.sharingpaintarget:HasModifier("modifier_sharing_of_pain_ally_target") then
					caster.sharingpaintarget:RemoveModifierByName("modifier_sharing_of_pain_ally_target")
				end
			end
		end
	end
end

function SharingPainCreate (keys)
	--[[local caster = keys.caster 
	local ability = keys.ability 
	caster.sharingpainFx1 = ParticleManager:CreateParticle( "particles/custom/kuro/kuro_sharing_pain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( caster.sharingpainFx1, 0, caster:GetAbsOrigin() )
	caster.sharingpainFx2 = ParticleManager:CreateParticle( "particles/custom/kuro/kuro_sharing_pain.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.sharingpaintarget )
	ParticleManager:SetParticleControl( caster.sharingpainFx2, 0, caster.sharingpaintarget:GetAbsOrigin() )]]
end

function SharingPainDestroy (keys)
	--[[local caster = keys.caster 
	if caster.sharingpaintarget:GetTeam() == caster:GetTeam() then 
		if caster.sharingpaintarget:HasModifier("modifier_sharing_of_pain_ally_target") then
			caster.sharingpaintarget:RemoveModifierByName("modifier_sharing_of_pain_ally_target")
		end
	else
		if caster.sharingpaintarget:HasModifier("modifier_sharing_of_pain_enemy_target") then
			caster.sharingpaintarget:RemoveModifierByName("modifier_sharing_of_pain_enemy_target")
		end
	end
	ParticleManager:DestroyParticle( caster.sharingpainFx1, false )
	ParticleManager:ReleaseParticleIndex( caster.sharingpainFx1 )]]
end

function SharingPainTargetDestroy (keys)
	--[[local caster = keys.caster 
	ParticleManager:DestroyParticle( caster.sharingpainFx2, false )
	ParticleManager:ReleaseParticleIndex( caster.sharingpainFx2 )]]
	--print('Remove SharingPain Fx')
end

function FarSightVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local radius = keys.ability:GetSpecialValueFor("radius")
	local duration = keys.ability:GetSpecialValueFor("duration")
	local targetLoc = keys.target_points[1]

	local visiondummy = SpawnVisionDummy(caster, targetLoc, radius, keys.Duration, false)
	
	if caster.IsEagleEyeAcquired then 
		SpawnVisionDummy(caster, targetLoc, radius, duration, true)
	end

	if caster.IsHruntingAcquired and not caster:HasModifier("modifier_hrunting_cooldown") then 
		if caster.IsEagleEyeAcquired then 
			if caster:FindAbilityByName("kuro_hrunting_upgrade"):IsCooldownReady() then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_kuro_hrunting_window", {})
			end
		else
			if caster:FindAbilityByName("kuro_hrunting"):IsCooldownReady() then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_kuro_hrunting_window", {})
			end
		end
	end
	
	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	ParticleManager:SetParticleControl( circleFxIndex, 3, Vector( 100, 255, 255 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	visiondummy.circle_fx = circleFxIndex
	visiondummy.dust_fx = dustFxIndex
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
			
	-- Destroy particle after delay
	Timers:CreateTimer( duration, function()
			ParticleManager:DestroyParticle( circleFxIndex, false )
			ParticleManager:DestroyParticle( dustFxIndex, false )
			ParticleManager:ReleaseParticleIndex( circleFxIndex )
			ParticleManager:ReleaseParticleIndex( dustFxIndex )
			return nil
		end
	)

    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
        	AddFOWViewer(playerHero:GetTeamNumber(), targetLoc, 50, 0.5, false)
        	
        end
    end)
	-- Particles
	--visiondummy:EmitSound("Hero_KeeperOfTheLight.BlindingLight") 
	Timers:CreateTimer(0.033, function()
		EmitSoundOnLocationWithCaster(targetLoc, "Hero_KeeperOfTheLight.BlindingLight", visiondummy)
	end)		
end

function OnHruntingWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsEagleEyeAcquired then
		caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_hrunting_upgrade", false, true) 
	else
		caster:SwapAbilities("kuro_clairvoyance", "kuro_hrunting", false, true) 
	end
end

function OnHruntingWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsEagleEyeAcquired then
		caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_hrunting_upgrade", true, false) 
	else
		caster:SwapAbilities("kuro_clairvoyance", "kuro_hrunting", true, false) 
	end
end

function OnHruntingWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_kuro_hrunting_window")
end

function OnBowCreate(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:GetName() == "npc_dota_hero_naga_siren" then 
		if caster:ScriptLookupAttachment("attach_attack1") ~= nil then 
			if caster:HasModifier("modifier_alternate_01") then
				local kanshou = Attachments:GetCurrentAttachment(caster, "attach_attack1")
				if kanshou ~= nil and not kanshou:IsNull() then
					kanshou:RemoveSelf()
				end
				local bakuya = Attachments:GetCurrentAttachment(caster, "attach_attack2")
				if bakuya ~= nil and not bakuya:IsNull() then
					bakuya:RemoveSelf()
				end
			end
			if string.match(ability:GetAbilityName(), "kuro_hrunting") or string.match(ability:GetAbilityName(), "kuro_calabolg") then
				Attachments:AttachProp(caster, "attach_bow", "models/kuro/kuro_bow.vmdl")
			end
		end
	end
end

function OnBowDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster:GetName() == "npc_dota_hero_naga_siren" then 
		if caster:ScriptLookupAttachment("attach_attack1") ~= nil then 
			if caster:HasModifier("modifier_alternate_01") then
				Attachments:AttachProp(caster, "attach_attack1", "models/archer/kanshou.vmdl")
				Attachments:AttachProp(caster, "attach_attack2", "models/archer/byakuya.vmdl")
			end
			if string.match(ability:GetAbilityName(), "kuro_hrunting") or string.match(ability:GetAbilityName(), "kuro_calabolg") then
				local bow = Attachments:GetCurrentAttachment(caster, "attach_bow")
				if bow ~= nil and not bow:IsNull() then
					bow:RemoveSelf()
				end
			end
		end
	end
end

function OnHruntingFilter (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target")
	end
end

function OnHruntCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability.target =target
	local ply = caster:GetPlayerOwner()

	ability:EndCooldown()
	-- Show hrunting cast
	if caster.hrunting_particle ~= nil then
		ParticleManager:DestroyParticle( caster.hrunting_particle, false )
		ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
	end
	Timers:CreateTimer(4.0, function() 
		if caster.hrunting_particle ~= nil then
			ParticleManager:DestroyParticle( caster.hrunting_particle, false )
			ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
		end
		return
	end)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bow", {})
	caster.hrunting_particle = ParticleManager:CreateParticle( "particles/econ/events/ti4/teleport_end_ti4.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( caster.hrunting_particle, 2, Vector( 255, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(caster.hrunting_particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(caster.hrunting_particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	caster.hruntingCrosshead = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hrunting_tracker", {Duration=ability:GetSpecialValueFor("cast_delay") - 0.04})
	if target:IsHero() then
		Say(ply, "Hrunting targets " .. FindName(target:GetName()) .. ".", true)
	end
end

function OnHruntStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.target
	if caster:HasModifier("modifier_hrunting_tracker") then 
		OnHruntInterrupted(keys)
		return nil 
	end
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.hruntingCrosshead, true)
	if not caster:CanEntityBeSeenByMyTeam(target) or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
		Say(ply, "Hrunting failed.", true)
		return 
	end
	local base_damage = ability:GetSpecialValueFor("damage")
	local mana_used = ability:GetSpecialValueFor("mana_used")
	ability:StartCooldown(ability:GetCooldown(1))
	EmitGlobalSound("chloe_broken")
	local mana_use = caster:GetMana() * mana_used / 100
	
	caster:RemoveModifierByName("modifier_kuro_hrunting_window")
	caster:RemoveModifierByName("modifier_bow")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hrunting_cooldown", {duration=ability:GetCooldown(1)})
	caster.HruntDamage =  base_damage + mana_use

	caster:SetMana(caster:GetMana() - mana_use) 
	caster.hrunting_bounce = 0
	
	local info = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/custom/archer/archer_hrunting_orb.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 3000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDodgeable = false
	}

	ProjectileManager:CreateTrackingProjectile(info) 
	-- give vision for enemy
	if IsValidEntity(target) then
		SpawnVisionDummy(target, caster:GetAbsOrigin(), 500, 3, false)
	end
	--EmitGlobalSound("Archer.Hrunting_Fireoff")
	--caster:EmitSound("Emiya_Hrunt2")
	if target:IsHero() then
		Say(ply, "Hrunting fired at " .. FindName(target:GetName()) .. ".", true)
	end
end

function OnHruntInterrupted(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle( caster.hrunting_particle, false )
	ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
	ParticleManager:DestroyParticle(caster.hruntingCrosshead, true)
	caster:RemoveModifierByName("modifier_bow")
	Say(ply, "Hrunting failed.", true)
end

function OnHruntHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	keys.target:EmitSound("Archer.HruntHit")
	local caster = keys.caster
	
	local ability = keys.ability
	-- Create Particle
	local explosionParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_hrunting_area.vpcf", PATTACH_CUSTOMORIGIN, keys.target )
	ParticleManager:SetParticleControl( explosionParticleIndex, 0, keys.target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( explosionParticleIndex, 1, Vector( 200, 200, 0 ) )
	
	-- Destroy Particle
	Timers:CreateTimer( 1.0, function()
		ParticleManager:DestroyParticle( explosionParticleIndex, false )
		ParticleManager:ReleaseParticleIndex( explosionParticleIndex )
		return nil
	end)
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local bounce_damage = ability:GetSpecialValueFor("bounce_damage") / 100
	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
	
	DoDamage(caster, target, caster.HruntDamage * (bounce_damage ^ caster.hrunting_bounce), DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
	--[[if caster.hrunting_bounce == 0 then
		DoDamage(caster, target, caster.HruntDamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	elseif caster.hrunting_bounce == 1 then
		DoDamage(caster, target, caster.HruntDamage * bounce_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	elseif caster.hrunting_bounce == 2 then
		DoDamage(caster, target, caster.HruntDamage * bounce_damage * bounce_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end]]
	local max_bounce = ability:GetSpecialValueFor("max_bounce")
	local radius = ability:GetSpecialValueFor("radius")
	if caster.hrunting_bounce < max_bounce then
        local hBounceTarget = nil

        local tTargets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
        for i=1, #tTargets do
            if tTargets[i] ~= target then
                hBounceTarget = tTargets[i]
                break
            end
        end

        if hBounceTarget ~= nil then
			FireProjectile(hBounceTarget, target, ability)
			caster.hrunting_bounce = caster.hrunting_bounce + 1

        end
    end	
end

function FireProjectile(hTarget, hSource, ability)

    local tProjectile = {
        Target = hTarget,
        Source = hSource,
        Ability = ability,
        EffectName = "particles/custom/archer/archer_hrunting_orb.vpcf",
        iMoveSpeed = 3000,
        vSourceLoc = hSource:GetAbsOrigin(),
        bDodgeable = false,
        flExpireTime = GameRules:GetGameTime() + 10,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    ProjectileManager:CreateTrackingProjectile(tProjectile)
end

function KanshouByakuyaStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_destination = ability:GetCursorPosition()

	if caster.IsUBWActive and caster.IsUBWActive == true then
		ability:EndCooldown()
		ability:StartCooldown(1.0)
	end

	local ply = caster:GetPlayerOwner()
	local forward = (target_destination - caster:GetAbsOrigin()):Normalized()
	local origin = caster:GetAbsOrigin()
	local num_blade = ability:GetSpecialValueFor("num_blade")
	local speed = 1350
	local angle = caster:GetAnglesAsVector().y

	-- Defaults the crossing point to 600 range in front of where Emiya is facing
	if (math.abs(target_destination.x - origin.x) < 500) and (math.abs(target_destination.y - origin.y) < 500) then
		target_destination = GetRotationPoint(target_destination, 500, angle)
	end

	local lsword_origin = GetRotationPoint(origin, 100, angle - 30)
	local left_forward = (target_destination - lsword_origin):Normalized()
	local rsword_origin = GetRotationPoint(origin, 100, angle + 30)
	local right_forward = (target_destination - rsword_origin):Normalized()	

	caster:EmitSound("chloe_crane_" .. math.random(1,3))

	--Left Sword
	local timeL = 0.05
	for i = 1, num_blade/2 do		
		Timers:CreateTimer(timeL, function()
			if not caster:IsAlive() then return end
			lsword_origin = GetRotationPoint(caster:GetAbsOrigin(), 100, angle - 30)
			left_forward = (target_destination - lsword_origin):Normalized()
			KBFireSword(lsword_origin, left_forward, ability, caster, speed, 1)
		end)
		timeL = timeL + 0.4		
	end

	-- Right Sword
	local timeR = 0.25
	for j = 1, num_blade/2 do		
		Timers:CreateTimer(timeR, function()
			if not caster:IsAlive() then return end
			rsword_origin = GetRotationPoint(caster:GetAbsOrigin(), 100, angle + 30)
			right_forward = (target_destination - rsword_origin):Normalized()	
	
			KBFireSword(rsword_origin, right_forward, ability, caster, speed, 2)
		end)
		timeR = timeR + 0.4		
	end

end

function KBFireSword(origin, forwardVec, ability, caster, speed, iSword)
	local aoe = ability:GetSpecialValueFor("sword_aoe")
	local range = ability:GetSpecialValueFor("range")
	local particle = "particles/custom/archer/archer_byakuya.vpcf"	
	if iSword == 2 then
		particle = "particles/custom/archer/archer_kanshou.vpcf"	
	end
	local duration = range / speed

    local projectileTable = {
		Ability = ability,
		EffectName = particle,
		vSpawnOrigin = origin + Vector(0,0,50),
		fDistance = range,
		Source = caster,
		fStartRadius = aoe,
        fEndRadius = aoe,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + duration,
		bDeleteOnHit = false,
		vVelocity = forwardVec * speed,		
	}

    local projectile = ProjectileManager:CreateLinearProjectile(projectileTable)

    caster:EmitSound("Hero_Luna.Attack")
end

function OnKBHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end

	--for k,v in pairs(tData) do print(k,v) end

	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(KBHitFx, 0, target:GetAbsOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( KBHitFx, false )
		ParticleManager:ReleaseParticleIndex( KBHitFx )
	end)

	target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
		if caster.IsOveredgeAcquired then
			local overedge_count = ability:GetSpecialValueFor("overedge_count")
			local overedge_stack = target:GetModifierStackCount("modifier_overedge_stack", caster) or 0
			ability:ApplyDataDrivenModifier(caster, target, "modifier_overedge_stack", {})
			target:SetModifierStackCount("modifier_overedge_stack", caster, overedge_stack + 1)

			if target:GetModifierStackCount("modifier_overedge_stack", caster) >= overedge_count then
				local bonus_damage = ability:GetSpecialValueFor("overedge_damage")
				local bonus_stun = ability:GetSpecialValueFor("overedge_stun")
				target:RemoveModifierByName("modifier_overedge_stack")
				if not target:IsMagicImmune() and not IsSpellBlocked(target) and not IsImmuneToCC(target) then
					target:AddNewModifier(caster, nil, "modifier_stunned", {duration = bonus_stun})
				end
				DoDamage(caster, target, bonus_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				
			end
		end
	end
end

function OnCraneWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_crane_wing", false, true) 
end

function OnCraneWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_crane_wing", true, false)
end

function OnCraneWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_crane_wing_window")
end

function OnCraneWingStart (keys)
	local caster = keys.caster 
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local dist = (caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6
	local castRange = keys.castRange
	local damage = ability:GetSpecialValueFor("damage")

	-- When you exit the ubw on the last moment, dist is going to be a pretty high number, since the targetPoint is on ubw but you are outside it
	-- If it's, then we can't use it like that. Either cancel Overedge, or use a default one.
	-- 2000 is a fixedNumber, just to check if dist is not valid. Over 2000 is surely wrong. (Max is close to 900)
	if dist > 2000 then
		dist = 600 --Default one
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	caster:RemoveModifierByName("modifier_crane_wing_window")
	caster:RemoveModifierByName("modifier_crane_wing_stack")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_crane_cooldown", {})
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
    local archer = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 850))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-2666))

    local soundQueue = math.random(1,3)

	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 

	StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.8})

	local stacks = 0

	if caster.IsOveredgeAcquired then 
		damage = damage + 300
		caster:RemoveModifierByName("modifier_crane_cooldown")
		ability:EndCooldown()
	end

	--[[if caster:HasModifier("modifier_kanshou_byakuya_stock") then
	stacks = caster:GetModifierStackCount("modifier_kanshou_byakuya_stock", keys.ability)
	caster:RemoveModifierByName("modifier_kanshou_byakuya_stock") 
	damage = damage * (1 + 0.17 * stacks)
	caster:GiveMana(stacks * 70)
	end]]

	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		caster:EmitSound("Hero_Centaur.DoubleEdge") 
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	-- Create particles
		-- Variable for cross slash
		local origin = caster:GetAbsOrigin()
		local forwardVec = caster:GetForwardVector()
		local rightVec = caster:GetRightVector()
		local backPoint1 = origin - keys.Radius * forwardVec + keys.Radius * rightVec
		local backPoint2 = origin - keys.Radius * forwardVec - keys.Radius * rightVec
		local frontPoint1 = origin + keys.Radius * forwardVec - keys.Radius * rightVec
		local frontPoint2 = origin + keys.Radius * forwardVec + keys.Radius * rightVec
		backPoint1.z = backPoint1.z + 250
		backPoint2.z = backPoint2.z + 250

	-- Variable for vertical slash
		--[[local origin = caster:GetAbsOrigin()
		local forwardVec = caster:GetForwardVector()
		local rightVec = caster:GetRightVector()
		local backPoint1 = origin - 200 * forwardVec + 150 * rightVec
		local backPoint2 = origin - 200 * forwardVec - 150 * rightVec
		local frontPoint1 = origin + 200 * forwardVec + 50 * rightVec
		local frontPoint2 = origin + 200 * forwardVec - 50 * rightVec
		backPoint1.z = backPoint1.z + 250
		backPoint2.z = backPoint2.z + 250]]
		
	-- Cross slash
		local slash1ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( slash1ParticleIndex, 2, backPoint1 )
		ParticleManager:SetParticleControl( slash1ParticleIndex, 3, frontPoint1 )
	
		local slash2ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( slash2ParticleIndex, 2, backPoint2 )
		ParticleManager:SetParticleControl( slash2ParticleIndex, 3, frontPoint2 )
		
	-- Stomp
		local stompParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( stompParticleIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( stompParticleIndex, 1, Vector( keys.Radius, keys.Radius, keys.Radius ) )
		
	-- Destroy particle
		Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( slash1ParticleIndex, false )
			ParticleManager:DestroyParticle( slash2ParticleIndex, false )
			ParticleManager:DestroyParticle( stompParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( slash1ParticleIndex )
			ParticleManager:ReleaseParticleIndex( slash2ParticleIndex )
			ParticleManager:ReleaseParticleIndex( stompParticleIndex )
		end)
		
        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	       	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    end
	end})
end

function OnBPUpgrade (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if caster.IsHruntingAcquired then 
		if caster.IsEagleEyeAcquired then
			caster:FindAbilityByName("kuro_hrunting_upgrade"):SetLevel(ability:GetLevel())
		else
			caster:FindAbilityByName("kuro_hrunting"):SetLevel(ability:GetLevel())
		end
	end
end

function OnBPCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability.target = target
	local ply = caster:GetPlayerOwner()
	ability:EndCooldown()
	caster:GiveMana(ability:GetManaCost(1))

	caster.BPparticle = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_bow", {})
	ParticleManager:SetParticleControl( caster.BPparticle, 0, target:GetAbsOrigin() + Vector(0,0,100)) 
	ParticleManager:SetParticleControl( caster.BPparticle, 1, target:GetAbsOrigin() + Vector(0,0,100)) 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bp_tracker", {Duration=ability:GetSpecialValueFor("cast_delay") - 0.04})
	if target:IsHero() then
		Say(ply, "Calabolg III targets " .. FindName(target:GetName()) .. ".", true)
	end
end

function OnBPStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.target
	if caster:HasModifier("modifier_bp_tracker") then 
		OnBPInterrupted(keys)
		return nil 
	end
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.BPparticle, true)
	caster:RemoveModifierByName("modifier_bow")
	if not caster:CanEntityBeSeenByMyTeam(target) or caster:GetRangeToUnit(target) > 4500 or caster:GetMana() < ability:GetManaCost(1) or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
		Say(ply, "Calabolg III failed.", true)
		return 
	end

	ability:StartCooldown(ability:GetCooldown(1))
	caster:SetMana(caster:GetMana() - ability:GetManaCost(1))
	local info = {
		Target = target,
		Source = caster, 
		Ability = ability,
		EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 3000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDodgeable = true
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	caster:EmitSound("chloe_broken")
	-- give vision for enemy
	if IsValidEntity(target) then
		SpawnVisionDummy(target, caster:GetAbsOrigin(), 500, 3, false)
	end
	
	if target:IsHero() then
		Say(ply, "Calabolg III fired at " .. FindName(target:GetName()) .. ".", true)
	end
end

function OnBPInterrupted(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.BPparticle, true)
	caster:RemoveModifierByName("modifier_bow")
	Say(ply, "Calabolg III failed.", true)
end

function OnBPHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	
	local ability = keys.ability
	keys.target:EmitSound("Misc.Crash")
	local total_damage = ability:GetSpecialValueFor("total_damage")
	local splash_damage = ability:GetSpecialValueFor("splash_damage")

	local BpHitFx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(BpHitFx, 3, target:GetAbsOrigin())

	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = keys.StunDuration})
	end

	DoDamage(caster, target, total_damage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, ability, false)

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if IsValidEntity(v) and not v:IsNull() and v ~= target then
        	DoDamage(caster, v, splash_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        end
    end

	--ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()) -- target location
	Timers:CreateTimer( 2, function()
		ParticleManager:DestroyParticle( BpHitFx, false )
		ParticleManager:ReleaseParticleIndex( BpHitFx )
	end)

	
end

function OnProjectStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_kuro_project_check", {})
	caster.IsProject = false
	ability:EndCooldown()
end

function OnProjectUpgrade (keys)
	local caster = keys.caster 
	if caster.IsImproveProjectionAcquired then
		caster:FindAbilityByName("kuro_excalibur_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_gae_bolg_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_fake_nine_live_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_rho_aias_upgrade"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_rosa_ichthys_upgrade"):SetLevel(keys.ability:GetLevel())
	else
		caster:FindAbilityByName("kuro_excalibur"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_gae_bolg"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_fake_nine_live"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_rho_aias"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("kuro_rosa_ichthys"):SetLevel(keys.ability:GetLevel())
	end
end

function OnProjectOpen (keys)
	local caster = keys.caster
	local ability = keys.ability 
	-- window

	if caster:HasModifier("modifier_fake_ubw_window") then 
		caster:RemoveModifierByName("modifier_fake_ubw_window")
	end
	if caster:HasModifier("modifier_kuro_hrunting_window") then 
		caster:RemoveModifierByName("modifier_kuro_hrunting_window")
	end
	if caster.IsImproveProjectionAcquired then
		if caster.IsOveredgeAcquired then 
			caster:SwapAbilities("kuro_kanshou_byakuya_upgrade", "kuro_excalibur_upgrade", false, true)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_nine_live_upgrade", false, true)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_nine_live_upgrade", false, true)
			end
		else
			caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_excalibur_upgrade", false, true)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_nine_live_upgrade", false, true)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_nine_live_upgrade", false, true)
			end
		end
		if caster.IsEagleEyeAcquired then
			caster:SwapAbilities("kuro_calabolg_upgrade", "kuro_gae_bolg_upgrade", false, true)
			caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_projection_close", false, true)
		else
			caster:SwapAbilities("kuro_calabolg", "kuro_gae_bolg_upgrade", false, true)
			caster:SwapAbilities("kuro_clairvoyance", "kuro_projection_close", false, true)
		end
		if caster.IsKuroMagicAcquired then 
			caster:SwapAbilities("kuro_sharing_pain_upgrade", "kuro_rho_aias_upgrade", false, true)
		else
			caster:SwapAbilities("kuro_sharing_pain", "kuro_rho_aias_upgrade", false, true)
		end
		caster:SwapAbilities("kuro_projection_upgrade", "kuro_rosa_ichthys_upgrade", false, true)	
	else
		if caster.IsOveredgeAcquired then 
			caster:SwapAbilities("kuro_kanshou_byakuya_upgrade", "kuro_excalibur", false, true)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_nine_live", false, true)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_nine_live", false, true)
			end
		else
			caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_excalibur", false, true)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_nine_live", false, true)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_nine_live", false, true)
			end
		end
		if caster.IsEagleEyeAcquired then
			caster:SwapAbilities("kuro_calabolg_upgrade", "kuro_gae_bolg", false, true)
			caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_projection_close", false, true)
		else
			caster:SwapAbilities("kuro_calabolg", "kuro_gae_bolg", false, true)
			caster:SwapAbilities("kuro_clairvoyance", "kuro_projection_close", false, true)
		end
		if caster.IsKuroMagicAcquired then 
			caster:SwapAbilities("kuro_sharing_pain_upgrade", "kuro_rho_aias", false, true)
		else
			caster:SwapAbilities("kuro_sharing_pain", "kuro_rho_aias", false, true)
		end
		caster:SwapAbilities("kuro_projection", "kuro_rosa_ichthys", false, true)
	end
end

function OnProjectClose (keys)
	local caster = keys.caster
	local ability = keys.ability 

	if caster.IsImproveProjectionAcquired then
		if caster.IsOveredgeAcquired then 
			caster:SwapAbilities("kuro_kanshou_byakuya_upgrade", "kuro_excalibur_upgrade", true, false)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_nine_live_upgrade", true, false)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_nine_live_upgrade", true, false)
			end
		else
			caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_excalibur_upgrade", true, false)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_nine_live_upgrade", true, false)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_nine_live_upgrade", true, false)
			end
		end
		if caster.IsEagleEyeAcquired then
			caster:SwapAbilities("kuro_calabolg_upgrade", "kuro_gae_bolg_upgrade", true, false)
			caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_projection_close", true, false)
		else
			caster:SwapAbilities("kuro_calabolg", "kuro_gae_bolg_upgrade", true, false)
			caster:SwapAbilities("kuro_clairvoyance", "kuro_projection_close", true, false)
		end
		if caster.IsKuroMagicAcquired then 
			caster:SwapAbilities("kuro_sharing_pain_upgrade", "kuro_rho_aias_upgrade", true, false)
		else
			caster:SwapAbilities("kuro_sharing_pain", "kuro_rho_aias_upgrade", true, false)
		end
		caster:SwapAbilities("kuro_projection_upgrade", "kuro_rosa_ichthys_upgrade", true, false)	
	else
		if caster.IsOveredgeAcquired then 
			caster:SwapAbilities("kuro_kanshou_byakuya_upgrade", "kuro_excalibur", true, false)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_nine_live", true, false)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_nine_live", true, false)
			end
		else
			caster:SwapAbilities("kuro_kanshou_byakuya", "kuro_excalibur", true, false)
			if caster.IsKuroMagicAcquired then
				caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_nine_live", true, false)
			else
				caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_nine_live", true, false)
			end
		end
		if caster.IsEagleEyeAcquired then
			caster:SwapAbilities("kuro_calabolg_upgrade", "kuro_gae_bolg", true, false)
			caster:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_projection_close", true, false)
		else
			caster:SwapAbilities("kuro_calabolg", "kuro_gae_bolg", true, false)
			caster:SwapAbilities("kuro_clairvoyance", "kuro_projection_close", true, false)
		end
		if caster.IsKuroMagicAcquired then 
			caster:SwapAbilities("kuro_sharing_pain_upgrade", "kuro_rho_aias", true, false)
		else
			caster:SwapAbilities("kuro_sharing_pain", "kuro_rho_aias", true, false)
		end
		caster:SwapAbilities("kuro_projection", "kuro_rosa_ichthys", true, false)
	end

	if caster.IsProject == true and not caster.IsImproveProjectionAcquired then 
		caster:FindAbilityByName("kuro_projection"):StartCooldown(caster:FindAbilityByName("kuro_projection"):GetCooldown(1))
	end
end

function OnProjectCloseStart (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_kuro_project_check")
end

function OnExcaliburVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound("chloe_excalibur_sfx")
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
end

function OnExcaliburSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end


function OnExcaliburStart(keys)
	EmitGlobalSound("chloe_excalibur")
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	keys.Range = keys.Range - keys.EndRadius + 100 -- We need this to take end radius of projectile into account
	caster.IsProject = true
	if not caster.IsImproveProjectionAcquired then 
		caster:RemoveModifierByName("modifier_kuro_project_check")
	end
	local pause_duration = ability:GetSpecialValueFor("pause_duration")
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", pause_duration)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur", {})
	ability:ApplyDataDrivenModifier(caster, caster, "saber_anim_vfx", {})
	local excal = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = keys.Range,
        fStartRadius = keys.StartRadius,
        fEndRadius = keys.EndRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	
	--EmitGlobalSound("Saber_Ex") 		

	Timers:CreateTimer(keys.Delay - 0.5, function() 
		if caster:IsAlive() then
			--EmitGlobalSound("Saber_Kalibar") return 
		end
	end)

	-- Create linear projectile
	Timers:CreateTimer(keys.Delay - 0.3, function()
		if caster:IsAlive() then
			excal.vSpawnOrigin = caster:GetAbsOrigin() 
			excal.vVelocity = caster:GetForwardVector() * keys.Speed
			local projectile = ProjectileManager:CreateLinearProjectile(excal)
		end
	end)
	
	-- for i=0,1 do
		Timers:CreateTimer(keys.Delay - 0.3, function() -- Adjust 2.5 to 3.2 to match the sound
			if caster:IsAlive() then
				-- Create Particle for projectile
				local casterFacing = caster:GetForwardVector()
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				dummy:SetForwardVector(casterFacing)
				Timers:CreateTimer( function()
						if IsValidEntity(dummy) then
							local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * casterFacing
							dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
							-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.StartRadius, true, 0.15)
							return 0.03
						else
							return nil
						end
					end
				)
				
				local excalFxIndex = ParticleManager:CreateParticle( "particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )
				ParticleManager:SetParticleControl(excalFxIndex, 4, Vector(keys.StartRadius,0,0))

				Timers:CreateTimer( 1, function()
						ParticleManager:DestroyParticle( excalFxIndex, false )
						ParticleManager:ReleaseParticleIndex( excalFxIndex )
						Timers:CreateTimer( 0.1, function()
								if IsValidEntity(dummy) then
									dummy:RemoveSelf()
								end
								return nil
							end
						)
						return nil
					end
				)
				return 
			end
		end)
	-- end
end


function OnExcaliburHit(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability 
	local damage = ability:GetSpecialValueFor("damage")
	
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Target")
		return
	end
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)
end


function OnGBTargetHit(keys)
	local caster = keys.caster
	caster.IsProject = true
	local ability = keys.ability
	local target = keys.target
	if not caster.IsImproveProjectionAcquired then 
		caster:RemoveModifierByName("modifier_kuro_project_check")
	end
	caster:EmitSound("chloe_gae_bolg")

	local casterName = caster:GetName()
	
	local HBThreshold = ability:GetSpecialValueFor("heart_break")
	local Damage = ability:GetSpecialValueFor("damage")
	local stun = ability:GetSpecialValueFor("stun")
	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=3})

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	target:EmitSound("Hero_Lion.Impale")

	if IsSpellBlocked(target) then -- no damage but play the effect

	else
		-- Blood splat
		local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)	
		local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)	

		if not IsImmuneToCC(target) then
			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		end
		giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
		DoDamage(caster, target, Damage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
		
		if IsValidEntity(target) and not target:IsNull() and target:IsAlive() then
			if target:GetHealthPercent() < HBThreshold and not target:IsMagicImmune() and not IsUnExecute(target) then
				local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
				target:Execute(ability, caster, { bExecution = true })
				
				Timers:CreateTimer( 3.0, function()
					ParticleManager:DestroyParticle( hb, false )
					ParticleManager:ReleaseParticleIndex(hb)
				end)
			end  -- check for HB
		end

		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splat, false )
			ParticleManager:DestroyParticle( culling_kill_particle, false )
			ParticleManager:ReleaseParticleIndex(culling_kill_particle)	
		end)
	end
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex(dagon_particle)	
		--ParticleManager:DestroyParticle( flashIndex, false )
	end)
end

function OnNineCast(keys)
	local caster = keys.caster
	local casterName = caster:GetName()
	local target = keys.target
	if target:GetName() == "npc_dota_ward_base" then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target")
	end
	StartAnimation(caster, {duration=0.1, activity=ACT_DOTA_ATTACK_EVENT, rate=3.0})
end

function OnNineStart(keys)
	local caster = keys.caster
	local casterName = caster:GetName()
	local target = keys.target
	local targetPoint = target:GetAbsOrigin()
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance
	local range = ability:GetSpecialValueFor("range")
	local pause_duration = ability:GetSpecialValueFor("pause_duration")
	if distance > range then
		ability:EndCooldown()
		caster:SetMana(caster:GetMana() + ability:GetCooldown(1))
		return 
	end
	caster.IsProject = true
	if not caster.IsImproveProjectionAcquired then 
		caster:RemoveModifierByName("modifier_kuro_project_check")
	end
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", pause_duration)
	caster:EmitSound("Hero_OgreMagi.Ignite.Cast")

	Timers:CreateTimer(0.5, function()
		if caster:IsAlive() then
			OnNineLanded(caster, ability, target)
		end
	end)
end

-- add pause
function OnNineLanded(caster, ability,target)
	local tickdmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel())
	local lasthitdmg = ability:GetLevelSpecialValueFor("damage_lasthit", ability:GetLevel())
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local range = ability:GetSpecialValueFor("range")
	local returnDelay = 0.2
	local radius = ability:GetSpecialValueFor("radius")
	local lasthitradius = ability:GetSpecialValueFor("radius_lasthit")
	local stun = ability:GetSpecialValueFor("stun_duration")
	local mini_duration = ability:GetSpecialValueFor("mini_duration")
	local post_nine = ability:GetSpecialValueFor("post_nine")
	local nineCounter = 0
	local casterInitOrigin = caster:GetAbsOrigin() 
	local random = RandomInt(1, 3)
	-- main timer
	Timers:CreateTimer(function()
		if caster:IsAlive() and target:IsAlive() and (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= range then -- only perform actions while caster stays alive
			--[[local particle = ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/hit.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector() * -1)
			ParticleManager:SetParticleControl(particle, 1, Vector(0,0,(nineCounter % 2) * 180))]]
			if caster:HasModifier("modifier_alternate_01") then 
				if nineCounter % 3 == 0 then
					StartAnimation(caster, {duration=returnDelay * 3, activity=ACT_DOTA_CAST_ABILITY_3, rate=1 / (returnDelay * 3)}) 
				end
			else
				StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=3.0}) 
			end

			caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 

			if nineCounter == total_hit - 1 then -- if it is last strike

				caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
				caster:RemoveModifierByName("pause_sealdisabled") 
				caster:AddNewModifier(caster, ability, "modifier_stunned", { Duration = post_nine })
				ScreenShake(caster:GetAbsOrigin(), 7, 1.0, 2, 1500, 0, true)
				CreateSlashFx(caster, target:GetAbsOrigin() + Vector(0,300,50), target:GetAbsOrigin() + Vector(0,-300,50))
				-- do damage to targets
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
				for k,v in pairs(lasthitTargets) do
					if IsValidEntity(v) and not v:IsNull() and v:GetName() ~= "npc_dota_ward_base" then
						if not v:IsMagicImmune() then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = stun })
						end
						DoDamage(caster, v, lasthitdmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						--giveUnitDataDrivenModifier(caster, v, "stunned", 1.5)

						--[[if caster:GetName() ~= "npc_dota_hero_ember_spirit" then
							giveUnitDataDrivenModifier(caster, v, "revoked", 0.5)
						end]]
						-- push enemies back
						if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
							if not IsKnockbackImmune(v) then
								local pushback = Physics:Unit(v)
								v:PreventDI()
								v:SetPhysicsFriction(0)
								v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
								v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
								v:FollowNavMesh(false)
								Timers:CreateTimer(0.5, function()  
									v:PreventDI(false)
									v:SetPhysicsVelocity(Vector(0,0,0))
									v:OnPhysicsFrame(nil)
									FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
								end)
							end
						end
					end
				end
				--[[ParticleManager:SetParticleControl(particle, 2, Vector(1,1,lasthitradius))
				ParticleManager:SetParticleControl(particle, 3, Vector(lasthitradius / 350,1,1))
				ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/last_hit.vpcf", PATTACH_ABSORIGIN, caster)]]

				-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, lasthitradius, true, 0.5)
			else
				-- if its not last hit, do regular hit stuffs
				if random == 1 then
					CreateSlashFx(caster, target:GetAbsOrigin() + Vector(250,250,50), target:GetAbsOrigin() + Vector(-250,-250,50))
				elseif random == 2 then 
					CreateSlashFx(caster, target:GetAbsOrigin() + Vector(270,-270,50), target:GetAbsOrigin() + Vector(-270,270,50))
				elseif random == 3 then
					CreateSlashFx(caster, target:GetAbsOrigin() + Vector(300,120,50), target:GetAbsOrigin() + Vector(-300,-120,50))
				elseif random == 4 then
					CreateSlashFx(caster, target:GetAbsOrigin() + Vector(-300,120,50), target:GetAbsOrigin() + Vector(300,-120,50))
				end

				local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
						if not v:IsMagicImmune() then
							v:AddNewModifier(caster, ability, "modifier_stunned", { Duration = mini_duration })
						end
						DoDamage(caster, v, tickdmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
				end
				

				nineCounter = nineCounter + 1
				random = RandomInt(1, 4)
				return returnDelay - 0.01
			end
		else
			caster:RemoveModifierByName("pause_sealdisabled")
		end 
	end)
end

rhoTarget = nil

function OnRhoCast (keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	if target:HasModifier("modifier_rho_aias") then 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Target Already Has Rho Aias")
	end
end

function OnRhoStart(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	caster.IsProject = true
	if caster.IsImproveProjectionAcquired then 
		local knock_radius = ability:GetSpecialValueFor("knock_radius")
		local knock = ability:GetSpecialValueFor("knock")
		local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, knock_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
	 	
		local modifierKnockback =
		{
			center_x = target:GetAbsOrigin().x,
			center_y = target:GetAbsOrigin().y,
			center_z = target:GetAbsOrigin().z,
			duration = 0.5,
			knockback_duration = 0.5,
			knockback_distance = knock,
			knockback_height = knock,
		}

		for _,unit in pairs(knockBackUnits) do
	--		print( "knock back unit: " .. unit:GetName() )
			if IsValidEntity(unit) and not unit:IsNull() and not IsKnockbackImmune(unit) then
				unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback );
			end
		end
	else
		caster:RemoveModifierByName("modifier_kuro_project_check")
	end
	caster.rhoTarget = target 
	caster.rhoTarget.rhoShieldAmount = keys.ShieldAmount
	ability:ApplyDataDrivenModifier(caster, caster.rhoTarget, "modifier_rho_aias", {})
	caster.rhoTarget:SetModifierStackCount("modifier_rho_aias", caster, keys.ShieldAmount/10)

	caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
end

function OnRhoCreate (keys)
	local caster = keys.caster
	-- Attach particle for shield facing the forward vector
	if caster.rhoTarget.rhoShieldParticleIndex == nil then
		caster.rhoTarget.rhoShieldParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_rhoaias_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.rhoTarget )
	end
end

function OnRhoThink (keys)
	local caster = keys.caster
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 0, caster.rhoTarget:GetAbsOrigin() )
			
	local origin = caster.rhoTarget:GetAbsOrigin()
	local forwardVec = caster.rhoTarget:GetForwardVector()
	local rightVec = caster.rhoTarget:GetRightVector()
			
	-- Hard coded value, these values have to be adjusted manually for core and end point of each petal
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 1, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z + 225 ) ) -- petal_core, center of petals
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 2, Vector( origin.x - 30 * forwardVec.x, origin.y - 30 * forwardVec.y, origin.z + 375 ) ) -- petal_a
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 3, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z ) ) -- petal_d
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 4, Vector( origin.x + 150 * rightVec.x, origin.y + 150 * rightVec.y, origin.z + 300 ) ) -- petal_b
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 5, Vector( origin.x - 150 * rightVec.x, origin.y - 150 * rightVec.y, origin.z + 300 ) ) -- petal_c
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 6, Vector( origin.x + 150 * rightVec.x + 60 * forwardVec.x, origin.y + 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_e
	ParticleManager:SetParticleControl( caster.rhoTarget.rhoShieldParticleIndex, 7, Vector( origin.x - 150 * rightVec.x + 60 * forwardVec.x, origin.y - 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_f
end

function OnRhoDestroy (keys)
	local caster = keys.caster 
	ParticleManager:DestroyParticle( caster.rhoTarget.rhoShieldParticleIndex, false )
	ParticleManager:ReleaseParticleIndex( caster.rhoTarget.rhoShieldParticleIndex )
	caster.rhoTarget.rhoShieldParticleIndex = nil
end

function OnRhoDamaged(keys)
	local caster = keys.caster 
	local currentHealth = caster.rhoTarget:GetHealth() 

	-- Create particles
	local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, keys.unit )
	ParticleManager:SetParticleControl( onHitParticleIndex, 2, keys.unit:GetAbsOrigin() )
	
	Timers:CreateTimer( 0.5, function()
			ParticleManager:DestroyParticle( onHitParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
		end
	)

	caster.rhoTarget.rhoShieldAmount = caster.rhoTarget.rhoShieldAmount - keys.DamageTaken
	if caster.rhoTarget.rhoShieldAmount <= 0 then
		if currentHealth + caster.rhoTarget.rhoShieldAmount <= 0 then
			--print("lethal")
		else
			--print("rho broken, but not lethal")
			caster.rhoTarget:RemoveModifierByName("modifier_rho_aias")
			caster.rhoTarget:SetHealth(currentHealth + keys.DamageTaken + caster.rhoTarget.rhoShieldAmount)
			caster.rhoTarget.rhoShieldAmount = 0
		end
	else
		--print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		caster.rhoTarget:SetHealth(currentHealth + keys.DamageTaken)
		caster.rhoTarget:SetModifierStackCount("modifier_rho_aias", caster, caster.rhoTarget.rhoShieldAmount/10)
	end
end

function OnRIStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local range = ability:GetSpecialValueFor("range")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	caster.IsProject = true
	if not caster.IsImproveProjectionAcquired then 
		caster:RemoveModifierByName("modifier_kuro_project_check")
	end

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	CreateSlashFx(caster, caster:GetAbsOrigin(), caster:GetAbsOrigin() + diff:Normalized() * diff:Length2D())
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	StartAnimation(caster, {duration = 1, activity = ACT_DOTA_ATTACK_EVENT, rate = 1.5})	
	caster:MoveToTargetToAttack(target)
	caster.rosatarget = target

	if IsSpellBlocked(keys.target) then return end

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end

	target:EmitSound("Hero_Lion.FingerOfDeath")

	if caster.IsImproveProjectionAcquired then 
		if not IsImmuneToSlow(target) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_kuro_rosa_slow", {})
		end
	end

	local slashFx = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth_child_embers_rosa.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( slashFx, 0, target:GetAbsOrigin() + Vector(0,0,300))

	DoCleaveAttack(caster, caster, ability, 0, 200, 400, 500, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf")

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( slashFx, false )
		ParticleManager:ReleaseParticleIndex( slashFx )
	end)

	-- Too dumb to make particles, just call cleave function 4head
	local slash = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 5000,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 500 - 200,
        fStartRadius = 200,
        fEndRadius = 400,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 0.1,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 5000
	}
	local projectile = ProjectileManager:CreateLinearProjectile(slash)
end

function OnRIHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target == nil then return end

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	local damage = ability:GetSpecialValueFor("damage")
	local splash_damage = ability:GetSpecialValueFor("splash_damage") / 100
	if target ~= caster.rosatarget then 
		DoDamage(caster, target, damage * splash_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnTripleCraneTarget(keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target 
	local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local int_ratio = ability:GetSpecialValueFor("int_ratio")

	Timers:CreateTimer(0.3, function()
		if caster:IsAlive() and target:IsAlive() then 
			local forwardVec = target:GetForwardVector()
			local angle = VectorToAngles(forwardVec).y
			local targetloc = target:GetAbsOrigin()
			--[[local Vec1 = Vector(forwardVec.x, forwardVec.y, 0)
			local Vec2 = Vector(-forwardVec.x, forwardVec.y, 0)
			local Vec3 = Vector(forwardVec.x, -forwardVec.y, 0)
			local Vec4 = Vector(-forwardVec.x, -forwardVec.y, 0)
			local dummy1 = CreateUnitByName("dummy_unit", GetRotationPoint(targetloc,500,angle + 45), false, caster, caster, caster:GetTeamNumber())
			dummy1:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			local dummy2 = CreateUnitByName("dummy_unit", GetRotationPoint(targetloc,500,angle + 135), false, caster, caster, caster:GetTeamNumber())
			dummy2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			local dummy3 = CreateUnitByName("dummy_unit", GetRotationPoint(targetloc,500,angle + 225), false, caster, caster, caster:GetTeamNumber())
			dummy3:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			local dummy4 = CreateUnitByName("dummy_unit", GetRotationPoint(targetloc,500,angle + 315), false, caster, caster, caster:GetTeamNumber())
			dummy4:FindAbilityByName("dummy_unit_passive"):SetLevel(1)]]

			UBWSword(ability,target,GetRotationPoint(targetloc,500,angle + 45),2)
			UBWSword(ability,target,GetRotationPoint(targetloc,500,angle + 135),3)
			UBWSword(ability,target,GetRotationPoint(targetloc,500,angle + 225),2)
			UBWSword(ability,target,GetRotationPoint(targetloc,500,angle + 315),3)

			StartAnimation(caster, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_5, rate=3.5})
			EmitGlobalSound("chloe_crane_4")
			giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.8)
			caster:SetAbsOrigin(targetloc + (-forwardVec * 300) + Vector(0,0,200))	
			caster:SetForwardVector(forwardVec)

			Timers:CreateTimer(0.4, function()
				--print(bonus_damage)
				if not IsFacingUnit(caster, target, 135) then
					bonus_damage = bonus_damage + int_ratio * caster:GetIntellect() 
					print(bonus_damage)
				end

				if not target:IsMagicImmune() then 
					target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
				end

				EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Juggernaut.OmniSlash.Damage", caster)
				
				local newforwardvec = (target:GetAbsOrigin() - caster:GetAbsOrigin() + Vector(0,0,200)):Normalized()
				caster:SetAbsOrigin(target:GetAbsOrigin() + (newforwardvec * 300))	
				caster:SetForwardVector(newforwardvec)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)	

				CraneWingSlashFX(caster, target:GetAbsOrigin())

				DoDamage(caster, target, bonus_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

			end)

			--[[Timers:CreateTimer(0.05, function()
				if IsValidEntity(dummy1) then
					dummy1:RemoveSelf()
				end
				if IsValidEntity(dummy2) then
					dummy2:RemoveSelf()
				end
				if IsValidEntity(dummy3) then
					dummy3:RemoveSelf()
				end
				if IsValidEntity(dummy4) then
					dummy4:RemoveSelf()
				end
			end)]]
		else
			return
		end
	end)
end


function OnTripleCraneWingStart (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	if keys.target ~= nil then 
		OnTripleCraneTarget(keys)
	else
		local target_destination = ability:GetCursorPosition()
		local target_loc = ability:GetCursorPosition()
		local ply = caster:GetPlayerOwner()
		local origin = caster:GetAbsOrigin()
		local forwardVec = caster:GetForwardVector()
		local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
		local radius = ability:GetSpecialValueFor("radius")
		local range = ability:GetSpecialValueFor("range")
		local stun_duration = ability:GetSpecialValueFor("stun_duration")
		local speed = 1350
		local angle = caster:GetAnglesAsVector().y
		local face_kuro = true

		if GridNav:IsBlocked(target_destination) or not GridNav:IsTraversable(target_destination) then
			ability:EndCooldown() 
			caster:GiveMana(ability:GetManaCost(ability:GetLevel())) 
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
			return 
		end 

		local backloc = GetRotationPoint(target_destination, 200, angle)

		-- Defaults the crossing point to 600 range in front of where Emiya is facing
		if (math.abs(target_destination.x - origin.x) < 500) and (math.abs(target_destination.y - origin.y) < 500) then
			target_destination = GetRotationPoint(target_destination, 500, angle)
		end

		local lsword_origin = GetRotationPoint(origin, 100, angle - 30)
		--local left_forward = (target_destination - lsword_origin):Normalized()
		local lsword_origin_2 = GetRotationPoint(origin, 200, angle - 60)
		--local left_forward_2 = (target_destination - lsword_origin_2):Normalized()
		local rsword_origin = GetRotationPoint(origin, 100, angle + 30)
		--local right_forward = (target_destination - rsword_origin):Normalized()	
		local rsword_origin_2 = GetRotationPoint(origin, 200, angle + 60)
		--local right_forward_2 = (target_destination - rsword_origin_2):Normalized()	

		local k_origin = GetRotationPoint(target_loc,500,45)
		local k_forward = (target_loc - k_origin):Normalized()
		local k_origin_2 = GetRotationPoint(target_loc,500,225)
		local k_forward_2 = (target_loc - k_origin_2):Normalized()
		local b_origin = GetRotationPoint(target_loc,500,135)
		local b_forward = (target_loc - b_origin):Normalized()	
		local b_origin_2 = GetRotationPoint(target_loc,500,315)
		local b_forward_2 = (target_loc - b_origin_2):Normalized()
		local k1_speed = (k_origin - lsword_origin):Length2D()/0.6
		local k2_speed = (k_origin_2 - lsword_origin_2):Length2D()/0.6
		local b1_speed = (b_origin - rsword_origin):Length2D()/0.6
		local b2_speed = (b_origin_2 - rsword_origin_2):Length2D()/0.6

		local K1Launch = ParticleManager:CreateParticle("particles/custom/kuro/kuro_kanshou_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(K1Launch, 0, lsword_origin + Vector(0,0,50)) 
		ParticleManager:SetParticleControl(K1Launch, 1, k_origin + Vector(0,0,100)) 
		ParticleManager:SetParticleControl(K1Launch, 2, Vector(k1_speed,0,0)) 

		local K2Launch = ParticleManager:CreateParticle("particles/custom/kuro/kuro_kanshou_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(K2Launch, 0, lsword_origin_2 + Vector(0,0,50)) 
		ParticleManager:SetParticleControl(K2Launch, 1, k_origin_2 + Vector(0,0,100) )
		ParticleManager:SetParticleControl(K2Launch, 2, Vector(k2_speed,0,0)) 

		local B1Launch = ParticleManager:CreateParticle("particles/custom/kuro/kuro_byakuya_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(B1Launch, 0, rsword_origin + Vector(0,0,50)) 
		ParticleManager:SetParticleControl(B1Launch, 1, b_origin + Vector(0,0,100) )
		ParticleManager:SetParticleControl(B1Launch, 2, Vector(b1_speed,0,0)) 

		local B2Launch = ParticleManager:CreateParticle("particles/custom/kuro/kuro_byakuya_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(B2Launch, 0, rsword_origin_2 + Vector(0,0,50) )
		ParticleManager:SetParticleControl(B2Launch, 1, b_origin_2 + Vector(0,0,100) )
		ParticleManager:SetParticleControl(B2Launch, 2, Vector(b2_speed,0,0)) 

		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.3)
		Timers:CreateTimer(0.05, function()
			Timers:CreateTimer(0.3 + 0.3, function()	
				ParticleManager:DestroyParticle( K1Launch, true )
				ParticleManager:ReleaseParticleIndex( K1Launch )
				ParticleManager:DestroyParticle( K2Launch, true )
				ParticleManager:ReleaseParticleIndex( K2Launch )
				ParticleManager:DestroyParticle( B1Launch, true )
				ParticleManager:ReleaseParticleIndex( B1Launch )
				ParticleManager:DestroyParticle( B2Launch, true )
				ParticleManager:ReleaseParticleIndex( B2Launch )
				KBFireSword(k_origin, k_forward, ability, caster, speed, 1)
				KBFireSword(k_origin_2, k_forward_2, ability, caster, speed, 1)
				KBFireSword(b_origin, b_forward, ability, caster, speed, 2)
				KBFireSword(b_origin_2, b_forward_2, ability, caster, speed, 2)
			end)
			
			local projectileDuration = range / speed
					
			Timers:CreateTimer(0.3, function()
				StartAnimation(caster, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_5, rate=3.5})
				EmitGlobalSound("chloe_crane_4")
				if caster.IsKuroMagicAcquired then
					giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.8)
					--caster:SetOrigin(target_loc + Vector(0,0,500))
					caster:SetAbsOrigin(backloc + Vector(0,0,200))	
					caster:SetForwardVector(-forwardVec)
				else
					giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.6)
					local dist = (caster:GetAbsOrigin() - target_loc):Length2D() * 10/6
					if dist > 2000 then
						dist = 600 --Default one
					end
					local kuro = Physics:Unit(caster)
				    caster:PreventDI()
				    caster:SetPhysicsFriction(0)
				    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 850))
				    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
				    caster:FollowNavMesh(false)	
				    caster:SetAutoUnstuck(false)
				    caster:SetPhysicsAcceleration(Vector(0,0,-2666))
				    Timers:CreateTimer({
						endTime = 0.6,
						callback = function()
						caster:EmitSound("Hero_Centaur.DoubleEdge") 
						caster:PreventDI(false)
						caster:SetPhysicsVelocity(Vector(0,0,0))
						caster:SetAutoUnstuck(true)
				       	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				    end})
				end
			end)


			Timers:CreateTimer(projectileDuration, function()
				EmitSoundOnLocationWithCaster(target_loc, "Hero_Juggernaut.OmniSlash.Damage", caster)
				local TLCWTargets = FindUnitsInRadius(caster:GetTeam(), target_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)		
				for _,target in pairs (TLCWTargets) do 
					if IsValidEntity(target) and not target:IsNull() then
						if caster.IsKuroMagicAcquired then
							if not IsFacingUnit(caster, target, 135) then
								print('kuro back bonus damage')
								local int_ratio = ability:GetSpecialValueFor("int_ratio")
								bonus_damage = bonus_damage + int_ratio * caster:GetIntellect() 
							end
						end
						if not target:IsMagicImmune() then 
							target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration})
						end

						DoDamage(caster, target, bonus_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
					
				end
				if caster.IsKuroMagicAcquired then
					caster:SetAbsOrigin(target_loc-(target_loc - origin):Normalized()*200)	
					caster:SetForwardVector(-forwardVec)
					FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)	
				end

				CraneWingSlashFX(caster, target_loc)

				return nil
			end)
		end)
	end
end

function CraneWingSlashFX(caster, target_loc)
	CreateSlashFx(caster, target_loc + Vector(200, 200, 0), target_loc + Vector(-200, -200, 0))
	CreateSlashFx(caster, target_loc + Vector(250, 250, 25), target_loc + Vector(-250, -250, 25))
	CreateSlashFx(caster, target_loc + Vector(300, 300, 50), target_loc + Vector(-300, -300, 50))

	CreateSlashFx(caster, target_loc + Vector(100,-100,0) + Vector(200, 200, 0), target_loc + Vector(100,-100,0) + Vector(-200, -200, 0))
	CreateSlashFx(caster, target_loc + Vector(100,-100,0) + Vector(250, 250, 25), target_loc + Vector(100,-100,0) + Vector(-250, -250, 25))
	CreateSlashFx(caster, target_loc + Vector(100,-100,0) + Vector(300, 300, 50), target_loc + Vector(100,-100,0) + Vector(-300, -300, 50))

	CreateSlashFx(caster, target_loc + Vector(-100,100,0) + Vector(200, 200, 0), target_loc + Vector(-100,100,0) + Vector(-200, -200, 0))
	CreateSlashFx(caster, target_loc + Vector(-100,100,0) + Vector(250, 250, 25), target_loc + Vector(-100,100,0) + Vector(-250, -250, 25))
	CreateSlashFx(caster, target_loc + Vector(-100,100,0) + Vector(300, 300, 50), target_loc + Vector(-100,100,0) + Vector(-300, -300, 50))

	CreateSlashFx(caster, target_loc + Vector(200, -200, 0), target_loc + Vector(-200, 200, 0))
	CreateSlashFx(caster, target_loc + Vector(250, -250, 25), target_loc + Vector(-250, 250, 25))	
	CreateSlashFx(caster, target_loc + Vector(300, -300, 50), target_loc + Vector(-300, 300, 50))		

	CreateSlashFx(caster, target_loc + Vector(-100,-100,0) + Vector(200, -200, 0), target_loc + Vector(-100,-100,0) + Vector(-200, 200, 0))
	CreateSlashFx(caster, target_loc + Vector(-100,-100,0) + Vector(250, -250, 25), target_loc + Vector(-100,-100,0) + Vector(-250, 250, 25))	
	CreateSlashFx(caster, target_loc + Vector(-100,-100,0) + Vector(300, -300, 50), target_loc + Vector(-100,-100,0) + Vector(-300, 300, 50))	

	CreateSlashFx(caster, target_loc + Vector(100,100,0) + Vector(200, -200, 0), target_loc + Vector(100,100,0) + Vector(-200, 200, 0))
	CreateSlashFx(caster, target_loc + Vector(100,100,0) + Vector(250, -250, 25), target_loc + Vector(100,100,0) + Vector(-250, 250, 25))	
	CreateSlashFx(caster, target_loc + Vector(100,100,0) + Vector(300, -300, 50), target_loc + Vector(100,100,0) + Vector(-300, 300, 50))

end

function OnTLCWHit(keys)
	local target = keys.target

	if not IsValidEntity(target) or target:IsNull() or not target:IsAlive() then return end

	if target == nil then return end
	if target:IsMagicImmune() or IsSpellBlocked(target) then return end
	--for k,v in pairs(tData) do print(k,v) end

	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local mini_duration = ability:GetSpecialValueFor("mini_duration")
	local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(KBHitFx, 0, target:GetAbsOrigin()) 
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( KBHitFx, false )
		ParticleManager:ReleaseParticleIndex( KBHitFx )
	end)

	target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")

	if not IsImmuneToCC(target) then
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration = mini_duration})
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	
end

function KuroCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if caster.IsKuroMagicAcquired then
			if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain_upgrade") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_3"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain_upgrade") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_2"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain_upgrade") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_1"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain_upgrade") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			end
		else
			if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_3"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain") and caster:FindAbilityByName("kuro_triple_link_crane_wing"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_2"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain") and caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw_upgrade_1"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
				if ability == caster:FindAbilityByName("kuro_sharing_pain") and caster:FindAbilityByName("kuro_triple_link_crane_wing"):IsCooldownReady() and caster:FindAbilityByName("kuro_fake_ubw"):IsCooldownReady() and not caster:HasModifier("modifier_fake_ubw_cooldown") then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_window", {})	
				end
			end
		end
	end
end

function OnFakeUBWWindow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsKuroMagicAcquired then
		if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_ubw_upgrade_3", false, true) 
		elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_ubw_upgrade_2", false, true) 
		elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_ubw_upgrade_1", false, true) 
		elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_ubw", false, true) 
		end
	else
		if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_ubw_upgrade_3", false, true) 
		elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_ubw_upgrade_2", false, true) 
		elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_ubw_upgrade_1", false, true) 
		elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_ubw", false, true) 
		end
	end
end

function OnFakeUBWWindowDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.IsKuroMagicAcquired then
		if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_ubw_upgrade_3", true, false) 
		elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_ubw_upgrade_2", true, false) 
		elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_fake_ubw_upgrade_1", true, false) 
		elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_fake_ubw", true, false) 
		end
	else
		if caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_ubw_upgrade_3", true, false) 
		elseif not caster.IsOveredgeAcquired and caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_ubw_upgrade_2", true, false) 
		elseif caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_fake_ubw_upgrade_1", true, false) 
		elseif not caster.IsOveredgeAcquired and not caster.IsImproveProjectionAcquired then
			caster:SwapAbilities("kuro_triple_link_crane_wing", "kuro_fake_ubw", true, false) 
		end
	end
end

function OnFakeUBWWindowDied(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_fake_ubw_window")
end

function OnFakeUBWCast(keys)
	local caster = keys.caster 
	local ability= keys.ability 
	EmitGlobalSound("chloe_pre_combo")
end

function OnFakeUBWStart (keys)
	local caster = keys.caster 
	local ability= keys.ability 
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_cooldown", {duration=ability:GetCooldown(1)})
	local tlcw = caster:FindAbilityByName("kuro_triple_link_crane_wing")
	if tlcw == nil then 
		if caster.IsOveredgeAcquired and caster.IsKuroMagicAcquired then 
			tlcw = caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3")
		elseif not caster.IsOveredgeAcquired and caster.IsKuroMagicAcquired then 
			tlcw = caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2")
		elseif caster.IsOveredgeAcquired and not caster.IsKuroMagicAcquired then 
			tlcw = caster:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1")
		end
	end
	tlcw:StartCooldown(30.0)
	caster.IsUBWActive = true
	if not caster.IsImproveProjectionAcquired then 
		giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", duration)
	end
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_dummy", {duration = duration})	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fake_ubw_think", {duration = duration})	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("kuro_fake_ubw")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(ability:GetCooldown(1))
	ability:StartCooldown(ability:GetCooldown(1))
	caster:RemoveModifierByName("modifier_fake_ubw_window")
	SpawnAttachedVisionDummy(caster, caster, radius + 100, duration, false)
	Timers:CreateTimer(0.6, function()
		EmitGlobalSound("chloe_combo")
	end)
end

function OnFakeUBWRingCreate (keys)
	local caster = keys.caster 
	local ability= keys.ability 
	local origin = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	--[[caster.dummyNorth = CreateUnitByName("dummy_unit", origin, false, caster, caster, caster:GetTeamNumber())
	caster.dummyNorthPos = origin + Vector(0,radius,0)
	caster.dummyNorth:SetAbsOrigin(caster.dummyNorthPos)
	caster.dummyNorth:SetForwardVector((Vector(0,radius,0)):Normalized())
	caster.dummyNorth:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.UBWFx1 = ParticleManager:CreateParticle("particles/custom/kuro/kuro_kanshou.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.dummyNorth)
	ParticleManager:SetParticleControl( caster.UBWFx1, 0, caster.dummyNorth:GetAbsOrigin() )
	caster.dummyWest = CreateUnitByName("dummy_unit", origin, false, caster, caster, caster:GetTeamNumber())
	caster.dummyWestPos = origin + Vector(-radius,0,0)
	caster.dummyWest:SetAbsOrigin(caster.dummyWestPos)
	caster.dummyWest:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.UBWFx2 = ParticleManager:CreateParticle("particles/custom/kuro/kuro_byakuya.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.dummyWest)
	ParticleManager:SetParticleControl( caster.UBWFx2, 0, caster.dummyWest:GetAbsOrigin() )
	caster.dummySouth = CreateUnitByName("dummy_unit", origin, false, caster, caster, caster:GetTeamNumber())
	caster.dummySouthPos = origin + Vector(0,-radius,0)
	caster.dummySouth:SetAbsOrigin(caster.dummySouthPos)
	caster.dummySouth:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.UBWFx3 = ParticleManager:CreateParticle("particles/custom/kuro/kuro_kanshou.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.dummySouth)
	ParticleManager:SetParticleControl( caster.UBWFx3, 0, caster.dummySouth:GetAbsOrigin() )
	caster.dummyEast = CreateUnitByName("dummy_unit", origin, false, caster, caster, caster:GetTeamNumber())
	caster.dummyEastPos = origin + Vector(radius,0,0)
	caster.dummyEast:SetAbsOrigin(caster.dummyEastPos)
	caster.dummyEast:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	caster.UBWFx4 = ParticleManager:CreateParticle("particles/custom/kuro/kuro_byakuya.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.dummyEast)
	ParticleManager:SetParticleControl( caster.UBWFx4, 0, caster.dummyEast:GetAbsOrigin() )
	caster.rotation = 0
	caster.rotate_delta = 12]]
	caster.UBWGroundFx = ParticleManager:CreateParticle("particles/custom/kuro/kuro_ubw_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl( caster.UBWGroundFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl( caster.UBWGroundFx, 2, Vector(radius,radius,0))
end

function OnFakeUBWDummyMove (keys)
	--[[local caster = keys.caster
	local ability = keys.ability
	local origin = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local casterOrigin = caster:GetAbsOrigin()

	-- Rotate
	local relative_pos = Vector(-radius,0,0)
	caster.rotation = caster.rotation + caster.rotate_delta
	caster.dummyNorthPos = RotatePosition( origin, QAngle( 0, -caster.rotation, 0 ),origin + Vector(0,radius,0))
	caster.dummyNorth:SetAbsOrigin( caster.dummyNorthPos )

	caster.dummyWestPos = RotatePosition( origin, QAngle( 0, -caster.rotation, 0 ),origin + Vector(-radius,0,0))
	caster.dummyWest:SetAbsOrigin( caster.dummyWestPos )

	caster.dummySouthPos = RotatePosition( origin, QAngle( 0, -caster.rotation, 0 ),origin + Vector(0,-radius,0))
	caster.dummySouth:SetAbsOrigin( caster.dummySouthPos )

	caster.dummyEastPos = RotatePosition( origin, QAngle( 0, -caster.rotation, 0 ),origin + Vector(radius,0,0))
	caster.dummyEast:SetAbsOrigin( caster.dummyEastPos )]]
end

function OnFakeUBWRingDestroy (keys)
	local caster = keys.caster 
	caster.IsUBWActive = false
	
	--[[caster.dummyNorth:RemoveSelf()
	caster.dummyWest:RemoveSelf()	
	caster.dummySouth:RemoveSelf()	
	caster.dummyEast:RemoveSelf() 
	ParticleManager:DestroyParticle( caster.UBWFx1, false )
	ParticleManager:ReleaseParticleIndex( caster.UBWFx1 )
	ParticleManager:DestroyParticle( caster.UBWFx2, false )
	ParticleManager:ReleaseParticleIndex( caster.UBWFx2 )
	ParticleManager:DestroyParticle( caster.UBWFx3, false )
	ParticleManager:ReleaseParticleIndex( caster.UBWFx3 )
	ParticleManager:DestroyParticle( caster.UBWFx4, false )
	ParticleManager:ReleaseParticleIndex( caster.UBWFx4 )]]
	ParticleManager:DestroyParticle( caster.UBWGroundFx, false )
	ParticleManager:ReleaseParticleIndex( caster.UBWGroundFx )
	caster:RemoveModifierByName("modifier_fake_ubw_think")
end

function OnFakeUBWDeath (keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_fake_ubw_dummy")
end

function OnFakeUBWThink (keys)
	local caster = keys.caster 
	local ability= keys.ability 
	local radius = ability:GetSpecialValueFor("radius")
	local swordtarget = nil
	local Sword = 1
	caster.KSword = false
	caster.BSword = false

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for i=1, #targets do
        swordtarget = targets[i]
        break
    end

   	if swordtarget ~= nil then
   		if caster.IsOveredgeAcquired then
   			local chance = ability:GetSpecialValueFor("overedge_chance") 
   			local Krandom = RandomInt(1, 100)
   			local Brandom = RandomInt(1, 100)
   			if Krandom < chance then 
   				caster.KSword = true 
   				Sword = 2
   			end
   			if KSword == false then 
   				if Brandom < chance then 
   					caster.BSword = true 
   					Sword = 3
   				end
   			end
   		end
   		if swordtarget:IsAlive() then
   			local swordorigin = swordtarget:GetAbsOrigin() + RandomVector(200)
   			--[[local sword_dummy = CreateUnitByName("dummy_unit", swordorigin, false, caster, caster, caster:GetTeamNumber())
   			sword_dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)]]
			UBWSword(ability,swordtarget,swordorigin,Sword)
			--[[Timers:CreateTimer(0.05, function()
				if IsValidEntity(sword_dummy) then
					sword_dummy:RemoveSelf()
				end
			end)]]
		end
    end
end

function UBWSword(ability,target,origin,sword)
	local effect = "particles/custom/archer/emiya_kb_swords.vpcf"
	if sword == 2 then 
		effect = "particles/custom/archer/archer_kanshou.vpcf"
	elseif sword == 3 then 
		effect = "particles/custom/archer/archer_byakuya.vpcf"
	end

	local UBWSword = {
		EffectName = effect,
        Ability = ability,
        vSourceLoc = origin,
        Target = target,
        --Source = souce, 
        fExpireTime = GameRules:GetGameTime() + 0.5,
        iMoveSpeed = 1000,
        bDeleteOnHit = true
	}
	ProjectileManager:CreateTrackingProjectile(UBWSword)
end

LinkLuaModifier("modifier_vision_provider", "abilities/general/modifiers/modifier_vision_provider", LUA_MODIFIER_MOTION_NONE)

function OnFakeUBWHit (keys)
	local caster = keys.caster 
	local ability = keys.ability 
	local target = keys.target
	local dmg = ability:GetSpecialValueFor("dmg")
	local stun = ability:GetSpecialValueFor("stun")
	local bonus_damage = 0 
	if caster.IsOveredgeAcquired then 
		bonus_damage = ability:GetSpecialValueFor("overedge_dmg")
	end
	if target == nil then return end
	if caster.KSword == true then 
		dmg = dmg + bonus_damage
		--print('KSword')
		
	elseif caster.BSword == true then 
		dmg = dmg + bonus_damage
		--print('BSword')
	end
	target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
	caster:AddNewModifier(target, ability, "modifier_vision_provider", {duration = 0.5})
	
	--print(dmg)
	caster.KSword = false 
	caster.BSword = false
	if not target:IsMagicImmune() and not IsImmuneToCC(target) then 
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
	end
	local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(KBHitFx, 0, target:GetAbsOrigin()) 

	DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	-- Destroy particle after delay
	Timers:CreateTimer(0.5, function()
		ParticleManager:DestroyParticle( KBHitFx, false )
		ParticleManager:ReleaseParticleIndex( KBHitFx )
	end)
end

function OnImproveProjectionAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImproveProjectionAcquired) then

		if hero:HasModifier("modifier_fake_ubw_window") then 
			hero:RemoveModifierByName("modifier_fake_ubw_window")
		end

		if hero:HasModifier("modifier_kuro_hrunting_window") then 
			hero:RemoveModifierByName("modifier_kuro_hrunting_window")
		end

		hero.IsImproveProjectionAcquired = true

		hero:AddAbility("kuro_excalibur_upgrade")
		hero:FindAbilityByName("kuro_excalibur_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())
		if not hero:FindAbilityByName("kuro_excalibur"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_excalibur_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_excalibur"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_gae_bolg_upgrade")
		hero:FindAbilityByName("kuro_gae_bolg_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())
		if not hero:FindAbilityByName("kuro_gae_bolg"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_gae_bolg_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_gae_bolg"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_rho_aias_upgrade")
		hero:FindAbilityByName("kuro_rho_aias_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())
		if not hero:FindAbilityByName("kuro_rho_aias"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_rho_aias_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_rho_aias"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_rosa_ichthys_upgrade")
		hero:FindAbilityByName("kuro_rosa_ichthys_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())
		if not hero:FindAbilityByName("kuro_rosa_ichthys"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_rosa_ichthys_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_rosa_ichthys"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_fake_nine_live_upgrade")
		hero:FindAbilityByName("kuro_fake_nine_live_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())
		if not hero:FindAbilityByName("kuro_fake_nine_live"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_fake_nine_live_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_fake_nine_live"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_projection_upgrade")
		hero:FindAbilityByName("kuro_projection_upgrade"):SetLevel(hero:FindAbilityByName("kuro_projection"):GetLevel())

		if hero:HasModifier("modifier_kuro_project_check") then 
			hero:SwapAbilities("kuro_excalibur_upgrade", "kuro_excalibur", true, false) 
			hero:SwapAbilities("kuro_gae_bolg_upgrade", "kuro_gae_bolg", true, false) 
			hero:SwapAbilities("kuro_rho_aias_upgrade", "kuro_rho_aias", true, false) 
			hero:SwapAbilities("kuro_rosa_ichthys_upgrade", "kuro_rosa_ichthys", true, false) 
			hero:SwapAbilities("kuro_fake_nine_live_upgrade", "kuro_fake_nine_live", true, false) 
			hero:FindAbilityByName("kuro_projection_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("kuro_projection_upgrade", "kuro_projection", true, false) 
		end

		hero:RemoveAbility("kuro_excalibur")
		hero:RemoveAbility("kuro_gae_bolg")
		hero:RemoveAbility("kuro_rho_aias")
		hero:RemoveAbility("kuro_rosa_ichthys")
		hero:RemoveAbility("kuro_fake_nine_live")
		hero:RemoveAbility("kuro_projection")

		if hero.IsOveredgeAcquired then 
			hero:AddAbility("kuro_fake_ubw_upgrade_3")
			hero:FindAbilityByName("kuro_fake_ubw_upgrade_3"):SetLevel(1)
			if not hero:FindAbilityByName("kuro_fake_ubw_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_fake_ubw_upgrade_3"):StartCooldown(hero:FindAbilityByName("kuro_fake_ubw_upgrade_1"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("kuro_fake_ubw_upgrade_1")
		else
			hero:AddAbility("kuro_fake_ubw_upgrade_2")
			hero:FindAbilityByName("kuro_fake_ubw_upgrade_2"):SetLevel(1)
			if not hero:FindAbilityByName("kuro_fake_ubw"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_fake_ubw_upgrade_2"):StartCooldown(hero:FindAbilityByName("kuro_fake_ubw"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("kuro_fake_ubw")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnOveredgeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsOveredgeAcquired) then

		if hero:HasModifier("modifier_fake_ubw_window") then 
			hero:RemoveModifierByName("modifier_fake_ubw_window")
		end

		hero.IsOveredgeAcquired = true

		hero:AddAbility("kuro_kanshou_byakuya_upgrade")
		hero:FindAbilityByName("kuro_kanshou_byakuya_upgrade"):SetLevel(hero:FindAbilityByName("kuro_kanshou_byakuya"):GetLevel())
		if not hero:FindAbilityByName("kuro_kanshou_byakuya"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_kanshou_byakuya_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_kanshou_byakuya"):GetCooldownTimeRemaining())
		end

		if hero.IsImproveProjectionAcquired then 
			hero:AddAbility("kuro_fake_ubw_upgrade_3")
			hero:FindAbilityByName("kuro_fake_ubw_upgrade_3"):SetLevel(1)
			if not hero:FindAbilityByName("kuro_fake_ubw_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_fake_ubw_upgrade_3"):StartCooldown(hero:FindAbilityByName("kuro_fake_ubw_upgrade_2"):GetCooldownTimeRemaining())
			end
		else
			hero:AddAbility("kuro_fake_ubw_upgrade_1")
			hero:FindAbilityByName("kuro_fake_ubw_upgrade_1"):SetLevel(1)
			if not hero:FindAbilityByName("kuro_fake_ubw"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_fake_ubw_upgrade_1"):StartCooldown(hero:FindAbilityByName("kuro_fake_ubw"):GetCooldownTimeRemaining())
			end
		end

		if hero.IsKuroMagicAcquired then 
			hero:AddAbility("kuro_triple_link_crane_wing_upgrade_3")
			hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):SetLevel(hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):GetLevel())
			if not hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):StartCooldown(hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):GetCooldownTimeRemaining())
			end
		else
			hero:AddAbility("kuro_triple_link_crane_wing_upgrade_1")
			hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):SetLevel(hero:FindAbilityByName("kuro_triple_link_crane_wing"):GetLevel())
			if not hero:FindAbilityByName("kuro_triple_link_crane_wing"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):StartCooldown(hero:FindAbilityByName("kuro_triple_link_crane_wing"):GetCooldownTimeRemaining())
			end
		end

		if hero:HasModifier("modifier_kuro_project_check") then 
			hero:FindAbilityByName("kuro_kanshou_byakuya_upgrade"):SetHidden(true)
			if hero.IsKuroMagicAcquired then
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):SetHidden(true)
			else
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):SetHidden(true)
			end
		else
			hero:SwapAbilities("kuro_kanshou_byakuya_upgrade", "kuro_kanshou_byakuya", true, false) 
			if hero.IsKuroMagicAcquired then
				hero:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_triple_link_crane_wing_upgrade_2", true, false) 
			else
				hero:SwapAbilities("kuro_triple_link_crane_wing_upgrade_1", "kuro_triple_link_crane_wing", true, false) 
			end
		end

		hero:RemoveAbility("kuro_kanshou_byakuya")
		if hero.IsImproveProjectionAcquired then
			hero:RemoveAbility("kuro_fake_ubw_upgrade_2")
		else
			hero:RemoveAbility("kuro_fake_ubw")
		end
		if hero.IsKuroMagicAcquired then
			hero:RemoveAbility("kuro_triple_link_crane_wing_upgrade_2")
		else
			hero:RemoveAbility("kuro_triple_link_crane_wing")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnKuroMagicAcquired(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsKuroMagicAcquired) then

		if hero:HasModifier("modifier_fake_ubw_window") then 
			hero:RemoveModifierByName("modifier_fake_ubw_window")
		end

		hero.IsKuroMagicAcquired = true

		hero:AddAbility("kuro_sharing_pain_upgrade")
		hero:FindAbilityByName("kuro_sharing_pain_upgrade"):SetLevel(1)
		if not hero:FindAbilityByName("kuro_sharing_pain"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_sharing_pain_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_sharing_pain"):GetCooldownTimeRemaining())
		end

		if hero.IsOveredgeAcquired then 
			hero:AddAbility("kuro_triple_link_crane_wing_upgrade_3")
			hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):SetLevel(hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):GetLevel())
			if not hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):StartCooldown(hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_1"):GetCooldownTimeRemaining())
			end
		else
			hero:AddAbility("kuro_triple_link_crane_wing_upgrade_2")
			hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):SetLevel(hero:FindAbilityByName("kuro_triple_link_crane_wing"):GetLevel())
			if not hero:FindAbilityByName("kuro_triple_link_crane_wing"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):StartCooldown(hero:FindAbilityByName("kuro_triple_link_crane_wing"):GetCooldownTimeRemaining())
			end
		end

		if hero:HasModifier("modifier_kuro_project_check") then 
			if hero.IsOveredgeAcquired then
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_3"):SetHidden(true)
			else
				hero:FindAbilityByName("kuro_triple_link_crane_wing_upgrade_2"):SetHidden(true)
			end
			hero:FindAbilityByName("kuro_sharing_pain_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("kuro_sharing_pain_upgrade", "kuro_sharing_pain", true, false) 
			if hero.IsOveredgeAcquired then
				hero:SwapAbilities("kuro_triple_link_crane_wing_upgrade_3", "kuro_triple_link_crane_wing_upgrade_1", true, false) 
			else
				hero:SwapAbilities("kuro_triple_link_crane_wing_upgrade_2", "kuro_triple_link_crane_wing", true, false) 
			end
		end

		hero:RemoveAbility("kuro_sharing_pain")
		if hero.IsOveredgeAcquired then
			hero:RemoveAbility("kuro_triple_link_crane_wing_upgrade_1")
		else
			hero:RemoveAbility("kuro_triple_link_crane_wing")
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnHruntingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHruntingAcquired) then

		hero.IsHruntingAcquired = true

		if hero.IsEagleEyeAcquired then 
			hero:AddAbility("kuro_hrunting_upgrade")
			hero:FindAbilityByName("kuro_hrunting_upgrade"):SetLevel(hero:FindAbilityByName("kuro_calabolg_upgrade"):GetLevel())
			hero:RemoveAbility("kuro_hrunting")
		else
			hero:FindAbilityByName("kuro_hrunting"):SetLevel(hero:FindAbilityByName("kuro_calabolg"):GetLevel())
		end

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

		if ServerTables:GetTableValue("Condition", "dbhruntproh") == true then
			local archer_playerId = ServerTables:GetTableValue("Condition", "archer")
			local archer = PlayerResource:GetPlayer(archer_playerId):GetAssignedHero()
			archer.MasterUnit2:FindAbilityByName('archer_attribute_hrunting'):StartCooldown(9999)
			archer.MasterUnit2:AddAbility("fate_empty3")
			archer.MasterUnit2:SwapAbilities("fate_empty3", "archer_attribute_hrunting", true, false)
			Say(hero:GetPlayerOwner(), "Chloe is upgrading Attribute: Hrunting", true)
			Say(hero:GetPlayerOwner(), "Emiya's Attribute: Hrunting will be disabled", true)
			--[[local hero_data = ServerTables:GetAllTableValues('HeroSelection')
			for i = 0, DOTA_MAX_PLAYERS - 1 do 
				if hero_data[i] == "npc_dota_hero_ember_spirit" then 
					local hhero = PlayerTables:GetTableValue("hHero", 'hhero', i)
					local archer =  EntIndexToHScript(hhero)
					archer.MasterUnit2:FindAbilityByName('archer_attribute_hrunting'):StartCooldown(9999)
					--UpgradeAttribute(archer.MasterUnit2, 'archer_attribute_hrunting', 'fate_empty3', true)
					archer.MasterUnit2:AddAbility("fate_empty3")
					archer.MasterUnit2:SwapAbilities("fate_empty3", "archer_attribute_hrunting", true, false)
					Say(hero:GetPlayerOwner(), "Chloe is upgrading Attribute: Hrunting", true)
					Say(hero:GetPlayerOwner(), "Emiya's Attribute: Hrunting will be disabled", true)
				end
			end]]
			--[[local archer = Entities:FindByClassname(nil, "npc_dota_hero_ember_spirit")
			if hero:GetTeam() == archer:GetTeam() then
				archer.MasterUnit2:FindAbilityByName('archer_attribute_hrunting'):StartCooldown(9999)
				--UpgradeAttribute(archer.MasterUnit2, 'archer_attribute_hrunting', 'fate_empty3', true)
				archer.MasterUnit2:AddAbility("fate_empty3")
				archer.MasterUnit2:SwapAbilities("fate_empty3", "archer_attribute_hrunting", true, false)
				Say(hero:GetPlayerOwner(), "Chloe is upgrading Attribute: Hrunting", true)
				Say(hero:GetPlayerOwner(), "Emiya's Attribute: Hrunting will be disabled", true)
			end]]
		end
	end
end

function OnEagleEyeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsEagleEyeAcquired) then
	
		if hero:HasModifier("modifier_kuro_hrunting_window") then 
			hero:RemoveModifierByName("modifier_kuro_hrunting_window")
		end

		hero.IsEagleEyeAcquired = true
		
		hero:AddAbility("kuro_clairvoyance_upgrade")
		hero:FindAbilityByName("kuro_clairvoyance_upgrade"):SetLevel(1)
		if not hero:FindAbilityByName("kuro_clairvoyance"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_clairvoyance_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_clairvoyance"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("kuro_calabolg_upgrade")
		hero:FindAbilityByName("kuro_calabolg_upgrade"):SetLevel(hero:FindAbilityByName("kuro_calabolg"):GetLevel())
		if not hero:FindAbilityByName("kuro_calabolg"):IsCooldownReady() then 
			hero:FindAbilityByName("kuro_calabolg_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_calabolg"):GetCooldownTimeRemaining())
		end

		if hero.IsHruntingAcquired then 
			hero:AddAbility("kuro_hrunting_upgrade")
			hero:FindAbilityByName("kuro_hrunting_upgrade"):SetLevel(hero:FindAbilityByName("kuro_hrunting"):GetLevel())
			if not hero:FindAbilityByName("kuro_hrunting"):IsCooldownReady() then 
				hero:FindAbilityByName("kuro_hrunting_upgrade"):StartCooldown(hero:FindAbilityByName("kuro_hrunting"):GetCooldownTimeRemaining())
			end
			hero:RemoveAbility("kuro_hrunting")
		end

		if hero:HasModifier("modifier_kuro_project_check") then 
			hero:FindAbilityByName("kuro_clairvoyance_upgrade"):SetHidden(true)
			hero:FindAbilityByName("kuro_calabolg_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("kuro_clairvoyance_upgrade", "kuro_clairvoyance", true, false) 
			hero:SwapAbilities("kuro_calabolg_upgrade", "kuro_calabolg", true, false) 
		end

		hero:RemoveAbility("kuro_clairvoyance")
		hero:RemoveAbility("kuro_calabolg")

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end
