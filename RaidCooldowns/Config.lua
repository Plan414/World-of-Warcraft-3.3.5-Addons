assert(RaidCooldowns, "RaidCooldowns not found!")

local MINOR_VERSION = tonumber(("$Revision: 48 $"):match("%d+"))
if MINOR_VERSION > RaidCooldowns.MINOR_VERSION then RaidCooldowns.MINOR_VERSION = MINOR_VERSION end

local L = LibStub("AceLocale-3.0"):GetLocale("RaidCooldowns")
local Media = LibStub("LibSharedMedia-3.0")
local textures = Media:List("statusbar")
local fonts = Media:List("font")
--local backgrounds = Media:List("background")
--local borders = Media:List("border")

local pairs, ipairs = _G.pairs, _G.ipairs
local tonumber, tostring = _G.tonumber, _G.tostring

local Display = RaidCooldowns:GetModule("Display")

Media.RegisterCallback(Display, "LibSharedMedia_Registered", "UpdateDisplay")
Media.RegisterCallback(Display, "LibSharedMedia_SetGlobal", "UpdateDisplay")

-- Omen rip; most of this file is, actually
local function GetLSMIndex(t, value)
	for k, v in pairs(Media:List(t)) do
		if v == value then
			return k
		end
	end
	return nil
end

local function set(t, value)
	Display.db.profile[t[#t]] = value
	Display:UpdateDisplay()
end
local function get(t)
	return Display.db.profile[t[#t]]
end

local options = {
	type = "group",
	args = {
		test = {
			type = "execute",
			name = L["Test"],
			desc = L["Test"],
			func = Display.Test,
		},
		reset = {
			type = "execute",
			name = L["Reset"],
			desc = L["Reset"],
			func = Display.Reset,
		},
		display = {
			type = "group",
			name = L["Display Options"],
			desc = L["Display Options"],
			cmdHidden = true,
			args = {
				locked = {
					type = "toggle",
					name = L["Lock Anchor"],
					desc = L["Locks the anchor in place and prevents it from being dragged."],
					get = get,
					set = set,
					order = 1,
					width = "full",
				},
				growUp = {
					type = "toggle",
					name = L["Grow Up"],
					desc = L["Grow bars upwards"],
					get = get,
					set = set,
					order = 2,
					width = "full",
				},
				scale = {
					type = "range",
					name = L["Scale"],
					desc = L["Control the scale of the entire RaidCooldowns GUI"],
					min = 1, max = 150, step = 1, bigStep = 1,
					get = get,
					set = set,
					order = 3,
					width = "full",
				},
				alpha = {
					type = "range",
					name = L["Alpha"],
					desc = L["Control the transparency of the entire RaidCooldowns GUI"],
					min = 0, max = 100, step = 5, bigStep = 10,
					get = get,
					set = set,
					order = 4,
					width = "full",
				},
				width = {
					type = "range",
					name = L["Width"],
					min = 50, max = 500, step = 5, bigStep = 10,
					get = get,
					set = set,
					order = 5,
					width = "full",
				},
				height = {
					type = "range",
					name = L["Height"],
					min = 1, max = 20, step = 1, bigStep = 1,
					get = get,
					set = set,
					order = 6,
					width = "full",
				},
				clamped = {
					type = 'toggle',
					name = L["Clamp to screen"],
					desc = L["Prevent the anchor from moving off screen."],
					get = get,
					set = set,
					order = 7,
					width = "full",
				},
				posX = {
					type = 'input',
					name = L["X Position"],
					get = function(info) return tostring(Display.db.profile.posX) end,
					set = function(info, v)
						Display.db.profile.posX = tonumber(v)
						Display:SetAnchors(true)
					end,
					order = 8,
					width = "full",
				},
				posY = {
					type = 'input',
					name = L["Y Position"],
					get = function(info) return tostring(Display.db.profile.posY) end,
					set = function(info, v)
						Display.db.profile.posY = tonumber(v)
						Display:SetAnchors(true)
					end,
					order = 9,
					width = "full",
				},
				bars = {
					type = "group",
					name = L["Bar options"],
					desc = L["Options which affect the style of the cooldown bars"],
					args = {
						texture = {
							type = "select",
							name = L["Texture"],
							desc = L["The texture that the bar will use"],
							values = textures,
							get = function(info) return GetLSMIndex("statusbar", Display.db.profile.texture) end,
							set = function(info, v)
								Display.db.profile.texture = Media:List("statusbar")[v]
								Display:UpdateDisplay()
							end,
							order = 1,
							width = "full",
						},
						fontSize = {
							type = "range",
							name = L["Label Font Size"],
							desc = L["The size of the font that the bar labels will use"],
							min = 5, max = 30, step = 1, bigStep = 1,
							get = get,
							set = set,
							order = 2,
							width = "full",
						},
						fontFace = {
							type = "select",
							name = L["Label Font"],
							desc = L["The font that the bar labels will use"],
							values = fonts,
							get = function(info) return GetLSMIndex("font", Display.db.profile.fontFace) end,
							set = function(info, v)
								Display.db.profile.fontFace = Media:List("font")[v]
								Display:UpdateDisplay()
							end,
							order = 3,
							width = "full",
						},
						orientation = {
							type = "select",
							name = L["Orientation"],
							values = { L["Right to Left"], L["Left to Right"] },
							-- "2" in LibBars is top to bottom, but we only have 2 choices, so this is a bit of a cheat
							get = function(info) return (Display.db.profile.orientation == 3) and 2 or 1 end,
							set = function(info, v)
								Display.db.profile.orientation = (v == 2) and 3 or 1
								Display:UpdateDisplay()
							end,
							order = 4,
							width = nil,
						},
					}
				},
			},
		},
		spells = {
			type = "group",
			name = L["Spell Options"],
			desc = L["Configure which spell cooldowns are shown and which aren't"],
			cmdHidden = true,
			args = {
				hideSelf = {
					type = "toggle",
					name = L["Hide Self"],
					desc = L["Hide your own cooldowns."],
					order = 1,
					get = function(info) return Display.db.profile.hideSelf end,
					set = function(info, v)
						Display.db.profile.hideSelf = v
					end,
					width = "full",
				},
				message = {
					type = "toggle",
					name = L["Ready Message"],
					desc = L["Print a chat message after a cooldown is ready."],
					order = 2,
					get = function(info) return Display.db.profile.readyMsg end,
					set = function(info, v)
						Display.db.profile.readyMsg = v
					end,
					width = "full",
				},
			},
		},
		config = {
			type = "execute",
			name = L["Configure"],
			desc = L["Open the configuration dialog"],
			func = Display.ShowConfig,
			guiHidden = true
		}
	}
}

do
	local classes = {"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}
	local t = options.args.spells.args
	local i = 5 -- Sorting
	local Display = Display
	
	for _, v in ipairs(classes) do
		-- Separate class spells with a header
		t[v] = {
			type = "header",
			name = L[v],
			cmdHidden = true,
			order = i,
		}
		i = i + 1
		
		-- Add an option entry for each spell
		for k2, v2 in pairs(RaidCooldowns.cooldowns[v]) do
			t[tostring(v2.id)] = {
				type = "toggle",
				name = k2,
				desc = L["Display %s cooldowns"]:format(k2),
				order = i,
				get = function(info) return Display.db.profile.spells[v2.id] end,
				set = function(info, val)
					Display.db.profile.spells[v2.id] = val
					Display:SpellToggle(v2.id, val)
				end,
				cmdHidden = true,
			}
			i = i + 1
		end
	end
end

Display.configOptions = options
LibStub("AceConfig-3.0"):RegisterOptionsTable(L["RaidCooldowns"], options, "rcd")