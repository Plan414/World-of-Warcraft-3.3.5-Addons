local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["actionbar"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["PushedColor"] and true or false

--Cache global variables
local pairs = pairs

P["CustomTweaks"]["PushedColor"] = {
	["Color"] = {r = 1, g = 0, b = 0, a = 0.3},
}

local function UpdateBars()
	for barName in pairs(AB["handledBars"]) do
		AB:PositionAndSizeBar(barName)
	end
	AB:PositionAndSizeBarPet()
	AB:PositionAndSizeBarShapeShift()
end

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Actionbar.args.options.args.PushedColor = {
		type = "group",
		name = "PushedColor",
		args = {
			color = {
				order = 1,
				type = "color",
				name = L["Color"],
				disabled = function() return not isEnabled end,
				hasAlpha = true,
				get = function(info)
					local t = E.db.CustomTweaks.PushedColor.Color
					local d = P.CustomTweaks.PushedColor.Color
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
				end,
				set = function(info, r, g, b, a)
					E.db.CustomTweaks.PushedColor.Color = {}
					local t = E.db.CustomTweaks.PushedColor.Color
					t.r, t.g, t.b, t.a = r, g, b, a
					UpdateBars()
				end,
			},
		},
	}
end
CT.Configs["PushedColor"] = ConfigTable
if not isEnabled then return; end

local function StyleButton(self, button, noBackdrop, adjustChecked)
	if button.SetPushedTexture then
		local c = E.db.CustomTweaks.PushedColor.Color
		local r, g, b, a = c.r, c.g, c.b, c.a
		local pushedmod = button:CreateTexture("frame", nil, self)
		pushedmod:SetTexture(r, g, b, a)
		pushedmod:SetInside()
		button.pushedmod = pushedmod
		button:SetPushedTexture(pushedmod)
	end
end
hooksecurefunc(AB, "StyleButton", StyleButton)