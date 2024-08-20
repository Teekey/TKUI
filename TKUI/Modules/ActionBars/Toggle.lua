local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Toggle ActionBars
----------------------------------------------------------------------------------------
local ToggleBar = CreateFrame("Frame", "ToggleActionbar", UIParent)

local ToggleBarText = function(i, text, plus, neg)
	if plus then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.3, 0.3, 0.9)
	elseif neg then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.9, 0.3, 0.3)
	end
end

local MainBars = function()
	if TKUISettingsPerChar.BottomBars == 1 then
		ActionBarAnchor:SetHeight(C.actionbar.button_size)
		ToggleBarText(1, "+ + +", true)
		Bar2Holder:Hide()
		Bar5Holder:Hide()
	elseif TKUISettingsPerChar.BottomBars == 2 then
		ActionBarAnchor:SetHeight(C.actionbar.button_size * 2 + C.actionbar.button_space)
		ToggleBarText(1, "+ + +", true)
		Bar2Holder:Show()
		Bar5Holder:Hide()
	elseif TKUISettingsPerChar.BottomBars == 3 then
		ActionBarAnchor:SetHeight((C.actionbar.button_size * 3) + (C.actionbar.button_space * 2))
		ToggleBarText(1, "- - -", false, true)
		Bar2Holder:Show()
		Bar5Holder:Show()
	end
end

local RightBars = function()
	if C.actionbar.rightbars > 2 then
		if TKUISettingsPerChar.RightBars == 1 then
			RightActionBarAnchor:SetWidth(C.actionbar.button_size)
			ToggleBar[2]:SetWidth(C.actionbar.button_size)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Hide()
			Bar4Holder:Hide()
		elseif TKUISettingsPerChar.RightBars == 2 then
			RightActionBarAnchor:SetWidth(C.actionbar.button_size * 2 + C.actionbar.button_space)
			ToggleBar[2]:SetWidth(C.actionbar.button_size * 2 + C.actionbar.button_space)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Hide()
			Bar4Holder:Show()
		elseif TKUISettingsPerChar.RightBars == 3 then
			RightActionBarAnchor:SetWidth((C.actionbar.button_size * 3) + (C.actionbar.button_space * 2))
			ToggleBar[2]:SetWidth((C.actionbar.button_size * 3) + (C.actionbar.button_space * 2))
			ToggleBarText(2, "> > >", false, true)
			RightActionBarAnchor:Show()
			Bar3Holder:Show()
			Bar4Holder:Show()
			Bar6Holder:Show()
		elseif TKUISettingsPerChar.RightBars == 0 then
			ToggleBar[2]:SetWidth(C.actionbar.button_size)
			ToggleBarText(2, "< < <", true)
			RightActionBarAnchor:Hide()
			Bar3Holder:Hide()
			Bar4Holder:Hide()
			Bar6Holder:Hide()
		end
	elseif C.actionbar.rightbars < 3 then
		if TKUISettingsPerChar.RightBars == 1 then
			RightActionBarAnchor:SetWidth(C.actionbar.button_size)
			ToggleBar[2]:SetWidth(C.actionbar.button_size)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Show()
			Bar4Holder:Hide()
		elseif TKUISettingsPerChar.RightBars == 2 then
			RightActionBarAnchor:SetWidth(C.actionbar.button_size * 2 + C.actionbar.button_space)
			ToggleBar[2]:SetWidth(C.actionbar.button_size * 2 + C.actionbar.button_space)
			ToggleBarText(2, "> > >", false, true)
			RightActionBarAnchor:Show()
			Bar3Holder:Show()
			Bar4Holder:Show()
		elseif TKUISettingsPerChar.RightBars == 0 then
			ToggleBar[2]:SetWidth(C.actionbar.button_size)
			ToggleBarText(2, "< < <", true)
			RightActionBarAnchor:Hide()
			Bar3Holder:Hide()
			Bar4Holder:Hide()
			Bar6Holder:Hide()
		end
	end
end

local LockCheck = function(i)
	if TKUISettingsPerChar.BarsLocked == true then
		ToggleBar[i].Text:SetText("U")
		ToggleBar[i].Text:SetTextColor(0.3, 0.3, 0.9)
	elseif TKUISettingsPerChar.BarsLocked == false then
		ToggleBar[i].Text:SetText("L")
		ToggleBar[i].Text:SetTextColor(0.9, 0.3, 0.3)
	else
		ToggleBar[i].Text:SetText("L")
		ToggleBar[i].Text:SetTextColor(0.9, 0.3, 0.3)
	end
end

for i = 1, 5 do
	ToggleBar[i] = CreateFrame("Frame", "ToggleBar"..i, ToggleBar)
	ToggleBar[i]:EnableMouse(true)
	ToggleBar[i]:SetAlpha(0)

	ToggleBar[i].Text = ToggleBar[i]:CreateFontString(nil, "OVERLAY")
	ToggleBar[i].Text:SetFont(C.media.pixel_font, C.media.pixel_font_size, C.media.pixel_font_style)
	ToggleBar[i].Text:SetPoint("CENTER", 2, 0)

	if i == 1 then
		ToggleBar[i]:CreatePanel("Transparent", ActionBarAnchor:GetWidth(), C.actionbar.button_size / 1.5, "BOTTOM", ActionBarAnchor, "TOP", 0, C.actionbar.button_space)
		ToggleBarText(i, "- - -", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
			TKUISettingsPerChar.BottomBars = TKUISettingsPerChar.BottomBars + 1

			if TKUISettingsPerChar.BottomBars > 3 then
				TKUISettingsPerChar.BottomBars = 1
			elseif TKUISettingsPerChar.BottomBars > 2 then
				TKUISettingsPerChar.BottomBars = 3
			elseif TKUISettingsPerChar.BottomBars < 1 then
				TKUISettingsPerChar.BottomBars = 3
			end

			MainBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", MainBars)
	elseif i == 2 then
		ToggleBar[i]:CreatePanel("Transparent", RightActionBarAnchor:GetWidth(), C.actionbar.button_size / 1.5, "TOPRIGHT", RightActionBarAnchor, "BOTTOMRIGHT", 0, -C.actionbar.button_space)
		ToggleBar[i]:SetFrameStrata("LOW")
		ToggleBarText(i, "> > >", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
			TKUISettingsPerChar.RightBars = TKUISettingsPerChar.RightBars - 1

			if C.actionbar.rightbars > 2 then
				if TKUISettingsPerChar.RightBars > 3 then
					TKUISettingsPerChar.RightBars = 2
				elseif TKUISettingsPerChar.RightBars > 2 then
					TKUISettingsPerChar.RightBars = 1
				elseif TKUISettingsPerChar.RightBars < 0 then
					TKUISettingsPerChar.RightBars = 3
				end
			elseif C.actionbar.rightbars < 3 then
				if TKUISettingsPerChar.RightBars > 2 then
					TKUISettingsPerChar.RightBars = 1
				elseif TKUISettingsPerChar.RightBars < 0 then
					TKUISettingsPerChar.RightBars = 2
				end
			end

			RightBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", RightBars)
	elseif i == 5 then
		ToggleBar[i]:CreatePanel("Transparent", 19, 19, "TOPLEFT", Minimap, "TOPRIGHT", 3, 2)
		ToggleBar[i]:SetBackdropBorderColor(unpack(C.media.classborder_color))
		ToggleBar[i].Text:SetPoint("CENTER", 1, 0)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then return end

			if TKUISettingsPerChar.BarsLocked == true then
				TKUISettingsPerChar.BarsLocked = false
			elseif TKUISettingsPerChar.BarsLocked == false then
				TKUISettingsPerChar.BarsLocked = true
			end

			LockCheck(i)
			ToggleBar[i]:GetScript("OnEnter")(ToggleBar[i])
		end)
		ToggleBar[i]:SetScript("OnEvent", function() LockCheck(i) end)
	end

	ToggleBar[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_DISABLED")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_ENABLED")

	ToggleBar[i]:SetScript("OnEnter", function()
		if InCombatLockdown() then return end
		if i == 2 then
			if C.actionbar.rightbars_mouseover == true then
				ToggleBar[i]:SetAlpha(1)
				RightBarMouseOver(1)
			else
				ToggleBar[i]:FadeIn()
			end
		else
			if i == 1 and C.actionbar.bottombars_mouseover then
				BottomBarMouseOver(1)
				ToggleBar[i]:SetAlpha(1)
				return
			end
			ToggleBar[i]:FadeIn()
		end
		if i == 5 then
			GameTooltip:SetOwner(ToggleBar[i], "ANCHOR_LEFT")
			GameTooltip:AddLine(L_MINIMAP_TOGGLE, 0.40, 0.78, 1)
			GameTooltip:AddDoubleLine(" ", TALENT_TREE_LOCKED..": "..(TKUISettingsPerChar.BarsLocked and "|cff55ff55"..L_STATS_ON or "|cffff5555"..strupper(OFF)), 1, 1, 1, 0.75, 0.90, 1)
			GameTooltip:Show()
		end
	end)

	ToggleBar[i]:SetScript("OnLeave", function()
		if i == 2 then
			if C.actionbar.rightbars_mouseover == true then
				ToggleBar[i]:SetAlpha(0)
				RightBarMouseOver(0)
			else
				ToggleBar[i]:FadeOut()
			end
		else
			if i == 1 and C.actionbar.bottombars_mouseover then
				BottomBarMouseOver(0)
				ToggleBar[i]:SetAlpha(0)
				return
			end
			ToggleBar[i]:FadeOut()
		end
		if i == 5 then
			GameTooltip:Hide()
		end
	end)

	ToggleBar[i]:SetScript("OnUpdate", function()
		if InCombatLockdown() then return end
		if TKUISettingsPerChar.BarsLocked == true then
			for i = 1, 4 do
				ToggleBar[i]:EnableMouse(false)
			end
		elseif TKUISettingsPerChar.BarsLocked == false then
			for i = 1, 4 do
				ToggleBar[i]:EnableMouse(true)
			end
		end
	end)
end