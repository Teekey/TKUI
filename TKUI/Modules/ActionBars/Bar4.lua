local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	MultiBarRight(by Tukz)
----------------------------------------------------------------------------------------
local bar = CreateFrame("Frame", "Bar4Holder", RightActionBarAnchor)
bar:SetAllPoints(RightActionBarAnchor)
MultiBarRight:SetParent(bar)

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_4", true)
	for i = 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		local b2 = _G["MultiBarRightButton"..i-1]
		b:ClearAllPoints()
		if i == 1 then
			b:SetPoint("TOPRIGHT", RightActionBarAnchor, "TOPRIGHT", 0, 0)
		else
			b:SetPoint("TOP", b2, "BOTTOM", 0, -C.actionbar.button_space)
		end
	end
end)

-- Hide bar
if C.actionbar.rightbars < 1 then
	bar:Hide()
end

-- Mouseover bar
if C.actionbar.rightbars_mouseover == true then
	for i = 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
	end
end