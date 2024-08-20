----------------------------------------------------------------------------------------
--	Initiation of TKUI
----------------------------------------------------------------------------------------
-- Including system
local addon, engine = ...
engine[1] = {}	-- T, Functions
engine[2] = {}	-- C, Config
engine[3] = {}	-- L, Localization

TKUI = engine	-- Allow other addons to use Engine

--[[
	This should be at the top of every file inside of the TKUI AddOn:
	local T, C, L = unpack(TKUI)

	This is how another addon imports the TKUI engine:
	local T, C, L, _ = unpack(TKUI)
]]