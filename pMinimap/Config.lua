local SharedMedia = LibStub('LibSharedMedia-3.0')

local group, slider, dropdown, checkbox = LibStub('tekKonfig-Group'), LibStub('tekKonfig-Slider'), LibStub('tekKonfig-Dropdown'), LibStub('tekKonfig-Checkbox')

local function updateStrings()
	local font, size, flag = SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag

	MiniMapMailText:SetFont(font, size, flag)
	MinimapZoneText:SetFont(font, size, flag)
	MinimapCoordinatesText:SetFont(font, size, flag)

	if(pMinimapDB.clock) then
		TimeManagerClockTicker:SetFont(font, size, flag)
	end
end

local function dropStrata(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimapDB.strata = self.value
		Minimap:SetFrameStrata(self.value)
		orig.text:SetText(self.value)
	end

	for k, v in next, {'DIALOG', 'HIGH', 'MEDIUM', 'LOW', 'BACKGROUND'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropZone(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimapDB.zonepoint = self.value
		MinimapZoneTextButton:ClearAllPoints()
		if(pMinimapDB.zonefixed) then
			MinimapZoneTextButton:SetPoint(self.value == 'BOTTOM' and 'BOTTOMLEFT' or 'TOPLEFT', Minimap, 0, pMinimapDB.zoneoffset)
			MinimapZoneTextButton:SetPoint(self.value == 'BOTTOM' and 'BOTTOMRIGHT' or 'TOPRIGHT', Minimap, 0, pMinimapDB.zoneoffset)
		else
			MinimapZoneTextButton:SetPoint(self.value, Minimap, 0, pMinimapDB.zoneoffset)
			MinimapZoneTextButton:SetWidth(Minimap:GetWidth() * 1.5)
		end
		orig.text:SetText(self.value)
	end

	for k, v in next, {'TOP', 'BOTTOM'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropFont(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimapDB.font = self.value
		orig.text:SetText(self.value)
		updateStrings()
	end

	for k, v in next, SharedMedia:List('font') do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropFontflag(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimapDB.fontflag = self.value
		updateStrings()
		orig.text:SetText(self.value)
	end

	for k, v in next, {'OUTLINE', 'THICKOUTLINE', 'MONOCHROME', 'NONE'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function config(self)
	local header = LibStub('tekKonfig-Heading').new(self, self.name)

	local info = self:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
	info:SetPoint('TOPLEFT', header, 0, 100)
	info:SetWidth(300)
	info:SetHeight(400)
	info:SetText('Use the colums in the menu to the left to access the options.\n\nThis is most likely temporary, and will be cleaned up later.\n\n\nPlease visit the addon page over at\n|cff8080ffhttp://wowinterface.com/|r for more information and to ask for questions/report bugs.\n\nEnjoy!')
end

local function minimap(self)
	local scale, scaletext = slider.new(self, format('Scale: %.2f', pMinimapDB.scale), 0.5, 2.5, 'TOPLEFT', self, 15, -15)
	scale:SetValueStep(0.01)
	scale:SetValue(pMinimapDB.scale)
	scale:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.scale = value
		scaletext:SetFormattedText('Scale: %.2f', value)
		Minimap:SetScale(value)
	end)

	local level, leveltext = slider.new(self, 'Framelevel: '..pMinimapDB.level, 1, 15, 'TOPLEFT', scale, 'BOTTOMLEFT', 0, -30)
	level:SetValueStep(1)
	level:SetValue(pMinimapDB.level)
	level:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.level = value
		leveltext:SetFormattedText('Framelevel: %d', value)
		pMinimap:SetFrameLevel(value)
	end)

	local strata, stratatext = dropdown.new(self, 'Framestrata', 'LEFT', scale, 'RIGHT', 40, 0)
	strata.text = stratatext
	strata.text:SetText(pMinimapDB.strata)
	UIDropDownMenu_Initialize(strata, dropStrata)

	local lock = checkbox.new(self, 22, 'Locked', 'LEFT', level, 'RIGHT', 45, 0)
	lock:SetChecked(not pMinimap.unlocked)
	lock:SetScript('OnClick', function()
		pMinimap.unlocked = not pMinimap.unlocked

		if(pMinimap.unlocked) then
			Minimap:SetBackdropColor(0, 1, 0, 0.5)
		else
			Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
		end
	end)
end

local function modules(self)
	local coordinates = checkbox.new(self, 22, 'Coordinates', 'TOPLEFT', self, 10, -10)
	coordinates:SetChecked(pMinimapDB.coordinates)
	coordinates:SetScript('OnClick', function()
		pMinimapDB.coordinates = not pMinimapDB.coordinates

		if(pMinimapDB.coordinates) then
			MinimapCoordinates:Show()
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		else
			MinimapCoordinates:Hide()
		end

		if(pMinimapDB.clock) then
			TimeManagerClockButton:ClearAllPoints()
			TimeManagerClockButton:SetPoint(pMinimapDB.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
		end
	end)

	local coordinatesdecimals, cdtext = slider.new(self, 'Coord Decimals: '..pMinimapDB.coordinatesdecimals, 0, 3, 'TOPRIGHT', self, -15, -15)
	coordinatesdecimals:SetValueStep(1)
	coordinatesdecimals:SetValue(pMinimapDB.coordinatesdecimals)
	coordinatesdecimals:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.coordinatesdecimals = value
		cdtext:SetFormattedText('Coord Decimals: %d', value)
	end)

	local clock = checkbox.new(self, 22, 'Clock', 'TOPLEFT', coordinates, 'BOTTOMLEFT', 0, -10)
	clock:SetChecked(pMinimapDB.clock)
	clock:SetScript('OnClick', function()
		pMinimapDB.clock = not pMinimapDB.clock

		if(pMinimapDB.clock) then
			if(not pMinimap:IsEventRegistered('CALENDAR_UPDATE_PENDING_INVITES')) then
				pMinimap:Clock()
			else
				TimeManagerClockButton:ClearAllPoints()
				TimeManagerClockButton:SetPoint(pMinimapDB.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
				TimeManagerClockButton:SetScript('OnShow', nil)
				TimeManagerClockButton:Show()
			end
		else
			TimeManagerClockButton:Hide()
			TimeManagerClockButton:SetScript('OnShow', pMinimap.ClockHook)
		end

		if(pMinimapDB.coordinates) then
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		end
	end)

	local mail = checkbox.new(self, 22, 'Mail', 'TOPLEFT', clock, 'BOTTOMLEFT', 0, -10)
	mail:SetChecked(pMinimapDB.mail)
	mail:SetScript('OnClick', function()
		pMinimapDB.mail = not pMinimapDB.mail

		if(pMinimapDB.mail) then
			MiniMapMailIcon:Hide()
			MiniMapMailText:Show()
		else
			MiniMapMailIcon:Show()
			MiniMapMailText:Hide()
		end
	end)

	local durability = checkbox.new(self, 22, 'Durability', 'LEFT', mail, 'RIGHT', 110, 0)
	durability:SetChecked(pMinimapDB.durability)
	durability:SetScript('OnClick', function()
		pMinimapDB.durability = not pMinimapDB.durability

		if(pMinimapDB.durability) then
			DurabilityFrame:SetAlpha(0)
			pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
			pMinimap:UPDATE_INVENTORY_ALERTS()
		else
			DurabilityFrame:SetAlpha(1)
			pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
			Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
		end
	end)
end

local function background(self)
	local borderoffset, borderoffsettext = slider.new(self, 'Thickness: '..pMinimapDB.borderoffset, 0, 10, 'TOPLEFT', self, 15, -15)
	borderoffset:SetValueStep(1/2)
	borderoffset:SetValue(pMinimapDB.borderoffset)
	borderoffset:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.borderoffset = value
		borderoffsettext:SetFormattedText('Thickness: %.1f', value)
		Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -value, bottom = -value, left = -value, right = -value}})
		Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
	end)

	-- todo: color palette
end

local function zone(self)
	local zone = checkbox.new(self, 22, 'Zone Toggle', 'TOPLEFT', self, 10, -10)
	zone:SetChecked(pMinimapDB.zone)
	zone:SetScript('OnClick', function()
		pMinimapDB.zone = not pMinimapDB.zone

		if(pMinimapDB.zone) then
			MinimapZoneTextButton:Show()
		else
			MinimapZoneTextButton:Hide()
		end
	end)

	local zonepoint, zonepointtext = dropdown.new(self, 'Zone Point', 'TOPLEFT', zone, 'BOTTOMLEFT')
	zonepoint.text = zonepointtext
	zonepoint.text:SetText(pMinimapDB.zonepoint)
	UIDropDownMenu_Initialize(zonepoint, dropZone)

	local zoneoffset, zoneoffsettext = slider.new(self, 'Zone Offset: '..pMinimapDB.zoneoffset, -45, 45, 'TOPRIGHT', self, -15, -15)
	zoneoffset:SetValueStep(1)
	zoneoffset:SetValue(pMinimapDB.zoneoffset)
	zoneoffset:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.zoneoffset = value
		zoneoffsettext:SetFormattedText('Zone Offset: %d', value)

		MinimapZoneTextButton:ClearAllPoints()
		if(pMinimapDB.zonefixed) then
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMLEFT' or 'TOPLEFT', Minimap, 0, value)
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMRIGHT' or 'TOPRIGHT', Minimap, 0, value)
		else
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint, Minimap, 0, value)
			MinimapZoneTextButton:SetWidth(Minimap:GetWidth() * 1.5)
		end
	end)

	local zonefixed = checkbox.new(self, 22, 'Zone Fixed Width', 'TOPLEFT', zonepoint, 'BOTTOMLEFT', 10, -10)
	zonefixed:SetChecked(pMinimapDB.zonefixed)
	zonefixed:SetScript('OnClick', function()
		pMinimapDB.zonefixed = not pMinimapDB.zonefixed

		MinimapZoneTextButton:ClearAllPoints()
		if(pMinimapDB.zonefixed) then
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMLEFT' or 'TOPLEFT', Minimap, 0, pMinimapDB.zoneoffset)
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'BOTTOM' and 'BOTTOMRIGHT' or 'TOPRIGHT', Minimap, 0, pMinimapDB.zoneoffset)
		else
			MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint, Minimap, 0, pMinimapDB.zoneoffset)
			MinimapZoneTextButton:SetWidth(Minimap:GetWidth() * 1.5)
		end

		zoneoffset:GetScript('OnValueChanged')(self, pMinimapDB.zoneoffset)
	end)
end

local function fonts(self)
	local font, fonttext, fontcontainer = dropdown.new(self, 'Font', 'TOPLEFT', self, 10, -4)
	font:SetWidth(180)
	font.text = fonttext
	font.text:SetText(pMinimapDB.font)
	UIDropDownMenu_Initialize(font, dropFont)

	local fontflag, fontflagtext = dropdown.new(self, 'Font Flag', 'TOPLEFT', font, 'BOTTOMLEFT', 15, 0)
	fontflag:SetWidth(180)
	fontflag.text = fontflagtext
	fontflag.text:SetText(pMinimapDB.fontflag)
	UIDropDownMenu_Initialize(fontflag, dropFontflag)

	local fontsize, fontsizetext = slider.new(self, 'Font Size'..pMinimapDB.fontsize, 5, 18, 'TOPRIGHT', self, -15, -15)
	fontsize:SetValueStep(1)
	fontsize:SetValue(pMinimapDB.fontsize)
	fontsize:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.fontsize = value
		fontsizetext:SetFormattedText('Font Size: %d', value)
		updateStrings()
	end)
end

local function spawn(name, func, parent)
	local group = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
	group.name = name
	group.parent = parent and 'pMinimap'
	group.addonname = parent and 'pMinimap'
	group:SetScript('OnShow', func)
	group:HookScript('OnShow', function(self) self:SetScript('OnShow', nil) end)

	InterfaceOptions_AddCategory(group)
	return group
end

spawn('pMinimap', config):Hide()
spawn('Minimap', minimap, true)
spawn('Modules', modules, true)
spawn('Background', background, true)
spawn('Zone', zone, true)
spawn('Fonts', fonts, true)
