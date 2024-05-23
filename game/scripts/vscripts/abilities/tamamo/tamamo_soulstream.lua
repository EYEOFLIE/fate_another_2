tamamo_soulstream = class({})
tamamo_soulstream_upgrade = class({})
tamamo_soulstream_fire = class({})
tamamo_soulstream_fire_upgrade_1 = class({})
tamamo_soulstream_fire_upgrade_2 = class({})
tamamo_soulstream_fire_upgrade_3 = class({})
tamamo_soulstream_ice = class({})
tamamo_soulstream_ice_upgrade_1 = class({})
tamamo_soulstream_ice_upgrade_2 = class({})
tamamo_soulstream_ice_upgrade_3 = class({})
tamamo_soulstream_wind = class({})
tamamo_soulstream_wind_upgrade_1 = class({})
tamamo_soulstream_wind_upgrade_2 = class({})
tamamo_soulstream_wind_upgrade_3 = class({})
modifier_soulstream_buff = class({})
modifier_tamamo_fire_debuff = class({})
modifier_tamamo_ice_debuff = class({})
modifier_tamamo_wind_debuff = class({})
modifier_tamamo_wind_particle = class({})

LinkLuaModifier("modifier_soulstream_buff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_fire_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_ice_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_wind_debuff", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tamamo_wind_particle", "abilities/tamamo/tamamo_soulstream", LUA_MODIFIER_MOTION_NONE)

function tamamo_soulstream_wrapper(ability)
	function ability:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("range")
	end

	function ability:GetManaCost(iLevel)
		local hCaster = self:GetCaster()
		local upkeep = self:GetSpecialValueFor("mana_upkeep")
		local fAddCost = 0

		if hCaster:HasModifier("modifier_soulstream_buff") then
			fAddCost = hCaster:GetModifierStackCount("modifier_soulstream_buff", hCaster) * upkeep
		end

		return 100 + fAddCost
	end

	function ability:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function ability:StartCD()
		local hCaster = self:GetCaster()
		local ability = self
		if hCaster.IsSpiritTheftAcquired and hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream_upgrade" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_3" then
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_3" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_3" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif not hCaster.IsSpiritTheftAcquired and hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_2" then
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetLevel())
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_2" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_2" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif hCaster.IsSpiritTheftAcquired and not hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream_upgrade" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_1" then
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_1" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_1" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		elseif not hCaster.IsSpiritTheftAcquired and not hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_fire" then
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_ice" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_wind"):StartCooldown(self:GetCooldown(self:GetLevel()))
			elseif self:GetAbilityName() == "tamamo_soulstream_wind" then
				hCaster:FindAbilityByName("tamamo_soulstream_fire"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream_ice"):StartCooldown(self:GetCooldown(self:GetLevel()))
				hCaster:FindAbilityByName("tamamo_soulstream"):StartCooldown(self:GetCooldown(self:GetLevel()))
			end
		end
	end

	function ability:OnUpgrade()
		local hCaster = self:GetCaster()
		if hCaster.IsSpiritTheftAcquired and hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream_upgrade" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_3" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_3" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_3"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_3" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_3"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
			end
		elseif hCaster.IsSpiritTheftAcquired and not hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream_upgrade" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_1" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_1" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_1"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_1" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_1"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_upgrade"):SetLevel(self:GetLevel())
				end
			end
		elseif not hCaster.IsSpiritTheftAcquired and hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_fire_upgrade_2" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_ice_upgrade_2" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind_upgrade_2"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_wind_upgrade_2" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice_upgrade_2"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
			end
		elseif not hCaster.IsSpiritTheftAcquired and not hCaster.IsWitchcraftAcquired then
			if self:GetAbilityName() == "tamamo_soulstream" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_fire" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_ice" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_wind"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_wind"):SetLevel(self:GetLevel())
				end
			elseif self:GetAbilityName() == "tamamo_soulstream_wind" then
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_fire"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_fire"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream_ice"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream_ice"):SetLevel(self:GetLevel())
				end
				if self:GetLevel() ~= hCaster:FindAbilityByName("tamamo_soulstream"):GetLevel() then
					hCaster:FindAbilityByName("tamamo_soulstream"):SetLevel(self:GetLevel())
				end
			end
		end

		if hCaster.IsWitchcraftAcquired then 
			hCaster:FindAbilityByName("tamamo_fiery_heaven_upgrade"):SetLevel(self:GetLevel())
			hCaster:FindAbilityByName("tamamo_frigid_heaven_upgrade"):SetLevel(self:GetLevel())
			hCaster:FindAbilityByName("tamamo_gust_heaven_upgrade"):SetLevel(self:GetLevel())
		else 
			hCaster:FindAbilityByName("tamamo_fiery_heaven"):SetLevel(self:GetLevel())
			hCaster:FindAbilityByName("tamamo_frigid_heaven"):SetLevel(self:GetLevel())
			hCaster:FindAbilityByName("tamamo_gust_heaven"):SetLevel(self:GetLevel())
		end
	end


	function ability:OnSpellStart()
		local hCaster = self:GetCaster()
		local hTargetLoc = self:GetCursorPosition()
		local total_soul = self:GetSpecialValueFor("total_soul")
		local width = self:GetSpecialValueFor("width")
		local range = self:GetSpecialValueFor("range")
		local speed = 1500
		local hModifier = ""
		self:StartCD()

		hCaster:AddNewModifier(hCaster, self, "modifier_soulstream_buff", { Duration = self:GetSpecialValueFor("buff_dur")})

		local sCharmColor = "particles/custom/tamamo/charms_blue.vpcf" --default
		local tExtraData = { sExplosionColor = "particles/custom/tamamo/charms_blue_explosion.vpcf"} -- default

		
		
	    for i = 1, total_soul do
	    	Timers:CreateTimer(0.1 * i, function()
	    		if hCaster:HasModifier("modifier_fiery_heaven_indicator") then
					sCharmColor = "particles/custom/tamamo/charms_red.vpcf"
					tExtraData["sExplosionColor"] = "particles/custom/tamamo/charms_red_explosion.vpcf"
					tExtraData["sDebuffName"] = "modifier_tamamo_fire_debuff"
					--tExtraData["sCharmAbility"] = "tamamo_fiery_heaven"

					hModifier = hCaster:FindModifierByName("modifier_fiery_heaven_indicator")
					if hModifier:GetStackCount() > 1 then
						hModifier:SetStackCount(hModifier:GetStackCount() - 1)
					else
						hCaster:RemoveModifierByName("modifier_fiery_heaven_indicator")
					end
				elseif hCaster:HasModifier("modifier_frigid_heaven_indicator") then 
					sCharmColor = "particles/custom/tamamo/charms_purple.vpcf"
					tExtraData["sExplosionColor"] = "particles/custom/tamamo/charms_purple_explosion.vpcf"
					tExtraData["sDebuffName"] = "modifier_tamamo_ice_debuff"
					--tExtraData["sCharmAbility"] = "tamamo_frigid_heaven"

					hModifier = hCaster:FindModifierByName("modifier_frigid_heaven_indicator")
					if hModifier:GetStackCount() > 1 then
						hModifier:SetStackCount(hModifier:GetStackCount() - 1)
					else
						hCaster:RemoveModifierByName("modifier_frigid_heaven_indicator")
					end
				elseif hCaster:HasModifier("modifier_gust_heaven_indicator") then
					sCharmColor = "particles/custom/tamamo/charms_green.vpcf"
					tExtraData["sExplosionColor"] = "particles/custom/tamamo/charms_green_explosion.vpcf"
					tExtraData["sDebuffName"] = "modifier_tamamo_wind_debuff"
					--tExtraData["sCharmAbility"] = "tamamo_gust_heaven"

					hModifier = hCaster:FindModifierByName("modifier_gust_heaven_indicator")
					if hModifier:GetStackCount() > 1 then
						hModifier:SetStackCount(hModifier:GetStackCount() - 1)
					else
						hCaster:RemoveModifierByName("modifier_gust_heaven_indicator")
					end
				else
					sCharmColor = "particles/custom/tamamo/charms_blue.vpcf"
					tExtraData["sExplosionColor"] = "particles/custom/tamamo/charms_blue_explosion.vpcf"
					tExtraData["sDebuffName"] = nil
					--tExtraData["sCharmAbility"] = "tamamo_soul_stream"
				end

	    		hCaster:EmitSound("Hero_Wisp.Spirits.Cast")
	    		local vPosition = RandomPointInCircle(hTargetLoc, self:GetAOERadius())
	    		--[[local hDummy = CreateUnitByName("dummy_unit", vPosition, false, hCaster, hCaster, hCaster:GetTeamNumber())
			    hDummy:SetOrigin(vPosition)
			    hDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			    hDummy:AddNewModifier(hCaster, self, "modifier_kill", { Duration = 1.5 })]]

	    		local soul_vector = (vPosition - hCaster:GetAbsOrigin()):Normalized()
	    		local distance = (vPosition - hCaster:GetAbsOrigin()):Length2D()

	    		local ProjectileFx = ParticleManager:CreateParticle(sCharmColor, PATTACH_WORLDORIGIN, hCaster)
	    		ParticleManager:SetParticleControl(ProjectileFx, 0, hCaster:GetAbsOrigin() + Vector(0,0,80))
				ParticleManager:SetParticleControl(ProjectileFx, 1, vPosition + Vector(0,0,80))
				ParticleManager:SetParticleControl(ProjectileFx, 2, Vector(speed,0,0))	
				tExtraData["ProjectileFx"] = ProjectileFx
				--tExtraData["hDummy"] = hDummy

			    local projectileTable = {
					Ability = self,
					--EffectName = sCharmColor,
					iMoveSpeed = speed,
					vSpawnOrigin = hCaster:GetAbsOrigin(),
					fDistance = distance,
					Source = hCaster,
					fStartRadius = width,
			        fEndRadius = width,
					bHasFrontialCone = true,
					bReplaceExisting = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_ALL,
					fExpireTime = GameRules:GetGameTime() + 3,
					bDeleteOnHit = true,
					vVelocity = soul_vector * speed,
					ExtraData = tExtraData
				}

			    ProjectileManager:CreateLinearProjectile(projectileTable)

			    Timers:CreateTimer((vPosition - hCaster:GetAbsOrigin()):Length2D() / speed, function()
			    	if ProjectileFx ~= nil then 
			    		ParticleManager:DestroyParticle(ProjectileFx, true)
						ParticleManager:ReleaseParticleIndex(ProjectileFx)
					end
			    end)
	    	end)
	    end
	end

	function ability:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
		if hTarget == nil then return end
		local hCaster = self:GetCaster()
		local fExplodeRadius = self:GetSpecialValueFor("explode_radius")
		local fDamage = self:GetSpecialValueFor("damage")

		local sExplosionColor = tData["sExplosionColor"] 
		
		local hCharmDebuff = tData["sDebuffName"]

		ParticleManager:DestroyParticle(tData["ProjectileFx"], true)
		ParticleManager:ReleaseParticleIndex(tData["ProjectileFx"])

		if hCaster.IsSpiritTheftAcquired then
			local base_mana_drain = self:GetSpecialValueFor("base_mana_drain")
			local bonus_int_ratio = self:GetSpecialValueFor("bonus_int_ratio")
			local fManaBurn = base_mana_drain + hCaster:GetIntellect() * bonus_int_ratio
			fDamage = fDamage + (hCaster:GetIntellect() * bonus_int_ratio)
			if not IsManaLess(hTarget) then
				hCaster:GiveMana(fManaBurn)
				hTarget:SetMana(hTarget:GetMana() - fManaBurn)		
			end	
		end

		if hCaster.IsWitchcraftAcquired then 
			if not hTarget:IsMagicImmune() then
				local witchcraft = hCaster:FindAbilityByName("tamamo_witchcraft")
				witchcraft:ApplyDataDrivenModifier(hCaster, hTarget, "modifier_witchcraft_mr_reduction", {})
				local current_stack = hTarget:GetModifierStackCount("modifier_witchcraft_mr_reduction", hCaster) or 0
				local mr = hTarget:GetBaseMagicalResistanceValue()
				current_stack = current_stack + 1 
				hTarget:SetModifierStackCount("modifier_witchcraft_mr_reduction", hCaster, current_stack)
			end
		end

		hTarget:EmitSound("Hero_Wisp.Spirits.Target")
		local explosionFx = ParticleManager:CreateParticle(sExplosionColor, PATTACH_WORLDORIGIN, hTarget)
		ParticleManager:SetParticleControl(explosionFx, 0, vLocation)
		ParticleManager:SetParticleControl(explosionFx, 1, vLocation)
		ParticleManager:SetParticleControl(explosionFx, 3, vLocation)

		local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fExplodeRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for i = 1, #tEnemies do
			if IsValidEntity(tEnemies[i]) and not tEnemies[i]:IsNull() then
				if hCharmDebuff ~= nil then
					if IsWindProtect(tEnemies[i]) and hCharmDebuff == "modifier_tamamo_wind_debuff" then

					else
						tEnemies[i]:AddNewModifier(hCaster, self, hCharmDebuff, { Duration = self:GetSpecialValueFor("debuff_duration") })
					end
				end

				DoDamage(hCaster, tEnemies[i], fDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
			end
		end
	end
end

tamamo_soulstream_wrapper(tamamo_soulstream)
tamamo_soulstream_wrapper(tamamo_soulstream_upgrade)
tamamo_soulstream_wrapper(tamamo_soulstream_fire)
tamamo_soulstream_wrapper(tamamo_soulstream_fire_upgrade_1)
tamamo_soulstream_wrapper(tamamo_soulstream_fire_upgrade_2)
tamamo_soulstream_wrapper(tamamo_soulstream_fire_upgrade_3)
tamamo_soulstream_wrapper(tamamo_soulstream_ice)
tamamo_soulstream_wrapper(tamamo_soulstream_ice_upgrade_1)
tamamo_soulstream_wrapper(tamamo_soulstream_ice_upgrade_2)
tamamo_soulstream_wrapper(tamamo_soulstream_ice_upgrade_3)
tamamo_soulstream_wrapper(tamamo_soulstream_wind)
tamamo_soulstream_wrapper(tamamo_soulstream_wind_upgrade_1)
tamamo_soulstream_wrapper(tamamo_soulstream_wind_upgrade_2)
tamamo_soulstream_wrapper(tamamo_soulstream_wind_upgrade_3)

-- Stacking buff 
function modifier_soulstream_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

if IsServer() then
	function modifier_soulstream_buff:OnCreated(args)
		self:SetStackCount(1)
	end

	function modifier_soulstream_buff:OnRefresh(args)
		self:SetStackCount(math.min((self:GetStackCount() or 0) + 1, self:GetAbility():GetSpecialValueFor("max_stack")))
	end
end

function modifier_soulstream_buff:GetModifierMoveSpeedBonus_Percentage()
	return (self:GetStackCount() or 1) * self:GetAbility():GetSpecialValueFor("ms_per_stack")
end

-- Fire Charm Debuff
if IsServer() then
	function modifier_tamamo_fire_debuff:OnCreated(args)
		self:SetStackCount(1)
		self.fire_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.fire_particle, 0, self:GetParent():GetAbsOrigin()) 
		self:StartIntervalThink(0.25)
	end

	function modifier_tamamo_fire_debuff:OnRefresh(args)
		if self:GetCaster().IsWitchcraftAcquired then 
			self:SetStackCount((self:GetStackCount() or 0) + 1)
			
		end
	end

	function modifier_tamamo_fire_debuff:OnIntervalThink()
		local hCaster = self:GetCaster()
		local hTarget = self:GetParent()
		local fDamage = self:GetAbility():GetSpecialValueFor("fire_dps") * 0.25 
		if hCaster.IsWitchcraftAcquired then 
			fDamage = fDamage * self:GetStackCount() 
			if self:GetStackCount() > self:GetAbility():GetSpecialValueFor("spirit_consume") then 
				local stun = self:GetAbility():GetSpecialValueFor("fire_stun")
				local fire_stun_damage = self:GetAbility():GetSpecialValueFor("fire_stun_damage")
				local hTarget = self:GetParent()
				if not IsImmuneToCC(hTarget) then
					hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_stunned", {Duration = stun})
				end

				self:SetStackCount(self:GetStackCount() - self:GetAbility():GetSpecialValueFor("spirit_consume"))

				local explodeFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
				ParticleManager:SetParticleControl( explodeFx, 0, hTarget:GetAbsOrigin())
				hTarget:EmitSound("Ability.LightStrikeArray")

				DoDamage(hCaster, hTarget, fire_stun_damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)

				Timers:CreateTimer(1.5, function()
					ParticleManager:DestroyParticle(explodeFx, false)
					ParticleManager:ReleaseParticleIndex(explodeFx)
			    	return nil
			    end)
			end
		end
		DoDamage(hCaster, hTarget, fDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
	end
	function modifier_tamamo_fire_debuff:OnDestroy()
		if self.fire_particle ~= nil then
			ParticleManager:DestroyParticle( self.fire_particle, true )
			ParticleManager:ReleaseParticleIndex( self.fire_particle )
		end
	end
end

function modifier_tamamo_fire_debuff:IsDebuff()
	return true
end

function modifier_tamamo_fire_debuff:GetTexture()
	return "custom/tamamo_fiery_heaven"
end 

function modifier_tamamo_fire_debuff:GetAttributes()
	local attribute = MODIFIER_ATTRIBUTE_NONE 
	return attribute
end

--Ice Charm Debuff
if IsServer() then
	function modifier_tamamo_ice_debuff:OnCreated(args)
		self:SetStackCount(1)
		self.ParticleIndex = ParticleManager:CreateParticle("particles/custom/tamamo/frigid_heaven.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.ParticleIndex, 0, self:GetParent():GetAbsOrigin())
		self:StartIntervalThink(0.5)
	end

	function modifier_tamamo_ice_debuff:OnRefresh(arg)
		local hCaster = self:GetCaster()
		if hCaster.IsWitchcraftAcquired then
			self:SetStackCount((self:GetStackCount() or 0) + 1)
			
		end
	end

	function modifier_tamamo_ice_debuff:OnIntervalThink()
		local hCaster = self:GetCaster()
		local hTarget = self:GetParent()
		if hCaster.IsWitchcraftAcquired then 
			if self:GetStackCount() > self:GetAbility():GetSpecialValueFor("spirit_consume") then 
				local ice_freeze = self:GetAbility():GetSpecialValueFor("ice_freeze")
				local hTarget = self:GetParent()
				if not IsImmuneToCC(hTarget) then
					giveUnitDataDrivenModifier(hCaster, hTarget, "freezed", ice_freeze)
				end
				hTarget:EmitSound("Hero_Invoker.ColdSnap.Freeze")
				self:SetStackCount(self:GetStackCount() - self:GetAbility():GetSpecialValueFor("spirit_consume"))
			end
		end
	end

	function modifier_tamamo_ice_debuff:OnDestroy()
		if self.ParticleIndex ~= nil then
			ParticleManager:DestroyParticle(self.ParticleIndex, true)
			ParticleManager:ReleaseParticleIndex(self.ParticleIndex)
		end
	end
end

function modifier_tamamo_ice_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_tamamo_ice_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_perc")
end

function modifier_tamamo_ice_debuff:IsDebuff()
	return true
end

function modifier_tamamo_ice_debuff:GetTexture()
	return "custom/tamamo_frigid_heaven"
end

--Wind Charm Debuff
if IsServer() then
	function modifier_tamamo_wind_debuff:OnCreated(args)
		self:SetStackCount(1)
		self.ParticleIndex = ParticleManager:CreateParticle("particles/custom/tamamo/gust_heaven_static.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.ParticleIndex, 0, self:GetParent():GetAbsOrigin())
		local wind_interval = self:GetAbility():GetSpecialValueFor("wind_interval")
		self:StartIntervalThink(wind_interval)
	end

	function modifier_tamamo_wind_debuff:OnRefresh(args)
		local hCaster = self:GetCaster()
		if hCaster.IsWitchcraftAcquired then
			self:SetStackCount((self:GetStackCount() or 0) + 1)
		end
	end

	function modifier_tamamo_wind_debuff:OnDestroy()	
		if self.ParticleIndex ~= nil then	
			ParticleManager:DestroyParticle(self.ParticleIndex, false)
			ParticleManager:ReleaseParticleIndex(self.ParticleIndex)
		end
	end

	function modifier_tamamo_wind_debuff:OnIntervalThink()
		local hCaster = self:GetCaster()
		local hTarget = self:GetParent()
		local fZapAoe = self:GetAbility():GetSpecialValueFor("wind_radius")
		local fSilence = self:GetAbility():GetSpecialValueFor("wind_silence")
		local wind_interval = self:GetAbility():GetSpecialValueFor("wind_interval")
		local fDamage = self:GetAbility():GetSpecialValueFor("wind_dps") * wind_interval
		local target_loc = hTarget:GetAbsOrigin()

		giveUnitDataDrivenModifier(hCaster, hTarget, "silenced", fSilence)

		if hCaster.IsWitchcraftAcquired then 
			if self:GetStackCount() > self:GetAbility():GetSpecialValueFor("spirit_consume") then 
				local fDisarm = self:GetAbility():GetSpecialValueFor("wind_disarm")
				local hTarget = self:GetParent()
				giveUnitDataDrivenModifier(hCaster, hTarget, "disarmed", fDisarm)
				self:SetStackCount(self:GetStackCount() - self:GetAbility():GetSpecialValueFor("spirit_consume"))
			end
		end

		DoDamage(hCaster, hTarget, fDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)


		local tEnemies = FindUnitsInRadius(hCaster:GetTeam(), target_loc, nil, fZapAoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for i = 1, #tEnemies do	
			if IsValidEntity(tEnemies[i]) and not tEnemies[i]:IsNull() and tEnemies[i] ~= hTarget then
				if IsWindProtect(tEnemies[i]) then return end

				--local iParticleIndex = ParticleManager:CreateParticle("particles/custom/tamamo/gust_heaven_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				--ParticleManager:SetParticleControl(iParticleIndex, 0, hTarget:GetAbsOrigin())
				--ParticleManager:SetParticleControl(iParticleIndex, 1, tEnemies[i]:GetAbsOrigin())

				giveUnitDataDrivenModifier(hCaster, tEnemies[i], "silenced", fSilence)
				--tEnemies[i]:AddNewModifier(hTarget, self:GetAbility(), "modifier_tamamo_wind_particle", { Duration = fSilence, ParticleIndex = iParticleIndex })
				
				DoDamage(hCaster, tEnemies[i], fDamage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
				return
			end
		end	
	end
end

function modifier_tamamo_wind_debuff:IsDebuff()
	return true
end

function modifier_tamamo_wind_debuff:GetTexture()
	return "custom/tamamo_gust_heaven"
end

if IsServer() then
	function modifier_tamamo_wind_particle:OnCreated(args)
		self.ParticleIndex = args.ParticleIndex
	end

	function modifier_tamamo_wind_particle:OnDestroy()
		if self.ParticleIndex ~= nil then
			ParticleManager:DestroyParticle(self.ParticleIndex, true)
			ParticleManager:ReleaseParticleIndex(self.ParticleIndex)
		end
	end
end

function modifier_tamamo_wind_particle:IsHidden()
	return true
end