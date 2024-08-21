local T, C, L = unpack(TKUI)
local DB = T.DB

function DB:CreateButton(parent, texture, bg, textString, ...)
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
--	Micro Menu Module
----------------------------------------------------------------------------------------

function DB:CreateMicroMenu()
    self.microMenu = CreateFrame("Frame", nil, self.TKUILeftBar)
    self.microMenu:SetSize(500, 35)
    self.microMenu:SetPoint("LEFT", self.TKUILeftBar, "LEFT", 5, 0)

    self.buttons = {
        { name = "GameMenu",           func = function() ToggleFrame(GameMenuFrame) end },
        { name = "Character",          func = function() ToggleCharacter("PaperDollFrame") end },
        { name = "Spellbook",          func = function() PlayerSpellsUtil.TogglePlayerSpellsFrame(3) end },
        { name = "ClassTalent",        func = function() PlayerSpellsUtil.TogglePlayerSpellsFrame(2) end },
        { name = "Achievement",        func = ToggleAchievementFrame },
        { name = "QuestScroll",        func = ToggleQuestLog },
        { name = "Friends",            func = ToggleFriendsFrame },
        { name = "Communities",        func = ToggleGuildFrame },
        { name = "PVE",                func = ToggleLFDParentFrame },
        { name = "CollectionsJournal", func = function() ToggleCollectionsJournal(1) end },
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