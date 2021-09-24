local E, L, V, P, G = unpack(ElvUI)
local LPB = E:NewModule("LocationPlus", "AceTimer-3.0")
local DT = E:GetModule("DataTexts")
local LSM = LibStub("LibSharedMedia-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")

local tourist = LibStub("LibTourist-3.0")

local format, tonumber, pairs, print = string.format, tonumber, pairs, print

local CreateFrame = CreateFrame
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetBindLocation = GetBindLocation
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetMinimapZoneText = GetMinimapZoneText
local GetPlayerMapPosition = GetPlayerMapPosition
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText
local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance, InCombatLockdown = IsInInstance, InCombatLockdown
local UnitLevel = UnitLevel
local UIFrameFadeIn, UIFrameFadeOut, ToggleFrame = UIFrameFadeIn, UIFrameFadeOut, ToggleFrame
local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown
local GameTooltip, WorldMapFrame = _G["GameTooltip"], _G["WorldMapFrame"]

local PLAYER, UNKNOWN, TRADE_SKILLS, LEVEL_RANGE, STATUS, HOME, CONTINENT = PLAYER, UNKNOWN, TRADE_SKILLS, LEVEL_RANGE, STATUS, HOME, CONTINENT
local SANCTUARY_TERRITORY, ARENA, HOSTILE, CONTESTED_TERRITORY, COMBAT, AGGRO_WARNING_IN_INSTANCE, PVP, RAID = SANCTUARY_TERRITORY, ARENA, HOSTILE, CONTESTED_TERRITORY, COMBAT, AGGRO_WARNING_IN_INSTANCE, PVP, RAID

-- GLOBALS: LocationPlusPanel, LeftCoordDtPanel, RightCoordDtPanel, XCoordsPanel, YCoordsPanel, selectioncolor, continent, continentID

local left_dtp = CreateFrame("Frame", "LeftCoordDtPanel", E.UIParent)
local right_dtp = CreateFrame("Frame", "RightCoordDtPanel", E.UIParent)

local COORDS_WIDTH = 30 -- Coord panels width
local classColor = RAID_CLASS_COLORS[E.myclass] -- for text coloring

LPB.version = GetAddOnMetadata("ElvUI_LocPlus", "Version")

if E.db.locplus == nil then E.db.locplus = {} end

do
	DT:RegisterPanel(LeftCoordDtPanel, 1, "ANCHOR_BOTTOM", 0, -4)
	DT:RegisterPanel(RightCoordDtPanel, 1, "ANCHOR_BOTTOM", 0, -4)

	L["RightCoordDtPanel"] = L["LocationPlus Right Panel"]
	L["LeftCoordDtPanel"] = L["LocationPlus Left Panel"]

	-- Setting default datatexts
	P.datatexts.panels.RightCoordDtPanel = "Time"
	P.datatexts.panels.LeftCoordDtPanel = "Durability"
end

local SPACING = 1

-- Status
local function GetStatus(color)
	local status = ""
	local statusText
	local r, g, b = 1, 1, 0
	local pvpType = GetZonePVPInfo()
	local inInstance, _ = IsInInstance()
	if(pvpType == "sanctuary") then
		status = SANCTUARY_TERRITORY
		r, g, b = 0.41, 0.8, 0.94
	elseif(pvpType == "arena") then
		status = ARENA
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "friendly") then
		status = L["Friendly"]
		r, g, b = 0.1, 1, 0.1
	elseif(pvpType == "hostile") then
		status = HOSTILE
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "contested") then
		status = CONTESTED_TERRITORY
		r, g, b = 1, 0.7, 0.10
	elseif(pvpType == "combat" ) then
		status = COMBAT
		r, g, b = 1, 0.1, 0.1
	elseif(inInstance) then
		status = L["In Instance"]
		r, g, b = 1, 0.1, 0.1
	else
		status = CONTESTED_TERRITORY
	end

	statusText = format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, status)
	if color then
		return r, g, b
	else
		return statusText
	end
end

-- Dungeon coords
local function GetDungeonCoords(zone)
	local z, x, y = "", 0, 0
	local dcoords

	if tourist:IsInstance(zone) then
		z, x, y = tourist:GetEntrancePortalLocation(zone)
	end

	if z == nil then
		dcoords = ""
	elseif E.db.locplus.ttcoords then
		x = tonumber(E:Round(x, 0))
		y = tonumber(E:Round(y, 0))
		dcoords = format(" |cffffffff(%d, %d)|r", x, y)
	else
		dcoords = ""
	end

	return dcoords
end

-- PvP/Raid filter
 local function PvPorRaidFilter(zone)

	local isPvP, isRaid

	isPvP = nil
	isRaid = nil

	if(tourist:IsArena(zone) or tourist:IsBattleground(zone)) then
		if E.db.locplus.tthidepvp then
			return
		end
		isPvP = true
	end

	if(not isPvP and tourist:GetInstanceGroupSize(zone) >= 10) then
		if E.db.locplus.tthideraid then
			return
		end
		isRaid = true
	end

	return (isPvP and "|cffff0000 "..PVP.."|r" or "")..(isRaid and "|cffff4400 "..RAID.."|r" or "")

end

-- Recommended zones
local function GetRecomZones(zone)

	local low, high = tourist:GetLevel(zone)
	local r, g, b = tourist:GetLevelColor(zone)
	local zContinent = tourist:GetContinent(zone)

	if PvPorRaidFilter(zone) == nil then return end

	GameTooltip:AddDoubleLine(
	"|cffffffff"..zone
	..PvPorRaidFilter(zone) or "",
	format("|cff%02xff00%s|r", continent == zContinent and 0 or 255, zContinent)
	..(" |cff%02x%02x%02x%s|r"):format(r *255, g *255, b *255,(low == high and low or ("%d-%d"):format(low, high))))

end

-- Dungeons in the zone
local function GetZoneDungeons(dungeon)

	local low, high = tourist:GetLevel(dungeon)
	local r, g, b = tourist:GetLevelColor(dungeon)
	local groupSize = tourist:GetInstanceGroupSize(dungeon)
	local groupSizeStyle = (groupSize > 0 and format("|cFFFFFF00|r (%d", groupSize) or "")
	local name = dungeon

	if PvPorRaidFilter(dungeon) == nil then return end

	GameTooltip:AddDoubleLine(
	"|cffffffff"..name
	..(groupSizeStyle or "")
	..GetDungeonCoords(dungeon)
	..PvPorRaidFilter(dungeon) or "",
	("|cff%02x%02x%02x%s|r"):format(r *255, g *255, b *255,(low == high and low or ("%d-%d"):format(low, high))))

end

-- Recommended Dungeons
local function GetRecomDungeons(dungeon)

	local low, high = tourist:GetLevel(dungeon)
	local r, g, b = tourist:GetLevelColor(dungeon)
	local instZone = tourist:GetInstanceZone(dungeon)
	local name = dungeon

	if PvPorRaidFilter(dungeon) == nil then return end

	if instZone == nil then
		instZone = ""
	else
		instZone = "|cFFFFA500 ("..instZone..")"
	end

	GameTooltip:AddDoubleLine(
	"|cffffffff"..name
	..instZone
	..GetDungeonCoords(dungeon)
	..PvPorRaidFilter(dungeon) or "",
	("|cff%02x%02x%02x%s|r"):format(r *255, g *255, b *255,(low == high and low or ("%d-%d"):format(low, high))))

end

-- Icons on Location Panel
local LEVEL_ICON = "|TInterface\\AddOns\\ElvUI_LocPlus\\media\\levelup.tga:22:22|t"

-- Zone level range
local function GetLevelRange(zoneText, ontt)
	local zoneText = GetRealZoneText() or UNKNOWN
	local low, high = tourist:GetLevel(zoneText)
	local dlevel
	if low > 0 and high > 0 then
		local r, g, b = tourist:GetLevelColor(zoneText)
		if low ~= high then
			dlevel = format("|cff%02x%02x%02x%d-%d|r", r*255, g*255, b*255, low, high) or ""
		else
			dlevel = format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, high) or ""
		end

		if ontt then
			return dlevel
		else
			if E.db.locplus.showicon then
				dlevel = format(" (%s) ", dlevel)..LEVEL_ICON
			else
				dlevel = format(" (%s) ", dlevel)
			end
		end
	end

	return dlevel or ""
end

local capRank = 800

local function UpdateTooltip()
	local zoneText = GetRealZoneText() or UNKNOWN
	local curPos = (zoneText.." ") or ""

	GameTooltip:ClearLines()

	-- Zone
	GameTooltip:AddDoubleLine(L["Zone : "], zoneText, 1, 1, 1, selectioncolor)

	-- Continent
	GameTooltip:AddDoubleLine(CONTINENT.." : ", tourist:GetContinent(zoneText), 1, 1, 1, selectioncolor)

	-- Home
	GameTooltip:AddDoubleLine(HOME.." :", GetBindLocation(), 1, 1, 1, 0.41, 0.8, 0.94)

	-- Status
	if E.db.locplus.ttst then
		GameTooltip:AddDoubleLine(L["Status"].." :", GetStatus(false), 1, 1, 1)
	end

    -- Zone level range
	if E.db.locplus.ttlvl then
		local checklvl = GetLevelRange(zoneText, true)
		if checklvl ~= "" then
			GameTooltip:AddDoubleLine(LEVEL_RANGE.." : ", checklvl, 1, 1, 1, r, g, b)
		end
	end

	-- Recommended zones
	if E.db.locplus.ttreczones then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Recommended Zones :"], selectioncolor)

		for zone in tourist:IterateRecommendedZones() do
			GetRecomZones(zone)
		end
	end

	-- Instances in the zone
	if E.db.locplus.ttinst and tourist:DoesZoneHaveInstances(zoneText) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(curPos..L["Dungeons :"], selectioncolor)

		for dungeon in tourist:IterateZoneInstances(zoneText) do
			GetZoneDungeons(dungeon)
		end
	end

	-- Recommended Instances
	local level = UnitLevel("player")
	if E.db.locplus.ttrecinst and tourist:HasRecommendedInstances() and level >= 15 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Recommended Dungeons :"], selectioncolor)

		for dungeon in tourist:IterateRecommendedInstances() do
			GetRecomDungeons(dungeon)
		end
	end

	-- Hints
	if E.db.locplus.tt then
		if E.db.locplus.tthint then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L["Left Click : "], L["Toggle WorldMap"], 0.7, 0.7, 1, 0.7, 0.7, 1)
			GameTooltip:AddDoubleLine(L["Right Click : "], L["Toggle Configuration"],0.7, 0.7, 1, 0.7, 0.7, 1)
			GameTooltip:AddDoubleLine(L["Shift Click : "], L["Send position to chat"],0.7, 0.7, 1, 0.7, 0.7, 1)
			GameTooltip:AddDoubleLine(L["Ctrl Click : "], L["Toggle Datatexts"],0.7, 0.7, 1, 0.7, 0.7, 1)
		end
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end

end

-- mouse over the location panel
local function LocPanel_OnEnter(self,...)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)

	if InCombatLockdown() and E.db.locplus.ttcombathide then
		GameTooltip:Hide()
	else
		UpdateTooltip()
	end

	if E.db.locplus.mouseover then
		UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end
end

-- mouse leaving the location panel
local function LocPanel_OnLeave(self,...)
	GameTooltip:Hide()
	if E.db.locplus.mouseover then
		UIFrameFadeOut(self, 0.2, self:GetAlpha(), E.db.locplus.malpha)
	end
end

-- Hide in combat, after fade function ends
local function LocPanelOnFade()
	LocationPlusPanel:Hide()
end

-- Coords Creation
local function CreateCoords()
	local x, y = GetPlayerMapPosition("player")
	local dig

	if E.db.locplus.dig then
		dig = 2
	else
		dig = 0
	end

	if x then
		x = tonumber(E:Round(100 * x, dig))
	end
	if y then
		y = tonumber(E:Round(100 * y, dig))
	end

	return x, y
end

-- clicking the location panel
local function LocPanel_OnClick(self, btn)
	local zoneText = GetRealZoneText() or UNKNOWN
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local edit_box = ChatEdit_ChooseBoxForSend()
			local x, y = CreateCoords()
			local message
			local coords = x..", "..y
				if zoneText ~= GetSubZoneText() then
					message = format("%s: %s (%s)", zoneText, GetSubZoneText(), coords)
				else
					message = format("%s (%s)", zoneText, coords)
				end
				ChatEdit_ActivateChat(edit_box)
				edit_box:Insert(message)
		else
			if IsControlKeyDown() then
				LeftCoordDtPanel:SetScript("OnShow", function(self) E.db.locplus.dtshow = true end)
				LeftCoordDtPanel:SetScript("OnHide", function(self) E.db.locplus.dtshow = false end)
				ToggleFrame(LeftCoordDtPanel)
				ToggleFrame(RightCoordDtPanel)
			else
				ToggleFrame(WorldMapFrame)
			end
		end
	end
	if btn == "RightButton" then
		E:ToggleOptionsUI()
	end
end

-- Custom text color. Credits: Edoc
local color = { r = 1, g = 1, b = 1 }
local function unpackColor(color)
	return color.r, color.g, color.b
end

-- Location panel
local function CreateLocPanel()
	local loc_panel = CreateFrame("Frame", "LocationPlusPanel", E.UIParent)
	loc_panel:Width(E.db.locplus.lpwidth)
	loc_panel:Height(E.db.locplus.dtheight)
	loc_panel:Point("TOP", E.UIParent, "TOP", 0, -E.mult -22)
	loc_panel:SetFrameStrata("LOW")
	loc_panel:SetFrameLevel(2)
	loc_panel:EnableMouse(true)
	loc_panel:SetScript("OnEnter", LocPanel_OnEnter)
	loc_panel:SetScript("OnLeave", LocPanel_OnLeave)
	loc_panel:SetScript("OnMouseUp", LocPanel_OnClick)

	-- Location Text
	loc_panel.Text = LocationPlusPanel:CreateFontString(nil, "LOW")
	loc_panel.Text:Point("CENTER", 0, 0)
	loc_panel.Text:SetAllPoints()
	loc_panel.Text:SetJustifyH("CENTER")
	loc_panel.Text:SetJustifyV("MIDDLE")

	-- Hide in combat
	loc_panel:SetScript("OnEvent",function(self, event)
		if E.db.locplus.combat then
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
				self.fadeInfo.finishedFunc = LocPanelOnFade
			elseif event == "PLAYER_REGEN_ENABLED" then
				if E.db.locplus.mouseover then
					UIFrameFadeIn(self, 0.2, self:GetAlpha(), E.db.locplus.malpha)
				else
					UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
				end
				self:Show()
			end
		end
	end)

	-- Mover
	E:CreateMover(LocationPlusPanel, "LocationMover", L["LocationPlus "])
end

local function HideDT()
	if E.db.locplus.dtshow then
		RightCoordDtPanel:Show()
		LeftCoordDtPanel:Show()
	else
		RightCoordDtPanel:Hide()
		LeftCoordDtPanel:Hide()
	end
end

-- Coord panels
local function CreateCoordPanels()

	-- X Coord panel
	local coordsX = CreateFrame("Frame", "XCoordsPanel", LocationPlusPanel)
	coordsX:Width(COORDS_WIDTH)
	coordsX:Height(E.db.locplus.dtheight)
	coordsX:SetFrameStrata("LOW")
	coordsX.Text = XCoordsPanel:CreateFontString(nil, "LOW")
	coordsX.Text:SetAllPoints()
	coordsX.Text:SetJustifyH("CENTER")
	coordsX.Text:SetJustifyV("MIDDLE")

	-- Y Coord panel
	local coordsY = CreateFrame("Frame", "YCoordsPanel", LocationPlusPanel)
	coordsY:Width(COORDS_WIDTH)
	coordsY:Height(E.db.locplus.dtheight)
	coordsY:SetFrameStrata("LOW")
	coordsY.Text = YCoordsPanel:CreateFontString(nil, "LOW")
	coordsY.Text:SetAllPoints()
	coordsY.Text:SetJustifyH("CENTER")
	coordsY.Text:SetJustifyV("MIDDLE")

	LPB:CoordsColor()
end

-- mouse over option
function LPB:MouseOver()
	if E.db.locplus.mouseover then
		LocationPlusPanel:SetAlpha(E.db.locplus.malpha)
	else
		LocationPlusPanel:SetAlpha(1)
	end
end

-- datatext panels width
function LPB:DTWidth()
	LeftCoordDtPanel:Width(E.db.locplus.dtwidth)
	RightCoordDtPanel:Width(E.db.locplus.dtwidth)
end

-- all panels height
function LPB:DTHeight()
	if E.db.locplus.ht then
		LocationPlusPanel:Height((E.db.locplus.dtheight)+6)
	else
		LocationPlusPanel:Height(E.db.locplus.dtheight)
	end

	LeftCoordDtPanel:Height(E.db.locplus.dtheight)
	RightCoordDtPanel:Height(E.db.locplus.dtheight)

	XCoordsPanel:Height(E.db.locplus.dtheight)
	YCoordsPanel:Height(E.db.locplus.dtheight)
end

-- Fonts
function LPB:ChangeFont()

	E["media"].lpFont = LSM:Fetch("font", E.db.locplus.lpfont)

	local panelsToFont = {LocationPlusPanel, XCoordsPanel, YCoordsPanel}
	for _, frame in pairs(panelsToFont) do
		frame.Text:FontTemplate(E["media"].lpFont, E.db.locplus.lpfontsize, E.db.locplus.lpfontflags)
	end

	local dtToFont = {RightCoordDtPanel, LeftCoordDtPanel}
	for panelName, panel in pairs(dtToFont) do
		for i=1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			panel.dataPanels[pointIndex].text:FontTemplate(E["media"].lpFont, E.db.locplus.lpfontsize, E.db.locplus.lpfontflags)
			panel.dataPanels[pointIndex].text:SetPoint("CENTER", 0, 1)
		end
	end
end

-- Enable/Disable shadows
function LPB:ShadowPanels()
	local panelsToAddShadow = {LocationPlusPanel, XCoordsPanel, YCoordsPanel, LeftCoordDtPanel, RightCoordDtPanel}

	for _, frame in pairs(panelsToAddShadow) do
		frame:CreateShadow()
		if E.db.locplus.shadow then
			frame.shadow:Show()
		else
			frame.shadow:Hide()
		end
	end

	if E.db.locplus.shadow then
		SPACING = 2
	else
		SPACING = 1
	end

	self:HideCoords()
end

-- Show/Hide coord frames
function LPB:HideCoords()
	XCoordsPanel:Point("RIGHT", LocationPlusPanel, "LEFT", -SPACING, 0)
	YCoordsPanel:Point("LEFT", LocationPlusPanel, "RIGHT", SPACING, 0)

	LeftCoordDtPanel:ClearAllPoints()
	RightCoordDtPanel:ClearAllPoints()

	if E.db.locplus.hidecoords then
		XCoordsPanel:Hide()
		YCoordsPanel:Hide()
		LeftCoordDtPanel:Point("RIGHT", LocationPlusPanel, "LEFT", -SPACING, 0)
		RightCoordDtPanel:Point("LEFT", LocationPlusPanel, "RIGHT", SPACING, 0)
	else
		XCoordsPanel:Show()
		YCoordsPanel:Show()
		LeftCoordDtPanel:Point("RIGHT", XCoordsPanel, "LEFT", -SPACING, 0)
		RightCoordDtPanel:Point("LEFT", YCoordsPanel, "RIGHT", SPACING, 0)
	end
end

-- Toggle transparency
function LPB:TransparentPanels()
	local panelsToAddTrans = {LocationPlusPanel, XCoordsPanel, YCoordsPanel, LeftCoordDtPanel, RightCoordDtPanel}

	for _, frame in pairs(panelsToAddTrans) do
		frame:SetTemplate("NoBackdrop")
		if not E.db.locplus.noback then
			E.db.locplus.shadow = false
		elseif E.db.locplus.trans then
			frame:SetTemplate("Transparent")
		else
			frame:SetTemplate("Default", true)
		end
	end
end

function LPB:UpdateLocation()
	local subZoneText = GetMinimapZoneText() or ""
	local zoneText = GetRealZoneText() or UNKNOWN
	local displayLine

	-- zone and subzone
	if E.db.locplus.both then
		if (subZoneText ~= "") and (subZoneText ~= zoneText) then
			displayLine = zoneText .. ": " .. subZoneText
		else
			displayLine = subZoneText
		end
	else
		displayLine = subZoneText
	end

	-- Show Other (Level)
	if E.db.locplus.displayOther == "RLEVEL" then
		local displaylvl = GetLevelRange(zoneText) or ""
		if displaylvl ~= "" then
			displayLine = displayLine..displaylvl
		end
	else
		displayLine = displayLine
	end

	LocationPlusPanel.Text:SetText(displayLine)

	-- Coloring
	if displayLine ~= "" then
		if E.db.locplus.customColor == 1 then
			LocationPlusPanel.Text:SetTextColor(GetStatus(true))
		elseif E.db.locplus.customColor == 2 then
			LocationPlusPanel.Text:SetTextColor(classColor.r, classColor.g, classColor.b)
		else
			LocationPlusPanel.Text:SetTextColor(unpackColor(E.db.locplus.userColor))
		end
	end

	-- Sizing
	local fixedwidth = (E.db.locplus.lpwidth + 18)
	local autowidth = (LocationPlusPanel.Text:GetStringWidth() + 18)

	if E.db.locplus.lpauto then
		LocationPlusPanel:Width(autowidth)
		LocationPlusPanel.Text:Width(autowidth)
	else
		LocationPlusPanel:Width(fixedwidth)
		if E.db.locplus.trunc then
			LocationPlusPanel.Text:Width(fixedwidth - 18)
			LocationPlusPanel.Text:SetWordWrap(false)
		elseif autowidth > fixedwidth then
			LocationPlusPanel:Width(autowidth)
			LocationPlusPanel.Text:Width(autowidth)
		end
	end
end

function LPB:UpdateCoords()
	local x, y = CreateCoords()
	local xt,yt

	if (x == 0 or x == nil) and (y == 0 or y == nil) then
		XCoordsPanel.Text:SetText("-")
		YCoordsPanel.Text:SetText("-")
	else
		if x < 10 then
			xt = "0"..x
		else
			xt = x
		end

		if y < 10 then
			yt = "0"..y
		else
			yt = y
		end
		XCoordsPanel.Text:SetText(xt)
		YCoordsPanel.Text:SetText(yt)
	end
end

-- Coord panels width
function LPB:CoordsDigit()
	if E.db.locplus.dig then
		XCoordsPanel:Width(COORDS_WIDTH*1.5)
		YCoordsPanel:Width(COORDS_WIDTH*1.5)
	else
		XCoordsPanel:Width(COORDS_WIDTH)
		YCoordsPanel:Width(COORDS_WIDTH)
	end
end

function LPB:CoordsColor()
	if E.db.locplus.customCoordsColor == 1 then
		XCoordsPanel.Text:SetTextColor(unpackColor(E.db.locplus.userColor))
		YCoordsPanel.Text:SetTextColor(unpackColor(E.db.locplus.userColor))
	elseif E.db.locplus.customCoordsColor == 2 then
		XCoordsPanel.Text:SetTextColor(classColor.r, classColor.g, classColor.b)
		YCoordsPanel.Text:SetTextColor(classColor.r, classColor.g, classColor.b)
	else
		XCoordsPanel.Text:SetTextColor(unpackColor(E.db.locplus.userCoordsColor))
		YCoordsPanel.Text:SetTextColor(unpackColor(E.db.locplus.userCoordsColor))
	end
end

-- Datatext panels
local function CreateDTPanels()

	-- Left coords Datatext panel
	left_dtp:Width(E.db.locplus.dtwidth)
	left_dtp:Height(E.db.locplus.dtheight)
	left_dtp:SetFrameStrata("LOW")
	left_dtp:SetParent(LocationPlusPanel)

	-- Right coords Datatext panel
	right_dtp:Width(E.db.locplus.dtwidth)
	right_dtp:Height(E.db.locplus.dtheight)
	right_dtp:SetFrameStrata("LOW")
	right_dtp:SetParent(LocationPlusPanel)
end

-- Update changes
function LPB:LocPlusUpdate()
	self:TransparentPanels()
	self:ShadowPanels()
	self:DTHeight()
	HideDT()
	self:CoordsDigit()
	self:MouseOver()
	self:HideCoords()
end

-- Defaults in case something is wrong on first load
function LPB:LocPlusDefaults()
	if E.db.locplus.lpwidth == nil then
		E.db.locplus.lpwidth = 200
	end

	if E.db.locplus.dtwidth == nil then
		E.db.locplus.dtwidth = 100
	end

	if E.db.locplus.dtheight == nil then
		E.db.locplus.dtheight = 21
	end
end

function LPB:ToggleBlizZoneText()
	if E.db.locplus.zonetext then
		ZoneTextFrame:UnregisterAllEvents()
	else
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED")
	end
end

function LPB:TimerUpdate()
	self:ScheduleRepeatingTimer("UpdateCoords", E.db.locplus.timer)
end

-- needed to fix LocPlus datatext font
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		LPB:ChangeFont()
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

function LPB:Initialize()
	self:LocPlusDefaults()
	CreateLocPanel()
	CreateDTPanels()
	CreateCoordPanels()
	self:LocPlusUpdate()
	self:TimerUpdate()
	self:ToggleBlizZoneText()
	self:ScheduleRepeatingTimer("UpdateLocation", 0.5)
	EP:RegisterPlugin("ElvUI_LocPlus", LPB.AddOptions)
	LocationPlusPanel:RegisterEvent("PLAYER_REGEN_DISABLED")
	LocationPlusPanel:RegisterEvent("PLAYER_REGEN_ENABLED")

	if E.db.locplus.LoginMsg then
		print(L["Location Plus "]..format("v|cff33ffff%s|r",LPB.version)..L[" is loaded. Thank you for using it."])
	end
end

E:RegisterModule(LPB:GetName())
