----------------------------------------------------------------------------------------
--	Auto Quest for TKUI
--	This module provides automatic quest acceptance, turn-in, and dialogue handling.
--	It streamlines the questing experience by automating repetitive interactions.
--	Features include auto-accepting quests, turning in completed quests, and handling
--	special cases like Darkmoon Faire interactions and trivial quests.
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
if not C.quest.auto_quest_enable then return end

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------

C.quest = C.quest or {}

local GetNPCID = function(unit)
	local npcGUID = UnitGUID(unit or 'npc')
	if npcGUID then
		return tonumber(npcGUID:match('%w+%-.-%-.-%-.-%-.-%-(.-)%-'))
	end
end

local ShouldAcceptTrivialQuests = function()
	for index = 1, GetNumTrackingTypes() do
		local name, _, isActive = GetTrackingInfo(index)
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return isActive
		end
	end
end

local tLength = function(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end

----------------------------------------------------------------------------------------
--	Event Handling System
----------------------------------------------------------------------------------------

local EventHandler = CreateFrame('Frame')
EventHandler.events = {}
EventHandler:SetScript('OnEvent', function(self, event, ...)
	self:Trigger(event, ...)
end)

function EventHandler:Register(event, func)
	local registered = not not self.events[event]
	if not registered then
		self.events[event] = {}
	end

	for _, f in next, self.events[event] do
		if f == func then
			return
		end
	end

	table.insert(self.events[event], func)

	if not registered then
		self:RegisterEvent(event)
	end
end

function EventHandler:Unregister(event, func)
	local funcs = self.events[event]
	if funcs then
		for i, f in next, funcs do
			if f == func then
				funcs[i] = nil
				break
			end
		end
	end

	if funcs and #funcs == 0 then
		self:UnregisterEvent(event)
	end
end

function EventHandler:Trigger(event, ...)
	local funcs = self.events[event]
	if funcs then
		for _, func in next, funcs do
			if type(func) == 'string' then
				self:Trigger(func, ...)
			else
				if func(...) then
					self:Unregister(event, func)
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
--	Quest Automation Variables 
----------------------------------------------------------------------------------------

local paused

local DARKMOON_ISLE_MAP_ID = 407
local DARKMOON_FAIRE_TELEPORT_NPC_ID = 57850

local darkmoonNPCs = {
	-- Darkmoon Faire teleporation NPCs
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

----------------------------------------------------------------------------------------
--	Gossip and Dialogue Handling
----------------------------------------------------------------------------------------

EventHandler:Register('GOSSIP_CONFIRM', function(index)
	if paused then
		return
	end

	if C.quest.auto_quest_paydarkmoonfaire and darkmoonNPCs[GetNPCID()] then
		C_GossipInfo.SelectOption(index, '', true)
		StaticPopup_Hide('GOSSIP_CONFIRM')
	end
end)

EventHandler:Register('GOSSIP_SHOW', function()
	if paused then
		return
	end

	if C_Map.GetBestMapForUnit('player') == DARKMOON_ISLE_MAP_ID then
		for index, info in next, C_GossipInfo.GetOptions() do
			if info.name:find('FF008E8') then
				C_GossipInfo.SelectOption(index)
				return
			end
		end
	end

	if C_GossipInfo.GetNumActiveQuests() > 0 or C_GossipInfo.GetNumAvailableQuests() > 0 then
		return
	end

	local npcID = GetNPCID()
	if C.quest.auto_quest_paydarkmoonfaire and npcID == DARKMOON_FAIRE_TELEPORT_NPC_ID then
		C_GossipInfo.SelectOption(1)
		return
	end

	if #C_GossipInfo.GetOptions() == 1 and C.quest.auto_quest_skipgossip then
		local _, instanceType = GetInstanceInfo()
		if instanceType == 'raid' and C.quest.auto_quest_skipgossipwhen > 0 then
			if GetNumGroupMembers() <= 1 or C.quest.auto_quest_skipgossipwhen == 2 then
				C_GossipInfo.SelectOption(1)
				return
			end
		elseif instanceType ~= 'raid' then
			C_GossipInfo.SelectOption(1)
			return
		end
	end
end)

----------------------------------------------------------------------------------------
--	Quest Acceptance and Turn-in
----------------------------------------------------------------------------------------

local function ShouldAcceptTrivialQuests()
    if not C_Minimap then
        return false
    end
    for i = 1, C_Minimap.GetNumTrackingTypes() do
        local name, texture, active, category, nested = C_Minimap.GetTrackingInfo(i)
        if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
            return active
        end
    end
    return false
end

EventHandler:Register('GOSSIP_SHOW', function()
    if paused then
        return
    end

    for index, info in next, C_GossipInfo.GetActiveQuests() do
        if info.isComplete and not C_QuestLog.IsWorldQuest(info.questID) then
            C_GossipInfo.SelectActiveQuest(index)
        end
    end

    local shouldAcceptTrivial = ShouldAcceptTrivialQuests()
    for index, info in next, C_GossipInfo.GetAvailableQuests() do
        if not info.isTrivial or shouldAcceptTrivial then
            C_GossipInfo.SelectAvailableQuest(index)
        end
    end
end)

EventHandler:Register('QUEST_GREETING', function()
    if paused then
        return
    end

    for index = 1, GetNumActiveQuests() do
        local _, isComplete = GetActiveTitle(index)
        if isComplete and not C_QuestLog.IsWorldQuest(GetActiveQuestID(index)) then
            SelectActiveQuest(index)
        end
    end

    for index = 1, GetNumAvailableQuests() do
        local isTrivial, _, _, _, questID = GetAvailableQuestInfo(index)
        if not isTrivial or ns.ShouldAcceptTrivialQuests() then
            SelectAvailableQuest(index)
        end
    end
end)

EventHandler:Register('QUEST_DETAIL', function(questItemID)
    if paused then
        return
    end

    if QuestIsFromAreaTrigger() then
        AcceptQuest()
    elseif QuestGetAutoAccept() then
        AcknowledgeAutoAcceptQuest()
    elseif not C_QuestLog.IsQuestTrivial(GetQuestID()) or ns.ShouldAcceptTrivialQuests() then
        AcceptQuest()
    end
end)

EventHandler:Register('QUEST_PROGRESS', function()
    if paused then
        return
    end

    if not IsQuestCompletable() then
        return
    end

    CompleteQuest()
    EventHandler:Unregister('QUEST_ITEM_UPDATE', 'QUEST_PROGRESS')
end)

----------------------------------------------------------------------------------------
--	Quest Completion and Reward Selection
----------------------------------------------------------------------------------------

EventHandler:Register('QUEST_COMPLETE', function()
	if paused then
		return
	end

	if GetNumQuestChoices() <= 1 then
		GetQuestReward(1)
	end
end)

EventHandler:Register('QUEST_COMPLETE', function()
	local numItemRewards = GetNumQuestChoices()
	if numItemRewards <= 1 then
		return
	end

	local highestItemValue, highestItemValueIndex = 0

	for index = 1, numItemRewards do
		local itemLink = GetQuestItemLink('choice', index)
		if itemLink then
			local _, _, _, _, _, _, _, _, _, _, itemValue = GetItemInfo(itemLink)
			local itemID = GetItemInfoFromHyperlink(itemLink)

			itemValue = cashRewards[itemID] or itemValue

			if itemValue > highestItemValue then
				highestItemValue = itemValue
				highestItemValueIndex = index
			end
		else
			EventHandler:Register('QUEST_ITEM_UPDATE', 'QUEST_COMPLETE')
			GetQuestItemInfo('choice', index)
			return
		end
	end

	if highestItemValueIndex then
		QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestItemValueIndex])
	end

	EventHandler:Unregister('QUEST_ITEM_UPDATE', 'QUEST_COMPLETE')
end)

----------------------------------------------------------------------------------------
--	Quest Popup and Auto-Accept Handling
----------------------------------------------------------------------------------------

EventHandler:Register('QUEST_WATCH_LIST_CHANGED', function()
	if paused then
		return
	end

	if GetNumAutoQuestPopUps() > 0 then
		if UnitIsDeadOrGhost('player') then
			EventHandler:Register('PLAYER_REGEN_ENABLED', 'QUEST_WATCH_LIST_CHANGED')
			return
		end

		EventHandler:Unregister('PLAYER_REGEN_ENABLED', 'QUEST_WATCH_LIST_CHANGED')

		local questID, questType = GetAutoQuestPopUp(1)
		if questType == 'OFFER' then
			ShowQuestOffer(questID)
		else
			ShowQuestComplete(questID)
		end

		-- Update the function call to the new API
		if RemoveAutoQuestPopUp then
			RemoveAutoQuestPopUp(questID)
		else
			print("Warning: RemoveAutoQuestPopUp function is not available.")
		end
	end
end)

EventHandler:Register('QUEST_ACCEPT_CONFIRM', function()
	if paused then
		return
	end

	AcceptQuest()
end)

EventHandler:Register('QUEST_ACCEPTED', function(questID)
    if C.quest.auto_quest_share then
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if questLogIndex then
            QuestLogPushQuest(questLogIndex)
        end
    end
end)

----------------------------------------------------------------------------------------
--	Pause Key Handling
----------------------------------------------------------------------------------------

EventHandler:Register('MODIFIER_STATE_CHANGED', function(key, state)
    if string.sub(key, 2) == C.quest.auto_quest_pausekey then
        if C.quest.auto_quest_pausekeyreverse then
            paused = state ~= 1
        else
            paused = state == 1
        end
    end
end)

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------

EventHandler:Register('PLAYER_LOGIN', function()
    if C.quest.auto_quest_pausekeyreverse then
        paused = true
    end
end)