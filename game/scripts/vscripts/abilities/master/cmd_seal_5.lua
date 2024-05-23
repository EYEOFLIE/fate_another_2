cmd_seal_5 = class({})

LinkLuaModifier("modifier_master_intervention", "abilities/master/modifiers/modifier_master_intervention", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_command_seal_5", "abilities/master/modifiers/modifier_command_seal_5", LUA_MODIFIER_MOTION_NONE)


function cmd_seal_5:GetCooldown(iLevel)
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_command_seal_1") then
		return 0
	else
		return 30
	end
end

function cmd_seal_5:OnSpellStart()
	local caster = self:GetCaster()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if not hero then hero = caster.HeroUnit end


	if caster:GetHealth() == 1 then
		self:EndCooldown() 
		caster:SetMana(caster:GetMana() + self:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Master_Not_Enough_Health")
		return 
	elseif not hero:IsAlive() or IsRevoked(hero) then
		self:EndCooldown()
		caster:SetMana(caster:GetMana() + self:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
		return
	end

	if not hero:IsAlive() then return end

	local master2 = hero.MasterUnit2
	master2:SetMana(caster:GetMana())
	-- pay health cost
	caster:SetHealth(caster:GetHealth() - 1) 

	hero:EmitSound("Hero_Abaddon.AphoticShield.Cast")
	HardCleanse(hero)
	hero:RemoveModifierByName("modifier_zabaniya_curse")
	hero:AddNewModifier(caster, self, "modifier_master_intervention", { Duration = self:GetSpecialValueFor("duration") })
	local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, hero )
    ParticleManager:SetParticleControl( dispel, 1, hero:GetAbsOrigin())

    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( dispel, false )
        ParticleManager:ReleaseParticleIndex( dispel )
    end)

    if hero:GetName() == "npc_dota_hero_doom_bringer" and RandomInt(1, 100) <= 35 then
		EmitGlobalSound("Shiro_Onegai")
	end

	-- Set cooldown
	if not caster:HasModifier("modifier_command_seal_1") then
		--caster:FindAbilityByName("cmd_seal_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
		--caster:FindAbilityByName("cmd_seal_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
		--caster:FindAbilityByName("cmd_seal_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
		--caster:FindAbilityByName("cmd_seal_4"):StartCooldown(self:GetCooldown(self:GetLevel()))
		hero:AddNewModifier(caster, self, "modifier_command_seal_5", { Duration = self:GetCooldown(1) })
	end
end