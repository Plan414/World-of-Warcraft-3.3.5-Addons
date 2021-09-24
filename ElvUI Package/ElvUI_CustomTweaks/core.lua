local E, L, V, P, G = unpack(ElvUI);
local CT = E:NewModule("CustomTweaks", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

--Cache global variables
local pairs, ipairs = pairs, ipairs
local tinsert, tsort = table.insert, table.sort
local format = string.format

CT.Version = GetAddOnMetadata(addon, "Version")
CT.Title = "|cff4beb2cCustomTweaks|r"
CT.Configs = {}

P["CustomTweaks"] = {}
V["CustomTweaks"] = {}

local Tweaks = {
	["Actionbar"] = {
		{"PushedColor", L["Allows you to choose the color of the actionbar button when it is pushed down."]}, 
		{"ClickThroughActionBars", L["Allows you to make actionbars clickthrough."]},
	},
	["Bags"] = {
		{"BagButtons", L["Allows you to change bag buttons to use the classic texture style and allows you to add a 'Stack' button."]},
	},
	["Chat"] = {
		{"ChatMaxLines", L["Increases the amount of messages saved in a chat window, before they get replaced by new messages."]},
	},
	["Datatexts"] = {
		{"BagsTextFormat", L["Allows you to choose which text format the Bags datatext uses."]},
	},
	["Minimap"] = {
		{"MinimapSizeLimits", L["Lowers the minimum allowed minimap size."]},
	},
	["Misc"] = {
		{"RaidControl", L["Allows you to change template of the Raid Control button or hide it altogether."]},
		{"NoBorders", L["Attempts to remove borders on all ElvUI elements. This doesn't work on all statusbars, so some borders will be kept intact."]},
	},
	["Unitframe"] = {
		{"AuraIconSpacing", L["Allows you to set a spacing between individual aura icons for the units you choose."]},
		{"CastbarText", L["Allows you to position and change color and alpha of castbar text."]},
		{"PowerBarTexture", L["Allows you to use a separate texture for unitframe power bars."]},
		{"UnitFrameSpacingLimits", L["Increases the maximum allowed vertical and horizontal spacing for party and raid frames."]},
		{"CastbarFont", L["Allows you to change the text and duration font for the castbar."]},
	},
}

local Authors = {
	{"Benik", {
		"PowerBarTexture",
	}},
	{"Blazeflack", {
		"AuraIconSpacing",
		"BagButtons",
		"BagsTextFormat",
		"CastbarText",
		"ChatMaxLines",
		"ClickThroughActionBars",
		"MinimapSizeLimits",
		"NoBorders",
		"PushedColor",
		"RaidControl",
		"UnitFrameSpacingLimits",
		"CastbarFont",
	}},
}

local linebreak = "\n"
local function GetTweaksAsString(tweaks)
	local tweaksString = ""
	local temp = {}

	for _, tweak in pairs(tweaks) do
		tinsert(temp, tweak)
	end
	tsort(temp)
	
	for _, tweak in ipairs(temp) do
		tweaksString = tweaksString..tweak..linebreak
	end
	
	return tweaksString
end

--Copied from ElvUI
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("%02x%02x%02x", r*255, g*255, b*255)
end

function CT:ColorStr(str, r, g, b)
	local hex
	local coloredString
	
	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		hex = RGBToHex(75/255, 235/255, 44/255)
	end
	
	coloredString = "|cff"..hex..str.."|r"
	return coloredString
end

local function buildCategory(category, groupName)
	E.Options.args.CustomTweaks.args[category] = {
		order = 100,
		type = "group",
		name = groupName,
		childGroups = "tab",
		args = {
			header = {
				order = 1,
				type = "header",
				name = CT:ColorStr(L["Tweaks"]),
			},
			description = {
				order = 2,
				type = "description",
				name = format(L["Some tweaks may provide customizable options when enabled. If so then they will appear in the '%s' field below."], L["Options"]),
			},
			tweaks = {
				order = 3,
				type = "group",
				name = "",
				guiInline = true,
				args = {},
			},
			spacer = {
				order = 4,
				type = "description",
				name = "",
			},
			options = {
				order = 5,
				type = "group",
				name = CT:ColorStr(L["Options"]),
				args = {},
			},
		},
	}
end

function CT:ConfigTable()
	E.Options.args.CustomTweaks = {
		order = 100,
		type = "group",
		name = CT.Title,
		args = {
			header1 = {
				order = 1,
				type = "header",
				name = format(L["%s version %s by Blazeflack of tukui.org"], CT.Title, CT:ColorStr(CT.Version)),
			},		
			description1 = {
				order = 2,
				type = "description",
				name = format(L["%s is a collection of various tweaks for ElvUI. New features or changes have been requested by regular users and then fulfilled by members of the Tukui community."], CT.Title),
			},
			spacer1 = {
				order = 3,
				type = "description",
				name = "\n",
			},
			header2 = {
				order = 4,
				type = "header",
				name = CT:ColorStr(L["Information / Help"]),
			},
			description2 = {
				order = 5,
				type = "description",
				name = L["Please use the following links if you need help or wish to know more about this AddOn."],
			},
			addonpage = {
				order = 6,
				type = "input",
				width = "full",
				name = L["AddOn Description / Download"],
				get = function(info) return "http://www.tukui.org/addons/index.php?act=view&id=254" end,
				set = function(info) return "http://www.tukui.org/addons/index.php?act=view&id=254" end,
			},
			tickets = {
				order = 7,
				type = "input",
				width = "full",
				name = L["Report Bugs / Request Tweaks"],
				get = function(info) return "http://git.tukui.org/Blazeflack/elvui-customtweaks/issues" end,
				set = function(info) return "http://git.tukui.org/Blazeflack/elvui-customtweaks/issues" end,
			},
			credit = {
				order = -1,
				type = "group",
				name = L["Credit"],
				args = {},
			},
		},
	}

	local n = 0
	for i = 1, #Authors do
		local author = Authors[i][1]
		local tweaks = Authors[i][2]
		n = n + 1
		E.Options.args.CustomTweaks.args.credit.args[author.."Header"] = {
			order = n,
			type = "header",
			name = CT:ColorStr(author),
		}
		n = n + 1
		E.Options.args.CustomTweaks.args.credit.args[author.."Desc"] = {
			order = n,
			type = "description",
			name = format(L["%s is the author of the following tweaks:"], author).."\n"
		}
		n = n + 1
		E.Options.args.CustomTweaks.args.credit.args[author.."List"] = {
			order = n,
			type = "description",
			name = GetTweaksAsString(tweaks),
		}
	end

	for cat, tweaks in pairs(Tweaks) do
		buildCategory(cat, L[cat.." Tweaks"])
		for _, tweak in pairs(tweaks) do
			local tName = tweak[1]
			local tDesc = tweak[2]
			E.Options.args.CustomTweaks.args[cat].args.tweaks.args[tName] = {
				type = "toggle",
				name = CT:ColorStr(tName),
				desc = tDesc,
				descStyle = "inline",
				get = function(info) return E.private["CustomTweaks"][tName] end,
				set = function(info, value) E.private["CustomTweaks"][tName] = value; E:StaticPopup_Show("PRIVATE_RL") end,
			}
		end
	end
	
	for _, func in pairs(CT.Configs) do func() end
end

function CT:Initialize()
	EP:RegisterPlugin(addon, CT.ConfigTable)
end

E:RegisterModule(CT:GetName())