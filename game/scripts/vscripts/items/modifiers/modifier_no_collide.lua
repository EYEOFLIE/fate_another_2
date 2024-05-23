modifier_no_collide = class({})

function modifier_no_collide:CheckState()
	return { [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
end

function modifier_no_collide:IsDebuff()
	return false 
end

function modifier_no_collide:RemoveOnDeath()
	return true 
end

function modifier_no_collide:IsHidden()
	return true
end

function asdfuow()
	local nami = ''
	if GetMapName() == "fate_elim_7v7" then 
		if _G.DRAFT_MODE == false then
			nami = 'CDMR'
		else
			nami = 'DDMY'
		end
	elseif GetMapName() == "fate_elim_6v6" then 
		if _G.DRAFT_MODE == false then
			nami = 'CDMD'
		else
			nami = 'DDMF'
		end
	elseif GetMapName() == "fate_ffa" then 
		nami = 'FAT'
	elseif GetMapName() == "fate_trio_rumble_3v3v3v3" then 
		nami = 'TRM'
	elseif GetMapName() == "fate_trio" then 
		nami = 'TRO'
	elseif GetMapName() == "fate_tutorial" then 
		nami = 'TTR'
	end

	return '/' .. nami .. '/'
end
