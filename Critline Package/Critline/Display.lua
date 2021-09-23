local CRITLINE, Critline = ...
local L = Critline.L

local FRAME_WIDTH = 128
local FRAME_WIDTH_WIDE = 160
local FRAME_HEIGHT = 24
local FRAME_HEIGHT_WIDE = 16

local height = FRAME_HEIGHT

local Display = Critline:NewModule("Display", CreateFrame("Frame", nil, UIParent, "BackdropTemplate"))
Display:SetMovable(true)
Display:SetBackdrop({
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 12,
})
Display:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

Critline.SlashCmdHandlers["reset"] = function()
	Display:ClearAllPoints()
	Display:SetPoint("CENTER")
end

local function onDragStart(self)
	Display:StartMoving()
end

local function onDragStop(self)
	Display:StopMovingOrSizing()
	local pos = Display.profile.pos
	pos.point, pos.x, pos.y = select(3, Display:GetPoint())
end

local function onEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	Critline:ShowTooltip(self.tree)
	if not Display.profile.locked then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Drag to move"], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	GameTooltip:Show()
end

local backdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

local trees = {}

for k, tree in pairs(Critline.trees) do
	local frame = CreateFrame("Frame", nil, Display, "BackdropTemplate")
	frame:SetFrameStrata("LOW")
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetPoint("LEFT", 4, 0)
	frame:SetPoint("RIGHT", -4, 0)
	frame:SetBackdrop(backdrop)
	frame:SetScript("OnDragStart", onDragStart)
	frame:SetScript("OnDragStop", onDragStop)
	frame:SetScript("OnEnter", onEnter)
	frame:SetScript("OnLeave", GameTooltip_Hide)
	frame.tree = k
	
	local text = frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	text:SetPoint("CENTER", frame, "RIGHT", -48, 0)
	frame.text = text
	
	local icon = frame:CreateTexture(nil, "OVERLAY")
	icon:SetSize(20, 20)
	icon:SetPoint("LEFT", 2, 0)
	icon:SetTexture(tree.icon)
	frame.icon = icon
	
	local label = frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	label:SetPoint("LEFT", 4, 0)
	label:SetText(tree.title..":")
	frame.label = label
	
	trees[k] = frame
end

trees.dmg:SetPoint("TOP", 0, -4)

local config = Critline.config:AddSubCategory("Display")

do
	local options = {
		{
			type = "CheckButton",
			text = L["Show"],
			tooltip = L["Show summary frame."],
			key = "show",
			func = "UpdateLayout",
		},
		{
			type = "CheckButton",
			text = L["Locked"],
			tooltip = L["Lock summary frame."],
			key = "locked",
			func = function(self, checked)
				for _, tree in pairs(trees) do
					tree:RegisterForDrag(not checked and "LeftButton")
				end
			end,
		},
		{
			type = "CheckButton",
			text = L["Show icons"],
			tooltip = L["Enable to show icon indicators instead of text."],
			key = "icons",
			func = function(self, checked)
				Display:SetWidth(checked and FRAME_WIDTH or FRAME_WIDTH_WIDE)
				height = checked and FRAME_HEIGHT or FRAME_HEIGHT_WIDE
				for _, tree in pairs(trees) do
					tree.icon:SetShown(checked)
					tree.label:SetShown(not checked)
					tree:SetHeight(height)
				end
				Display:UpdateLayout()
			end,
		},
		{
			type = "Slider",
			text = L["Scale"],
			tooltip = L["Sets the scale of the display."],
			key = "scale",
			func = function(self, value)
				local os = Display:GetScale()
				Display:SetScale(value)
				local point, relativeTo, relativePoint, xOffset, yOffset = Display:GetPoint()
				Display:SetPoint(point, relativeTo, relativePoint, (xOffset * os / value), (yOffset * os / value))
			end,
			min = 0.5,
			max = 2,
			step = 0.05,
			isPercent = true,
		},
		{
			type = "Slider",
			text = L["Opacity"],
			tooltip = L["Sets the opacity of the display."],
			key = "alpha",
			func = "SetAlpha",
			min = 0,
			max = 1,
			step = 0.05,
			isPercent = true,
		},
		{
			type = "Slider",
			text = L["Backdrop opacity"],
			tooltip = L["Sets the opacity of the display backdrop."],
			key = "bgAlpha",
			func = function(self, value)
				for k, v in pairs(trees) do
					local color = Display.profile[k.."Bg"]
					v:SetBackdropColor(color.r, color.g, color.b, value)
				end
			end,
			min = 0,
			max = 1,
			step = 0.05,
			isPercent = true,
		},
		{
			type = "Slider",
			text = L["Border opacity"],
			tooltip = L["Sets the opacity of the display border."],
			key = "borderAlpha",
			func = function(self, value)
				Display:SetBackdropBorderColor(0.5, 0.5, 0.5, value)
			end,
			min = 0,
			max = 1,
			step = 0.05,
			isPercent = true,
		},
	}
	
	local function swatchFunc(self, color)
		trees[self.key:sub(1, -3)]:SetBackdropColor(color.r, color.g, color.b, Display.profile.bgAlpha)
	end
	
	-- inject these separately for now since we're using the tree iteration
	for i, v in ipairs(Critline.treeIndex) do
		tinsert(options, 3 + i, {
			type = "ColorButton",
			text = Critline.trees[v].title,
			key = v.."Bg",
			func = swatchFunc,
		})
	end
	
	config:CreateOptions(options)
end

local defaults = {
	profile = {
		show = true,
		locked = false,
		icons = true,
		scale = 1,
		alpha = 1,
		bgAlpha = 1,
		borderAlpha = 1,
		dmgBg  = {r = 0, g = 0, b = 0},
		healBg = {r = 0, g = 0, b = 0},
		petBg  = {r = 0, g = 0, b = 0},
		pos = {
			point = "CENTER",
		},
	}
}

function Display:OnInitialize()
	self.db = Critline.db:RegisterNamespace("display", defaults)
	Critline.RegisterCallback(self, "SettingsLoaded")
	Critline.RegisterCallback(self, "OnNewTopRecord", "UpdateRecords")
	Critline.RegisterCallback(self, "FormatChanged", "UpdateRecords")
	Critline.RegisterCallback(self, "OnTreeStateChanged", "UpdateTree")
	
	config:SetDatabase(self.db, true)
	config:SetHandler(self)
	
	self:SettingsLoaded()
	self:UpdateRecords()
	self:UpdateTree()
end

function Display:SettingsLoaded()
	self.profile = self.db.profile
	
	-- restore stored position
	local pos = self.profile.pos
	self:ClearAllPoints()
	self:SetPoint(pos.point, pos.x, pos.y)
	-- need to set scale separately first to ensure proper positioning
	self:SetScale(self.profile.scale)
	
	config:SetupControls()
end

function Display:UpdateRecords(event, tree)
	if tree then
		local normal, crit = Critline:GetHighest(tree)
		trees[tree].text:SetFormattedText("%8s / %-8s", Critline:ShortenNumber(normal), Critline:ShortenNumber(crit))
	else
		for k in pairs(Critline.trees) do
			self:UpdateRecords(nil, k)
		end
	end
end

function Display:UpdateTree(event, tree, enabled)
	if tree then
		trees[tree]:SetShown(enabled)
		self:UpdateLayout()
	else
		for k in pairs(Critline.trees) do
			self:UpdateTree(nil, k, Critline.percharDB.profile[k])
		end
	end
end

function Display:Toggle()
	local show = not self.profile.show
	self.profile.show = show
	config:GetControlByKey("show"):SetChecked(show)
	self:UpdateLayout()
end

-- rearrange display buttons when any of them is shown or hidden
function Display:UpdateLayout()
	local shown = {}
	for k, v in ipairs(Critline.treeIndex) do
		local frame = trees[v]
		if frame:IsShown() then
			local prevShown = shown[#shown]
			if prevShown then
				frame:SetPoint("TOP", prevShown, "BOTTOM", 0, -2)
			else
				frame:SetPoint("TOP", 0, -4)
			end
			tinsert(shown, frame)
		end
	end
	
	self:SetHeight(#shown * (height + 2) + 6)
	
	-- hide the entire frame if it turns out none of the individual frames are shown
	self:SetShown(#shown > 0 and self.profile.show)
end
