jeanne_la_pucelle = class({})

LinkLuaModifier("modifier_la_pucelle_slow", "abilities/jeanne/modifiers/modifier_la_pucelle_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_la_pucelle_cooldown", "abilities/jeanne/modifiers/modifier_la_pucelle_cooldown", LUA_MODIFIER_MOTION_NONE)

function jeanne_la_pucelle:GetCastPoint()
	return 0.5
end

function jeanne_la_pucelle:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN
end

function jeanne_la_pucelle:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function jeanne_la_pucelle:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local kill_radius = self:GetSpecialValueFor("kill_radius")
	local damage_radius = self:GetSpecialValueFor("radius")
	caster:RemoveModifierByName("modifier_jeanne_la_pucelle_window")

	-- prevent la pucelle bug
	if PlayerResource:GetConnectionState(caster:GetPlayerOwnerID()) == 3 then 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Player_" .. caster:GetPlayerOwnerID() .. "_is_disconnected")
		caster:SetMana(caster:GetMana() + self:GetManaCost(1))
		self:EndCooldown()
		return
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", delay + 0.25)


	caster:AddNewModifier(caster, self, "modifier_la_pucelle_cooldown", { Duration = self:GetCooldown(1) })

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	caster.LaPucelleSuccess = false
	ServerTables:SetTableValue("LaPucelle", "active", false)
	--_G.LaPucelleActivated = false

	EmitGlobalSound("jeanne_combo_" .. math.random(1,2))

	StartAnimation(caster, {duration=3, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})

	self.particle = ParticleManager:CreateParticle("particles/custom/ruler/la_pucelle/ruler_la_pucelle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( self.particle, 1, caster:GetAbsOrigin() )

	self.pucelle_ring = ParticleManager:CreateParticle("particles/custom/ruler/la_pucelle/la_pucelle_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(self.pucelle_ring, 0, Vector(radius,0,0))
	ParticleManager:SetParticleControl(self.pucelle_ring, 1, Vector(radius,0,0))

	for i = 1, #enemies do
		if IsValidEntity(enemies[i]) and not enemies[i]:IsNull() then
			enemies[i]:AddNewModifier(caster, self, "modifier_la_pucelle_slow", { Duration = delay + 0.25,
																				  SlowAmt = self:GetSpecialValueFor("slow") })
			giveUnitDataDrivenModifier(caster, enemies[i], "locked", delay + 0.25)
		end
	end

	local masterCombo = caster.MasterUnit2:FindAbilityByName("jeanne_la_pucelle")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(self:GetCooldown(1))

	Timers:CreateTimer(delay, function()  		
		if caster:IsAlive() then
			ServerTables:SetTableValue("LaPucelle", "active", true)
			caster.LaPucelleSuccess = true
	        --_G.LaPucelleActivated = true

			local beam = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControlEnt( beam, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
			ParticleManager:SetParticleControl( beam, 1, caster:GetAbsOrigin() )

			local damage = caster:GetMaxHealth() * self:GetSpecialValueFor("life_damage")
			if caster:HasModifier("modifier_saint_buff") then 
				damage = caster:GetMaxHealth() * self:GetSpecialValueFor("life_damage_saint")
			end
			EmitGlobalSound("jeanne_combo_end")
			
	        --[[local kill_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, kill_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	        for i = 1, #kill_targets do
	        	kill_targets[i]:RemoveModifierByName("modifier_share_damage")
	        	self:PurgeBuffs(kill_targets[i])
	        	giveUnitDataDrivenModifier(caster, kill_targets[i], "can_be_executed", 1)
	        	DoDamage(caster, kill_targets[i], 99999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, self, false)
	        end]]

	        local damage_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	        for k,v in pairs (damage_targets) do
	        	if IsValidEntity(v) and not v:IsNull() then
	        	--damage_targets[i]:RemoveModifierByName("modifier_share_damage")
		        	ApplyStrongDispel(v)
		        	giveUnitDataDrivenModifier(caster, v, "can_be_executed", 1)
		        	DoDamage(caster, v, damage, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, self, false)
		        end
		    end
	        ApplyStrongDispel(caster)
	        --caster:Execute(ability, caster, { bExecution = true })
	        DoDamage(caster, caster, 99999, DAMAGE_TYPE_PURE, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, self, false)  

	        if string.match(GetMapName(), "fate_elim") then 
		        Timers:CreateTimer(0.4, function()
		            local nRadiantAlive = 0
		            local nDireAlive = 0
		            local game = GameRules.AddonTemplate
		            local sData = ServerTables:GetAllTableValues("Score")

		            if ServerTables:GetTableValue("GameState", "state") ~= "FATE_POST_ROUND" then
		                game:LoopOverPlayers(function(player, playerID, playerHero)
		                    if playerHero:IsAlive() then
		                        if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
		                            nRadiantAlive = nRadiantAlive + 1
		                        else
		                            nDireAlive = nDireAlive + 1
		                        end
		                    end
		                end)

		                if nRadiantAlive == nDireAlive then
		    --                    -- Default Radiant Win
		                    if sData.nRadiantScore + 1 < sData.nDireScore                            
		                        then game:FinishRound(true,3)
		          --         -- Default Dire Win
		                    elseif sData.nRadiantScore > sData.nDireScore + 1
		                        then game:FinishRound(true,4)
		            --        -- Draw
		                    else                    
		                        game:FinishRound(true, 2)
		                    end
		                    -- if remaining players are not equal
		                elseif nRadiantAlive > nDireAlive then
		                    game:FinishRound(true, 0)
		                elseif nRadiantAlive < nDireAlive then
		                    game:FinishRound(true, 1)
		                end
		            end
		        end)
		    end      
       	end

        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)

        ParticleManager:DestroyParticle(self.pucelle_ring, true)
        ParticleManager:ReleaseParticleIndex(self.pucelle_ring)

        return
    end)
end

function jeanne_la_pucelle:PurgeBuffs(target)
	local troublesome_buffs = { "modifier_c_rule_breaker",
								"modifier_l_rule_breaker",
								"modifier_heart_of_harmony",
								"modifier_heracles_berserk",
								"modifier_share_damage"}

	for i = 1, #troublesome_buffs do
		target:RemoveModifierByName(troublesome_buffs[i])
	end
end