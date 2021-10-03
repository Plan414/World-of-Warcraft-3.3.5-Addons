if ( GetLocale() ~= "enUS" ) then return end

local addon, ns = ...
ns.L = {
	-- Core Globals
	["Combat Fade"] = "Combat Fade",
	["Class Colored"] = "Class Colored",
	["Global Font Size"] = "Global Font Size",
	["ProfDesc"] = "Create new or copy existing profiles. Default profiles set to character.",
	["ProfResDesc"] = "Reset Profile",
	["ProfNew"] = "New",
	["ProfReset"] = "Reset",
	["ProfCurrent"] = "Current",
	["ProfCopy"] = "Copy",
	["ProfDel"] = "Delete",
	["/sldt"] = "/sldt",
	["Command List"] = "Command List",
	["config"] = "config",
	["Toggle Configuration Mode"] = "Toggle Configuration Mode",
	["Configuration Mode"] = "Configuration Mode",
	["active"] = "active",
	["inactive"] = "inactive",
	["global"] = "global",
	["Open SLDataText Global Menu"] = "Open SLDataText Global Menu",
	["<module>"] = "<module>",
	["Open Module Option Menu"] = "Open Module Option Menu",
	["Loaded Modules"] = "Loaded Modules",
	["TTScale"] = "SLToolTip Scale",
	
	-- Common
	["Enabled"] = "Enabled",
	["Global Font"] = "Global Font",
	["Outline"] = "Outline",
	["Force Shown"] = "Force Shown",
	["Tooltip On"] = "Tooltip On",
	["Font Size"] = "Font Size",
	["Font"] = "Font",
	["Justify"] = "Justify",
	["Parent"] = "Parent",
	["Anchor"] = "Anchor",
	["X Offset"] = "X Offset",
	["Y Offset"] = "Y Offset",
	["Frame Strata"] = "Frame Strata",
	["Update Interval"] = "Update Interval",
	["On"] = "On",
	["Off"] = "Off",
	["Prefix"] = "Prefix",
	["Prefix Text"] = "Prefix Text",
	["Suffix"] = "Suffix",
	["Suffix Text"] = "Suffix Text",
	["Left-Click"] = "Left-Click",
	["Right-Click"] = "Right-Click",
	["Show Icon"] = "Show Icon",
	["Show Text"] = "Show Text",
	["Text Display"] = "Text Display",
	
	-- Armor Module
	["Armor"] = "Armor",
	["All Items"] = "All Items",
	["Auto Repair"] = "Auto Repair",
	["Use Guild Bank"] = "Use Guild Bank",
	["Armor"] = "Armor",
	["AutoRepairLine"] = "Items repaired for",
	["GFAutoRepairLine"] = "Items repaired for (Guild Funds)",
	["ArmorTextDesc"] = "Tags for Text Display: [Dur] = Current Durability",
	
	-- Bag Module
	["Bag Info"] = "Bag Info",
	["Space Used"] = "Space Used",
	["Space Avail"] = "Space Avail",
	["Space Left"] = "Space Left",
	["AutoSell Junk"] = "AutoSell Junk",
	["JunkSoldLine"] = "Junk Sold Earned",
	["Toggle Bags"] = "Toggle Bags",
	["BagTextDesc"] = "Tags for Text Display: [T] = Total, [R] = Remaining, [U] = Used",
	
	-- Clock Module
	["Toggle Calendar"] = "Toggle Calendar",
	["Toggle Time Manager"] = "Toggle Time Manager",
	["Queued for:"] = "Queued for:",
	["Realm Time"] = "Realm Time",
	["24 Hour"] = "24 Hour",
	["PvP Info"] = "PvP Info",
	["Time String"] = "Time String",
	["ClockDesc"] = "Visit http://www.lua.org/pil/22.1.html for a full list of clock tags. Turn 'Correct Hour' option off if hour tag is not first in the time string.",
	["CorrHour"] = "Correct Hour",
	
	-- Coords Module
	["Precision"] = "Precision",
	
	-- Currency Module
	["Currency"] = "Currency",
	["No Currency"] = "No Currency",
	["Click to set display currency."] = "Click to set display currency.",
	["Display Currency"] = "Display Currency",
	
	-- Exp Module
	["Max Level Hide"] = "Max Level Hide",
	["Exp"] = "Exp",
	["ExpTextDesc"] = "Tags for Text Display: [Cur] = Current XP, [Max] = Max XP, [Rem] = Remaining XP, [Per] = XP Percent, [PerR] = XP Remaining Percent, [R] = Rest XP, [RP] = Rest XP Percent",
	
	-- FPS Module
	["fps"] = "fps",
	["FPSTextDesc"] = "Tags for Text Display: [F] = Current FPS",
	
	-- Gold Module
	["Wallet"] = "Wallet",
	["Current"] = "Current",
	["Session Start"] = "Session Start",
	["Session Earned"] = "Session Earned",
	["Server Gold"] = "Server Gold",
	["Horde"] = "Horde",
	["Alliance"] = "Alliance",
	["Total Gold"] = "Total Gold",
	["Display Style"] = "Display Style",
	["Alt Money"] = "Alt Money",
	["ResetData"] = "Reset Data",
	
	-- Latency Module
	["Latency"] = "Latency",
	["Bandwidth In"] = "Bandwidth In",
	["Bandwidth Out"] = "Bandwidth Out",
	["Latency (Home)"] = "Latency (Home)",
	["Latency (World)"] = "Latency (World)",
	["ms"] = "ms",
	["LagTextDesc"] = "Tags for Text Display: [L] = Current Latency",
	
	-- Mail Module
	["No Mail"] = "No Mail",
	["Mail!"] = "Mail!",
	["AH Alert!"] = "AH Alert!",
	["Play Sounds"] = "Play Sounds",
	
	-- Memory Module
	["AddOn Memory"] = "AddOn Memory",
	["Showing Top 15 AddOns"] = "Showing Top 15 AddOns",
	["Total AddOn Memory"] = "Total AddOn Memory",
	["Total UI Memory Usage"] = "Total UI Memory Usage",
	["Hover"] = "Hover",
	["Show only top AddOns"] = "Show only top AddOns",
	["Alt+Hover"] = "Alt+Hover",
	["Show all AddOns"] = "Show all AddOns",
	["Collect Garbage"] = "Collect Garbage",
	["mb"] = "mb",
	["MemTextDesc"] = "Tags for Text Display: [MA] = Addon Memory, [MT] = Total Memory",
	
	-- Reputation Module
	["Reputation"] = "Reputation",
	["No Reputation"] = "No Reputation",
	["Click to set display reputation."] = "Click to set display reputation.",
	["Display Reputation"] = "Display Reputation",
	["Hated"] = "Hated",
	["Hostile"] = "Hostile",
	["Unfriendly"] = "Unfriendly",
	["Neutral"] = "Neutral",
	["Friendly"] = "Friendly",
	["Honored"] = "Honored",
	["Revered"] = "Revered",
	["Exalted"] = "Exalted",
}