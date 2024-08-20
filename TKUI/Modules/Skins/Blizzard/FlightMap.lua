local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	Flight Map skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	FlightMapFrame:CreateBackdrop("Transparent")
	FlightMapFrame.BorderFrame:StripTextures()
	FlightMapFramePortrait:Kill()

	FlightMapFrame.ScrollContainer:ClearAllPoints()
	FlightMapFrame.ScrollContainer:SetPoint("TOPLEFT")
	FlightMapFrame.ScrollContainer:SetPoint("BOTTOMRIGHT")

	T.SkinCloseButton(FlightMapFrameCloseButton)
end

T.SkinFuncs["Blizzard_FlightMap"] = LoadSkin