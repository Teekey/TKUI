local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	AlliedRacesUI skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	AlliedRacesFrame:StripTextures()
	AlliedRacesFrame:SetTemplate("Transparent")

	AlliedRacesFramePortrait:SetAlpha(0)

	AlliedRacesFrame.ModelScene:StripTextures()
	AlliedRacesFrame.ModelScene:CreateBackdrop("Transparent")
	AlliedRacesFrame.ModelScene.backdrop:SetFrameLevel(1)
	AlliedRacesFrame.ModelScene.backdrop:SetPoint("TOPLEFT", -2, 2)
	AlliedRacesFrame.ModelScene.backdrop:SetPoint("BOTTOMRIGHT", 2, -2)

	AlliedRacesFrame.ModelScene:SetSize(313, 575)
	AlliedRacesFrame.ModelScene:SetPoint("LEFT", 10, -6)

	local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
	AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, .8, 0)
	scrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
	scrollFrame.Child.RacialTraitsLabel:SetTextColor(1, .8, 0)

	scrollFrame.Child.ObjectivesFrame:StripTextures()
	scrollFrame.Child.ObjectivesFrame:CreateBackdrop("Overlay")

	AlliedRacesFrame:HookScript("OnShow", function(self)
		for button in self.abilityPool:EnumerateActive() do
			select(3, button:GetRegions()):Hide()
			button.Icon:SkinIcon()
			button.Text:SetTextColor(1, 1, 1)
		end
	end)

	T.SkinScrollBar(scrollFrame.ScrollBar)
	T.SkinCloseButton(AlliedRacesFrameCloseButton)
end

T.SkinFuncs["Blizzard_AlliedRacesUI"] = LoadSkin