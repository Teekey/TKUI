local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	MultiBarBottomRight(by Tukz)
----------------------------------------------------------------------------------------
local bar = CreateFrame("Frame", "Bar5Holder", T_PetBattleFrameHider)
bar:SetAllPoints(ActionBarAnchor)
MultiBarBottomRight:SetParent(bar)
bar:SetFrameStrata("LOW")

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_5", true)
	for i = 1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		if i == 1 then
			b:SetPoint("TOPLEFT", Bar1Holder, 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", T.Scale(C.actionbar.button_space), 0)
		end
	end
end)

-- Hide bar
if C.actionbar.bottombars < 3 then
	bar:Hide()
end

-- Mouseover bar
if C.actionbar.bottombars_mouseover then
	for i = 1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() BottomBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then BottomBarMouseOver(0) end end)
	end
end