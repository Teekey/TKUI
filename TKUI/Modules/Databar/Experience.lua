local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Experience Module
----------------------------------------------------------------------------------------

function DB:CreateExperienceModule()
    local maxLevel = GetMaxPlayerLevel()

    -- If player is at max level, don't create the module
    if T.level >= maxLevel then
        return
    end

    -- Create the experience module frame
    self.experienceModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.experienceModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.experienceModule:SetPoint("LEFT", self.TKUIRightBar2, "LEFT", 0, 0)

    -- Create a button to hold the radial status bar
    local button = CreateFrame("Button", nil, self.experienceModule)
    button:SetSize(C.databar.iconsize, C.databar.iconsize)
    button:SetPoint("CENTER")
    button:SetTemplate("Transparent") -- Apply template to the button

    -- Create the radial status bar
    local radialBar = T.CreateRadialStatusBar(button)
    radialBar:SetAllPoints(button)
    radialBar:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\White.tga")
    radialBar:SetVertexColor(T.color.r, T.color.g, T.color.b) -- Use your addon's color scheme
    radialBar:SetFrameLevel(button:GetFrameLevel() + 1)

    -- Create a background frame
    local bgFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
    bgFrame:SetSize(C.databar.iconsize - 4, C.databar.iconsize - 4) -- Slightly smaller than the button
    bgFrame:SetPoint("CENTER")
    bgFrame:SetFrameLevel(radialBar:GetFrameLevel() + 1)            -- Set it above the radial bar

    -- Set up the backdrop
    bgFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    bgFrame:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Dark gray with 80% opacity
    bgFrame:SetBackdropBorderColor(0, 0, 0, 1) -- Black border
    radialBar:SetFrameLevel(button:GetFrameLevel() + 10)
    bgFrame:SetFrameLevel(radialBar:GetFrameLevel() + 10)
    -- Create the experience text
    local expText = bgFrame:CreateFontString(nil, "OVERLAY")
    expText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    expText:SetPoint("CENTER")
    expText:SetJustifyH("CENTER")
    expText:SetTextColor(T.color.r, T.color.g, T.color.b) -- White text for better visibility


    -- Function to update the experience bar and text
    local function UpdateExperience()
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local percentXP = currentXP / maxXP

        radialBar:SetRadialStatusBarValue(percentXP)
        expText:SetText(string.format("%.0f%%", percentXP * 100))
    end

    -- Update the bar and text initially
    UpdateExperience()

    -- Register events for updates
    self.experienceModule:RegisterEvent("PLAYER_XP_UPDATE")
    self.experienceModule:RegisterEvent("PLAYER_LEVEL_UP")
    self.experienceModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.experienceModule:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LEVEL_UP" then
            -- Check if player has reached max level
            if UnitLevel("player") >= GetMaxPlayerLevel() then
                self:Hide()
                return
            end
        end
        UpdateExperience()
    end)

    -- Add tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local remainingXP = maxXP - currentXP
        local percentXP = (currentXP / maxXP) * 100

        GameTooltip:AddLine("Experience")
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Current XP:", T.ShortValue(currentXP) .. " / " .. T.ShortValue(maxXP), 1, 1, 1, 1, 1,
            1)
        GameTooltip:AddDoubleLine("Remaining XP:", T.ShortValue(remainingXP), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("Progress:", string.format("%.2f%%", percentXP), 1, 1, 1, 1, 1, 1)

        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Optional: Add click functionality to the button
    button:SetScript("OnClick", function(self, button)
        -- Add any click functionality you want here
        -- For example, you could toggle the experience window
        ToggleCharacter("PaperDollFrame")
    end)
end