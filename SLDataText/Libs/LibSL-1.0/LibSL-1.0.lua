--[[            LibSL-1.0 - Simple Light Library 				]]
--[[ Use to create & manage SLDT Modules without complication 	]]

local MAJOR, MINOR = "LibSL-1.0", 4
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if ( not lib ) then return end
local function err(msg) ChatFrame1:AddMessage(string.format("LibSL: %s", msg)) end

local diaBG, diaBor = "Interface\\DialogFrame\\UI-DialogBox-Background", "Interface\\DialogFrame\\UI-DialogBox-Border"
local toolBG, toolBor = "Interface\\Tooltips\\UI-Tooltip-Background", "Interface\\Tooltips\\UI-Tooltip-Border"
local solidBG = "Interface\\BUTTONS\\WHITE8X8"

local BGDia = { bgFile = diaBG, edgeFile = diaBor, insets = {left=4,right=4,top=4,bottom=4}, tile = true, tileSize = 16, edgeSize = 16, }
local BGSol = { bgFile = solidBG, edgeFile = diaBor, insets = {left=4,right=4,top=4,bottom=4}, tile = true, tileSize = 16, edgeSize = 16, }
local anchTbl = { [1] = "TOPLEFT", [2] = "TOP", [3] = "TOPRIGHT", [4] = "LEFT", [5] = "CENTER", [6] = "RIGHT", [7] = "BOTTOMLEFT", [8] = "BOTTOM", [9] = "BOTTOMRIGHT" }


--[[ ----------------------------------------------- ]]
--[[ Frame Movement Functions ---------------------- ]]
--[[ ----------------------------------------------- ]]
local function TransCoords(frame, aF, aP, x, y)
    local y1, x1
	-- Handle Y-axis
    if      ( aF == "TOP" or aF == "TOPLEFT" or aF == "TOPRIGHT" ) then                             	y1 = frame:GetHeight()/2; y = y - y1
    elseif  ( aF == "BOTTOM" or aF == "BOTTOMLEFT" or aF == "BOTTOMRIGHT" ) then                    	y1 = frame:GetHeight()/2; y = y + y1 end
	-- Handle X-axis
    if      ( aP == "RIGHT" 	and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then   x = x
    elseif  ( aP == "RIGHT" 	and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then      x1 = frame:GetWidth(); x = x + x1
    elseif  ( aP == "RIGHT" 	and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then            x1 = frame:GetWidth()/2; x = x + x1
    elseif  ( aP == "LEFT" 		and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then   x1 = frame:GetWidth(); x = x - x1
    elseif  ( aP == "LEFT" 		and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then      x = x
    elseif  ( aP == "LEFT" 		and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then            x1 = frame:GetWidth()/2; x = x - x1
    elseif  ( aP == "CENTER" 	and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then     	x1 = frame:GetWidth()/2; x = x + x1
    elseif  ( aP == "CENTER" 	and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then  	x1 = frame:GetWidth()/2; x = x - x1
    elseif  ( aP == "CENTER" 	and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then           	x = x end
    return x, y
end
function lib:MoveSLFrame(frame, db)
	frame:SetPoint(db.aP, db.anch, db.aF, db.xOff, db.yOff)
	frame:StartMoving()
end
function lib:StopSLFrame(frame, db, opt, title)
	frame:StopMovingOrSizing()
	local _, _, aF, x, y = frame:GetPoint()
	local anch = frame:GetParent():GetName()
	local xOff, yOff = TransCoords(frame, aF, db.aP, x, y)
	db["aP"], db["anch"], db["aF"], db["xOff"], db["yOff"] = db.aP, anch, aF, floor(xOff), floor(yOff)
	frame:ClearAllPoints(); frame:SetPoint(db.aP, db.anch, db.aF, db.xOff, db.yOff)
	
	-- Update applicable module menu accordingly
	local id
	for k, v in pairs(anchTbl) do if ( db["aF"] == v ) then id = k end end
	if ( opt ) then 
		UIDropDownMenu_SetSelectedID(opt["aF"], id)
		opt["anch"]:SetText(db.anch); opt["xOff"]:SetText(db.xOff); opt["yOff"]:SetText(db.yOff)
	end
end
--[[ ----------------------------------------------- ]]

--[[ ----------------------------------------------- ]]
--[[ Configuration Menu Functions ------------------ ]]
--[[ ----------------------------------------------- ]]
local function SliderMouse(self, delta)
	local min, max = self:GetMinMaxValues()
	local step = self:GetValueStep()
	local value = self:GetValue()

	if (value > min) and (delta < 0) then 
		value = (value - step)
		if (value > min) then self:SetValue( value ) else self:SetValue( min ) end
	end
	if (value < max) and (delta > 0) then
		value = (value + step)
		if (value < max) then self:SetValue( value ) else self:SetValue( max ) end
	end
end

local function NewCheckBox(owner, label, db, dbval, title, isGlobal)
	local box = CreateFrame("CheckButton", label.."CheckBox", owner.Opt, "InterfaceOptionsCheckButtonTemplate")
	box:SetSize(20,20)
	box:SetChecked(db[dbval])
	box.Text = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	box.Text:SetFont(box.Text:GetFont(), 11)
	box.Text:SetPoint("LEFT", box, "RIGHT", 6, 0)
	box.Text:SetJustifyH("LEFT")
	box.Text:SetText(title)
	
	box:SetScript("OnClick", function(self)
		PlaySound("GAMEGENERICBUTTONPRESS")
		
		if ( self:GetChecked() ) then
			db[dbval] = true; self:SetChecked(db[dbval])
		else
			db[dbval] = false; self:SetChecked(db[dbval])
		end
		
		if ( not isGlobal ) then SLDataText:UpdateBaseText(owner, db) end
		if ( dbval == "enabled" ) then
			if ( db[dbval] ) then
				owner:Enable()
			else
				owner:Disable()
			end
		else
			owner:Refresh()
		end
	end)
	
	return box
end

local function NewSlider(owner, label, db, dbval, title, min, max, step, isGlobal)
	local slider = CreateFrame("Slider", label.."Slider", owner.Opt, "OptionsSliderTemplate")
	slider:SetMinMaxValues(min, max)
	slider:SetOrientation("HORIZONTAL")
	slider:SetValueStep(step)
	slider:SetWidth(math.floor(owner.Opt:GetWidth()-30))
	slider:SetHeight(14)
	slider:SetValue(db[dbval])
	
	getglobal(slider:GetName() .. 'Low'):SetText(min)
	getglobal(slider:GetName() .. 'High'):SetText(max)
	getglobal(slider:GetName() .. 'Text'):SetFont(getglobal(slider:GetName() .. 'Text'):GetFont(), 11)
	getglobal(slider:GetName() .. 'Text'):SetText(title)
	
	slider:SetScript("OnValueChanged", function(self)
		db[dbval] = self:GetValue()
		self:SetValue(db[dbval]); self.val:SetText(string.format("%.1f", db[dbval]))
		if ( not isGlobal ) then SLDataText:UpdateBaseText(owner, db) end
		owner:Refresh()
	end)
	slider:SetScript("OnMouseWheel", function(self, delta)
		SliderMouse(self, delta)
	end)
	
	slider.val = CreateFrame("EditBox", label.."SliderValue", slider, "InputBoxTemplate")
	slider.val:SetFontObject("ChatFontNormal")
	slider.val:SetFont(slider.val:GetFont(), 11)
	slider.val:SetTextInsets(0, 0, 2, 2)
	slider.val:SetJustifyH("CENTER")
	slider.val:SetWidth(35)
	slider.val:SetHeight(12)
	slider.val:SetScale(0.8)
	slider.val:SetAutoFocus(false)
	slider.val:SetMaxLetters(24)
	slider.val:SetPoint("CENTER", slider, "CENTER", 0, -16)
	slider.val:SetText(string.format("%.1f", db[dbval]))
	
	slider.val:SetScript("OnEnterPressed", function(self)
		db[dbval] = self:GetText()
		self:SetText(string.format("%.1f", db[dbval])); slider:SetValue(db[dbval])
		self:ClearFocus()
		if ( not isGlobal ) then SLDataText:UpdateBaseText(owner, db) end
		owner:Refresh()
	end)
	slider.val:SetScript("OnEscapePressed", function(self)
		self:SetText(string.format("%.1f", db[dbval]))
		self:ClearFocus()
	end)
	
	return slider
end

local function NewEditBox(owner, label, db, dbval, title, isGlobal)
	local ebox = CreateFrame("EditBox", label, owner.Opt, "InputBoxTemplate")
	ebox:SetFontObject("ChatFontNormal")
	ebox:SetTextInsets(0, 0, 3, 3)
	ebox:SetHeight(18)
	ebox:SetWidth(math.floor(owner.Opt:GetWidth()-25))
	ebox:SetAutoFocus(false)
	ebox:SetMaxLetters(254)
	
	ebox:SetScript("OnEnterPressed" , function(self)
		db[dbval] = self:GetText()
		self:SetText(db[dbval])
		self:ClearFocus()
		if ( not isGlobal ) then SLDataText:UpdateBaseText(owner, db) end
		owner:Refresh()
	end)
	ebox:SetScript("OnEscapePressed", function(self)
		self:SetText(db[dbval])
		self:ClearFocus()
	end)
	ebox:SetText(db[dbval])

	ebox.Text = ebox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	ebox.Text:SetPoint("BOTTOMLEFT", ebox, "TOPLEFT", 0, 2)
	ebox.Text:SetFont(ebox.Text:GetFont(), 11)
	ebox.Text:SetJustifyH("LEFT")
	ebox.Text:SetText(title)
	
	return ebox
end

local function NewSelectBox(owner, label, db, dbval, title, items, isGlobal)
	local select = CreateFrame("Button", label, owner.Opt, "UIDropDownMenuTemplate")
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(select, self:GetID())
		for k, v in pairs(items) do
			if ( self:GetID() == k ) then
				db[dbval] = v
				if ( not isGlobal ) then SLDataText:UpdateBaseText(owner, db) end
				owner:Refresh()
			end
		end
	end
	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in ipairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	local id = 1
	for k, v in pairs(items) do
		if ( db[dbval] == v ) then id = k end
	end
	
	UIDropDownMenu_Initialize(select, Initialize)
	UIDropDownMenu_SetWidth(select, math.floor(owner.Opt:GetWidth()-37))
	UIDropDownMenu_SetButtonWidth(select, math.floor(owner.Opt:GetWidth()-51))
	UIDropDownMenu_SetSelectedID(select, id)
	UIDropDownMenu_JustifyText(select, "LEFT")
	
	select.Text = select:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	select.Text:SetPoint("BOTTOMLEFT", select, "TOPLEFT", 23, 1)
	select.Text:SetFont(select.Text:GetFont(), 11)
	select.Text:SetJustifyH("LEFT")
	select.Text:SetText(title)
	
	return select
end

local function NewDesc(owner, label, str)
	local desc = owner.Opt:CreateFontString(label, "OVERLAY", "GameFontHighlightSmall")
	desc:SetFont(desc:GetFont(), 11)
	desc:SetWidth(math.floor(owner.Opt:GetWidth()-30))
	desc:SetWordWrap(true)
	desc:SetNonSpaceWrap(false)
	desc:SetJustifyH("LEFT")
	desc:SetText(str)
	
	return desc
end

local function NewButton(owner, label, name, func)
	local button = CreateFrame("Button", label, owner.Opt, "GameMenuButtonTemplate")
	button:SetText(name)
	button:SetWidth(math.floor(owner.Opt:GetWidth()-30))
	button:SetHeight(20)
	button:SetScript("OnClick", func)
	
	return button
end

local function ProfileDesc(owner, label)
	local desc = owner.Opt:CreateFontString(label, "OVERLAY", "GameFontHighlightSmall")
	desc:SetFont(desc:GetFont(), 11)
	desc:SetWidth(math.floor(owner.Opt:GetWidth()-30))
	desc:SetWordWrap(true)
	desc:SetNonSpaceWrap(false)
	desc:SetJustifyH("LEFT")
	desc:SetText(string.format("Current Profile: %s", owner.db:GetCurrentProfile()))
	
	return desc
end

local function ProfileNewBox(owner, label)
	local ebox = CreateFrame("EditBox", label, owner.Opt, "InputBoxTemplate")
	ebox:SetFontObject("ChatFontNormal")
	ebox:SetTextInsets(0, 0, 3, 3)
	ebox:SetHeight(18)
	ebox:SetWidth(math.floor(owner.Opt:GetWidth()-25))
	ebox:SetAutoFocus(false)
	ebox:SetMaxLetters(254)
	
	ebox:SetScript("OnEnterPressed" , function(self)
		local newProfile = self:GetText()
		self:SetText(""); self:ClearFocus()
		owner.db:SetProfile(newProfile)
		
		owner:Refresh()
		ReloadUI()
	end)
	ebox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	ebox:SetText("")

	ebox.Text = ebox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	ebox.Text:SetPoint("BOTTOMLEFT", ebox, "TOPLEFT", 0, 2)
	ebox.Text:SetFont(ebox.Text:GetFont(), 11)
	ebox.Text:SetJustifyH("LEFT")
	ebox.Text:SetText("New Profile")
	
	return ebox
end

local function ProfileCopyBox(owner, label)
	local select = CreateFrame("Button", label, owner.Opt, "UIDropDownMenuTemplate")
	local items = owner.db:GetProfiles()
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(select, self:GetID())
		for k, v in pairs(items) do
			if ( self:GetID() == k ) then
				owner.db:CopyProfile(v, true)
				owner.Opt["Profile".."Current"]:SetText(v)
				owner:Refresh()
			end
		end
	end
	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in ipairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	local id = 1
	for k, v in pairs(items) do
		if ( owner.db:GetCurrentProfile() == v ) then id = k end
	end
	
	UIDropDownMenu_Initialize(select, Initialize)
	UIDropDownMenu_SetWidth(select, math.floor(owner.Opt:GetWidth()-37))
	UIDropDownMenu_SetButtonWidth(select, math.floor(owner.Opt:GetWidth()-51))
	UIDropDownMenu_SetSelectedID(select, id)
	UIDropDownMenu_JustifyText(select, "LEFT")
	
	select.Text = select:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	select.Text:SetPoint("BOTTOMLEFT", select, "TOPLEFT", 23, 1)
	select.Text:SetFont(select.Text:GetFont(), 11)
	select.Text:SetJustifyH("LEFT")
	select.Text:SetText("Copy Profile")
	
	return select
end

local function ProfileReset(owner, label, title)
	local button = CreateFrame("Button", label, owner.Opt, "GameMenuButtonTemplate")
	button:SetText(title)
	button:SetWidth(math.floor(owner.Opt:GetWidth()-30))
	button:SetHeight(20)
	
	local func = function()
		owner.db:ResetProfile()
	end
	
	button:SetScript("OnClick", func)
	
	return button
end

local function ProfileDeleteBox(owner, label)
	local select = CreateFrame("Button", label, owner.Opt, "UIDropDownMenuTemplate")
	local items = owner.db:GetProfiles()
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(select, self:GetID())
		for k, v in pairs(items) do
			if ( self:GetID() == k ) then
				owner.db:DeleteProfile(v, true)
				owner:Refresh()
				ReloadUI()
			end
		end
	end
	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in ipairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	local id = 1
	for k, v in pairs(items) do
		if ( owner.db:GetCurrentProfile() == v ) then id = k end
	end
	
	UIDropDownMenu_Initialize(select, Initialize)
	UIDropDownMenu_SetWidth(select, math.floor(owner.Opt:GetWidth()-37))
	UIDropDownMenu_SetButtonWidth(select, math.floor(owner.Opt:GetWidth()-51))
	UIDropDownMenu_SetSelectedID(select, id)
	UIDropDownMenu_JustifyText(select, "LEFT")
	
	select.Text = select:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	select.Text:SetPoint("BOTTOMLEFT", select, "TOPLEFT", 23, 1)
	select.Text:SetFont(select.Text:GetFont(), 11)
	select.Text:SetJustifyH("LEFT")
	select.Text:SetText("Delete Profile")
	
	return select
end

local function BuildOpt(module, db, title, width)
	module.Opt = module.Opt or CreateFrame("Frame", nil, UIParent)
	module.Opt:SetBackdrop(BGDia)
	module.Opt:SetWidth(width)
	module.Opt:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	module.Opt:EnableMouse(true)
	module.Opt:SetMovable(true)
	module.Opt:SetClampedToScreen(true)
	module.Opt:SetUserPlaced(true)
	module.Opt:SetScript("OnMouseDown", function() module.Opt:StartMoving() end)
	module.Opt:SetScript("OnMouseUp", function() module.Opt:StopMovingOrSizing() end)
	
	module.Opt.hdr = module.Opt.hdr or CreateFrame("Frame", nil, module.Opt or module.Frame)
	module.Opt.hdr:SetBackdrop(BGSol)
	module.Opt.hdr:SetBackdropColor(0,0,0,1)
	module.Opt.hdr:SetPoint("CENTER", module.Opt, "TOP", 0, -4)
	
	module.Opt.text = module.Opt.hdr:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	module.Opt.text:SetFont(module.Opt.text:GetFont(), 14)
	module.Opt.text:SetText(title)
	module.Opt.text:SetPoint("CENTER", 0, 0)
	
	module.Opt.hdr:SetWidth(125)
	module.Opt.hdr:SetHeight(30)
	
	module.Opt.close = CreateFrame("Button", nil, module.Opt, "UIPanelCloseButton")
	module.Opt.close:SetScale(0.9)
	module.Opt.close:SetPoint("TOPRIGHT", -3, -3)
	
	module.Opt:Hide()
end

function lib:CreateMenu(title, module, options, width)
	local db, width, height, isGlobal = module.db.profile, width or 250, 30, nil
	if ( not module.Opt ) then BuildOpt(module, db, title, width) end
	if ( title == "SLDataText" ) then isGlobal = true end
	
	for k, v in ipairs(options) do
		local type, name, dbval = v[1], v[2], v[3]
		if ( type == "toggle" ) then
			module.Opt[dbval] = NewCheckBox(module, "SLDT"..title..name, db, dbval, name, isGlobal)
			module.Opt[dbval]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
			height = math.floor(height+20)
		elseif ( type == "button" ) then
			local func = dbval
			module.Opt[name] = NewButton(module, "SLDT"..title..name, name, func)
			height = math.floor(height+8)
			module.Opt[name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
			height = math.floor(height+20)
		elseif ( type == "select" ) then
			local items = v[4]
			module.Opt[dbval] = NewSelectBox(module, "SLDT"..title..name, db, dbval, name, items, isGlobal)
			height = math.floor(height+16)
			module.Opt[dbval]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", -7, math.floor(0-height))
			height = math.floor(height+28)
		elseif ( type == "range" ) then
			local min, max, step = v[4], v[5], v[6]
			module.Opt[dbval] = NewSlider(module, "SLDT"..title..name, db, dbval, name, min, max, step, isGlobal)
			height = math.floor(height+16)
			module.Opt[dbval]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
			height = math.floor(height+26)
		elseif ( type == "text" ) then
			module.Opt[dbval] = NewEditBox(module, "SLDT"..title..name, db, dbval, name, isGlobal)
			height = math.floor(height+16)
			module.Opt[dbval]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
			height = math.floor(height+20)
		elseif ( type == "desc" ) then
			module.Opt[name] = NewDesc(module, "SLDT"..title..name, dbval)
			height = math.floor(height+6)
			module.Opt[name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
			height = math.floor((height+module.Opt[name]:GetHeight())+6)
		elseif ( type == "profile" ) then
			if ( dbval == "Current" ) then
				module.Opt["Profile"..name] = ProfileDesc(module, "SLDT_Profile"..name)
				height = math.floor(height+2)
				module.Opt["Profile"..name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
				height = math.floor((height+module.Opt["Profile"..name]:GetHeight())+6)
			elseif ( dbval == "New" ) then
				module.Opt["Profile"..name] = ProfileNewBox(module, "SLDT_Profile"..name)
				height = math.floor(height+16)
				module.Opt["Profile"..name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
				height = math.floor(height+20)
			elseif ( dbval == "Copy" ) then
				module.Opt["Profile"..name] = ProfileCopyBox(module, "SLDT_Profile"..name)
				height = math.floor(height+16)
				module.Opt["Profile"..name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", -7, math.floor(0-height))
				height = math.floor(height+28)
			elseif ( dbval == "Reset" ) then
				module.Opt["Profile"..name] = ProfileReset(module, "SLDT_Profile"..name, v[4])
				height = math.floor(height+12)
				module.Opt["Profile"..name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", 15, math.floor(0-height))
				height = math.floor(height+28)
			elseif ( dbval == "Delete" ) then
				module.Opt["Profile"..name] = ProfileDeleteBox(module, "SLDT_Profile"..name)
				height = math.floor(height+16)
				module.Opt["Profile"..name]:SetPoint("TOPLEFT", module.Opt, "TOPLEFT", -7, math.floor(0-height))
				height = math.floor(height+28)
			end
		end
	end
	
	height = math.floor(height+10)
	module.Opt:SetHeight(height)
end

function lib:OpenOptBox(module) 
	if ( not module.Opt ) then self:CreateMenu(module.db.profile.name, module, module.optsTbl) end
	module.Opt:Show()
end