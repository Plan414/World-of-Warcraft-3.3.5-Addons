local E, L, V, P, G = unpack(ElvUI)
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule("UnitFrames")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["PowerBarTexture"] and true or false

--Cache global variables
---
-- GLOBALS: AceGUIWidgetLSMlists
---

P["CustomTweaks"]["PowerBarTexture"] = {
	["powerstatusbar"] = "ElvUI Norm",
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.PowerBarTexture = {
		type = "group",
		name = "PowerBarTexture",
		get = function(info) return E.db.CustomTweaks.PowerBarTexture[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.PowerBarTexture[info[#info]] = value; UF:Update_AllFrames() end,
		args = {
			powerstatusbar = {
				order = 1,
				type = "select", dialogControl = "LSM30_Statusbar",
				name = L["PowerBar Texture"],
				disabled = function() return not isEnabled end,
				values = AceGUIWidgetLSMlists.statusbar,
			},
		},
	}
end
CT.Configs["PowerBarTexture"] = ConfigTable
if not isEnabled then return; end

local function UpdateStatusBars(_, frame)
	local statusBarTexture = LSM:Fetch("statusbar", E.db.CustomTweaks.PowerBarTexture.powerstatusbar)
	local power = frame.Power
	UF["statusbars"][power] = nil
	if power and power:GetObjectType() == "StatusBar" and not power.isTransparent then
		power:SetStatusBarTexture(statusBarTexture)
		power.texture = statusBarTexture --Update .texture for oUF
	elseif power and power:GetObjectType() == "Texture" then
		power:SetStatusBarTexture(statusBarTexture)
	end
end
hooksecurefunc(UF, "Configure_Power", UpdateStatusBars)