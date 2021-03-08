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

local localizedClass, englishClass, classIndex = UnitClass("player");

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
	if E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"] = {}
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
	if E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"] = {}
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
	if E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"] = {}
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
	if E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"] = {}
	end
	if E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"] = {}
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
	if E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"] = {}
	end
	if E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"] = {}
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
	if E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"] = {}
	end
	if E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"] = {}
	end
	if not E.db.unitframe.units.boss.customTexts then
			E.db.unitframe.units.boss.customTexts = {}
	end
	if E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"] = {}
	end
	if E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"] = {}
	end
	if not E.db.unitframe.units.arena.customTexts then
			E.db.unitframe.units.arena.customTexts = {}
	end
	if E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"] == nil then
			E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"] = {}
	end
	if E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"] == nil then
			E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"] = {}
	end
	if not E.global.datatexts.customPanels then
		E.global.datatexts.customPanels = {}
	end
	if E.global["datatexts"]["customPanels"]["TKUI"] == nil then
		E.global["datatexts"]["customPanels"]["TKUI"] = {}
	end
	if not E.db.datatexts.panels then
		E.db.datatexts.panels = {}
	end
	if E.db["datatexts"]["panels"]["TKUI"] == nil then
		E.db["datatexts"]["panels"]["TKUI"] = {}
	end
  -- -- Fix Movers ??
  if E.db["movers"] == nil then
      E.db["movers"] = {}
  end
--   E.db["unitframe"]["units"]["target"]["orientation"] = "RIGHT"
  -- PRIVATEDB ------------------------------------------------------------------
	E.private["general"]["chatBubbleFont"] = "Barlow-SemiBold"
	E.private["general"]["chatBubbleFontOutline"] = "OUTLINE"
	E.private["general"]["chatBubbleFontSize"] = 10
	E.private["general"]["chatBubbles"] = "nobackdrop"
	E.private["general"]["dmgfont"] = "Barlow-SemiBold"
	E.private["general"]["glossTex"] = "ElvUI Blank"
	E.private["general"]["loot"] = false
	E.private["general"]["minimap"]["hideClassHallReport"] = true
	E.private["general"]["namefont"] = "Barlow-SemiBold"
	E.private["general"]["normTex"] = "ElvUI Blank"
	E.private["general"]["totemBar"] = false
	E.private["general"]["unifiedBlizzFonts"] = true
	E.private["install_complete"] = 12.17
	E.private["nameplates"]["enable"] = false
	E.private["skins"]["blizzard"]["objectiveTracker"] = false
	E.private["theme"] = "default"
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
	E.db["datatexts"]["font"] = "Barlow-SemiBold"
	E.db["datatexts"]["fontSize"] = 14
	E.db["datatexts"]["panels"]["LeftChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["MinimapPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["RightChatDataPanel"]["enable"] = false
	--Custom DataText
	E.db["datatexts"]["font"] = "Barlow-SemiBold"
	E.db["datatexts"]["fontSize"] = 14
	E.db["datatexts"]["panels"]["LeftChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["MinimapPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["RightChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["TKUI"][1] = ""
	E.db["datatexts"]["panels"]["TKUI"]["enable"] = true
	E.global["datatexts"]["customPanels"]["TKUI"]["enable"] = true
	E.global["datatexts"]["customPanels"]["TKUI"]["backdrop"] = true
	E.global["datatexts"]["customPanels"]["TKUI"]["border"] = true
	-- E.global["datatexts"]["customPanels"]["TKUI"]["fonts"]["enable"] = false
	-- E.global["datatexts"]["customPanels"]["TKUI"]["fonts"]["font"] = "PT Sans Narrow"
	-- E.global["datatexts"]["customPanels"]["TKUI"]["fonts"]["fontOutline"] = "OUTLINE"
	-- E.global["datatexts"]["customPanels"]["TKUI"]["fonts"]["fontSize"] = 12
	E.global["datatexts"]["customPanels"]["TKUI"]["frameLevel"] = 1
	E.global["datatexts"]["customPanels"]["TKUI"]["frameStrata"] = "LOW"
	E.global["datatexts"]["customPanels"]["TKUI"]["growth"] = "HORIZONTAL"
	E.global["datatexts"]["customPanels"]["TKUI"]["height"] = 52
	E.global["datatexts"]["customPanels"]["TKUI"]["mouseover"] = false
	E.global["datatexts"]["customPanels"]["TKUI"]["name"] = "TKUI"
	E.global["datatexts"]["customPanels"]["TKUI"]["numPoints"] = 1
	E.global["datatexts"]["customPanels"]["TKUI"]["panelTransparency"] = true
	E.global["datatexts"]["customPanels"]["TKUI"]["textJustify"] = "CENTER"
	E.global["datatexts"]["customPanels"]["TKUI"]["tooltipAnchor"] = "ANCHOR_TOPLEFT"
	E.global["datatexts"]["customPanels"]["TKUI"]["tooltipXOffset"] = -17
	E.global["datatexts"]["customPanels"]["TKUI"]["tooltipYOffset"] = 4
	E.global["datatexts"]["customPanels"]["TKUI"]["visibility"] = "[petbattle] hide;show"
	E.global["datatexts"]["customPanels"]["TKUI"]["width"] = 400
  -- NAMEPLATES -------------------------------------------------------------
  E.db["v11NamePlateReset"] = true
	E.db["nameplates"]["enable"] = false
  -- BAGS --------------------------------------------------------------
	E.private["bags"]["enable"] = false
	E.db["bags"]["countFont"] = "Barlow-SemiBold"
	E.db["bags"]["countFontSize"] = 14
	E.db["bags"]["itemLevelFont"] = "Barlow-SemiBold"
	E.db["bags"]["itemLevelFontSize"] = 14
	E.db["bags"]["vendorGrays"]["enable"] = true
  -- COOLDOWN --------------------------------------------------------------------
  -- CHAT -------------------------------------------------------------------------
	E.db["chat"]["editBoxPosition"] = "ABOVE_CHAT"
	E.db["chat"]["font"] = "Barlow-SemiBold"
	E.db["chat"]["fontOutline"] = "OUTLINE"
	E.db["chat"]["fontSize"] = 14
	E.db["chat"]["keywords"] = "%MYNAME%"
	E.db["chat"]["numScrollMessages"] = 1
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
	E.db["chat"]["tabFont"] = "Barlow-SemiBold"
	E.db["chat"]["tabFontOutline"] = "OUTLINE"
	E.db["chat"]["tabFontSize"] = 16
	E.db["chat"]["timeStampFormat"] = "%H:%M "
  -- DATABARS ------------------------------------------
	E.db["convertPages"] = true
	E.db["cooldown"]["fonts"]["enable"] = true
	E.db["cooldown"]["fonts"]["font"] = "Barlow-Bold"
	E.db["cooldown"]["fonts"]["fontSize"] = 22
	E.db["databars"]["azerite"]["enable"] = false
	E.db["databars"]["azerite"]["width"] = 201
	E.db["databars"]["experience"]["enable"] = false
	E.db["databars"]["experience"]["font"] = "Barlow-SemiBold"
	E.db["databars"]["experience"]["height"] = 11
	E.db["databars"]["experience"]["width"] = 200
	E.db["databars"]["honor"]["enable"] = false
	E.db["databars"]["statusbar"] = "ElvUI Blank"
	E.db["databars"]["threat"]["enable"] = false
	-- DATATEXTS ------------------------------------------
	E.db["datatexts"]["font"] = "Barlow-SemiBold"
	E.db["datatexts"]["fontSize"] = 14
	E.db["datatexts"]["panels"]["LeftChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["MinimapPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["RightChatDataPanel"]["enable"] = false
	E.db["datatexts"]["panels"]["TKUI"][1] = ""
	E.db["datatexts"]["panels"]["TKUI"]["enable"] = true
  -- GENERAL---------------------------------------------
	E.db["general"]["afk"] = false
	E.db["general"]["altPowerBar"]["font"] = "Barlow-SemiBold"
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
	E.db["general"]["font"] = "Barlow-SemiBold"
	E.db["general"]["fontSize"] = 14
	E.db["general"]["itemLevel"]["itemLevelFont"] = "Barlow-SemiBold"
	E.db["general"]["loginmessage"] = false
	E.db["general"]["minimap"]["icons"]["lfgEye"]["xOffset"] = 5
	E.db["general"]["minimap"]["icons"]["lfgEye"]["yOffset"] = -5
	E.db["general"]["minimap"]["icons"]["mail"]["scale"] = 1.25
	E.db["general"]["minimap"]["locationFont"] = "Barlow-Bold"
	E.db["general"]["minimap"]["locationFontSize"] = 18
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
	E.db["tooltip"]["font"] = "Barlow-SemiBold"
	E.db["tooltip"]["fontOutline"] = "OUTLINE"
	E.db["tooltip"]["guildRanks"] = false
	E.db["tooltip"]["headerFontSize"] = 16
	E.db["tooltip"]["healthBar"]["font"] = "Barlow-SemiBold"
	E.db["tooltip"]["healthBar"]["height"] = 1
	E.db["tooltip"]["healthBar"]["statusPosition"] = "DISABLED"
	E.db["tooltip"]["healthBar"]["text"] = false
	E.db["tooltip"]["itemCount"] = "BOTH"
	E.db["tooltip"]["playerTitles"] = false
	E.db["tooltip"]["smallTextFontSize"] = 14
	E.db["tooltip"]["targetInfo"] = false
	E.db["tooltip"]["textFontSize"] = 15
	E.db["tooltip"]["visibility"]["combatOverride"] = "HIDE"
  -- AURAS -------------------------------------------------------------------
	E.db["auras"]["buffs"]["barColor"]["b"] = 0.33725490196078
	E.db["auras"]["buffs"]["barColor"]["g"] = 0.33725490196078
	E.db["auras"]["buffs"]["barColor"]["r"] = 0.33725490196078
	E.db["auras"]["buffs"]["barColorGradient"] = true
	E.db["auras"]["buffs"]["barShow"] = true
	E.db["auras"]["buffs"]["barTexture"] = "ElvUI Blank"
	E.db["auras"]["buffs"]["countFont"] = "Barlow-Bold"
	E.db["auras"]["buffs"]["countFontOutline"] = "OUTLINE"
	E.db["auras"]["buffs"]["countFontSize"] = 16
	E.db["auras"]["buffs"]["countXOffset"] = 4
	E.db["auras"]["buffs"]["countYOffset"] = 4
	E.db["auras"]["buffs"]["growthDirection"] = "RIGHT_DOWN"
	E.db["auras"]["buffs"]["horizontalSpacing"] = 18
	E.db["auras"]["buffs"]["size"] = 46
	E.db["auras"]["buffs"]["sortDir"] = "+"
	E.db["auras"]["buffs"]["timeFont"] = "Barlow-SemiBold"
	E.db["auras"]["buffs"]["timeFontOutline"] = "OUTLINE"
	E.db["auras"]["buffs"]["timeFontSize"] = 16
	E.db["auras"]["buffs"]["timeYOffset"] = 15
	E.db["auras"]["buffs"]["wrapAfter"] = 18
	E.db["auras"]["debuffs"]["barColor"]["g"] = 0
	E.db["auras"]["debuffs"]["barShow"] = true
	E.db["auras"]["debuffs"]["barSize"] = 5
	E.db["auras"]["debuffs"]["barTexture"] = "ElvUI Blank"
	E.db["auras"]["debuffs"]["countFont"] = "Barlow-Bold"
	E.db["auras"]["debuffs"]["countFontOutline"] = "OUTLINE"
	E.db["auras"]["debuffs"]["countFontSize"] = 14
	E.db["auras"]["debuffs"]["growthDirection"] = "RIGHT_DOWN"
	E.db["auras"]["debuffs"]["horizontalSpacing"] = 20
	E.db["auras"]["debuffs"]["size"] = 46
	E.db["auras"]["debuffs"]["timeFont"] = "Barlow-Bold"
	E.db["auras"]["debuffs"]["timeFontOutline"] = "OUTLINE"
	E.db["auras"]["debuffs"]["timeFontSize"] = 16
	E.db["auras"]["debuffs"]["timeYOffset"] = 15
	E.db["auras"]["debuffs"]["wrapAfter"] = 7
  -- ACTIONBARS ------------------------------------------------------
  -- Main Actionbar Bottom
	E.db["actionbar"]["bar1"]["buttons"] = 12
	E.db["actionbar"]["bar1"]["backdropSpacing"] = 0
	E.db["actionbar"]["bar1"]["buttonHeight"] = 16
	E.db["actionbar"]["bar1"]["buttonSize"] = 26
	E.db["actionbar"]["bar1"]["buttonSpacing"] = 7
	E.db["actionbar"]["bar1"]["countFont"] = "m5x7"
	E.db["actionbar"]["bar1"]["countFontSize"] = 15
	E.db["actionbar"]["bar1"]["hotkeytext"] = false
  -- Main Actionbar Top
	E.db["actionbar"]["bar2"]["buttons"] = 12
	E.db["actionbar"]["bar2"]["buttonSize"] = 26
	E.db["actionbar"]["bar2"]["buttonSpacing"] = 7
	E.db["actionbar"]["bar2"]["countFont"] = "m5x7"
	E.db["actionbar"]["bar2"]["countFontSize"] = 15
	E.db["actionbar"]["bar2"]["enabled"] = true
	E.db["actionbar"]["bar2"]["hotkeytext"] = false
	-- Pet Bar
	E.db["actionbar"]["barPet"]["backdrop"] = false
	E.db["actionbar"]["barPet"]["buttonSize"] = 26
	E.db["actionbar"]["barPet"]["buttonSpacing"] = 7
	E.db["actionbar"]["barPet"]["buttonsPerRow"] = 10
	E.db["actionbar"]["barPet"]["mouseover"] = true
  -- Bottom Actionbar
	E.db["actionbar"]["bar3"]["buttons"] = 12
	E.db["actionbar"]["bar3"]["buttonSize"] = 26
	E.db["actionbar"]["bar3"]["buttonSpacing"] = 7
	E.db["actionbar"]["bar3"]["buttonsPerRow"] = 12
	E.db["actionbar"]["bar3"]["hotkeytext"] = false
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
	E.db["actionbar"]["cooldown"]["fonts"]["font"] = "Barlow-Bold"
	E.db["actionbar"]["cooldown"]["override"] = false
	E.db["actionbar"]["countTextYOffset"] = 0
	E.db["actionbar"]["desaturateOnCooldown"] = true
	E.db["actionbar"]["extraActionButton"]["clean"] = true
	E.db["actionbar"]["font"] = "m5x7"
	E.db["actionbar"]["fontSize"] = 16
	E.db["actionbar"]["movementModifier"] = "CTRL"
	E.db["actionbar"]["stanceBar"]["enabled"] = false
	E.db["actionbar"]["transparent"] = true
	E.db["actionbar"]["zoneActionButton"]["clean"] = true
  --UNITFRAME ----------------------------------------------------------------
	E.db["unitframe"]["font"] = "Barlow-SemiBold"
	E.db["unitframe"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["fontSize"] = 16
	E.db["unitframe"]["smartRaidFilter"] = false
	E.db["unitframe"]["smoothbars"] = true
	E.db["unitframe"]["statusbar"] = "ElvUI Blank"
	E.db["unitframe"]["colors"]["auraBarBuff"]["b"] = 0.87
	E.db["unitframe"]["colors"]["auraBarBuff"]["g"] = 0.44
	E.db["unitframe"]["colors"]["auraBarBuff"]["r"] = 0
	E.db["unitframe"]["colors"]["castClassColor"] = true
	E.db["unitframe"]["colors"]["castColor"]["b"] = 0
	E.db["unitframe"]["colors"]["castColor"]["g"] = 0.81176470588235
	E.db["unitframe"]["colors"]["castColor"]["r"] = 1
	E.db["unitframe"]["colors"]["castInterruptedColor"]["b"] = 0.50196078431373
	E.db["unitframe"]["colors"]["castInterruptedColor"]["g"] = 0.50196078431373
	E.db["unitframe"]["colors"]["castInterruptedColor"]["r"] = 0.50196078431373
	E.db["unitframe"]["colors"]["castNoInterrupt"]["b"] = 0.25098039215686
	E.db["unitframe"]["colors"]["castNoInterrupt"]["g"] = 0.25098039215686
	E.db["unitframe"]["colors"]["castNoInterrupt"]["r"] = 0.78039215686275
	E.db["unitframe"]["colors"]["castbar_backdrop"]["b"] = 0.43529411764706
	E.db["unitframe"]["colors"]["castbar_backdrop"]["g"] = 0.058823529411765
	E.db["unitframe"]["colors"]["castbar_backdrop"]["r"] = 0.50196078431373
	E.db["unitframe"]["colors"]["debuffHighlight"]["blendMode"] = "ALPHAKEY"
	E.db["unitframe"]["colors"]["health"]["b"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health"]["g"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health"]["r"] = 0.70196078431373
	E.db["unitframe"]["colors"]["health_backdrop"]["b"] = 0.011764705882353
	E.db["unitframe"]["colors"]["health_backdrop"]["g"] = 0.011764705882353
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["b"] = 0
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["g"] = 0
	E.db["unitframe"]["colors"]["health_backdrop_dead"]["r"] = 0
	E.db["unitframe"]["colors"]["healthclass"] = true
	E.db["unitframe"]["colors"]["transparentAurabars"] = true
	E.db["unitframe"]["debuffHighlighting"] = "GLOW"
  --Player
	E.db["unitframe"]["units"]["player"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["RestIcon"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["aurabar"]["maxDuration"] = 300
		E.db["unitframe"]["units"]["player"]["buffs"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["buffs"]["attachTo"] = "HEALTH"
	E.db["unitframe"]["units"]["player"]["buffs"]["sizeOverride"] = 22
	E.db["unitframe"]["units"]["player"]["buffs"]["yOffset"] = 6
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["a"] = 0
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["b"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["g"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["colorBackdrop"]["r"] = 0.50196078431373
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["useClassColor"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["customColor"]["useCustomBackdrop"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["customTextFont"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["customTextFont"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["player"]["castbar"]["customTextFont"]["fontSize"] = 18
	E.db["unitframe"]["units"]["player"]["castbar"]["customTimeFont"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["customTimeFont"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["player"]["castbar"]["customTimeFont"]["fontSize"] = 24
	E.db["unitframe"]["units"]["player"]["castbar"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["castbar"]["height"] = 14
	E.db["unitframe"]["units"]["player"]["castbar"]["icon"] = false
	E.db["unitframe"]["units"]["player"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["player"]["castbar"]["iconPosition"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["player"]["castbar"]["iconSize"] = 24
	E.db["unitframe"]["units"]["player"]["castbar"]["iconXOffset"] = 500
	E.db["unitframe"]["units"]["player"]["castbar"]["overlayOnFrame"] = "Health"
	E.db["unitframe"]["units"]["player"]["castbar"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["player"]["castbar"]["strataAndLevel"]["frameStrata"] = "BACKGROUND"
	E.db["unitframe"]["units"]["player"]["castbar"]["strataAndLevel"]["useCustomLevel"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["strataAndLevel"]["useCustomStrata"] = true
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["player"]["castbar"]["width"] = 400
	E.db["unitframe"]["units"]["player"]["castbar"]["xOffsetText"] = 24
	E.db["unitframe"]["units"]["player"]["castbar"]["xOffsetTime"] = 0
	E.db["unitframe"]["units"]["player"]["castbar"]["yOffsetText"] = -42
	E.db["unitframe"]["units"]["player"]["castbar"]["yOffsetTime"] = -40
	E.db["unitframe"]["units"]["player"]["classbar"]["detachFromFrame"] = true
	E.db["unitframe"]["units"]["player"]["classbar"]["detachedWidth"] = 400
	E.db["unitframe"]["units"]["player"]["classbar"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["classbar"]["height"] = 4
	E.db["unitframe"]["units"]["player"]["classbar"]["spacing"] = 0
	E.db["unitframe"]["units"]["player"]["cutaway"]["health"]["fadeOutTime"] = 0.3
	E.db["unitframe"]["units"]["player"]["cutaway"]["health"]["lengthBeforeFade"] = 0.1
	E.db["unitframe"]["units"]["player"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["player"]["debuffs"]["countFont"] = "Barlow-SemiBold"
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
	E.db["unitframe"]["units"]["player"]["raidicon"]["attachTo"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["player"]["raidicon"]["enable"] = false
	E.db["unitframe"]["units"]["player"]["raidicon"]["xOffset"] = -62
	E.db["unitframe"]["units"]["player"]["raidicon"]["yOffset"] = 58
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["frameLevel"] = 2
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["frameStrata"] = "BACKGROUND"
	E.db["unitframe"]["units"]["player"]["strataAndLevel"]["useCustomStrata"] = true
	E.db["unitframe"]["units"]["player"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["player"]["width"] = 400
	--Player Custom Text
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Frame"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Power"]["yOffset"] = 30
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["size"] = 13
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["player"]["customTexts"]["TKUI:Status"]["yOffset"] = 60
  --Pet
	E.db["unitframe"]["units"]["pet"]["castbar"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["height"] = 5
	E.db["unitframe"]["units"]["pet"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["pet"]["power"]["enable"] = false
	E.db["unitframe"]["units"]["pet"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["pet"]["width"] = 400
  --Target
	E.db["unitframe"]["units"]["target"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["aurabar"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["aurabar"]["maxDuration"] = 300
	E.db["unitframe"]["units"]["target"]["buffs"]["anchorPoint"] = "RIGHT"
	E.db["unitframe"]["units"]["target"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["target"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["target"]["buffs"]["countFontSize"] = 15
	E.db["unitframe"]["units"]["target"]["buffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["target"]["buffs"]["priority"] = "Blacklist,Personal,nonPersonal,RaidBuffsElvUI"
	E.db["unitframe"]["units"]["target"]["buffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["target"]["buffs"]["sortDirection"] = "ASCENDING"
	E.db["unitframe"]["units"]["target"]["buffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["target"]["buffs"]["xOffset"] = -68
	E.db["unitframe"]["units"]["target"]["buffs"]["yOffset"] = 25
	E.db["unitframe"]["units"]["target"]["castbar"]["customTextFont"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["castbar"]["customTextFont"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["target"]["castbar"]["customTextFont"]["fontSize"] = 20
	E.db["unitframe"]["units"]["target"]["castbar"]["customTimeFont"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["castbar"]["customTimeFont"]["font"] = "Barlow-Black"
	E.db["unitframe"]["units"]["target"]["castbar"]["customTimeFont"]["fontSize"] = 22
	E.db["unitframe"]["units"]["target"]["castbar"]["customTimeFont"]["fontStyle"] = "THICKOUTLINE"
	E.db["unitframe"]["units"]["target"]["castbar"]["height"] = 28
	E.db["unitframe"]["units"]["target"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["target"]["castbar"]["iconAttachedTo"] = "Castbar"
	E.db["unitframe"]["units"]["target"]["castbar"]["iconPosition"] = "CENTER"
	E.db["unitframe"]["units"]["target"]["castbar"]["iconXOffset"] = 0
	E.db["unitframe"]["units"]["target"]["castbar"]["spark"] = false
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["target"]["castbar"]["width"] = 53
	E.db["unitframe"]["units"]["target"]["debuffs"]["anchorPoint"] = "RIGHT"
	E.db["unitframe"]["units"]["target"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["target"]["debuffs"]["countFont"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["target"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["target"]["debuffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["target"]["debuffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["target"]["debuffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["target"]["debuffs"]["xOffset"] = -98
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
	E.db["unitframe"]["units"]["target"]["power"]["detachedWidth"] = 15
	E.db["unitframe"]["units"]["target"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["target"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["target"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["target"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["target"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["target"]["raidicon"]["size"] = 24
	E.db["unitframe"]["units"]["target"]["raidicon"]["yOffset"] = 25
	E.db["unitframe"]["units"]["target"]["smartAuraPosition"] = "FLUID_DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["target"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["target"]["width"] = 185
  --Target Custom Text
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["fontOutline"] = "THICKOUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["size"] = 20
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:medium]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["xOffset"] = 114
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Name"]["yOffset"] = 42
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["xOffset"] = -70
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-Black"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["fontOutline"] = "THICKOUTLINE"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["size"] = 11
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["target"]["customTexts"]["TKUI:Status"]["yOffset"] = 28
	E.db["unitframe"]["units"]["target"]["infoPanel"]["enable"] = false
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
	E.db["unitframe"]["units"]["targettarget"]["raidicon"]["enable"] = false
	E.db["unitframe"]["units"]["targettarget"]["smartAuraPosition"] = "DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["targettarget"]["width"] = 58
	--Target Target Custom Text
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["size"] = 12
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor]>[name:abbrev:short][TKUI:Health]"
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["targettarget"]["customTexts"]["TKUI:Name"]["yOffset"] = 0
	--Focus
	E.db["unitframe"]["units"]["focus"]["CombatIcon"]["enable"] = false
	E.db["unitframe"]["units"]["focus"]["aurabar"]["detachedWidth"] = 270
	E.db["unitframe"]["units"]["focus"]["aurabar"]["maxBars"] = 6
	E.db["unitframe"]["units"]["focus"]["aurabar"]["maxDuration"] = 300
	E.db["unitframe"]["units"]["focus"]["buffs"]["anchorPoint"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["buffs"]["countFont"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["focus"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["focus"]["buffs"]["countFontSize"] = 8
	E.db["unitframe"]["units"]["focus"]["buffs"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["buffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["focus"]["buffs"]["priority"] = "Blacklist,Personal,nonPersonal,RaidBuffsElvUI"
	E.db["unitframe"]["units"]["focus"]["buffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["focus"]["buffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["focus"]["buffs"]["xOffset"] = 65
	E.db["unitframe"]["units"]["focus"]["buffs"]["yOffset"] = 25
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTextFont"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTextFont"]["font"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTextFont"]["fontSize"] = 15
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTimeFont"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTimeFont"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["focus"]["castbar"]["customTimeFont"]["fontSize"] = 18
	E.db["unitframe"]["units"]["focus"]["castbar"]["height"] = 28
	E.db["unitframe"]["units"]["focus"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["focus"]["castbar"]["iconAttachedTo"] = "Castbar"
	E.db["unitframe"]["units"]["focus"]["castbar"]["iconPosition"] = "CENTER"
	E.db["unitframe"]["units"]["focus"]["castbar"]["spark"] = false
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["b"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["g"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["textColor"]["r"] = 0.98039215686275
	E.db["unitframe"]["units"]["focus"]["castbar"]["width"] = 53
	E.db["unitframe"]["units"]["focus"]["debuffs"]["anchorPoint"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["attachTo"] = "BUFFS"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["focus"]["debuffs"]["countFont"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["focus"]["debuffs"]["priority"] = "Blacklist,Personal,RaidDebuffs,CCDebuffs,Friendly:Dispellable"
	E.db["unitframe"]["units"]["focus"]["debuffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["focus"]["debuffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["focus"]["debuffs"]["xOffset"] = 128
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
	E.db["unitframe"]["units"]["focus"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["focus"]["name"]["xOffset"] = 224
	E.db["unitframe"]["units"]["focus"]["name"]["yOffset"] = -84
	E.db["unitframe"]["units"]["focus"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["power"]["detachedWidth"] = 15
	E.db["unitframe"]["units"]["focus"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["focus"]["power"]["hideonnpc"] = true
	E.db["unitframe"]["units"]["focus"]["raidicon"]["attachTo"] = "RIGHT"
	E.db["unitframe"]["units"]["focus"]["raidicon"]["attachToObject"] = "Health"
	E.db["unitframe"]["units"]["focus"]["raidicon"]["size"] = 24
	E.db["unitframe"]["units"]["focus"]["raidicon"]["yOffset"] = 25
	E.db["unitframe"]["units"]["focus"]["smartAuraPosition"] = "FLUID_DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["focus"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["focus"]["width"] = 185
	--Focus Custom Text
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["fontOutline"] = "THICKOUTLINE"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["size"] = 20
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name:abbrev:medium]"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["xOffset"] = -114
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Name"]["yOffset"] = 42
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["xOffset"] = 70
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["size"] = 11
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["focus"]["customTexts"]["TKUI:Status"]["yOffset"] = 28
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
	E.db["unitframe"]["units"]["focustarget"]["raidicon"]["enable"] = false
	E.db["unitframe"]["units"]["focustarget"]["smartAuraPosition"] = "DEBUFFS_ON_BUFFS"
	E.db["unitframe"]["units"]["focustarget"]["width"] = 58
	--Focus Target Customn Text
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["size"] = 12
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["text_format"] = "[TKUI:Health] [namecolor][name:abbrev:short]<"
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["focustarget"]["customTexts"]["TKUI:Name"]["yOffset"] = 0
  --Party
	E.db["unitframe"]["units"]["party"]["buffIndicator"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["buffIndicator"]["size"] = 18
	E.db["unitframe"]["units"]["party"]["buffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["party"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["party"]["buffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["party"]["buffs"]["perrow"] = 1
	E.db["unitframe"]["units"]["party"]["buffs"]["priority"] = "Blacklist"
	E.db["unitframe"]["units"]["party"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["party"]["buffs"]["yOffset"] = 25
	E.db["unitframe"]["units"]["party"]["classbar"]["height"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["debuffs"]["perrow"] = 3
	E.db["unitframe"]["units"]["party"]["debuffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["party"]["disableMouseoverGlow"] = true
	E.db["unitframe"]["units"]["party"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["party"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["party"]["groupSpacing"] = 1
	E.db["unitframe"]["units"]["party"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["party"]["health"]["position"] = "BOTTOM"
	E.db["unitframe"]["units"]["party"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["health"]["yOffset"] = 2
	E.db["unitframe"]["units"]["party"]["height"] = 5
	E.db["unitframe"]["units"]["party"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["party"]["infoPanel"]["height"] = 12
	E.db["unitframe"]["units"]["party"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["orientation"] = "MIDDLE"
	E.db["unitframe"]["units"]["party"]["phaseIndicator"]["scale"] = 0.5
	E.db["unitframe"]["units"]["party"]["portrait"]["camDistanceScale"] = 1
	E.db["unitframe"]["units"]["party"]["portrait"]["fullOverlay"] = true
	E.db["unitframe"]["units"]["party"]["portrait"]["overlayAlpha"] = 1
	E.db["unitframe"]["units"]["party"]["portrait"]["yOffset"] = -0.04
	E.db["unitframe"]["units"]["party"]["power"]["attachTextTo"] = "Power"
	E.db["unitframe"]["units"]["party"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["party"]["power"]["position"] = "BOTTOMRIGHT"
	E.db["unitframe"]["units"]["party"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["party"]["power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["party"]["power"]["yOffset"] = 2
	E.db["unitframe"]["units"]["party"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["party"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["raidicon"]["size"] = 14
	E.db["unitframe"]["units"]["party"]["raidicon"]["xOffset"] = -14
	E.db["unitframe"]["units"]["party"]["raidicon"]["yOffset"] = 22
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["fontSize"] = 16
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["size"] = 20
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["stack"]["color"]["b"] = 1
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["stack"]["color"]["g"] = 1
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["stack"]["yOffset"] = 0
	E.db["unitframe"]["units"]["party"]["rdebuffs"]["yOffset"] = 18
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["position"] = "CENTER"
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["size"] = 26
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["xOffset"] = -2
	E.db["unitframe"]["units"]["party"]["readycheckIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["party"]["roleIcon"]["enable"] = false
	E.db["unitframe"]["units"]["party"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["party"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["party"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["party"]["sortMethod"] = "NAME"
	E.db["unitframe"]["units"]["party"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["party"]["verticalSpacing"] = 50
	E.db["unitframe"]["units"]["party"]["width"] = 90
	--Party Custom Text
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["size"] = 14
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["text_format"] = "[TKUI:GroupLead]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["xOffset"] = 15
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Leader"]["yOffset"] = -3
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["size"] = 14
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][TKUI:Name]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Name"]["yOffset"] = -3
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["xOffset"] = 4
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["size"] = 14
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["xOffset"] = -15
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Role"]["yOffset"] = -3
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["size"] = 10
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["party"]["customTexts"]["TKUI:Status"]["yOffset"] = 18
  --Raid 40
	E.db["unitframe"]["units"]["raid40"]["buffIndicator"]["enable"] = false
	E.db["unitframe"]["units"]["raid40"]["buffIndicator"]["size"] = 18
	E.db["unitframe"]["units"]["raid40"]["buffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["raid40"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid40"]["buffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["raid40"]["buffs"]["perrow"] = 1
	E.db["unitframe"]["units"]["raid40"]["buffs"]["priority"] = "Blacklist"
	E.db["unitframe"]["units"]["raid40"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["raid40"]["buffs"]["yOffset"] = 25
	E.db["unitframe"]["units"]["raid40"]["classbar"]["height"] = 3
	E.db["unitframe"]["units"]["raid40"]["debuffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["raid40"]["disableMouseoverGlow"] = true
	E.db["unitframe"]["units"]["raid40"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["raid40"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["raid40"]["groupSpacing"] = 1
	E.db["unitframe"]["units"]["raid40"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["raid40"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid40"]["height"] = 5
	E.db["unitframe"]["units"]["raid40"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["raid40"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid40"]["phaseIndicator"]["scale"] = 0.5
	E.db["unitframe"]["units"]["raid40"]["portrait"]["camDistanceScale"] = 1
	E.db["unitframe"]["units"]["raid40"]["portrait"]["fullOverlay"] = true
	E.db["unitframe"]["units"]["raid40"]["portrait"]["overlayAlpha"] = 1
	E.db["unitframe"]["units"]["raid40"]["portrait"]["yOffset"] = -0.04
	E.db["unitframe"]["units"]["raid40"]["power"]["attachTextTo"] = "Power"
	E.db["unitframe"]["units"]["raid40"]["power"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["raid40"]["power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["raid40"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["raid40"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["raidicon"]["size"] = 14
	E.db["unitframe"]["units"]["raid40"]["raidicon"]["xOffset"] = -14
	E.db["unitframe"]["units"]["raid40"]["raidicon"]["yOffset"] = 22
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["fontSize"] = 16
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["size"] = 20
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["stack"]["color"]["b"] = 1
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["stack"]["color"]["g"] = 1
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["stack"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["yOffset"] = 18
	E.db["unitframe"]["units"]["raid40"]["readycheckIcon"]["position"] = "CENTER"
	E.db["unitframe"]["units"]["raid40"]["readycheckIcon"]["size"] = 26
	E.db["unitframe"]["units"]["raid40"]["readycheckIcon"]["xOffset"] = -2
	E.db["unitframe"]["units"]["raid40"]["readycheckIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["raid40"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid40"]["sortMethod"] = "NAME"
	E.db["unitframe"]["units"]["raid40"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["verticalSpacing"] = 50
	E.db["unitframe"]["units"]["raid40"]["width"] = 90
	--Raid40 Custom Text
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["size"] = 14
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["text_format"] = "[TKUI:GroupLead]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["xOffset"] = 15
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Leader"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["size"] = 14
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][TKUI:Name]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Name"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["xOffset"] = 4
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["size"] = 14
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["xOffset"] = -15
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Role"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["size"] = 8
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid40"]["customTexts"]["TKUI:Status"]["yOffset"] = 18
  -- Basic Raid Frame setup
	E.db["unitframe"]["units"]["raid"]["buffIndicator"]["enable"] = false
	E.db["unitframe"]["units"]["raid"]["buffIndicator"]["size"] = 18
	E.db["unitframe"]["units"]["raid"]["buffs"]["clickThrough"] = true
	E.db["unitframe"]["units"]["raid"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid"]["buffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["raid"]["buffs"]["perrow"] = 1
	E.db["unitframe"]["units"]["raid"]["buffs"]["priority"] = "Blacklist"
	E.db["unitframe"]["units"]["raid"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["raid"]["buffs"]["yOffset"] = 25
	E.db["unitframe"]["units"]["raid"]["classbar"]["height"] = 3
	E.db["unitframe"]["units"]["raid"]["debuffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["raid"]["disableMouseoverGlow"] = true
	E.db["unitframe"]["units"]["raid"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["raid"]["groupBy"] = "ROLE"
	E.db["unitframe"]["units"]["raid"]["groupSpacing"] = 1
	E.db["unitframe"]["units"]["raid"]["growthDirection"] = "DOWN_LEFT"
	E.db["unitframe"]["units"]["raid"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid"]["height"] = 5
	E.db["unitframe"]["units"]["raid"]["horizontalSpacing"] = 24
	E.db["unitframe"]["units"]["raid"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["raid"]["phaseIndicator"]["scale"] = 0.5
	E.db["unitframe"]["units"]["raid"]["portrait"]["camDistanceScale"] = 1
	E.db["unitframe"]["units"]["raid"]["portrait"]["fullOverlay"] = true
	E.db["unitframe"]["units"]["raid"]["portrait"]["overlayAlpha"] = 1
	E.db["unitframe"]["units"]["raid"]["portrait"]["yOffset"] = -0.04
	E.db["unitframe"]["units"]["raid"]["power"]["attachTextTo"] = "Power"
	E.db["unitframe"]["units"]["raid"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["raid"]["power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["raidRoleIcons"]["enable"] = false
	E.db["unitframe"]["units"]["raid"]["raidWideSorting"] = true
	E.db["unitframe"]["units"]["raid"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["raidicon"]["size"] = 14
	E.db["unitframe"]["units"]["raid"]["raidicon"]["xOffset"] = -14
	E.db["unitframe"]["units"]["raid"]["raidicon"]["yOffset"] = 22
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["enable"] = false
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["fontSize"] = 16
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["size"] = 20
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["stack"]["color"]["b"] = 1
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["stack"]["color"]["g"] = 1
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["stack"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["rdebuffs"]["yOffset"] = 18
	E.db["unitframe"]["units"]["raid"]["readycheckIcon"]["position"] = "CENTER"
	E.db["unitframe"]["units"]["raid"]["readycheckIcon"]["size"] = 26
	E.db["unitframe"]["units"]["raid"]["readycheckIcon"]["xOffset"] = -2
	E.db["unitframe"]["units"]["raid"]["readycheckIcon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["enable"] = false
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["position"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["size"] = 8
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["xOffset"] = -9
	E.db["unitframe"]["units"]["raid"]["roleIcon"]["yOffset"] = -1
	E.db["unitframe"]["units"]["raid"]["sortMethod"] = "NAME"
	E.db["unitframe"]["units"]["raid"]["threatStyle"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["verticalSpacing"] = 50
	E.db["unitframe"]["units"]["raid"]["width"] = 90
	--Raid Custom Text
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["size"] = 14
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["text_format"] = "[TKUI:GroupLead]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["xOffset"] = 15
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Leader"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["size"] = 14
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][TKUI:Name]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Name"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["justifyH"] = "RIGHT"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["size"] = 15
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["xOffset"] = 4
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["size"] = 14
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["text_format"] = "[TKUI:RoleIcon]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["xOffset"] = -15
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Role"]["yOffset"] = -3
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["enable"] = true
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["fontOutline"] = "NONE"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["size"] = 8
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["text_format"] = "[TKUI:Status]"
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["xOffset"] = 0
	E.db["unitframe"]["units"]["raid"]["customTexts"]["TKUI:Status"]["yOffset"] = 18
  --Tank
  E.db["unitframe"]["units"]["tank"]["targetsGroup"]["enable"] = false
  E.db["unitframe"]["units"]["tank"]["enable"] = false
	E.db["unitframe"]["units"]["assist"]["enable"] = false
  --Boss
	E.db["unitframe"]["units"]["boss"]["buffIndicator"]["enable"] = false
	E.db["unitframe"]["units"]["boss"]["buffs"]["anchorPoint"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["boss"]["buffs"]["attachTo"] = "POWER"
	E.db["unitframe"]["units"]["boss"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["boss"]["buffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["boss"]["buffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["boss"]["buffs"]["sizeOverride"] = 24
	E.db["unitframe"]["units"]["boss"]["buffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["boss"]["buffs"]["xOffset"] = 118
	E.db["unitframe"]["units"]["boss"]["buffs"]["yOffset"] = 68
	E.db["unitframe"]["units"]["boss"]["castbar"]["height"] = 20
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconSize"] = 48
	E.db["unitframe"]["units"]["boss"]["castbar"]["iconXOffset"] = -2
	E.db["unitframe"]["units"]["boss"]["castbar"]["textColor"]["b"] = 1
	E.db["unitframe"]["units"]["boss"]["castbar"]["textColor"]["g"] = 1
	E.db["unitframe"]["units"]["boss"]["castbar"]["textColor"]["r"] = 1
	E.db["unitframe"]["units"]["boss"]["castbar"]["width"] = 185
	E.db["unitframe"]["units"]["boss"]["debuffs"]["anchorPoint"] = "TOPLEFT"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["attachTo"] = "HEALTH"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["boss"]["debuffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["boss"]["debuffs"]["perrow"] = 5
	E.db["unitframe"]["units"]["boss"]["debuffs"]["sizeOverride"] = 24
	E.db["unitframe"]["units"]["boss"]["debuffs"]["xOffset"] = 118
	E.db["unitframe"]["units"]["boss"]["debuffs"]["yOffset"] = -10
	E.db["unitframe"]["units"]["boss"]["disableFocusGlow"] = true
	E.db["unitframe"]["units"]["boss"]["disableMouseoverGlow"] = true
	E.db["unitframe"]["units"]["boss"]["disableTargetGlow"] = true
	E.db["unitframe"]["units"]["boss"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["height"] = 7
	E.db["unitframe"]["units"]["boss"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["orientation"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["boss"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["boss"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["raidicon"]["size"] = 24
	E.db["unitframe"]["units"]["boss"]["raidicon"]["xOffset"] = -28
	E.db["unitframe"]["units"]["boss"]["raidicon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["boss"]["spacing"] = 70
	E.db["unitframe"]["units"]["boss"]["width"] = 185
	--Boss Custom Text
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["fontOutline"] = "THICKOUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["size"] = 22
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name][shortclassification]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["xOffset"] = 115
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Name"]["yOffset"] = 25
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["size"] = 16
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["xOffset"] = 10
	E.db["unitframe"]["units"]["boss"]["customTexts"]["TKUI:Power"]["yOffset"] = 10
	--Arena
	E.db["unitframe"]["units"]["arena"]["buffs"]["anchorPoint"] = "BOTTOMLEFT"
	E.db["unitframe"]["units"]["arena"]["buffs"]["attachTo"] = "POWER"
	E.db["unitframe"]["units"]["arena"]["buffs"]["countFont"] = "m5x7"
	E.db["unitframe"]["units"]["arena"]["buffs"]["countFontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["arena"]["buffs"]["countFontSize"] = 16
	E.db["unitframe"]["units"]["arena"]["buffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["arena"]["buffs"]["perrow"] = 8
	E.db["unitframe"]["units"]["arena"]["buffs"]["priority"] = "Blacklist,CastByUnit,Dispellable,Whitelist,RaidBuffsElvUI"
	E.db["unitframe"]["units"]["arena"]["buffs"]["sizeOverride"] = 20
	E.db["unitframe"]["units"]["arena"]["buffs"]["spacing"] = 2
	E.db["unitframe"]["units"]["arena"]["buffs"]["yOffset"] = -1
	E.db["unitframe"]["units"]["arena"]["castbar"]["height"] = 20
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconAttached"] = false
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconSize"] = 48
	E.db["unitframe"]["units"]["arena"]["castbar"]["iconXOffset"] = -2
	E.db["unitframe"]["units"]["arena"]["castbar"]["textColor"]["b"] = 1
	E.db["unitframe"]["units"]["arena"]["castbar"]["textColor"]["g"] = 1
	E.db["unitframe"]["units"]["arena"]["castbar"]["textColor"]["r"] = 1
	E.db["unitframe"]["units"]["arena"]["castbar"]["width"] = 185
	E.db["unitframe"]["units"]["arena"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
	E.db["unitframe"]["units"]["arena"]["debuffs"]["countFont"] = "Barlow-SemiBold"
	E.db["unitframe"]["units"]["arena"]["debuffs"]["desaturate"] = true
	E.db["unitframe"]["units"]["arena"]["debuffs"]["enable"] = false
	E.db["unitframe"]["units"]["arena"]["debuffs"]["maxDuration"] = 0
	E.db["unitframe"]["units"]["arena"]["debuffs"]["perrow"] = 4
	E.db["unitframe"]["units"]["arena"]["debuffs"]["priority"] = "Blacklist,Boss,Personal,RaidDebuffs,CastByUnit,Whitelist"
	E.db["unitframe"]["units"]["arena"]["debuffs"]["sizeOverride"] = 18
	E.db["unitframe"]["units"]["arena"]["debuffs"]["yOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["health"]["text_format"] = ""
	E.db["unitframe"]["units"]["arena"]["height"] = 7
	E.db["unitframe"]["units"]["arena"]["infoPanel"]["height"] = 16
	E.db["unitframe"]["units"]["arena"]["name"]["text_format"] = ""
	E.db["unitframe"]["units"]["arena"]["power"]["height"] = 4
	E.db["unitframe"]["units"]["arena"]["power"]["text_format"] = ""
	E.db["unitframe"]["units"]["arena"]["pvpTrinket"]["enable"] = false
	E.db["unitframe"]["units"]["arena"]["pvpTrinket"]["size"] = 34
	E.db["unitframe"]["units"]["arena"]["pvpclassificationindicator"]["position"] = "TOPRIGHT"
	E.db["unitframe"]["units"]["arena"]["raidicon"]["attachTo"] = "LEFT"
	E.db["unitframe"]["units"]["arena"]["raidicon"]["size"] = 24
	E.db["unitframe"]["units"]["arena"]["raidicon"]["xOffset"] = -28
	E.db["unitframe"]["units"]["arena"]["raidicon"]["yOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["spacing"] = 70
	E.db["unitframe"]["units"]["arena"]["width"] = 185
	E.db["unitframe"]["units"]["assist"]["enable"] = false
	--Arena Custom Text
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["enable"] = true
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["font"] = "Barlow-Bold"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["fontOutline"] = "OUTLINE"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["justifyH"] = "LEFT"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["size"] = 16
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["text_format"] = "[namecolor][name][shortclassification]"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["xOffset"] = -2
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Name"]["yOffset"] = 10
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["attachTextTo"] = "Health"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["enable"] = true
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["font"] = "m5x7"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["fontOutline"] = "MONOCHROMEOUTLINE"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["justifyH"] = "CENTER"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["size"] = 16
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["text_format"] = "[perpp]"
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["xOffset"] = 0
	E.db["unitframe"]["units"]["arena"]["customTexts"]["TKUI:Power"]["yOffset"] = 1


	-- MOVERS -----------------------------------------------------------------
	-- Variables
	E.db["movers"]["ElvAB_1"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+1)
	E.db["movers"]["ElvAB_2"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+25)
	E.db["movers"]["ElvAB_3"] = "BOTTOM,ElvUIParent,BOTTOM,0,33"
	--Varible MOVERS
	----Player
	E.db["movers"]["ElvUF_PlayerMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..playerFrame
	E.db["movers"]["DebuffsMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+100)
	E.db["movers"]["ClassBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+51)
	E.db["movers"]["PlayerPowerBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+51)
	E.db["movers"]["AltPowerBarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame-35)
	----Action Bar Panel
	E.db["movers"]["DTPanelTKUIMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame)
	----Pet
	if localizedClass == "Warlock" or englishClass == "WARLOCK" then
		E.db["movers"]["ElvUF_PetMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+55)
	else
		E.db["movers"]["ElvUF_PetMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..(playerFrame+51)
	end
	E.db["movers"]["ElvUF_PetCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0"..(playerFrame-46)

	----Target
	E.db["movers"]["ElvUF_TargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,292,"..(playerFrame-7)
	E.db["movers"]["ElvUF_TargetCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,350,"..(playerFrame+54)
	----TargetTarget
	E.db["movers"]["ElvUF_TargetTargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,344,"..(playerFrame+3)
	----Focus
	E.db["movers"]["ElvUF_FocusMover"] = "BOTTOM,ElvUIParent,BOTTOM,-292,"..(playerFrame-7)
	E.db["movers"]["ElvUF_FocusTargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,-346,"..(playerFrame+3)
	E.db["movers"]["ElvUF_FocusCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,-350,"..(playerFrame+54)

	----Groups
	E.db["movers"]["ElvUF_PartyMover"] = "RIGHT,ElvUIParent,RIGHT,-475," .. (partyFrame)
	E.db["movers"]["ElvUF_RaidMover"] = "RIGHT,ElvUIParent,RIGHT,-475," .. (partyFrame)
	E.db["movers"]["ElvUF_Raid40Mover"] = "RIGHT,ElvUIParent,RIGHT,-475," .. (partyFrame)
	----Boss
	E.db["movers"]["BossHeaderMover"] = "LEFT,ElvUIParent,LEFT,-868,".."-"..(partyFrame)
	----Arena
	E.db["movers"]["ArenaHeaderMover"] = "LEFT,ElvUIParent,LEFT,-967,".."-"..(partyFrame)
	----Misc
	E.db["movers"]["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["ZoneAbility"] = "BOTTOM,ElvUIParent,BOTTOM,0,"..buttonFrame
	E.db["movers"]["LossControlMover"] = "CENTER,ElvUIParent,CENTER,0,0"
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

	-- local function CreateStyleFilter(name)
	-- 	local filter = {} --Create filter table
	-- 	NP:StyleFilterCopyDefaults(filter) --Initialize new filter with default options
	-- 	E.global["nameplate"]["filters"][name] = filter --Add new filter to database
	--
	-- 	--Add the "Enable" option to current profile
	-- 	if not E.db.nameplates then E.db.nameplates = {} end
	-- 	if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
	-- 	if not E.db.nameplates.filters[name] then E.db.nameplates.filters[name] = {} end
	-- 	if not E.db.nameplates.filters[name].triggers then E.db.nameplates.filters[name].triggers = {} end
	-- 	E.db["nameplates"]["filters"][name]["triggers"]["enable"] = true
	-- end

	-- --Nameplate Filters
	-- CreateStyleFilter("TKUI:Enemy_Casting")
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["priority"] = 1
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["actions"]["alpha"] = 100
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["actions"]["scale"] = 1.2
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["casting"]["isCasting"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["casting"]["isChanneling"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enemyNPC"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enemyPlayer"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_Casting"]["triggers"]["nameplateType"]["enable"] = true
	-- CreateStyleFilter("TKUI:Enemy_NonTarget")
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["priority"] = 2
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["actions"]["alpha"] = 75
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enemyNPC"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enemyPlayer"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["notTarget"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Enemy_NonTarget"]["triggers"]["nameplateType"]["enable"] = true
	-- CreateStyleFilter("TKUI:Friendly_NonTarget")
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["priority"] = 2
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["actions"]["alpha"] = 50
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["friendlyNPC"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["friendlyPlayer"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["notTarget"] = true
	-- E.global["nameplate"]["filters"]["TKUI:Friendly_NonTarget"]["triggers"]["nameplateType"]["enable"] = true
	--
	-- E.db["nameplates"]["filters"]["ElvUI_Explosives"]["triggers"]["enable"] = false
	-- E.db["nameplates"]["filters"]["ElvUI_NonTarget"]["triggers"]["enable"] = false
	-- E.db["nameplates"]["filters"]["ElvUI_Target"]["triggers"]["enable"] = false
	-- E.db["nameplates"]["filters"]["ElvUI_Boss"]["triggers"]["enable"] = false
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
		E.db[TKUIPlugin].targetfocusScale = 0.9
		E.db[TKUIPlugin].groupScale = 0.8
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
			-- [5] = function()
			-- 	PluginInstallFrame.SubTitle:SetText("Details")
			-- 	if IsAddOnLoaded("Details") then --Make sure the User has Details installed.
			-- 			PluginInstallFrame.Desc1:SetText("Import TKUI Details profile. A new profile called TKUI will be created. If you already have the TKUI profile it will be updated.")
			-- 			PluginInstallFrame.Option1:Show()
			-- 			PluginInstallFrame.Option1:SetScript("OnClick", function() TKUI:SetupDetails() end)
			-- 			PluginInstallFrame.Option1:SetText("Setup Details")
			-- 	else
			-- 		PluginInstallFrame.Desc1:SetText("|cFFff8c00Oops, it looks like you don't have Details installed!|r")
			-- 		PluginInstallFrame.Desc2:SetText("Details is recommended for use with TKUI")
			-- 	end
			-- end,
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
			  -- [5] = "TKUI Details Settings",
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
