local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Force readycheck warning
----------------------------------------------------------------------------------------
local ShowReadyCheckHook = function(_, initiator)
	if initiator ~= "player" then
		PlaySound(SOUNDKIT.READY_CHECK, "Master")
	end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

----------------------------------------------------------------------------------------
--	Force other warning
----------------------------------------------------------------------------------------
local ForceWarning = CreateFrame("Frame")
ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
ForceWarning:RegisterEvent("RESURRECT_REQUEST")
ForceWarning:SetScript("OnEvent", function(_, event)
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		for i = 1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE, "Master")
				break
			end
			i = i + 1
		end
	elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
		PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE, "Master")
	elseif event == "LFG_PROPOSAL_SHOW" then
		PlaySound(SOUNDKIT.READY_CHECK, "Master")
	elseif event == "RESURRECT_REQUEST" then
		PlaySound(37, "Master")
	end
end)

----------------------------------------------------------------------------------------
--	Misclicks for some popups
----------------------------------------------------------------------------------------
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
PetBattleQueueReadyFrame.hideOnEscape = nil
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

----------------------------------------------------------------------------------------
--	Sticky Targeting
----------------------------------------------------------------------------------------
if C.misc.sticky_targeting == true then
	local function toggleSticky(self, event, ...)
		SetCVar("deselectOnClick", event == "PLAYER_REGEN_DISABLED" and 0 or 1)
	end
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", toggleSticky)
end


----------------------------------------------------------------------------------------
--	Spin camera while afk(by Telroth and Eclipse)
----------------------------------------------------------------------------------------
if C.misc.afk_spin_camera == true then
    local spinning
    local originalZoom

    local function ZoomIn()
        originalZoom = GetCameraZoom()
        local targetZoom = 4  -- Adjust this value to set how close you want to zoom
        local zoomSpeed = 0.1  -- Adjust this to change how fast the camera zooms

        local zoomFrame = CreateFrame("Frame")
        zoomFrame:SetScript("OnUpdate", function(self)
            local currentZoom = GetCameraZoom()
            if currentZoom > targetZoom then
                CameraZoomIn(zoomSpeed)
            else
                self:SetScript("OnUpdate", nil)
            end
        end)
    end

    local function ZoomOut()
        if originalZoom then
            local zoomFrame = CreateFrame("Frame")
            zoomFrame:SetScript("OnUpdate", function(self)
                local currentZoom = GetCameraZoom()
                if currentZoom < originalZoom then
                    CameraZoomOut(0.1)
                else
                    self:SetScript("OnUpdate", nil)
                end
            end)
        end
    end

    local function SpinStart()
        spinning = true
        MoveViewRightStart(0.1)
        UIParent:Hide()
        ZoomIn()
        DoEmote("DANCE")
    end

    local function SpinStop()
        if not spinning then return end
        spinning = nil
        MoveViewRightStop()
        if InCombatLockdown() then return end
        UIParent:Show()
        ZoomOut()
        -- Stop the dance emote
        DoEmote("STOP")
    end

    local SpinCam = CreateFrame("Frame")
    SpinCam:RegisterEvent("PLAYER_LEAVING_WORLD")
    SpinCam:RegisterEvent("PLAYER_FLAGS_CHANGED")
    SpinCam:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LEAVING_WORLD" then
            SpinStop()
        else
            if UnitIsAFK("player") and not InCombatLockdown() then
                SpinStart()
            else
                SpinStop()
            end
        end
    end)
end

----------------------------------------------------------------------------------------
--	Undress button in dress-up frame(by Nefarion)
----------------------------------------------------------------------------------------
local strip = CreateFrame("Button", "DressUpFrameUndressButton", DressUpFrame, "UIPanelButtonTemplate")
strip:SetText(L_MISC_UNDRESS)
strip:SetWidth(78)
strip:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", -2, 0)
strip:RegisterForClicks("AnyUp")
strip:SetScript("OnClick", function(_, button)
	local actor = DressUpFrame.ModelScene:GetPlayerActor()
	if not actor then return end
	if button == "RightButton" then
		actor:UndressSlot(19)
	else
		actor:Undress()
	end
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
end)
DressUpFrame.LinkButton:SetWidth(78)

----------------------------------------------------------------------------------------
--	Boss Banner Hider
----------------------------------------------------------------------------------------
	BossBanner.PlayBanner = function() end
	BossBanner:UnregisterAllEvents()

----------------------------------------------------------------------------------------
--	Easy delete good items
----------------------------------------------------------------------------------------
local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
if deleteDialog.OnShow then
	hooksecurefunc(deleteDialog, "OnShow",
		function(s)
			s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			s.editBox:SetAutoFocus(false)
			s.editBox:ClearFocus()
		end)
end

----------------------------------------------------------------------------------------
--	Change UIErrorsFrame strata
----------------------------------------------------------------------------------------
UIErrorsFrame:SetFrameLevel(0)

----------------------------------------------------------------------------------------
--	Increase speed for AddonList scroll
----------------------------------------------------------------------------------------
AddonList.ScrollBox.wheelPanScalar = 6
AddonList.ScrollBar.wheelPanScalar = 6
