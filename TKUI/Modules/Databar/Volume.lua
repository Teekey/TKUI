local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Volume Module
----------------------------------------------------------------------------------------

function DB:CreateVolumeModule()
    -- Create the volume module frame
    self.volumeModule = CreateFrame("Frame", nil, self.TKUILeftBar)
    self.volumeModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.volumeModule:SetPoint("RIGHT", self.systemModule, "LEFT", -1, 0)

    -- Create the volume icon
    local volumeIcon = CreateFrame("Button", nil, self.volumeModule)
    volumeIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    volumeIcon:SetPoint("CENTER", self.volumeModule, "CENTER", 0, 0)
    volumeIcon:SetTemplate("Transparent")

    local texture = volumeIcon:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Volume")
    texture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    texture:SetPoint("BOTTOM", volumeIcon, "BOTTOM")
    volumeIcon.texture = texture

    -- Create a separate frame for the text
    local textFrame = CreateFrame("Frame", nil, volumeIcon)
    textFrame:SetAllPoints()
    textFrame:SetFrameLevel(volumeIcon:GetFrameLevel() + 1)

    -- Create the volume text
    local volumeText = textFrame:CreateFontString(nil, "OVERLAY")
    volumeText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    volumeText:SetPoint("TOP", textFrame, "TOP", 0, -3)
    volumeText:SetJustifyH("CENTER")

    -- Function to map volume to alpha
    local function VolumeToAlpha(volume)
        -- Clamp volume between 0 and 100
        volume = math.max(0, math.min(100, volume))
        -- Map 0-100 to 0.3-1.0
        return 0.3 + (volume / 100) * 0.7
    end

    -- Function to update volume text and icon
    local function UpdateVolume()
        local volume = GetCVar("Sound_MasterVolume") * 100
        -- Update icon based on volume
        if volume == 0 then
            volumeIcon.texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Mute")
            volumeIcon.texture:SetVertexColor(0.988, .44, 0.368, 1)
            volumeText:SetText("M")
            volumeText:SetTextColor(0.988, .44, 0.368, 1)
        else
            local alpha = VolumeToAlpha(volume)
            volumeIcon.texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Volume")
            volumeIcon.texture:SetVertexColor(unpack(C.databar.iconcolor))
            volumeIcon.texture:SetAlpha(alpha)
            volumeText:SetText(string.format("%d", volume))
            volumeText:SetTextColor(unpack(C.databar.fontcolor))
            volumeText:SetAlpha(alpha)
        end
    end

    local previousVolume = 1

    -- Function to handle volume changes
    local function ChangeVolume(amount)
        local currentVolume = tonumber(GetCVar("Sound_MasterVolume"))

        -- If we're unmuting, use the previous volume
        if amount == "unmute" then
            SetCVar("Sound_MasterVolume", previousVolume)
        else
            -- Store the current volume as previous if it's not 0
            if currentVolume > 0 then
                previousVolume = currentVolume
            end

            -- Calculate new volume
            local newVolume = math.min(math.max(currentVolume + amount, 0), 1)
            SetCVar("Sound_MasterVolume", newVolume)
        end

        UpdateVolume()
    end

    -- Set up click handlers
    volumeIcon:SetScript("OnMouseDown", function(self, button)
        local currentVolume = tonumber(GetCVar("Sound_MasterVolume"))
        if button == "LeftButton" then
            ChangeVolume(0.1)  -- Increase volume by 10%
        elseif button == "RightButton" then
            ChangeVolume(-0.1) -- Decrease volume by 10%
        elseif button == "MiddleButton" then
            if currentVolume == 0 then
                ChangeVolume("unmute")       -- Restore to previous volume
            else
                ChangeVolume(-currentVolume) -- Mute (set to 0)
            end
        end
    end)

    -- Update the volume text initially
    UpdateVolume()

    -- Register events for updates (if needed)
    self.volumeModule:RegisterEvent("CVAR_UPDATE")
    self.volumeModule:SetScript("OnEvent", function(self, event, cvar)
        if event == "CVAR_UPDATE" and cvar == "Sound_MasterVolume" then
            UpdateVolume()
        end
    end)
end