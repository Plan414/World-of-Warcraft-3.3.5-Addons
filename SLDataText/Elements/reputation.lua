--[[ 		  SLDataText Module: Reputation 			]]
--[[ Author: Taffu  RevDate: 05/28/2012  Version: 5.0.0 ]]

-- Rev: Added proper "Tooltip On" check

local SLDT, MODNAME, SLT = SLDataText, "Reputation", LibStub("LibSLTip-1.0")
if ( SLDT ) then SLDT.Reputation = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool, tip, noWatch

local standingTbl = {
	[1] = L["Hated"],
	[2] = L["Hostile"],
	[3] = L["Unfriendly"],
	[4] = L["Neutral"],
	[5] = L["Friendly"],
	[6] = L["Honored"],
	[7] = L["Revered"],
	[8] = L["Exalted"],
}

local stdCol = {
    [1] = { r = 0.8, g = 0.3, b = 0.22 },
    [2] = { r = 0.8, g = 0.3, b = 0.22 },
    [3] = { r = 0.75, g = 0.27, b = 0 },
    [4] = { r = 0.9, g = 0.7, b = 0 },
    [5] = { r = 0, g = 0.6, b = 0.1 },
    [6] = { r = 0, g = 0.6, b = 0.1 },
    [7] = { r = 0, g = 0.6, b = 0.1 },
    [8] = { r = 0.5, g = 0.9, b = 0.1 },
}

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		if ( SLDT.Reputation.repTbl and noWatch ~= true and db.tooltipOn ) then
			local repTbl = SLDT.Reputation.repTbl
			
			tip = SLT:GetTooltip("SLDT_Reputation", false)
			SLT:AddHeader("SLDT_Reputation", repTbl[1], repTbl[2], { 1, 1, 1 })
			SLT:AddDoubleLine("SLDT_Reputation", standingTbl[repTbl[3]], string.format("%i/%i", repTbl[6]-repTbl[4], repTbl[5]-repTbl[4]), { stdCol[repTbl[3]].r, stdCol[repTbl[3]].g, stdCol[repTbl[3]].b }, nil)
			
			if ( not InCombatLockdown() ) then SLT:ShowTooltip("SLDT_Reputation", frame) end
		end
	end)
	tool:SetScript("OnLeave", function(this) if ( SLDT.Reputation.repTbl and db.tooltipOn ) then SLT:ClearTooltip("SLDT_Reputation") end end)
	tool:SetScript("OnMouseDown", function(this, button)
		ToggleCharacter("ReputationFrame")
	end)
end

local function TruncateName(name)
	local first, second = string.split(" ", name)
	return first
end

function SLDT.Reputation:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
		self:RegisterEvent("GUILD_REP_UPDATED")
		self:RegisterEvent("UPDATE_FACTION")
		self:SetScript("OnEvent", function() self:Refresh() end)
	end
	self:Refresh()
end

function SLDT.Reputation:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
		self:UnregisterEvent("GUILD_REP_UPDATED")
		self:UnregisterEvent("UPDATE_FACTION")
		self:SetScript("OnEvent", nil)
	end
	self:Refresh()
end

local repCheckTimer = function()
	SLDT.Reputation:SetScript("OnUpdate", function(self, elapsed)
		if ( GetNumFactions() > 0 ) then
			self:SetScript("OnUpdate", nil)
			self:Refresh()
		end
	end)
end

function SLDT.Reputation:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		if ( GetNumFactions() == 0 ) then repCheckTimer(); return end
		
		noWatch = true
		SLDT.Reputation.repTbl = {}		
		for i = 1, GetNumFactions() do
			local name, desc, sID, barMin, barMax, barVal, _, _, isHeader, _, hasRep, isWatched, _ = GetFactionInfo(i)
			if ( not isHeader ) then				
				if ( isWatched ) then
					-- Store for tooltip use
					SLDT.Reputation.repTbl = { name, desc, sID, barMin, barMax, barVal }
					
					local repPer = (100/(barMax-barMin))*(barVal-barMin)
					text:SetFormattedText("|cff%s%s:|r %.0f%%", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", name, repPer)
					text:SetTextColor(stdCol[sID].r, stdCol[sID].g, stdCol[sID].b)
					noWatch = false
				end
			end
		end
		
		if ( noWatch ) then
			SLDT.Reputation.repTbl = nil
			text:SetText(L["No Reputation"])
			text:SetTextColor(1, 1, 1)
		end
		
		SLDT:UpdateBaseFrame(SLDT.Reputation, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Reputation.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
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
	SLDT.Reputation.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Reputation.db:RegisterDefaults({
        profile = {
			name = "Reputation",
			enabled = true,
			display = "None",
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = -100,
			yOff = -48,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			interval = 10,
			tooltipOn = true,
        },
    })
	db = SLDT.Reputation.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Reputation)
	SetupToolTip()
	
	SLDT.Reputation:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Reputation:Enable()
end

SLDT.Reputation:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Reputation:SetScript("OnEvent", OnInit)