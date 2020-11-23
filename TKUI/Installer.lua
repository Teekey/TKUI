-- Don't worry about this
local addon, ns = ...
local Version = GetAddOnMetadata(addon, "Version")

-- Cache Lua / WoW API
local format = string.format
local GetCVarBool = GetCVarBool
local ReloadUI = ReloadUI
local StopMusic = StopMusic

-- Change this line and use a unique name for your plugin.
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"

-- Create references to ElvUI internals
local E, L, V, P, G = unpack(ElvUI)

-- Create reference to LibElvUIPlugin
local EP = LibStub("LibElvUIPlugin-1.0")

-- Create a new ElvUI module so ElvUI can handle initialization when ready
local mod = E:NewModule(TKUIPlugin, "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

local NP = E:GetModule("NamePlates")

-- Runs for the step questioning the user if they want a new ElvUI profile
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
		  self.editBox:SetText("TKUI"); --default text in the editbox
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

local function SetupCVAR()
SetCVar("nameplateMaxDistance", 100)
SetCVar("nameplateSelectedScale", 1.2)
SetCVar("nameplateOccludedAlphaMult", 0.4)
end



-- This function will hold your layout settings
local function SetupLayout()
	local screenHeight = GetScreenHeight()
	local playerFrame = (GetScreenHeight()/4)
	local partyFrame = (GetScreenHeight()/2)
	local buttonFrame = (GetScreenHeight()/6)
	local localizedClass, englishClass, classIndex = UnitClass("player");
	local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
	-- CUSTOM TEXTS
	if not E.db.unitframe.units.player.customTexts then
			E.db.unitframe.units.player.customTexts = {}
	end
	if E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.target.customTexts then
			E.db.unitframe.units.target.customTexts = {}
	end
	if E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"] = {}
	end
	if E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.targettarget.customTexts then
			E.db.unitframe.units.targettarget.customTexts = {}
	end
	if E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"] = {}
	end
	if not E.db.unitframe.units.focus.customTexts then
			E.db.unitframe.units.focus.customTexts = {}
	end
	if E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"] = {}
	end
	if E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.focustarget.customTexts then
			E.db.unitframe.units.focustarget.customTexts = {}
	end
	if E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"] = {}
	end
	if not E.db.unitframe.units.party.customTexts then
			E.db.unitframe.units.party.customTexts = {}
	end
	if E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"] == nil then
			E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"] = {}
	end
	if E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"] == nil then
			E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"] = {}
	end
	if E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.raid.customTexts then
			E.db.unitframe.units.raid.customTexts = {}
	end
	if E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"] == nil then
			E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"] = {}
	end
	if E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"] == nil then
			E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"] = {}
	end
	if E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.raid40.customTexts then
			E.db.unitframe.units.raid40.customTexts = {}
	end
	if E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"] == nil then
			E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"] = {}
	end
	if E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"] == nil then
			E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"] = {}
	end
	if E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"] == nil then
			E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"] = {}
	end
	if not E.db.unitframe.units.boss.customTexts then
			E.db.unitframe.units.boss.customTexts = {}
	end
	if E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"] == nil then
			E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"] = {}
	end
	if E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"] == nil then
			E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"] = {}
	end
	if E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"] == nil then
			E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"] = {}
	end
  -- -- Fix Movers ??
  if E.db["movers"] == nil then
      E.db["movers"] = {}
  end
--   E.db["unitframe"]["units"]["target"]["orientation"] = "RIGHT"
  -- PRIVATEDB ------------------------------------------------------------------
	E.private["general"]["chatBubbleFont"] = "font"
	E.private["general"]["chatBubbleFontOutline"] = "OUTLINE"
	E.private["general"]["chatBubbleFontSize"] = 10
	E.private["general"]["chatBubbles"] = "nobackdrop"
	E.private["general"]["dmgfont"] = "font"
	E.private["general"]["glossTex"] = "ElvUI Blank"
	E.private["general"]["loot"] = false
	E.private["general"]["minimap"]["hideClassHallReport"] = true
	E.private["general"]["namefont"] = "font"
	E.private["general"]["normTex"] = "ElvUI Blank"
	E.private["general"]["totemBar"] = false
	E.private["bags"]["enable"] = false
	-- MASQUE ------------------------------------------------------------------
	E.private["actionbar"]["masque"]["actionbars"] = true
	E.private["actionbar"]["masque"]["petBar"] = true
	E.private["actionbar"]["masque"]["stanceBar"] = true
	E.private["auras"]["masque"]["buffs"] = true
	E.private["auras"]["masque"]["debuffs"] = true
  -- GLOBAL ------------------------------------------------------------------
	E.global["general"]["commandBarSetting"] = "DISABLED"
	E.global["general"]["fadeMapWhenMoving"] = false
	E.global["general"]["mapAlphaWhenMoving"] = 0.3
  -- DATATEXT ------------------------------------------------------------------
	E.db["datatexts"]["font"] = "font"
	E.db["datatexts"]["fontSize"] = 14
	E.db["datatexts"]["panels"]["LeftChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["MinimapPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["RightChatDataPanel"]["enable"] = false
  -- NAMEPLATES -------------------------------------------------------------
  E.db["v11NamePlateReset"] = true
	E.db["nameplates"]["colors"]["reactions"]["bad"]["b"] = 0.25098039215686
	E.db["nameplates"]["colors"]["reactions"]["bad"]["g"] = 0.25098039215686
	E.db["nameplates"]["colors"]["reactions"]["bad"]["r"] = 0.78039215686275
	E.db["nameplates"]["colors"]["selection"][0]["b"] = 0.17647058823529
	E.db["nameplates"]["colors"]["selection"][0]["g"] = 0.17647058823529
	E.db["nameplates"]["colors"]["selection"][3]["g"] = 0.70588235294118
	E.db["nameplates"]["colors"]["threat"]["badColor"]["b"] = 0.17647058823529
	E.db["nameplates"]["colors"]["threat"]["badColor"]["g"] = 0.17647058823529
	E.db["nameplates"]["colors"]["threat"]["goodColor"]["g"] = 0.70588235294118
	E.db["nameplates"]["colors"]["threat"]["offTankColorBadTransition"]["b"] = 0.27058823529412
	E.db["nameplates"]["colors"]["threat"]["offTankColorBadTransition"]["g"] = 0.43137254901961
	E.db["nameplates"]["colors"]["threat"]["offTankColorBadTransition"]["r"] = 0.70980392156863
	E.db["nameplates"]["colors"]["threat"]["offTankColorGoodTransition"]["b"] = 0.63137254901961
	E.db["nameplates"]["colors"]["threat"]["offTankColorGoodTransition"]["g"] = 0.45098039215686
	E.db["nameplates"]["colors"]["threat"]["offTankColorGoodTransition"]["r"] = 0.30980392156863
	E.db["nameplates"]["cooldown"]["fonts"]["enable"] = true
	E.db["nameplates"]["cooldown"]["fonts"]["font"] = "m6x11"
	E.db["nameplates"]["cooldown"]["fonts"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["nameplates"]["font"] = "font"
	E.db["nameplates"]["highlight"] = false
	E.db["nameplates"]["plateSize"]["friendlyHeight"] = 25
	E.db["nameplates"]["plateSize"]["friendlyWidth"] = 125
	E.db["nameplates"]["smoothbars"] = true
	E.db["nameplates"]["statusbar"] = "ElvUI Blank"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["buffs"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["font"] = "font"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["fontSize"] = 12
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["height"] = 18
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["iconPosition"] = "LEFT"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["iconSize"] = 18
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["textPosition"] = "ONBAR"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["timeToHold"] = 0.5
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["width"] = 141
	E.db["nameplates"]["units"]["ENEMY_NPC"]["castbar"]["yOffset"] = -18
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["countFont"] = "font"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["countPosition"] = "CENTER"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["growthX"] = "RIGHT"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["size"] = 16
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["xOffset"] = 39
	E.db["nameplates"]["units"]["ENEMY_NPC"]["debuffs"]["yOffset"] = -8
	E.db["nameplates"]["units"]["ENEMY_NPC"]["eliteIcon"]["position"] = "TOPLEFT"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["eliteIcon"]["xOffset"] = 0
	E.db["nameplates"]["units"]["ENEMY_NPC"]["health"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_NPC"]["health"]["text"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_NPC"]["level"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["font"] = "font"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["fontSize"] = 14
	E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["format"] = "[TKUI:RaidMarker][TKUI:EnemyNPC]"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["position"] = "CENTER"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["name"]["yOffset"] = 0
	E.db["nameplates"]["units"]["ENEMY_NPC"]["questIcon"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_NPC"]["questIcon"]["position"] = "LEFT"
	E.db["nameplates"]["units"]["ENEMY_NPC"]["raidTargetIndicator"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["maxDuration"] = 0
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["buffs"]["priority"] = "Blacklist,RaidBuffsElvUI,Dispellable,blockNoDuration,PlayerBuffs,TurtleBuffs,CastByUnit"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["font"] = "font"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["fontSize"] = 12
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["height"] = 18
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["iconPosition"] = "LEFT"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["iconSize"] = 18
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["textPosition"] = "ONBAR"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["timeToHold"] = 0.5
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["width"] = 141
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["castbar"]["yOffset"] = -18
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["countFont"] = "font"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["countPosition"] = "CENTER"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["growthX"] = "RIGHT"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["priority"] = "Blacklist,Personal,CCDebuffs"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["size"] = 10
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["xOffset"] = 39
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["debuffs"]["yOffset"] = -8
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["health"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["health"]["text"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["level"]["format"] = "[difficultycolor][level][shortclassification]"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["font"] = "font"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["fontSize"] = 14
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["format"] = "[TKUI:RaidMarker][TKUI:EnemyPlayer"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["position"] = "CENTER"
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["name"]["yOffset"] = 0
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["power"]["displayAltPower"] = true
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["raidTargetIndicator"]["enable"] = false
	E.db["nameplates"]["units"]["ENEMY_PLAYER"]["title"]["format"] = "[npctitle]"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["maxDuration"] = 300
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["buffs"]["priority"] = "Blacklist,blockNoDuration,Personal,TurtleBuffs,PlayerBuffs"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["castbar"]["yOffset"] = -19
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["debuffs"]["priority"] = "Blacklist,blockNoDuration,Personal,Boss,CCDebuffs,RaidDebuffs,Dispellable"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["font"] = "font"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["fontSize"] = 12
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["format"] = "[perhp]"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["parent"] = "Health"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["health"]["text"]["position"] = "TOPRIGHT"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["level"]["format"] = "[difficultycolor][level]"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["font"] = "font"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["fontSize"] = 14
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["format"] = "[TKUI:RaidMarker][TKUI:FriendlyNPC]"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["position"] = "CENTER"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["name"]["yOffset"] = 0
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["raidTargetIndicator"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["title"]["enable"] = true
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["title"]["font"] = "font"
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["title"]["fontSize"] = 10
	E.db["nameplates"]["units"]["FRIENDLY_NPC"]["title"]["position"] = "CENTER"
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["buffs"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["height"] = 13
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["castbar"]["textPosition"] = "ONBAR"
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["debuffs"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["health"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["level"]["fontSize"] = 14
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["font"] = "font"
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["fontSize"] = 14
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["format"] = "[TKUI:RaidMarker][TKUI:FriendlyPlayer]"
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["name"]["position"] = "CENTER"
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["nameOnly"] = true
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["raidTargetIndicator"]["enable"] = false
	E.db["nameplates"]["units"]["FRIENDLY_PLAYER"]["showTitle"] = false
	E.db["nameplates"]["units"]["PLAYER"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["nameplates"]["units"]["PLAYER"]["debuffs"]["growthX"] = "RIGHT"
	E.db["nameplates"]["units"]["PLAYER"]["power"]["enable"] = false
	E.db["nameplates"]["units"]["PLAYER"]["power"]["height"] = 4
	E.db["nameplates"]["units"]["PLAYER"]["raidTargetIndicator"]["enable"] = false
	E.db["nameplates"]["units"]["TARGET"]["classpower"]["enable"] = true
	E.db["nameplates"]["units"]["TARGET"]["classpower"]["height"] = 4
	E.db["nameplates"]["units"]["TARGET"]["classpower"]["width"] = 50
	E.db["nameplates"]["units"]["TARGET"]["classpower"]["yOffset"] = -12
	E.db["nameplates"]["units"]["TARGET"]["glowStyle"] = "none"
	E.db["nameplates"]["visibility"]["enemy"]["guardians"] = true
	E.db["nameplates"]["visibility"]["enemy"]["minions"] = true
	E.db["nameplates"]["visibility"]["enemy"]["pets"] = true
	E.db["nameplates"]["visibility"]["enemy"]["totems"] = true
	E.db["nameplates"]["visibility"]["friendly"]["guardians"] = true
	E.db["nameplates"]["visibility"]["friendly"]["minions"] = true
	E.db["nameplates"]["visibility"]["friendly"]["pets"] = true
	E.db["nameplates"]["visibility"]["friendly"]["totems"] = true
  -- BAGS --------------------------------------------------------------
	E.db["bags"]["countFont"] = "font"
	E.db["bags"]["countFontSize"] = 14
	E.db["bags"]["itemLevelFont"] = "font"
	E.db["bags"]["itemLevelFontSize"] = 14
	E.db["bags"]["vendorGrays"]["enable"] = true
  -- COOLDOWN --------------------------------------------------------------------
  -- CHAT -------------------------------------------------------------------------
	E.db["chat"]["editBoxPosition"] = "ABOVE_CHAT"
	E.db["chat"]["font"] = "font"
	E.db["chat"]["fontOutline"] = "OUTLINE"
	E.db["chat"]["fontSize"] = 14
	E.db["chat"]["keywords"] = "%MYNAME%"
	E.db["chat"]["panelBackdrop"] = "HIDEBOTH"
	E.db["chat"]["panelColor"]["a"] = 0.5
	E.db["chat"]["panelColor"]["b"] = 0.058823529411765
	E.db["chat"]["panelColor"]["g"] = 0.058823529411765
	E.db["chat"]["panelColor"]["r"] = 0.058823529411765
	E.db["chat"]["separateSizes"] = true
	if screenHeight < 1440 then
	E.db["chat"]["panelHeight"] = 250
	E.db["chat"]["panelHeightRight"] = 250
	E.db["chat"]["panelWidth"] = 500
	E.db["chat"]["panelWidthRight"] = 250
	else
	E.db["chat"]["panelHeight"] = 300
	E.db["chat"]["panelHeightRight"] = 300
	E.db["chat"]["panelWidth"] = 600
	E.db["chat"]["panelWidthRight"] = 300
	end
	E.db["chat"]["tabFont"] = "font"
	E.db["chat"]["tabFontOutline"] = "OUTLINE"
	E.db["chat"]["tabFontSize"] = 14
	E.db["chat"]["timeStampFormat"] = "%H:%M "
  -- DATABARS ------------------------------------------
	E.db["databars"]["azerite"]["enable"] = false
	E.db["databars"]["azerite"]["width"] = 201
	E.db["databars"]["experience"]["enable"] = false
	E.db["databars"]["experience"]["font"] = "font"
	E.db["databars"]["experience"]["height"] = 11
	E.db["databars"]["experience"]["width"] = 200
	E.db["databars"]["honor"]["enable"] = false
	E.db["databars"]["threat"]["enable"] = false
  -- GENERAL---------------------------------------------
	E.db["general"]["afk"] = false
	E.db["general"]["altPowerBar"]["font"] = "font"
	E.db["general"]["altPowerBar"]["height"] = 5
	E.db["general"]["altPowerBar"]["statusBar"] = "ElvUI Blank"
	E.db["general"]["altPowerBar"]["width"] = 400
	E.db["general"]["autoRepair"] = "PLAYER"
	E.db["general"]["backdropcolor"]["b"] = 0.10196078431373
	E.db["general"]["backdropcolor"]["g"] = 0.10196078431373
	E.db["general"]["backdropcolor"]["r"] = 0.10196078431373
	E.db["general"]["backdropfadecolor"]["a"] = 0.5
	E.db["general"]["backdropfadecolor"]["b"] = 0.058823529411765
	E.db["general"]["backdropfadecolor"]["g"] = 0.058823529411765
	E.db["general"]["backdropfadecolor"]["r"] = 0.058823529411765
	E.db["general"]["bottomPanel"] = false
	E.db["general"]["decimalLength"] = 4
	E.db["general"]["font"] = "font"
	E.db["general"]["fontSize"] = 14
	E.db["general"]["itemLevel"]["itemLevelFont"] = "font"
	E.db["general"]["loginmessage"] = false
	E.db["general"]["minimap"]["icons"]["lfgEye"]["xOffset"] = 5
	E.db["general"]["minimap"]["icons"]["lfgEye"]["yOffset"] = -5
	E.db["general"]["minimap"]["icons"]["mail"]["scale"] = 1.5
	E.db["general"]["minimap"]["locationFont"] = "font"
	E.db["general"]["minimap"]["locationFontSize"] = 16
	E.db["general"]["minimap"]["resetZoom"]["enable"] = true
	E.db["general"]["minimap"]["resetZoom"]["time"] = 10
	if screenHeight < 1440 then
	E.db["general"]["minimap"]["size"] = 250
	else
	E.db["general"]["minimap"]["size"] = 300
	end
	E.db["general"]["smoothingAmount"] = 0.63
	E.db["general"]["totems"]["enable"] = false
	E.db["general"]["totems"]["growthDirection"] = "HORIZONTAL"
	E.db["general"]["totems"]["sortDirection"] = "DESCENDING"
	E.db["general"]["valuecolor"]["b"] = bPerc
	E.db["general"]["valuecolor"]["g"] = gPerc
	E.db["general"]["valuecolor"]["r"] = rPerc
  -- TOOLTIPS ---------------------------------------------------------------
	E.db["tooltip"]["colorAlpha"] = 0.5
	E.db["tooltip"]["cursorAnchor"] = true
	E.db["tooltip"]["font"] = "font"
	E.db["tooltip"]["fontOutline"] = "OUTLINE"
	E.db["tooltip"]["guildRanks"] = false
	E.db["tooltip"]["headerFontSize"] = 14
	E.db["tooltip"]["healthBar"]["font"] = "font"
	E.db["tooltip"]["healthBar"]["height"] = 1
	E.db["tooltip"]["healthBar"]["text"] = false
	E.db["tooltip"]["playerTitles"] = false
	E.db["tooltip"]["smallTextFontSize"] = 14
	E.db["tooltip"]["targetInfo"] = false
	E.db["tooltip"]["textFontSize"] = 14
	E.db["tooltip"]["visibility"]["combatOverride"] = "HIDE"
  -- AURAS -------------------------------------------------------------------
	E.db["auras"]["buffs"]["countFont"] = "font"
	E.db["auras"]["buffs"]["countFontOutline"] = "OUTLINE"
	E.db["auras"]["buffs"]["countFontSize"] = 16
	E.db["auras"]["buffs"]["countXOffset"] = 2
	E.db["auras"]["buffs"]["countYOffset"] = 4
	E.db["auras"]["buffs"]["growthDirection"] = "RIGHT_DOWN"
	E.db["auras"]["buffs"]["horizontalSpacing"] = 12
	E.db["auras"]["buffs"]["size"] = 46
	E.db["auras"]["buffs"]["sortDir"] = "+"
	E.db["auras"]["buffs"]["timeFont"] = "font"
	E.db["auras"]["buffs"]["timeFontOutline"] = "OUTLINE"
	E.db["auras"]["buffs"]["timeFontSize"] = 16
	E.db["auras"]["buffs"]["wrapAfter"] = 18
	E.db["auras"]["debuffs"]["countFont"] = "font"
	E.db["auras"]["debuffs"]["countFontOutline"] = "OUTLINE"
	E.db["auras"]["debuffs"]["countFontSize"] = 14
	E.db["auras"]["debuffs"]["growthDirection"] = "RIGHT_DOWN"
	E.db["auras"]["debuffs"]["horizontalSpacing"] = 11
	E.db["auras"]["debuffs"]["timeFont"] = "font"
	E.db["auras"]["debuffs"]["timeFontOutline"] = "OUTLINE"
	E.db["auras"]["debuffs"]["timeFontSize"] = 16
	E.db["auras"]["debuffs"]["timeYOffset"] = 21
	E.db["auras"]["debuffs"]["wrapAfter"] = 9
	E.db["auras"]["debuffs"]["size"] = 34
  -- ACTIONBARS ------------------------------------------------------
  -- Main Actionbar Bottom
  E.db["actionbar"]["bar1"]["enabled"] = true
  E.db["actionbar"]["bar1"]["buttons"] = 12
  E.db["actionbar"]["bar1"]["buttonsPerRow"] = 12
  E.db["actionbar"]["bar1"]["buttonspacing"] = 7
  E.db["actionbar"]["bar1"]["buttonsize"] = 26
  E.db["actionbar"]["bar1"]["backdropSpacing"] = 0
  E.db["actionbar"]["bar1"]["backdrop"] = false
  -- Main Actionbar Top
  E.db["actionbar"]["bar2"]["enabled"] = true
  E.db["actionbar"]["bar2"]["buttons"] = 12
  E.db["actionbar"]["bar2"]["buttonsPerRow"] = 12
  E.db["actionbar"]["bar2"]["buttonspacing"] = 7
  E.db["actionbar"]["bar2"]["buttonsize"] = 26
  E.db["actionbar"]["bar2"]["backdropSpacing"] = 0
  E.db["actionbar"]["bar2"]["backdrop"] = false
	-- Pet Bar
	E.db["actionbar"]["barPet"]["backdrop"] = false
	E.db["actionbar"]["barPet"]["buttonsPerRow"] = 10
	E.db["actionbar"]["barPet"]["buttonsize"] = 26
	E.db["actionbar"]["barPet"]["buttonspacing"] = 7
	E.db["actionbar"]["barPet"]["mouseover"] = true
  -- Bottom Actionbar
  E.db["actionbar"]["bar3"]["enabled"] = true
  E.db["actionbar"]["bar3"]["buttonsize"] = 26
  E.db["actionbar"]["bar3"]["backdrop"] = false
  E.db["actionbar"]["bar3"]["buttonspacing"] = 7
  E.db["actionbar"]["bar3"]["buttonsPerRow"] = 12
  E.db["actionbar"]["bar3"]["visibility"] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show; [combat] hide; show;"
  E.db["actionbar"]["bar3"]["mouseover"] = true
  -- Disabled Actionbars
	E.db["actionbar"]["bar4"]["enabled"] = false
  E.db["actionbar"]["bar5"]["enabled"] = false
  E.db["actionbar"]["bar6"]["enabled"] = false
  E.db["actionbar"]["bar7"]["enabled"] = false
  E.db["actionbar"]["bar8"]["enabled"] = false
  E.db["actionbar"]["bar9"]["enabled"] = false
  E.db["actionbar"]["bar10"]["enabled"] = false
  -- Actionbar Options from import
	E.db["actionbar"]["countTextYOffset"] = 0
	E.db["actionbar"]["desaturateOnCooldown"] = true
	E.db["actionbar"]["extraActionButton"]["clean"] = true
	E.db["actionbar"]["font"] = "font"
	E.db["actionbar"]["fontOutline"] = "OUTLINE"
	E.db["actionbar"]["fontSize"] = 12
	E.db["actionbar"]["hotkeytext"] = false
	E.db["actionbar"]["movementModifier"] = "CTRL"
	E.db["actionbar"]["stanceBar"]["enabled"] = false
	E.db["actionbar"]["transparent"] = true
	E.db["actionbar"]["zoneActionButton"]["clean"] = true
  --UNITFRAME ----------------------------------------------------------------
  E.db["unitframe"]["fontSize"] = 16
  E.db["unitframe"]["font"] = "font"
  --Player
	E.db["unitframe"]["units"]["player"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["RestIcon"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["aurabar"]["maxDuration"] = 300
	E.db["unitframe"]["units"]["player"]["buffs"]["attachTo"] = "HEALTH"
	E.db["unitframe"]["units"]["player"]["buffs"]["sizeOverride"] = 24
	E.db["unitframe"]["units"]["player"]["buffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["a"] = 0
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["b"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["g"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["r"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["useClassColor"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["useCustomBackdrop"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["height"] = 14
	E.db["unitframe"]["units"]["player"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["player"]["castbar"]["iconAttachedTo"] = "Castbar"
	E.db["unitframe"]["units"]["player"]["castbar"]["iconPosition"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["player"]["castbar"]["iconSize"] = 24
	E.db["unitframe"]["units"]["player"]["castbar"]["iconXOffset"] = 23
	E.db["unitframe"]["units"]["player"]["castbar"]["iconYOffset"] = -4
	E.db["unitframe"]["units"]["player"]["castbar"]["overlayOnFrame"] = "Health"
	E.db["unitframe"]["units"]["player"]["castbar"]["strataAndLevel"]["frameStrata"] = "BACKGROUND"
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["width"] = 400
	E.db["unitframe"]["units"]["player"]["castbar"]["xOffsetText"] = 24
	E.db["unitframe"]["units"]["player"]["castbar"]["xOffsetTime"] = 0
	E.db["unitframe"]["units"]["player"]["castbar"]["yOffsetText"] = -42
	E.db["unitframe"]["units"]["player"]["castbar"]["yOffsetTime"] = -42
	E.db["unitframe"]["units"]["player"]["classbar"]["detachFromFrame"] = true
	E.db["unitframe"]["units"]["player"]["classbar"]["detachedWidth"] = 400
	E.db["unitframe"]["units"]["player"]["classbar"]["height"] = 4
	E.db["unitframe"]["units"]["player"]["classbar"]["spacing"] = 0
	E.db["unitframe"]["units"]["player"]["cutaway"]["health"]["fadeOutTime"] = 0.3
	E.db["unitframe"]["units"]["player"]["cutaway"]["health"]["lengthBeforeFade"] = 0.1
	E.db["unitframe"]["units"]["player"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["player"]["debuffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["player"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["debuffs"]["perrow"] = 12
	E.db["unitframe"]["units"]["player"]["debuffs"]["sizeOverride"] = 32
	E.db["unitframe"]["units"]["player"]["debuffs"]["spacing"] = 4
	E.db["unitframe"]["units"]["player"]["debuffs"]["yOffset"] = 40
	E.db["unitframe"]["units"]["player"]["fader"]["minAlpha"] = 0
	E.db["unitframe"]["units"]["player"]["healPrediction"]["absorbStyle"] = "NONE"
	E.db["unitframe"]["units"]["player"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["player"]["health"]["xOffset"] = -2
	E.db["unitframe"]["units"]["player"]["health"]["yOffset"] = 12
	E.db["unitframe"]["units"]["player"]["height"] = 52
	E.db["unitframe"]["units"]["player"]["infoPanel"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["player"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["player"]["power"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["player"]["power"]["detachFromFrame"] = true
	E.db["unitframe"]["units"]["player"]["power"]["detachedWidth"] = 400
	E.db["unitframe"]["units"]["player"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["player"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["player"]["power"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["player"]["power"]["strataAndLevel"]["frameStrata"] = "BACKGROUND"
	E.db["unitframe"]["units"]["player"]["power"]["strataAndLevel"]["useCustomStrata"] = true
	E.db["unitframe"]["units"]["player"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["player"]["power"]["xOffset"] = 2
	E.db["unitframe"]["units"]["player"]["pvp"]["position"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["raidRoleIcons"]["xOffset"] = -70
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["frameStrata"] = "BACKGROUND"
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["useCustomStrata"] = true
	E.db["unitframe"]["units"]["player"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["player"]["width"] = 400
	--Player Custom Text
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["font"] = "font"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["size"] = 16
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:StatusIcon]"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["yOffset"] = 60
  --Pet
	E.db["unitframe"]["units"]["pet"]["castbar"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["height"] = 5
	E.db["unitframe"]["units"]["pet"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["pet"]["power"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["width"] = 400
  --Target
	E.db["unitframe"]["units"]["target"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["aurabar"]["maxDuration"] = 300
	E.db["unitframe"]["units"]["target"]["buffs"]["anchorPoint"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["target"]["buffs"]["attachTo"] = "POWER"
	E.db["unitframe"]["units"]["target"]["buffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["target"]["buffs"]["countFontSize"] = 8
	E.db["unitframe"]["units"]["target"]["buffs"]["priority"] = "Blacklist,Personal,nonPersonal,RaidBuffsElvUI"
	E.db["unitframe"]["units"]["target"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["target"]["buffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["target"]["castbar"]["height"] = 21
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["width"] = 185
	E.db["unitframe"]["units"]["target"]["debuffs"]["anchorPoint"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["target"]["debuffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["target"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["target"]["debuffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["target"]["debuffs"]["sizeOverride"] = 32
	E.db["unitframe"]["units"]["target"]["debuffs"]["xOffset"] = 160
	E.db["unitframe"]["units"]["target"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["minAlpha"] = 0
	E.db["unitframe"]["units"]["target"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["target"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["target"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["target"]["health"]["yOffset"] = 12
	E.db["unitframe"]["units"]["target"]["height"] = 7
	E.db["unitframe"]["units"]["target"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["target"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["target"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["target"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["target"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["target"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["target"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["target"]["width"] = 185
	E.db["unitframe"]["units"]["target"]["infoPanel"]["enable"] = false
  --Target Custom Text
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["font"] = "font"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["size"] = 16
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:medium]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["yOffset"] = 8
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["font"] = "font"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["size"] = 12
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:StatusIcon]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["xOffset"] = 2
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["yOffset"] = 24
	--Target Target
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["targettarget"]["buffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["targettarget"]["debuffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["targettarget"]["health"]["yOffset"] = 12
	E.db["unitframe"]["units"]["targettarget"]["height"] = 7
	E.db["unitframe"]["units"]["targettarget"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["targettarget"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["targettarget"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["targettarget"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["targettarget"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["targettarget"]["power"]["enable"] = false
	E.db["unitframe"]["units"]["targettarget"]["power"]["height"] = 3
	E.db["unitframe"]["units"]["targettarget"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["targettarget"]["smartAuraPosition"] = "DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["targettarget"]["width"] = 58
	--Target Target Custom Text
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["font"] = "font"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["size"] = 12
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:short]"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["yOffset"] = 8
	--Focus
	E.db["unitframe"]["units"]["focus"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["aurabar"]["maxBars"] = 6
	E.db["unitframe"]["units"]["focus"]["aurabar"]["maxDuration"] = 300
	E.db["unitframe"]["units"]["focus"]["buffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["focus"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["buffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["focus"]["buffs"]["sizeOverride"] = 24
	E.db["unitframe"]["units"]["focus"]["castbar"]["height"] = 21
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["width"] = 185
	E.db["unitframe"]["units"]["focus"]["debuffs"]["anchorPoint"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["attachTo"] = "BUFFS"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["focus"]["debuffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["debuffs"]["sizeOverride"] = 36
	E.db["unitframe"]["units"]["focus"]["debuffs"]["yOffset"] = 24
	E.db["unitframe"]["units"]["focus"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["casting"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["combat"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["fader"]["health"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["hover"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["minAlpha"] = 0
	E.db["unitframe"]["units"]["focus"]["fader"]["playertarget"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["power"] = true
	E.db["unitframe"]["units"]["focus"]["fader"]["vehicle"] = true
	E.db["unitframe"]["units"]["focus"]["health"]["yOffset"] = 12
	E.db["unitframe"]["units"]["focus"]["height"] = 7
	E.db["unitframe"]["units"]["focus"]["infoPanel"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["focus"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["focus"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["focus"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["focus"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["focus"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["focus"]["power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["focus"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["focus"]["width"] = 185
	--Focus Custom Text
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["font"] = "font"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["size"] = 16
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:long]"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["xOffset"] = 4
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["yOffset"] = 8
	--Focus Target
	E.db["unitframe"]["units"]["focustarget"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["focustarget"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["focustarget"]["buffs"]["priority"] = "Blacklist,Personal,PlayerBuffs,Dispellable"
	E.db["unitframe"]["units"]["focustarget"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["focustarget"]["buffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["attachTo"] = "BUFFS"
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["priority"] = "Blacklist,Personal,Boss,RaidDebuffs,CCDebuffs,Dispellable,Whitelist"
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["focustarget"]["debuffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["focustarget"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["focustarget"]["enable"] = true
	E.db["unitframe"]["units"]["focustarget"]["health"]["yOffset"] = 12
	E.db["unitframe"]["units"]["focustarget"]["height"] = 7
	E.db["unitframe"]["units"]["focustarget"]["infoPanel"]["height"] = 20
	E.db["unitframe"]["units"]["focustarget"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["focustarget"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["focustarget"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["focustarget"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["focustarget"]["power"]["enable"] = false
	E.db["unitframe"]["units"]["focustarget"]["power"]["height"] = 3
	E.db["unitframe"]["units"]["focustarget"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["focustarget"]["smartAuraPosition"] = "DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["focustarget"]["width"] = 58
	--Focus Target Customn Text
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["font"] = "font"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["size"] = 12
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:short]"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["yOffset"] = 8
  --Party
	E.db["unitframe"]["units"]["party"]["buffs"]["perrow"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["debuffs"]["perrow"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["sizeOverride"] = 0
	E.db["unitframe"]["units"]["party"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["party"]["groupSpacing"] = 1
	E.db["unitframe"]["units"]["party"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["party"]["health"]["position"] = "BOTTOM"
	E.db["unitframe"]["units"]["party"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["health"]["yOffset"] = 2
	E.db["unitframe"]["units"]["party"]["height"] = 7
	E.db["unitframe"]["units"]["party"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["party"]["infoPanel"]["height"] = 12
	E.db["unitframe"]["units"]["party"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["orientation"] = "MIDDLE"
	E.db["unitframe"]["units"]["party"]["phaseIndicator"]["scale"] = 0.5
	E.db["unitframe"]["units"]["party"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["party"]["power"]["position"] = "BOTTOMRIGHT"
	E.db["unitframe"]["units"]["party"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["power"]["yOffset"] = 2
	E.db["unitframe"]["units"]["party"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["position"] = "CENTER"
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["size"] = 18
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["party"]["roleIcon"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["party"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["party"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["party"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["party"]["verticalSpacing"] = 36
	E.db["unitframe"]["units"]["party"]["width"] = 64
	--Party Custom Text
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["size"] = 16
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["text_format"] = "[namecolor][TKUI:GroupLead]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["xOffset"] = 11
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["yOffset"] = 0
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["size"] = 16
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["xOffset"] = -14
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["yOffset"] = -1
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["font"] = "font"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["size"] = 8
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:StatusIcon]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["xOffset"] = 1
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["yOffset"] = 16
  --Raid 40
	E.db["unitframe"]["units"]["raid40"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["raid40"]["groupSpacing"] = 1
	E.db["unitframe"]["units"]["raid40"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["raid40"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid40"]["height"] = 7
	E.db["unitframe"]["units"]["raid40"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["raid40"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid40"]["phaseIndicator"]["scale"] = 0.5
	E.db["unitframe"]["units"]["raid40"]["power"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["raid40"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["raid40"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid40"]["showPlayer"] = false
	E.db["unitframe"]["units"]["raid40"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["verticalSpacing"] = 36
	E.db["unitframe"]["units"]["raid40"]["width"] = 64
	--Raid40 Custom Text
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["size"] = 16
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["text_format"] = "[namecolor][TKUI:GroupLead]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["xOffset"] = 11
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["size"] = 16
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["xOffset"] = -14
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["font"] = "font"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["size"] = 8
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:StatusIcon]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["xOffset"] = 1
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["yOffset"] = 16
  -- Basic Raid Frame setup
	E.db["unitframe"]["units"]["raid"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["raid"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["raid"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid"]["height"] = 7
	E.db["unitframe"]["units"]["raid"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["raid"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["raid"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["raid"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["fontSize"] = 15
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["size"] = 18
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["xOffset"] = 45
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["yOffset"] = 10
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid"]["showPlayer"] = false
	E.db["unitframe"]["units"]["raid"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["verticalSpacing"] = 36
	E.db["unitframe"]["units"]["raid"]["width"] = 64
	--Raid Custom Text
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["size"] = 16
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["text_format"] = "[namecolor][TKUI:GroupLead]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["xOffset"] = 11
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["size"] = 16
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["xOffset"] = -14
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["font"] = "font"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["size"] = 8
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:StatusIcon]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["xOffset"] = 1
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["yOffset"] = 16
  --Tank
  E.db["unitframe"]["units"]["tank"]["targetsGroup"]["enable"] = false
  E.db["unitframe"]["units"]["tank"]["enable"] = false
	E.db["unitframe"]["units"]["assist"]["enable"] = false
  --Boss
	E.db["unitframe"]["units"]["boss"]["buffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["boss"]["buffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["boss"]["buffs"]["enable"] = false
	E.db["unitframe"]["units"]["boss"]["buffs"]["perrow"] = 4
	E.db["unitframe"]["units"]["boss"]["buffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["boss"]["buffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["castbar"]["width"] = 174
	E.db["unitframe"]["units"]["boss"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["countFont"] = "font"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["boss"]["debuffs"]["perrow"] = 4
	E.db["unitframe"]["units"]["boss"]["debuffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["boss"]["debuffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["height"] = 6
	E.db["unitframe"]["units"]["boss"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["power"]["height"] = 3
	E.db["unitframe"]["units"]["boss"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["spacing"] = 37
	E.db["unitframe"]["units"]["boss"]["width"] = 174
	--Boss Custom Text
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["font"] = "font"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["size"] = 14
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["text_format"] = "[namecolor][name][shortclassification]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["xOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossName"]["yOffset"] = 8
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["font"] = "m6x11"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["size"] = 10
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["xOffset"] = 20
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossPower"]["yOffset"] = 1
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["font"] = "font"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["size"] = 42
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["text_format"] = "[perhp]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["xOffset"] = 2
	E.db["unitframe"]["units"]["boss"]["customTexts"]["BossHealth"]["yOffset"] = 16
  --Frame Settings
	E.db["unitframe"]["smoothbars"] = true
	E.db["unitframe"]["statusbar"] = "ElvUI Blank"
	E.db["unitframe"]["colors"]["auraBarBuff"]["b"] = 0.87
	E.db["unitframe"]["colors"]["auraBarBuff"]["g"] = 0.44
	E.db["unitframe"]["colors"]["auraBarBuff"]["r"] = 0
	E.db["unitframe"]["colors"]["castClassColor"] = true
	E.db["unitframe"]["colors"]["health"]["b"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health"]["g"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health"]["r"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health_backdrop"]["b"] = 0.011764705882353
	E.db["unitframe"]["colors"]["health_backdrop"]["g"] = 0.011764705882353
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["b"] = 0
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["g"] = 0
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["r"] = 0
	E.db["unitframe"]["colors"]["healthclass"] = true
	E.db["unitframe"]["smartRaidFilter"] = false
  E.db["unitframe"]["debuffHighlighting"] = "GLOW"
  E.db["unitframe"]["fontOutline"] = "OUTLINE"
	-- MOVERS -----------------------------------------------------------------
	-- Variables
	E.db["movers"]["ElvAB_1"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+1)
	E.db["movers"]["ElvAB_2"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+25)
	E.db["movers"]["ElvAB_3"] = "BOTTOM,ElvUIParent,BOTTOM,0,33"
	--Varible MOVERS
	----Player
	E.db["movers"]["ElvUF_PlayerMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..playerFrame
	E.db["movers"]["DebuffsMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+86)
	E.db["movers"]["ClassBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+51)
	E.db["movers"]["PlayerPowerBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame-3)
	E.db["movers"]["AltPowerBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame-35)
	----Pet
	E.db["movers"]["ElvUF_PetMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+51)
	E.db["movers"]["ElvUF_PetCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0"..(playerFrame-46)
	E.db["movers"]["ElvUF_FocusCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,-330,"..(playerFrame+28)

	----Target
	E.db["movers"]["ElvUF_TargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,330,"..(playerFrame+48)
	E.db["movers"]["ElvUF_TargetCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,330,"..(playerFrame+28)
	----TargetTarget
	E.db["movers"]["ElvUF_TargetTargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,466,"..(playerFrame+48)
	----Focus
	E.db["movers"]["ElvUF_FocusMover"] = "BOTTOM,ElvUIParent,BOTTOM,-330,"..(playerFrame+48)
	E.db["movers"]["ElvUF_FocusTargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,-466,"..(playerFrame+48)
	----Groups
	E.db["movers"]["ElvUF_PartyMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,978,614"
	E.db["movers"]["ElvUF_RaidMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,626,614"
	E.db["movers"]["ElvUF_Raid40Mover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,355,614"
	----Boss
	E.db["movers"]["BossHeaderMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-868,".."-"..(partyFrame)
	----Arena
	E.db["movers"]["ArenaHeaderMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-967,".."-"..(partyFrame)
	----Misc
	E.db["movers"]["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["ZoneAbility"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["LossControlMover"] = "CENTER,ElvUIParent,CENTER,0,-671"
  -- GENERAL MOVERS
	E.db["movers"]["ArtifactBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-530,30"
	E.db["movers"]["AzeriteBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,30"
	E.db["movers"]["BNETMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-306,30"
	E.db["movers"]["BelowMinimapContainerMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-93,333"
	E.db["movers"]["BuffsMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,8,1"
	E.db["movers"]["DurabilityFrameMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,483"
	E.db["movers"]["ElvUF_AssistMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,662,240"
	E.db["movers"]["ElvUIBagMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,334"
	E.db["movers"]["ElvUIBankMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,204"
	E.db["movers"]["ExperienceBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,25"
	E.db["movers"]["GMMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,4,-4"
	E.db["movers"]["HonorBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-518,30"
	E.db["movers"]["LeftChatMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,2,29"
	E.db["movers"]["MinimapMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,29"
	E.db["movers"]["ObjectiveFrameMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-51,-240"
	E.db["movers"]["PetAB"] = "BOTTOM,ElvUIParent,BOTTOM,0,332"
	if screenHeight < 1440 then
	E.db["movers"]["RightChatMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-256,30"
	else
	E.db["movers"]["RightChatMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-306,31"
	end
	E.db["movers"]["ShiftAB"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,768"
	E.db["movers"]["SquareMinimapButtonBarMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,334"
	E.db["movers"]["TalkingHeadFrameMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,75"
	E.db["movers"]["ThreatBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,334,456"
	E.db["movers"]["TooltipMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,334"
	E.db["movers"]["TopCenterContainerMover"] = "TOP,ElvUIParent,TOP,0,-36"
	E.db["movers"]["TotemBarMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,292,361"
	E.db["movers"]["VOICECHAT"] = "TOPLEFT,ElvUIParent,TOPLEFT,4,-2"
	E.db["movers"]["VehicleLeaveButton"] = "BOTTOM,ElvUIParent,BOTTOM,183,414"
	E.db["movers"]["VehicleSeatMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-656"

	local function CreateStyleFilter(name)
		local filter = {} --Create filter table
		NP:StyleFilterCopyDefaults(filter) --Initialize new filter with default options
		E.global["nameplate"]["filters"][name] = filter --Add new filter to database

		--Add the "Enable" option to current profile
		if not E.db.nameplates then E.db.nameplates = {} end
		if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
		if not E.db.nameplates.filters[name] then E.db.nameplates.filters[name] = {} end
		if not E.db.nameplates.filters[name].triggers then E.db.nameplates.filters[name].triggers = {} end
		E.db["nameplates"]["filters"][name]["triggers"]["enable"] = true
	end

	--Nameplate Filters
	CreateStyleFilter("TKUI:Enemy_Casting")
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["priority"] = 1
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["actions"]["alpha"] = 100
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["actions"]["scale"] = 1.2
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["casting"]["isCasting"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["casting"]["isChanneling"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enemyNPC"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enemyPlayer"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enable"] = true
	CreateStyleFilter("TKUI:Enemy_NonTarget")
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["priority"] = 2
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["actions"]["alpha"] = 75
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enemyNPC"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enemyPlayer"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["notTarget"] = true
	E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enable"] = true
	CreateStyleFilter("TKUI:Friendly_NonTarget")
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["priority"] = 2
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["actions"]["alpha"] = 50
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["friendlyNPC"] = true
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["friendlyPlayer"] = true
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["notTarget"] = true
	E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["enable"] = true

	E.db["nameplates"]["filters"]["ElvUI_Explosives"]["triggers"]["enable"] = false
	E.db["nameplates"]["filters"]["ElvUI_NonTarget"]["triggers"]["enable"] = false
	E.db["nameplates"]["filters"]["ElvUI_Target"]["triggers"]["enable"] = false
	E.db["nameplates"]["filters"]["ElvUI_Boss"]["triggers"]["enable"] = false
	NP:ConfigureAll()

  E:UpdateAll(true)
  -- Show message about layout being set
  PluginInstallStepComplete.message = "Layout Set"
  PluginInstallStepComplete:Show()
end


-- INSTALATION COMPLETE - Set version and overlay status ------------------------------
local function InstallComplete()
    if GetCVarBool("Sound_EnableMusic") then
        StopMusic()
    end

    -- Set a variable tracking the version of the addon when layout was installed
    E.db[TKUIPlugin].install_version = Version

    -- Set the key for Overlay
    E.db[TKUIPlugin].classHealth = true
		E.db[TKUIPlugin].gradientHealth = true
		E.db[TKUIPlugin].playerScale = 1.0
		E.db[TKUIPlugin].targetfocusScale = 0.7
		E.db[TKUIPlugin].groupScale = 0.6
    ReloadUI()
end

-- PLUGIN INSTALLER -----------------------------------------------------------------
local InstallerData = {
    Title = format("|cffff8c00%s %s|r", TKUIPlugin, "|cffffffffInstallation|r"),
    Name = TKUIPlugin,
    tutorialImage = "Interface\\AddOns\\TKUI\\Media\\Logo\\Logo.blp",
    Pages = {
        [1] = function()
            PluginInstallFrame.SubTitle:SetFormattedText("Welcome to the installation for %s.", TKUIPlugin)
            PluginInstallFrame.Desc1:SetText(
                "This installation process will guide you through a few steps and apply settings to your current ElvUI profile. If you want to be able to go back to your original settings then create a new profile before going through this installation process."
            )
            PluginInstallFrame.Desc2:SetText(
                "Please press the continue button if you wish to go through the installation process, otherwise click the 'Skip Process' button."
            )
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Skip Process")
        end,
        [2] = function()
			PluginInstallFrame.SubTitle:SetText("Profiles")
			PluginInstallFrame.Desc1:SetText("You can either create a new profile to install NoobTacoUI onto or you can apply NoobTacoUI settings to your current profile")
			PluginInstallFrame.Desc3:SetText("Your currently active ElvUI profile is: |cffff8c00"..ElvUI[1].data:GetCurrentProfile().."|r")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NewProfile(false) end)
			PluginInstallFrame.Option1:SetText("Use Current")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() NewProfile(true, "TKUI") end)
			PluginInstallFrame.Option2:SetText("Create New")

			PluginInstallFrame.SubTitle:SetText("Profiles")
			PluginInstallFrame.Desc1:SetText("Press \"Update Current\" to update your current profile with the new NoobTacoUI changes.")
			PluginInstallFrame.Desc2:SetText("If you'd like to check out what the changes are, without overwriting your current settings, you can press \"Create New\"")
			PluginInstallFrame.Desc3:SetText("Your currently active ElvUI profile is: |cffff8c00"..ElvUI[1].data:GetCurrentProfile().."|r")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NewProfile(false) end)
			PluginInstallFrame.Option1:SetText("Update Current")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() NewProfile(true, "TKUI-Update") end)
			PluginInstallFrame.Option2:SetText("Create New")
        end,
				[3] = function()
			PluginInstallFrame.SubTitle:SetText(L["CVars for |cFFff8c00TK|r|cFFFFFFFFUI|r"])
			PluginInstallFrame.Desc1:SetText(L["This is the recommended CVars for |cFFff8c00TK|r|cFFFFFFFFUI|r."])
			PluginInstallFrame.Desc2:SetText(L["This will set some general console variables."])
			PluginInstallFrame.Desc3:SetFormattedText(L["Importance: |cffFF0000High|r"])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupCVAR(); end)
			PluginInstallFrame.Option1:SetText("Setup CVars")
		end,
        [4] = function()
			PluginInstallFrame.SubTitle:SetText(L["General Layout of |cFFff8c00TK|r|cFFFFFFFFUI|r"])
			PluginInstallFrame.Desc1:SetText(L["This is the recommended base layout for |cFFff8c00TK|r|cFFFFFFFFUI|r."])
			PluginInstallFrame.Desc2:SetText(L["This will set some general settings for the layout installation"])
			PluginInstallFrame.Desc3:SetFormattedText(L["Importance: |cffFF0000High|r"])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() SetupLayout(); end)
			PluginInstallFrame.Option1:SetText("Install")
		end,
        [5] = function()
            PluginInstallFrame.SubTitle:SetText("Installation Complete")
            PluginInstallFrame.Desc1:SetText(
                "You have completed the installation process.\nIf you need help or wish to report a bug, please go to http://tukui.org"
            )
            PluginInstallFrame.Desc2:SetText(
                "Please click the button below in order to finalize the process and automatically reload your UI. \nLog out of character is needed for all fonts to update."
            )
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Finished")
        end
    },
    StepTitles = {
        [1] = "Welcome",
        [2] = "Profiles",
        [3] = "Setup CVars",
        [4] = "TKUI Layout",
        [5] = "Installation Complete"

    },
    StepTitlesColor = {1, 1, 1},
    StepTitlesColorSelected = {0, 179 / 255, 1},
    StepTitleWidth = 200,
    StepTitleButtonWidth = 180,
    StepTitleTextJustification = "RIGHT"
}

-- This function holds the options table which will be inserted into the ElvUI config
local function InsertOptions()
    E.Options.args.TKUIPlugin = {
        order = 100,
        type = "group",
        name = format("|cffff8c00%s|r", TKUIPlugin),
        get = function(info)
            return E.db[TKUIPlugin][info[#info]]
        end,
        set = function(info, value)
            E.db[TKUIPlugin][info[#info]] = value
            E:StaticPopup_Show("PRIVATE_RL")
        end,
        args = {
            header1 = {order = 1, type = "header", name = TKUIPlugin},
            description1 = {
                order = 2,
                type = "description",
                name = format("%s is an external edit of ElvUI.\n\nRequired Addons:\nElvUI\nMasque\n\nOptional Addons:\nDetails!\nWeakAuras\nNamePlateSCT\nKaliel's Tracker\nXIV_DataBar\n\nRecommended Addons:\nAdiBags\nOPie\nProjectAzilroka (Square Minimap Buttons)\nXLoot\n\nReport bugs or make suggestions at: |cffff8c00https://www.curseforge.com/wow/addons/tkui|r", TKUIPlugin)
            },
            spacer1 = {order = 3, type = "description", name = "\n"},
            header2 = {order = 4, type = "header", name = "Options"},
            health = {
                order = 5,
                type = "group",
                -- name = MER:cOption(L["General"]),
                name = "Health Options",
                guiInline = true,
                args = {
                    classHealth = {
                        order = 1,
                        type = "toggle",
                        name = L[" Class Health"],
                        desc = L["Color health text by class or reaction color."]
										},
										gradientHealth = {
													order = 2,
													type = "toggle",
													name = L[" Gradient by Value"],
													desc = L["Gradient health color by amount remaining."]
                    }
										-- customColor = {
										-- 		order = 3,
										-- 		type = "color",
										-- 		name = L[" Custom Color"],
										-- 		desc = L["Default color."],
										-- 		hasAlpha = false,
										-- }
                }
            },
						scale = {
								order = 6,
								type = "group",
								-- name = MER:cOption(L["General"]),
								name = "Size Options",
								guiInline = true,
								args = {
										playerScale = {
												order = 1,
												type = "range",
												name = L[" Player Scale"],
												desc = L["Change size of Player health.\nDEFAULT: 1.0"],
												min = .5,max = 1.5,step = .05
										},
										targetfocusScale = {
													order = 2,
													type = "range",
													name = L["Target/Focus Scale"],
													desc = L["Change size of Target and Focus health.\nDEFAULT: 0.7"],
													min = .5, max = 1.5, step = .05
										},
										groupScale = {
												order = 3,
												type = "range",
												name = L["Party/Raid Scale"],
												desc = L["Change size of Party and Raid health.\nDEFAULT: 0.6"],
												min = .5, max = 1.5, step = .05
										}
								}
						},
            header3 = {order = 7, type = "header", name = "Installation"},
            description2 = {
                order = 8,
                type = "description",
                name = "The installation guide should pop up automatically after you have completed the ElvUI installation. If you wish to re-run the installation process for this layout then please click the button below."
            },
            spacer2 = {order = 9, type = "description", name = ""},
            install = {
                order = 10,
                type = "execute",
                name = "Install",
                desc = "Run the installation process.",
                func = function()
                    E:GetModule("PluginInstaller"):Queue(InstallerData)
                    E:ToggleOptionsUI()
                end
            },
						header4 = {order = 11, type = "header", name = "|cffff8c00Special Thanks|r"},
            description3 = {
                order = 12,
                type = "description",
                name = format("This UI would not be possible without:\nThe entire ElvUI Team - Your contribution to the WoW community is unmatched.\nThe oUF team and community\nHanktheTank (oUF_Hank)\nPaopao001 (AltzUI)\nSimpy\n...and many others that provide assistance to novice coders like me on forums across the web.", TKUI)
            }
				}
    }
end

-- Create a unique table for our plugin
P[TKUIPlugin] = {}

-- This function will handle initialization of the addon
function mod:Initialize()
    -- Initiate installation process if ElvUI install is complete and our plugin install has not yet been run
    if E.private.install_complete and E.db[TKUIPlugin].install_version == nil then
        E:GetModule("PluginInstaller"):Queue(InstallerData)
    end

    -- Insert our options table when ElvUI config is loaded
    EP:RegisterPlugin(addon, InsertOptions)
end

-- Register module with callback so it gets initialized when ready
E:RegisterModule(mod:GetName())
