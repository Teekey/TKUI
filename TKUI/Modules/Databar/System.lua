local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	System Module
----------------------------------------------------------------------------------------

function DB:CreateSystemModule()
    -- Create the system menu frame
    self.systemModule = CreateFrame("Frame", nil, self.TKUILeftBar)
    self.systemModule:SetSize(C.databar.iconsize * 2 + 5, C.databar.iconsize)
    self.systemModule:SetPoint("RIGHT", self.TKUILeftBar, "RIGHT", 2, 0)

    -- Create the Latency icon
    local latencyIcon = CreateFrame("Button", nil, self.systemModule)
    latencyIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    latencyIcon:SetPoint("RIGHT", self.systemModule, "RIGHT", 0, 0)
    latencyIcon:SetTemplate("Transparent")

    local latencyTexture = latencyIcon:CreateTexture(nil, "ARTWORK")
    latencyTexture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Ping")
    latencyTexture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    latencyTexture:SetPoint("BOTTOM", latencyIcon, "BOTTOM")
    latencyIcon.texture = latencyTexture

    -- Create a separate frame for the Latency text
    local latencyTextFrame = CreateFrame("Frame", nil, latencyIcon)
    latencyTextFrame:SetAllPoints()
    latencyTextFrame:SetFrameLevel(latencyIcon:GetFrameLevel() + 1)

    -- Create the Latency text
    local latencyText = latencyTextFrame:CreateFontString(nil, "OVERLAY")
    latencyText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    latencyText:SetPoint("TOP", latencyTextFrame, "TOP", 0, -3)
    latencyText:SetJustifyH("CENTER")

    -- Create the FPS icon
    local fpsIcon = CreateFrame("Button", nil, self.systemModule)
    fpsIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    fpsIcon:SetPoint("RIGHT", latencyIcon, "LEFT", -3, 0)
    fpsIcon:SetTemplate("Transparent")

    local fpsTexture = fpsIcon:CreateTexture(nil, "ARTWORK")
    fpsTexture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\FPS")
    fpsTexture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    fpsTexture:SetPoint("BOTTOM", fpsIcon, "BOTTOM")
    fpsIcon.texture = fpsTexture

    -- Create a separate frame for the FPS text
    local fpsTextFrame = CreateFrame("Frame", nil, fpsIcon)
    fpsTextFrame:SetAllPoints()
    fpsTextFrame:SetFrameLevel(fpsIcon:GetFrameLevel() + 1)

    -- Create the FPS text
    local fpsText = fpsTextFrame:CreateFontString(nil, "OVERLAY")
    fpsText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    fpsText:SetPoint("TOP", fpsTextFrame, "TOP", 0, -3)
    fpsText:SetJustifyH("CENTER")


    -- Function to update FPS and Latency
    local function UpdateSystemInfo()
        local fps = math.floor(GetFramerate())
        local targetFPS = tonumber(C_CVar.GetCVar("targetFPS")) or 60
        local fpsPercent = math.min(fps / targetFPS, 1)
        local fpsR, fpsG, fpsB = T.ColorGradient(fpsPercent, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.databar.iconcolor))
        fpsIcon.texture:SetVertexColor(fpsR, fpsG, fpsB)
        fpsText:SetText(fps)
        fpsText:SetTextColor(fpsR, fpsG, fpsB)
        local fpsR, fpsG, fpsB = T.ColorGradient(fpsPercent, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.media.border_color))
        fpsIcon:SetBackdropBorderColor(fpsR, fpsG, fpsB, 1)

        local _, _, latencyHome, latencyWorld = GetNetStats()
        local latency = math.max(latencyHome, latencyWorld)
        local latencyPercent = 1 - math.min(latency / 100, 1)
        local latR, latG, latB = T.ColorGradient(latencyPercent * 2, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.databar.iconcolor))
        latencyIcon.texture:SetVertexColor(latR, latG, latB)
        latencyText:SetText(latency)
        latencyText:SetTextColor(latR, latG, latB)
        local latR, latG, latB = T.ColorGradient(latencyPercent * 2, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.media.border_color))
        latencyIcon:SetBackdropBorderColor(latR, latG, latB, 1)
    end

    -- Update the system info initially
    UpdateSystemInfo()

    -- Register events for updates
    self.systemModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.systemModule:RegisterEvent("PLAYER_LEAVING_WORLD")
    self.systemModule:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed > 1 then
                    UpdateSystemInfo()
                    self.elapsed = 0
                end
            end) -- Directly set OnUpdate function
            UpdateSystemInfo() -- Ensure the info is updated when entering the world
        elseif event == "PLAYER_LEAVING_WORLD" then
            self:SetScript("OnUpdate", nil) -- Disable OnUpdate
        end
    end)

    -- Initial setup for OnUpdate
    self.systemModule:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            UpdateSystemInfo()
            self.elapsed = 0
        end
    end) -- Ensure OnUpdate is set initially

    -- Function to format memory usage
    local function FormatMemory(memory)
        if memory > 1024 then
            return string.format("%.2f MB", memory / 1024)
        else
            return string.format("%.2f KB", memory)
        end
    end

    -- Function to get addon memory usage
    local function GetAddonMemoryUsage()
        UpdateAddOnMemoryUsage()
        local totalMemory = 0
        local addonMemoryUsage = {}
        local numAddons = C_AddOns.GetNumAddOns()
        for i = 1, numAddons do
            local name = C_AddOns.GetAddOnInfo(i)
            local memory = GetAddOnMemoryUsage(name)
            totalMemory = totalMemory + memory
            if memory > 0 then
                table.insert(addonMemoryUsage, { name = name, memory = memory })
            end
        end
        table.sort(addonMemoryUsage, function(a, b) return a.memory > b.memory end)
        return totalMemory, addonMemoryUsage
    end

    local function PerformAddonCleanup()
        local before = collectgarbage("count")
        collectgarbage("collect")
        local after = collectgarbage("count")
        local cleaned = before - after

        print(string.format("|cFFFF5C00Addon Cleanup:|r Freed up |cFFFF5C00%.2f|r MB of memory", cleaned / 1024))

        -- Force an update of the system info
        UpdateSystemInfo()
    end

    -- Function to create tooltip
    local function CreateSystemTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        -- FPS Information
        local fps = math.floor(GetFramerate())
        local targetFPS = tonumber(C_CVar.GetCVar("targetFPS")) or 60
        GameTooltip:AddDoubleLine("FPS:", string.format("%d / %d", fps, targetFPS), 1, 1, 1, 1, 1, 1)

        -- Latency Information
        local _, _, latencyHome, latencyWorld = GetNetStats()
        GameTooltip:AddDoubleLine("Home Latency:", latencyHome .. " ms", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("World Latency:", latencyWorld .. " ms", 1, 1, 1, 1, 1, 1)

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("AddOn Memory Usage")

        local totalMemory, addonMemoryUsage = GetAddonMemoryUsage()
        GameTooltip:AddDoubleLine("Total Memory Usage:", FormatMemory(totalMemory), 1, 1, 1, 1, 1, 1)

        for i = 1, math.min(5, #addonMemoryUsage) do
            local addon = addonMemoryUsage[i]
            GameTooltip:AddDoubleLine(addon.name, FormatMemory(addon.memory), 1, 1, 1, 1, 1, 1)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to perform addon memory cleanup", 0.5, 0.5, 0.5)

        GameTooltip:Show()
    end

    -- Add tooltip and click functionality to FPS icon
    fpsIcon:SetScript("OnEnter", CreateSystemTooltip)
    fpsIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    fpsIcon:SetScript("OnClick", PerformAddonCleanup)

    -- Add tooltip and click functionality to Latency icon
    latencyIcon:SetScript("OnEnter", CreateSystemTooltip)
    latencyIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    latencyIcon:SetScript("OnClick", PerformAddonCleanup)
end