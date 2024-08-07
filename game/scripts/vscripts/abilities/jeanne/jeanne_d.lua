
jeanne_identity_discernment = class({})

LinkLuaModifier("modifier_jeanne_vision", "abilities/jeanne/modifiers/modifier_jeanne_vision", LUA_MODIFIER_MOTION_NONE)

function jeanne_identity_discernment:OnSpellStart()
	self.caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("saint_vision_duration")

	local delay = 0

	if self.caster.ServStat.radiantWin <= self.caster.ServStat.direWin and self.caster:GetTeam() == DOTA_TEAM_GOODGUYS or self.caster.ServStat.radiantWin >= self.caster.ServStat.direWin and self.caster:GetTeam() == DOTA_TEAM_BADGUYS then
		duration = self:GetSpecialValueFor("saint_vision_duration_lose")        	
	end


	GameRules:SendCustomMessage("#identity_discernment_alert", 0, 0)
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= self.caster:GetTeamNumber() and playerHero:IsAlive() then
        	--print("looping through " .. playerHero:GetName())
        	delay = delay + 0.15
        	Timers:CreateTimer(delay, function()
        		MinimapEvent( self.caster:GetTeamNumber(), self.caster, playerHero:GetAbsOrigin().x, playerHero:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2)
        	end)
        	-- Score is updated at end of round in addon_game_mode.lua. Since I'm already tracking score over there, I may as well use it...
        	
        	playerHero:AddNewModifier(self.caster, self, "modifier_jeanne_vision", { Duration = duration })
        end
    end)
end