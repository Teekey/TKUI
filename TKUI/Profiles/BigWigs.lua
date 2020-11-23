local E, L, V, P, G = unpack(ElvUI);
local MyPluginName = "RetroUI"
local RetroUI = E:GetModule(MyPluginName);


local profileName = "RetroUI"

--Cache global variables
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: BigWigs3DB, LibStub

function RetroUI:LoadBigWigsProfile()

		--	BigWigs - Settings
			BigWigs3DB = {
				["namespaces"] = {
		["BigWigs_Plugins_Victory"] = {
		},
		["BigWigs_Plugins_Alt Power"] = {
			["profiles"] = {
				["RetroUI"] = {
					["posx"] = 283.7336850643078,
					["fontName"] = "Florence Sans",
					["font"] = "Friz Quadrata TT",
					["posy"] = 435.9101855691479,
					["fontOutline"] = "OUTLINE",
				},
			},
		},
		["LibDualSpec-1.0"] = {
		},
		["BigWigs_Plugins_Sounds"] = {
		},
		["BigWigs_Plugins_Statistics"] = {
		},
		["BigWigs_Plugins_Colors"] = {
		},
		["BigWigs_Plugins_Raid Icons"] = {
		},
		["BigWigs_Plugins_InfoBox"] = {
			["profiles"] = {
				["RetroUI"] = {
					["posx"] = 460.0887787787142,
					["posy"] = 382.5780773862134,
				},
			},
		},
		["BigWigs_Plugins_Bars"] = {
			["profiles"] = {
				["RetroUI"] = {
					["outline"] = "OUTLINE",
					["BigWigsAnchor_width"] = 196.9998931884766,
					["BigWigsEmphasizeAnchor_height"] = 22.00000953674316,
					["fontName"] = "Florence Sans",
					["BigWigsAnchor_height"] = 20.00000381469727,
					["fontSize"] = 13,
					["BigWigsAnchor_y"] = 14.88909390548406,
					["emphasizeGrowup"] = true,
					["texture"] = "Mogchamp",
					["barStyle"] = "MonoUI",
					["BigWigsAnchor_x"] = 292.9774153264443,
					["BigWigsEmphasizeAnchor_y"] = 239.444330585502,
					["monochrome"] = false,
					["fontSizeEmph"] = 15,
					["BigWigsEmphasizeAnchor_x"] = 620.0888533274338,
					["emphasizeTime"] = 8,
					["BigWigsEmphasizeAnchor_width"] = 195.0002899169922,
				},
			},
		},
		["BigWigs_Plugins_Super Emphasize"] = {
			["profiles"] = {
				["RetroUI"] = {
					["outline"] = "OUTLINE",
					["fontName"] = "Florence Sans",
					["font"] = "Friz Quadrata TT",
					["fontSize"] = 52,
				},
			},
		},
		["BigWigs_Plugins_Wipe"] = {
		},
		["BigWigs_Plugins_AutoReply"] = {
		},
		["BigWigs_Plugins_BossBlock"] = {
		},
		["BigWigs_Plugins_Respawn"] = {
		},
		["BigWigs_Plugins_Proximity"] = {
			["profiles"] = {
				["RetroUI"] = {
					["fontSize"] = 15,
					["posy"] = 86.75601368585194,
					["fontName"] = "Florence Sans",
					["width"] = 124.4444961547852,
					["font"] = "Expressway",
					["posx"] = 831.2892782942363,
					["lock"] = false,
					["height"] = 99.99993896484375,
					["sound"] = true,
				},
			},
		},
		["BigWigs_Plugins_Pull"] = {
		},
		["BigWigs_Plugins_Messages"] = {
			["profiles"] = {
				["RetroUI"] = {
					["outline"] = "OUTLINE",
					["BWEmphasizeCountdownMessageAnchor_x"] = 666.311083842647,
					["BWMessageAnchor_y"] = 457.244498919117,
					["BWMessageAnchor_x"] = 615.11112600565,
					["fontName"] = "Florence Sans",
					["BWEmphasizeCountdownMessageAnchor_y"] = 529.777790606022,
					["font"] = "Friz Quadrata TT",
				},
			},
		},
		["BigWigs_Plugins_Pull"] = {
		},
		["LibDualSpec-1.0"] = {
		},
	},
}
		
		BigWigsIconDB = {
			["hide"] = true,
		}
		BigWigs3IconDB = nil
		BigWigsStatsDB = {
		}
		BigWigsStatisticsDB = nil
		
		-- Profile creation
		local db = LibStub("AceDB-3.0"):New(BigWigs3DB)
		db:SetProfile(profileName)
	end
