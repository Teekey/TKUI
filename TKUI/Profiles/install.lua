local E, L, V, P, G = unpack(ElvUI)
local MyPluginName = "RetroUI"

local RetroUI = E:GetModule(MyPluginName);
local EP = LibStub("LibElvUIPlugin-1.0")
local addon = ...

local pairs, tinsert, tremove, unpack = pairs, tinsert, tremove, unpack
local format = format
local _G = _G
local ceil, format, checkTable = ceil, format, next
local tinsert, twipe, tsort, tconcat = table.insert, table.wipe, table.sort, table.concat

-- WoW API / Variables

local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI
local FCF_SetLocked = FCF_SetLocked
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_StopDragging = FCF_StopDragging
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local ADDONS, LOOT, TRADE, TANK, HEALER = ADDONS, LOOT, TRADE, TANK, HEALER
RetroUI.Version = GetAddOnMetadata('ElvUI_RetroUI', 'Version')


--Runs for the step questioning the user if they want a new ElvUI profile
local function NewProfile(new)
	if (new) then -- the user clicked "Create New" create a dialog pop up
		StaticPopupDialogs["CreateProfileNameNew"] = {
		text = L["Name for the new profile"],
		button1 = L["Accept"],
		button2 = L["Cancel"],
		hasEditBox = 1,
		whileDead = 1,
		hideOnEscape = 1,
		timeout = 0,
		OnShow = function(self, data)
		  self.editBox:SetText("RetroUI"); --default text in the editbox
		end,
		OnAccept = function(self, data, data2)
		  local text = self.editBox:GetText()
		  ElvUI[1].data:SetProfile(text) --ElvUI function for changing profiles, creates a new profile if name doesn't exist
		  PluginInstallStepComplete.message = "Profile Created"
		  PluginInstallStepComplete:Show()
		end
	  };
	  StaticPopup_Show("CreateProfileNameNew", "test"); --tell our dialog box to show
	elseif(new == false) then -- the user clicked "Use Current" create a dialog pop up
		StaticPopupDialogs["ProfileOverrideConfirm"] = {
			text = "Are you sure you want to override the current profile?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
			    PluginInstallStepComplete.message = "Profile Selected"
		        PluginInstallStepComplete:Show()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
		StaticPopup_Show("ProfileOverrideConfirm", "test")--tell our dialog box to show
	end
end



local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)

		FCF_SetChatWindowFontSize(nil, frame, 13)

		-- move ElvUI default loot frame to the left chat, so that Recount/Skada can go to the right chat.
		if i == 3 and chatName == LOOT.." / "..TRADE then
			FCF_UnDockFrame(frame)
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
			FCF_SetWindowName(frame, LOOT)
			FCF_DockFrame(frame)
			if not frame.isLocked then
				FCF_SetLocked(frame, 1)
			end
			frame:Show()
		end
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
	end
	ChatFrame_RemoveChannel(ChatFrame3, L["Trade"])
	ChatFrame_AddChannel(ChatFrame1, L["Trade"])
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")

	-- Enable classcolor automatically on login and on each character without doing /configure each time
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	--chat options--
	
	E.db["chat"]["chatHistory"] = false
	E.db["chat"]["panelColor"]["a"] = 0.50197747349739
	E.db["chat"]["panelColor"]["b"] = 0.058823529411765
	E.db["chat"]["panelColor"]["g"] = 0.058823529411765
	E.db["chat"]["panelColor"]["r"] = 0.058823529411765
	E.db["chat"]["tabFontOutline"] = "OUTLINE"
	E.db["chat"]["keywordSound"] = "Whisper Alert"
	E.db["chat"]["timeStampFormat"] = "%H:%M "
	E.db["chat"]["separateSizes"] = true
	E.db["chat"]["copyChatLines"] = true
	E.db["chat"]["editBoxPosition"] = "ABOVE_CHAT"
	E.db["chat"]["panelHeightRight"] = 155
	E.db["chat"]["font"] = "Florence Sans"
	E.db["chat"]["panelTabTransparency"] = true
	E.db["chat"]["panelHeight"] = 155
	E.db["chat"]["tabFont"] = "Florence Sans"
	E.db["chat"]["panelWidthRight"] = 376
	E.db["chat"]["keywords"] = "%MYNAME%, ElvUI, RetroUI"
	E.db["chat"]["panelWidth"] = 376
	

		
	PluginInstallStepComplete.message = RetroUI.Title..L['Chat Set']
	PluginInstallStepComplete:Show()
	E:UpdateAll(true)
	end
	
local function SetupLayout()
		-- common settings
		E.db["datatexts"]["font"] = "Florence Sans"
		E.db["datatexts"]["panels"]["LeftMiniPanel"] = ""
		E.db["datatexts"]["panels"]["RightCoordDtPanel"] = "Guild"
		E.db["datatexts"]["panels"]["MinimapPanel"]["enable"] = false
		E.db["datatexts"]["panels"]["LeftChatDataPanel"][2] = "Guild"
		E.db["datatexts"]["panels"]["LeftChatDataPanel"][3] = "Friends"
		E.db["datatexts"]["panels"]["BottomMiniPanel"] = "Time"
		E.db["datatexts"]["panels"]["RightMiniPanel"] = ""
		E.db["datatexts"]["panels"]["LeftCoordDtPanel"] = "Friends"
		E.db["datatexts"]["fontOutline"] = "OUTLINE"
		E.db["tooltip"]["fontSize"] = 13
		E.db["tooltip"]["healthBar"]["height"] = 14
		E.db["tooltip"]["healthBar"]["fontSize"] = 12
		E.db["tooltip"]["healthBar"]["font"] = "Florence Sans"
		E.db["tooltip"]["headerFontSize"] = 13
		E.db["tooltip"]["textFontSize"] = 13
		E.db["tooltip"]["showMount"] = true
		E.db["tooltip"]["spellID"] = true
		E.db["tooltip"]["fontOutline"] = "OUTLINE"
		E.db["tooltip"]["font"] = "Florence Sans"
		E.db["tooltip"]["playerTitles"] = false
		E.db["tooltip"]["smallTextFontSize"] = 13
		E.db["databars"]["threat"]["height"] = 14
		E.db["databars"]["threat"]["font"] = "Florence Sans"
		E.db["databars"]["threat"]["fontOutline"] = "OUTLINE"
		E.db["databars"]["threat"]["width"] = 408
		E.db["databars"]["experience"]["orientation"] = "HORIZONTAL"
		E.db["databars"]["experience"]["font"] = "Florence Sans"
		E.db["databars"]["experience"]["fontOutline"] = "OUTLINE"
		E.db["databars"]["experience"]["width"] = 500
		E.db["databars"]["honor"]["textFormat"] = "CURPERC"
		E.db["databars"]["honor"]["orientation"] = "HORIZONTAL"
		E.db["databars"]["honor"]["fontOutline"] = "OUTLINE"
		E.db["databars"]["honor"]["height"] = 12
		E.db["databars"]["honor"]["font"] = "Florence Sans"
		E.db["databars"]["honor"]["mouseover"] = true
		E.db["databars"]["honor"]["width"] = 375
		E.db["databars"]["reputation"]["orientation"] = "HORIZONTAL"
		E.db["databars"]["reputation"]["textFormat"] = "PERCENT"
		E.db["databars"]["reputation"]["height"] = 12
		E.db["databars"]["reputation"]["fontOutline"] = "OUTLINE"
		E.db["databars"]["reputation"]["enable"] = true
		E.db["databars"]["reputation"]["font"] = "Florence Sans"
		E.db["databars"]["reputation"]["mouseover"] = true
		E.db["databars"]["reputation"]["width"] = 375
		E.db["databars"]["azerite"]["textFormat"] = "CURPERC"
		E.db["databars"]["azerite"]["height"] = 12
		E.db["databars"]["azerite"]["fontOutline"] = "OUTLINE"
		E.db["databars"]["azerite"]["orientation"] = "HORIZONTAL"
		E.db["databars"]["azerite"]["font"] = "Florence Sans"
		E.db["databars"]["azerite"]["mouseover"] = true
		E.db["databars"]["azerite"]["width"] = 200
		E.db["currentTutorial"] = 3
		E.db["general"]["totems"]["spacing"] = 1
		E.db["general"]["font"] = "Florence Sans"
		E.db["general"]["bottomPanel"] = false
		E.db["general"]["backdropcolor"]["b"] = 0.10196078431373
		E.db["general"]["backdropcolor"]["g"] = 0.10196078431373
		E.db["general"]["backdropcolor"]["r"] = 0.10196078431373
		E.db["general"]["backdropfadecolor"]["a"] = 0.65000000596046
		E.db["general"]["backdropfadecolor"]["b"] = 0.13725490196078
		E.db["general"]["backdropfadecolor"]["g"] = 0.13725490196078
		E.db["general"]["backdropfadecolor"]["r"] = 0.13725490196078
		E.db["general"]["minimap"]["size"] = 200
		E.db["general"]["minimap"]["locationFont"] = "Florence Sans"
		
		E.db["bags"]["countFontSize"] = 12
		E.db["bags"]["countFont"] = "Florence Sans"
		E.db["bags"]["itemLevelFont"] = "Florence Sans"
		E.db["bags"]["countFontOutline"] = "OUTLINE"
		E.db["bags"]["itemLevelFontSize"] = 12
		E.db["bags"]["itemLevelFontOutline"] = "OUTLINE"
		E.db["hideTutorial"] = true
		
		E.db["auras"]["buffs"]["countFont"] = "Florence Sans"
		E.db["auras"]["buffs"]["countFontOutline"] = "OUTLINE"
		E.db["auras"]["buffs"]["countFontSize"] = 12
		E.db["auras"]["buffs"]["timeFont"] = "Florence Sans"
		E.db["auras"]["buffs"]["timeFontOutline"] = "OUTLINE"
		E.db["auras"]["buffs"]["timeFontSize"] = 12
		E.db["auras"]["debuffs"]["countFont"] = "Florence Sans"
		E.db["auras"]["debuffs"]["countFontOutline"] = "OUTLINE"
		E.db["auras"]["debuffs"]["countFontSize"] = 12
		E.db["auras"]["debuffs"]["timeFont"] = "Florence Sans"
		E.db["auras"]["debuffs"]["timeFontOutline"] = "OUTLINE"
		E.db["auras"]["debuffs"]["timeFontSize"] = 12
		E.db["v11NamePlateReset"] = true
		
		E.private["skins"]["blizzard"]["alertframes"] = true
		E.private["auras"]["enable"] = true
		
		E.private["general"]["normTex"] = "ElvUI Blank"
		E.private["general"]["glossTex"] = "ElvUI Blank"
		E.private["general"]["chatBubbles"] = 'backdrop'
		E.private["general"]["namefont"] = "Florence Sans"
		E.private["general"]["dmgfont"] = "Florence Sans"
		
		--nameplates
		
		E.db["actionbar"]["bar4"]["buttonsPerRow"] = 12
		E.db["actionbar"]["bar4"]["alpha"] = 0.75
		E.db["actionbar"]["bar4"]["backdrop"] = false
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["countFontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["durationPosition"] = "TOP"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["priority"] = "Blacklist,Personal,CCDebuffs"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["size"] = 28
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["yOffset"] = 11
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["portrait"]["height"] = 20
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["portrait"]["width"] = 20
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["portrait"]["xOffset"] = 5
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["portrait"]["yOffset"] = 0
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["power"]["displayAltPower"] = true
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["raidTargetIndicator"]["xOffset"] = -5
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["raidTargetIndicator"]["size"] = 18
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["countFontSize"] = 11
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["growthX"] = "LEFT"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["durationPosition"] = "TOP"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["size"] = 28
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["yOffset"] = 42
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["title"]["format"] = "[npctitle]"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["height"] = 10
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["iconOffsetX"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["iconOffsetY"] = -5
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["iconSize"] = 18
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["width"] = 130
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["xOffset"] = -10
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["yOffset"] = -22
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["format"] = "[name:long]"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["fontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["yOffset"] = -4
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["xOffset"] = 2
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["format"] = "[difficultycolor][level][shortclassification]"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["fontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["yOffset"] = -4
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["health"]["height"] = 16
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["health"]["text"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["health"]["text"]["fontSize"] = 12
		E.db["nameplates"]["units"]["TARGET"]["classpower"]["yOffset"] = 53
		E.db["nameplates"]["units"]["TARGET"]["classpower"]["width"] = 122
		E.db["nameplates"]["units"]["TARGET"]["glowStyle"] = "style1"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["countFontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["durationPosition"] = "TOPLEFT"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["priority"] = "Blacklist,Personal,CCDebuffs"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["size"] = 28
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["yOffset"] = 11
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["portrait"]["height"] = 20
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["portrait"]["width"] = 20
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["portrait"]["xOffset"] = 5
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["portrait"]["yOffset"] = 0
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["height"] = 10
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["iconOffsetX"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["iconOffsetY"] = -5
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["iconSize"] = 18
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["width"] = 130
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["xOffset"] = -10
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["yOffset"] = -22
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["questIcon"]["xOffset"] = 5
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["questIcon"]["size"] = 18
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["raidTargetIndicator"]["xOffset"] = -5
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["raidTargetIndicator"]["size"] = 18
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["format"] = "[name:long]"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["fontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["yOffset"] = -4
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["xOffset"] = 2
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["fontSize"] = 12
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["yOffset"] = -4
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["countFontSize"] = 11
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["growthX"] = "LEFT"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["durationPosition"] = "TOPLEFT"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["size"] = 28
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["yOffset"] = 42
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["height"] = 16
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["countFontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["durationPosition"] = "TOP"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["size"] = 28
		E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["yOffset"] = 11
		E.db["nameplates"]["units"]["ENEMY_NPC"]["portrait"]["height"] = 20
		E.db["nameplates"]["units"]["ENEMY_NPC"]["portrait"]["width"] = 20
		E.db["nameplates"]["units"]["ENEMY_NPC"]["portrait"]["xOffset"] = 5
		E.db["nameplates"]["units"]["ENEMY_NPC"]["portrait"]["yOffset"] = 0
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["height"] = 10
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["iconOffsetX"] = 3
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["iconOffsetY"] = -5
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["iconSize"] = 18
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["width"] = 130
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["xOffset"] = -10
		E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["yOffset"] = -22
		E.db["nameplates"]["units"]["ENEMY_NPC"]["questIcon"]["xOffset"] = 10
		E.db["nameplates"]["units"]["ENEMY_NPC"]["questIcon"]["size"] = 18
		E.db["nameplates"]["units"]["ENEMY_NPC"]["raidTargetIndicator"]["xOffset"] = -5
		E.db["nameplates"]["units"]["ENEMY_NPC"]["raidTargetIndicator"]["size"] = 18
		E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["format"] = "[name:long]"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["yOffset"] = -4
		E.db["nameplates"]["units"]["ENEMY_NPC"]["level"]["xOffset"] = 2
		E.db["nameplates"]["units"]["ENEMY_NPC"]["level"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_NPC"]["level"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["level"]["yOffset"] = -4
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["countFontSize"] = 11
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["growthX"] = "LEFT"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["yOffset"] = 42
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["priority"] = "Blacklist,blockNoDuration,Personal,TurtleBuffs"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["durationPosition"] = "TOP"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["size"] = 28
		E.db["nameplates"]["units"]["ENEMY_NPC"]["health"]["height"] = 16
		E.db["nameplates"]["units"]["ENEMY_NPC"]["health"]["text"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["health"]["text"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["countFontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["durationPosition"] = "TOPLEFT"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["priority"] = "Blacklist,Personal,CCDebuffs"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["size"] = 28
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["yOffset"] = 11
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["portrait"]["height"] = 20
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["portrait"]["width"] = 20
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["portrait"]["xOffset"] = 5
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["portrait"]["yOffset"] = 0
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["power"]["displayAltPower"] = true
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["raidTargetIndicator"]["xOffset"] = -5
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["raidTargetIndicator"]["size"] = 18
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["countFontSize"] = 11
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["countFont"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["growthX"] = "LEFT"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["yOffset"] = 42
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["maxDuration"] = 0
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["spacing"] = 3
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["priority"] = "Blacklist,blockNoDuration,Personal,TurtleBuffs"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["durationPosition"] = "TOPLEFT"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["size"] = 28
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["title"]["format"] = "[npctitle]"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["height"] = 10
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["iconOffsetX"] = 3
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["iconOffsetY"] = -5
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["iconSize"] = 18
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["width"] = 130
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["xOffset"] = -10
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["yOffset"] = -22
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["format"] = "[name:long]"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["yOffset"] = -4
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["xOffset"] = 2
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["format"] = "[difficultycolor][level][shortclassification]"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["fontSize"] = 12
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["yOffset"] = -4
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["health"]["height"] = 16
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["health"]["text"]["font"] = "Florence Sans"
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["health"]["text"]["fontSize"] = 12
		E.db["nameplates"]["units"]["PLAYER"]["raidTargetIndicator"]["xOffset"] = -20
		E.db["nameplates"]["statusbar"] = "ElvUI Blank"
		E.db["nameplates"]["font"] = "Florence Sans"
		E.db["nameplates"]["clampToScreen"] = true	

		
		-- Movers
		if E.db["movers"] == nil then E.db["movers"] = {} end
		E.db["movers"]["ThreatBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,4"
		E.db["movers"]["RightChatMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4"
		E.db["movers"]["LeftChatMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,4"
		E.db["movers"]["GMMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,510,-4"
		E.db["movers"]["BossButton"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,642,185"
		E.db["movers"]["LootFrameMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,524,-350"
		E.db["movers"]["ZoneAbility"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-642,185"
		E.db["movers"]["VehicleSeatMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-382,53"
		E.db["movers"]["LocationMover"] = "TOP,ElvUIParent,TOP,0,-8"
		E.db["movers"]["ExperienceBarMover"] = "TOP,ElvUIParent,TOP,0,-5"
		E.db["movers"]["MinimapMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-10,-9"
		E.db["movers"]["ClassBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,-334,68"
		E.db["movers"]["DurabilityFrameMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-512,54"
		E.db["movers"]["ElvUIBankMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,202"
		E.db["movers"]["TotemBarMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,383,17"
		E.db["movers"]["LossControlMover"] = "TOP,ElvUIParent,TOP,0,-550"
		E.db["movers"]["ElvUIBagMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,202"
		E.db["movers"]["BelowMinimapContainerMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-10,-233"
		E.db["movers"]["TalkingHeadFrameMover"] = "TOP,ElvUIParent,TOP,0,-170"
		E.db["movers"]["ReputationBarMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,186"
		E.db["movers"]["AzeriteBarMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-10,-213"
		E.db["movers"]["ObjectiveFrameMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-85,-275"
		E.db["movers"]["BNETMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,4,-4"
		E.db["movers"]["VehicleLeaveButton"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-511,149"
		E.db["movers"]["VOICECHAT"] = "TOPLEFT,ElvUIParent,TOPLEFT,4,-4"
		E.db["movers"]["HonorBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,186"
		E.db["movers"]["TooltipMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-3,281"
		
	PluginInstallStepComplete.message = RetroUI.Title..L['Layout Set']
	PluginInstallStepComplete:Show()

	E:UpdateAll(true)
end


local function SetupUnitframes(layout)
	if layout == 'v1' then
	E.db.unitframes = nil
	-- Units
	-- general
	E.db["unitframe"]["statusbar"] = "ElvUI Blank"
	E.db["unitframe"]["colors"]["colorhealthbyvalue"] = false
	E.db["unitframe"]["colors"]["health_backdrop"]["b"] = 0.007843137254902
	E.db["unitframe"]["colors"]["health_backdrop"]["g"] = 0.007843137254902
	E.db["unitframe"]["colors"]["health_backdrop"]["r"] = 0.64313725490196
	E.db["unitframe"]["colors"]["transparentHealth"] = true
	E.db["unitframe"]["colors"]["healthMultiplier"] = 1
	E.db["unitframe"]["colors"]["classResources"]["WARLOCK"]["r"] = 0.58039215686275
	E.db["unitframe"]["colors"]["power"]["PAIN"]["b"] = 1
	E.db["unitframe"]["colors"]["power"]["PAIN"]["g"] = 1
	E.db["unitframe"]["colors"]["power"]["PAIN"]["r"] = 1
	E.db["unitframe"]["colors"]["power"]["MAELSTROM"]["g"] = 0.50196078431373
	E.db["unitframe"]["colors"]["power"]["FOCUS"]["b"] = 0.27058823529412
	E.db["unitframe"]["colors"]["power"]["FOCUS"]["g"] = 0.43137254901961
	E.db["unitframe"]["colors"]["power"]["FOCUS"]["r"] = 0.70980392156863
	E.db["unitframe"]["colors"]["power"]["RUNIC_POWER"]["g"] = 0.81960784313725
	E.db["unitframe"]["colors"]["power"]["ENERGY"]["b"] = 0.53725490196078
	E.db["unitframe"]["colors"]["power"]["ENERGY"]["g"] = 0.96862745098039
	E.db["unitframe"]["colors"]["power"]["ENERGY"]["r"] = 1
	E.db["unitframe"]["colors"]["power"]["INSANITY"]["b"] = 0.8156862745098
	E.db["unitframe"]["colors"]["power"]["INSANITY"]["g"] = 0.16862745098039
	E.db["unitframe"]["colors"]["power"]["INSANITY"]["r"] = 0.65098039215686
	E.db["unitframe"]["colors"]["power"]["LUNAR_POWER"]["b"] = 0.13333333333333
	E.db["unitframe"]["colors"]["power"]["LUNAR_POWER"]["g"] = 0.95294117647059
	E.db["unitframe"]["colors"]["power"]["LUNAR_POWER"]["r"] = 1
	E.db["unitframe"]["colors"]["power"]["MANA"]["b"] = 1
	E.db["unitframe"]["colors"]["power"]["MANA"]["g"] = 0.71372549019608
	E.db["unitframe"]["colors"]["power"]["MANA"]["r"] = 0.49019607843137
	E.db["unitframe"]["colors"]["power"]["FURY"]["b"] = 0.17254901960784
	E.db["unitframe"]["colors"]["power"]["FURY"]["g"] = 0.55686274509804
	E.db["unitframe"]["colors"]["power"]["FURY"]["r"] = 1
	E.db["unitframe"]["colors"]["power"]["RAGE"]["b"] = 0.32156862745098
	E.db["unitframe"]["colors"]["power"]["RAGE"]["g"] = 0.32156862745098
	E.db["unitframe"]["colors"]["power"]["RAGE"]["r"] = 1
	E.db["unitframe"]["colors"]["castColor"]["b"] = 0.25882352941176
	E.db["unitframe"]["colors"]["castColor"]["g"] = 0.69411764705882
	E.db["unitframe"]["colors"]["castColor"]["r"] = 0.23921568627451
	E.db["unitframe"]["colors"]["health"]["b"] = 0.30980392156863
	E.db["unitframe"]["colors"]["health"]["g"] = 0.30980392156863
	E.db["unitframe"]["colors"]["health"]["r"] = 0.30980392156863
	E.db["unitframe"]["colors"]["classbackdrop"] = true
	E.db["unitframe"]["smartRaidFilter"] = false
	E.db["unitframe"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["font"] = "Florence Sans"
	E.db["unitframe"]["fontSize"] = 13

	
	-- player
	
	E.db["unitframe"]["units"]["player"]["debuffs"]["attachTo"] = "BUFFS"
	E.db["unitframe"]["units"]["player"]["debuffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["player"]["debuffs"]["sortDirection"] = "ASCENDING"
	E.db["unitframe"]["units"]["player"]["debuffs"]["durationPosition"] = "TOP"
	E.db["unitframe"]["units"]["player"]["debuffs"]["yOffset"] = 2
	E.db["unitframe"]["units"]["player"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["player"]["health"]["text_format"] = "[health:current] [namecolor]|| ||cfff2f2f2[health:percent]"
	E.db["unitframe"]["units"]["player"]["health"]["position"] = "RIGHT"
	E.db["unitframe"]["units"]["player"]["classbar"]["height"] = 6
	E.db["unitframe"]["units"]["player"]["classbar"]["fill"] = "spaced"
	E.db["unitframe"]["units"]["player"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["aurabar"]["minDuration"] = 1
	E.db["unitframe"]["units"]["player"]["RestIcon"]["anchorPoint"] = "TOP"
	E.db["unitframe"]["units"]["player"]["RestIcon"]["texture"] = "RESTING1"
	E.db["unitframe"]["units"]["player"]["RestIcon"]["color"]["b"] = 0.1921568627451
	E.db["unitframe"]["units"]["player"]["RestIcon"]["color"]["g"] = 0.74117647058824
	E.db["unitframe"]["units"]["player"]["RestIcon"]["color"]["r"] = 0.8
	E.db["unitframe"]["units"]["player"]["RestIcon"]["xOffset"] = 0
	E.db["unitframe"]["units"]["player"]["RestIcon"]["defaultColor"] = false
	E.db["unitframe"]["units"]["player"]["RestIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["player"]["power"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["player"]["power"]["height"] = 8
	E.db["unitframe"]["units"]["player"]["power"]["xOffset"] = 2
	E.db["unitframe"]["units"]["player"]["power"]["detachedWidth"] = 300
	E.db["unitframe"]["units"]["player"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["player"]["castbar"]["iconYOffset"] = -11
	E.db["unitframe"]["units"]["player"]["castbar"]["iconXOffset"] = -5
	E.db["unitframe"]["units"]["player"]["castbar"]["iconSize"] = 60
	E.db["unitframe"]["units"]["player"]["castbar"]["width"] = 250
	E.db["unitframe"]["units"]["player"]["castbar"]["height"] = 20
	E.db["unitframe"]["units"]["player"]["width"] = 250
	E.db["unitframe"]["units"]["player"]["CombatIcon"]["size"] = 16
	E.db["unitframe"]["units"]["player"]["CombatIcon"]["yOffset"] = 16
	E.db["unitframe"]["units"]["player"]["CombatIcon"]["texture"] = "ALERT"
	E.db["unitframe"]["units"]["player"]["height"] = 38
	E.db["unitframe"]["units"]["player"]["buffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["player"]["buffs"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["buffs"]["yOffset"] = 5
	E.db["unitframe"]["units"]["player"]["buffs"]["maxDuration"] = 120
	E.db["unitframe"]["units"]["player"]["buffs"]["attachTo"] = "FRAME"
	E.db["unitframe"]["units"]["player"]["buffs"]["sortDirection"] = "ASCENDING"
	E.db["unitframe"]["units"]["player"]["buffs"]["priority"] = "blockNoDuration,Blacklist,Personal,PlayerBuffs,Whitelist,nonPersonal"
	E.db["unitframe"]["units"]["player"]["buffs"]["minDuration"] = 1
	E.db["unitframe"]["units"]["player"]["buffs"]["durationPosition"] = "TOP"
	E.db["unitframe"]["units"]["player"]["raidicon"]["attachTo"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["raidicon"]["size"] = 16
	E.db["unitframe"]["units"]["player"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["player"]["raidicon"]["yOffset"] = 2
	
	-- target
	E.db["unitframe"]["units"]["target"]["customTexts"] = {}
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"] = {}
	
	E.db["unitframe"]["units"]["target"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["target"]["debuffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["target"]["debuffs"]["attachTo"] = "FRAME"
	E.db["unitframe"]["units"]["target"]["debuffs"]["sortMethod"] = "PLAYER"
	E.db["unitframe"]["units"]["target"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["target"]["debuffs"]["priority"] = "Blacklist,Personal,nonPersonal"
	E.db["unitframe"]["units"]["target"]["debuffs"]["durationPosition"] = "TOP"
	E.db["unitframe"]["units"]["target"]["debuffs"]["yOffset"] = 5
	E.db["unitframe"]["units"]["target"]["CombatIcon"]["size"] = 16
	E.db["unitframe"]["units"]["target"]["CombatIcon"]["yOffset"] = 16
	E.db["unitframe"]["units"]["target"]["CombatIcon"]["texture"] = "ALERT"
	E.db["unitframe"]["units"]["target"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["aurabar"]["minDuration"] = 1
	E.db["unitframe"]["units"]["target"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["target"]["health"]["text_format"] = "[health:current] [namecolor]|| ||cfff2f2f2[health:percent]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["xOffset"] = 2
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["text_format"] = "[difficultycolor][level][shortclassification] [namecolor][name]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["yOffset"] = -34
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["Na"]["size"] = 16
	E.db["unitframe"]["units"]["target"]["width"] = 250
	E.db["unitframe"]["units"]["target"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["target"]["castbar"]["iconYOffset"] = -11
	E.db["unitframe"]["units"]["target"]["castbar"]["iconPosition"] = "RIGHT"
	E.db["unitframe"]["units"]["target"]["castbar"]["width"] = 250
	E.db["unitframe"]["units"]["target"]["castbar"]["iconSize"] = 60
	E.db["unitframe"]["units"]["target"]["castbar"]["iconXOffset"] = 5
	E.db["unitframe"]["units"]["target"]["castbar"]["height"] = 20
	E.db["unitframe"]["units"]["target"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["target"]["power"]["detachedWidth"] = 300
	E.db["unitframe"]["units"]["target"]["power"]["text_format"] = "[classpowercolor][classpower:current][powercolor][  >power:current]"
	E.db["unitframe"]["units"]["target"]["power"]["height"] = 8
	E.db["unitframe"]["units"]["target"]["height"] = 38
	E.db["unitframe"]["units"]["target"]["buffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["target"]["buffs"]["yOffset"] = 2
	E.db["unitframe"]["units"]["target"]["buffs"]["maxDuration"] = 120
	E.db["unitframe"]["units"]["target"]["buffs"]["minDuration"] = 1
	E.db["unitframe"]["units"]["target"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["target"]["buffs"]["sortDirection"] = "ASCENDING"
	E.db["unitframe"]["units"]["target"]["buffs"]["priority"] = "Blacklist,blockNoDuration,Personal,PlayerBuffs,Whitelist,nonPersonal"
	E.db["unitframe"]["units"]["target"]["buffs"]["attachTo"] = "DEBUFFS"
	E.db["unitframe"]["units"]["target"]["buffs"]["durationPosition"] = "TOP"
	E.db["unitframe"]["units"]["target"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["target"]["raidicon"]["attachTo"] = "CENTER"
	E.db["unitframe"]["units"]["target"]["raidicon"]["size"] = 16
	E.db["unitframe"]["units"]["target"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["target"]["raidicon"]["yOffset"] = 2
	
	-- pet
	E.db["unitframe"]["units"]["pet"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["pet"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["pet"]["debuffs"]["enable"] = true
	E.db["unitframe"]["units"]["pet"]["debuffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["pet"]["castbar"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["castbar"]["width"] = 100
	E.db["unitframe"]["units"]["pet"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["pet"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["pet"]["width"] = 100
	E.db["unitframe"]["units"]["pet"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["pet"]["power"]["height"] = 6
	E.db["unitframe"]["units"]["pet"]["power"]["xOffset"] = -2
	E.db["unitframe"]["units"]["pet"]["name"]["xOffset"] = 2
	E.db["unitframe"]["units"]["pet"]["name"]["yOffset"] = -22
	E.db["unitframe"]["units"]["pet"]["name"]["position"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["pet"]["height"] = 30
	E.db["unitframe"]["units"]["pet"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["pet"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["pet"]["buffs"]["attachTo"] = "DEBUFFS"
	E.db["unitframe"]["units"]["pet"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["pet"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["pet"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["pet"]["health"]["text_format"] = "[health:percent]"
	
	-- focus
	E.db["unitframe"]["units"]["focus"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["priority"] = "Blacklist,Personal,Boss,RaidDebuffs"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["debuffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["focus"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["focus"]["aurabar"]["attachTo"] = "FRAME"
	E.db["unitframe"]["units"]["focus"]["aurabar"]["maxBars"] = 6
	E.db["unitframe"]["units"]["focus"]["aurabar"]["spacing"] = 2
	E.db["unitframe"]["units"]["focus"]["aurabar"]["detachedWidth"] = 130
	E.db["unitframe"]["units"]["focus"]["aurabar"]["priority"] = ""
	E.db["unitframe"]["units"]["focus"]["aurabar"]["yOffset"] = 2
	E.db["unitframe"]["units"]["focus"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["focus"]["health"]["text_format"] = "[health:percent]"
	E.db["unitframe"]["units"]["focus"]["power"]["height"] = 6
	E.db["unitframe"]["units"]["focus"]["power"]["xOffset"] = -2
	E.db["unitframe"]["units"]["focus"]["castbar"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["castbar"]["width"] = 100
	E.db["unitframe"]["units"]["focus"]["name"]["xOffset"] = 2
	E.db["unitframe"]["units"]["focus"]["name"]["yOffset"] = -22
	E.db["unitframe"]["units"]["focus"]["name"]["position"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["focus"]["width"] = 100
	E.db["unitframe"]["units"]["focus"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["focus"]["height"] = 30
	E.db["unitframe"]["units"]["focus"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["focus"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["buffs"]["attachTo"] = "DEBUFFS"
	E.db["unitframe"]["units"]["focus"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["buffs"]["priority"] = "Blacklist,Personal,PlayerBuffs"
	E.db["unitframe"]["units"]["focus"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["focus"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["focus"]["raidicon"]["attachTo"] = "CENTER"
	E.db["unitframe"]["units"]["focus"]["raidicon"]["size"] = 16
	E.db["unitframe"]["units"]["focus"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["focus"]["raidicon"]["yOffset"] = 2
	
	-- targettarget
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["targettarget"]["power"]["height"] = 6
	E.db["unitframe"]["units"]["targettarget"]["power"]["xOffset"] = -2
	E.db["unitframe"]["units"]["targettarget"]["threatStyle"] = "GLOW"
	E.db["unitframe"]["units"]["targettarget"]["width"] = 100
	E.db["unitframe"]["units"]["targettarget"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["targettarget"]["height"] = 30
	E.db["unitframe"]["units"]["targettarget"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["targettarget"]["health"]["text_format"] = "[health:percent]"
	E.db["unitframe"]["units"]["targettarget"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["targettarget"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["targettarget"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["targettarget"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["targettarget"]["name"]["xOffset"] = 2
	E.db["unitframe"]["units"]["targettarget"]["name"]["yOffset"] = -22
	E.db["unitframe"]["units"]["targettarget"]["name"]["position"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["targettarget"]["raidicon"]["attachTo"] = "CENTER"
	E.db["unitframe"]["units"]["targettarget"]["raidicon"]["size"] = 16
	E.db["unitframe"]["units"]["targettarget"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["targettarget"]["raidicon"]["yOffset"] = 2
	
	-- party
	E.db["unitframe"]["units"]["party"]["horizontalSpacing"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["party"]["debuffs"]["countFont"] = "Expressway"
	E.db["unitframe"]["units"]["party"]["debuffs"]["perrow"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["sizeOverride"] = 26
	E.db["unitframe"]["units"]["party"]["debuffs"]["yOffset"] = 2
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["party"]["growthDirection"] = "RIGHT_DOWN"
	E.db["unitframe"]["units"]["party"]["roleIcon"]["xOffset"] = 0
	E.db["unitframe"]["units"]["party"]["roleIcon"]["attachTo"] = "Frame"
	E.db["unitframe"]["units"]["party"]["roleIcon"]["yOffset"] = -19
	E.db["unitframe"]["units"]["party"]["power"]["xOffset"] = 2
	E.db["unitframe"]["units"]["party"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["power"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["party"]["health"]["text_format"] = "[health:deficit]"
	E.db["unitframe"]["units"]["party"]["health"]["position"] = "RIGHT"
	E.db["unitframe"]["units"]["party"]["width"] = 80
	E.db["unitframe"]["units"]["party"]["infoPanel"]["height"] = 18
	E.db["unitframe"]["units"]["party"]["name"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["party"]["name"]["yOffset"] = -17
	E.db["unitframe"]["units"]["party"]["name"]["text_format"] = "[difficultycolor][level] [namecolor][name:veryshort]"
	E.db["unitframe"]["units"]["party"]["name"]["position"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["party"]["height"] = 40
	E.db["unitframe"]["units"]["party"]["verticalSpacing"] = 0
	E.db["unitframe"]["units"]["party"]["raidicon"]["yOffset"] = 6
	
	-- raid
	E.db["unitframe"]["units"]["raid"]["customTexts"] = {}
	E.db["unitframe"]["units"]["raid"]["customTexts"]["Na"] = {} 
	
	
	E.db["unitframe"]["units"]["raid"]["horizontalSpacing"] = 2
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["fontSize"] = 12
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["size"] = 22
	E.db["unitframe"]["units"]["raid"]["growthDirection"] = "RIGHT_DOWN"
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["xOffset"] = 2
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["attachTo"] = "Frame"
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["infoPanel"]["height"] = 18
	E.db["unitframe"]["units"]["raid"]["name"]["text_format"] = "[namecolor][name:veryshort]"
	E.db["unitframe"]["units"]["raid"]["height"] = 40
	E.db["unitframe"]["units"]["raid"]["verticalSpacing"] = 2
	
	-- raid 40
	E.db["unitframe"]["units"]["raid40"]["customTexts"] = {}
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["Na"] = {} 


	E.db["unitframe"]["units"]["raid40"]["horizontalSpacing"] = -1
	E.db["unitframe"]["units"]["raid40"]["debuffs"]["priority"] = "Blacklist,Boss,RaidDebuffs,CCDebuffs,Dispellable"
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["fontSize"] = 12
	E.db["unitframe"]["units"]["raid40"]["groupSpacing"] = 8
	E.db["unitframe"]["units"]["raid40"]["power"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["width"] = 77
	E.db["unitframe"]["units"]["raid40"]["infoPanel"]["height"] = 18
	E.db["unitframe"]["units"]["raid40"]["name"]["text_format"] = "[namecolor][name:veryshort]"
	E.db["unitframe"]["units"]["raid40"]["height"] = 40
	E.db["unitframe"]["units"]["raid40"]["verticalSpacing"] = -1
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["attachTo"] = "Frame"
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["xOffset"] = 2
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["yOffset"] = 0
	
	-- Boss
	E.db["unitframe"]["units"]["boss"]["customTexts"] = {}
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"] = {}
	
	E.db["unitframe"]["units"]["boss"]["debuffs"]["anchorPoint"] = "RIGHT"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["xOffset"] = 5
	E.db["unitframe"]["units"]["boss"]["debuffs"]["perrow"] = 4
	E.db["unitframe"]["units"]["boss"]["debuffs"]["sizeOverride"] = 30
	E.db["unitframe"]["units"]["boss"]["debuffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["text_format"] = "[difficultycolor][level][shortclassification] [namecolor][name:long]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["yOffset"] = 26
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["xOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["customTexts"]["Na"]["size"] = 16
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconYOffset"] = 14
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconXOffset"] = 5
	E.db["unitframe"]["units"]["boss"]["castbar"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconAttachedTo"] = "Castbar"
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconSize"] = 50
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconPosition"] = "RIGHT"
	E.db["unitframe"]["units"]["boss"]["castbar"]["width"] = 200
	E.db["unitframe"]["units"]["boss"]["width"] = 200
	E.db["unitframe"]["units"]["boss"]["name"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["boss"]["name"]["yOffset"] = 17
	E.db["unitframe"]["units"]["boss"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["name"]["position"] = "TOPLEFT"
	E.db["unitframe"]["units"]["boss"]["spacing"] = 45
	E.db["unitframe"]["units"]["boss"]["height"] = 30
	E.db["unitframe"]["units"]["boss"]["buffs"]["xOffset"] = -5
	E.db["unitframe"]["units"]["boss"]["buffs"]["sizeOverride"] = 30
	E.db["unitframe"]["units"]["boss"]["buffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["boss"]["buffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["health"]["text_format"] = "[health:current] [namecolor]|| ||cfff2f2f2[health:percent]"
	E.db["unitframe"]["units"]["boss"]["health"]["position"] = "RIGHT"
	
	-- Arena
	E.db["unitframe"]["units"]["arena"]["customTexts"] = {}
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"] = {}
	
	E.db["unitframe"]["units"]["arena"]["debuffs"]["anchorPoint"] = "RIGHT"
	E.db["unitframe"]["units"]["arena"]["debuffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["arena"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["arena"]["debuffs"]["xOffset"] = 5
	E.db["unitframe"]["units"]["arena"]["debuffs"]["perrow"] = 4
	E.db["unitframe"]["units"]["arena"]["debuffs"]["sizeOverride"] = 30
	E.db["unitframe"]["units"]["arena"]["debuffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["spacing"] = 45
	E.db["unitframe"]["units"]["arena"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["enable"] = true
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["text_format"] = "[difficultycolor][level] [namecolor][name:long]"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["yOffset"] = 26
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["font"] = "Florence Sans"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["xOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["customTexts"]["Na"]["size"] = 16
	E.db["unitframe"]["units"]["arena"]["health"]["xOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["health"]["text_format"] = "[health:current] [namecolor]|| ||cfff2f2f2[health:percent]"
	E.db["unitframe"]["units"]["arena"]["health"]["position"] = "RIGHT"
	E.db["unitframe"]["units"]["arena"]["width"] = 200
	E.db["unitframe"]["units"]["arena"]["infoPanel"]["height"] = 16
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconYOffset"] = 14
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconXOffset"] = 5
	E.db["unitframe"]["units"]["arena"]["castbar"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconAttachedTo"] = "Castbar"
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconSize"] = 50
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconPosition"] = "RIGHT"
	E.db["unitframe"]["units"]["arena"]["castbar"]["width"] = 200
	E.db["unitframe"]["units"]["arena"]["name"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["arena"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["arena"]["name"]["yOffset"] = 17
	E.db["unitframe"]["units"]["arena"]["portrait"]["camDistanceScale"] = 1
	E.db["unitframe"]["units"]["arena"]["portrait"]["width"] = 35
	E.db["unitframe"]["units"]["arena"]["height"] = 30
	E.db["unitframe"]["units"]["arena"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["arena"]["buffs"]["countFont"] = "Florence Sans"
	E.db["unitframe"]["units"]["arena"]["buffs"]["xOffset"] = -5
	E.db["unitframe"]["units"]["arena"]["buffs"]["sizeOverride"] = 30
	E.db["unitframe"]["units"]["arena"]["buffs"]["yOffset"] = 0

	
	-- Tank
	E.db["unitframe"]["units"]["tank"]["targetsGroup"]["width"] = 100
	E.db["unitframe"]["units"]["tank"]["width"] = 175
	E.db["unitframe"]["units"]["tank"]["verticalSpacing"] = 25
	E.db["unitframe"]["units"]["tank"]["name"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["tank"]["name"]["position"] = "TOPLEFT"
	E.db["unitframe"]["units"]["tank"]["name"]["xOffset"] = -2
	E.db["unitframe"]["units"]["tank"]["name"]["text_format"] = "[name:medium]"
	E.db["unitframe"]["units"]["tank"]["name"]["yOffset"] = 17
	E.db["unitframe"]["units"]["tank"]["height"] = 30

	
	-- Assist
	E.db["unitframe"]["units"]["assist"]["targetsGroup"]["width"] = 100
	E.db["unitframe"]["units"]["assist"]["width"] = 175
	E.db["unitframe"]["units"]["assist"]["name"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["assist"]["name"]["position"] = "TOPLEFT"
	E.db["unitframe"]["units"]["assist"]["name"]["xOffset"] = -2
	E.db["unitframe"]["units"]["assist"]["name"]["text_format"] = "[name:medium]"
	E.db["unitframe"]["units"]["assist"]["name"]["yOffset"] = 17
	E.db["unitframe"]["units"]["assist"]["verticalSpacing"] = 25
	E.db["unitframe"]["units"]["assist"]["height"] = 30

	
	-- Movers
	if E.db["movers"] == nil then E.db["movers"] = {} end
	E.db["movers"]["ElvUF_PlayerCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,-300,293"
	E.db["movers"]["ElvUF_RaidMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,34"
	E.db["movers"]["TargetPowerBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-557,61"
	E.db["movers"]["ElvUF_RaidpetMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,737"
	E.db["movers"]["ElvUF_FocusMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,534,380"
	E.db["movers"]["ElvUF_PetMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,642,260"
	E.db["movers"]["ElvUF_TargetCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,300,293"
	E.db["movers"]["ElvUF_AssistMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,296,994"
	E.db["movers"]["ElvUF_TankMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,296,1060"
	E.db["movers"]["BossHeaderMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-413,-324"
	E.db["movers"]["ElvUF_PlayerMover"] = "BOTTOM,ElvUIParent,BOTTOM,-300,316"
	E.db["movers"]["ElvUF_TargetTargetMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-642,260"
	E.db["movers"]["ElvUF_PartyMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,160"
	E.db["movers"]["ElvUF_TargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,300,316"
	E.db["movers"]["ElvUF_Raid40Mover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,239"
	E.db["movers"]["PlayerPowerBarMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,557,61"
	E.db["movers"]["ArenaHeaderMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-413,-324"
	
end

PluginInstallStepComplete.message = RetroUI.Title..L['Unitframes Set']
	PluginInstallStepComplete:Show()
	E:UpdateAll(true)
end

local function SetupActionbars(layout)
	-- Actionbars
	E.db["actionbar"]["lockActionBars"] = true
	
	if layout == 'v1' then
		E.db.actionbars = nil
		
		E.db["actionbar"]["bar3"]["inheritGlobalFade"] = true
		E.db["actionbar"]["bar3"]["flyoutDirection"] = "UP"
		E.db["actionbar"]["bar3"]["buttons"] = 11
		E.db["actionbar"]["bar3"]["buttonsPerRow"] = 12
		E.db["actionbar"]["bar3"]["alpha"] = 0.75
		E.db["actionbar"]["bar3"]["point"] = "TOPLEFT"
		E.db["actionbar"]["fontSize"] = 12
		E.db["actionbar"]["globalFadeAlpha"] = 0.75
		E.db["actionbar"]["fontOutline"] = "OUTLINE"
		E.db["actionbar"]["microbar"]["enabled"] = true
		E.db["actionbar"]["microbar"]["buttonSpacing"] = 4
		E.db["actionbar"]["microbar"]["mouseover"] = true
		E.db["actionbar"]["microbar"]["buttonSize"] = 18
		E.db["actionbar"]["bar2"]["enabled"] = true
		E.db["actionbar"]["bar2"]["inheritGlobalFade"] = true
		E.db["actionbar"]["bar2"]["buttons"] = 10
		E.db["actionbar"]["bar2"]["alpha"] = 0.75
		E.db["actionbar"]["bar1"]["inheritGlobalFade"] = true
		E.db["actionbar"]["bar1"]["point"] = "TOPLEFT"
		E.db["actionbar"]["bar1"]["buttons"] = 10
		E.db["actionbar"]["bar1"]["alpha"] = 0.75
		E.db["actionbar"]["bar5"]["enabled"] = false
		E.db["actionbar"]["bar5"]["inheritGlobalFade"] = true
		E.db["actionbar"]["bar5"]["flyoutDirection"] = "UP"
		E.db["actionbar"]["bar5"]["buttons"] = 11
		E.db["actionbar"]["bar5"]["buttonsPerRow"] = 12
		E.db["actionbar"]["bar5"]["alpha"] = 0.75
		E.db["actionbar"]["bar5"]["point"] = "TOPLEFT"
		E.db["actionbar"]["font"] = "Florence Sans"
		E.db["actionbar"]["stanceBar"]["inheritGlobalFade"] = true
		E.db["actionbar"]["stanceBar"]["point"] = "BOTTOMLEFT"
		E.db["actionbar"]["stanceBar"]["buttons"] = 5
		E.db["actionbar"]["stanceBar"]["buttonsPerRow"] = 8
		E.db["actionbar"]["stanceBar"]["buttonsize"] = 24
		E.db["actionbar"]["stanceBar"]["alpha"] = 0.75
		E.db["actionbar"]["barPet"]["inheritGlobalFade"] = true
		E.db["actionbar"]["barPet"]["point"] = "TOPLEFT"
		E.db["actionbar"]["barPet"]["buttonsPerRow"] = 10
		E.db["actionbar"]["barPet"]["backdrop"] = false
		E.db["actionbar"]["barPet"]["buttonsize"] = 24
		E.db["actionbar"]["bar4"]["flyoutDirection"] = "UP"
		E.db["actionbar"]["bar4"]["inheritGlobalFade"] = true
		E.db["actionbar"]["bar4"]["point"] = "TOPLEFT"
		E.db["actionbar"]["bar4"]["buttons"] = 11
		E.db["actionbar"]["bar4"]["buttonsPerRow"] = 12
		E.db["actionbar"]["bar4"]["alpha"] = 0.75
		E.db["actionbar"]["bar4"]["backdrop"] = false
		E.db["actionbar"]["zoneActionButton"]["clean"] = true
		E.db["actionbar"]["extraActionButton"]["clean"] = true

		-- Movers
		if E.db["movers"] == nil then E.db["movers"] = {} end
		E.db["movers"]["ElvAB_1"] = "BOTTOM,ElvUIParent,BOTTOM,0,281"
		E.db["movers"]["ElvAB_2"] = "BOTTOM,ElvUIParent,BOTTOM,0,247"
		E.db["movers"]["ElvAB_3"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,203"
		E.db["movers"]["ElvAB_4"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,237"
		E.db["movers"]["ElvAB_5"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,271"
		E.db["movers"]["PetAB"] = "BOTTOM,ElvUIParent,BOTTOM,0,315"
		E.db["movers"]["MicrobarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-10,273"
		E.db["movers"]["ShiftAB"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,204"
	end
PluginInstallStepComplete.message = RetroUI.Title..L['Actionbars Set']
	PluginInstallStepComplete:Show()
	E:UpdateAll(true)
end
			
	
local addonNames = {}
local profilesFailed = format('|cff00c0fa%s |r', L["RetroUI didn't find any supported addons for profile creation"])
	
local function SetupAddons()	
	--	Details - Settings
	if IsAddOnLoaded("Details") then
		RetroUI:LoadDetailsProfile()
		tinsert(addonNames, 'Details')
	end	
	
	-- MikScrollingBattleText
	if IsAddOnLoaded('MikScrollingBattleText') then
		RetroUI:LoadMSBTProfile()
		tinsert(addonNames, "Mik's Scrolling Battle Text")
	end
	
	-- Deadly Boss Mods
	if IsAddOnLoaded("DBM-Core") then
		RetroUI:LoadDBMProfile()
		tinsert(addonNames, 'Deadly Boss Mods')	
	end
	
	--	BigWigs - Settings
	if IsAddOnLoaded("BigWigs") then
		RetroUI:LoadBigWigsProfile()
		tinsert(addonNames, 'BigWigs')
	end

	--	AddOnSkins - Settings
	if IsAddOnLoaded("AddOnSkins") then
		RetroUI:LoadAddOnSkinsProfile()
		tinsert(addonNames, 'AddOnSkins')
	end
	--	Skada - Settings
	if IsAddOnLoaded("Skada") then
		RetroUI:LoadSkadaProfile()
		tinsert(addonNames, 'Skada')
	end
	if checkTable(addonNames) ~= nil then
		local profileString = format('|cfffff400%s |r', L['RetroUI successfully created and applied profile(s) for:']..'\n')

		tsort(addonNames, function(a, b) return a < b end)
		local names = tconcat(addonNames, ", ")
		profileString = profileString..names

		PluginInstallFrame.Desc4:SetText(profileString..'.')
	else
		PluginInstallFrame.Desc4:SetText(profilesFailed)
	end

	PluginInstallStepComplete.message = RetroUI.Title..L['Addons Set']
	PluginInstallStepComplete:Show()
	twipe(addonNames)
	E:UpdateAll(true)
	
end

local function InstallComplete()
	E.private.RetroUI.install_complete = RetroUI.Version
		--Set a variable tracking the version of the addon when layout was installed
	E["global"][MyPluginName].profile_name = ElvUI[1].data:GetCurrentProfile()
	E.db[MyPluginName].install_version = RetroUI.Version
	if GetCVarBool("Sound_EnableMusic") then
		StopMusic()
	end

	ReloadUI()

end

RetroUI.RetroUIInstallTable = {
	Name = "|cff9482c9RetroUI UI|r",
	Title = L["|cff9482c9RetroUI UI|r Installation"],
	tutorialImage = [[Interface\AddOns\ElvUI_RetroUI\media\textures\RetroUI]],
	Pages = {
		[1] = function()
			PluginInstallFrame.SubTitle:SetFormattedText(L["Welcome to RetroUI UI |cff00c0faVersion|r %s, for ElvUI %s."], RetroUI.Version, E.version)
			PluginInstallFrame.Desc1:SetText(L["By pressing the Continue button, RetroUI UI will be applied in your current ElvUI installation.\r|cffff8000 TIP: If you apply the changes in a new profile, you can always change back if you don't like the result.|r"])
			PluginInstallFrame.Desc2:SetText(L["Please press the continue button to go onto the next step."])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() InstallComplete() end)
			PluginInstallFrame.Option1:SetText(L["Skip Process"])
		end,
		[2] = function()
			PluginInstallFrame.SubTitle:SetText("Profiles")
			PluginInstallFrame.Desc1:SetText("You can either create a new profile to install RetroUI onto or you can apply RetroUI settings to your current profile")
			PluginInstallFrame.Desc3:SetText("Your currently active ElvUI profile is: |cffc41f3b"..ElvUI[1].data:GetCurrentProfile().."|r")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NewProfile(false) end)
			PluginInstallFrame.Option1:SetText("Use Current")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() NewProfile(true, "RetroUI") end)
			PluginInstallFrame.Option2:SetText("Create New")
		
			PluginInstallFrame.SubTitle:SetText("Profiles")
			PluginInstallFrame.Desc1:SetText("Press \"Update Current\" to update your current profile with the new RetroUI changes.")
			PluginInstallFrame.Desc2:SetText("If you'd like to check out what the changes are, without overwriting your current settings, you can press \"Create New\"")
			PluginInstallFrame.Desc3:SetText("Your currently active ElvUI profile is: |cffc41f3b"..ElvUI[1].data:GetCurrentProfile().."|r")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NewProfile(false) end)
			PluginInstallFrame.Option1:SetText("Update Current")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() NewProfile(true, "RetroUI-Update") end)
			PluginInstallFrame.Option2:SetText("Create New")
		end,
		[3] = function()
			PluginInstallFrame.SubTitle:SetText(L["Chat"])
			PluginInstallFrame.Desc1:SetText(L["This is the part where we set up your chat/colors."])
			PluginInstallFrame.Desc2:SetText(L["This button will set up your chat windows. Skip this if chat is already set up."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupChat() end)
			PluginInstallFrame.Option1:SetText(L["SET CHAT"])
			end,
		[4] = function()
			PluginInstallFrame.SubTitle:SetText(L["General Layout of RetroUI"])
			PluginInstallFrame.Desc1:SetText(L["This is the recommended base layout for RetroUI."])
			PluginInstallFrame.Desc2:SetText(L["This will set some general settings for before the layout installation of |cff9482c9RetroUI UI|r."])
			PluginInstallFrame.Desc3:SetFormattedText(L["Importance: |cffFF0000High|r"])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupLayout(); end) 
			PluginInstallFrame.Option1:SetText("SET LAYOUT")
		end,
		[5] = function()
			PluginInstallFrame.SubTitle:SetText(L["Unitframe Layouts for RetroUIUI"])
			PluginInstallFrame.Desc1:SetText(L["This Installs Unitframe Layouts based on your Specialization."])
			PluginInstallFrame.Desc2:SetText(L["The healing frames are currently a work in progress."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffFF0000High|r"])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupUnitframes('v1'); end) 
			PluginInstallFrame.Option1:SetText("SET UNITFRAMES")
			end,
		[6] = function()
			PluginInstallFrame.SubTitle:SetText(L["Actionbar Layout for RetroUIUI"])
			PluginInstallFrame.Desc1:SetText(L["This is the standard layout for the RetroUIUI"])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffFF0000High|r"])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupActionbars('v1'); end) 
			PluginInstallFrame.Option1:SetText("SET ACTIONBARS")
			
			end,
		[7] = function()
			PluginInstallFrame.SubTitle:SetText(L["Addon Profiles"])
			PluginInstallFrame.Desc1:SetText(L["Applies Settings based on the Addons Selected"])
			PluginInstallFrame.Desc2:SetText()
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffD3CF00High|r"])
			
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupAddons() end)
			PluginInstallFrame.Option1:SetText("SET ADDONS")
			end,
		[8] = function()
			PluginInstallFrame.SubTitle:SetText(L["Installation Complete"])
			PluginInstallFrame.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
			PluginInstallFrame.Option1:SetText(L["FINISH"])
			end,
		},
	
	StepTitles = {
		 [1] = START,
		 [2] = L["Profile"],
		 [3] = L["Chat Setup"],
		 [4] = L["General Layout"],
		 [5] = L["Unitframes"],
		 [6] = L["Actionbars"],
		 [7] = L["Addon Profiles"],
		 [8] = L["Installation Complete"],
	},
	StepTitlesColor = {1, 1, 1},
	StepTitlesColorSelected = {0, 179/255, 1},
	StepTitleWidth = 200,
	StepTitleButtonWidth = 180,
	StepTitleTextJustification = "RIGHT",

}