local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Hearthstone Module
----------------------------------------------------------------------------------------

function DB:CreateHearthstoneModule()
    -- Create the hearthstone module frame
    self.hearthstoneModule = CreateFrame("Frame", nil, self.TKUIRightBar1)
    self.hearthstoneModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.hearthstoneModule:SetPoint("RIGHT", self.TKUIRightBar1, "RIGHT", 0, 0)

    -- Create the hearthstone button as a SecureActionButton
    local hearthButton = CreateFrame("Button", "TKUIHearthstoneButton", self.TKUIRightBar1, "SecureActionButtonTemplate")
    hearthButton:SetSize(C.databar.iconsize, C.databar.iconsize)
    hearthButton:SetPoint("CENTER", self.hearthstoneModule)
    hearthButton:SetTemplate("Transparent")

    -- Create the cooldown frame
    local cooldown = CreateFrame("Cooldown", nil, hearthButton, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetReverse(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetSwipeColor(0, 0, 0, 0.8)
    cooldown:SetFrameLevel(hearthButton:GetFrameLevel() + 1)
    hearthButton.cooldown = cooldown

    -- Create a separate frame for the texture
    local textureFrame = CreateFrame("Frame", nil, hearthButton)
    textureFrame:SetAllPoints()
    textureFrame:SetFrameLevel(cooldown:GetFrameLevel() + 1)

    -- Create the hearthstone icon texture
    local hearthTexture = textureFrame:CreateTexture(nil, "ARTWORK")
    hearthTexture:SetSize(C.databar.iconsize * 0.7, C.databar.iconsize * 0.7)
    hearthTexture:SetPoint("CENTER", textureFrame, "CENTER")
    hearthButton.texture = hearthTexture

    -- Table to store hearthstone and teleport items
    local hearthItems = {
        6948,   -- Hearthstone
        110560, -- Garrison Hearthstone
        140192, -- Dalaran Hearthstone
        -- 180290, -- Night Fae Hearthstone
        -- Add more hearthstone or teleport item IDs here
    }

    local currentHearthIndex = 1

    -- Function to update the hearthstone button
    local function UpdateHearthButton()
        local itemID = hearthItems[currentHearthIndex]
        local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)

        if itemTexture then
            hearthTexture:SetTexture(itemTexture)
        end

        -- Update cooldown
        local start, duration = GetItemCooldown(itemID)
        if start > 0 and duration > 0 then
            cooldown:SetCooldown(start, duration)
            -- Desaturate the icon
            hearthTexture:SetDesaturated(true)
        else
            cooldown:Clear()
            -- Remove desaturation
            hearthTexture:SetDesaturated(false)
        end

        -- Only set attributes when not in combat
        if not InCombatLockdown() then
            -- Set up left-click action
            hearthButton:SetAttribute("type1", "macro")
            hearthButton:SetAttribute("macrotext1", "/use item:" .. itemID)

            -- Set up right-click action to show menu
            hearthButton:SetAttribute("type2", "macro")
            hearthButton:SetAttribute("macrotext2", "/click HearthstoneMenuButton")
        end
    end

    -- Function to show the hearthstone menu
    local function ShowHearthMenu()
        local menu = {}
        for i, itemID in ipairs(hearthItems) do
            local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
            if itemName and (IsUsableItem(itemID) or PlayerHasToy(itemID)) then
                local start, duration = GetItemCooldown(itemID)
                local isOnCooldown = (start > 0 and duration > 0)

                table.insert(menu, {
                    text = itemName,
                    icon = itemTexture,
                    checked = (i == currentHearthIndex),
                    func = function()
                        currentHearthIndex = i
                        UpdateHearthButton()
                    end,
                    disabled = isOnCooldown,
                    tooltipTitle = isOnCooldown and itemName or nil,
                    tooltipText = isOnCooldown and
                        "On cooldown: " .. SecondsToTime(math.ceil(duration - (GetTime() - start))) or nil,
                    tooltipOnButton = true,
                })
            end
        end
        EasyMenu(menu, CreateFrame("Frame", "HearthstoneMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 100,
            "MENU")
    end

    -- Create a hidden button to handle the right-click menu
    local menuButton = CreateFrame("Button", "HearthstoneMenuButton", UIParent, "SecureHandlerClickTemplate")
    menuButton:Hide()
    menuButton:SetScript("OnClick", ShowHearthMenu)

    -- Set up click handlers
    hearthButton:EnableMouse(true)
    hearthButton:RegisterForClicks("AnyUp", "AnyDown")

    -- Set up tooltip
    hearthButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local currentItemID = hearthItems[currentHearthIndex]
        local currentItemName, _, _, _, _, _, _, _, _, currentItemTexture = GetItemInfo(currentItemID)

        GameTooltip:AddLine(currentItemName, 1, 1, 1)
        GameTooltip:AddLine(" ")

        for i, itemID in ipairs(hearthItems) do
            local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
            if itemName then
                local start, duration = GetItemCooldown(itemID)
                if start > 0 and duration > 0 then
                    local remainingCooldown = math.ceil(duration - (GetTime() - start))
                    GameTooltip:AddDoubleLine(
                        "|T" .. itemTexture .. ":14:14:0:0:64:64:5:59:5:59|t " .. itemName,
                        SecondsToTime(remainingCooldown),
                        0.5, 0.5, 0.5, 0.5, 0.5, 0.5
                    )
                else
                    local r, g, b = 1, 1, 1
                    if i == currentHearthIndex then
                        r, g, b = 0, 1, 0 -- Green for the currently selected item
                    end
                    GameTooltip:AddLine("|T" .. itemTexture .. ":14:14:0:0:64:64:5:59:5:59|t " .. itemName, r, g, b)
                end
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-click to use", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-click to change", 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end)

    hearthButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Call UpdateHearthButton when the module is initialized
    UpdateHearthButton()

    -- Register events for updates
    self.hearthstoneModule:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self.hearthstoneModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.hearthstoneModule:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.hearthstoneModule:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" or not InCombatLockdown() then
            UpdateHearthButton()
        end
    end)

    -- Update cooldown every second, but only update attributes when out of combat
    local updateTimer = 0
    hearthButton:SetScript("OnUpdate", function(self, elapsed)
        updateTimer = updateTimer + elapsed
        if updateTimer >= 1 then
            updateTimer = 0
            if not InCombatLockdown() then
                UpdateHearthButton()
            else
                -- Update only visual elements during combat
                local itemID = hearthItems[currentHearthIndex]
                local start, duration = GetItemCooldown(itemID)
                if start > 0 and duration > 0 then
                    cooldown:SetCooldown(start, duration)
                    hearthTexture:SetDesaturated(true)
                else
                    cooldown:Clear()
                    hearthTexture:SetDesaturated(false)
                end
            end
        end
    end)

    -- Initial update
    UpdateHearthButton()
end