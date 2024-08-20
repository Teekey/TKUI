local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Gold Module
----------------------------------------------------------------------------------------

function DB:CreateGoldModule()
    -- Create the gold module frame
    self.goldModule = CreateFrame("Button", nil, self.TKUIRightBar1)
    self.goldModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.goldModule:SetPoint("RIGHT", self.bagModule, "LEFT", -4, 0)
    self.goldModule:SetTemplate("Transparent")

    -- Create the gold icon
    local texture = self.goldModule:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\Currency")
    texture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    texture:SetPoint("BOTTOM", self.goldModule, "BOTTOM")
    self.goldModule.texture = texture

    -- Create the gold text
    self.goldModule.text = self.goldModule:CreateFontString(nil, "OVERLAY")
    self.goldModule.text:SetFont(C.font.databar_font, C.font.databar_font_size - 2, C.font.databar_font_style)
    self.goldModule.text:SetPoint("TOP", self.goldModule, "TOP", 0, -3)
    self.goldModule.text:SetJustifyH("CENTER")

    -- Function to format money
    local function FormatMoney(copper, shortened)
        if shortened then
            return T.ShortValue(floor(copper / COPPER_PER_GOLD))
        else
            return GetCoinTextureString(copper)
        end
    end

    -- Function to update the gold text
    local function UpdateGold()
        local currentMoney = GetMoney()
        self.goldModule.text:SetText(FormatMoney(currentMoney, true))
        self.goldModule.text:SetTextColor(unpack(C.databar.fontcolor))
        self.goldModule.texture:SetVertexColor(unpack(C.databar.iconcolor))

        -- Initialize TKUISettings if it doesn't exist
        if not TKUISettings then
            TKUISettings = { Gold = {} }
        end

        TKUISettings.Gold[T.name] = currentMoney
    end

    -- Function to show tooltip
    local function ShowTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local currentMoney = GetMoney()
        GameTooltip:AddLine("Currency", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T.name, FormatMoney(currentMoney), 1, 1, 1, 1, 1, 1)

        if TKUISettings and TKUISettings.Gold then
            local totalGold = currentMoney
            local sortedCharacters = {}

            -- Collect character data and calculate total gold
            for characterName, gold in pairs(TKUISettings.Gold) do
                if characterName ~= T.name then
                    table.insert(sortedCharacters, { name = characterName, gold = gold })
                end
                totalGold = totalGold + gold
            end

            -- Sort characters by gold amount (descending order)
            table.sort(sortedCharacters, function(a, b) return a.gold > b.gold end)

            if #sortedCharacters > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Other Characters:", 1, 0.82, 0)

                -- Check if C.databar.currency_characters is initialized, set default if nil
                local displayLimit = C.databar.currency_characters or 5 -- Default to 5 if nil
                local displayCount = math.min(displayLimit, #sortedCharacters)

                for i = 1, displayCount do
                    local character = sortedCharacters[i]
                    GameTooltip:AddDoubleLine(character.name, FormatMoney(character.gold), 1, 1, 1, 1, 1, 1)
                end

                -- If there are more characters than the limit, add a line to indicate this
                if #sortedCharacters > displayCount then
                    GameTooltip:AddLine("...and " .. (#sortedCharacters - displayCount) .. " more", 0.7, 0.7, 0.7)
                end

                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("Total", FormatMoney(totalGold), 1, 1, 1, 1, 1, 1)
            end
        end

        GameTooltip:Show()
    end

    -- Set up tooltip
    self.goldModule:SetScript("OnEnter", ShowTooltip)
    self.goldModule:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Set up click handler
    self.goldModule:SetScript("OnClick", ToggleAllBags)

    -- Update the text initially
    UpdateGold()

    -- Register events for updates
    self.goldModule:RegisterEvent("PLAYER_MONEY")
    self.goldModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.goldModule:SetScript("OnEvent", function(self, event)
        UpdateGold()
    end)
end
