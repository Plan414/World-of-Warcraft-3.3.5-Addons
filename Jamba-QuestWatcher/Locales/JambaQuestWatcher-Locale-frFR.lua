--[[
Jamba - Jafula's Awesome Multi-Boxer Assistant
Copyright 2008 - 2010 Michael "Jafula" Miller
All Rights Reserved
http://wow.jafula.com/addons/jamba/
jamba at jafula dot com
]]--
 
local L = LibStub("AceLocale-3.0"):NewLocale( "Jamba-QuestWatcher", "frFR" )
if L then
L["Slash Commands"] = true
L["Quest"] = "Quêtes"
L["Quest: Watcher"] = "Quêtes : suivi"
L["Quest Watcher"] = "Suivi de quêtes"
L["Push Settings"] = "Transférer"
L["Push the quest settings to all characters in the team."] = "Transférer les réglages de quête à tous les personnages de l'équipe"
L["Settings received from A."] = function( characterName )
    return string.format( "Réglages reçus de %s.", characterName )
end
L["N/A"] = "N/A"
L["Update"] = "Actualiser"
L["Border Colour"] = "Couleur de bordure"
L["Background Colour"] = "Couleur de fond"
L["<Map>"] = "Carte"
L["Lines Of Info To Display (Reload UI To See Change)"] = "Lignes à afficher (recharger l'interface pour actualiser)"
L["Quest Watcher Width (Reload UI To See Change)"] = "Largeur du suivi (recharger l'interface pour actualiser)"
L["DONE"] = "FAIT"
L["Unlock Quest Watcher Frame (To Move It)"] = "Débloquer le cadre de Suivi (pour le déplacer)"
L["Hide Blizzard's Objectives Watch Frame"] = "Cacher le cadre des Objectifs de Blizzard"
L["Show Completed Objectives As 'DONE'"] = "Montrer les objectifs réalisés comme 'FAIT'"
L["Do Not Hide Completed Objectives"] = "Ne pas cacher les objectifs réalisés"
L["Hide Quests Completed By Team"] = "Cacher les quêtes terminées par toute l'équipe"
L["Enable Team Quest Watcher"] = "Activer le suivi des quêtes"
L["Jamba Quest Watcher"] = "Suivi des quêtes de Jamba"
L["Blizzard Tooltip"] = true
L["Blizzard Dialog Background"] = true
L["Hide Quest Watcher In Combat"] = "Cacher le suivi en combat"
L["Show Team Quest Watcher On Master Only"] = "Afficher le suivi sur le maître seulement"
L["Border Style"] = "Style de bordure"
L["Transparency"] = "Transparence"
L["Scale"] = "Echelle"
L["Background"] = "Fond"
L["Show Quest Watcher"] = true
L["Show the quest watcher window."] = true
L["Hide Quest Watcher"] = true
L["Hide the quest watcher window."] = true
L["Send Message Area"] = true
L["Send Progress Messages To Message Area"] = true
end
