local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	StanceBar(by Tukz)
----------------------------------------------------------------------------------------
-- Hide bar
if C.actionbar.stancebar_hide then
	StanceBar:SetParent(StanceBarAnchor)
	StanceBar:UnregisterAllEvents()
	for _, button in pairs(StanceBar.actionButtons) do
		button:UnregisterAllEvents()
		button:SetAttribute("statehidden", true)
		button:Hide()
	end
	StanceBarAnchor:Hide()
	return
end

-- Create bar
local bar = CreateFrame("Frame", "StanceHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetAllPoints(StanceBarAnchor)

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
bar:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		for i = 1, 10 do
			local button = _G["StanceButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", StanceBarAnchor, "BOTTOMLEFT", 0, 0)
			else
				local previous = _G["StanceButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", C.actionbar.button_space, 0)
			end
			local icon = GetShapeshiftFormInfo(i)
			if icon then
				button:Show()
			else
				button:Hide()
			end
		end
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		if InCombatLockdown() then return end
		for i = 1, 10 do
			local button = _G["StanceButton"..i]
			local icon = GetShapeshiftFormInfo(i)
			if icon then
				button:Show()
			else
				button:Hide()
			end
		end
		T.ShiftBarUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		T.StyleShift()
	else
		T.ShiftBarUpdate()
	end
end)

local function reposition()
	for i = 1, 10 do
		local button = _G["StanceButton"..i]
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", StanceBarAnchor, "BOTTOMLEFT", 0, 0)
		else
			local previous = _G["StanceButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", C.actionbar.button_space, 0)
		end
	end
end

hooksecurefunc(StanceButton1, "SetPoint", function(_, _, anchor)
	if InCombatLockdown() then return end
	if anchor and anchor == StanceBar then
		local forms = GetNumShapeshiftForms()
		local button = _G["StanceButton"..forms]
		if button and not button.hook then
			hooksecurefunc(button, "SetPoint", function(_, _, anchor)
				if InCombatLockdown() then return end
				if anchor and anchor == StanceBar then
					reposition()
				end
			end)
			button.hook = true
		end
	end
end)

-- Mouseover bar
if C.actionbar.stancebar_mouseover == true then
	StanceBarAnchor:SetAlpha(0)
	StanceBarAnchor:SetScript("OnEnter", function() StanceBarMouseOver(1) end)
	StanceBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then StanceBarMouseOver(0) end end)
	for i = 1, 10 do
		local b = _G["StanceButton"..i]
		b:SetAlpha(C.actionbar.stancebar_mouseover_alpha)
		b:HookScript("OnEnter", function() StanceBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then StanceBarMouseOver(C.actionbar.stancebar_mouseover_alpha) end end)
	end
end