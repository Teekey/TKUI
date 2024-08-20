local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Item Level Module
----------------------------------------------------------------------------------------

function DB:CreateItemLevelModule()
    -- Create the item level module frame
    self.itemLevelModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.itemLevelModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.itemLevelModule:SetPoint("LEFT", self.durabilityModule, "RIGHT", 5, 0)

    -- Create the item level icon
    local ilvlIcon = CreateFrame("Button", nil, self.itemLevelModule)
    ilvlIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    ilvlIcon:SetPoint("CENTER", self.itemLevelModule, "CENTER", 0, 0)
    ilvlIcon:SetTemplate("Transparent")

    local texture = ilvlIcon:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Character")
    texture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    texture:SetPoint("BOTTOM", ilvlIcon, "BOTTOM")
    ilvlIcon.texture = texture
    ilvlIcon.texture:SetVertexColor(unpack(C.databar.iconcolor))

    -- Create a separate frame for the text
    local textFrame = CreateFrame("Frame", nil, ilvlIcon)
    textFrame:SetAllPoints()
    textFrame:SetFrameLevel(ilvlIcon:GetFrameLevel() + 1)

    -- Create the item level text
    local ilvlText = textFrame:CreateFontString(nil, "OVERLAY")
    ilvlText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    ilvlText:SetPoint("TOP", textFrame, "TOP", 1, -3)
    ilvlText:SetJustifyH("CENTER")
    ilvlText:SetTextColor(T.color.r, T.color.g, T.color.b)

    -- Function to update the item level text
    local function UpdateItemLevel()
        local _, equippedIlvl = GetAverageItemLevel()
        ilvlText:SetText(string.format("%d", math.floor(equippedIlvl)))
    end

    -- Function to show equipment sets menu
    local function ShowEquipmentSetsMenu()
        local menu = {}
        local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()

        for _, setID in ipairs(equipmentSetIDs) do
            local name, iconFileID, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
            table.insert(menu, {
                text = name,
                icon = iconFileID,
                checked = isEquipped,
                func = function()
                    C_EquipmentSet.UseEquipmentSet(setID)
                end
            })
        end

        -- Add an option to open the Equipment Manager
        table.insert(menu, {
            text = "Equipment Manager",
            icon = 134331, -- Interface\\Icons\\INV_Misc_Gear_02
            func = function()
                ToggleCharacter("PaperDollFrame")
                PaperDollFrame_SetSidebar(PaperDollFrame, 2)
            end
        })

        EasyMenu(menu, CreateFrame("Frame", "EquipmentSetsMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0,
            "MENU")
    end

    -- Set up click handlers
    ilvlIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    ilvlIcon:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            ToggleCharacter("PaperDollFrame")
        elseif button == "RightButton" then
            ShowEquipmentSetsMenu()
        end
    end)

    -- Update tooltip to include information about right-click functionality
    ilvlIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Item Level", 1, 1, 1)
        GameTooltip:AddLine(" ")
        local _, equippedIlvl = GetAverageItemLevel()
        GameTooltip:AddDoubleLine("Equipped Item Level:", string.format("%.2f", equippedIlvl), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-click to open Character Pane", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-click to change Equipment Set", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    ilvlIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Update the text initially
    UpdateItemLevel()

    -- Register events for updates
    self.itemLevelModule:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.itemLevelModule:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
    self.itemLevelModule:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    self.itemLevelModule:SetScript("OnEvent", function(self, event)
        UpdateItemLevel()
    end)
end