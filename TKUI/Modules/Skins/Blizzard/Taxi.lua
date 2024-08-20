local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	Taxi skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	TaxiFrame:StripTextures()
	TaxiFrame.TitleText:SetPoint("TOP", TaxiFrame, "TOP", -4, -25)
	TaxiRouteMap:CreateBackdrop("Default")
	T.SkinCloseButton(TaxiFrame.CloseButton)
	TaxiFrame.CloseButton:SetPoint("TOPRIGHT", -9, -26)
end

tinsert(T.SkinFuncs["TKUI"], LoadSkin)