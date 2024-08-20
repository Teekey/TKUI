local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	EventTrace skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	local frame = EventTrace
	T.SkinCloseButton(frame.CloseButton)

	frame:StripTextures()
	frame:SetTemplate("Transparent")

	EventTrace.SubtitleBar.OptionsDropDown:SkinButton()
	T.SkinEditBox(EventTrace.Log.Bar.SearchBox, nil, 16)

	if EventTrace.Log.Events.ScrollBar.Background then
		EventTrace.Log.Events.ScrollBar.Background:Hide()
	end

	EventTraceTooltip:HookScript("OnShow", function(self)
		self.NineSlice:SetTemplate("Transparent")
	end)
end

T.SkinFuncs["Blizzard_EventTrace"] = LoadSkin