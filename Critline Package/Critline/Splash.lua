local CRITLINE, Critline = ...
local L = Critline.L
local LSM = LibStub("LibSharedMedia-3.0")

local splash = Critline:NewModule("Splash", CreateFrame("MessageFrame", nil, UIParent))
splash:SetMovable(true)
splash:RegisterForDrag("LeftButton")
splash:SetSize(512, 96)
splash:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		if self.profile.enabled then
			Critline.RegisterCallback(self, "NewRecord")
		end
		self:SetFrameStrata("MEDIUM")
		self.hitRect:Hide()
		self:EnableMouse(false)
		self:SetFading(true)
		self:Clear()
	end
end)
splash:EnableMouse(false)
splash:SetScript("OnDragStart", splash.StartMoving)
splash:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local pos = self.profile.pos
	pos.point, pos.x, pos.y = select(3, self:GetPoint())
end)

local hitRect = splash:CreateTexture()
hitRect:SetTexture(0, 1, 0, 0.3)
hitRect:SetAllPoints()
hitRect:Hide()
splash.hitRect = hitRect

local config = Critline.config:AddSubCategory(L["Splash frame"])

do
	local options = {
		{
			type = "CheckButton",
			text = L["Enabled"],
			tooltip = L["Shows the new record on the middle of the screen."],
			key = "enabled",
			func = function(self, checked)
				if checked then
					if not splash:IsMouseEnabled() then
						Critline.RegisterCallback(splash, "NewRecord")
					end
				else
					Critline.UnregisterCallback(splash, "NewRecord")
				end
			end,
		},
		{
			type = "CheckButton",
			text = L["Use combat text splash"],
			tooltip = L["Enable to use scrolling combat text for \"New record\" messages instead of the default splash frame."],
			key = "sct",
		},
		{
			type = "ColorButton",
			text = L["Spell color"],
			tooltip = L["Sets the color for the spell text in the splash frame."],
			key = "spellColor",
		},
		{
			type = "ColorButton",
			text = L["Amount color"],
			tooltip = L["Sets the color for the amount text in the splash frame."],
			key = "amountColor",
		},
		{
			type = "Slider",
			text = L["Scale"],
			tooltip = L["Sets the scale of the splash frame."],
			key = "scale",
			func = function(self, value)
				local os = splash:GetScale()
				splash:SetScale(value)
				local point, relativeTo, relativePoint, xOff, yOff = splash:GetPoint()
				splash:SetPoint(point, relativeTo, relativePoint, (xOff*os/value), (yOff*os/value))
			end,
			min = 0.5,
			max = 1,
			step = 0.05,
			isPercent = true,
		},
		{
			type = "Slider",
			text = L["Duration"],
			tooltip = L["Sets the time (in seconds) the splash frame is visible before fading out."],
			key = "duration",
			func = "SetTimeVisible",
			min = 0,
			max = 5,
			step = 0.5,
		},
		{
			type = "Slider",
			text = L["Fade duration"],
			tooltip = L["Sets the time between the splash frame starting to fade and being fully faded out."],
			key = "fadeDuration",
			func = "SetFadeDuration",
			min = 0,
			max = 5,
			step = 0.5,
		},
		{
			newColumn = true,
			type = "Dropdown",
			text = L["Font"],
			key = "fontFace",
			func = "UpdateFont",
			width = 120,
			menuList = function() return LSM:List("font") end,
		},
		{
			type = "Dropdown",
			text = L["Font outline"],
			key = "fontFlags",
			func = "UpdateFont",
			width = 120,
			menuList = {
				"",
				"OUTLINE",
				"THICKOUTLINE",
			},
			properties = {
				text = {
					[""] = L["None"],
					["OUTLINE"] = L["Normal"],
					["THICKOUTLINE"] = L["Thick"],
				},
			}
		},
		{
			type = "Slider",
			text = L["Font size"],
			tooltip = L["Sets the font size of the splash frame."],
			key = "fontSize",
			func = "UpdateFont",
			min = 8,
			max = 30,
			step = 1,
		},
	}

	config:CreateOptions(options, splash)

	local moveSplash = Critline:CreateButton(config)
	moveSplash:SetPoint("TOP", config:GetControlByKey("fadeDuration"), "BOTTOM", 0, -24)
	moveSplash:SetWidth(96)
	moveSplash:SetText(UNLOCK)
	moveSplash:SetScript("OnClick", function()
		-- don't want to be interrupted by new records
		Critline.UnregisterCallback(splash, "NewRecord")
		splash:SetFrameStrata("FULLSCREEN")
		splash.hitRect:Show()
		splash:EnableMouse(true)
		splash:SetFading(false)
		splash:Clear()
		splash:AddMessage(L["Critline splash frame unlocked"], splash.profile.spellColor)
		splash:AddMessage(L["Drag to move"], splash.profile.amountColor)
		splash:AddMessage(L["Right-click to lock"], splash.profile.amountColor)
	end)
end

local defaults = {
	profile = {
		enabled = true,
		sct = false,
		scale = 1,
		duration = 2,
		fadeDuration = 3,
		fontFace = "Skurri",
		fontSize = 30,
		fontFlags = "OUTLINE",
		spellColor  = {r = 1, g = 1, b = 0},
		amountColor = {r = 1, g = 1, b = 1},
		pos = {
			point = "CENTER"
		},
	}
}

function splash:OnInitialize()
	self.db = Critline.db:RegisterNamespace("splash", defaults)
	Critline.RegisterCallback(self, "SettingsLoaded", "LoadSettings")
	
	config:SetDatabase(self.db, true)
	config:SetHandler(self)
	
	self:LoadSettings()
end

function splash:LoadSettings()
	self.profile = self.db.profile
	
	local pos = self.profile.pos
	self:ClearAllPoints()
	self:SetPoint(pos.point, pos.x, pos.y)
	-- need to set scale separately first to ensure proper positioning
	self:SetScale(self.profile.scale)
	
	config:SetupControls()
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateFont")
	LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "UpdateFont")
end

local addMessage = splash.AddMessage

function splash:AddMessage(msg, color, ...)
	addMessage(self, msg, color.r, color.g, color.b, ...)
end

local red1 = {r = 1, g = 0, b = 0}
local red255 = {r = 255, g = 0, b = 0}

function splash:NewRecord(event, tree, spellID, spellName, periodic, amount, crit, prevRecord, isFiltered)
	if isFiltered then
		return
	end
	
	spell = format(L["New %s record!"], Critline:GetFullSpellName(spellName, periodic, true))
	amount = Critline:ShortenNumber(amount)
	if Critline.db.profile.oldRecord and prevRecord.amount > 0 then
		amount = format("%s (%s)", amount, Critline:ShortenNumber(prevRecord.amount))
	end
	
	local spellColor = self.profile.spellColor
	local amountColor = self.profile.amountColor
	
	if self.profile.sct then
		-- check if any custom SCT addon is loaded and use it accordingly
		if MikSBT then
			if crit then
				MikSBT.DisplayMessage(L["Critical!"], nil, true, 255, 0, 0)
			end
			MikSBT.DisplayMessage(spell, nil, true, spellColor.r * 255, spellColor.g * 255, spellColor.b * 255)
			MikSBT.DisplayMessage(amount, nil, true, amountColor.r * 255, amountColor.g * 255, amountColor.b * 255)
		elseif SCT then
			if crit then
				SCT:DisplayMessage(L["Critical!"], red255)
			end
			SCT:DisplayMessage(spell, spellColor)
			SCT:DisplayMessage(amount, amountColor)
		elseif Parrot then
			local Parrot = Parrot:GetModule("Display")
			Parrot:ShowMessage(amount, nil, true, amountColor.r, amountColor.g, amountColor.b)
			Parrot:ShowMessage(spell, nil, true, spellColor.r, spellColor.g, spellColor.b)
			if crit then
				Parrot:ShowMessage(L["Critical!"], nil, true, 1, 0, 0)
			end
		elseif SHOW_COMBAT_TEXT == "1" then
			CombatText_AddMessage(amount, CombatText_StandardScroll, amountColor.r, amountColor.g, amountColor.b)
			CombatText_AddMessage(spell, CombatText_StandardScroll, spellColor.r, spellColor.g, spellColor.b)
			if crit then
				CombatText_AddMessage(L["Critical!"], CombatText_StandardScroll, 1, 0, 0)
			end
		end
	else
		self:Clear()
		if crit then
			self:AddMessage(L["Critical!"], red1)
		end
		self:AddMessage(spell, spellColor)
		self:AddMessage(amount, amountColor)
	end
end

function splash:UpdateFont()
	self:SetFont(LSM:Fetch("font", self.profile.fontFace), self.profile.fontSize, self.profile.fontFlags)
end
