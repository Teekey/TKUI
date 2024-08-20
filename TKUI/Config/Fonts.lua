local T, C, L = unpack(TKUI)

-- Helper function to create sections
local function CreateSection(name)
	C[name] = C[name] or {}
	return setmetatable({}, {
		__newindex = function(t, k, v)
			rawset(C[name], k, v)
		end
	})
end

----------------------------------------------------------------------------------------
--	TKUI fonts configuration file
--	BACKUP THIS FILE BEFORE UPDATING!
----------------------------------------------------------------------------------------
--	Configuration example:
----------------------------------------------------------------------------------------
-- C["font"] = {
--		-- Stats font
--		["stats_font"] = "Interface\\AddOns\\TKUI\\Media\\Fonts\\Normal.ttf",
--		["stats_font_size"] = 11,
--		["stats_font_style"] = "",
--		["stats_font_shadow"] = true,
-- }
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--	Fonts options
----------------------------------------------------------------------------------------
local font = CreateSection("font")

-- Combat text font
font.combat_text_font = C.media.pixel_font
font.combat_text_font_size = 16
font.combat_text_font_style = "MONOCHROMEOUTLINE"
font.combat_text_font_shadow = false

-- Chat font
font.chat_font = C.media.normal_font
font.chat_font_style = "OUTLINE"
font.chat_font_shadow = true

-- Chat tabs font
font.chat_tabs_font = C.media.normal_font
font.chat_tabs_font_size = 14
font.chat_tabs_font_style = "OUTLINE"
font.chat_tabs_font_shadow = false

-- Action bars font
font.action_bars_font = C.media.normal_font
font.action_bars_font_size = 12
font.action_bars_font_style = "OUTLINE"
font.action_bars_font_shadow = false

-- Threat meter font
font.threat_meter_font = C.media.normal_font
font.threat_meter_font_size = 12
font.threat_meter_font_style = "OUTLINE"
font.threat_meter_font_shadow = false

-- Raid cooldowns font
font.raid_cooldowns_font = C.media.normal_font
font.raid_cooldowns_font_size = 12
font.raid_cooldowns_font_style = "OUTLINE"
font.raid_cooldowns_font_shadow = false

-- Cooldowns timer font
font.cooldown_timers_font = C.media.bold_font
font.cooldown_timers_font_size = 16
font.cooldown_timers_font_style = "OUTLINE"
font.cooldown_timers_font_shadow = false

-- Loot font
font.loot_font = C.media.normal_font
font.loot_font_size = 12
font.loot_font_style = "OUTLINE"
font.loot_font_shadow = false

-- Unit frames font
font.unitframes_font = C.media.normal_font
font.unitframes_font_size = 14
font.unitframes_font_style = "OUTLINE"
font.unitframes_font_shadow = true

font.unitframes_health_font = C.media.normal_font
font.unitframes_health_font_size = 16
font.unitframes_health_font_style = "OUTLINE"
font.unitframes_health_font_shadow = true

font.unitframes_name_font = C.media.normal_font
font.unitframes_name_font_size = 16
font.unitframes_name_font_style = "OUTLINE"
font.unitframes_name_font_shadow = true

font.unitframes_spell_font = C.media.normal_font
font.unitframes_spell_font_size = 12
font.unitframes_spell_font_style = "OUTLINE"
font.unitframes_spell_font_shadow = true

font.unitframes_casttime_font = C.media.bold_font
font.unitframes_casttime_size = 18
font.unitframes_casttime_style = "THICKOUTLINE"
font.unitframes_casttime_shadow = false

-- Auras font
font.unitframes_auras_font = C.media.normal_font
font.unitframes_auras_font_size = 10
font.unitframes_auras_font_style = "OUTLINE"
font.unitframes_auras_font_shadow = false

-- Raid UnitFrame font
font.groupframes_name_font = C.media.normal_font
font.groupframes_name_size = 12
font.groupframes_name_style = "OUTLINE"
font.groupframes_name_shadow = false

-- Auras font
font.auras_font = C.media.bold_font
font.auras_font_size = 16
font.auras_font_style = "OUTLINE"
font.auras_font_shadow = false

font.player_buffs_font = C.media.bold_font
font.player_buffs_font_size = 18
font.player_buffs_font_style = "OUTLINE"
font.player_buffs_font_shadow = false

font.player_buffs_count_font = C.media.bold_font
font.player_buffs_count_font_size = 12
font.player_buffs_count_font_style = "OUTLINE"
font.player_buffs_count_font_shadow = false

-- Nameplates font
font.nameplates_font = C.media.normal_font
font.nameplates_font_size = 8
font.nameplates_font_style = "OUTLINE"
font.nameplates_font_shadow = false

font.nameplates_name_font = C.media.normal_font
font.nameplates_name_font_size = 14
font.nameplates_name_font_style = "OUTLINE"
font.nameplates_name_font_shadow = true

font.nameplates_health_font = C.media.normal_font
font.nameplates_health_font_size = 14
font.nameplates_health_font_style = "OUTLINE"
font.nameplates_health_font_shadow = true

font.nameplates_spell_font = C.media.normal_font
font.nameplates_spell_size = 12
font.nameplates_spell_style = "OUTLINE"
font.nameplates_spell_shadow = true

font.nameplates_spelltime_font = C.media.bold_font
font.nameplates_spelltime_size = 16
font.nameplates_spelltime_style = "OUTLINE"
font.nameplates_spelltime_shadow = true

font.nameplates_aura_count_font = C.media.normal_font
font.nameplates_aura_count_size = 9
font.nameplates_aura_count_style = "OUTLINE"
font.nameplates_aura_count_shadow = true

-- Filger bar font
font.filger_font = C.media.normal_font
font.filger_font_size = 12
font.filger_font_style = "OUTLINE"
font.filger_font_shadow = false

font.filger_time_font = C.media.bold_font
font.filger_time_size = 18
font.filger_time_style = "OUTLINE"
font.filger_time_shadow = true

font.filger_count_font = C.media.normal_font
font.filger_count_size = 12
font.filger_count_style = "OUTLINE"
font.filger_count_shadow = false

-- Stylization font
-- Stylization font
font.stylization_font = C.media.normal_font
font.stylization_font_size = 12
font.stylization_font_style = "OUTLINE"
font.stylization_font_shadow = false

-- Bags font
font.bags_font = C.media.normal_font
font.bags_font_size = 12
font.bags_font_style = "OUTLINE"
font.bags_font_shadow = false

-- Blizzard fonts
font.tooltip_header_font_size = 13
font.tooltip_font_size = 11
font.bubble_font_size = 8
font.quest_tracker_font_mult = 1

font.quest_font = C.media.normal_font
font.quest_font_size = 12
font.quest_font_style = "OUTLINE"
font.quest_font_shadow = false


-- Databar fonts
font.databar_font = C.media.normal_font
font.databar_font_size = 12
font.databar_font_style = "OUTLINE"

-- Databar small fonts
font.databar_smallfont = C.media.normal_font
font.databar_smallfont_size = 10
font.databar_smallfont_style = "OUTLINE"

-- SCT fonts
font.sct_font = C.media.normal_font
font.sct_font_size = 10
font.sct_font_style = "OUTLINE"
font.sct_font_shadow = false

-- BW Timeline fonts
font.bwt_font = C.media.normal_font
font.bwt_font_size = 12
font.bwt_font_style = "OUTLINE"
font.bwt_font_shadow = true

font.bwt_duration_font = C.media.bold_font
font.bwt_duration_size = 12
font.bwt_duration_style = "OUTLINE"
font.bwt_duration_shadow = true

font.bwt_tick_font = C.media.normal_font
font.bwt_tick_font_size = 10
font.bwt_tick_font_style = "OUTLINE"
font.bwt_tick_font_shadow = true

-- Edit Mode Fonts
font.editmode_font = C.media.normal_font
font.editmode_size = 12
font.editmode_style = "OUTLINE"
font.editmode_shadow = false

----------------------------------------------------------------------------------------
--	Font replacement for zhTW, zhCN, and koKR clients
----------------------------------------------------------------------------------------
local locale_font
if T.client == "zhTW" then
	locale_font = "Fonts\\bLEI00D.ttf"
elseif T.client == "zhCN" then
	locale_font = "Fonts\\ARKai_T.ttf"
elseif T.client == "koKR" then
	locale_font = "Fonts\\2002.ttf"
end

if locale_font then
	C["media"].normal_font = locale_font
	C["media"].pixel_font = locale_font
	C["media"].pixel_font_style = "OUTLINE"
	C["media"].pixel_font_size = 11

	font.stats_font = locale_font
	font.stats_font_size = 12
	font.stats_font_style = "OUTLINE"
	font.stats_font_shadow = true

	font.combat_text_font = locale_font
	font.combat_text_font_size = 16
	font.combat_text_font_style = "OUTLINE"
	font.combat_text_font_shadow = true

	font.chat_font = locale_font
	font.chat_font_style = "OUTLINE"
	font.chat_font_shadow = true

	font.chat_tabs_font = locale_font
	font.chat_tabs_font_size = 12
	font.chat_tabs_font_style = "OUTLINE"
	font.chat_tabs_font_shadow = true

	font.action_bars_font = locale_font
	font.action_bars_font_size = 12
	font.action_bars_font_style = "OUTLINE"
	font.action_bars_font_shadow = true

	font.threat_meter_font = locale_font
	font.threat_meter_font_size = 12
	font.threat_meter_font_style = "OUTLINE"
	font.threat_meter_font_shadow = true

	font.raid_cooldowns_font = locale_font
	font.raid_cooldowns_font_size = 12
	font.raid_cooldowns_font_style = "OUTLINE"
	font.raid_cooldowns_font_shadow = true

	font.cooldown_timers_font = locale_font
	font.cooldown_timers_font_size = 13
	font.cooldown_timers_font_style = "OUTLINE"
	font.cooldown_timers_font_shadow = true

	font.loot_font = locale_font
	font.loot_font_size = 13
	font.loot_font_style = "OUTLINE"
	font.loot_font_shadow = true

	font.nameplates_font = locale_font
	font.nameplates_font_size = 13
	font.nameplates_font_style = "OUTLINE"
	font.nameplates_font_shadow = true

	font.unitframes_font = locale_font
	font.unitframes_font_size = 12
	font.unitframes_font_style = "OUTLINE"
	font.unitframes_font_shadow = true

	font.auras_font = locale_font
	font.auras_font_size = 11
	font.auras_font_style = "OUTLINE"
	font.auras_font_shadow = true

	font.filger_font = locale_font
	font.filger_font_size = 14
	font.filger_font_style = "OUTLINE"
	font.filger_font_shadow = true

	font.stylization_font = locale_font
	font.stylization_font_size = 12
	font.stylization_font_style = ""
	font.stylization_font_shadow = true

	font.bags_font = locale_font
	font.bags_font_size = 11
	font.bags_font_style = "OUTLINE"
	font.bags_font_shadow = true

	font.tooltip_header_font_size = 14
	font.tooltip_font_size = 12
	font.bubble_font_size = 10
end