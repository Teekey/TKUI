----------------------------------------------------------------------------------------
--	Unit Frames for TKUI
--	This module handles the creation and updating of unit frames.
--	It manages health, power, cast bars, auras, and other elements related to unit frames.
--  Based on oUF (https://www.wowace.com/projects/ouf)
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
if C.unitframe.enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF
T.oUF = oUF
local NP = {}
local LibRangeCheck = LibStub("LibRangeCheck-3.0")

-- Constants
local MIN_ALPHA, MAX_ALPHA = 0.1, 1.0
local TARGET_ALPHA, COMBAT_ALPHA, NON_COMBAT_ALPHA = 1.0, 0.8, 0.6
local MAX_DISTANCE = 60
local UPDATE_INTERVAL = 0.25

-- Cached functions
local UnitIsUnit, UnitIsFriend, UnitThreatSituation = UnitIsUnit, UnitIsFriend, UnitThreatSituation
local InCombatLockdown, UnitIsPlayer, UnitIsTapDenied = InCombatLockdown, UnitIsPlayer, UnitIsTapDenied
local UnitReaction, UnitSelectionColor = UnitReaction, UnitSelectionColor
local GetTime, unpack = GetTime, unpack

local function InitializeModule()
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGIN")
    function frame:PLAYER_REGEN_ENABLED()
        SetCVar("nameplateMotion", 0)
        local inInstance, instanceType = IsInInstance();
        if ((instanceType == 'party') or (instanceType == 'raid')) then
        else
            SetCVar("nameplateShowFriends", 1)
            -- SetCVar("UnitNameFriendlyPlayerName", 1)
        end
    end

    function frame:PLAYER_REGEN_DISABLED()
        SetCVar("nameplateMotion", 1)
        local inInstance, instanceType = IsInInstance();
        if ((instanceType == 'party') or (instanceType == 'raid')) then
        else
            SetCVar("nameplateShowFriends", 0)
            -- SetCVar("UnitNameFriendlyPlayerName", 0)
        end
    end

    function frame:PLAYER_ENTERING_WORLD()
        _G.SystemFont_NamePlate:SetFont(C.media.normal_font, 8, "OUTLINE")
        _G.SystemFont_NamePlateFixed:SetFont(C.media.normal_font, 8, "OUTLINE")
        _G.SystemFont_LargeNamePlate:SetFont(C.media.normal_font, 10, "OUTLINE")
        _G.SystemFont_LargeNamePlateFixed:SetFont(C.media.normal_font, 10, "OUTLINE")
        local inInstance, instanceType = IsInInstance();
        local inBattleground = UnitInBattleground("player")
        if ((instanceType == 'party') or (instanceType == 'raid')) or inBattleground ~= nil then
            SetCVar("nameplateShowFriendlyNPCs", 0)
            SetCVar("nameplateShowFriends", 0)
            -- SetCVar("UnitNameFriendlyPlayerName", 0)
        else
            SetCVar("nameplateShowFriendlyNPCs", 1)
            SetCVar("nameplateShowFriends", 1)
            -- SetCVar("UnitNameFriendlyPlayerName", 1)
        end
    end

    frame:RegisterEvent("PLAYER_LOGIN")
    function frame:PLAYER_LOGIN()
        if C.nameplate.enhance_threat == true then
            SetCVar("threatWarning", 3)
        end
        SetCVar("nameplateGlobalScale", 1)
        SetCVar("namePlateMinScale", 1)
        SetCVar("namePlateMaxScale", 1)
        SetCVar("nameplateLargerScale", 1)
        SetCVar("nameplateSelectedScale", 1)
        SetCVar("nameplateMinAlpha", .9)
        SetCVar("nameplateMaxAlpha", .9)
        SetCVar("nameplateSelectedAlpha", 1)
        SetCVar("nameplateNotSelectedAlpha", .9)
        SetCVar("nameplateLargeTopInset", 0.08)
        SetCVar("nameplateOcclusion", .5)

        SetCVar("nameplateOtherTopInset", C.nameplate.clamp and 0.08 or -1)
        SetCVar("nameplateOtherBottomInset", C.nameplate.clamp and 0.1 or -1)
        SetCVar("clampTargetNameplateToScreen", C.nameplate.clamp and "1" or "0")

        SetCVar("nameplatePlayerMaxDistance", 60)

        SetCVar("nameplateShowOnlyNames", 1)

        local function changeFont(self, size)
            local mult = size or 1
            self:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * mult * T.noscalemult,
                C.font.nameplates_font_style)
            self:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
        end
        changeFont(SystemFont_NamePlateFixed)
        changeFont(SystemFont_LargeNamePlateFixed, 2)
    end
end


function NP.CreateBorder(frame, point)
    if not frame or frame.border then return end
    point = point or frame

    local borderThickness = T.noscalemult * 3
    local backdropThickness = T.noscalemult * 4
    local innerBorderThickness = T.noscalemult

    frame.backdrop = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    frame.backdrop:SetPoint("TOPLEFT", point, "TOPLEFT", -backdropThickness, backdropThickness)
    frame.backdrop:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", backdropThickness, -backdropThickness)
    frame.backdrop:SetColorTexture(0, 0, 0, 1)

    frame.border = frame:CreateTexture(nil, "BORDER", nil, -7)
    frame.border:SetPoint("TOPLEFT", point, "TOPLEFT", -borderThickness, borderThickness)
    frame.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", borderThickness, -borderThickness)

    local textureSize = 512
    local l, r, t, b = borderThickness / textureSize, 1 - borderThickness / textureSize, borderThickness / textureSize,
        1 - borderThickness / textureSize
    frame.border:SetTexture(C.media.blank)
    frame.border:SetTexCoord(l, r, t, b)
    frame.border:SetVertexColor(unpack(C.media.border_color))

    frame.innerBorder = frame:CreateTexture(nil, "BORDER", nil, -6)
    frame.innerBorder:SetPoint("TOPLEFT", point, "TOPLEFT", -innerBorderThickness, innerBorderThickness)
    frame.innerBorder:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", innerBorderThickness, -innerBorderThickness)
    frame.innerBorder:SetColorTexture(0, 0, 0, 1)

    frame.SetBorderColor = function(self, r, g, b, a)
        self.border:SetVertexColor(r, g, b, a or 1)
    end

    frame.SetBorderThickness = function(self, thickness, innerThickness)
        borderThickness = thickness
        innerBorderThickness = innerThickness or T.noscalemult

        local l, r, t, b = borderThickness / textureSize, 1 - borderThickness / textureSize,
            borderThickness / textureSize, 1 - borderThickness / textureSize
        self.border:SetTexCoord(l, r, t, b)
        self.border:SetPoint("TOPLEFT", point, "TOPLEFT", -borderThickness, borderThickness)
        self.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", borderThickness, -borderThickness)

        self.innerBorder:SetPoint("TOPLEFT", point, "TOPLEFT", -innerBorderThickness, innerBorderThickness)
        self.innerBorder:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", innerBorderThickness, -innerBorderThickness)
    end

    frame.SetInnerBorderColor = function(self, r, g, b, a)
        self.innerBorder:SetColorTexture(r, g, b, a or 1)
    end

    T.CreateLowerShadow(frame)
end

function NP.CreateBorderFrame(frame, point)
    if point and point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({ edgeFile = C.media.border, edgeSize = 7 })
    frame.border:SetBackdropBorderColor(unpack(C.media.border_color))
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 1)
end

function NP.CreateBorderFrameIcon(frame, point)
    if point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", point, "TOPLEFT", -4, 4)
    frame.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", 4, -4)
    frame.border:SetBackdrop({ edgeFile = C.media.border, edgeSize = 8 })
    frame.border:SetBackdropBorderColor(unpack(C.media.border_color))
    frame.border:SetFrameStrata("MEDIUM")
end

local function SetColorBorder(frame, r, g, b, a)
    if frame.border then
        frame.border:SetVertexColor(r, g, b, a or 1)
    else
        print("Error: No border found on the frame. Make sure CreateBorder has been called first.")
    end
end

-- Auras functions
function NP.AurasCustomFilter(element, unit, data)
    if UnitIsFriend("player", unit) then return false end

    if data.isHarmful then
        if C.nameplate.track_debuffs and (data.isPlayerAura or data.sourceUnit == "pet") then
            if data.nameplateShowAll or data.nameplateShowPersonal then
                return not T.DebuffBlackList[data.name]
            end
            return T.DebuffWhiteList[data.name] ~= nil
        end
    else
        return T.BuffWhiteList[data.name] or data.isStealable
    end

    return false
end

local Mult = 1
if T.screenHeight > 1200 then
    Mult = T.mult
end

NP.AurasPostCreateIcon = function(element, button)
    NP.CreateBorder(button)
    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button.Count:ClearAllPoints()
    button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    button.Count:SetJustifyH("RIGHT")
    button.Count:SetFont(C.font.nameplates_aura_count_font, C.font.nameplates_aura_count_size * T.noscalemult,
        C.font.nameplates_aura_count_style)
    button.Count:SetShadowOffset(C.font.nameplates_aura_count_shadow and 1 or 0,
        C.font.nameplates_aura_count_shadow and -1 or 0)

    button.Cooldown:ClearAllPoints()
    button.Cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", -3 * T.noscalemult, 3 * T.noscalemult)
    button.Cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3 * T.noscalemult, -3 * T.noscalemult)
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetSwipeColor(1, 0, 0, 1)
    button.Cooldown.noCooldownCount = true

    button.Icon:ClearAllPoints()
    button.Icon:SetAllPoints(button)
    button.Icon:SetDrawLayer("ARTWORK", 1)

    local parent = CreateFrame("Frame", nil, button)
    parent:SetFrameLevel(button:GetFrameLevel() - 1)
    button.parent = parent
    button.Cooldown:SetParent(parent)
end

NP.AurasPostUpdateIcon = function(_, button, unit, data)
    if UnitIsFriend("player", unit) then return end

    local borderColor = C.media.border_color

    if data.isHarmful then
        if C.nameplate.track_debuffs and (data.isPlayerAura or data.sourceUnit == "pet") then
            local whitelistData = T.DebuffWhiteList[data.spellId] or T.DebuffWhiteList[data.name]
            if whitelistData then
                if type(whitelistData) == "table" and whitelistData[2] then
                    borderColor = whitelistData[2]
                end
            end
        end
    else
        if T.BuffWhiteList[data.name] then
            borderColor = { 0, 0.5, 0 }
        elseif data.isStealable then
            borderColor = { 1, 0.85, 0 }
        end
    end

    SetColorBorder(button, unpack(borderColor))

    button.first = true
end

local function HandleAlpha(self)
    local unit = self.unit
    if not unit or UnitIsUnit(unit, "player") then
        self:SetAlpha(0)
        return
    end

    local alpha
    if UnitIsUnit(unit, "target") then
        alpha = TARGET_ALPHA
    elseif InCombatLockdown() then
        alpha = (UnitThreatSituation("player", unit) or UnitThreatSituation(unit, "player")) and COMBAT_ALPHA or NON_COMBAT_ALPHA
    else
        local _, maxRange = LibRangeCheck:GetRange(unit)
        local distance = maxRange or MAX_DISTANCE
        alpha = MAX_ALPHA - (distance / MAX_DISTANCE) * (MAX_ALPHA - MIN_ALPHA)
    end

    self:SetAlpha(math.max(MIN_ALPHA, math.min(MAX_ALPHA, alpha)))
end

local function UpdateNameplate(self, elapsed)
    self.updateTimer = (self.updateTimer or 0) + elapsed
    if self.updateTimer >= UPDATE_INTERVAL then
        HandleAlpha(self)
        NP.UpdateTarget(self)
        NP.threatColor(self)
        self.updateTimer = 0
    end
end

function NP.UpdateTarget(self)
    local unit = self.unit
    if not unit then return end

    local isTarget = UnitIsUnit(unit, "target")
    local isPlayer = UnitIsUnit(unit, "player")

    if isTarget and not isPlayer then
        if C.nameplate.target_glow then
            self.Glow:Show()
        end
        if C.nameplate.target_arrow then
            local isFriend = UnitIsFriend("player", unit)
            local anchorFrame = isFriend and self.Name or self.Health
            self.RTargetIndicator:SetPoint("LEFT", anchorFrame, "RIGHT", 0, isFriend and 1 or 0)
            self.LTargetIndicator:SetPoint("RIGHT", anchorFrame, "LEFT", 0, isFriend and 1 or 0)
            self.RTargetIndicator:Show()
            self.LTargetIndicator:Show()
        end
    else
        if C.nameplate.target_glow then
            self.Glow:Hide()
        end
        if C.nameplate.target_arrow then
            self.RTargetIndicator:Hide()
            self.LTargetIndicator:Hide()
        end
    end
end

local kickID = 0
if C.nameplate.kick_color then
    if T.class == "DEATHKNIGHT" then
        kickID = 47528
    elseif T.class == "DEMONHUNTER" then
        kickID = 183752
    elseif T.class == "DRUID" then
        kickID = 106839
    elseif T.class == "EVOKER" then
        kickID = 351338
    elseif T.class == "HUNTER" then
        kickID = GetSpecialization() == 3 and 187707 or 147362
    elseif T.class == "MAGE" then
        kickID = 2139
    elseif T.class == "MONK" then
        kickID = 116705
    elseif T.class == "PALADIN" then
        kickID = 96231
    elseif T.class == "PRIEST" then
        kickID = 15487
    elseif T.class == "ROGUE" then
        kickID = 1766
    elseif T.class == "SHAMAN" then
        kickID = 57994
    elseif T.class == "WARLOCK" then
        kickID = 119910
    elseif T.class == "WARRIOR" then
        kickID = 6552
    end
end

-- Cast color
function NP.castColor(self)
    if not self then return end

    local color, borderColor

    if self.notInterruptible then
        color = { 0.78, 0.25, 0.25 }
        borderColor = color
    else
        color = { 1, 0.8, 0 }
        if C.nameplate.kick_color and kickID ~= 0 then
            local start = GetSpellCooldown(kickID)
            if start ~= 0 then
                color = { 1, 0.5, 0 }
            end
        end
        borderColor = C.media.border_color
    end

    self:SetStatusBarColor(unpack(color))
    if self.bg then
        self.bg:SetColorTexture(color[1], color[2], color[3], 0.2)
    end

    if self.Icon then
        SetColorBorder(self.Icon:GetParent(), unpack(color))
    end

    if C.nameplate.cast_color and self.spellID then
        if T.InterruptCast[self.spellID] then
            borderColor = { 1, 0.8, 0 }
        elseif T.ImportantCast[self.spellID] then
            borderColor = { 1, 0, 0 }
        end
    end

    SetColorBorder(self, unpack(borderColor))

    if self.IconCooldown then
        self.IconCooldown:SetCooldown(GetTime(), self.max)
    end
end

-- Health color
function NP.threatColor(self)
    if UnitIsPlayer(self.unit) or UnitIsTapDenied(self.unit) then return end
    if not UnitAffectingCombat("player") then return end

    local health = self.Health
    local npcID = self.npcID
    local threatStatus = UnitThreatSituation("player", self.unit)
    local color

    if T.ColorPlate[npcID] then
        color = T.ColorPlate[npcID]
    elseif threatStatus == 3 then
        color = T.Role == "Tank" and C.nameplate.good_color or C.nameplate.bad_color
    elseif threatStatus == 2 or threatStatus == 1 then
        color = C.nameplate.near_color
    elseif threatStatus == 0 then
        if T.Role == "Tank" then
            local offTank = false
            if IsInRaid() then
                for i = 1, GetNumGroupMembers() do
                    local raidUnit = "raid" .. i
                    if UnitExists(raidUnit) and not UnitIsUnit(raidUnit, "player") and
                        UnitGroupRolesAssigned(raidUnit) == "TANK" and
                        UnitDetailedThreatSituation(raidUnit, self.unit) then
                        offTank = true
                        break
                    end
                end
            end
            color = offTank and C.nameplate.offtank_color or C.nameplate.bad_color
        else
            color = C.nameplate.good_color
        end
    end

    if color then
        if C.nameplate.enhance_threat then
            health:SetStatusBarColor(unpack(color))
        else
            self:SetBorderColor(unpack(color))
        end
    end
end

function NP.HealthPostUpdate(self, unit, cur, max)
    if not unit then return end

    local main = self:GetParent()
    local perc = max > 0 and cur / max or 0
    local mu = self.bg.multiplier
    local isPlayer = UnitIsPlayer(unit)

    local r, g, b

    if not UnitIsUnit("player", unit) then
        if isPlayer then
            local unitReaction = UnitReaction(unit, "player")
            if unitReaction and unitReaction >= 5 then
                r, g, b = unpack(T.oUF_colors.power["MANA"])
            end
        elseif not UnitIsTapDenied(unit) then
            if C.nameplate.mob_color_enable and T.ColorPlate[main.npcID] then
                r, g, b = unpack(T.ColorPlate[main.npcID])
            else
                local unitReaction = UnitReaction(unit, "player")
                local reaction = T.oUF_colors.reaction[unitReaction]
                if reaction then
                    r, g, b = reaction[1], reaction[2], reaction[3]
                else
                    r, g, b = UnitSelectionColor(unit, true)
                end
            end
        end
    end

    if r and g and b then
        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r * mu, g * mu, b * mu)
    end

    if isPlayer then
        local borderColor = perc <= 0.2 and {1, 0, 0} or (perc <= 0.5 and {1, 1, 0} or C.media.border_color)
        self:SetBorderColor(unpack(borderColor))
    end

    NP.threatColor(main)
end

function NP.Callback(self, event, unit)
    if not self or not unit then return end

    local unitGUID = UnitGUID(unit)
    self.npcID = unitGUID and select(6, strsplit('-', unitGUID))
    self.unitName = UnitName(unit)
    self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

    if self.npcID and T.PlateBlacklist[self.npcID] then
        self:Hide()
        return
    end

    self:Show()

    local isPlayer = UnitIsUnit(unit, "player")
    local isFriendly = UnitIsFriend("player", unit)

    self.Power:SetShown(isPlayer)
    self.Name:SetShown(not isPlayer)
    self.Castbar:SetAlpha(isPlayer and 0 or 1)
    self.RaidTargetIndicator:SetAlpha(isPlayer and 0 or 1)

    local widgetAlpha = (self.widgetsOnly or (UnitWidgetSet(unit) and UnitIsOwnerOrControllerOfUnit("player", unit))) and 0 or 1
    self.Health:SetAlpha(widgetAlpha)
    self.Name:SetAlpha(widgetAlpha)
    self.Castbar:SetAlpha(widgetAlpha)
    if self.Title then self.Title:SetShown(widgetAlpha == 0) end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate.UnitFrame and nameplate.UnitFrame.WidgetContainer then
        nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
    end

    if C.nameplate.only_name and isFriendly then
        self.Health:SetAlpha(0)
        self.Name:ClearAllPoints()
        self.Name:SetPoint("CENTER", self, "CENTER", 0, 0)
        self.Name:SetJustifyH("CENTER")
        self.Castbar:SetAlpha(0)
        if C.nameplate.target_glow then
            self.Glow:SetAlpha(0)
        end
        if self.Title then self.Title:Show() end
    else
        self.Health:SetAlpha(1)
        self.Name:ClearAllPoints()
        self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4 * T.noscalemult, 2 * T.noscalemult)
        self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 4 * T.noscalemult, 2 * T.noscalemult)
        self.Name:SetJustifyH("CENTER")
        self.Castbar:SetAlpha(1)
        if C.nameplate.target_glow then
            self.Glow:SetAlpha(1)
        end
        if self.Title then self.Title:Hide() end
    end

    self:SetScript("OnUpdate", UpdateNameplate)
end

InitializeModule()

T.UF = NP
return T
