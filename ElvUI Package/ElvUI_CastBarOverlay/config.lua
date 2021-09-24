local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CBO = E:NewModule('CastBarOverlay', 'AceTimer-3.0', 'AceEvent-3.0')
local UF = E:GetModule('UnitFrames');

-- Defaults
V['CBO'] = {
	['warned'] = false,
}

P['CBO'] = {
	['player'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
	['target'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
	['focus'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
	['pet'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
	['boss'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
	['arena'] = {
		['overlay'] = false,
		["overlayOnFrame"] = "POWER",
		['hidetext'] = false,
		['xOffsetText'] = 4,
		['yOffsetText'] = 0,
		['xOffsetTime'] = -4,
		['yOffsetTime'] = 0,
	},
}

function CBO:InsertOptions()
	local function CreateOptionsGroup(order, name, unit, updateFunc)
		local group = {
			order = order,
			type = "group",
			name = name,
			args = {
				info = {
					order = 1,
					type = 'header',
					name = name,
				},
				overlay = {
					order = 2,
					type = 'toggle',
					name = L['Enable Overlay'],
					desc = L['Overlay the castbar on the chosen panel.'],
					get = function(info) return E.db.CBO[unit].overlay end,
					set = function(info, value) E.db.CBO[unit].overlay = value; updateFunc(CBO, unit) end,
				},
				overlayOnFrame = {
					order = 3,
					type = 'select',
					name = L['Overlay Panel'],
					desc = L['Choose which panel to overlay the castbar on.'],
					disabled = function() return not E.db.CBO[unit].overlay end,
					values = {
						["POWER"] = L["Power"],
						["HEALTH"] = L["Health"],
					},
					get = function(info) return E.db.CBO[unit].overlayOnFrame end,
					set = function(info, value)
						if value == "POWER" and not E.db.unitframe.units[unit].power.enable then
							E:StaticPopup_Show('CBO_PowerDisabled')
							value = "HEALTH"
						end
						E.db.CBO[unit].overlayOnFrame = value;
						updateFunc(CBO, unit);
					end,
				},
				hidetext = {
					order = 4,
					type = 'toggle',
					name = L['Hide Text'],
					desc = L['Hide Castbar text. Useful if your power height is very low or if you use power offset.'],
					get = function(info) return E.db.CBO[unit].hidetext end,
					set = function(info, value) E.db.CBO[unit].hidetext = value; updateFunc(CBO, unit); end,
					disabled = function() return not E.db.CBO[unit].overlay end,
				},
				spacer1 = {
					order = 5,
					type = 'description',
					name ='',
				},
				xOffsetText = {
					order = 6,
					type = 'range',
					name = L['Text xOffset'],
					desc = L['Move castbar text to the left or to the right. Default is 4'],
					get = function(info) return E.db.CBO[unit].xOffsetText end,
					set = function(info, value) E.db.CBO[unit].xOffsetText = value; updateFunc(CBO, unit); end,
					min = -100, max = 100, step = 1,
					disabled = function() return (not E.db.CBO[unit].overlay or E.db.CBO[unit].hidetext) end,
				},
				yOffsetText = {
					order = 7,
					type = 'range',
					name = L['Text yOffset'],
					desc = L['Move castbar text up or down. Default is 0'],
					get = function(info) return E.db.CBO[unit].yOffsetText end,
					set = function(info, value) E.db.CBO[unit].yOffsetText = value; updateFunc(CBO, unit); end,
					min = -50, max = 50, step = 1,
					disabled = function() return (not E.db.CBO[unit].overlay or E.db.CBO[unit].hidetext) end,
				},
				spacer2 = {
					order = 8,
					type = 'description',
					name ='',
				},
				xOffsetTime = {
					order = 9,
					type = 'range',
					name = L['Time xOffset'],
					desc = L['Move castbar time to the left or to the right. Default is -4'],
					get = function(info) return E.db.CBO[unit].xOffsetTime end,
					set = function(info, value) E.db.CBO[unit].xOffsetTime = value; updateFunc(CBO, unit); end,
					min = -100, max = 100, step = 1,
					disabled = function() return (not E.db.CBO[unit].overlay or E.db.CBO[unit].hidetext) end,
				},
				yOffsetTime = {
					order = 10,
					type = 'range',
					name = L['Time yOffset'],
					desc = L['Move castbar time up or down. Default is 0'],
					get = function(info) return E.db.CBO[unit].yOffsetTime end,
					set = function(info, value) E.db.CBO[unit].yOffsetTime = value; updateFunc(CBO, unit); end,
					min = -50, max = 50, step = 1,
					disabled = function() return (not E.db.CBO[unit].overlay or E.db.CBO[unit].hidetext) end,
				},
			},
		}

		return group
	end

	E.Options.args.plugins.args.CBO = {
		type = 'group',
		name = 'CastBarOverlay',
		childGroups = 'tab',
		disabled = function() return not E.private.unitframe.enable end,
		args = {},
	}

	local options = E.Options.args.plugins.args.CBO.args
	options.player = CreateOptionsGroup(1, L["Player"], "player", CBO.UpdateSettings)
	options.target = CreateOptionsGroup(2, L["Target"], "target", CBO.UpdateSettings)
	options.focus = CreateOptionsGroup(3, L["Focus"], "focus", CBO.UpdateSettings)
	options.pet = CreateOptionsGroup(4, L["Pet"], "pet", CBO.UpdateSettings)
	options.arena = CreateOptionsGroup(5, L["Arena"], "arena", CBO.UpdateSettings)
	options.boss = CreateOptionsGroup(6, L["Boss"], "boss", CBO.UpdateSettings)
end

local function InitializeCallback()
	CBO:Initialize()
end

E:RegisterModule(CBO:GetName(), InitializeCallback)