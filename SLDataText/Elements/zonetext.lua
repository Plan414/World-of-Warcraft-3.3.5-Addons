--[[ 		   SLDataText Module: Zone Text 			]]
--[[ Author: Taffu  RevDate: 01/16/2012  Version: 5.0.0 ]]

local SLDT, MODNAME = SLDataText, "ZoneText"
if ( SLDT ) then SLDT.ZoneText = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local zoneName, subZoneName, pvpType, factionName
local zCol = {
	["sanctuary"] = { r = 0.41, b = 0.8, g = 0.94 },
	["arena"] = { r = 1.0, b = 0.1, g = 0.1 },
	["friendly"] = { r = 0.1, b = 1.0, g = 0.1 },
	["hostile"] = { r = 1.0, b = 0.1, g = 0.1 },
	["contested"] = { r = 1.0, b = 0.7, g = 0 },
	
}

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		GameTooltip:SetOwner(this, db.aF)
		GameTooltip:AddLine(zoneName, zCol[pvpType] and { zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g } or { 1, 1, 1 })
		if ( subZoneName and subZoneName ~= "" ) then
			GameTooltip:AddLine(subZoneName, 1, 1, 1)
		end
		if ( zCol[pvpType] ) then
            if ( pvpType == "sanctuary" ) then
                GameTooltip:AddLine(SANCTUARY_TERRITORY, zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
            elseif ( pvpType == "arena" ) then
                GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
            elseif ( pvpType == "friendly" ) then
                GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
            elseif ( pvpType == "hostile" ) then
                GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
            elseif ( pvpType == "contested" ) then
                GameTooltip:AddLine(CONTESTED_TERRITORY, zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
            end
		end
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this) if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end end)
	tool:SetScript("OnMouseDown", function()
		ToggleFrame(WorldMapFrame)
	end)
end

local function FixFrames(t)
	if ( t ) then
		MinimapZoneTextButton.Show = MiniMapWorldMapButton.Hide
		MinimapBorderTop.Show = MiniMapWorldMapButton.Hide
		MiniMapWorldMapButton.Show = MiniMapWorldMapButton.Hide
		
		if ( IsAddOnLoaded("Chinchilla") ) then
			if ( Chinchilla_Location_Frame and Chinchilla_Location_Frame:IsShown() ) then
				Chinchilla_Location_Frame:Hide()
			end
		end
	else
		MinimapZoneTextButton.Show = MiniMapWorldMapButton.Show
		MinimapBorderTop.Show = MiniMapWorldMapButton.Show
		MiniMapWorldMapButton.Show = MiniMapWorldMapButton.Show
		
		if ( IsAddOnLoaded("Chinchilla") ) then
			if ( Chinchilla_Location_Frame and not Chinchilla_Location_Frame:IsShown() ) then
				Chinchilla_Location_Frame:Show()
			end
		end
	end
end

function SLDT.ZoneText:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("ZONE_CHANGED")
		self:RegisterEvent("ZONE_CHANGED_INDOORS")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:SetScript("OnEvent", function() self:Refresh() end)
	end
	self:Refresh()
end

function SLDT.ZoneText:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("ZONE_CHANGED")
		self:UnregisterEvent("ZONE_CHANGED_INDOORS")
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self:SetScript("OnEvent", nil)
	end
	self:Refresh()
end

function SLDT.ZoneText:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		zoneName = GetZoneText()
		subZoneName = GetSubZoneText()
		pvpType, _, factionName = GetZonePVPInfo()
		
		if ( subZoneName == zoneName or subZoneName == "" ) then text:SetText(zoneName) else text:SetText(subZoneName) end
		
		if ( zCol[pvpType] ) then
			text:SetTextColor(zCol[pvpType].r, zCol[pvpType].b, zCol[pvpType].g)
		else
			text:SetTextColor(1.0, 0.9294, 0.7607) 
		end
		
		SLDT:UpdateBaseFrame(self, db)
		FixFrames(db.enabled)
	else
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
		FixFrames(db.enabled)
	end
end

SLDT.ZoneText.optsTbl = {
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
	SLDT.ZoneText.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.ZoneText.db:RegisterDefaults({
        profile = {
			name = "ZoneText",
			enabled = true,
			forceShow = true,
			aP = "CENTER",
			anch = "Minimap",
			aF = "TOP",
			xOff = 0,
			yOff = -12,
			strata = "LOW",
			gfont = false,
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = true,
        },
    })
	db = SLDT.ZoneText.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.ZoneText)
	SetupToolTip()
	
	SLDT.ZoneText:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.ZoneText:Enable()
end

SLDT.ZoneText:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.ZoneText:SetScript("OnEvent", OnInit)