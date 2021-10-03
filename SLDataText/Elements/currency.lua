--[[ 		   SLDataText Module: Currency 				]]
--[[ Author: Taffu  RevDate: 01/29/2012  Version: 5.0.0 ]]

local SLDT, MODNAME, SLT = SLDataText, "Currency", LibStub("LibSLTip-1.0")
if ( SLDT ) then SLDT.Currency = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool, tip

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		tip = SLT:GetTooltip("SLDT_Currency", true)
		SLT:AddHeader("SLDT_Currency", L["Currency"])
		
		for k, v in pairs(SLDT.Currency.currTbl) do
			local buttonFunc = function(self, button)
				db["display"] = k
				SLDT.Currency:Refresh()
			end
			
			SLT:AddDoubleLine("SLDT_Currency", k, tostring(v), nil, nil, true, buttonFunc)
		end
		
		SLT:AddFooter("SLDT_Currency", L["Click to set display currency."], nil)
		if ( select(2, GetNumGuildMembers()) > 1 and not InCombatLockdown() ) then SLT:ShowTooltip("SLDT_Currency", frame) end
	end)
	tool:SetScript("OnLeave", function(this) SLT:ClearTooltip("SLDT_Currency") end)
	tool:SetScript("OnMouseDown", function(this, button)
		ToggleCharacter("TokenFrame")
	end)
end

local function TruncateName(name)
	local first, second = string.split(" ", name)
	return first
end

function SLDT.Currency:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		self:SetScript("OnEvent", function() self:Refresh() end)
	end
	self:Refresh()
end

function SLDT.Currency:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
		self:SetScript("OnEvent", nil)
	end
	self:Refresh()
end

function SLDT.Currency:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		SLDT.Currency.currTbl = {}
		for i = 1, GetCurrencyListSize() do
			local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(i)
			if ( not isHeader ) and ( not isUnused ) then
				SLDT.Currency.currTbl[name] = count
			end
		end
		
		if ( SLDT.Currency.currTbl[db.display] ) then
			local line = TruncateName(db.display)
			text:SetFormattedText("|cff%s%s:|r %i", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", line, SLDT.Currency.currTbl[db.display])
		else
			text:SetText(L["No Currency"])
		end
		
		SLDT:UpdateBaseFrame(SLDT.Currency, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

local function GetCurrList()
	local list = {}
	table.insert(list, "None")
	for i = 1, GetCurrencyListSize() do
		local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(i)
		if ( not isHeader ) and ( not isUnused ) then
			table.insert(list, name)
		end
	end
	return list
end

SLDT.Currency.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[7] = { [1] = "select", [2] = L["Display Currency"], [3] = "display", [4] = GetCurrList() },
	[8] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[9] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[10] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[11] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[12] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[13] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[14] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Currency.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Currency.db:RegisterDefaults({
        profile = {
			name = "Currency",
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
	db = SLDT.Currency.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Currency)
	SetupToolTip()
	
	SLDT.Currency:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Currency:Enable()
end

SLDT.Currency:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Currency:SetScript("OnEvent", OnInit)