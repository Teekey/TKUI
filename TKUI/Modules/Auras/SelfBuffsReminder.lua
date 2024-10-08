local T, C, L = unpack(TKUI)
if C.reminder.solo_buffs_enable ~= true then return end

----------------------------------------------------------------------------------------
--	Self buffs on player(by Tukz and Elv22)
----------------------------------------------------------------------------------------
local tab = T.ReminderSelfBuffs[T.class]
if not tab then return end
local playerBuff = {}

local function OnEvent(self, event, arg1)
	local group = tab[self.id]
	if not group.spells then return end
	if not GetSpecialization() then return end
	if (event == "UNIT_AURA" or event == "UNIT_INVENTORY_CHANGED") and arg1 ~= "player" then return end
	if group.level and T.level < group.level then return end

	self:Hide()

	for i = 1, #group.spells do
		local spellID, icon = unpack(group.spells[i])
		if type(spellID) == "number" then
			local usable, nomana = C_Spell.IsSpellUsable(spellID)
			if usable or nomana or group.level then
				self.icon:SetTexture(icon)
				break
			else
				self.icon:SetTexture(nil)
			end
		else
			print("TKUI: Invalid spell ID for SelfBuffsReminder entry", spellID)
		end
	end

	if event == "PLAYER_LOGIN" then
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		if not self.icon:GetTexture() then
			self:UnregisterAllEvents()
			self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		end
		return
	end

	if group.always then
		self:RegisterEvent("UNIT_AURA")
	end

	if event == "LEARNED_SPELL_IN_TAB" and self.icon:GetTexture() then
		self:UnregisterAllEvents()
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_ENTERED_VEHICLE")
		self:RegisterEvent("UNIT_EXITED_VEHICLE")

		if group.combat then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end

		if group.instance or group.pvp then
			self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		end
	end

	if group.mainhand or group.offhand then
		self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	end

	local role = group.role
	local spec = group.spec
	local reversecheck = group.reversecheck
	local canplaysound = false
	local rolepass = true
	local specpass = true
	local _, instanceType, difficultyID = GetInstanceInfo()

	if role and role ~= T.Role then
		rolepass = false
	end

	if spec and spec ~= T.Spec then
		specpass = false
	end

	-- Prevent user error
	if reversecheck ~= nil and (role == nil and spec == nil) then reversecheck = nil end

	-- Check event to play sound
	if (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_DISABLED") and C.reminder.solo_buffs_sound == true then canplaysound = true end

	if ((group.always) or (group.combat and UnitAffectingCombat("player")) and (group.instance and difficultyID ~= 0 and not C_Garrison.IsOnGarrisonMap()) or (group.pvp and (instanceType == "arena" or instanceType == "pvp"))) and
		specpass == true and rolepass == true and not UnitInVehicle("player") then
		if group.mainhand then
			local hasMainHandEnchant = GetWeaponEnchantInfo()
			if not hasMainHandEnchant then
				self:Show()
				if canplaysound == true then PlaySoundFile(C.media.warning_sound, "Master") end
			end
			return
		elseif group.offhand then
			local _, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
			if not hasOffHandEnchant and C_PaperDollInfo.OffhandHasWeapon() then
				self:Show()
				if canplaysound == true then PlaySoundFile(C.media.warning_sound, "Master") end
			end
			return
		end

		wipe(playerBuff)
		local i = 1
		while true do
			local name = UnitBuff("player", i)
			if not name then break end
			playerBuff[name] = true
			i = i + 1
		end
		if reversecheck then
			if group.negate_reversecheck and group.negate_reversecheck == T.Spec then
				self:Hide()
				return
			end
			for i = 1, #group.spells do
				local name = group.spells[i][1]
				if name and playerBuff[name] then
					self:Show()
					if canplaysound == true then PlaySoundFile(C.media.warning_sound, "Master") end
					return
				end
			end
		else
			for i = 1, #group.spells do
				local name = group.spells[i][1]
				if name and playerBuff[name] then
					self:Hide()
					return
				end
			end
			self:Show()
			if canplaysound == true then PlaySoundFile(C.media.warning_sound, "Master") end
		end
	end
end

for i = 1, #tab do
	local frame = CreateFrame("Frame", "ReminderFrame" .. i, UIParent)
	frame:CreatePanel("Default", C.reminder.solo_buffs_size, C.reminder.solo_buffs_size, unpack(C.position.self_buffs))
	frame:SetFrameLevel(6)
	frame.id = i

	frame.icon = frame:CreateTexture(nil, "OVERLAY")
	frame.icon:CropIcon()
	frame.icon:SetSize(C.reminder.solo_buffs_size, C.reminder.solo_buffs_size)

	local ag = frame:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	ag:SetLooping("REPEAT")
	local fadeIn = ag:CreateAnimation("Alpha")
	fadeIn:SetOrder(1)
	fadeIn:SetDuration(.5)
	fadeIn:SetFromAlpha(.6)
	fadeIn:SetToAlpha(0.1)
	fadeIn:SetSmoothing("NONE")

	local fadeOut = ag:CreateAnimation("Alpha")
	fadeOut:SetOrder(2)
	fadeOut:SetDuration(.5)
	fadeOut:SetFromAlpha(0.1)
	fadeOut:SetToAlpha(.6)
	ag:Play()

	frame:Hide()

	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnUpdate", function(self)
		if not self.icon:GetTexture() then
			self:Hide()
		end
	end)
	frame:SetScript("OnShow", function(self)
		if not self.icon:GetTexture() then
			self:Hide()
		end
	end)
end
