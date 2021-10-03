local Config = {}
local L = PurgeatoryLocals
local AceDialog, AceRegistry, options

local announceDest = {["ct"] = L["Combat text"], ["party"] = L["Party"], ["raid"] = L["Raid"], ["rw"] = L["Raid warning"], ["rwframe"] = L["Middle of screen"], ["say"] = L["Say"], ["1"] = string.format(L["Chat frame #%d"], 1), ["2"] = string.format(L["Chat frame #%d"], 2), ["3"] = string.format(L["Chat frame #%d"], 3), ["4"] = string.format(L["Chat frame #%d"], 4), ["5"] = string.format(L["Chat frame #%d"], 5), ["6"] = string.format(L["Chat frame #%d"], 6), ["7"] = string.format(L["Chat frame #%d"], 7)}
local localDest = {["ct"] = true, ["rwframe"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = true, ["7"] = true}

-- General option
local function loadOptions()
	options = {
		type = "group",
		name = "Purgeatory",
		args = {},
	}
	
	
	options.args.general = {
		order = 0,
		type = "group",
		name = L["General"],
		set = function(info, ...)
			local config = Purgeatory.db.profile[info[#(info)]]
			if( type(config) == "table" ) then
				local r, g, b = select(1, ...)
				config.r = r
				config.g = g
				config.b = b
				return
			end
			
			Purgeatory.db.profile[info[#(info)]] = select(1, ...)
		end,
		get = function(info)
			local config = Purgeatory.db.profile[info[#(info)]]
			if( type(config) == "table" ) then
				return config.r, config.g, config.b
			end
		
			return config
		end,
		args = {
			help = {
				order = 1,
				type = "group",
				inline = true,
				name = L["Help"],
				args = {
					help = {
						order = 1,
						type = "description",
						name = L["You can set what kind of dispels and interrupts to monitor in the zone category to the left. Spell steals are considered offensive dispels.\n\nFor announcement messages you have access to a few variables:\n*target - Name of the person the announcement is targeted on\n*spell - The spell that was removed or interrupted\n*used - The spell that was used to either remove or interrupt"],
					},
				},
			},
			general = {
				order = 2,
				type = "group",
				inline = true,
				name = L["General"],
				args = {
					showIcon = {
						order = 1,
						type = "toggle",
						name = L["Show icons in announcements"],
						desc = L["The spell icon will be shown at the start of the announcement, only used if the output is local."],
						width = "double",
					},
				},
			},
			dispel = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Dispels"],
				args = {
					dispelSuccessMsg = {
						order = 3,
						type = "input",
						name = L["Successful message"],
						desc = L["Message to show when a dispel is successful."],
						width = "full",
					},
					dispelFailMsg = {
						order = 4,
						type = "input",
						name = L["Failed message"],
						desc = L["Message to show when a dispel fails to remove anything."],
						width = "full",
					},
					dispelColor = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = L["Color to use for dispel announcements, only used if the output is local."],
					},
					dispelLocation = {
						order = 6,
						type = "select",
						name = L["Location"],
						desc = L["Announcement location for dispels."],
						values = announceDest,
					},
				},
			},
			interrupt = {
				order = 4,
				type = "group",
				inline = true,
				name = L["Interrupts"],
				args = {
					interruptMsg = {
						order = 8,
						type = "input",
						name = L["Message"],
						desc = L["Message to show when a spell is interrupted"],
						width = "full",
					},
					interruptColor = {
						order = 9,
						type = "color",
						name = L["Color"],
						desc = L["Color to use for interrupt announcements, only used if the output is local."],
					},
					interruptLocation = {
						order = 10,
						type = "select",
						name = L["Location"],
						desc = L["Announcement location for interrupts."],
						values = announceDest,
					},
				},
			},
			reflect = {
				order = 5,
				type = "group",
				inline = true,
				name = L["Reflects"],
				args = {
					reflectMsg = {
						order = 12,
						type = "input",
						name = L["Message"],
						desc = L["Message to show when a spell is reflected"],
						width = "full",
					},
					reflectColor = {
						order = 13,
						type = "color",
						name = L["Color"],
						desc = L["Color to use for reflect announcements, only used if the output is local."],
					},
					reflectLocation = {
						order = 14,
						type = "select",
						name = L["Location"],
						desc = L["Announcement location for reflects."],
						values = announceDest,
					},
				},
			},
			grounding = {
				order = 6,
				type = "group",
				inline = true,
				name = L["Groundings"],
				args = {
					groundingMsg = {
						order = 16,
						type = "input",
						name = L["Message"],
						desc = L["Message to show when a spell is grounded"],
						width = "full",
					},
					groundingColor = {
						order = 17,
						type = "color",
						name = L["Color"],
						desc = L["Color to use for grounding announcements, only used if the output is local."],
					},
					groundingLocation = {
						order = 18,
						type = "select",
						name = L["Location"],
						desc = L["Announcement location for groundings."],
						values = announceDest,
					},
				},
			},
		},
	}

	
	local globalSettings = {}
	local zoneList = {"none", "party", "pvp", "raid", "arena"}
	local function loadZoneSettings(type)
		return {
			order = type == "global" and 0 or type == "none" and 1 or 2,
			type = "group",
			name = L.zones[type] or L["Global"],
			inline = true,
			set = function(info, value)
				local zone = info[2]
				local key = info[#(info)]
				if( zone == "global" ) then
					globalSettings[key] = value
					
					for _, zoneType in pairs(zoneList) do
						Purgeatory.db.profile.zones[zoneType][key] = value
					end
				else
					Purgeatory.db.profile.zones[zone][key] = value
				end
				
				-- Might need to be enabled
				Purgeatory:Reload()
			end,
			get = function(info)
				local zone = info[2]
				local key = info[#(info)]
				if( zone == "global" ) then
					return globalSettings[key]
				end
				
				return Purgeatory.db.profile.zones[zone][key]
			end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable mod"],
					desc = L["Allows you to disable the mod entirely while inside this zone type."],
				},
				dispel = {
					order = 2,
					type = "header",
					name = L["Dispels"],
				},
				dispelFail = {
					order = 3,
					type = "toggle",
					name = L["Alert failed dispels"],
					desc = L["This only alerts for failed dispels if the parent type is enabled, it won't show defensive dispel failures if defensive dispels are disabled."],
				},
				sep = {
					order = 3.5,
					type = "description",
					name = "",
				},
				dispelOffensive = {
					order = 4,
					type = "toggle",
					name = L["Alert offensive dispels"],
					desc = L["Alerts when an offensive dispel is successful. Spell stealing is considered an offensive dispel."],
				},
				dispelDefensive = {
					order = 5,
					type = "toggle",
					name = L["Alert defensive dispels"],
					desc = L["Alerts when a defensive dispel is successful"],
				},
				interruptHeader = {
					order = 6,
					type = "header",
					name = L["Interrupts"],
				},
				interrupt = {
					order = 7,
					type = "toggle",
					name = L["Alert interrupts"],
					desc = L["Alerts when a spell is successfully interrupted. Sometimes a spell will be announced as interrupted but it will not actually be due to server timing."],
				},
				reflectHeader = {
					order = 8,
					type = "header",
					name = L["Reflects"],
				},
				reflect = {
					order = 9,
					type = "toggle",
					name = L["Alert reflects"],
					desc = L["Alerts when a spell is successfully reflected."],
				},
				groundingHeader = {
					order = 10,
					type = "header",
					name = L["Groundings"],
				},
				grounding = {
					order = 11,
					type = "toggle",
					name = L["Alert groundings"],
					desc = L["Alerts when a spell is successfully grounded."],
				},
			},
		}
	end
	
	options.args.zones = {
		order = 2,
		type = "group",
		name = L["Zones"],
		args = {
			global = loadZoneSettings("global"),
			none = loadZoneSettings("none"),
			arena = loadZoneSettings("arena"),
			pvp = loadZoneSettings("pvp"),
			party = loadZoneSettings("party"),
			raid = loadZoneSettings("raid"),
		},
	}
	
	-- DB Profiles
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Purgeatory.db)
	options.args.profile.order = 3
end

SLASH_PURGEATORY1 = "/purgeatory"
SlashCmdList["PURGEATORY"] = function(msg)
	AceDialog = LibStub("AceConfigDialog-3.0")
	AceRegistry = LibStub("AceConfigRegistry-3.0")

	if( not options ) then
		loadOptions()
	
		LibStub("AceConfig-3.0"):RegisterOptionsTable("Purgeatory", options)
		AceDialog:SetDefaultSize("Purgeatory", 650, 550)
	end

	AceDialog:Open("Purgeatory")
end
