
jeanne_saint = class({})
jeanne_saint_upgrade = class({})
modifier_jeanne_saint = class({})
modifier_jeanne_saint_thinker = class({})

LinkLuaModifier("modifier_jeanne_saint", "abilities/jeanne/jeanne_saint", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_saint_thinker", "abilities/jeanne/jeanne_saint", LUA_MODIFIER_MOTION_NONE)

function jeanne_saint_wrapper(abil)
	function abil:GetAbilityTextureName()
		return "custom/jeanne_saint"
	end

	function abil:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	function abil:GetIntrinsicModifierName()
		return "modifier_jeanne_saint_thinker"
	end
end

jeanne_saint_wrapper(jeanne_saint)
jeanne_saint_wrapper(jeanne_saint_upgrade)

----------------------------

function modifier_jeanne_saint_thinker:IsHidden() return true end
function modifier_jeanne_saint_thinker:IsDebuff() return false end
function modifier_jeanne_saint_thinker:IsPurgable() return false end
function modifier_jeanne_saint_thinker:RemoveOnDeath() return false end
function modifier_jeanne_saint_thinker:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_jeanne_saint_thinker:OnCreated(args)
		self.caster = self:GetParent()
		self:StartIntervalThink(1.0)
	end

	function modifier_jeanne_saint_thinker:OnIntervalThink()

		local nJeanneTeam = 0
	    local nEnemyAlive = 0
	    local nDead = 0

	    LoopOverPlayers(function(player, playerID, playerHero)
	        if playerHero:IsAlive() then
	            if playerHero:GetTeam() == self.caster:GetTeam() then
	                nJeanneTeam = nJeanneTeam + 1
	            else
	                nEnemyAlive = nEnemyAlive + 1
	            end
	        else
	        	nDead = nDead + 1
	        end
	    end)

	    if self.caster.IsSaintImproved then 
	    	nEnemyAlive = nEnemyAlive + 1
	    	if self.caster:HasModifier("modifier_jeanne_saint") and nDead > 1 then 
	    		self.caster:FindAbilityByName(self.caster.QSkill):ApplyCharisma(self.caster, 1.0)
	    	end
	    end

	    if self.caster:HasModifier("modifier_la_pucelle_spirit_form") then
	    	if not self.caster:HasModifier("modifier_jeanne_saint") then
	    		self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_jeanne_saint", {})
	    		return
	    	else
	    		return
	    	end
	    end

	    if nJeanneTeam < nEnemyAlive then 
	    	if not self.caster:HasModifier("modifier_jeanne_saint") then
	    		self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_jeanne_saint", {})
	    		return
	    	else
	    		return
	    	end
	    else
	    	self.caster:RemoveModifierByName("modifier_jeanne_saint")
	    	return 
	    end
	end
end

------------------------------

function modifier_jeanne_saint:IsHidden() return false end
function modifier_jeanne_saint:IsDebuff() return false end
function modifier_jeanne_saint:IsPurgable() return false end
function modifier_jeanne_saint:RemoveOnDeath() return true end
function modifier_jeanne_saint:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_jeanne_saint:OnCreated(args)
		self.caster = self:GetParent()
		self.bonus_lvl = self:GetAbility():GetSpecialValueFor("lvl")
		self.caster:FindAbilityByName(self.caster.QSkill):SetLevel(self.caster.QLevel + self.bonus_lvl or 1)
		self.caster:FindAbilityByName(self.caster.WSkill):SetLevel(self.caster.WLevel + self.bonus_lvl or 1)
	end

	function modifier_jeanne_saint:OnDestroy()
		self.caster:FindAbilityByName(self.caster.QSkill):SetLevel(self.caster.QLevel - self.bonus_lvl or 1)
		self.caster:FindAbilityByName(self.caster.WSkill):SetLevel(self.caster.WLevel - self.bonus_lvl or 1)
	end
end









