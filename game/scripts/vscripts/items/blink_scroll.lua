item_blink_scroll = class({})

require('libraries/util' )

function item_blink_scroll:OnSpellStart()
	AbilityBlink(self:GetCaster(), self:GetCursorPosition(), self:GetSpecialValueFor("distance"))
end

function item_blink_scroll:IsResettable()
	return true
end

function item_blink_scroll:CastFilterResultLocation( vLocation )
	local caster = self:GetCaster()

	if IsLocked(caster) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS


	--if IsServer() then return AbilityBlinkCastError(self:GetCaster(), vLocation) end
end

function item_blink_scroll:CheckLocks(caster)

    if IsLocked(caster) then
        return true
    end
    return false
end

function item_blink_scroll:GetCustomCastErrorLocation( vLocation )
	return "#Cannot_Blink"
end