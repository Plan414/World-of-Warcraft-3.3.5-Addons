--[[

 Copyright (c) 2009, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local addon = CreateFrame('Frame', 'pMinimap', Minimap)
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
addon:RegisterEvent('ADDON_LOADED')

local SharedMedia = LibStub('LibSharedMedia-3.0')
local defaults = {
	font = 'Visitor TT1',
	fontsize = 13,
	fontflag = 'OUTLINE',
	zone = false,
	zonepoint = 'TOP',
	zoneoffset = 16,
	zonefixed = false,
	scale = 0.9,
	level = 2,
	strata = 'BACKGROUND',
	borderoffset = 1,
	bordercolors = {0, 0, 0, 1},
	mail = true,
	clock = true,
	durabilty = true,
	coordinates = false,
	coordinatesdecimals = 0,
}

function addon:ClockHook()
	self:Hide()
end

function addon:Clock()
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint(pMinimapDB.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
	TimeManagerClockButton:SetWidth(40)
	TimeManagerClockButton:SetHeight(14)
	TimeManagerClockButton:SetScript('OnShow', nil)
	TimeManagerClockButton:Show()
	TimeManagerClockButton:SetScript('OnClick', function(self, button)
		if(button == 'RightButton') then
			ToggleCalendar()
		else
			if(self.alarmFiring) then
				PlaySound('igMainMenuQuit')
				TimeManager_TurnOffAlarm()
			else
				ToggleTimeManager()
			end
		end
	end)

	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	TimeManagerClockTicker:SetShadowOffset(0, 0)

	TimeManagerAlarmFiredTexture.Show = function() TimeManagerClockTicker:SetTextColor(1, 0, 0) end
	TimeManagerAlarmFiredTexture.Hide = function() TimeManagerClockTicker:SetTextColor(1, 1, 1) end

	self:RegisterEvent('CALENDAR_UPDATE_PENDING_INVITES')
	self.CALENDAR_UPDATE_PENDING_INVITES()
end

function addon:OnClick(button)
	if(button == 'RightButton') then
		ToggleBattlefieldMinimap()
	else
		ToggleFrame(WorldMapFrame)
	end
end

function addon:OnUpdate(elapsed)
	if(self.total <= 0) then
		local x, y = GetPlayerMapPosition('player')
		if(x ~= 0 and y ~= 0) then
			MinimapCoordinatesText:SetFormattedText('%.' .. pMinimapDB.coordinatesdecimals .. 'f,%.' .. pMinimapDB.coordinatesdecimals .. 'f', x * 100, y * 100)
		else
			MinimapCoordinatesText:SetText()
		end

		self.total = 0.25
	else
		self.total = self.total - elapsed
	end
end

function addon:Style()
	-- Mousewheel zoom
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', function(self, direction)
		if(direction > 0) then
			MinimapZoomIn:Click()
		else
			MinimapZoomOut:Click()
		end
	end)

	-- Tracking icon
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:SetPoint('TOPLEFT', -2, 2)
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:SetTexture(nil)
	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingIconOverlay:SetTexture(nil)
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)

	-- LFG
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:SetPoint('BOTTOMLEFT', -2, -2)
	MiniMapLFGFrameBorder:Hide()

	-- Battlefield icon
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', -2, -2)
	MiniMapBattlefieldBorder:SetTexture(nil)
	BattlegroundShine:Hide()

	-- Mail text
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOP', 0, -4)
	MiniMapMailFrame:SetHeight(8)
	MiniMapMailBorder:SetTexture(nil)

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	MiniMapMailText:SetTextColor(1, 1, 1)
	MiniMapMailText:SetText('New Mail!')

	if(pMinimapDB.mail) then
		MiniMapMailIcon:Hide()
	else
		MiniMapMailText:Hide()
	end

	-- Coordinates
	MinimapCoordinates = CreateFrame('Button', nil, Minimap)
	MinimapCoordinates:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM')
	MinimapCoordinates:SetWidth(40)
	MinimapCoordinates:SetHeight(14)
	MinimapCoordinates:RegisterForClicks('AnyUp')
	MinimapCoordinates:SetScript('OnClick', self.OnClick)
	MinimapCoordinates:SetScript('OnUpdate', self.OnUpdate)
	MinimapCoordinates.total = 0.25

	MinimapCoordinatesText = MinimapCoordinates:CreateFontString(nil, 'OVERLAY')
	MinimapCoordinatesText:SetPoint('BOTTOMRIGHT', MinimapCoordinates)
	MinimapCoordinatesText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	MinimapCoordinatesText:SetTextColor(1, 1, 1)

	if(not pMinimapDB.coordinates) then
		MinimapCoordinates:Hide()
	end

	-- Zone text
	MinimapZoneText:SetAllPoints(MinimapZoneTextButton)
	MinimapZoneText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	MinimapZoneText:SetShadowOffset(0, 0)

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetParent(Minimap)

	if(not pMinimapDB.zone) then
		MinimapZoneTextButton:Hide()
	end

	if(pMinimapDB.zonefixed) then
		MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMLEFT' or 'TOPLEFT', Minimap, 0, pMinimapDB.zoneoffset)
		MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMRIGHT' or 'TOPRIGHT', Minimap, 0, pMinimapDB.zoneoffset)
	else
		MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint, Minimap, 0, pMinimapDB.zoneoffset)
		MinimapZoneTextButton:SetWidth(Minimap:GetWidth() * 1.5)
	end

	-- Misc textures/icons/texts
	MinimapBorder:SetTexture(nil)
	MinimapBorderTop:Hide()
	MinimapNorthTag:SetAlpha(0)
	MiniMapInstanceDifficulty:SetAlpha(0)
	MiniMapWorldMapButton:Hide()
	GameTimeFrame:Hide()

	-- Inject settings
	Minimap:SetScale(pMinimapDB.scale)
	Minimap:SetFrameLevel(pMinimapDB.level)
	Minimap:SetFrameStrata(pMinimapDB.strata)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - pMinimapDB.borderoffset, bottom = - pMinimapDB.borderoffset, left = - pMinimapDB.borderoffset, right = - pMinimapDB.borderoffset}})
	Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))

	Minimap:RegisterForDrag('LeftButton')
	Minimap:SetMovable(true)
	Minimap:SetScript('OnDragStop', function() if(self.unlocked) then Minimap:StopMovingOrSizing() end end)
	Minimap:SetScript('OnDragStart', function() if(self.unlocked) then Minimap:StartMoving() end end)
	MinimapCluster:EnableMouse(false)

	-- Modules
	if(pMinimapDB.durability) then
		DurabilityFrame:SetAlpha(0)

		self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
		self:UPDATE_INVENTORY_ALERTS()
	end
end

function addon.Command(str)
	if(str == 'reset') then
		pMinimapDB = defaults
		print('|cffff8080pMinimap:|r Settings reset. You should reload/relog to affect changes.')
	else
		InterfaceOptionsFrame_OpenToCategory(addon:GetName())
	end
end

function addon:ADDON_LOADED(event, name)
	if(name == self:GetName()) then
		SharedMedia:Register('font', 'Visitor TT1', [=[Interface\AddOns\pMinimap\media\font.ttf]=])

		SLASH_pMinimap1 = '/pmm'
		SLASH_pMinimap2 = '/pminimap'
		SlashCmdList[name] = self.Command

		self.unlocked = false
		pMinimapDB = setmetatable(pMinimapDB or {}, {__index = defaults})
		self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		self:RegisterEvent('VARIABLES_LOADED')

		self:Style()
	elseif(name == 'Blizzard_TimeManager') then
		TimeManagerClockButton:SetScript('OnShow', self.ClockHook)
		TimeManagerClockButton:Hide()

		if(pMinimapDB.clock) then
			self:Clock()
		end

		for k, v in next, {InterfaceOptionsDisplayPanelShowClock} do
			v:SetButtonState('DISABLED', true)
		end
	end
end

function addon:VARIABLES_LOADED(event)
	SetCVar('showClock', '1')

	if(not IsAddOnLoaded('Blizzard_TimeManager')) then
		LoadAddOn('Blizzard_TimeManager')
	elseif(not self:IsEventRegistered('CALENDAR_UPDATE_PENDING_INVITES')) then
		self:ADDON_LOADED(event, 'Blizzard_TimeManager')
	end
end

function addon:CALENDAR_UPDATE_PENDING_INVITES()
	if(CalendarGetNumPendingInvites() ~= 0) then
		TimeManagerClockTicker:SetTextColor(0, 1, 0)
	else
		TimeManagerClockTicker:SetTextColor(1, 1, 1)
	end
end

function addon:UPDATE_INVENTORY_ALERTS()
	local highstatus = 0
	for k in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(k)
		highstatus = status > highstatus and status or highstatus
	end

	local color = INVENTORY_ALERT_COLORS[highstatus]
	if(color) then
		Minimap:SetBackdropColor(color.r, color.g, color.b)
	else
		Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
	end
end

function addon:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end

-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end
