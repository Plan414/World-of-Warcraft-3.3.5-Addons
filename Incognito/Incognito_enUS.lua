local L = LibStub("AceLocale-3.0"):NewLocale("Incognito", "enUS", true)

if not L then return end

L["Loaded"] = "Loaded."

L["name"] = "Name"
L["name_desc"] = "The name that should be displayed in your chat messages."

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."

L["guild"] = "Guild"
L["guild_desc"] = "Add name to guild chat messages."

L["party"] = "Party"
L["party_desc"] = "Add name to party chat messages."

L["raid"] = "Raid"
L["raid_desc"] = "Add name to raid chat messages."

L["config"] = "Configuration"
L["config_desc"] = "Open configuration dialog."

L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."
