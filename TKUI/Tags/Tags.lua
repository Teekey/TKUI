local E, L, V, P, G, _ = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ElvUF = ElvUI.oUF
local Translit = E.Libs.Translit
local translitMark = "!"
local UF = E:GetModule('UnitFrames');
local _G = _G
E.TagFunctions = {}
-- Cache global variables
-- WoW API / Variables
local strfind, strmatch, strlower, utf8lower, utf8sub, utf8len = strfind, strmatch, strlower, string.utf8lower, string.utf8sub, string.utf8len

local function perHP(unit)
local min, max = UnitHealth(unit), UnitHealthMax(unit)
local deficit = max - min
	if not ((deficit <= 0) or (max == 0)) then
		return '|cFFFFFFFF '..math.floor(UnitHealth(unit) / max * 100 + .5)
	else
		return ""
	end
end

local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format('%s%02x%02x%02x%s', header or '|cff', r*255, g*255, b*255, ending or '')
end

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)

	if name == UNKNOWN and E.myclass == 'MONK' and UnitIsUnit(unit, 'pet') then
		name = format(UNITNAME_SUMMON_TITLE17, _G.UnitName('player'))
	end

	if realm and realm ~= '' then
		return name, realm
	else
		return name
	end
end

local function unitName(unit)
	local name, realm = _G.UnitName(unit)
	local isTarget = UnitIsUnit('playertarget', unit);

	if isTarget then
		return '['..name..']'
	else
		return name
	end
end

local function nameColor(unit)
	local _,status,_,_,_ = UnitDetailedThreatSituation('player', unit);
	local _,focus,_,_,_ = UnitDetailedThreatSituation('focus', unit);
	local isTank = UnitGroupRolesAssigned('player') == "TANK";
	local isDPS = UnitGroupRolesAssigned('player') == "DAMAGER";
	local isHealer = UnitGroupRolesAssigned('player') == "HEALER";
	local isNone = UnitGroupRolesAssigned('player') == "NONE";
	local isUnitCombat = UnitAffectingCombat(unit);
	local isPlayerCombat = UnitAffectingCombat('player');
	local isTapped = UnitIsTapDenied(unit);
	local tankColor = {
		[0] = "|cFFfe2d2d", --Bad Threat Color
		[1] = "|cFFff8132", --Transition Color
		[2] = "|cFFff8132", --Transition Color
		[3] = "|cFF32b400", --Good Color
		[4] = "|cFFbb32ff" --Offtank
	}
	local dpsColor = {
		[0] = "|cFF32b400", --Bad Threat Color
		[1] = "|cFFff8132", --Transition Color
		[2] = "|cFFff8132", --Transition Color
		[3] = "|cFFfe2d2d" --Good Color
	}
	local tappedColor = "|cFF999999"; --Tapped Color
	if UnitIsPlayer(unit) then
		local _, unitClass = UnitClass(unit)
		local cs = ElvUF.colors.class[unitClass]
		return RGBToHex(cs[1], cs[2], cs[3])
	elseif isTapped then
		return tappedColor
	elseif (isUnitCombat and isPlayerCombat and isTank and focus == 3) and (status ~= nil and status >=0 and status <=3) then
		return tankColor[4]
	elseif (isUnitCombat and isPlayerCombat and isTank) and (status ~= nil and status >=0 and status <=3) then
		return tankColor[status]
	elseif (isUnitCombat and isPlayerCombat) and (isDPS or isHealer) and (status ~= nil and status >=0 and status <=3) then
		return dpsColor[status]
	elseif (isUnitCombat and isPlayerCombat and isNone) and (status ~= nil and status >=0 and status <=3) then
		return tankColor[status]
	else
		local cr = ElvUF.colors.reaction[UnitReaction(unit, 'player')]
		return RGBToHex(cr[1], cr[2], cr[3])
	end
end


ElvUF.Tags.Events['TKUI:Name'] = 'PLAYER_TARGET_CHANGED'
ElvUF.Tags.Methods['TKUI:Name'] = function(unit)
		-- return nameColor(unit)..unitName(unit)..perHP(unit)
		return UnitName(unit):sub(1,10)
end

ElvUF.Tags.Events['TKUI:Health'] = 'UNIT_HEALTH UNIT_HEALTH UNIT_MAXHEALTH PLAYER_TARGET_CHANGED'
ElvUF.Tags.Methods['TKUI:Health'] = function(unit)
		return perHP(unit)
end

ElvUF.Tags.Events['TKUI:GroupLead'] = 'PARTY_LEADER_CHANGED PLAYER_ENTERING_WORLD GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['TKUI:GroupLead'] = function(unit)
	local localizedClass, englishClass, classIndex = UnitClass(unit);
	local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
	if(UnitIsGroupLeader(unit)) then
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Leader.tga:15:15:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t'
	elseif(UnitIsGroupAssistant(unit)) then
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Leader.tga:15:15:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t'
	else
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Blank.blp:15:15:0:0:16:16:0:16:0:16:1:1:1|t'
	end
end

ElvUF.Tags.Events['TKUI:RaidMarker'] = 'RAID_TARGET_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED'
ElvUF.Tags.Methods['TKUI:RaidMarker'] = function(unit)
	local iconNumber = GetRaidTargetIndex(unit);
	local raidIcon = {
		[1] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_1.blp:18:18|t ',
		[2] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_2.blp:18:18|t ',
		[3] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_3.blp:18:18|t ',
		[4] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_4.blp:18:18|t ',
		[5] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_5.blp:18:18|t ',
		[6] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_6.blp:18:18|t ',
		[7] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_7.blp:18:18|t ',
		[8] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_8.blp:18:18|t '
	}
	 return raidIcon[iconNumber]
end

ElvUF.Tags.Events['TKUI:Status'] = 'UNIT_FLAGS PLAYER_FLAGS_CHANGED PLAYER_ROLES_ASSIGNED PLAYER_DEAD UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['TKUI:Status'] = function(unit)
	local localizedClass, englishClass, classIndex = UnitClass(unit);
	local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
	local isDisconnected = not UnitIsConnected(unit)
	local isGhost = UnitIsGhost(unit)
	local isDead = UnitIsDead(unit)
	local isAFK = UnitIsAFK(unit)
	local status = {
		[1] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Offline.blp:64:128:0:0:64:128:0:64:0:128:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		[2] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Ghost.blp:64:128:0:0:64:128:0:64:0:128:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		[3] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Dead.blp:64:128:0:0:64:128:0:64:0:128:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		[4] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\AFK.blp:64:128:0:0:64:128:0:64:0:128:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t'
	}
	if isDisconnected then
	 return status[1]
 elseif isGhost then
	 return status[2]
 elseif isDead then
	 return status[3]
 elseif isAFK then
	return status[4]
 end
end

ElvUF.Tags.Events['TKUI:RoleIcon'] = 'PLAYER_DEAD UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['TKUI:RoleIcon'] = function(unit)
	local localizedClass, englishClass, classIndex = UnitClass(unit);
	local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
	local playerRole = UnitGroupRolesAssigned(unit);
	local roleIcon = {
		TANK = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Tank.tga:15:15:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		HEALER = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Healer.tga:15:15:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		DAMAGER = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\DPS.tga:15:15:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t'
	}
	if not UnitIsConnected(unit) then
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Disconnected.tga:0:0:0:0:16:16:0:16:0:16:153:153:153|t'
	elseif playerRole == "NONE" then
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Blank.blp:15:15:0:0:16:16:0:16:0:16:1:1:1|t'
	else
		return roleIcon[playerRole]
	end
end
