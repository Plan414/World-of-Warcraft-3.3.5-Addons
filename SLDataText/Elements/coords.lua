--[[ 		    SLDataText Module: Coords 				]]
--[[ Author: Taffu  RevDate: 04/04/2012  Version: 5.0.0 ]]

local SLDT, MODNAME, SML, SLC = SLDataText, "Coords", LibStub("LibSharedMedia-3.0"), LibStub("LibSL-1.0")
if ( SLDT ) then SLDT.Coords = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

function SLDT.Coords:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		frame:SetScript("OnUpdate", function() SLDT.Coords:Refresh() end)
	end
	self:Refresh()
end

function SLDT.Coords:Disable()
	if ( not db.enabled ) then
		frame:SetScript("OnUpdate", nil)
	end
	self:Refresh()
end

function SLDT.Coords:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		local posX, posY = GetPlayerMapPosition("player")
		text:SetFormattedText("%."..db.precision.."f, %."..db.precision.."f", posX*100, posY*100)
		
		SLDT:UpdateBaseFrame(SLDT.Coords, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Coords.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "range", [2] = L["Precision"], [3] = "precision", [4] = 0, [5] = 2, [6] = 1 },
	[6] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[7] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[8] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[9] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[10] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[11] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[12] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[13] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Coords.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Coords.db:RegisterDefaults({
        profile = {
			name = "Coords",
			enabled = true,
			precision = 0,
			forceShow = true,
			aP = "CENTER",
			anch = "Minimap",
			aF = "BOTTOM",
			xOff = 0,
			yOff = 16,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = false,
        },
    })
	db = SLDT.Coords.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Coords)
	
	SLDT.Coords:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Coords:Enable()
end

SLDT.Coords:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Coords:SetScript("OnEvent", OnInit)