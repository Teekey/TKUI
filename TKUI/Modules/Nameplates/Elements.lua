local T, C, L = unpack(TKUI)
local _, ns = ...
local oUF = ns.oUF
local NP = T.UF

-- Extended upvalues for performance
local CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave = CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave
local unpack, pairs, format = unpack, pairs, string.format
local SetPoint, SetSize, SetFrameLevel = UIParent.SetPoint, UIParent.SetSize, UIParent.SetFrameLevel

-- Constants (moved from local variables to improve readability)
local FRAME_HEIGHT = (C.nameplate.height * 2 + 9) * T.noscalemult
local FRAME_WIDTH = C.unitframe.frame_width 
local HEALTH_HEIGHT = C.unitframe.health_height
local POWER_HEIGHT = C.unitframe.power_height
local PET_WIDTH = (FRAME_WIDTH - 7) / 2
local BOSS_WIDTH = C.unitframe.boss_width

----------------------------------------------------------------------------------------
-- Frame Configuration
----------------------------------------------------------------------------------------
function NP.ConfigureNameplate(self)
    local nameplate = C_NamePlate.GetNamePlateForUnit(self.unit)

    self:SetPoint("CENTER", nameplate, "CENTER")
    self:SetSize(C.nameplate.width * T.noscalemult, C.nameplate.height * T.noscalemult)

    self.disableMovement = true

    self:SetScript("OnUpdate", NP.UpdateNameplate)

    self.updateTimer = 0

    self:RegisterEvent("PLAYER_TARGET_CHANGED", NP.UpdateTarget, true)

    if NP.PostCreateNameplates then
        NP.PostCreateNameplates(self, self.unit)
    end
end

----------------------------------------------------------------------------------------
-- Health Bar
----------------------------------------------------------------------------------------
function NP.CreateHealthBar(self)
    local health = CreateFrame("StatusBar", nil, self)
    health:SetAllPoints(self)
    health:SetStatusBarTexture(C.media.nameplate_texture)
    health.colorTapping = true
    health.colorDisconnected = true
    health.colorClass = true
    health.colorReaction = true
    health.colorHealth = true
    health.smooth = true
    NP.CreateBorder(health)

    health.bg = health:CreateTexture(nil, "BORDER")
    health.bg:SetAllPoints()
    health.bg:SetTexture(C.media.nameplate_texture)
    health.bg.multiplier = 0.2

    health.value = health:CreateFontString(nil, "OVERLAY")
    health.value:SetFont(C.font.nameplates_health_font, C.font.nameplates_health_font_size * T.noscalemult,
        C.font.nameplates_health_font_style)
    health.value:SetShadowOffset(C.font.nameplates_health_font_shadow and 1 or 0,
        C.font.nameplates_health_font_shadow and -1 or 0)
    health.value:SetPoint("CENTER", self, "CENTER", 0 + T.noscalemult, -1 * T.noscalemult)
    self:Tag(health.value, "[NameplateHealth]")

    local events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_THREAT_SITUATION_UPDATE", "UNIT_THREAT_LIST_UPDATE"}
    for _, event in pairs(events) do
        health:RegisterEvent(event)
    end
    health:SetScript("OnEvent", function() NP.threatColor(self) end)

    health.PostUpdate = NP.HealthPostUpdate

    -- Absorb (unchanged)
    if C.raidframe.plugins_healcomm then
        local ahpb = health:CreateTexture(nil, "ARTWORK")
        ahpb:SetTexture(C.media.texture)
        ahpb:SetVertexColor(1, 1, 0, 1)
        self.HealthPrediction = {
            absorbBar = ahpb
        }
    end

    self.Health = health
end

----------------------------------------------------------------------------------------
-- Power Bar
----------------------------------------------------------------------------------------
function NP.CreatePowerBar(self)
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetStatusBarTexture(C.media.texture)
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
    self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -6 - (C.nameplate.height * T.noscalemult / 2))
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.PostUpdate = T.PreUpdatePower
    NP.CreateBorderFrame(self.Power)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture)
    self.Power.bg.multiplier = 0.2

    -- Hide Blizzard Power Bar
    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
        if not frame or frame:IsForbidden() then
            return
        end
        if frame.classNamePlatePowerBar then
            frame.classNamePlatePowerBar:Hide()
            frame.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)
end

----------------------------------------------------------------------------------------
-- Cast Bar
----------------------------------------------------------------------------------------
function NP.CreateCastBar(self)
    local castbar = CreateFrame("StatusBar", nil, self)
    castbar:SetFrameLevel(3)
    castbar:SetStatusBarTexture(C.media.texture)
    castbar:SetStatusBarColor(1, 0.8, 0)
    castbar:SetSize(C.nameplate.width * T.noscalemult, C.nameplate.height * T.noscalemult)
    castbar:SetPoint("TOP", self.Health, "BOTTOM", 0, -9 * T.noscalemult)
    NP.CreateBorder(castbar)

    castbar.bg = castbar:CreateTexture(nil, "BORDER")
    castbar.bg:SetAllPoints()
    castbar.bg:SetTexture(C.media.texture)
    castbar.bg:SetColorTexture(1, 0.8, 0, 0.2)

    castbar.PostCastStart = NP.castColor
    castbar.PostCastInterruptible = NP.castColor
    castbar.PostChannelStart = castbar.PostChannelStart
    castbar.PostCastInterruptible = castbar.PostCastInterruptible

    -- Text elements (unchanged)
    castbar.Text = castbar:CreateFontString(nil, "OVERLAY")
    castbar.Text:SetPoint("CENTER", castbar, "CENTER", 0, -.5 * T.noscalemult)
    castbar.Text:SetFont(C.font.nameplates_spell_font, C.font.nameplates_spell_size * T.noscalemult,
        C.font.nameplates_spell_style)
    castbar.Text:SetShadowOffset(C.font.nameplates_spell_shadow and 1 or 0,
        C.font.nameplates_spell_shadow and -1 or 0)
    castbar.Text:SetHeight(C.font.nameplates_spell_size)
    castbar.Text:SetJustifyH("CENTER")

    -- Icon (simplified positioning)
    local iconSize = FRAME_HEIGHT
    castbar.Button = CreateFrame("Frame", nil, castbar)
    castbar.Icon = castbar.Button:CreateTexture(nil, "ARTWORK")
    castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    castbar.Icon:SetSize(iconSize, iconSize)
    castbar.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -9 * T.noscalemult, 0)

    -- Cooldown frame
    castbar.IconCooldown = CreateFrame("Cooldown", nil, castbar.Button, "CooldownFrameTemplate")  -- Ensure it's parented to Button
    castbar.IconCooldown:SetPoint("TOPLEFT", castbar.Icon, "TOPLEFT", -2, 2)
    castbar.IconCooldown:SetPoint("BOTTOMRIGHT", castbar.Icon, "BOTTOMRIGHT", 2, -2)
    castbar.IconCooldown:SetReverse(false)
    castbar.IconCooldown:SetDrawEdge(false)  -- Ensure edges are drawn
    castbar.IconCooldown:SetSwipeColor(0, 0, 0, 0.9)  -- Ensure alpha is > 0
    castbar.IconCooldown:SetFrameLevel(castbar.Button:GetFrameLevel())  -- Set to the same level as the button

    -- Set the icon draw layer higher than the cooldown
    castbar.Icon:SetDrawLayer("ARTWORK", 2)  -- Set icon draw layer higher than cooldown
    NP.CreateBorder(castbar.Button, castbar.Icon)  -- Create border for the icon

    -- Time Text (positioned above the icon)
    castbar.Time = castbar.Button:CreateFontString(nil, "OVERLAY")
    castbar.Time:SetPoint("CENTER", castbar.Icon, "CENTER", 0, 0)
    castbar.Time:SetJustifyH("CENTER")
    castbar.Time:SetFont(C.font.nameplates_spelltime_font, C.font.nameplates_spelltime_size * T.noscalemult,
        C.font.nameplates_spelltime_style)
    castbar.Time:SetShadowOffset(C.font.nameplates_spelltime_shadow and 1 or 0,
        C.font.nameplates_spelltime_shadow and -1 or 0)

    castbar.CustomTimeText = function(self, duration)
        self.Time:SetText(duration > 600 and "∞" or format("%.1f", self.channeling and duration or self.max - duration))
    end

    self.Castbar = castbar
end

----------------------------------------------------------------------------------------
-- Name Text
----------------------------------------------------------------------------------------
function NP.CreateNameText(self)
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(C.font.nameplates_name_font, C.font.nameplates_name_font_size * T.noscalemult,
        C.font.nameplates_name_font_style)
    self.Name:SetShadowOffset(C.font.nameplates_name_font_shadow and 1 or 0,
        C.font.nameplates_name_font_shadow and -1 or 0)
    self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4 * T.noscalemult, 2 * T.noscalemult)
    self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 4 * T.noscalemult, 2 * T.noscalemult)
    self.Name:SetWordWrap(false)
    self.Name:SetJustifyH("CENTER")
    self:Tag(self.Name, "[NameplateNameColor][NameLongAbbrev]")

    self.Title = self:CreateFontString(nil, "OVERLAY")
    self.Title:SetFont(C.font.nameplates_name_font, (C.font.nameplates_name_font_size - 4) * T.noscalemult,
        C.font.nameplates_name_font_style)
    self.Title:SetShadowOffset(C.font.nameplates_name_font_shadow and 1 or 0,
        C.font.nameplates_name_font_shadow and -1 or 0)
    self.Title:SetPoint("TOP", self.Name, "BOTTOM", 0, 0)
    self.Title:SetWidth(C.nameplate.width)
    self.Title:SetWordWrap(false)
    self.Title:SetJustifyH("CENTER")       -- Center the text horizontally
    self.Title:SetTextColor(0.8, 0.8, 0.8) -- Set text color to slightly off white
    self:Tag(self.Title, "[NPCTitle]")
end

----------------------------------------------------------------------------------------
-- Auras
----------------------------------------------------------------------------------------
function NP.CreateAuras(self)
    local auras = CreateFrame("Frame", nil, self)
    auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, C.font.nameplates_font_size + 4)
    auras.initialAnchor = "BOTTOMRIGHT"
    auras["growth-y"] = "UP"
    auras["growth-x"] = "LEFT"
    auras.numDebuffs = C.nameplate.track_debuffs and 6 or 0
    auras.numBuffs = C.nameplate.track_buffs and 4 or 0
    
    local auraSize = C.nameplate.auras_size * T.noscalemult - 3
    auras:SetSize(20 + C.nameplate.width, C.nameplate.auras_size)
    auras.spacing = 8 * T.noscalemult
    auras.size = auraSize
    auras.disableMouse = true

    auras.FilterAura = NP.AurasCustomFilter
    auras.PostCreateButton = NP.AurasPostCreateIcon
    auras.PostUpdateButton = NP.AurasPostUpdateIcon

    self.Auras = auras
end

----------------------------------------------------------------------------------------
-- Target Functions
----------------------------------------------------------------------------------------
function NP.CreateRaidIcon(self)
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RaidTargetIndicator:SetSize((C.nameplate.height * 2 * T.noscalemult),
        (C.nameplate.height * 2 * T.noscalemult))
    self.RaidTargetIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 0)
end

----------------------------------------------------------------------------------------
-- Quest Icon
----------------------------------------------------------------------------------------
local function UpdateQuestIconPosition(self)
    if self.Health:GetAlpha() == 0 then
        -- Health bar is hidden, position near the name
        self.QuestIcon:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
    else
        -- Health bar is visible, position above the health bar
        self.QuestIcon:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
    end
end

-- Quest Icon
function NP.CreateQuestIcon(self)
    self.QuestIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.QuestIcon:SetSize((C.nameplate.height * 1.25 * T.noscalemult), (C.nameplate.height * 1.25 * T.noscalemult))
    self.QuestIcon:Hide()

    self.QuestIcon.Text = self:CreateFontString(nil, "OVERLAY")
    self.QuestIcon.Text:SetPoint("RIGHT", self.QuestIcon, "LEFT", -1 * T.noscalemult, -1 * T.noscalemult)
    self.QuestIcon.Text:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * T.noscalemult * 1.5,
        C.font.nameplates_font_style)
    self.QuestIcon.Text:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0,
        C.font.nameplates_font_shadow and -1 or 0)

    self.QuestIcon.Item = self:CreateTexture(nil, "OVERLAY")
    self.QuestIcon.Item:SetSize((C.nameplate.height * 2 * T.noscalemult), (C.nameplate.height * 2 * T.noscalemult))

    self.QuestIcon.Item:SetPoint("RIGHT", self.Health, "LEFT", 0, 0)
    self.QuestIcon.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    if self.QuestIcon.Item:IsShown() then
        self.QuestIcon:Hide()
    else
        self.QuestIcon:Show()
    end

    UpdateQuestIconPosition(self)
end

----------------------------------------------------------------------------------------
-- Target Functions
----------------------------------------------------------------------------------------
function NP.CreateTargetGlow(self)
    self.Glow = CreateFrame("Frame", nil, self, "BackdropTemplate")
    self.Glow:SetBackdrop({
        edgeFile = C.media.glow_texture,
        edgeSize = 4 * T.noscalemult
    })
    self.Glow:SetPoint("TOPLEFT", -5 * T.noscalemult, 5 * T.noscalemult)
    self.Glow:SetPoint("BOTTOMRIGHT", 5 * T.noscalemult, -5 * T.noscalemult)
    self.Glow:SetBackdropBorderColor(0.8, 0.8, 0.8)
    self.Glow:SetFrameLevel(0)
    self.Glow:Hide()
end

function NP.CreateTargetArrows(self)
    self.RTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RTargetIndicator:SetTexture("Interface/AddOns/TKUI/Media/Textures/RTargetArrow")
    self.RTargetIndicator:SetSize(16 * T.noscalemult, 16 * T.noscalemult)
    self.RTargetIndicator:Hide()

    self.LTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.LTargetIndicator:SetTexture("Interface/AddOns/TKUI/Media/Textures/LTargetArrow")
    self.LTargetIndicator:SetSize(16 * T.noscalemult, 16 * T.noscalemult)
    self.LTargetIndicator:Hide()
end