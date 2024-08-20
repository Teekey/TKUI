local T, C, L = unpack(TKUI)

T.RangeChecker = {}
local RangeChecker = T.RangeChecker

-- Upvalues
local CreateFrame, GetActionInfo, IsActionInRange = CreateFrame, GetActionInfo, IsActionInRange
local GetActionCooldown, IsUsableAction = GetActionCooldown, IsUsableAction
local GetPetActionInfo, GetPetActionSlotUsable = GetPetActionInfo, GetPetActionSlotUsable
local pairs, wipe, next = pairs, wipe, next
local GetSpellCooldown = GetSpellCooldown
local GetActionCharges = GetActionCharges
local GetTime = GetTime

-- Constants
local UPDATE_INTERVAL = 0.05  -- Reduced from 0.1 to catch shorter cooldowns
local lastUpdateTime = 0
local GCD_THRESHOLD = 1.5
local BUTTON_TYPES = {
    "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
    "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", 
    "MultiBar6Button", "MultiBar7Button"
}

-- Configuration
local defaultConfig = {
    updateDelay = 0.05,
    petActions = true,
    colors = {
        normal = { 1, 1, 1, 1, desaturate = false },
        oor = { 0.85, 0.27, 0.27, 1, desaturate = true },
        cooldown = { 0.2, 0.2, 0.2, 1, desaturate = true },
        oom = { 0.1, 0.3, 1, 1, desaturate = true },
        unusable = { 0.4, 0.4, 0.4, 1, desaturate = false }
    }
}

-- State management
local buttonStates = {}
local watchedActions = {}
local watchedPetActions = {}

-- Helper functions
local function GetButtonState(button)
    local action = button.action
    if not action then return "normal" end

    local currentTime = GetTime()
    local start, duration, enable = GetActionCooldown(action)
    
    if enable == 0 then return "unusable" end
    
    -- Check for charges
    local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action)
    
    -- If the ability has charges
    if maxCharges > 1 then
        if charges == 0 and chargeStart > 0 and (chargeStart + chargeDuration) > currentTime then
            return "cooldown"
        end
    -- If it's a regular cooldown
    elseif start > 0 and duration > GCD_THRESHOLD and (start + duration) > currentTime then
        return "cooldown"
    end

    local isUsable, notEnoughMana = IsUsableAction(action)
    if not isUsable then
        return notEnoughMana and "oom" or "unusable"
    end

    return IsActionInRange(action) == false and "oor" or "normal"
end

local function UpdateButtonVisuals(button, state)
    local color = RangeChecker.config.colors[state]
    button.icon:SetDesaturated(color.desaturate)
    button.icon:SetVertexColor(unpack(color))
end

-- Main update function
local function UpdateButtons()
    local currentTime = GetTime()
    for button in pairs(watchedActions) do
        local newState = GetButtonState(button, currentTime)
        if buttonStates[button] ~= newState then
            buttonStates[button] = newState
            UpdateButtonVisuals(button, newState)
        end
    end
end

-- Button setup functions
local function SetupButton(button)
    if button.rangeCheckerSetup then return end
    button.rangeCheckerSetup = true

    button:HookScript("OnShow", function()
        watchedActions[button] = true
        RangeChecker:UpdateActive()
    end)
    button:HookScript("OnHide", function()
        watchedActions[button] = nil
        RangeChecker:UpdateActive()
    end)
    
    -- Hook the SetCooldown function of the button's cooldown frame
    if button.cooldown then
        hooksecurefunc(button.cooldown, "SetCooldown", function(_, start, duration)
            C_Timer.After(0, function() 
                RangeChecker:UpdateButton(button)
                if start > 0 and duration > 0 then
                    C_Timer.After(duration, function()
                        RangeChecker:UpdateButton(button)
                    end)
                end
            end)
        end)
    end
end

local function SetupPetButton(button)
    if button.rangeCheckerSetup then return end
    button.rangeCheckerSetup = true

    button:HookScript("OnShow", function()
        watchedPetActions[button] = true
        RangeChecker:UpdateActive()
    end)
    button:HookScript("OnHide", function()
        watchedPetActions[button] = nil
        RangeChecker:UpdateActive()
    end)
end

-- RangeChecker methods
function RangeChecker:Init()
    self.config = defaultConfig
    self:SetupActionButtons()
    if self.config.petActions then
        self:SetupPetActions()
    end
    self:RegisterEvents()
end

function RangeChecker:SetupActionButtons()
    for _, buttonType in ipairs(BUTTON_TYPES) do
        for i = 1, 12 do
            local button = _G[buttonType..i]
            if button then
                SetupButton(button)
            end
        end
    end
end

function RangeChecker:SetupPetActions()
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. i]
        if button then
            SetupPetButton(button)
        end
    end
end

function RangeChecker:UpdateActive()
    if next(watchedActions) or next(watchedPetActions) then
        if not self.updateTimer then
            self.updateTimer = C_Timer.NewTicker(UPDATE_INTERVAL, UpdateButtons)
        end
    elseif self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
end

function RangeChecker:UpdateButton(button)
    local newState = GetButtonState(button)
    if buttonStates[button] ~= newState then
        buttonStates[button] = newState
        UpdateButtonVisuals(button, newState)
    end
end

function RangeChecker:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    frame:RegisterEvent("SPELL_UPDATE_CHARGES")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("PET_BAR_UPDATE")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:SetupActionButtons()
            self:SetupPetActions()
        elseif event == "ACTIONBAR_SLOT_CHANGED" then
            self:SetupActionButtons()
        elseif event == "PET_BAR_UPDATE" then
            self:SetupPetActions()
        else
            -- For all other events, update all buttons
            self:UpdateAll()
        end
        self:UpdateActive()
    end)
end

function RangeChecker:UpdateAll()
    for button in pairs(watchedActions) do
        self:UpdateButton(button)
    end
end

local function ThrottledUpdate()
    local currentTime = GetTime()
    if currentTime - lastUpdateTime >= UPDATE_INTERVAL then
        for button in pairs(watchedActions) do
            local newState = GetButtonState(button)
            if buttonStates[button] ~= newState then
                buttonStates[button] = newState
                UpdateButtonVisuals(button, newState)
            end
        end
        lastUpdateTime = currentTime
    end
end

function RangeChecker:StartContinuousUpdate()
    if self.updateTimer then
        self.updateTimer:Cancel()
    end
    self.updateTimer = C_Timer.NewTicker(0.01, ThrottledUpdate)
end

function RangeChecker:StopContinuousUpdate()
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
end


function RangeChecker:UpdateActive()
    if next(watchedActions) or next(watchedPetActions) then
        self:StartContinuousUpdate()
    else
        self:StopContinuousUpdate()
    end
end

-- Modify the Init function to start the continuous update
function RangeChecker:Init()
    self.config = defaultConfig
    self:SetupActionButtons()
    if self.config.petActions then
        self:SetupPetActions()
    end
    self:RegisterEvents()
    self:StartContinuousUpdate()
end

function RangeChecker:Init()
    self.config = defaultConfig
    self:SetupActionButtons()
    if self.config.petActions then
        self:SetupPetActions()
    end
    self:RegisterEvents()
    self:StartContinuousUpdate()
end

-- Initialize the addon
RangeChecker:Init()