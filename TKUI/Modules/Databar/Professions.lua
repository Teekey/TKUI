local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Professions Module
----------------------------------------------------------------------------------------

function DB:CreateProfessionsModule()
    -- Create the professions module frame
    self.professionsModule = CreateFrame("Frame", nil, self.TKUIRightBar1)
    self.professionsModule:SetSize(C.databar.iconsize * 4, C.databar.iconsize) -- Width for four icons
    self.professionsModule:SetPoint("LEFT", self.TKUIRightBar1, "LEFT", 0, 0)

    local professionIcons = {}

    -- Define the profession icons table locally
    local professionIconsTable = {
        [164] = "Blacksmithing",
        [165] = "Leatherworking",
        [171] = "Alchemy",
        [182] = "Herbalism",
        [185] = "Cooking",
        [186] = "Mining",
        [197] = "Tailoring",
        [202] = "Engineering",
        [333] = "Enchanting",
        [393] = "Skinning",
        [755] = "Jewelcrafting",
        [773] = "Inscription",
        [356] = "Fishing",
    }

    -- Local function to get profession icon
    local function GetProfessionIcon(professionID)
        local iconName = professionIconsTable[professionID] or "Default"
        return "Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\" .. iconName
    end

    -- Function to update profession icons
    local function UpdateProfessionIcons()
        -- Hide all existing icons
        for _, icon in pairs(professionIcons) do
            icon:Hide()
        end

        local professions = {}
        local prof1, prof2, archaeology, fishing, cooking = GetProfessions()

        local function AddProfession(index)
            if index then
                local name, icon, skillLevel, maxSkillLevel, _, _, skillLine, _, _ = GetProfessionInfo(index)
                if skillLevel > 0 then
                    table.insert(professions, {
                        name = name,
                        level = skillLevel,
                        maxLevel = maxSkillLevel,
                        id = skillLine
                    })
                end
            end
        end

        AddProfession(prof1)
        AddProfession(prof2)
        AddProfession(fishing)
        AddProfession(cooking)

        -- Sort professions by skill level (highest first)
        table.sort(professions, function(a, b) return a.level > b.level end)

        -- Create or update icons for each profession
        for i, profession in ipairs(professions) do
            if i > 4 then break end -- Only show up to 4 professions

            local icon = professionIcons[i]
            if not icon then
                icon = CreateFrame("Button", nil, self.professionsModule)
                icon:SetSize(C.databar.iconsize, C.databar.iconsize)
                icon:SetPoint("LEFT", (i - 1) * (C.databar.iconsize + 4), 0)
                icon:SetTemplate("Transparent")

                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetPoint("CENTER", icon, "CENTER")
                icon.texture:SetSize(C.databar.iconsize * .8, C.databar.iconsize * .8)
                icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                -- Create the radial status bar
                icon.radialBar = T.CreateRadialStatusBar(icon)
                icon.radialBar:SetAllPoints(icon)
                icon.radialBar:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\RadialBorder")
                icon.radialBar:SetVertexColor(T.color.r, T.color.g, T.color.b)
                icon.radialBar:SetFrameLevel(icon:GetFrameLevel() + 1)

                professionIcons[i] = icon
            end

            -- Set icon texture based on profession ID
            local texturePath = GetProfessionIcon(profession.id)
            icon.texture:SetTexture(texturePath)
            icon.texture:SetVertexColor(unpack(C.databar.iconcolor))

            -- Update radial bar
            local percentSkill = profession.level / profession.maxLevel
            icon.radialBar:SetRadialStatusBarValue(percentSkill)

            -- Show the icon
            icon:Show()

            -- Set up tooltip
            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(profession.name, 1, 1, 1)
                GameTooltip:AddLine(profession.level .. " / " .. profession.maxLevel, 1, 1, 1)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Click to toggle " .. profession.name .. " window.", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            icon:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Set up click functionality to open profession window
            icon:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    C_TradeSkillUI.OpenTradeSkill(profession.id)
                elseif button == "RightButton" then
                    ToggleSpellBook(BOOKTYPE_PROFESSION)
                end
            end)
        end
        for i = #professions + 1, #professionIcons do
            professionIcons[i]:Hide()
        end
    end

    -- Register events for updates
    self.professionsModule:RegisterEvent("SKILL_LINES_CHANGED")
    self.professionsModule:RegisterEvent("SPELLS_CHANGED")
    self.professionsModule:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    self.professionsModule:SetScript("OnEvent", function(self, event, ...)
        UpdateProfessionIcons()
    end)

    -- Initial update
    UpdateProfessionIcons()
end