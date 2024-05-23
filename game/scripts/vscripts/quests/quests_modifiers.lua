
quest_location_thinker = quest_location_thinker or class({})

function quest_location_thinker:OnCreated(event)
	local thinker = self:GetParent()
	--DeepPrintTable(event)
	if IsServer() then
		--print("IsServer == true")
		--print("Location radius is " .. event.radius)
	else
		--print("IsServer == false")
	end
	self.team_number = thinker:GetTeamNumber()
	self.radius = event.radius or 400
end

function quest_location_thinker:IsAura() return true end
function quest_location_thinker:GetAuraRadius() return self.radius end
function quest_location_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function quest_location_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function quest_location_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end
function quest_location_thinker:GetModifierAura() return "quest_location_aura" end

quest_location_aura = quest_location_aura or class({})

function quest_location_aura:IsBuff() return true end
function quest_location_aura:IsHidden() return true end
function quest_location_aura:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function quest_location_aura:OnCreated( event )	
	if not IsServer() then return end
	if self:GetCaster().locationString then
		--todo: Ensure this only triggers for heroes
		local playerID = self:GetParent():GetPlayerOwnerID()
		Event:Trigger('location_visited',{
			playerID = playerID,
			locationName = self:GetCaster().locationString
		})
	end
end


modifier_quest_skin = modifier_quest_skin or class({})

function modifier_quest_skin:GetStatusEffectName()
	--return 'particles/quest/exclamation_yellow_status.vpcf'
	return 'particles/status_fx/status_effect_statue_compendium_2014_dire.vpcf'
end