local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Durability Module
----------------------------------------------------------------------------------------

function DB:CreateDurabilityModule()
    -- Create the durability module frame
    self.durabilityModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.durabilityModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    if self.experienceModule then
        self.durabilityModule:SetPoint("LEFT", self.experienceModule, "RIGHT", 5, 0)
    else
        self.durabilityModule:SetPoint("LEFT", self.TKUIRightBar2, "LEFT", 0, 0)
    end

    -- Create the armor icon
    local armorIcon = CreateFrame("Button", nil, self.durabilityModule)
    armorIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    armorIcon:SetPoint("CENTER", self.durabilityModule, "CENTER", 0, 0)
    armorIcon:SetTemplate("Transparent")

    local texture = armorIcon:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Armor")
    texture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    texture:SetPoint("BOTTOM", armorIcon, "BOTTOM")
    armorIcon.texture = texture

    -- Create a separate frame for the text
    local textFrame = CreateFrame("Frame", nil, armorIcon)
    textFrame:SetAllPoints()
    textFrame:SetFrameLevel(armorIcon:GetFrameLevel() + 1)

    -- Create the durability text
    local durabilityText = textFrame:CreateFontString(nil, "OVERLAY")
    durabilityText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    durabilityText:SetPoint("TOP", textFrame, "TOP", 0, -3)
    durabilityText:SetJustifyH("CENTER")

    -- Function to update the durability text
    local function UpdateDurability()
        local lowestDurability = 100
        for i = 1, 11 do -- Iterate through equipment slots
            local current, max = GetInventoryItemDurability(i)
            if current and max then
                local percent = (current / max) * 100
                if percent < lowestDurability then
                    lowestDurability = percent
                end
            end
        end
        durabilityText:SetText(string.format("%.0f", lowestDurability))

        -- Set durability text color based on percentage
        local r, g, b = T.ColorGradient(lowestDurability / 100, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.databar.iconcolor))
        durabilityText:SetTextColor(r, g, b)
        armorIcon.texture:SetVertexColor(r, g, b)
        local r, g, b = T.ColorGradient(lowestDurability / 100, 0.988, .44, 0.368, 0.988, 0.852, 0,
            unpack(C.media.border_color))
        armorIcon:SetBackdropBorderColor(r, g, b, 1)
    end

    -- Update the text initially
    UpdateDurability()


    local function CreateDurabilityTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Equipment Durability", 1, 1, 1)
        GameTooltip:AddLine(" ")

        local totalDurability = 0
        local itemCount = 0

        local slotNames = {
            [1] = "Head",
            [3] = "Shoulders",
            [5] = "Chest",
            [6] = "Waist",
            [7] = "Legs",
            [8] = "Feet",
            [9] = "Wrists",
            [10] = "Hands",
            [16] = "Main Hand",
            [17] = "Off Hand",
            [18] = "Ranged"
        }

        for slotID, slotName in pairs(slotNames) do
            local current, max = GetInventoryItemDurability(slotID)
            if current and max then
                local percent = (current / max) * 100
                totalDurability = totalDurability + percent
                itemCount = itemCount + 1

                local r, g, b = T.ColorGradient(percent / 100, 0.988, 0.44, 0.368, 0.988, 0.852, 0, 0.4, 1, 0.4)
                GameTooltip:AddDoubleLine(slotName .. ":", string.format("%.1f%%", percent), 1, 1, 1, r, g, b)
            end
        end

        if itemCount > 0 then
            local averageDurability = totalDurability / itemCount
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("Average Durability:", string.format("%.1f%%", averageDurability), 1, 1, 1, 1, 1, 1)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to toggle Character Info", 0.5, 0.5, 0.5)

        GameTooltip:Show()
    end

    -- Add tooltip functionality to the armor icon
    armorIcon:SetScript("OnEnter", CreateDurabilityTooltip)
    armorIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Add click functionality to open character info
    armorIcon:SetScript("OnClick", function() ToggleCharacter("PaperDollFrame") end)


    -- Register events for updates
    self.durabilityModule:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    self.durabilityModule:SetScript("OnEvent", function(self, event)
        if event == "UPDATE_INVENTORY_DURABILITY" then
            UpdateDurability()
        end
    end)
end