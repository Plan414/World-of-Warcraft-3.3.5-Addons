local Libra = LibStub("Libra")
local Type, Version = "Dropdown", 13
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Dropdown = Libra.modules[Type]
Dropdown.Prototype = Dropdown.Prototype or CreateFrame("Frame")
Dropdown.MenuPrototype = Dropdown.MenuPrototype or setmetatable({}, {__index = Dropdown.Prototype})
Dropdown.FramePrototype = Dropdown.FramePrototype or setmetatable({}, {__index = Dropdown.Prototype})
Dropdown.objects = Dropdown.objects or {}
Dropdown.listData = Dropdown.listData or {}
Dropdown.hookedLists = Dropdown.hookedLists or {}
Dropdown.hookedButtons = Dropdown.hookedButtons or {}
Dropdown.secureButtons = Dropdown.secureButtons or {}
Dropdown.secureBin = Dropdown.secureBin or {}

local menuMT = {__index = Dropdown.MenuPrototype}
local frameMT = {__index = Dropdown.FramePrototype}

local Prototype = Dropdown.Prototype
local MenuPrototype = Dropdown.MenuPrototype
local FramePrototype = Dropdown.FramePrototype
local objects = Dropdown.objects
local listData = Dropdown.listData

local function setHeight() end

local function constructor(self, type, parent, name)
	local dropdown
	if type == "Menu" then
		-- adding a SetHeight dummy lets us use a simple table instead of a frame, no side effects noticed so far
		dropdown = setmetatable({}, menuMT)
		dropdown:SetDisplayMode("MENU")
		dropdown.SetHeight = setHeight
		dropdown.xOffset = 0
		dropdown.yOffset = 0
	end
	if type == "Frame" then
		name = name or Libra:GetWidgetName(self.name)
		dropdown = setmetatable(CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate"), frameMT)
		dropdown:SetWidth(115)
		dropdown.label = dropdown:CreateFontString(name.."Label", "BACKGROUND", "GameFontNormalSmall")
		dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
	end
	
	objects[dropdown] = true
	
	return dropdown
end


local methods = {
	Refresh = UIDropDownMenu_Refresh,
}

for k, v in pairs(methods) do
	Prototype[k] = v
end

function Prototype:AddButton(info, level)
	info.owner = self
	if info.icon and not info.iconOnly then
		-- hack to properly increase button width for icon when .iconOnly is not set
		info.padding = (info.padding or 0) + 10
	end
	self.displayMode = self._displayMode
	self.selectedName = self._selectedName
	self.selectedValue = self._selectedValue
	self.selectedID = self._selectedID
	UIDropDownMenu_AddButton(info, level)
	self.displayMode = nil
	self.selectedName = nil
	self.selectedValue = nil
	self.selectedID = nil
end

function Prototype:ToggleMenu(value, anchorName, xOffset, yOffset, menuList, level, ...)
	ToggleDropDownMenu(level, value, self, anchorName, xOffset, yOffset, menuList, ...)
end

function Prototype:RebuildMenu(level)
	level = level or 1
	if self:IsMenuShown(level) then
		-- hiding a menu will also hide all deeper level menus, so we'll check which ones are open and restore them afterwards
		local maxLevel
		for i = level, UIDROPDOWNMENU_MENU_LEVEL do
			if _G["DropDownList"..i]:IsShown() then
				maxLevel = i
			else
				break
			end
		end
		self:HideMenu(level)
		for i = level, maxLevel do
			local listData = listData[i]
			-- set .rebuild to indicate that we don't want to reset the scroll offset on the next ToggleDropDownMenu
			self.rebuild = true
			self:ToggleMenu(listData.value, listData.anchorName, listData.xOffset, listData.yOffset, listData.menuList, i, listData.button, listData.autoHideDelay)
		end
	end
end

function Prototype:HideMenu(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		HideDropDownMenu(level)
	end
end

function Prototype:CloseMenus(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		CloseDropDownMenus(level)
	end
end

function Prototype:IsMenuShown(level)
	level = level or 1
	local listFrame = _G["DropDownList"..level]
	return UIDropDownMenu_GetCurrentDropDown() == self and listFrame and listFrame:IsShown()
end

function Prototype:SetSelectedName(name, useValue)
	self._selectedName = name
	self._selectedValue = nil
	self._selectedID = nil
	self.selectedName = name
	self:Refresh(useValue)
	self.selectedName = nil
end

function Prototype:SetSelectedValue(value, useValue)
	self._selectedValue = value
	self._selectedName = nil
	self._selectedID = nil
	self.selectedValue = value
	self:Refresh(useValue)
	self.selectedValue = nil
end

function Prototype:SetSelectedID(id, useValue)
	self._selectedID = id
	self._selectedName = nil
	self._selectedValue = nil
	self.selectedID = id
	self:Refresh(useValue)
	self.selectedID = nil
end

function Prototype:GetSelectedName()
	return self._selectedName
end

function Prototype:GetSelectedValue()
	return self._selectedValue
end

function Prototype:GetSelectedID()
	if self._selectedID then
		return self._selectedID
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		for i=1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
			-- See if checked or not
			if self:GetSelectedName() then
				if button:GetText() == self:GetSelectedName() then
					return i
				end
			elseif self:GetSelectedValue() then
				if button.value == self:GetSelectedValue() then
					return i
				end
			end
		end
	end
end

function Prototype:SetDisplayMode(mode)
	self._displayMode = mode
end


local menuMethods = {
	Toggle = Prototype.ToggleMenu,
	Rebuild = Prototype.RebuildMenu,
	Hide = Prototype.HideMenu,
	Close = Prototype.CloseMenus,
	IsShown = Prototype.IsMenuShown,
}

for k, v in pairs(menuMethods) do
	MenuPrototype[k] = v
end


local frameMethods = {
	Enable = UIDropDownMenu_EnableDropDown,
	Disable = UIDropDownMenu_DisableDropDown,
	IsEnabled = UIDropDownMenu_IsEnabled,
	JustifyText = UIDropDownMenu_JustifyText,
	SetButtonWidth = UIDropDownMenu_SetButtonWidth,
	SetText = UIDropDownMenu_SetText,
	GetText = UIDropDownMenu_GetText,
}

for k, v in pairs(frameMethods) do
	FramePrototype[k] = v
end

local setWidth = Prototype.SetWidth

function FramePrototype:SetWidth(width, padding)
	_G[self:GetName().."Middle"]:SetWidth(width)
	local defaultPadding = 25
	if padding then
		setWidth(self, width + padding)
		_G[self:GetName().."Text"]:SetWidth(width)
	else
		setWidth(self, width + defaultPadding + defaultPadding)
		_G[self:GetName().."Text"]:SetWidth(width - defaultPadding)
	end
	self.noResize = 1
end

function FramePrototype:SetLabel(text)
	self.label:SetText(text)
end

function FramePrototype:SetEnabled(enable)
	if enable then
		self:Enable()
	else
		self:Disable()
	end
end


local numShownButtons

local function update(level)
	local scroll = listData[level].scroll
	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..level.."Button"..i]
		local _, _, _, x, y = button:GetPoint()
		local y = -((button:GetID() - 1 - scroll) * UIDROPDOWNMENU_BUTTON_HEIGHT) - UIDROPDOWNMENU_BORDER_HEIGHT
		button:SetPoint("TOPLEFT", x, y)
		button:SetShown(i > scroll and i <= (numShownButtons + scroll))
	end
	Dropdown.scrollButtons[level].up:SetShown(scroll > 0)
	Dropdown.scrollButtons[level].down:SetShown(scroll < _G["DropDownList"..level].numButtons - numShownButtons)
end

local function scroll(self, delta)
	local level = self:GetID()
	local listData = listData[level]
	delta = (type(delta) == "number" and delta or self.delta)
	if IsShiftKeyDown() then delta = delta * (numShownButtons - 1) end
	listData.scroll = listData.scroll - (type(delta) == "number" and delta or self.delta)
	listData.scroll = min(listData.scroll, (self.numButtons or self:GetParent().numButtons) - numShownButtons)
	listData.scroll = max(listData.scroll, 0)
	update(level)
end

local scrollScripts = {
	OnEnter = function(self)
		UIDropDownMenu_StopCounting(self:GetParent())
	end,
	OnLeave = function(self)
		UIDropDownMenu_StartCounting(self:GetParent())
	end,
	OnMouseDown = function(self)
		self.texture:SetPoint("CENTER", 1, -1)
	end,
	OnMouseUp = function(self)
		self.texture:SetPoint("CENTER")
	end,
	OnHide = function(self)
		self.texture:SetPoint("CENTER")
		-- explicitly hide so that they are hidden for unmanaged dropdowns
		self:Hide()
	end,
}

local function createScrollButton(listFrame)
	local level = listFrame:GetID()
	local button = CreateFrame("Button", nil, listFrame)
	button:SetSize(16, 16)
	button:SetScript("OnClick", scroll)
	for script, handler in pairs(scrollScripts) do
		button:SetScript(script, handler)
	end
	button:SetID(level)
	button.texture = button:CreateTexture()
	button.texture:SetSize(16, 16)
	button.texture:SetPoint("CENTER")
	button.texture:SetTexture([[Interface\Calendar\MoreArrow]])
	return button
end

local function createScrollButtons(listFrame)
	local scrollUp = listFrame.scrollUp or createScrollButton(listFrame)
	scrollUp:SetPoint("TOP")
	scrollUp.delta = 1
	scrollUp.texture:SetTexCoord(0, 1, 1, 0)
	listFrame.scrollUp = scrollUp
	
	local scrollDown = listFrame.scrollDown or createScrollButton(listFrame)
	scrollDown:SetPoint("BOTTOM")
	scrollDown.delta = -1
	listFrame.scrollDown = scrollDown
end

Dropdown.scrollButtons = Dropdown.scrollButtons or setmetatable({}, {
	__index = function(self, level)
		local listFrame = _G["DropDownList"..level]
		createScrollButtons(listFrame)
		self[level] = {
			up = listFrame.scrollUp,
			down = listFrame.scrollDown,
		}
		return self[level]
	end,
})

function Dropdown:ToggleDropDownMenuHook(level, value, dropdownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	level = level or 1
	if level ~= 1 then
		dropdownFrame = dropdownFrame or UIDROPDOWNMENU_OPEN_MENU
	end
	local listFrameName = "DropDownList"..level
	local listFrame = _G[listFrameName]
	if not objects[dropdownFrame] then return end
	if dropdownFrame and dropdownFrame._displayMode == "MENU" then
		_G[listFrameName.."Backdrop"]:Hide()
		_G[listFrameName.."MenuBackdrop"]:Show()
	end
	
	-- store all parameters per level so we can use them to rebuild the menu
	listData[level] = listData[level] or {}
	local listData = listData[level]
	listData.value = value
	listData.anchorName = anchorName
	listData.xOffset = xOffset
	listData.yOffset = yOffset
	listData.menuList = menuList
	listData.button = button
	listData.autoHideDelay = autoHideDelay
	
	numShownButtons = dropdownFrame.numShownButtons or floor((UIParent:GetHeight() - UIDROPDOWNMENU_BORDER_HEIGHT * 2) / UIDROPDOWNMENU_BUTTON_HEIGHT)
	local scrollable = numShownButtons < listFrame.numButtons
	if scrollable then
		-- make scrollable
		listData.scroll = listData.scroll or 0
		if not dropdownFrame.rebuild then
			listData.scroll = 0
		end
		listFrame:SetScript("OnMouseWheel", scroll)
		listFrame:SetHeight((numShownButtons * UIDROPDOWNMENU_BUTTON_HEIGHT) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
		if listFrame:GetTop() > GetScreenHeight() then
			local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
			local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
			listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		end
		update(level)
	else
		if listFrame:GetTop() > GetScreenHeight() then
			local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
			local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
			listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		end
		listFrame:SetScript("OnMouseWheel", nil)
		self.scrollButtons[level].up:Hide()
		self.scrollButtons[level].down:Hide()
	end
	dropdownFrame.rebuild = nil
end

if not Dropdown.hookToggleDropDownMenu then
	hooksecurefunc("ToggleDropDownMenu", function(...)
		Dropdown:ToggleDropDownMenuHook(...)
	end)
	Dropdown.hookToggleDropDownMenu = true
end

function Dropdown:AddButtonHook(info, level)
	if not objects[UIDropDownMenu_GetCurrentDropDown()] then return end
	local listFrameName = "DropDownList"..(level or 1)
	local listFrame = _G[listFrameName]
	local button = _G[listFrameName.."Button"..(listFrame.numButtons)]
	button.onEnter = info.onEnter
	button.onLeave = info.onLeave
	button.tooltipLines = info.tooltipLines
	if info.attributes and not InCombatLockdown() then
		local secureButton = self.secureBin[1]
		tremove(Dropdown.secureBin, 1)
		-- since this is a separate button, we need to set the disabled state on it too
		secureButton:SetEnabled(not info.disabled)
		secureButton:SetParent(button)
		secureButton:SetAllPoints()
		secureButton:Show()
		-- clear existing attributes
		for attribute in pairs(secureButton.attributes) do
			secureButton:SetAttribute(attribute, nil)
			secureButton.attributes[attribute] = nil
		end
		for attribute, value in pairs(info.attributes) do
			secureButton:SetAttribute(attribute, value)
			secureButton.attributes[attribute] = true
		end
		tinsert(Dropdown.secureButtons, secureButton)
	end
end

if not Dropdown.hookAddButton then
	hooksecurefunc("UIDropDownMenu_AddButton", function(...)
		Dropdown:AddButtonHook(...)
	end)
	Dropdown.hookAddButton = true
end

local function onEnter(self)
	if self.onEnter then
		self:onEnter()
	elseif self.tooltipLines and self.tooltipTitle then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.tooltipTitle, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		if self.tooltipText then
			for line in self.tooltipText:gmatch("[^\n]+") do
				GameTooltip:AddLine(line)
			end
		end
		GameTooltip:Show()
	end
end

local function onLeave(self)
	if self.onLeave then
		self:onLeave()
	end
end

local function invisibleButtonOnEnter(self)
	local parent = self:GetParent()
	if parent.onEnter or parent.tooltipWhileDisabled then
		onEnter(parent)
	end
end

local function invisibleButtonOnLeave(self)
	local parent = self:GetParent()
	if parent.onLeave or parent.tooltipWhileDisabled then
		onLeave(parent)
	end
end

function Dropdown:HideListHook(self)
	if not InCombatLockdown() then
		for i = #Dropdown.secureButtons, 1, -1 do
			-- hide secure buttons attached to this list frame
			local button = Dropdown.secureButtons[i]
			if button:GetParent():GetParent() == self then
				Dropdown:DismissSecureButton(button)
				tremove(Dropdown.secureButtons, i)
			end
		end
	end
	if objects[UIDropDownMenu_GetCurrentDropDown()] then
		self:SetScript("OnMouseWheel", nil)
	end
end

local function listOnHide(self)
	Dropdown:HideListHook(self)
end

function Dropdown:CreateFramesHook(numLevels, numButtons)
	for level = 1, numLevels do
		if not self.hookedLists[level] then
			_G["DropDownList"..level]:HookScript("OnHide", listOnHide)
			self.hookedLists[level] = true
		end
		self.hookedButtons[level] = self.hookedButtons[level] or {}
		for i = 1, numButtons do
			if not self.hookedButtons[level][i] then
				local button = _G["DropDownList"..level.."Button"..i]
				button:HookScript("OnEnter", onEnter)
				button:HookScript("OnLeave", onLeave)
				button.invisibleButton:HookScript("OnEnter", invisibleButtonOnEnter)
				button.invisibleButton:HookScript("OnLeave", invisibleButtonOnLeave)
				self.hookedButtons[level][i] = true
			end
		end
	end
end

if not Dropdown.hookCreateFrames then
	Dropdown:CreateFramesHook(UIDROPDOWNMENU_MAXLEVELS, UIDROPDOWNMENU_MAXBUTTONS)
	hooksecurefunc("UIDropDownMenu_CreateFrames", function(...)
		Dropdown:CreateFramesHook(...)
	end)
	Dropdown.hookCreateFrames = true
end

-- script handlers to mimic regular dropdown button behaviour
local scripts = {
	PreClick = function(self)
		local parent = self:GetParent()
		parent:GetScript("OnClick")(parent)
	end,
	OnMouseDown = function(self)
		self:GetParent():SetButtonState("PUSHED")
	end,
	OnMouseUp = function(self)
		self:GetParent():SetButtonState("NORMAL")
	end,
	OnEnter = function(self)
		local parent = self:GetParent()
		parent:GetScript("OnEnter")(parent)
	end,
	OnLeave = function(self)
		local parent = self:GetParent()
		parent:GetScript("OnLeave")(parent)
	end,
}

setmetatable(Dropdown.secureBin, {
	__index = function(self, index)
		local button = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
		for script, handler in pairs(scripts) do
			button:SetScript(script, handler)
		end
		button.attributes = {}
		return button
	end,
})

function Dropdown:DismissSecureButton(button)
	button:Hide()
	button:ClearAllPoints()
	button:SetParent(nil)
	tinsert(Dropdown.secureBin, button)
end

Dropdown.frame = Dropdown.frame or CreateFrame("Frame")
Dropdown.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
Dropdown.frame:SetScript("OnEvent", function(self)
	for i, button in ipairs(Dropdown.secureButtons) do
		Dropdown:DismissSecureButton(button)
	end
	wipe(Dropdown.secureButtons)
end)

Libra:RegisterModule(Type, Version, constructor)