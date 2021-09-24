local E, L, V, P, G, _ = unpack(ElvUI)
local EAB = E:GetModule("ExtraActionBars")
local AB = E:GetModule("ActionBars")
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

function EAB:UpdateButtonSettings()
	for i = 7, 10 do
		AB:PositionAndSizeBar("bar"..i)
	end
end

function EAB:CreateBars()
	AB["barDefaults"]["bar7"] = {
		["page"] = 7,
		["bindButtons"] = "EXTRABAR7BUTTON",
		["conditions"] = "",
		["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,82"
	}
	AB["barDefaults"]["bar8"] = {
		["page"] = 8,
		["bindButtons"] = "EXTRABAR8BUTTON",
		["conditions"] = "",
		["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,122"
	}
	AB["barDefaults"]["bar9"] = {
		["page"] = 9,
		["bindButtons"] = "EXTRABAR9BUTTON",
		["conditions"] = "",
		["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,162"
	}
	AB["barDefaults"]["bar10"] = {
		["page"] = 10,
		["bindButtons"] = "EXTRABAR10BUTTON",
		["conditions"] = "",
		["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,202"
	}

	for i = 7, 10 do
		AB:CreateBar(i)
	end

	for b, _ in pairs(AB["handledbuttons"]) do
		AB:RegisterButton(b, true)
	end

	AB:UpdateButtonSettings()
	AB:ReassignBindings()

	hooksecurefunc(AB, 'UpdateButtonSettings', EAB.UpdateButtonSettings)
end

function EAB:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	EAB:CreateBars()
end

function EAB:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	EAB:CreateBars()
end

function EAB:OnInitialize()
	EP:RegisterPlugin(addon, EAB.InsertOptions)

	if(E.private.actionbar.enable ~= true) then return end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end