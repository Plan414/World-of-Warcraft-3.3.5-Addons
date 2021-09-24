local E, L, V, P, G = unpack(ElvUI)
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["CastbarFont"]and true or false
local UF = E:GetModule("UnitFrames")
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
local _G = _G
local pairs = pairs

P["CustomTweaks"]["CastbarFont"] = {
	["Player"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
	["Pet"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
	["Target"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
	["Focus"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
	["Arena"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
	["Boss"] = {
		["duration"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
		["text"] = {
			["font"] = "Homespun",
			["fontSize"] = 10,
			["fontOutline"] = "MONOCHROMEOUTLINE",
		},
	},
}

local units = {"Player", "Pet", "Target", "Focus", "Arena", "Boss"}
local UpdateCastbarFont
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.CastbarFont = {
		type = "group",
		name = "CastbarFont",
		get = function(info) return E.db.CustomTweaks.CastbarFont[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.CastbarFont[info[#info]] = value; end,
		childGroups = "tab",
		args = {},
	}

	local function CreateOptionsGroup(order, name, unit)
		local group = {
			order = order,
			type = "group",
			name = name,
			args = {
				text = {
					order = 2,
					type = "group",
					name = L["Text"],
					guiInline = true,
					get = function(info) return E.db.CustomTweaks.CastbarFont[unit].text[info[#info]] end,
					set = function(info, value) E.db.CustomTweaks.CastbarFont[unit].text[info[#info]] = value; UpdateCastbarFont(unit) end,
					disabled = function() return not isEnabled end,
					args = {
						font = {
							order = 1,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 22, step = 1,
						},
						fontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE",
							},
						},
					},
				},

				duration = {
					order = 1,
					type = "group",
					name = L["Duration"],
					guiInline = true,
					get = function(info) return E.db.CustomTweaks.CastbarFont[unit].duration[info[#info]] end,
					set = function(info, value) E.db.CustomTweaks.CastbarFont[unit].duration[info[#info]] = value; UpdateCastbarFont(unit) end,
					disabled = function() return not isEnabled end,
					args = {
						font = {
							order = 1,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 22, step = 1,
						},
						fontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE",
							},
						},
					},
				},
			},
		}

		return group
	end
	
	local options = E.Options.args.CustomTweaks.args.Unitframe.args.options.args.CastbarFont.args
	options.player = CreateOptionsGroup(1, L["Player"], "Player")
	options.pet = CreateOptionsGroup(2, L["Pet"], "Pet")
	options.target = CreateOptionsGroup(3, L["Target"], "Target")
	options.focus = CreateOptionsGroup(4, L["Focus"], "Focus")
	options.arena = CreateOptionsGroup(5, L["Arena"], "Arena")
	options.boss = CreateOptionsGroup(6, L["Boss"], "Boss")
end
CT.Configs["CastbarFont"] = ConfigTable
if not isEnabled then return; end

function UpdateCastbarFont(unit)
	local font = E.db.CustomTweaks.CastbarFont[unit].text.font
	local fontSize = E.db.CustomTweaks.CastbarFont[unit].text.fontSize
	local fontOutline = E.db.CustomTweaks.CastbarFont[unit].text.fontOutline
	
	local font2 = E.db.CustomTweaks.CastbarFont[unit].duration.font
	local fontSize2 = E.db.CustomTweaks.CastbarFont[unit].duration.fontSize
	local fontOutline2 =	E.db.CustomTweaks.CastbarFont[unit].duration.fontOutline

	if unit == "Arena" then
		for i = 1, 5 do
			local unitframe = _G["ElvUF_Arena"..i]
			local castbar = unitframe and unitframe.Castbar

			if castbar then
				castbar.Text:FontTemplate(LSM:Fetch("font", font), fontSize, fontOutline)
				castbar.Time:FontTemplate(LSM:Fetch("font", font2), fontSize2, fontOutline2)

				if onLoad then
					UF["fontstrings"][castbar.Time] = nil
					UF["fontstrings"][castbar.Text] = nil
				end
			end
		end
	elseif unit == "Boss" then
		for i = 1, MAX_BOSS_FRAMES do
			local unitframe = _G["ElvUF_Boss"..i]
			local castbar = unitframe and unitframe.Castbar
			
			if castbar then
				castbar.Text:FontTemplate(LSM:Fetch("font", font), fontSize, fontOutline)
				castbar.Time:FontTemplate(LSM:Fetch("font", font2), fontSize2, fontOutline2)

				if onLoad then
					UF["fontstrings"][castbar.Time] = nil
					UF["fontstrings"][castbar.Text] = nil
				end
			end
		end
	else
		local unitframe = _G["ElvUF_"..unit]
		local castbar = unitframe and unitframe.Castbar
		
		if castbar then
			castbar.Text:FontTemplate(LSM:Fetch("font", font), fontSize, fontOutline)
			castbar.Time:FontTemplate(LSM:Fetch("font", font2), fontSize2, fontOutline2)

			if onLoad then
				UF["fontstrings"][castbar.Time] = nil
				UF["fontstrings"][castbar.Text] = nil
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	for _, unit in pairs(units) do
		UpdateCastbarFont(unit, true)
	end
end)