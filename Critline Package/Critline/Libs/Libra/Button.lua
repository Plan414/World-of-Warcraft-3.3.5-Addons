local Libra = LibStub("Libra")
local Type, Version = "Button", 2
if Libra:GetModuleVersion(Type) >= Version then return end

local function onEnable(self)
	self.arrow:SetDesaturated(false)
end

local function onDisable(self)
	self.arrow:SetDesaturated(true)
end

local function constructor(self, parent)
	local button = CreateFrame("Button", nil, parent, "UIMenuButtonStretchTemplate")
	button:SetHeight(23)
	button:SetScript("OnEnable", onEnable)
	button:SetScript("OnDisable", onDisable)
	button.arrow = button:CreateTexture()
	button.arrow:SetSize(10, 12)
	button.arrow:SetPoint("RIGHT", -5, 0)
	button.arrow:SetTexture([[Interface\ChatFrame\ChatFrameExpandArrow]])
	button.arrow:Hide()
	button.Icon = button.arrow
	return button
end

Libra:RegisterModule(Type, Version, constructor)