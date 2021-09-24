local E, _, V, P, G = unpack(ElvUI)
local L = E.Libs.ACL:GetLocale("ElvUI", E.global.general.locale)
local SB = E:GetModule("SwingBar")
local UF = E:GetModule("UnitFrames")

local positionValues = {
	TOP = L["Top"],
	LEFT = L["Left"],
	RIGHT = L["Right"],
	CENTER = L["Center"],
	BOTTOM = L["Bottom"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function SB:InsertOptions()
	E.Options.args.swing = {
		order = 50,
		type = "group",
		name = ColorizeSettingName(L["Swing Bar"]),
		get = function(info) return E.db.unitframe.units.player.swingbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units.player.swingbar[info[#info]] = value UF:CreateAndUpdateUF("player") end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			spacer = {
				order = 2,
				type = "description",
				name = " "
			},
			forceShowSingle = {
				order = 3,
				type = "execute",
				name = L["Show Swing Bar"],
				func = function()
					if ElvUF_PlayerSwingBar.testMode then
						ElvUF_PlayerSwingBar:Hide()
						ElvUF_PlayerSwingBar.testMode = nil
					else
						ElvUF_PlayerSwingBar:Show()

						ElvUF_PlayerSwingBar.Twohand:Show()
						ElvUF_PlayerSwingBar.Twohand:SetMinMaxValues(1, 100)
						ElvUF_PlayerSwingBar.Twohand:SetValue(random(10, 90))
						ElvUF_PlayerSwingBar.Twohand.Text:SetText("0.0")

						ElvUF_PlayerSwingBar.Mainhand:Hide()
						ElvUF_PlayerSwingBar.Offhand:Hide()

						ElvUF_PlayerSwingBar.testMode = true
					end
				end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			forceShowDual = {
				order = 4,
				type = "execute",
				name = L["Show Swing Bar (Dual Wield)"],
				func = function()
					if ElvUF_PlayerSwingBar.testMode then
						ElvUF_PlayerSwingBar:Hide()
						ElvUF_PlayerSwingBar.testMode = nil
					else
						ElvUF_PlayerSwingBar:Show()

						ElvUF_PlayerSwingBar.Mainhand:Show()
						ElvUF_PlayerSwingBar.Mainhand:SetMinMaxValues(1, 100)
						ElvUF_PlayerSwingBar.Mainhand:SetValue(random(10, 90))
						ElvUF_PlayerSwingBar.Mainhand.Text:SetText("0.0")

						ElvUF_PlayerSwingBar.Offhand:Show()
						ElvUF_PlayerSwingBar.Offhand:SetMinMaxValues(1, 100)
						ElvUF_PlayerSwingBar.Offhand:SetValue(random(10, 90))
						ElvUF_PlayerSwingBar.Offhand.Text:SetText("0.0")

						ElvUF_PlayerSwingBar.Twohand:Hide()

						ElvUF_PlayerSwingBar.testMode = true
					end
				end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			restore = {
				order = 5,
				type = "execute",
				name = L["Restore Defaults"],
				func = function() E:CopyTable(E.db.unitframe.units.player.swingbar, P.unitframe.units.player.swingbar) E:ResetMovers(L["Player SwingBar"]) UF:CreateAndUpdateUF("player") end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			spacer2 = {
				order = 6,
				type = "description",
				name = " "
			},
			width = {
				order = 7,
				type = "range",
				name = L["Width"],
				min = 5, max = 600, step = 1,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			height = {
				order = 8,
				type = "range",
				name = L["Height"],
				min = 5, max = 600, step = 1,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			spacing = {
				order = 9,
				type = "range",
				name = L["Spacing"],
				min = 0, max = 20, step = 1,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			spacer3 = {
				order = 10,
				type = "description",
				name = " "
			},
			spark = {
				order = 11,
				type = "toggle",
				name = L["Spark"],
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			verticalOrientation = {
				order = 12,
				type = "toggle",
				name = L["Vertical Fill Direction"],
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			color = {
				order = 13,
				type = "color",
				name = L["COLOR"],
				get = function(info)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					local d = P.unitframe.units.player.swingbar[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					t.r, t.g, t.b = r, g, b
					UF:CreateAndUpdateUF("player")
				end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			backdropColor = {
				order = 14,
				type = "color",
				name = L["Backdrop Color"],
				get = function(info)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					local d = P.unitframe.units.player.swingbar[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					t.r, t.g, t.b = r, g, b
					UF:CreateAndUpdateUF("player")
				end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			textGroup = {
				order = 15,
				type = "group",
				name = L["Text"],
				guiInline = true,
				get = function(info) return E.db.unitframe.units.player.swingbar.text[info[#info]] end,
				set = function(info, value) E.db.unitframe.units.player.swingbar.text[info[#info]] = value UF:CreateAndUpdateUF("player") end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
					},
					spacer = {
						order = 2,
						type = "description",
						name = " "
					},
					position = {
						order = 3,
						type = "select",
						name = L["Text Position"],
						values = positionValues,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					xOffset = {
						order = 4,
						type = "range",
						name = L["X-Offset"],
						min = -300, max = 300, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					yOffset = {
						order = 5,
						type = "range",
						name = L["Y-Offset"],
						min = -300, max = 300, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					color = {
						order = 6,
						type = "color",
						name = L["Text Color"],
						get = function(info)
							local t = E.db.unitframe.units.player.swingbar.text[info[#info]]
							local d = P.unitframe.units.player.swingbar.text[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.unitframe.units.player.swingbar.text[info[#info]]
							t.r, t.g, t.b = r, g, b
							UF:CreateAndUpdateUF("player")
						end,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					font = {
						order = 7,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					fontSize = {
						order = 8,
						type = "range",
						name = L["FONT_SIZE"],
						min = 6, max = 32, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					fontOutline = {
						order = 9,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["NONE"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					}
				}
			}
		}
	}
end