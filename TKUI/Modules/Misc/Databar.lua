----------------------------------------------------------------------------------------
--	TKUI Data Bar for TKUI
--	This module creates a custom data bar for TKUI, displaying information like
--  system performance, character stats, currency, and more.
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
local TKUIBar = {}

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------

function TKUIBar:Initialize()
    --Left Bar
    TKUIBar:CreateLeftBar()
    TKUIBar:CreateMicroMenu()
    TKUIBar:CreateSystemModule()
    TKUIBar:CreateVolumeModule()
    --Right Bar 1
    TKUIBar:CreateRightBar1()
    TKUIBar:CreateHearthstoneModule()
    TKUIBar:CreateBagModule()
    TKUIBar:CreateGoldModule()
    TKUIBar:CreateProfessionsModule()
    --Right Bar 2
    TKUIBar:CreateRightBar2()
    TKUIBar:CreateExperienceModule()
    TKUIBar:CreateDurabilityModule()
    TKUIBar:CreateItemLevelModule()
    TKUIBar:CreateSpecModule()
    TKUIBar:CreateLootSpecModule()
    --Clock
    TKUIBar:CreateClockModule()
end

----------------------------------------------------------------------------------------
--	Helper Functions
----------------------------------------------------------------------------------------

function TKUIBar:CreateButton(parent, texture, bg, textString, ...)
    -- Create the button frame
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(C.databar.iconsize, C.databar.iconsize)
    if ... then button:SetPoint(...) end
    -- Apply the texture
    if texture then
        button:SetNormalTexture(texture)
    end

    if bg then
        button:SetTemplate("Transparent")
    end

    -- Create the text
    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    button.text:SetPoint("BOTTOM", button, "BOTTOM", 0, 2) -- Center the text in the button
    button.text:SetTextColor(1, 1, 1, 1)                   -- White text for visibility
    button.text:SetText(textString or "")

    -- Make sure the text is on top
    button.text:SetDrawLayer("OVERLAY", 7)

    return button
end

----------------------------------------------------------------------------------------
--	Bar Creation
----------------------------------------------------------------------------------------

local function SetupMouseoverBehavior(frame)
    if C.databar.enableMouseover then
        frame:SetAlpha(C.databar.normalAlpha)

        local function OnEnter(self)
            frame:SetAlpha(C.databar.mouseoverAlpha)
        end

        local function OnLeave(self)
            C_Timer.After(0.1, function()
                if not MouseIsOver(frame) then
                    frame:SetAlpha(C.databar.normalAlpha)
                end
            end)
        end

        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)

        -- Apply to all child frames recursively
        local function ApplyToChildren(parent)
            for _, child in ipairs({ parent:GetChildren() }) do
                child:HookScript("OnEnter", OnEnter)
                child:HookScript("OnLeave", OnLeave)
                ApplyToChildren(child)
            end
        end

        ApplyToChildren(frame)

        -- Create a timer to check mouse position periodically
        frame.updateTimer = C_Timer.NewTicker(0.1, function()
            if MouseIsOver(frame) then
                frame:SetAlpha(C.databar.mouseoverAlpha)
            else
                frame:SetAlpha(C.databar.normalAlpha)
            end
        end)
    else
        frame:SetAlpha(C.databar.mouseoverAlpha)
    end
end

function TKUIBar:CreateLeftBar()
    -- Create the main frame for the left TKUIBar
    self.TKUILeftBar = CreateFrame("Frame", "TKUILeftBar", UIParent)
    self.TKUILeftBar:CreatePanel("Invisible", 600, 40, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    SetupMouseoverBehavior(self.TKUILeftBar)
end

function TKUIBar:CreateRightBar1()
    -- Create the main frame for the right TKUIBar (section 1)
    self.TKUIRightBar1 = CreateFrame("Frame", "TKUIRightBar1", UIParent)
    self.TKUIRightBar1:CreatePanel("Invisible", 300, 40, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 0)
    SetupMouseoverBehavior(self.TKUIRightBar1)
end

function TKUIBar:CreateRightBar2()
    -- Create the main frame for the right TKUIBar (section 2)
    self.TKUIRightBar2 = CreateFrame("Frame", "TKUIRightBar2", UIParent)
    self.TKUIRightBar2:CreatePanel("Invisible", 300, 40, "RIGHT", "TKUIRightBar1", "LEFT", -4, 0)
    SetupMouseoverBehavior(self.TKUIRightBar2)
end

----------------------------------------------------------------------------------------
--	Micro Menu Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateMicroMenu()
    self.microMenu = CreateFrame("Frame", nil, self.TKUILeftBar)
    self.microMenu:SetSize(500, 35)
    self.microMenu:SetPoint("LEFT", self.TKUILeftBar, "LEFT", 5, 0)

    self.buttons = {
        { name = "GameMenu",           func = function() ToggleFrame(GameMenuFrame) end },
        { name = "Character",          func = function() ToggleCharacter("PaperDollFrame") end },
        { name = "Spellbook",          func = function() ToggleSpellBook(BOOKTYPE_SPELL) end },
        { name = "ClassTalent",        func = ToggleTalentFrame },
        { name = "Achievement",        func = ToggleAchievementFrame },
        { name = "QuestScroll",        func = ToggleQuestLog },
        { name = "Friends",            func = ToggleFriendsFrame },
        { name = "Communities",        func = ToggleGuildFrame },
        { name = "PVE",                func = ToggleLFDParentFrame },
        { name = "CollectionsJournal", func = ToggleCollectionsJournal },
        { name = "EncounterJournal",   func = ToggleEncounterJournal },
        { name = "PvP",                func = TogglePVPUI },
        { name = "Store",              func = ToggleStoreUI },
        { name = "Help",               func = ToggleHelpFrame },
    }

    local function CreateFriendsTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Friends", 1, 1, 1)
        GameTooltip:AddLine(" ")

        local numBNetTotal, numBNetOnline = BNGetNumFriends()
        local totalOnlineFriends = C_FriendList.GetNumOnlineFriends()
        local playerFaction = UnitFactionGroup("player")

        GameTooltip:AddDoubleLine("Total Online Friends:", numBNetOnline + totalOnlineFriends, 1, 1, 1, 1, 1, 1)
        GameTooltip:AddLine(" ")

        -- Battle.net friends
        if numBNetOnline > 0 then
            GameTooltip:AddLine("Battle.net Friends", 0.1, 0.6, 0.8)
            for i = 1, numBNetTotal do
                local friendAccInfo = C_BattleNet.GetFriendAccountInfo(i)
                if friendAccInfo and friendAccInfo.gameAccountInfo.isOnline then
                    local gameAccount = friendAccInfo.gameAccountInfo
                    local charName = gameAccount.characterName
                    local gameClient = gameAccount.clientProgram
                    local realmName = gameAccount.realmName
                    local faction = gameAccount.factionName
                    local zone = gameAccount.areaName
                    local richPresence = gameAccount.richPresence
                    local isWoW = (gameClient == BNET_CLIENT_WOW)
                    local isClassic = (isWoW and richPresence:find("Classic"))
                    local statusIcon = FRIENDS_TEXTURE_ONLINE
                    local socialIcon = BNet_GetClientEmbeddedAtlas(gameClient, 16)
                    local note = friendAccInfo.note ~= "" and ("(|cffecd672" .. friendAccInfo.note .. "|r)") or ""
                    local charNameFormat = ""
    
                    if friendAccInfo.isAFK or gameAccount.isGameAFK then
                        statusIcon = FRIENDS_TEXTURE_AFK
                    elseif friendAccInfo.isDND or gameAccount.isGameBusy then
                        statusIcon = FRIENDS_TEXTURE_DND
                    end
    
                    if isWoW then
                        if isClassic then
                            charNameFormat = richPresence
                        elseif (not faction) or (faction == playerFaction) then
                            charNameFormat = string.format("(|cffecd672%s-%s|r)", charName or "N/A", realmName or "N/A")
                        else
                            local factionColors = {
                                ['Alliance'] = "ff008ee8",
                                ['Horde'] = "ffc80000"
                            }
                            charNameFormat = string.format("(|c%s%s|r - |cffecd672%s|r)", factionColors[faction], faction,
                                charName or "N/A")
                        end
                    end
    
                    local lineLeft = string.format("|T%s:16|t|cff82c5ff %s|r %s", statusIcon, friendAccInfo.accountName,
                        note)
                    local lineRight = ""
    
                    if not isWoW then
                        lineRight = socialIcon
                    elseif isClassic then
                        lineRight = string.format("%s %s", richPresence, socialIcon)
                    else
                        lineRight = string.format("%s %s %s", charNameFormat, zone, socialIcon)
                    end
    
                    GameTooltip:AddDoubleLine(lineLeft, lineRight, 1, 1, 1, 1, 1, 1)
                end
            end
            GameTooltip:AddLine(" ")
        end

        -- WoW friends
        if totalOnlineFriends > 0 then
            GameTooltip:AddLine("World of Warcraft Friends", 0.1, 0.6, 0.8)
            for i = 1, C_FriendList.GetNumFriends() do
                local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                if friendInfo.connected then
                    local name = friendInfo.name
                    local level = friendInfo.level
                    local class = friendInfo.className
                    local area = friendInfo.area
                    local statusIcon = FRIENDS_TEXTURE_ONLINE
                    if friendInfo.afk then
                        statusIcon = FRIENDS_TEXTURE_AFK
                    elseif friendInfo.dnd then
                        statusIcon = FRIENDS_TEXTURE_DND
                    end
                    local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
                    local lineLeft = string.format("|T%s:16|t %s, " .. LEVEL .. ":%s %s", statusIcon, name, level, class)
                    local lineRight = area
                    GameTooltip:AddDoubleLine(lineLeft, lineRight, classColor.r, classColor.g, classColor.b, 1, 1, 1)
                end
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-Click: Open Friends List", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Shift-Click: Invite to Group", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-Click: Whisper", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end

    local function CreateCommunitiesTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Guild", 1, 1, 1)
        GameTooltip:AddLine(" ")

        local guildName, guildRankName, guildRankIndex, realm = GetGuildInfo("player")
        if not guildName then
            GameTooltip:AddLine("You are not in a guild", 1, 0.1, 0.1)
        else
            local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
            GameTooltip:AddDoubleLine("Guild Name:", guildName, 1, 1, 1, 0.1, 1, 0.1)
            GameTooltip:AddDoubleLine("Your Rank:", guildRankName, 1, 1, 1, 0.1, 1, 0.1)
            GameTooltip:AddDoubleLine("Online Members:", numOnlineGuildMembers .. "/" .. numTotalGuildMembers, 1, 1, 1, 0.1, 1, 0.1)
            GameTooltip:AddLine(" ")

            -- Sort online members by rank
            local onlineMembers = {}
            for i = 1, numTotalGuildMembers do
                local name, rank, rankIndex, level, _, zone, note, officernote, online, status, class = GetGuildRosterInfo(i)
                if online then
                    table.insert(onlineMembers, {name = name, rank = rank, rankIndex = rankIndex, level = level, zone = zone, status = status, class = class})
                end
            end
            table.sort(onlineMembers, function(a, b) return a.rankIndex < b.rankIndex end)

            -- Display online members (up to 20)
            GameTooltip:AddLine("Online Guild Members", 0.1, 0.6, 0.8)
            for i = 1, math.min(20, #onlineMembers) do
                local member = onlineMembers[i]
                local statusIcon = FRIENDS_TEXTURE_ONLINE
                if member.status == 1 then
                    statusIcon = FRIENDS_TEXTURE_AFK
                elseif member.status == 2 then
                    statusIcon = FRIENDS_TEXTURE_DND
                end
                local classColor = RAID_CLASS_COLORS[member.class] or NORMAL_FONT_COLOR
                local lineLeft = string.format("|T%s:16|t |c%s%s|r", statusIcon, classColor.colorStr, member.name)
                local lineRight = string.format("%s (%d)", member.zone or "Unknown", member.level)
                GameTooltip:AddDoubleLine(lineLeft, lineRight, 1, 1, 1, 0.5, 0.5, 0.5)
            end

            if #onlineMembers > 20 then
                GameTooltip:AddLine("... and " .. (#onlineMembers - 20) .. " more", 0.7, 0.7, 0.7)
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-Click: Open Guild Roster", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-Click: Open Communities", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end

    local function UpdateFriendText(button)
        local _, bnOnlineMembers = BNGetNumFriends()
        local friendsOnline = C_FriendList.GetNumOnlineFriends()
        local totalFriends = bnOnlineMembers + friendsOnline
        button.text:SetText(totalFriends)
    end

    local function UpdateGuildText(button)
        local numTotalGuildMembers, numOnlineGuildMembers = GetNumGuildMembers()
        button.text:SetText(numOnlineGuildMembers)
    end

    for i, buttonInfo in ipairs(self.buttons) do
        local button = self:CreateButton(self.microMenu,
            "Interface\\AddOns\\TKUI\\Media\\Textures\\Databar\\" .. buttonInfo.name,
            true, "", "LEFT", (i - 1) * 35, 0)

        if buttonInfo.name == "Friends" then
            button:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(T.color.r, T.color.g, T.color.b)
                self:SetBackdropBorderColor(T.color.r, T.color.g, T.color.b)
                CreateFriendsTooltip(self)
            end)
            button:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(C.databar.iconcolor))
                self:SetBackdropBorderColor(unpack(C.media.border_color))
                GameTooltip:Hide()
            end)
            button:SetScript("OnClick", function(self, btnType)
                if btnType == "LeftButton" then
                    ToggleFriendsFrame()
                elseif btnType == "RightButton" then
                    local friendsList = {}
                    for i = 1, C_FriendList.GetNumFriends() do
                        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                        if friendInfo.connected then
                            table.insert(friendsList, { name = friendInfo.name, isBNet = false })
                        end
                    end
                    local numBNetTotal, numBNetOnline = BNGetNumFriends()
                    for i = 1, numBNetTotal do
                        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
                        if accountInfo and accountInfo.isOnline then
                            table.insert(friendsList, { name = accountInfo.accountName, isBNet = true })
                        end
                    end
                    if #friendsList > 0 then
                        local friend = friendsList[math.random(#friendsList)]
                        if friend.isBNet then
                            ChatFrame_SendBNetTell(friend.name)
                        else
                            ChatFrame_OpenChat("/w " .. friend.name .. " ", SELECTED_DOCK_FRAME)
                        end
                    end
                end
            end)
            UpdateFriendText(button)
            self.microMenu:RegisterEvent("FRIENDLIST_UPDATE")
            self.microMenu:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
            self.microMenu:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
            self.microMenu:SetScript("OnEvent", function(_, event)
                if event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_ACCOUNT_ONLINE" or event == "BN_FRIEND_ACCOUNT_OFFLINE" then
                    UpdateFriendText(button)
                end
            end)

            
        elseif buttonInfo.name == "Communities" then
            button:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(T.color.r, T.color.g, T.color.b)
                self:SetBackdropBorderColor(T.color.r, T.color.g, T.color.b)
                CreateCommunitiesTooltip(self)
            end)
            button:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(C.databar.iconcolor))
                self:SetBackdropBorderColor(unpack(C.media.border_color))
                GameTooltip:Hide()
            end)
            button:SetScript("OnClick", function(self, btnType)
                if btnType == "LeftButton" then
                    ToggleGuildFrame()
                elseif btnType == "RightButton" then
                    ToggleCommunitiesFrame()
                end
            end)
            UpdateGuildText(button)
            self.microMenu:RegisterEvent("GUILD_ROSTER_UPDATE")
            self.microMenu:HookScript("OnEvent", function(_, event)
                if event == "GUILD_ROSTER_UPDATE" then
                    UpdateGuildText(button)
                end
            end)
        else
            button:SetScript("OnClick", buttonInfo.func)
            button:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(T.color.r, T.color.g, T.color.b)
                self:SetBackdropBorderColor(T.color.r, T.color.g, T.color.b)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(buttonInfo.name)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(C.databar.iconcolor))
                self:SetBackdropBorderColor(unpack(C.media.border_color))
                GameTooltip:Hide()
            end)
        end

        button:GetNormalTexture():SetVertexColor(unpack(C.databar.iconcolor))
    end
end

----------------------------------------------------------------------------------------
--	System Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateSystemModule()
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
    self.systemModule:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            UpdateSystemInfo()
            self.elapsed = 0
        end
    end)

    self.systemModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.systemModule:RegisterEvent("PLAYER_LEAVING_WORLD")
    self.systemModule:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self:SetScript("OnUpdate", self:GetScript("OnUpdate"))
        elseif event == "PLAYER_LEAVING_WORLD" then
            self:SetScript("OnUpdate", nil)
        end
    end)

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

----------------------------------------------------------------------------------------
--	Durability Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateDurabilityModule()
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

----------------------------------------------------------------------------------------
--	Item Level Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateItemLevelModule()
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

----------------------------------------------------------------------------------------
--	Volume Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateVolumeModule()
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

----------------------------------------------------------------------------------------
--	Clock Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateClockModule()
    -- Create the clock module frame
    self.clockModule = CreateFrame("Frame", "clockModule", self.TKUIBar)
    self.clockModule:SetSize(80, 35)
    self.clockModule:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -4)

    -- Create the clock text
    local clockText = self.clockModule:CreateFontString(nil, "OVERLAY")
    clockText:SetFont(C.font.databar_font, 24, C.font.databar_font_style)
    clockText:SetPoint("BOTTOM", self.clockModule, "BOTTOM", 0, 0)
    clockText:SetJustifyH("CENTER")
    clockText:SetAlpha(0.5)

    -- Make the clock module interactive
    self.clockModule:EnableMouse(true)

    -- Variable to track mouse over state
    local isMouseOver = false

    -- Function to update the clock/timer text
    local function UpdateClockText()
        local text
        if IsEncounterInProgress() then
            -- In combat, show timer
            local combatTime = GetTime() - combatStartTime
            local minutes = math.floor(combatTime / 60)
            local seconds = math.floor(combatTime % 60)
            text = string.format("%02d:%02d", minutes, seconds)
            clockText:SetTextColor(0.85, 0.27, 0.27, .7)
            clockText:SetFont(C.font.databar_font, 24, "THICKOUTLINE")
        else
            -- Out of combat, show clock
            local hour, minute = GetGameTime()
            text = string.format("%02d:%02d", hour, minute)
            if isMouseOver then
                local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
                clockText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
                clockText:SetAlpha(1)
            else
                clockText:SetTextColor(unpack(C.databar.fontcolor))
                clockText:SetAlpha(0.5)
            end
            clockText:SetFont(C.font.databar_font, 24)
        end
        clockText:SetText(text)
    end

    -- Call UpdateClockText initially to set the time
    UpdateClockText()

    -- Event handler for entering/leaving combat
    local function OnCombatEvent(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            combatStartTime = GetTime()
        elseif event == "PLAYER_REGEN_ENABLED" then
            UpdateClockText()
        end
    end

    -- Register combat events
    self.clockModule:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.clockModule:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.clockModule:SetScript("OnEvent", OnCombatEvent)

    -- Update the clock every second
    local clockUpdateTimer = CreateFrame("Frame", nil, self.clockModule)
    local elapsed = 0
    clockUpdateTimer:SetScript("OnUpdate", function(self, elap)
        elapsed = elapsed + elap
        if elapsed >= 1 then
            UpdateClockText()
            elapsed = 0
        end
    end)

    -- Mouse over effect
    self.clockModule:SetScript("OnEnter", function()
        if not IsEncounterInProgress() then
            isMouseOver = true
            UpdateClockText()
        end
    end)

    self.clockModule:SetScript("OnLeave", function()
        if not IsEncounterInProgress() then
            isMouseOver = false
            UpdateClockText()
        end
    end)

    -- Click to open calendar
    self.clockModule:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not IsEncounterInProgress() then
            ToggleCalendar()
        end
    end)
end

----------------------------------------------------------------------------------------
--	Hearthstone Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateHearthstoneModule()
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

----------------------------------------------------------------------------------------
--	Bag Module
----------------------------------------------------------------------------------------

function TKUIBar:GetBagInfo()
    local freeBags = 0
    local totalBags = 0
    for i = 0, NUM_BAG_SLOTS do
        freeBags = freeBags + C_Container.GetContainerNumFreeSlots(i)
        totalBags = totalBags + C_Container.GetContainerNumSlots(i)
    end
    return freeBags, totalBags
end

function TKUIBar:CreateBagModule()
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
        local freeBags, totalBags = TKUIBar:GetBagInfo()
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

        local freeBags, totalBags = TKUIBar:GetBagInfo()
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

----------------------------------------------------------------------------------------
--	Gold Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateGoldModule()
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

                -- Display sorted characters, limited by databar.currency_characters
                local displayCount = math.min(C.databar.currency_characters, #sortedCharacters)
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

----------------------------------------------------------------------------------------
--	Helper Function: Get Bag Info
----------------------------------------------------------------------------------------

-- Helper function to get bag information
function TKUIBar:GetBagInfo()
    local freeBags = 0
    local totalBags = 0
    for i = 0, NUM_BAG_SLOTS do
        freeBags = freeBags + C_Container.GetContainerNumFreeSlots(i)
        totalBags = totalBags + C_Container.GetContainerNumSlots(i)
    end
    return freeBags, totalBags
end

----------------------------------------------------------------------------------------
--	Experience Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateExperienceModule()
    local maxLevel = GetMaxPlayerLevel()

    -- If player is at max level, don't create the module
    if T.level >= maxLevel then
        return
    end

    -- Create the experience module frame
    self.experienceModule = CreateFrame("Frame", nil, self.TKUIRightBar2)
    self.experienceModule:SetSize(C.databar.iconsize, C.databar.iconsize)
    self.experienceModule:SetPoint("LEFT", self.TKUIRightBar2, "LEFT", 0, 0)

    -- Create a button to hold the radial status bar
    local button = CreateFrame("Button", nil, self.experienceModule)
    button:SetSize(C.databar.iconsize, C.databar.iconsize)
    button:SetPoint("CENTER")
    button:SetTemplate("Transparent") -- Apply template to the button

    -- Create the radial status bar
    local radialBar = T.CreateRadialStatusBar(button)
    radialBar:SetAllPoints(button)
    radialBar:SetTexture("Interface\\AddOns\\TKUI\\Media\\Textures\\White.tga")
    radialBar:SetVertexColor(T.color.r, T.color.g, T.color.b) -- Use your addon's color scheme
    radialBar:SetFrameLevel(button:GetFrameLevel() + 1)

    -- Create a background frame
    local bgFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
    bgFrame:SetSize(C.databar.iconsize - 4, C.databar.iconsize - 4) -- Slightly smaller than the button
    bgFrame:SetPoint("CENTER")
    bgFrame:SetFrameLevel(radialBar:GetFrameLevel() + 1)            -- Set it above the radial bar

    -- Set up the backdrop
    bgFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    bgFrame:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Dark gray with 80% opacity
    bgFrame:SetBackdropBorderColor(0, 0, 0, 1) -- Black border
    radialBar:SetFrameLevel(button:GetFrameLevel() + 10)
    bgFrame:SetFrameLevel(radialBar:GetFrameLevel() + 10)
    -- Create the experience text
    local expText = bgFrame:CreateFontString(nil, "OVERLAY")
    expText:SetFont(C.font.databar_font, C.font.databar_font_size, C.font.databar_font_style)
    expText:SetPoint("CENTER")
    expText:SetJustifyH("CENTER")
    expText:SetTextColor(T.color.r, T.color.g, T.color.b) -- White text for better visibility


    -- Function to update the experience bar and text
    local function UpdateExperience()
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local percentXP = currentXP / maxXP

        radialBar:SetRadialStatusBarValue(percentXP)
        expText:SetText(string.format("%.0f%%", percentXP * 100))
    end

    -- Update the bar and text initially
    UpdateExperience()

    -- Register events for updates
    self.experienceModule:RegisterEvent("PLAYER_XP_UPDATE")
    self.experienceModule:RegisterEvent("PLAYER_LEVEL_UP")
    self.experienceModule:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.experienceModule:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LEVEL_UP" then
            -- Check if player has reached max level
            if UnitLevel("player") >= GetMaxPlayerLevel() then
                self:Hide()
                return
            end
        end
        UpdateExperience()
    end)

    -- Add tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()

        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local remainingXP = maxXP - currentXP
        local percentXP = (currentXP / maxXP) * 100

        GameTooltip:AddLine("Experience")
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Current XP:", T.ShortValue(currentXP) .. " / " .. T.ShortValue(maxXP), 1, 1, 1, 1, 1,
            1)
        GameTooltip:AddDoubleLine("Remaining XP:", T.ShortValue(remainingXP), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("Progress:", string.format("%.2f%%", percentXP), 1, 1, 1, 1, 1, 1)

        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Optional: Add click functionality to the button
    button:SetScript("OnClick", function(self, button)
        -- Add any click functionality you want here
        -- For example, you could toggle the experience window
        ToggleCharacter("PaperDollFrame")
    end)
end

----------------------------------------------------------------------------------------
--	Specialization Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateSpecModule()
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

----------------------------------------------------------------------------------------
--	Loot Specialization Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateLootSpecModule()
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

----------------------------------------------------------------------------------------
--	Professions Module
----------------------------------------------------------------------------------------

function TKUIBar:CreateProfessionsModule()
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

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------

-- Initialize the TKUIBar when the addon loads
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        TKUIBar:Initialize()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnEvent)

-- If you need to access the TKUIBar module from other parts of your addon:
T.TKUIBar = TKUIBar
