local E, L, V, P, G, _ = unpack(ElvUI)
local EAB = E:NewModule("ExtraActionBars", "AceEvent-3.0")
local AB = E:GetModule("ActionBars")

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT"
}

P["actionbar"]["bar7"] = {
	["enabled"] = false,
	["mouseover"] = false,
	["buttons"] = 12,
	["buttonsPerRow"] = 12,
	["point"] = "BOTTOMLEFT",
	["backdrop"] = true,
	["heightMult"] = 1,
	["widthMult"] = 1,
	["buttonsize"] = 32,
	["buttonspacing"] = 2,
	["backdropSpacing"] = 2,
	["alpha"] = 1,
	["inheritGlobalFade"] = false,
	["showGrid"] = true,
	["paging"] = {},
	["visibility"] = "[vehicleui] hide; show"
}

P["actionbar"]["bar8"] = {
	["enabled"] = false,
	["mouseover"] = false,
	["buttons"] = 12,
	["buttonsPerRow"] = 12,
	["point"] = "BOTTOMLEFT",
	["backdrop"] = true,
	["heightMult"] = 1,
	["widthMult"] = 1,
	["buttonsize"] = 32,
	["buttonspacing"] = 2,
	["backdropSpacing"] = 2,
	["alpha"] = 1,
	["inheritGlobalFade"] = false,
	["showGrid"] = true,
	["paging"] = {},
	["visibility"] = "[vehicleui] hide; show"
}

P["actionbar"]["bar9"] = {
	["enabled"] = false,
	["mouseover"] = false,
	["buttons"] = 12,
	["buttonsPerRow"] = 12,
	["point"] = "BOTTOMLEFT",
	["backdrop"] = true,
	["heightMult"] = 1,
	["widthMult"] = 1,
	["buttonsize"] = 32,
	["buttonspacing"] = 2,
	["backdropSpacing"] = 2,
	["alpha"] = 1,
	["inheritGlobalFade"] = false,
	["showGrid"] = true,
	["paging"] = {},
	["visibility"] = "[vehicleui] hide; show"
}

P["actionbar"]["bar10"] = {
	["enabled"] = false,
	["mouseover"] = false,
	["buttons"] = 12,
	["buttonsPerRow"] = 12,
	["point"] = "BOTTOMLEFT",
	["backdrop"] = true,
	["heightMult"] = 1,
	["widthMult"] = 1,
	["buttonsize"] = 32,
	["buttonspacing"] = 2,
	["backdropSpacing"] = 2,
	["alpha"] = 1,
	["inheritGlobalFade"] = false,
	["showGrid"] = true,
	["paging"] = {},
	["visibility"] = "[vehicleui] hide; show"
}

function EAB:InsertOptions()
	local group = E.Options.args.actionbar.args
	for i = 7, 10 do
		local name = L["Bar "]..i
		group["bar" .. i] = {
			order = 200 + i,
			type = "group",
			name = name,
			disabled = function() return not E.private.actionbar.enable end,
			get = function(info) return E.db.actionbar["bar" .. i][ info[#info] ] end,
			set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value AB:PositionAndSizeBar("bar" .. i) end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = name
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar["bar"..i][ info[#info] ] = value
						AB:PositionAndSizeBar("bar"..i)
					end
				},
				restorePosition = {
					order = 3,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["bar"..i], P.actionbar["bar"..i]) E:ResetMovers(L["Bar "..i]) AB:PositionAndSizeBar("bar"..i) end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				spacer = {
					order = 4,
					type = "description",
					name = " "
				},
				backdrop = {
					order = 5,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				showGrid = {
					order = 6,
					type = "toggle",
					name = L["Show Empty Buttons"],
					set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value AB:UpdateButtonSettingsForBar("bar" .. i) end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				mouseover = {
					order = 7,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				inheritGlobalFade = {
					order = 8,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				point = {
					order = 9,
					type = "select",
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				buttons = {
					order = 10,
					type = "range",
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				buttonsPerRow = {
					order = 11,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				buttonsize = {
					order = 12,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				buttonspacing = {
					order = 13,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -1, max = 10, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				backdropSpacing = {
					order = 14,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				heightMult = {
					order = 15,
					type = "range",
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				widthMult = {
					order = 16,
					type = "range",
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				alpha = {
					order = 17,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				paging = {
					order = 18,
					type = "input",
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2'"],
					width = "full",
					multiline = true,
					get = function(info) return E.db.actionbar["bar" .. i]["paging"][E.myclass] end,
					set = function(info, value)
						if(not E.db.actionbar["bar" .. i]["paging"][E.myclass]) then
							E.db.actionbar["bar" .. i]["paging"][E.myclass] = {}
						end

						E.db.actionbar["bar"..i]["paging"][E.myclass] = value
						AB:UpdateButtonSettings()
					end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				},
				visibility = {
					order = 19,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] showhide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						E.db.actionbar["bar" .. i]["visibility"] = value
						AB:UpdateButtonSettings()
					end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled end
				}
			}
		}
	end
end


E:RegisterModule(EAB:GetName())