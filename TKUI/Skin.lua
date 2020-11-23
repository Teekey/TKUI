local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"
--Masque Skin
local MSQ = LibStub('Masque', true)
if not MSQ then return end

MSQ:AddSkin('TKUI', {
	Author = 'Teekey',
	Version = '1.0',
	Masque_Version = 90001,
	Shape = 'Square',
	Description = "TKUI Masque Skin",
	Backdrop = {
		Width = 44,
		Height = 30,
		Color = {0, 0, 0, 0.75},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\No_Backdrop]],
	},
	Icon = {
		Width = 40,
		Height = 28,
		TexCoords = {0.07,0.93,0.2,0.8},
	},
	Flash = {
		Width = 44,
		Height = 30,
		Color = {1, 1, 1, 0.5},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Flash]],
	},
	Cooldown = {
		Width = 44,
		Height = 30,
		Color = {0, 0, 0, 0.75},
	},
	Pushed = {
		Width = 44,
		Height = 30,
		BlendMode = 'ADD',
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Highlight]],
	},
	Normal = {
		Width = 44,
		Height = 30,
		Color = {0, 0, 0, 1},
		BlendMode = 'BLEND',
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Normal]],

	},
	Checked = {
		Width = 44,
		Height = 30,
		BlendMode = 'ADD',
		Color = {1, 204/255, 0, 0.4},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Checked]],
	},
	Border = { -- Item Quality
		Hide = true,
	},
	Gloss = {
		Width = 44,
		Height = 30,
		BlendMode = 'ADD',
		Color = {1, 1, 1, 0.6},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Gloss]],
	},
	AutoCastable = {
		Width = 65,
		Height = 65,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 44,
		Height = 30,
		BlendMode = 'ADD',
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Highlight]],
	},
	Glow = {
		Width = 44,
		Height = 30,
	},
	AutoCastable = {
		Width = 44,
		Height = 30,
	},
	Shine = {
		Width = 44,
		Height = 30,
	},
	-- SlotHighlight
	SpellHighlight = {
		Width = 44,
		Height = 30,
		BlendMode = 'BLEND',
		Color = {1, 204/255, 0, 1},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Highlight]],
	},
	NewAction = {
		Width = 44,
		Height = 30,
		BlendMode = 'BLEND',
		Color = {1, 204/255, 0, 1},
		Texture = [[Interface\AddOns\TKUI\Media\Textures\Highlight]],
	},
	Name = { -- Macro name for action bar slots.
		JustifyH = "LEFT",
		JustifyV = "TOP",
		Width = 28,
		Height = 10,
		DrawLayer = "OVERLAY",
		DrawLevel = 10,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 0.5,
		OffsetY = -1,
	},
	Count = {
		JustifyH = "RIGHT",
		JustifyV = "BOTTOM",
		Width = 30,
		Height = 10,
		DrawLayer = "OVERLAY",
		DrawLevel = 10,
		Point = "BOTTOMRIGHT",
		RelPoint = "BOTTOMRIGHT",
		OffsetX = 3,
		OffsetY = 3,
	},
	HotKey = {
		JustifyH = "RIGHT",
		JustifyV = "TOP",
		Width = 30,
		Height = 10,
		DrawLayer = "OVERLAY",
		DrawLevel = 10,
		Point = "TOPRIGHT",
		RelPoint = "TOPRIGHT",
		OffsetX = 0.5,
		OffsetY = -1,
	},
	Duration = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		Width = 36,
		Height = 10,
		Point = "TOP",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = -2
,
	},
	AutoCastShine = {
		Width = 34,
		Height = 34,
		OffsetX = 1,
		OffsetY = -1,
	},
}, true)
