local E, _, V, P, G = unpack(ElvUI);
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
local tcopy = table.copy
local DT = E:GetModule('DataTexts')
local DB = E:GetModule('DTBars2')

local ADVANCED_OPTIONS = ADVANCED_OPTIONS
local ADD, ENABLE, DELETE = ADD, ENABLE, DELETE
local pairs, format = pairs, format

local points = {
	["LEFT"] = "LEFT",
	["TOPLEFT"] = "TOPLEFT",
	["TOP"] = "TOP",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOM"] = "BOTTOM",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["RIGHT"] = "RIGHT",
	["CENTER"] = "CENTER",
}

local stratas = {
	["BACKGROUND"] = "1. Background",
	["LOW"] = "2. Low",
	["MEDIUM"] = "3. Medium",
	["HIGH"] = "4. High",
	["DIALOG"] = "5. Dialog",
	["FULLSCREEN"] = "6. Fullscreen",
	["FULLSCREEN_DIALOG"] = "7. Fullscreen Dialog",
	["TOOLTIP"] = "8. Tooltip",
}

local panels = {}

function DB:GetOptions()
	E.Options.args.dtbars = {
		type = "group",
		name = "DT Bars 2",
		order = 10,
		childGroups = "select",
		args = {
			intro = {
				order = 1,
				type = 'description',
				name = L["DTBars2_DESC"],
			},
			advanced = {
				order = 2,
				type = "toggle",
				name = ADVANCED_OPTIONS,
				desc = L["Show additional options."],
				get = function(info) return E.global.dtbarsSetup.advanced end,
				set = function(info, value) E.global.dtbarsSetup.advanced = value end,
			},
			spacer = {
				order = 3,
				type = 'description',
				name = '',
			},
			spacer2 = {
				order = 4,
				type = 'description',
				name = '',
			},
			--Normal
			name = {
				order = 5,
				type = 'input',
				width = 'full',
				name = L["Name"],
				desc = L["Set the name for the new datatext panel."],
				get = function(info) return E.global.dtbarsSetup.name end,
				set = function(info, value) E.global.dtbarsSetup.name = value end,
			},
			slots = {
				order = 7,
				type = "range",
				name = L['Slots'],
				desc = L["Sets number of datatext slots for the panel"],
				min = 1, max = 5, step = 1,
				get = function(info, value) return E.global.dtbarsSetup.slots end,
				set = function(info, value) E.global.dtbarsSetup.slots = value end,
			},
			growth = {
				order = 8,
				type = 'select',
				name = L["Growth Direction"],
				get = function(info) return E.global.dtbarsSetup.growth end,
				set = function(info, value) E.global.dtbarsSetup.growth = value end,
				values = {
					["HORIZONTAL"] = L["Horizontal"],
					["VERTICAL"] = L["Vertical"],
				},
			},
			width = {
				order = 9,
				type = "range",
				name = L['Width'],
				desc = L["Sets width of the panel"],
				min = 50, max = E.screenwidth, step = 1,
				get = function(info, value) return E.global.dtbarsSetup.width end,
				set = function(info, value) E.global.dtbarsSetup.width = value end,
			},
			height = {
				order = 10,
				type = "range",
				name = L['Height'],
				desc = L["Sets height of the panel (height of each individual datatext)"],
				min = 10, max = E.screenheight, step = 1,
				get = function(info, value) return E.global.dtbarsSetup.height end,
				set = function(info, value) E.global.dtbarsSetup.height = value; DB:Resize() end,
			},
			transparent = {
				order = 11,
				name = L['Panel Transparency'],
				type = 'toggle',
				get = function() return E.global.dtbarsSetup.transparent end,
				set = function(info, value) E.global.dtbarsSetup.transparent = value; end,
			},
			border = {
				order = 12,
				name = L['Border'],
				type = 'toggle',
				get = function() return E.global.dtbarsSetup.border end,
				set = function(info, value) E.global.dtbarsSetup.border = value; end,
			},
			hide = {
				order = 13,
				type = "toggle",
				name = L['Hide panel background'],
				desc = L["Don't show this panel, only datatexts assinged to it"],
				get = function(info) return E.global.dtbarsSetup.hide end,
				set = function(info, value) E.global.dtbarsSetup.hide = value end,
			},
			mouseover = {
				order = 14,
				name = L["Mouse Over"],
				type = 'toggle',
				get = function() return E.global.dtbarsSetup.mouseover end,
				set = function(info, value) E.global.dtbarsSetup.mouseover = value; end,
			},
			combatHide = {
				order = 15,
				name = L["Hide In Combat"],
				type = 'toggle',
				get = function() return E.global.dtbarsSetup.combatHide end,
				set = function(info, value) E.global.dtbarsSetup.combatHide = value; end,
			},
			vehicleHide = {
				order = 16,
				name = L["Hide In Vehicle"],
				type = 'toggle',
				get = function() return E.global.dtbarsSetup.vehicleHide end,
				set = function(info, value) E.global.dtbarsSetup.vehicleHide = value; end,
			},
			--Advanced
			anchor = {
				order = 50,
				type = 'select',
				name = L["Anchor"],
				desc = L["Panel anchors itself on the parent frame with this point."],
				get = function(info) return E.global.dtbarsSetup.anchor end,
				set = function(info, value) E.global.dtbarsSetup.anchor = value end,
				hidden = function() return not E.global.dtbarsSetup.advanced end,
				values = points,
			},
			point = {
				order = 51,
				type = 'select',
				name = L["Anchor Point"],
				desc = L["Panel anchors itself to this point on the parent frame."],
				get = function(info) return E.global.dtbarsSetup.point end,
				set = function(info, value) E.global.dtbarsSetup.point = value end,
				hidden = function() return not E.global.dtbarsSetup.advanced end,
				values = points,
			},
			x = {
				order = 52,
				type = "range",
				name = L['X-Offset'],
				min = -(E.eyefinity or E.screenwidth), max = (E.eyefinity or E.screenwidth), step = 1,
				get = function(info, value) return E.global.dtbarsSetup.x end,
				set = function(info, value) E.global.dtbarsSetup.x = value end,
				hidden = function() return not E.global.dtbarsSetup.advanced end,
			},
			y = {
				order = 53,
				type = "range",
				name = L['Y-Offset'],
				min = -E.screenheight, max = E.screenheight, step = 1,
				get = function(info, value) return E.global.dtbarsSetup.y end,
				set = function(info, value) E.global.dtbarsSetup.y = value end,
				hidden = function() return not E.global.dtbarsSetup.advanced end,
			},
			strata = {
				order = 54,
				type = 'select',
				name = L["Strata"],
				desc = L["Defines on what layer of the UI your panel will be: higher layer/number allows the panel to overlap more other frames. If you are not sure, leave this option at \"2. Low\""],
				get = function(info) return E.global.dtbarsSetup.strata end,
				set = function(info, value) E.global.dtbarsSetup.strata = value end,
				hidden = function() return not E.global.dtbarsSetup.advanced end,
				values = stratas,
			},
			buttonspacer1 = {
				order = 98,
				type = 'description',
				name = '',
			},
			buttonspacer2 = {
				order = 99,
				type = 'description',
				name = '',
			},
			create = {
				order = 100,
				name = ADD,
				type = 'execute',
				disabled = function() return E.global.dtbarsSetup.name == "" end,
				func = function() E:StaticPopup_Show("DT_Panel_Add") end,
			}
		},
	}

	for panelname, data in pairs(E.global.dtbars) do
		local table = E.Options.args.dtbars.args
		table[panelname] = {
			order = 1,
			name = panelname,
			type = 'group',
			args = {
				--Normal
				enable = {
					order = 1,
					type = "toggle",
					name = ENABLE,
					get = function(info) return E.db.dtbars[panelname].enable end,
					set = function(info, value) E.db.dtbars[panelname].enable = value; DB:ExtraDataBarSetup() end,
				},
				slots = {
					order = 2,
					type = "range",
					name = L['Slots'],
					desc = L["Sets number of datatext slots for the panel"],
					min = 1, max = 5, step = 1,
					get = function(info, value) return E.global.dtbars[panelname].slots end,
					set = function(info, value)
						local oldValue = E.global.dtbars[panelname].slots
						E.PopupDialogs["DT_Slot_Changed"].text = format(L["DT_Slot_Change_Text"], oldValue, value)
						E.PopupDialogs["DT_Slot_Changed"].OnAccept = function() E.global.dtbars[panelname].slots = value; DB:ChangeSlots(panelname) end
						E.PopupDialogs["DT_Slot_Changed"].OnCancel = function() E.global.dtbars[panelname].slots = oldValue end
						E:StaticPopup_Show("DT_Slot_Changed")
					end,
				},
				growth = {
					order = 3,
					type = 'select',
					name = L["Growth Direction"],
					get = function(info) return E.db.dtbars[panelname].growth end,
					set = function(info, value) E.db.dtbars[panelname].growth = value; DB:Resize(); DT:UpdateAllDimensions() end,
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"],
					},
				},
				width = {
					order = 4,
					type = "range",
					name = L['Width'],
					desc = L["Sets width of the panel"],
					min = 50, max = E.screenwidth, step = 1,
					get = function(info, value) return E.db.dtbars[panelname].width end,
					set = function(info, value) E.db.dtbars[panelname].width = value; DB:Resize() end,
				},
				height = {
					order = 5,
					type = "range",
					name = L['Height'],
					desc = L["Sets height of the panel (height of each individual datatext)"],
					min = 10, max = E.screenheight, step = 1,
					get = function(info, value) return E.db.dtbars[panelname].height end,
					set = function(info, value) E.db.dtbars[panelname].height = value; DB:Resize() end,
				},
				transparent = {
					order = 6,
					name = L['Panel Transparency'],
					type = 'toggle',
					get = function() return E.db.dtbars[panelname].transparent end,
					set = function(info, value) E.db.dtbars[panelname].transparent = value; DB:ExtraDataBarSetup() end,
				},
				border = {
					order = 17,
					name = L['Border'],
					type = 'toggle',
					get = function() return E.db.dtbars[panelname].border end,
					set = function(info, value) E.db.dtbars[panelname].border = value; DB:ExtraDataBarSetup() end,
				},
				hide = {
					order = 9,
					type = "toggle",
					name = L['Hide panel background'],
					desc = L["Don't show this panel, only datatexts assinged to it"],
					get = function(info) return E.global.dtbars[panelname].hide end,
					set = function(info, value) E.global.dtbars[panelname].hide = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				mouseover = {
					order = 10,
					name = L["Mouse Over"],
					type = 'toggle',
					get = function() return E.db.dtbars[panelname].mouseover end,
					set = function(info, value) E.db.dtbars[panelname].mouseover = value; DB:MouseOver() end,
				},
				combatHide = {
					order = 11,
					name = L["Hide In Combat"],
					type = 'toggle',
					get = function() return E.db.dtbars[panelname].combatHide end,
					set = function(info, value) E.db.dtbars[panelname].combatHide = value; end,
				},
				vehicleHide = {
					order = 12,
					name = L["Hide In Vehicle"],
					type = 'toggle',
					get = function() return E.db.dtbars[panelname].vehicleHide end,
					set = function(info, value) E.db.dtbars[panelname].vehicleHide = value; end,
				},
				--Advanced
				anchor = {
					order = 50,
					type = 'select',
					name = L["Anchor"],
					desc = L["Panel anchors itself on the parent frame with this point."],
					get = function(info) return E.global.dtbars[panelname].anchor end,
					set = function(info, value) E.global.dtbars[panelname].anchor = value; E:StaticPopup_Show("GLOBAL_RL") end,
					hidden = function() return not E.global.dtbarsSetup.advanced end,
					values = points,
				},
				point = {
					order = 51,
					type = 'select',
					name = L["Anchor Point"],
					desc = L["Panel anchors itself to this point on the parent frame."],
					get = function(info) return E.global.dtbars[panelname].point end,
					set = function(info, value) E.global.dtbars[panelname].point = value; E:StaticPopup_Show("GLOBAL_RL") end,
					hidden = function() return not E.global.dtbarsSetup.advanced end,
					values = points,
				},
				x = {
					order = 52,
					type = "range",
					name = L['X-Offset'],
					min = -(E.eyefinity or E.screenwidth), max = (E.eyefinity or E.screenwidth), step = 1,
					get = function(info, value) return E.global.dtbars[panelname].x end,
					set = function(info, value) E.global.dtbars[panelname].x = value; E:StaticPopup_Show("GLOBAL_RL") end,
					hidden = function() return not E.global.dtbarsSetup.advanced end,
				},
				y = {
					order = 53,
					type = "range",
					name = L['Y-Offset'],
					min = -E.screenheight, max = E.screenheight, step = 1,
					get = function(info, value) return E.global.dtbars[panelname].y end,
					set = function(info, value) E.global.dtbars[panelname].y = value; E:StaticPopup_Show("GLOBAL_RL") end,
					hidden = function() return not E.global.dtbarsSetup.advanced end,
				},
				strata = {
					order = 54,
					type = 'select',
					name = L["Strata"],
					desc = L["Defines on what layer of the UI your panel will be: higher layer/number allows the panel to overlap more other frames. If you are not sure, leave this option at \"2. Low\""],
					get = function(info) return E.global.dtbars[panelname].strata end,
					set = function(info, value) E.global.dtbars[panelname].strata = value; E:StaticPopup_Show("GLOBAL_RL") end,
					hidden = function() return not E.global.dtbarsSetup.advanced end,
					values = stratas,
				},
				buttonspacer1 = {
					order = 98,
					type = 'description',
					name = '',
				},
				buttonspacer2 = {
					order = 99,
					type = 'description',
					name = '',
				},
				delete = {
					order = 100,
					name = DELETE,
					type = 'execute',
					func = function()
						E.PopupDialogs["DT_Panel_Delete"].OnAccept = function() DB:DeletePanel(panelname) end
						E:StaticPopup_Show("DT_Panel_Delete")
					end,
				},
			},
		}
	end
end
