--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--

local L = LibStub("AceLocale-3.0"):NewLocale( "Jamba-Trade", "koKR" )
if L then
L["Slash Commands"] = true
L["Interaction"] = true
L["Trade"] = true
L["Trade Options"] = true
L["Push Settings"] = true
L["Push the trade settings to all characters in the team."] = true
L["Settings received from A."] = function( characterName )
	return "Settings received from "..characterName.."."
end
L["Message Area"] = true
L["Load Item By Name"] = true
L["Load a certain amount of an item by name into the trade window."] = true
L["Load Items By Type"] = true
L["Load items by type into the trade window."] = true
L["Load Mine"] = true
L["Load Theirs"] = true
L["Jamba-Trade: Please provide a class and a subclass seperated by a comma for the loadtype command."] = true
L["Jamba-Trade: Please provide a name and an amount seperated by a comma for the loadname command."] = true
L["!Single Item"] = true
L["Show Jamba Trade Window On Trade"] = true
L["Adjust Toon Money While Visiting The Guild Bank"] = true
L["Amount of Gold"] = true
L["!Quality"] = true
L["0. Poor (gray)"] = true
L["1. Common (white)"] = true
L["2. Uncommon (green)"] = true
L["3. Rare / Superior (blue)"] = true
L["4. Epic (purple)"] = true
L["5. Legendary (orange)"] = true
L["6. Artifact (golden yellow)"] = true
L["7. Heirloom (light yellow)"] = true
L["Unknown"] = true
L["Ignore Soulbound"] = true
end
