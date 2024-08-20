local T, C, L = unpack(TKUI)
if C.unitframe.enable ~= true or C.unitframe.show_arena ~= true then return end

----------------------------------------------------------------------------------------
--	Based on oUF_AuraTracker(by Thizzelle)
----------------------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF

local function Update(object, _, unit)
    local _, instanceType = IsInInstance()
    if instanceType ~= "arena" then
        object.AuraTracker:Hide()
        return
    else
        object.AuraTracker:Show()
    end

    if object.unit ~= unit then return end

    local auraList = T.ArenaControl
    local priority = 0
    local auraName, auraIcon, auraExpTime

    -- Buffs
    for _, auraData in ipairs(C_UnitAuras.GetAuraDataByUnit(unit, "HELPFUL")) do
        local name = auraData.name
        if auraList[name] and auraList[name] >= priority then
            priority = auraList[name]
            auraName = name
            auraIcon = auraData.icon
            auraExpTime = auraData.expirationTime
        end
    end

    -- Debuffs
    for _, auraData in ipairs(C_UnitAuras.GetAuraDataByUnit(unit, "HARMFUL")) do
        local name = auraData.name
        if auraList[name] and auraList[name] >= priority then
            priority = auraList[name]
            auraName = name
            auraIcon = auraData.icon
            auraExpTime = auraData.expirationTime
        end
    end

    if auraName then
        object.AuraTracker.icon:SetTexture(auraIcon)
        object.AuraTracker.timeleft = auraExpTime - GetTime()
        if object.AuraTracker.timeleft > 0 then
            object.AuraTracker.active = true
        end
    else
        object.AuraTracker.icon:SetTexture("")
        object.AuraTracker.text:SetText("")
        object.AuraTracker.active = false
    end
end

local function Enable(object)
	-- If we're not highlighting this unit return
	if not object.AuraTracker then return end

	-- Make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(object)
	if object.AuraTracker then
		object:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("AuraTracker", Update, Enable, Disable)