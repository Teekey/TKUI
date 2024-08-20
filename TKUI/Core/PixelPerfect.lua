local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Pixel perfect script of custom ui Scale
----------------------------------------------------------------------------------------
if T.screenWidth <= 1440 then
	T.low_resolution = true
else
	T.low_resolution = false
end

T.UIScale = min(2, max(0.20, 768 / T.screenHeight))
if T.screenHeight >= 2400 then
	T.UIScale = T.UIScale * 3
elseif T.screenHeight >= 1600 then
	T.UIScale = T.UIScale * 2
end
T.UIScale = tonumber(string.sub(T.UIScale, 0, 5))  -- 8.1 Fix scale bug


T.mult = 768 / T.screenHeight / T.UIScale
T.noscalemult = T.mult * T.UIScale

T.Scale = function(x)
	return T.mult * math.floor(x / T.mult + 0.5)
end

----------------------------------------------------------------------------------------
--	Pixel perfect fonts for high resolution
----------------------------------------------------------------------------------------
if T.screenHeight <= 1200 then return end
C.media.pixel_font_size = C.media.pixel_font_size * T.mult
C.font.chat_tabs_font_size = C.font.chat_tabs_font_size * T.mult
C.font.action_bars_font_size = C.font.action_bars_font_size * T.mult
C.font.threat_meter_font_size = C.font.threat_meter_font_size * T.mult
C.font.raid_cooldowns_font_size = C.font.raid_cooldowns_font_size * T.mult
C.font.unitframes_font_size = C.font.unitframes_font_size * T.mult
C.font.auras_font_size = C.font.auras_font_size * T.mult
C.font.filger_font_size = C.font.filger_font_size * T.mult
C.font.bags_font_size = C.font.bags_font_size * T.mult
C.font.loot_font_size = C.font.loot_font_size * T.mult
C.font.combat_text_font_size = C.font.combat_text_font_size * T.mult
C.font.stylization_font_size = C.font.stylization_font_size * T.mult
C.font.cooldown_timers_font_size = C.font.cooldown_timers_font_size * T.mult
