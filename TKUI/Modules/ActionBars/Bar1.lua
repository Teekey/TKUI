local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	ActionBar(by Tukz)
----------------------------------------------------------------------------------------
local bar = CreateFrame("Frame", "Bar1Holder", ActionBarAnchor, "SecureHandlerStateTemplate")
bar:SetAllPoints(ActionBarAnchor)

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["EVOKER"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[possessbar] 16; [shapeshift] 17; [overridebar] 18; [vehicleui] 16; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = T.class
	local page = Page[class]
	if page then
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
bar:RegisterEvent("UNIT_ENTERED_VEHICLE")
bar:RegisterEvent("UNIT_EXITED_VEHICLE")
bar:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		for i = 1, 12 do
			local b = _G["ActionButton"..i]
			b:SetSize(C.actionbar.button_size, C.actionbar.button_size)
			b:ClearAllPoints()
			if i == 1 then
				b:SetPoint("BOTTOMLEFT", Bar1Holder, 0, 0)
			else
				local previous = _G["ActionButton"..i-1]
				b:SetPoint("LEFT", previous, "RIGHT", T.Scale(C.actionbar.button_space), 0)
			end

			self:SetFrameRef("ActionButton"..i, b)
			b:SetParent(Bar1Holder)
		end

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		self:SetAttribute("_onstate-page", [[
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

		RegisterStateDriver(self, "page", GetBar())
	elseif event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_OVERRIDE_ACTIONBAR" then
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G["ActionButton"..i]
			local action = button.action
			local icon = button.icon

			if action >= 120 then
				local texture = GetActionTexture(action)

				if texture then
					icon:SetTexture(texture)
					icon:Show()
				else
					if icon:IsShown() then
						icon:Hide()
					end
				end
			end
		end
	elseif event == "UNIT_ENTERED_VEHICLE" then
		if UnitHasVehicleUI("player") then
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				local button = _G["ActionButton"..i]
				button:GetCheckedTexture():SetAlpha(0)
			end
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G["ActionButton"..i]
			button:GetCheckedTexture():SetAlpha(1)
		end
	end
end)

if C.actionbar.bottombars_mouseover then
	for i = 1, 12 do
		local b = _G["ActionButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() BottomBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then BottomBarMouseOver(0) end end)
	end
end
