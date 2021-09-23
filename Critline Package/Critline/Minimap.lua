local CRITLINE, Critline = ...
local L = Critline.L

local function onUpdate(self)
	local xpos, ypos = GetCursorPosition()
	local xmin, ymin = Minimap:GetCenter()
	
	xpos = xpos / Minimap:GetEffectiveScale() - xmin
	ypos = ypos / Minimap:GetEffectiveScale() - ymin
	
	local pos = atan2(ypos, xpos)
	self.db.profile.pos = pos
	self:Move(pos)
end

local minimap = Critline:NewModule("Minimap", CreateFrame("Button", "CritlineMinimapButton", Minimap))
minimap:SetToplevel(true)
minimap:SetMovable(true)
minimap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
minimap:RegisterForDrag("LeftButton")
minimap:SetSize(32, 32)
minimap:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])
minimap:SetFrameLevel(8)
minimap:Hide()
minimap:SetScript("OnClick", function(self, button)
	local display = Critline:GetModule("Display")
	if button == "LeftButton" and display then
		display:Toggle()
	elseif button == "RightButton" then
		Critline:OpenConfig()
	end
end)
minimap:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("Critline")
	if Critline:GetModule("Display") then
		GameTooltip:AddLine(L["Left-click to toggle summary frame"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	GameTooltip:AddLine(L["Right-click to open options"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	if not self.db.profile.locked then
		GameTooltip:AddLine(L["Drag to move"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	GameTooltip:Show()
end)
minimap:SetScript("OnLeave", GameTooltip_Hide)
minimap:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", onUpdate) end)
minimap:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
minimap:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)

local icon = minimap:CreateTexture()
icon:SetSize(20, 20)
icon:SetPoint("TOPLEFT", 6, -6)
icon:SetTexture(Critline.trees.dmg.icon)

local border = minimap:CreateTexture(nil, "OVERLAY")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT")
border:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])

local config = Critline.config:AddSubCategory(L["Minimap"])

config:CreateOptions({
	{
		type = "CheckButton",
		text = L["Show"],
		tooltip = L["Show minimap button."],
		key = "show",
		func = "SetShown",
	},
	{
		type = "CheckButton",
		text = L["Locked"],
		tooltip = L["Lock minimap button."],
		key = "locked",
		func = function(self, checked)
			minimap:RegisterForDrag(not checked and "LeftButton")
		end,
	},
})


local defaults = {
	profile = {
		show = true,
		locked = false,
		pos = 225,
	}
}

function minimap:OnInitialize()
	self.db = Critline.db:RegisterNamespace("minimap", defaults)
	Critline.RegisterCallback(self, "SettingsLoaded", "LoadSettings")
	
	config:SetDatabase(self.db, true)
	config:SetHandler(self)
	
	self:LoadSettings()
end

function minimap:LoadSettings()
	config:SetupControls()
	self:Move(self.db.profile.pos)
end

function minimap:Move(angle)
	self:SetPoint("CENTER", 80 * cos(angle), 80 * sin(angle))
end
