semiramis_summon_birds = class({})

function semiramis_summon_birds:OnSpellStart()
	local caster = self:GetCaster()
	local targetpoint = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")

	local bird = CreateUnitByName("semiramis_bird", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())	
	bird:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
	bird:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
	bird:SetOwner(caster)
	FindClearSpaceForUnit(bird, bird:GetAbsOrigin(), true)

   	caster:EmitSound("Semi.GardenDove")
   	
	Timers:CreateTimer(0.05, function()
		bird:MoveToPosition(targetpoint)
	end)
end