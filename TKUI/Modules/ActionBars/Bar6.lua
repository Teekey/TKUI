local T, C, L, _ = unpack(TKUI)

----------------------------------------------------------------------------------------
--	MultiBar5
----------------------------------------------------------------------------------------
local bar = CreateFrame("Frame", "Bar6Holder", UIParent)
bar:SetAllPoints(RightActionBarAnchor)
MultiBar5:SetParent(bar)

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_6", true)
	for i = 1, 12 do
		local b = _G["MultiBar5Button"..i]
		local b2 = _G["MultiBar5Button"..i-1]
		b:ClearAllPoints()
		if i == 1 then
			b:SetPoint("TOPLEFT", RightActionBarAnchor, "TOPLEFT", 0, 0)
		else
			b:SetPoint("TOP", b2, "BOTTOM", 0, -C.actionbar.button_space)
		end
	end
end)

-- Hide bar
if C.actionbar.rightbars < 3 then
	bar:Hide()
end

-- Mouseover bar
if C.actionbar.rightbars_mouseover == true then
	for i = 1, 12 do
		local b = _G["MultiBar5Button"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
	end
end