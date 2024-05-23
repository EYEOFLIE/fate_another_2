
function OnRebelThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_stack = ability:GetSpecialValueFor("max_stack")

    local allies_dead = 0
    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero:GetTeam() == caster:GetTeam() then 
    		if not playerHero:IsAlive() then 
    			allies_dead = allies_dead + 1 
    		end
    	end
    end)

    if allies_dead > 0 then 
    	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_rebel_buff", {})
    	caster:SetModifierStackCount("modifier_lubu_rebel_buff", caster, math.min(max_stack, allies_dead))
    	caster:CalculateStatBonus(true)
    	if not caster.rebelfx then
    		caster.rebelfx = ParticleManager:CreateParticle('particles/custom/lubu/lubu_rebel_buff.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
    	end
    	ParticleManager:SetParticleControl(caster.rebelfx, 1, Vector(allies_dead,1,1))
    else
    	caster:RemoveModifierByName("modifier_lubu_rebel_buff")
    	if caster.rebelfx then
    		ParticleManager:DestroyParticle(caster.rebelfx, true)
    		ParticleManager:ReleaseParticleIndex(caster.rebelfx)
    		caster.rebelfx = nil 
    	end
    end
end

function OnRebelGoldTick(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gold_gain = ability:GetSpecialValueFor("bonus_gold_per_stack")
	local stack = caster:GetModifierStackCount("modifier_lubu_rebel_buff", caster)
    if caster:IsAlive() and GameRules:GetGameTime() > 75 then 
    	caster:SetGold(0, false)
    	caster:SetGold(caster:GetGold() + (gold_gain * stack), true) 
    end
end

function OnRebelDeath(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_lubu_rebel_buff")
end

function OnFBCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	ability:EndCooldown()
	caster:GiveMana(ability:GetManaCost(1))

	target.FBparticle = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

	ParticleManager:SetParticleControl( target.FBparticle, 0, target:GetAbsOrigin() + Vector(0,0,100)) 
	ParticleManager:SetParticleControl( target.FBparticle, 1, target:GetAbsOrigin() + Vector(0,0,100)) 

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bow", {})
	local arrow_model = Attachments:GetCurrentAttachment(caster, "attach_arrow")
	caster.ChargeParticle = ParticleManager:CreateParticle("particles/custom/lubu/lubu_arcana_powershot_channel_combo_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, arrow_model)
	ParticleManager:SetParticleControlEnt(caster.ChargeParticle, 0, arrow_model, PATTACH_POINT_FOLLOW, "attach_arrow_tip", arrow_model:GetAbsOrigin(),false)
	--ParticleManager:SetParticleControl( caster.ChargeParticle, 0, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 200, caster:GetAnglesAsVector().y)) 
    ParticleManager:SetParticleControl( caster.ChargeParticle, 1, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 350, caster:GetAnglesAsVector().y)) 
    Timers:CreateTimer(cast_delay, function()
    	if target.FBparticle then 
    		ParticleManager:DestroyParticle(target.FBparticle, true)
    		ParticleManager:ReleaseParticleIndex(target.FBparticle)
    	end
    	if caster.ChargeParticle then 
    		ParticleManager:DestroyParticle(caster.ChargeParticle, true)
			ParticleManager:ReleaseParticleIndex(caster.ChargeParticle)
    	end
    end)

end

function OnFBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ParticleManager:DestroyParticle(target.FBparticle, true)
	ParticleManager:DestroyParticle(caster.ChargeParticle, true)
	ParticleManager:ReleaseParticleIndex(caster.ChargeParticle)
	ParticleManager:ReleaseParticleIndex(target.FBparticle)
	caster:RemoveModifierByName("modifier_bow")
	if not caster:CanEntityBeSeenByMyTeam(target) or caster:GetRangeToUnit(target) > 4500 or caster:GetMana() < ability:GetManaCost(1) or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
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

	caster:EmitSound('Lubu.Arrow')

	-- give vision for enemy
	if IsValidEntity(target) then
		SpawnVisionDummy(target, caster:GetAbsOrigin(), 500, 2, false)
	end

end

function OnFBInterrupted(keys)
	local caster = keys.caster
	local target = keys.target

	ParticleManager:DestroyParticle(target.FBparticle, true)
	ParticleManager:DestroyParticle(caster.ChargeParticle, true)
	ParticleManager:ReleaseParticleIndex(caster.ChargeParticle)
	ParticleManager:ReleaseParticleIndex(target.FBparticle)
	caster:RemoveModifierByName("modifier_bow")
end

function OnFBHit(keys)
	local target = keys.target
	ParticleManager:DestroyParticle(target.FBparticle, true)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster	
	local ability = keys.ability
	target:EmitSound("Misc.Crash")
	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	if not target:IsMagicImmune() and not IsImmuneToCC(target) then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
	
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

    local FBHitFx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(FBHitFx, 3, target:GetAbsOrigin())

	Timers:CreateTimer( 2, function()
		ParticleManager:DestroyParticle( FBHitFx, false )
		ParticleManager:ReleaseParticleIndex( FBHitFx )
	end)

	
end

function OnBowCreate(keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_axe" then 
		if caster:ScriptLookupAttachment("attach_lance") ~= nil then 
			local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
			if lance ~= nil and not lance:IsNull() then
				lance:RemoveSelf()
			end
			Attachments:AttachProp(caster, "attach_bow", "models/lubu/lubu_bow.vmdl")
			Attachments:AttachProp(caster, "attach_arrow", "models/lubu/lubu_arrow2.vmdl")
		end
	end
end

function OnBowDestroy(keys)
	local caster = keys.caster 
	if caster:GetName() == "npc_dota_hero_axe" then
		if caster:ScriptLookupAttachment("attach_bow") ~= nil then 
			local bow = Attachments:GetCurrentAttachment(caster, "attach_bow")
			if bow ~= nil and not bow:IsNull() then
				bow:RemoveSelf()
			end
			local arrow = Attachments:GetCurrentAttachment(caster, "attach_arrow")
			if arrow ~= nil and not arrow:IsNull() then
				arrow:RemoveSelf()
			end
			Attachments:AttachProp(caster, "attach_lance", "models/lubu/lubu_lance2.vmdl")
		end
	end
end

function OnFlyingSTart(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local target = keys.target 

	caster.fly_target = target
	caster:EmitSound('Lubu.Arrow')
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_fly", {})
	if caster.IsMadEnhancementAcquired then
		local mad = caster:FindAbilityByName("lubu_bravary_upgrade")
		mad:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_mad", {Duration = ability:GetSpecialValueFor("duration")})
	end
end

function OnFlyingRun(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local target = caster.fly_target
	keys.target = target

	if target:IsNull() or not target:IsAlive() or not caster:IsAlive() or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then
		caster:RemoveModifierByName("modifier_lubu_fly")
        return
    end

    if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 275 then
    	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*200) 
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        OnFlyingAttack(keys)
        caster:RemoveModifierByName("modifier_lubu_fly")
    end

    if not caster.fly_effect then
    	caster.fly_effect = true
    	local forward_vec = caster:GetForwardVector()
    	local right_vec = caster:GetRightVector()
    	--print('right: ' .. (right_vec*100))
    	local fly_run_effect = ParticleManager:CreateParticle('particles/custom/lubu/lubu_dash_lines.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(fly_run_effect, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fly_run_effect, 1, (right_vec * 100) + Vector(0,-100,50))
		ParticleManager:SetParticleControl(fly_run_effect, 2, (-right_vec * 100) + Vector(0,100,10))
		ParticleManager:SetParticleControl(fly_run_effect, 3, -forward_vec * 20)
		ParticleManager:SetParticleControl(fly_run_effect, 4, -forward_vec * 30)
    	Timers:CreateTimer(0.5, function()
    		ParticleManager:DestroyParticle(fly_run_effect, true)
    		ParticleManager:ReleaseParticleIndex(fly_run_effect)
    		caster.fly_effect = nil
    	end)
    end
 
 	if caster.IsMadEnhancementAcquired then
 		caster:MoveToTargetToAttack(target)
 	else
	 	if not caster:IsStunned() and not caster:IsRooted() then
	    	caster:MoveToTargetToAttack(target)
	    end
	end
end

function OnFlyingAttack(keys)
	local caster = keys.caster	
	local ability = keys.ability
	if ability == nil then 
		ability = caster:FindAbilityByName("lubu_flying_upgrade")
	end
	local target = keys.target

	if not target:IsAlive() or not caster:IsAlive() then 
		return 
	end

	local hit_damage = ability:GetSpecialValueFor("hit_damage")
	local slam_damage = ability:GetSpecialValueFor("slam_damage")
	local slam_stun = ability:GetSpecialValueFor("slam_stun")
	local slam_aoe = ability:GetSpecialValueFor("slam_aoe")
	local anim_duration = 0.4
	DoDamage(caster, target, hit_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_lubu_fly_slam", {Duration = anim_duration})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", anim_duration + 0.1) 

	Timers:CreateTimer(anim_duration, function()
		if not caster:IsAlive() then 
			return 
		end
		if target:IsAlive() then
			target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = slam_stun})
		end
		local smashfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf', PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(smashfx, 0, target:GetAbsOrigin())
		Timers:CreateTimer(1.0, function()
			ParticleManager:DestroyParticle(smashfx, false)
			ParticleManager:ReleaseParticleIndex(smashfx)
		end)
		caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
		local slam_enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, slam_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(slam_enemies) do 
			if IsValidEntity(v) and not v:IsNull() then 
				DoDamage(caster, v, slam_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			end
		end
	end)
end

function OnSlamAnim(keys)
	local caster = keys.caster	
	local target = keys.target
	local caster_angle = caster:GetAnglesAsVector().y
	local target_loc = GetRotationPoint(caster:GetAbsOrigin(), 100, caster_angle + 45)
	local height = 0
	local tick_count = 0
	Timers:CreateTimer('lubu_grip' .. caster:GetPlayerOwnerID(), {
		endTime = 0,
		callback = function()
	   	if target:IsAlive() and caster:IsAlive() and tick_count < 0.4 then 
	   		target_loc = GetRotationPoint(caster:GetAbsOrigin(), 160, caster_angle - 60)
	   		if tick_count < 0.2 then 
	   			height = height + 30
	   			if tick_count > 0.1 then 
	   				target:SetAngles(-90, 0, 0)
	   			end
	   		else
	   			target:SetAngles(-90, 0, 0)
	   			height = height - 30
	   		end
	   		target:SetAbsOrigin(target_loc + Vector(0,0,height))
		else
			target:SetAngles(0, 0, 0)
			local ground = GetGroundPosition(target:GetOrigin(), target)
			target:SetAbsOrigin(ground)
			target:RemoveModifierByName("modifier_lubu_fly_slam")
			return nil
		end
		tick_count = tick_count + 0.033
		return 0.033
	end})
end

function OnFlyingCreate(keys)
	local caster = keys.caster
	caster.fly_run_effect = ParticleManager:CreateParticle('particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_screen_wipe_lines.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.fly_run_effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
end

function OnFlyingDestroy(keys)
	local caster = keys.caster
	ParticleManager:DestroyParticle(caster.fly_run_effect, true)
	ParticleManager:ReleaseParticleIndex(caster.fly_run_effect)
end

function OnBravaryStart(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local particle = 'particles/custom/lubu/lubu_spell_warcry_ti_5.vpcf'
	if caster.IsMadEnhancementAcquired then 
		particle = 'particles/custom/lubu/lubu_spell_warcry_ti_5b.vpcf'
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_bravary", {})
	caster:EmitSound('Lubu.Bravary')
	local lightningFx = {}
	local lightningFx1 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(lightningFx1, 0, caster:GetAbsOrigin())
	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(lightningFx1, false)
		ParticleManager:ReleaseParticleIndex(lightningFx1)
	end)
	for i = 1,6 do
		lightningFx[i] = ParticleManager:CreateParticle('particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_ambient_random.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(lightningFx[i], 1, caster:GetAbsOrigin() + Vector(0,0,RandomInt(10, 60)))
		ParticleManager:SetParticleControl(lightningFx[i], 2, GetRotationPoint(caster:GetAbsOrigin(), 300, (360 / 6) * i))
		Timers:CreateTimer(1.0, function()
			ParticleManager:DestroyParticle(lightningFx[i], false)
			ParticleManager:ReleaseParticleIndex(lightningFx[i])
		end)
	end
	if caster.IsMadEnhancementAcquired then 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_mad", {})
		
		local radius = ability:GetSpecialValueFor("slow_aoe")
		local damage = ability:GetSpecialValueFor("slow_damage")
		
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do 
			if IsValidEntity(v) and not v:IsNull() and not v:IsMagicImmune() and not IsImmuneToCC(v) and not IsImmuneToSlow(v) then
				ability:ApplyDataDrivenModifier(caster, v, "modifier_lubu_fear", {})
			end
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
	end

	LuBuCheckCombo(caster,ability)
end

function OnBravaryAttack(keys)
	local caster = keys.caster 
	local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
	local slashfx = ParticleManager:CreateParticle('particles/custom/lubu/lubu_lance.vpcf',PATTACH_ABSORIGIN_FOLLOW,lance)
	ParticleManager:SetParticleControlEnt(slashfx, 1, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
	ParticleManager:SetParticleControlEnt(slashfx, 7, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
	ParticleManager:SetParticleControlEnt(slashfx, 8, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(slashfx, true)
		ParticleManager:ReleaseParticleIndex(slashfx)
	end)
end

function OnGodForceStart(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local interval = ability:GetSpecialValueFor("interval")
	local radius = ability:GetSpecialValueFor("radius")
	local angle = ability:GetSpecialValueFor("angle")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_lasthit = ability:GetSpecialValueFor("damage_lasthit")
	local mini_stun = ability:GetSpecialValueFor("mini_stun")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local knock = ability:GetSpecialValueFor("knock")	
	local godforce_hit = false
	local sound = false

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", total_hit * interval) 

	local lancetipfx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lightning.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(lancetipfx, 0, caster, PATTACH_POINT_FOLLOW	, "attach_arrow", caster:GetAbsOrigin(),false)
	ParticleManager:SetParticleControlEnt(lancetipfx, 2, caster, PATTACH_POINT_FOLLOW	, "attach_lance", caster:GetAbsOrigin(),false)
	local markfx = ParticleManager:CreateParticle('particles/units/heroes/hero_void_spirit/planeshift/void_spirit_planeshift_untargetable.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(markfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(markfx, 1, caster:GetAbsOrigin())
	Timers:CreateTimer(interval * total_hit, function()
		ParticleManager:DestroyParticle(lancetipfx, false)
		ParticleManager:ReleaseParticleIndex(lancetipfx)
		ParticleManager:DestroyParticle(markfx, false)
		ParticleManager:ReleaseParticleIndex(markfx)
	end)
	for i = 0,total_hit - 1 do 
		Timers:CreateTimer(i * interval, function()
			if caster:IsAlive() then
				if i < total_hit - 1 then 
					local anim = ACT_DOTA_ATTACK
					if i % 2 == 0 then 
						StartAnimation(caster, {duration= (2*interval) - 0.05, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.7})
						anim = ACT_DOTA_ATTACK2
					end
					caster:EmitSound('Hero_Juggernaut.OmniSlash')
					
					--StartAnimation(caster, {duration=interval - 0.05, activity=anim, rate=2.5})
					local slashfxx = ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlForward(slashfxx, 0, caster:GetForwardVector() * -1)
					ParticleManager:SetParticleControl(slashfxx, 1, Vector(0,0,(i % 2) * 180))
					ParticleManager:SetParticleControl(slashfxx, 2, Vector(1,1,radius))
					ParticleManager:SetParticleControl(slashfxx, 3, Vector(radius / 250,1,1))
					Timers:CreateTimer(interval + 1.0, function()
						ParticleManager:DestroyParticle(slashfxx, true)
						ParticleManager:ReleaseParticleIndex(slashfxx)
					end)
				else
					if caster.IsHoutengagekiAcquired then 
						local bonus_str = ability:GetSpecialValueFor("bonus_damage_last")
						damage_lasthit = damage_lasthit + (bonus_str * caster:GetStrength())
					end	
					EmitGlobalSound('Lubu.GodForce')
					caster:EmitSound("Hero_PrimalBeast.Uproar.Projectile.Split")
					StartAnimation(caster, {duration=interval + 0.3, activity=ACT_DOTA_ATTACK_EVENT, rate=1/(interval + 0.3)})
					local thrustfx = ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/last_hit.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(thrustfx, 0, caster:GetAbsOrigin())
					Timers:CreateTimer(0.8, function()
						ParticleManager:DestroyParticle(thrustfx, false)
						ParticleManager:ReleaseParticleIndex(thrustfx)
					end)
				end
				godforce_hit = false
				sound = false
				local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				if i >= total_hit - 1 then 
					local caster_origin = caster:GetAbsOrigin()
					for k,v in pairs(targets) do
						if IsValidEntity(v) and not v:IsNull()then
							if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
							end
					        
					        if caster.IsRuthlessWarriorAcquired then 
								local MR = v:GetBaseMagicalResistanceValue()/100
				            	local dmg_deal = damage_lasthit * (1-MR) 
				            	if godforce_hit == false then
				            		OnRuthlessDrain(caster, 1, dmg_deal)
				            	else
				            		OnRuthlessDrain(caster, 0, dmg_deal)
				            	end
				            end

				            if k == 1 then 
				            	v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
				            end
				            DoDamage(caster, v, damage_lasthit, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					        if godforce_hit == false then
					        	godforce_hit = true 
					        	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_god_str", {})
								local stack = caster:GetModifierStackCount("modifier_lubu_god_str", caster) or 0
								caster:SetModifierStackCount("modifier_lubu_god_str", caster, math.min(total_hit, stack + 1))
					        end
					        if IsValidEntity(v) and not v:IsNull() and not IsKnockbackImmune(v) and not v:IsMagicImmune() then
								local pushback = Physics:Unit(v)
								v:PreventDI()
								v:SetPhysicsFriction(0)
								v:SetPhysicsVelocity((v:GetAbsOrigin() - caster_origin):Normalized() * knock)
								v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
								v:FollowNavMesh(false)
								Timers:CreateTimer(0.5, function()  
									if IsValidEntity(v) then
										v:PreventDI(false)
										v:SetPhysicsVelocity(Vector(0,0,0))
										v:OnPhysicsFrame(nil)
										FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
									end
								end)
							end
						end
				    end
				else
					for k,v in pairs(targets) do
						if IsValidEntity(v) and not v:IsNull() then
							local caster_angle = caster:GetAnglesAsVector().y
							--print('lubu angle ' .. caster_angle)
					        local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

					        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

					        origin_difference_radian = origin_difference_radian * 180
					        local enemy_angle = origin_difference_radian / math.pi

					        enemy_angle = enemy_angle + 180.0
					        --print('enemy angle ' .. enemy_angle)

					        if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
					        	enemy_angle = 360 - enemy_angle
					        elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
					        	caster_angle = 360 - caster_angle 
					        end

					        local result_angle = math.abs(enemy_angle - caster_angle)

					        --result_angle = math.abs(result_angle)

					        if result_angle <= angle/2 then
					        	if not v:IsMagicImmune() and not IsImmuneToCC(v) then
									v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = mini_stun})
								end
								if sound == false  then 
									v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
									sound = true 
								end
					        	if caster.IsRuthlessWarriorAcquired then 
									local MR = v:GetBaseMagicalResistanceValue()/100
				            		local dmg_deal = damage * (1-MR) 
				            		if godforce_hit == false then
				            			OnRuthlessDrain(caster, 1, dmg_deal)
				            		else
				            			OnRuthlessDrain(caster, 0, dmg_deal)
				            		end
				            	end
				            	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					        	if godforce_hit == false then
					        		godforce_hit = true 
					        		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_god_str", {})
									local stack = caster:GetModifierStackCount("modifier_lubu_god_str", caster) or 0
									caster:SetModifierStackCount("modifier_lubu_god_str", caster, math.min(total_hit, stack + 1))
					        	end
					        end
					    end
				    end
				end
			end
		end)
	end
end

function ImmortalRedHareTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damageTaken = keys.DamageTaken
	local revive_health = ability:GetSpecialValueFor("revive_health") / 100
	local invul_dur = ability:GetSpecialValueFor("invul_dur")

	if caster:GetHealth() > damageTaken then 
		return 
	end

	if IsReviveSeal(caster) or caster:HasModifier("modifier_lubu_immortal_cooldown") or IsRevoked(caster) or not IsRevivePossible(caster) then 
		return 
	end

	if caster:GetHealth() == 0 and caster:FindAbilityByName("lubu_immortal_red_hare"):IsCooldownReady() then

		ability:StartCooldown(ability:GetCooldown(1))

		HardCleanse(caster)
		caster:SetHealth(caster:GetMaxHealth() * revive_health)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_immortal",{})
		caster:EmitSound("Hero_SkeletonKing.Reincarnate")
		
		local reviveFx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 3, caster:GetAbsOrigin())

		local invule = FxCreator("particles/custom/vlad/vlad_bc_buff.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
		ParticleManager:SetParticleControlEnt(invule, 2, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_immortal_cooldown", {Duration = ability:GetCooldown(1)})
		
		Timers:CreateTimer( invul_dur, function()
			ParticleManager:DestroyParticle( reviveFx, false )
			ParticleManager:DestroyParticle( invule, false )
			ParticleManager:ReleaseParticleIndex(reviveFx)
			ParticleManager:ReleaseParticleIndex(invule)
		end)
	end
end

function OnRuthlessThink(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local currentPercentHP = caster:GetHealthPercent()
	local HpLoss = 100 - currentPercentHP 
	if caster:IsAlive() then
		if HpLoss > 0 then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_ruthless_stack", {})
			caster:SetModifierStackCount("modifier_lubu_ruthless_stack", caster, HpLoss)
		else
			caster:RemoveModifierByName("modifier_lubu_ruthless_stack")
		end
	end
end

function OnRuthlessDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_lubu_ruthless_stack")
end

function OnRuthlessAttack(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage
	local damage_splash = damage * ability:GetSpecialValueFor("splash_percentage") / 100
    local splash_aoe = ability:GetSpecialValueFor("splash_aoe")
    if target == caster:GetAttackTarget() and caster:IsAlive() then

      	OnRuthlessDrain(caster, 1, damage)

      	local targets_splash = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

      	for k,v in pairs(targets_splash) do
        	if IsValidEntity(v) and not v:IsNull() and v ~= target and v:IsRealHero() then
	          	DoDamage(caster, v, damage_splash, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
	          	local reduction = GetPhysicalDamageReduction(v:GetPhysicalArmorValue(false))
	            local dmg_deal = damage_splash * (1-reduction)
	          	OnRuthlessDrain(caster, 0, dmg_deal)
        	end
      	end
    end
end

function OnRuthlessDrain(caster, count, damage)
	local ability = caster:FindAbilityByName("lubu_ruthless_warrior")
	local drain = ability:GetSpecialValueFor("drain_hp") / 100 
	local atk_count = ability:GetSpecialValueFor("atk_count_drain_hp")

	local stack = caster:GetModifierStackCount("modifier_lubu_ruthless_counter", caster) or 0 
	stack = stack + count 
	if (stack >= atk_count) or (stack == 0 and count == 0) then 
		stack = 0
		caster:Heal(drain * damage, caster)
		if not caster.drainfx then 
			local drainfx = ParticleManager:CreateParticle('particles/econ/items/lifestealer/ls_ti9_immortal_gold/ls_ti9_open_wounds_gold_wisp.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(drainfx, 0, caster:GetAbsOrigin() + Vector(0,0,50))
			caster.drainfx = true
			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(drainfx, false)
				ParticleManager:ReleaseParticleIndex(drainfx)
				caster.drainfx = false
			end)
		end
	end
	caster:SetModifierStackCount("modifier_lubu_ruthless_counter", caster, math.min(stack,atk_count))
end

function LuBuCheckCombo(caster,ability)
	if math.ceil(caster:GetStrength()) >= 25 and math.ceil(caster:GetAgility()) >= 25 and math.ceil(caster:GetIntellect()) >= 25 then
		if string.match(ability:GetAbilityName(), "lubu_bravary") then
			if caster.IsDragonTongueBowAcquired then
				if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and caster:FindAbilityByName("lubu_combo_god_force_upgrade"):IsCooldownReady() and not caster:HasModifier("modifier_lubu_combo_cooldown") then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_combo_window", {})
				end
			else
				if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() and caster:FindAbilityByName("lubu_combo_god_force"):IsCooldownReady() and not caster:HasModifier("modifier_lubu_combo_cooldown") then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_combo_window", {})
				end
			end
		end
	end
end

function OnGodForceComboWindow(keys)
	local caster = keys.caster 
	if caster.IsDragonTongueBowAcquired then
		caster:SwapAbilities(caster.RSkill, "lubu_combo_god_force_upgrade", false, true)
	else
		caster:SwapAbilities(caster.RSkill, "lubu_combo_god_force", false, true)
	end
end

function OnGodForceComboDestroy(keys)
	local caster = keys.caster 
	if caster.IsDragonTongueBowAcquired then
		caster:SwapAbilities(caster.RSkill, "lubu_combo_god_force_upgrade", true, false)
	else
		caster:SwapAbilities(caster.RSkill, "lubu_combo_god_force", true, false)
	end
end

function OnGodForceComboDeath(keys)
	local caster = keys.caster 
	caster:RemoveModifierByName("modifier_lubu_combo_window")
end

function OnGodForceComboStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 
	local position = nil
	if target == nil then 
		position = ability:GetCursorPosition() 
	end
	local delay = ability:GetSpecialValueFor("delay")
	local aoe = ability:GetSpecialValueFor("aoe")
	local arrow_aoe = ability:GetSpecialValueFor("arrow_aoe")
	local arrows = ability:GetSpecialValueFor("arrows")
	local damage = ability:GetSpecialValueFor("damage")

	caster:RemoveModifierByName("modifier_lubu_combo_window")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lubu_combo_cooldown", {duration = ability:GetCooldown(1)})

	local god_force = caster:FindAbilityByName(caster.RSkill)
	god_force:StartCooldown(god_force:GetCooldown(god_force:GetLevel()))

	local MasterCombo = caster.MasterUnit2:FindAbilityByName("lubu_combo_god_force")
	MasterCombo:EndCooldown()
  	MasterCombo:StartCooldown(MasterCombo:GetCooldown(1))

  	EmitGlobalSound('Lubu.PreCombo')

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", delay + 0.3)
	if caster.Skin == 3 then 
		StartAnimation(caster, {duration=delay + 0.3, activity=ACT_DOTA_CAST_ABILITY_3, rate= 1 / delay})
		local bodyfx = ParticleManager:CreateParticle('particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf', PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(bodyfx, 0, caster:GetAbsOrigin() + Vector(0,0,80))
		local groundfx = ParticleManager:CreateParticle('models/heroes/dawnbreaker/debut/particles/battlemaiden_debut_intro_fall_ground_burn.vpcf', PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(groundfx, 0, caster:GetAbsOrigin())
		Timers:CreateTimer(delay + 0.3, function()
			ParticleManager:DestroyParticle(bodyfx, true)
			ParticleManager:ReleaseParticleIndex(bodyfx)
			ParticleManager:DestroyParticle(groundfx, true)
			ParticleManager:ReleaseParticleIndex(groundfx)
		end)
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bow", {})
		local arrow_model = Attachments:GetCurrentAttachment(caster, "attach_arrow")
		StartAnimation(caster, {duration=delay + 0.3, activity=ACT_DOTA_CAST_ABILITY_2, rate= 1 / delay})
		local bodyfx = ParticleManager:CreateParticle('particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf', PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(bodyfx, 0, caster:GetAbsOrigin() + Vector(0,0,80))
		local groundfx = ParticleManager:CreateParticle('models/heroes/dawnbreaker/debut/particles/battlemaiden_debut_intro_fall_ground_burn.vpcf', PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(groundfx, 0, caster:GetAbsOrigin())
		local thrustfx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lightning_bolt.vpcf", PATTACH_POINT_FOLLOW, caster)
		--ParticleManager:SetParticleControl(thrustfx, 0, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 300, caster:GetAnglesAsVector().y))
		ParticleManager:SetParticleControlEnt(thrustfx, 0, caster, PATTACH_POINT_FOLLOW	, "attach_arrow", caster:GetAbsOrigin(),false)
		ParticleManager:SetParticleControlEnt(thrustfx, 1, arrow_model, PATTACH_POINT_FOLLOW	, "attach_arrow_tip", arrow_model:GetAbsOrigin(),false)
		local ChargeParticle = ParticleManager:CreateParticle("particles/custom/lubu/lubu_arcana_powershot_channel_combo_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, arrow_model)
		ParticleManager:SetParticleControlEnt(ChargeParticle, 0, arrow_model, PATTACH_POINT_FOLLOW, "attach_arrow_tip", arrow_model:GetAbsOrigin(),false)
		--ParticleManager:SetParticleControl( caster.ChargeParticle, 0, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 200, caster:GetAnglesAsVector().y)) 
	    ParticleManager:SetParticleControl( ChargeParticle, 1, GetRotationPoint(caster:GetAbsOrigin() + Vector(0,0,80), 200, caster:GetAnglesAsVector().y)) 
	
		Timers:CreateTimer(delay + 0.3, function()
			ParticleManager:DestroyParticle(thrustfx, true)
			ParticleManager:ReleaseParticleIndex(thrustfx)
			ParticleManager:DestroyParticle(ChargeParticle, true)
			ParticleManager:ReleaseParticleIndex(ChargeParticle)
			ParticleManager:DestroyParticle(bodyfx, true)
			ParticleManager:ReleaseParticleIndex(bodyfx)
			ParticleManager:DestroyParticle(groundfx, true)
			ParticleManager:ReleaseParticleIndex(groundfx)
		end)
	end

	Timers:CreateTimer(delay, function()
		if caster:IsAlive() then
			EmitGlobalSound('Lubu.GodForce')
			for i = 1, arrows do 
				Timers:CreateTimer(i * 0.05, function()
					if target == nil then
						local arrow_pos = GetRotationPoint(position, aoe - arrow_aoe, (360 / arrows) * i)
						GodForceComboFire(caster,ability,arrow_pos,false)
						--print(arrow_pos)
					else
						GodForceComboFire(caster,ability,target,true)
					end
				end)
			end
		end
	end)
end

function GodForceComboFire(caster,ability,hTarget,bAim)
	local target = hTarget
	if bAim == false then
		local dummy = CreateUnitByName("dummy_unit", hTarget, false, caster, caster, caster:GetTeamNumber())
    	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
    	dummy:AddNewModifier(caster, nil, 'modifier_kill', {Duration = 5.0})
    	target = dummy

	end

    local projectile = {
	   	Target = target,
		Source = caster,
		Ability = ability,	
	    EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
	    iMoveSpeed = 3000,
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
	    bDodgeable = false,
	    bIsAttack = false,
	    bVisibleToEnemies = true,
	    bReplaceExisting = false,
	    flExpireTime = GameRules:GetGameTime() + 3,
		bProvidesVision = false,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function OnGodForceComboHit(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local target = keys.target 
	local arrow_aoe = ability:GetSpecialValueFor("arrow_aoe")
	local damage = ability:GetSpecialValueFor("damage")

	target:EmitSound("Misc.Crash")
	local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster)
	local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_ABSORIGIN, caster)
	local explodeFx1 = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_hit.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( fire, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl( crack, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl( explodeFx1, 0, target:GetAbsOrigin())

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, arrow_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
		
	Timers:CreateTimer( 2.0, function()
	ParticleManager:DestroyParticle( crack, false )
		ParticleManager:DestroyParticle( fire, false )
		ParticleManager:DestroyParticle( explodeFx1, false )
	end)
	if string.match(target:GetUnitName(), 'dummy_unit') then 
		if IsValidEntity(target) then
			target:RemoveSelf()
		end
	end
end

lubu_circular_blade = class({})
lubu_circular_blade_upgrade = class({})
LinkLuaModifier("modifier_lubu_circular_window", "abilities/lubu/lubu_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lubu_circular_tracker", "abilities/lubu/lubu_abilities", LUA_MODIFIER_MOTION_NONE)

function lubu_blade_wrapper(blade)
	function blade:GetCastPoint()
		if self:CheckSequence() == 2 then
			return 0.1
		elseif self:CheckSequence() == 1 then
			return 0.2
		else
			return 0.2
		end
	end

	function blade:CheckSequence()
		local caster = self:GetCaster()

		if caster:HasModifier("modifier_lubu_circular_tracker") then
			local stack = caster:GetModifierStackCount("modifier_lubu_circular_tracker", caster)

			return stack
		else
			return 0
		end	
	end

	function blade:GetPlaybackRateOverride()
		if self:CheckSequence() == 2 then
			return 2.6
		elseif self:CheckSequence() == 1 then
			return 2.5
		else
			return 2.5
		end
	end

	function blade:GetCastAnimation()
		if self:CheckSequence() == 2 then
			return ACT_DOTA_CAST_ABILITY_1
		elseif self:CheckSequence() == 1 then
			return ACT_DOTA_ATTACK
		else
			return ACT_DOTA_ATTACK2
		end
	end

	function blade:GetCastRange(vLocation, hTarget)
		if self:CheckSequence() == 2 then
			return self:GetSpecialValueFor("third_aoe")
		elseif self:CheckSequence() == 1 then
			return self:GetSpecialValueFor("second_aoe")
		else
			return self:GetSpecialValueFor("first_aoe")
		end
	end

	function blade:GetAbilityTextureName()
		if self:CheckSequence() == 2 then
			return "custom/lubu/lubu_blade3"
		elseif self:CheckSequence() == 1 then
			return "custom/lubu/lubu_blade2"
		else
			return "custom/lubu/lubu_blade1"
		end
	end

	function blade:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local total_slash = self:GetSpecialValueFor("total_slash")
		local first_aoe = self:GetSpecialValueFor("first_aoe")
		local second_aoe = self:GetSpecialValueFor("second_aoe")
		local third_aoe = self:GetSpecialValueFor("third_aoe")
		local damage_1 = self:GetSpecialValueFor("damage_1")
		local damage_2 = self:GetSpecialValueFor("damage_2")
		local damage_3 = self:GetSpecialValueFor("damage_3")
		local third_knock = self:GetSpecialValueFor("third_knock")
		local window_duration = self:GetSpecialValueFor("window_duration")
		local radius = first_aoe
		local damage = damage_1
		local origin = caster:GetAbsOrigin()
		local delay = 0.2
		local blade_hit = false

		giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", delay)

		if self:CheckSequence() == total_slash - 1 then
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 3)
			radius = third_aoe
			damage = damage_3
			Timers:CreateTimer(delay, function()
				origin = GetRotationPoint(origin, caster:GetBaseAttackRange(),caster:GetAnglesAsVector().y)
			end)
			ability:EndCooldown()
			caster:RemoveModifierByName('modifier_lubu_circular_window')
		elseif self:CheckSequence() == total_slash - 2 then
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 2)
			radius = second_aoe
			damage = damage_2
			ability:EndCooldown()
			Timers:CreateTimer(delay, function()
				origin = caster:GetAbsOrigin()
			end)
		else
			caster:AddNewModifier(caster, self, "modifier_lubu_circular_window", {Duration = window_duration})
			caster:AddNewModifier(caster, self, "modifier_lubu_circular_tracker", {Duration = window_duration})
			caster:SetModifierStackCount("modifier_lubu_circular_tracker", caster, 1)
			ability:EndCooldown()
			Timers:CreateTimer(delay, function()
				origin = caster:GetAbsOrigin()
			end)
		end

		local dash = Physics:Unit(caster)
		caster:PreventDI()
		caster:SetPhysicsFriction(0)
		caster:SetPhysicsVelocity(caster:GetForwardVector()*500)
		caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
		caster:FollowNavMesh(false)

		if self:CheckSequence() < total_slash then 
			DoCleaveAttack(caster, caster, self, 0, 180, radius, radius, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf")
		end

		Timers:CreateTimer(delay, function()
			caster:OnPreBounce(nil)
			caster:OnPhysicsFrame(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:EmitSound('Lubu.Blade')
			if caster:IsAlive() then
				local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
					if self:CheckSequence() >= total_slash then 
						if IsValidEntity(v) and not v:IsNull() then
							if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								ApplyAirborne(caster, v, third_knock)
							end
							if caster.IsHoutengagekiAcquired then 
								local damage_3_per_str = ability:GetSpecialValueFor("damage_3_per_str")
								damage = damage + (damage_3_per_str * caster:GetStrength())
							end
							DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
							if caster.IsRuthlessWarriorAcquired then
								local MR = v:GetBaseMagicalResistanceValue()/100
			            		local dmg_deal = damage * (1-MR) 
								if k == 1 then 
									OnRuthlessDrain(caster, 1, dmg_deal)
									v:EmitSound('Hero_EarthShaker.Fissure')
								else
									OnRuthlessDrain(caster, 0, dmg_deal)
								end
							end
						end
					else
						if IsValidEntity(v) and not v:IsNull() then
							local angle = 180
							local caster_angle = caster:GetAnglesAsVector().y
							--print('lubu angle ' .. caster_angle)
					        local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

					        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

					        origin_difference_radian = origin_difference_radian * 180
					        local enemy_angle = origin_difference_radian / math.pi

					        enemy_angle = enemy_angle + 180.0
					        --print('enemy angle ' .. enemy_angle)

					        if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
					        	enemy_angle = 360 - enemy_angle
					        elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
					        	caster_angle = 360 - caster_angle 
					        end

							local result_angle = enemy_angle - caster_angle
							result_angle = math.abs(result_angle)

							if result_angle <= angle/2 then
								DoDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability, false)
								if caster.IsRuthlessWarriorAcquired then
									local reduction = GetPhysicalDamageReduction(v:GetPhysicalArmorValue(false))
			            			local dmg_deal = damage * (1-reduction) 
									if blade_hit == false then
										blade_hit = true
										OnRuthlessDrain(caster, 1, dmg_deal)
										v:EmitSound('Hero_Sven.Attack')
									else
										OnRuthlessDrain(caster, 0, dmg_deal) 
									end
								end
							end
						end
					end
				end
				if self:CheckSequence() >= total_slash then 
					if caster:HasModifier('modifier_lubu_circular_tracker') then 
						caster:RemoveModifierByName('modifier_lubu_circular_tracker')
					end
					local smashfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf', PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControl(smashfx, 0, GetRotationPoint(caster:GetAbsOrigin(), caster:GetBaseAttackRange(),caster:GetAnglesAsVector().y))
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(smashfx, false)
						ParticleManager:ReleaseParticleIndex(smashfx)
					end)
				end
			end
		end)
	end
end
	
lubu_blade_wrapper(lubu_circular_blade_upgrade)
lubu_blade_wrapper(lubu_circular_blade)		

modifier_lubu_circular_window = class({})	

function modifier_lubu_circular_window:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_lubu_circular_window:IsHidden()
	return false 
end

function modifier_lubu_circular_window:IsDebuff()
	return false 
end

function modifier_lubu_circular_window:RemoveOnDeath()
	return true 
end

if IsServer() then
	function modifier_lubu_circular_window:OnDestroy()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		local time = self:GetDuration() - self:GetRemainingTime()
		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()) - time)
	end
end

modifier_lubu_circular_tracker = class({})	

function modifier_lubu_circular_tracker:GetAttributes() 
	return {MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE, MODIFIER_ATTRIBUTE_PERMANENT}
end

function modifier_lubu_circular_tracker:IsHidden()
	return true 
end

function modifier_lubu_circular_tracker:IsDebuff()
	return false 
end

function modifier_lubu_circular_tracker:RemoveOnDeath()
	return true 
end

function OnHoutengagekiAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsHoutengagekiAcquired) then
		if hero:HasModifier('modifier_lubu_combo_window') then 
			hero:RemoveModifierByName('modifier_lubu_combo_window')
		end
	
		hero.IsHoutengagekiAcquired = true

		UpgradeAttribute(hero, "lubu_circular_blade", "lubu_circular_blade_upgrade", true)
		UpgradeAttribute(hero, "lubu_god_force_new", "lubu_god_force_new_upgrade", true)
		hero.QSkill = "lubu_circular_blade_upgrade"
		hero.RSkill = "lubu_god_force_new_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnMadEnhancementAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsMadEnhancementAcquired) then
	
		hero.IsMadEnhancementAcquired = true
		if hero:HasModifier('modifier_lubu_combo_window') then 
			hero:RemoveModifierByName('modifier_lubu_combo_window')
		end
		UpgradeAttribute(hero, "lubu_bravary", "lubu_bravary_upgrade", true)
		UpgradeAttribute(hero, "lubu_flying", "lubu_flying_upgrade", true)
		hero.WSkill = "lubu_flying_upgrade"
		hero.ESkill = "lubu_bravary_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnDragonTongueBowAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsDragonTongueBowAcquired) then
	
		hero.IsDragonTongueBowAcquired = true
		--UpgradeAttribute(hero, "lubu_fallible_bow", "lubu_fallible_bow_upgrade", true)
		UpgradeAttribute(hero, "lubu_combo_god_force", "lubu_combo_god_force_upgrade", false)
		hero.ComboSkill = "lubu_combo_god_force_upgrade"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnRuthlessWarriorAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsRuthlessWarriorAcquired) then
	
		hero.IsRuthlessWarriorAcquired = true
		hero:FindAbilityByName('lubu_ruthless_warrior'):SetLevel(1)

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnImmortalAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsImmortalAcquired) then
	
		hero.IsImmortalAcquired = true
		hero:FindAbilityByName('lubu_immortal_red_hare'):SetLevel(1)
		hero:SwapAbilities('fate_empty1', 'lubu_immortal_red_hare', false, true)
		hero.FSkill = "lubu_immortal_red_hare"

		NonResetAbility(hero)

		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end


--ATTEMPT ON LUA

LinkLuaModifier("modifier_lubu_god_force", "abilities/lubu/lubu_abilities", LUA_MODIFIER_MOTION_NONE)

modifier_lubu_god_force = class({})

function modifier_lubu_god_force:IsHidden()
	return false 
end

function modifier_lubu_god_force:IsPurgable()
    return false
end

function modifier_lubu_god_force:RemoveOnDeath()
    return true
end

function modifier_lubu_god_force:OnCreated()
    local ability = self:GetAbility()

    if ability and not ability:IsNull() then
        self.movespeed_bonus = ability:GetSpecialValueFor("movespeed_bonus")
        self.turn_rate_reduction = ability:GetSpecialValueFor("turn_rate_reduction")
    else
        self.movespeed_bonus = 150 -- Default value if ability is missing
        self.turn_rate_reduction = -200 -- Default value if ability is missing
    end
end

function modifier_lubu_god_force:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return funcs
end

function modifier_lubu_god_force:GetModifierMoveSpeed_Absolute()
    return self.movespeed_bonus
end

function modifier_lubu_god_force:GetModifierTurnRate_Percentage()
    return self.turn_rate_reduction
end

function modifier_lubu_god_force:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end


lubu_god_force_new = class({})
lubu_god_force_new_upgrade = class({})

function lubu_god_force_new_wrapper(ability)

	 function ability:GetAbilityTextureName()
        if self:GetCaster():HasModifier("modifier_alternate_03") then
            return "custom/lubu/lubu_god_force_skin"
        else
            return "custom/lubu/lubu_god_force"
        end
    end    

    function ability:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local radius = ability:GetSpecialValueFor("radius")
	local interval = ability:GetSpecialValueFor("interval")
	local angle = ability:GetSpecialValueFor("angle")
	local total_hit = ability:GetSpecialValueFor("total_hit")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_spin = ability:GetSpecialValueFor("damage_spin")
	local damage_thrust = ability:GetSpecialValueFor("damage_thrust")
	local mini_stun = ability:GetSpecialValueFor("mini_stun")
	local spin_stun = ability:GetSpecialValueFor("spin_stun")
	local thrust_stun = ability:GetSpecialValueFor("thrust_stun")
	local thrust_distance = ability:GetSpecialValueFor("thrust_distance")
	local thrust_width = ability:GetSpecialValueFor("thrust_width")
	local knock = ability:GetSpecialValueFor("knock")	
	local bonus_dmg = 0
	local hit_count = 0
	local targets
	local sound = false

    local modifierDuration = (total_hit + 1) * interval
    print("Modifier Duration: " .. modifierDuration) -- Print out the modifier duration for debugging purposes

    caster:AddNewModifier(caster, ability, "modifier_lubu_god_force", {Duration = modifierDuration})
	giveUnitDataDrivenModifier(caster,caster,"revoked", (total_hit + 1) * interval)

	local markfx = ParticleManager:CreateParticle('particles/units/heroes/hero_void_spirit/planeshift/void_spirit_planeshift_untargetable.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(markfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(markfx, 1, caster:GetAbsOrigin())
	Timers:CreateTimer(interval * total_hit, function()
		ParticleManager:DestroyParticle(markfx, false)
		ParticleManager:ReleaseParticleIndex(markfx)
	end)

	Timers:CreateTimer( function()
		if caster:IsAlive() and hit_count < total_hit + 1 then 
			local caster_angle = caster:GetAnglesAsVector().y
			caster:EmitSound("Hero_PhantomLancer.Attack")
			targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			if hit_count < 3 then 
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_dmg = ability:GetSpecialValueFor("bonus_hp_dmg")	/ 100 
					bonus_dmg = caster:GetMaxHealth() * bonus_hp_dmg
				end

				if hit_count == 0 then 
					if caster:HasModifier("modifier_alternate_03") then 
						print('dynasty lubu')
						StartAnimation(caster, {duration= (3*interval) - 0.05, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.5})
					else
						StartAnimation(caster, {duration= (3*interval) - 0.05, activity=ACT_DOTA_CAST_ABILITY_4, rate=2.3})
					end
				end
				local slashfxx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_new_r_grow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(slashfxx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(slashfxx, 1, Vector(radius, 12, 0))
				ParticleManager:SetParticleControl(slashfxx, 2, Vector((30 * hit_count) / math.max(1,hit_count), caster_angle + 180,((hit_count + 1) % 2) * 180)) --(roll,pitch,yaw)
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(slashfxx, false)
					ParticleManager:ReleaseParticleIndex(slashfxx)
				end)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull() then
						local caster_angle = caster:GetAnglesAsVector().y
							--print('lubu angle ' .. caster_angle)
					    local origin_difference = caster:GetAbsOrigin() - v:GetAbsOrigin()

					    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

					    origin_difference_radian = origin_difference_radian * 180
					    local enemy_angle = origin_difference_radian / math.pi

					    enemy_angle = enemy_angle + 180.0
					        --print('enemy angle ' .. enemy_angle)

					    if (caster_angle < angle/2 and enemy_angle > 360 - angle/2) then
					        enemy_angle = 360 - enemy_angle
					    elseif (enemy_angle < angle/2 and caster_angle > 360 - angle/2) then 
					      	caster_angle = 360 - caster_angle 
					    end

					    local result_angle = math.abs(enemy_angle - caster_angle)

					    if result_angle <= angle/2 then
					        if not v:IsMagicImmune() and not IsImmuneToCC(v) then
								v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = mini_stun})
							end
							if sound == false  then 
								v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
								sound = true 
							end
					        if caster.IsRuthlessWarriorAcquired then 
								local MR = v:GetBaseMagicalResistanceValue()/100
				            	local dmg_deal = (damage + bonus_dmg) * (1-MR) 
				            	if godforce_hit == false then
				            		OnRuthlessDrain(caster, 1, dmg_deal)
				            	else
				            		OnRuthlessDrain(caster, 0, dmg_deal)
				            	end
				            end
				            DoDamage(caster, v, damage + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					    end
					end
				end
				sound = false
			elseif hit_count == 3 then 
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_dmg = ability:GetSpecialValueFor("bonus_hp_dmg")	/ 100 
					bonus_dmg = caster:GetHealth() * bonus_hp_dmg
				end
				if caster:HasModifier("modifier_alternate_03") then
					StartAnimation(caster, {duration= (2*interval), activity=ACT_DOTA_CAST_ABILITY_4_END, rate=1.0})
					local angle = caster:GetAnglesAsVector().y
					for i = 0,15 do 
						Timers:CreateTimer(i * 0.04, function()
							caster:SetAngles(0, angle + (i * 24), 0)
						end)
						if i == 15 then
							caster:SetAngles(0, 0, 0)
						end
					end
				else
					StartAnimation(caster, {duration= (2*interval), activity=ACT_DOTA_CAST_ABILITY_4_END, rate=3.0})
				end
				
				local slashfxx = ParticleManager:CreateParticle("particles/custom/lubu/lubu_new_r_grow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(slashfxx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(slashfxx, 1, Vector(radius, 7, 0))
				ParticleManager:SetParticleControl(slashfxx, 2, Vector(0, caster_angle, 0)) --(roll,pitch,yaw)
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(slashfxx, false)
					ParticleManager:ReleaseParticleIndex(slashfxx)
				end)
				
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull()then
						if not v:IsMagicImmune() and not IsImmuneToCC(v) then
							v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = spin_stun})
						end
					        
					    if caster.IsRuthlessWarriorAcquired then 
							local MR = v:GetBaseMagicalResistanceValue()/100
				           	local dmg_deal = (damage_spin + bonus_dmg) * (1-MR) 
				           	if godforce_hit == false then
				           		OnRuthlessDrain(caster, 1, dmg_deal)
				           	else
				           		OnRuthlessDrain(caster, 0, dmg_deal)
				           	end
				        end

				        if k == 1 then 
				           	v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
				        end
				        DoDamage(caster, v, damage_spin + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				    end
				end
			elseif hit_count == 4 then 
				if caster:HasModifier("modifier_alternate_03") then
					--[[local lancetip = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lance_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(lancetip, 0, caster, PATTACH_POINT_FOLLOW	, "attach_lance", caster:GetAbsOrigin(),false)
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(lancetip, false)
						ParticleManager:ReleaseParticleIndex(lancetip)
					end)]]
				else
					local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
					local lancetip = ParticleManager:CreateParticle("particles/custom/lubu/lubu_lance_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, lance)
					ParticleManager:SetParticleControlEnt(lancetip, 0, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
					Timers:CreateTimer(1.0, function()
						ParticleManager:DestroyParticle(lancetip, false)
						ParticleManager:ReleaseParticleIndex(lancetip)
					end)
				end
			elseif hit_count == 5 then
				EmitGlobalSound('Lubu.GodForce')
				caster:EmitSound("Hero_PrimalBeast.Uproar.Projectile.Split")
				local lance = Attachments:GetCurrentAttachment(caster, "attach_lance")
				local end_point = GetRotationPoint(caster:GetAbsOrigin(), thrust_distance, caster:GetAnglesAsVector().y)
				local thrustfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_WORLDORIGIN, caster)
				--ParticleManager:SetParticleControlEnt(thrustfx, 0, lance, PATTACH_POINT_FOLLOW	, "attach_lance_tip", lance:GetAbsOrigin(),false)
				ParticleManager:SetParticleControl(thrustfx, 0, caster:GetAbsOrigin() + Vector(0,0,100))
				ParticleManager:SetParticleControl(thrustfx, 1, end_point + Vector(0,0,100))
				Timers:CreateTimer(1.0, function()
					ParticleManager:DestroyParticle(thrustfx, false)
					ParticleManager:ReleaseParticleIndex(thrustfx)
				end)
				if caster.IsHoutengagekiAcquired then 
					local bonus_hp_thrust_dmg = ability:GetSpecialValueFor("bonus_hp_thrust_dmg")	/ 100 
					bonus_dmg = caster:GetHealth() * bonus_hp_thrust_dmg
				end
				targets = FindUnitsInLine(caster:GetTeam(), caster:GetAbsOrigin(), end_point, nil, thrust_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE)
				for k,v in pairs(targets) do
					if IsValidEntity(v) and not v:IsNull()then
						if not v:IsMagicImmune() and not IsImmuneToCC(v) then
							v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = thrust_stun})
						end
					        
					    if caster.IsRuthlessWarriorAcquired then 
							local MR = v:GetBaseMagicalResistanceValue()/100
				           	local dmg_deal = (damage_thrust + bonus_dmg) * (1-MR) 
				           	if godforce_hit == false then
				           		OnRuthlessDrain(caster, 1, dmg_deal)
				           	else
				           		OnRuthlessDrain(caster, 0, dmg_deal)
				           	end
				        end

				        if k == 1 then 
				           	v:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
				        end
				        DoDamage(caster, v, damage_thrust + bonus_dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				        if IsValidEntity(v) and not v:IsNull() and not IsKnockbackImmune(v) and not v:IsMagicImmune() then
							local pushback = Physics:Unit(v)
							v:PreventDI()
							v:SetPhysicsFriction(0)
							v:SetPhysicsVelocity((v:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * knock)
							v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
							v:FollowNavMesh(false)
							Timers:CreateTimer(0.5, function()  
								if IsValidEntity(v) then
									v:PreventDI(false)
									v:SetPhysicsVelocity(Vector(0,0,0))
									v:OnPhysicsFrame(nil)
									FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
								end
							end)
						end
				    end
				end

			end

			hit_count = hit_count + 1 
			return interval
		else
			return nil 
		end
	end)
    end
end

lubu_god_force_new_wrapper(lubu_god_force_new)
lubu_god_force_new_wrapper(lubu_god_force_new_upgrade)