local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	MultiBarBottomLeft(by Tukz)
----------------------------------------------------------------------------------------
local bar = CreateFrame("Frame", "Bar2Holder", ActionBarAnchor)
bar:SetAllPoints(ActionBarAnchor)
MultiBarBottomLeft:SetParent(bar)

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true)
	for i = 1, 12 do
		local b = _G["MultiBarBottomLeftButton"..i]
		local b2 = _G["MultiBarBottomLeftButton"..i-1]
		b:ClearAllPoints()
		if i == 1 then
			b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, C.actionbar.button_space)
		else
			b:SetPoint("LEFT", b2, "RIGHT", T.Scale(C.actionbar.button_space), 0)
		end
	end
end)

-- Hide bar
if C.actionbar.bottombars == 1 then
	bar:Hide()
end

if C.actionbar.bottombars_mouseover then
	for i = 1, 12 do
		local b = _G["MultiBarBottomLeftButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() BottomBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then BottomBarMouseOver(0) end end)
	end
end