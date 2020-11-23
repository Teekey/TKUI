local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TKUI = E:NewModule("TKUI", 'AceConsole-3.0', 'AceEvent-3.0')
local UF = E:GetModule("UnitFrames")
local EP = LibStub("LibElvUIPlugin-1.0")
local oUF_TKUI = {}
local addon, ns = ...
local oUF = ns.oUF
TKUI.Config = {}
-- Lua functions
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"
-- Sanity check for fresh profiles
if E.db[TKUIPlugin] == nil then
    E.db[TKUIPlugin] = {}
end
-- WoW API / Variables
local _G = _G


E:RegisterModule(TKUI:GetName())
