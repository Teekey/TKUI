local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	First Time Launch and On Login file
----------------------------------------------------------------------------------------
local function InstallUI()
	-- Don't need to set CVar multiple time
	SetCVar("screenshotQuality", 8)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("showTutorials", 0)
	SetCVar("gameTip", "0")
	SetCVar("UberTooltips", 1)
	SetCVar("chatMouseScroll", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("WhisperMode", "inline")
	SetCVar("colorblindMode", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("RotateMinimap", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("taintLog", 0)
	SetCVar("buffDurations", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("lossOfControl", 0)
	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateShowFriendlyNPCs", 1)
	if C.lootfilter.enable == true then SetCVar("autoLootDefault", 0) else SetCVar("autoLootDefault", 1) end

	-- Setting chat frames
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()

		frame:SetSize(C.chat.width, C.chat.height)

		-- Default width and height of chats
		SetChatWindowSavedDimensions(chatFrameId, T.Scale(C.chat.width), T.Scale(C.chat.height))

		-- Move general chat to bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:SetPoint(unpack(C.position.chat))
		end

		-- Save new default position and dimension
		FCF_SavePositionAndDimensions(frame)

		-- Rename general and combat log tabs
		if i == 1 then FCF_SetWindowName(frame, GENERAL) end
		if i == 2 then FCF_SetWindowName(frame, GUILD_BANK_LOG) end

		-- Lock them if unlocked
		if not frame.isLocked then FCF_SetLocked(frame, 1) end
	end

	-- Enable classcolor automatically on login and on each character without doing /configure each time
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
end

-- Reset saved variables on char
TKUISettingsPerChar = {}

TKUISettingsPerChar.Install = true
TKUISettingsPerChar.FogOfWar = true
TKUISettingsPerChar.Coords = true
TKUISettingsPerChar.Archaeology = false
TKUISettingsPerChar.BarsLocked = false
TKUISettingsPerChar.SplitBars = true
TKUISettingsPerChar.RightBars = C.actionbar.rightbars
TKUISettingsPerChar.BottomBars = C.actionbar.bottombars

-- Set to default layout of Blizzard Edit Mode
C_EditMode.SetActiveLayout(1)

ReloadUI()


----------------------------------------------------------------------------------------
--	Button in GameMenuButton frame
----------------------------------------------------------------------------------------
local function EditModeButton()
	for button in GameMenuFrame.buttonPool:EnumerateActive() do
		local text = button:GetText()

		-- Replace EditMode with our moving system
		if text and text == HUD_EDIT_MODE_MENU then
			button:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
				SlashCmdList.MOVING()
				HideUIPanel(GameMenuFrame)
			end)

			-- Replace the button text
			button:SetText("|cFFFF5C00TK|cFFFFFFFFUI Edit Mode|r")
		end

		local fstring = button:GetFontString()
		fstring:SetFont(C.media.normal_font, 14)
	end
end

hooksecurefunc(GameMenuFrame, "Layout", EditModeButton)

----------------------------------------------------------------------------------------
--	Button in GameMenuButton frame
----------------------------------------------------------------------------------------
local function openKeybindMode()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	HideUIPanel(GameMenuFrame)
	SlashCmdList.MOUSEOVERBIND()
end

local keybindButton = CreateFrame("Button", "TKUI_KeybindButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
keybindButton:SetScript("OnClick", openKeybindMode)
keybindButton:SetSize(150, 28)
keybindButton:SetText("|cFFFF5C00TK|cFFFFFFFFUI Keybinds|r")

GameMenuFrame.TKUIKeybind = keybindButton

local gameMenuLastButtons = {
	[_G.GAMEMENU_OPTIONS] = 1,
	[_G.BLIZZARD_STORE] = 2
}

local function PositionGameMenuButtons()
	local anchorIndex = (C_StorePublic.IsEnabled and C_StorePublic.IsEnabled() and 2) or 1
	local lastAnchorButton
	for button in GameMenuFrame.buttonPool:EnumerateActive() do
		local text = button:GetText()

		local lastIndex = gameMenuLastButtons[text]
		if lastIndex == anchorIndex then
			lastAnchorButton = button
		elseif not lastIndex then
			local point, anchor, point2, x, y = button:GetPoint()
			button:SetPoint(point, anchor, point2, x, y - 35) -- Offset for the new button
		end

		-- Replace EditMode with our moving system
		if text and text == HUD_EDIT_MODE_MENU then
			button:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
				SlashCmdList.MOVING()
				HideUIPanel(GameMenuFrame)
			end)
		end

		local fstring = button:GetFontString()
		fstring:SetFont(C.media.normal_font, 14)
	end

	if lastAnchorButton then
		GameMenuFrame.TKUIKeybind:SetPoint("TOPLEFT", lastAnchorButton, "BOTTOMLEFT", 0, -14)
	end

	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 14) -- Increased height to accommodate the new button
end

hooksecurefunc(GameMenuFrame, "Layout", PositionGameMenuButtons)

----------------------------------------------------------------------------------------
--	Popups
----------------------------------------------------------------------------------------
StaticPopupDialogs.INSTALL_UI = {
	text = L_POPUP_INSTALLUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() TKUISettingsPerChar.Install = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 5,
}

StaticPopupDialogs.RESET_UI = {
	text = L_POPUP_RESETUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() TKUISettingsPerChar.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("RESET_UI") end
