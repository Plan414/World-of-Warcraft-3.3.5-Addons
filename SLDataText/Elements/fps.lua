--[[ 		     SLDataText Module: FPS 				]]
--[[ Author: Taffu  RevDate: 01/16/2012  Version: 5.0.0 ]]

local SLDT, MODNAME = SLDataText, "FPS"
if ( SLDT ) then SLDT.FPS = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

function SLDT.FPS:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		local int = db.interval
		frame:SetScript("OnUpdate", function(_, elapsed)
			int = int - elapsed
			if ( int <= 0 ) then self:Refresh(); int = db.interval end
		end)
	end
	self:Refresh()
end

function SLDT.FPS:Disable()
	if ( not db.enabled ) then
		frame:SetScript("OnUpdate", nil)
	end
	self:Refresh()
end

local tags = {
	["F"] = function()
		local fr = GetFramerate()
		return string.format("|cffffffff%.0f|r|cff%s", fr, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
}

function SLDT.FPS:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		local str = db.textDisplay
		str = string.gsub(str, "%[(%w+)%]", function(w) return tags[w]() end)
		text:SetFormattedText("|cff%s%s|r", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", str)
		
		SLDT:UpdateBaseFrame(self, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.FPS.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "text", [2] = L["Text Display"], [3] = "textDisplay" },
	[6] = { [1] = "desc", [2] = "FPSTextDesc", [3] = L["FPSTextDesc"] },
	[7] = { [1] = "range", [2] = L["Update Interval"], [3] = "interval", [4] = 10, [5] = 1000, [6] = 10 },
	[8] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[9] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[10] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[11] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[12] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[13] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[14] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[15] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.FPS.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.FPS.db:RegisterDefaults({
        profile = {
			name = "FPS",
			enabled = true,
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = -100,
			yOff = 0,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			interval = 10,
			tooltipOn = false,
			textDisplay = "[F] fps",			
        },
    })
	db = SLDT.FPS.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.FPS)
	
	SLDT.FPS:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.FPS:Enable()
end

SLDT.FPS:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.FPS:SetScript("OnEvent", OnInit)