--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--

local L = LibStub("AceLocale-3.0"):NewLocale( "Jamba-QuestWatcher", "ruRU" )
if L then
L["Slash Commands"] = true
L["Quest"] = true
L["Quest: Watcher"] = true
L["Quest Watcher"] = true
L["Push Settings"] = true
L["Push the quest settings to all characters in the team."] = true
L["Settings received from A."] = function( characterName )
	return string.format( "Settings received from %s.", characterName )
end
L["N/A"] = true
L["Update"] = true
L["Border Colour"] = true
L["Background Colour"] = true
L["<Map>"] = true
L["Lines Of Info To Display (Reload UI To See Change)"] = true
L["Quest Watcher Width (Reload UI To See Change)"] = true
L["DONE"] = true
L["Unlock Quest Watcher Frame (To Move It)"] = true
L["Hide Blizzard's Objectives Watch Frame"] = true
L["Show Completed Objectives As 'DONE'"] = true
L["Do Not Hide Completed Objectives"] = true
L["Hide Quests Completed By Team"] = true
L["Enable Team Quest Watcher"] = true
L["Jamba Quest Watcher"] = true
L["Blizzard Tooltip"] = true
L["Blizzard Dialog Background"] = true
L["Hide Quest Watcher In Combat"] = true
L["Show Team Quest Watcher On Master Only"] = true
L["Border Style"] = true
L["Transparency"] = true
L["Scale"] = true
L["Background"] = true
L["Show Quest Watcher"] = true
L["Show the quest watcher window."] = true
L["Hide Quest Watcher"] = true
L["Hide the quest watcher window."] = true
L["Send Message Area"] = true
L["Send Progress Messages To Message Area"] = true
end
