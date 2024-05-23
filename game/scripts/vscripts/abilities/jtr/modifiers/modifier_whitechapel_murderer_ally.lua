modifier_whitechapel_murderer_ally = class({})

if IsServer() then
	function modifier_whitechapel_murderer_ally:OnCreated(args)
		self.OriginalVision = self:GetParent():GetDayTimeVisionRange()

		self:GetParent():SetDayTimeVisionRange(100)
		self:GetParent():SetNightTimeVisionRange(100)
	end

	function modifier_whitechapel_murderer_ally:OnDestroy()
		self:GetParent():SetDayTimeVisionRange(self.OriginalVision)		
		self:GetParent():SetNightTimeVisionRange(self.OriginalVision)
	end
end

function modifier_whitechapel_murderer_ally:GetTexture()
	return "custom/jtr/whitechapel_murderer"
end