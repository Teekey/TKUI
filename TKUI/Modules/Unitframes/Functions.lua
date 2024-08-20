----------------------------------------------------------------------------------------
--	Unit Frames for TKUI
--	This module handles the creation and updating of unit frames.
--	It manages health, power, cast bars, auras, and other elements related to unit frames.
--  Based on oUF (https://www.wowace.com/projects/ouf)
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
if C.unitframe.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Unit Frames Functions
----------------------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF
T.oUF = oUF
local UF = {}

C.raidframe.icon_multiplier = (C.raidframe.party_health + C.raidframe.party_power) / 26

----------------------------------------------------------------------------------------
--	General Functions
----------------------------------------------------------------------------------------
UF.UpdateAllElements = function(frame)
	for _, v in ipairs(frame.__elements) do
		v(frame, "UpdateElement", frame.unit)
	end
end

UF.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "ARTWORK")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetShadowOffset(C.font.unitframes_font_shadow and 1 or 0, C.font.unitframes_font_shadow and -1 or 0)
	return fs
end

----------------------------------------------------------------------------------------
--	Unit Categorization Function
----------------------------------------------------------------------------------------
local unitPatterns = {
	{ "^player$",      "player" },
	{ "^target$",      "target" },
	{ "^focus$",       "focus" },
	{ "^pet$",         "pet" },
	{ "^arena%d+$",    "arena" },
	{ "^boss%d+$",     "boss" },
	{ "^party%d+$",    "party" },
	{ "^raid%d+$",     "raid" },
	{ "^partypet%d+$", "pet" },
	{ "^raidpet%d+$",  "pet" },
}

local singleUnits = {
	player = true,
	target = true,
	focus = true,
	pet = true,
	arena = true,
	boss = true
}

-- This function categorizes a unit based on its name.
function UF.CategorizeUnit(unit)
	if not unit then return nil end

	for _, pattern in ipairs(unitPatterns) do
		if string.match(unit, pattern[1]) then
			local genericType = pattern[2]
			return {
				isSingleUnit = singleUnits[genericType] or false,  -- True if it's a single unit like player, target, etc.
				isPartyRaid = genericType == "party" or genericType == "raid", -- True if it's a party or raid member
				genericType =
					genericType                                    -- The generic type of the unit (e.g., "player", "target", "raid")
			}
		end
	end

	-- If no match found, treat it as a single unit (default behavior)
	return {
		isSingleUnit = true,
		isPartyRaid = false,
		genericType = unit
	}
end

----------------------------------------------------------------------------------------
--	Health Functions
----------------------------------------------------------------------------------------
UF.PostUpdateHealth = function(health, unit, min, max)
	if unit and unit:find("arena%dtarget") then return end
	if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
		health:SetValue(0)
		if not UnitIsConnected(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_OFFLINE .. "|r")
		elseif UnitIsDead(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_DEAD .. "|r")
		elseif UnitIsGhost(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_GHOST .. "|r")
		end
	else
		local r, g, b
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = T.oUF_colors.class[class]
				if color then
					r, g, b = color[1], color[2], color[3]
					health:SetStatusBarColor(r, g, b)
				end
			end
		else
			local reaction = UnitReaction(unit, "player")
			if reaction then
				local color = T.oUF_colors.reaction[reaction]
				if color then
					r, g, b = color[1], color[2], color[3]
					health:SetStatusBarColor(r, g, b)
				end
			end
		end

		if unit == "pet" then
			local _, class = UnitClass("player")
			r, g, b = unpack(T.oUF_colors.class[class])
			health:SetStatusBarColor(r, g, b)
			if health.bg and health.bg.multiplier then
				local mu = health.bg.multiplier
				health.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end

		if C.unitframe.bar_color_value == true and not UnitIsTapDenied(unit) then
			r, g, b = health:GetStatusBarColor()
			local newr, newg, newb = oUF:ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

			health:SetStatusBarColor(newr, newg, newb)
			if health.bg and health.bg.multiplier then
				local mu = health.bg.multiplier
				health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
			end
		end

		if min ~= max then
			local percent = floor(min / max * 100)
			r, g, b = oUF:ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if C.unitframe.color_value == true then
				health.value:SetFormattedText("|cff%02x%02x%02x%d|r", r * 255, g * 255, b * 255, percent)
			else
				health.value:SetFormattedText("|cffffffff%d|r", percent)
			end
		else
			if C.unitframe.color_value == true then
				health.value:SetFormattedText("|cff559655%d|r", 100)
			else
				health.value:SetFormattedText("|cffffffff%d|r", 100)
			end
		end
	end
end

UF.PostUpdateRaidHealth = function(health, unit, min, max)
	local self = health:GetParent()
	local power = self.Power
	local border = self.backdrop
	if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
		health:SetValue(0)
		if not UnitIsConnected(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_OFFLINE .. "|r")
		elseif UnitIsDead(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_DEAD .. "|r")
		elseif UnitIsGhost(unit) then
			health.value:SetText("|cffD7BEA5" .. L_UF_GHOST .. "|r")
		end
	else
		local r, g, b
		if not UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and C.unitframe.own_color ~= true then
			local c = T.oUF_colors.reaction[5]
			if c then
				r, g, b = c[1], c[2], c[3]
				health:SetStatusBarColor(r, g, b)
				if health.bg and health.bg.multiplier then
					local mu = health.bg.multiplier
					health.bg:SetVertexColor(r * mu, g * mu, b * mu)
				end
			end
		end
		if C.unitframe.bar_color_value == true and not UnitIsTapDenied(unit) then
			if C.unitframe.own_color == true then
				r, g, b = C.unitframe.uf_color[1], C.unitframe.uf_color[2], C.unitframe.uf_color[3]
			else
				r, g, b = health:GetStatusBarColor()
			end
			local newr, newg, newb = oUF:ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

			health:SetStatusBarColor(newr, newg, newb)
			if health.bg and health.bg.multiplier then
				local mu = health.bg.multiplier
				health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
			end
		end
		health.value:SetText("|cffffffff" .. math.floor(min / max * 100 + .5) .. "|r")
	end
	local _, class = UnitClass(unit)
	local color = T.oUF_colors.class[class]
	if color then
		self.GroupRoleIndicator:SetVertexColor(color[1], color[2], color[3])
		self.LeaderIndicator:SetVertexColor(color[1], color[2], color[3])
		self.AssistantIndicator:SetVertexColor(color[1], color[2], color[3])
	end
end


UF.digitTexCoords = {
	["1"] = { 0, 36 },
	["2"] = { 41, 42 },
	["3"] = { 90, 42 },
	["4"] = { 141, 44 },
	["5"] = { 192, 42 },
	["6"] = { 241, 42 },
	["7"] = { 289, 42 },
	["8"] = { 336, 42 },
	["9"] = { 385, 42 },
	["0"] = { 435, 42 },
	["height"] = 58,
	["texWidth"] = 512,
	["texHeight"] = 128
}

UF.UpdateDigitHealth = function(self)
	local h, hMax = UnitHealth(self.unit), UnitHealthMax(self.unit)
	local status = (not UnitIsConnected(self.unit) or nil) or UnitIsGhost(self.unit) or UnitIsDead(self.unit) --or UnitIsAFK(self.unit)
	local hPerc = ("%d"):format(h / hMax * 100 + 0.5)
	local len = strlen(hPerc)
	if status then
		for i = 1, 3 do
			self.healthFill[i]:Hide()
			self.health[i]:Hide()
		end
	elseif not status then
		for i = 1, 3 do
			if i > len then
				self.health[i]:Hide()
				self.healthFill[i]:Hide()
			else
				local digit = strsub(hPerc , i, i)
				self.health[i]:SetSize(UF.digitTexCoords[digit][2], UF.digitTexCoords["height"])
				self.health[i]:SetTexCoord(UF.digitTexCoords[digit][1] / UF.digitTexCoords["texWidth"], (UF.digitTexCoords[digit][1] + UF.digitTexCoords[digit][2]) / UF.digitTexCoords["texWidth"], 1 / UF.digitTexCoords["texHeight"], (1 + UF.digitTexCoords["height"]) / UF.digitTexCoords["texHeight"])
				self.health[i]:Show()
				self.healthFill[i]:SetSize(UF.digitTexCoords[digit][2], UF.digitTexCoords["height"] * h / hMax)
				self.healthFill[i]:SetTexCoord(UF.digitTexCoords[digit][1] / UF.digitTexCoords["texWidth"], (UF.digitTexCoords[digit][1] + UF.digitTexCoords[digit][2]) / UF.digitTexCoords["texWidth"], (2 + 2 * UF.digitTexCoords["height"] - UF.digitTexCoords["height"] * h / hMax) / UF.digitTexCoords["texHeight"], (2 + 2 * UF.digitTexCoords["height"]) / UF.digitTexCoords["texHeight"])
				self.healthFill[i]:Show()
			end
		end
		if UnitIsPlayer(self.unit) then
			local localizedClass, englishClass, classIndex = UnitClass(self.unit);
			local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
			local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, rPerc, gPerc, bPerc)
			for i = 1, 3 do
				self.healthFill[i]:SetVertexColor(r,g,b)
				self.health[i]:SetVertexColor(r,g,b)
			end
		elseif not UnitIsPlayer(self.unit) then
			local reaction = {}
			local reaction = oUF.colors.reaction[UnitReaction(self.unit, 'player')]
			local r, g, b = oUF:ColorGradient(h, hMax, 1,0,0, 1,.5,0, 1,1,0, reaction[1],reaction[2],reaction[3])
			for i = 1, 3 do
				self.healthFill[i]:SetVertexColor(r,g,b)
				self.health[i]:SetVertexColor(r,g,b)
			end
		else
			for i = 1, 3 do
				self.healthFill[i]:SetVertexColor(1,1,1)
				self.health[i]:SetVertexColor(1,1,1)
			end
		end
		local h, hMax = UnitHealth(self.unit), UnitHealthMax(self.unit)
		local hPerc = ("%d"):format(h / hMax * 100 + 0.5)
		local len = strlen(hPerc)
		if (len == 3) then
			self.health[1]:SetPoint("LEFT")
			self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
			self.health[3]:SetPoint("LEFT", self.health[2], "RIGHT")
		elseif (len == 2) then
			self.health[1]:SetPoint("LEFT", 21, 0)
			self.health[2]:SetPoint("LEFT", self.health[1], "RIGHT")
		elseif (len == 1) then
			self.health[1]:SetPoint("LEFT", 42, 0)
		end
		self.healthFill[1]:SetPoint("BOTTOM", self.health[1])
		self.healthFill[2]:SetPoint("BOTTOM", self.health[2])
		self.healthFill[3]:SetPoint("BOTTOM", self.health[3])
	end
end

----------------------------------------------------------------------------------------
--	Power Functions
----------------------------------------------------------------------------------------
UF.PreUpdatePower = function(power, unit)
	local _, pToken = UnitPowerType(unit)

	local color = T.oUF_colors.power[pToken]
	if color then
		power:SetStatusBarColor(color[1], color[2], color[3])
	end
end

UF.PostUpdatePower = function(power, unit, cur, _, max)
	if unit and unit:find("arena%dtarget") then return end
	local self = power:GetParent()
	local pType, pToken = UnitPowerType(unit)
	local color = T.oUF_colors.power[pToken]

	if color then
		power.value:SetTextColor(color[1], color[2], color[3])
	end

	if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
		power:SetValue(0)
	end

	if unit == "focus" or unit == "focustarget" or unit == "targettarget" or (self:GetParent():GetName():match("oUF_RaidDPS")) then return end

	if not UnitIsConnected(unit) then
		power.value:SetText()
	elseif UnitIsDead(unit) or UnitIsGhost(unit) or max == 0 then
		power.value:SetText()
	end
end

----------------------------------------------------------------------------------------
--	Mana Level Functions
----------------------------------------------------------------------------------------
local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup()
	self.anim:SetLooping("BOUNCE")
	self.anim.fade = self.anim:CreateAnimation("Alpha")
	self.anim.fade:SetFromAlpha(1)
	self.anim.fade:SetToAlpha(0)
	self.anim.fade:SetDuration(0.6)
	self.anim.fade:SetSmoothing("IN_OUT")
end

local Flash = function(self)
	if not self.anim then
		SetUpAnimGroup(self)
	end

	if not self.anim:IsPlaying() then
		self.anim:Play()
	end
end

local StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

UF.UpdateManaLevel = function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < 0.2 then return end
	self.elapsed = 0

	if UnitPowerType("player") == 0 then
		local cur = UnitPower("player", 0)
		local max = UnitPowerMax("player", 0)
		local percMana = max > 0 and (cur / max * 100) or 100
		if percMana <= 20 and not UnitIsDeadOrGhost("player") then
			self.ManaLevel:SetText("|cffaf5050" .. MANA_LOW:upper() .. "|r")
			Flash(self)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	elseif T.class ~= "DRUID" and T.class ~= "PRIEST" and T.class ~= "SHAMAN" then
		self.ManaLevel:SetText()
		StopFlash(self)
	end
end

UF.UpdateClassMana = function(self)
	if self.unit ~= "player" then return end

	-- Ensure FlashInfo is initialized
	if not self.FlashInfo then
		self.FlashInfo = {}  -- Initialize FlashInfo if it doesn't exist
	end

	if UnitPowerType("player") ~= 0 then
		local min = UnitPower("player", 0)
		local max = UnitPowerMax("player", 0)
		local percMana = max > 0 and (min / max * 100) or 100
		if percMana <= 20 and not UnitIsDeadOrGhost("player") then
			if not self.FlashInfo.ManaLevel then
				self.FlashInfo.ManaLevel = self:CreateFontString(nil, "OVERLAY")  -- Create ManaLevel if it doesn't exist
				self.FlashInfo.ManaLevel:SetPoint("CENTER", self, "CENTER")  -- Set position as needed
				self.FlashInfo.ManaLevel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")  -- Set font as needed
			end
			self.FlashInfo.ManaLevel:SetText("|cffaf5050" .. MANA_LOW .. "|r")
			Flash(self.FlashInfo)
		else
			if self.FlashInfo.ManaLevel then
				self.FlashInfo.ManaLevel:SetText()
			end
			StopFlash(self.FlashInfo)
		end

		if min ~= max then
			if self.Power.value:GetText() then
				self.ClassMana:SetPoint("RIGHT", self.Power.value, "LEFT", -1, 0)
				self.ClassMana:SetFormattedText("%d%%|r |cffD7BEA5-|r", floor(min / max * 100))
				self.ClassMana:SetJustifyH("RIGHT")
			else
				self.ClassMana:SetPoint("LEFT", self.Power, "LEFT", 4, 0)
				self.ClassMana:SetFormattedText("%d%%", floor(min / max * 100))
			end
		else
			self.ClassMana:SetText()
		end

		self.ClassMana:SetAlpha(1)
	else
		self.ClassMana:SetAlpha(0)
	end
end


----------------------------------------------------------------------------------------
--	PvP Status Functions
----------------------------------------------------------------------------------------
UF.UpdatePvPStatus = function(self)
	local unit = self.unit

	if self.Status then
		local factionGroup = UnitFactionGroup(unit)
		if UnitIsPVPFreeForAll(unit) then
			self.Status:SetText(PVP)
		elseif factionGroup and UnitIsPVP(unit) then
			self.Status:SetText(PVP)
		else
			self.Status:SetText("")
		end
	end
end

----------------------------------------------------------------------------------------
--	Cast Bar Functions
----------------------------------------------------------------------------------------
local ticks = {}
local setBarTicks = function(Castbar, numTicks)
	for _, v in pairs(ticks) do
		v:Hide()
	end
	if numTicks and numTicks > 0 then
		local delta = Castbar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not ticks[i] then
				ticks[i] = Castbar:CreateTexture(nil, "OVERLAY")
				ticks[i]:SetTexture(C.media.texture)
				ticks[i]:SetVertexColor(unpack(C.media.border_color))
				ticks[i]:SetWidth(1)
				ticks[i]:SetHeight(Castbar:GetHeight())
				ticks[i]:SetDrawLayer("OVERLAY", 7)
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", Castbar, "RIGHT", -delta * i, 0)
			ticks[i]:Show()
		end
	end
end

local function castColor(unit)
	local r, g, b
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local color = T.oUF_colors.class[class]
		if color then
			r, g, b = color[1], color[2], color[3]
		end
	else
		local reaction = UnitReaction(unit, "player")
		local color = T.oUF_colors.reaction[reaction]
		if color and reaction >= 5 then
			r, g, b = color[1], color[2], color[3]
		else
			r, g, b = 0.85, 0.77, 0.36
		end
	end

	return r, g, b
end

local function SetCastbarColor(Castbar, r, g, b)
	Castbar:SetStatusBarColor(r, g, b)
	Castbar.bg:SetVertexColor(C.media.backdrop_color[1], C.media.backdrop_color[2], C.media.backdrop_color[3], 1)
	-- Castbar.backdrop:SetBackdropBorderColor(r, g, b)
	-- Castbar.Button.border:SetBackdropBorderColor(r, g, b)
end

local function SetButtonColor(button, r, g, b)
	button:SetBackdropBorderColor(r, g, b)
	if button.backdrop and button.backdrop.border then
		button.backdrop.border:SetBackdropBorderColor(r, g, b)
	end
end

UF.PostCastStart = function(Castbar, unit)
	unit = unit == "vehicle" and PLAYER or unit

	local r, g, b
	if UnitCanAttack(PLAYER, unit) then
		r, g, b = unpack(Castbar.notInterruptible and T.oUF_colors.notinterruptible or
			T.oUF_colors.interruptible)
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		r, g, b = unpack(T.oUF_colors.class[class])
	else
		local color = T.oUF_colors.reaction[UnitReaction(unit, PLAYER)]
		r, g, b = color[1], color[2], color[3]
	end
	SetCastbarColor(Castbar, r, g, b)
	Castbar.bg:SetVertexColor(r, g, b, 0.1)

	-- Safely set the button border color
	if Castbar.Button then
		if Castbar.Button.SetBackdropBorderColor then
			Castbar.Button:SetBackdropBorderColor(r, g, b, 1)
		elseif Castbar.Button.SetBorderColor then
			Castbar.Button:SetBorderColor(r, g, b, 1)
		elseif Castbar.Button.Border then
			Castbar.Button.Border:SetVertexColor(r, g, b, 1)
		end
	end

	if not Castbar.Button.Cooldown then
		Castbar.Button.Cooldown = CreateFrame("Cooldown", nil, Castbar.Button, "CooldownFrameTemplate")
		Castbar.Button.Cooldown:SetAllPoints()
		Castbar.Button.Cooldown:SetReverse(true)
		Castbar.Button.Cooldown:SetDrawEdge(false)
		Castbar.Button.Cooldown:SetSwipeColor(0, 0, 0, 0.8)
	end

	local start = GetTime()
	local duration = Castbar.max or 0

	if Castbar.channeling then
		local name, _, _, startTimeMS = UnitChannelInfo(unit)
		if name and startTimeMS then
			start = startTimeMS / 1000
			duration = Castbar.max or (Castbar.endTime and (Castbar.endTime - start)) or 0
		end
	end
	Castbar.Button.Cooldown:SetCooldown(start, duration)

	if unit == PLAYER then
		if C.unitframes.castbarLatency and Castbar.Latency then
			local _, _, _, ms = GetNetStats()
			Castbar.Latency:SetFormattedText("%dms", ms)
			Castbar.SafeZone:SetDrawLayer(Castbar.casting and "BORDER" or "ARTWORK")
			Castbar.SafeZone:SetVertexColor(0.85, 0.27, 0.27, Castbar.casting and 1 or 0.75)
		end

		if C.unitframes.castbarTicks then
			if Castbar.casting then
				setBarTicks(Castbar, 0)
			else
				local spell = UnitChannelInfo(unit)
				Castbar.channelingTicks = T.CastBarTicks[spell] or 0
				setBarTicks(Castbar, Castbar.channelingTicks)
			end
		end
	end
end

UF.CustomCastTimeText = function(self, duration)
	if duration > 600 then
		self.Time:SetText("∞")
	else
		self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
	end
end

UF.CustomCastDelayText = function(self, duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration,
		self.channeling and "-" or "+", abs(self.delay)))
end

----------------------------------------------------------------------------------------
--	Aura Tracking Functions
----------------------------------------------------------------------------------------
UF.AuraTrackerTime = function(self, elapsed)
	if self.active then
		self.timeleft = self.timeleft - elapsed
		if self.timeleft <= 5 then
			self.text:SetTextColor(1, 0, 0)
		else
			self.text:SetTextColor(1, 1, 1)
		end
		if self.timeleft <= 0 then
			self.icon:SetTexture("")
			self.text:SetText("")
		end
		self.text:SetFormattedText("%.1f", self.timeleft)
	end
end

UF.HideAuraFrame = function(self)
	if self.unit == "player" then
		BuffFrame:Hide()
		self.Debuffs:Hide()
	elseif self.unit == "pet" or self.unit == "focus" or self.unit == "focustarget" or self.unit == "targettarget" then
		self.Debuffs:Hide()
	end
end

UF.PostCreateIcon = function(element, button)
	button:SetTemplate("Default")
	if unit == "player" then
		button.remaining = UF.SetFontString(button, C.font.unitframes_auras_font,
			C.font.unitframes_auras_font_size, C.font.unitframes_auras_font_size)
		button.remaining:SetShadowOffset(C.font.unitframes_auras_font_shadow and 1 or 0,
			C.font.unitframes_auras_font_shadow and -1 or 0)
		button.remaining:SetPoint("CENTER", button, "CENTER", 1, 1)
		button.remaining:SetJustifyH("CENTER")
	else
		button.remaining = UF.SetFontString(button, C.font.auras_font, C.font.auras_font_size, C.font.auras_font_style)
		button.remaining:SetShadowOffset(C.font.auras_font_shadow and 1 or 0, C.font.auras_font_shadow and -1 or 0)
		button.remaining:SetPoint("CENTER", button, "CENTER", 1, 1)
		button.remaining:SetJustifyH("CENTER")
	end

	button.Cooldown.noCooldownCount = false


	button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
	button.Count:SetJustifyH("RIGHT")
	button.Count:SetFont(C.font.unitframes_auras_font, C.font.unitframes_auras_font_size,
		C.font.unitframes_auras_font_style)
	button.Count:SetShadowOffset(C.font.unitframes_auras_font_shadow and 1 or 0,
		C.font.unitframes_auras_font_shadow and -1 or 0)

	button.parent = CreateFrame("Frame", nil, button)
	button.parent:SetFrameLevel(button:GetFrameLevel() - 1)
	button:ClearAllPoints()
	button.Cooldown:SetParent(button.parent)
	button.Cooldown:SetSwipeColor(1, 0, 0, 1)
	button.Cooldown:SetReverse(true)


	button.Icon:SetParent(button)
	button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
	button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.Icon:SetDrawLayer("ARTWORK", 1) -- Set the icon to a higher draw layer



	-- if C.aura.show_spiral == true then
	-- 	element.disableCooldown = false
	-- 	button.Cooldown:SetReverse(true)
	-- 	-- button.Cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	-- 	-- button.Cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	-- 	button.parent = CreateFrame("Frame", nil, button)
	-- 	button.parent:SetFrameLevel(button.Cooldown:GetFrameLevel() - 1)
	-- 	button.Cooldown:SetParent(button.parent)
	-- else
	-- 	element.disableCooldown = true
	-- end
end

local day, hour, minute = 86400, 3600, 60
local FormatTime = function(s)
	if s >= day then
		return format("%dd", floor(s / day + 0.5))
	elseif s >= hour then
		return format("%dh", floor(s / hour + 0.5))
	elseif s >= minute then
		return format("%dm", floor(s / minute + 0.5))
	elseif s >= 5 then
		return floor(s + 0.5)
	end
	return format("%.1f", s)
end

UF.CreateAuraTimer = function(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end


local playerUnits = {
	player = true,
	pet = true,
	vehicle = true,
}

UF.PostUpdateIcon = function(_, button, unit, data)
	local unitCategory = UF.CategorizeUnit(data.sourceUnit)
	local isPlayerUnit = unitCategory and (unitCategory.genericType == "player" or unitCategory.genericType == "pet")

	if data.isHarmful then
		if not UnitIsFriend("player", unit) and not isPlayerUnit then
			if not C.aura.player_aura_only then
				button:SetBackdropBorderColor(unpack(C.media.border_color))
				button.Icon:SetDesaturated(true)
			end
		else
			if C.aura.debuff_color_type == true then
				local color = DebuffTypeColor[data.dispelName] or DebuffTypeColor.none
				button:SetBackdropBorderColor(color.r, color.g, color.b)
				button.Icon:SetDesaturated(false)
			else
				button:SetBackdropBorderColor(1, 0, 0)
			end
		end
	else
		-- This is the buff section
		if (data.isStealable or ((T.class == "MAGE" or T.class == "PRIEST" or T.class == "SHAMAN" or T.class == "HUNTER") and data.dispelName == "Magic")) and not UnitIsFriend("player", unit) then
			button:SetBackdropBorderColor(1, 0.85, 0)
		elseif data.duration and data.duration > 0 then
			-- Set the border color to green for buffs with duration
			button:SetBackdropBorderColor(0, 1, 0) -- RGB values for green
		else
			-- Use default border color for permanent/passive buffs
			button:SetBackdropBorderColor(unpack(C.media.border_color))
		end
		button.Icon:SetDesaturated(false)
	end

	button.remaining:Hide()
	button.timeLeft = math.huge
	button:SetScript("OnUpdate", nil)

	button.first = true
end

UF.CustomFilter = function(element, unit, data)
	if C.aura.player_aura_only then
		if data.isHarmful then
			if not UnitIsFriend("player", unit) and not playerUnits[data.sourceUnit] then
				return false
			end
		end
	end
	return true
end

UF.CustomFilterBoss = function(element, unit, data)
	if data.isHarmful then
		if (playerUnits[data.sourceUnit] or data.sourceUnit == unit) then
			if (T.DebuffBlackList and not T.DebuffBlackList[data.name]) or not T.DebuffBlackList then
				return true
			end
		end
		return false
	end
	return true
end

----------------------------------------------------------------------------------------
--	Threat Functions
----------------------------------------------------------------------------------------
UF.UpdateThreat = function(self, unit, status, r, g, b)
	local parent = self:GetParent()
	local badunit = not unit or parent.unit ~= unit

	if not badunit and status and status > 1 then
		parent.backdrop:SetBackdropBorderColor(r, g, b)
	else
		parent.backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
	end
end


----------------------------------------------------------------------------------------
--	Aura Watch Functions
----------------------------------------------------------------------------------------
local CountOffSets = {
	Normal = {
		[1] = { "TOPRIGHT", "TOPRIGHT", 0, 0 },       -- Top Right
		[2] = { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0 }, -- Bottom Right
		[3] = { "BOTTOMLEFT", "BOTTOMLEFT", 0, 0 },   -- Bottom Left
		[4] = { "TOPLEFT", "TOPLEFT", 0, 0 },         -- Top Left
	},
	Reversed = {
		[1] = { "TOPLEFT", "TOPLEFT", 0, 0 },         -- Top Left
		[2] = { "BOTTOMLEFT", "BOTTOMLEFT", 0, 0 },   -- Bottom Left
		[3] = { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0 }, -- Bottom Right
		[4] = { "TOPRIGHT", "TOPRIGHT", 0, 0 },       -- Top Right
	}
}

UF.CreateAuraWatch = function(self, buffs, name, anchorPoint, size, filter, reverseGrowth)
	local auras = CreateFrame("Frame", nil, self)
	auras:SetPoint(anchorPoint[1], self[anchorPoint[2]], anchorPoint[3], anchorPoint[4], anchorPoint[5])
	auras:SetSize(size, size)

	auras.icons = {}
	auras.PostCreateIcon = UF.CreateAuraWatchIcon

	-- Create icons for all buffs
	for _, spell in ipairs(buffs) do
		local icon = CreateFrame("Frame", nil, auras)
		icon.spellID = spell[1]
		icon.anyUnit = spell[4]
		icon.strictMatching = spell[5]
		icon:SetSize(size / 2 - 1, size / 2 - 1)

		-- Set frame level for each icon
		icon:SetFrameLevel(auras:GetFrameLevel() + 1)

		icon:SetTemplate("Default")

		local borderColor = spell[2] or { 0.8, 0.8, 0.8 }
		icon:SetBackdropBorderColor(unpack(borderColor))

		local texFrame = CreateFrame("Frame", nil, icon)
		texFrame:SetAllPoints(icon)
		texFrame:SetFrameLevel(icon:GetFrameLevel() + 1)

		local tex = texFrame:CreateTexture(nil, "OVERLAY")
		tex:SetSize(size / 2 - 7, size / 2 - 7)
		tex:SetPoint("CENTER", texFrame, "CENTER", 0, 0)
		icon.icon = tex

		local spellTexture = C_Spell.GetSpellTexture(icon.spellID)
		if spellTexture then
			icon.icon:SetTexture(spellTexture)
			icon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end

		local count = UF.SetFontString(icon, C.font.unitframes_font, C.font.unitframes_font_size,
			C.font.unitframes_font_style)
		count:SetPoint("CENTER", icon, "CENTER", 0, 0)
		icon.count = count

		icon:Hide() -- Hide all icons initially

		auras.icons[spell[1]] = icon
	end

	-- Function to update auras and manage visibility
	auras.UpdateAuras = function(self, unit)
		if not unit then
			return
		end

		local visibleIcons = {}
		for i = 1, 40 do
			local name, icon, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, i, filter)
			if not name then break end

			local watchIcon = self.icons[spellID]
			if watchIcon then
				if (filter == "HELPFUL|PLAYER") or (filter == "HELPFUL" and (not UnitIsUnit(unitCaster, "player"))) then
					watchIcon.count:SetText(count > 1 and count or "")
					watchIcon.expirationTime = expirationTime
					watchIcon.duration = duration
					watchIcon:SetScript("OnUpdate", UF.UpdateAuraTimer)
					table.insert(visibleIcons, watchIcon)
				end
			end
		end

		-- Sort visible icons by expiration time (oldest first)
		table.sort(visibleIcons, function(a, b)
			return (a.expirationTime or 0) < (b.expirationTime or 0)
		end)

		-- Show and position the first 4 visible icons
		local offsetSet = reverseGrowth and CountOffSets.Reversed or CountOffSets.Normal
		for i = 1, math.min(4, #visibleIcons) do
			local icon = visibleIcons[i]
			local point, anchorPoint, x, y = unpack(offsetSet[i])
			icon:ClearAllPoints()
			icon:SetPoint(point, self, anchorPoint, x, y)
			icon:SetAlpha(1)
			icon:Show()
		end

		-- Hide any remaining icons
		for i = 5, #visibleIcons do
			visibleIcons[i]:Hide()
			visibleIcons[i]:ClearAllPoints()
		end

		-- Hide all unused icons
		for _, icon in pairs(self.icons) do
			if not tContains(visibleIcons, icon) then
				icon:Hide()
				icon:ClearAllPoints()
			end
		end
	end

	auras:RegisterEvent("UNIT_AURA")
	auras:SetScript("OnEvent", function(frame, event, unit)
		if unit == self.unit or (self.unit == "player" and unit == "vehicle") then
			frame.UpdateAuras(frame, unit)
		end
	end)

	self[name] = auras

	-- Initial update
	auras.UpdateAuras(auras, self.unit)

	return auras
end

-- Function to create the original AuraWatch (player buffs)
UF.CreatePlayerBuffWatch = function(self)
	local buffs = {}

	-- Collect buffs
	if T.RaidBuffs["ALL"] then
		for _, value in pairs(T.RaidBuffs["ALL"]) do
			tinsert(buffs, value)
		end
	end

	if T.RaidBuffs[T.class] then
		for _, value in pairs(T.RaidBuffs[T.class]) do
			tinsert(buffs, value)
		end
	end

	return UF.CreateAuraWatch(self, buffs, "AuraWatch", { "BOTTOMRIGHT", "Health", "TOPRIGHT", 4, 6 }, 40,
		"HELPFUL|PLAYER")
end

-- Function to create a new AuraWatch for other players' buffs
UF.CreatePartyBuffWatch = function(self)
	local buffs = {}

	-- Collect all buffs from T.RaidBuffs, regardless of category
	for category, buffList in pairs(T.RaidBuffs) do
		for _, value in pairs(buffList) do
			tinsert(buffs, value)
		end
	end

	return UF.CreateAuraWatch(self, buffs, "OtherPlayersAuraWatch", { "BOTTOMLEFT", "Health", "TOPLEFT", -4, 6 }, 40,
		"HELPFUL", true)
end

-- Check for existing buffs when entering world or reloading UI
local function InitialAuraCheck(frame)
	if frame.AuraWatch then
		frame.AuraWatch.UpdateAuras(frame.AuraWatch, frame.unit)
	end
	if frame.OtherPlayersAuraWatch then
		frame.OtherPlayersAuraWatch.UpdateAuras(frame.OtherPlayersAuraWatch, frame.unit)
	end
end

-- Register for PLAYER_ENTERING_WORLD event
local initialCheckFrame = CreateFrame("Frame")
initialCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initialCheckFrame:SetScript("OnEvent", function()
	for _, frame in pairs(oUF.objects) do
		InitialAuraCheck(frame)
	end
	-- Unregister the event after the initial check
	initialCheckFrame:UnregisterAllEvents()
end)


----------------------------------------------------------------------------------------
--	Health Prediction Functions
----------------------------------------------------------------------------------------
UF.CreateHealthPrediction = function(self)
	local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
	mhpb:SetTexture(C.media.texture)
	mhpb:SetVertexColor(0, 1, 0.5, 0.2)

	local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
	ohpb:SetTexture(C.media.texture)
	ohpb:SetVertexColor(0, 1, 0, 0.2)

	local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
	ahpb:SetTexture(C.media.texture)
	ahpb:SetVertexColor(1, 1, 0, 0.2)

	local hab = self.Health:CreateTexture(nil, "ARTWORK")
	hab:SetTexture(C.media.texture)
	hab:SetVertexColor(1, 0, 0, 0.4)

	local oa = self.Health:CreateTexture(nil, "ARTWORK")
	oa:SetTexture([[Interface\AddOns\TKUI\Media\Textures\Cross.tga]], "REPEAT", "REPEAT")
	oa:SetVertexColor(0.5, 0.5, 1)
	oa:SetHorizTile(true)
	oa:SetVertTile(true)
	oa:SetAlpha(0.4)
	oa:SetBlendMode("ADD")

	local oha = self.Health:CreateTexture(nil, "ARTWORK")
	oha:SetTexture([[Interface\AddOns\TKUI\Media\Textures\Cross.tga]], "REPEAT", "REPEAT")
	oha:SetVertexColor(1, 0, 0)
	oha:SetHorizTile(true)
	oha:SetVertTile(true)
	oha:SetAlpha(0.4)
	oha:SetBlendMode("ADD")

	self.HealthPrediction = {
		myBar = mhpb,                                           -- Represents predicted health from your heals
		otherBar = ohpb,                                        -- Represents predicted health from other heals
		absorbBar = ahpb,                                       -- Represents predicted absorb shields
		healAbsorbBar = hab,                                    -- Represents predicted heals that will be absorbed
		overAbsorb = C.raidframe.plugins_over_absorb and oa,    -- Texture for over-absorption
		overHealAbsorb = C.raidframe.plugins_over_heal_absorb and oha -- Texture for over-heal-absorb
	}
end

T.UF = UF
return UF
