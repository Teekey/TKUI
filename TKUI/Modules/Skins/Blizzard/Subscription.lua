local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	SubscriptionInterstitialUI skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	local frame = SubscriptionInterstitialFrame
	T.SkinCloseButton(frame.CloseButton)

	frame:StripTextures()
	frame:SetTemplate("Transparent")
	frame.ShadowOverlay:Hide()

	frame.ClosePanelButton:SkinButton()
end

T.SkinFuncs["Blizzard_SubscriptionInterstitialUI"] = LoadSkin