local E, L, V, P, G, _ = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ElvUF = ElvUI.oUF
local Translit = E.Libs.Translit
local translitMark = "!"
local UF = E:GetModule('UnitFrames');

-- Cache global variables
-- WoW API / Variables
local strfind, strmatch, strlower, utf8lower, utf8sub, utf8len = strfind, strmatch, strlower, string.utf8lower, string.utf8sub, string.utf8len

local perhp = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return math.floor(UnitHealth(u) / m * 100 + .5)
	end
end

local name = function(u, r)
	return UnitName(r or u)
end

ElvUF.Tags.Events['TKUI:EnemyNPC'] = 'UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED RAID_TARGET_UPDATE'
ElvUF.Tags.Methods['TKUI:EnemyNPC'] = function(unit, player, target)
	local _,threat = UnitDetailedThreatSituation('player', unit);
	local _,focus = UnitDetailedThreatSituation('focus', unit);
	local isTank = UnitGroupRolesAssigned('player') == "TANK";
	local isDPS = UnitGroupRolesAssigned('player') == "DAMAGER";
	local isHealer = UnitGroupRolesAssigned('player') == "HEALER";
	local isNone = UnitGroupRolesAssigned('player') == "NONE";
	local unitName = _TAGS['name'](unit) or "Unknown"
	local unitNameTarget = '['..unitName..']';
	--local nameColor = _TAGS['namecolor'](unit);
	local unitReaction = UnitReaction(unit, 'player');
	local nameColor = Hex(ElvUF.colors.reaction[unitReaction])
	local perHp = '|cFFFFFFFF '..perhp(unit);
	local isTarget = UnitIsUnit('playertarget', unit);
	local isUnitCombat = UnitAffectingCombat(unit);
	local isPlayerCombat = UnitAffectingCombat('player');
	local isTapped = UnitIsTapDenied(unit);

    --
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
--
	if (isTarget and isTapped) then
		return tappedColor..unitNameTarget..perHp;
	elseif isTapped then
		return tappedColor..unitName..perHp;
	elseif (isTarget and isUnitCombat and isPlayerCombat and isTank and focus == 3) then
		return tankColor[4]..unitNameTarget..perHp;
	elseif (isTarget and isUnitCombat and isPlayerCombat and isTank) then
		return tankColor[threat]..unitNameTarget..perHp;
	elseif (isTarget and isUnitCombat and isPlayerCombat) and (isDPS or isHealer) then
		return dpsColor[threat]..unitNameTarget..perHp;
	elseif (isTarget and isUnitCombat and isPlayerCombat and isNone) then
		return tankColor[threat]..unitNameTarget..perHp;
	elseif (isUnitCombat and isPlayerCombat and isTank and focus == 3) then
		return tankColor[4]..unitName..perHp;
	elseif (isUnitCombat and isPlayerCombat and isTank) then
		return tankColor[threat]..unitName..perHp;
	elseif (isUnitCombat and isPlayerCombat) and (isDPS or isHealer) then
		return dpsColor[threat]..unitName..perHp;
	elseif (isUnitCombat and isPlayerCombat and isNone) then
		return tankColor[threat]..unitName..perHp;
	elseif isTarget then
		return nameColor..'['..unitName..']'..perHp;
	else
		return nameColor .. unitName .. perHp;
	end
end

ElvUF.Tags.Events['TKUI:FriendlyNPC'] = 'UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED RAID_TARGET_UPDATE'
ElvUF.Tags.Methods['TKUI:FriendlyNPC'] = function(unit, player, target)
	local unitName = _TAGS['name'](unit) or "Unknown"
	local unitNameTarget = '['..unitName..']';
	local isTarget = UnitIsUnit('playertarget', unit);
	local nameColor = _TAGS['namecolor'](unit);
	local perHp = '|cFFFFFFFF '..perhp(unit);
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min

	if isTarget and not ((deficit <= 0) or (min == 0)) then
		return nameColor..unitNameTarget..perHp;
	elseif isTarget and ((deficit <= 0) or (min == 0)) then
		return nameColor..unitNameTarget;
	end
    --
	if not isTarget and not ((deficit <= 0) or (min == 0)) then
		return nameColor..unitName..perHp;
	elseif not isTarget and ((deficit <= 0) or (min == 0)) then
		return nameColor..unitName;
	end
end

ElvUF.Tags.Events['TKUI:FriendlyPlayer'] = 'UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED RAID_TARGET_UPDATE'
ElvUF.Tags.Methods['TKUI:FriendlyPlayer'] = function(unit, player, target)
	local unitName = name(unit)  or "Unknown";
	local unitNameTarget = '['..unitName..']';
	local isTarget = UnitIsUnit('playertarget', unit);
	local nameColor = _TAGS['namecolor'](unit);
	local perHp = '|cFFFFFFFF '..perhp(unit);
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min

	if isTarget and not ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitNameTarget..perHp;
	elseif isTarget and ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitNameTarget;
	end
    --
	if not isTarget and not ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitName..perHp;
	elseif not isTarget and ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitName;
	end
end

ElvUF.Tags.Events['TKUI:EnemyPlayer'] = 'UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED RAID_TARGET_UPDATE'
ElvUF.Tags.Methods['TKUI:EnemyPlayer'] = function(unit, player, target)
	local unitName = name(unit)  or "Unknown";
	local unitNameTarget = '['..unitName..']';
	local isTarget = UnitIsUnit('playertarget', unit);
	local nameColor = _TAGS['namecolor'](unit);
	local perHp = '|cFFFFFFFF '..perhp(unit);
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min

	if isTarget and not ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitNameTarget..perHp;
	elseif isTarget and ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitNameTarget;
	end
    --
	if not isTarget and not ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitName..perHp;
	elseif not isTarget and ((deficit <= 0) or (min == 0) or (UnitIsGhost(unit))) then
		return nameColor..unitName;
	end
end


ElvUF.Tags.Events['TKUI:GroupLead'] = 'PARTY_LEADER_CHANGED'
ElvUF.Tags.Methods['TKUI:GroupLead'] = function(unit, player)
	if(UnitIsGroupLeader(unit)) then
		return 'L'
	elseif(UnitIsGroupAssistant(unit)) then
		return 'A'
	end
end

ElvUF.Tags.Events['TKUI:RaidMarker'] = 'RAID_TARGET_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED'
ElvUF.Tags.Methods['TKUI:RaidMarker'] = function(unit, player, target)
	local iconNumber = GetRaidTargetIndex(unit);
	local raidIcon = {
		[1] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_1.blp:18:18|t',
		[2] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_2.blp:18:18|t',
		[3] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_3.blp:18:18|t',
		[4] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_4.blp:18:18|t',
		[5] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_5.blp:18:18|t',
		[6] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_6.blp:18:18|t',
		[7] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_7.blp:18:18|t',
		[8] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\UI-RaidTargetingIcon_8.blp:18:18|t'
	}
	 return raidIcon[iconNumber]
end

ElvUF.Tags.Events['TKUI:StatusIcon'] = 'PLAYER_DEAD UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_TARGET_CHANGED NAME_PLATE_UNIT_ADDED NAME_PLATE_CREATED UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED'
ElvUF.Tags.Methods['TKUI:StatusIcon'] = function(unit, player, target)
	isDisconnected = not UnitIsConnected(unit)
	isGhost = UnitIsGhost(unit)
	isDead = UnitIsDead(unit)
	local statusIcon = {
		[1] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\TKUIDisconnected.blp:64:64|t',
		[2] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\TKUIGhost.blp:64:64|t',
		[3] = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\TKUIDead.blp:64:64|t'
	}
	if isDisconnected then
	 return statusIcon[1]
 elseif isGhost then
	 return statusIcon[2]
 elseif isDead then
	 return statusIcon[3]
 end
end

ElvUF.Tags.Events['TKUI:RoleIcon'] = 'GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['TKUI:RoleIcon'] = function(unit, player)
	local localizedClass, englishClass, classIndex = UnitClass(unit);
	local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
	local playerRole = UnitGroupRolesAssigned(unit);
	local roleIcon = {
		TANK = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Tank.tga:0:0:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		HEALER = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Healer.tga:0:0:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t',
		DAMAGER = '|TInterface\\AddOns\\TKUI\\Media\\Textures\\DPS.tga:0:0:0:0:16:16:0:16:0:16:'..(rPerc * 255)..':'..(gPerc * 255)..':'..(bPerc * 255)..'|t'
	}
	if not UnitIsConnected(unit) then
		return '|TInterface\\AddOns\\TKUI\\Media\\Textures\\Disconnected.tga:0:0:0:0:16:16:0:16:0:16:153:153:153|t'
	else
		return roleIcon[playerRole]
	end
end
