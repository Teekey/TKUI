local T, C, L = unpack(TKUI)

-- Spells lists initialization
C.filger.buff_spells_list = {}
C.filger.proc_spells_list = {}
C.filger.debuff_spells_list = {}
C.filger.aura_bar_spells_list = {}
C.filger.cd_spells_list = {}
C.filger.ignore_spells_list = {}
C.raidframe.plugins_aura_watch_list = {}
C.raidcooldown.spells_list = {}
C.raidcooldown.spells_list_ver = 1
C.enemycooldown.spells_list = {}
C.enemycooldown.spells_list_ver = 1
C.pulsecooldown.spells_list = {}
C.nameplate.debuffs_list = {}
C.nameplate.buffs_list = {}
C.chat.spam_list = ""
C.font.global_font = false
C.media.profile = "-- Insert Your code here\n"
C.general.choose_profile = 1
C.general.profile_name = "1"
C.options = {}


----------------------------------------------------------------------------------------
--	This Module loads new user settings if TKUI_Config is loaded
----------------------------------------------------------------------------------------
-- Create the profile boolean
if not TKUIOptionsGlobal then TKUIOptionsGlobal = {} end
if TKUIOptionsGlobal[T.realm] == nil then TKUIOptionsGlobal[T.realm] = {} end
if TKUIOptionsGlobal[T.realm][T.name] == nil then TKUIOptionsGlobal[T.realm][T.name] = false end
if TKUIOptionsGlobal[T.realm]["Current_Profile"] == nil then TKUIOptionsGlobal[T.realm]["Current_Profile"] = {} end

-- Create the main options table
if TKUIOptions == nil then TKUIOptions = {} end

-- Determine which settings to use
local profile
if not TKUIOptions.merged and not TKUIOptions["1"] then	-- TODO delete after while
    local backup = TKUIOptions
    TKUIOptions = {}
    TKUIOptions["1"] = backup
    TKUIOptions.merged = true
end

TKUIOptionsGlobal["Current_Profile"] = TKUIOptionsGlobal["Current_Profile"] or 1
local i = tostring(TKUIOptionsGlobal["Current_Profile"])
TKUIOptions[i] = TKUIOptions[i] or {}
profile = TKUIOptions[i]

-- Apply or remove saved settings as needed
for group, options in pairs(profile) do
	if C[group] then
		for option, value in pairs(options) do
			if C[group][option] == nil or C[group][option] == value then
				-- remove saved vars if they do not exist in lua config anymore, or are the same as the lua config
				profile[group][option] = nil
			else
				C[group][option] = value
			end
		end
	else
		-- profile[group] = nil
	end
end

if profile.gold and profile.gold.characters then
    for character, amount in pairs(profile.gold.characters) do
        C.gold.characters[character] = amount
    end
end

-- Add global options variable
C.options = profile

-- Load edited profile code
loadstring("local T, C, L = unpack(TKUI)\n"..C["media"].profile)()