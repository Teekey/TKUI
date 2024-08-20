--	TKUI Data Bar for TKUI
--	This module creates a custom data bar for TKUI, displaying information like
--  system performance, character stats, currency, and more.
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
local DB = T.DB

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------

function DB:Initialize()
    --Left Bar
    DB:CreateLeftBar()
    DB:CreateMicroMenu()
    DB:CreateSystemModule()
    DB:CreateVolumeModule()
    --Right Bar 1
    DB:CreateRightBar1()
    DB:CreateHearthstoneModule()
    DB:CreateBagModule()
    DB:CreateGoldModule()
    DB:CreateProfessionsModule()
    --Right Bar 2
    DB:CreateRightBar2()
    DB:CreateExperienceModule()
    DB:CreateDurabilityModule()
    DB:CreateItemLevelModule()
    DB:CreateSpecModule()
    DB:CreateLootSpecModule()
    --Clock
    DB:CreateClockModule()
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------

-- Initialize the TKUIBar when the addon loads
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        DB:Initialize()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnEvent)

-- If you need to access the TKUIBar module from other parts of your addon:
T.DB = DB
