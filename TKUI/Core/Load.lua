local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	On logon function
----------------------------------------------------------------------------------------
local OnLogon = CreateFrame("Frame")
OnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
OnLogon:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then

		-- Create empty CVar if they doesn't exist
		if TKUISettings == nil then TKUISettings = {} end
		if TKUISettings.Gold == nil then TKUISettings.Gold = {} end
		if TKUIPositions == nil then TKUIPositions = {} end
		if TKUILootFilter == nil then TKUILootFilter = {} end
		if TKUISettingsPerChar == nil then TKUISettingsPerChar = {} end
		if TKUISettingsPerChar.FogOfWar == nil then TKUISettingsPerChar.FogOfWar = true end
		if TKUISettingsPerChar.Coords == nil then TKUISettingsPerChar.Coords = true end
		if TKUISettingsPerChar.Archaeology == nil then TKUISettingsPerChar.Archaeology = false end
		if TKUISettingsPerChar.BarsLocked == nil then TKUISettingsPerChar.BarsLocked = false end
		if TKUISettingsPerChar.SplitBars == nil then TKUISettingsPerChar.SplitBars = true end
		if TKUISettingsPerChar.RightBars == nil then TKUISettingsPerChar.RightBars = C.actionbar.rightbars end
		if TKUISettingsPerChar.BottomBars == nil then TKUISettingsPerChar.BottomBars = C.actionbar.bottombars end

		if T.screenWidth < 1024 and GetCVar("gxMonitor") == "0" then
			SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
		else
			SetCVar("useUiScale", 1)
			if T.UIScale > 1.28 then T.UIScale = 1.28 end

			-- Set our uiScale
			if tonumber(GetCVar("uiScale")) ~= tonumber(T.UIScale) then
				SetCVar("uiScale", T.UIScale)
			end

			-- Hack for 4K and WQHD Resolution
			if T.UIScale < 0.64 then
				UIParent:SetScale(T.UIScale)
			end

			-- Install default if we never ran TKUI on this character
			if not TKUISettingsPerChar.Install then
				StaticPopup_Show("INSTALL_UI")
			end
		end

		if C.unitframe.enable and C.raidframe.layout ~= "BLIZZARD" then
			if CompactRaidFrameManager then
				local function HideFrames()
					CompactRaidFrameManager:UnregisterAllEvents()
					CompactRaidFrameContainer:UnregisterAllEvents()
					if not InCombatLockdown() then
						CompactRaidFrameManager:Hide()
						local shown = CompactRaidFrameManager_GetSetting("IsShown")
						if shown and shown ~= "0" then
							CompactRaidFrameManager_SetSetting("IsShown", "0")
						end
					end
				end
				hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideFrames)
				CompactRaidFrameManager:HookScript("OnShow", HideFrames)
				CompactRaidFrameContainer:HookScript("OnShow", HideFrames)
				HideFrames()
			end
			CompactArenaFrame:HookScript("OnShow", function(self) self:Hide() end)
		end
	end
end)

----------------------------------------------------------------------------------------
--	Kill all stuff on default UI that we don't need
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
	if ClassPowerBar then
		ClassPowerBar.OnEvent = T.dummy -- Fix error with druid on logon
	end

	TutorialFrameAlertButton:Kill()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES, true)

	SetCVar("countdownForCooldowns", 0)

	SetCVar("chatStyle", "im")

	if T.class == "DEATHKNIGHT" and C.unitframe_class_bar.rune ~= true then
		RuneFrame:Kill()
	end

	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("minimapTrackingShowAll", 1)

	C_Container.SetSortBagsRightToLeft(true)
	C_Container.SetInsertItemsLeftToRight(false)
	SetCVar("enableFloatingCombatText", 0)
end)

local function AcknowledgeTips()
	if InCombatLockdown() then return end

	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

AcknowledgeTips()
hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)

----------------------------------------------------------------------------------------
--	Prevent users config errors
----------------------------------------------------------------------------------------
if C.actionbar.rightbars > 3 then
	C.actionbar.rightbars = 3
end

if C.actionbar.bottombars > 3 then
	C.actionbar.bottombars = 3
end

if C.actionbar.bottombars < 1 then
	C.actionbar.bottombars = 1
end