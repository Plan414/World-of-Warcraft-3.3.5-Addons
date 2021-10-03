--[[ 		     SLDataText Module: Armor 				]]
--[[ Author: Taffu  RevDate: 07/13/2012  Version: 5.0.0 ]]

-- Added guild fund repair

local SLDT, MODNAME = SLDataText, "Armor"
if ( SLDT ) then SLDT.Armor = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local durMin, durCol
local function convertMoney(moolah, display)
    local g, s, c = abs(moolah/10000), abs(mod(moolah/100, 100)), abs(mod(moolah, 100))
	local cash
    if ( display ) then -- True = Long display
		if ( g < 1 ) then g = "" else g = string.format("%d|cffffd700g|r ", g) end
		if ( s < 1 ) then s = "" else s = string.format("%d|cffc7c7cfs|r ", s) end
		c = string.format("%d|cffeda55fc|r", c)
        cash = string.format("%s%s%s", g, s, c)
    else
        cash = string.format("%.1f|cffffd700g|r", g)
    end
    return cash
end

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		GameTooltip:SetOwner(this, db.aF)
		GameTooltip:AddLine("|cffffffff"..L["Armor"].."|r")
		local durFull = true
		for slot, slotName in gmatch("1HEAD3SHOULDER5CHEST6WAIST7LEGS8FEET9WRIST10HANDS16MAINHAND17SECONDARYHAND18RANGED","(%d+)([^%d]+)") do
			local durCur, durMax = GetInventoryItemDurability(slot)
			local slotName = _G[slotName.."SLOT"]
			if ( durCur ~= durMax ) then
				GameTooltip:AddDoubleLine(slotName, string.format("%.0f%%", durCur ~= 0 and durCur*(100/durMax) or 0), 1,1,0,1,1,1)
				if ( durFull ) then durFull = false end
			end
		end
		if ( durFull ) then
			GameTooltip:AddDoubleLine(L["All Items"], "100%", 1,1,0,1,1,1)
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Auto Repair"], string.format("%s", db.autorepair and L["On"] or L["Off"]), 1,1,0,1,1,1)
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this) if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end end)
end

function SLDT.Armor:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", function(self, event)
			if ( event == "MERCHANT_SHOW" and db.autorepair and CanMerchantRepair() ) then
				local repCost, totCost = GetRepairAllCost(), 0
				if ( repCost > 0 ) then
					if ( CanGuildBankRepair() and db.usegfunds ) then
						RepairAllItems(1)
						print(string.format("|cff6698FFSLDataText|r: %s %s.", L["GFAutoRepairLine"], convertMoney(repCost, true)))
					else
						RepairAllItems()
						print(string.format("|cff6698FFSLDataText|r: %s %s.", L["AutoRepairLine"], convertMoney(repCost, true)))
					end
				end
			else self:Refresh() end
		end)
	end
	self:Refresh()
end

function SLDT.Armor:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		self:UnregisterEvent("MERCHANT_SHOW")
	end
	self:Refresh()
end

local tags = {
	["Dur"] = function()
		durMin, durCol = 100, "ffffff"
		for i = 1, 18 do
			local durCur, durMax = GetInventoryItemDurability(i)
			if ( durCur ~= durMax ) then durMin = min(durMin, durCur*(100/durMax)) end
		end
		if ( durMin < 60 ) then durCol = "ffff00" elseif ( durMin < 30 ) then durCol = "ff0000" end
		return string.format("|cff%s%.0f|r|cff%s", durCol, durMin, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
}

function SLDT.Armor:Refresh()
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

SLDT.Armor.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "toggle", [2] = L["Auto Repair"], [3] = "autorepair" },
	[7] = { [1] = "toggle", [2] = L["Use Guild Bank"], [3] = "usegfunds" },
	[8] = { [1] = "text", [2] = L["Text Display"], [3] = "textDisplay" },
	[9] = { [1] = "desc", [2] = "ArmorTextDesc", [3] = L["ArmorTextDesc"] },
	[10] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[11] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[12] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[13] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[14] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[15] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[16] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[17] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Armor.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Armor.db:RegisterDefaults({
        profile = {
			name = "Armor",
			enabled = true,
			autorepair = false,
			usegfunds = false,
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = 100,
			yOff = 24,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = true,
			textDisplay = "Armor [Dur]%",
        },
    })
	db = SLDT.Armor.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Armor)
	SetupToolTip()
	
	SLDT.Armor:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Armor:Enable()
end

SLDT.Armor:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Armor:SetScript("OnEvent", OnInit)