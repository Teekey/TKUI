local E, L, V, P, G = unpack(ElvUI);
local MyPluginName = "RetroUI"
local RetroUI = E:GetModule(MyPluginName);



--Cache global variables
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: AddOnSkinsDB, LibStub
function RetroUI:LoadAddOnSkinsProfile()
    
        --    AddonSkins - Settings

		
if AddOnSkinsDB["profiles"]["RetroUI"] == nil then AddOnSkinsDB["profiles"]["RetroUI"] = {} end
		
		-- defaults
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeft'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeft'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedMain'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedRight'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystem'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystemDual'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['ParchmentRemover'] = true
		AddOnSkinsDB["profiles"]["RetroUI"]['TransparentEmbed'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['DBMSkinHalf'] = true
		
		--   Embeded settings  	--
	if IsAddOnLoaded("Skada") then
		AddOnSkinsDB["profiles"]["RetroUI"]['SkadaBackdrop'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedFrameStrata'] = "2-LOW"
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedBelowTop'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeft'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedMain'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedRight'] = 'Skada'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystem'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystemDual'] = true
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeftWidth'] = 184
		AddOnSkinsDB["profiles"]["RetroUI"]['TransparentEmbed'] = true
	end

	if IsAddOnLoaded("Details") then
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedFrameStrata'] = "2-LOW"
		AddOnSkinsDB["profiles"]["RetroUI"]['DetailsBackdrop'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedBelowTop'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeft'] = 'Details'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedMain'] = 'Details'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedRight'] = 'Details'
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystem'] = false
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedSystemDual'] = true
		AddOnSkinsDB["profiles"]["RetroUI"]['EmbedLeftWidth'] = 184
		AddOnSkinsDB["profiles"]["RetroUI"]['TransparentEmbed'] = true
	end

	if IsAddOnLoaded("DBM-Core") then
		AddOnSkinsDB["profiles"]["RetroUI"]['DBMFont'] = 'Florence Sans'
		AddOnSkinsDB["profiles"]["RetroUI"]['DBMFontSize'] = 13
		AddOnSkinsDB["profiles"]["RetroUI"]['DBMRadarTrans'] = true
	end
	
        -- Profile creation
        local db = LibStub("AceDB-3.0"):New(AddOnSkinsDB)
        db:SetProfile("RetroUI")
    end
	