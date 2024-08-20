local T, C, L = unpack(TKUI)

local backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
local borderr, borderg, borderb, bordera = unpack(C.media.border_color)

local Mult = T.mult
if T.screenHeight > 1200 then
	Mult = T.Scale(1)
end

----------------------------------------------------------------------------------------
--	Position functions
----------------------------------------------------------------------------------------
local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 3
	yOffset = yOffset or 3
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 3
	yOffset = yOffset or 3
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

----------------------------------------------------------------------------------------
--	Color functions
----------------------------------------------------------------------------------------

T.RGBToHex = function(r, g, b)
	r = tonumber(r) <= 1 and tonumber(r) >= 0 and tonumber(r) or 0
	g = tonumber(g) <= tonumber(g) and tonumber(g) >= 0 and tonumber(g) or 0
	b = tonumber(b) <= 1 and tonumber(b) >= 0 and tonumber(b) or 0
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

T.ColorGradient = function(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
	if perc >= 1 then
		return r3, g3, b3
	elseif perc <= 0 then
		return r1, g1, b1
	end

	local segment, relperc = math.modf(perc * 2)
	local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1, g1, b1, r2, g2, b2, r3, g3, b3)

	return rr1 + (rr2 - rr1) * relperc, rg1 + (rg2 - rg1) * relperc, rb1 + (rb2 - rb1) * relperc
end

----------------------------------------------------------------------------------------
--	Template functions
----------------------------------------------------------------------------------------
function T.CreateShadow(frame, size, r, g, b, force)
	if not force and not C.skins.shadow then
		return
	end

	if not frame or frame.__tkShadow or frame.shadow and frame.shadow.__tk then
		return
	end

	if frame:GetObjectType() == "Texture" then
		frame = frame:GetParent()
	end

	r = r or C.skins.shadow_color.r or 0
	g = g or C.skins.shadow_color.g or 0
	b = b or C.skins.shadow_color.b or 0

	size = C.skins.shadow_size or 4

	local shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	shadow:SetFrameStrata(frame:GetFrameStrata())

	-- Optimization: Set the shadow's frame level relative to the parent
	local parentLevel = frame:GetFrameLevel()
	shadow:SetFrameLevel(max(0, parentLevel - 1))

	shadow:SetOutside(frame, size, size)
	shadow:SetBackdrop({ edgeFile = C.media.glow_texture, edgeSize = size + 1 })
	shadow:SetBackdropColor(r, g, b, 0)
	shadow:SetBackdropBorderColor(r, g, b, 0.618)
	shadow.__tk = true -- mark the shadow created by TKUI

	frame.shadow = shadow
	frame.__tkShadow = 1 -- mark the current frame has shadow
end

function T.CreateLowerShadow(frame, force)
	if not force and not C.skins.shadow then
		return
	end

	T.CreateShadow(frame)
	if frame.shadow and frame.SetFrameStrata and frame.SetFrameLevel then
		local function refreshFrameLevel()
			local parentFrameLevel = frame:GetFrameLevel()
			frame.shadow:SetFrameLevel(parentFrameLevel > 0 and parentFrameLevel - 1 or 0)
		end

		-- avoid the shadow level is reset when the frame strata/level is changed
		hooksecurefunc(frame, "SetFrameStrata", refreshFrameLevel)
		hooksecurefunc(frame, "SetFrameLevel", refreshFrameLevel)
	end
end

local function CreateOverlay(f)
	if f.overlay then return end

	local overlay = f:CreateTexture("$parentOverlay", "BORDER")
	overlay:SetInside()
	overlay:SetTexture(C.media.blank)
	overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	f.overlay = overlay
end

local function CreateBorder(f, i, o)
	if i then
		if f.iborder then return end
		local border = CreateFrame("Frame", "$parentInnerBorder", f, "BackdropTemplate")
		border:SetPoint("TOPLEFT", Mult * 2, -Mult * 2)
		border:SetPoint("BOTTOMRIGHT", -Mult * 2, Mult * 2)
		border:SetBackdrop({
			edgeFile = C.media.blank,
			edgeSize = Mult,
			insets = { left = Mult, right = Mult, top = Mult, bottom = Mult }
		})
		border:SetBackdropBorderColor(unpack(C.media.backdrop_color))
		f.iborder = border
	end
	if o then
		if f.oborder then return end
		local border = CreateFrame("Frame", "$parentOuterBorder", f, "BackdropTemplate")
		border:SetPoint("TOPLEFT", -Mult, Mult)
		border:SetPoint("BOTTOMRIGHT", Mult, -Mult)
		border:SetFrameLevel(f:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = C.media.blank,
			edgeSize = Mult,
			insets = { left = Mult, right = Mult, top = Mult, bottom = Mult }
		})
		border:SetBackdropBorderColor(unpack(C.media.backdrop_color))
		f.oborder = border
	end
end

local function GetTemplate(t)
	if t == "ClassColor" then
		borderr, borderg, borderb, bordera = unpack(C.media.classborder_color)
		backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
	else
		borderr, borderg, borderb, bordera = unpack(C.media.border_color)
		backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
	end
end

local function ApplyTemplate(f, t)
	if t == "Transparent" then
		backdropa = C.media.backdrop_alpha
		f:CreateBorder(true, true)
	elseif t == "Zero" then
		backdropa = 0
		f:CreateBorder(true, true)
		backdropa = C.media.backdrop_color[4]
	elseif t == "Overlay" then
		backdropa = 1
		f:CreateOverlay()
	elseif t == "Databar" then
		bordera = 0
	elseif t == "Invisible" then -- Added for consistency with CreatePanel
		backdropa = 0
		bordera = 0
	else
		f:CreateBorder(true, true)
		backdropa = C.media.backdrop_color[4]
	end

	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb, bordera)

	-- Apply shadow to all templates except "Zero" and "Invisible"
	if t ~= "Invisible" then
		T.CreateLowerShadow(f)
	end
end

local function SetTemplate(f, t)
	Mixin(f, BackdropTemplateMixin) -- 9.0 to set backdrop
	GetTemplate(t)

	f:SetBackdrop({
		bgFile = C.media.blank,
		edgeFile = C.media.blank,
		edgeSize = 2,
		insets = { left = -Mult, right = -Mult, top = -Mult, bottom = -Mult }
	})

	ApplyTemplate(f, t)
end

local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	Mixin(f, BackdropTemplateMixin) -- 9.0 to set backdrop
	GetTemplate(t)

	f:SetWidth(w)
	f:SetHeight(h)
	f:SetFrameLevel(3)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)
	f:SetBackdrop({
		bgFile = C.media.blank,
		edgeFile = C.media.blank,
		edgeSize = Mult * 2,
		insets = { left = -Mult, right = -Mult, top = -Mult, bottom = -Mult }
	})

	ApplyTemplate(f, t)
end

local function CreateBackdrop(f, t)
	local f = (f.IsObjectType and f:IsObjectType("Texture") and f:GetParent()) or f
	if f.backdrop then return end
	if not t then t = "Default" end

	local b = CreateFrame("Frame", "$parentBackdrop", f)
	b:SetOutside()
	b:SetTemplate(t)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

local StripTexturesBlizzFrames = {
	"Inset", "inset", "InsetFrame", "LeftInset", "RightInset", "NineSlice",
	"BG", "Bg", "border", "Border", "BorderFrame", "bottomInset", "BottomInset",
	"bgLeft", "bgRight", "FilligreeOverlay", "PortraitOverlay", "ArtOverlayFrame",
	"Portrait", "portrait", "ScrollFrameBorder",
}

local function StripTextures(object, kill)
	if not object.GetNumRegions then return end

	for i = 1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:IsObjectType("Texture") then
			if kill then
				region:Kill()
			else
				region:SetTexture("")
				region:SetAtlas("")
			end
		end
	end

	local frameName = object.GetName and object:GetName()
	if frameName then
		for _, blizzard in ipairs(StripTexturesBlizzFrames) do
			local blizzFrame = object[blizzard] or _G[frameName .. blizzard]
			if blizzFrame then
				StripTextures(blizzFrame, kill)
			end
		end
	end
end


----------------------------------------------------------------------------------------
--	Radial Statusbar functions
----------------------------------------------------------------------------------------

local cos, sin, pi2, halfpi = math.cos, math.sin, math.rad(360), math.rad(90)

local function TransformTexture(tx, x, y, angle, aspect)
	local c, s = cos(angle), sin(angle)
	local y, oy = y / aspect, 0.5 / aspect
	local ULx, ULy = 0.5 + (x - 0.5) * c - (y - oy) * s, (oy + (y - oy) * c + (x - 0.5) * s) * aspect
	local LLx, LLy = 0.5 + (x - 0.5) * c - (y + oy) * s, (oy + (y + oy) * c + (x - 0.5) * s) * aspect
	local URx, URy = 0.5 + (x + 0.5) * c - (y - oy) * s, (oy + (y - oy) * c + (x + 0.5) * s) * aspect
	local LRx, LRy = 0.5 + (x + 0.5) * c - (y + oy) * s, (oy + (y + oy) * c + (x + 0.5) * s) * aspect
	tx:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

-- Permanently pause our rotation animation after it starts playing
local function OnPlayUpdate(self)
	self:SetScript('OnUpdate', nil)
	self:Pause()
end

local function OnPlay(self)
	self:SetScript('OnUpdate', OnPlayUpdate)
end

local function SetRadialStatusBarValue(self, value)
	value = math.max(0, math.min(1, value))

	if self._reverse then
		value = 1 - value
	end

	local q = self._clockwise and (1 - value) or value
	local quadrant = q >= 0.75 and 1 or q >= 0.5 and 2 or q >= 0.25 and 3 or 4

	if self._quadrant ~= quadrant then
		self._quadrant = quadrant
		for i = 1, 4 do
			self._textures[i]:SetShown(self._clockwise and i < quadrant or not self._clockwise and i > quadrant)
		end
		self._scrollframe:SetAllPoints(self._textures[quadrant])
	end

	local rads = value * pi2
	if not self._clockwise then rads = -rads + halfpi end
	TransformTexture(self._wedge, -0.5, -0.5, rads, self._aspect)
	self._rotation:SetRadians(-rads)
end

local function OnSizeChanged(self, width, height)
	self._wedge:SetSize(width, height)
	self._aspect = width / height
end

-- Creates a function that calls a method on all textures at once
local function CreateTextureFunction(func)
	return function(self, ...)
		for i = 1, 4 do
			self._textures[i][func](self._textures[i], ...)
		end
		self._wedge[func](self._wedge, ...)
	end
end

-- Pass calls to these functions on our frame to its textures
local TextureFunctions = {
	SetTexture = CreateTextureFunction('SetTexture'),
	SetBlendMode = CreateTextureFunction('SetBlendMode'),
	SetVertexColor = CreateTextureFunction('SetVertexColor'),
}

local function CreateRadialStatusBar(parent)
	local bar = CreateFrame('Frame', nil, parent)

	local scrollframe = CreateFrame('ScrollFrame', nil, bar)
	scrollframe:SetPoint('BOTTOMLEFT', bar, 'CENTER')
	scrollframe:SetPoint('TOPRIGHT')
	bar._scrollframe = scrollframe

	local scrollchild = CreateFrame('frame', nil, scrollframe)
	scrollframe:SetScrollChild(scrollchild)
	scrollchild:SetAllPoints(scrollframe)

	local wedge = scrollchild:CreateTexture()
	wedge:SetPoint('BOTTOMRIGHT', bar, 'CENTER')
	bar._wedge = wedge

	-- Create quadrant textures
	local textures = {
		bar:CreateTexture(), -- Top Right
		bar:CreateTexture(), -- Bottom Right
		bar:CreateTexture(), -- Bottom Left
		bar:CreateTexture() -- Top Left
	}

	textures[1]:SetPoint('BOTTOMLEFT', bar, 'CENTER')
	textures[1]:SetPoint('TOPRIGHT')
	textures[1]:SetTexCoord(0.5, 1, 0, 0.5)

	textures[2]:SetPoint('TOPLEFT', bar, 'CENTER')
	textures[2]:SetPoint('BOTTOMRIGHT')
	textures[2]:SetTexCoord(0.5, 1, 0.5, 1)

	textures[3]:SetPoint('TOPRIGHT', bar, 'CENTER')
	textures[3]:SetPoint('BOTTOMLEFT')
	textures[3]:SetTexCoord(0, 0.5, 0.5, 1)

	textures[4]:SetPoint('BOTTOMRIGHT', bar, 'CENTER')
	textures[4]:SetPoint('TOPLEFT')
	textures[4]:SetTexCoord(0, 0.5, 0, 0.5)

	bar._textures = textures
	bar._quadrant = nil
	bar._clockwise = true
	bar._reverse = false
	bar._aspect = 1
	bar:HookScript('OnSizeChanged', OnSizeChanged)

	for method, func in pairs(TextureFunctions) do
		bar[method] = func
	end

	bar.SetRadialStatusBarValue = SetRadialStatusBarValue


	local group = wedge:CreateAnimationGroup()
	local rotation = group:CreateAnimation('Rotation')
	bar._rotation = rotation
	rotation:SetDuration(0)
	rotation:SetEndDelay(1)
	rotation:SetOrigin('BOTTOMRIGHT', 0, 0)
	group:SetScript('OnPlay', OnPlay)
	group:Play()

	return bar
end

T.CreateRadialStatusBar = CreateRadialStatusBar

----------------------------------------------------------------------------------------
--	Kill object function
----------------------------------------------------------------------------------------
local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()
T.Hider = HiddenFrame
local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(HiddenFrame)
	else
		object.Show = T.dummy
	end
	object:Hide()
end

----------------------------------------------------------------------------------------
--	Style ActionBars/Bags buttons function(by Chiril & Karudon)
----------------------------------------------------------------------------------------
local function SetButtonTexture(button, textureType, color, size, setBackdrop)
	local texture = button:CreateTexture()
	texture:SetColorTexture(unpack(color))
	if setBackdrop then
		texture:SetInside(button.backdrop)
	else
		texture:SetPoint("TOPLEFT", button, size, -size)
		texture:SetPoint("BOTTOMRIGHT", button, -size, size)
	end
	button[textureType] = texture
	button["Set" .. textureType .. "Texture"](button, texture)
end

local function StyleButton(button, t, size, setBackdrop)
	size = size or 2

	if button.SetHighlightTexture and not button.hover then
		SetButtonTexture(button, "Highlight", { 1, 1, 1, 0.3 }, size, setBackdrop)
		button.hover = button:GetHighlightTexture()
	end

	if not t and button.SetPushedTexture and not button.pushed then
		SetButtonTexture(button, "Pushed", { 0.9, 0.8, 0.1, 0.3 }, size, setBackdrop)
		button.pushed = button:GetPushedTexture()
	end

	if button.SetCheckedTexture and not button.checked then
		SetButtonTexture(button, "Checked", { 0, 1, 0, 0.3 }, size, setBackdrop)
		button.checked = button:GetCheckedTexture()
	end

	local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, size, -size)
		cooldown:SetPoint("BOTTOMRIGHT", button, -size, size)
	end
end

local function StyleActionButton(button, t, size, setBackdrop)
	size = size or 1

	if button.SetHighlightTexture and not button.hover then
		SetButtonTexture(button, "Highlight", { 1, 1, 1, 0.3 }, size, setBackdrop)
		button.hover = button:GetHighlightTexture()
	end

	if not t and button.SetPushedTexture and not button.pushed then
		SetButtonTexture(button, "Pushed", { 1, 1, 1, 0.3 }, size, setBackdrop)
		button.pushed = button:GetPushedTexture()
	end

	if button.SetCheckedTexture and not button.checked then
		SetButtonTexture(button, "Checked", { 0, 1, 0, 0.3 }, size, setBackdrop)
		button.checked = button:GetCheckedTexture()
	end

	local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, -size, size)
		cooldown:SetPoint("BOTTOMRIGHT", button, size, -size)
	end
end

----------------------------------------------------------------------------------------
--	Style buttons function
----------------------------------------------------------------------------------------
T.SetModifiedBackdrop = function(self)
	if self:IsEnabled() then
		self:SetBackdropBorderColor(unpack(C.media.classborder_color))
		if self.overlay then
			self.overlay:SetVertexColor(C.media.classborder_color[1] * 0.3, C.media.classborder_color[2] * 0.3,
				C.media.classborder_color[3] * 0.3, 1)
		end
	end
end

T.SetOriginalBackdrop = function(self)
	self:SetBackdropBorderColor(unpack(C.media.border_color))
	if self.overlay then
		self.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	end
end

local function SkinButton(f, strip)
	if strip then f:StripTextures() end

	if f.SetNormalTexture then f:SetNormalTexture(0) end
	if f.SetHighlightTexture then f:SetHighlightTexture(0) end
	if f.SetPushedTexture then f:SetPushedTexture(0) end
	if f.SetDisabledTexture then f:SetDisabledTexture(0) end

	if f.Left then f.Left:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end
	if f.Flash then f.Flash:SetAlpha(0) end

	if f.TopLeft then f.TopLeft:Hide() end
	if f.TopRight then f.TopRight:Hide() end
	if f.BottomLeft then f.BottomLeft:Hide() end
	if f.BottomRight then f.BottomRight:Hide() end
	if f.TopMiddle then f.TopMiddle:Hide() end
	if f.MiddleLeft then f.MiddleLeft:Hide() end
	if f.MiddleRight then f.MiddleRight:Hide() end
	if f.BottomMiddle then f.BottomMiddle:Hide() end
	if f.MiddleMiddle then f.MiddleMiddle:Hide() end
	if f.Background then f.Background:Hide() end

	f:SetTemplate("Overlay")
	f:HookScript("OnEnter", T.SetModifiedBackdrop)
	f:HookScript("OnLeave", T.SetOriginalBackdrop)
end

----------------------------------------------------------------------------------------
--	Style icon function
----------------------------------------------------------------------------------------
local function SkinIcon(icon, t, parent)
	parent = parent or icon:GetParent()

	if t then
		icon.b = CreateFrame("Frame", nil, parent)
		icon.b:SetTemplate("Default")
		icon.b:SetOutside(icon)
	else
		parent:CreateBackdrop("Default")
		parent.backdrop:SetOutside(icon)
	end

	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetParent(t and icon.b or parent)
end

local function CropIcon(icon)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetInside()
end

----------------------------------------------------------------------------------------
--	Font function
----------------------------------------------------------------------------------------
local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")

	if not name then
		parent.text = fs
	else
		parent[name] = fs
	end

	return fs
end

----------------------------------------------------------------------------------------
--	Fade in/out functions
----------------------------------------------------------------------------------------
local function FadeIn(f)
	UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

local function FadeOut(f)
	UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

local function addAPI(object)
	local mt = getmetatable(object).__index
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.CreateOverlay then mt.CreateOverlay = CreateOverlay end
	if not object.CreateBorder then mt.CreateBorder = CreateBorder end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreatePanel then mt.CreatePanel = CreatePanel end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.CreateRadialStatusBar then mt.CreateRadialStatusBar = CreateRadialStatusBar end
	if not object.SetRadialStatusBarValue then mt.SetRadialStatusBarValue = SetRadialStatusBarValue end
	if not object.Kill then mt.Kill = Kill end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.StyleActionButton then mt.StyleActionButton = StyleActionButton end
	if not object.SkinButton then mt.SkinButton = SkinButton end
	if not object.SkinIcon then mt.SkinIcon = SkinIcon end
	if not object.CropIcon then mt.CropIcon = CropIcon end
	if not object.FontString then mt.FontString = FontString end
	if not object.FadeIn then mt.FadeIn = FadeIn end
	if not object.FadeOut then mt.FadeOut = FadeOut end
end

local handled = { ["Frame"] = true }
local object = CreateFrame("Frame")
addAPI(object)
addAPI(object:CreateTexture())
addAPI(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addAPI(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

-- Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local scrollFrame = CreateFrame("ScrollFrame")
addAPI(scrollFrame)

----------------------------------------------------------------------------------------
--	Style functions
----------------------------------------------------------------------------------------
T.SkinFuncs = {}
T.SkinFuncs["TKUI"] = {}

function T.SkinScrollBar(frame, isMinimal)
	frame:StripTextures()

	local frameName = frame.GetName and frame:GetName()
	local UpButton = frame.ScrollUpButton or frame.ScrollUp or frame.UpButton or frame.Back or
		_G[frameName and frameName .. "ScrollUpButton"] or frame:GetParent().scrollUp
	local DownButton = frame.ScrollDownButton or frame.ScrollDown or frame.DownButton or frame.Forward or
		_G[frameName and frameName .. "ScrollDownButton"] or frame:GetParent().scrollDown
	local ThumbTexture = frame.ThumbTexture or frame.thumbTexture or _G[frameName and frameName .. "ThumbTexture"]
	local newThumb = frame.Back and frame:GetThumb()

	local minimal = isMinimal or frame.GetWidth and frame:GetWidth() < 10

	if UpButton and DownButton then
		if not UpButton.icon and not minimal then
			T.SkinNextPrevButton(UpButton, nil, "Up")
			UpButton:SetSize(UpButton:GetWidth() + 7, UpButton:GetHeight() + 7)
		end

		if not DownButton.icon and not minimal then
			T.SkinNextPrevButton(DownButton, nil, "Down")
			DownButton:SetSize(DownButton:GetWidth() + 7, DownButton:GetHeight() + 7)
		end

		if ThumbTexture then
			ThumbTexture:SetTexture(nil)
			if not frame.thumbbg then
				frame.thumbbg = CreateFrame("Frame", nil, frame)
				frame.thumbbg:SetPoint("TOPLEFT", ThumbTexture, "TOPLEFT", 0, -3)
				frame.thumbbg:SetPoint("BOTTOMRIGHT", ThumbTexture, "BOTTOMRIGHT", 0, 3)
				frame.thumbbg:SetTemplate("Overlay")

				frame:HookScript("OnShow", function()
					local _, maxValue = frame:GetMinMaxValues()
					if maxValue == 0 then
						frame:SetAlpha(0)
					else
						frame:SetAlpha(1)
					end
				end)

				frame:HookScript("OnMinMaxChanged", function()
					local _, maxValue = frame:GetMinMaxValues()
					if maxValue == 0 then
						frame:SetAlpha(0)
					else
						frame:SetAlpha(1)
					end
				end)

				frame:HookScript("OnDisable", function()
					frame:SetAlpha(0)
				end)

				frame:HookScript("OnEnable", function()
					frame:SetAlpha(1)
				end)
			end
		elseif newThumb then
			if frame.Background then
				frame.Background:Hide()
			end
			if frame.Track then
				frame.Track:DisableDrawLayer("ARTWORK")
			end
			newThumb:DisableDrawLayer("BACKGROUND")
			newThumb:DisableDrawLayer("ARTWORK")
			if not frame.thumbbg then
				frame.thumbbg = CreateFrame("Frame", nil, newThumb)
				frame.thumbbg:SetPoint("TOPLEFT", newThumb, "TOPLEFT", 0, -3)
				frame.thumbbg:SetPoint("BOTTOMRIGHT", newThumb, "BOTTOMRIGHT", 0, 3)
				frame.thumbbg:SetTemplate("Overlay")

				if not newThumb:IsShown() then
					frame:SetAlpha(0)
				end

				hooksecurefunc(newThumb, "Hide", function(self)
					frame:SetAlpha(0)
				end)

				hooksecurefunc(newThumb, "Show", function(self)
					frame:SetAlpha(1)
				end)

				hooksecurefunc(newThumb, "SetShown", function(self, showThumb)
					if showThumb then
						frame:SetAlpha(1)
					else
						frame:SetAlpha(0)
					end
				end)
			end

			if minimal then
				-- UpButton:SetSize(14, 14)
				-- DownButton:SetSize(14, 14)
				newThumb:SetWidth(10)
			end
		end
	end
end

local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

function T.SkinTab(tab, bg)
	if not tab then return end

	for _, object in pairs(tabs) do
		local tex = tab:GetName() and _G[tab:GetName() .. object]
		if tex then
			tex:SetTexture(nil)
		end
	end

	if tab.GetHighlightTexture and tab:GetHighlightTexture() then
		tab:GetHighlightTexture():SetTexture(nil)
	else
		tab:StripTextures()
	end

	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	if bg then
		tab.backdrop:SetTemplate("Overlay")
		tab.backdrop:SetPoint("TOPLEFT", 2, -9)
		tab.backdrop:SetPoint("BOTTOMRIGHT", -2, -2)
	else
		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:SetPoint("TOPLEFT", 0, -3)
		tab.backdrop:SetPoint("BOTTOMRIGHT", 0, 3)
	end
end

function T.SkinNextPrevButton(btn, left, scroll)
	local normal, pushed, disabled
	local frameName = btn.GetName and btn:GetName()
	local isPrevButton = frameName and
		(string.find(frameName, "Left") or string.find(frameName, "Prev") or string.find(frameName, "Decrement") or string.find(frameName, "Back")) or
		left
	local isScrollUpButton = frameName and string.find(frameName, "ScrollUp") or scroll == "Up"
	local isScrollDownButton = frameName and string.find(frameName, "ScrollDown") or scroll == "Down"

	if btn:GetNormalTexture() then
		normal = btn:GetNormalTexture():GetTexture()
	end

	if btn:GetPushedTexture() then
		pushed = btn:GetPushedTexture():GetTexture()
	end

	if btn:GetDisabledTexture() then
		disabled = btn:GetDisabledTexture():GetTexture()
	end

	btn:StripTextures()

	if btn.Texture then
		btn.Texture:SetAlpha(0)

		if btn.Overlay then
			btn.Overlay:SetAlpha(0)
		end
	end

	if scroll == "Up" or scroll == "Down" or scroll == "Any" then
		normal = nil
		pushed = nil
		disabled = nil
	end

	if not normal then
		if isPrevButton then
			normal = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
		elseif isScrollUpButton then
			normal = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up"
		elseif isScrollDownButton then
			normal = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"
		else
			normal = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"
		end
	end

	if not pushed then
		if isPrevButton then
			pushed = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down"
		elseif isScrollUpButton then
			pushed = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down"
		elseif isScrollDownButton then
			pushed = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down"
		else
			pushed = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down"
		end
	end

	if not disabled then
		if isPrevButton then
			disabled = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled"
		elseif isScrollUpButton then
			disabled = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled"
		elseif isScrollDownButton then
			disabled = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled"
		else
			disabled = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled"
		end
	end

	btn:SetNormalTexture(normal)
	btn:SetPushedTexture(pushed)
	btn:SetDisabledTexture(disabled)

	btn:SetTemplate("Overlay")
	btn:SetSize(btn:GetWidth() - 7, btn:GetHeight() - 7)

	if normal and pushed and disabled then
		btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)
		if btn:GetPushedTexture() then
			btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.81, 0.65, 0.35, 0.65, 0.81)
		end
		if btn:GetDisabledTexture() then
			btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
		end

		btn:GetNormalTexture():ClearAllPoints()
		btn:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
		btn:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
		if btn:GetDisabledTexture() then
			btn:GetDisabledTexture():SetAllPoints(btn:GetNormalTexture())
		end
		if btn:GetPushedTexture() then
			btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
		end
		if btn:GetHighlightTexture() then
			btn:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
			btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
		end
	end
end

function T.SkinRotateButton(btn)
	btn:SetTemplate("Default")
	btn:SetSize(btn:GetWidth() - 14, btn:GetHeight() - 14)

	btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)
	btn:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	btn:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)

	btn:GetNormalTexture():ClearAllPoints()
	btn:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
	btn:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
	btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end

function T.SkinEditBox(frame, width, height)
	frame:DisableDrawLayer("BACKGROUND")

	frame:CreateBackdrop("Overlay")

	local frameName = frame.GetName and frame:GetName()
	if frameName and (frameName:find("Gold") or frameName:find("Silver") or frameName:find("Copper")) then
		if frameName:find("Gold") then
			frame.backdrop:SetPoint("TOPLEFT", -3, 1)
			frame.backdrop:SetPoint("BOTTOMRIGHT", -3, 0)
		else
			frame.backdrop:SetPoint("TOPLEFT", -3, 1)
			frame.backdrop:SetPoint("BOTTOMRIGHT", -13, 0)
		end
	end

	if width then frame:SetWidth(width) end
	if height then frame:SetHeight(height) end
end

function T.SkinDropDownBox(frame, width, pos)
	if frame.Arrow then
		frame.Background:SetTexture(nil)
		frame:CreateBackdrop("Overlay")
		frame.backdrop:SetPoint("TOPLEFT", -2, -1)
		frame.backdrop:SetPoint("BOTTOMRIGHT", 0, 1)
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame.Arrow:SetAlpha(0)

		local tex = frame:CreateTexture(nil, "ARTWORK")
		tex:SetPoint("RIGHT", frame, -4, 0)
		tex:SetSize(15, 15)
		tex:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
		tex:SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)

		local f = CreateFrame("Frame", nil, frame)
		f:SetOutside(tex)
		f:SetTemplate("Default")
		tex:SetParent(f)
		return
	end

	local frameName = frame.GetName and frame:GetName()
	local button = frame.Button or frameName and (_G[frameName .. "Button"] or _G[frameName .. "_Button"])
	local text = frameName and _G[frameName .. "Text"] or frame.Text
	if not width then width = 155 end

	frame:StripTextures()
	frame:SetWidth(width)

	if text then
		text:ClearAllPoints()
		text:SetPoint("RIGHT", button, "LEFT", -2, 0)
	end

	button:ClearAllPoints()
	if pos then
		button:SetPoint("TOPRIGHT", frame.Right, -20, -21)
	else
		button:SetPoint("RIGHT", frame, "RIGHT", -10, 3)
	end
	button.SetPoint = T.dummy
	T.SkinNextPrevButton(button, nil, "Down")

	frame:CreateBackdrop("Overlay")
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	frame.backdrop:SetPoint("TOPLEFT", 20, -2)
	frame.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
end

function T.SkinCheckBox(frame, size)
	if size then
		frame:SetSize(size, size)
	end
	frame:SetNormalTexture(0)
	frame:SetPushedTexture(0)
	frame:CreateBackdrop("Overlay")
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	frame.backdrop:SetPoint("TOPLEFT", 4, -4)
	frame.backdrop:SetPoint("BOTTOMRIGHT", -4, 4)

	if frame.SetHighlightTexture then
		local highligh = frame:CreateTexture()
		highligh:SetColorTexture(1, 1, 1, 0.3)
		highligh:SetPoint("TOPLEFT", frame, 6, -6)
		highligh:SetPoint("BOTTOMRIGHT", frame, -6, 6)
		frame:SetHighlightTexture(highligh)
	end

	if frame.SetCheckedTexture then
		local checked = frame:CreateTexture()
		checked:SetColorTexture(1, 0.82, 0, 0.8)
		checked:SetPoint("TOPLEFT", frame, 6, -6)
		checked:SetPoint("BOTTOMRIGHT", frame, -6, 6)
		frame:SetCheckedTexture(checked)
	end

	if frame.SetDisabledCheckedTexture then
		local disabled = frame:CreateTexture()
		disabled:SetColorTexture(0.6, 0.6, 0.6, 0.75)
		disabled:SetPoint("TOPLEFT", frame, 6, -6)
		disabled:SetPoint("BOTTOMRIGHT", frame, -6, 6)
		frame:SetDisabledCheckedTexture(disabled)
	end
end

function T.SkinCheckBoxAtlas(checkbox, size)
	if size then
		checkbox:SetSize(size, size)
	end

	checkbox:CreateBackdrop("Overlay")
	checkbox.backdrop:SetInside(nil, 4, 4)

	for _, region in next, { checkbox:GetRegions() } do
		if region:IsObjectType("Texture") then
			if region:GetAtlas() == "checkmark-minimal" or region:GetTexture() == 130751 then
				region:SetTexture(C.media.texture)

				local checkedTexture = checkbox:GetCheckedTexture()
				checkedTexture:SetColorTexture(1, 0.82, 0, 0.8)
				checkedTexture:SetInside(checkbox.backdrop)
			else
				region:SetTexture("")
			end
		end
	end
end

function T.SkinCloseButton(f, point, text, pixel)
	f:StripTextures()
	f:SetTemplate("Overlay")
	f:SetSize(18, 18)

	if not text then text = "x" end
	if text == "-" and not pixel then
		f.text = f:CreateTexture(nil, "OVERLAY")
		f.text:SetSize(7, 1)
		f.text:SetPoint("CENTER")
		f.text:SetTexture(C.media.blank)
	end
	if text == "-" and pixel then
		f.text = f:CreateTexture(nil, "OVERLAY")
		f.text:SetSize(5, 1)
		f.text:SetPoint("CENTER")
		f.text:SetTexture(C.media.blank)
	end
	if not f.text then
		if pixel then
			f.text = f:FontString(nil, [[Interface\AddOns\TKUI\Media\Fonts\Pixel.ttf]], 8)
			f.text:SetPoint("CENTER", 0, 0)
		else
			f.text = f:FontString(nil, C.media.normal_font, 17)
			f.text:SetPoint("CENTER", 0, 1)
		end
		f.text:SetText(text)
	end

	if point then
		f:SetPoint("TOPRIGHT", point, "TOPRIGHT", -4, -4)
	else
		f:SetPoint("TOPRIGHT", -4, -4)
	end

	f:HookScript("OnEnter", T.SetModifiedBackdrop)
	f:HookScript("OnLeave", T.SetOriginalBackdrop)
end

function T.SkinSlider(f)
	f:StripTextures()

	local bd = CreateFrame("Frame", nil, f)
	bd:SetTemplate("Overlay")
	if f:GetOrientation() == "VERTICAL" then
		bd:SetPoint("TOPLEFT", -2, -6)
		bd:SetPoint("BOTTOMRIGHT", 2, 6)
		f:GetThumbTexture():SetRotation(rad(90))
	else
		bd:SetPoint("TOPLEFT", 14, -2)
		bd:SetPoint("BOTTOMRIGHT", -15, 3)
	end
	bd:SetFrameLevel(f:GetFrameLevel() - 1)

	f:SetThumbTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	f:GetThumbTexture():SetBlendMode("ADD")
end

function T.SkinSliderStep(frame, minimal)
	frame:StripTextures()

	local slider = frame.Slider
	if not slider then return end

	slider:DisableDrawLayer("ARTWORK")

	local thumb = slider.Thumb
	if thumb then
		thumb:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		thumb:SetBlendMode("ADD")
		thumb:SetSize(20, 30)
	end

	local offset = minimal and 10 or 13
	slider:CreateBackdrop("Overlay")
	slider.backdrop:SetPoint("TOPLEFT", 10, -offset)
	slider.backdrop:SetPoint("BOTTOMRIGHT", -10, offset)

	if not slider.barStep then
		local step = CreateFrame("StatusBar", nil, slider.backdrop)
		step:SetStatusBarTexture(C.media.texture)
		step:SetStatusBarColor(1, 0.82, 0, 1)
		step:SetPoint("TOPLEFT", slider.backdrop, T.mult * 2, -T.mult * 2)
		step:SetPoint("BOTTOMLEFT", slider.backdrop, T.mult * 2, T.mult * 2)
		step:SetPoint("RIGHT", thumb, "CENTER")

		slider.barStep = step
	end
end

function T.SkinIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	local frameName = frameNameOverride or frame:GetName()
	-- local scrollFrame = frame.ScrollFrame or _G[frameName.."ScrollFrame"]
	local editBox = frame.BorderBox.IconSelectorEditBox
	local okayButton = frame.OkayButton or frame.BorderBox.OkayButton or _G[frameName .. "Okay"]
	local cancelButton = frame.CancelButton or frame.BorderBox.CancelButton or _G[frameName .. "Cancel"]

	frame:StripTextures()
	frame.BorderBox:StripTextures()
	frame:CreateBackdrop("Transparent")
	frame.backdrop:SetPoint("TOPLEFT", 3, 1)
	frame:SetHeight(frame:GetHeight() + 13)

	T.SkinScrollBar(frame.IconSelector.ScrollBar)

	okayButton:SkinButton()
	cancelButton:SkinButton()
	cancelButton:ClearAllPoints()
	cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)

	editBox:DisableDrawLayer("BACKGROUND")
	T.SkinEditBox(editBox)

	local button = frame.BorderBox.SelectedIconArea and frame.BorderBox.SelectedIconArea.SelectedIconButton
	if button then
		button:DisableDrawLayer("BACKGROUND")
		local texture = button.Icon:GetTexture()
		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate("Default")

		button.Icon:ClearAllPoints()
		button.Icon:SetPoint("TOPLEFT", 2, -2)
		button.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		if texture then
			button.Icon:SetTexture(texture)
		end
	end

	for _, button in next, { frame.IconSelector.ScrollBox.ScrollTarget:GetChildren() } do
		local texture = button.Icon:GetTexture()
		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate("Default")

		button.Icon:ClearAllPoints()
		button.Icon:SetPoint("TOPLEFT", 2, -2)
		button.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		if texture then
			button.Icon:SetTexture(texture)
		end
	end

	local dropdown = frame.BorderBox.IconTypeDropDown and frame.BorderBox.IconTypeDropDown.DropDownMenu
	if dropdown then
		T.SkinDropDownBox(dropdown)
	end
end

function T.SkinMaxMinFrame(frame, point)
	frame:SetSize(18, 18)

	if point then
		frame:SetPoint("RIGHT", point, "LEFT", -2, 0)
	end

	for name, direction in pairs({ ["MaximizeButton"] = "up", ["MinimizeButton"] = "down" }) do
		local button = frame[name]
		if button then
			button:StripTextures()
			button:SetTemplate("Overlay")
			button:SetPoint("CENTER")
			button:SetHitRectInsets(1, 1, 1, 1)

			button.minus = button:CreateTexture(nil, "OVERLAY")
			button.minus:SetSize(7, 1)
			button.minus:SetPoint("CENTER")
			button.minus:SetTexture(C.media.blank)

			if direction == "up" then
				button.plus = button:CreateTexture(nil, "OVERLAY")
				button.plus:SetSize(1, 7)
				button.plus:SetPoint("CENTER")
				button.plus:SetTexture(C.media.blank)
			end

			button:HookScript("OnEnter", T.SetModifiedBackdrop)
			button:HookScript("OnLeave", T.SetOriginalBackdrop)
		end
	end
end

function T.SkinExpandOrCollapse(f)
	f:SetHighlightTexture(0)
	f:SetPushedTexture(0)

	local bg = CreateFrame("Frame", nil, f)
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", f:GetNormalTexture(), 0, -1)
	bg:SetTemplate("Overlay")
	f.bg = bg

	bg.minus = bg:CreateTexture(nil, "OVERLAY")
	bg.minus:SetSize(5, 1)
	bg.minus:SetPoint("CENTER")
	bg.minus:SetTexture(C.media.blank)

	bg.plus = bg:CreateTexture(nil, "OVERLAY")
	bg.plus:SetSize(1, 5)
	bg.plus:SetPoint("CENTER")
	bg.plus:SetTexture(C.media.blank)
	bg.plus:Hide()

	hooksecurefunc(f, "SetNormalTexture", function(self, texture)
		if self.settingTexture then return end
		self.settingTexture = true
		self:SetNormalTexture(0)

		if texture and texture ~= "" then
			if texture:find("Plus") then
				self.bg.plus:Show()
			elseif texture:find("Minus") then
				self.bg.plus:Hide()
			end
			self.bg:Show()
		else
			self.bg:Hide()
		end
		self.settingTexture = nil
	end)

	f:HookScript("OnEnter", function(self)
		self.bg:SetBackdropBorderColor(unpack(C.media.classborder_color))
		if self.bg.overlay then
			self.bg.overlay:SetVertexColor(C.media.classborder_color[1] * 0.3, C.media.classborder_color[2] * 0.3,
				C.media.classborder_color[3] * 0.3, 1)
		end
	end)

	f:HookScript("OnLeave", function(self)
		self.bg:SetBackdropBorderColor(unpack(C.media.border_color))
		if self.bg.overlay then
			self.bg.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
		end
	end)
end

function T.SkinHelpBox(frame)
	frame:StripTextures()
	frame:SetTemplate("Transparent")
	if frame.CloseButton then
		T.SkinCloseButton(frame.CloseButton)
	end
	if frame.Arrow then
		frame.Arrow:Hide()
	end
end

function T.SkinFrame(frame, backdrop, x, y)
	local name = frame and frame.GetName and frame:GetName()
	local portraitFrame = name and _G[name .. "Portrait"] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name .. "PortraitOverlay"] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name .. "ArtOverlayFrame"] or frame.ArtOverlayFrame

	frame:StripTextures()
	if backdrop then
		frame:CreateBackdrop("Transparent")
		if x and y then
			frame.backdrop:SetPoint("TOPLEFT", x, -y)
			frame.backdrop:SetPoint("BOTTOMRIGHT", -x, y)
		end
	else
		frame:SetTemplate("Transparent")
	end

	if frame.CloseButton then
		T.SkinCloseButton(frame.CloseButton)
	end

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end
end

local iconColors = {
	["uncollected"] = { r = borderr, g = borderg, b = borderb },
	["gray"]        = { r = borderr, g = borderg, b = borderb },
	["white"]       = { r = borderr, g = borderg, b = borderb },
	["green"]       = BAG_ITEM_QUALITY_COLORS[2],
	["blue"]        = BAG_ITEM_QUALITY_COLORS[3],
	["purple"]      = BAG_ITEM_QUALITY_COLORS[4],
	["orange"]      = BAG_ITEM_QUALITY_COLORS[5],
	["artifact"]    = BAG_ITEM_QUALITY_COLORS[6],
	["account"]     = BAG_ITEM_QUALITY_COLORS[7]
}

function T.SkinIconBorder(frame, parent)
	local border = parent or frame:GetParent().backdrop
	frame:SetAlpha(0)
	hooksecurefunc(frame, "SetVertexColor", function(self, r, g, b)
		if r ~= BAG_ITEM_QUALITY_COLORS[1].r ~= r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
			border:SetBackdropBorderColor(r, g, b)
		else
			border:SetBackdropBorderColor(unpack(C.media.border_color))
		end
	end)

	hooksecurefunc(frame, "SetAtlas", function(self, atlas)
		local atlasAbbr = atlas and strmatch(atlas, "%-(%w+)$")
		local color = atlasAbbr and iconColors[atlasAbbr]
		if color then
			border:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	hooksecurefunc(frame, "Hide", function(self)
		border:SetBackdropBorderColor(unpack(C.media.border_color))
	end)

	hooksecurefunc(frame, "SetShown", function(self, show)
		if not show then
			border:SetBackdropBorderColor(unpack(C.media.border_color))
		end
	end)
end

function T.ReplaceIconString(frame, text)
	if not text then text = frame:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
	if count > 0 then frame:SetFormattedText("%s", newText) end
end

local LoadBlizzardSkin = CreateFrame("Frame")
LoadBlizzardSkin:RegisterEvent("ADDON_LOADED")
LoadBlizzardSkin:SetScript("OnEvent", function(self, _, addon)
	for _addon, skinfunc in pairs(T.SkinFuncs) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(T.SkinFuncs[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end)

function T.SkinModelControl(frame)
	for i = 1, 5 do
		local button = select(i, frame.ControlFrame:GetChildren())
		if button.NormalTexture then
			button.NormalTexture:SetAlpha(0)
			button.PushedTexture:SetAlpha(0)
		end
	end
end
