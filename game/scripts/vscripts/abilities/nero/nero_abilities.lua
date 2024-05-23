
PassiveModifiers = {
	"modifier_eternal_arms_mastership_think",
	"modifier_eternal_arms_mastership_crit",
	"modifier_golden_rule",
	"modifier_minds_eye_crit",
	"modifier_minds_eye",
	"modifier_martial_arts_critical",
	"modifier_martial_arts_crit_hit",
	"modifier_martial_arts_aura",
}

function OnIPStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	if caster:HasModifier("modifier_laus_saint_ready_checker") then 
		caster:RemoveModifierByName("modifier_laus_saint_ready_checker")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_imperial_privilege", {})
	caster.IPAcquire = false
	ability:EndCooldown()
end

function OnIPClose(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function OnIPRespawn(keys)
	local caster = keys.caster
 	keys.ability:EndCooldown()
end

function OnIPCreate(keys)
	local caster = keys.caster 
	caster.CurrentIPAbility = caster:GetAbilityByIndex(3):GetName()
	if caster.IsPrivilegeImproved then 
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_acquire_eternal_arms_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_acquire_golden_rule_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_acquire_martial_arts_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "nero_acquire_minds_eye_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_close_spellbook", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_acquire_clairvoyance_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_acquire_eternal_arms", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_acquire_golden_rule", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_acquire_martial_arts", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "nero_acquire_minds_eye", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_close_spellbook", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_acquire_clairvoyance", false, true)
	end
end

function OnIPDestroy(keys)
	local caster = keys.caster 
	local ability = keys.ability
	if caster.IsPTBAcquired then 
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_tres_fontaine_ardent_upgrade", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_gladiusanus_blauserum_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_tres_fontaine_ardent", false, true)
		caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_gladiusanus_blauserum", false, true)
	end
	if caster.IsPrivilegeImproved then
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_imperial_privilege_upgrade", false, true)
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_imperial_privilege", false, true)
	end
	if caster.IsSoverignsGloryAcquired then 
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_aestus_domus_aurea_upgrade", false, true)
		if caster.IsAestusEstusAcquired then
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_rosa_ichthys_upgrade_3", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_rosa_ichthys_upgrade_1", false, true)
		end
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_aestus_domus_aurea", false, true)
		if caster.IsAestusEstusAcquired then
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_rosa_ichthys_upgrade_2", false, true)
		else
			caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_rosa_ichthys", false, true)
		end
	end
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), caster.CurrentIPAbility, false, true)
	if caster.IPAcquire == true then
		ability:StartCooldown(ability:GetCooldown(1))
	end
end

function OnEternalArmsAcquired(keys)
	local caster = keys.caster
	caster.IPAcquire = true

	if caster.CurrentIPAbility ~= "fate_empty1" then
		caster:RemoveAbility(caster.CurrentIPAbility)
	end

	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	
	if caster.IsPrivilegeImproved then
		caster.CurrentIPAbility = "lancelot_eternal_arms_mastership_upgrade"
	else
		caster.CurrentIPAbility = "lancelot_eternal_arms_mastership"			
	end

	caster:AddAbility(caster.CurrentIPAbility)
	caster:FindAbilityByName(caster.CurrentIPAbility):SetLevel(1)	
	caster:FindAbilityByName(caster.CurrentIPAbility):SetHidden(true)

	NonResetAbility(caster)

	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function OnGoldenRuleAcquired(keys)
	local caster = keys.caster
	caster.IPAcquire = true

	if caster.CurrentIPAbility ~= "fate_empty1" then
		caster:RemoveAbility(caster.CurrentIPAbility)
	end

	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	
	if caster.IsPrivilegeImproved then
		caster.CurrentIPAbility = "gilgamesh_golden_rule_upgrade"
	else
		caster.CurrentIPAbility = "gilgamesh_golden_rule"			
	end

	caster:AddAbility(caster.CurrentIPAbility)
	caster:FindAbilityByName(caster.CurrentIPAbility):SetLevel(1)	
	caster:FindAbilityByName(caster.CurrentIPAbility):SetHidden(true)

	NonResetAbility(caster)

	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function OnMindEyeAcquired(keys)
	local caster = keys.caster
	caster.IPAcquire = true

	if caster.CurrentIPAbility ~= "fate_empty1" then
		caster:RemoveAbility(caster.CurrentIPAbility)
	end

	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	
	if caster.IsPrivilegeImproved then
		caster.CurrentIPAbility = "sasaki_minds_eye_upgrade"
	else
		caster.CurrentIPAbility = "sasaki_minds_eye"			
	end

	caster:AddAbility(caster.CurrentIPAbility)
	caster:FindAbilityByName(caster.CurrentIPAbility):SetLevel(1)	
	caster:FindAbilityByName(caster.CurrentIPAbility):SetHidden(true)

	NonResetAbility(caster)

	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function OnMartialArtsAcquired(keys)
	local caster = keys.caster
	caster.IPAcquire = true

	if caster.CurrentIPAbility ~= "fate_empty1" then
		caster:RemoveAbility(caster.CurrentIPAbility)
	end

	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	
	if caster.IsPrivilegeImproved then
		caster.CurrentIPAbility = "lishuwen_martial_arts_upgrade"
	else
		caster.CurrentIPAbility = "lishuwen_martial_arts"			
	end

	caster:AddAbility(caster.CurrentIPAbility)
	caster:FindAbilityByName(caster.CurrentIPAbility):SetLevel(1)	
	caster:FindAbilityByName(caster.CurrentIPAbility):SetHidden(true)

	NonResetAbility(caster)

	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function OnClairvoyanceAcquired(keys)
	local caster = keys.caster
	caster.IPAcquire = true

	if caster.CurrentIPAbility ~= "fate_empty1" then
		caster:RemoveAbility(caster.CurrentIPAbility)
	end

	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	
	if caster.IsPrivilegeImproved then
		caster.CurrentIPAbility = "archer_clairvoyance_upgrade"
	else
		caster.CurrentIPAbility = "archer_clairvoyance"			
	end

	caster:AddAbility(caster.CurrentIPAbility)
	caster:FindAbilityByName(caster.CurrentIPAbility):SetLevel(1)	
	caster:FindAbilityByName(caster.CurrentIPAbility):SetHidden(true)

	NonResetAbility(caster)

	caster:RemoveModifierByName("modifier_imperial_privilege")
end

function NeroTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local damageTaken = keys.damageTaken
	local revive_health = ability:GetSpecialValueFor("revive_health") / 100
	local delay = ability:GetSpecialValueFor("delay")

	if caster:GetHealth() == 0 and IsRevivePossible(caster) and caster.IsInvictusSpiritusAcquired and not caster:HasModifier("modifier_invictus_spiritus_cooldown") and not IsRevoked(caster) then
		HardCleanse(caster)
		caster:SetHealth(caster:GetMaxHealth() * revive_health)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_invictus_spiritus",{})
		giveUnitDataDrivenModifier(caster, caster, "revoked", delay)
		caster:EmitSound("Hero_SkeletonKing.Reincarnate")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_invictus_spiritus_cooldown", {duration = ability:GetCooldown(1)})
	end
end

function OnPTBAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPTBAcquired) then

		hero.IsPTBAcquired = true

		hero:AddAbility("nero_tres_fontaine_ardent_upgrade")
		hero:FindAbilityByName("nero_tres_fontaine_ardent_upgrade"):SetLevel(hero:FindAbilityByName("nero_tres_fontaine_ardent"):GetLevel())
		if not hero:FindAbilityByName("nero_tres_fontaine_ardent"):IsCooldownReady() then 
			hero:FindAbilityByName("nero_tres_fontaine_ardent_upgrade"):StartCooldown(hero:FindAbilityByName("nero_tres_fontaine_ardent"):GetCooldownTimeRemaining())
		end

		hero:AddAbility("nero_gladiusanus_blauserum_upgrade")
		hero:FindAbilityByName("nero_gladiusanus_blauserum_upgrade"):SetLevel(hero:FindAbilityByName("nero_gladiusanus_blauserum"):GetLevel())
		if not hero:FindAbilityByName("nero_gladiusanus_blauserum"):IsCooldownReady() then 
			hero:FindAbilityByName("nero_gladiusanus_blauserum_upgrade"):StartCooldown(hero:FindAbilityByName("nero_gladiusanus_blauserum"):GetCooldownTimeRemaining())
		end

		if hero:HasModifier("modifier_imperial_privilege") then 
			hero:FindAbilityByName("nero_gladiusanus_blauserum_upgrade"):SetHidden(true)
			hero:FindAbilityByName("nero_tres_fontaine_ardent_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("nero_tres_fontaine_ardent_upgrade", "nero_tres_fontaine_ardent", true, false) 
			hero:SwapAbilities("nero_gladiusanus_blauserum_upgrade", "nero_gladiusanus_blauserum", true, false) 
		end

		hero:RemoveAbility("nero_tres_fontaine_ardent")
		hero:RemoveAbility("nero_gladiusanus_blauserum")

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnPrivilegeImproved(keys)
    local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsPrivilegeImproved) then

	    hero.IsPrivilegeImproved = true

	    hero:AddAbility("nero_imperial_privilege_upgrade")
	    hero:AddAbility("nero_acquire_eternal_arms_upgrade")
	    hero:AddAbility("nero_acquire_golden_rule_upgrade")
	    hero:AddAbility("nero_acquire_minds_eye_upgrade")
	    hero:AddAbility("nero_acquire_clairvoyance_upgrade")
	    hero:AddAbility("nero_acquire_martial_arts_upgrade")
		hero:FindAbilityByName("nero_imperial_privilege_upgrade"):SetLevel(1)
		hero:FindAbilityByName("nero_acquire_eternal_arms_upgrade"):SetLevel(1)
		hero:FindAbilityByName("nero_acquire_golden_rule_upgrade"):SetLevel(1)
		hero:FindAbilityByName("nero_acquire_minds_eye_upgrade"):SetLevel(1)
		hero:FindAbilityByName("nero_acquire_clairvoyance_upgrade"):SetLevel(1)
		hero:FindAbilityByName("nero_acquire_martial_arts_upgrade"):SetLevel(1)
		if hero:HasModifier("modifier_imperial_privilege") then 
			hero:FindAbilityByName("nero_imperial_privilege_upgrade"):SetHidden(true)
			hero:SwapAbilities("nero_acquire_eternal_arms_upgrade", "nero_acquire_eternal_arms", true, false) 
			hero:SwapAbilities("nero_acquire_golden_rule_upgrade", "nero_acquire_golden_rule", true, false) 
			hero:SwapAbilities("nero_acquire_minds_eye_upgrade", "nero_acquire_minds_eye", true, false) 
			hero:SwapAbilities("nero_acquire_clairvoyance_upgrade", "nero_acquire_clairvoyance", true, false) 
			hero:SwapAbilities("nero_acquire_martial_arts_upgrade", "nero_acquire_martial_arts", true, false) 
		else
			hero:SwapAbilities("nero_imperial_privilege_upgrade", "nero_imperial_privilege", true, false) 
		end

		hero:RemoveAbility("nero_imperial_privilege")
		hero:RemoveAbility("nero_acquire_eternal_arms")
		hero:RemoveAbility("nero_acquire_golden_rule")
		hero:RemoveAbility("nero_acquire_minds_eye")
		hero:RemoveAbility("nero_acquire_clairvoyance")
		hero:RemoveAbility("nero_acquire_martial_arts")

	    NonResetAbility(hero)

	    -- Set master 1's mana 
	    local master = hero.MasterUnit
	    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnISAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsInvictusSpiritusAcquired) then

		hero.IsInvictusSpiritusAcquired = true

		hero:FindAbilityByName("nero_invictus_spiritus"):SetLevel(1)

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnSGAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsSoverignsGloryAcquired) then

		if hero:HasModifier("modifier_laus_saint_ready_checker") then 
			hero:RemoveModifierByName("modifier_laus_saint_ready_checker")
		end

		hero.IsSoverignsGloryAcquired = true

		hero:AddAbility("nero_aestus_domus_aurea_upgrade")
		hero:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):SetLevel(hero:FindAbilityByName("nero_aestus_domus_aurea"):GetLevel())
		if not hero:FindAbilityByName("nero_aestus_domus_aurea"):IsCooldownReady() then 
			hero:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):StartCooldown(hero:FindAbilityByName("nero_aestus_domus_aurea"):GetCooldownTimeRemaining())
		end

		if hero:HasModifier("modifier_imperial_privilege") then 
			hero:FindAbilityByName("nero_aestus_domus_aurea_upgrade"):SetHidden(true)
		else
			hero:SwapAbilities("nero_aestus_domus_aurea_upgrade", "nero_aestus_domus_aurea", true, false) 
		end

		hero:RemoveAbility("nero_aestus_domus_aurea")

		if hero.IsAestusEstusAcquired then 
			hero:AddAbility("nero_rosa_ichthys_upgrade_3")
			hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):SetLevel(hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):GetLevel())
			if not hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):IsCooldownReady() then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):StartCooldown(hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_imperial_privilege") then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):SetHidden(true)
			else
				hero:SwapAbilities("nero_rosa_ichthys_upgrade_3", "nero_rosa_ichthys_upgrade_2", true, false) 
			end

			hero:RemoveAbility("nero_rosa_ichthys_upgrade_2")
		else
			hero:AddAbility("nero_rosa_ichthys_upgrade_1")
			hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):SetLevel(hero:FindAbilityByName("nero_rosa_ichthys"):GetLevel())
			if not hero:FindAbilityByName("nero_rosa_ichthys"):IsCooldownReady() then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):StartCooldown(hero:FindAbilityByName("nero_rosa_ichthys"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_imperial_privilege") then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):SetHidden(true)
			else
				hero:SwapAbilities("nero_rosa_ichthys_upgrade_1", "nero_rosa_ichthys", true, false) 
			end

			hero:RemoveAbility("nero_rosa_ichthys")
		end

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

function OnAestusEstusAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = caster.HeroUnit

	if not MasterCannotUpgrade(hero, caster, keys.ability, hero.IsAestusEstusAcquired) then

		hero.IsAestusEstusAcquired = true

		if hero.IsSoverignsGloryAcquired then 
			hero:AddAbility("nero_rosa_ichthys_upgrade_3")
			hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):SetLevel(hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):GetLevel())
			if not hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):IsCooldownReady() then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):StartCooldown(hero:FindAbilityByName("nero_rosa_ichthys_upgrade_1"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_imperial_privilege") then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_3"):SetHidden(true)
			else
				hero:SwapAbilities("nero_rosa_ichthys_upgrade_3", "nero_rosa_ichthys_upgrade_1", true, false) 
			end

			hero:RemoveAbility("nero_rosa_ichthys_upgrade_1")
		else
			hero:AddAbility("nero_rosa_ichthys_upgrade_2")
			hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):SetLevel(hero:FindAbilityByName("nero_rosa_ichthys"):GetLevel())
			if not hero:FindAbilityByName("nero_rosa_ichthys"):IsCooldownReady() then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):StartCooldown(hero:FindAbilityByName("nero_rosa_ichthys"):GetCooldownTimeRemaining())
			end

			if hero:HasModifier("modifier_imperial_privilege") then 
				hero:FindAbilityByName("nero_rosa_ichthys_upgrade_2"):SetHidden(true)
			else
				hero:SwapAbilities("nero_rosa_ichthys_upgrade_2", "nero_rosa_ichthys", true, false) 
			end

			hero:RemoveAbility("nero_rosa_ichthys")
		end

		hero:FindAbilityByName("nero_aestus_estus_passive"):SetLevel(1)

		NonResetAbility(hero)
		
		-- Set master 1's mana 
		local master = hero.MasterUnit
		master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	end
end

