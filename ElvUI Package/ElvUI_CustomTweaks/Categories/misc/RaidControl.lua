local E, L, V, P, G = unpack(ElvUI)
local RU = E:GetModule("RaidUtility")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["CustomTweaks"] and E.private["CustomTweaks"]["RaidControl"] and true or false

--Cache global variables
local InCombatLockdown = InCombatLockdown

---
-- GLOBALS: RaidUtility_ShowButton, RaidUtility_CloseButton, RaidUtilityPanel
---

P["CustomTweaks"]["RaidControl"] = {
	["hide"] = false,
	["transparent"] = true,
}

local UpdateRaidControl
local function ConfigTable()
	E.Options.args.CustomTweaks.args.Misc.args.options.args.RaidControl = {
		type = "group",
		name = "RaidControl",
		get = function(info) return E.db.CustomTweaks.RaidControl[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.RaidControl[info[#info]] = value; UpdateRaidControl() end,
		args = {
			hide = {
				order = 1,
				type = "toggle",
				name = L["Hide Raid Control"],
				disabled = function() return not isEnabled end,
			},
			transparent = {
				order = 2,
				type = "toggle",
				name = L["Use Transparent Template"],
				disabled = function() return not isEnabled end,
			},
		},
	}
end
CT.Configs["RaidControl"] = ConfigTable
if not isEnabled then return; end

function UpdateRaidControl()
	if InCombatLockdown() then return; end

	if (E.db.CustomTweaks.RaidControl.hide) then
		RaidUtility_ShowButton:Hide()
		RaidUtilityPanel:Hide()
	end
	if (E.db.CustomTweaks.RaidControl.transparent) then
		RaidUtility_ShowButton:SetTemplate("Transparent")
		RaidUtility_CloseButton:SetTemplate("Transparent")
		RaidUtilityPanel:SetTemplate("Transparent")
	else
		RaidUtility_ShowButton:SetTemplate("Default", true)
		RaidUtility_CloseButton:SetTemplate("Default", true)
		RaidUtilityPanel:SetTemplate("Default", true)
	end
end
hooksecurefunc(RU, "ToggleRaidUtil", UpdateRaidControl)