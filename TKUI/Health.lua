local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF_TKUI = {}
local addon, ns = ...
local oUF = ns.oUF
-- Lua functions
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"

-- WoW API / Variables
local _G = _G
--oUF Text
local pairs = pairs
local ipairs = ipairs
local select = select
local tinsert = table.insert
local ceil = math.ceil
local floor = math.floor
local upper = string.upper
local strlen = string.len
local strsub = string.sub
local gmatch = string.gmatch
local match = string.match

oUF_TKUI.digitTexCoords = {
	["1"] = {9, 40},
	["2"] = {61 , 40},
	["3"] = {111, 40},
	["4"] = {159, 40},
	["5"] = {210, 40},
	["6"] = {260, 40},
	["7"] = {308, 40},
	["8"] = {359, 40},
	["9"] = {408, 40},
	["0"] = {458, 40},
	["height"] = 56,
	["texWidth"] = 512,
	["texHeight"] = 128
}

-- Colors -------------------------------------
-- Unit menu
-- oUF_TKUI.menu = function(self)
-- 	local unit = self.unit:sub(1, -2)
-- 	local cunit = self.unit:gsub("(.)", upper, 1)
--
-- 	-- Swap menus in vehicle
-- 	if self == oUF_player and cunit=="Vehicle" then cunit = "Player" end
-- 	if self == oUF_pet and cunit=="Player" then cunit = "Pet" end
--
-- 	if(unit == "party" or unit == "partypet") then
-- 		ToggleDropDownMenu(nil, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
-- 	elseif(_G[cunit.."FrameDropDown"]) then
-- 		ToggleDropDownMenu(nil, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
-- 	end
-- end
-- Thanks to HanktheTank for this code: "This is where the magic happens. Handle health update, display digit textures"
oUF_TKUI.UpdateHealth = function(self)
  local h, hMax = UnitHealth(self.unit), UnitHealthMax(self.unit)
	local status = (not UnitIsConnected(self.unit) or nil) or UnitIsGhost(self.unit) or UnitIsDead(self.unit)
  local hPerc = ("%d"):format(h / hMax * 100 + 0.5)
  local len = strlen(hPerc)
	if status then
		for i = 1, 3 do
			self.healthFill[i]:Hide()
			self.health[i]:Hide()
		end
	elseif not status then
			for i = 1, 3 do
				if i > len then
					self.health[i]:Hide()
					self.healthFill[i]:Hide()
				else
					local digit = strsub(hPerc , i, i)
					self.health[i]:SetSize(oUF_TKUI.digitTexCoords[digit][2], oUF_TKUI.digitTexCoords["height"])
					self.health[i]:SetTexCoord(oUF_TKUI.digitTexCoords[digit][1] / oUF_TKUI.digitTexCoords["texWidth"], (oUF_TKUI.digitTexCoords[digit][1] + oUF_TKUI.digitTexCoords[digit][2]) / oUF_TKUI.digitTexCoords["texWidth"], 1 / oUF_TKUI.digitTexCoords["texHeight"], (1 + oUF_TKUI.digitTexCoords["height"]) / oUF_TKUI.digitTexCoords["texHeight"])
					self.health[i]:Show()
					self.healthFill[i]:SetSize(oUF_TKUI.digitTexCoords[digit][2], oUF_TKUI.digitTexCoords["height"] * h / hMax)
					self.healthFill[i]:SetTexCoord(oUF_TKUI.digitTexCoords[digit][1] / oUF_TKUI.digitTexCoords["texWidth"], (oUF_TKUI.digitTexCoords[digit][1] + oUF_TKUI.digitTexCoords[digit][2]) / oUF_TKUI.digitTexCoords["texWidth"], (2 + 2 * oUF_TKUI.digitTexCoords["height"] - oUF_TKUI.digitTexCoords["height"] * h / hMax) / oUF_TKUI.digitTexCoords["texHeight"], (2 + 2 * oUF_TKUI.digitTexCoords["height"]) / oUF_TKUI.digitTexCoords["texHeight"])
					self.healthFill[i]:Show()
				end
			end
    --Colors
    if (E.db[TKUIPlugin].classHealth == false) and (E.db[TKUIPlugin].gradientHealth == false) then
      -- local c = E.db[TKUIPlugin].customColor
      for i = 1, 3 do
        self.healthFill[i]:SetVertexColor(1, 1, 1)
        self.health[i]:SetVertexColor(1, 1, 1)
        -- self.healthFill[i]:SetVertexColor(c.r, c.g, c.b)
        -- self.health[i]:SetVertexColor(c.r, c.g, c.b)
      end
    elseif (E.db[TKUIPlugin].classHealth == true) and (E.db[TKUIPlugin].gradientHealth == false) and UnitIsPlayer(self.unit) then
      local localizedClass, englishClass, classIndex = UnitClass(self.unit);
      local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
      for i = 1, 4 do
        self.healthFill[i]:SetVertexColor(rPerc, gPerc, bPerc)
        self.health[i]:SetVertexColor(rPerc, gPerc, bPerc)
      end
    elseif (E.db[TKUIPlugin].classHealth == true) and (E.db[TKUIPlugin].gradientHealth == false) and not UnitIsPlayer(self.unit) then
      local unitReaction = UnitReaction(self.unit, 'player');
      local reaction = ElvUF.colors.reaction[unitReaction]
      for i = 1, 3 do
        self.healthFill[5 - i]:SetVertexColor(reaction[1],reaction[2],reaction[3])
        self.health[5 - i]:SetVertexColor(reaction[1],reaction[2],reaction[3])
      end
    elseif (E.db[TKUIPlugin].classHealth == false) and (E.db[TKUIPlugin].gradientHealth == true) then
      -- local c = E.db[TKUIPlugin].customColor
      -- local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, c.r, c.g, c.b)
      local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, 1,1,1)
      for i = 1, 3 do
        self.healthFill[i]:SetVertexColor(r,g,b)
        self.health[i]:SetVertexColor(r,g,b)
      end
    elseif (E.db[TKUIPlugin].classHealth == true) and (E.db[TKUIPlugin].gradientHealth == true) and UnitIsPlayer(self.unit) then
      local localizedClass, englishClass, classIndex = UnitClass(self.unit);
      local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
      local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, rPerc, gPerc, bPerc)
      for i = 1, 3 do
        self.healthFill[i]:SetVertexColor(r,g,b)
        self.health[i]:SetVertexColor(r,g,b)
      end
    elseif (E.db[TKUIPlugin].classHealth == true) and (E.db[TKUIPlugin].gradientHealth == true) and not UnitIsPlayer(self.unit) then
      local unitReaction = UnitReaction(self.unit, 'player');
      local reaction = ElvUF.colors.reaction[unitReaction]
      local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, reaction[1],reaction[2],reaction[3])
      for i = 1, 3 do
        self.healthFill[i]:SetVertexColor(r,g,b)
        self.health[i]:SetVertexColor(r,g,b)
      end
    else
        for i = 1, 3 do
          self.healthFill[i]:SetVertexColor(1,1,1)
          self.health[i]:SetVertexColor(1,1,1)
        end
    end
    local h, hMax = UnitHealth(self.unit), UnitHealthMax(self.unit)
    local hPerc = ("%d"):format(h / hMax * 100 + 0.5)
    local len = strlen(hPerc)
    if self.unit == "player" and (len == 3) then
      self.health[1]:SetPoint("LEFT")
      self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
      self.health[3]:SetPoint("LEFT", self.health[2], "RIGHT")
    elseif self.unit == "player" and (len == 2) then
      self.health[1]:SetPoint("LEFT", 20, 0)
      self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
    elseif self.unit == "player" and (len == 1) then
      self.health[1]:SetPoint("LEFT", 40, 0)
    elseif (self.unit == "target") and (len == 3) then
      self.health[3]:SetPoint("RIGHT")
      self.health[2]:SetPoint("RIGHT", self.health[3], "LEFT")
      self.health[1]:SetPoint("RIGHT", self.health[2], "LEFT")
    elseif (self.unit == "target") and (len == 2) then
      self.health[2]:SetPoint("RIGHT")
      self.health[1]:SetPoint("RIGHT", self.health[2], "LEFT")
    elseif (self.unit == "target") and (len == 1) then
      self.health[1]:SetPoint("RIGHT")
    elseif self.unit == "focus" then
      self.health[1]:SetPoint("LEFT")
      self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
      self.health[3]:SetPoint("LEFT", self.health[2], "RIGHT")
    elseif (len == 3) then
        self.health[1]:SetPoint("LEFT")
        self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
        self.health[3]:SetPoint("LEFT", self.health[2], "RIGHT")
    elseif (len == 2) then
        self.health[1]:SetPoint("LEFT", 20, 0)
        self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
      elseif (len == 1) then
        self.health[1]:SetPoint("LEFT", 40, 0)
    end
    self.healthFill[1]:SetPoint("BOTTOM", self.health[1])
    self.healthFill[2]:SetPoint("BOTTOM", self.health[2])
    self.healthFill[3]:SetPoint("BOTTOM", self.health[3])
  end
end
-- Frame constructor -----------------------------
oUF_TKUI.HP = function(self, unit, isSingle)
  self:RegisterForClicks("AnyUp")
  self:SetScript("OnEnter", UnitFrame_OnEnter)
  self:SetScript("OnLeave", UnitFrame_OnLeave)
	-- HP%
	local health = {}
	local healthFill = {}
	local status = (not UnitIsConnected(unit) or nil) or UnitIsGhost(unit) or UnitIsDead(unit)
  if unit == "player" or unit == "target" or unit == "focus" or unit == "party" or unit == "raid" or unit == "raid40" or unit:find("boss") then
		self:RegisterEvent("UNIT_HEALTH", function(_, _, ...)
				oUF_TKUI.UpdateHealth(self)
		end)
		self:RegisterEvent("UNIT_MAXHEALTH", function(_, _, ...)
				oUF_TKUI.UpdateHealth(self)
		end)
  -- self:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, _, ...)
  --     oUF_TKUI.UpdateHealth(self)
  -- end)
	-- Health update on unit switch
		tinsert(self.__elements, oUF_TKUI.UpdateHealth)
		for i = 1, 3 do
			health[i] = self:CreateTexture(nil, "ARTWORK")
			health[i]:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\TKUIDigits.blp")
			health[i]:SetVertexColor(r, g, b)
			health[i]:Hide()
			healthFill[i] = self:CreateTexture(nil, "OVERLAY")
			healthFill[i]:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\TKUIDigits.blp")
			healthFill[i]:SetVertexColor(r, g, b)
			healthFill[i]:Hide()
		end
  	if unit == "player" then
    	health[1]:SetPoint("LEFT")
    	health[2]:SetPoint("LEFT", health[1], "RIGHT")
    	health[3]:SetPoint("LEFT", health[2], "RIGHT")
  	elseif (unit == "target") then
    	health[3]:SetPoint("RIGHT")
    	health[2]:SetPoint("RIGHT", health[3], "LEFT")
    	health[1]:SetPoint("RIGHT", health[2], "LEFT")
  	elseif unit == "focus" then
    	health[1]:SetPoint("LEFT")
    	health[2]:SetPoint("LEFT", health[1], "RIGHT")
    	health[3]:SetPoint("LEFT", health[2], "RIGHT")
  	else
    	health[1]:SetPoint("LEFT")
    	health[2]:SetPoint("LEFT", health[1], "RIGHT")
    	health[3]:SetPoint("LEFT", health[2], "RIGHT")
  	end
  	healthFill[1]:SetPoint("BOTTOM", health[1])
  	healthFill[2]:SetPoint("BOTTOM", health[2])
  	healthFill[3]:SetPoint("BOTTOM", health[3])
  	self.Range = {
  	insideAlpha = 1.0,
  	outsideAlpha = 0.35,
  	}
		self.health = health
		self.healthFill = healthFill
    	self:SetSize(120, 56)
			if status then
				for i = 1, 3 do
					healthFill[i]:Hide()
					health[i]:Hide()
			end
		end
	end
end
-- Frame creation --------------------------------
oUF:RegisterStyle("TKUI", oUF_TKUI.HP)
oUF:SetActiveStyle("TKUI")
oUF:Spawn("player", "oUF_player"):SetPoint("BOTTOM", ElvUF_Player, "TOP", 0, 4)
oUF:Spawn("target", "oUF_target"):SetPoint("BOTTOMRIGHT", ElvUF_Target, "TOPRIGHT", 0, 0)
oUF:Spawn("focus", "oUF_focus"):SetPoint("BOTTOMLEFT", ElvUF_Focus_HealthBar, "TOPLEFT", 0, 0)
local party = oUF:SpawnHeader('Party', nil, "custom [@raid6,exists][nogroup] hide;show",
'oUF-initialConfigFunction', ([[
self:SetWidth(%d)
self:SetHeight(%d)
]]):format(64, 33),
  'showPlayer', true,
  'showSolo', false,
  'showParty', true,
  'showRaid', false,
	'xoffset', 0,
	'yOffset', -16,
	'point', "TOP",
	'groupBy', 'ASSIGNEDROLE',
	'groupingOrder', 'TANK,HEALER,DAMAGER',
	'maxColumns', 8,
	'unitsPerColumn', 5,
	'columnSpacing', 26,
	'columnAnchorPoint', "RIGHT",
	'sortMethod', "NAME"
)
party:SetPoint("CENTER", ElvUF_PartyGroup1UnitButton1, "CENTER", -2, -2)
local raid = oUF:SpawnHeader('Raid', nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
'oUF-initialConfigFunction', ([[
self:SetWidth(%d)
self:SetHeight(%d)
]]):format(64, 33),
'showPlayer', true,
'showSolo', false,
'showParty', false,
'showRaid', true,
'xoffset', 0,
'yOffset', -16,
'point', "TOP",
'groupBy', 'ASSIGNEDROLE',
'groupingOrder', 'TANK,HEALER,DAMAGER',
'maxColumns', 8,
'unitsPerColumn', 5,
'columnSpacing', 26,
'columnAnchorPoint', "RIGHT",
'sortMethod', "NAME"
)
raid:SetPoint("TOPRIGHT", ElvUF_RaidGroup1UnitButton1, "TOPRIGHT", -2, 54)
local raid40 = oUF:SpawnHeader('Raid40', nil, "custom [@raid26,noexists] hide;show",
'oUF-initialConfigFunction', ([[
self:SetWidth(%d)
self:SetHeight(%d)
]]):format(64, 33),
'showPlayer', true,
'showSolo', false,
'showParty', false,
'showRaid', true,
'xoffset', 0,
'yOffset', -16,
'point', "TOP",
'groupBy', 'ASSIGNEDROLE',
'groupingOrder', 'TANK,HEALER,DAMAGER',
'maxColumns', 8,
'unitsPerColumn', 5,
'columnSpacing', 26,
'columnAnchorPoint', "RIGHT",
'sortMethod', "NAME"
)
raid40:SetPoint("TOPRIGHT", ElvUF_Raid40Group1UnitButton1, "TOPRIGHT", -2, 54)

oUF_player:SetScale(E.db[TKUIPlugin].playerScale)
oUF_target:SetScale(E.db[TKUIPlugin].targetfocusScale)
oUF_focus:SetScale(E.db[TKUIPlugin].targetfocusScale)
party:SetScale(E.db[TKUIPlugin].groupScale)
raid:SetScale(E.db[TKUIPlugin].groupScale)
raid40:SetScale(E.db[TKUIPlugin].groupScale)
