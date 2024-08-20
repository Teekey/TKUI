local T, C, L = unpack(TKUI)
local DB = T.DB


----------------------------------------------------------------------------------------
--	Specialization Module
----------------------------------------------------------------------------------------

function DB:CreateSpecModule()
    -- Create the spec module frame
    self.specModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.specModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.specModule:SetPoint("LEFT", self.itemLevelModule, "RIGHT", 5, 0)

    local specCoords = {
        [1] = { 0.00, 0.25, 0, 1 },
        [2] = { 0.25, 0.50, 0, 1 },
        [3] = { 0.50, 0.75, 0, 1 },
        [4] = { 0.75, 1.00, 0, 1 }
    }

    -- Create the specialization icon
    local specIcon = CreateFrame("Button", nil, self.specModule)
    specIcon:SetSize(C.databar.iconsize, C.databar.iconsize)
    specIcon:SetPoint("CENTER", self.specModule, "CENTER", 0, 0)
    specIcon:SetTemplate("Transparent")

    local specTexture = specIcon:CreateTexture(nil, "ARTWORK")
    specTexture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\" ..
        string.upper(select(2, UnitClass("player"))))
    specTexture:SetSize(C.databar.iconsize, C.databar.iconsize)
    specTexture:SetPoint("CENTER", specIcon, "CENTER")
    specTexture:SetVertexColor(unpack(C.databar.iconcolor))
    specIcon.texture = specTexture

    -- Create the loot spec text
    local specText = specIcon:CreateFontString(nil, "OVERLAY")
    specText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    specText:SetPoint("BOTTOMLEFT", specIcon, "BOTTOMLEFT", 2, 2)
    specText:SetJustifyH("CENTER")
    specText:SetText("S")
    specText:SetTextColor(unpack(C.databar.fontcolor))
    specText:SetDrawLayer("OVERLAY", 7)

    -- Function to update the module
    local function UpdateSpecModule()
        local currentSpecID = GetSpecialization() or 1
        specTexture:SetTexCoord(unpack(specCoords[currentSpecID]))
    end
    -- Function to show spec menu
    local function ShowSpecMenu(self, button)
        if button == "RightButton" then
            local menu = {}
            local currentSpecID = GetSpecialization()

            -- Add title
            table.insert(menu, {
                text = "Specializations",
                isTitle = true,
                notCheckable = true,
            })

            for i = 1, GetNumSpecializations() do
                local id, name, description, icon = GetSpecializationInfo(i)
                local isCurrentSpec = (currentSpecID == i)
                menu[#menu + 1] = {
                    text = name,
                    checked = isCurrentSpec,
                    func = function()
                        SetSpecialization(i)
                    end,
                    colorCode = isCurrentSpec and "|cff00ff00" or "|cffffffff",
                }
            end

            EasyMenu(menu, CreateFrame("Frame", "SpecializationMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0,
                100, "MENU")
        end
    end


    -- Function to show tooltip
    local function ShowTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local currentSpecID = GetSpecialization()
        local _, name, description = GetSpecializationInfo(currentSpecID)

        GameTooltip:AddLine("Current Specialization", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(name, 0, 1, 0)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Right-click to change specialization", 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end

    -- Set up click handler
    specIcon:EnableMouse(true)
    specIcon:RegisterForClicks("AnyUp")
    specIcon:SetScript("OnClick", ShowSpecMenu)

    -- Set up tooltip
    specIcon:SetScript("OnEnter", ShowTooltip)
    specIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Register events for updates
    self.specModule:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self.specModule:SetScript("OnEvent", function(self, event, ...)
        UpdateSpecModule()
    end)

    -- Initial update
    UpdateSpecModule()
end