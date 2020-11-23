local E, L, V, P, G = unpack(ElvUI)
local TKUIPlugin = "|cFFff8c00TK|r|cFFFFFFFFUI|r"
local TKUI = E:GetModule(TKUIPlugin);

if E.db.TKUI == nil then E.db.TKUI = {} end
local format = string.format
local tinsert, tsort, tconcat = table.insert, table.sort, table.concat


local function Core()
	E.Options.args.TKUI = {
		order = 9000,
		type = 'group',
		name = TKUI.Title,
		args = {
			name = {
				order = 1,
				type = 'header',
				name = TKUI.Title..TKUI:cOption(TKUI.Version)..L['by MaximumOverdrive (NA-Area 52)'],
			},
			logo = {
				order = 2,
				type = 'description',
				name = L['TKUI is a completely external ElvUI mod. Changes can be made in the ElvUI options (e.g. Actionbars, Unitframes, Player and Target Portraits).'],
				fontSize = 'medium',
				image = function() return 'Interface\\AddOns\\ElvUI_TKUI\\media\\textures\\TKUI.tga', 256, 128 end,
			},
			install = {
				order = 3,
				type = 'execute',
				name = L['Install'],
				desc = L['Run the installation process.'],
				func = function() E:GetModule("PluginInstaller"):Queue(TKUI.TKUIInstallTable); E:ToggleOptionsUI() end,
			},
			spacer2 = {
				order = 4,
				type = 'header',
				name = '',
			},
			info = {
				order = 2000,
				type = 'group',
				name = L['Information'],
				args = {
					name = {
						order = 1,
						type = 'header',
						name = TKUI.Title,
					},
					support = {
						order = 2,
						type = 'group',
						name = TKUI:cOption(L['Support']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'execute',
								name = L['Tukui.org'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "http://www.tukui.org/addons/index.php?act=view&id=228") end,
								},
							git = {
								order = 2,
								type = 'execute',
								name = L['Git Ticket tracker'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "https://git.tukui.org/Benik/ElvUI_TKUI/issues") end,
							},
							discord = {
								order = 3,
								type = 'execute',
								name = L['Discord Server'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "https://discord.gg/8ZDDUem") end,
							},
						},
					},
					download = {
						order = 3,
						type = 'group',
						name = TKUI:cOption(L['Download']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'execute',
								name = L['Tukui.org'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=94") end,
							},
							curse = {
								order = 2,
								type = 'execute',
								name = L['CurseForge.com'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "https://www.curseforge.com/wow/addons/mog-ui") end,
							},
							wowint = {
								order = 3,
								type = 'execute',
								name = L['WoW Interface'],
								func = function() StaticPopup_Show("TKUI_CREDITS", nil, nil, "http://www.wowinterface.com/downloads/info24573-TKUI.html") end,
							},
						},
					},
					coding = {
						order = 4,
						type = 'group',
						name = TKUI:cOption(L['Coding']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'description',
								fontSize = 'medium',
								name = format('|cffffd200%s|r', 'Elv, Tukz, Blazeflack, Azilroka, Benik, Merathilis, Simpy'),
							},
						},
					},
					testing = {
						order = 5,
						type = 'group',
						name = TKUI:cOption(L['Testing & Inspiration']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'description',
								fontSize = 'medium',
								name = format('|cffffd200%s|r', 'Benik, Merathilis, Klix, ElvUI community'),
							},
						},
					},
				},
			},
		},
	}
end
tinsert(TKUI.Config, Core)
