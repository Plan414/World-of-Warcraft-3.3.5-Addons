local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["actionbar"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["ClickThroughActionBars"] and true or false

--Cache global variables
local _G = _G
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_SHAPESHIFT_SLOTS = NUM_SHAPESHIFT_SLOTS

---
-- GLOBALS: IsAddOnLoaded, ElvUI_StanceBar, ElvUI_BarPet
---

P["CustomTweaks"]["ClickThroughActionBars"] = {
	["bar1"] = false,
	["bar2"] = false,
	["bar3"] = false,
	["bar4"] = false,
	["bar5"] = false,
	["bar6"] = false,
	["bar7"] = false,
	["bar8"] = false,
	["bar9"] = false,
	["bar10"] = false,
	["barPet"] = false,
	["stanceBar"] = false,
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Actionbar.args.options.args.ClickThroughActionBars = {
		type = "group",
		name = "ClickThroughActionBars",
		args = {
			barPet = {
				order = 11,
				type = "toggle",
				name = L["Pet Bar"],
				disabled = function() return not isEnabled end,
				get = function(info) return E.db.CustomTweaks["ClickThroughActionBars"]["barPet"] end,
				set = function(info, value) E.db.CustomTweaks["ClickThroughActionBars"]["barPet"] = value; AB:PositionAndSizeBarPet() end,
			},
			stanceBar = {
				order = 12,
				type = "toggle",
				name = L["Stance Bar"],
				disabled = function() return not isEnabled end,
				get = function(info) return E.db.CustomTweaks["ClickThroughActionBars"]["stanceBar"] end,
				set = function(info, value) E.db.CustomTweaks["ClickThroughActionBars"]["stanceBar"] = value; AB:PositionAndSizeBarShapeShift() end,
			},
		},
	}

	local numBars = 6
	if IsAddOnLoaded("ElvUI_ExtraActionBars") then
		numBars = 10
	end

	for i = 1, numBars do
		E.Options.args.CustomTweaks.args.Actionbar.args.options.args.ClickThroughActionBars.args["bar"..i] = {
			order = i,
			type = "toggle",
			name = L["Bar "]..i,
			disabled = function() return not isEnabled end,
			get = function(info) return E.db.CustomTweaks["ClickThroughActionBars"]["bar"..i] end,
			set = function(info, value) E.db.CustomTweaks["ClickThroughActionBars"]["bar"..i] = value; AB:PositionAndSizeBar("bar"..i) end,
		}
	end
end
CT.Configs["ClickThroughActionBars"] = ConfigTable
if not isEnabled then return; end

local function PositionAndSizeBar(self, barName)
	local clickThrough = E.db.CustomTweaks.ClickThroughActionBars[barName]
	local bar = AB["handledBars"][barName]
	local button

	bar:EnableMouse(not clickThrough)
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		button:EnableMouse(not clickThrough)
	end
end

local function PositionAndSizeBarShapeShift(self)
	ElvUI_StanceBar:EnableMouse(not E.db.CustomTweaks.ClickThroughActionBars.stanceBar)
	
	local button
	for i=1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i];
		button:EnableMouse(not E.db.CustomTweaks.ClickThroughActionBars.stanceBar)
	end
end

local function PositionAndSizeBarPet(self)
	ElvUI_BarPet:EnableMouse(not E.db.CustomTweaks.ClickThroughActionBars.barPet)
	
	local button
	for i=1, NUM_PET_ACTION_SLOTS do
		button = _G["PetActionButton"..i];
		button:EnableMouse(not E.db.CustomTweaks.ClickThroughActionBars.barPet)
	end
end

hooksecurefunc(AB, "PositionAndSizeBar", PositionAndSizeBar)
hooksecurefunc(AB, "PositionAndSizeBarShapeShift", PositionAndSizeBarShapeShift)
hooksecurefunc(AB, "PositionAndSizeBarPet", PositionAndSizeBarPet)