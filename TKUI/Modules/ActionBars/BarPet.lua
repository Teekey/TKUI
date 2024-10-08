local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	PetActionBar(by Tukz)
----------------------------------------------------------------------------------------
-- Hide bar
if C.actionbar.petbar_hide then PetActionBarAnchor:Hide() return end

-- Create bar
local bar = CreateFrame("Frame", "PetHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetAllPoints(PetActionBarAnchor)

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("PLAYER_CONTROL_LOST")
bar:RegisterEvent("PLAYER_CONTROL_GAINED")
bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
bar:RegisterEvent("PET_BAR_UPDATE")
bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
bar:RegisterEvent("UNIT_PET")
bar:RegisterEvent("UNIT_FLAGS")
bar:RegisterEvent("UNIT_AURA")
bar:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		T.StylePet()
		PetActionBar_ShowGrid = T.dummy
		PetActionBar_HideGrid = T.dummy
		PetActionBar.showgrid = nil
		for i = 1, 10 do
			local button = _G["PetActionButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", 0, 0)
			else
				local previous = _G["PetActionButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", C.actionbar.button_space, 0)
			end
			button:Show()
			self:SetAttribute("addchild", button)
		end
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")
		hooksecurefunc(PetActionBar, "Update", T.PetBarUpdate)
	elseif event == "PET_BAR_UPDATE" or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED"
	or event == "UNIT_FLAGS" or (event == "UNIT_PET" and arg1 == "player") or (event == "UNIT_AURA" and arg1 == "pet") then
		T.PetBarUpdate()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
	end
end)

hooksecurefunc(PetActionButton10, "SetPoint", function(_, _, anchor)
	if InCombatLockdown() then return end
	if anchor and anchor == PetActionBar then
		for i = 1, 10 do
			local button = _G["PetActionButton"..i]
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", 0, 0)
			else
				local previous = _G["PetActionButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", C.actionbar.button_space, 0)
			end
		end
	end
end)

-- Mouseover bar
if C.actionbar.petbar_mouseover == true then
	PetActionBarAnchor:SetAlpha(0)
	PetActionBarAnchor:SetScript("OnEnter", function() PetBarMouseOver(1) end)
	PetActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then PetBarMouseOver(0) end end)
	for i = 1, NUM_PET_ACTION_SLOTS do
		local b = _G["PetActionButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() PetBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then PetBarMouseOver(0) end end)
	end
end