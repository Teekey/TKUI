local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	AzeriteUI skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	AzeriteEmpoweredItemUI:StripTextures()
	AzeriteEmpoweredItemUI:SetTemplate("Transparent")

	AzeriteEmpoweredItemUI.BorderFrame:StripTextures()

	AzeriteEmpoweredItemUIPortrait:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()

	T.SkinCloseButton(AzeriteEmpoweredItemUICloseButton)
end

T.SkinFuncs["Blizzard_AzeriteUI"] = LoadSkin