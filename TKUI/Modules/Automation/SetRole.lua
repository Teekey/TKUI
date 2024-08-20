----------------------------------------------------------------------------------------
--	SetRole for TKUI
--	This script automatically sets the player's role based on their specialization.
--	It updates the role when talents change or group roster updates.
--	Based on Auto role setter by iSpawnAtHome
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
if C.automation.auto_role ~= true then return end

----------------------------------------------------------------------------------------
--	Variables
----------------------------------------------------------------------------------------
local prev = 0

----------------------------------------------------------------------------------------
--	Core Function
----------------------------------------------------------------------------------------
local function SetRole()
	-- Check conditions: player level, not in combat, in a group, not in LFG
	if T.level >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG() then
		local spec = GetSpecialization()
		if spec then
			local role = GetSpecializationRole(spec)
			-- Update role if it has changed
			if UnitGroupRolesAssigned("player") ~= role then
				local t = GetTime()
				-- Throttle updates to prevent spam
				if t - prev > 2 then
					prev = t
					UnitSetRole("player", role)
				end
			end
		else
			UnitSetRole("player", "No Role")
		end
	end
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", SetRole)

----------------------------------------------------------------------------------------
--	Role Poll Modification
----------------------------------------------------------------------------------------
-- Prevent the default role poll popup
RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")