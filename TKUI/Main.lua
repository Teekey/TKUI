local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TKUI = E:NewModule("TKUI", 'AceConsole-3.0', 'AceEvent-3.0')
local UF = E:GetModule("UnitFrames")
local EP = LibStub("LibElvUIPlugin-1.0")
local oUF_TKUI = {}
local addon, ns = ...
local oUF = ns.oUF
TKUI.Config = {}
-- Lua functions
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"
-- Sanity check for fresh profiles
if E.db[TKUIPlugin] == nil then
  E.db[TKUIPlugin] = {}
end
-- WoW API / Variables
local _G = _G


local hidePlayerHP = CreateFrame("Frame")
hidePlayerHP:RegisterEvent("PLAYER_ENTERING_WORLD")
hidePlayerHP:SetScript("OnEvent", function(self, event)
  self:UnregisterEvent(event)
  ElvUF_Player.Health:SetAlpha(0)
  ElvUF_Player.Power:SetAlpha(0)
  -- ElvUF_Player:SetHeight(0)
end)

function GetNumBuffs()
  local a=0; while UnitBuff("player", a+1) do a=a+1 end
  return a;
end

local buffsBar = CreateFrame("Frame")
buffsBar:RegisterEvent("PLAYER_ENTERING_WORLD")
buffsBar:RegisterEvent("UNIT_AURA", "player")
buffsBar:RegisterUnitEvent("UNIT_AURA", "player");
buffsBar:SetScript("OnEvent", function(self, event)

  local totalBuffs=0; while UnitBuff("player", totalBuffs+1) do totalBuffs=totalBuffs+1 end
  for i=1, totalBuffs do
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:ClearAllPoints()
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:SetPoint("CENTER", "ElvUIPlayerBuffsAuraButton"..i, "CENTER", 0, 0)
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:SetFrameStrata("LOW")
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:SetHeight(42)
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:SetWidth(60)
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar:SetOrientation("VERTICAL")
    _G["ElvUIPlayerBuffsAuraButton"..i].statusBar.backdrop:SetBackdropColor(0, 0, 0, .25)
  end
end)

local debbuffsBar = CreateFrame("Frame")
debbuffsBar:RegisterEvent("PLAYER_ENTERING_WORLD")
debbuffsBar:RegisterEvent("UNIT_AURA", "player")
debbuffsBar:RegisterUnitEvent("UNIT_AURA", "player");
debbuffsBar:SetScript("OnEvent", function(self, event)
  local totalDebuffs=0; while UnitDebuff("player", totalDebuffs+1) do totalDebuffs=totalDebuffs+1 end
  for i=1, totalDebuffs do

    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:ClearAllPoints()
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetPoint("CENTER", "ElvUIPlayerDebuffsAuraButton"..i, "CENTER", 0, 0)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetFrameStrata("LOW")
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetHeight(44)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetWidth(62)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetOrientation("VERTICAL")
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetReverseFill("TRUE")
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetFillStyle("STANDARD_NO_RANGE_FILL")
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetStatusBarColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.LeftEdge:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.TopLeftCorner:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.RightEdge:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.TopEdge:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.BottomEdge:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.TopLeftCorner:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.TopRightCorner:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.BottomLeftCorner:SetVertexColor(0, 0, 0, 1)
    _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop.BottomRightCorner:SetVertexColor(0, 0, 0, 1)
    local DispellColor = {
      ['Magic']	= {.2, .6, 1},
      ['Curse']	= {.6, 0, 1},
      ['Disease']	= {.6, .4, 0},
      ['Poison']	= {0, .6, 0},
      ['None'] = { 1, 0, 0}
    }
    local _, _, _, debuffType, _, _, unitCaster = UnitDebuff("player", i)
    local localizedClass, englishClass, classIndex = UnitClass("player");
    local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
    if unitCaster == "player" then
      _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop:SetBackdropColor(rPerc, gPerc, bPerc, 1)
    elseif debuffType == nil then
      local color = DispellColor['None']
      _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop:SetBackdropColor(color[1], color[2], color[3], 1)
    else
      local color = DispellColor[debuffType]
      _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar.backdrop:SetBackdropColor(color[1], color[2], color[3], 1)

    end

    -- _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetReverseFill("FALSE")
    -- _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetFillStyle("STANDARD_NO_RANGE_FILL")
    --   local DispellColor = {
    --   	['Magic']	= {.2, .6, 1},
    --   	['Curse']	= {.6, 0, 1},
    --   	['Disease']	= {.6, .4, 0},
    --   	['Poison']	= {0, .6, 0},
    --   	['None'] = { .23, .23, .23}
    --   }
    --   local _, _, _, debuffType = UnitDebuff("player", i)
    --   if debuffType == nil then
    --   local color = DispellColor['None']
    --   _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetStatusBarColor(color[1], color[2], color[3], 1)
    -- else
    --   local color = DispellColor[debuffType]
    --   _G["ElvUIPlayerDebuffsAuraButton"..i].statusBar:SetStatusBarColor(color[1], color[2], color[3], 1)
    -- end

  end
end)

local hidePartyHP = CreateFrame("Frame")
hidePartyHP:RegisterEvent("PLAYER_ENTERING_WORLD")
hidePartyHP:SetScript("OnEvent", function(self, event)
  self:UnregisterEvent(event)
  for i=1, 1 do
    for j=1, 5 do
      -- local PartyFrame = _G["ElvUF_PartyGroup"..i.."UnitButton"..j]
      _G["ElvUF_PartyGroup"..i.."UnitButton"..j].Health:SetAlpha(0)
      _G["ElvUF_PartyGroup"..i.."UnitButton"..j].Power:SetAlpha(0)
    end
  end

  for i=1, 1 do
    for j=1, 40 do
      -- local PartyFrame = _G["ElvUF_PartyGroup"..i.."UnitButton"..j]
      _G["ElvUF_Raid40Group"..i.."UnitButton"..j].Health:SetAlpha(0)
      _G["ElvUF_Raid40Group"..i.."UnitButton"..j].Power:SetAlpha(0)
    end
  end

  for i=1, 1 do
    for j=1, 25 do
      -- local PartyFrame = _G["ElvUF_PartyGroup"..i.."UnitButton"..j]
      _G["ElvUF_RaidGroup"..i.."UnitButton"..j].Health:SetAlpha(0)
      _G["ElvUF_RaidGroup"..i.."UnitButton"..j].Power:SetAlpha(0)
    end
  end
  -- for i = 1,5 do
  --   _G[("ElvUF_PartyGroup1UnitButton%i_HealthBar"):SetAlpha(0)]
  --   -- ElvUF_PartyGroup1UnitButton..i.._HealthBar:SetAlpha(0)
  --   -- ElvUF_PartyGroup1UnitButton1..i.._PowerBar:SetAlpha(0)
  -- end
  -- ElvUF_Player:SetHeight(0)
end)


local t = CreateFrame("Frame")
t:RegisterEvent("PLAYER_ENTERING_WORLD")
t:RegisterEvent("PLAYER_TARGET_CHANGED")
t:RegisterEvent("PLAYER_FOCUS_CHANGED")
t:SetScript("OnEvent", function(self, event)
  self:UnregisterEvent(event)
  ElvUF_Target.Health:SetAlpha(0)
  ElvUF_Target.Power:SetAlpha(0)
  ElvUF_TargetBuffs:SetAlpha(0.75)
  ElvUF_Focus.Health:SetAlpha(0)
  ElvUF_Focus.Power:SetAlpha(0)
  ElvUF_FocusBuffs:SetAlpha(0.75)
  ElvUF_TargetTarget.Health:SetAlpha(0)
  ElvUF_FocusTarget.Health:SetAlpha(0)

  ElvUF_Target_CastBar:SetHeight(42)
  ElvUF_Target_CastBar:SetWidth(58)
  ElvUF_Target_CastBar.Icon:ClearAllPoints()
  ElvUF_Target_CastBar.Icon:SetHeight(36)
  ElvUF_Target_CastBar.Icon:SetWidth(52)
  ElvUF_Target_CastBar.Icon:SetTexCoord(0.07,0.93,0.2,0.8)
  ElvUF_Target_CastBar.Icon:SetPoint("CENTER", ElvUF_Target_CastBar, "CENTER", 0, 0);
  ElvUF_Target_CastBar.Icon.bg:ClearAllPoints()
  ElvUF_Target_CastBar.Icon.bg:SetBackdropColor(0,0,0,1);
  ElvUF_Target_CastBar.Icon.bg:SetPoint("CENTER", ElvUF_Target_CastBar, "CENTER", 0, 0);
  ElvUF_Target_CastBar.Icon.bg:SetHeight(38)
  ElvUF_Target_CastBar.Icon.bg:SetWidth(54)

  ElvUF_Target_CastBar.Text:ClearAllPoints()
  ElvUF_Target_CastBar.Text:SetPoint("LEFT", ElvUF_Target_CastBar, "RIGHT", 2, 0);
  ElvUF_Target_CastBar.Text:SetShadowOffset(2,-2)
  ElvUF_Target_CastBar.Time:ClearAllPoints()
  ElvUF_Target_CastBar.Time:SetPoint("CENTER", ElvUF_Target_CastBar.Icon, "CENTER", 0, 0);
  ElvUF_Target_CastBar.Time:SetParent(ElvUF_Target_CastBar.Holder)


  ElvUF_Focus_CastBar:SetHeight(42)
  ElvUF_Focus_CastBar:SetWidth(58)
  ElvUF_Focus_CastBar.Icon:ClearAllPoints()
  ElvUF_Focus_CastBar.Icon:SetHeight(36)
  ElvUF_Focus_CastBar.Icon:SetWidth(52)
  ElvUF_Focus_CastBar.Icon:SetTexCoord(0.07,0.93,0.2,0.8)
  ElvUF_Focus_CastBar.Icon:SetPoint("CENTER", ElvUF_Focus_CastBar, "CENTER", 0, 0);
  ElvUF_Focus_CastBar.Icon.bg:ClearAllPoints()
  ElvUF_Focus_CastBar.Icon.bg:SetBackdropColor(0,0,0,1);
  ElvUF_Focus_CastBar.Icon.bg:SetPoint("CENTER", ElvUF_Focus_CastBar, "CENTER", 0, 0);
  ElvUF_Focus_CastBar.Icon.bg:SetHeight(38)
  ElvUF_Focus_CastBar.Icon.bg:SetWidth(54)

  ElvUF_Focus_CastBar.Text:ClearAllPoints()
  ElvUF_Focus_CastBar.Text:SetPoint("RIGHT", ElvUF_Focus_CastBar, "LEFT", 2, 0);
  ElvUF_Focus_CastBar.Text:SetShadowOffset(2,-2)
  ElvUF_Focus_CastBar.Time:ClearAllPoints()
  ElvUF_Focus_CastBar.Time:SetPoint("CENTER", ElvUF_Focus_CastBar.Icon, "CENTER", 0, 0);
  ElvUF_Focus_CastBar.Time:SetParent(ElvUF_Target_CastBar.Holder)
  -- ElvUF_Target_CastBar.Time:Raise()

  -- ElvUF_Player:SetHeight(0)
end)
--

-- local movePartyHP = CreateFrame("Frame")
-- movePartyHP:RegisterEvent("PLAYER_ENTERING_WORLD")
-- movePartyHP:SetScript("OnEvent", function(self, event)
-- self:UnregisterEvent(event)
--   PartyUnitButton1:ClearAllPoints()
--   PartyUnitButton1:SetPoint("BOTTOM", ElvUF_PartyGroup1UnitButton1, "TOP", 4, 0);
--   -- PartyUnitButton2:ClearAllPoints()
--   -- PartyUnitButton2:SetPoint("BOTTOM", ElvUF_PartyGroup1UnitButton2, "TOP", 4, 0);
-- -- for i=1, 5 do
-- --     for j=1, 5 do
-- --       _G["PartyUnitButton"..i]:ClearAllPoints()
-- --       _G["PartyUnitButton"..i]:SetPoint("BOTTOM", _G["ElvUF_PartyGroup"..i.."UnitButton"..j].Health, "TOP", 2, 0);
-- --     end
-- --     --_G["ElvUF_PartyGroup"..i.."UnitButton"..j].Health
-- -- end
-- end)

-- Only for testing.

local hideBossHP = CreateFrame("Frame")
hideBossHP:RegisterEvent("PLAYER_ENTERING_WORLD")
hideBossHP:SetScript("OnEvent", function(self, event)
  self:UnregisterEvent(event)
  for i = 1, MAX_BOSS_FRAMES do
    _G["ElvUF_Boss"..i].Health:SetAlpha(0)
    _G["ElvUF_Boss"..i].Power:SetAlpha(0)
  end
end)


function TKUI:SetupDetails(windows)
  TKUI:DetailsSettings(windows)
  _detalhes:ApplyProfile("TKUI", false, false)
  PluginInstallStepComplete.message = "Details Profile Applied"
  PluginInstallStepComplete:Show()
end

E.twoPixelsPlease = false

E:RegisterModule(TKUI:GetName())
