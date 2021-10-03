--[[ 		     SLDataText Module: Exp 				]]
--[[ Author: Taffu  RevDate: 5/28/2012  Version: 5.0.0 ]]

-- Rev: Added tooltip

local SLDT, MODNAME, SLT = SLDataText, "Exp", LibStub("LibSLTip-1.0")
if ( SLDT ) then SLDT.Exp = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local tags = {
	["Cur"] = function()
		local curXP = UnitXP("player")
		if ( curXP > 9999 ) then
			return string.format("|cffffffff%.0fk|r|cff%s", curXP / 1000, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		else
			return string.format("|cffffffff%.0f|r|cff%s", curXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		end
	end,
	["Max"] = function()
		local maxXP = UnitXPMax("player")
		if ( maxXP > 9999 ) then
			return string.format("|cffffffff%.0fk|r|cff%s", maxXP / 1000, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		else
			return string.format("|cffffffff%.0f|r|cff%s", maxXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		end
	end,
	["MaxRaw"] = function()
		local maxXP = UnitXPMax("player")
		return string.format("|cffffffff%.0f|r|cff%s", maxXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["Rem"] = function()
		local remXP = UnitXPMax("player") - UnitXP("player")
		if ( remXP > 9999 ) then
			return string.format("|cffffffff%.0fk|r|cff%s", remXP / 1000, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		else
			return string.format("|cffffffff%.0f|r|cff%s", remXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		end
	end,
	["Per"] = function()
		local perXP = UnitXP("player") * (100 / UnitXPMax("player"))
		return string.format("|cffffffff%.1f%%|r|cff%s", perXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["PerR"] = function()
		local perRemXP = 100 - (UnitXP("player") * (100 / UnitXPMax("player")))
		return string.format("|cffffffff%.1f%%|r|cff%s", perRemXP, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["R"] = function()
		local rest = GetXPExhaustion() or 0
		if ( rest > 9999 ) then
			return string.format("|cffffffff%.0fk|r|cff%s", rest / 1000, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		else
			return string.format("|cffffffff%.0f|r|cff%s", rest, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
		end
	end,
	["RP"] = function()
		local rem, rest = UnitXPMax("player") - UnitXP("player"), GetXPExhaustion() or 0
		local restPer = (100 / rem) * rest
		return string.format("|cffffffff%.1f%%|r|cff%s", restPer, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
}

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		if ( db.tooltipOn ) then
			tip = SLT:GetTooltip("SLDT_Exp", false)
			SLT:AddHeader("SLDT_Exp", UnitName("player"), "Level " .. UnitLevel("player"), {1, 1, 1})
			
			SLT:AddDoubleLine("SLDT_Exp", "Current", tags["Cur"]() .. " (" .. tags["Per"]() .. ")")
			SLT:AddDoubleLine("SLDT_Exp", "Needed", tags["MaxRaw"]())
			SLT:AddDoubleLine("SLDT_Exp", "Remaining", tags["Rem"]() .. " (" .. tags["PerR"]() .. ")")
			
			if ( GetXPExhaustion() ) then
				SLT:AddDoubleLine("SLDT_Exp", "Rested", tags["R"]() .. " (" .. tags["RP"]() .. ")")
			end
			
			if ( not InCombatLockdown() ) then SLT:ShowTooltip("SLDT_Exp", frame) end
		end
	end)
	tool:SetScript("OnLeave", function(this) if ( db.tooltipOn ) then SLT:ClearTooltip("SLDT_Exp") end end)
end

function SLDT.Exp:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("PLAYER_XP_UPDATE")
		self:RegisterEvent("DISABLE_XP_GAIN")
		self:RegisterEvent("ENABLE_XP_GAIN")
		self:SetScript("OnEvent", function(self, event) self:Refresh() end)
	end
	self:Refresh()
end

function SLDT.Exp:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("PLAYER_XP_UPDATE")
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:SetScript("OnEvent", nil)
	end
	self:Refresh()
end

function SLDT.Exp:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		if ( db.hideMaxLvl and ( UnitLevel("player") == 90 ) ) then
			text:SetText("")
		else
			local str = db.textDisplay
			str = string.gsub(str, "%[(%w+)%]", function(w) return tags[w]() end)
			text:SetFormattedText("|cff%s%s|r", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", str)
		end
		
		SLDT:UpdateBaseFrame(self, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Exp.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "toggle", [2] = L["Max Level Hide"], [3] = "hideMaxLvl" },
	[7] = { [1] = "text", [2] = L["Text Display"], [3] = "textDisplay" },
	[8] = { [1] = "desc", [2] = "ExpTextDesc", [3] = L["ExpTextDesc"] },
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
	SLDT.Exp.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Exp.db:RegisterDefaults({
        profile = {
			name = "Exp",
			enabled = true,
			hideMaxLvl = false,
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = -100,
			yOff = 24,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = true,
			textDisplay = "Exp [Cur]/[Max] ([Per])",
        },
    })
	db = SLDT.Exp.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Exp)
	SetupToolTip()
	
	SLDT.Exp:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Exp:Enable()
end

SLDT.Exp:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Exp:SetScript("OnEvent", OnInit)