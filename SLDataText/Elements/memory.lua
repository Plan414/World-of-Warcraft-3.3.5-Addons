--[[ 		     SLDataText Module: Memory 				]]
--[[ Author: Taffu  RevDate: 01/16/2012  Version: 5.0.0 ]]

local SLDT, MODNAME = SLDataText, "Memory"
if ( SLDT ) then SLDT.Memory = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		local function sortdesc(a, b) return a[2] > b[2] end
		GameTooltip:SetOwner(this, db.aF)
		UpdateAddOnMemoryUsage()
		local addons, total = {}, 0
		for i = 1, GetNumAddOns() do
			if ( IsAddOnLoaded(i) ) then
				local memUse = GetAddOnMemoryUsage(i)
				table.insert(addons, { GetAddOnInfo(i), memUse })
				total = total + memUse
			end
		end
		table.sort(addons, sortdesc)
		GameTooltip:AddLine(string.format("|cffffffff"..L["AddOn Memory"]..":|r %.1fmb", total/1024))
		if ( not IsAltKeyDown() ) then GameTooltip:AddLine(L["Showing Top 15 AddOns"]) end
		GameTooltip:AddLine(" ")
		for i = 1, #addons do
			if ( i <= 15 and not IsAltKeyDown() ) then
				local v = addons[i]
				local tag, memAmt
				if ( v[2]/1024 < 1 ) then tag = "kb"; memAmt = v[2] else tag = "mb"; memAmt = v[2]/1024 end
				GameTooltip:AddDoubleLine(v[1], string.format("%.1f%s", memAmt, tag), 1,1,0,1,1,1)
			elseif ( IsAltKeyDown() ) then
				local v = addons[i]
				local tag, memAmt
				if ( v[2]/1024 < 1 ) then tag = "kb"; memAmt = v[2] else tag = "mb"; memAmt = v[2]/1024 end
				GameTooltip:AddDoubleLine(v[1], string.format("%.1f%s", memAmt, tag), 1,1,0,1,1,1)
			end
		end
		GameTooltip:AddDoubleLine("", "----------", 1,1,1,1,1,1)
		GameTooltip:AddDoubleLine(L["Total AddOn Memory"], string.format("%.1fmb", total/1024), 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Total UI Memory Usage"], string.format("%.1fmb", gcinfo()/1024), 1,1,0,1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Hover"], L["Show only top AddOns"], 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Alt+Hover"], L["Show all AddOns"], 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Right-Click"], L["Collect Garbage"], 1,1,0,1,1,1)
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this)
		if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
	end)
	tool:SetScript("OnMouseDown", function(self, button)
		if ( button == "RightButton" ) then
			collectgarbage()
		end
	end)
end

function SLDT.Memory:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		local int = db.interval
		frame:SetScript("OnUpdate", function(_, elapsed)
			int = int - elapsed
			if ( int <= 0 ) then SLDT.Memory:Refresh(); int = db.interval end
		end)
	end
	self:Refresh()
end

function SLDT.Memory:Disable()
	if ( not db.enabled ) then
		frame:SetScript("OnUpdate", nil)
	end
	self:Refresh()
end

local tags = {
	["MA"] = function()
		local total = 0
		for i = 1, GetNumAddOns() do
			if ( IsAddOnLoaded(i) ) then total = total + GetAddOnMemoryUsage(i) end
		end
		return string.format("|cffffffff%.1f|r|cff%s", total/1024, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["MT"] = function()
		return string.format("|cffffffff%.1f|r|cff%s", gcinfo()/1024, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
}

function SLDT.Memory:Refresh()
	if ( db.enabled or SLDT.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		UpdateAddOnMemoryUsage()
		local str = db.textDisplay
		str = string.gsub(str, "%[(%w+)%]", function(w) return tags[w]() end)
		text:SetFormattedText("|cff%s%s|r", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", str)
		
		SLDT:UpdateBaseFrame(self, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Memory.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "text", [2] = L["Text Display"], [3] = "textDisplay" },
	[7] = { [1] = "desc", [2] = "MemTextDesc", [3] = L["MemTextDesc"] },
	[8] = { [1] = "range", [2] = L["Update Interval"], [3] = "interval", [4] = 10, [5] = 1000, [6] = 10 },
	[9] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[10] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[11] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[12] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[13] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[14] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[15] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[16] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Memory.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Memory.db:RegisterDefaults({
        profile = {
			name = "Memory",
			enabled = true,
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = 100,
			yOff = 0,
			strata = "MEDIUM",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			interval = 10,
			tooltipOn = true,
			textDisplay = "[MA]mb",
        },
    })
	db = SLDT.Memory.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Memory)
	SetupToolTip()
	
	SLDT.Memory:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Memory:Enable()
end

SLDT.Memory:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Memory:SetScript("OnEvent", OnInit)