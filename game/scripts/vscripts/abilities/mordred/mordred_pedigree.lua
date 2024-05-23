LinkLuaModifier("pedigree_off", "abilities/mordred/mordred_pedigree", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("pedigree_buff", "abilities/mordred/mordred_pedigree", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_combo_window", "abilities/mordred/mordred_pedigree", LUA_MODIFIER_MOTION_NONE)

mordred_pedigree = class({})
mordred_pedigree_upgrade = class({})

function mordred_pedigree_wrapper(ability)
	function ability:GetIntrinsicModifierName()
		return "pedigree_buff"
	end

	function ability:OnSpellStart()
		local caster = self:GetCaster()
		EmitSoundOn("mordred_koros", self:GetCaster())
		caster:AddNewModifier(caster, self, "pedigree_off", {Duration = self:GetSpecialValueFor("duration")})

		if caster:HasModifier("mordred_combo_check") then 
			if caster:FindAbilityByName(caster.RSkill):IsCooldownReady() then
				local remain_duration = caster:FindModifierByName("mordred_combo_check"):GetRemainingTime() 
				caster:AddNewModifier(caster, self, "modifier_mordred_combo_window", {Duration = remain_duration})
			end
		end
	end
end

mordred_pedigree_wrapper(mordred_pedigree)
mordred_pedigree_wrapper(mordred_pedigree_upgrade)

pedigree_off = class({})

function pedigree_off:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function pedigree_off:RemoveOnDeath() return false end

function pedigree_off:IsDebuff() return true end

if IsServer() then
	function pedigree_off:OnCreated(args)
		self.parent = self:GetParent() 
		local remove_duration = self:GetAbility():GetSpecialValueFor("duration")

		local ped_buff = self.parent:FindModifierByName("pedigree_buff")
		ped_buff:RemoveArmor(remove_duration)
		
	end

	function pedigree_off:OnRefresh(args)
		self:OnCreated(args)
	end

	function pedigree_off:OnDestroy()
		
	end
end

pedigree_buff = class({})

if IsServer() then
	function pedigree_buff:OnCreated()
		self.Caster = self:GetParent()
		self.MagicResist = self:GetAbility():GetSpecialValueFor("magic_resist")
		self.Armor = self:GetAbility():GetSpecialValueFor("armor")
		self.ArmorActive = true
		self:StartIntervalThink(FrameTime())

		CustomNetTables:SetTableValue("sync","pedigree", { armor = self.Armor,
																	  magic_resist = self.MagicResist })
	end

	function pedigree_buff:OnIntervalThink()

		self.MagicResist = self:GetAbility():GetSpecialValueFor("magic_resist")
		self.Armor = self:GetAbility():GetSpecialValueFor("armor")
		self.ArmorActive = true

		CustomNetTables:SetTableValue("sync","pedigree", { armor = self.Armor,
																	  magic_resist = self.MagicResist })

		self:StartIntervalThink(-1)

		if self.Caster:HasModifier("modifier_padoru") then 

		else

			if not self.Caster:HasModifier('modifier_alternate_01') and not self.Caster:HasModifier('modifier_alternate_02') and not self.Caster:HasModifier('modifier_alternate_03') then 
				self.Caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
				self.Caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim.vmdl")
			end
		end
	end

	function pedigree_buff:RemoveArmor(remove_duration)
		if self.ArmorActive == false then return end

		self.Armor = 0
		self.MagicResist = 0
		self.ArmorActive = false

		CustomNetTables:SetTableValue("sync","pedigree", { armor = self.Armor,
																	  magic_resist = self.MagicResist })

		self:StartIntervalThink(remove_duration)

		if self.Caster:HasModifier("modifier_padoru") then 

		else

			if not self.Caster:HasModifier('modifier_alternate_01') and not self.Caster:HasModifier('modifier_alternate_02') and not self.Caster:HasModifier('modifier_alternate_03') then 
				self.Caster:SetModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim_face.vmdl")
				self.Caster:SetOriginalModel("models/updated_by_seva_and_hudozhestvenniy_film_spizdili/mordred/mordred_unanim_face.vmdl")
			end
		end

	end
end

function pedigree_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			 MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function pedigree_buff:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return self.MagicResist
	elseif IsClient() then
		local magic_resist = CustomNetTables:GetTableValue("sync","pedigree").magic_resist
        return magic_resist 
	end
end

function pedigree_buff:GetModifierPhysicalArmorBonus()
	if IsServer() then
		return self.Armor
	elseif IsClient() then
		local armor = CustomNetTables:GetTableValue("sync","pedigree").armor
        return armor 
	end
end

function pedigree_buff:IsHidden()
	if self:GetParent():HasModifier("pedigree_off") then return true end
	return false
end

modifier_mordred_combo_window = class({})

if IsServer() then
	function modifier_mordred_combo_window:OnCreated()
		self.parent = self:GetParent()
		if self.parent.LightningOverloadAcquired then 
			self.parent:SwapAbilities("mordred_mmb_lightning_upgrade", self.parent.RSkill, true, false)
		else
			self.parent:SwapAbilities("mordred_mmb_lightning", self.parent.RSkill, true, false)
		end
	end

	function modifier_mordred_combo_window:OnDestroy()
		if self.parent.LightningOverloadAcquired then 
			self.parent:SwapAbilities("mordred_mmb_lightning_upgrade", self.parent.RSkill, false, true)
		else
			self.parent:SwapAbilities("mordred_mmb_lightning", self.parent.RSkill, false, true)
		end
	end
end

function modifier_mordred_combo_window:RemoveOnDeath()
	return true 
end