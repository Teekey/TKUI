local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Clock Module
----------------------------------------------------------------------------------------

function DB:CreateClockModule()
    local combatStartTime = 0 -- Initialize to 0 or a suitable default value

    -- Create the DB: module frame
    self.clockModule = CreateFrame("Frame", "clockModule", self.TKUIBar)
    self.clockModule:SetSize(80, 35)
    self.clockModule:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -4)

    -- Create the DB: text
    local clockText = self.clockModule:CreateFontString(nil, "OVERLAY")
    clockText:SetFont(C.font.databar_font, 24, C.font.databar_font_style)
    clockText:SetPoint("BOTTOM", self.clockModule, "BOTTOM", 0, 0)
    clockText:SetJustifyH("CENTER")
    clockText:SetAlpha(0.5)

    -- Make the DB: module interactive
    self.clockModule:EnableMouse(true)

    -- Variable to track mouse over state
    local isMouseOver = false

    -- Function to update the DB:/timer text
    local function UpdateClockText()
        local text
        if IsEncounterInProgress() then
            -- In combat, show timer
            local combatTime = GetTime() - combatStartTime
            local minutes = math.floor(combatTime / 60)
            local seconds = math.floor(combatTime % 60)
            text = string.format("%02d:%02d", minutes, seconds)
            clockText:SetTextColor(0.85, 0.27, 0.27, .7)
            clockText:SetFont(C.font.databar_font, 24, "THICKOUTLINE")
        else
            -- Out of combat, show DB:
            local hour, minute = GetGameTime()
            text = string.format("%02d:%02d", hour, minute)
            if isMouseOver then
                local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
                clockText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
                clockText:SetAlpha(1)
            else
                clockText:SetTextColor(unpack(C.databar.fontcolor))
                clockText:SetAlpha(0.5)
            end
            clockText:SetFont(C.font.databar_font, 24)
        end
        clockText:SetText(text)
    end

    -- Call UpdateClockText initially to set the time
    UpdateClockText()

    -- Event handler for entering/leaving combat
    local function OnCombatEvent(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            combatStartTime = GetTime()
        elseif event == "PLAYER_REGEN_ENABLED" then
            UpdateClockText()
        end
    end

    -- Register combat events
    self.clockModule:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.clockModule:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.clockModule:SetScript("OnEvent", OnCombatEvent)

    -- Update the DB: every second
    local clockUpdateTimer = CreateFrame("Frame", nil, self.clockModule)
    local elapsed = 0
    clockUpdateTimer:SetScript("OnUpdate", function(self, elap)
        elapsed = elapsed + elap
        if elapsed >= 1 then
            UpdateClockText()
            elapsed = 0
        end
    end)

    -- Mouse over effect
    self.clockModule:SetScript("OnEnter", function()
        if not IsEncounterInProgress() then
            isMouseOver = true
            UpdateClockText()
        end
    end)

    self.clockModule:SetScript("OnLeave", function()
        if not IsEncounterInProgress() then
            isMouseOver = false
            UpdateClockText()
        end
    end)

    -- Click to open calendar
    self.clockModule:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not IsEncounterInProgress() then
            ToggleCalendar()
        end
    end)
end