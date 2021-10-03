--[[ 		     SLDataText Module: Bag 				]]
--[[ Author: Taffu  RevDate: 01/28/2012  Version: 5.0.0 ]]

local SLDT, MODNAME = SLDataText, "Bag"
if ( SLDT ) then SLDT.Bag = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

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
		local bagRem, bagTtl = 0, 0
		for i = 0, NUM_BAG_SLOTS do
			bagRem, bagTtl = bagRem + GetContainerNumFreeSlots(i), bagTtl + GetContainerNumSlots(i)
		end
		GameTooltip:AddLine("|cffffffff"..L["Bag Info"].."|r")
		GameTooltip:AddDoubleLine(L["Space Used"], string.format("%d", bagTtl - bagRem), 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Space Avail"], string.format("%d", bagTtl), 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Space Left"], string.format("%d", bagRem), 1,1,0,1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["AutoSell Junk"], string.format("%s", db.selljunk and "On" or "Off"), 1,1,0,1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Left-Click"], L["Toggle Bags"], 1,1,0,1,1,1)
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this) if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end end)
	tool:SetScript("OnMouseDown", function(this, button)
		if ( button == "LeftButton" ) then OpenAllBags() end
	end)
end

function SLDT.Bag:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("BAG_UPDATE")
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", function(self, event)
			if ( event == "MERCHANT_SHOW" and db.selljunk ) then
				local junkMon = 0
				for bag = 0, NUM_BAG_SLOTS do 
					for slot = 0, GetContainerNumSlots(bag) do
						local link = GetContainerItemLink(bag, slot)
						if ( link ) then
							if ( select(3, GetItemInfo(link)) == 0 ) then
								junkMon = junkMon + select(11, GetItemInfo(link)) * select(2, GetContainerItemInfo(bag, slot))
								UseContainerItem(bag, slot)
							end
						end
					end
				end
				if ( junkMon > 0 ) then print(string.format("|cff6698FFSLDataText|r: %s %s", L["JunkSoldLine"], convertMoney(junkMon, true))) end
				self:Refresh()
			else self:Refresh() end
		end)
	end
	self:Refresh()
end

function SLDT.Bag:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("BAG_UPDATE")
		self:UnregisterEvent("MERCHANT_SHOW")
	end
	self:Refresh()
end

local tags = {
	["T"] = function()
		local total = 0
		for i = 0, NUM_BAG_SLOTS do
			total = total + GetContainerNumSlots(i)
		end
		return string.format("|cffffffff%s|r|cff%s", total, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["U"] = function()
		local rem, total = 0, 0
		for i = 0, NUM_BAG_SLOTS do
			rem, total = rem + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
		end
		return string.format("|cffffffff%s|r|cff%s", total-rem, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
	["R"] = function()
		local rem = 0
		for i = 0, NUM_BAG_SLOTS do
			rem = rem + GetContainerNumFreeSlots(i)
		end
		return string.format("|cffffffff%s|r|cff%s", rem, SLDT.db.profile.cCol and SLDT.classColor or "ffffff")
	end,
}

function SLDT.Bag:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		local str = db.textDisplay
		str = string.gsub(str, "%[(%w+)%]", function(w) return tags[w]() end)
		text:SetFormattedText("|cff%s%s|r", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", str)
		
		SLDT:UpdateBaseFrame(SLDT.Bag, db)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Bag.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "toggle", [2] = L["AutoSell Junk"], [3] = "selljunk" },
	[7] = { [1] = "text", [2] = L["Text Display"], [3] = "textDisplay" },
	[8] = { [1] = "desc", [2] = "BagTextDesc", [3] = L["BagTextDesc"] },
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
	SLDT.Bag.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Bag.db:RegisterDefaults({
        profile = {
			name = "Bag",
			enabled = true,
			selljunk = false,
			forceShow = false,
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = 100,
			yOff = 48,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = true,
			textDisplay = "Bag: [R]/[T]",
        },
    })
	db = SLDT.Bag.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Bag)
	SetupToolTip()
	
	SLDT.Bag:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Bag:Enable()
end

SLDT.Bag:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Bag:SetScript("OnEvent", OnInit)