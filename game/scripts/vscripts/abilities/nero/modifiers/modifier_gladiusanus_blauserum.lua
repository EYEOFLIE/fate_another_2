modifier_gladiusanus_blauserum = class({})

LinkLuaModifier("modifier_gladiusanus_blauserum_mark", "abilities/nero/modifiers/modifier_gladiusanus_blauserum", LUA_MODIFIER_MOTION_NONE)

function modifier_gladiusanus_blauserum:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_gladiusanus_blauserum:OnCreated(args)
	if IsServer() then
		self.StunDuration = args.StunDuration
		self.Damage = args.Damage
		self.BonusDamage = args.BonusDamage
		self.MarkDuration = args.MarkDuration
		self.TotalHit = args.TotalHit
		self.AOE = self:GetAbility():GetSpecialValueFor("aoe")
		self:SetStackCount(self.TotalHit)

		if not self.flame_sword then
			self.flame_sword = ParticleManager:CreateParticle("particles/custom/nero/nero_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.flame_sword, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(),false)
			ParticleManager:SetParticleControlEnt(self.flame_sword, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(),false)
		end
	end
end

function modifier_gladiusanus_blauserum:OnDestroy()
	if IsServer() then
		if self:GetParent().IsPTBAcquired then 
			self:GetParent():RemoveModifierByName("modifier_pari_tenu_blauserum")
		end
		ParticleManager:DestroyParticle(self.flame_sword, true)
		ParticleManager:ReleaseParticleIndex(self.flame_sword)
	end
end

function modifier_gladiusanus_blauserum:OnRefresh(args)
	if IsServer() then
		self:OnCreated(args)		
	end
end

function modifier_gladiusanus_blauserum:OnAttackLanded(args)
	if IsServer() then
		if args.attacker ~= self:GetParent() or not args.target:IsHero() then return end

		local caster = self:GetCaster()
		local target = args.target
		local ability = self:GetAbility()

		self:SetStackCount(self:GetStackCount() - 1)

		if caster.IsPTBAcquired then
			local aspd = caster:FindModifierByName("modifier_pari_tenu_blauserum")
			aspd:IncrementStackCount()		
		end		

		local aoeTargets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, self.AOE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		caster:EmitSound("Hero_Clinkz.DeathPact")

	    for k, v in pairs(aoeTargets) do
	    	if IsValidEntity(v) and not v:IsNull() then	
	    		local mark_stack = v:GetModifierStackCount("modifier_gladiusanus_blauserum_mark", caster) or 0     
	    		v:AddNewModifier(caster, ability, "modifier_gladiusanus_blauserum_mark", {Duration = self.MarkDuration})	
	    		DoDamage(caster, v, self.Damage + (self.BonusDamage * mark_stack), DAMAGE_TYPE_MAGICAL, 0, ability, false)	    		
	    	end
	    	
	    	if IsValidEntity(v) and not v:IsNull() and v:IsAlive() then
		    	if v:GetModifierStackCount("modifier_gladiusanus_blauserum_mark", caster) >= self.TotalHit then 
		    		if not v:IsMagicImmune() and not IsImmuneToCC(v) then
			        	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = self.StunDuration})
			        end
			        v:RemoveModifierByName("modifier_gladiusanus_blauserum_mark")
			        local flameFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControl(flameFx, 2, v:GetAbsOrigin())

					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, v)
					ParticleManager:SetParticleControl(particle, 0, v:GetAbsOrigin()) 
					ParticleManager:SetParticleControl(particle, 1, Vector(350, 350, 350)) 
					ParticleManager:SetParticleControl(particle, 3, Vector(350, 350, 350)) 

					Timers:CreateTimer( 2.0, function()
						ParticleManager:DestroyParticle( flameFx, false )
						ParticleManager:ReleaseParticleIndex( flameFx )
						ParticleManager:DestroyParticle( particle, false )
						ParticleManager:ReleaseParticleIndex( particle )
					end)
			    end
			end
	    end 

	    if self:GetStackCount() < 1 then 
	    	self:Destroy()
	    end
	end
end

function modifier_gladiusanus_blauserum:IsHidden()
	return false
end

function modifier_gladiusanus_blauserum:IsDebuff()
	return false
end

function modifier_gladiusanus_blauserum:RemoveOnDeath()
	return true
end

function modifier_gladiusanus_blauserum:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_gladiusanus_blauserum:GetTexture()
	return "custom/nero_gladiusanus_blauserum"
end

modifier_gladiusanus_blauserum_mark = class({})

function modifier_gladiusanus_blauserum_mark:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_gladiusanus_blauserum_mark:OnRefresh(args)
	if IsServer() then
		self:IncrementStackCount()		
	end
end

function modifier_gladiusanus_blauserum_mark:IsHidden()
	return false
end

function modifier_gladiusanus_blauserum_mark:IsDebuff()
	return true
end

function modifier_gladiusanus_blauserum_mark:RemoveOnDeath()
	return true
end

function modifier_gladiusanus_blauserum_mark:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_gladiusanus_blauserum_mark:GetTexture()
	return "custom/nero_gladiusanus_blauserum"
end

modifier_pari_tenu_blauserum = class({})

function modifier_pari_tenu_blauserum:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_pari_tenu_blauserum:OnCreated(args)
	if IsServer() then
		self.AttackSpeed = args.AttackSpeed
		self:SetStackCount(1)

		CustomNetTables:SetTableValue("sync","gladiusanus_stats", {attack_speed = self.AttackSpeed})
	end
end

function modifier_pari_tenu_blauserum:OnDestroy()
	if IsServer() then
		CustomNetTables:SetTableValue("sync","gladiusanus_stats", {attack_speed = 0})
	end
end

function modifier_pari_tenu_blauserum:OnRefresh(args)
	if IsServer() then
		self:OnCreated(args)		
	end
end

function modifier_pari_tenu_blauserum:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.AttackSpeed * self:GetStackCount()
    elseif IsClient() then
        local attack_speed = CustomNetTables:GetTableValue("sync","gladiusanus_stats").attack_speed * self:GetStackCount()
        return attack_speed 
    end
end

function modifier_pari_tenu_blauserum:IsHidden()
	return true
end

function modifier_pari_tenu_blauserum:IsDebuff()
	return false
end

function modifier_pari_tenu_blauserum:RemoveOnDeath()
	return true
end

function modifier_pari_tenu_blauserum:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_pari_tenu_blauserum:GetTexture()
	return "custom/nero_gladiusanus_blauserum"
end