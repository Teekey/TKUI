local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Bag Module
----------------------------------------------------------------------------------------

function DB:GetBagInfo()
    local freeBags = 0
    local totalBags = 0
    for i = 0, NUM_BAG_SLOTS do
        freeBags = freeBags + C_Container.GetContainerNumFreeSlots(i)
        totalBags = totalBags + C_Container.GetContainerNumSlots(i)
    end
    return freeBags, totalBags
end

function DB:CreateBagModule()
    -- Create the bag module frame
    self.bagModule = CreateFrame("Frame", nil, self.TKUIRightBar1)
    self.bagModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.bagModule:SetPoint("RIGHT", self.hearthstoneModule, "LEFT", -4, 0)

    -- Create the bag icon
    local bagIcon = CreateFrame("Button", nil, self.bagModule)
    bagIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    bagIcon:SetPoint("CENTER", self.bagModule, "CENTER", 0, 0)
    bagIcon:SetTemplate("Transparent")

    local texture = bagIcon:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Backpack")
    texture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    texture:SetPoint("BOTTOM", bagIcon, "BOTTOM")
    bagIcon.texture = texture

    -- Create a separate frame for the text
    local textFrame = CreateFrame("Frame", nil, bagIcon)
    textFrame:SetAllPoints()
    textFrame:SetFrameLevel(bagIcon:GetFrameLevel() + 1)

    -- Create the bag text
    local bagText = textFrame:CreateFontString(nil, "OVERLAY")
    bagText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    bagText:SetPoint("TOP", textFrame, "TOP", 0, -3)
    bagText:SetJustifyH("CENTER")

    -- Function to update the bag text
    local function UpdateBags()
        local freeBags, totalBags = DB:GetBagInfo()
        bagText:SetText(freeBags)

        -- Calculate percentage of free bag slots and apply gradient
        local freePercentage = (freeBags / totalBags)
        local r, g, b = T.ColorGradient(freePercentage, 0.988, .44, 0.368, 0.988, 0.852, 0, unpack(C.databar.iconcolor))
        bagText:SetTextColor(r, g, b)
        bagIcon.texture:SetVertexColor(r, g, b)
        local r, g, b = T.ColorGradient(freePercentage, 0.988, .44, 0.368, 0.988, 0.852, 0, unpack(C.media.border_color))
        bagIcon:SetBackdropBorderColor(r, g, b, 1)
    end

    -- Function to create and show the tooltip
    local function ShowBagTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local freeBags, totalBags = DB:GetBagInfo()
        local usedBags = totalBags - freeBags
        local freePercentage = (freeBags / totalBags) * 100

        GameTooltip:AddLine("Bag Space", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Free slots:", freeBags, 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("Used slots:", usedBags, 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("Total slots:", totalBags, 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("Free space:", string.format("%.1f%%", freePercentage), 1, 1, 1, 1, 1, 1)

        -- Add information about each bag
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Bag Details:", 1, 0.82, 0)
        for i = 0, NUM_BAG_SLOTS do
            local freeSlots = C_Container.GetContainerNumFreeSlots(i)
            local totalSlots = C_Container.GetContainerNumSlots(i)
            local usedSlots = totalSlots - freeSlots
            local bagName

            if i == 0 then
                bagName = "Backpack"
            elseif i == NUM_BAG_SLOTS then
                bagName = "Reagent Bag"
            else
                bagName = "Bag " .. i
            end

            if totalSlots > 0 then
                local r, g, b = T.ColorGradient(freeSlots / totalSlots, 0.988, .44, 0.368, 0.988, 0.852, 0, 0.4, 1, 0.4)
                GameTooltip:AddDoubleLine(bagName .. ":", string.format("%d / %d", usedSlots, totalSlots), 1, 1, 1, r, g,
                    b)
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to open all bags", 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end

    -- Set up tooltip
    bagIcon:SetScript("OnEnter", ShowBagTooltip)
    bagIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Function to open all bags
    local function ToggleBags()
        ToggleAllBags()
    end

    -- Set up click handler to open bags
    bagIcon:SetScript("OnClick", ToggleBags)

    -- Update the text initially
    UpdateBags()

    -- Register events for updates
    self.bagModule:RegisterEvent("BAG_UPDATE")
    self.bagModule:SetScript("OnEvent", function(self, event)
        UpdateBags()
    end)
end