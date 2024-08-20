local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Loot Specialization Module
----------------------------------------------------------------------------------------

function DB:CreateLootSpecModule()
    -- Create the loot spec module frame
    self.lootSpecModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.lootSpecModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.lootSpecModule:SetPoint("LEFT", self.specModule, "RIGHT", 5, 0)

    -- Create the loot specialization icon
    local lootSpecIcon = CreateFrame("Button", nil, self.lootSpecModule)
    lootSpecIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    lootSpecIcon:SetPoint("CENTER", self.lootSpecModule, "CENTER", 0, 0)
    lootSpecIcon:SetTemplate("Transparent")


    local lootSpecTexture = lootSpecIcon:CreateTexture(nil, "ARTWORK")
    lootSpecTexture:SetSize(C.databar.iconsize, C.databar.iconsize)
    lootSpecTexture:SetPoint("CENTER", lootSpecIcon, "CENTER")
    lootSpecTexture:SetVertexColor(unpack(C.databar.iconcolor))
    lootSpecIcon.texture = lootSpecTexture

    -- Create the loot spec text
    local lootSpecText = lootSpecIcon:CreateFontString(nil, "OVERLAY")
    lootSpecText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    lootSpecText:SetPoint("BOTTOMLEFT", lootSpecIcon, "BOTTOMLEFT", 2, 2)
    lootSpecText:SetJustifyH("CENTER")
    lootSpecText:SetText("L")
    lootSpecText:SetTextColor(unpack(C.databar.fontcolor))
    lootSpecText:SetDrawLayer("OVERLAY", 7)

    local specCoords = {
        [1] = { 0.00, 0.25, 0, 1 },
        [2] = { 0.25, 0.50, 0, 1 },
        [3] = { 0.50, 0.75, 0, 1 },
        [4] = { 0.75, 1.00, 0, 1 }
    }

    -- Function to update the module
    local function UpdateLootSpecModule()
        local lootSpecID = GetLootSpecialization()

        if lootSpecID == 0 then
            lootSpecID = GetSpecialization()
        end

        -- Convert the loot spec ID to a spec index (1-4)
        local specIndex
        for i = 1, GetNumSpecializations() do
            local specID = GetSpecializationInfo(i)
            if specID == lootSpecID then
                specIndex = i
                break
            end
        end
        specIndex = specIndex or GetSpecialization() -- Fallback to current spec if not found

        -- Update loot spec icon to show spec
        local classFilename = select(2, UnitClass("player"))
        local texturePath = "Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\" .. string.upper(classFilename)

        lootSpecTexture:SetTexture(texturePath)
        lootSpecTexture:SetTexCoord(unpack(specCoords[specIndex]))
    end

    -- Function to show loot spec menu
    local function ShowLootSpecMenu(self, button)
        if button == "LeftButton" then
            SetLootSpecialization(0) -- Set to current spec
            UpdateLootSpecModule()
        elseif button == "RightButton" then
            local menu = {}
            local currentSpecID = GetLootSpecialization()
            local currentSpec = GetSpecialization()
            local _, currentSpecName = GetSpecializationInfo(currentSpec)

            menu[1] = { text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true }
            menu[2] = {
                text = string.format(LOOT_SPECIALIZATION_DEFAULT, currentSpecName),
                checked = (currentSpecID == 0),
                func = function()
                    SetLootSpecialization(0)
                    UpdateLootSpecModule()
                end
            }

            for i = 1, GetNumSpecializations() do
                local id, name = GetSpecializationInfo(i)
                menu[i + 2] = {
                    text = name,
                    checked = (currentSpecID == id),
                    func = function()
                        SetLootSpecialization(id)
                        UpdateLootSpecModule()
                    end
                }
            end

            EasyMenu(menu, CreateFrame("Frame", "LootSpecializationMenu", UIParent, "UIDropDownMenuTemplate"), "cursor",
                0, 120, "MENU", 10)
        end
    end

    -- Function to show tooltip
    local function ShowTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local lootSpecID = GetLootSpecialization()
        local currentSpec = GetSpecialization()
        local _, currentSpecName = GetSpecializationInfo(currentSpec)

        GameTooltip:AddLine("Loot Specialization", 1, 1, 1)
        GameTooltip:AddLine(" ")

        if lootSpecID == 0 then
            GameTooltip:AddLine("Current: " .. currentSpecName .. " (Current Spec)", 0, 1, 0)
        else
            local _, name = GetSpecializationInfoByID(lootSpecID)
            GameTooltip:AddLine("Current: " .. name, 0, 1, 0)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Right-click to change Loot Spec.", 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end

    -- Set up click handler
    lootSpecIcon:EnableMouse(true)
    lootSpecIcon:RegisterForClicks("AnyUp")
    lootSpecIcon:SetScript("OnClick", ShowLootSpecMenu)

    -- Set up tooltip
    lootSpecIcon:SetScript("OnEnter", ShowTooltip)
    lootSpecIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Register events for updates
    self.lootSpecModule:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
    self.lootSpecModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.lootSpecModule:SetScript("OnEvent", function(self, event, ...)
        UpdateLootSpecModule()
    end)

    -- Initial update
    UpdateLootSpecModule()
end