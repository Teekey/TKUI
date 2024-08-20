----------------------------------------------------------------------------------------
--	AutoInvite Module for TKUI
--	This module provides automatic invite acceptance from friends/guild members
--	and auto-invite functionality based on whisper keywords.
--	Accept invites feature by ALZA, Auto invite by whisper feature by Tukz
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Locals
----------------------------------------------------------------------------------------
local UnitExists, UnitIsGroupLeader, UnitIsGroupAssistant = UnitExists, UnitIsGroupLeader, UnitIsGroupAssistant
local GetNumGroupMembers, AcceptGroup = GetNumGroupMembers, AcceptGroup
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local BNInviteFriend = BNInviteFriend

----------------------------------------------------------------------------------------
--	Auto Accept Invites
----------------------------------------------------------------------------------------
if C.automation.accept_invite == true then
	-- Check if inviter is a friend or guild member
	local function CheckFriend(inviterGUID)
		return C_BattleNet.GetAccountInfoByGUID(inviterGUID) or C_FriendList.IsFriend(inviterGUID) or IsGuildMember(inviterGUID)
	end

	-- Create frame for handling invite requests
	local ai = CreateFrame("Frame")
	ai:RegisterEvent("PARTY_INVITE_REQUEST")
	ai:SetScript("OnEvent", function(_, _, name, _, _, _, _, _, inviterGUID)
		-- Don't accept if in queue or already in a group
		if QueueStatusButton:IsShown() or GetNumGroupMembers() > 0 then return end
		
		if CheckFriend(inviterGUID) then
			-- Notify player of accepted invite
			RaidNotice_AddMessage(RaidWarningFrame, L_INFO_INVITE..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
			print(format("|cffffff00"..L_INFO_INVITE..name..".|r"))
			
			-- Accept the group invite
			AcceptGroup()
			
			-- Hide invite popups
			for i = 1, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if frame:IsVisible() and (frame.which == "PARTY_INVITE" or frame.which == "PARTY_INVITE_XREALM") then
					frame.inviteAccepted = 1
					StaticPopup_Hide(frame.which)
					return
				end
			end
		end
	end)
end

----------------------------------------------------------------------------------------
--	Auto Invite by Whisper
----------------------------------------------------------------------------------------

-- Create a table of invite keywords (moved outside main body)
local list_keyword = {}
for word in gmatch(C.automation.invite_keyword, "%S+") do
	list_keyword[word:lower()] = true
end

-- Create frame for handling whisper events
local autoinvite = CreateFrame("Frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:RegisterEvent("CHAT_MSG_BN_WHISPER")

-- Debounce mechanism
local lastInviteTime = 0
local INVITE_COOLDOWN = 5 -- 5 seconds cooldown

autoinvite:SetScript("OnEvent", function(_, event, arg1, arg2, ...)
	-- Check if whisper invite is enabled
	if not C.automation.whisper_invite then return end
	
	-- Check if player can invite (is alone or is leader/assistant) and not in queue
	if ((not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) and not QueueStatusButton:IsShown() then
		local currentTime = GetTime()
		if currentTime - lastInviteTime < INVITE_COOLDOWN then return end

		-- Convert whisper to lowercase once
		local lowerArg1 = arg1:lower()
		
		-- Check for invite keywords in whisper
		for word in pairs(list_keyword) do
			if lowerArg1:match(word) then
				lastInviteTime = currentTime
				if event == "CHAT_MSG_WHISPER" then
					C_PartyInfo_InviteUnit(arg2)
				elseif event == "CHAT_MSG_BN_WHISPER" then
					local bnetIDAccount = select(11, ...)
					local accountInfo = C_BattleNet_GetAccountInfoByID(bnetIDAccount)
					BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
				end
				break
			end
		end
	end
end)