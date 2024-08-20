----------------------------------------------------------------------------------------
--	LoggingCombat Module for TKUI
--	This module automatically enables combat log text file in raid instances
--	Based on EasyLogger by Sildor
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)

-- Check if the feature is enabled in the configuration
if C.automation.logging_combat ~= true then return end

----------------------------------------------------------------------------------------
--	Local Variables
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")

----------------------------------------------------------------------------------------
--	Helper Functions
----------------------------------------------------------------------------------------
local function ShouldEnableLogging(instanceType)
	return instanceType == "raid" and IsInRaid(LE_PARTY_CATEGORY_HOME)
end

local function EnableCombatLogging()
	if not LoggingCombat() then
		LoggingCombat(1)
		PrintLoggingStatus(COMBATLOGENABLED)
	end
end

local function DisableCombatLogging()
	if LoggingCombat() then
		LoggingCombat(0)
		PrintLoggingStatus(COMBATLOGDISABLED)
	end
end

local function PrintLoggingStatus(message)
	print("|cffffff00"..message.."|r")
end

----------------------------------------------------------------------------------------
--	Event Registration
----------------------------------------------------------------------------------------
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
frame:SetScript("OnEvent", function()
	local _, instanceType = IsInInstance()
	
	if ShouldEnableLogging(instanceType) then
		EnableCombatLogging()
	else
		DisableCombatLogging()
	end
end)

